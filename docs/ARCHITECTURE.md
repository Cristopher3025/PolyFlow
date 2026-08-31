# PolyFlow Architecture

## Project Vision

PolyFlow is an integrated environmental data processing system that demonstrates collaborative software development across multiple programming languages. Each stage processes data through a well-defined pipeline, transforming raw environmental measurements into actionable alerts with integrity verification.

---

## Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        RAW DATA INPUT                            │
│                   data/datos_crudos.csv                          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
          ╔══════════════════════════════════╗
          ║        STAGE 1: BASIC-256        ║
          ║    Data Cleaning & Validation    ║
          ║     (Cris: data quality)         ║
          ╚══════════════════════════════════╝
                         │
                         ▼
              ┌──────────────────────────┐
              │ data/datos_normalizados  │
              │          .csv            │
              └──────────────────────────┘
                         │
                         ▼
          ╔══════════════════════════════════╗
          ║      STAGE 2: FORTRAN            ║
          ║   Metrics Calculation            ║
          ║  (Anthony: statistical analysis) ║
          ╚══════════════════════════════════╝
                         │
                         ▼
              ┌──────────────────────────┐
              │  data/metricas.csv       │
              └──────────────────────────┘
                         │
                         ▼
          ╔══════════════════════════════════╗
          ║        STAGE 3: COBOL            ║
          ║      Rules Engine                ║
          ║  (Justin: alert generation)      ║
          ╚══════════════════════════════════╝
                         │
          ┌──────────────┴──────────────┐
          ▼                             ▼
    ┌─────────────┐          ┌─────────────────┐
    │alertas.csv  │          │ secuencia.txt   │
    └──────┬──────┘          └────────┬────────┘
           │                          │
           └──────────────┬───────────┘
                          ▼
          ╔══════════════════════════════════╗
          ║      STAGE 4: MIPS               ║
          ║  Checksum Verification           ║
          ║   (Justin: integrity check)      ║
          ╚══════════════════════════════════╝
                         │
                         ▼
              ┌──────────────────────────┐
              │   data/checksum.txt      │
              └──────────────────────────┘
                         │
                         ▼
          ┌────────────────────────────────┐
          │   PIPELINE COMPLETE             │
          │   All verifications passed      │
          └────────────────────────────────┘
```

---

## Stages Overview

### Stage 1: BASIC-256 (Cleaning & Validation)
- **Responsible**: Cris
- **Input**: `data/datos_crudos.csv`
- **Output**: `data/datos_normalizados.csv`
- **Tasks**:
  - Load raw environmental data
  - Remove records with missing critical fields
  - Validate data ranges and types
  - Normalize units and formats
  - Remove duplicate records
  - Ensure consistency across measurements
- **Development Environment**: BASIC-256 IDE (external to VS Code)
- **File Location**: `basic256/limpieza.kbs`

### Stage 2: FORTRAN (Metrics Calculation)
- **Responsible**: Anthony
- **Input**: `data/datos_normalizados.csv`
- **Output**: `data/metricas.csv`
- **Tasks**:
  - Calculate statistics per weather station
  - Compute averages (temperature, wind, battery)
  - Find maximums and minimums
  - Sum total precipitation
  - Aggregate data by station
- **Development Environment**: VS Code with FORTRAN compiler
- **File Location**: `fortran/procesamiento.f90`

### Stage 3: COBOL (Rules Engine)
- **Responsible**: Justin
- **Input**: `data/metricas.csv` + `input/reglas.txt`
- **Output**: `data/alertas.csv` + `data/secuencia.txt`
- **Tasks**:
  - Load metrics and rule definitions
  - Evaluate conditional rules against metrics
  - Generate alerts when conditions met
  - Record rule execution sequence
  - Validate alert consistency
- **Architecture**: Pattern-based rule evaluation (not object-oriented)
- **Development Environment**: VS Code with GnuCOBOL compiler
- **File Location**: `cobol/reglas.cob`

### Stage 4: MIPS (Integrity Verification)
- **Responsible**: Justin
- **Input**: `data/alertas.csv` + `data/secuencia.txt`
- **Output**: `data/checksum.txt`
- **Tasks**:
  - Read alert records and sequence
  - Compute checksum over combined data
  - Verify data integrity
  - Write results with status
- **Architecture**: Low-level computation with memory/register operations
- **Development Environment**: VS Code with MIPS simulator
- **File Location**: `mips/checksum.asm`

---

## Key Architectural Decisions

### 1. Language Distribution
- **BASIC-256**: High-level sequential processing (I/O, string manipulation)
- **FORTRAN**: Numerical computation (statistics, aggregation)
- **COBOL**: Business logic and rule evaluation (conditions, records)
- **MIPS**: Low-level verification (checksum, registers, memory)

### 2. Data Exchange Format
- **CSV files** for multi-record data (human-readable, easily validated)
- **Plain text** for simple outputs (checksum, sequences)
- **Strict schema contracts** enforced at every boundary

### 3. File Organization
- **data/**: Central hub for inter-stage communication
- **[language]/**: Language-specific source code and binaries
- **docs/**: Architecture, contracts, and specifications
- **scripts/**: Build, configuration, and execution automation
- **tests/**: Test data and validation utilities

### 4. Development Process
- **Parallel development**: Each contributor works independently on their stage
- **Test data contracts**: Participants use sample data matching schema
- **Integration points**: Well-defined at file boundaries, not runtime
- **Final assembly**: Single entry point (PolyFlow.bat) orchestrates execution

---

## Design Principles

### P1: Modularity
Each stage is completely independent and can be developed in isolation using test data that conforms to contracts.

### P2: Robustness
Each stage validates inputs and provides clear error messages if contracts are violated.

### P3: Traceability
Data flow is linear and auditable; each file is traceable to its producer.

### P4: Simplicity
Communication through files (not APIs, databases, or message queues) eliminates runtime dependencies.

### P5: Reproducibility
All conversions are deterministic; same input always produces same output.

---

## Team Responsibilities

| Team Member | Component | Language | Tasks |
|---|---|---|---|
| **Cris** | Integration Lead | Multiple | Pipeline orchestration, BASIC-256 execution automation, environment setup |
| **Cris** | BASIC-256 Stage | BASIC-256 | Data cleaning, validation, normalization |
| **Anthony** | FORTRAN Stage | FORTRAN | Statistical calculations, aggregation |
| **Justin** | COBOL Stage | COBOL | Rule evaluation, alert generation |
| **Justin** | MIPS Stage | MIPS | Checksum verification, integrity checks |
| **All** | Testing & QA | Multiple | End-to-end pipeline validation |
| **All** | Documentation | Markdown | Architecture, guides, troubleshooting |

---

## Development Workflow

### Phase 1: Infrastructure Setup ✓
- [x] Create directory structure
- [x] Define data contracts
- [x] Prepare configuration templates
- [ ] Set up version control branches

### Phase 2: Individual Development
- [ ] Cris develops BASIC-256 (in IDE, uploads .kbs)
- [ ] Anthony develops FORTRAN (in VS Code)
- [ ] Justin develops COBOL (in VS Code)
- [ ] Each uses test data matching contracts

### Phase 3: Stage Integration
- [ ] Verify BASIC-256 output → FORTRAN input
- [ ] Verify FORTRAN output → COBOL input
- [ ] Verify COBOL outputs → MIPS input

### Phase 4: Pipeline Assembly
- [ ] Create PolyFlow.bat (calls all stages in order)
- [ ] Implement validation checks between stages
- [ ] Test full pipeline end-to-end

### Phase 5: Deployment & Documentation
- [ ] Verify all README files updated
- [ ] Create troubleshooting guide
- [ ] Prepare demonstration materials

---

## Error Handling Strategy

Each stage must:

1. **Validate inputs** - Check if input file exists and matches expected schema
2. **Report clearly** - If validation fails, write descriptive error message to console
3. **Stop cascade** - If stage fails, pipeline halts (PolyFlow.bat aborts)
4. **Log details** - Write diagnostic info (row counts, parsing errors, etc.)

Example error flow:
```
PolyFlow.bat runs BASIC-256
BASIC-256 encounters invalid data
BASIC-256 writes error message + exit code
PolyFlow.bat detects failure
PolyFlow.bat displays error and stops
(FORTRAN and later stages NOT executed)
```

---

## Execution Entry Points

### Development
Each participant works in their language:
```bash
# Cris: BASIC-256 IDE (separate from VS Code)
# Anthony: VS Code → compile FORTRAN → test with sample data
# Justin: VS Code → compile COBOL → test with sample data
# Justin: VS Code → assemble MIPS → run in simulator
```

### Integration Testing
```bash
PolyFlow.bat    # Single point of entry
```

### External Use (Professor/Demo)
- Double-click `PolyFlow.bat`
- System runs automatically
- No need to open VS Code or other IDEs
- Result in `data/checksum.txt` confirms completion

---

## Dependencies

### External Tools (Platform-Dependent)
- BASIC-256 IDE (developed in external IDE, source in repo)
- FORTRAN Compiler (gfortran or ifort)
- GnuCOBOL Compiler (cobc)
- MIPS Simulator (MARS or QtSPIM)

### File System
- Windows (batch files)
- Linux/Mac (bash scripts, if needed)

### Development Environment
- VS Code
- Git (version control)

---

## Future Enhancements

1. **Testing Framework**: Automated test suite for each stage
2. **Performance Metrics**: Execution time tracking
3. **Logging System**: Comprehensive audit trail
4. **Error Recovery**: Checkpoint/restart capability
5. **Data Visualization**: Graphical dashboard for results

---

## References

- [Data Contract](DATA_CONTRACT.md) - Strict interface specifications
- [Grammar Specification](GRAMMAR.md) - Rule evaluation syntax
- [Checksum Algorithm](CHECKSUM.md) - MIPS verification method
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions

