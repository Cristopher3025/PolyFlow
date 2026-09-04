# FORTRAN · Etapa 2 — Procesamiento numérico (métricas)

## Rol en el pipeline

Recibe `data/datos_normalizados.csv` (producido por BASIC-256), agrupa por
estación y calcula las métricas que consume el motor de reglas (COBOL).

## Entrada

`data/datos_normalizados.csv`:
```
ID,STATION,TEMPERATURE,PRECIPITATION,WIND,BATTERY
```
Solo registros válidos: sin campos vacíos, valores en rango, sin IDs
duplicados (garantía de la Etapa 1).

## Salida

`data/metricas.csv` — una fila por estación:
```
ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM
COTO,31.00,36.00,31.00,6.00,21.50,25.00,79.00
```

## Métricas calculadas

| Columna | Métrica del enunciado |
|---|---|
| TEMP_PROM | Temperatura promedio |
| TEMP_MAX | Temperatura máxima |
| TEMP_MIN | Temperatura mínima |
| LLUVIA_TOTAL | Precipitación acumulada |
| VIENTO_PROM | Viento promedio |
| VIENTO_MAX | Viento máximo |
| BATERIA_PROM | Batería promedio |

## Implementación (`procesamiento.f90`, estándar Fortran 2008)

- Arrays de tamaño fijo para registros y estaciones (dataset académico).
- Agrupación por nombre de estación; comparación de cadenas insensible a
  mayúsculas no requerida (los nombres vienen normalizados).
- Cálculos en `REAL(KIND=8)`; formato de salida con 2 decimales.
- Errores de apertura de archivo detienen el programa con mensaje claro
  y código de salida distinto de 0.

## Compilación y ejecución

Igual que en `PolyFlow.bat` / `run_pipeline.sh` (desde la raíz del repo):

```batch
gfortran -std=f2008 -Wall -Wextra -O2 -o bin\polyflow_metrics.exe fortran\procesamiento.f90
bin\polyflow_metrics.exe
```

```bash
gfortran -std=f2008 -Wall -Wextra -O2 -o bin/polyflow_metrics fortran/procesamiento.f90
./bin/polyflow_metrics
```

## Referencias

- [DATA_CONTRACT.md](../docs/DATA_CONTRACT.md) — secciones 2-3
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) — vista general del pipeline
- Datos de prueba: `tests/datos_prueba.csv`
