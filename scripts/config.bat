@REM ========================================================================
@REM PolyFlow Configuration Script
@REM 
@REM Purpose:
@REM   Configure tool paths for the complete pipeline
@REM   Customize settings for your development environment
@REM 
@REM Usage:
@REM   Run this script once to set environment variables
@REM   Paths are stored for use by PolyFlow.bat
@REM 
@REM Author: Cris
@REM Status: Template - Customize with your tool paths
@REM ========================================================================

@ECHO OFF

REM ========================================================================
REM STEP 1: Set BASIC-256 Configuration
REM ========================================================================
REM Set the path to BASIC-256 executable
REM Common locations:
REM   - C:\Program Files\BASIC256\BASIC256.exe (Windows default)
REM   - C:\Program Files (x86)\BASIC256\BASIC256.exe (32-bit)
REM   - /usr/bin/basic256 (Linux/Mac)
REM 
REM TODO: Update this path to your BASIC-256 installation
REM

SET "BASIC256_HOME="
IF NOT DEFINED BASIC256_EXE SET "BASIC256_EXE=basic256"

IF DEFINED BASIC256_EXE (
  ECHO [CONFIG] BASIC-256: !BASIC256_EXE!
) ELSE (
  ECHO [WARNING] BASIC-256 path not configured
  ECHO   Update BASIC256_EXE in this script
)

REM ========================================================================
REM STEP 2: Set FORTRAN Configuration
REM ========================================================================
REM FORTRAN Compiler: gfortran or ifort
REM Verify compiler is in PATH or provide full path
REM 
REM Test: In command prompt, type: gfortran --version
REM 

IF NOT DEFINED FORTRAN_COMPILER SET "FORTRAN_COMPILER=gfortran"
SET "FORTRAN_FLAGS=-o fortran\bin\metrics"
SET "FORTRAN_SOURCE=fortran\procesamiento.f90"

ECHO [CONFIG] FORTRAN Compiler: !FORTRAN_COMPILER!

REM ========================================================================
REM STEP 3: Set COBOL Configuration
REM ========================================================================
REM COBOL Compiler: GnuCOBOL (cobc)
REM Verify compiler is in PATH or provide full path
REM 
REM Test: In command prompt, type: cobc --version
REM 

IF NOT DEFINED COBOL_COMPILER SET "COBOL_COMPILER=cobc"
SET "COBOL_FLAGS=-x -free"
SET "COBOL_SOURCE=cobol\rules_engine.cob"
SET "COBOL_OUTPUT=bin\polyflow_rules.exe"

ECHO [CONFIG] COBOL Compiler: !COBOL_COMPILER!

REM ========================================================================
REM STEP 4: Set MIPS Configuration
REM ========================================================================
REM MIPS Simulator: MARS or QtSPIM
REM Provide the path to your simulator
REM 
REM Downloads:
REM   - MARS: http://courses.missouristate.edu/kaseej/mars/
REM   - QtSPIM: http://spimsimulator.org/
REM 

IF NOT DEFINED MIPS_SIMULATOR SET "MIPS_SIMULATOR="
IF NOT DEFINED MIPS_MARS_JAR SET "MIPS_MARS_JAR="

REM For MARS (Java-based):
REM SET "MIPS_MARS_JAR=C:\path\to\Mars.jar"

REM For QtSPIM (native):
REM SET "MIPS_SIMULATOR=C:\Program Files\QtSPIM\QtSPIM.exe"

IF DEFINED MIPS_SIMULATOR (
  ECHO [CONFIG] MIPS Simulator: !MIPS_SIMULATOR!
) ELSE (
  ECHO [WARNING] MIPS simulator path not configured
  ECHO   Update MIPS_SIMULATOR or MIPS_MARS_JAR in this script
)

REM ========================================================================
REM STEP 5: Set Pipeline Paths
REM ========================================================================

SET "DATA_DIR=data"
SET "INPUT_DIR=input"
SET "OUTPUT_LOG=pipeline.log"

ECHO [CONFIG] Data directory: !DATA_DIR!

REM ========================================================================
REM STEP 6: Verify Directory Structure
REM ========================================================================

IF NOT EXIST "!DATA_DIR!" (
  ECHO [ERROR] Data directory not found: !DATA_DIR!
  GOTO :EOF
)

IF NOT EXIST "basic256\limpieza.kbs" (
  ECHO [WARNING] BASIC-256 source not found: basic256\limpieza.kbs
)

IF NOT EXIST "fortran\procesamiento.f90" (
  ECHO [WARNING] FORTRAN source not found: fortran\procesamiento.f90
)

IF NOT EXIST "cobol\rules_engine.cob" (
  ECHO [WARNING] COBOL source not found: cobol\rules_engine.cob
)

IF NOT EXIST "mips\checksum.asm" (
  ECHO [WARNING] MIPS source not found: mips\checksum.asm
)

REM ========================================================================
REM STEP 7: Display Configuration Summary
REM ========================================================================

ECHO.
ECHO ========================================================================
ECHO Configuration Summary
ECHO ========================================================================
ECHO BASIC-256: !BASIC256_EXE!
ECHO FORTRAN:   !FORTRAN_COMPILER!
ECHO COBOL:     !COBOL_COMPILER!
ECHO MIPS:      !MIPS_SIMULATOR! or !MIPS_MARS_JAR!
ECHO Data Dir:  !DATA_DIR!
ECHO ========================================================================
ECHO.

ECHO Configuration script completed.
ECHO Before running PolyFlow.bat, please:
ECHO   1. Verify all tool paths above are correct
ECHO   2. Test each tool individually (compile, run)
ECHO   3. Ensure all source files are in place
ECHO.
