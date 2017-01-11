***INCLUDE LBTCHF27.

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_CHECKSTATE               *
************************************************************************

*---------------------------------------------------------------------*
*      FORM CHECK_FOR_JOB_STILL_READY                                 *
*---------------------------------------------------------------------*
* Überprüfe, ob ein als bereit gekennzeichneter Job wirklich noch im
* Status 'bereit' ist:
*
*   - Information über Workprozesse vom Ausführungsrechner des Jobs
*     besorgen ( SM50-Information )
*   - Job ist noch bereit, wenn
*     - der Ausführungsrechner für Batch konfiguriert ist und
*     - in der Batchqueue des Ausführungsrechners mindestens ein
*       Eintrag vorhanden ist
*
*   Ich weiß, das ist eine 'leicht' unscharfe Bedingung um festzu-
*   stellen, ob ein Job wirklich noch bereit ist. Da aber, bedingt
*   durch das Workloadbalancing, die Wahrscheinlichkeit sehr gering
*   ist, das ein Job im Zustand bereit ist ( Jobs werden nur ange-
*   startet, wenn vorher geprüft wurde, ob auch mindestens ein Work-
*   prozess frei ist ), gehen wir davon aus, daß eine nichtleere Batch-
*   queue den zu untersuchenden Job enthält.
*
* Inputparameter : - Dialog ja / nein
*                  - Ausführungsrechner des Jobs
* Outputparameter: - RC = 0 : Job ist noch im Status bereit
*                    RC = 3 : Job ist nicht mehr im Status bereit
*                    RC = 4 : Fehler beim Ermitteln der Batchqueue-
*                             größe des Ausführungsrechner aufgetreten
*
*---------------------------------------------------------------------*

FORM check_for_job_still_ready
  USING p_dialog LIKE btch0000-char1
        p_server LIKE tbtco-reaxserver
        p_rc TYPE i.

  CLEAR p_rc.

  IF p_server IS INITIAL.
    DATA: server_list LIKE msxxlist OCCURS 0 WITH HEADER LINE.
    DATA: batch LIKE msxxlist-msgtypes VALUE 8.
    DATA: temp_server LIKE tbtco-reaxserver.

    FREE server_list.
    CALL FUNCTION 'TH_SERVER_LIST'
      EXPORTING
        services = batch
      TABLES
        list     = server_list
      EXCEPTIONS
        OTHERS   = 99.

    LOOP AT server_list.
      temp_server = server_list-name.
      PERFORM check_queue_on_server
        CHANGING temp_server p_rc.
      IF p_rc = 0.
        p_server = server_list-name.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
* zunächst prüfen, ob der Server überhaupt noch im System ist
* bzw. ob der Server noch ein Batch Server ist
    CALL FUNCTION 'TH_SERVER_LIST'
      EXPORTING
        services = batch
      TABLES
        list     = server_list
      EXCEPTIONS
        OTHERS   = 99.

    READ TABLE server_list WITH KEY name = p_server.
    IF sy-subrc NE 0.
      p_rc = job_not_ready_anymore.
      EXIT.
    ENDIF.

    PERFORM check_queue_on_server
      CHANGING p_server p_rc.
  ENDIF.

ENDFORM. " CHECK_FOR_JOB_STILL_READY

*---------------------------------------------------------------------*
*      FORM CORRECT_JOB_STATUS                                        *
*---------------------------------------------------------------------*
* Korrigiere den Status eines Jobs, weil festgestellt wurde, daß der
* in den Jobkopfdaten gespeicherte Status nicht mit dem tatsächlichen
* Status des Jobs übereinstimmt:
*
*   Status laut Jobkopf |       Aktion
*   --------------------|--------------------------------------------
*       aktiv           | im Dialog:
*                       | - hat Job externe Programme ?
*                       |   ja:   - Meldung ausgeben die besagt, daß
*                       |           Job in keinem WP mehr aktiv ist und
*                       |           ext. Pgm. (noch nicht) überprüft /
*                       |           abgebrochen werden können. Benutzer
*                       |           hat aber die Möglichkeit, den Job
*                       |           auf 'abgebrochen' zu setzen.
*                       |   nein: - Meldung ausgeben die besagt, daß
*                       |           Job in keinem WP mehr aktiv ist.
*                       |           Benutzer hat die Möglichkeit, den
*                       |           Job auf 'abgebrochen' zu setzen
*                       |
*                       |  im Nichtdialog: noch nicht realisiert
*                       |
*                       |
* Falls ein Job von Status bereit nach 'eingeplant' versetzt wird, dann
* werden auch evtl. vorhandenen Starttermindaten des Jobs in der DB
* gelöscht.
*---------------------------------------------------------------------*
FORM correct_job_status_active
    TABLES p_corr_steplist STRUCTURE tbtcstep
    USING  p_corr_jobhead  STRUCTURE tbtcjob
           p_start_asap    TYPE btch0000-char1
           p_dialog        TYPE btch0000-char1
           p_rc            TYPE i.

  DATA:
        laststep                   TYPE i,
        job_has_xpgm               LIKE true,
        sv_list_row_index          LIKE list_row_index,
        sv_list_processing_context LIKE list_processing_context,
        sv_current_page            LIKE sy-cpage,
        sv_current_head_row        LIKE sy-staro,
        sv_current_row             LIKE sy-curow,
        sv_current_col             LIKE sy-cucol.

  DATA: BEGIN OF i_corr_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF i_corr_stdt.

  DATA: jobinfo(73).
  DATA: sysloginfo(100).
  DATA: status_info(3).
  data: lt_tbtcp type table of tbtcp.
  data: ls_tbtcp type tbtcp.

  CLEAR p_rc.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  p_corr_jobhead-jobname.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_active:'   "#EC NOTEXT
                                          'Job = '                       "#EC NOTEXT
                                          p_corr_jobhead-jobname
                                          p_corr_jobhead-jobcount.

*********************************************************


*
*  um kaskadierte Aufrufe von Funktionsbausteinen der Gruppe BTCH
*  zu ermögliche, müssen gemeinsam benutzte globale Variable zunächst
*  auf einen "Stack" gelegt und am Ende der Routine wieder restauriert
*  werden
*
  sv_list_row_index          = list_row_index.
  sv_list_processing_context = list_processing_context.
  sv_current_page            = current_page.
  sv_current_head_row        = current_head_row.
  sv_current_row             = current_row.
  sv_current_col             = current_col.

* feststellen, ob letzter Step extern.

  job_has_xpgm = false.
  DESCRIBE TABLE p_corr_steplist LINES laststep.

  LOOP AT p_corr_steplist FROM laststep.
    IF p_corr_steplist-typ <> btc_abap.
      job_has_xpgm = true.
    ENDIF.
  ENDLOOP.

*
*  Benutzer fragen, ob Status in DB korrigiert werden soll abhängig da-
*  von, ob Job externe Programme als Steps hat oder nicht. Im Nicht-
*  dialog wird automatisch korrigiert, falls es nicht zu gefährlich ist.
*
  IF p_corr_jobhead-status <> btc_running.
    EXIT.
  ENDIF.

  IF p_dialog EQ btc_yes.
    IF job_has_xpgm EQ true.
      global_job          = p_corr_jobhead.
      correct_job_status  = false.
      REFRESH global_step_tbl.
      LOOP AT p_corr_steplist.
        global_step_tbl = p_corr_steplist.
        APPEND global_step_tbl.
      ENDLOOP.
      list_processing_context = btc_show_xpgm_list.
      CALL SCREEN 1220.
*
*          globale, von mehreren Funktionsbausteinen gemeinsam benutzte
*          Variable restaurieren
*
      list_row_index          = sv_list_row_index.
      list_processing_context = sv_list_processing_context.
      current_page            = sv_current_page.
      current_head_row        = sv_current_head_row.
      current_row             = sv_current_row.
      current_col             = sv_current_col.

      IF correct_job_status EQ false.
        p_rc = 0.
        EXIT.
      ENDIF.
    ENDIF.

* d023157    Endezeitpunkt setzen, wenn noch leer
    IF p_corr_jobhead-enddate = space OR
       p_corr_jobhead-enddate IS INITIAL.
      p_corr_jobhead-enddate = sy-datum.
    ENDIF.

    IF p_corr_jobhead-endtime = space OR
       p_corr_jobhead-endtime IS INITIAL.
      p_corr_jobhead-endtime = sy-uzeit.
    ENDIF.

    p_corr_jobhead-status = btc_aborted.
  ELSE.
    IF p_start_asap = 'D' OR p_start_asap = 'd'.
      p_corr_jobhead-status = 'X'.
      EXIT.
    ELSE.
* d023157    Endezeitpunkt setzen, wenn noch leer
      IF p_corr_jobhead-enddate = space OR
         p_corr_jobhead-enddate IS INITIAL.
        p_corr_jobhead-enddate = sy-datum.
      ENDIF.

      IF p_corr_jobhead-endtime = space OR
         p_corr_jobhead-endtime IS INITIAL.
        p_corr_jobhead-endtime = sy-uzeit.
      ENDIF.

      p_corr_jobhead-status = btc_aborted.
    ENDIF.
  ENDIF.
*
* Job sperren
*
  PERFORM enq_job USING p_corr_jobhead-jobname
                        p_corr_jobhead-jobcount
                        p_dialog
                        p_rc.
  CASE p_rc.
    WHEN 0.
      " ok
    WHEN table_entry_already_locked.
      p_rc = job_already_locked.
      EXIT.
    WHEN OTHERS.
      p_rc = correcting_job_status_failed.
      EXIT.
  ENDCASE.

  PERFORM insert_joblog_message USING p_corr_jobhead
        abort_msg_id
        'S'.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_active:'
                                          'after form'
                                          'insert_joblog_message'
                                          ' '.


  SELECT * FROM tbtcp INTO TABLE lt_tbtcp WHERE
  jobname = p_corr_jobhead-jobname AND jobcount = p_corr_jobhead-jobcount.
  LOOP AT lt_tbtcp INTO ls_tbtcp WHERE status = btc_running.
    ls_tbtcp-status = btc_aborted.
    UPDATE tbtcp FROM ls_tbtcp.
    EXIT.
  ENDLOOP.

  IF ls_tbtcp-status <> btc_aborted.    " old job
    UPDATE tbtcp SET STATUS = btc_aborted
    WHERE jobname =  p_corr_jobhead-jobname AND
    jobcount = p_corr_jobhead-jobcount AND
    stepcount = laststep.
  ENDIF.

  IF sy-subrc <> 0 and sy-dbcnt > 0.
    IF p_dialog EQ btc_yes.
      MESSAGE s144 WITH p_corr_jobhead-jobname.
    ENDIF.
    PERFORM write_job_checkstat_syslog USING tbtcp_update_db_error
                                             p_corr_jobhead-jobname.
    PERFORM deq_job USING p_corr_jobhead-jobname
                          p_corr_jobhead-jobcount
                          p_dialog
                          p_rc.

** store precise error information ********************************
    xbp_error_text = 'update tbtcp failed'.

    CALL METHOD cl_btc_error_controller=>fill_error_info
      EXPORTING
        i_msgid    = 'XM'
        i_msgno    = msg_correcting_state_failed
        i_formname = 'correct_job_status_active'.
    CLEAR xbp_error_text.
*******************************************************************

    p_rc = correcting_job_status_failed.
    EXIT.
  ENDIF.

  CLEAR tbtco.
  MOVE-CORRESPONDING p_corr_jobhead TO tbtco.
  UPDATE tbtco.

  IF sy-subrc EQ 0.
    COMMIT WORK.
    CONCATENATE p_corr_jobhead-jobname p_corr_jobhead-jobcount INTO jobinfo
                SEPARATED BY '&'.
    CONCATENATE btc_running btc_aborted INTO status_info SEPARATED BY '&'.
    CONCATENATE jobinfo status_info INTO sysloginfo SEPARATED BY '&'.
    PERFORM write_job_checkstat_syslog USING job_checkstate_successful
*                                             p_corr_jobhead-jobname.
*                                             jobinfo.
                                              sysloginfo.

    perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_active:'
                                          'after committing'
                                          'new status'
                                          ' '.

  ELSE.
    IF p_dialog EQ btc_yes.
      MESSAGE s144 WITH p_corr_jobhead-jobname.
    ENDIF.
    PERFORM write_job_checkstat_syslog USING tbtco_update_db_error
                                             p_corr_jobhead-jobname.
    PERFORM deq_job USING p_corr_jobhead-jobname
                          p_corr_jobhead-jobcount
                          p_dialog
                          p_rc.

** store precise error information ********************************
    xbp_error_text = 'update tbtco failed'.

    CALL METHOD cl_btc_error_controller=>fill_error_info
      EXPORTING
        i_msgid    = 'XM'
        i_msgno    = msg_correcting_state_failed
        i_formname = 'correct_job_status_active'.
    CLEAR xbp_error_text.
*******************************************************************

    p_rc = correcting_job_status_failed.
    EXIT.
  ENDIF.

  PERFORM deq_job USING p_corr_jobhead-jobname
                        p_corr_jobhead-jobcount
                        p_dialog
                        p_rc.
  p_rc = 0.

ENDFORM. " CORRECT_JOB_STATUS_ACTIVE

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_CHECKSTAT_SYSLOG                                *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM write_job_checkstat_syslog USING syslogid data.

  IF syslogid <> job_checkstate_successful.
*
* Kopfeintrag schreiben
*
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
         ID 'KEY'  FIELD job_checkstat_problem_detected.

  ENDIF.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD syslogid
        ID 'DATA' FIELD data.

ENDFORM. " WRITE_JOB_CHECKSTAT_SYSLOG

*&---------------------------------------------------------------------*
*&      Form  CHECK_JOB_ON_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SERVER  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM check_queue_on_server
  USING p_server LIKE tbtco-reaxserver
        p_rc TYPE i.

* Größe der Batchqueue von Ausführungsrechner des Jobs holen

  DATA: BEGIN OF req_tbl OCCURS 1.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF req_tbl.

  DATA: BEGIN OF rsp_tbl OCCURS 20.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF rsp_tbl.

  REFRESH req_tbl.
  REFRESH rsp_tbl.

  CLEAR req_tbl.
  req_tbl-opcode = ad_queue.
  APPEND req_tbl.

  CALL FUNCTION 'RZL_EXECUTE_STRG_REQ'
    EXPORTING
      srvname = p_server
    TABLES
      req_tbl = req_tbl
      rsp_tbl = rsp_tbl
    EXCEPTIONS
      OTHERS  = 99.

  IF sy-subrc NE 0.
    p_rc = cant_get_batchq_size.
    EXIT.
  ENDIF.

  p_rc = job_not_ready_anymore.

  LOOP AT rsp_tbl.
    IF rsp_tbl-opcode EQ ad_queue AND rsp_tbl-errno EQ 0.
      ad_queue_rec = rsp_tbl-buffer.
      IF ad_queue_rec-rqtyp EQ wp_type_btc AND
         ad_queue_rec-now > 0.                            "#EC PORTABLE
        p_rc = 0.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_QUEUE_ON_SERVER

*---------------------------------------------------------------------*
*       FORM CORRECT_JOB_STATUS_READY                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_CORR_STEPLIST                                               *
*  -->  P_CORR_JOBHEAD                                                *
*  -->  P_START_ASAP                                                  *
*  -->  P_DIALOG                                                      *
*  -->  P_RC                                                          *
*---------------------------------------------------------------------*
FORM correct_job_status_ready TABLES p_corr_steplist STRUCTURE tbtcstep
                              USING  p_corr_jobhead  STRUCTURE tbtcjob
                                     p_start_asap    TYPE btch0000-char1
                                     p_dialog        TYPE btch0000-char1
                                     p_rc            TYPE i.

  DATA: i_text_question(132).
  DATA: BEGIN OF i_corr_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF i_corr_stdt.

  data: wa_tbtcy like tbtcy.
  data: wa_tbtco like tbtco.
  data: rc_n(4)  type n.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  p_corr_jobhead-jobname.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_ready:'    "#EC NOTEXT
                                          'Job = '                       "#EC NOTEXT
                                          p_corr_jobhead-jobname
                                          p_corr_jobhead-jobcount.

**********************************************************

  CLEAR p_rc.

  IF p_corr_jobhead-status <> btc_ready.
    EXIT.
  ENDIF.

  CLEAR p_corr_jobhead-status.

  IF p_dialog EQ btc_yes.

     DATA: i_answer.
     CONCATENATE p_corr_jobhead-jobname ' ('
                    p_corr_jobhead-jobcount ')' INTO i_text_question.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar      = text-344
         text_question = i_text_question
         text_button_1 = text-345  " Starte asap
         text_button_2 = text-346  " -> 'scheduled'
       IMPORTING
         answer        = i_answer
       EXCEPTIONS
         OTHERS        = 99.

     IF i_answer = '1'.
        p_corr_jobhead-status = btc_released.
     ELSEIF i_answer = '2'.
        p_corr_jobhead-status = btc_scheduled.
     ELSE.
        p_corr_jobhead-status = 'X'.
     ENDIF.

  ELSE.

     IF p_start_asap = 'X' OR p_start_asap = 'x'.
        p_corr_jobhead-status = btc_released.
     ELSEIF p_start_asap = 'D' OR p_start_asap = 'd'.
        p_corr_jobhead-status = 'X'.
     ELSE.
        p_corr_jobhead-status = btc_scheduled.
     ENDIF.

  ENDIF.

  IF p_corr_jobhead-status = btc_scheduled.
*
*    Starttermindaten des ehemals 'bereiten' Jobs in der Datenbank
*    löschen. Da das Löschen in der DB schiefgehen kann, weil die Daten
*    schon vom Batchscheduler gelöscht wurden, werten wir den RC der
*    Löschfunktion nicht aus
*

    PERFORM enq_job USING p_corr_jobhead-jobname
                          p_corr_jobhead-jobcount
                          p_dialog
                          p_rc.
    CASE p_rc.
      WHEN 0.
        " ok
      WHEN table_entry_already_locked.
        p_rc = job_already_locked.
        EXIT.
      WHEN OTHERS.
        p_rc = correcting_job_status_failed.
        EXIT.
    ENDCASE.

* Now, after enqueueing the job, we have to check, if the DB status is
* still 'ready'.

    select single * from tbtco into wa_tbtco
                                  where jobname  = p_corr_jobhead-jobname
                                    and jobcount = p_corr_jobhead-jobcount.

    if sy-subrc ne 0 or wa_tbtco-status ne btc_ready.
* job does not exist any more or is not ready any more => exit.
       IF p_dialog EQ btc_yes.
          MESSAGE s144 WITH p_corr_jobhead-jobname.
       ENDIF.

       PERFORM deq_job USING p_corr_jobhead-jobname
                            p_corr_jobhead-jobcount
                            p_dialog
                            p_rc.

       p_rc = correcting_job_status_failed.
       EXIT.
    endif.

    PERFORM extract_stdt_from_jobhead USING p_corr_jobhead i_corr_stdt.

*  25.11.2013   d023157   note 1945160
*  If we reset an event periodic job from 'ready' to 'scheduled',
*  we must not touch the entry in table BTCEVTJOB. Otherwise the
*  periodicity chain will be interrupted. This is, because all jobs
*  of the chain use the same BTCEVTJOB entry.

    if not ( i_corr_stdt-startdttyp = btc_stdt_event and
             i_corr_stdt-periodic = 'X' ) .

       PERFORM reset_release_info_in_db USING p_corr_jobhead
                                              i_corr_stdt
                                              btc_no
                                              p_rc.
    endif.

* 19.4.2013    d023157  ready jobs restart mechanism
* here we set back the job to 'scheduled', i.e. we have to
* delete a possibly existing TBTCY entry
    select single * from TBTCY into wa_tbtcy
                               where jobname  = p_corr_jobhead-jobname
                                 and jobcount = p_corr_jobhead-jobcount.

    if sy-subrc = 0.
       delete tbtcy from wa_tbtcy.
    endif.

    CLEAR tbtco.
    MOVE-CORRESPONDING p_corr_jobhead TO tbtco.
    UPDATE tbtco.

    IF sy-subrc EQ 0.
      COMMIT WORK.

      perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_ready:'
                                          'job has been set'
                                          'to scheduled.'
                                          ' '.

    ELSE.
      IF p_dialog EQ btc_yes.
        MESSAGE s144 WITH p_corr_jobhead-jobname.
      ENDIF.
      PERFORM write_job_checkstat_syslog USING tbtco_update_db_error
                                               p_corr_jobhead-jobname.
      PERFORM deq_job USING p_corr_jobhead-jobname
                            p_corr_jobhead-jobcount
                            p_dialog
                            p_rc.
      p_rc = correcting_job_status_failed.
      EXIT.
    ENDIF.

    PERFORM deq_job USING p_corr_jobhead-jobname
                          p_corr_jobhead-jobcount
                          p_dialog
                          p_rc.
    p_rc = 0.

  ELSEIF p_corr_jobhead-status = btc_released.
*
* Den Job wieder starten.
*
* we don't need to check, if the job has a last start date and time.
* The job starter will take care of it.

     PERFORM enq_job USING p_corr_jobhead-jobname
                            p_corr_jobhead-jobcount
                            p_dialog
                            p_rc.

     CASE p_rc.
        WHEN 0.
          " ok
        WHEN table_entry_already_locked.
          p_rc = job_already_locked.
          EXIT.
        WHEN OTHERS.
          p_rc = correcting_job_status_failed.
          EXIT.
     ENDCASE.

* Now, after enqueueing the job, we have to check, if the DB status is
* still 'ready'.

     select single * from tbtco into wa_tbtco
                                  where jobname  = p_corr_jobhead-jobname
                                    and jobcount = p_corr_jobhead-jobcount.

     if sy-subrc ne 0 or wa_tbtco-status ne btc_ready.
* job does not exist any more or is not ready any more => exit.
        IF p_dialog EQ btc_yes.
           MESSAGE s144 WITH p_corr_jobhead-jobname.
        ENDIF.

        PERFORM deq_job USING p_corr_jobhead-jobname
                              p_corr_jobhead-jobcount
                              p_dialog
                              p_rc.

        p_rc = correcting_job_status_failed.
        EXIT.
     endif.

* Friday, 13th, September 2013
* d023157  note 1912628  due to CM 747530 2013
* If the following routine check_and_start_job finds, that there are no
* free batch ressources any more, it will convert the job into
* a released job with a TBTCS entry. If the job is periodic, the
* TBTCS entry will contain all periodicity data, and a successor will
* be generated at job start.
* But a successor has already been generated at the first start attempt,
* when the job got stuck in 'ready'.
* Therefore we clear the periodic field here.

     clear p_corr_jobhead-periodic.

     PERFORM check_and_start_job
        USING p_corr_jobhead p_corr_jobhead-execserver
              p_dialog space space p_rc.

     rc_n = p_rc.
     perform write_string_to_wptrace_btc using tracelevel_btc
                                          'correct_job_status_ready:'
                                          'tried to restart job'
                                          'rc ='
                                          rc_n.



     PERFORM deq_job USING p_corr_jobhead-jobname
                           p_corr_jobhead-jobcount
                           p_dialog
                           p_rc.



     p_corr_jobhead-status = btc_released.

  ENDIF.

ENDFORM. " CORRECT_JOB_STATUS_READY

*&---------------------------------------------------------------------*
*&      Form  CORRECT_JOB_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CORR_STEPLIST  text
*      -->CORR_JOBHEAD   text
*      -->DIALOG         text
*      -->RC             text
*----------------------------------------------------------------------*
FORM correct_job_status TABLES corr_steplist STRUCTURE tbtcstep
                        USING  corr_jobhead STRUCTURE tbtcjob
                               dialog
                               rc.
  DATA: now                        TYPE p,
        time_diff                  TYPE p,
        ready_since                TYPE p,
        warning(132),
        job_status_in_db           LIKE tbtcjob-status.
*        JOB_HAS_XPGM               LIKE TRUE,
*        SV_LIST_ROW_INDEX          LIKE LIST_ROW_INDEX,
*        SV_LIST_PROCESSING_CONTEXT LIKE LIST_PROCESSING_CONTEXT,
*        SV_CURRENT_PAGE            LIKE SY-CPAGE,
*        SV_CURRENT_HEAD_ROW        LIKE SY-STARO,
*        SV_CURRENT_ROW             LIKE SY-CUROW,
*        SV_CURRENT_COL             LIKE SY-CUCOL.

  DATA: BEGIN OF corr_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF corr_stdt.
  DATA: question_text TYPE string.
*
*  um kaskadierte Aufrufe von Funktionsbausteinen der Gruppe BTCH
*  zu ermögliche, müssen gemeinsam benutzte globale Variable zunächst
*  auf einen "Stack" gelegt und am Ende der Routine wieder restauriert
*  werden
*
*  SV_LIST_ROW_INDEX          = LIST_ROW_INDEX.
*  SV_LIST_PROCESSING_CONTEXT = LIST_PROCESSING_CONTEXT.
*  SV_CURRENT_PAGE            = CURRENT_PAGE.
*  SV_CURRENT_HEAD_ROW        = CURRENT_HEAD_ROW.
*  SV_CURRENT_ROW             = CURRENT_ROW.
*  SV_CURRENT_COL             = CURRENT_COL.

* feststellen, ob Job externe Programm als Steps hat.

*  JOB_HAS_XPGM = FALSE.
*
*  LOOP AT CORR_STEPLIST.
*    IF CORR_STEPLIST-TYP EQ BTC_XPG OR
*       CORR_STEPLIST-TYP EQ BTC_XCMD.
*       JOB_HAS_XPGM = TRUE.
*       EXIT.
*    ENDIF.
*  ENDLOOP.
*
*  Benutzer fragen, ob Status in DB korrigiert werden soll abhängig da-
*  von, ob Job externe Programme als Steps hat oder nicht. Im Nicht-
*  dialog wird automatisch korrigiert, falls es nicht zu gefährlich ist.
*
  job_status_in_db = corr_jobhead-status.

  IF job_status_in_db EQ btc_running.
*     IF DIALOG EQ BTC_YES.
*        IF JOB_HAS_XPGM EQ TRUE.
*           GLOBAL_JOB          = CORR_JOBHEAD.
*           CORRECT_JOB_STATUS  = FALSE.
*           REFRESH GLOBAL_STEP_TBL.
*           LOOP AT CORR_STEPLIST.
*             GLOBAL_STEP_TBL = CORR_STEPLIST.
*             APPEND GLOBAL_STEP_TBL.
*           ENDLOOP.
*           LIST_PROCESSING_CONTEXT = BTC_SHOW_XPGM_LIST.
*           CALL SCREEN 1220.
**
**          globale, von mehreren Funktionsbausteinen gemeinsam benutzte
**          Variable restaurieren
**
*           LIST_ROW_INDEX          = SV_LIST_ROW_INDEX.
*           LIST_PROCESSING_CONTEXT = SV_LIST_PROCESSING_CONTEXT.
*           CURRENT_PAGE            = SV_CURRENT_PAGE.
*           CURRENT_HEAD_ROW        = SV_CURRENT_HEAD_ROW.
*           CURRENT_ROW             = SV_CURRENT_ROW.
*           CURRENT_COL             = SV_CURRENT_COL.
*
*           IF CORRECT_JOB_STATUS EQ FALSE.
*              RC = 0.
*              EXIT.
*           ENDIF.
*        ELSE. " Job wirklich nicht mehr aktiv. User nach Korrektur
*           CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE' " des Jobstatus
*                EXPORTING DEFAULTOPTION = 'N'          " fragen
*                          TEXT_BEFORE   = TEXT-250
*                          TEXT_AFTER    = TEXT-251
*                          OBJECTVALUE   = CORR_JOBHEAD-JOBNAME(32)
*                          TITEL         = TEXT-252
*                IMPORTING ANSWER        = POPUP_ANSWER
*                EXCEPTIONS OTHERS       = 99.
*
*           IF POPUP_ANSWER NE 'J'.
*              RC = 999.
*              EXIT.
*           ENDIF.
*        ENDIF.
*     ELSE.
*       " im Nichtdialogbetrieb wird automatisch korrigiert
*     ENDIF.

    corr_jobhead-status = btc_aborted.
  ELSE. " Status = bereit
    GET TIME.
    now         = ( sy-datum - initial_from_date ) * sec_per_day +
                  sy-uzeit.
    ready_since = ( corr_jobhead-sdlstrtdt - initial_from_date ) *
                  sec_per_day + corr_jobhead-sdlstrttm.
    time_diff = now - ready_since.

    IF dialog EQ btc_yes.
      IF time_diff < sec_per_day.
        warning = text-249.
      ELSE.
        warning = text-269.
      ENDIF.

      CONCATENATE warning corr_jobhead-jobname(32) text-270 INTO question_text
      SEPARATED BY space.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = text-252
          text_question  = question_text
          default_button = '2'
        IMPORTING
          answer         = popup_answer
        EXCEPTIONS
          OTHERS         = 99.

      IF popup_answer NE '1'.
        rc = 999.
        EXIT.
      ENDIF.
    ELSE. " im Nichtdialog wird automatisch korrigiert, falls Job
      IF time_diff < sec_per_day.         " länger als 24h bereit ist
        rc = ready_switch_too_dangerous.
        EXIT.
      ENDIF.
    ENDIF.
    corr_jobhead-status = btc_scheduled.
  ENDIF.
*
* Job sperren
*
  PERFORM enq_job USING corr_jobhead-jobname
                        corr_jobhead-jobcount
                        dialog
                        rc.
  CASE rc.
    WHEN 0.
      " ok
    WHEN table_entry_already_locked.
      rc = job_already_locked.
      EXIT.
    WHEN OTHERS.
      rc = correcting_job_status_failed.
      EXIT.
  ENDCASE.

  IF job_status_in_db EQ btc_ready.
*
*    Starttermindaten des ehemals 'bereiten' Jobs in der Datenbank
*    löschen. Da das Löschen in der DB schiefgehen kann, weil die Daten
*    schon vom Batchscheduler gelöscht wurden, werten wir den RC der
*    Löschfunktion nicht aus
*
    PERFORM extract_stdt_from_jobhead USING corr_jobhead corr_stdt.
    PERFORM reset_release_info_in_db USING corr_jobhead
                                           corr_stdt
                                           btc_no
                                           rc.
  ELSE.
*
*    in Jobprotokoll des ehemals 'aktiven' Job vermerken, daß der Job
*    von außen abgebrochen wurde
*
    PERFORM insert_joblog_message USING corr_jobhead
                                        abort_msg_id
                                        'S'.
  ENDIF.

  CLEAR tbtco.
  MOVE-CORRESPONDING corr_jobhead TO tbtco.
  UPDATE tbtco.

  IF sy-subrc EQ 0.
    COMMIT WORK.
  ELSE.
    IF dialog EQ btc_yes.
      MESSAGE s144 WITH corr_jobhead-jobname.
    ENDIF.
    PERFORM write_job_checkstat_syslog USING tbtco_update_db_error
                                             corr_jobhead-jobname.
    PERFORM deq_job USING corr_jobhead-jobname
                          corr_jobhead-jobcount
                          dialog
                          rc.
    rc = correcting_job_status_failed.
    EXIT.
  ENDIF.

  PERFORM deq_job USING corr_jobhead-jobname
                        corr_jobhead-jobcount
                        dialog
                        rc.
  rc = 0.

ENDFORM. " CORRECT_JOB_STATUS

*&--------------------------------------------------------------------*
*&      Form  job_check_status_sm37
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_JOBS     text
*---------------------------------------------------------------------*
FORM job_check_status_sm37
  TABLES i_jobs STRUCTURE marked_itab.

  DATA:
    p_num_of_jobs           TYPE i,
    p_answer,
    p_db_status             LIKE tbtco-status,
    p_actual_status         LIKE tbtco-status,
    p_start_asap            TYPE btch0000-char1,
    p_percentage            TYPE i,
    p_text1(80)             TYPE c,
    p_text2(8)              TYPE c,
    p_individual_processing LIKE btc_yes,
    p_num_of_checked_jobs   TYPE i,
    p_num_of_corrected_jobs TYPE i,
    p_num_of_dangerous_jobs TYPE i.

  DESCRIBE TABLE i_jobs LINES p_num_of_jobs.
  IF p_num_of_jobs = 0.
* No jobs to check.
    MESSAGE s635.
    EXIT.
  ELSEIF p_num_of_jobs = 1.
* Only 1 job to check.
    p_individual_processing = btc_yes.
  ELSE.
* Many jobs to check.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = 'Mass processing'(348)
        text_question = 'Check and correct all marked jobs equally?'(349)
      IMPORTING
        answer        = p_answer
      EXCEPTIONS
        OTHERS        = 99.

    IF p_answer = '1'.
* Mass processing
      p_individual_processing = btc_no.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar      = 'Mass processing'(348)
          text_question = 'Choose the type of status correction'(350)
          text_button_1 = 'Start ASAP'(345)
          text_button_2 = '-> Scheduled'(346)
        IMPORTING
          answer        = p_answer
        EXCEPTIONS
          OTHERS        = 99.

      IF p_answer = '1' OR p_answer = '2'.
        IF p_answer = '1'.
* Start all jobs immediately
          p_start_asap = 'X'.
        ELSE.
* Reset all jobs (-> 'scheduled')
          CLEAR p_start_asap.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ELSEIF p_answer = '2'.
      p_individual_processing = btc_yes.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

  p_num_of_checked_jobs = 0.
  p_num_of_corrected_jobs = 0.
  p_num_of_dangerous_jobs = 0.
  LOOP AT i_jobs.
    p_num_of_checked_jobs = p_num_of_checked_jobs + 1.
* Show percentage
    p_percentage = p_num_of_checked_jobs * 100 / p_num_of_jobs.
    p_text1 = '&1 of &2 jobs are processed'(351).
    WRITE p_num_of_checked_jobs TO p_text2.
    REPLACE '&1' WITH p_text2 INTO p_text1.
    WRITE p_num_of_jobs TO p_text2.
    REPLACE '&2' WITH p_text2 INTO p_text1.
    CONDENSE p_text1.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = p_percentage
        text       = p_text1.
* Check status
    CALL FUNCTION 'BP_JOB_CHECKSTATE'
      EXPORTING
        dialog                       = p_individual_processing
        jobname                      = i_jobs-jobname
        jobcount                     = i_jobs-jobcount
        start_asap                   = p_start_asap
      IMPORTING
        status_according_to_db       = p_db_status
        actual_status                = p_actual_status
      EXCEPTIONS
        checking_of_job_has_failed   = 1
        correcting_job_status_failed = 2
        invalid_dialog_type          = 3
        job_does_not_exist           = 4
        no_check_privilege_given     = 5
        ready_switch_too_dangerous   = 6
        OTHERS                       = 7.
    IF sy-subrc = 6.
* ready_switch_too_dangerous
      p_num_of_dangerous_jobs = p_num_of_dangerous_jobs + 1.
    ELSEIF sy-subrc = 0 AND p_db_status <> p_actual_status.
      p_num_of_corrected_jobs = p_num_of_corrected_jobs + 1.
    ENDIF.
  ENDLOOP.

  IF p_num_of_dangerous_jobs = 0.
    MESSAGE s640 WITH p_num_of_checked_jobs p_num_of_corrected_jobs.
  ELSE.
    MESSAGE s669 WITH p_num_of_corrected_jobs p_num_of_checked_jobs
      p_num_of_dangerous_jobs.
  ENDIF.

ENDFORM.                    "job_check_status_sm37
