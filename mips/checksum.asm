; ========================================================================
; PolyFlow - Checksum Verification Stage
; Language: MIPS Assembly
; Author: Justin
; Purpose: Compute integrity checksum over alert and sequence files
;
; Input:  data/alertas.csv + data/secuencia.txt
; Output: data/checksum.txt
;
; Status: Skeleton - TODO: Implement full logic
; ========================================================================

; ========================================================================
; Register Usage
; ========================================================================
; $v0: Return value / syscall results
; $a0-$a3: Arguments
; $t0-$t9: Temporary values
; $s0-$s7: Saved values
;
; TODO: Define detailed register allocation as implementation proceeds
; ========================================================================

.text
.globl main

main:
    # ====================================================================
    # TODO: Initialize program
    # ====================================================================
    # Load program entry message
    # Load file paths into memory
    # Initialize buffers for file data
    
    # ====================================================================
    # TODO: Step 1 - Read alertas.csv
    # ====================================================================
    # Syscall to open file
    # Syscall to read file contents into buffer
    # Track byte count read
    
    # ====================================================================
    # TODO: Step 2 - Read secuencia.txt
    # ====================================================================
    # Syscall to open file
    # Syscall to read file contents into buffer
    # Track byte count read
    
    # ====================================================================
    # TODO: Step 3 - Calculate checksum
    # ====================================================================
    # Call checksum subroutine
    # Pass combined byte stream
    # Receive checksum value in $v0
    
    # ====================================================================
    # TODO: Step 4 - Format result
    # ====================================================================
    # Convert checksum to hexadecimal
    # Format as "CHECKSUM=XXXXXXXX"
    
    # ====================================================================
    # TODO: Step 5 - Write output file
    # ====================================================================
    # Syscall to create/open data/checksum.txt
    # Syscall to write formatted checksum
    # Syscall to close file
    
    # ====================================================================
    # TODO: Step 6 - Exit program
    # ====================================================================
    li $v0, 10    # Syscall 10: exit
    syscall

# ========================================================================
# SUBROUTINE: read_file
# Purpose: Read file contents into memory
# Arguments: 
#   $a0 = file path (string)
#   $a1 = destination buffer
#   $a2 = buffer size
# Returns:
#   $v0 = bytes read
#   $v1 = error code (0 = success)
# ========================================================================

read_file:
    # TODO: Implement file reading
    # 1. Open file using syscall 13
    # 2. Read contents using syscall 14
    # 3. Close file using syscall 16
    # 4. Return byte count and status
    
    jr $ra

# ========================================================================
# SUBROUTINE: calculate_checksum
# Purpose: Compute integrity checksum over byte stream
# Arguments:
#   $a0 = buffer pointer (byte array)
#   $a1 = buffer size (bytes)
# Returns:
#   $v0 = checksum value (32-bit)
# Algorithm: TODO - Choose XOR, SUM, or CRC-32
# ========================================================================

calculate_checksum:
    # TODO: Implement checksum algorithm
    # 
    # Option 1: XOR Checksum (Simplest)
    #   checksum = 0x00000000
    #   for each byte b in buffer:
    #     checksum = checksum XOR b
    #   return checksum
    #
    # Option 2: Sum Checksum
    #   checksum = 0x00000000
    #   for each byte b in buffer:
    #     checksum = (checksum + b) AND 0xFFFFFFFF
    #   return checksum
    #
    # Option 3: CRC-32 (More complex)
    #   Use standard CRC-32 polynomial
    #   See docs/CHECKSUM.md for details
    
    jr $ra

# ========================================================================
# SUBROUTINE: convert_to_hex
# Purpose: Convert 32-bit integer to 8-digit hex string
# Arguments:
#   $a0 = value to convert
#   $a1 = destination buffer (string)
# Returns:
#   $v0 = string length
# ========================================================================

convert_to_hex:
    # TODO: Implement hexadecimal conversion
    # 1. Extract each 4-bit nibble (most significant first)
    # 2. Convert to ASCII hex digit (0-9, A-F uppercase)
    # 3. Store in destination buffer
    # 4. Return length
    
    jr $ra

# ========================================================================
# SUBROUTINE: write_file
# Purpose: Write data to output file
# Arguments:
#   $a0 = file path (string)
#   $a1 = data buffer (string)
#   $a2 = buffer size
# Returns:
#   $v0 = bytes written
#   $v1 = error code (0 = success)
# ========================================================================

write_file:
    # TODO: Implement file writing
    # 1. Create/open file using syscall 13 (write mode)
    # 2. Write contents using syscall 15
    # 3. Close file using syscall 16
    # 4. Return bytes written and status
    
    jr $ra

# ========================================================================
# DATA SECTION
# ========================================================================

.data

# File paths
input_file_alerts:    .asciiz "data/alertas.csv"
input_file_sequence:  .asciiz "data/secuencia.txt"
output_file_checksum: .asciiz "data/checksum.txt"

# Buffers for file data
# TODO: Allocate appropriately based on expected file sizes
buffer_alerts:    .space 10000    # 10KB buffer for alerts
buffer_sequence:  .space 1000     # 1KB buffer for sequence
buffer_output:    .space 100      # Small buffer for output

# Messages
msg_start:        .asciiz "PolyFlow - MIPS Checksum Verification\n"
msg_reading:      .asciiz "Reading input files...\n"
msg_computing:    .asciiz "Computing checksum...\n"
msg_writing:      .asciiz "Writing output...\n"
msg_success:      .asciiz "Checksum verification completed successfully\n"
msg_error:        .asciiz "ERROR: Processing failed\n"

; ========================================================================
; NOTES FOR DEVELOPER
; ========================================================================
; 1. Start with simple XOR checksum, upgrade to CRC-32 if needed
; 2. Test algorithm with known inputs before full implementation
; 3. Verify determinism: same input → same checksum every time
; 4. Handle file I/O errors gracefully
; 5. Test in MARS or QtSPIM simulator
; 6. Document any syscall deviations specific to simulator
; 7. See docs/CHECKSUM.md for algorithm details
; ========================================================================
