# MIPS · Etapa 4 — Verificación de integridad (checksum)

## Rol en el pipeline

Consume la secuencia de alertas generada por COBOL y produce la firma de
integridad final del pipeline.

## Entrada

`data/secuencia.txt` — identificadores de alerta separados por coma
(una línea), o `SIN_ALERTAS`:
```
LLUVIA_INTENSA,BATERIA_BAJA,TEMP_ALTA
```

## Salida

`data/checksum.txt`:
```
CHECKSUM=00000060
```
`CHECKSUM=` + 8 dígitos hexadecimales en mayúsculas + salto de línea
(18 bytes exactos).

## Algoritmo (según el enunciado)

Cada identificador tiene un valor numérico fijo:

| Identificador | Valor |
|---|---|
| TEMP_ALTA | 10 |
| LLUVIA_INTENSA | 20 |
| VIENTO_FUERTE | 30 |
| BATERIA_BAJA | 40 |

Para cada identificador de la secuencia, en orden (posición desde 0):

```
checksum = checksum + valor
checksum = checksum XOR posicion
```

Ejemplo con `LLUVIA_INTENSA,VIENTO_FUERTE,BATERIA_BAJA,TEMP_ALTA`:
`(0+20)^0=20` → `(20+30)^1=51` → `(51+40)^2=93` → `(93+10)^3=96`
→ `CHECKSUM=00000060`. Detalle completo en [../docs/CHECKSUM.md](../docs/CHECKSUM.md).

## Implementación (`checksum.asm`, MIPS32 / syscalls MARS)

- Lee el archivo completo con la syscall 14 a un buffer de 4096 bytes.
- Tokeniza por delimitadores `,` (44), LF (10) y CR (13).
- Compara cada token contra la tabla de identificadores
  (`TEMP_ALTA`, `LLUVIA_INTENSA`, `VIENTO_FUERTE`, `BATERIA_BAJA`);
  los tokens desconocidos se ignoran.
- Acumula el checksum en `$s0` y la posición en `$s1`.
- Convierte el resultado a hexadecimal con la tabla `0123456789ABCDEF`
  y escribe 18 bytes con la syscall 15.

**Importante**: las rutas `data/secuencia.txt` y `data/checksum.txt` son
relativas; ejecutar siempre desde la raíz del repositorio (como hacen
`PolyFlow.bat` y `run_pipeline.sh`).

## Ejecución en simulador

Con MARS (incluido en `tools/Mars4_5.jar`, autodetectado por
`scripts/config.bat`):
```batch
java -jar tools\Mars4_5.jar nc mips\checksum.asm
```

Con una instalación propia de MARS u otro simulador:
```batch
java -jar "%MIPS_MARS_JAR%" nc mips\checksum.asm
```

Con QtSPIM (alternativa soportada por los orquestadores):
```batch
"%MIPS_SIMULATOR%" -file mips\checksum.asm
```

## Referencias

- [DATA_CONTRACT.md](../docs/DATA_CONTRACT.md) — secciones 5-6
- [CHECKSUM.md](../docs/CHECKSUM.md) — especificación y ejemplo paso a paso
- [GRAMMAR.md](../docs/GRAMMAR.md) — identificadores válidos
