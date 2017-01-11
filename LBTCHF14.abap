***INCLUDE LBTCHF14 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOBLIST_PROCESSOR           *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM SORT_JOBLIST                                              *
*---------------------------------------------------------------------*
* Sortieren der globalen Tabelle JOBLIST entsprechend dem             *
* aktiven (vom Anwender eingestellten) Sortierkriterium (in globaler  *
* Variablen JOBLIST_SORT_CRITERIA)                                    *
*---------------------------------------------------------------------*
TYPE-POOLS: sp01r.

*&---------------------------------------------------------------------*
*&      Form  SORT_JOBLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sort_joblist.

  CASE joblist_sort_criteria.
    WHEN btc_alphabetical.
      SORT joblist BY jobname   ASCENDING
                      sdlstrtdt DESCENDING
                      sdlstrttm DESCENDING
                      strtdate  DESCENDING
                      strttime  DESCENDING.
    WHEN btc_chronological.
      SORT joblist BY prednum   DESCENDING
                      eventid   DESCENDING
                      sdlstrtdt DESCENDING
                      sdlstrttm DESCENDING
                      strtdate  DESCENDING
                      strttime  DESCENDING
                      jobname   ASCENDING.
    WHEN btc_jobsbyclass.
      SORT joblist ASCENDING BY jobclass jobname.
    WHEN btc_jobsbyclient.
      SORT joblist ASCENDING BY authckman jobname.
    WHEN btc_jobsbytgtsys.
      SORT joblist ASCENDING BY btcsystem jobname.
    WHEN btc_jobsbyexecsys.
      SORT joblist ASCENDING BY btcsysreax jobname.
    WHEN OTHERS. " sollte nicht vorkommen
      SORT joblist BY jobname   ASCENDING
                      sdlstrtdt DESCENDING
                      sdlstrttm DESCENDING
                      strtdate  DESCENDING
                      strttime  DESCENDING
                      prednum   ASCENDING
                      eventid   ASCENDING.
  ENDCASE.

ENDFORM. " SORT_JOBLIST.

*---------------------------------------------------------------------*
*      FORM CHECK_FOR_NEW_HEADER                                      *
*---------------------------------------------------------------------*
* Prüfen, ob abhängig vom aktiven Sortierkriterium (globale Variable  *
* JOBLIST_SORT_CRITERIA) eine neue Ueberschrift ausgegeben werden muß.*
* Beachte: Nach NEW-PAGE wird TOP-OF-PAGE angesprungen                *
*---------------------------------------------------------------------*
FORM check_for_new_header USING jobhead STRUCTURE tbtcjob
                                last_date_processed
                                last_time_processed
                                first_job_with_predjob
                                first_job_with_event
                                first_job_without_stdt
                                first_job_alphabetical
                                last_jobclass_processed
                                last_client_processed
                                last_tgtsys_processed
                                prev_lst_grp_exists
                                last_xsys_processed.
  DATA: last_hour(2),
        time_dummy LIKE global_job-sdlstrttm,
        new_header_necessary LIKE true.

  DATA: BEGIN OF stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF stdt.

  new_header_necessary = false.
  CLEAR joblist_header.

  IF joblist_sort_criteria EQ btc_alphabetical.
    IF first_job_alphabetical EQ true.
      NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
      new_header_necessary   = true.
      first_job_alphabetical = false.
    ENDIF.
  ELSEIF joblist_sort_criteria EQ btc_chronological.
    PERFORM extract_stdt_from_jobhead USING jobhead stdt.
    IF stdt-startdttyp EQ btc_stdt_datetime OR
       stdt-startdttyp EQ btc_stdt_onworkday.
      time_dummy = last_time_processed.
      last_hour  = time_dummy(2).
      IF jobhead-sdlstrtdt    NE last_date_processed OR
         jobhead-sdlstrttm(2) NE last_hour.
        PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
        time_dummy = jobhead-sdlstrttm(2).
        NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
        WRITE text-177 TO joblist_header.
        offset = strlen( joblist_header ) + 1.
        WRITE jobhead-sdlstrtdt TO joblist_header+offset.
        offset = strlen( joblist_header ) + 1.
        WRITE text-178 TO joblist_header+offset.
        offset = strlen( joblist_header ) + 1.
        WRITE time_dummy TO joblist_header+offset(8).
        offset = strlen( joblist_header ) + 1.
        WRITE text-179 TO joblist_header+offset.
        offset = strlen( joblist_header ) + 1.
        time_dummy = time_dummy + 59_min.
        WRITE time_dummy TO joblist_header+offset(8).
        last_date_processed  = jobhead-sdlstrtdt.
        last_time_processed  = jobhead-sdlstrttm.
        new_header_necessary = true.
      ENDIF.
    ELSEIF stdt-startdttyp EQ btc_stdt_event.
      IF first_job_with_event EQ true.
        PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
        NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
        WRITE text-181 TO joblist_header.
        new_header_necessary = true.
        first_job_with_event = false.
      ENDIF.
    ELSEIF stdt-startdttyp EQ btc_stdt_afterjob.
      IF first_job_with_predjob EQ true.
        PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
        NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
        WRITE text-180 TO joblist_header.
        new_header_necessary   = true.
        first_job_with_predjob = false.
      ENDIF.
    ELSE.
      IF first_job_without_stdt EQ true.
        PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
        NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
        WRITE text-182 TO joblist_header.
        new_header_necessary   = true.
        first_job_without_stdt = false.
      ENDIF.
    ENDIF.
  ELSEIF joblist_sort_criteria EQ btc_jobsbyclass.
    IF jobhead-jobclass NE last_jobclass_processed.
      PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
      NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
      IF jobhead-jobclass EQ space.
        WRITE text-184 TO joblist_header.
      ELSE.
        WRITE text-183 TO joblist_header.
        offset = strlen( joblist_header ) + 1.
        WRITE jobhead-jobclass TO joblist_header+offset.
      ENDIF.
      last_jobclass_processed = jobhead-jobclass.
      new_header_necessary    = true.
    ENDIF.
  ELSEIF joblist_sort_criteria EQ btc_jobsbyclient.
    IF jobhead-authckman NE last_client_processed.
      PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
      NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
      WRITE text-185 TO joblist_header.
      offset = strlen( joblist_header ) + 1.
      WRITE jobhead-authckman TO joblist_header+offset.
      last_client_processed = jobhead-authckman.
      new_header_necessary  = true.
    ENDIF.
  ELSEIF joblist_sort_criteria EQ btc_jobsbytgtsys.
    IF jobhead-btcsystem NE last_tgtsys_processed.
      PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
      NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
      IF jobhead-btcsystem EQ space.
        WRITE text-236 TO joblist_header.
      ELSE.
        WRITE text-235 TO joblist_header.
        offset = strlen( joblist_header ) + 1.
        WRITE jobhead-btcsystem TO joblist_header+offset.
      ENDIF.
      last_tgtsys_processed = jobhead-btcsystem.
      new_header_necessary  = true.
    ENDIF.
  ELSEIF joblist_sort_criteria EQ btc_jobsbyexecsys.
    IF jobhead-btcsysreax NE last_xsys_processed.
      PERFORM close_prev_lst_grp USING prev_lst_grp_exists.
      NEW-PAGE NO-TITLE NO-HEADING LINE-SIZE joblist_width.
      IF jobhead-btcsysreax EQ space.
        WRITE text-241 TO joblist_header.
      ELSE.
        WRITE text-242 TO joblist_header.
        offset = strlen( joblist_header ) + 1.
        WRITE jobhead-btcsysreax TO joblist_header+offset.
      ENDIF.
      last_xsys_processed  = jobhead-btcsysreax.
      new_header_necessary = true.
    ENDIF.
  ENDIF.
*
* falls eine sortierkriteriumspezifische Ueberschrift ausgegeben wurde,
* dann muß jetzt der allgemeingültige Header mit Jobname und Status-
* feldern ausgegeben werden (mit TOP-OF-PAGE-Verarbeitung)
*
  IF new_header_necessary EQ true.
    WRITE: 'X'. " --> Damit TOP-OF-PAGE-Verarbeitung angesprungen wird
  ENDIF.

ENDFORM. " CHECK_FOR_NEW_HEADER

*---------------------------------------------------------------------*
*      FORM CLOSE_PREV_LST_GRP                                        *
*---------------------------------------------------------------------*
* Aufgabe dieser Routine ist es im Rahmen der Ausgabe der Jobliste    *
* dafür zu sorgen, daß bei 'Gruppenwechseln' von logischen List-      *
* gruppen eine evtl. vorausgehende Listgruppe mit ULINE abgeschlossen *
* wird. Der Parameter PREV_LST_GRP_EXISTS gibt an, ob eine voraus-    *
* gehende Listgruppe auf dem Bildschirm existiert.                    *
*---------------------------------------------------------------------*
FORM close_prev_lst_grp USING prev_lst_grp_exists.

  IF prev_lst_grp_exists EQ true.
    CLEAR valid_row_selected.
    CLEAR jobname_selected.
    CLEAR jobcount_selected.
    CLEAR list_row_index.

    ULINE.
    HIDE: valid_row_selected, jobname_selected, jobcount_selected,
          list_row_index.
  ELSE.
    prev_lst_grp_exists = true.
  ENDIF.

ENDFORM. " CLOSE_PREV_LST_GRP

*---------------------------------------------------------------------*
*      FORM CHANGE_JOB_STATUS                                         *
*---------------------------------------------------------------------*
* Status eines Jobs ändern ('eingeplant' <--> 'freigegeben') oder     *
* Status eines Blocks von Jobs ändern.                                *
* Der Parameter HOW gibt an, auf welchen Status der Job geändert     .*
* werden soll. Der entsprechende Job wird durch die globale Variable  *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*
FORM change_job_status USING how.

  DATA: stdt_modify_flag LIKE btch0000-int4.

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF old_steplist OCCURS 0. " Dummy
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.

  DATA: BEGIN OF new_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF new_stdt.

  IF block_marking_is_active EQ true.
*
*    prüfen, ob eine "offene" (nicht beendete) Blockmarkierung vorliegt
*
    IF block_starts_at_row NE 0 AND
       block_ends_at_row   EQ 0.
      MESSAGE e163.
    ENDIF.
*
*    falls Jobs freigegeben werden sollen: Starttermin für alle mar-
*    kierten Jobs vom Benutzer erfragen
*
    IF how EQ btc_release_job.
      CALL FUNCTION 'BP_START_DATE_EDITOR'
        EXPORTING
          stdt_dialog      = btc_yes
          stdt_opcode      = btc_edit_startdate
          stdt_input       = new_stdt
        IMPORTING
          stdt_output      = new_stdt
          stdt_modify_type = stdt_modify_flag
        EXCEPTIONS
          OTHERS           = 99.

      IF sy-subrc NE 0 OR
         stdt_modify_flag EQ btc_stdt_not_modified.
        PERFORM init_joblist_block_proc.
        EXIT.
      ENDIF.
    ENDIF.
*
*    jetzt alle markierten Jobs freigeben / zurücknehmen
*
    LOOP AT joblist.
      IF joblist-newflag EQ 'X'.
        jobname_selected = joblist-jobname.

        IF how EQ btc_release_job.
          CALL FUNCTION 'BP_JOB_READ'
            EXPORTING
              job_read_jobname  = joblist-jobname
              job_read_jobcount = joblist-jobcount
              job_read_opcode   = btc_read_jobhead_only
            IMPORTING
              job_read_jobhead  = old_jobhead
            TABLES
              job_read_steplist = old_steplist
            EXCEPTIONS
              job_doesnt_exist  = 1
              OTHERS            = 99.

          CASE sy-subrc.
            WHEN 0.
              " Lesen hat geklappt
            WHEN 1.
              PERFORM init_joblist_block_proc.
              MESSAGE e127 WITH jobname_selected.
            WHEN OTHERS.
              PERFORM init_joblist_block_proc.
              MESSAGE e155 WITH jobname_selected.
          ENDCASE.
        ENDIF.

        CALL FUNCTION 'BP_JOB_MODIFY'
          EXPORTING
            jobname              = joblist-jobname
            jobcount             = joblist-jobcount
            dialog               = btc_no
            opcode               = how
            release_stdt         = new_stdt
            release_targetsystem = old_jobhead-btcsystem
          IMPORTING
            modified_jobhead     = joblist
          TABLES
            new_steplist         = global_step_tbl " Dummy
          EXCEPTIONS
            nothing_to_do        = 1
            OTHERS               = 99.

        IF sy-subrc EQ 0.
          MODIFY joblist.
          IF sy-subrc NE 0.
            PERFORM init_joblist_block_proc.
            MESSAGE e154.
          ENDIF.
        ELSEIF sy-subrc EQ 1.
          " nichts tun
        ELSE.
          PERFORM init_joblist_block_proc.
          MESSAGE e268 WITH jobname_selected.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM init_joblist_block_proc.
  ELSE.
*
*    es soll lediglich ein einziger Job freigegeben / zurückgenommen
*    werden
*
    IF valid_row_selected NE 'X'.
      MESSAGE e019.
    ENDIF.

    IF how EQ btc_release_job.
*
*       Jobkopfdaten lesen um den Zielrechner zu ermitteln
*
      CALL FUNCTION 'BP_JOB_READ'
        EXPORTING
          job_read_jobname  = jobname_selected
          job_read_jobcount = jobcount_selected
          job_read_opcode   = btc_read_jobhead_only
        IMPORTING
          job_read_jobhead  = old_jobhead
        TABLES
          job_read_steplist = old_steplist
        EXCEPTIONS
          job_doesnt_exist  = 1
          OTHERS            = 99.

      CASE sy-subrc.
        WHEN 0.
          " Lesen hat geklappt
        WHEN 1.
          MESSAGE e127 WITH jobname_selected.
        WHEN OTHERS.
          MESSAGE e155 WITH jobname_selected.
      ENDCASE.
    ENDIF.

    CALL FUNCTION 'BP_JOB_MODIFY'
      EXPORTING
        jobname              = jobname_selected
        jobcount             = jobcount_selected
        dialog               = btc_yes
        opcode               = how
        release_targetsystem = old_jobhead-btcsystem
      IMPORTING
        modified_jobhead     = joblist
      TABLES
        new_steplist         = global_step_tbl
      EXCEPTIONS
        nothing_to_do        = 1
        OTHERS               = 99.

    IF sy-subrc EQ 0.
      MODIFY joblist INDEX list_row_index.
      IF sy-subrc NE 0.
        MESSAGE e154.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM. " CHANGE_JOB_STATUS

*---------------------------------------------------------------------*
*      FORM REPEAT_JOB_DEFINITION                                     *
*---------------------------------------------------------------------*
* Definition eines Jobs wiederholen. Der Job, dessen Definition       *
* wiederholt werden soll, wird durch die globale Variable             *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM repeat_job_definition.

  DATA: rc TYPE i VALUE 0,
        stdt_modify_flag LIKE btch0000-int4.

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF new_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF new_stdt.

  DATA: BEGIN OF old_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.
*
* prüfen, ob Benutzer berechtigt ist, Jobs einzuplanen
*
  PERFORM check_job_plan_privilege USING rc.

  IF rc NE 0.
    MESSAGE e266.
  ENDIF.
*
* Jobdaten aus Datenbank lesen und prüfen, ob Operation zulässig ist
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname_selected
      job_read_jobcount = jobcount_selected
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = old_jobhead
    TABLES
      job_read_steplist = old_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist die Einplanung des Jobs zu wiederh.
*
  PERFORM check_operation_privilege USING old_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e193.
  ENDIF.

  IF old_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname_selected.
  ENDIF.
*
* Starttermindaten extrahieren, Starttermineditor aufrufen und an-
* schliessend die neuen Starttermindaten in den Jobkopfdaten speichern
*
  PERFORM extract_stdt_from_jobhead USING old_jobhead new_stdt.

  CALL FUNCTION 'BP_START_DATE_EDITOR'
    EXPORTING
      stdt_dialog      = btc_yes
      stdt_opcode      = btc_edit_startdate
      stdt_input       = new_stdt
    IMPORTING
      stdt_output      = new_stdt
      stdt_modify_type = stdt_modify_flag
    EXCEPTIONS
      OTHERS           = 99.

  IF sy-subrc NE 0 OR
     stdt_modify_flag EQ btc_stdt_not_modified.
    EXIT.
  ENDIF.

  PERFORM store_stdt_in_jobhead USING old_jobhead
                                      new_stdt
                                      btc_no
                                      rc.
  IF rc NE 0.
    MESSAGE e158 WITH jobname_selected.
  ENDIF.
*
* neuen Job erzeugen
*
  CALL FUNCTION 'BP_JOB_CREATE'
    EXPORTING
      job_cr_dialog   = btc_no
      job_cr_head_inp = old_jobhead
    IMPORTING
      job_cr_head_out = old_jobhead
    TABLES
      job_cr_steplist = old_steplist
    EXCEPTIONS
      OTHERS          = 99.

  IF sy-subrc EQ 0.
    CLEAR joblist.
    joblist = old_jobhead.

    APPEND joblist.

    MESSAGE s156 WITH jobname_selected.
  ELSE.
    MESSAGE e157 WITH jobname_selected.
  ENDIF.

ENDFORM. " REPEAT_JOB_DEFINITION.

*---------------------------------------------------------------------*
*      FORM COPY_JOB                                                  *
*---------------------------------------------------------------------*
* Job kopieren. Der zu kopierende Job wird durch die globale Variable *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM copy_job.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  CALL FUNCTION 'BP_JOB_COPY'
    EXPORTING
      dialog            = btc_yes
      source_jobname    = jobname_selected
      source_jobcount   = jobcount_selected
    IMPORTING
      new_jobhead       = joblist
    EXCEPTIONS
      job_copy_canceled = 1
      OTHERS            = 99.

  IF sy-subrc EQ 0.
    APPEND joblist.
  ENDIF.

ENDFORM. " COPY_JOB.

*---------------------------------------------------------------------*
*      FORM MOVE_JOB                                                  *
*---------------------------------------------------------------------*
* Job umziehen. Der umzuziehende Job wird durch die globale Variable  *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM move_job.

  IF block_marking_is_active EQ true.
*
*    prüfen, ob eine "offene" (nicht beendete) Blockmarkierung vorliegt
*
    IF block_starts_at_row NE 0 AND
       block_ends_at_row   EQ 0.
      MESSAGE e163.
    ENDIF.
*
*    Name des neuen Zielrechners vom Anwender erfragen
*
    CLEAR btch1270.

    CALL SCREEN 1270 STARTING AT 10 5
                     ENDING   AT 65 7.

    IF okcode EQ 'CAN'. " falls Benutzer das 'Umziehen' abbrechen will
      EXIT.
    ENDIF.
*
*    jetzt alle markierten Jobs 'umziehen' auf neuen Zielrechner
*
    LOOP AT joblist.
      IF joblist-newflag EQ 'X'.
        CALL FUNCTION 'BP_JOB_MOVE'
          EXPORTING
            jobname           = joblist-jobname
            jobcount          = joblist-jobcount
            dialog            = btc_yes
            new_target_system = btch1270-newtgtsrv
            new_target_group  = btch1270-newtgtgrp
          EXCEPTIONS
            OTHERS            = 99.

        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM init_joblist_block_proc.
  ELSE.
*
*    es soll lediglich ein einziger Job umgezogen werden
*
    IF valid_row_selected NE 'X'.
      MESSAGE e019.
    ENDIF.
*
*    Name des neuen Zielrechners vom Anwender erfragen, Job umziehen
*
    CLEAR btch1270.

    CALL SCREEN 1270 STARTING AT 10 5
                     ENDING   AT 65 7.

    IF okcode EQ 'CAN'. " falls Benutzer das 'Umziehen' abbrechen will
      EXIT.
    ENDIF.

    CALL FUNCTION 'BP_JOB_MOVE'
      EXPORTING
        jobname           = jobname_selected
        jobcount          = jobcount_selected
        dialog            = btc_yes
        new_target_system = btch1270-newtgtsrv
        new_target_group  = btch1270-newtgtgrp
      EXCEPTIONS
        OTHERS            = 99.
  ENDIF.

ENDFORM. " MOVE_JOB

*---------------------------------------------------------------------*
*      FORM REFRESH_JOBLIST                                           *
*---------------------------------------------------------------------*
* Jobinformationen gemäß der vom Benutzer vorgegebenen Selektions-    *
* kriterien erneut von der Datenbank lesen (Jobliste aktualisieren)   *
*---------------------------------------------------------------------*

FORM refresh_joblist.

  IF joblist_refr_param EQ space.  " falls keine Selektionsparameter
    MESSAGE e197.                 " zum Auffrischen der Liste vorliegen
  ENDIF.

  CALL FUNCTION 'BP_JOB_SELECT'
    EXPORTING
      jobsel_param_in   = joblist_refr_param
      jobselect_dialog  = btc_no
    TABLES
      jobselect_joblist = joblist
    EXCEPTIONS
      OTHERS            = 99.

  IF sy-subrc EQ 0.
    joblist_sort_necessary = true.
  ENDIF.

ENDFORM. " REFRESH_JOBLIST.

*---------------------------------------------------------------------*
*      FORM DELETE_JOB                                                *
*---------------------------------------------------------------------*
* Job(s) löschen. Abhängig von der globalen Variablen                 *
* BLOCK_MARKING_IS_ACTIVE wird entschieden, ob ein ganzer Block von   *
* Jobs oder nur ein einzelner Jobs zu löschen ist. Beim Löschen nur   *
* eines Jobs gilt: Der zu löschende Job wird durch die globale Vari-  *
* able LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und    *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM delete_job.

  DATA: rc TYPE i,
        help_text(80).

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF old_steplist OCCURS 0. " Dummy
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.

  DATA: question_text TYPE string.

  IF block_marking_is_active EQ true.
*
*    prüfen, ob eine "offene" (nicht beendete) Blockmarkierung vorliegt
*    und Sicherheitsabfrage vornehmen
*
    IF block_starts_at_row NE 0 AND
       block_ends_at_row   EQ 0.
      MESSAGE e163.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = text-190
        text_question  = text-193
        default_button = '2'
      IMPORTING
        answer         = popup_answer
      EXCEPTIONS
        OTHERS         = 99.

    IF popup_answer <> '1'.
      EXIT.
    ENDIF.
*
*    alle markierten Jobs löschen (Jobs mit NEWFLAG = 'X') und an-
*    schließend Blockverarbeitung neu initialisieren. Falls ein zu
*    löschender Job Vorgänger hat, so wird deren Freigabe zurück-
*    genommen. Um dies herauszufinden lesen wir den Job vorsichtshalber
*    noch einmal von der Datenbank, um sicher zu gehen, daß wir die
*    aktuelle Anzahl Nachfolgerjobs bekommen
*
    LOOP AT joblist.
      IF joblist-newflag EQ 'X'.
        CALL FUNCTION 'BP_JOB_READ'
          EXPORTING
            job_read_jobname  = joblist-jobname
            job_read_jobcount = joblist-jobcount
            job_read_opcode   = btc_read_jobhead_only
          IMPORTING
            job_read_jobhead  = old_jobhead
          TABLES
            job_read_steplist = old_steplist
          EXCEPTIONS
            OTHERS            = 99.

        IF sy-subrc EQ 0.
          IF old_jobhead-succnum > 0.
            PERFORM derelease_successors USING old_jobhead-jobname
                                               old_jobhead-jobcount
                                               rc.
            IF rc NE 0.
              EXIT. " Fehlermeldung wird von Routine ausgegeben
            ENDIF.
          ENDIF.

          CALL FUNCTION 'BP_JOB_DELETE'
            EXPORTING
              jobname    = old_jobhead-jobname
              jobcount   = old_jobhead-jobcount
              forcedmode = 'X'
            EXCEPTIONS
              OTHERS     = 99.

          IF sy-subrc EQ 0.
            DELETE joblist.

            IF sy-subrc NE 0.
              MESSAGE s161.
              EXIT.
            ENDIF.
          ELSE.
            EXIT. " BP_JOB_DELETE gibt selbst Fehlermeldung aus.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM init_joblist_block_proc.
  ELSE. " nur ein Job ist zu löschen
    IF valid_row_selected NE 'X'.
      MESSAGE e019.
    ENDIF.

    CALL FUNCTION 'BP_JOB_READ'
      EXPORTING
        job_read_jobname  = jobname_selected
        job_read_jobcount = jobcount_selected
        job_read_opcode   = btc_read_jobhead_only
      IMPORTING
        job_read_jobhead  = old_jobhead
      TABLES
        job_read_steplist = old_steplist
      EXCEPTIONS
        job_doesnt_exist  = 1
        OTHERS            = 99.

    CASE sy-subrc.
      WHEN 0.
        " Lesen hat geklappt
      WHEN 1.
        MESSAGE e127 WITH jobname_selected.
      WHEN OTHERS.
        MESSAGE e155 WITH jobname_selected.
    ENDCASE.

    IF old_jobhead-succnum > 0.
      help_text = text-237.
    ELSE.
      help_text = space.
    ENDIF.

    CONCATENATE text-189 jobname_selected help_text INTO question_text
    SEPARATED BY space.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = text-190
        text_question  = question_text
        default_button = '2'
      IMPORTING
        answer         = popup_answer
      EXCEPTIONS
        OTHERS         = 99.

    IF popup_answer <> '1'.
      EXIT.
    ENDIF.

    IF old_jobhead-succnum > 0.
      PERFORM derelease_successors USING old_jobhead-jobname
                                         old_jobhead-jobcount
                                         rc.
      IF rc NE 0.
        EXIT. " Fehlermeldung wird von Routine ausgegeben
      ENDIF.
    ENDIF.

    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        jobname    = old_jobhead-jobname
        jobcount   = old_jobhead-jobcount
        forcedmode = 'X'
      EXCEPTIONS
        OTHERS     = 99.

    IF sy-subrc EQ 0.
      DELETE joblist INDEX list_row_index.

      IF sy-subrc NE 0.
        MESSAGE e161.
      ENDIF.

      MESSAGE s162 WITH old_jobhead-jobname.
    ENDIF.
  ENDIF.

ENDFORM. " DELETE_JOB.

*---------------------------------------------------------------------*
*      FORM EDIT_JOB                                                  *
*---------------------------------------------------------------------*
* Job editieren. Der zu Job wird durch die globale Variable           *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*
FORM edit_job.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      jobname          = jobname_selected
      jobcount         = jobcount_selected
      dialog           = btc_yes
      opcode           = btc_modify_whole_job
    IMPORTING
      modified_jobhead = joblist
    TABLES
      new_steplist     = global_step_tbl  " Dummy
    EXCEPTIONS
      OTHERS           = 99.

  IF sy-subrc EQ 0.
    MODIFY joblist INDEX list_row_index.

    IF sy-subrc NE 0.
      MESSAGE e154.
    ENDIF.
  ENDIF.

ENDFORM. " EDIT_JOB

*---------------------------------------------------------------------*
*      FORM DEBUG_JOB                                                 *
*---------------------------------------------------------------------*
* Job debuggen. Der zu debuggende Job wird durch die globale Variable *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
* (Jobablauf wird im Debugger simuliert)                              *
*---------------------------------------------------------------------*
FORM debug_job.

  DATA: rc TYPE i,
        switch_btc_dbg_on  TYPE i VALUE 1,
        switch_btc_dbg_off TYPE i VALUE 0,
        debugging_possible LIKE true.

  DATA: BEGIN OF dbg_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF dbg_jobhead.

  DATA: BEGIN OF dbg_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF dbg_steplist.

  DATA: BEGIN OF packed_print_params.
          INCLUDE STRUCTURE pri_params.
  DATA: END OF packed_print_params.

  DATA: BEGIN OF packed_arc_params.
          INCLUDE STRUCTURE arc_params.
  DATA: END OF packed_arc_params.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname_selected
      job_read_jobcount = jobcount_selected
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = dbg_jobhead
    TABLES
      job_read_steplist = dbg_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist den Job zu debuggen
*
  PERFORM check_operation_privilege USING dbg_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e195.
  ENDIF.
*
* Debuggen ist nur möglich, wenn
*
*  a) die Jobdefinition abgeschlossen ist
*  b) der Job keine externen Programme enthält
*  c) der Job nicht aktiv ist
*
  IF dbg_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname_selected.
  ENDIF.

  debugging_possible = true.

  LOOP AT dbg_steplist.
    IF dbg_steplist-typ EQ btc_xpg.
      debugging_possible = false.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF debugging_possible EQ false.
    MESSAGE e183 WITH jobname_selected.
  ENDIF.

  IF dbg_jobhead-status EQ btc_ready OR
     dbg_jobhead-status EQ btc_running.
    MESSAGE e185 WITH jobname_selected.
  ENDIF.
*
* jetzt die Reports der einzelnen Jobsteps im Debugmodus aufrufen:
*
  LOOP AT dbg_steplist.
    MOVE-CORRESPONDING dbg_steplist TO packed_print_params.
    MOVE-CORRESPONDING dbg_steplist TO packed_arc_params.

    CALL 'BatchDebugging' ID 'FLAG' FIELD switch_btc_dbg_on.
    sy-debug = 'Y'.                                       "#EC WRITE_OK

    SUBMIT (dbg_steplist-program)
      TO SAP-SPOOL WITHOUT SPOOL DYNPRO
*      USER DBG_STEPLIST-AUTHCKNAM
      USING SELECTION-SET dbg_steplist-parameter
      SPOOL PARAMETERS packed_print_params
      ARCHIVE PARAMETERS packed_arc_params
      AND RETURN.

    sy-debug = 'N'.                                       "#EC WRITE_OK
    CALL 'BatchDebugging' ID 'FLAG' FIELD switch_btc_dbg_off.
  ENDLOOP.


ENDFORM. " DEBUG_JOB

*---------------------------------------------------------------------*
*      FORM DEBUG_ACTIVE_JOB                                          *
*---------------------------------------------------------------------*
* Aktiven Job debuggen. Der zu debuggene Job wird durch die globale   *
* Variable LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und*
* JOBCOUNT_SELECTED identifiziert.                                    *
*                                                                     *
* Mit dieser Funktion ist es möglich, einen aktiven Job im Debugger   *
* 'einzufangen' und zu analysieren.                                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM debug_active_job.

  DATA: wp_no LIKE wpinfo-wp_index,
        subrc LIKE sy-subrc,
        rc TYPE i.

  DATA: BEGIN OF act_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF act_jobhead.

  DATA: BEGIN OF act_steplist OCCURS 0. " Dummy, wird nur wegen FB-Auf-
          INCLUDE STRUCTURE tbtcstep.         " ruf BP_JOB_READ gebraucht
  DATA: END OF act_steplist.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname_selected
      job_read_jobcount = jobcount_selected
      job_read_opcode   = btc_read_jobhead_only
    IMPORTING
      job_read_jobhead  = act_jobhead
    TABLES
      job_read_steplist = act_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist den Job 'einzufangen'
*
  PERFORM check_operation_privilege USING act_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e196.
  ENDIF.
*
* Debuggen ist nur möglich, wenn
*
*  a) der Job aktiv ist
*  b) der Benutzer auf dem Rechner angemeldet ist, auf dem der Job
*     läuft
*
  IF act_jobhead-status NE btc_running.
    MESSAGE e186 WITH jobname_selected.
  ENDIF.

  IF act_jobhead-btcsysreax NE sy-host.
    MESSAGE e187 WITH jobname_selected act_jobhead-btcsysreax.
  ENDIF.

  wp_no = act_jobhead-wpnumber.

  CALL FUNCTION 'TH_DEBUG_WP'
    EXPORTING
      wp_index        = wp_no
    IMPORTING
      subrc        = subrc
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 99.

  CASE sy-subrc.
    WHEN 0.
      " ok, Debuggen hat funktioniert
    WHEN 1.
      MESSAGE e192.
    WHEN OTHERS.
      MESSAGE e188 WITH jobname_selected.
  ENDCASE.

ENDFORM. " DEBUG_ACTIVE_JOB

*---------------------------------------------------------------------*
*      FORM SHOW_JOB                                                  *
*---------------------------------------------------------------------*
* Job anzeigen. Der anzuzeigende Job wird durch die globale Variable *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*
FORM show_job.

  DATA: rc TYPE i.

  DATA: BEGIN OF jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF jobhead.

  DATA: BEGIN OF job_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF job_steplist.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname_selected
      job_read_jobcount = jobcount_selected
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = jobhead
    TABLES
      job_read_steplist = job_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.

  IF jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname_selected.
  ENDIF.
*
* Anzeigeberechtigung prüfen. Anzeigeberechtigung liegt vor, wenn:
*
*  - der Job vom gerade aktive Benutzer erstellt wurde oder
*  - der Benutzer Batchadministratorberechtigung hat oder
*  - der Benutzer generelle Anzeigeberechtigung für Jobs hat
*
  PERFORM check_operation_privilege USING jobhead-sdluname rc.

  IF rc NE 0.
    PERFORM check_job_show_privilege USING rc.
    IF rc NE 0.
      MESSAGE e251 WITH jobhead-jobname.
    ENDIF.
  ENDIF.
*
* Jobdaten anzeigen
*
  CALL FUNCTION 'BP_JOB_EDITOR'
    EXPORTING
      job_editor_dialog = btc_yes
      job_editor_opcode = btc_show_job
      job_head_input    = jobhead
    TABLES
      job_steplist      = job_steplist
    EXCEPTIONS
      OTHERS            = 99.

ENDFORM. " SHOW_JOB

*---------------------------------------------------------------------*
*      FORM INIT_JOBLIST_BLOCK_PROC                                   *
*---------------------------------------------------------------------*
* Variablen und Joblisteninformation für die Blockverarbeitung initi-*
* alisieren.                                                          *
*---------------------------------------------------------------------*
FORM init_joblist_block_proc.

  block_marking_is_active = false.
  block_starts_at_row     = 0.
  block_ends_at_row       = 0.

  LOOP AT joblist.
    joblist-newflag = space.

    MODIFY joblist.

    IF sy-subrc NE 0.
      MESSAGE e154.
    ENDIF.
  ENDLOOP.

ENDFORM. " INIT_JOBLIST_BLOCK_PROC.

*---------------------------------------------------------------------*
*      FORM MARK_BLOCK_OF_JOBS                                        *
*---------------------------------------------------------------------*
* Markieren von Jobs durchführen.                                     *
*---------------------------------------------------------------------*

FORM mark_block_of_jobs.

  DATA: tmp TYPE i.

  block_marking_is_active = true.

  IF block_starts_at_row EQ 0.
    block_starts_at_row = list_row_index.

    READ TABLE joblist INDEX block_starts_at_row.

    IF sy-subrc NE 0.
      MESSAGE e153.
    ENDIF.

    joblist-newflag = 'X'.

    MODIFY joblist INDEX block_starts_at_row.

    IF sy-subrc NE 0.
      MESSAGE e154.
    ENDIF.
  ELSE.
    block_ends_at_row = list_row_index.
    IF block_ends_at_row < block_starts_at_row.
      tmp = block_starts_at_row.
      block_starts_at_row = block_ends_at_row.
      block_ends_at_row   = tmp.
    ENDIF.

    tmp = ( block_ends_at_row - block_starts_at_row ) + 1.

    DO tmp TIMES.
      READ TABLE joblist INDEX block_starts_at_row.

      IF sy-subrc NE 0.
        MESSAGE e153.
      ENDIF.

      joblist-newflag = 'X'.

      MODIFY joblist INDEX block_starts_at_row.

      IF sy-subrc NE 0.
        MESSAGE e154.
      ENDIF.

      block_starts_at_row = block_starts_at_row + 1.
    ENDDO.

    block_starts_at_row = 0.
    block_ends_at_row   = 0.
  ENDIF.

ENDFORM. " MARK_BLOCK_OF_JOBS.

*---------------------------------------------------------------------*
*      FORM SHOW_JOBLOG                                               *
*---------------------------------------------------------------------*
* Joblog eines Jobs anzeigen. Der entsprechende Job wird durch die   *
* globale Variable LIST_ROW_INDEX bzw. die HIDE-Variablen            *
* JOBNAME_SELECTED und JOBCOUNT_SELECTED identifiziert                *
*---------------------------------------------------------------------*

FORM show_joblog.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  CALL FUNCTION 'BP_JOBLOG_SHOW'
    EXPORTING
      jobname  = jobname_selected
      jobcount = jobcount_selected
    EXCEPTIONS
      OTHERS   = 99.

ENDFORM. " SHOW_JOBLOG.

*---------------------------------------------------------------------*
*      FORM ABORT_JOB                                                 *
*---------------------------------------------------------------------*
* Job abbrechen. Der abzubrechende Job wird durch die globale Variable*
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM abort_job.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  CALL FUNCTION 'BP_JOB_ABORT'
    EXPORTING
      jobname  = jobname_selected
      jobcount = jobcount_selected
    EXCEPTIONS
      OTHERS   = 99.

ENDFORM. " ABORT_JOB

*---------------------------------------------------------------------*
*      FORM CHECK_JOBSTATUS                                           *
*---------------------------------------------------------------------*
* Jobstatus prüfen. Der zu prüfende Job wird durch die glob. Variable *
* LIST_ROW_INDEX bzw. die HIDE-Variablen JOBNAME_SELECTED und         *
* JOBCOUNT_SELECTED identifiziert.                                    *
*---------------------------------------------------------------------*

FORM check_jobstatus.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  CALL FUNCTION 'BP_JOB_CHECKSTATE'
    EXPORTING
      dialog   = btc_yes
      jobname  = jobname_selected
      jobcount = jobcount_selected
    EXCEPTIONS
      OTHERS   = 99.

ENDFORM. " CHECK_JOBSTATUS


*---------------------------------------------------------------------*
* FORM       : SHOW_SPOOLREQUEST
* AUTHOR     : Heiko Kiessling
* Date       : 20.02.1997
* PURPOSE    : Show spool request
* PARAMETERS : INPUT : ID: Spool request identification
*---------------------------------------------------------------------*

*DATA: bdc LIKE bdcdata OCCURS 20 WITH HEADER LINE.

FORM show_spoolrequest
  USING id TYPE tbtcstep-listident
        stepcount TYPE tbtcp-stepcount
        i_jobname TYPE tbtcjob-jobname
        i_jobcount TYPE tbtcjob-jobcount.

  DATA: idtab TYPE sp01r_id_list WITH HEADER LINE.

  DATA: local_layout TYPE slis_layout_alv.

* handling of spool lists
  DATA: wa_tsp01 TYPE tsp01.
  DATA: wa_spoolid TYPE tbtc_spoolid.
  DATA: enddate TYPE tbtcjob-enddate.
  DATA: endtime TYPE tbtcjob-endtime.
  DATA: rc TYPE sy-subrc.

  SELECT SINGLE * FROM tsp01 INTO wa_tsp01
         WHERE rqident = id.

  IF sy-subrc > 0.
    MESSAGE e175.
  ENDIF.

  IF stepcount IS INITIAL.
    stepcount = 1.
  ENDIF.

  SELECT SINGLE * FROM tbtc_spoolid INTO wa_spoolid
  WHERE jobname = i_jobname AND
        jobcount = i_jobcount AND
        stepcount = stepcount AND
        spoolid = id.

  IF sy-subrc = 0.
    IF wa_spoolid-recycled IS NOT INITIAL.
      MESSAGE e350 WITH id.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE enddate endtime FROM tbtco
  INTO (enddate, endtime) WHERE jobname  = i_jobname AND
                                jobcount = i_jobcount.
  IF sy-subrc = 0.
    PERFORM compare_timestamps USING wa_tsp01-rqcretime
                                     enddate
                                     endtime
                               CHANGING rc.
    IF rc <> 0.
      CLEAR rc.
      MESSAGE e350 WITH id.
      EXIT.
    ENDIF.
  ENDIF.

  local_layout = gs_layout.

  idtab-id = id.
  idtab-sysid = sy-sysid.
  APPEND idtab.
  CALL FUNCTION 'RSPO_RID_SPOOLREQ_LIST'
    EXPORTING
      id_list = idtab[]
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  gs_layout = local_layout.

*  DATA: spi TYPE i,
*        id2 LIKE sy-spono.
*
*  REFRESH bdc.
*  spi = id. id2 = spi.
*  PERFORM add_data USING '100' 'TSP01-RQIDENT' id2 'X'.
*  PERFORM add_data USING '100' 'TSP01-RQOWNER' space ' '.
*  PERFORM add_data USING '100' 'TSP01-RQCLIENT' space ' '.
*  PERFORM add_data USING '100' 'RSPOTYPE-CREDATE' space ' '.
*  PERFORM add_data USING '100' 'BDC_OKCODE' '/0' ' '.
*  PERFORM add_data USING '120' 'BDC_CURSOR' '04,27' 'X'.
*  PERFORM add_data USING '120' 'BDC_OKCODE' '/02' ' '.
*  CALL TRANSACTION 'SP01' USING bdc MODE 'E'.
ENDFORM. " SHOW_SPOOLREQUEST


*---------------------------------------------------------------------*
* FORM       : SHOW_JOBSTEP_SPOOLREQUESTS
* AUTHOR     : C5035006
* Date       : 09.2007
* PURPOSE    : Show spool request table
* PARAMETERS : INPUT : ID: Spool requests Table
*---------------------------------------------------------------------*
FORM show_jobstep_spoolrequests USING i_header_spoolid TYPE btclistid
                                      i_jobname        TYPE btcjob
                                      i_jobcount       TYPE btcjobcnt
                                      i_stepcount      TYPE int4
                                      i_message_type   TYPE sy-msgty.

  DATA: idtab TYPE STANDARD TABLE OF sp01r_id,
        wa TYPE sp01r_id,
        spoolid TYPE btclistid,
        spool_request TYPE tsp01-rqident,
        wa_tsp01 TYPE tsp01,
        rc TYPE sy-subrc.
  DATA: enddate TYPE tbtcjob-enddate.
  DATA: endtime TYPE tbtcjob-endtime.

  DATA: local_layout TYPE slis_layout_alv.

  local_layout = gs_layout.

* append header spoolid
  IF NOT i_header_spoolid IS INITIAL.
    wa-id = i_header_spoolid.
    wa-sysid = sy-sysid.
    INSERT wa INTO TABLE idtab.
  ENDIF.

* append additional spool's if they are available
  SELECT spoolid FROM tbtc_spoolid INTO spoolid
      WHERE jobname = i_jobname AND
           jobcount = i_jobcount AND
          stepcount = i_stepcount AND
          recycled  NE 'X'.
    CHECK spoolid IS NOT INITIAL.
    wa-id = spoolid.
    wa-sysid = sy-sysid.
    READ TABLE idtab WITH KEY id = wa-id TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      INSERT wa INTO TABLE idtab.
    ENDIF.
  ENDSELECT.

* Check existence
*  SELECT SINGLE * FROM tsp01
*         WHERE rqident = spool_rqid.
*  IF sy-subrc > 0.
*    MESSAGE ID 'BT' TYPE i_message_type NUMBER 175.
*  ENDIF.

  SELECT SINGLE enddate endtime FROM tbtco
  INTO (enddate, endtime) WHERE jobname  = i_jobname AND
                                jobcount = i_jobcount.

  CLEAR wa.

  LOOP AT idtab INTO wa.
    spool_request = wa-id.
    CLEAR rc.
    SELECT SINGLE * FROM tsp01 INTO wa_tsp01 WHERE rqident = spool_request.
    IF sy-subrc <> 0.
      rc = 1.
    ELSE.
      PERFORM compare_timestamps USING wa_tsp01-rqcretime
                                       enddate
                                       endtime
                                 CHANGING rc.
    ENDIF.
    IF rc <> 0.
      DELETE idtab INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  IF idtab IS INITIAL.
    MESSAGE ID 'BT' TYPE i_message_type NUMBER 175.
    EXIT.
  ENDIF.

  CALL FUNCTION 'RSPO_RID_SPOOLREQ_LIST'
    EXPORTING
      id_list = idtab
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  gs_layout = local_layout.

ENDFORM.                    "SHOW_JOBSTEP_SPOOLREQUESTS

*FORM add_data USING dyn nam dta flg.
*  bdc-program = 'RSPOSP01'.
*  bdc-dynpro  = dyn.
*  bdc-dynbegin = flg.
*  bdc-fnam = nam.
*  bdc-fval = dta.
*  APPEND bdc.
*ENDFORM.

*---------------------------------------------------------------------*
*      FORM SHOW_SPOLLIST                                             *
*---------------------------------------------------------------------*
* Spoolliste(n) eines Jobsteps anzeigen:                              *
*                                                                     *
*  - gibt es für den Job nur eine Spoolliste, dann wird diese mittels *
*    Transaktion SP01 dirket angezeigt.                               *
*  - gibt es mehrere Spoollisten (Steps), dann wird in den Steplisten-*
*    editor verzweigt, in der der Anwender den Step auswählen kann    *
*    dessen Liste er sehen will.                                      *
*                                                                     *
* Der Job, wird durch die glob. Variable LIST_ROW_INDEX bzw. die      *
* HIDE-Variablen JOBNAME_SELECTED und JOBCOUNT_SELECTED identifiziert.*
*---------------------------------------------------------------------*

FORM show_spoollist.

*Redirect C5035006
  PERFORM show_spoollist_universal
              USING
                 jobname_selected
                 jobcount_selected
                 'E' .

ENDFORM. " SHOW_SPOOLLIST

*---------------------------------------------------------------------*
*      FORM SHOW_STEPLIST                                             *
*---------------------------------------------------------------------*
* Stepliste eines Jobs anzeigen                                       *
*                                                                     *
* Der Job, wird durch die glob. Variable LIST_ROW_INDEX bzw. die      *
* HIDE-Variablen JOBNAME_SELECTED und JOBCOUNT_SELECTED identifiziert.*
*---------------------------------------------------------------------*

FORM show_steplist.

  DATA: rc TYPE i.

  DATA: BEGIN OF stpl_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF stpl_jobhead.

  DATA: BEGIN OF stpl_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF stpl_steplist.
*
* Jobdaten aus Jobliste und anschliessend aus DB lesen
*
*  READ TABLE JOBLIST INDEX LIST_ROW_INDEX.
*
*  IF SY-SUBRC NE 0.
*     MESSAGE E153.
*  ENDIF.

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname_selected
      job_read_jobcount = jobcount_selected
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = stpl_jobhead
    TABLES
      job_read_steplist = stpl_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist, Stepliste des Jobs anzuzueigen
*
  PERFORM check_operation_privilege USING stpl_jobhead-sdluname rc.

  IF rc NE 0.
    PERFORM check_job_show_privilege USING rc.
    IF rc NE 0.
      MESSAGE e248.
    ENDIF.
  ENDIF.

  IF stpl_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname_selected.
  ENDIF.
*
* Stepliste anzeigen
*
  CALL FUNCTION 'BP_STEPLIST_EDITOR'
    EXPORTING
      steplist_dialog = btc_yes
      steplist_opcode = btc_show_steplist
    TABLES
      steplist        = stpl_steplist
    EXCEPTIONS
      OTHERS          = 99.

ENDFORM. " SHOW_STEPLIST

*---------------------------------------------------------------------*
*      FORM STORE_SELECTED_JOB                                        *
*---------------------------------------------------------------------*
* Ein vom Anwender ausgewählten Job im globalen Schnittstellen-       *
* parameter JOBLIST_SEL_JOB speichern und somit an den Rufer returnen.*
* Der ausgewählte Job wird durch die globale Variable LIST_ROW_INDEX  *
* bzw. die HIDE-Variablen JOBNAME_SELECTED und JOBCOUNT_SELECTED      *
* identifiziert                                                       *
*---------------------------------------------------------------------*

FORM store_selected_job.

  READ TABLE joblist INDEX list_row_index.

  IF sy-subrc NE 0.
    MESSAGE e153.
  ENDIF.

  joblist_sel_job = joblist.

ENDFORM. " STORE_SELECTED_JOB.

*---------------------------------------------------------------------*
*      FORM DERELEASE_SUCCESSORS                                      *
*---------------------------------------------------------------------*
* Freigabe der Nachfolgejobs eines bestimmten Jobs zurücknehmen       *
*---------------------------------------------------------------------*

FORM derelease_successors USING jobname jobcount rc.

  DATA BEGIN OF successor_list OCCURS 10.
          INCLUDE STRUCTURE tbtcjob.
  DATA END OF successor_list.
*
* Nachfolgerjobs ermitteln. Wenn Job nicht mehr existiert (kann in-
* zwischen gelöscht worden sein) oder es keine Nachfolger mehr dazu gibt
* (können ebenfalls zwischenzeitlich gelöscht worden sein), dann zum
* Rufer zurückkehren und so tun, als ob das Rücknehmen der Jobfreigabe
* der Nachfolgejobs gelungen sei.
* Nachfolgejobs nur dann in den Status 'eingeplant' überführen, wenn
* deren aktueller Status = 'freigegeben' ist.
*
  rc = 0.

  CALL FUNCTION 'BP_JOB_GET_SUCCESSORS'
    EXPORTING
      jobname             = jobname
      jobcount            = jobcount
    TABLES
      succ_joblist        = successor_list
    EXCEPTIONS
      job_not_exists      = 1
      no_successors_found = 2
      OTHERS              = 99.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  LOOP AT successor_list.
    IF successor_list-status EQ btc_released.
      CALL FUNCTION 'BP_JOB_MODIFY'
        EXPORTING
          jobname       = successor_list-jobname
          jobcount      = successor_list-jobcount
          dialog        = btc_yes
          opcode        = btc_derelease_job
        TABLES
          new_steplist  = global_step_tbl
        EXCEPTIONS
          nothing_to_do = 1
          OTHERS        = 99.

      IF sy-subrc EQ 0 OR
         sy-subrc EQ 1.
* attemp for fix 46D - joblist->output_joblist
        LOOP AT joblist WHERE jobname  EQ successor_list-jobname
                          AND jobcount EQ successor_list-jobcount.
          joblist-status = btc_scheduled.

          MODIFY joblist INDEX sy-tabix.

          IF sy-subrc NE 0.
            MESSAGE s154.
            rc = 1.
            EXIT.
          ENDIF.
          EXIT. " es sollte nur einen solchen Job geben in der Liste
        ENDLOOP.
        IF rc NE 0.
          EXIT.
        ENDIF.
      ELSE.
        rc = 1. " Errormessage wurde schon von Fubst. abgesetzt
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM. " DERELEASE_SUCCESSORS

*---------------------------------------------------------------------*
*      FORM WRITE_JOBLST_PROC_SYSLOG                                  *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM write_joblst_proc_syslog USING syslogid data.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD joblst_problem_detected.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD syslogid
        ID 'DATA' FIELD data.

ENDFORM. " WRITE_JOBLST_PROC_SYSLOG
*&---------------------------------------------------------------------*
*&      Form  derelease_successors_sm37b
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLD_JOBHEAD_JOBNAME  text
*      -->P_OLD_JOBHEAD_JOBCOUNT  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM derelease_successors_sm37b USING jobname jobcount rc.
  DATA BEGIN OF successor_list OCCURS 10.
          INCLUDE STRUCTURE tbtcjob.
  DATA END OF successor_list.

  rc = 0.

  CALL FUNCTION 'BP_JOB_GET_SUCCESSORS'
    EXPORTING
      jobname             = jobname
      jobcount            = jobcount
    TABLES
      succ_joblist        = successor_list
    EXCEPTIONS
      job_not_exists      = 1
      no_successors_found = 2
      OTHERS              = 99.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  LOOP AT successor_list.
    IF successor_list-status EQ btc_released.
      CALL FUNCTION 'BP_JOB_MODIFY'
        EXPORTING
          jobname       = successor_list-jobname
          jobcount      = successor_list-jobcount
          dialog        = btc_yes
          opcode        = btc_derelease_job
        TABLES
          new_steplist  = global_step_tbl
        EXCEPTIONS
          nothing_to_do = 1
          OTHERS        = 99.

      IF sy-subrc EQ 0 OR
         sy-subrc EQ 1.
* attemp for fix 46D - joblist->output_joblist
        LOOP AT output_joblist WHERE jobname  EQ
successor_list-jobname
                          AND jobcount EQ successor_list-jobcount.
          output_joblist-status = btc_scheduled.

          MODIFY output_joblist INDEX sy-tabix.

          IF sy-subrc NE 0.
            MESSAGE s154.
            rc = 1.
            EXIT.
          ENDIF.
          EXIT. " es sollte nur einen solchen Job geben in der Liste
        ENDLOOP.
        IF rc NE 0.
          EXIT.
        ENDIF.
      ELSE.
        rc = 1. " Errormessage wurde schon von Fubst. abgesetzt
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " derelease_successors_sm37b
