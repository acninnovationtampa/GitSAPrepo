**INCLUDE LBTCHF034 .
*----------------------------------------------------------------------*
* Hilfsfunktionen für BP_JOBVARIANT_SCHEDULE  (Heinz Wolf 14.3.95)     *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_INIT_START_DATE
*&---------------------------------------------------------------------*
*       Berechnet initial angezeigte Startzeitdaten für das            *
*       Dynpro zur Eingabe der Einplanungszeit. Dabei wird zur         *
*       aktuellen Zeit auf dem Rechner, auf dem diese Transaktion      *
*       gestartet wurde, eine Stunde hinzugezählt.                     *
*----------------------------------------------------------------------*
*  <-->  DATE      Neu berechnetes Datum
*  <-->  TIME      Neu berechnete Uhrzeit
*
*  GLOB: SY-DATUM, SY-UZEIT
*----------------------------------------------------------------------*
FORM compute_init_start_date
     USING date LIKE tbtcjob-strtdate
           time LIKE tbtcjob-strttime.

  date = sy-datum.
  time = sy-uzeit.
  IF time < 30.
    date = sy-datum.            " Es könnte eine Datumsumschaltung
  ENDIF.                               " dazwischen gekommen sein!

  time = time + 3600.                  " eine Stunde später
  IF time < sy-uzeit.
    date = date + 1.
*   Mitternacht wurde übersprungen
  ENDIF.

ENDFORM.                               " COMPUTE_INIT_START_DATE

*&---------------------------------------------------------------------*
*&      Form  EXIT_SCREEN
*&---------------------------------------------------------------------*
*       Verläßt das aktuelle Dynpro und kehrt ggf. zum                 *
*       aufrufenden zurück.                                            *
*----------------------------------------------------------------------*
FORM exit_screen.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                               " EXIT_SCREEN

*&---------------------------------------------------------------------*
*&      Form  ABORT_SCHEDULE
*&---------------------------------------------------------------------*
*       Realisiert die Abbruchfunktionalität (rote Kreuzikone)         *
*       für die Einplanungstransaktion. Vom Anfangsdynpro bzw.         *
*       von der Ausgabe der Variantenliste aus wird die                *
*       Transaktion beendet, ansonsten zum Ausgangsbild gesprungen.    *
*----------------------------------------------------------------------*
*  -->  FROM_DYNPRO    Nummer des Dynpros von dem aus Abbruch erfolgt
* GLOB: SY-DYNNR       wird implizit durch SET SCREEN verändert
*----------------------------------------------------------------------*
FORM abort_schedule
     USING value(from_dynpro) LIKE sy-dynnr.

  IF from_dynpro = 100 OR from_dynpro = 120.
    PERFORM exit_screen.
  ELSE.
    SET SCREEN 100.
  ENDIF.
  LEAVE SCREEN.

ENDFORM.                               " ABORT_SCHEDULE

*&---------------------------------------------------------------------*
*&      Form  BACK_ONE_DYNPRO
*&---------------------------------------------------------------------*
*       Geht um ein Dynpro zurück (grüne Pfeilikone).                  *
*----------------------------------------------------------------------*
*  -->  FROM_DYNPRO   Dynpronummer, von dem aus zurück gewählt wurde
* GLOB: SY-DYNNR      implizit verändert durch SET SCREEN
*----------------------------------------------------------------------*
FORM back_one_dynpro
     USING value(from_dynpro) LIKE sy-dynnr.
  DATA: next_dynpro LIKE sy-dynnr.

  IF from_dynpro = 400 OR from_dynpro = 500.
    next_dynpro = 0.
  ELSE.
    next_dynpro = from_dynpro - 100.
  ENDIF.

  IF next_dynpro = 0.
    PERFORM exit_screen.
  ENDIF.

  SET SCREEN next_dynpro.
  LEAVE SCREEN.

ENDFORM.                               " BACK_ONE_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_IMMEDIATELY
*&---------------------------------------------------------------------*
*       Sofortige Einplanung. Der Batchjob wird mit dem Attribut       *
*       IMMEDIATELY eingeplant, wird aber ebenso als Batchjob          *
*       eingeplant (damit auch dieselbe Spoolliste und das Ablauf-     *
*       protokoll erzeugt wird. Dies kann aber dazu führen, dass der   *
*       Job zwar sofort freigegeben wird, aber aufgrund der aktuellen  *
*       Situation (kein Batch-Prozeß verfügbar oder aktuelle Betriebs- *
*       art nicht für Batchverarbeitung eingestellt) nicht sofort      *
*       abgearbeitet wird.                                             *
*----------------------------------------------------------------------*
*  -->  JOB_NAME   Name des zu startenden Batchjobs
*       PROG_NAME  Name des Programms für den ersten Jobstep
*                  (es ist nur ein Step vorgesehen).
*       VAR_NAME   Name der Variante für das angebene Programm
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird die Liste der Batchjobs
*                  erweitert. Im Fehlerfall wird eine Nachricht
*                  ausgegeben und ggf. durchgeführte Veränderungen
*                  zurückgenommen.
*----------------------------------------------------------------------*
FORM schedule_immediately
     USING value(job_name)   LIKE tbtco-jobname
           value(prog_name)  LIKE rsvar-report
           value(var_name)   LIKE rsvar-variant.

  DATA: job_number   LIKE tbtco-jobcount,
        retval       LIKE sy-subrc.

  PERFORM open_job
          USING job_name
                job_number             " --> Nummer des angelegten Jobs
                retval.                " --> 0 = Ok, sonst Fehler
  IF retval <> 0.
    EXIT.
  ENDIF.

  PERFORM submit_job
          USING job_name
                job_number
                prog_name
                var_name
                retval.                " --> 0 = Ok, sonst Fehler
  IF retval <> 0.
    MESSAGE s001(38) WITH text-284.
    EXIT.
  ENDIF.

  PERFORM close_job
          USING job_name
                job_number
                sy-datum               " Datum
                sy-uzeit               " Uhrzeit
                'I'                    " Periodenkennung (IMMEDIATE)
                0                      " Periodendauer
                retval.                " --> 0 = Ok, sonst Fehler

  IF retval <> 0.
    MESSAGE s001(38) WITH text-284.
    EXIT.
  ENDIF.

  MESSAGE s001(38) WITH text-326 var_name text-327.     " OK-Nachricht
  read_joblist = 1.      " ein neuer ist geboren, also ggf. neue Liste

ENDFORM.                               " SCHEDULE_IMMEDIATELY

*&---------------------------------------------------------------------*
*&      Form  SHOW_JOBLST
*&---------------------------------------------------------------------*
*       Gibt die Liste der bereits eingeplanten Auftrags-Jobs aus.     *
*       Dazu wird der Funktionsbaustein BP_JOBVARIANT_OVERVIEW         *
*       aufgerufen.                                                    *
*----------------------------------------------------------------------*
FORM show_joblst.

  CALL FUNCTION 'BP_JOBVARIANT_OVERVIEW'
    EXPORTING
      title_name  = workarea_name
      job_name    = batchjob_name
      prog_name   = program_name
    EXCEPTIONS
      no_such_job = 01.
  IF sy-subrc <> 0.
    MESSAGE s001(38) WITH text-229.
  ENDIF.

  list_processing_context = btc_varlist_select.  " Listkontext merken

ENDFORM.                               " SHOW_JOBLST

*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_LATE
*&---------------------------------------------------------------------*
*       Einplanung eines Jobs zu einem gegebenen Zeitpunkt mit ggf.    *
*       gegebener Wiederholungsperiodendauer. Die Periodendauer wird   *
*       dabei über den Beschreibungsparameter PER_DESC und die Größe   *
*       PER_AMOUNT bestimmt.                                           *
*----------------------------------------------------------------------*
*  -->  JOB_NAME    Name des einzuplanenden Batchjobs
*       PROG_NAME   Name des Programms im ersten und einzigen Step
*       VAR_NAME    Variante des Programms PROG_NAME
*       DATE        geplantes Startdatum
*       TIME        geplante Startzeit
*       PER_DESC    Periodendauerbeschreibung.
*                   ' ' = KEINE PERIODE, 'M' = MONATE, 'W' = WOCHEN,
*                   'D' = Tage, 'H' = Stunden, 'N' = Minuten
*                   Eine Kombination dieser Einheiten ist nicht
*                   vorgesehen.
*       PER_AMOUNT  ANZAHL DER IN PER_DESC ANGEGEBENE EINHEITEN
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird die Liste der Batchjobs
*                  erweitert. Im Fehlerfall wird eine Nachricht
*                  ausgegeben und ggf. durchgeführte Veränderungen
*                  zurückgenommen.
*----------------------------------------------------------------------*
FORM schedule_late
     USING value(job_name)      LIKE tbtco-jobname
           value(prog_name)     LIKE rsvar-report
           value(var_name)      LIKE rsvar-variant
           value(date)          LIKE tbtco-strtdate
           value(time)          LIKE tbtco-strttime
           value(per_desc)      TYPE c
           value(per_amount)    TYPE i.

  DATA: job_number   LIKE tbtco-jobcount,
        retval       LIKE sy-subrc.


  job_name   = jobname_100.
  prog_name  = program_name_100.
  var_name   = variant_name_100.

  PERFORM open_job
          USING job_name
                job_number             " --> Nummer des angelegten Jobs
                retval.                " --> 0 = Ok, sonst Fehler
  IF retval <> 0.
    EXIT.
  ENDIF.

  PERFORM submit_job
          USING job_name
                job_number
                prog_name
                var_name
                retval.                " --> 0 = Ok, sonst Fehler
  IF retval <> 0.
    MESSAGE s001(38) WITH text-284.
    EXIT.
  ENDIF.

  PERFORM close_job
          USING job_name
                job_number
                date                   " Datum
                time                   " Uhrzeit
                per_desc               " Periodenkennung
                per_amount             " Periodendauer
                retval.                " --> 0 = Ok, sonst Fehler

  IF retval <> 0.
    MESSAGE s001(38) WITH text-284.
    EXIT.
  ENDIF.

  MESSAGE s001(38) WITH text-326 var_name text-299.   " OK-Nachricht
  read_joblist = 1.      " ein neuer ist geboren, also ggf. neue Liste

ENDFORM.                               " SCHEDULE_LATE

*&---------------------------------------------------------------------*
*&      Form  ENTER_PERIOD_DIALOG
*&---------------------------------------------------------------------*
*       Geht in das modale Dialogfenster für die Periodendauereingabe. *
*       Dieses modale Dialogfenster wird von beiden Transaktionen      *
*       BAT1 und BAT2 verwendet.                                       *
*----------------------------------------------------------------------*
FORM enter_period_dialog.

  PERFORM init_periods.                " Periodenwerte initialisieren

  CALL SCREEN 201 STARTING AT 45 6 ENDING AT 70 14.

ENDFORM.                               " ENTER_PERIOD_DIALOG

*&---------------------------------------------------------------------*
*&      Form  ENTER_STARTDATE
*&---------------------------------------------------------------------*
*       Starte Dialog für die Eingabe der Startzeitdaten.              *
*----------------------------------------------------------------------*
FORM enter_startdate.

  PERFORM compute_init_start_date      " Startzeitfelder initialisieren
          USING tbtcjob-strtdate
                tbtcjob-strttime.

  SET SCREEN 200. LEAVE SCREEN.

ENDFORM.                               " ENTER_STARTDATE

*&---------------------------------------------------------------------*
*&      Form  RETURN_FROM_POPUP
*&---------------------------------------------------------------------*
*       Kehre aus einem modalen Dialogfenster (Popup) zurück.          *
*----------------------------------------------------------------------*
FORM return_from_popup.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                               " RETURN_FROM_POPUP

*&---------------------------------------------------------------------*
*&      Form  OPEN_JOB
*&---------------------------------------------------------------------*
*       Legt eine interne Jobbeschreibung an, die später mit Steps     *
*       gefüllt werden kann (SUBMIT_JOB) und dann eingeplant werden    *
*       kann (CLOSE_JOB).                                              *
*----------------------------------------------------------------------*
*  -->  JOB_NAME    Name des anzulegenden Batchjobs
*  <--  JOB_NUMBER  interne Jobnummer zur späteren Identifikation
*       RETVAL      Rückgabewert (0 = OK, sonst Fehler)
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird die Liste der Batchjobs
*                  intern verlängert.
*----------------------------------------------------------------------*
FORM open_job
     USING value(job_name)   LIKE tbtco-jobname
           job_number        LIKE tbtco-jobcount
           retval            LIKE sy-subrc.

  retval = 0.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = job_name
    IMPORTING
      jobcount = job_number
    EXCEPTIONS
      OTHERS   = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    retval = 1.
    MESSAGE i001(38) WITH text-285.
  ENDIF.

ENDFORM.                               " OPEN_JOB

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_JOB
*&---------------------------------------------------------------------*
*       Eintragen eines Jobsteps in eine vorhandene Jobbeschreibung.   *
*----------------------------------------------------------------------*
*  -->  JOB_NAME    Name des zu bearbeitenden Jobs
*       JOB_NUMBER  interne Kennung des zu bearb. Jobs (von OPEN_JOB)
*       PROG_NAME   Name des Programm für den anzuheftenden Job
*       VAR_NAME    Name der Variante des Programms PROG_NAME
*  <--  RETVAL      Ergebniswert (0 = OK, sonst Fehler
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird die Jobliste des angegebenen
*                  Batchjobs verlängert - ansonsten wird der Job
*                  aus der Jobliste entfernt.
*----------------------------------------------------------------------*
FORM submit_job
     USING value(job_name)   LIKE tbtco-jobname
           value(job_number) LIKE tbtco-jobcount
           value(prog_name)  LIKE rsvar-report
           value(var_name)   LIKE rsvar-variant
           retval            LIKE sy-subrc.

  DATA: print_parameters LIKE pri_params,
        arc_parameters   LIKE arc_params.

  retval = 0.                          " wir hoffen das Beste...

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      mode                   = 'BATCH'
      report                 = prog_name
      no_dialog              = 'X'
    IMPORTING
      out_parameters         = print_parameters
      out_archive_parameters = arc_parameters
    EXCEPTIONS
      OTHERS                 = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  print_parameters-prnew = 'X'.        " neue Spoolliste

  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      authcknam = sy-uname
      jobcount  = job_number
      jobname   = job_name
      report    = prog_name
      variant   = var_name
      priparams = print_parameters
      arcparams = arc_parameters
    EXCEPTIONS
      OTHERS    = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE i001(38) WITH text-287.
    PERFORM delete_vjob USING job_name job_number retval.
* wenn der Step nicht angehängt werden kann, wird der gesamte Job
* entfernt!
    retval = 1.
  ENDIF.

ENDFORM.                               " SUBMIT_JOB

*&---------------------------------------------------------------------*
*&      Form  CLOSE_JOB
*&---------------------------------------------------------------------*
*       Plant einen Job endgültig ein. Der Job muß dabei schon         *
*       definiert (OPEN_JOB) und mindestens ein Step dafür angelegt    *
*       sein (SUBMIT_JOB).                                             *
*----------------------------------------------------------------------*
*  -->  JOB_NAME   Name des einzuplanenden Jobs
*       JOB_NUMBER Interne Identifikationsnummer des Jobs (JOB_OPEN)
*       START_DATE Geplantes Startdatum
*       START_TIME Geplante Startzeit
*       PER_DESC   Periodendauerbeschreibung (s.a. SCHEDULE_LATE)
*       PER_AMOUNT Periodendauerwert (s.a. SCHEDULE_LATE)
*  <--  RETVAL     Rückgabewert (0 = OK, sonst Fehler).
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird der Job eingeplant, d.h. die
*                  Einplanungstabelle erweitert. Im Fehlerfall wird
*                  der Job aus der Jobliste entfernt.
*----------------------------------------------------------------------*
FORM close_job
     USING value(job_name)   LIKE tbtco-jobname
           value(job_number) LIKE tbtco-jobcount
           value(start_date) LIKE sy-datum
           value(start_time) LIKE sy-uzeit
           value(per_desc)   TYPE c
           value(per_amount) TYPE i
           retval            LIKE sy-subrc.

  DATA: job_released LIKE btch0000-char1,
        periodic     VALUE ' ',
        immed        LIKE  btch0000-char1 VALUE ' ',
        months       LIKE tbtco-prdmonths ,
        weeks        LIKE tbtco-prdweeks ,
        days         LIKE tbtco-prddays ,
        hours        LIKE tbtco-prdhours ,
        minutes      LIKE tbtco-prdmins .

  retval = 0.

  IF per_desc = 'I'.                   " sofort ausführen
    immed = 'X'.
    per_desc = ' '.
  ENDIF.

  IF per_desc <> ' '.                  " periodisch ausführen
    periodic = 'X'.
    CASE per_desc.
      WHEN 'M'.
        months  = per_amount.
      WHEN 'W'.
        weeks   = per_amount.
      WHEN 'D'.
        days    = per_amount.
      WHEN 'H'.
        hours   = per_amount.
      WHEN 'N'.
        minutes = per_amount.
    ENDCASE.
  ENDIF.

  if immed = 'X'.
     CALL FUNCTION 'JOB_CLOSE'
       EXPORTING
         jobcount         = job_number
         jobname          = job_name
         prddays          = days
         prdhours         = hours
         prdmins          = minutes
         prdmonths        = months
         prdweeks         = weeks
         strtimmed        = immed
       IMPORTING
         job_was_released = job_released
       EXCEPTIONS
         OTHERS           = 01.
  else.
     CALL FUNCTION 'JOB_CLOSE'
       EXPORTING
         jobcount         = job_number
         jobname          = job_name
         prddays          = days
         prdhours         = hours
         prdmins          = minutes
         prdmonths        = months
         prdweeks         = weeks
         sdlstrtdt        = start_date
         sdlstrttm        = start_time
         strtimmed        = immed
       IMPORTING
         job_was_released = job_released
       EXCEPTIONS
         OTHERS           = 01.

  endif.
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE i001(38) WITH text-288.
    PERFORM delete_vjob USING job_name job_number retval.
    retval = 1.
  ENDIF.

ENDFORM.                               " CLOSE_JOB

*&---------------------------------------------------------------------*
*&      Form  DELETE_VJOB
*&---------------------------------------------------------------------*
*       Löscht einen eingeplanten Job aus der Jobliste.                *
*       Im Fehlerfall wird eine Fehlermeldung ausgegeben und die       *
*       Jobliste bleibt unverändert.                                   *
*----------------------------------------------------------------------*
*  -->  JOB_NAME    Name des eingeplanten Jobs in der Jobliste
*       JOB_NUMBER  Interne Kennummer des Jobs (JOB_OPEN)
*  <--  RETVAL      Rückgabewert (0 = OK, sonst Fehler)
*----------------------------------------------------------------------*
* Seiteneffekte:   Im Erfolgsfall wird der Job aus der Einplanungs-
*                  tabelle erweitert.
*----------------------------------------------------------------------*
FORM delete_vjob
     USING value(job_name)   LIKE tbtco-jobname
           value(job_number) LIKE tbtco-jobcount
           retval TYPE i.

  retval = 0.

  CALL FUNCTION 'BP_JOB_DELETE'
    EXPORTING
      forcedmode = 'X'
      jobcount   = job_number
      jobname    = job_name
    EXCEPTIONS
      OTHERS     = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE i001(38) WITH text-286.
    retval = 1.
  ENDIF.

ENDFORM.                               " DELETE_VJOB

*&---------------------------------------------------------------------*
*&      Form  FILL_VARTAB
*&---------------------------------------------------------------------*
*       Füllt die Tabelle der Variantennamen und deren Kurztexte.      *
*----------------------------------------------------------------------*
* GLOB: --> PROGRAM_NAME   Name des Programms für die Variantenliste
*           VARID          Variantentabelle
*           VARIT          Kurztexttabelle
*       <-- VAR_NUM        Anzahl der gefundenen Varianten zum Programm
*           VARIANT_TABLE  Tabelle mit Variantennamen und Kurztexten
*                          für das Programm PROG_NAME
*           DEFAULT_PARAMS Varianten Defaultwerte für Dynproausgabe
*----------------------------------------------------------------------*
FORM fill_vartab.

* variables for note 1363273
  CONSTANTS: var_nodisplay TYPE btcoptions-btcoption
                                VALUE 'VAR_NODISPLAY'.
  DATA: show_no_display_variants TYPE btcchar1.
  DATA: var_options TYPE TABLE OF btcoptions.
  DATA: wa_varoptions TYPE btcoptions.

  REFRESH variant_table.

* Selektieren der Varianten

  show_no_display_variants = 'X'.

  CALL FUNCTION 'BTC_OPTION_GET'          " note 1363273
    EXPORTING
      name               = var_nodisplay
*     IMPVALUE1          =
*     IMPVALUE2          =
*   IMPORTING
*     COUNT              =
   TABLES
     options            = var_options
   EXCEPTIONS
     invalid_name       = 1
     OTHERS             = 2
            .
  IF sy-subrc = 0.
    READ TABLE var_options INDEX 1 INTO wa_varoptions.
    IF wa_varoptions-value1 IS NOT INITIAL.
      CLEAR show_no_display_variants.
    ENDIF.
  ENDIF.

  SELECT * FROM varid CLIENT SPECIFIED
     WHERE report = program_name
     AND
     ( mandt = sy-mandt
       OR
       mandt = '000' AND ( variant LIKE 'SAP&%' OR variant LIKE
                           'CUS&%' ) )
     ORDER BY PRIMARY KEY.

    IF show_no_display_variants IS INITIAL
    AND ( varid-transport = 'X' OR varid-transport = 'N' ). "n 1363273
      CONTINUE.
    ENDIF.

    MOVE varid-variant TO variant_table-variant.

    SELECT SINGLE * FROM varit CLIENT SPECIFIED WHERE
                             langu      = sy-langu       AND
                             report     = program_name   AND
                             variant    = varid-variant  AND
                             mandt      = varid-mandt.

    IF sy-subrc = 0. " <>0 happens if the proper language is not there
      MOVE varit-vtext TO variant_table-vtext.
    ELSE.
      MOVE text-nvd TO variant_table-vtext.
    ENDIF.

    APPEND variant_table.
  ENDSELECT.

  DESCRIBE TABLE variant_table LINES var_num.

  IF var_num EQ 0.                     " keine Variante
    MESSAGE i001(38) WITH text-322.    " gefunden
    CLEAR default_params.
  ENDIF.

ENDFORM.                               " FILL_VARTAB

*&---------------------------------------------------------------------*
*&      Form  GET_VARIANT
*&---------------------------------------------------------------------*
*       Liefert die aktuell ausgewählte Variante zurück.               *
*----------------------------------------------------------------------*
* GLOB: --> VARIANT_TABLE  aktuell ausgewählte Variante
*       <-- RSVAR-VARIANT  ausgewählte Variante (Kopie)
*           RETVAL         1 = nix ausgewählt, 0 = OK
*----------------------------------------------------------------------*
FORM get_variant
     USING variant LIKE rsvar-variant
           retval TYPE i.

  rsvar-variant = variant_table-variant.
  IF rsvar-variant IS INITIAL.
    retval = 1.
  ELSE.
    retval = 0.
  ENDIF.

ENDFORM.                               " GET_VARIANT

*&---------------------------------------------------------------------*
*&      Form  CREATE_VARIANT
*&---------------------------------------------------------------------*
*       Erstellen einer neuen Variante.                                *
*----------------------------------------------------------------------*
* GLOB: --> PROGRAM_NAME   Name des Programms, das eine neue Variante
*                          bekommen soll
*----------------------------------------------------------------------*
* Seiteneffekte: Die Variantentabelle wird erweitert
*----------------------------------------------------------------------*
FORM create_variant.

  DATA: new_variant LIKE rsvar-variant.

  program_name = program_name_100.

  CALL FUNCTION 'RS_VARIANT_ADD'
    EXPORTING
      report  = program_name
      variant = ' '
    IMPORTING
      variant = new_variant
    EXCEPTIONS
      OTHERS  = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE s001(38) WITH text-322.
  ELSE.
    PERFORM reread_vartab.             " Variantentabelle geändert, also
  ENDIF.                               " neu einlesen

ENDFORM.                               " CREATE_VARIANT

*&---------------------------------------------------------------------*
*&      Form  SET_VARIANT_TEXT
*&---------------------------------------------------------------------*
*       Setzt den Tabellenarbeitsbereich VARIANT_TABLE auf die         *
*       Variante aus RSVAR-VARIANT. Dadurch wird für das Dynpro auch   *
*       der Kurztext gesetzt.                                          *
*----------------------------------------------------------------------*
* GLOB: --> RSVAR-VARIANT   Variante für die der Kurztext gesucht wird
*       <-- VARIANT_TABLE   Arbeitsbereich mit Variantenkurztext
*----------------------------------------------------------------------*
FORM set_variant_text.

  READ TABLE variant_table WITH KEY rsvar-variant.
  rsvar-variant = variant_name_100.
  variant_table-vtext = variant_text_100.

  if sy-dynnr = 500.
     rsvar-variant = variant_name_105.
  endif.

ENDFORM.                               " SET_VARIANT_TEXT

*&---------------------------------------------------------------------*
*&      Form  CHECK_VAR_SELECTION
*&---------------------------------------------------------------------*
*       Prüft, ob für die ausgewählte Funktion eine Variante           *
*       ausgewählt wurde.                                              *
*----------------------------------------------------------------------*
* GLOB: --> OK_CODE        ausgewählte Funktion
*           VARIANT_TABLE  ausgewählte Variante
*       <-- RETVAL         0 = OK, 1 = Auswahl paßt nicht zur Funktion
*----------------------------------------------------------------------*
FORM check_var_selection
     USING retval TYPE i.

  retval = 0.

  IF ok_code <> 'IMED' AND ok_code <> 'LATE' AND ok_code <> 'VSHO'.
    EXIT.         " Variante interessiert nur bei IMED, LATE, VSHO
  ENDIF.

  IF variant_table-variant IS INITIAL. " keine Variante ausgewählt
    MESSAGE s001(38) WITH text-323.
    retval = 1.
    EXIT.
  ENDIF.

ENDFORM.                               " CHECK_VAR_SELECTION

*&---------------------------------------------------------------------*
*&      Form  VAR_LINE_SELECTION
*&---------------------------------------------------------------------*
*       Doppelklick auf Variantenzeile: Es werden die Sektionswerte    *
*       der ausgewählten Variante angezeigt.                           *
*----------------------------------------------------------------------*
FORM var_line_selection.

  DATA: retval TYPE i,
        del_variant LIKE rsvar-variant." zu löschende Variante
  " kommt evtl. von
  " RS_VARIANT_DISPLAY zurück

  PERFORM get_variant USING rsvar-variant retval.
  IF retval <> 0.
    MESSAGE s001(38) WITH text-323.
    EXIT.
  ENDIF.

  PERFORM show_variant.

ENDFORM.                               " VAR_LINE_SELECTION

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_VLINE2_POSITIONS
*&---------------------------------------------------------------------*
*       Berechnet Spaltenpositionen für die Variantenlistenausgabe.    *
*----------------------------------------------------------------------*
* GLOB: --> VARIANT_TABLE  Struktur der Ausgabetabelle
*       <-- VLINE2_POS2, VLINE3_POS2, VNAME_POS, VTEXT_POS
*----------------------------------------------------------------------*
FORM compute_vline2_positions.

  DESCRIBE FIELD variant_table-variant LENGTH vline2_pos2
                                      IN CHARACTER MODE.
  vname_pos = 3.
  vline2_pos2 = vline2_pos2 + vname_pos + 1.
  DESCRIBE FIELD variant_table-vtext LENGTH vline3_pos2
                                      IN CHARACTER MODE.
  vtext_pos = vline2_pos2 + 2.
  vline3_pos2 = vline3_pos2 + vtext_pos + 1.

ENDFORM.                               " COMPUTE_VLINE2_POSITIONS

*&---------------------------------------------------------------------*
*&      Form  WRITE_VARTAB
*&---------------------------------------------------------------------*
*       Variantentabelle ausgeben.                                     *
*----------------------------------------------------------------------*
* GLOB: --> VARIANT_TABLE   Tabelle der Varianten
*           diverse Positionsangaben
*----------------------------------------------------------------------*
FORM write_vartab.

*  DATA: idx TYPE i VALUE 1.
*
*  FORMAT INTENSIFIED OFF.
*  FORMAT COLOR COL_NORMAL.
*
*  LOOP AT variant_table.
*
*    idx = idx + 1.
*
*    WRITE: / sy-vline NO-GAP.
*    POSITION vname_pos.   WRITE: variant_table-variant.
*    POSITION vline2_pos2. WRITE: sy-vline.
*    POSITION vtext_pos.   WRITE: variant_table-vtext.
*    POSITION vline3_pos2. WRITE: sy-vline.
*
*    HIDE: variant_table.               " merken für spätere Selektion
*
*  ENDLOOP.
*
*  ULINE AT /(vline3_pos2).
*
*  CLEAR variant_table.                 " löschen für spätere Auswahl

DATA:  layout_100  TYPE lvc_s_layo.

if container_100 is initial.

   perform make_field_cat_100.

   create object container_100
      exporting
         container_name = 'CC_GRID_100'.

   create object grid_100
      exporting
         i_parent  =  container_100.

   layout_100-sel_mode = 'A'.

*   call method grid_100->set_table_for_first_display
*       exporting
*         is_layout        = layout_100
*      changing
*         it_fieldcatalog  = field_cat_100
*         it_outtab        = variant_table.


endif.

ENDFORM.                               " WRITE_VARTAB

*&---------------------------------------------------------------------*
*&      Form  WRITE_VARTAB_HEADER
*&---------------------------------------------------------------------*
*       Überschrift für die Variantentabelle ausgeben. Wird bei        *
*       TOP-OF-PAGE und TOP-OF-PAGE-DURING-LINE-SELECTION aufgerufen.  *
*----------------------------------------------------------------------*
* GLOB: --> diverse Positionsangaben
*----------------------------------------------------------------------*
FORM write_vartab_header.

  list_processing_context = btc_varlist_select.  " Listkontext merken
  ULINE AT /(vline3_pos2).
  WRITE: / sy-vline.
  POSITION vname_pos.   WRITE: text-298.
  POSITION vline2_pos2. WRITE: sy-vline.
  POSITION vtext_pos. WRITE: text-325.
  POSITION vline3_pos2. WRITE: sy-vline.
  ULINE AT /(vline3_pos2).

ENDFORM.                               " WRITE_VARTAB_HEADER

*&---------------------------------------------------------------------*
*&      Form  REREAD_VARTAB
*&---------------------------------------------------------------------*
*       Variantentabelle neu einlesen (wenn eine Veränderung war).     *
*----------------------------------------------------------------------*
* GLOB: --> READ_VARTAB   Flag für Neulesen der Variantentabelle
*----------------------------------------------------------------------*
FORM reread_vartab.

  read_vartab = 1.                " aktuelle Variantentabelle ungültig
  SET SCREEN 100. LEAVE SCREEN.

ENDFORM.                               " REREAD_VARTAB

*&---------------------------------------------------------------------*
*&      Form  READ_VARIANT
*&---------------------------------------------------------------------*
*       Variantenliste einlesen (mittels Funktionsbaustein), um        *
*       im Dynproeingabefeld zu erscheinen.                            *
*----------------------------------------------------------------------*
* GLOB: --> PROGRAM_NAME   zugrunde liegendes Programm                 *
*       <-> RSVAR-VARIANT  im Dynprofeld stehende Variante             *
*----------------------------------------------------------------------*
FORM read_variant.

  DATA: old_variant LIKE rsvar-variant,
        new_variant LIKE rsvar-variant.

  old_variant = rsvar-variant.

  CALL FUNCTION 'RS_VARIANT_CATALOG'
    EXPORTING
      report      = program_name
      new_title   = ' '
    IMPORTING
      sel_variant = new_variant
    EXCEPTIONS
      OTHERS      = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc = 0 AND old_variant <> new_variant.
    rsvar-variant = new_variant.       " Dynprofeld neu setzen
    vjoblist-variant = new_variant.
    SET SCREEN sy-dynnr.               " Dynpro neu prozessieren
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                               " READ_VARIANT

*&---------------------------------------------------------------------*
*&      Form  SHOW_VARIANT
*&---------------------------------------------------------------------*
*       Anzeigen der ausgewählten Variante. Dabei können sowohl        *
*       die Attribute wie auch die Selektionswerte angezeigt und       *
*       bei Bedarf geändert werden. Es ist auch möglich beliebig       *
*       viele Varianten des gegebenen Programms zu löschen.            *
*----------------------------------------------------------------------*
FORM show_variant.

  program_name   = program_name_100.
  rsvar-variant  = variant_name_100.

  CALL FUNCTION 'RS_VARIANT_DISPLAY_255'
    EXPORTING
      report  = program_name
      variant = rsvar-variant
    EXCEPTIONS
      OTHERS  = 01.
* hier keine Returncodeabfrage, da RS_VARIANT_DISPLAY zu viele
* unterschiedliche Dinge machen kann (bis hin zum Löschen)

  PERFORM reread_vartab.             " Variantentabelle evtl. geändert,
  " also neu einlesen. Leider liefert
  " RS_VARIANTANT_DISPLAY nicht
  " zurück, ob eine Änderung gemacht
  " wurde - könnte hier unnötiges
  " Warten einsparen

ENDFORM.                    " SHOW_VARIANT
