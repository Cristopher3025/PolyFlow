@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM ========================================================================
REM PolyFlow - Master Pipeline Orchestrator (Windows)
REM BASIC-256 -> FORTRAN -> COBOL -> MIPS
REM ========================================================================

CD /D "%~dp0"

IF EXIST "scripts\config.bat" CALL "scripts\config.bat"

SET "DATA_DIR=data"
SET "BIN_DIR=bin"

IF NOT EXIST "%BIN_DIR%" MKDIR "%BIN_DIR%"

IF NOT DEFINED BASIC256_EXE SET "BASIC256_EXE=basic256"
IF NOT DEFINED FORTRAN_COMPILER SET "FORTRAN_COMPILER=gfortran"
IF NOT DEFINED COBOL_COMPILER SET "COBOL_COMPILER=cobc"

IF NOT EXIST "%DATA_DIR%\datos_crudos.csv" GOTO :ERROR_INPUT
IF NOT EXIST "basic256\limpieza.kbs" GOTO :ERROR_SOURCE
IF NOT EXIST "fortran\procesamiento.f90" GOTO :ERROR_SOURCE
IF NOT EXIST "cobol\rules_engine.cob" GOTO :ERROR_SOURCE
IF NOT EXIST "mips\checksum.asm" GOTO :ERROR_SOURCE
IF NOT EXIST "input\rules.txt" GOTO :ERROR_SOURCE

DEL /Q "%DATA_DIR%\datos_normalizados.csv" "%DATA_DIR%\metricas.csv" "%DATA_DIR%\alertas.csv" "%DATA_DIR%\secuencia.txt" "%DATA_DIR%\checksum.txt" 2>NUL

ECHO.
ECHO ========================================================================
ECHO PolyFlow Environmental Data Processing Pipeline
ECHO ========================================================================
ECHO.

ECHO [1/4] BASIC-256 - Data Cleaning and Validation
ECHO ==========================================

PUSHD "basic256"
"%BASIC256_EXE%" -s limpieza.kbs
SET "BASIC_EXIT=!ERRORLEVEL!"
POPD

IF NOT "!BASIC_EXIT!"=="0" GOTO :ERROR_STAGE

IF NOT EXIST "%DATA_DIR%\datos_normalizados.csv" GOTO :ERROR_OUTPUT

ECHO [OK] BASIC-256 completed.
ECHO.

ECHO [2/4] FORTRAN - Metrics Calculation
ECHO ==========================================

"%FORTRAN_COMPILER%" -std=f2008 -Wall -Wextra -O2 ^
    -o "%BIN_DIR%\polyflow_metrics.exe" ^
    fortran\procesamiento.f90

IF ERRORLEVEL 1 GOTO :ERROR_STAGE

"%BIN_DIR%\polyflow_metrics.exe"

IF ERRORLEVEL 1 GOTO :ERROR_STAGE
IF NOT EXIST "%DATA_DIR%\metricas.csv" GOTO :ERROR_OUTPUT

ECHO [OK] FORTRAN completed.
ECHO.

ECHO [3/4] COBOL - Rules Engine and Alert Generation
ECHO ==========================================

"%COBOL_COMPILER%" -x -free -Wall ^
    -o "%BIN_DIR%\polyflow_rules.exe" ^
    cobol\rules_engine.cob

IF ERRORLEVEL 1 GOTO :ERROR_STAGE

"%BIN_DIR%\polyflow_rules.exe"

IF ERRORLEVEL 1 GOTO :ERROR_STAGE
IF NOT EXIST "%DATA_DIR%\alertas.csv" GOTO :ERROR_OUTPUT
IF NOT EXIST "%DATA_DIR%\secuencia.txt" GOTO :ERROR_OUTPUT

ECHO [OK] COBOL completed.
ECHO.

ECHO [4/4] MIPS - Checksum Integrity Verification
ECHO ==========================================

IF DEFINED MIPS_MARS_JAR GOTO :MARS
IF DEFINED MIPS_SIMULATOR GOTO :QTSPIM

ECHO [ERROR] Configure MIPS_MARS_JAR or MIPS_SIMULATOR in scripts\config.bat
GOTO :ERROR_STAGE

:MARS

IF NOT EXIST "%MIPS_MARS_JAR%" GOTO :ERROR_MIPS_CONFIG

java -jar "%MIPS_MARS_JAR%" nc mips\checksum.asm

IF ERRORLEVEL 1 GOTO :ERROR_STAGE

GOTO :CHECK_MIPS_OUTPUT

:QTSPIM

"%MIPS_SIMULATOR%" -file mips\checksum.asm

IF ERRORLEVEL 1 GOTO :ERROR_STAGE

GOTO :CHECK_MIPS_OUTPUT

:CHECK_MIPS_OUTPUT

IF NOT EXIST "%DATA_DIR%\checksum.txt" GOTO :ERROR_OUTPUT

FINDSTR /R /X /C:"CHECKSUM=[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]" ^
    "%DATA_DIR%\checksum.txt" >NUL

IF ERRORLEVEL 1 GOTO :ERROR_OUTPUT

ECHO [OK] MIPS completed.
ECHO.

ECHO ========================================================================
ECHO PIPELINE COMPLETED SUCCESSFULLY
ECHO ========================================================================

EXIT /B 0


:ERROR_INPUT

ECHO [ERROR] Missing data\datos_crudos.csv
EXIT /B 1


:ERROR_SOURCE

ECHO [ERROR] A required source/configuration file is missing.
EXIT /B 1


:ERROR_OUTPUT

ECHO [ERROR] An expected stage output was not generated correctly.
EXIT /B 1


:ERROR_MIPS_CONFIG

ECHO [ERROR] MARS JAR not found: %MIPS_MARS_JAR%
EXIT /B 1


:ERROR_STAGE

ECHO [ERROR] Pipeline stage failed. Execution aborted.
EXIT /B 1