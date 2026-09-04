# ============================================================
# PolyFlow - Stage 4: MIPS Checksum Verification
# ============================================================
# Input : data/secuencia.txt (alert identifiers produced by COBOL)
# Output: data/checksum.txt  (CHECKSUM=XXXXXXXX)
#
# Algorithm (per course specification):
#   Each alert identifier maps to a numeric value:
#     TEMP_ALTA      = 10
#     LLUVIA_INTENSA = 20
#     VIENTO_FUERTE  = 30
#     BATERIA_BAJA   = 40
#
#   For every alert found, in sequence order:
#     checksum = checksum + value
#     checksum = checksum XOR position   (position starts at 0)
#
#   The final 32-bit checksum is written as 8 uppercase hex digits.
# ============================================================

.data

sequencePath:
    .asciiz "data/secuencia.txt"

checksumPath:
    .asciiz "data/checksum.txt"

readBuffer:
    .space 4096

tokenBuffer:
    .space 64

outputBuffer:
    .space 32

hexDigits:
    .asciiz "0123456789ABCDEF"

# Identifier table
idTemp:
    .asciiz "TEMP_ALTA"
idLluvia:
    .asciiz "LLUVIA_INTENSA"
idViento:
    .asciiz "VIENTO_FUERTE"
idBateria:
    .asciiz "BATERIA_BAJA"

errorOpenInput:
    .asciiz "ERROR: Could not open data/secuencia.txt\n"

errorOpenOutput:
    .asciiz "ERROR: Could not create data/checksum.txt\n"

successMessage:
    .asciiz "[MIPS] Checksum generated successfully.\n"

.text
.globl main

# ============================================================
# main
#   $s0 = checksum
#   $s1 = position
#   $s2 = token buffer write pointer
#   $s3 = token length
#   $s4 = total bytes read
#   $s5 = read index
#   $s6 = token buffer base
# ============================================================

main:

    li   $s0, 0
    li   $s1, 0
    la   $s2, tokenBuffer
    la   $s6, tokenBuffer
    li   $s3, 0

    # Open input file (read-only)
    li   $v0, 13
    la   $a0, sequencePath
    li   $a1, 0
    li   $a2, 0
    syscall

    bltz $v0, open_input_error
    move $s7, $v0

    # Read the whole file (small academic datasets)
    li   $v0, 14
    move $a0, $s7
    la   $a1, readBuffer
    li   $a2, 4096
    syscall

    bltz $v0, read_error
    move $s4, $v0

    # Close input file
    li   $v0, 16
    move $a0, $s7
    syscall

    # Tokenize and evaluate
    li   $s5, 0

process_loop:

    bge  $s5, $s4, process_done

    la   $t1, readBuffer
    add  $t1, $t1, $s5
    lbu  $t0, 0($t1)
    addi $s5, $s5, 1

    # Delimiters: ',' (44), LF (10), CR (13)
    li   $t2, 44
    beq  $t0, $t2, delimiter
    li   $t2, 10
    beq  $t0, $t2, delimiter
    li   $t2, 13
    beq  $t0, $t2, delimiter

    # Append byte to current token
    sb   $t0, 0($s2)
    addi $s2, $s2, 1
    addi $s3, $s3, 1
    li   $t2, 63
    ble  $s3, $t2, process_loop

    # Token too long: reset and continue
    la   $s2, tokenBuffer
    li   $s3, 0
    j    process_loop

delimiter:

    beqz $s3, process_loop
    sb   $zero, 0($s2)
    j    evaluate_token

process_done:

    # Flush trailing token (file may not end with a separator)
    beqz $s3, build_output
    sb   $zero, 0($s2)
    j    evaluate_token

# ============================================================
# evaluate_token: compare tokenBuffer against known identifiers
#   $t3 = comparison index
# ============================================================

evaluate_token:

    li   $t3, 0

check_temp:

    la   $t4, idTemp
    add  $t5, $t4, $t3
    lbu  $t1, 0($t5)
    add  $t5, $s6, $t3
    lbu  $t2, 0($t5)
    bne  $t1, $t2, check_lluvia
    beqz $t2, match_temp
    addi $t3, $t3, 1
    j    check_temp

check_lluvia:

    li   $t3, 0

check_lluvia_loop:

    la   $t4, idLluvia
    add  $t5, $t4, $t3
    lbu  $t1, 0($t5)
    add  $t5, $s6, $t3
    lbu  $t2, 0($t5)
    bne  $t1, $t2, check_viento
    beqz $t2, match_lluvia
    addi $t3, $t3, 1
    j    check_lluvia_loop

check_viento:

    li   $t3, 0

check_viento_loop:

    la   $t4, idViento
    add  $t5, $t4, $t3
    lbu  $t1, 0($t5)
    add  $t5, $s6, $t3
    lbu  $t2, 0($t5)
    bne  $t1, $t2, check_bateria
    beqz $t2, match_viento
    addi $t3, $t3, 1
    j    check_viento_loop

check_bateria:

    li   $t3, 0

check_bateria_loop:

    la   $t4, idBateria
    add  $t5, $t4, $t3
    lbu  $t1, 0($t5)
    add  $t5, $s6, $t3
    lbu  $t2, 0($t5)
    bne  $t1, $t2, no_match
    beqz $t2, match_bateria
    addi $t3, $t3, 1
    j    check_bateria_loop

# ------------------------------------------------------------
# match handlers: identifier -> numeric value (course mapping)
# ------------------------------------------------------------

match_temp:

    li   $t6, 10
    j    apply_match

match_lluvia:

    li   $t6, 20
    j    apply_match

match_viento:

    li   $t6, 30
    j    apply_match

match_bateria:

    li   $t6, 40
    j    apply_match

# ------------------------------------------------------------
# apply_match:
#   checksum = checksum + value
#   checksum = checksum XOR position
#   position = position + 1
# Then (also for unknown tokens): reset token and continue.
# ------------------------------------------------------------

apply_match:

    add  $s0, $s0, $t6
    xor  $s0, $s0, $s1
    addi $s1, $s1, 1

no_match:

    la   $s2, tokenBuffer
    li   $s3, 0
    j    process_loop

# ============================================================
# build_output
# Builds "CHECKSUM=XXXXXXXX\n" in outputBuffer
# ============================================================

build_output:

    la   $t0, outputBuffer

    li   $t1, 'C'
    sb   $t1, 0($t0)
    li   $t1, 'H'
    sb   $t1, 1($t0)
    li   $t1, 'E'
    sb   $t1, 2($t0)
    li   $t1, 'C'
    sb   $t1, 3($t0)
    li   $t1, 'K'
    sb   $t1, 4($t0)
    li   $t1, 'S'
    sb   $t1, 5($t0)
    li   $t1, 'U'
    sb   $t1, 6($t0)
    li   $t1, 'M'
    sb   $t1, 7($t0)
    li   $t1, '='
    sb   $t1, 8($t0)

    # Write 8 hexadecimal digits starting at offset 9
    addi $t0, $t0, 9

    li   $t3, 28

hex_loop:

    bltz $t3, finish_output

    srlv $t4, $s0, $t3
    andi $t4, $t4, 0x000F

    la   $t5, hexDigits
    add  $t5, $t5, $t4

    lbu  $t6, 0($t5)
    sb   $t6, 0($t0)

    addi $t0, $t0, 1
    addi $t3, $t3, -4

    j    hex_loop

finish_output:

    li   $t1, 10
    sb   $t1, 0($t0)

    addi $t0, $t0, 1
    sb   $zero, 0($t0)

    j    write_checksum_file

# ============================================================
# write_checksum_file
# Writes "CHECKSUM=XXXXXXXX\n" to data/checksum.txt
# ============================================================

write_checksum_file:

    # Open output file (write/create)
    li   $v0, 13
    la   $a0, checksumPath
    li   $a1, 1
    li   $a2, 0
    syscall

    bltz $v0, open_output_error
    move $s7, $v0

    # Write 18 bytes: "CHECKSUM=" (9) + 8 hex digits + newline (1)
    li   $v0, 15
    move $a0, $s7
    la   $a1, outputBuffer
    li   $a2, 18
    syscall

    # Close output file
    li   $v0, 16
    move $a0, $s7
    syscall

    # Success message
    li   $v0, 4
    la   $a0, successMessage
    syscall

    # Exit
    li   $v0, 10
    syscall

open_input_error:

    li   $v0, 4
    la   $a0, errorOpenInput
    syscall

    li   $v0, 10
    syscall

read_error:

    li   $v0, 4
    la   $a0, errorOpenInput
    syscall

    li   $v0, 10
    syscall

open_output_error:

    li   $v0, 4
    la   $a0, errorOpenOutput
    syscall

    li   $v0, 10
    syscall
