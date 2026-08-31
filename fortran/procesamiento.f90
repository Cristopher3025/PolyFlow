! ========================================================================
! PolyFlow - Metrics Calculation Stage
! Language: FORTRAN
! Author: Anthony
! Purpose: Process normalized environmental data and calculate metrics
! 
! Input:  data/datos_normalizados.csv
! Output: data/metricas.csv
!
! Status: Skeleton - TODO: Implement full logic
! ========================================================================

PROGRAM POLYFLOW_METRICS
  IMPLICIT NONE
  
  ! ====================================================================
  ! TODO: Define constants
  ! ====================================================================
  ! INTEGER, PARAMETER :: MAX_RECORDS = 10000
  ! INTEGER, PARAMETER :: MAX_STATIONS = 100
  ! CHARACTER(LEN=*), PARAMETER :: INPUT_FILE = "data/datos_normalizados.csv"
  ! CHARACTER(LEN=*), PARAMETER :: OUTPUT_FILE = "data/metricas.csv"
  
  ! ====================================================================
  ! TODO: Define data types
  ! ====================================================================
  ! TYPE :: NORMALIZED_RECORD
  !   CHARACTER(LEN=10) :: id
  !   CHARACTER(LEN=20) :: station
  !   REAL(KIND=8) :: temperature
  !   REAL(KIND=8) :: precipitation
  !   REAL(KIND=8) :: wind
  !   INTEGER :: battery
  ! END TYPE NORMALIZED_RECORD
  
  ! TYPE :: METRIC_RESULT
  !   CHARACTER(LEN=20) :: station
  !   REAL(KIND=8) :: avg_temperature
  !   REAL(KIND=8) :: max_temperature
  !   REAL(KIND=8) :: min_temperature
  !   REAL(KIND=8) :: total_precipitation
  !   REAL(KIND=8) :: avg_wind
  !   REAL(KIND=8) :: avg_battery
  ! END TYPE METRIC_RESULT
  
  ! ====================================================================
  ! MAIN PROGRAM
  ! ====================================================================
  
  PRINT *, "======================================================================"
  PRINT *, "PolyFlow - Metrics Calculation Stage (FORTRAN)"
  PRINT *, "======================================================================"
  PRINT *, ""
  
  ! TODO: Step 1 - Open input file
  ! IF input file not found:
  !   PRINT *, "ERROR: Input file not found"
  !   PRINT *, "Path: data/datos_normalizados.csv"
  !   STOP
  ! END IF
  
  ! TODO: Step 2 - Read all records from normalized CSV
  ! OPEN(UNIT=10, FILE=INPUT_FILE, STATUS='OLD', ACTION='READ')
  ! Read header line
  ! FOR each data line:
  !   Parse fields
  !   Store in record array
  ! CLOSE(UNIT=10)
  
  ! TODO: Step 3 - Group records by station
  ! Create station list from records
  ! Sort stations alphabetically
  
  ! TODO: Step 4 - Calculate metrics for each station
  ! FOR each unique station:
  !   Calculate AVG_TEMPERATURE from records
  !   Calculate MAX_TEMPERATURE from records
  !   Calculate MIN_TEMPERATURE from records
  !   Calculate TOTAL_PRECIPITATION from records
  !   Calculate AVG_WIND from records
  !   Calculate AVG_BATTERY from records
  ! END FOR
  
  ! TODO: Step 5 - Write output CSV
  ! OPEN(UNIT=20, FILE=OUTPUT_FILE, STATUS='REPLACE', ACTION='WRITE')
  ! Write header: STATION,AVG_TEMPERATURE,MAX_TEMPERATURE,...
  ! FOR each station metrics:
  !   Format and write CSV line
  ! CLOSE(UNIT=20)
  
  ! TODO: Step 6 - Display summary
  ! PRINT *, "Records read: ", record_count
  ! PRINT *, "Stations processed: ", station_count
  ! PRINT *, "Output file: ", OUTPUT_FILE
  ! PRINT *, ""
  ! PRINT *, "Metrics calculation completed successfully"
  
  STOP "TODO: Implement FORTRAN metrics calculation"
  
END PROGRAM POLYFLOW_METRICS

! ========================================================================
! SUBROUTINES (to be implemented)
! ========================================================================

! SUBROUTINE read_normalized_data(records, count)
!   PURPOSE: Read normalized CSV data
!   INPUT:   File path (data/datos_normalizados.csv)
!   OUTPUT:  Array of records, record count
! END SUBROUTINE

! SUBROUTINE aggregate_by_station(records, count, stations, station_count)
!   PURPOSE: Group records by weather station
!   INPUT:   Array of records, record count
!   OUTPUT:  List of unique stations, count
! END SUBROUTINE

! SUBROUTINE calculate_statistics(records, count, station_name, metrics)
!   PURPOSE: Calculate all metrics for a single station
!   INPUT:   Records array, count, station name
!   OUTPUT:  Calculated metrics struct
! END SUBROUTINE

! SUBROUTINE write_metrics_csv(metrics_array, count, output_file)
!   PURPOSE: Write metrics to CSV output file
!   INPUT:   Metrics array, count, output filename
!   OUTPUT:  CSV file written
! END SUBROUTINE

! ========================================================================
! NOTES FOR DEVELOPER
! ========================================================================
! 1. Use REAL(KIND=8) for floating-point calculations (64-bit precision)
! 2. Handle CSV parsing carefully (comma delimiters, quoted fields)
! 3. Test with sample data from tests/datos_prueba.csv
! 4. Verify output format matches DATA_CONTRACT.md exactly
! 5. Include error handling for file I/O and data validation
! ========================================================================
