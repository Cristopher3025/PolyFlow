# Gramática del mini-lenguaje de reglas (oficial)

## Definición (BNF)

```
<regla>         ::= <identificador> <operador> <numero>
<operador>      ::= ">" | "<" | ">=" | "<="
<identificador> ::= "TEMP_ALTA" | "LLUVIA_INTENSA"
                 |  "VIENTO_FUERTE" | "BATERIA_BAJA"
<numero>        ::= DIGITO+ ( "." DIGITO+ )?
```

## Ejemplos

- ✅ Válida: `TEMP_ALTA > 35`
- ❌ Inválida: `> TEMP_ALTA 35` (orden incorrecto de los tokens)

## Convenciones del archivo `input/reglas.txt`

- Una regla por línea.
- Las líneas que inician con `#` son comentarios y se ignoran.
- Máximo 50 reglas (límite del parser).

## Mapeo identificador → métrica evaluada (`data/metricas.csv`)

| Identificador     | Columna evaluada | Significado                          |
|-------------------|------------------|--------------------------------------|
| TEMP_ALTA         | TEMP_MAX         | Temperatura máxima sobre el umbral   |
| LLUVIA_INTENSA    | LLUVIA_TOTAL     | Precipitación acumulada sobre umbral |
| VIENTO_FUERTE     | VIENTO_MAX       | Viento máximo sobre el umbral        |
| BATERIA_BAJA      | BATERIA_PROM     | Batería promedio bajo el umbral      |

## Validación (parser COBOL)

- Exactamente 3 tokens por regla: identificador, operador, número.
- El número se valida con `FUNCTION TEST-NUMVAL` (acepta decimales y signo);
  no se usa `IS NUMERIC` porque rechaza literales con punto decimal.
- Las reglas inválidas se reportan con su línea y se cuentan
  (`INVALID-RULES-COUNT`); el procesamiento continúa con las válidas.

