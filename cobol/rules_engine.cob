       IDENTIFICATION DIVISION.
       PROGRAM-ID. RULES-ENGINE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT METRICS-FILE
               ASSIGN TO "data/metrics.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS METRICS-FILE-STATUS.

           SELECT RULES-FILE
               ASSIGN TO "input/rules.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS RULES-FILE-STATUS.

           SELECT ALERTS-FILE
               ASSIGN TO "data/alerts.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS ALERTS-FILE-STATUS.

           SELECT SEQUENCE-FILE
               ASSIGN TO "data/sequence.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS SEQUENCE-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD METRICS-FILE.
       01 METRICS-LINE PIC X(500).

       FD RULES-FILE.
       01 RULES-LINE PIC X(500).

       FD ALERTS-FILE.
       01 ALERTS-LINE PIC X(500).

       FD SEQUENCE-FILE.
       01 SEQUENCE-LINE PIC X(100000).

       WORKING-STORAGE SECTION.

       78 MAX-RULES VALUE 100.

       *> ==============================================================
       *> File status
       *> ==============================================================

       01 METRICS-FILE-STATUS  PIC XX.
       01 RULES-FILE-STATUS    PIC XX.
       01 ALERTS-FILE-STATUS   PIC XX.
       01 SEQUENCE-FILE-STATUS PIC XX.

       *> ==============================================================
       *> Processing control
       *> ==============================================================

       01 END-OF-METRICS PIC X VALUE "N".
           88 METRICS-FINISHED VALUE "Y".

       01 END-OF-RULES PIC X VALUE "N".
           88 RULES-FINISHED VALUE "Y".

       01 RULES-COUNT        PIC 9(3) VALUE 0.
       01 METRICS-COUNT      PIC 9(9) VALUE 0.
       01 ALERTS-COUNT       PIC 9(9) VALUE 0.
       01 INVALID-RULES-COUNT PIC 9(3) VALUE 0.

       01 RULE-INDEX PIC 9(3) VALUE 0.

       *> ==============================================================
       *> Metric CSV fields
       *> ==============================================================

       01 METRIC-RECORD.
           05 STATION-TEXT          PIC X(30).
           05 AVG-TEMPERATURE-TEXT  PIC X(20).
           05 MAX-TEMPERATURE-TEXT  PIC X(20).
           05 MIN-TEMPERATURE-TEXT  PIC X(20).
           05 TOTAL-PRECIP-TEXT     PIC X(20).
           05 AVG-WIND-TEXT         PIC X(20).
           05 AVG-BATTERY-TEXT      PIC X(20).

       *> ==============================================================
       *> Numeric metric values
       *> ==============================================================

       01 METRIC-VALUES.
           05 AVG-TEMPERATURE-VALUE PIC S9(7)V9(4) COMP-3 VALUE 0.
           05 MAX-TEMPERATURE-VALUE PIC S9(7)V9(4) COMP-3 VALUE 0.
           05 MIN-TEMPERATURE-VALUE PIC S9(7)V9(4) COMP-3 VALUE 0.
           05 TOTAL-PRECIP-VALUE    PIC S9(7)V9(4) COMP-3 VALUE 0.
           05 AVG-WIND-VALUE        PIC S9(7)V9(4) COMP-3 VALUE 0.
           05 AVG-BATTERY-VALUE     PIC S9(7)V9(4) COMP-3 VALUE 0.

       *> ==============================================================
       *> Rule parser tokens
       *> ==============================================================

       01 RULE-TOKENS.
           05 TOKEN-01 PIC X(30).
           05 TOKEN-02 PIC X(30).
           05 TOKEN-03 PIC X(30).
           05 TOKEN-04 PIC X(10).
           05 TOKEN-05 PIC X(30).
           05 TOKEN-06 PIC X(10).
           05 TOKEN-07 PIC X(30).
           05 TOKEN-08 PIC X(10).
           05 TOKEN-09 PIC X(30).
           05 TOKEN-10 PIC X(10).
           05 TOKEN-11 PIC X(50).

       *> ==============================================================
       *> Rule table
       *> ==============================================================

       01 RULE-TABLE.
           05 RULE-ENTRY OCCURS 100 TIMES.
               10 STORED-RULE-ID           PIC X(10).
               10 STORED-FIELD-1           PIC X(30).
               10 STORED-OPERATOR-1        PIC X(2).
               10 STORED-THRESHOLD-1       PIC S9(7)V9(4) COMP-3.
               10 STORED-LOGICAL-OPERATOR  PIC X(3).
               10 STORED-FIELD-2           PIC X(30).
               10 STORED-OPERATOR-2        PIC X(2).
               10 STORED-THRESHOLD-2       PIC S9(7)V9(4) COMP-3.
               10 STORED-ACTION            PIC X(50).
               10 STORED-HAS-SECOND-TERM   PIC X VALUE "N".

       *> ==============================================================
       *> Evaluation variables
       *> ==============================================================

       01 FIELD-VALUE-1 PIC S9(7)V9(4) COMP-3 VALUE 0.
       01 FIELD-VALUE-2 PIC S9(7)V9(4) COMP-3 VALUE 0.

       01 CONDITION-1-RESULT PIC X VALUE "N".
           88 CONDITION-1-TRUE VALUE "Y".

       01 CONDITION-2-RESULT PIC X VALUE "N".
           88 CONDITION-2-TRUE VALUE "Y".

       01 RULE-MATCHED PIC X VALUE "N".
           88 RULE-IS-MATCHED VALUE "Y".

       *> ==============================================================
       *> Output formatting
       *> ==============================================================

       01 ALERT-VALUE-DISPLAY PIC -ZZZZZZ9.9999.

       01 ALERT-TYPE-OUTPUT PIC X(50).

       01 SEQUENCE-BUFFER PIC X(100000) VALUE SPACES.
       01 SEQUENCE-POINTER PIC 9(6) VALUE 1.

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           DISPLAY "========================================".
           DISPLAY "        POLYFLOW - COBOL STAGE".
           DISPLAY "========================================".

           PERFORM LOAD-RULES.

           IF RULES-COUNT = 0
               DISPLAY "ERROR: No valid rules were loaded."
               STOP RUN
           END-IF.

           PERFORM OPEN-OUTPUT-FILES.
           PERFORM PROCESS-METRICS.
           PERFORM WRITE-SEQUENCE-FILE.
           PERFORM CLOSE-OUTPUT-FILES.

           DISPLAY "========================================".
           DISPLAY "Rules loaded:        " RULES-COUNT.
           DISPLAY "Invalid rules:       " INVALID-RULES-COUNT.
           DISPLAY "Records processed:   " METRICS-COUNT.
           DISPLAY "Alerts generated:    " ALERTS-COUNT.
           DISPLAY "COBOL stage completed successfully.".
           DISPLAY "========================================".

           STOP RUN.

       *> ==============================================================
       *> Rule loading
       *> ==============================================================

       LOAD-RULES.

           DISPLAY "[COBOL] Loading rules...".

           OPEN INPUT RULES-FILE.

           IF RULES-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: Could not open input/rules.txt"
               DISPLAY "File status: " RULES-FILE-STATUS
               STOP RUN
           END-IF.

           MOVE "N" TO END-OF-RULES.

           PERFORM UNTIL RULES-FINISHED

               READ RULES-FILE
                   AT END
                       SET RULES-FINISHED TO TRUE

                   NOT AT END
                       IF FUNCTION TRIM(RULES-LINE) NOT = SPACES
                           IF RULES-LINE(1:1) NOT = "#"
                               PERFORM PARSE-RULE
                           END-IF
                       END-IF
               END-READ

           END-PERFORM.

           CLOSE RULES-FILE.

           DISPLAY "[COBOL] Rules loaded successfully.".

       *> ==============================================================
       *> Rule parsing
       *> ==============================================================

       PARSE-RULE.

           MOVE SPACES TO RULE-TOKENS.

           UNSTRING RULES-LINE
               DELIMITED BY ALL SPACES
               INTO
                   TOKEN-01
                   TOKEN-02
                   TOKEN-03
                   TOKEN-04
                   TOKEN-05
                   TOKEN-06
                   TOKEN-07
                   TOKEN-08
                   TOKEN-09
                   TOKEN-10
                   TOKEN-11
           END-UNSTRING.

           IF TOKEN-01 NOT = "RULE"
               PERFORM REJECT-RULE
           ELSE
               IF TOKEN-06 = "->" OR TOKEN-06 = "=>"
                   PERFORM VALIDATE-SIMPLE-RULE
               ELSE
                   IF TOKEN-06 = "AND" OR TOKEN-06 = "OR"
                       PERFORM VALIDATE-COMPOUND-RULE
                   ELSE
                       PERFORM REJECT-RULE
                   END-IF
               END-IF
           END-IF.

       VALIDATE-SIMPLE-RULE.

           IF TOKEN-07 = SPACES
               PERFORM REJECT-RULE
           ELSE
               IF TOKEN-03 = SPACES
                   OR TOKEN-04 = SPACES
                   OR TOKEN-05 = SPACES
                   PERFORM REJECT-RULE
               ELSE
                   PERFORM STORE-SIMPLE-RULE
               END-IF
           END-IF.

       VALIDATE-COMPOUND-RULE.

           IF TOKEN-10 NOT = "->"
               AND TOKEN-10 NOT = "=>"
               PERFORM REJECT-RULE
           ELSE
               IF TOKEN-11 = SPACES
                   OR TOKEN-07 = SPACES
                   OR TOKEN-08 = SPACES
                   OR TOKEN-09 = SPACES
                   PERFORM REJECT-RULE
               ELSE
                   PERFORM STORE-COMPOUND-RULE
               END-IF
           END-IF.

       REJECT-RULE.

           ADD 1 TO INVALID-RULES-COUNT.

           DISPLAY "WARNING: Invalid rule ignored: "
               FUNCTION TRIM(RULES-LINE).

       *> ==============================================================
       *> Store rules
       *> ==============================================================

       STORE-SIMPLE-RULE.

           IF RULES-COUNT >= MAX-RULES
               DISPLAY "ERROR: Maximum number of rules exceeded."
               STOP RUN
           END-IF.

           ADD 1 TO RULES-COUNT.

           MOVE TOKEN-02
               TO STORED-RULE-ID(RULES-COUNT).

           MOVE TOKEN-03
               TO STORED-FIELD-1(RULES-COUNT).

           MOVE TOKEN-04
               TO STORED-OPERATOR-1(RULES-COUNT).

           MOVE FUNCTION NUMVAL(FUNCTION TRIM(TOKEN-05))
               TO STORED-THRESHOLD-1(RULES-COUNT).

           MOVE SPACES
               TO STORED-LOGICAL-OPERATOR(RULES-COUNT).

           MOVE SPACES
               TO STORED-FIELD-2(RULES-COUNT).

           MOVE SPACES
               TO STORED-OPERATOR-2(RULES-COUNT).

           MOVE 0
               TO STORED-THRESHOLD-2(RULES-COUNT).

           MOVE TOKEN-07
               TO STORED-ACTION(RULES-COUNT).

           MOVE "N"
               TO STORED-HAS-SECOND-TERM(RULES-COUNT).

           DISPLAY "  ["
               FUNCTION TRIM(TOKEN-02)
               "] "
               FUNCTION TRIM(TOKEN-03)
               " "
               FUNCTION TRIM(TOKEN-04)
               " "
               FUNCTION TRIM(TOKEN-05)
               " -> "
               FUNCTION TRIM(TOKEN-07).

       STORE-COMPOUND-RULE.

           IF RULES-COUNT >= MAX-RULES
               DISPLAY "ERROR: Maximum number of rules exceeded."
               STOP RUN
           END-IF.

           ADD 1 TO RULES-COUNT.

           MOVE TOKEN-02
               TO STORED-RULE-ID(RULES-COUNT).

           MOVE TOKEN-03
               TO STORED-FIELD-1(RULES-COUNT).

           MOVE TOKEN-04
               TO STORED-OPERATOR-1(RULES-COUNT).

           MOVE FUNCTION NUMVAL(FUNCTION TRIM(TOKEN-05))
               TO STORED-THRESHOLD-1(RULES-COUNT).

           MOVE TOKEN-06
               TO STORED-LOGICAL-OPERATOR(RULES-COUNT).

           MOVE TOKEN-07
               TO STORED-FIELD-2(RULES-COUNT).

           MOVE TOKEN-08
               TO STORED-OPERATOR-2(RULES-COUNT).

           MOVE FUNCTION NUMVAL(FUNCTION TRIM(TOKEN-09))
               TO STORED-THRESHOLD-2(RULES-COUNT).

           MOVE TOKEN-11
               TO STORED-ACTION(RULES-COUNT).

           MOVE "Y"
               TO STORED-HAS-SECOND-TERM(RULES-COUNT).

           DISPLAY "  ["
               FUNCTION TRIM(TOKEN-02)
               "] "
               FUNCTION TRIM(TOKEN-03)
               " "
               FUNCTION TRIM(TOKEN-04)
               " "
               FUNCTION TRIM(TOKEN-05)
               " "
               FUNCTION TRIM(TOKEN-06)
               " "
               FUNCTION TRIM(TOKEN-07)
               " "
               FUNCTION TRIM(TOKEN-08)
               " "
               FUNCTION TRIM(TOKEN-09)
               " -> "
               FUNCTION TRIM(TOKEN-11).

       *> ==============================================================
       *> Output files
       *> ==============================================================

       OPEN-OUTPUT-FILES.

           OPEN OUTPUT ALERTS-FILE.

           IF ALERTS-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: Could not create data/alerts.csv"
               DISPLAY "File status: " ALERTS-FILE-STATUS
               STOP RUN
           END-IF.

           OPEN OUTPUT SEQUENCE-FILE.

           IF SEQUENCE-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: Could not create data/sequence.txt"
               DISPLAY "File status: " SEQUENCE-FILE-STATUS
               CLOSE ALERTS-FILE
               STOP RUN
           END-IF.

           MOVE
               "STATION,RULE_ID,ALERT_TYPE,ALERT_VALUE"
               TO ALERTS-LINE.

           WRITE ALERTS-LINE.

       *> ==============================================================
       *> Metric processing
       *> ==============================================================

       PROCESS-METRICS.

           DISPLAY "[COBOL] Processing metrics...".

           OPEN INPUT METRICS-FILE.

           IF METRICS-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: Could not open data/metrics.csv"
               DISPLAY "File status: " METRICS-FILE-STATUS
               STOP RUN
           END-IF.

           MOVE "N" TO END-OF-METRICS.

           READ METRICS-FILE
               AT END
                   SET METRICS-FINISHED TO TRUE
           END-READ.

           PERFORM UNTIL METRICS-FINISHED

               READ METRICS-FILE
                   AT END
                       SET METRICS-FINISHED TO TRUE

                   NOT AT END
                       IF FUNCTION TRIM(METRICS-LINE) NOT = SPACES
                           PERFORM PARSE-METRIC-RECORD
                           PERFORM CONVERT-METRIC-VALUES
                           ADD 1 TO METRICS-COUNT
                           PERFORM EVALUATE-ALL-RULES
                       END-IF
               END-READ

           END-PERFORM.

           CLOSE METRICS-FILE.

       PARSE-METRIC-RECORD.

           MOVE SPACES TO METRIC-RECORD.

           UNSTRING METRICS-LINE
               DELIMITED BY ","
               INTO
                   STATION-TEXT
                   AVG-TEMPERATURE-TEXT
                   MAX-TEMPERATURE-TEXT
                   MIN-TEMPERATURE-TEXT
                   TOTAL-PRECIP-TEXT
                   AVG-WIND-TEXT
                   AVG-BATTERY-TEXT
           END-UNSTRING.

       CONVERT-METRIC-VALUES.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(AVG-TEMPERATURE-TEXT))
               TO AVG-TEMPERATURE-VALUE.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(MAX-TEMPERATURE-TEXT))
               TO MAX-TEMPERATURE-VALUE.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(MIN-TEMPERATURE-TEXT))
               TO MIN-TEMPERATURE-VALUE.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(TOTAL-PRECIP-TEXT))
               TO TOTAL-PRECIP-VALUE.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(AVG-WIND-TEXT))
               TO AVG-WIND-VALUE.

           MOVE FUNCTION NUMVAL(
               FUNCTION TRIM(AVG-BATTERY-TEXT))
               TO AVG-BATTERY-VALUE.

       *> ==============================================================
       *> Rule evaluation
       *> ==============================================================

       EVALUATE-ALL-RULES.

           PERFORM VARYING RULE-INDEX FROM 1 BY 1
               UNTIL RULE-INDEX > RULES-COUNT

               PERFORM EVALUATE-CURRENT-RULE

               IF RULE-IS-MATCHED
                   PERFORM WRITE-ALERT
                   PERFORM APPEND-SEQUENCE
               END-IF

           END-PERFORM.

       EVALUATE-CURRENT-RULE.

           MOVE "N" TO RULE-MATCHED.
           MOVE "N" TO CONDITION-1-RESULT.
           MOVE "N" TO CONDITION-2-RESULT.

           PERFORM GET-FIRST-FIELD-VALUE.
           PERFORM EVALUATE-FIRST-CONDITION.

           IF STORED-HAS-SECOND-TERM(RULE-INDEX) = "Y"

               PERFORM GET-SECOND-FIELD-VALUE
               PERFORM EVALUATE-SECOND-CONDITION

               EVALUATE FUNCTION TRIM(
                   STORED-LOGICAL-OPERATOR(RULE-INDEX))

                   WHEN "AND"
                       IF CONDITION-1-TRUE
                           AND CONDITION-2-TRUE
                           SET RULE-IS-MATCHED TO TRUE
                       END-IF

                   WHEN "OR"
                       IF CONDITION-1-TRUE
                           OR CONDITION-2-TRUE
                           SET RULE-IS-MATCHED TO TRUE
                       END-IF

               END-EVALUATE

           ELSE

               IF CONDITION-1-TRUE
                   SET RULE-IS-MATCHED TO TRUE
               END-IF

           END-IF.

       GET-FIRST-FIELD-VALUE.

           MOVE 0 TO FIELD-VALUE-1.

           EVALUATE FUNCTION TRIM(
               STORED-FIELD-1(RULE-INDEX))

               WHEN "TEMPERATURE"
                   MOVE AVG-TEMPERATURE-VALUE TO FIELD-VALUE-1

               WHEN "PRECIPITATION"
                   MOVE TOTAL-PRECIP-VALUE TO FIELD-VALUE-1

               WHEN "WIND"
                   MOVE AVG-WIND-VALUE TO FIELD-VALUE-1

               WHEN "BATTERY"
                   MOVE AVG-BATTERY-VALUE TO FIELD-VALUE-1

           END-EVALUATE.

       GET-SECOND-FIELD-VALUE.

           MOVE 0 TO FIELD-VALUE-2.

           EVALUATE FUNCTION TRIM(
               STORED-FIELD-2(RULE-INDEX))

               WHEN "TEMPERATURE"
                   MOVE AVG-TEMPERATURE-VALUE TO FIELD-VALUE-2

               WHEN "PRECIPITATION"
                   MOVE TOTAL-PRECIP-VALUE TO FIELD-VALUE-2

               WHEN "WIND"
                   MOVE AVG-WIND-VALUE TO FIELD-VALUE-2

               WHEN "BATTERY"
                   MOVE AVG-BATTERY-VALUE TO FIELD-VALUE-2

           END-EVALUATE.

       EVALUATE-FIRST-CONDITION.

           EVALUATE FUNCTION TRIM(
               STORED-OPERATOR-1(RULE-INDEX))

               WHEN ">"
                   IF FIELD-VALUE-1 >
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

               WHEN "<"
                   IF FIELD-VALUE-1 <
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

               WHEN ">="
                   IF FIELD-VALUE-1 >=
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

               WHEN "<="
                   IF FIELD-VALUE-1 <=
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

               WHEN "=="
                   IF FIELD-VALUE-1 =
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

               WHEN "!="
                   IF FIELD-VALUE-1 NOT =
                       STORED-THRESHOLD-1(RULE-INDEX)
                       SET CONDITION-1-TRUE TO TRUE
                   END-IF

           END-EVALUATE.

       EVALUATE-SECOND-CONDITION.

           EVALUATE FUNCTION TRIM(
               STORED-OPERATOR-2(RULE-INDEX))

               WHEN ">"
                   IF FIELD-VALUE-2 >
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

               WHEN "<"
                   IF FIELD-VALUE-2 <
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

               WHEN ">="
                   IF FIELD-VALUE-2 >=
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

               WHEN "<="
                   IF FIELD-VALUE-2 <=
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

               WHEN "=="
                   IF FIELD-VALUE-2 =
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

               WHEN "!="
                   IF FIELD-VALUE-2 NOT =
                       STORED-THRESHOLD-2(RULE-INDEX)
                       SET CONDITION-2-TRUE TO TRUE
                   END-IF

           END-EVALUATE.

       *> ==============================================================
       *> Alert generation
       *> ==============================================================

       WRITE-ALERT.

           ADD 1 TO ALERTS-COUNT.

           MOVE FIELD-VALUE-1
               TO ALERT-VALUE-DISPLAY.

           MOVE STORED-ACTION(RULE-INDEX)
               TO ALERT-TYPE-OUTPUT.

           IF ALERT-TYPE-OUTPUT(1:6) = "ALERT_"
               MOVE ALERT-TYPE-OUTPUT(7:)
                   TO ALERT-TYPE-OUTPUT
           END-IF.

           MOVE SPACES TO ALERTS-LINE.

           STRING
               FUNCTION TRIM(STATION-TEXT)
               ","
               FUNCTION TRIM(STORED-RULE-ID(RULE-INDEX))
               ","
               FUNCTION TRIM(ALERT-TYPE-OUTPUT)
               ","
               FUNCTION TRIM(ALERT-VALUE-DISPLAY)
               DELIMITED BY SIZE
               INTO ALERTS-LINE
           END-STRING.

           WRITE ALERTS-LINE.

           DISPLAY "[ALERT] "
               FUNCTION TRIM(STATION-TEXT)
               " -> "
               FUNCTION TRIM(ALERT-TYPE-OUTPUT).

       *> ==============================================================
       *> Sequence generation
       *> ==============================================================

       APPEND-SEQUENCE.

           IF ALERTS-COUNT > 1
               STRING
                   ","
                   FUNCTION TRIM(
                       STORED-RULE-ID(RULE-INDEX))
                   DELIMITED BY SIZE
                   INTO SEQUENCE-BUFFER
                   WITH POINTER SEQUENCE-POINTER
               END-STRING
           ELSE
               STRING
                   FUNCTION TRIM(
                       STORED-RULE-ID(RULE-INDEX))
                   DELIMITED BY SIZE
                   INTO SEQUENCE-BUFFER
                   WITH POINTER SEQUENCE-POINTER
               END-STRING
           END-IF.

       WRITE-SEQUENCE-FILE.

           MOVE SEQUENCE-BUFFER TO SEQUENCE-LINE.

           WRITE SEQUENCE-LINE.

       CLOSE-OUTPUT-FILES.

           CLOSE ALERTS-FILE.
           CLOSE SEQUENCE-FILE.
