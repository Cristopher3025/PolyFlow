! ========================================================================
! PolyFlow - Metrics Calculation Stage
! Language: FORTRAN
! Author: Anthony
! Purpose: Process normalized environmental data and calculate metrics
! 
! Input:  data/datos_normalizados.csv
! Output: data/metricas.csv
!
! Status: Implemented
! ========================================================================

PROGRAM POLYFLOW_METRICS
  IMPLICIT NONE

  ! ====================================================================
  ! Constants
  ! ====================================================================
  INTEGER, PARAMETER :: MAX_RECORDS = 10000
  INTEGER, PARAMETER :: MAX_STATIONS = 100
  CHARACTER(LEN=*), PARAMETER :: INPUT_FILE = "data/datos_normalizados.csv"
  CHARACTER(LEN=*), PARAMETER :: OUTPUT_FILE = "data/metricas.csv"

  ! ====================================================================
  ! Data types
  ! ====================================================================
  TYPE :: NORMALIZED_RECORD
    CHARACTER(LEN=10) :: id
    CHARACTER(LEN=20) :: station
    REAL(KIND=8) :: temperature
    REAL(KIND=8) :: precipitation
    REAL(KIND=8) :: wind
    REAL(KIND=8) :: battery
  END TYPE NORMALIZED_RECORD

  TYPE :: METRIC_RESULT
    CHARACTER(LEN=20) :: station
    REAL(KIND=8) :: avg_temperature
    REAL(KIND=8) :: max_temperature
    REAL(KIND=8) :: min_temperature
    REAL(KIND=8) :: total_precipitation
    REAL(KIND=8) :: avg_wind
    REAL(KIND=8) :: max_wind
    REAL(KIND=8) :: avg_battery
  END TYPE METRIC_RESULT

  ! ====================================================================
  ! Working variables
  ! ====================================================================
  TYPE(NORMALIZED_RECORD) :: records(MAX_RECORDS)
  TYPE(METRIC_RESULT)     :: metrics(MAX_STATIONS)
  CHARACTER(LEN=20)       :: stations(MAX_STATIONS)
  INTEGER :: record_count
  INTEGER :: station_count
  INTEGER :: i

  ! ====================================================================
  ! MAIN PROGRAM
  ! ====================================================================

  PRINT *, "======================================================================"
  PRINT *, "PolyFlow - Metrics Calculation Stage (FORTRAN)"
  PRINT *, "======================================================================"
  PRINT *, ""

  ! Step 1 & 2 - Open and read all records from normalized CSV
  CALL read_normalized_data(INPUT_FILE, records, record_count, MAX_RECORDS)

  IF (record_count == 0) THEN
    PRINT *, "ERROR: No valid records found in input file"
    PRINT *, "Path: ", INPUT_FILE
    STOP 1
  END IF

  ! -- Test print: show every record that was read --
  PRINT *, "----------------------------------------------------------------------"
  PRINT *, "Records read from file (verification):"
  PRINT *, "----------------------------------------------------------------------"
  DO i = 1, record_count
    WRITE(*, '(A,A,A,A,A,F7.2,A,F7.2,A,F7.2,A,F6.1)') &
      ' ID=', TRIM(records(i)%id),                      &
      '  STATION=', TRIM(records(i)%station),            &
      '  TEMP=', records(i)%temperature,                 &
      '  PRECIP=', records(i)%precipitation,             &
      '  WIND=', records(i)%wind,                        &
      '  BAT=', records(i)%battery
  END DO
  PRINT *, ""
  WRITE(*, '(A,I0,A)') ' Total: ', record_count, ' records read successfully.'
  PRINT *, ""

  ! Step 3 - Group records by station (unique list, sorted alphabetically)
  CALL aggregate_by_station(records, record_count, stations, station_count, MAX_STATIONS)

  ! Step 4 - Calculate metrics for each station
  DO i = 1, station_count
    CALL calculate_statistics(records, record_count, stations(i), metrics(i))
  END DO

  ! Step 5 - Write output CSV
  CALL write_metrics_csv(metrics, station_count, OUTPUT_FILE)

  ! Step 6 - Display summary
  PRINT *, "----------------------------------------------------------------------"
  PRINT *, "Summary:"
  PRINT *, "----------------------------------------------------------------------"
  WRITE(*, '(A,I0)') ' Records read:       ', record_count
  WRITE(*, '(A,I0)') ' Stations processed: ', station_count
  PRINT *, "Output file:        ", OUTPUT_FILE
  PRINT *, ""
  PRINT *, "Metrics calculation completed successfully"

CONTAINS

  ! ======================================================================
  ! SUBROUTINE read_normalized_data
  ! PURPOSE: Read normalized CSV data
  ! INPUT:   File path (data/datos_normalizados.csv)
  ! OUTPUT:  Array of records, record count
  ! ======================================================================
  SUBROUTINE read_normalized_data(file_path, out_records, out_count, max_size)
    CHARACTER(LEN=*), INTENT(IN) :: file_path
    TYPE(NORMALIZED_RECORD), INTENT(OUT) :: out_records(:)
    INTEGER, INTENT(OUT) :: out_count
    INTEGER, INTENT(IN) :: max_size

    INTEGER :: unit_in, ios
    CHARACTER(LEN=200) :: header_line
    CHARACTER(LEN=10) :: rec_id
    CHARACTER(LEN=20) :: rec_station
    REAL(KIND=8) :: rec_temp, rec_precip, rec_wind, rec_battery

    out_count = 0
    unit_in = 10

    OPEN(UNIT=unit_in, FILE=file_path, STATUS='OLD', ACTION='READ', IOSTAT=ios)
    IF (ios /= 0) THEN
      PRINT *, "ERROR: Cannot open input file"
      PRINT *, "Path: ", file_path
      STOP 1
    END IF

    ! Read header line
    READ(unit_in, '(A)', IOSTAT=ios) header_line

    ! Read each data line
    DO
      IF (out_count >= max_size) THEN
        PRINT *, "WARNING: MAX_RECORDS reached, remaining lines ignored"
        EXIT
      END IF

      READ(unit_in, *, IOSTAT=ios) rec_id, rec_station, rec_temp, &
           rec_precip, rec_wind, rec_battery

      IF (ios /= 0) EXIT  ! end of file or malformed line -> stop reading

      out_count = out_count + 1
      out_records(out_count)%id            = rec_id
      out_records(out_count)%station       = rec_station
      out_records(out_count)%temperature   = rec_temp
      out_records(out_count)%precipitation = rec_precip
      out_records(out_count)%wind          = rec_wind
      out_records(out_count)%battery       = rec_battery
    END DO

    CLOSE(unit_in)
  END SUBROUTINE read_normalized_data

  ! ======================================================================
  ! SUBROUTINE aggregate_by_station
  ! PURPOSE: Group records by weather station
  ! INPUT:   Array of records, record count
  ! OUTPUT:  List of unique stations (sorted alphabetically), count
  ! ======================================================================
  SUBROUTINE aggregate_by_station(in_records, in_count, out_stations, out_count, max_size)
    TYPE(NORMALIZED_RECORD), INTENT(IN) :: in_records(:)
    INTEGER, INTENT(IN) :: in_count
    CHARACTER(LEN=20), INTENT(OUT) :: out_stations(:)
    INTEGER, INTENT(OUT) :: out_count
    INTEGER, INTENT(IN) :: max_size

    INTEGER :: i, j
    LOGICAL :: found
    CHARACTER(LEN=20) :: temp_swap

    out_count = 0

    DO i = 1, in_count
      found = .FALSE.
      DO j = 1, out_count
        IF (TRIM(out_stations(j)) == TRIM(in_records(i)%station)) THEN
          found = .TRUE.
          EXIT
        END IF
      END DO

      IF (.NOT. found) THEN
        IF (out_count >= max_size) THEN
          PRINT *, "WARNING: MAX_STATIONS reached, extra stations ignored"
          CYCLE
        END IF
        out_count = out_count + 1
        out_stations(out_count) = in_records(i)%station
      END IF
    END DO

    ! Simple alphabetical sort (bubble sort - station lists are small)
    DO i = 1, out_count - 1
      DO j = 1, out_count - i
        IF (TRIM(out_stations(j)) > TRIM(out_stations(j + 1))) THEN
          temp_swap = out_stations(j)
          out_stations(j) = out_stations(j + 1)
          out_stations(j + 1) = temp_swap
        END IF
      END DO
    END DO
  END SUBROUTINE aggregate_by_station

  ! ======================================================================
  ! SUBROUTINE calculate_statistics
  ! PURPOSE: Calculate all metrics for a single station
  ! INPUT:   Records array, count, station name
  ! OUTPUT:  Calculated metrics struct
  ! ======================================================================
  SUBROUTINE calculate_statistics(in_records, in_count, station_name, out_metrics)
    TYPE(NORMALIZED_RECORD), INTENT(IN) :: in_records(:)
    INTEGER, INTENT(IN) :: in_count
    CHARACTER(LEN=20), INTENT(IN) :: station_name
    TYPE(METRIC_RESULT), INTENT(OUT) :: out_metrics

    INTEGER :: i, n
    REAL(KIND=8) :: sum_temp, sum_wind, sum_battery, sum_precip
    REAL(KIND=8) :: max_temp, min_temp, max_wind

    n = 0
    sum_temp = 0.0D0
    sum_wind = 0.0D0
    sum_battery = 0.0D0
    sum_precip = 0.0D0
    max_temp = -HUGE(1.0D0)
    min_temp = HUGE(1.0D0)
    max_wind = -HUGE(1.0D0)

    DO i = 1, in_count
      IF (TRIM(in_records(i)%station) == TRIM(station_name)) THEN
        n = n + 1
        sum_temp = sum_temp + in_records(i)%temperature
        sum_wind = sum_wind + in_records(i)%wind
        sum_battery = sum_battery + in_records(i)%battery
        sum_precip = sum_precip + in_records(i)%precipitation
        IF (in_records(i)%temperature > max_temp) max_temp = in_records(i)%temperature
        IF (in_records(i)%temperature < min_temp) min_temp = in_records(i)%temperature
        IF (in_records(i)%wind > max_wind) max_wind = in_records(i)%wind
      END IF
    END DO

    out_metrics%station = station_name
    IF (n > 0) THEN
      out_metrics%avg_temperature = sum_temp / REAL(n, KIND=8)
      out_metrics%avg_wind = sum_wind / REAL(n, KIND=8)
      out_metrics%avg_battery = sum_battery / REAL(n, KIND=8)
    ELSE
      out_metrics%avg_temperature = 0.0D0
      out_metrics%avg_wind = 0.0D0
      out_metrics%avg_battery = 0.0D0
    END IF
    out_metrics%max_temperature = max_temp
    out_metrics%min_temperature = min_temp
    out_metrics%total_precipitation = sum_precip
    out_metrics%max_wind = max_wind
  END SUBROUTINE calculate_statistics

  ! ======================================================================
  ! SUBROUTINE write_metrics_csv
  ! PURPOSE: Write metrics to CSV output file
  ! INPUT:   Metrics array, count, output filename
  ! OUTPUT:  CSV file written
  ! ======================================================================
  SUBROUTINE write_metrics_csv(in_metrics, in_count, file_path)
    TYPE(METRIC_RESULT), INTENT(IN) :: in_metrics(:)
    INTEGER, INTENT(IN) :: in_count
    CHARACTER(LEN=*), INTENT(IN) :: file_path

    INTEGER :: unit_out, ios, i

    unit_out = 20
    OPEN(UNIT=unit_out, FILE=file_path, STATUS='REPLACE', ACTION='WRITE', IOSTAT=ios)
    IF (ios /= 0) THEN
      PRINT *, "ERROR: Cannot create output file"
      PRINT *, "Path: ", file_path
      STOP 1
    END IF

    WRITE(unit_out, '(A)') "ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM"

    DO i = 1, in_count
      WRITE(unit_out, '(A,",",F0.2,",",F0.2,",",F0.2,",",F0.1,",",F0.2,",",F0.2,",",F0.1)') &
            TRIM(in_metrics(i)%station), &
            in_metrics(i)%avg_temperature, &
            in_metrics(i)%max_temperature, &
            in_metrics(i)%min_temperature, &
            in_metrics(i)%total_precipitation, &
            in_metrics(i)%avg_wind, &
            in_metrics(i)%max_wind, &
            in_metrics(i)%avg_battery
    END DO

    CLOSE(unit_out)
  END SUBROUTINE write_metrics_csv

END PROGRAM POLYFLOW_METRICS
