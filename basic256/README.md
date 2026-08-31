# BASIC-256 - Data Cleaning & Validation (Updated)

## Overview

This component implements the first stage of the PolyFlow pipeline: cleaning, validation, and normalization of raw environmental data.

**Responsible Developer**: Cris  
**Language**: BASIC-256  
**Development Environment**: BASIC-256 IDE (external to VS Code)  
**Important**: Developed in the standalone BASIC-256 IDE, not in VS Code

---

## Development Process

### Key Difference
Unlike FORTRAN, COBOL, and MIPS which are developed in VS Code:
- **BASIC-256 code is written in the BASIC-256 IDE** (standalone application)
- You use the IDE to write, test, and debug the program
- Once complete, you save `limpieza.kbs` to the repository
- VS Code is used for repository management and pipeline coordination

### Workflow
```
1. Open BASIC-256 IDE (external application)
2. Write/edit limpieza.kbs in the IDE
3. Test and debug in the IDE
4. Save the .kbs file to basic256/limpieza.kbs
5. Use VS Code for git commits and pipeline testing
```

---

## Input/Output Specification

### Input
- **File**: `data/datos_crudos.csv`
- **Format**: CSV with headers (ID, STATION, TEMPERATURE, PRECIPITATION, WIND, BATTERY)
- **Content**: Raw data with potentially invalid/missing values

### Output
- **File**: `data/datos_normalizados.csv`
- **Format**: CSV with same headers, only valid records
- **Guarantees**: 
  - No missing values in required fields
  - All values within valid ranges
  - Sorted by STATION name
  - No duplicate IDs

---

## Validation Rules

### Record-Level Validation

| Field | Type | Valid Range | Action if Invalid |
|-------|------|-------------|-------------------|
| ID | String | Max 10 chars, non-empty | Reject record |
| STATION | String | Max 20 chars, non-empty | Reject record |
| TEMPERATURE | Float | -50.0 to 60.0°C | Reject record if missing or out of range |
| PRECIPITATION | Float | 0.0 to 300.0 mm (>= 0) | Reject record if missing or negative |
| WIND | Float | 0.0 to 150.0 km/h (>= 0) | Reject record if missing or negative |
| BATTERY | Integer | 0 to 100 % | Reject record if missing or out of range |

---

## Development Tasks

### Phase 1: Scaffolding (Current)
- [x] Create file structure and README
- [x] Document requirements

### Phase 2: Core Functionality (Your Work)
- [ ] Read CSV file with headers
- [ ] Parse each record
- [ ] Validate each field against rules
- [ ] Accumulate valid records
- [ ] Sort by station name
- [ ] Write output CSV

### Phase 3: Testing & Refinement
- [ ] Test with sample data
- [ ] Verify output format
- [ ] Handle edge cases

---

## Integration with Pipeline

### Downstream Expectations
- FORTRAN reads `data/datos_normalizados.csv`
- Expects CSV format with headers
- Expects only valid, complete records
- Expects no empty fields
- Expects numeric values parseable as floats

### Quality Guarantee
**Every record in datos_normalizados.csv must be processable by FORTRAN without errors.**

---

## References

- [Data Contract](../docs/DATA_CONTRACT.md) - Input/output specifications
- [Architecture](../docs/ARCHITECTURE.md) - Pipeline overview  
- Test data: `data/datos_crudos.csv` and `tests/datos_prueba.csv`
