# PolyFlow Rules Grammar

## Overview

The rules engine processes environmental metrics and evaluates conditions to generate alerts. This document defines the formal grammar and semantics for rule definition and evaluation.

---

## Formal Grammar

```
RULESET     ::= RULE+
RULE        ::= "RULE" RULE_ID CONDITION ("->" | "=>") ACTION
RULE_ID     ::= "R" DIGIT{3}
CONDITION   ::= TERM (LOGICAL_OP TERM)*
TERM        ::= FIELD RELOP VALUE
LOGICAL_OP  ::= "AND" | "OR"
FIELD       ::= "TEMPERATURE" | "PRECIPITATION" | "WIND" | "BATTERY"
RELOP       ::= ">" | "<" | ">=" | "<=" | "==" | "!="
VALUE       ::= FLOAT | INTEGER
ACTION      ::= "ALERT_" ALERT_NAME
ALERT_NAME  ::= ALPHA{1,32}
FLOAT       ::= "-"? DIGIT+ "." DIGIT+
INTEGER     ::= "-"? DIGIT+
DIGIT       ::= "0" | "1" | ... | "9"
ALPHA       ::= "A" | "B" | ... | "Z" | "a" | "b" | ... | "z" | "_"
```

---

## Rule Components

### Rule ID
- Format: `R` followed by exactly 3 digits
- Range: R000 to R999 (1000 possible rules)
- Purpose: Unique identifier for tracking alert generation
- Example: `R001`, `R042`, `R999`

### Conditions
Conditions evaluate metric values against thresholds.

#### Field Names
```
TEMPERATURE     - Average temperature (°C)
PRECIPITATION   - Total precipitation (mm)
WIND            - Average wind speed (km/h)
BATTERY         - Average battery level (%)
```

#### Relational Operators
```
>               - Greater than
<               - Less than
>=              - Greater than or equal
<=              - Less than or equal
==              - Exactly equal
!=              - Not equal
```

#### Values
- Floating-point or integer numbers
- May include negative values (e.g., for boundary conditions)
- Context-dependent (e.g., TEMPERATURE values in Celsius)

#### Logical Connectors
```
AND             - Both conditions must be true
OR              - At least one condition must be true
```

### Actions
When a condition evaluates to true, trigger an action.

#### Alert Generation
- Format: `ALERT_` followed by alert type name
- Alert type must be uppercase or mixed case with underscores
- Examples: `ALERT_HIGH_TEMPERATURE`, `ALERT_EXCESSIVE_WIND`

---

## Examples

### Example 1: Simple Temperature Alert
```
RULE R001 TEMPERATURE > 35 -> ALERT_HIGH_TEMPERATURE
```
**Interpretation**: If average temperature exceeds 35°C, trigger alert R001 for high temperature.

### Example 2: Compound Condition
```
RULE R002 WIND >= 60 AND BATTERY < 20 -> ALERT_CRITICAL_CONDITIONS
```
**Interpretation**: If wind is excessive AND battery is low, trigger alert R002.

### Example 3: Precipitation Alert
```
RULE R003 PRECIPITATION > 100 -> ALERT_HEAVY_RAINFALL
```
**Interpretation**: If total precipitation exceeds 100mm, trigger alert R003.

### Example 4: Multiple Conditions
```
RULE R004 TEMPERATURE > 30 OR TEMPERATURE < 5 -> ALERT_EXTREME_TEMPERATURE
```
**Interpretation**: If temperature is either very high or very low, trigger alert R004.

### Example 5: Negative Values
```
RULE R005 BATTERY <= 0 -> ALERT_SENSOR_FAILURE
```
**Interpretation**: If battery level is zero or negative (invalid data), trigger alert R005.

---

## Rule Evaluation Semantics

### Evaluation Order
1. Rules are evaluated sequentially in order they appear in rule file
2. Each rule is evaluated independently
3. Multiple rules can trigger for same data record
4. Alert sequence records order of evaluation

### Data Matching
- Rules evaluate against **station metrics** (per station)
- One rule evaluation = one rule applied to all metrics for station
- Multiple alerts possible per station if conditions overlap

### Alert Generation
- When condition evaluates TRUE, alert is generated
- Alert includes: STATION, RULE_ID, ALERT_TYPE, VALUE
- VALUE = actual metric value that triggered condition

### Sequence Tracking
- Each alert (TRUE condition) adds rule ID to sequence
- Sequence order = evaluation order
- Sequence is deterministic (same input → same output)

---

## Standard Alert Types

| Alert Type | Condition | Threshold | Priority |
|---|---|---|---|
| HIGH_TEMPERATURE | TEMPERATURE > 35 | 35°C | HIGH |
| LOW_TEMPERATURE | TEMPERATURE < 5 | 5°C | MEDIUM |
| EXTREME_TEMPERATURE | TEMPERATURE > 40 OR TEMPERATURE < 0 | Multiple | CRITICAL |
| HIGH_PRECIPITATION | PRECIPITATION > 100 | 100mm | MEDIUM |
| EXCESSIVE_WIND | WIND >= 60 | 60 km/h | HIGH |
| LOW_BATTERY | BATTERY < 20 | 20% | MEDIUM |
| CRITICAL_BATTERY | BATTERY <= 10 | 10% | CRITICAL |
| CRITICAL_CONDITIONS | Multiple conditions | Multiple | CRITICAL |
| SENSOR_FAILURE | BATTERY <= 0 | 0% | CRITICAL |

---

## Rule File Format

### File Location
`input/reglas.txt`

### File Structure
```
# PolyFlow Rules Configuration
# Lines starting with # are comments
# Each rule on separate line

RULE R001 TEMPERATURE > 35 -> ALERT_HIGH_TEMPERATURE
RULE R002 TEMPERATURE < 5 -> ALERT_LOW_TEMPERATURE
RULE R003 PRECIPITATION > 100 -> ALERT_HIGH_PRECIPITATION
RULE R004 WIND >= 60 -> ALERT_EXCESSIVE_WIND
RULE R005 BATTERY < 20 -> ALERT_LOW_BATTERY
RULE R006 TEMPERATURE > 35 AND WIND >= 60 -> ALERT_EXTREME_CONDITIONS
```

### Parsing Rules
- Comments: Lines starting with `#` are ignored
- Whitespace: Leading/trailing whitespace trimmed
- Case Sensitivity: Keywords uppercase (RULE, AND, OR), field names case-insensitive
- Encoding: UTF-8, LF line endings
- Error Handling: Invalid rules cause processing to halt with error

---

## Implementation Considerations

### In COBOL

The rules engine in COBOL should:

1. **Read rule file**: Load all rules into memory or process sequentially
2. **Parse each line**: Extract RULE_ID, FIELD, RELOP, VALUE, ALERT_NAME
3. **For each metric record**:
   - Evaluate each rule condition
   - If TRUE, write alert record
   - If TRUE, append rule ID to sequence
4. **Output generation**:
   - Write alertas.csv with alert records
   - Write secuencia.txt with rule ID sequence

### Edge Cases

1. **No rules match**: Generate empty alertas.csv, empty secuencia.txt
2. **Rule syntax error**: Abort with clear error message
3. **Missing field reference**: Abort with field name and line number
4. **Invalid operator**: Abort with operator and line number
5. **Division by zero**: Avoid (no division operations in rules)

### Performance

- Rule evaluation should be efficient (typically < 1 second for 100 rules)
- Sequential evaluation acceptable for academic project
- No optimization required at this stage

---

## Testing Strategy

### Test Cases

#### Test 1: Simple Conditions
- Input: Single metric record, single rule
- Verify: Correct alert generated or not generated

#### Test 2: Multiple Rules
- Input: Single metric record, multiple rules
- Verify: All matching rules generate alerts in order

#### Test 3: Compound Conditions
- Input: Metrics with AND/OR conditions
- Verify: Logical operations evaluated correctly

#### Test 4: Edge Values
- Input: Metrics exactly on threshold values
- Verify: Boundary conditions (< vs <=) respected

#### Test 5: Sequence Tracking
- Input: Multiple alerts from same station
- Verify: secuencia.txt contains correct rule order

### Sample Test Data
```
# Test record 1: Triggers R001, R004, R006
STATION: COTO
AVG_TEMPERATURE: 38.5
MAX_TEMPERATURE: 42.0
MIN_TEMPERATURE: 35.0
TOTAL_PRECIPITATION: 45.2
AVG_WIND: 65.0
AVG_BATTERY: 92.0

Expected alerts:
- R001 (TEMPERATURE > 35)
- R004 (WIND >= 60)
- R006 (TEMPERATURE > 35 AND WIND >= 60)
```

---

## References

- [Data Contract](DATA_CONTRACT.md) - metricas.csv input specification
- [Checksum Algorithm](CHECKSUM.md) - Verification of rules processed

