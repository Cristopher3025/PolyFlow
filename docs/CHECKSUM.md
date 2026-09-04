# Algoritmo de checksum (oficial · MIPS)

Este documento define el algoritmo de verificación de integridad que
implementa la Etapa 4 (`mips/checksum.asm`), tal como lo exige el enunciado.

---

## Entrada

`data/secuencia.txt`: identificadores de alerta separados por coma
(producido por COBOL), por ejemplo:

```
LLUVIA_INTENSA,VIENTO_FUERTE,BATERIA_BAJA,TEMP_ALTA
```

Si no hubo alertas, la secuencia es la literal `SIN_ALERTAS`.

## Tabla de conversión (fija, definida en el enunciado)

| Identificador | Valor numérico |
|---------------|----------------|
| TEMP_ALTA | 10 |
| LLUVIA_INTENSA | 20 |
| VIENTO_FUERTE | 30 |
| BATERIA_BAJA | 40 |
| SIN_ALERTAS | 0 (sin contribución) |

## Algoritmo

Para cada identificador `i` de la secuencia (posiciones desde 0):

```
checksum = checksum + valor(i)
checksum = checksum XOR posicion
```

`valor(i)` proviene de la tabla de conversión y `posicion` es el índice
del identificador dentro de la secuencia (0, 1, 2, ...). La operación
XOR se aplica sobre registros de 32 bits; el checksum final es el valor
de 32 bits resultante.

## Ejemplo de cálculo

Secuencia: `LLUVIA_INTENSA,VIENTO_FUERTE,BATERIA_BAJA,TEMP_ALTA`

| Posición | Identificador | Valor | checksum = (checksum + valor) XOR pos |
|----------|---------------------|-------|----------------------------------------|
| 0 | LLUVIA_INTENSA | 20 | (0 + 20) XOR 0 = 20 (0x14) |
| 1 | VIENTO_FUERTE | 30 | (20 + 30) XOR 1 = 51 (0x33) |
| 2 | BATERIA_BAJA | 40 | (51 + 40) XOR 2 = 93 (0x5D) |
| 3 | TEMP_ALTA | 10 | (93 + 10) XOR 3 = 96 (0x60) |

Salida en `data/checksum.txt`:

```
CHECKSUM=00000060
```

## Salida

- Archivo: `data/checksum.txt`
- Formato: `CHECKSUM=XXXXXXXX`
- `XXXXXXXX`: 8 dígitos hexadecimales en **mayúsculas** (valor de 32 bits con
  relleno de ceros a la izquierda).

## Propiedades

- **Determinista**: la misma secuencia produce siempre el mismo checksum.
- **Sensible al orden**: dos secuencias con los mismos identificadores en
  distinto orden producen checksums distintos (por el XOR de posición).
- **Sensible al contenido**: cambiar un identificador cambia su valor y,
  por lo tanto, el checksum.

## Verificación cruzada

El mismo cálculo puede reproducirse fuera del simulador (p. ej. Python):

```python
vals = {"TEMP_ALTA": 10, "LLUVIA_INTENSA": 20,
        "VIENTO_FUERTE": 30, "BATERIA_BAJA": 40}
seq = open("data/secuencia.txt").read().strip().split(",")
c = 0
for pos, ident in enumerate(seq):
    c = (c + vals.get(ident, 0)) ^ pos
print(f"CHECKSUM={c:08X}")
```

## Referencias

- [DATA_CONTRACT.md](DATA_CONTRACT.md) — formato de `secuencia.txt` y `checksum.txt`
- [gramatica.md](gramatica.md) / [GRAMMAR.md](GRAMMAR.md) — identificadores válidos
