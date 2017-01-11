*-------------------------------------------------------------------
***INCLUDE LBTCHF35 .
*-------------------------------------------------------------------
*----------------------------------------------------------------------*
* Hilfsroutinen für BP_JOBVARIANT_OVERVIEW  (Heinz Wolf 14.3.95)       *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  HANDLE_OKCODE
*&---------------------------------------------------------------------*
*       Behandelt die Funktionscodes für Drucktasten, die in Dynpros   *
*       gedrückt werden. Wird für alle Dynpros verwendet. Falls nötig  *
*       wird über den PF-Status unterschieden (wenn in mehreren Stati  *
*       derselbe Funktionscode benutzt wird).                          *
*----------------------------------------------------------------------*
* GLOB: OK_CODE   Funktionscode für die Drucktaste / Menüpunkt
*       PF-Status CUA-Status des aktuellen Dynpros
*       SY-DYNNR  Nummer des aktuellen Dynpros
*----------------------------------------------------------------------*
FORM handle_okcode.

  DATA: retval TYPE i.
  DATA: rc     TYPE i.

  CASE ok_code.

*   Transaktion beenden (Pfeil nach oben Ikone)
    WHEN 'EXIT'.
      PERFORM exit_screen.

*   Abbruch des aktuellen Einplanungsvorgangs (rote Kreuzikone)
    WHEN 'ABOR'.
      PERFORM abort_schedule USING sy-dynnr.

*   Einen Dialogschritt zurückgehen Pfeil nach links Ikone
    WHEN 'BACK'.
      PERFORM back_one_dynpro USING sy-dynnr.

*   Sofort einplanen
    WHEN 'IMED'.
      PERFORM get_variant USING rsvar-variant retval.
      IF retval <> 0. EXIT. ENDIF.
      PERFORM schedule_immediately
              USING batchjob_name program_name rsvar-variant.

*   Starttermin eingeben
    WHEN 'LATE'.
*      PERFORM GET_VARIANT USING RSVAR-VARIANT RETVAL.
*      IF RETVAL <> 0. EXIT. ENDIF.
      PERFORM enter_startdate.

*   Variante anzeigen oder ändern
    WHEN 'VSHO'.
*      PERFORM GET_VARIANT USING RSVAR-VARIANT RETVAL.
*      IF RETVAL <> 0. EXIT. ENDIF.
      PERFORM show_variant.

*   Liste der eingeplanten Aufträge anzeigen
    WHEN 'SHOW'.
      IF sy-dynnr = 200.
        PERFORM fill_joblist_table_105 USING rc.
        IF rc = 0.
          CALL SCREEN 105.
        ENDIF.
      ELSE.
        PERFORM show_joblst.
      ENDIF.

*   Einplanung durchführen (mit Starttermin, nicht periodisch)
    WHEN 'SAVE'.
      PERFORM schedule_late
              USING jobname_100 program_name_100 variant_name_100
                    tbtcjob-strtdate tbtcjob-strttime
                    ' '  0.            " nicht periodisch!

*   Einplanungsänderung durchführen
    WHEN 'DOCH'.
      PERFORM do_change_schedule.

*   Periodendauer eingeben
    WHEN 'VIEL'.
      PERFORM enter_period_dialog.
      IF sy-dynnr = 500.
        SET SCREEN 500.
        LEAVE SCREEN.                  " neue Periodenwerte anzeigen
      ENDIF.

*   Protokoll zum ausgewählten Job anzeigen
    WHEN 'LIST'.
      PERFORM log_list.

*   Ergebnisse des ausgewählten, beendeten Jobs anzeigen
    WHEN 'RESU'.
      PERFORM result_list.

*   Änderungsdialog für den ausgewählten Job starten
    WHEN 'CHAN'.
      PERFORM change_schedule.

*   Ausgewählte Einplanung löschen
    WHEN 'DELE'.
      PERFORM delete_schedule.

*   Jobausgabeliste aktualisieren
    WHEN 'AKTU'.
      PERFORM reread_list.

*   Dialog zur Erstellung einer neuen Variante starten
    WHEN 'NPAR'.
      PERFORM create_variant.

*   Nach einer ausgewählten Spalte sortieren
    WHEN 'SORT'.
      sorting_field = space.
      GET CURSOR FIELD sorting_field.
      PERFORM sort_vjoblist USING sorting_field.
      SET SCREEN 400. LEAVE SCREEN.              " Liste neu ausgeben

    WHEN OTHERS.
* do nothing

  ENDCASE.

ENDFORM.                               " HANDLE_OKCODE

*&---------------------------------------------------------------------*
*&      Form  LOG_LIST
*&---------------------------------------------------------------------*
*       Ausgabe eines Jobprotokolls.                                   *
*----------------------------------------------------------------------*
* GLOB: VJOBLIST   enthält den aktuell ausgewählten Job (Hide)
*----------------------------------------------------------------------*
FORM log_list.

  CALL FUNCTION 'BP_JOBLOG_SHOW'
    EXPORTING
      jobcount = vjoblist-jobcount
      jobname  = vjoblist-jobname
    EXCEPTIONS
      OTHERS   = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE s001(38) WITH text-306.
  ENDIF.

ENDFORM.                               " LOG_LIST

*&---------------------------------------------------------------------*
*&      Form  RESULT_LIST
*&---------------------------------------------------------------------*
*       Ausgabe der Ergebnisliste für einen ordentlich beendeten Job.  *
*----------------------------------------------------------------------*
* GLOB: JOBSTEPLIST  enthält den ersten step des ausgewählten Jobs.
*----------------------------------------------------------------------*
* Seiteneffekte: Zur Ausgabe dieser Ergebnisliste wird die Transaktion
*                SP01 aufgerufen und die Listennummer über SPA/GPA
*                übergeben.
*----------------------------------------------------------------------*
FORM result_list.

  SET PARAMETER ID 'SPI' FIELD jobsteplist-listident.
  CALL TRANSACTION 'SP01' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

ENDFORM.                               " RESULT_LIST

*&---------------------------------------------------------------------*
*&      Form  CHANGE_SCHEDULE
*&---------------------------------------------------------------------*
*       Startet den Dialog zur Änderung von Startzeit- und Perioden-   *
*       daten für einen schon eingeplanten Job.                        *
*----------------------------------------------------------------------*
* GLOB: VJOBLIST         enthält den ausgewählten Job (Hide)
*   <-- OLD_PERIOD_TEXT  enthält nach dem Aufruf den Periodentext für
*                        den bisher eingetragenen Peridenwert.
*   <-- NEW_PERIOD_TEXT  wird hier zunächste auf denselben Wert wie
*                       OLD_PERIOD_TEXT initialisiert.
*----------------------------------------------------------------------*
FORM change_schedule.

  tbtcjob = vjoblist-tbtcjob.

  PERFORM create_period_text USING vjoblist-tbtcjob old_period_text.

  new_period_text = old_period_text.

  CALL SCREEN 500.                     " Dynpro für Änderungsdialog

  IF recursive_call = 1.
    recursive_call = 0.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                               " CHANGE_SCHEDULE

*&---------------------------------------------------------------------*
*&      Form  DELETE_SCHEDULE
*&---------------------------------------------------------------------*
*       Löscht eine Einplanung wieder aus der Einplanungsliste.        *
*----------------------------------------------------------------------*
* GLOB: VJOBLIST  enthält den aktuell ausgewählten Job (Hide)
*----------------------------------------------------------------------*
* Seiteneffekte:  Der Job wird im Erfolgsfall aus der Jobliste entfernt.
*----------------------------------------------------------------------*
FORM delete_schedule.

  DATA: retval TYPE i, antwort.

  IF vjoblist-status = btc_running.
    MESSAGE s001(38) WITH text-293.
    EXIT.
  ENDIF.

* Sicherheitsabfrage vor dem Löschen
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = text-329
      text_question = text-328
    IMPORTING
      answer        = antwort
    EXCEPTIONS
      OTHERS        = 99.

  IF antwort = '1'.
    PERFORM delete_vjob USING vjoblist-jobname vjoblist-jobcount retval.

    IF retval = 0.
      MESSAGE s001(38) WITH text-305.
      PERFORM reread_list.
    ENDIF.
  ENDIF.

ENDFORM.                               " DELETE_SCHEDULE

*&---------------------------------------------------------------------*
*&      Form  JOB_LINE_SELECTION
*&---------------------------------------------------------------------*
*       Reaktion auf den Doppelklick im Joblistenausgabefenster.       *
*       Es wird geprüft, ob überhaupt ein Job ausgewählt wurde und     *
*       falls ja eine für den aktuellen Status des ausgewählten Jobs   *
*       spezifische Aktion ausgeführt.                                 *
*----------------------------------------------------------------------*
* GLOB: VJOBLIST  enthält den aktuell ausgewählten Job bzw. Initial-
*                 werte, wenn kein Job ausgewählt wurde.
*----------------------------------------------------------------------*
FORM job_line_selection.

  IF vjoblist-jobname IS INITIAL.       " kein Job ausgewählt
    MESSAGE s001(38) WITH text-289.
    EXIT.
  ENDIF.

  IF vjoblist-status = btc_scheduled OR
     vjoblist-status = btc_released OR
     vjoblist-status = btc_ready.
    rsvar-variant = vjoblist-variant.  " Variantenfeld im Dynpro setzen
    PERFORM change_schedule.           " in den Änderungsdialog
  ELSEIF vjoblist-status = btc_finished.
    READ TABLE jobsteplist WITH KEY jobcount = vjoblist-jobcount.
    PERFORM result_list.               " Ergebnisliste ausgeben
  ELSEIF vjoblist-status = btc_aborted OR
         vjoblist-status = btc_running.
    READ TABLE jobsteplist WITH KEY jobcount = vjoblist-jobcount.
    PERFORM log_list.                  " Protokoll ausgeben
  ENDIF.

ENDFORM.                               " JOB_LINE_SELECTION

*&---------------------------------------------------------------------*
*&      Form  CHECK_JOB_SELECTION
*&---------------------------------------------------------------------*
*       Prüft, ob die ausgewählte Funktion auf den ausgewählten Job    *
*       angewendet werden kann.                                        *
*----------------------------------------------------------------------*
*  <--  RETVAL    Rückgabewert (0=OK, 1=kein Job gewählt, 2=unzulässige
*                               Funktion für gewählten Job)
* GLOB: VJOBLIST  aktuell ausgewählter Job, initial falls keiner
*                 ausgewählt.
*----------------------------------------------------------------------*
FORM check_job_selection USING retval TYPE i.

  retval = 0.

  IF vjoblist-jobname IS INITIAL.       " kein Job ausgewählt
    MESSAGE s001(38) WITH text-289.
    retval = 1.
    EXIT.
  ENDIF.

  CASE ok_code.

    WHEN 'LIST'.
      IF vjoblist-status <> btc_aborted AND     " Protokoll kann nur
         vjoblist-status <> btc_finished AND    " für abgebrochene,
         vjoblist-status <> btc_running.        " beendete oder
        MESSAGE s001(38) WITH text-290.         " laufende Jobs
        retval = 2.                             " ausgegeben werden
        EXIT.
      ENDIF.

    WHEN 'RESU'.
      IF vjoblist-status <> btc_finished.       " Ergebnisliste nur für
        MESSAGE s001(38) WITH text-291.         " beendete Jobs
        retval = 2.
        EXIT.
      ENDIF.

    WHEN 'CHAN'.
      IF vjoblist-status <> btc_scheduled AND   " nur eingeplante oder
         vjoblist-status <> btc_released.       " freigegebene Jobs sind
        MESSAGE s001(38) WITH text-292." änderbar
        retval = 2.
        EXIT.
      ENDIF.

    WHEN 'DELE'.                       " laufende Jobs können
      IF vjoblist-status = btc_running. " nicht gelöscht werden
        MESSAGE s001(38) WITH text-293.
* [CHANGE]
* evtl. sollten laufende Jobs hier abgebrochen werden
        retval = 2.
        EXIT.
      ENDIF.

  ENDCASE.

  " nun noch die JOBSTEPLIST für den asugewählten Job richtig setzen
  READ TABLE jobsteplist WITH KEY jobcount = vjoblist-jobcount.

  " und in Gottes Namen auch noch das Varianten-Feld für Ändern
  rsvar-variant = vjoblist-variant.

ENDFORM.                               " CHECK_JOB_SELECTION

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_VLINE1_POSITIONS
*&---------------------------------------------------------------------*
*       Berechnet die Ausgabepositionen für die Jobliste.              *
*----------------------------------------------------------------------*
* GLOB: <-- VLINE?_POS, SDLDATE_POS, SDLTIME_POS, STATUS_POS,
*           UNAME_POS, VARNAME_POS
*----------------------------------------------------------------------*
FORM compute_vline1_positions.

  DESCRIBE FIELD vjoblist-sdldate LENGTH vline2_pos IN CHARACTER MODE.
  sdldate_pos = 3.
  vline2_pos = vline2_pos + sdldate_pos + 3.
  DESCRIBE FIELD vjoblist-sdltime LENGTH vline3_pos IN CHARACTER MODE.
  sdltime_pos = vline2_pos + 2.
  vline3_pos = vline3_pos + sdltime_pos + 3.
  DESCRIBE FIELD status_text LENGTH vline4_pos IN CHARACTER MODE.
  status_pos = vline3_pos + 2.
  vline4_pos = vline4_pos + status_pos + 1.
  DESCRIBE FIELD vjoblist-sdluname LENGTH vline5_pos IN CHARACTER MODE .
  uname_pos = vline4_pos + 2.
  vline5_pos = vline5_pos + uname_pos + 1.
  DESCRIBE FIELD vjoblist-vtext LENGTH vline6_pos IN CHARACTER MODE.
  varname_pos = vline5_pos + 2.
  vline6_pos = vline6_pos + varname_pos + 1.

ENDFORM.                               " COMPUTE_VLINE1_POSITIONS

*&---------------------------------------------------------------------*
*&      Form  WRITE_JOBLIST_HEADER
*&---------------------------------------------------------------------*
*       Schreibt die Überschrift für die Jobliste.                    *
*----------------------------------------------------------------------*
* GLOB: VLINE?_POS, SDLDATE_POS, SDLTIME_POS, STATUS_POS,
*       UNAME_POS, VARNAME_POS
*----------------------------------------------------------------------*
FORM write_joblist_header.

  list_processing_context = btc_varjoblist_select.  " Listkontext merken
  ULINE AT /(vline6_pos).
  WRITE: / sy-vline.
  POSITION sdldate_pos. WRITE: text-295.
  POSITION vline2_pos.  WRITE: sy-vline.
  POSITION sdltime_pos. WRITE: text-296.
  POSITION vline3_pos.  WRITE: sy-vline.
  POSITION status_pos.  WRITE: text-297.
  POSITION vline4_pos.  WRITE: sy-vline.
  POSITION uname_pos.   WRITE: text-319.
  POSITION vline5_pos.  WRITE: sy-vline.
  POSITION varname_pos. WRITE: text-298.
  POSITION vline6_pos.  WRITE: sy-vline.

  ULINE AT /(vline6_pos).

ENDFORM.                               " WRITE_JOBLIST_HEADER

*&---------------------------------------------------------------------*
*&      Form  REREAD_LIST
*&---------------------------------------------------------------------*
*       Setzt das Flag, um die Jobliste neu zu lesen und startet das   *
*       entsprechende Dynpro neu. Wird aufgerufen, wenn eine Aktion    *
*       durchgeführt wurde, die die Liste verändert hat oder wenn      *
*       explizit "aktualisieren" gewählt wurde.                        *
*----------------------------------------------------------------------*
* GLOB: <-- READ_JOBLIST  Flag für Joblistenaktualisierung
*----------------------------------------------------------------------*
FORM reread_list.

  read_joblist = 1.
  SET SCREEN 400. LEAVE SCREEN.

ENDFORM.                               " REREAD_LIST

*&---------------------------------------------------------------------*
*&      Form  CREATE_PERIOD_TEXT
*&---------------------------------------------------------------------*
*       Generiert einen Textstring aus einer Periodenbeschreibung.     *
*       Die Periodenbeschreibung besteht aus einem Beschreibungs-      *
*       zeichen (PERIODIC), welches die Einheit der Periode angibt     *
*       und für jede Einheit einer Anzahl, wobei nur die zum Beschrei- *
*       bungszeichen passende Anzahl benutzt wird.                     *
*----------------------------------------------------------------------*
*  -->  JOBDESC   Jobbeschreibung (nur die Periodenwerte werden
*                 verwendet). PERIODIC trägt nicht nur binäre
*                 Information, sondern die Periodeneinheit.
*----------------------------------------------------------------------*
FORM create_period_text
  USING value(jobdesc) STRUCTURE tbtcjob
        per_text LIKE old_period_text.

  DATA: amount TYPE i.

  CASE jobdesc-periodic.               " Periodeneinheit

    WHEN ' '.                          " keine Periode
      per_text = text-317.
      " keine expizite Einheit
    WHEN 'X'.                          " es wird einfach die erste
      IF jobdesc-prdmonths <> 0.       " Größe <> 0 verwendet.
        amount = jobdesc-prdmonths.
        PERFORM build_texts
                USING amount text-307 text-308 per_text.
      ELSEIF jobdesc-prdweeks <> 0.
        amount = jobdesc-prdweeks.
        PERFORM build_texts
                USING amount text-309 text-310 per_text.
      ELSEIF jobdesc-prddays <> 0.
        amount = jobdesc-prddays.
        PERFORM build_texts
                USING amount text-311 text-312 per_text.
      ELSEIF jobdesc-prdhours <> 0.
        amount = jobdesc-prdhours.
        PERFORM build_texts
                USING amount text-313 text-314 per_text.
      ELSEIF jobdesc-prdmins <> 0.
        amount = jobdesc-prdmins.
        PERFORM build_texts
                USING amount text-315 text-316 per_text.
      ENDIF.

    WHEN 'M'.                          " Einheit Monate
      amount = jobdesc-prdmonths.
      PERFORM build_texts
              USING amount text-307 text-308 per_text.

    WHEN 'W'.                          " Einheit Wochen
      amount = jobdesc-prdweeks.
      PERFORM build_texts
              USING amount text-309 text-310 per_text.

    WHEN 'D'.                          " Einheit Tage
      amount = jobdesc-prddays.
      PERFORM build_texts
              USING amount text-311 text-312 per_text.

    WHEN 'H'.                          " Einheit Stunden
      amount = jobdesc-prdhours.
      PERFORM build_texts
              USING amount text-313 text-314 per_text.

    WHEN 'N'.                          " Einheit Minuten
      amount = jobdesc-prdmins.
      PERFORM build_texts
              USING amount text-315 text-316 per_text.

  ENDCASE.

ENDFORM.                               " CREATE_PERIOD_TEXT

*&---------------------------------------------------------------------*
*&      Form  BUILD_TEXTS
*&---------------------------------------------------------------------*
*       Baut eine Textzeile für die Periodendauer aus den Bestand-     *
*       teilen zusammen.                                               *
*----------------------------------------------------------------------*
*  -->  AMOUNT       Anzahl der Periodeneinheiten
*       TEXT1        Erster Textteil
*       TEXT2        Abschließender Textteil
*  <--  RETURN_TEXT  Rückgabetextzeile
*----------------------------------------------------------------------*
FORM build_texts
  USING value(amount) TYPE i
        value(text1)
        value(text2)
        return_text.

  DATA amount_c(5).

  IF amount = 0.
    return_text = text-317.            " keine Periode
  ELSEIF amount = 1.
    return_text = text1.               " Singular (täglich, wöchentlich.
  ELSE.
    amount_c = amount.                 " Typkonvertierung für Ausgabe
*   concatenate text-318 amount_c text2 into return_text.
* leider darf ich das obige ABAP-3.0 Statement nicht verwenden :-(
* aber längerfristig sollte der Aufruf des Funktionsbausteins raus!
    CALL FUNCTION 'STRING_CONCATENATE_3'
      EXPORTING
        string1   = text-318
        string2   = amount_c
        string3   = text2
      IMPORTING
        string    = return_text
      EXCEPTIONS
        too_small = 01.

    CONDENSE return_text.
  ENDIF.

ENDFORM.                               " BUILD_TEXTS

*&---------------------------------------------------------------------*
*&      Form  INIT_PERIODS
*&---------------------------------------------------------------------*
*       Periodenwerte für die Dynproausgabe initialisieren. Dabei wird *
*       nur bei der Ersteingabe (dynpro 200) dafür gesorgt, daß        *
*       überall wo der Initialwert stand, eine 1 eingetragen wird.     *
*----------------------------------------------------------------------*
* GLOB: <--> TBTCJOB  Die Periodenwerte werden ggf. auf 1 initialisiert.
*----------------------------------------------------------------------*
FORM init_periods.

  IF sy-dynnr = 200.
    IF tbtcjob-prdmonths IS INITIAL.
      tbtcjob-prdmonths = 1.
    ENDIF.
    IF tbtcjob-prdweeks IS INITIAL.
      tbtcjob-prdweeks = 1.
    ENDIF.
    IF tbtcjob-prddays IS INITIAL.
      tbtcjob-prddays = 1.
    ENDIF.
    IF tbtcjob-prdhours IS INITIAL.
      tbtcjob-prdhours = 1.
    ENDIF.
    IF tbtcjob-prdmins IS INITIAL.
      tbtcjob-prdmins = 1.
    ENDIF.
  ENDIF.

ENDFORM.                               " INIT_PERIODS
*&---------------------------------------------------------------------*
*&      Form  FILL_JOBLIST_TABLE
*&---------------------------------------------------------------------*
*       Füllt die Jobtabelle für die spätere Auflistung und Bear-      *
*       beitung und die Jobsteptabelle mit dem jeweils ersten Jobstep. *
*----------------------------------------------------------------------*
* GLOB: --> BATCHJOB_NAME   Name des Jobs, für den die Liste kommt
*       <-- VJOBLIST        Liste der eingeplanten Jobs
*           JOBSTEPLIST     Liste der jeweils ersten Steps dieser Jobs
*----------------------------------------------------------------------*
FORM fill_joblist_table.

  DATA:  job_select_in  LIKE btcselect,
         job_select_out LIKE job_select_in,
         jobhead        LIKE tbtcjob.
  DATA  BEGIN OF steplist OCCURS 10.
          INCLUDE STRUCTURE jobsteplist.
  DATA  END   OF steplist.
  DATA  len TYPE i.
  DATA  idx TYPE i.

  PERFORM compute_vline1_positions.    " Ausgabepositionen für
  " Jobliste berechnen
  job_select_in-jobname  = batchjob_name.
  job_select_in-username = '*'.        " Userübergreifend
  job_select_in-no_date  = 'X'.        " alle Jobtypen
  job_select_in-prelim   = 'X'.        " auswählen
  job_select_in-schedul  = 'X'.
  job_select_in-ready    = 'X'.
  job_select_in-running  = 'X'.
  job_select_in-finished = 'X'.
  job_select_in-aborted  = 'X'.

  REFRESH: vjoblist, jobsteplist.       " Tabellen erst löschen

  CALL FUNCTION 'BP_JOB_SELECT'
    EXPORTING
      jobselect_dialog  = btc_no
      jobsel_param_in   = job_select_in
    IMPORTING
      jobsel_param_out  = job_select_out
    TABLES
      jobselect_joblist = vjoblist
    EXCEPTIONS
      OTHERS            = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc <> 0.
    MESSAGE i001(38) WITH text-294.
    RAISE no_such_job.
*    PERFORM EXIT_SCREEN.
  ENDIF.

  idx = 1.

  LOOP AT vjoblist.               " für jeden Job die Stepliste lesen

    CALL FUNCTION 'BP_JOB_READ'
      EXPORTING
        job_read_jobcount = vjoblist-jobcount
        job_read_jobname  = vjoblist-jobname
        job_read_opcode   = btc_read_all_jobdata
      IMPORTING
        job_read_jobhead  = jobhead
      TABLES
        job_read_steplist = steplist
      EXCEPTIONS
        OTHERS            = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

    IF sy-subrc <> 0.
      CLEAR steplist.
    ENDIF.

    steplist-jobcount = vjoblist-jobcount. " für spätere Referenzierung
    APPEND steplist TO jobsteplist .      " nur der erste Step!

    " jetzt noch die Variante in die Jobliste eintragen

    CLEAR variant_table.   " note 570493
    READ TABLE variant_table WITH KEY variant = steplist-parameter.
    IF sy-subrc = 0.       " note 570493
      MOVE-CORRESPONDING variant_table TO vjoblist.
    ENDIF.                 " note 570493
    MODIFY vjoblist INDEX idx FROM vjoblist.
    idx = idx + 1.

  ENDLOOP.

* ++ajk -- 23.7.98
* This is a repair: The jobs that were planned for another mandt
* should not be displayed (the varit-text was wrong -
* it was the text for the display  mandt!). Cleanup those. --ajk
  LOOP AT vjoblist.
    IF sy-mandt <> vjoblist-authckman.
      DELETE vjoblist.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE vjoblist LINES len.
  IF len = 0.
    MESSAGE i001(38) WITH text-mdt.
  ENDIF.
* --ajk

  " nach aktuellem Sortierwunsch (SELECTED_FIELD) sortieren
  PERFORM sort_vjoblist USING sorting_field.

ENDFORM.                               " FILL_JOBLIST_TABLE

*&---------------------------------------------------------------------*
*&      Form  DO_CHANGE_SCHEDULE
*&---------------------------------------------------------------------*
*       Änderung eines eingeplanten Jobs intern durchführen.          *
*----------------------------------------------------------------------*
* GLOB: --> TBTCJOB  Im Dynpro eingegebene Startzeit- und Periodendaten
*           RSVAR    Im Dynpro eingegebene Programmvariante
*           VJOBLIST Daten des zu ändernden Jobs
*           JOBSTEPLIST  Stepliste des zu ändernden Jobs
*           RADIO_*  Pushbuttons für die Periodeneinheit
*----------------------------------------------------------------------*
FORM do_change_schedule.

  DATA  BEGIN OF steplist OCCURS 1.
          INCLUDE STRUCTURE tbtcstep.
  DATA  END   OF steplist.
  DATA: return_head LIKE tbtcjob,
        newhead     LIKE tbtcjob,
        modifiedjob LIKE tbtcjob,
        antwort.

  DATA: rc TYPE i.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = text-331
      text_question = text-330
    IMPORTING
      answer        = antwort
    EXCEPTIONS
      OTHERS        = 99.

  IF antwort <> '1'.
    EXIT.
  ENDIF.

  newhead = vjoblist-tbtcjob.

  REFRESH steplist.
  READ TABLE jobsteplist WITH KEY jobcount = vjoblist-jobcount.
  jobsteplist-parameter = rsvar-variant.
  MOVE-CORRESPONDING jobsteplist TO steplist.
  APPEND steplist.

  newhead-sdlstrtdt = tbtcjob-sdlstrtdt.
  newhead-sdlstrttm = tbtcjob-sdlstrttm.
  newhead-periodic  = vjoblist-periodic.
  newhead-prdmonths = vjoblist-prdmonths.
  newhead-prdweeks  = vjoblist-prdweeks.
  newhead-prddays   = vjoblist-prddays.
  newhead-prdhours  = vjoblist-prdhours.
  newhead-prdmins   = vjoblist-prdmins.

  IF NOT tbtcjob-periodic IS INITIAL.
    newhead-periodic = 'X'.
    IF tbtcjob-periodic = 'M' OR
       ( tbtcjob-periodic = 'X' AND radio_months = 'X' ).
      newhead-prdmonths = tbtcjob-prdmonths.
      IF newhead-prdmonths = 0. newhead-periodic = ' '. ENDIF.
    ELSEIF tbtcjob-periodic = 'W' OR
       ( tbtcjob-periodic = 'X' AND radio_weeks = 'X' ).
      newhead-prdweeks  = tbtcjob-prdweeks.
      IF newhead-prdweeks = 0. newhead-periodic = ' '. ENDIF.
    ELSEIF tbtcjob-periodic = 'D' OR
       ( tbtcjob-periodic = 'X' AND radio_days = 'X' ).
      newhead-prddays   = tbtcjob-prddays.
      IF newhead-prddays = 0. newhead-periodic = ' '. ENDIF.
    ELSEIF tbtcjob-periodic = 'H' OR
       ( tbtcjob-periodic = 'X' AND radio_hours = 'X' ).
      newhead-prdhours  = tbtcjob-prdhours.
      IF newhead-prdhours = 0. newhead-periodic = ' '. ENDIF.
    ELSEIF tbtcjob-periodic = 'N' OR
       ( tbtcjob-periodic = 'X' AND radio_minutes = 'X' ).
      newhead-prdmins   = tbtcjob-prdmins.
      IF newhead-prdmins = 0. newhead-periodic = ' '. ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      dialog           = btc_no
      jobcount         = vjoblist-jobcount
      jobname          = vjoblist-jobname
      new_jobhead      = newhead
      opcode           = btc_modify_whole_job
    IMPORTING
      modified_jobhead = modifiedjob
    TABLES
      new_steplist     = steplist
    EXCEPTIONS
      OTHERS           = 01.
* [CHANGE]
* alle Fehlerfälle werden gleich behandelt - sollte zur besseren
* Information geändert werden.

  IF sy-subrc = 0.
    MESSAGE s001(38) WITH text-320.
    read_joblist = 1.  " Jobliste wurde verändert
*    RECURSIVE_CALL = 1.

    SET SCREEN 0.                    " also neu lesen und ausgeben
    LEAVE SCREEN.
  ELSE.
    MESSAGE i001(38) WITH text-321.
  ENDIF.

ENDFORM.                               " DO_CHANGE_SCHEDULE

*&---------------------------------------------------------------------*
*&      Form  WRITE_JOBLIST_TABLE
*&---------------------------------------------------------------------*
*       Ausgabe der Einplanungsliste. Ausgegeben wird Startdatum,      *
*       Startzeit, Status, Einplaner und Variantenkurztext (Parameter) *
*       für jeden in der Planungsliste vorhandenen Auftrag.            *
*----------------------------------------------------------------------*
* GLOB: --> VJOBLIST    Liste der Aufträge
*           JOBSTEPLIST Liste der jeweils ersten Steps der Aufträge
*           diverse Positionsangaben
*----------------------------------------------------------------------*
FORM write_joblist_table.

  DATA: date LIKE tbtco-strtdate,
        time LIKE tbtco-strttime.

  LOOP AT vjoblist.
    FORMAT COLOR COL_NORMAL.           " helles unauffälliges grau
    CLEAR status_text.
    date = vjoblist-strtdate.          " reale Startzeitdaten
    time = vjoblist-strttime.

    CASE vjoblist-status.
      WHEN btc_scheduled.
        FORMAT COLOR COL_POSITIVE.     " grün wie die Hoffnung
        status_text = text-299.
        date = vjoblist-sdlstrtdt.     " geplante Startzeitdaten
        time = vjoblist-sdlstrttm.
      WHEN btc_released.
        FORMAT COLOR COL_POSITIVE.     " grün wie die Hoffnung
        status_text = text-300.
        date = vjoblist-sdlstrtdt.     " geplante Startzeitdaten
        time = vjoblist-sdlstrttm.
      WHEN btc_ready.
        FORMAT COLOR COL_POSITIVE.     " grün wie die Hoffnung
        status_text = text-301.
        date = vjoblist-sdlstrtdt.     " geplante Startzeitdaten
        time = vjoblist-sdlstrttm.
      WHEN btc_running.
        FORMAT COLOR COL_TOTAL.        " gelb
        status_text = text-302.
      WHEN btc_finished.
        status_text = text-303.
      WHEN btc_aborted.
        FORMAT COLOR COL_NEGATIVE.     " rot
        status_text = text-304.
    ENDCASE.

    WRITE: / sy-vline NO-GAP.
    POSITION sdldate_pos. WRITE: date.
    POSITION vline2_pos.  WRITE: sy-vline.
    POSITION sdltime_pos. WRITE: time.
    POSITION vline3_pos.  WRITE: sy-vline.
    POSITION status_pos.  WRITE: status_text.
    POSITION vline4_pos.  WRITE: sy-vline.
    POSITION uname_pos.   WRITE: vjoblist-sdluname.
    POSITION vline5_pos.  WRITE: sy-vline.
    POSITION varname_pos. WRITE: vjoblist-vtext.
    POSITION vline6_pos.  WRITE: sy-vline.

    HIDE: vjoblist.        " merken für spätere Selektion

  ENDLOOP.

  ULINE AT /(vline6_pos).

  CLEAR vjoblist.                       " löschen für spätere Auswahl

ENDFORM.                               " WRITE_JOBLIST_TABLE

*&---------------------------------------------------------------------*
*&      Form  HANDLE_OKCODE_201
*&---------------------------------------------------------------------*
*       Behandelt Funktionsauswahl aus dem modalen Dialogfenster 201   *
*       heraus (Periodenauswahldynpro). Es wird nur eine Perioden-     *
*       einheit verwendet (die erste <> 0). Das Dynpro wird von beiden *
*       Transaktionen (bat1,bat2) verwendet. In bat1 für die Perioden- *
*       eingabe für eine neue Einplanung und in bat2 für die Änderung  *
*       der Periode einer existierenden Einplanung. Dies wird erkannt  *
*       durch den Inhalt von VJOBLIST. Ist VJOBLIST initial, so wird   *
*       eine neue Einplanung angelegt, ansonsten enthält es die        *
*       Beschreibung für die zu änderende Einplanung.                  *
*----------------------------------------------------------------------*
* GLOB: --> OK_CODE        ausgewählte Funktion
*           RADIO_*        gedrückter Auswahlknopf
*           TBTCJOB        eingebene Periodenwerte
*           VJOBLIST       ausgewählter Job (falls Änderung der Periode
*                          durchgeführt wird), sonst ist dies initial
*           BATCHJOB_NAME  Name des Jobs
*           PROGRAM_NAME   Name des Programms für den ersten Jobstep
*           RSVAR          Beschreibung der Variante des ersten Jobsteps
*----------------------------------------------------------------------*
FORM handle_okcode_201.

  DATA: per_amount TYPE i.

  CASE ok_code.

    WHEN 'SAVE'.
      IF radio_months = 'X'.
        tbtcjob-periodic = 'M'.
        per_amount = tbtcjob-prdmonths.
      ELSEIF radio_weeks = 'X'.
        tbtcjob-periodic = 'W'.
        per_amount = tbtcjob-prdweeks.
      ELSEIF radio_days  = 'X'.
        tbtcjob-periodic = 'D'.
        per_amount = tbtcjob-prddays.
      ELSEIF radio_hours = 'X'.
        tbtcjob-periodic = 'H'.
        per_amount = tbtcjob-prdhours.
      ELSEIF radio_minutes = 'X'.
        tbtcjob-periodic   = 'N'.
        per_amount = tbtcjob-prdmins.
      ENDIF.

      IF vjoblist-jobname IS INITIAL.  " neue Einplanung
        PERFORM schedule_late
                USING batchjob_name
                      program_name
                      rsvar-variant
                      tbtcjob-strtdate
                      tbtcjob-strttime
                      tbtcjob-periodic " periodisch!
                      per_amount.
      ELSE.                            " Änderung einer
        PERFORM create_period_text     " Einplanung
                USING tbtcjob new_period_text.   " neuen Periodentext
      ENDIF.                           " erzeugen für die
      " Dynproanzeige
      PERFORM return_from_popup.

    WHEN 'ABOR'.                       " modalen Dialog abbrechen
      PERFORM return_from_popup.

    WHEN 'EXIT'.                       " gesamte Transaktion beenden
      PERFORM exit_screen.

  ENDCASE.

ENDFORM.                               " HANDLE_OKCODE_201

*&---------------------------------------------------------------------*
*&      Form  SET_TITLE_AND_STATUS
*&---------------------------------------------------------------------*
*       Dynprotitel und -status setzen. Wird in allen PBOs ausgerufen. *
*       Die Unterscheidung pro Dynpro geschieht durch SY-DYNNR.        *
*       Außerdem wird ggf. der Cursor auf dem Dynpro initial positio-  *
*       niert. Auswahlknöpfe werden ebenfalls initialisiert.           *
*----------------------------------------------------------------------*
* GLOB: <-> RADIO_*    Auswahlknöpfe
*       --> TBTCJOB    Periodenwerte
*----------------------------------------------------------------------*
FORM set_title_and_status.

  CASE sy-dynnr.               "SY-DYNNR holds the current dynpro no.

    WHEN 100.
      SET TITLEBAR 'VLS' WITH workarea_name.
      SET PF-STATUS 'PARAMS'.

    WHEN 200.
      SET TITLEBAR 'VSD' WITH title_100.
      SET PF-STATUS 'STARTDAT'.
      SET CURSOR FIELD 'TBTCJOB-STRTDATE'.

    WHEN 201.
      SET TITLEBAR 'VPD'.
      SET PF-STATUS 'PERIOD'.
      CLEAR: radio_months, radio_weeks, radio_days, radio_hours,
             radio_minutes.
      IF NOT tbtcjob-prdmonths IS INITIAL.
        SET CURSOR FIELD 'TBTCJOB-PRDMONTHS'.
        radio_months = 'X'.
      ELSEIF NOT tbtcjob-prdweeks IS INITIAL.
        SET CURSOR FIELD 'TBTCJOB-PRDWEEKS'.
        radio_weeks = 'X'.
      ELSEIF NOT tbtcjob-prddays IS INITIAL.
        SET CURSOR FIELD 'TBTCJOB-PRDDAYS'.
        radio_days = 'X'.
      ELSEIF NOT tbtcjob-prdhours IS INITIAL.
        SET CURSOR FIELD 'TBTCJOB-PRDHOURS'.
        radio_hours = 'X'.
      ELSEIF NOT tbtcjob-prdmins IS INITIAL.
        SET CURSOR FIELD 'TBTCJOB-PRDMINS'.
        radio_minutes = 'X'.
      ELSE.
        radio_months = 'X'.
      ENDIF.

    WHEN 400.
      SET TITLEBAR 'VJL' WITH workarea_name.
      SET PF-STATUS 'JOBLIST'.

    WHEN 500.
      SET TITLEBAR 'VJC' WITH title_100.
      SET PF-STATUS 'CHANGE'.

  ENDCASE.

ENDFORM.                               " SET_TITLE_AND_STATUS

*&---------------------------------------------------------------------*
*&      Form  SORT_VJOBLIST
*&---------------------------------------------------------------------*
*       Sortiert die Jobliste nach einer ausgewählten Spalte oder      *
*       defaultmäßig nach Datum und Status.                            *
*----------------------------------------------------------------------*
*  -->  FIELDNAME   Feldname der ausgewählten Spalte oder SPACE, falls
*                   keine Spalte ausgewählt wurde.
* GLOB: VJOBLIST    Zu sortierende Tabelle, wird ggf. umsortiert.
*----------------------------------------------------------------------*
FORM sort_vjoblist
     USING fieldname LIKE sorting_field.

  CASE fieldname.

    WHEN space.
      SORT vjoblist DESCENDING BY sdlstrtdt sdlstrttm status.

    WHEN 'STATUS_TEXT'.
      SORT vjoblist DESCENDING
           BY status ASCENDING sdlstrtdt sdlstrttm.

    WHEN 'VJOBLIST-SDLUNAME'.
      SORT vjoblist DESCENDING
           BY sdluname ASCENDING sdlstrtdt sdlstrttm status.

    WHEN 'VJOBLIST-VTEXT'.
      SORT vjoblist DESCENDING
           BY vtext ASCENDING sdlstrtdt sdlstrttm status.
  ENDCASE.

ENDFORM.                    " SORT_VJOBLIST
