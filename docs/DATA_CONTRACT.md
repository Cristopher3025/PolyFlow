# PolyFlow Data Contract

This document defines the strict interface between pipeline stages. All participants must follow these specifications exactly. No deviations are permitted.

---

## 1. datos_crudos.csv

**Source**: Initial input data  
**Producer**: External data source (environmental monitoring stations)  
**Consumer**: BASIC-256 (cleaning and normalization stage)  
**Location**: `data/datos_crudos.csv`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| ID | String | Max 10 chars, unique | "001" | Unique identifier for the record |
| STATION | String | Max 20 chars | "COTO" | Weather station name |
| TEMPERATURE | Float | Range: -50.0 to 60.0°C | 28.5 | Air temperature in Celsius |
| PRECIPITATION | Float | Range: 0.0 to 300.0 mm | 12.3 | Rainfall in millimeters |
| WIND | Float | Range: 0.0 to 150.0 km/h | 15.2 | Wind speed in km/h |
| BATTERY | Integer | Range: 0 to 100 % | 87 | Battery level percentage |

### Format
- **Delimiter**: Comma (,)
- **Encoding**: UTF-8
- **Line Ending**: LF (\n)
- **Header**: Required (first line contains field names)
- **Missing Values**: Empty field indicates missing/invalid data

### Validation Rules
- ID: Non-empty, alphanumeric
- STATION: Non-empty string
- TEMPERATURE: Numeric or empty; if present, must be within valid range
- PRECIPITATION: Numeric or empty; if present, must be >= 0
- WIND: Numeric or empty; if present, must be >= 0
- BATTERY: Numeric or empty; if present, must be between 0-100

---

## 2. datos_normalizados.csv

**Producer**: BASIC-256 (cleaning and validation stage)  
**Consumer**: FORTRAN (metrics calculation stage)  
**Location**: `data/datos_normalizados.csv`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| ID | String | Max 10 chars, unique | "001" | Unique identifier for the record |
| STATION | String | Max 20 chars | "COTO" | Weather station name |
| TEMPERATURE | Float | Range: -50.0 to 60.0°C | 28.5 | Air temperature in Celsius |
| PRECIPITATION | Float | Range: 0.0 to 300.0 mm | 12.3 | Rainfall in millimeters |
| WIND | Float | Range: 0.0 to 150.0 km/h | 15.2 | Wind speed in km/h |
| BATTERY | Integer | Range: 0 to 100 % | 87 | Battery level percentage |

### Format
- **Delimiter**: Comma (,)
- **Encoding**: UTF-8
- **Line Ending**: LF (\n)
- **Header**: Required
- **Missing Values**: None (records with missing values are excluded)

### Guarantees
- All records present are **valid** according to validation rules
- No missing values in required fields
- All numeric values within specified ranges
- Duplicates removed (by ID, keeping first occurrence)
- Records sorted by STATION name, then by ID

### Quality Assurance
- **Row count**: Output has fewer or equal rows than input
- **Traceability**: Original ID field preserved for audit trails
- **Completeness**: Empty fields in input result in record rejection

---

## 3. metricas.csv

**Producer**: FORTRAN (metrics calculation stage)  
**Consumer**: COBOL (rules engine)  
**Location**: `data/metricas.csv`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| ESTACION | String | Max 20 chars | "COTO" | Weather station identifier |
| TEMP_PROM | Float | Range: -50.0 to 60.0°C | 28.5 | Average temperature across records |
| TEMP_MAX | Float | Range: -50.0 to 60.0°C | 36.8 | Maximum temperature across records |
| TEMP_MIN | Float | Range: -50.0 to 60.0°C | 25.4 | Minimum temperature across records |
| LLUVIA_TOTAL | Float | Range: 0.0 to 3000.0 mm | 45.6 | Sum of all precipitation values |
| VIENTO_PROM | Float | Range: 0.0 to 150.0 km/h | 15.2 | Average wind speed across records |
| VIENTO_MAX | Float | Range: 0.0 to 150.0 km/h | 65.0 | Maximum wind speed across records |
| BATERIA_PROM | Float | Range: 0.0 to 100.0 % | 85.5 | Average battery level across records |

Header line: `ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM`

### Format
- **Delimiter**: Comma (,)
- **Encoding**: UTF-8
- **Line Ending**: LF (\n)
- **Header**: Required
- **Decimal Places**: Minimum 1, maximum 2 decimal places
- **Missing Values**: None

### Guarantees
- One row per unique STATION from normalized data
- All calculations use valid records only
- Floating-point precision: ±0.01 acceptable
- Stations sorted alphabetically

### Quality Assurance
- **Consistency**: Derived statistics must be mathematically consistent
- **Completeness**: Every station from input appears in output
- **Accuracy**: Calculations verified with test data

---

## 4. alertas.csv

**Producer**: COBOL (rules engine)  
**Consumer**: MIPS (checksum verification)  
**Location**: `data/alertas.csv`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| ESTACION | String | Max 20 chars | "GOLFITO" | Weather station identifier |
| IDENTIFICADOR | String | Official identifiers | "LLUVIA_INTENSA" | Identifier of the triggered rule |
| OPERADOR | String | > < >= <= | ">" | Operator of the triggered rule |
| UMBRAL | Float | Rule threshold | 50.0000 | Threshold of the triggered rule |
| VALOR | Float | Metric value | 110.0000 | Metric value that triggered the alert |

Header line: `ESTACION,IDENTIFICADOR,OPERADOR,UMBRAL,VALOR`

### Format
- **Delimiter**: Comma (,)
- **Encoding**: UTF-8
- **Line Ending**: LF (\n)
- **Header**: Required
- **Missing Values**: None

### Alert Identifiers (official)

```
TEMP_ALTA       - TEMP_MAX      > threshold (e.g. 35 °C)
LLUVIA_INTENSA  - LLUVIA_TOTAL  > threshold (e.g. 50 mm)
VIENTO_FUERTE   - VIENTO_MAX    > threshold (e.g. 40 km/h)
BATERIA_BAJA    - BATERIA_PROM  < threshold (e.g. 20 %)
```

The identifier, operator and threshold come from `input/reglas.txt`
(see [GRAMMAR.md](GRAMMAR.md)); the evaluated metric column per
identifier is fixed by the mapping above.

### Guarantees
- One row per alert triggered
- Multiple alerts possible per station
- Records in evaluation order (station by station, rules in file order)
- Alert values match metric field that triggered it

### Quality Assurance
- No duplicate alerts per station (each stored rule evaluates once per station)
- Alert values correspond to metrics provided by FORTRAN
- All alert types valid per defined list

---

## 5. secuencia.txt

**Producer**: COBOL (rules engine)  
**Consumer**: MIPS (checksum verification)  
**Location**: `data/secuencia.txt`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| SEQUENCE | String | Format: sequence of alerts | "LLUVIA_INTENSA,TEMP_ALTA" | Comma-separated alert identifiers in order |

### Format
- **File Type**: Plain text
- **Encoding**: UTF-8
- **Line Structure**: Single line containing alert sequence
- **Delimiter**: Comma (,) between identifiers
- **Content**: Official alert identifiers as they were triggered during processing

### Specifications
- **Line Format**: `IDENT,IDENT,IDENT,...` (identifiers defined in GRAMMAR.md)
- **Minimum**: 1 identifier, or the literal `SIN_ALERTAS` when no rule matched
- **Order**: Chronological order of rule evaluation
- **No Spaces**: Strictly no spaces around commas

### Example
```
LLUVIA_INTENSA,VIENTO_FUERTE,BATERIA_BAJA,TEMP_ALTA
```

### Guarantees
- Sequence reflects processing order of rules
- Each token is an official identifier that generated an alert
- Non-empty if any alerts generated
- Complete record of rule execution path

### Quality Assurance
- All identifiers valid and consistent with alertas.csv
- Sequence length matches number of alerts generated
- Can be used for audit trail and verification

---

## 6. checksum.txt

**Producer**: MIPS (checksum verification)  
**Consumer**: Final verification / Audit trail  
**Location**: `data/checksum.txt`

### Specifications

| Field | Type | Constraints | Example | Description |
|-------|------|-------------|---------|-------------|
| CHECKSUM | String | Hex format, 8 chars | "A3F2E891" | Integrity verification value |

### Format
- **File Type**: Plain text
- **Encoding**: UTF-8
- **Line Structure**: Single line
- **Content**: Hexadecimal checksum value

### Specifications
- **Format**: 8-character hexadecimal string (uppercase)
- **Algorithm**: Official course algorithm (identifier mapping 10/20/30/40, sum + XOR position; see docs/CHECKSUM.md)
- **Input Data**: secuencia.txt (alert identifier sequence)
- **Line Format**: `CHECKSUM=<value>` (with equals sign)

### Example
```
CHECKSUM=A3F2E891
```

### Guarantees
- Computed from secuencia.txt (official alert identifiers)
- Deterministic (same input always produces same checksum)
- Can detect data corruption in pipeline output

### Quality Assurance
- Checksum value reproducible from source files
- Documented algorithm available in docs/CHECKSUM.md
- Can verify pipeline integrity end-to-end

---

## Summary Table

| File | Producer | Consumer | Key Property |
|------|----------|----------|--------------|
| datos_crudos.csv | External | BASIC-256 | May contain invalid/missing data |
| datos_normalizados.csv | BASIC-256 | FORTRAN | Guaranteed valid, complete |
| metricas.csv | FORTRAN | COBOL | Aggregated statistics |
| alertas.csv | COBOL | MIPS | Alert events with IDs |
| secuencia.txt | COBOL | MIPS | Rule execution order |
| checksum.txt | MIPS | Verification | Integrity proof |

---

## Integration Rules

1. **Sequential Dependency**: Each stage must complete before next stage begins
2. **File Existence Check**: Each stage validates input files exist before processing
3. **Format Validation**: Each consumer must validate format before processing
4. **No File Modification**: Intermediate files are read-only after generation
5. **Logging**: Each stage logs input/output file information for debugging
6. **Error Handling**: If input violates contract, halt with clear error message

---

## Testing Strategy

1. Create test files for each contract (tests/data/ directory)
2. Implement validators for each file format
3. Test boundary conditions (empty files, invalid values, etc.)
4. Document test cases and expected outputs
5. Verify round-trip: data_crudos → checksum

