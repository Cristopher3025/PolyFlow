# Solución de problemas (Troubleshooting)

Problemas comunes al ejecutar el pipeline PolyFlow y su solución.
Todos los comandos se ejecutan desde la raíz del repositorio.

---

## 1. `[ERROR] Missing data\datos_crudos.csv`

El archivo de entrada no existe. Verificar que `data/datos_crudos.csv`
exista con el encabezado:
`ID,STATION,TEMPERATURE,PRECIPITATION,WIND,BATTERY`.

## 2. FORTRAN: `gfortran` no se reconoce como comando

- Instalar gfortran (MSYS2/MinGW-w64). `scripts/config.bat` antepone
  automáticamente `C:\msys64\ucrt64\bin` al `PATH` si existe; para otra
  instalación ajustar esa línea o definir `FORTRAN_COMPILER` con la ruta
  completa.
- Verificar con: `gfortran --version`
- Si el `.exe` compila pero al ejecutarlo falla con error `0xC0000139`,
  ver la sección 11 (el pipeline ya compila con `-static` para evitarlo).

## 3. COBOL: `cobc` no se reconoce como comando

- Instalar GnuCOBOL y agregar la carpeta `bin` al `PATH`, o definir
  `COBOL_COMPILER` en `scripts/config.bat`.
- Verificar con: `cobc --version`
- Si compila pero el `.exe` falla al iniciar, falta el directorio `bin` de
  GnuCOBOL en el `PATH` (DLLs en tiempo de ejecución).

## 4. BASIC-256: la etapa 1 falla o `basic256` no se reconoce

- `scripts/config.bat` autodetecta la instalación estándar
  (`C:\Program Files (x86)\BASIC256\basic256.exe`); para otra ruta definir
  `BASIC256_EXE` antes de ejecutar el pipeline.
- El orquestador ejecuta `basic256.exe -r limpieza.kbs` (ejecución en modo
  texto). Probado con la versión 0.9.6.68:
  - No existen `map`, `for each` ni `instrx` (regex): `limpieza.kbs`
    está escrito sin esas funciones a propósito.
  - Los arreglos se indexan con corchetes: `campos$[0]`.
  - Las comillas dentro de literales se escapan con `\"`.
- Alternativa manual: abrir `basic256/limpieza.kbs` en el IDE, ejecutarlo
  y verificar que se genere `data/datos_normalizados.csv`.

## 5. MIPS: `[ERROR] Configure MIPS_MARS_JAR or MIPS_SIMULATOR`

- Definir en `scripts/config.bat`:
  - `SET "MIPS_MARS_JAR=C:\ruta\a\Mars.jar"` (requiere Java en el `PATH`), o
  - `SET "MIPS_SIMULATOR=C:\ruta\a\QtSPIM.exe"`
- MARS ya viene incluido en el repositorio (`tools/Mars4_5.jar`); si la
  variable no está definida, `scripts/config.bat` lo autodetecta.
  (El sitio original de Missouri State está fuera de línea; por eso el
  jar se versiona en `tools/`.)
- El `.asm` usa rutas relativas (`data/secuencia.txt`): ejecutar siempre
  desde la raíz del repositorio (los orquestadores ya lo hacen).

## 6. `ERROR: Cannot open input file data/datos_normalizados.csv` (FORTRAN)

La etapa 1 no se ejecutó o no generó salida. Ejecutar primero BASIC-256.
Cada etapa requiere el archivo de la etapa anterior.

## 7. COBOL reporta reglas inválidas

El mini-lenguaje exige exactamente 3 tokens: identificador, operador y
número (p. ej. `TEMP_ALTA > 35`). Verificar:
- Identificadores válidos: `TEMP_ALTA`, `LLUVIA_INTENSA`, `VIENTO_FUERTE`, `BATERIA_BAJA`.
- Operadores válidos: `>`, `<`, `>=`, `<=`.
- Números sin espacios internos (`50` o `50.0`, no `5 0`).
Ver [GRAMMAR.md](GRAMMAR.md).

## 8. `checksum.txt` vacío o con formato inválido

- Confirmar que `data/secuencia.txt` contiene identificadores válidos
  separados por coma (o `SIN_ALERTAS`).
- El formato esperado es `CHECKSUM=XXXXXXXX` (8 hex mayúsculas); los
  orquestadores lo validan con `FINDSTR`/`grep`.
- Nota (Windows): MARS escribe con saltos de línea LF (unix) y `FINDSTR /X`
  falla contra archivos LF-only; el `.bat` normaliza la línea a un archivo
  temporal CRLF antes de validarla. No "simplificar" esa parte.
- Verificar el resultado manualmente con el script de
  [CHECKSUM.md](CHECKSUM.md) (verificación cruzada en Python).

## 9. Acentos/`ñ` deformados en la consola de Windows

Los mensajes del `.bat` evitan acentos a propósito (codepage de cmd.exe).
No es un error del pipeline. En PowerShell/WSL la salida UTF-8 se ve correcta.

## 10. Archivos intermedios viejos (`metrics.csv`, `alerts.csv`, `sequence.txt`)

Los nombres oficiales son `metricas.csv`, `alertas.csv` y `secuencia.txt`
(ver [DATA_CONTRACT.md](DATA_CONTRACT.md)). Los orquestadores borran los
artefactos obsoletos al inicio de cada ejecución; eliminar manualmente
cualquier resto y no crearlos a mano.

## 11. Error `0xC0000139` al ejecutar `polyflow_metrics.exe`

El exe se compiló dinámicamente y las DLL de gfortran (`libgcc`, `libgfortran`,
`libwinpthread`) no están en el `PATH` del proceso. El repositorio ya lo
resuelve con dos medidas: compilar con `-static` (`FORTRAN_FLAGS` en
`scripts/config.bat`) y anteponer `C:\msys64\ucrt64\bin` al `PATH` en ese
mismo script.

## 12. `IF ERRORLEVEL 1` no detecta un crash del programa

En cmd.exe, `IF ERRORLEVEL 1` solo es verdadero con códigos >= 1; un programa
que crashea puede terminar con código negativo (p. ej. `-1073741511` =
`0xC0000139`) y la comprobación no se activa. Por eso los orquestadores
validan el resultado real de cada etapa mediante sus archivos de salida
además del código de retorno.
