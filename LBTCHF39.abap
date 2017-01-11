***INCLUDE LBTCHF39.

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_CALCULATE_JOB_STARTDATES    *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM CALC_NEXT_JOB_STARTDATES                                 *
*---------------------------------------------------------------------*
* Diese Funktion berechnet die naechsten Starttermine eines           *
* zeitperiodischen Jobs unter Beruecksichtigung eines evtl.           *
* vorliegenden Fabrik-Kalenders bis zu einem vorgegebenen             *
* Zeithorizont.                                                       *
*---------------------------------------------------------------------*
FORM CALC_NEXT_JOB_STARTDATES TABLES JOB_TABLE STRUCTURE TBTCJOB
                                     USING  DATE_HORIZON
                                            TIME_HORIZON
                                     VALUE(GIVEN_JOB) STRUCTURE TBTCJOB.

  DATA: BEGIN OF NEXT_JOB.
    INCLUDE STRUCTURE TBTCJOB.
  DATA: END OF NEXT_JOB.

  DATA: DATE_TIME_HORIZON_REACHED TYPE I.

  NEXT_JOB = GIVEN_JOB.

  IF GIVEN_JOB-EMERGMODE = BTC_STDT_ONWORKDAY.
*     der vorliegende Job ist auf einen Arbeitstag innerhalb
*     eines Monats eingeplant

    WHILE DATE_TIME_HORIZON_REACHED = 0.

      PERFORM CALC_NEW_WORKDAY
        USING
          GIVEN_JOB NEXT_JOB.

      IF NEXT_JOB-SDLSTRTDT > DATE_HORIZON OR
         ( NEXT_JOB-SDLSTRTDT = DATE_HORIZON AND
           NEXT_JOB-SDLSTRTTM > TIME_HORIZON ).
        DATE_TIME_HORIZON_REACHED = 1.
      ELSE.
        JOB_TABLE = NEXT_JOB.
        APPEND JOB_TABLE.
        GIVEN_JOB = NEXT_JOB.
      ENDIF.

    ENDWHILE.

  ELSE.
*     der vorliegende Job ist ueber Datum/Uhrzeit eingeplant
    WHILE DATE_TIME_HORIZON_REACHED = 0.

      PERFORM CALC_NEW_START_DATE
        USING
          GIVEN_JOB NEXT_JOB.

      IF NEXT_JOB-SDLSTRTDT > DATE_HORIZON OR
         ( NEXT_JOB-SDLSTRTDT = DATE_HORIZON AND
           NEXT_JOB-SDLSTRTTM > TIME_HORIZON ).
        DATE_TIME_HORIZON_REACHED = 1.
      ELSE.
        JOB_TABLE = NEXT_JOB.
        APPEND JOB_TABLE.
        GIVEN_JOB = NEXT_JOB.
      ENDIF.

    ENDWHILE.

  ENDIF.

ENDFORM. " CALC_NEXT_JOB

*---------------------------------------------------------------------*
*       FORM CALC_NEW_START_DATE                                      *
*---------------------------------------------------------------------*
* Diese Funktion berechnet den naechsten Starttermin eines            *
* zeit-periodischen Jobs unter Beruecksichtigung eines evtl.          *
* vorliegenden Fabrik-Kalenders.                                      *
*                                                                     *
*---------------------------------------------------------------------*
FORM CALC_NEW_START_DATE
  USING
    GIVEN_JOB STRUCTURE TBTCJOB
    NEXT_JOB STRUCTURE TBTCJOB.

DATA:
*   Variable fuer Fabrikkalender
  NEXT_DATE_OK TYPE I,
  CAL_ID LIKE SCAL-FCALID,
  CAL_INDICATOR LIKE SCAL-INDICATOR,
  CAL_DATE LIKE SCAL-DATE,
  CAL_FDATE LIKE SCAL-FACDATE,
  CAL_WORKDAY LIKE SCAL-INDICATOR,
  FCAL_CORRECT LIKE TBTCS-CALCORRECT,
  NEXT_START_INT TYPE I,
  FCAL_START_INT TYPE I.


*  Zur besseren Uebersicht:
*  - GIVEN_JOB: enthaelt die Werte des vorgelegten Jobs,
*               dessen Periodenwerte fuer die Berechnung
*               verwendet werden
*  - NEXT_JOB:  wird nach dieser Funktion die Werte des
*               aufgrund der Wdh.periode erneut eingeplanten
*               Jobs enthalten
*               wobei hier alle Werte ausser
*               - CALCORRECT
*               - EOMCORRECT
*               - SDLSTRTDT
*               - SDLSTRTTM
*               vom Job GIVEN_JOB kopiert werden

*   Korrektur fuer Termin-Verschiebung gemaess Fabrik-Kalender
  IF GIVEN_JOB-CALCORRECT <> 0.

    GIVEN_JOB-SDLSTRTDT = GIVEN_JOB-SDLSTRTDT - GIVEN_JOB-CALCORRECT.
    NEXT_JOB-CALCORRECT = 0.
  ENDIF.

  PERFORM CALC_NEXT_START_DATE
    USING
      GIVEN_JOB NEXT_JOB.

  IF GIVEN_JOB-CALENDARID <> SPACE AND
     GIVEN_JOB-PRDBEHAV <> BTC_PROCESS_ALWAYS.
*   naechster Starttermin muss gegen Fabrik-Kalender verprobt werden

    CAL_ID = GIVEN_JOB-CALENDARID.
    CASE GIVEN_JOB-PRDBEHAV.
      WHEN BTC_DONT_PROCESS_ON_HOLIDAY.
        CAL_INDICATOR = '+'.
      WHEN BTC_PROCESS_BEFORE_HOLIDAY.
        CAL_INDICATOR = '-'.
      WHEN BTC_PROCESS_AFTER_HOLIDAY.
        CAL_INDICATOR = '+'.
      WHEN BTC_PROCESS_ALWAYS.
        CAL_INDICATOR = '+'.
      WHEN OTHERS.
        CAL_INDICATOR = '+'.
    ENDCASE.
    NEXT_DATE_OK = 0.

    WHILE NEXT_DATE_OK = 0.

      CAL_DATE = NEXT_JOB-SDLSTRTDT.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          CORRECT_OPTION = CAL_INDICATOR
          DATE = CAL_DATE
          FACTORY_CALENDAR_ID = CAL_ID
        IMPORTING
          DATE = CAL_DATE
          FACTORYDATE = CAL_FDATE
          WORKINGDAY_INDICATOR = CAL_WORKDAY
        EXCEPTIONS
          OTHERS = 99.

      IF CAL_WORKDAY = SPACE.
*         der naechste Starttermin ist ein Werktag

        NEXT_DATE_OK = 1.
      ELSE.
*         der naechste Starttermin ist kein Werktag

        IF GIVEN_JOB-PRDBEHAV <> BTC_DONT_PROCESS_ON_HOLIDAY.
*           Verhalten bei Nicht-Werktag ist Vorschieben auf
*           naechsten Werktag vor oder nach dem Nicht-Arbeitstag.
*           Diese Berechnung hat bereits der obige Fuba
*           durchgefuehrt, d.h. man kann das gelieferte
*           Datum uebernehmen.

					IF GIVEN_JOB-PRDWEEKS <> 0 OR GIVEN_JOB-PRDMONTHS <> 0.
            FCAL_START_INT = CAL_DATE.
            NEXT_START_INT = NEXT_JOB-SDLSTRTDT.
            NEXT_JOB-CALCORRECT = FCAL_START_INT - NEXT_START_INT.
          ENDIF.

          NEXT_JOB-SDLSTRTDT = CAL_DATE.
          NEXT_DATE_OK = 1.
        ELSE.
*          berechne neuen Starttermin gemaess Wdh.periode

          GIVEN_JOB = NEXT_JOB.
          PERFORM CALC_NEXT_START_DATE
            USING
              GIVEN_JOB NEXT_JOB.
        ENDIF.
      ENDIF.
    ENDWHILE.
  ENDIF.

ENDFORM. " CALC_NEW_START_DATE

*---------------------------------------------------------------------*
*       FORM CALC_NEXT_START_DATE                                     *
*---------------------------------------------------------------------*
* Diese Funktion berechnet den naechsten Starttermin eines            *
* zeit-periodischen Jobs gemaess der vorgegebenen Wdh.periode.        *
* Ein evtl. vorliegender Fabrik-Kalender wird hier nicht              *
* beruecksichtigt.                                                    *
*                                                                     *
*---------------------------------------------------------------------*
FORM CALC_NEXT_START_DATE
  USING
    GIVEN_JOB STRUCTURE TBTCJOB
    NEXT_JOB STRUCTURE TBTCJOB.

DATA:
  ADDITIONAL_DAYS TYPE I,
*   delta zwischen dem urspruenglich geplanten Startdatum und dem
*   im berechneten Monat zulaessigen Datum
*   z.B. 31.1 --> 28.2 ergibt ein delta von 3 Tagen, die bei der
*        naechsten Einplanung beruecksichtigt werden muessen.
  EOM_OFFSET      TYPE I,
  NUM_MONTHDAYS   TYPE I,
  PRD_MINS        TYPE I,
  PRD_HOURS       TYPE I,
  YEAR            TYPE I,
  MONTH           TYPE I,
  DAY             TYPE I,
  LAST_EXECTIME   TYPE I,
  NEXT_EXECTIME   TYPE I,
  NEXT_EXECDATE   LIKE SY-DATUM.


*  Uhrzeit und Periodenwerte fuer Minuten und Stunden werden
*  in INT-Felder uebertragen, um die schnellere Arithmetik zu
*  nutzen und unnoetige Konvertierungen INT -> UZEIT zu
*  vermeiden
  NEXT_EXECTIME   = GIVEN_JOB-SDLSTRTTM.
  PRD_MINS        = GIVEN_JOB-PRDMINS.
  PRD_HOURS       = GIVEN_JOB-PRDHOURS.
  ADDITIONAL_DAYS = 0.

*   Monatsende-Korrektur
  IF GIVEN_JOB-EOMCORRECT = 0.
    EOM_OFFSET = 0.
  ELSE.
    EOM_OFFSET = GIVEN_JOB-EOMCORRECT.
    CLEAR GIVEN_JOB-EOMCORRECT.
    CLEAR NEXT_JOB-EOMCORRECT.
  ENDIF.

*     es gibt direkte Arithmetik fuer den Datentyp Uhrzeit auf
*     Sekundenbasis, d.h. rechne den vorliegenden Periodenwert
*     fuer Minuten bzw. Stunden (i.e. GIVEN_JOB-PRDMINS bzw.
*     GIVEN_JOB-PRDHOURS) in Sekunden um und addiere ihn direkt zur
*     letzten Ausfuehrungszeit hinzu.
*     Beachte, dass bei der Angabe des Stundenwertes auch Werte > 24
*     auftreten koennen, d.h. hier muessen die vollen Tage zunaechst
*     aus dem Stundenanteil extrahiert werden.
*     Beachte, dass auch nach dem Extrahieren des Tagesanteils
*     immer noch ein Tageswechsel fuer die naechste Einplanung
*     moeglich ist (z.B. letzte Ausfuehrung um 23:00, Wdh.periode
*     3 Stunden, d.h. naechste Ausfuehrung am naechsten Tag um 2:00).
  ADDITIONAL_DAYS = PRD_HOURS DIV HOURS_PER_DAY.
  PRD_HOURS = PRD_HOURS MOD HOURS_PER_DAY.
  LAST_EXECTIME = NEXT_EXECTIME.
  NEXT_EXECTIME = NEXT_EXECTIME + PRD_MINS * 60 + PRD_HOURS * 3600.
  NEXT_EXECTIME = NEXT_EXECTIME MOD SECONDS_PER_DAY.
  IF NEXT_EXECTIME < LAST_EXECTIME. " 0:00 Uhr ueberschritten
    ADDITIONAL_DAYS = ADDITIONAL_DAYS + 1.
  ENDIF.

*   Die Berechnung des Datums fuer den naechsten
*   Ausfuehrungszeitpunkt gestaltet sich aufwendiger, da fuer den
*   Datentyp Datum die direkte Arithmetik nur auf Tagesbasis
*   realisiert ist, wir aber mit Wochen und Monaten umgehen muessen,
*   ohne z.B. bei den Monaten die genaue Anzahl der Tage
*   beruecksichtigen zu wollen.
*   Deshalb wird der Monats- und Jahresanteil aus dem Datum
*   extrahiert und separat behandelt. Hierbei werden auch
*   Jahreswechsel beruecksichtigt.
  IF GIVEN_JOB-PRDMONTHS = 0.
    NEXT_EXECDATE = GIVEN_JOB-SDLSTRTDT.
  ELSE.
    YEAR = GIVEN_JOB-SDLSTRTDT+0(4).
    MONTH = GIVEN_JOB-SDLSTRTDT+4(2).
    DAY = GIVEN_JOB-SDLSTRTDT+6(2).

    MONTH = MONTH + ( GIVEN_JOB-PRDMONTHS MOD 12 ).
    YEAR  = YEAR + ( GIVEN_JOB-PRDMONTHS DIV 12 ).

    IF MONTH > 12.                    " Jahreswechsel
      MONTH = MONTH - 12.
      YEAR = YEAR + 1.
    ENDIF.

*     jetzt wird das Datum fuer den naechsten Ausfuehrungszeitpunkt
*     wieder zusammengesetzt.
    IF MONTH > 9.                     " Zahl fuer Monat zweistellig
      NEXT_EXECDATE+4(2) = MONTH.
    ELSE.
      NEXT_EXECDATE+4(1) = '0'.
      NEXT_EXECDATE+5(1) = MONTH.
    ENDIF.

    NEXT_EXECDATE+0(4) = YEAR.

*     Bei einer monatlichen Wdh.periode ist die Anzahl der Tage,
*     welche der berechnete Ausfuehrungsmonat besitzt, wichtig.
*     Bsp.: Am 31.1. wird ein Job mit monatlicher Wdh.periode erneut
*           eingeplant, einen 31.2 gibt es aber nicht.
*           Es muss der 28. oder 29. genommen werden. Dabei ist die
*           Differenz (3 bzw. 2 Tage) festzuhalten, damit die
*           naechste Einplanung (fuer den 31.3.) wieder den
*           korrekten Termin verwendet.
*     Vorgehen: - Beruecksichtige einen evtl. bereits vorliegenden
*                 Korrekturwert
*               - Berechne die Anzahl der Tage, welche der berechnete
*                 Ausfuehrungsmonat besitzt
*               - Korrigiere evtl. den Ausfuehrungstag
*               - Die Korrektur muss in der DB festgehalten und bei
*                 der naechsten Einplanung mit beruecksichtigt werden
*     Dabei sind folgende Optimierungen moeglich:
*     - nach Beruecksichtigung eines evtl. bereits vorliegenden
*       Korrekturwerts muessen nur solche Tage betrachtet werden,
*       die groesser 28 Tage sind
    DAY = DAY + EOM_OFFSET.
    EOM_OFFSET = 0.
    IF DAY > 28.
      PERFORM DAYS_PER_MONTH USING MONTH YEAR NUM_MONTHDAYS.
      IF NUM_MONTHDAYS < DAY.
        NEXT_JOB-EOMCORRECT = DAY - NUM_MONTHDAYS.
        DAY = NUM_MONTHDAYS.
      ENDIF.
    ENDIF.

    IF DAY > 9.                     " Zahl fuer Tag zweistellig
      NEXT_EXECDATE+6(2) = DAY.
    ELSE.
      NEXT_EXECDATE+6(1) = '0'.
      NEXT_EXECDATE+7(1) = DAY.
    ENDIF.
  ENDIF.

*   Addiere die Wiederholungsperiode fuer Tage. Diese Addition kann
*   direkt ausgefuehrt werden.
*   Beachte dabei die durch entsprechende Periodenwerte fuer die
*   Stundenanzahl evtl. zusaetzlicen Tage
  NEXT_EXECDATE = NEXT_EXECDATE + GIVEN_JOB-PRDWEEKS * 7 +
                  GIVEN_JOB-PRDDAYS + ADDITIONAL_DAYS.

*   Eintragen des naechsten Starttermins im Job-Deskriptor
  NEXT_JOB-SDLSTRTDT = NEXT_EXECDATE.
  NEXT_JOB-SDLSTRTTM = NEXT_EXECTIME.

ENDFORM. " CALC_NEXT_START_DATE


*---------------------------------------------------------------------*
*       FORM CALC_NEW_WORKDAY                                         *
*---------------------------------------------------------------------*
* Diese Funktion berechnet den naechsten Starttermin eines            *
* zeit-periodischen Jobs, der auf einen Arbeitstag eingeplant ist,    *
* unter Beruecksichtigung eines vorliegenden Fabrik-Kalenders.        *
*                                                                     *
*---------------------------------------------------------------------*
FORM CALC_NEW_WORKDAY
  USING
    GIVEN_JOB STRUCTURE TBTCJOB
    NEXT_JOB STRUCTURE TBTCJOB.

DATA:
  CAL_ID LIKE SCAL-FCALID,
  CAL_INDICATOR LIKE SCAL-INDICATOR,
  CAL_DATE LIKE SCAL-DATE,
  CAL_FDATE LIKE SCAL-FACDATE,
  CAL_WORKDAY LIKE SCAL-INDICATOR,
  FCAL_CORRECT LIKE GIVEN_JOB-CALCORRECT,
  NUM_MONTHDAYS   TYPE I,
  YEAR            TYPE I,
  MONTH           TYPE I,
  DAY(2),
  DATE LIKE SY-DATUM.

  YEAR = GIVEN_JOB-SDLSTRTDT+0(4).
  MONTH = GIVEN_JOB-SDLSTRTDT+4(2).

  MONTH = MONTH + ( GIVEN_JOB-PRDMONTHS MOD 12 ).
  YEAR  = YEAR + ( GIVEN_JOB-PRDMONTHS DIV 12 ).

  IF MONTH > 12.                    " Jahreswechsel
    MONTH = MONTH - 12.
    YEAR = YEAR + 1.
  ENDIF.

*   jetzt wird das Datum fuer den naechsten Ausfuehrungszeitpunkt
*   wieder zusammengesetzt.
  IF MONTH > 9.                     " Zahl fuer Monat zweistellig
    DATE+4(2) = MONTH.
  ELSE.
    DATE+4(1) = '0'.
    DATE+5(1) = MONTH.
  ENDIF.
  DATE+0(4) = YEAR.

  CAL_ID = GIVEN_JOB-CALENDARID.

  IF GIVEN_JOB-PRDMINS = BTC_BEGINNING_OF_MONTH.
    CAL_INDICATOR = '+'.
    DATE+6(2) = '01'.
    CAL_DATE = DATE.

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        CORRECT_OPTION = CAL_INDICATOR
        DATE = CAL_DATE
        FACTORY_CALENDAR_ID = CAL_ID
      IMPORTING
        DATE = CAL_DATE
        FACTORYDATE = CAL_FDATE
        WORKINGDAY_INDICATOR = CAL_WORKDAY
      EXCEPTIONS
        CALENDAR_BUFFER_NOT_LOADABLE = 1
        CORRECT_OPTION_INVALID = 2
        DATE_AFTER_RANGE = 3
        DATE_BEFORE_RANGE = 4
        DATE_INVALID = 5
        FACTORY_CALENDAR_NOT_FOUND = 6
        OTHERS = 99.

    CAL_FDATE = CAL_FDATE + GIVEN_JOB-PRDDAYS - 1.

    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        FACTORYDATE = CAL_FDATE
        FACTORY_CALENDAR_ID = CAL_ID
      IMPORTING
        DATE = CAL_DATE
      EXCEPTIONS
        CALENDAR_BUFFER_NOT_LOADABLE = 1
        FACTORYDATE_AFTER_RANGE      = 2
        FACTORYDATE_BEFORE_RANGE     = 3
        FACTORYDATE_INVALID          = 4
        FACTORY_CALENDAR_ID_MISSING  = 5
        FACTORY_CALENDAR_NOT_FOUND   = 6
        OTHERS                       = 99.

  ELSE. " Zaehlrichtung vom Ende des Monats her
    CAL_INDICATOR = '-'.
    PERFORM DAYS_PER_MONTH
      USING MONTH YEAR NUM_MONTHDAYS.

    DAY = NUM_MONTHDAYS.
    DATE+6(2) = DAY.
    CAL_DATE = DATE.

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        CORRECT_OPTION = CAL_INDICATOR
        DATE = CAL_DATE
        FACTORY_CALENDAR_ID = CAL_ID
      IMPORTING
        DATE = CAL_DATE
        FACTORYDATE = CAL_FDATE
        WORKINGDAY_INDICATOR = CAL_WORKDAY
      EXCEPTIONS
        CALENDAR_BUFFER_NOT_LOADABLE = 1
        CORRECT_OPTION_INVALID = 2
        DATE_AFTER_RANGE = 3
        DATE_BEFORE_RANGE = 4
        DATE_INVALID = 5
        FACTORY_CALENDAR_NOT_FOUND = 6
        OTHERS = 99.

    CAL_FDATE = CAL_FDATE - GIVEN_JOB-PRDDAYS + 1.

    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        FACTORYDATE = CAL_FDATE
        FACTORY_CALENDAR_ID = CAL_ID
      IMPORTING
        DATE = CAL_DATE
      EXCEPTIONS
        CALENDAR_BUFFER_NOT_LOADABLE = 1
        FACTORYDATE_AFTER_RANGE      = 2
        FACTORYDATE_BEFORE_RANGE     = 3
        FACTORYDATE_INVALID          = 4
        FACTORY_CALENDAR_ID_MISSING  = 5
        FACTORY_CALENDAR_NOT_FOUND   = 6
        OTHERS                       = 99.

  ENDIF.

  NEXT_JOB-SDLSTRTDT = CAL_DATE.

ENDFORM. " CALC_NEW_WORKDAY

* #####################################################################
* New routines for calculation of new start date
* #####################################################################
FORM reschedule_main
  USING i_prd TYPE t_period
        i_strt TYPE t_start_cond
        i_horizon_date TYPE sydatum
        i_horizon_time TYPE syuzeit
  CHANGING o_prd TYPE t_period
           o_strt TYPE t_start_cond
           o_time_periodic TYPE boolean
           o_rc TYPE i.

  CLEAR o_rc.

  IF i_prd-prdmins = 0 AND
     i_prd-prdhours = 0 AND
     i_prd-prddays = 0 AND
     i_prd-prdweeks = 0 AND
     i_prd-prdmonths = 0.
    CLEAR o_time_periodic.
    EXIT.
  ENDIF.

  o_time_periodic = 'X'.

  IF i_prd-emergmode = btc_stdt_onworkday.
    PERFORM calculate_new_workday
      USING i_prd i_strt CHANGING o_strt o_rc.
*return prd structure because it is not modified in called subroutine!
      o_prd = i_prd.

  ELSE.
    PERFORM calculate_new_date
      USING i_prd i_strt i_horizon_date i_horizon_time CHANGING o_prd o_strt o_rc.
  ENDIF.

ENDFORM.                    "reschedule_main

*&---------------------------------------------------------------------*
*&      Form  calculate_new_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_PRD           text
*      -->I_STRT          text
*      -->I_HORIZON_DATE  text
*      -->I_HORIZON_TIME  text
*      -->O_PRD           text
*      -->O_STRT          text
*      -->O_RC            text
*----------------------------------------------------------------------*
FORM calculate_new_date
  USING i_prd TYPE t_period
        i_strt TYPE t_start_cond
        i_horizon_date TYPE sydatum
        i_horizon_time TYPE syuzeit
  CHANGING o_prd TYPE t_period
           o_strt TYPE t_start_cond
           o_rc TYPE i.

  DATA:
    next_date_ok TYPE i,
    cal_id TYPE scal-fcalid,
    cal_indicator TYPE scal-indicator,
    cal_date TYPE scal-date,
    cal_fdate TYPE scal-facdate,
    cal_workday TYPE scal-indicator,
    next_start_int TYPE i,
    fcal_start_int TYPE i,
    sav_subrc TYPE i.


*  Felder fuer die Berechnung des neuen spaetesten Startermins bei
*  periodischen Jobs
  DATA:
*   Zeitdifferenz zwischen zwei Datumsangaben in Sekunden
    diff        TYPE i,
*   Zeitdifferenz zwischen zwei Datumsangaben in Tagen
    days        TYPE i,
*   verbleibende Zeitdifferenz in Sekunden nach dem man die Tage
*   bereits herausgerechnet hat
    secs        TYPE i.

  DATA:
    p_horizon_date TYPE sydatum,
    p_horizon_time TYPE syuzeit.

  CLEAR o_rc.

  p_horizon_date = i_horizon_date.
  p_horizon_time = i_horizon_time.

  o_prd = i_prd.
  o_strt = i_strt.

*   Korrektur fuer Termin-Verschiebung gemaess Fabrik-Kalender
  IF i_prd-calcorrect <> 0.
    o_strt-sdlstrtdt = i_strt-sdlstrtdt - i_prd-calcorrect.
    o_prd-calcorrect = 0.
  ENDIF.

  PERFORM calculate_next_date
    USING p_horizon_date p_horizon_time i_strt-sdlstrtdt CHANGING o_prd o_strt.

  IF i_prd-calendarid IS NOT INITIAL AND
     i_prd-prdbehav <> btc_process_always.
*  naechster starttermin muss gegen fabrik-kalender verprobt werden

    cal_id = i_prd-calendarid.
    CASE i_prd-prdbehav.
      WHEN btc_dont_process_on_holiday.
        cal_indicator = '+'.
      WHEN btc_process_before_holiday.
        cal_indicator = '-'.
      WHEN btc_process_after_holiday.
        cal_indicator = '+'.
      WHEN btc_process_always.
        cal_indicator = '+'.
      WHEN OTHERS.
        cal_indicator = '+'.
    ENDCASE.
    next_date_ok = 0.

    WHILE next_date_ok = 0.
      cal_date = o_strt-sdlstrtdt.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          correct_option               = cal_indicator
          date                         = cal_date
          factory_calendar_id          = cal_id
        IMPORTING
          date                         = cal_date
          factorydate                  = cal_fdate
          workingday_indicator         = cal_workday
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 99.
      sav_subrc = sy-subrc.
      IF sav_subrc <> 0.
        IF sav_subrc = 1 OR sav_subrc = 6.
          o_rc = rc_calendar_load_failed.
        ELSEIF sav_subrc = 3 OR sav_subrc = 4.
          o_rc = rc_no_date_found.
        ELSE.
          o_rc = rc_date_corrupted.
        ENDIF.
        EXIT.
      ENDIF.

      GET TIME.
      IF cal_workday IS NOT INITIAL.
        IF cal_indicator = '-' AND
           ( cal_date < sy-datum OR
             ( cal_date = sy-datum AND i_strt-sdlstrttm < sy-uzeit )
           ).
          o_rc = rc_no_date_found.
          EXIT.
        ENDIF.
      ENDIF.

* this point reached: calendar and/or date not critical
      IF cal_workday IS INITIAL.
        " der naechste Starttermin ist ein Werktag
        next_date_ok = 1.
      ELSE.
        " der naechste Starttermin ist kein Werktag
        IF i_prd-prdbehav <> btc_dont_process_on_holiday.
*           Verhalten bei Nicht-Werktag ist Vorschieben auf
*           naechsten Werktag vor oder nach dem Nicht-Arbeitstag.
*           Diese Berechnung hat bereits der obige Fuba
*           durchgefuehrt, d.h. man kann das gelieferte
*           Datum uebernehmen.

          fcal_start_int = cal_date.
          next_start_int = o_strt-sdlstrtdt.
          o_prd-calcorrect = fcal_start_int - next_start_int.
          o_strt-sdlstrtdt = cal_date.

          next_date_ok = 1.
        ELSE.
*          berechne neuen Starttermin gemaess Wdh.periode

          p_horizon_date = o_strt-sdlstrtdt. p_horizon_time = o_strt-sdlstrttm.
          PERFORM calculate_next_date
            USING p_horizon_date p_horizon_time p_horizon_date
            CHANGING o_prd o_strt.
        ENDIF.
      ENDIF.
    ENDWHILE.
  ENDIF.

*   Enthaelt der gerade gestartete Job einen spaetesten Start-
*   termin, so wird fuer den neu einzuplanenden Job ein ent-
*   sprechender neuer spaetester Starttermin berechnet. Das
*   erfolgt nach folgender Formel:
*
*    ST(akt)  = Starttermin des gerade gestarteten Jobs.
*    SST(akt) = spaetester Starttermin des gerade gestarteten
*               Jobs
*    ST(neu)  = Starttermin des neu einzuplanenden Jobs
*    SST(neu) = spaetester Starttermin des neu einzuplanenden
*               Jobs
*
*    SST(neu) = ST(neu) + ( SST(akt) - ST(akt) ).
*
*    Die Ermittlung von Zeitdifferenzen, z.B. SST(akt) - ST(akt)
*    muss in ABAP in Sekunden ermittelt werden:
*
*    1       2       3       4       5  ...
*    |--+----|-------|-------|----+--|--------> t (Datum)
*       |                         |
*       DX                        DY
*
*     DX(D) = Datum des Starttermins
*     DX(H) = Uhrzeit des Starttermins
*     DY(D) = Datum des spdtesten Starttermins
*     DY(H) = Uhrzeit des spdtesten Starttermins
*     DIFF  = Zeitdifferenz in Sekunden
*
*    DIFF = ( DY(D) - DX(D) ) * 24 * 3600 - DX(H) + DY(H)
*
*    Um nun letztendlich zu einem gegebenen Datum, z.B. ST(neu)
*    eine Zeit addieren zu koennen, extrahiert man aus DIFF die
*    Anzahl der Tage und der dann verbleibenden Sekunden und
*    addiert diese Werte zu den entsprechenden Werten des neuen
*    Starttermins:
*
*    Tage     = DIFF DIV ( 24 * 3600 )
*    Sekunden = DIFF MOD ( 24 * 3600 )
*
*    SST(D) = ST(D) + Tage.
*    SST(H) = ST(H) + Sekunden.
*
*    falls eine Tagesgrenze ueberschritten wurde
*    ( SST(H) < ST(H) ) gilt SST(D) = SST(D) + 1.
*
  IF i_strt-laststrtdt <> no_date AND
     i_strt-laststrttm <> no_time AND
     i_strt-laststrtdt IS NOT INITIAL.

* Beginn 15.5.2008     d023157
* In der folgenden Berechnung
*     diff = ( i_strt-laststrtdt - i_strt-sdlstrtdt ) * seconds_per_day ...
* kann es zum Dump  COMPUTE_INT_TIMES_OVERFLOW
* kommen (bei 4 Byte Integer), wenn die Differenz
*       i_strt-laststrtdt - i_strt-sdlstrtdt
* größer ist als (grob geschätzt) 30 Jahre.
* Im Normalfall lassen wir eine Differenz > 1 Jahr gar nicht zu, und so
* eine große Differenz macht auch keinen Sinn, aber wir müssen das hier noch mal
* abfangen für den Fall, daß jemand in der DB rumgepfuscht hat.
* Denn wenn nur ein 'verpfuschter' Job in der DB ist, dumpt der Scheduler immer,
* und es starten keine Jobs mehr.
* Wir fangen das Problem nun ab, indem wir die Differenz auf 365 setzen, wenn
* sie größer als 365 ist.

    diff = i_strt-laststrtdt - i_strt-sdlstrtdt.
    if diff > 365.
       diff = 365.
    endif.

    diff = diff * seconds_per_day -
           i_strt-sdlstrttm + i_strt-laststrttm.

    days = diff DIV seconds_per_day.
    secs = diff MOD seconds_per_day.

    o_strt-laststrtdt = o_strt-sdlstrtdt + days.
    o_strt-laststrttm = o_strt-sdlstrttm + secs.

    IF o_strt-laststrttm < o_strt-sdlstrttm.
      o_strt-laststrtdt = o_strt-laststrtdt + 1.
    ENDIF.
  ENDIF.

ENDFORM.                    "calculate_new_date

*&---------------------------------------------------------------------*
*&      Form  calculate_new_workday
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_PRD      text
*      -->I_STRT     text
*      -->O_STRT     text
*      -->O_RC       text
*----------------------------------------------------------------------*
FORM calculate_new_workday
  USING i_prd TYPE t_period
        i_strt TYPE t_start_cond
  CHANGING o_strt TYPE t_start_cond
           o_rc TYPE i.

  DATA:
    cal_id TYPE scal-fcalid,
    cal_indicator TYPE scal-indicator,
    cal_date TYPE scal-date,
    cal_fdate TYPE scal-facdate,
    cal_workday TYPE scal-indicator,
    num_monthdays   TYPE i,
    year            TYPE i,
    month           TYPE i,
    day(2) TYPE c,
    date TYPE sy-datum,
    sav_subrc TYPE i.

  CLEAR o_rc.
  o_strt = i_strt.

* tbtco fields misused (this case: only monthly periods possible):
*       prdmins indicates whether relative to the begin/end of a month
*       prddays is the number of days relative to begin/end of a month
*

  year = i_strt-sdlstrtdt+0(4).
  month = i_strt-sdlstrtdt+4(2).
  month = month + ( i_prd-prdmonths MOD 12 ).
  year  = year + ( i_prd-prdmonths DIV 12 ).
  IF month > 12.                    " Jahreswechsel
    month = month - 12.
    year = year + 1.
  ENDIF.

*   jetzt wird das Datum fuer den naechsten Ausfuehrungszeitpunkt
*   wieder zusammengesetzt.
  IF month > 9.                     " Zahl fuer Monat zweistellig
    date+4(2) = month.
  ELSE.
    date+4(1) = '0'.
    date+5(1) = month.
  ENDIF.
  date+0(4) = year.

  cal_id = i_prd-calendarid.

  IF i_prd-prdmins = btc_beginning_of_month.
    " Start day is counted from the beginning of month:
    cal_indicator = '+'.
    date+6(2) = '01'.
    cal_date = date.

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        correct_option               = cal_indicator
        date                         = cal_date
        factory_calendar_id          = cal_id
      IMPORTING
        date                         = cal_date
        factorydate                  = cal_fdate
        workingday_indicator         = cal_workday
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        correct_option_invalid       = 2
        date_after_range             = 3
        date_before_range            = 4
        date_invalid                 = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 99.
    sav_subrc = sy-subrc.
    IF sav_subrc <> 0.
      IF sav_subrc = 1 OR sav_subrc = 6.
        o_rc = rc_calendar_load_failed.
      ELSEIF sav_subrc = 3 OR sav_subrc = 4.
        o_rc = rc_no_date_found.
      ELSE.
        o_rc = rc_date_corrupted.
      ENDIF.
      EXIT.
    ENDIF.

    GET TIME.
    IF cal_indicator = '-' AND
       ( cal_date < sy-datum OR
         ( cal_date = sy-datum AND i_strt-sdlstrttm < sy-uzeit )
       ).
      " Planed for the past!
      o_rc = rc_no_date_found.
      EXIT.
    ENDIF.

    " Make sure date used is valid and in the future:
    cal_fdate = cal_fdate + i_prd-prddays - 1.
    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        factorydate                  = cal_fdate
        factory_calendar_id          = cal_id
      IMPORTING
        date                         = cal_date
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        factorydate_after_range      = 2
        factorydate_before_range     = 3
        factorydate_invalid          = 4
        factory_calendar_id_missing  = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 99.
    IF sy-subrc <> 0.
      o_rc = rc_cant_convert_fdate.
      EXIT.
    ENDIF.
  ELSE.
    " Start day is counted from the end of month:
    PERFORM get_month_length
      USING month year CHANGING num_monthdays.

    cal_indicator = '-'.
    day = num_monthdays.
    date+6(2) = day.
    cal_date = date.
    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        correct_option               = cal_indicator
        date                         = cal_date
        factory_calendar_id          = cal_id
      IMPORTING
        date                         = cal_date
        factorydate                  = cal_fdate
        workingday_indicator         = cal_workday
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        correct_option_invalid       = 2
        date_after_range             = 3
        date_before_range            = 4
        date_invalid                 = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 99.
    sav_subrc = sy-subrc.
    IF sav_subrc <> 0.
      IF sav_subrc = 1 OR sav_subrc = 6.
        o_rc = rc_calendar_load_failed.
      ELSEIF sav_subrc = 3 OR sav_subrc = 4.
        o_rc = rc_no_date_found.
      ELSE.
        o_rc = rc_date_corrupted.
      ENDIF.
      EXIT.
    ENDIF.

    GET TIME.
    IF cal_indicator = '-' AND
       ( cal_date < sy-datum OR
         ( cal_date = sy-datum AND i_strt-sdlstrttm < sy-uzeit )
       ).
      o_rc = rc_no_date_found.
      EXIT.
    ENDIF.

    " Make sure this thing is set properly at this point:
    cal_fdate = cal_fdate - i_prd-prddays + 1.
    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        factorydate                  = cal_fdate
        factory_calendar_id          = cal_id
      IMPORTING
        date                         = cal_date
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        factorydate_after_range      = 2
        factorydate_before_range     = 3
        factorydate_invalid          = 4
        factory_calendar_id_missing  = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 99.
    IF sy-subrc <> 0.
      o_rc = rc_cant_convert_fdate.
      EXIT.
    ENDIF.
  ENDIF.

  o_strt-sdlstrtdt = cal_date.

ENDFORM.                    "calculate_new_workday


*&---------------------------------------------------------------------*
*&      Form  calculate_new_workday_sbti
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM calculate_new_workday_sbti
   USING
      iv_prdmins TYPE btcpmin
      iv_prddays type btcpday
      iv_prdmonths TYPE btcpmnth
      iv_emergmode TYPE tbtco-emergmode
      iv_calendarid TYPE tbtco-calendarid
   CHANGING
      ev_sdlstrtdt TYPE tbtco-sdlstrtdt
      ev_sdlstrttm TYPE tbtco-sdlstrttm
      ev_laststrtdt TYPE tbtco-laststrtdt
      ev_laststrttm TYPE tbtco-laststrttm
      ev_rc TYPE i.

  DATA: ls_period TYPE t_period,
        ls_start_cond TYPE t_start_cond.

  ls_period-prdmins = iv_prdmins.
  ls_period-prdmonths = iv_prdmonths.
  ls_period-prddays = iv_prddays.
  ls_period-emergmode = iv_emergmode.
  ls_period-calendarid = iv_calendarid.

  ls_start_cond-sdlstrtdt = ev_sdlstrtdt.
  ls_start_cond-sdlstrttm = ev_sdlstrttm.
  ls_start_cond-laststrtdt = ev_laststrtdt.
  ls_start_cond-laststrttm = ev_laststrttm.

  PERFORM calculate_new_workday
        USING ls_period ls_start_cond CHANGING ls_start_cond ev_rc.

ENDFORM.                    "calculate_new_workday_new


*&---------------------------------------------------------------------*
*&      Form  calculate_next_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_FIRST_DATE     text
*      -->I_FIRST_TIME     text
*      -->I_LAST_EXECDATE  text
*      -->O_PRD            text
*      -->O_STRT           text
*----------------------------------------------------------------------*
FORM calculate_next_date
  USING i_first_date TYPE sydatum
        i_first_time TYPE syuzeit
        i_last_execdate TYPE sydatum
  CHANGING o_prd TYPE t_period
           o_strt TYPE t_start_cond.

  DATA:
    additional_days TYPE i,
*   delta zwischen dem urspruenglich geplanten Startdatum und dem
*   im berechneten Monat zulaessigen Datum
*   z.B. 31.1 --> 28.2 ergibt ein delta von 3 Tagen, die bei der
*        naechsten Einplanung beruecksichtigt werden muessen.
    increase_days   TYPE i,   "effective day increment (hours incl.)
    eom_offset      TYPE i,
    num_monthdays   TYPE i,
    prd_mins        TYPE i,
    prd_hours       TYPE i,
    year            TYPE i,
    month           TYPE i,
    day             TYPE i,
    pure_days       TYPE i,    " save days retrieved from 24/48.. hours
    last_exectime   TYPE i,
    last_execdate   TYPE i,
    next_exectime   TYPE i,
    next_execdate   TYPE sy-datum.

  DATA:
*   Anzahl der komplett versaeumten Tage
    missed_days TYPE i,
*   Anzahl des bisher versaeumten Zeitintervalls in Sekunden
    missed_secs TYPE i,
*   Laenge der Wiederholungsperiode in Sekunden
    prd_secs TYPE i,
*   Anzahl der versaeumten Job-Starts
    missed_job_starts TYPE i.

*  Uhrzeit und Periodenwerte fuer Minuten und Stunden werden
*  in INT-Felder uebertragen, um die schnellere Arithmetik zu
*  nutzen und unnoetige Konvertierungen INT -> UZEIT zu
*  vermeiden
  next_exectime   = o_strt-sdlstrttm.
  last_execdate   = i_last_execdate.
  prd_mins        = o_prd-prdmins.
  prd_hours       = o_prd-prdhours.
  additional_days = 0.
  pure_days       = 0.

*   Monatsende-Korrektur
  IF o_prd-eomcorrect = 0.
    eom_offset = 0.
  ELSE.
    eom_offset = o_prd-eomcorrect.
    CLEAR o_prd-eomcorrect.
  ENDIF.

*   Bei der erneuten Einplanung periodischer Jobs kann es z.B. durch
*   Rechnerstillstand und verpasstem Ausfuehrungszeitpunkt dazu kommen,
*   dass der neue (i.e. naechste) Ausfuehrungszeitpunkt, der gemaess
*   der Periodenangabe berechnet wird, noch in der Vergangenheit liegt.
*   Loesung: Neuberechnung des naechsten Ausfuehrungszeitpunktes
*            solange bis dieser Termin nicht mehr in der Vergangenheit
*            liegt.
*   Problem: Bei einer kleinen Wiederholungsperiode und laengerer
*            Ausfallzeit des Systems ist diese Art der Neuberechnung
*            wegen der hohen Anzahl von Neuberechnungen sehr aufwendig.
*   Loesung: Der naechste Starttermin wird direkt berechnet. Dies
*            ist wohl nur fuer kleine Periodenwerte im Stunden- bzw.
*            Minutenbereich sinnvoll. Bei grossen Periodenwerten
*            verursacht das oben beschriebene Verfahren keine grossen
*            Belastungen, da ein Systemstillstand von mehreren Tagen
*            unwahrscheinlich ist.
*            Grundlage der direkten Berechnung ist folgender Satz:
*            Satz: Sei a_1 = (a_0 + delta)   mod m
*                      a_2 = (a_1 + delta)   mod m
*                      a_n = (a_n-1 + delta) mod m
*                  so gilt:
*                      a_n = (a_0 + n * delta) mod m
*            Bew.: vollst. Induktion
*            Folgerung: Addiere zum letzten Ausfuehrungszeitpunkt die
*                       verpasste Zeit hinzu und rechne dann modulo
*                       Uhrzeit --> naechster Ausfuehrungstermin am
*                       heutigen Tag. Beachte dabei einen moeglichen
*                       Tageswechsel.
*

  DO.
*     es gibt direkte Arithmetik fuer den Datentyp Uhrzeit auf
*     Sekundenbasis, d.h. rechne den vorliegenden Periodenwert
*     fuer Minuten bzw. Stunden (i.e. PRDMINS bzw.
*     PRDHOURS) in Sekunden um und addiere ihn direkt zur
*     letzten Ausfuehrungszeit hinzu.
*     Beachte, dass bei der Angabe des Stundenwertes auch Werte > 24
*     auftreten koennen, d.h. hier muessen die vollen Tage zunaechst
*     aus dem Stundenanteil extrahiert werden.
*     Beachte, dass auch nach dem Extrahieren des Tagesanteils
*     immer noch ein Tageswechsel fuer die naechste Einplanung
*     moeglich ist (z.B. letzte Ausfuehrung um 23:00, Wdh.periode
*     3 Stunden, d.h. naechste Ausfuehrung am naechsten Tag um 2:00).
    additional_days = prd_hours DIV hours_per_day.
    prd_hours = prd_hours MOD hours_per_day.
* ajk+/22.04.97
*     tricky and somewhat ugly problem correction:
*     whenever prd_hours was a multiple of 24, prd_hours was 0
*     and additional_days greater 0. If the first loop iteration
*     was not successful both were 0! Consequence: nothing was added
*     in the body or a division by zero inside 'Std/Min-Basis'-Part.
*     pure_days is just a unchanged reminder that there is
*     such a case and how large additional_days was the first time.
    IF additional_days > 0 AND prd_hours = 0.
      pure_days = additional_days.
    ENDIF.
* ajk-/22.04.97
    last_exectime = next_exectime.
    next_exectime = next_exectime + prd_mins * 60 + prd_hours * 3600.
    next_exectime = next_exectime MOD seconds_per_day.
    IF next_exectime < last_exectime. " 0:00 Uhr ueberschritten
      additional_days = additional_days + 1.
    ENDIF.

*     Die Berechnung des Datums fuer den naechsten
*     Ausfuehrungszeitpunkt gestaltet sich aufwendiger, da fuer den
*     Datentyp Datum die direkte Arithmetik nur auf Tagesbasis
*     realisiert ist, wir aber mit Wochen und Monaten umgehen muessen,
*     ohne z.B. bei den Monaten die genaue Anzahl der Tage
*     beruecksichtigen zu wollen.
*     Deshalb wird der Monats- und Jahresanteil aus dem Datum
*     extrahiert und separat behandelt. Hierbei werden auch
*     Jahreswechsel beruecksichtigt.
    IF o_prd-prdmonths = 0.
      next_execdate = o_strt-sdlstrtdt.
    ELSE.
      year = o_strt-sdlstrtdt+0(4).
      month = o_strt-sdlstrtdt+4(2).
      day = o_strt-sdlstrtdt+6(2).

      month = month + ( o_prd-prdmonths MOD 12 ).
      year  = year + ( o_prd-prdmonths DIV 12 ).
      IF month > 12.                    " Jahreswechsel
        month = month - 12.
        year = year + 1.
      ENDIF.

*       jetzt wird das Datum fuer den naechsten Ausfuehrungszeitpunkt
*       wieder zusammengesetzt.
      IF month > 9.                     " Zahl fuer Monat zweistellig
        next_execdate+4(2) = month.
      ELSE.
        next_execdate+4(1) = '0'.
        next_execdate+5(1) = month.
      ENDIF.

      next_execdate+0(4) = year.

*       Bei einer monatlichen Wdh.periode ist die Anzahl der Tage,
*       welche der berechnete Ausfuehrungsmonat besitzt, wichtig.
*       Bsp.: Am 31.1. wird ein Job mit monatlicher Wdh.periode erneut
*             eingeplant, einen 31.2 gibt es aber nicht.
*             Es muss der 28. oder 29. genomen werden. Dabei ist die
*             Differenz (3 bzw. 2 Tage) festzuhalten, damit die
*             naechste Einplanung (fuer den 31.3.) wieder den
*             korrekten Termin verwendet.
*       Vorgehen: - Beruecksichtige einen evtl. bereits vorliegenden
*                   Korrekturwert
*                 - Berechne die Anzahl der Tage, welche der berechnete
*                   Ausfuehrungsmonat besitzt
*                 - Korrigiere evtl. den Ausfuehrungstag
*                 - Die Korrektur muss in der DB festgehalten und bei
*                   der naechsten Einplanung mit beruecksichtigt werden
*       Dabei sind folgende Optimierungen moeglich:
*       - nach Beruecksichtigung eines evtl. bereits vorliegenden
*         Korrekturwerts muessen nur solche Tage betrachtet werden,
*         die groesser 28 Tage sind
      day = day + eom_offset.
      eom_offset = 0.
      IF day > 28.
        PERFORM get_month_length USING month year CHANGING num_monthdays.
        IF num_monthdays < day.
          o_prd-eomcorrect = day - num_monthdays.
          day = num_monthdays.
        ENDIF.
      ENDIF.

      IF day > 9.                     " Zahl fuer Tag zweistellig
        next_execdate+6(2) = day.
      ELSE.
        next_execdate+6(1) = '0'.
        next_execdate+7(1) = day.
      ENDIF.
    ENDIF.

*     Addiere die Wiederholungsperiode fuer Tage. Diese Addition kann
*     direkt ausgefuehrt werden.
*     Beachte dabei die durch entsprechende Periodenwerte fuer die
*     Stundenanzahl evtl. zusaetzlichen Tage
    IF additional_days > 0.   "first loop iteration & additional_days
      increase_days = additional_days.
    ELSEIF pure_days > 0.     "subsequent iteration (24h, 48h. etc.)
*      in this case we have to increase something. note: prd_hours = 0 !
      increase_days = pure_days.
    ELSE.
      increase_days = 0.     "subseq. iteration or no add._days at all
    ENDIF.

    next_execdate = next_execdate + o_prd-prdweeks * 7 +
                    o_prd-prddays + increase_days.

*     Fortschreiben des Eintrags in der Schedule-Tabelle
    o_strt-sdlstrtdt = next_execdate.

*     Pruefe, ob der berechnete naechste Ausfuehrungszeitpunkt
*     tatsaechlich in der Zukunft liegt

    IF next_execdate > i_first_date OR
       next_execdate = i_first_date AND next_exectime > i_first_time.
*       berechneter Zeitpunkt liegt in der Zukunft
      EXIT.  " verlasse DO-Schleife
    ELSE.
*       berechneter Zeitpunkt liegt in der Vergangenheit
*       pure_days > 0 indicates that we moved prd_hours to days
*       and erase prd_hours. Iff prd_mins is zero as well this
*       leads to div_zero: so avoid this shortcut and rely on loop.
      IF o_prd-prddays   = 0 AND pure_days = 0 AND
         o_prd-prdweeks  = 0 AND
         o_prd-prdmonths = 0.
*         Periodenwert nur auf Stunden-/Minutenbasis,
*         berechne neuen Starttermin direkt
        missed_days = i_first_date - last_execdate - 1.
        missed_secs = missed_days * seconds_per_day.
        missed_secs = missed_secs + i_first_time +
                      seconds_per_day - last_exectime.

        prd_secs = prd_mins * 60 + prd_hours * 3600.
        missed_job_starts = ( missed_secs DIV prd_secs ) + 1.

        next_exectime = last_exectime + prd_secs * missed_job_starts.
        next_exectime = next_exectime MOD seconds_per_day.
        o_strt-sdlstrtdt = i_first_date.
        IF next_exectime < i_first_time.  " 0:00 Uhr ueberschritten
          o_strt-sdlstrtdt = o_strt-sdlstrtdt + 1.
        ENDIF.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

  o_strt-sdlstrttm = next_exectime.

ENDFORM.                    "calculate_next_date

*&---------------------------------------------------------------------*
*&      Form  get_month_length
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_MONTH    text
*      -->I_YEAR     text
*      -->O_DAYS     text
*----------------------------------------------------------------------*
FORM get_month_length
  USING i_month TYPE i
        i_year TYPE i
  CHANGING o_days TYPE i.

  CONSTANTS: c_daytab TYPE string VALUE '312831303130313130313031'.

  DATA:
    offset TYPE i,
    i1 TYPE i,
    i2 TYPE i,
    i3 TYPE i.

  offset = 2 * i_month - 2.
  o_days = c_daytab+offset(2).

  IF i_month = 2.
*     die Schaltjahrberechnung ist nur fuer den Monat Februar
*     erforderlich

*     Kriterium fuer Schaltjahr
*     - Jahreszahl durch 4 teilbar
*     und
*     - Jahreszahl nicht durch 100 teilbar
*       oder
*       Jahreszahl durch 400 teilbar
    i1 = i_year MOD 4.
    i2 = i_year MOD 100.
    i3 = i_year MOD 400.
    IF i1 = 0 AND ( i2 <> 0 OR i3 = 0 ).
      o_days = o_days + 1.
    ENDIF.
  ENDIF.

ENDFORM.                    "get_month_length
