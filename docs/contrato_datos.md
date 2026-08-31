# Contrato de datos PolyFlow

## 1. datos_crudos.csv
ID,ESTACION,TEMPERATURA,PRECIPITACION,VIENTO,BATERIA

## 2. datos_normalizados.csv
Misma estructura que la entrada, pero solo registros válidos y normalizados.

## 3. metricas.csv
Definir columnas finales antes de integrar. Propuesta: ESTACION,PROM_TEMP,MAX_TEMP,MIN_TEMP,TOTAL_PRECIP,PROM_VIENTO,PROM_BATERIA

## 4. alertas.csv
Definir columnas finales antes de integrar. Propuesta: ESTACION,REGLA,ALERTA,VALOR

## 5. checksum.txt
CHECKSUM=<valor>
