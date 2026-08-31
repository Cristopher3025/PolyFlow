# FORTRAN - Metrics Calculation (Updated)

## Overview

This component processes normalized environmental data and calculates aggregated statistics per weather station.

**Responsible Developer**: Anthony  
**Language**: FORTRAN  
**Development Environment**: VS Code with FORTRAN compiler (gfortran or ifort)

---

## Input/Output Specification

### Input
- **File**: `data/datos_normalizados.csv`
- **Format**: CSV with headers (ID, STATION, TEMPERATURE, PRECIPITATION, WIND, BATTERY)
- **Source**: BASIC-256 cleaning stage
- **Guarantees**: All records valid, no missing values, normalized ranges

### Output
- **File**: `data/metricas.csv`
- **Format**: CSV with headers (STATION, AVG_TEMPERATURE, MAX_TEMPERATURE, etc.)
- **Content**: One row per unique station with aggregated metrics
- **Guarantees**: Sorted by station name, all calculations verified

---

## Calculation Specifications

For each weather station in the normalized data, calculate:

| Metric | Formula | Range | Precision |
|--------|---------|-------|-----------|
| AVG_TEMPERATURE | Mean of all TEMPERATURE values | -50.0 to 60.0°C | 0.01°C |
| MAX_TEMPERATURE | Maximum TEMPERATURE value | -50.0 to 60.0°C | 0.01°C |
| MIN_TEMPERATURE | Minimum TEMPERATURE value | -50.0 to 60.0°C | 0.01°C |
| TOTAL_PRECIPITATION | Sum of all PRECIPITATION values | 0.0 to 3000.0mm | 0.1mm |
| AVG_WIND | Mean of all WIND values | 0.0 to 150.0 km/h | 0.01 km/h |
| AVG_BATTERY | Mean of all BATTERY values | 0.0 to 100.0% | 0.1% |

---

## Implementation Roadmap

### Phase 1: Scaffolding (Current)
- [x] Create file structure and README
- [ ] Implement basic program skeleton

### Phase 2: Core Functionality
- [ ] Implement CSV input parsing
- [ ] Build metric calculation logic
- [ ] Generate CSV output

### Phase 3: Integration Testing
- [ ] Test with sample data from BASIC-256
- [ ] Verify output format compliance
- [ ] Validate calculation accuracy

### Phase 4: Refinement
- [ ] Add error handling
- [ ] Optimize numerical precision
- [ ] Document code thoroughly

---

## Development Guidelines

### 1. Array Management
- Use efficient FORTRAN arrays for data storage
- Pre-allocate size or use dynamic allocation
- Handle station grouping logically

### 2. Numerical Precision
- Use REAL(KIND=8) for floating-point calculations
- Maintain 2 decimal places in output
- Verify calculations with manual test cases

### 3. CSV Handling
- Parse comma-separated values correctly
- Handle numeric conversions
- Preserve station names exactly

### 4. Error Handling
```fortran
IF (ios /= 0) THEN
  WRITE(*,*) "ERROR: Cannot open input file"
  WRITE(*,*) "Path: data/datos_normalizados.csv"
  STOP
END IF
```

### 5. Testing
```
Test 1: Single station data
  Input:  5 records, same station
  Verify: 1 output row with correct calculations

Test 2: Multiple stations
  Input:  10 records, 3 different stations
  Verify: 3 output rows, sorted by station

Test 3: Edge values
  Input:  Temperatures at min/max range
  Verify: Calculations correct at boundaries
```

---

## Sample Structure

```fortran
PROGRAM METRICS_CALCULATION
  IMPLICIT NONE
  
  ! TODO: Define constants
  ! INTEGER, PARAMETER :: MAX_RECORDS = 10000
  ! INTEGER, PARAMETER :: MAX_STATIONS = 100
  
  ! TODO: Define data types
  ! TYPE :: METRIC_RECORD
  !   CHARACTER(LEN=20) :: station
  !   REAL(KIND=8) :: temperature
  !   ...
  ! END TYPE METRIC_RECORD
  
  ! TODO: Implement main logic
  !   1. Open data/datos_normalizados.csv
  !   2. Read all records
  !   3. Group by station
  !   4. Calculate metrics
  !   5. Write data/metricas.csv
  !   6. Close files
  
  ! TODO: Add subroutines
  !   - SUBROUTINE read_normalized_data()
  !   - SUBROUTINE aggregate_by_station()
  !   - SUBROUTINE calculate_statistics()
  !   - SUBROUTINE write_metrics()
  
END PROGRAM METRICS_CALCULATION
```

---

## Compilation & Execution

### Compilation (Future)
```bash
gfortran -o fortran/bin/metrics fortran/procesamiento.f90
```

### Execution (Future)
```bash
./fortran/bin/metrics
```

---

## References

- [Data Contract](../docs/DATA_CONTRACT.md) - Input/output specifications
- [Architecture](../docs/ARCHITECTURE.md) - Pipeline overview
- Test data: `tests/datos_prueba.csv`
