# MIPS - Checksum Verification (Updated)

## Overview

This component implements integrity verification of the pipeline output using checksum computation in MIPS assembly.

**Responsible Developer**: Justin  
**Language**: MIPS Assembly  
**Development Environment**: VS Code with MIPS simulator (MARS or QtSPIM)

---

## Input/Output Specification

### Input
- **File**: `data/alertas.csv`
- **Format**: CSV with alert records (STATION, RULE_ID, ALERT_TYPE, ALERT_VALUE)
- **Source**: COBOL rules engine

- **File**: `data/secuencia.txt`
- **Format**: Plain text, single line with comma-separated rule IDs
- **Source**: COBOL rules engine

### Output
- **File**: `data/checksum.txt`
- **Format**: Plain text, single line: `CHECKSUM=<value>`
- **Content**: 8-character hexadecimal checksum value
- **Purpose**: Verify data integrity and detect corruption

---

## Checksum Algorithm

### Specification

The checksum is computed over combined data from both input files.

**Algorithm**: CRC-32 or simple XOR-based checksum (to be fully documented in CHECKSUM.md)

**Process**:
1. Read all bytes from alertas.csv
2. Read all bytes from secuencia.txt
3. Apply checksum algorithm to combined byte stream
4. Format result as 8-character hexadecimal string

**Output Format**:
```
CHECKSUM=A3F2E891
```

---

## Implementation Roadmap

### Phase 1: Scaffolding (Current)
- [x] Create file structure and README
- [ ] Implement basic program skeleton
- [ ] Define checksum algorithm

### Phase 2: Core Functionality
- [ ] Implement file I/O in MIPS
- [ ] Implement byte reading logic
- [ ] Implement checksum calculation

### Phase 3: Integration Testing
- [ ] Test with sample output from COBOL
- [ ] Verify checksum reproducibility
- [ ] Validate output format

### Phase 4: Documentation & Refinement
- [ ] Document algorithm in detail (CHECKSUM.md)
- [ ] Add comprehensive comments
- [ ] Test edge cases

---

## Development Guidelines

### 1. Algorithm Selection
- Simple checksum: XOR all bytes
- Moderate: Sum all bytes with wrap
- Complex: CRC-32 (if familiar)
- Choose based on simplicity vs. robustness

### 2. Testing
```
Test 1: Known input
  Input:  Simple file with known content
  Verify: Checksum reproducible

Test 2: Different data
  Input:  Two different input files
  Verify: Different checksums produced

Test 3: Byte order
  Input:  Test byte ordering issues
  Verify: Consistent results
```

---

## References

- [Data Contract](../docs/DATA_CONTRACT.md) - Input/output specifications (sections 4-6)
- [Checksum Algorithm](../docs/CHECKSUM.md) - Detailed algorithm documentation (to be created)
- [Architecture](../docs/ARCHITECTURE.md) - Pipeline overview
- Test data: Sample alert files in `tests/`
