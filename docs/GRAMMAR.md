# Gramática del mini-lenguaje de reglas (oficial)

Este documento define la gramática formal que interpreta el motor de reglas
(Etapa 3, `cobol/rules_engine.cob`). El archivo de reglas es `input/reglas.txt`.

---

## Gramática formal (BNF)

```
<archivo_reglas> ::= <linea>*
<linea>          ::= <comentario> | <regla> | <linea_vacia>
<comentario>     ::= "#" <texto_libre>
<regla>          ::= <identificador> <operador> <numero>
<operador>       ::= ">" | "<" | ">=" | "<="
<identificador>  ::= "TEMP_ALTA" | "LLUVIA_INTENSA"
                  |  "VIENTO_FUERTE" | "BATERIA_BAJA"
<numero>         ::= DIGITO+ ( "." DIGITO+ )?
DIGITO           ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

---

## Ejemplos

| Regla | Estado | Motivo |
|-------|--------|--------|
| `TEMP_ALTA > 35` | ✅ Válida | identificador + operador + número |
| `BATERIA_BAJA < 20` | ✅ Válida | idéntico al anterior |
| `> TEMP_ALTA 35` | ❌ Inválida | orden incorrecto de los tokens |
| `LLUVIA_INTENSA >` | ❌ Inválida | falta el número |
| `HUMEDAD > 80` | ❌ Inválida | identificador fuera de la lista oficial |

---

## Mapeo identificador → métrica evaluada (`data/metricas.csv`)

| Identificador | Columna evaluada | Significado |
|---------------|------------------|-------------|
| TEMP_ALTA | TEMP_MAX | Temperatura máxima sobre el umbral |
| LLUVIA_INTENSA | LLUVIA_TOTAL | Precipitación acumulada sobre el umbral |
| VIENTO_FUERTE | VIENTO_MAX | Viento máximo sobre el umbral |
| BATERIA_BAJA | BATERIA_PROM | Batería promedio bajo el umbral |

---

## Convenciones del archivo `input/reglas.txt`

- Una regla por línea; máximo 50 reglas (límite del parser).
- Las líneas que inician con `#` son comentarios.
- Las líneas vacías se ignoran.
- Los tokens se separan con espacios.
- Codificación: texto plano, fin de línea LF.

## Errores y manejo

- Regla con cantidad de tokens distinta de 3 → inválida.
- Identificador desconocido → inválida.
- Operador no perteneciente a `{>, <, >=, <=}` → inválida.
- Número no convertible (`FUNCTION TEST-NUMVAL` falla) → inválida.
- Las reglas inválidas se reportan con su número de línea y se cuentan
  (`INVALID-RULES-COUNT`); el motor continúa con las válidas.

## Valores por defecto (demo)

Si `input/reglas.txt` no existe, el motor carga:

```
TEMP_ALTA > 35
LLUVIA_INTENSA > 50
VIENTO_FUERTE > 40
BATERIA_BAJA < 20
```

## Referencias

- [DATA_CONTRACT.md](DATA_CONTRACT.md) — formato de `alertas.csv` y `secuencia.txt`
- [CHECKSUM.md](CHECKSUM.md) — cómo el MIPS consume la secuencia de alertas
