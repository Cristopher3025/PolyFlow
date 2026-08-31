# Checksum Algorithm Specification

## Overview

This document defines the checksum algorithm used in the MIPS stage to verify the integrity of the pipeline output. The checksum is computed over the combined data from both COBOL outputs.

---

## Purpose

The checksum provides a cryptographic proof that:
- Data was not corrupted during processing
- All pipeline stages completed correctly
- Results are reproducible and verifiable
- Output files match expected format and content

---

## Algorithm Selection

### Recommendation for Implementation

For this academic project, we recommend **CRC-32** or a simpler **XOR-based checksum**:

#### Option 1: XOR Checksum (Simplest)
```
checksum = 0
for each byte in (alertas.csv + secuencia.txt):
  checksum = checksum XOR byte
```

**Advantages**: Simple, easy to implement in MIPS  
**Disadvantages**: Low collision resistance

#### Option 2: Sum Checksum
```
checksum = 0
for each byte in (alertas.csv + secuencia.txt):
  checksum = (checksum + byte) MOD 2^32
```

**Advantages**: Simple, slightly better distribution  
**Disadvantages**: Doesn't detect reordering

#### Option 3: CRC-32 (Recommended)
Standard cyclic redundancy check with polynomial: `0x04C11DB7`

**Advantages**: Industry standard, good collision detection  
**Disadvantages**: More complex to implement

### Decision

**Choose one algorithm and document your choice in the MIPS code comments.**

The academic evaluation will focus on:
- Correct implementation of chosen algorithm
- Documentation of the algorithm
- Deterministic results (same input → same output)
- Correct output format

---

## Input Data

### Source Files

**File 1**: `data/alertas.csv`
```csv
STATION,RULE_ID,ALERT_TYPE,ALERT_VALUE
COTO,R001,HIGH_TEMPERATURE,38.5
GOLFITO,R004,EXCESSIVE_WIND,65.0
```

**File 2**: `data/secuencia.txt`
```
R001,R004
```

### Byte Stream

Concatenate files in order:
```
STATION,RULE_ID,ALERT_TYPE,ALERT_VALUE
COTO,R001,HIGH_TEMPERATURE,38.5
GOLFITO,R004,EXCESSIVE_WIND,65.0
R001,R004
```

Each file contributes its complete content (including headers).

---

## Output Format

### File

**Location**: `data/checksum.txt`

### Content

**Single line**:
```
CHECKSUM=XXXXXXXX
```

Where `XXXXXXXX` is:
- 8 hexadecimal characters (0-9, A-F)
- Uppercase letters
- Representing 32-bit checksum value
- Prefixed with "CHECKSUM="

### Examples

Valid outputs:
```
CHECKSUM=A3F2E891
CHECKSUM=00000000
CHECKSUM=FFFFFFFF
CHECKSUM=12345678
```

Invalid outputs:
```
CHECKSUM=A3F2E8     (only 6 hex digits)
CHECKSUM=A3F2E8910  (9 hex digits)
CHECKSUM=a3f2e891   (lowercase - must be uppercase)
CHECKSUM = A3F2E891 (spaces - not allowed)
A3F2E891            (missing prefix)
```

---

## Determinism Requirement

**Critical**: The algorithm must be **completely deterministic**.

Same input files must **always** produce the **exact same checksum**.

### Testing Determinism

```
Test 1:
  Input:  alertas.csv, secuencia.txt
  Run 1:  CHECKSUM=A3F2E891
  Run 2:  CHECKSUM=A3F2E891
  Run 3:  CHECKSUM=A3F2E891
  Result: PASS (identical)

Test 2:
  Input:  Modified alertas.csv (one value changed)
  Run 1:  CHECKSUM=B4G3F9902
  Result: PASS (different from Test 1)
```

---

## Algorithm Example: XOR-Based

### Pseudocode

```
FUNCTION compute_checksum(alertas_file, secuencia_file)
  checksum = 0x00000000
  
  // Read alertas.csv
  for each byte b in alertas_file:
    checksum = checksum XOR b
  
  // Read secuencia.txt
  for each byte b in secuencia_file:
    checksum = checksum XOR b
  
  return checksum
END FUNCTION

FUNCTION format_checksum(checksum_value)
  // Convert 32-bit value to 8-digit hex string
  hex_string = convert_to_hex(checksum_value, 8_digits)
  return "CHECKSUM=" + hex_string
END FUNCTION
```

### MIPS Implementation Sketch

```mips
; Read first file, XOR all bytes
; Read second file, XOR all bytes
; Result in $v0

; Convert to hex string
; Write to output file
```

---

## Algorithm Example: CRC-32

### Polynomial

```
0x04C11DB7 (or its reversed form depending on implementation)
```

### Pseudocode

```
FUNCTION crc32(data_bytes)
  crc = 0xFFFFFFFF
  
  for each byte b in data_bytes:
    crc = crc XOR b
    for i = 0 to 7:
      if (crc & 0x80000000) != 0:
        crc = (crc << 1) XOR 0x04C11DB7
      else:
        crc = crc << 1
      crc = crc AND 0xFFFFFFFF
  
  return crc XOR 0xFFFFFFFF
END FUNCTION
```

(Note: Multiple valid implementations exist; use standard reference)

---

## Test Cases

### Test 1: Empty Files

**Input**:
- alertas.csv: Empty (or header only)
- secuencia.txt: Empty

**Expected Output**:
- Specific checksum value (depends on algorithm)
- Must be reproducible

### Test 2: Single Record

**Input**:
- alertas.csv: Header + one alert record
- secuencia.txt: Single rule ID

**Expected Output**:
- Specific checksum value
- Reproducible across runs

### Test 3: Multiple Records

**Input**:
- alertas.csv: Header + multiple alert records
- secuencia.txt: Multiple rule IDs

**Expected Output**:
- Specific checksum value
- Different from Test 1 and Test 2
- Reproducible

### Test 4: Data Corruption Detection

**Input 1**:
- alertas.csv: COTO,R001,HIGH_TEMPERATURE,38.5
- Checksum A: ABC12345

**Input 2** (one byte changed):
- alertas.csv: COTO,R001,HIGH_TEMPERATURE,38.6
- Checksum B: DEF67890

**Expected**:
- Checksum A ≠ Checksum B
- Different data → different checksum

---

## Implementation Checklist

- [ ] Choose algorithm (XOR, SUM, or CRC-32)
- [ ] Implement byte reading from both files
- [ ] Implement checksum calculation
- [ ] Format output as "CHECKSUM=XXXXXXXX"
- [ ] Test with multiple datasets
- [ ] Verify determinism (multiple runs)
- [ ] Verify byte order handling
- [ ] Verify hexadecimal formatting (uppercase)
- [ ] Handle edge cases (empty files)
- [ ] Document algorithm in code comments

---

## Verification

To verify your implementation:

1. **Manual calculation**: Choose simple input, manually compute checksum
2. **Comparison test**: Run twice, verify same input → same checksum
3. **Format validation**: Verify output file format exactly matches spec
4. **Integration test**: Run complete pipeline, verify checksum generated

---

## References

- CRC-32: https://en.wikipedia.org/wiki/Cyclic_redundancy_check
- Checksum algorithms: https://en.wikipedia.org/wiki/Checksum
- MIPS Assembly guide: [Your course materials]
- Data Contract: [DATA_CONTRACT.md](DATA_CONTRACT.md)

---

## Notes

- Start with simple XOR algorithm; upgrade if needed
- Document any deviations from specification
- Include error handling for file I/O
- Consider performance (large files)
- Test thoroughly before final submission

