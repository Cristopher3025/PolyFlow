# PolyFlow - Environmental Data Processing Pipeline

## Overview

**PolyFlow** is an integrated environmental data processing system that demonstrates collaborative software development across four different programming languages. The project implements a linear pipeline where each stage processes data and passes it to the next stage.

**Academic Focus**: Multi-language integration, data contracts, pipeline orchestration, and modular design.

---

## Quick Start

### For End Users (Professors/Reviewers)

To run the complete pipeline:

```batch
PolyFlow.bat
```

Double-click `PolyFlow.bat` and the system will:
1. Clean and validate environmental data (BASIC-256)
2. Calculate statistical metrics (FORTRAN)
3. Evaluate rule conditions and generate alerts (COBOL)
4. Verify data integrity with checksum (MIPS)

Final output: `data/checksum.txt`

### For Developers

Each team member works independently:

```
Cris:     BASIC-256 IDE → basic256/limpieza.kbs
Anthony:  VS Code + FORTRAN → fortran/procesamiento.f90
Justin:   VS Code + COBOL → cobol/rules_engine.cob
Justin:   VS Code + MIPS → mips/checksum.asm
```

---

## Project Structure

```
PolyFlow/
│
├── PolyFlow.bat                 ← Main entry point (double-click to run)
├── README.md                    ← This file
│
├── data/                        ← Data exchange hub
│   ├── datos_crudos.csv         ← Initial input
│   ├── datos_normalizados.csv   ← BASIC-256 output
│   ├── metricas.csv             ← FORTRAN output
│   ├── alertas.csv              ← COBOL output
│   ├── secuencia.txt            ← COBOL output
│   └── checksum.txt             ← MIPS output (final verification)
│
├── scripts/                     ← Pipeline infrastructure
│   ├── config.bat               ← Tool configuration
│   └── PolyFlow.bat             ← (copy of main entry point)
│
├── basic256/                    ← Stage 1: Data Cleaning
│   ├── limpieza.kbs             ← BASIC-256 source code
│   └── README.md                ← Development guide
│
├── fortran/                     ← Stage 2: Metrics Calculation
│   ├── procesamiento.f90        ← FORTRAN source code
│   ├── bin/                     ← Compiled binary
│   └── README.md                ← Development guide
│
├── cobol/                       ← Stage 3: Rules Engine
│   ├── rules_engine.cob         ← COBOL source code
│   ├── bin/                     ← Compiled binary
│   └── README.md                ← Development guide
│
├── mips/                        ← Stage 4: Checksum Verification
│   ├── checksum.asm             ← MIPS assembly code
│   ├── bin/                     ← Compiled binary
│   └── README.md                ← Development guide
│
├── docs/                        ← Documentation
│   ├── ARCHITECTURE.md          ← System design
│   ├── DATA_CONTRACT.md         ← Data format specifications
│   ├── GRAMMAR.md               ← Rule syntax and semantics
│   ├── CHECKSUM.md              ← Checksum algorithm
│   └── TROUBLESHOOTING.md       ← Common issues & solutions
│
├── input/                       ← Additional inputs
│   └── reglas.txt               ← Rule definitions for COBOL
│
├── tests/                       ← Test data
│   └── datos_prueba.csv         ← Sample records for testing
│
└── .gitignore                   ← Version control rules
```

---

## Pipeline Architecture

### Data Flow

```
Raw Environmental Data (datos_crudos.csv)
         ↓
    BASIC-256 (Data Cleaning)
         ↓
Normalized Data (datos_normalizados.csv)
         ↓
    FORTRAN (Metrics Calculation)
         ↓
    Metrics (metricas.csv)
         ↓
    COBOL (Rules Engine)
         ↓
  ┌─────────────┐
  ↓             ↓
Alerts       Sequence
(alertas.csv) (secuencia.txt)
  │             │
  └──────┬──────┘
         ↓
    MIPS (Checksum)
         ↓
   Checksum (checksum.txt)
```

### Stage Responsibilities

| Stage | Language | Developer | Input | Output | Task |
|-------|----------|-----------|-------|--------|------|
| 1 | BASIC-256 | Cris | datos_crudos.csv | datos_normalizados.csv | Data cleaning, validation, normalization |
| 2 | FORTRAN | Anthony | datos_normalizados.csv | metricas.csv | Statistical calculations (avg, max, min, totals) |
| 3 | COBOL | Justin | metricas.csv | alertas.csv, secuencia.txt | Rule evaluation, alert generation |
| 4 | MIPS | Justin | alertas.csv, secuencia.txt | checksum.txt | Integrity verification |

---

## Data Contracts

### Critical Principle: Contract-Driven Development

Each stage communicates through **strictly defined data formats**. No deviations permitted.

See [docs/DATA_CONTRACT.md](docs/DATA_CONTRACT.md) for complete specifications including:
- Exact column names and types
- Value ranges and constraints
- Encoding and delimiter rules
- Validation requirements

---

## Development Workflow

### Phase 1: Infrastructure (Complete ✓)
- [x] Define data contracts
- [x] Create directory structure
- [x] Prepare code skeletons
- [x] Configure version control

### Phase 2: Individual Development (Current)
- [ ] **Cris**: Develop BASIC-256 in IDE, test, commit
- [ ] **Anthony**: Develop FORTRAN, compile, test with sample data
- [ ] **Justin**: Develop COBOL, compile, test with sample data
- [ ] **Justin**: Develop MIPS, assemble, test in simulator

**Key**: Each developer works independently using test data that matches data contracts.

### Phase 3: Integration
- [ ] Verify each stage output matches specification
- [ ] Test stage connections in sequence

### Phase 4: Pipeline Assembly
- [ ] Implement PolyFlow.bat execution logic
- [ ] Verify end-to-end execution

### Phase 5: Deployment & Documentation
- [ ] Create troubleshooting guide
- [ ] Final documentation review
- [ ] Demonstration video

---

## Development Environment

### Requirements

#### For All Developers
- Windows 10+ or Linux/Mac
- VS Code
- Git

#### Cris (BASIC-256)
- BASIC-256 IDE (external to VS Code)

#### Anthony (FORTRAN)
- FORTRAN Compiler (gfortran or ifort)

#### Justin (COBOL + MIPS)
- GnuCOBOL Compiler (cobc)
- MIPS Simulator (MARS or QtSPIM)

### Configuration

1. Run `scripts/config.bat` to set tool paths
2. Verify each tool installation
3. Test compilation of sample files

---

## Important Notes

### BASIC-256 Development

⚠️ **Special Process**: BASIC-256 is developed in an external IDE, NOT in VS Code.

- Write and test in BASIC-256 IDE
- Save `limpieza.kbs` to `basic256/` directory
- Commit to git repository
- PolyFlow.bat executes the .kbs file automatically

---

## Integration Rules

- Do NOT manually edit files in `data/` directory
- Data contracts are mandatory (see DATA_CONTRACT.md)
- Each stage must validate inputs before processing
- Each stage must fail clearly if input is invalid
- Commit small, logical changes frequently

---

## References

### Documentation
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System design
- [docs/DATA_CONTRACT.md](docs/DATA_CONTRACT.md) - File specifications
- [docs/GRAMMAR.md](docs/GRAMMAR.md) - Rule syntax
- [docs/CHECKSUM.md](docs/CHECKSUM.md) - Checksum algorithm

### Language Guides
- [basic256/README.md](basic256/README.md)
- [fortran/README.md](fortran/README.md)
- [cobol/README.md](cobol/README.md)
- [mips/README.md](mips/README.md)

---

## Team Information

| Role | Developer | Responsibility |
|------|-----------|-----------------|
| **Integration Lead** | Cris | Pipeline orchestration, BASIC-256 |
| **Data Processing** | Anthony | FORTRAN metrics calculation |
| **Business Logic** | Justin | COBOL rules engine, MIPS verification |
| **Quality Assurance** | All | Testing and validation |

---

## Status

**Current Phase**: Development scaffold ready  
**Last Updated**: 2026-09-01  
**Next Step**: Developers begin individual stage implementation

For questions or issues, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) (to be created).


