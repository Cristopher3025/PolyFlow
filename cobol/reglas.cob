# COBOL Rules Engine - Skeleton

## Program Structure

COBOL implementation of the PolyFlow rules engine. This is a skeleton file to be completed by Justin.

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. POLYFLOW-RULES-ENGINE.
       AUTHOR. Justin.
       
      * ============================================================
      * PolyFlow - Rules Engine (COBOL)
      * 
      * Purpose:
      *   Read metrics from FORTRAN stage
      *   Evaluate conditional rules
      *   Generate alerts and rule sequence
      * 
      * Input:
      *   - data/metricas.csv (from FORTRAN)
      *   - input/reglas.txt (rule definitions)
      * 
      * Output:
      *   - data/alertas.csv (generated alerts)
      *   - data/secuencia.txt (rule evaluation sequence)
      * 
      * Development: Justin
      * Status: Skeleton - TODO: Implement full logic
      * ============================================================
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * TODO: Define file assignments for:
      * - METRICAS-FILE (input: data/metricas.csv)
      * - REGLAS-FILE (input: input/reglas.txt)
      * - ALERTAS-FILE (output: data/alertas.csv)
       
       DATA DIVISION.
       FILE SECTION.
      * TODO: Define file record structures
      
       WORKING-STORAGE SECTION.
      * TODO: Define working variables and data structures
      * - Metric record structure
      * - Rule record structure
      * - Alert record structure
      * - Sequence tracking
       
       PROCEDURE DIVISION.
       MAIN.
      * ============================================================
      * MAIN PROCEDURE
      * ============================================================
      
      * TODO: Step 1 - Validate input files exist
      * IF metricas file not found, display error and stop
      * IF reglas file not found, display error and stop
      
      * TODO: Step 2 - Load rule definitions
      * Read all rules from input/reglas.txt
      * Parse rule syntax (RULE R### CONDITION -> ACTION)
      * Validate rule format
      
      * TODO: Step 3 - Read and process metrics
      * For each metric record in data/metricas.csv:
      *   - Extract station and metric values
      *   - Evaluate all rules against this record
      *   - Generate alerts for matching rules
      *   - Record rule IDs in sequence
      
      * TODO: Step 4 - Write output files
      * Write alertas.csv with all generated alerts
      * Write secuencia.txt with rule sequence
      
      * TODO: Step 5 - Verify output
      * Check files were created
      * Display summary (records read, alerts generated)
      
           STOP RUN.
       
       
       EVALUATE-RULES.
      * ============================================================
      * EVALUATE-RULES SECTION
      * 
      * Purpose: Evaluate all rules against current metric
      * 
      * Input:  Current metric record
      * Output: Alerts generated, sequence updated
      * ============================================================
      
      * TODO: For each rule in rule set:
      *   IF condition evaluates to TRUE
      *     - Create alert record
      *     - Add rule ID to sequence
      *     - Write alert to file
      *   END-IF
      * END-FOR
       
       END PROGRAM POLYFLOW-RULES-ENGINE.
```

---

## Development Tasks

### Critical Sections to Implement

#### 1. File I/O
```
[ ] Open metricas.csv for input
[ ] Open reglas.txt for input
[ ] Open alertas.csv for output
[ ] Open secuencia.txt for output
[ ] Handle file not found errors
[ ] Handle I/O errors gracefully
```

#### 2. CSV Parsing
```
[ ] Parse metricas.csv header
[ ] Read metric records line by line
[ ] Handle quoted fields in CSV
[ ] Convert numeric strings to numbers
[ ] Skip empty lines
```

#### 3. Rule Parsing
```
[ ] Parse rule syntax: RULE R### CONDITION -> ACTION
[ ] Extract rule ID
[ ] Extract condition (FIELD OPERATOR VALUE)
[ ] Handle compound conditions (AND/OR)
[ ] Extract action (ALERT_TYPE)
```

#### 4. Condition Evaluation
```
[ ] Compare TEMPERATURE > threshold
[ ] Compare PRECIPITATION > threshold
[ ] Compare WIND > threshold
[ ] Compare BATTERY < threshold
[ ] Implement AND operator
[ ] Implement OR operator
```

#### 5. Alert Generation
```
[ ] Create alert record with STATION, RULE_ID, ALERT_TYPE, VALUE
[ ] Format alert for CSV output
[ ] Maintain chronological order
```

#### 6. Sequence Tracking
```
[ ] Track rule IDs as they generate alerts
[ ] Format sequence as comma-separated string
[ ] Write single line to secuencia.txt
```

---

## Data Structure Sketches

Uncomment and complete these structures:

```cobol
      * METRICS RECORD
      * 01 WS-METRIC-RECORD.
      *    05 WS-STATION           PIC X(20).
      *    05 WS-AVG-TEMP          PIC S9(3)V99.
      *    05 WS-MAX-TEMP          PIC S9(3)V99.
      *    05 WS-MIN-TEMP          PIC S9(3)V99.
      *    05 WS-TOTAL-PRECIP      PIC S9(4)V99.
      *    05 WS-AVG-WIND          PIC S9(3)V99.
      *    05 WS-AVG-BATTERY       PIC 9(3)V99.
      
      * RULE RECORD
      * 01 WS-RULE-RECORD.
      *    05 WS-RULE-ID           PIC X(4).
      *    05 WS-RULE-FIELD        PIC X(15).
      *    05 WS-RULE-OPERATOR     PIC X(2).
      *    05 WS-RULE-VALUE        PIC S9(4)V99.
      *    05 WS-RULE-ACTION       PIC X(32).
      
      * ALERT RECORD
      * 01 WS-ALERT-RECORD.
      *    05 WS-ALERT-STATION     PIC X(20).
      *    05 WS-ALERT-RULE-ID     PIC X(4).
      *    05 WS-ALERT-TYPE        PIC X(32).
      *    05 WS-ALERT-VALUE       PIC S9(4)V99.
```

---

## Testing Checklist

Before final submission:

- [ ] Program compiles without syntax errors
- [ ] Sample input files processed correctly
- [ ] Alerts generated for matching conditions
- [ ] Sequence recorded in correct order
- [ ] Output files in correct CSV format
- [ ] Error messages clear and helpful
- [ ] No crashes or hangs on edge cases
- [ ] Execution completes within reasonable time

---

## Related Files

- **Input Contract**: See `docs/DATA_CONTRACT.md` for metricas.csv specification
- **Rule Grammar**: See `docs/GRAMMAR.md` for rule syntax
- **Test Data**: See `tests/` for sample input files
- **Output Spec**: See `docs/DATA_CONTRACT.md` sections 4-5

