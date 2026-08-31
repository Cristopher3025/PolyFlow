# COBOL - Rules Engine

## Overview

This component implements the PolyFlow rules engine in COBOL. It processes environmental metrics and evaluates conditions to generate alerts.

**Responsible Developer**: Justin  
**Language**: COBOL (GnuCOBOL)  
**Development Environment**: VS Code

---

## Input/Output Specification

### Input
- **File**: `data/metricas.csv`
- **Format**: CSV with headers (STATION, AVG_TEMPERATURE, MAX_TEMPERATURE, etc.)
- **Source**: FORTRAN processing stage
- **Frequency**: Processed once per pipeline execution

- **File**: `input/reglas.txt`
- **Format**: Text file with rule definitions (see GRAMMAR.md)
- **Content**: Rule set defining alert conditions
- **Frequency**: Static; loaded before metric processing

### Output
- **File**: `data/alertas.csv`
- **Format**: CSV with headers (STATION, RULE_ID, ALERT_TYPE, ALERT_VALUE)
- **Content**: All alerts triggered during rule evaluation
- **Consistency**: One row per alert; can be multiple per station

- **File**: `data/secuencia.txt`
- **Format**: Plain text, single line
- **Content**: Comma-separated list of rule IDs in evaluation order
- **Consistency**: Records exact sequence of rules that generated alerts

---

## Implementation Roadmap

### Phase 1: Scaffolding (Current)
- [x] Create file structure and README
- [ ] Implement basic program skeleton
- [ ] Add file I/O operations

### Phase 2: Core Functionality
- [ ] Implement CSV parsing for metrics
- [ ] Implement rule file parsing
- [ ] Build condition evaluation logic
- [ ] Implement alert generation

### Phase 3: Integration Testing
- [ ] Test with sample metrics data
- [ ] Verify output format compliance
- [ ] Validate alert accuracy
- [ ] Check sequence recording

### Phase 4: Refinement
- [ ] Add comprehensive error handling
- [ ] Optimize performance
- [ ] Document code thoroughly
- [ ] Prepare for final pipeline integration

---

## Key Components

### 1. File Reader
```
Purpose: Load and parse input CSV and text files
Input:   File path, record structure
Output:  Parsed records in memory
Notes:   Handle quoted fields, missing values
```

### 2. Rule Parser
```
Purpose: Parse rule definitions from text file
Input:   Rule text (RULE R### CONDITION -> ACTION)
Output:  Structured rule objects with parsed fields
Notes:   Support AND/OR operators, validate syntax
```

### 3. Condition Evaluator
```
Purpose: Evaluate conditional expressions against metrics
Input:   Rule condition, metric record
Output:  Boolean (true/false)
Notes:   Implement relational operators (>, <, >=, <=, ==, !=)
```

### 4. Alert Generator
```
Purpose: Create alert records when conditions met
Input:   Rule ID, station, alert type, trigger value
Output:  Alert CSV record
Notes:   Maintain chronological order
```

### 5. Sequence Tracker
```
Purpose: Record order of rule evaluation
Input:   Rule ID each time condition evaluates to true
Output:  Comma-separated sequence string
Notes:   Deterministic; same input always produces same output
```

---

## Code Structure

```
IDENTIFICATION DIVISION.
PROGRAM-ID. POLYFLOW-RULES-ENGINE.
AUTHOR. Justin.

ENVIRONMENT DIVISION.
  INPUT-OUTPUT SECTION.
    FILE-CONTROL.
      SELECT METRICAS-FILE ASSIGN TO WS-METRICAS-PATH
        ORGANIZATION IS LINE SEQUENTIAL.
      SELECT REGLAS-FILE ASSIGN TO WS-REGLAS-PATH
        ORGANIZATION IS LINE SEQUENTIAL.
      SELECT ALERTAS-FILE ASSIGN TO WS-ALERTAS-PATH
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
  FILE SECTION.
    [File record definitions]
  
  WORKING-STORAGE SECTION.
    [Working variables]

PROCEDURE DIVISION.
  MAIN.
    [TODO: Implement main logic]
    STOP RUN.
```

---

## Data Structures

### Metrics Record
```cobol
WORKING-STORAGE SECTION.
01 WS-METRIC-RECORD.
   05 WS-STATION           PIC X(20).
   05 WS-AVG-TEMPERATURE   PIC S9(3)V99.
   05 WS-MAX-TEMPERATURE   PIC S9(3)V99.
   05 WS-MIN-TEMPERATURE   PIC S9(3)V99.
   05 WS-TOTAL-PRECIP      PIC S9(4)V99.
   05 WS-AVG-WIND          PIC S9(3)V99.
   05 WS-AVG-BATTERY       PIC 9(3)V99.
```

### Rule Record
```cobol
01 WS-RULE-RECORD.
   05 WS-RULE-ID           PIC X(4).       * R000 to R999
   05 WS-RULE-FIELD        PIC X(15).      * TEMPERATURE, etc.
   05 WS-RULE-OPERATOR     PIC X(2).       * >, <, >=, <=, ==, !=
   05 WS-RULE-VALUE        PIC S9(4)V99.
   05 WS-RULE-ACTION       PIC X(32).      * ALERT_XXX
   05 WS-LOGICAL-NEXT      PIC X(3).       * AND, OR, or NONE
```

### Alert Record
```cobol
01 WS-ALERT-RECORD.
   05 WS-ALERT-STATION     PIC X(20).
   05 WS-ALERT-RULE-ID     PIC X(4).
   05 WS-ALERT-TYPE        PIC X(32).
   05 WS-ALERT-VALUE       PIC S9(4)V99.
```

---

## Development Guidelines

### 1. Code Style
- Use standard COBOL conventions (UPPERCASE for keywords)
- Meaningful variable names with WS- prefix for working storage
- Clear section comments for major blocks
- Line length < 80 characters for readability

### 2. Error Handling
```
IF FILE-NOT-FOUND
  DISPLAY "ERROR: Input file not found"
  DISPLAY "Path: " WS-FILE-PATH
  STOP RUN
END-IF
```

### 3. Validation
- Verify input files exist before opening
- Validate CSV format (correct number of columns)
- Validate rule syntax before evaluation
- Check metric value ranges

### 4. Logging
- Log number of records read and processed
- Log number of alerts generated
- Log execution time (if possible)
- Include timestamps in messages

### 5. Testing
```
Test Case 1: Simple rule evaluation
  Input: Single metric, single rule
  Expected: Alert generated if condition true

Test Case 2: Multiple rules
  Input: Single metric, multiple rules
  Expected: All matching rules generate alerts

Test Case 3: Compound conditions
  Input: Metrics with AND/OR logic
  Expected: Logical operators work correctly
```

---

## Integration Points

### Upstream (From FORTRAN)
- Read `data/metricas.csv`
- File structure defined in DATA_CONTRACT.md
- Validate header row matches specification

### Downstream (To MIPS)
- Write `data/alertas.csv`
- Write `data/secuencia.txt`
- Ensure both files in correct format

### External Dependencies
- GnuCOBOL compiler (cobc) for compilation
- Windows batch environment for execution
- Standard file system (no databases)

---

## Compilation & Execution

### Compilation (Future)
```batch
cobc -x -free -o cobol/bin/reglas.exe cobol/reglas.cob
```

### Execution (Future)
```batch
cobol\bin\reglas.exe
```

### Error Output
- Exit code 0 = success
- Exit code 1 = input validation error
- Exit code 2 = file I/O error
- Exit code 3 = processing error

---

## Performance Expectations

- **Small dataset** (1-10 stations, 1-50 rules): < 100ms
- **Medium dataset** (100 stations, 100 rules): < 1 second
- **Large dataset** (1000 stations, 1000 rules): < 10 seconds

Optimization not required for academic project but keep in mind.

---

## References

- [Data Contract](../docs/DATA_CONTRACT.md) - File format specifications
- [Grammar Specification](../docs/GRAMMAR.md) - Rule syntax and examples
- [Architecture](../docs/ARCHITECTURE.md) - Pipeline overview
- [COBOL Reference](https://www.ibm.com/products/cobol/gnucobol) - GnuCOBOL documentation

---

## Notes for Developer

1. Start with basic file I/O to establish input reading pattern
2. Implement CSV parsing carefully (handle quoted fields, commas in values)
3. Test parsing logic thoroughly before implementing rules
4. Use test data from tests/ directory early and often
5. Coordinate with Justin on MIPS requirements (checksum inputs)
6. Document any assumptions made during implementation

