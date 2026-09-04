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
IF NOT DEFINED FORTRAN_FLAGS SET "FORTRAN_FLAGS=-std=f2008 -Wall -Wextra -O2 -static"

IF NOT EXIST "%DATA_DIR%\datos_crudos.csv" GOTO :ERROR_INPUT
IF NOT EXIST "basic256\limpieza.kbs" GOTO :ERROR_SOURCE
IF NOT EXIST "fortran\procesamiento.f90" GOTO :ERROR_SOURCE
IF NOT EXIST "cobol\rules_engine.cob" GOTO :ERROR_SOURCE
IF NOT EXIST "mips\checksum.asm" GOTO :ERROR_SOURCE
IF NOT EXIST "input\reglas.txt" GOTO :ERROR_SOURCE

DEL /Q "%DATA_DIR%\datos_normalizados.csv" "%DATA_DIR%\metricas.csv" "%DATA_DIR%\alertas.csv" "%DATA_DIR%\secuencia.txt" "%DATA_DIR%\checksum.txt" 2>NUL

ECHO.
ECHO ========================================================================
ECHO PolyFlow Environmental Data Processing Pipeline
ECHO ========================================================================
ECHO.

<NUL SET /P "_s=[BASIC-256] Procesando datos... "
ECHO ==========================================

REM BASIC-256 opens its IDE and does NOT exit after -r.
REM Launch it detached, wait for the output file, then close the IDE.

PUSHD "basic256"
START "" /B "%BASIC256_EXE%" -r limpieza.kbs
POPD

SET /A BASIC_TRIES=0
:BASIC_WAIT
IF EXIST "%DATA_DIR%\datos_normalizados.csv" GOTO :BASIC_READY
PING -n 2 127.0.0.1 >NUL
SET /A BASIC_TRIES+=1
IF %BASIC_TRIES% LSS 30 GOTO :BASIC_WAIT
GOTO :ERROR_OUTPUT

:BASIC_READY
PING -n 3 127.0.0.1 >NUL
TASKKILL /IM basic256.exe /F >NUL 2>&1

IF NOT EXIST "%DATA_DIR%\datos_normalizados.csv" GOTO :ERROR_OUTPUT

ECHO OK
ECHO.

<NUL SET /P "_s=[FORTRAN] Calculando metricas... "
ECHO ==========================================

REM gfortran needs ITS OWN binutils (as.exe, ld.exe) when
REM linking; GnuCOBOL also ships binutils and, if its directory comes
REM first in PATH, gfortran silently fails to link. The toolchain dir is
REM prepended only for the compile and the PATH is restored right after,
REM so the COBOL runtime DLLs keep resolving correctly later.

SET "SAVED_PATH=%PATH%"
IF EXIST "C:\msys64\ucrt64\bin\gfortran.exe" SET "PATH=C:\msys64\ucrt64\bin;%PATH%"

"%FORTRAN_COMPILER%" !FORTRAN_FLAGS! ^
    -o "%BIN_DIR%\polyflow_metrics.exe" ^
    fortran\procesamiento.f90

SET "FC_EXIT=!ERRORLEVEL!"
SET "PATH=%SAVED_PATH%"

IF NOT "!FC_EXIT!"=="0" GOTO :ERROR_STAGE

"%BIN_DIR%\polyflow_metrics.exe"

SET "RUN_EXIT=!ERRORLEVEL!"
IF NOT "!RUN_EXIT!"=="0" GOTO :ERROR_STAGE
IF NOT EXIST "%DATA_DIR%\metricas.csv" GOTO :ERROR_OUTPUT

ECHO OK
ECHO.

<NUL SET /P "_s=[COBOL] Evaluando reglas... "
ECHO ==========================================

"%COBOL_COMPILER%" -x -free -Wall ^
    -o "%BIN_DIR%\polyflow_rules.exe" ^
    cobol\rules_engine.cob

SET "CC_EXIT=!ERRORLEVEL!"
IF NOT "!CC_EXIT!"=="0" GOTO :ERROR_STAGE

"%BIN_DIR%\polyflow_rules.exe"

SET "CR_EXIT=!ERRORLEVEL!"
IF NOT "!CR_EXIT!"=="0" GOTO :ERROR_STAGE
IF NOT EXIST "%DATA_DIR%\alertas.csv" GOTO :ERROR_OUTPUT
IF NOT EXIST "%DATA_DIR%\secuencia.txt" GOTO :ERROR_OUTPUT

ECHO OK
ECHO.

<NUL SET /P "_s=[MIPS] Calculando firma... "
ECHO ==========================================

IF DEFINED MIPS_MARS_JAR GOTO :MARS
IF DEFINED MIPS_SIMULATOR GOTO :QTSPIM

ECHO [ERROR] Configure MIPS_MARS_JAR or MIPS_SIMULATOR in scripts\config.bat
GOTO :ERROR_STAGE

:MARS

IF NOT EXIST "%MIPS_MARS_JAR%" GOTO :ERROR_MIPS_CONFIG

java -jar "%MIPS_MARS_JAR%" nc mips\checksum.asm

SET "MARS_EXIT=!ERRORLEVEL!"
IF NOT "!MARS_EXIT!"=="0" GOTO :ERROR_STAGE

GOTO :CHECK_MIPS_OUTPUT

:QTSPIM

"%MIPS_SIMULATOR%" -file mips\checksum.asm

SET "SPIM_EXIT=!ERRORLEVEL!"
IF NOT "!SPIM_EXIT!"=="0" GOTO :ERROR_STAGE

GOTO :CHECK_MIPS_OUTPUT

:CHECK_MIPS_OUTPUT

IF NOT EXIST "%DATA_DIR%\checksum.txt" GOTO :ERROR_OUTPUT

REM MARS writes LF-only line endings; FINDSTR /X fails on LF-only files,
REM so the line is re-normalized to CRLF in a temp file before validating.
SET "CS_LINE="
FOR /F "usebackq delims=" %%L IN ("%DATA_DIR%\checksum.txt") DO SET "CS_LINE=%%L"
IF NOT DEFINED CS_LINE GOTO :ERROR_OUTPUT

>"%TEMP%\polyflow_checksum.tmp" ECHO !CS_LINE!
FINDSTR /R /X /C:"CHECKSUM=[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]" "%TEMP%\polyflow_checksum.tmp" >NUL
SET "CS_VALID=!ERRORLEVEL!"
DEL /Q "%TEMP%\polyflow_checksum.tmp" 2>NUL

IF NOT "!CS_VALID!"=="0" GOTO :ERROR_OUTPUT

ECHO OK
ECHO.

ECHO ========================================================================
ECHO PIPELINE COMPLETADO
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
