# Contrato de datos PolyFlow

Contratos **reales implementados**. Si se modifica alguna etapa, actualizar este documento.

## 1. data/datos_crudos.csv → BASIC-256
```
ID,STATION,TEMPERATURE,PRECIPITATION,WIND,BATTERY
001,COTO,28.5,12.3,15.2,87
```
Puede contener campos vacíos, valores fuera de rango y IDs duplicados.

## 2. data/datos_normalizados.csv → FORTRAN
Encabezado idéntico al de entrada. Solo registros válidos:
sin campos faltantes, valores dentro de rango, sin IDs duplicados.

## 3. data/metricas.csv → COBOL (una fila por estación)
```
ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM
COTO,28.50,28.50,28.50,12.3,15.20,15.20,87.0
```

## 4. data/alertas.csv → MIPS (una fila por alerta disparada)
```
ESTACION,IDENTIFICADOR,OPERADOR,UMBRAL,VALOR
GOLFITO,LLUVIA_INTENSA,>,50.0000,110.0000
```

## 5. data/secuencia.txt → MIPS (una línea)
Identificadores disparados en orden, separados por coma:
```
LLUVIA_INTENSA,VIENTO_FUERTE,BATERIA_BAJA,TEMP_ALTA
```
Si no hay alertas se escribe `SIN_ALERTAS`.

## 6. data/checksum.txt → resultado final
```
CHECKSUM=00000060
```
8 dígitos hexadecimales en mayúsculas. Algoritmo oficial: ver `docs/CHECKSUM.md`.

