.data

alertsPath:
    .asciiz "data/alerts.csv"

sequencePath:
    .asciiz "data/sequence.txt"

checksumPath:
    .asciiz "data/checksum.txt"

readBuffer:
    .space 4096

outputBuffer:
    .space 32

errorOpenInput:
    .asciiz "ERROR: Could not open input file.\n"

errorOpenOutput:
    .asciiz "ERROR: Could not create checksum file.\n"

successMessage:
    .asciiz "MIPS checksum generated successfully.\n"

newline:
    .asciiz "\n"

hexDigits:
    .asciiz "0123456789ABCDEF"


.text
.globl main


# ============================================================
# Main
# ============================================================

main:

    li   $s0, 0

    # Process alerts.csv
    la   $a0, alertsPath
    jal  process_file

    # Process sequence.txt
    la   $a0, sequencePath
    jal  process_file

    # Build CHECKSUM=XXXXXXXX
    jal  build_output

    # Write checksum.txt
    jal  write_checksum_file

    # Success message
    li   $v0, 4
    la   $a0, successMessage
    syscall

    # Exit
    li   $v0, 10
    syscall


# ============================================================
# process_file
#
# Input:
#   $a0 = address of file path
#
# Uses:
#   $s0 = accumulated XOR checksum
#
# Reads the file in chunks and applies XOR to every byte.
# ============================================================

process_file:

    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)

    # Open file for reading
    li   $v0, 13
    li   $a1, 0
    li   $a2, 0
    syscall

    bltz $v0, input_file_error

    move $s1, $v0


read_file_loop:

    # Read up to 4096 bytes
    li   $v0, 14
    move $a0, $s1
    la   $a1, readBuffer
    li   $a2, 4096
    syscall

    # Negative value = read error
    bltz $v0, input_file_error_close

    # Zero bytes = end of file
    beqz $v0, close_input_file

    move $s2, $v0

    la   $t0, readBuffer
    li   $t1, 0


xor_byte_loop:

    beq  $t1, $s2, read_file_loop

    lbu  $t2, 0($t0)

    xor  $s0, $s0, $t2

    addi $t0, $t0, 1
    addi $t1, $t1, 1

    j    xor_byte_loop


close_input_file:

    li   $v0, 16
    move $a0, $s1
    syscall

    lw   $s2, 0($sp)
    lw   $s1, 4($sp)
    lw   $ra, 8($sp)
    addi $sp, $sp, 12

    jr   $ra


input_file_error_close:

    li   $v0, 16
    move $a0, $s1
    syscall


input_file_error:

    li   $v0, 4
    la   $a0, errorOpenInput
    syscall

    li   $v0, 10
    syscall


# ============================================================
# build_output
#
# Creates:
#   CHECKSUM=XXXXXXXX
#
# The checksum is represented as 8 uppercase hexadecimal digits.
# ============================================================

build_output:

    la   $t0, outputBuffer

    # Write "CHECKSUM="
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

    # Start writing hexadecimal digits at position 9
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

    jr   $ra


# ============================================================
# write_checksum_file
#
# Writes exactly:
#
# CHECKSUM=XXXXXXXX\n
# ============================================================

write_checksum_file:

    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s1, 0($sp)

    # Open output file
    li   $v0, 13
    la   $a0, checksumPath
    li   $a1, 1
    li   $a2, 0
    syscall

    bltz $v0, output_file_error

    move $s1, $v0

    # Write 18 bytes:
    # 9  -> CHECKSUM=
    # 8  -> hexadecimal digits
    # 1  -> newline
    li   $v0, 15
    move $a0, $s1
    la   $a1, outputBuffer
    li   $a2, 18
    syscall

    # Close file
    li   $v0, 16
    move $a0, $s1
    syscall

    lw   $s1, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8

    jr   $ra


output_file_error:

    li   $v0, 4
    la   $a0, errorOpenOutput
    syscall

    li   $v0, 10
    syscall