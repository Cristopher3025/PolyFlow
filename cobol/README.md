# COBOL · Etapa 3 — Motor de reglas (alertas)

## Rol en el pipeline

Recibe `data/metricas.csv` (producido por FORTRAN) y `input/reglas.txt`,
evalúa las reglas por estación y produce `data/alertas.csv` +
`data/secuencia.txt` (consumidos por MIPS).

## Entradas

### `data/metricas.csv`
```
ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM
COTO,31.00,36.00,31.00,6.00,21.50,25.00,79.00
```

### `input/reglas.txt`
Mini-lenguaje oficial (ver [../docs/GRAMMAR.md](../docs/GRAMMAR.md)):
```
TEMP_ALTA > 35
LLUVIA_INTENSA > 50
VIENTO_FUERTE > 40
BATERIA_BAJA < 20
```
- Comentarios con `#`, una regla por línea, máximo 50 reglas.
- Si el archivo no existe, se cargan las 4 reglas anteriores por defecto.

## Salidas

### `data/alertas.csv`
```
ESTACION,IDENTIFICADOR,OPERADOR,UMBRAL,VALOR
GOLFITO,LLUVIA_INTENSA,>,50.0000,110.0000
```

### `data/secuencia.txt`
Una línea con los identificadores disparados en orden (o `SIN_ALERTAS`):
```
LLUVIA_INTENSA,BATERIA_BAJA
```

## Mapeo identificador → columna de métrica

| Identificador | Columna | Comparación |
|---|---|---|
| TEMP_ALTA | TEMP_MAX | `>` |
| LLUVIA_INTENSA | LLUVIA_TOTAL | `>` |
| VIENTO_FUERTE | VIENTO_MAX | `>` |
| BATERIA_BAJA | BATERIA_PROM | `<` |

(El operador real se toma de la regla; la tabla anterior es la semántica
esperada del archivo demo.)

## Implementación (`rules_engine.cob`, GnuCOBOL)

- Carga de reglas: tokenización manual por espacios; el número se valida
  con `FUNCTION TEST-NUMVAL` (acepta decimales); reglas inválidas se
  reportan con línea y se cuentan (`INVALID-RULES-COUNT`).
- Lectura de métricas: parser CSV propio (campos `PIC X(…)`, conversión
  numérica con `FUNCTION NUMVAL`).
- Evaluación: por cada estación, se recorren las reglas en orden de
  archivo; cada regla dispara a lo sumo una alerta por estación.
- Escritura: `alertas.csv` (LINE SEQUENTIAL) y `secuencia.txt`.

## Compilación y ejecución

Igual que en `PolyFlow.bat` / `run_pipeline.sh` (desde la raíz del repo):

```batch
cobc -x -free -Wall -o bin\polyflow_rules.exe cobol\rules_engine.cob
bin\polyflow_rules.exe
```

```bash
cobc -x -free -Wall -o bin/polyflow_rules cobol/rules_engine.cob
./bin/polyflow_rules
```

## Referencias

- [DATA_CONTRACT.md](../docs/DATA_CONTRACT.md) — secciones 3-5
- [GRAMMAR.md](../docs/GRAMMAR.md) — gramática oficial
- [CHECKSUM.md](../docs/CHECKSUM.md) — cómo MIPS consume `secuencia.txt`
