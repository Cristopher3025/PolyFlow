#!/bin/bash

# ============================================================================
# PolyFlow - Pipeline Orchestrator
# BASIC-256 -> FORTRAN -> COBOL -> MIPS
# ============================================================================

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DATA_DIR="$ROOT_DIR/data"
BIN_DIR="$ROOT_DIR/bin"

mkdir -p "$BIN_DIR"

BASIC256_CMD="${BASIC256_CMD:-basic256}"
FORTRAN_COMPILER="${FORTRAN_COMPILER:-gfortran}"
COBOL_COMPILER="${COBOL_COMPILER:-cobc}"
MARS_JAR="${MARS_JAR:-}"
MIPS_SIMULATOR="${MIPS_SIMULATOR:-}"

fail() {
    echo "[ERROR] $1" >&2
    echo "PIPELINE ABORTED"
    exit 1
}

require_file() {
    [[ -f "$1" ]] || fail "Required file not found: $1"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || \
        fail "Required command not found: $1"
}

require_file "$DATA_DIR/datos_crudos.csv"
require_file "basic256/limpieza.kbs"
require_file "fortran/procesamiento.f90"
require_file "cobol/rules_engine.cob"
require_file "mips/checksum.asm"
require_file "input/reglas.txt"

rm -f \
    "$DATA_DIR/datos_normalizados.csv" \
    "$DATA_DIR/metricas.csv" \
    "$DATA_DIR/alertas.csv" \
    "$DATA_DIR/secuencia.txt" \
    "$DATA_DIR/checksum.txt"

printf '%s\n' "========================================================================"
printf '%s\n' "PolyFlow Environmental Data Processing Pipeline"
printf '%s\n' "========================================================================"
printf '\n'


# ============================================================================
# STAGE 1 - BASIC-256
# ============================================================================

printf '%s' "[BASIC-256] Procesando datos... "

require_command "$BASIC256_CMD"

# BASIC-256 opens its IDE and does NOT exit after -r:
# launch detached, wait for the output file, then close the IDE.
(
    cd basic256 &&
    "$BASIC256_CMD" -r limpieza.kbs &
)

BASIC_TRIES=0
while [ ! -f "$DATA_DIR/datos_normalizados.csv" ] && [ "$BASIC_TRIES" -lt 30 ]; do
    sleep 1
    BASIC_TRIES=$((BASIC_TRIES + 1))
done

pkill -f basic256 2>/dev/null || true

require_file "$DATA_DIR/datos_normalizados.csv"

echo "OK"
echo


# ============================================================================
# STAGE 2 - FORTRAN
# ============================================================================

printf '%s' "[FORTRAN] Calculando métricas... "

require_command "$FORTRAN_COMPILER"

"$FORTRAN_COMPILER" \
    -std=f2008 \
    -Wall \
    -Wextra \
    -O2 \
    -o "$BIN_DIR/polyflow_metrics" \
    fortran/procesamiento.f90 \
    || fail "FORTRAN compilation failed"

"$BIN_DIR/polyflow_metrics" \
    || fail "FORTRAN execution failed"

require_file "$DATA_DIR/metricas.csv"

echo "OK"
echo


# ============================================================================
# STAGE 3 - COBOL
# ============================================================================

printf '%s' "[COBOL] Evaluando reglas... "

require_command "$COBOL_COMPILER"

"$COBOL_COMPILER" \
    -x \
    -free \
    -Wall \
    -o "$BIN_DIR/polyflow_rules" \
    cobol/rules_engine.cob \
    || fail "COBOL compilation failed"

"$BIN_DIR/polyflow_rules" \
    || fail "COBOL execution failed"

require_file "$DATA_DIR/alertas.csv"
require_file "$DATA_DIR/secuencia.txt"

echo "OK"
echo


# ============================================================================
# STAGE 4 - MIPS
# ============================================================================

printf '%s' "[MIPS] Calculando firma... "

if [[ -n "$MARS_JAR" ]]; then

    [[ -f "$MARS_JAR" ]] || \
        fail "MARS JAR not found: $MARS_JAR"

    require_command java

    java -jar "$MARS_JAR" nc mips/checksum.asm \
        || fail "MIPS/MARS execution failed"

elif [[ -n "$MIPS_SIMULATOR" ]]; then

    require_command "$MIPS_SIMULATOR"

    "$MIPS_SIMULATOR" -file mips/checksum.asm \
        || fail "MIPS simulator execution failed"

else

    fail "Configure MARS_JAR or MIPS_SIMULATOR to execute the MIPS stage"

fi

require_file "$DATA_DIR/checksum.txt"

grep -Eq '^CHECKSUM=[0-9A-F]{8}$' \
    "$DATA_DIR/checksum.txt" \
    || fail "Invalid checksum.txt format"

echo "OK"
echo

printf '%s\n' "========================================================================"
printf '%s\n' "PIPELINE COMPLETADO"
printf '%s\n' "========================================================================"
