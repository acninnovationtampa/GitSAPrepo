***INCLUDE LBTCHF12 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_CREATE                  *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM STORE_NEW_JOB_IN_DB                                       *
*---------------------------------------------------------------------*
* Speichern der Daten eines neuen Jobs in der Datenbank.              *
* Der Outputparameter RC gibt an, ob das Speichern erfolgreich war    *
* oder nicht. Im Fehlerfalle wird ein enstprchender Syslogeintrag vor-*
* genommen. Mögliche Werte für RC:                                    *
*                                                                     *
*    RC = 0: Speichern in DB ist gelungen
*    RC = 1: Speichern in DB ist misslungen                           *
*                                                                     *
* Diese Routine geht davon aus, daß die Job- und Steplistdaten auf    *
* Gültigkeit geprüft wurden.                                          *
*                                                                     *
* 30.11.2000 hgk      es wird nun nicht mehr der gesamte Namensraum   *
*                     sondern nur noch die Kombination                *
*                     jobname , jobcount                              *
*---------------------------------------------------------------------*

FORM store_new_job_in_db TABLES new_job_steplist STRUCTURE tbtcstep
                         USING  new_job_head     STRUCTURE tbtcjob
                                new_stdt         STRUCTURE tbtcstrt
                                dialog
                                rc
                                adk_mode.

  DATA: recipient_object LIKE swotobjid.
  swc_container container.
  DATA: jcnt LIKE tbtco-jobcount.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  new_job_head-jobname.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'STORE_NEW_JOB_IN_DB'     "#EC NOTEXT
                                          'Job = '                  "#EC NOTEXT
                                          new_job_head-jobname
                                          ' '.

*********************************************************

*
*** Jobnamensraum sperren (über alle Jobcounts eines Jobnamens)
*
* Einen freien Jobcount ermitteln und in tbtco die Kombination
* jobname , jobcount sperren

  PERFORM jobcount_create_new
    USING new_job_head-jobname dialog
    CHANGING jcnt rc.
  IF rc NE 0.
    rc = 1.
    EXIT.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'jobcount created'      "#EC NOTEXT
                                            jcnt
                                            ' '
                                            ' '.


  new_job_head-jobcount = jcnt.

* here we can already save the EPP
  PERFORM get_and_save_epp USING new_job_head-jobname
                                 new_job_head-jobcount.

*
*  Stepliste in Datenbank speichern
*
  PERFORM store_new_steplist_in_db
                             TABLES new_job_steplist
                             USING  new_job_head
                             dialog
                             rc.
  IF rc NE 0.
    ROLLBACK WORK.
    PERFORM deq_job_jcnt USING new_job_head-jobname
                       new_job_head-jobcount dialog rc.
    rc = 1.
    EXIT.
  ENDIF.
*
*  Jobfreigabeberechtigung des Anwenders testen
*
  PERFORM check_release_privilege.
*
*  bei Starttermintyp = 'nach Vorgängerjob' die Anzahl der Nachfolge-
*  jobs des Vorgängerjobs um 1 inkrementieren
*
  IF new_stdt-startdttyp EQ btc_stdt_afterjob.
    PERFORM enq_predecessor_job USING new_stdt-predjob
                                      new_stdt-predjobcnt
                                      dialog
                                      rc.
    IF rc NE 0.
      ROLLBACK WORK.
      PERFORM deq_job_jcnt USING new_job_head-jobname
                           new_job_head-jobcount dialog rc.
      PERFORM deq_predecessor_job USING new_stdt-predjob
                                        new_stdt-predjobcnt
                                        dialog
                                        rc.
      rc = 1.
      EXIT.
    ENDIF.

    PERFORM update_num_of_succjobs USING new_stdt-predjob
                                         new_stdt-predjobcnt
                                         increment
                                         dialog
                                         rc.
    IF rc NE 0.
      ROLLBACK WORK.
      PERFORM deq_job_jcnt USING new_job_head-jobname
                              new_job_head-jobcount dialog rc.
      PERFORM deq_predecessor_job USING new_stdt-predjob
                                        new_stdt-predjobcnt
                                        dialog
                                        rc.
      rc = 1.
      EXIT.
    ENDIF.

    PERFORM deq_predecessor_job USING new_stdt-predjob
                                      new_stdt-predjobcnt
                                      dialog
                                      rc.
  ENDIF.


* c5034979, note 578967
**
**  zum Abspeichern der Freigabedaten (Starttermins) notwendige DB-
**  Tabellen sperren
**
*  PERFORM enq_release_info_in_db USING new_stdt dialog rc.
* c5034979, note 578967

  IF rc NE 0.
    ROLLBACK WORK.
    PERFORM deq_job_jcnt USING new_job_head-jobname
                            new_job_head-jobcount dialog rc.
* c5034979, note 578967
    PERFORM deq_btcevtjob_entry
      USING new_stdt-eventid new_job_head-eventcount rc.
*      PERFORM DEQ_RELEASE_INFO_IN_DB USING NEW_STDT DIALOG RC.
* c5034979, note 578967
    rc = 1.
    EXIT.
  ENDIF.
*
*  evtl. vorhandene Freigabeinformationen abhängig von den Starttermin-
*  daten und der Freigabeberechtigung in der Datenbank fortschreiben
*

  perform write_string_to_wptrace_btc using tracelevel_btc
                                           'release_privilege_given = '
                                            release_privilege_given
                                           ' '
                                           ' '.


  IF release_privilege_given EQ btc_yes.

    PERFORM insert_release_info_in_db USING new_job_head
                                            new_stdt
                                            dialog
                                            rc.
    IF rc NE 0.
      ROLLBACK WORK.
      PERFORM deq_job_jcnt USING new_job_head-jobname
                              new_job_head-jobcount dialog rc.
* c5034979, note 578967
      PERFORM deq_btcevtjob_entry
        USING new_stdt-eventid new_job_head-eventcount rc.
*      PERFORM deq_release_info_in_db USING new_stdt dialog rc.
* c5034979, note 578967
      rc = 1.
      EXIT.
    ENDIF.
  ENDIF.
*
*  evtl. Periodenflag "anmachen"
*
  IF new_stdt-periodic EQ 'X'.
    new_job_head-periodic = 'X'.
  ENDIF.

*
* Maketh thy recipient object persistent and writeth it unto the TBTCO.
*
  IF NOT btch1140aux-recipient IS INITIAL.
    swc_call_method btch1140aux-recipient 'Save' container.
* insert note 760838
    IF sy-subrc NE 0.
      DATA: error_message(255),
      zsubrc(10).
      MOVE sy-subrc TO zsubrc.
      CONCATENATE sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3
      sy-msgv4 INTO error_message SEPARATED BY space.
      CALL 'WriteTrace'
        ID 'CALL' FIELD 'swc_call_method SAVE'              "#EC NOTEXT
        ID 'PAR1' FIELD 'SY-SUBRC'                          "#EC NOTEXT
        ID 'PAR2' FIELD zsubrc
        ID 'PAR3' FIELD 'Error message'                     "#EC NOTEXT
        ID 'PAR4' FIELD error_message.
      CLEAR: zsubrc, error_message.
    ENDIF.
* end of note 760838
    swc_object_to_persistent btch1140aux-recipient recipient_object.
* insert note 760838
    IF sy-subrc NE 0.
      MOVE sy-subrc TO zsubrc.
      CONCATENATE sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3
      sy-msgv4 INTO error_message SEPARATED BY space.
      CALL 'WriteTrace'
        ID 'CALL' FIELD 'swc_object_to_persistent'          "#EC NOTEXT
        ID 'PAR1' FIELD 'SY-SUBRC'                          "#EC NOTEXT
        ID 'PAR2' FIELD zsubrc
        ID 'PAR3' FIELD 'Error message'                     "#EC NOTEXT
        ID 'PAR4' FIELD error_message.
      CLEAR: zsubrc, error_message.
    ENDIF.
* end of note 760838
    new_job_head-reclogsys   = recipient_object-logsys.
    new_job_head-recobjtype  = recipient_object-objtype.
    new_job_head-recobjkey   = recipient_object-objkey.
    new_job_head-recdescrib  = recipient_object-describe.
  ENDIF.  "else: keep it empty - meaning no recipient specified

*
*  Jobkopfdaten in Tabelle TBTCO speichern. Im Fehlerfalle müssen auch
*  die von UPDATE_RELEASE_INFO_IN_DB gesetzten Sperren nach dem
*  ROLLBACK zurückgenommen werden.
*
  DATA: lv_subrc TYPE SYST_SUBRC,
        wa_tbtccntxt TYPE tbtccntxt.

  CLEAR tbtco.
  MOVE-CORRESPONDING new_job_head TO tbtco.
  CLEAR tbtco-jobgroup.  " evtl. vorh. 'IMMEDIATE'-Info in Jobkopf-
  INSERT tbtco.          " daten darf nicht in DB
  lv_subrc = sy-subrc.

  IF lv_subrc = 0.

* we write the following context entry only, if the system is separated.
     IF CL_RLFW_SERVER_GROUP=>IS_SYSTEM_SEPARATION_ACTIVE( ) = abap_true.

        WA_TBTCCNTXT-JOBNAME = tbtco-JOBNAME.
        WA_TBTCCNTXT-JOBCOUNT = tbtco-JOBCOUNT.
        WA_TBTCCNTXT-CTXTTYPE = 'SUBSYSTEM'.

        try.
           WA_TBTCCNTXT-CTXTVAL = CL_RLFW_SERVER_GROUP=>GET_SERVER_GROUP( ).

           INSERT tbtccntxt FROM WA_TBTCCNTXT.
           lv_subrc = sy-subrc.

           catch CX_RLFW_COMMUNICATION_ERROR.
              lv_subrc = 1.
        endtry.

     endif.

  ENDIF.

  IF lv_subrc <> 0.

    ROLLBACK WORK.
    PERFORM deq_job_jcnt USING new_job_head-jobname
                            new_job_head-jobcount dialog rc.
* c5034979, note 578967
    PERFORM deq_btcevtjob_entry
      USING new_stdt-eventid new_job_head-eventcount rc.
*    PERFORM deq_release_info_in_db USING new_stdt dialog rc.
* c5034979, note 578967
    IF dialog EQ btc_yes.
      MESSAGE s117 WITH new_job_head-jobname.
    ENDIF.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
         ID 'KEY'  FIELD tbtco_insert_db_error
         ID 'DATA' FIELD new_job_head-jobname.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD job_count
          ID 'DATA' FIELD new_job_head-jobcount.
    rc = 1.
    EXIT.
  ENDIF.
*
*  neuen JOB erfolgreich in DB gespeichert. Jetzt noch DB-Aktionen
*  committen und Sperren freigeben. Für die Archivierungsgruppe wird
*  zum committieren der Fubst. DB_COMMIT aufgerufen, damit der DB-
*  Cursor nicht zerstört wird.
*
  CALL FUNCTION 'DB_COMMIT'.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'Job inserted to TBTCO:'    "#EC NOTEXT
                                           new_job_head-jobname
                                           new_job_head-jobcount
                                          ' '.

  PERFORM deq_job_jcnt USING new_job_head-jobname
                          new_job_head-jobcount dialog rc.
* c5034979, note 578967
  PERFORM deq_btcevtjob_entry
    USING new_stdt-eventid new_job_head-eventcount rc.
*   PERFORM DEQ_RELEASE_INFO_IN_DB USING NEW_STDT DIALOG RC.
* c5034979, note 578967

  rc = 0.

ENDFORM. " STORE_NEW_JOB_IN_DB


*---------------------------------------------------------------------*
*      FORM START_JOB_IMMEDIATELY                                     *
*---------------------------------------------------------------------*
* Diese Routine sorgt dafür, daß ein Job sofort zur Ausführung ge-    *
* bracht wird. Dazu wird ein entsprechender Request an die Ziel-      *
* instanz, auf der der Job ausgeführt werden soll, geschickt.         *
*---------------------------------------------------------------------*
**** c5034979 XBP20 *****
FORM start_job_immediately
    USING p_job_head      STRUCTURE tbtcjob
          p_instance_name LIKE tbtcstrt-instname
          p_dialog        LIKE btch0000-char1
          p_direct_start  LIKE btch0000-char1
          p_old_status    LIKE tbtco-status
          p_rc            TYPE i.

  DATA BEGIN OF th_msg.
          INCLUDE STRUCTURE tbtcm.
  DATA END OF th_msg.
  DATA: is_intercepted.
  DATA: sy_subrc LIKE sy-subrc.

  DATA: eventid_icp   LIKE tbtco-eventid.
  DATA: eventparm_icp LIKE tbtco-eventparm.
  DATA: eventinfo.
  DATA: job_execute(40).
  DATA: name(40).

  CLEAR is_intercepted.

  p_rc = 0.

  PERFORM enq_job
    USING p_job_head-jobname p_job_head-jobcount p_dialog p_rc.
  IF p_rc <> 0.
    EXIT.
  ENDIF.

* note 1650982    9.11.2011    d023157

  select single * from tbtco where
                             jobname  = p_job_head-jobname
                         and jobcount = p_job_head-jobcount.

  if sy-subrc ne 0.

* actually, I decided not to write any messages in this case.
* The job has been deleted, and that's visible anyway.

*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBG'
*           ID 'DATA' FIELD p_job_head-jobname.
*
*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBD'
*           ID 'DATA' FIELD p_job_head-jobname.
*
*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBD'
*           ID 'DATA' FIELD p_job_head-jobcount.

     p_rc = rc_job_cannot_be_started.
     exit.
  endif.

* end  note 1650982 *******************************************

  CALL FUNCTION 'ENQUEUE_ESTBTCS'
    EXPORTING
      mode_tbtcs     = 'E'
      jobname        = p_job_head-jobname
      jobcount       = p_job_head-jobcount
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    PERFORM deq_tbtco_entry
      USING p_job_head-jobname p_job_head-jobcount
      CHANGING sy_subrc.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING p_job_head TO th_msg.

  DATA: wa_tbtco3 LIKE tbtco.
  DATA: wa_tbtccntxt LIKE tbtccntxt.
  SELECT SINGLE * FROM tbtco INTO wa_tbtco3
    WHERE jobname  = p_job_head-jobname AND
          jobcount = p_job_head-jobcount AND
          status   = btc_scheduled.
  sy_subrc = sy-subrc.

  SELECT SINGLE * FROM tbtccntxt INTO wa_tbtccntxt
    WHERE jobname  = p_job_head-jobname AND
          jobcount = p_job_head-jobcount AND
          ctxttype = 'INTERCEPTED'.

  IF sy_subrc <> 0 AND sy-subrc = 0.
    CLEAR is_intercepted.
    wa_tbtco3-status = btc_released.
    UPDATE tbtco FROM wa_tbtco3.
    DATA: wa_context LIKE tbtccntxt.
    SELECT SINGLE * FROM tbtccntxt INTO wa_context
      WHERE
        jobname  = p_job_head-jobname AND
        jobcount = p_job_head-jobcount AND
        ctxttype = 'INTERCEPTED'.

    IF wa_context-ctxttext NS 'S'.
      DATA: temp_string LIKE wa_context-ctxttext.
      temp_string = wa_context-ctxttext.
      CONCATENATE temp_string 'S' INTO wa_context-ctxttext.
      UPDATE tbtccntxt FROM wa_context.
    ENDIF.

* d023157   30.8.2004
* if the call comes from a BAPI, we may (unexpectedly) end up in this
* coding branch.
* In this case, we store the event information, if there are any
* note <xxx>
    CONCATENATE p_job_head-jobname p_job_head-jobcount INTO name.
    IMPORT job_execute = job_execute FROM MEMORY ID name.
    IF sy-subrc = 0.
      FREE MEMORY ID name.
      PERFORM get_eventinfo USING eventid_icp
                                  eventparm_icp
                                  eventinfo.
    ENDIF.
* end note <xxx>
  ELSE.

    CONCATENATE p_job_head-jobname p_job_head-jobcount INTO name.
    IMPORT job_execute = job_execute FROM MEMORY ID name.

    IF sy-subrc <> 0.
      PERFORM intercept_job
        USING p_job_head
        CHANGING is_intercepted.
    ELSE.
      IF job_execute = name.
        FREE MEMORY ID name.
        CLEAR is_intercepted.

* check, if job has event information
* note <xxx>
        PERFORM get_eventinfo USING eventid_icp
                                    eventparm_icp
                                    eventinfo.
* end note <xxx>

      ELSE.
        PERFORM intercept_job
          USING p_job_head
          CHANGING is_intercepted.
      ENDIF.
    ENDIF.
  ENDIF.

  DATA: start_right_away VALUE 'X'.

  IF is_intercepted IS INITIAL.
***** c5034979 Immediate start. Start of section *****
    DATA: wa_btcoptions2 LIKE btcoptions.
    SELECT SINGLE * FROM btcoptions INTO wa_btcoptions2
      WHERE btcoption = 'WEAK_IMMSTART' AND
            value1    = 'ON'.
    IF sy-subrc = 0.
* check if there are waiting jobs of same or higher priority.
      DATA: number_of_jobs TYPE i.
      DATA: waiting_tab LIKE tbtco OCCURS 10 WITH HEADER LINE.

      GET TIME.
      CASE p_job_head-jobclass.
        WHEN btc_jobclass_a.
          SELECT * FROM tbtco INTO TABLE waiting_tab
            WHERE ( status = btc_released OR status = btc_ready ) AND
                  jobclass = btc_jobclass_a AND
                sdlstrtdt <> '        ' AND
                sdlstrttm <> '      ' AND
                (
                  ( sdlstrtdt = sy-datum AND sdlstrttm <= sy-uzeit )
                  OR
                  ( sdlstrtdt < sy-datum )
                 ).

        WHEN btc_jobclass_b.
          SELECT * FROM tbtco INTO TABLE waiting_tab
            WHERE ( status = btc_released OR status = btc_ready ) AND
               ( jobclass = btc_jobclass_a OR
                 jobclass = btc_jobclass_b ) AND
                sdlstrtdt <> '        ' AND
                sdlstrttm <> '      ' AND
                (
                  ( sdlstrtdt = sy-datum AND sdlstrttm <= sy-uzeit )
                  OR
                  ( sdlstrtdt < sy-datum )
                 ).

        WHEN OTHERS.
          SELECT * FROM tbtco INTO TABLE waiting_tab
            WHERE ( status = btc_released OR status = btc_ready ) AND
                sdlstrtdt <> '        ' AND
                sdlstrttm <> '      ' AND
                (
                  ( sdlstrtdt = sy-datum AND sdlstrttm <= sy-uzeit )
                  OR
                  ( sdlstrtdt < sy-datum )
                 ).
      ENDCASE.

      DATA: active_servers LIKE msxxlist OCCURS 10 WITH HEADER LINE.
      PERFORM get_active_servers TABLES active_servers.

      LOOP AT waiting_tab.
        IF NOT waiting_tab-execserver IS INITIAL.
          READ TABLE active_servers
            WITH KEY name = waiting_tab-execserver.
          IF sy-subrc <> 0.
            DELETE waiting_tab.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DESCRIBE TABLE waiting_tab LINES number_of_jobs.

      IF number_of_jobs >= 2.
* There are waiting jobs with higher priority. The current job will not
* be started, but transformed into a time-based.
        DATA: wa_tbtco LIKE tbtco.
        DATA: wa_tbtcs LIKE tbtcs.
        SELECT SINGLE * FROM tbtco INTO wa_tbtco
          WHERE jobname  = p_job_head-jobname AND
                jobcount = p_job_head-jobcount.
        IF sy-subrc = 0.
          GET TIME.
          wa_tbtco-status = btc_released.
          wa_tbtco-sdlstrtdt = sy-datum.
          wa_tbtco-sdlstrttm = sy-uzeit.
          CLEAR wa_tbtco-jobgroup.
          UPDATE tbtco FROM wa_tbtco.

          MOVE-CORRESPONDING wa_tbtco TO wa_tbtcs.
          CLEAR wa_tbtcs-jobgroup.
          UPDATE tbtcs FROM wa_tbtcs.
          IF sy-subrc <> 0.
            INSERT INTO tbtcs VALUES wa_tbtcs.
          ENDIF.
        ENDIF.
        CLEAR start_right_away.
      ELSE.
        start_right_away = 'X'.
      ENDIF.
    ELSE.
      start_right_away = 'X'.
    ENDIF.
***** c5034979 Immediate start. End of section *****

    DATA: is_job_intercepted.
    CLEAR is_job_intercepted.
*C5035006 New interception criteria
*    PERFORM check_icpt_crit_job
*    USING
*        p_job_head-jobname
*        p_job_head-sdluname
*        p_job_head-authckman
*    CHANGING
*        is_job_intercepted.

    PERFORM check_icpt_crit_job_30
            USING
               p_job_head
    CHANGING
        is_job_intercepted.

*  1. IF the job fullfills the intercept criteria (no matter, if the
*     job has been intercepted some time before or not)
*   AND
*  2. IF the job shall be started (e.g. because the call came
*     from a BAPI)
*
*  THEN we write an 'X' into the context field.
*
*  The meaning of this 'X' is the following: If the job cannot be
*  started immediately due to a lack of ressources, the time scheduler
*  will not intercept this job any more.

    IF NOT is_job_intercepted IS INITIAL.
      DATA: wa_context4 LIKE tbtccntxt.
      SELECT SINGLE * FROM tbtccntxt INTO wa_context4
        WHERE
          jobname  = p_job_head-jobname AND
          jobcount = p_job_head-jobcount AND
          ctxttype = 'INTERCEPTED'.
      IF wa_context4-ctxttext NS 'X'.
        DATA: temp_string2 LIKE wa_context4-ctxttext.
        temp_string2 = wa_context4-ctxttext.
        CONCATENATE temp_string2 'X' INTO wa_context4-ctxttext.
        UPDATE tbtccntxt FROM wa_context4.
      ENDIF.
    ENDIF.

* if job has event information, we store them in tbtco here.
* note <xxx>
    IF eventinfo = 'X'.
      CLEAR eventinfo.
      IF NOT eventid_icp IS INITIAL OR
         NOT eventid_icp CO ' '.
        p_job_head-eventid = eventid_icp.
        UPDATE tbtco SET eventid = eventid_icp
                    WHERE jobname  = p_job_head-jobname
                      AND jobcount = p_job_head-jobcount.

* if job has event parameters, store them as well
        IF NOT eventparm_icp IS INITIAL OR
           NOT eventparm_icp CO ' '.
          p_job_head-eventparm = eventparm_icp.
          UPDATE tbtco SET eventparm = eventparm_icp
                      WHERE jobname  = p_job_head-jobname
                        AND jobcount = p_job_head-jobcount.

        ENDIF.

      ENDIF.
    ENDIF.
* end note <xxx>

* This commit is called for all jobs, which were about to be started
* immediately (both for transformed into time-based and for those,
* who will be really started.)
    CALL FUNCTION 'DB_COMMIT'.

    IF NOT start_right_away IS INITIAL.
      PERFORM check_and_start_job
          USING p_job_head p_instance_name p_dialog
                p_direct_start p_old_status p_rc.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_ESTBTCS'
    EXPORTING
      mode_tbtcs = 'E'
      jobname    = p_job_head-jobname
      jobcount   = p_job_head-jobcount.
  CALL FUNCTION 'DEQUEUE_ESTBTCO'
    EXPORTING
      mode_tbtco = 'E'
      jobname    = p_job_head-jobname
      jobcount   = p_job_head-jobcount
      _scope     = '1'.

ENDFORM. " START_JOB_IMMEDIATELY.

*---------------------------------------------------------------------*
*      FORM WRITE_MESSAGE_IN_JOBLOG                                   *
*---------------------------------------------------------------------*
* Nachricht in Joblog eines Jobs schreiben. Um welche Nachricht es    *
* sich handelt, ist im Parameter MESSAGE_ID spezifiziert.             *
* Das Schreiben der Nachricht erfolgt dadurch, in dem man vortäuscht, *
* der im Parameter JOB_HEAD spezifizierte Job würde laufen. Der Job   *
* wird auch angestartet, allerdings nicht mit seinen Originalsteps,   *
* sondern man "schiebt" ihm einen speziellen Report (MESSAGE_REPORT)  *
* unter, der die eigentliche Nachricht in den Joblog schreibt.        *
* Diese Routine wird man immer dann verwenden, wenn ein Job, auf Grund*
* einer Fehlersituation, nicht mehr in der Lage ist, selbst einen Ein-*
* trag vorzunehmen.                                                   *
*---------------------------------------------------------------------*

FORM write_message_in_joblog USING job_head STRUCTURE tbtcjob
                                   message_id.

  DATA: message_report LIKE sy-repid.

  CASE message_id.
    WHEN cant_start_job_immediately.
      message_report = immed_start_error_report.
    WHEN OTHERS.
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_joblog_message_id
            ID 'DATA' FIELD message_id.
      EXIT.
  ENDCASE.

  CALL 'BTC_CALL_KERNEL'
    ID 'FCID' FIELD btc_a2c_pretend_exec
    ID 'JNAM' FIELD job_head-jobname
    ID 'JCNT' FIELD job_head-jobcount
    ID 'JCLT' FIELD job_head-authckman
    ID 'IREP' FIELD message_report
    ID 'JSTA' FIELD btc_aborted.

  IF sy-subrc NE 0.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD cant_start_pretended_job
          ID 'DATA' FIELD job_head-jobname.
  ENDIF.

ENDFORM. " WRITE_MESSAGE_IN_JOBLOG

*---------------------------------------------------------------------*
*      FORM CHECK_BATCH_ADMIN_PRIVILEGE                               *
*---------------------------------------------------------------------*
* Prüfe, ob Benutzer Batchadministratorberechtigung hat. Diese Routine*
* setzt die globale Variable BATCH_ADMIN_PRIVILEGE.                   *
*---------------------------------------------------------------------*

FORM check_batch_admin_privilege.

  AUTHORITY-CHECK
    OBJECT 'S_BTCH_ADM'
        ID 'BTCADMIN' FIELD 'Y'.

  IF sy-subrc EQ 0.
    batch_admin_privilege_given = btc_yes.
  ELSE.
    batch_admin_privilege_given = btc_no.
  ENDIF.

ENDFORM. " CHECK_BATCH_ADMIN_PRIVILEGE.

*---------------------------------------------------------------------*
*      FORM CHECK_RELEASE_PRIVILEGE                                   *
*---------------------------------------------------------------------*
* Prüfe, ob Benutzer Jobfreigabeberechtigung besitzt. Diese liegt vor,*
* wenn der Benutzer entweder explizit Jobfreigabeberechtigung oder    *
* Batchadministratorberechtigung hat. Diese Routine setzt die glo-    *
* bale Variable RELEASE_PRIVILEGE_GIVEN.                              *
*---------------------------------------------------------------------*

FORM check_release_privilege.

  DATA: jobgroup LIKE tbtco-jobgroup. " Dummyfeld aus alten Tagen

  jobgroup = space.

  AUTHORITY-CHECK
    OBJECT 'S_BTCH_JOB'
        ID 'JOBGROUP'  FIELD jobgroup
        ID 'JOBACTION' FIELD 'RELE'.

  IF sy-subrc EQ 0.
    release_privilege_given = btc_yes.
  ELSE.
    PERFORM check_batch_admin_privilege.

    IF batch_admin_privilege_given EQ btc_yes.
      release_privilege_given = btc_yes.
    ELSE.
      release_privilege_given = btc_no.
    ENDIF.
  ENDIF.

ENDFORM. " CHECK_RELEASE_PRIVILEGE.

*---------------------------------------------------------------------*
*      FORM RAISE_JOB_CREATE_EXCEPTION                                *
*---------------------------------------------------------------------*
* Ausloesen einer Exception und Schreiben eines Syslogeintrages falls *
* der Funktionsbaustein BP_JOB_CREATE schwerwiegende Fehler entdeckt. *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM raise_job_create_exception USING exception data.

DATA: l_msg type symsg.
*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD job_create_problem_detected.
*
* exceptionspezifischen Eintrag schreiben und Exception ausloesen
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD exception
       ID 'DATA' FIELD data.

  CASE exception.
    WHEN invalid_dialog_type.
      RAISE invalid_dialog_type.
    WHEN invalid_job_data.
     CALL METHOD cl_btc_error_controller=>read_error_info
          IMPORTING
            einfo = l_msg.
     IF l_msg-msgno IS INITIAL.
       l_msg-msgid = 'BT'.
       l_msg-msgno = '390'.
       l_msg-msgty = 'E'.
     ELSEIF l_msg-msgty IS INITIAL.
       l_msg-msgty = 'E'.
     ENDIF.
     MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
      WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING invalid_job_data.
    WHEN cant_create_job.
      RAISE cant_create_job.
    WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb der Startterminpruefung soll ausge-
*      loest werden. Aus Verlegenheit wird INVALID_JOB_DATA ausge-
*      loest und die unbekannte Exception im Syslog vermerkt.
*
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_job_create_problem
            ID 'DATA' FIELD exception.
      RAISE invalid_job_data.
  ENDCASE.

ENDFORM. " RAISE_JOB_CREATE_EXCEPTION

*---------------------------------------------------------------------*
*      FORM UPDATE_NUM_OF_SUCCJOBS                                    *
*---------------------------------------------------------------------*
* Für einen bestimmten Job wird die Anzahl seiner Nachfolger um 1     *
* inkrementiert bzw. dekrementiert abhängig vom Parameter HOW.        *
* Das Ergebnis wird in der Datenbank speichern.                       *
*                                                                     *
* Inputparameter:                                                     *
*                                                                     *
* - JOBNAME : Name des Jobs, dessen Anzahl Nachfolger upgedated wird  *
* - JOBCOUNT: Jobcount "       "      "       "           "      "    *
* - HOW     : INCREMENT -> Anzahl Vorgängerjobs um 1 inkrementieren   *
*             DECREMENT -> Anzahl Vorgängerjobs um 1 dekrementieren   *
* - Dialog  : gibt an, ob die Routine im Dialog gerufen wurde.        *
*                                                                     *
* Outputparameter:                                                    *
*                                                                     *
* - RC = 0: Operation gelungen                                        *
* - RC = 1: Operation misslungen                                      *
*                                                                     *
* Diese Routine verläßt sich darauf, daß der entsprechende Job in     *
* der TBTCO bereits gesperrt ist.                                     *
*                                                                     *
*---------------------------------------------------------------------*
FORM update_num_of_succjobs USING jobname jobcount how dialog rc.
*
*  Jobdaten aus DB lesen. Falls der Nachfolgezähler eines Jobs dekre-
*  mentiert werden soll (weil eine Nachfolger- Vorgängerbeziehung auf-
*  gelöst werden soll) und der Vorgängerjob nicht mehr existiert, dann
*  tun wir so, als ob alles ok sei.
*
  SELECT SINGLE * FROM tbtco
         WHERE jobname  = jobname
           AND jobcount = jobcount.

  IF sy-subrc NE 0.
    IF how EQ decrement.  " Beim Auflösen einer Vorgängerbeziehung
      rc = 0.            " ist das kein Problem
      EXIT.
    ENDIF.

    IF dialog EQ btc_yes.
      MESSAGE s118 WITH jobname.
    ENDIF.

    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD jobentry_doesnt_exist
          ID 'DATA' FIELD jobname.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD job_count
          ID 'DATA' FIELD jobcount.
    rc = 1.
    EXIT.
  ENDIF.
*
*    Anzahl Nachfolger des Vorgängers um 1 inkrementieren bzw. dekre-
*    mentieren
*
  IF how EQ increment.
    tbtco-succnum = tbtco-succnum + 1.
  ELSE.
    tbtco-succnum = tbtco-succnum - 1.
  ENDIF.

  UPDATE tbtco.

  IF sy-subrc NE 0.
    IF dialog EQ btc_yes.
      MESSAGE s119 WITH jobname.
    ENDIF.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtco_update_db_error
          ID 'DATA' FIELD jobname.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD job_count
          ID 'DATA' FIELD jobcount.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM. " UPDATE_NUM_OF_SUCCJOBS

***** c5034979 XBP20 *****
*---------------------------------------------------------------------*
*  FORM intercept_job
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_JOB
*  -->  P_IS_INTERCEPTED
*---------------------------------------------------------------------*
* This form recieves a table of jobs, which should be check if they
* have to be intercepted. To check if a job has to be intercepted the
* check_icpt_crit_job form is executed. In case this form
* decides that the job has to be intercepted, a flag is set and the
* current intercept_evtdrv_jobs subroutine intercepts the jobs.
* Interception is done using the BP_JOBCONTEXT_ADD function module.
FORM intercept_job
  USING i_job LIKE tbtcjob
  CHANGING o_is_intercepted TYPE boolean.

* Data declaration
* The is_intercepted parameter is used as a flag to show
* if given job should be intercepted.
  DATA: is_intercepted TYPE c.
* Job context
  DATA:
    p_jobcontext  TYPE btcjobctxt,
    p_jobcontexts TYPE TABLE OF btcjobctxt.
* Workarea for job context table
  DATA: wa_context LIKE tbtccntxt,

    p_rc           TYPE i.
  DATA: int_value TYPE char1.

* Function code

  CLEAR o_is_intercepted.

  CALL FUNCTION 'BP_NEW_FUNC_CHECK'
    EXPORTING
      interception_action = 'r'
    IMPORTING
      interception        = int_value
    EXCEPTIONS
      wrong_action        = 1
      no_authority        = 2
      OTHERS              = 3.

  IF sy-subrc <> 0 OR int_value IS INITIAL.
    EXIT.
  ENDIF.

* Check if there is an entry in the context table for the current job
  SELECT SINGLE * FROM tbtccntxt INTO wa_context
    WHERE
      jobname = i_job-jobname AND
      jobcount = i_job-jobcount AND
      ctxttype = 'INTERCEPTED'.
  IF sy-subrc <> 0.
* The context table does not have an entry for the current job
********* locking
    PERFORM enq_tbtco_entry
      USING i_job-jobname i_job-jobcount
      CHANGING p_rc.
    IF p_rc <> 0.
      EXIT.
    ENDIF.

    SELECT SINGLE * FROM tbtccntxt INTO wa_context
      WHERE jobname = i_job-jobname AND
            jobcount = i_job-jobcount AND
            ctxttype = 'INTERCEPTED'.
********* locking finished

    IF sy-subrc <> 0.
*C5035006 New interception criteria
      PERFORM check_icpt_crit_job_30
              USING
                 i_job
              CHANGING
                 is_intercepted..
*      PERFORM check_icpt_crit_job
*      USING
*          i_job-jobname
*          i_job-sdluname
*          i_job-authckman
*      CHANGING
*          is_intercepted.
      IF is_intercepted IS NOT INITIAL.
* Job should be intercepted
        p_jobcontext-ctxttype = 'INTERCEPTED'.
        CONCATENATE sy-uzeit sy-datum INTO p_jobcontext-ctxtval.
        APPEND p_jobcontext TO p_jobcontexts.
        CALL FUNCTION 'BP_JOBCONTEXT_ADD'
          EXPORTING
            jobname                     = i_job-jobname
            jobcount                    = i_job-jobcount
          TABLES
            jobcontexts                 = p_jobcontexts
          EXCEPTIONS
            empty_contexts_table        = 1
            empty_contexttypes_table    = 2
            missing_jobname_or_jobcount = 3
            incomplete_context          = 4
            invalid_context_type        = 5
            job_for_context_not_found   = 6
            unknown_job_error           = 7
            duplicate_context_record    = 8
            job_locking_error           = 9
            OTHERS                      = 10.

        IF sy-subrc = 0.
          UPDATE tbtco SET status = btc_intercepted
            WHERE jobname = i_job-jobname AND
                  jobcount = i_job-jobcount.
          o_is_intercepted = 'X'.
          SELECT SINGLE * FROM tbtccntxt INTO wa_context
            WHERE
              jobname  = i_job-jobname AND
              jobcount = i_job-jobcount AND
              ctxttype = 'INTERCEPTED'.
          CONCATENATE wa_context-ctxttext 'S' INTO wa_context-ctxttext.
          UPDATE tbtccntxt FROM wa_context.
        ENDIF.
      ENDIF.
    ELSE.
* There is an entry in the context table for the current job.
* The CTXTTEXT field of this entry should be checked against 'X'.
      IF wa_context-ctxttext NS 'X'.
        o_is_intercepted = 'X'.
      ELSE.
        CLEAR o_is_intercepted.
      ENDIF.
    ENDIF.
    PERFORM deq_tbtco_entry
      USING i_job-jobname i_job-jobcount
      CHANGING p_rc.
  ELSE.
    IF wa_context-ctxttext NS 'X'.
      o_is_intercepted = 'X'.
    ELSE.
      CLEAR o_is_intercepted.
    ENDIF.
  ENDIF.

ENDFORM.                    "intercept_job

*---------------------------------------------------------------------*
*  FORM check_icpt_crit_job
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_EXEC_JOBNAME
*  -->  P_EXEC_JOBCOUNT
*  -->  P_EXEC_SDLUNAME
*  -->  P_IS_INTERCEPTED
*---------------------------------------------------------------------*
* This form checks if the given job fits at least to one of criteria in
* the intercept criteria table (TBCICPT1).
* If it does, then the p_is_intercepted flag is checked.
FORM check_icpt_crit_job
    USING p_exec_jobname      LIKE tbtcs-jobname
          p_exec_sdluname     LIKE tbtcs-sdluname
          p_exec_authckman    LIKE tbtcs-authckman
    CHANGING p_is_intercepted TYPE c.

* Data declaration
  DATA: wa_criteria         LIKE tbcicpt1.

* Function code
  CLEAR p_is_intercepted.

  DATA: icpt_state.
  CALL FUNCTION 'BP_NEW_FUNC_CHECK'
    EXPORTING
      interception_action = 'r'
    IMPORTING
      interception        = icpt_state
    EXCEPTIONS
      wrong_action        = 1
      no_authority        = 2
      OTHERS              = 3.

  IF sy-subrc <> 0 OR icpt_state IS INITIAL.
    EXIT.
  ENDIF.

  SELECT * FROM tbcicpt1 INTO wa_criteria.
    PERFORM correct_criteria_fields USING wa_criteria.
    IF p_exec_jobname CP wa_criteria-jobname AND
       p_exec_sdluname CP wa_criteria-jobcreator AND
       p_exec_authckman CP wa_criteria-clnt.
*    CALL 'WriteTrace'
*      ID 'CALL' FIELD 'current_scheduler'
*      ID 'PAR1' FIELD 'This job should be intercepted'
*      ID 'PAR2' FIELD p_exec_jobname.
      p_is_intercepted = 'X'.
      EXIT.
    ENDIF.
  ENDSELECT.

ENDFORM.                    "check_icpt_crit_job


*&---------------------------------------------------------------------*
*&      Form  correct_criteria_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_CRITERIA  text
*----------------------------------------------------------------------*
FORM correct_criteria_fields
  USING i_criteria TYPE tbcicpt1.

  IF i_criteria-jobname CA '%'.
    TRANSLATE i_criteria-jobname USING '%*'.
  ENDIF.
  TRANSLATE i_criteria-jobname TO UPPER CASE.            "#EC TRANSLANG

  IF i_criteria-clnt CA '%'.
    TRANSLATE i_criteria-clnt USING '%*'.
  ENDIF.
  TRANSLATE i_criteria-clnt TO UPPER CASE.               "#EC TRANSLANG

  IF i_criteria-jobcreator CA '%'.
    TRANSLATE i_criteria-jobcreator USING '%*'.
  ENDIF.
  TRANSLATE i_criteria-jobcreator TO UPPER CASE.         "#EC TRANSLANG

ENDFORM.                    " correct_criteria_fields
*&---------------------------------------------------------------------*
*&      Form  correct_status_interception
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBNAME  text
*      -->P_JOBCOUNT  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM correct_status_interception  USING    p_jobname
                                           p_jobcount
                                  CHANGING p_status.
  DATA: wa_tbtccntxt LIKE tbtccntxt.

  SELECT SINGLE * FROM tbtccntxt INTO wa_tbtccntxt
    WHERE
      jobname  = p_jobname AND
      jobcount = p_jobcount AND
      ctxttype = 'INTERCEPTED'.
  IF sy-subrc = 0.
    IF p_status = 'P' AND
       NOT wa_tbtccntxt-ctxttext = 'X'.
      p_status = 'I'.
    ENDIF.
  ENDIF.

ENDFORM.                    " correct_status_interception
*&---------------------------------------------------------------------*
*&      Form  check_functionality_flag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PARENTCHILD_ACTION  text
*      -->P_0026   text
*      <--P_PARENTCHILD  text
*      <--P_RC  text
*
* Return codes:
* 0 - no errors
* 1 - wrong action code
* 2 - no authority for switching interception or parent_child
* functionality on/off
*----------------------------------------------------------------------*
FORM check_functionality_flag
    USING    p_action             TYPE char1
             functionality_name LIKE btcoptions-btcoption
    CHANGING value              TYPE char1
             rc                 TYPE i.

  DATA: wa_btcoptions LIKE btcoptions.
  DATA: action LIKE p_action.
  CONSTANTS:
    c_read1       TYPE char1 VALUE 'R',
    c_read2       TYPE char1 VALUE 'r',
    c_set1        TYPE char1 VALUE 'S',
    c_set2        TYPE char1 VALUE 's',
    c_set_30      TYPE char1 VALUE '3',
    c_clear1      TYPE char1 VALUE 'C',
    c_clear2      TYPE char1 VALUE 'c'.

  CLEAR rc.
  action = p_action.

  IF action IS INITIAL.
    action = c_read1.
  ENDIF.

  CASE action.
    WHEN c_read1 OR c_read2.
* read value
      SELECT SINGLE * FROM btcoptions INTO wa_btcoptions
        WHERE btcoption = functionality_name.
      IF sy-subrc = 0.
        IF wa_btcoptions-value1 = 'ON'.
          value = 'X'.
        ELSEIF wa_btcoptions-value1 = 'ON_30'.
          value = '3'.
        ELSE.
          CLEAR value.
        ENDIF.
      ELSE.
        CLEAR value.
      ENDIF.

    WHEN c_set1 OR c_set2 OR c_set_30.
* set value.
* check authorization
      AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc <> 0.
        IF functionality_name = 'PARENTCHILD'.
          AUTHORITY-CHECK OBJECT 'S_BTCH_ADM'
                   ID 'BTCADMIN' FIELD 'Y'.
          IF sy-subrc <> 0.
            rc = 2.
            EXIT.
          ENDIF.
        ELSE.
          rc = 2.
          EXIT.
        ENDIF.
      ENDIF.
      DELETE FROM btcoptions WHERE btcoption = functionality_name.
      wa_btcoptions-btcoption = functionality_name.
      IF action = c_set_30.
* set value with XBP 3.0 mark.
        wa_btcoptions-value1 = 'ON_30'.
        value = '3'.
      ELSE.
        wa_btcoptions-value1 = 'ON'.
        value = 'X'.
      ENDIF.
      GET TIME.
      CONCATENATE sy-uname ',' space sy-uzeit INTO wa_btcoptions-value2.
      INSERT INTO btcoptions VALUES wa_btcoptions.

    WHEN c_clear1 OR c_clear2.
* clear value
* check authorization
      AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc <> 0.
        IF functionality_name = 'PARENTCHILD'.
          AUTHORITY-CHECK OBJECT 'S_BTCH_ADM'
                   ID 'BTCADMIN' FIELD 'Y'.
          IF sy-subrc <> 0.
            rc = 2.
            EXIT.
          ENDIF.
        ELSE.
          rc = 2.
          EXIT.
        ENDIF.
      ENDIF.
      DELETE FROM btcoptions WHERE btcoption = functionality_name.
      CLEAR value.

    WHEN OTHERS.
      value = action.
      rc = 1.

  ENDCASE.

ENDFORM.                    "check_functionality_flag


*&--------------------------------------------------------------------*
*&      Form  get_active_servers
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_SERVERS  text
*---------------------------------------------------------------------*
FORM get_active_servers TABLES p_servers STRUCTURE msxxlist.

  DATA: batch LIKE msxxlist-msgtypes VALUE 8.
  FREE p_servers.

  DATA: opcode_mslst_get TYPE x VALUE 1.
  CALL 'ThSysInfo' ID 'OPCODE' FIELD opcode_mslst_get
                   ID 'TAB'    FIELD p_servers-*sys*
                   ID 'TYPES'  FIELD batch.

ENDFORM.                    "get_active_servers

*&---------------------------------------------------------------------*
*&      Form  check_if_free_and_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SERVER  text
*      -->P_MESSAGE  text
*      -->P_RC  text
*
* p_rc:
* 0: The given server has free batch WPs. Enqueue created.
* 1: All batch WPs are occupied or will be occupied very soon by the
*    jobs, which are in the dispatcher queue.
* 2: Server/WP cannot be enqueued.
* 3: No free batch WPs.
* 4. Server group does not exist or contains no servers.
*----------------------------------------------------------------------*
FORM check_if_free_and_lock
  USING    p_jobclass    LIKE tbtco-jobclass
  CHANGING p_server      LIKE tbtco-execserver
           p_servergroup LIKE tbtco-tgtsrvgrp
           p_rc          TYPE i.

  DATA: server_list LIKE msxxlist OCCURS 0 WITH HEADER LINE.
  DATA: batch LIKE msxxlist-msgtypes VALUE 8.
  DATA: lock_server LIKE tbtco-jobname.
  DATA: myname LIKE tbtco-execserver.
  DATA: servergroup TYPE bpsrvgrp.
  DATA: server_group_list TYPE TABLE OF bpsrvline.
  DATA: wa_server_group_list TYPE bpsrvline.
  DATA: tmp_grp TYPE REF TO cl_bp_server_group.
  DATA: numlines TYPE i.

  CLEAR p_rc.
  FREE server_list.
  CALL FUNCTION 'TH_SERVER_LIST'
    EXPORTING
      services = batch
    TABLES
      list     = server_list
    EXCEPTIONS
      OTHERS   = 99.
  IF sy-subrc <> 0.
    p_rc = rc_cannot_get_all_servers.
    EXIT.
  ENDIF.

  CLEAR numlines.
  DESCRIBE TABLE server_list LINES numlines.
  IF numlines = 0.
    p_rc = rc_cannot_get_all_servers.
    EXIT.
  ENDIF.

  IF p_server IS INITIAL OR p_server = space.
* Check server groups
    p_rc = rc_cannot_read_server_group.
    PERFORM change_table_order TABLES server_list.
    CLASS cl_bp_const DEFINITION LOAD.
    IF NOT p_servergroup IS INITIAL.
      PERFORM map_id_to_name USING p_servergroup
                                servergroup.
      IF NOT servergroup IS INITIAL OR servergroup <> space.
        CALL METHOD cl_bp_group_factory=>make_group_by_name
          EXPORTING
            i_name          = servergroup
            i_only_existing = cl_bp_const=>true
          RECEIVING
            o_grp_instance  = tmp_grp.
        IF tmp_grp IS INITIAL.
          EXIT.
        ELSE.
          CALL METHOD tmp_grp->get_list
            RECEIVING
              o_list = server_group_list.

          PERFORM project_table TABLES server_list server_group_list.
        ENDIF.
      ELSE.
*   d023157    14.1.2011
*   the case that the group does not exist any more, must be handled !!
        FREE server_list.
        p_rc = rc_cannot_read_server_group.
        EXIT.
      ENDIF.
    ELSE.
* Does the default server group exist?
      CALL METHOD cl_bp_group_factory=>make_group_by_name
        EXPORTING
          i_name          = sap_default_srvgrp
          i_only_existing = cl_bp_const=>true
        RECEIVING
          o_grp_instance  = tmp_grp.
      IF NOT tmp_grp IS INITIAL.
        CALL METHOD tmp_grp->get_list
          RECEIVING
            o_list = server_group_list.

        PERFORM project_table TABLES server_list server_group_list.
      ENDIF.
    ENDIF.

    p_rc = rc_tgt_host_chk_has_failed.

    LOOP AT server_list.
      myname = server_list-name.
      PERFORM check_if_server_free_and_lock
        USING myname p_jobclass
        CHANGING p_rc.
      IF p_rc <> 0 AND
         p_rc <> rc_server_cannot_be_enqueued.
        lock_server = server_list-name.
        CALL FUNCTION 'DEQUEUE_ESTBTCS'
          EXPORTING
            jobname  = lock_server
            jobcount = 'SERVLOCK'.
      ENDIF.
      IF p_rc = 0.
        p_server = server_list-name.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    READ TABLE server_list WITH KEY name = p_server.
    IF sy-subrc = 0.
      myname = p_server.
      PERFORM check_if_server_free_and_lock
        USING myname p_jobclass
        CHANGING p_rc.
      IF p_rc <> 0 AND
         p_rc <> rc_server_cannot_be_enqueued.
        lock_server = p_server.
        CALL FUNCTION 'DEQUEUE_ESTBTCS'
          EXPORTING
            jobname  = lock_server
            jobcount = 'SERVLOCK'.
      ENDIF.
    ELSE.
      p_rc = rc_tgt_host_chk_has_failed.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_if_free_and_lock

*&---------------------------------------------------------------------*
*&      Form  check_if_server_free_and_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SERVER  text
*      -->P_MESSAGE  text
*      -->P_RC  text
*
* p_rc:
* 0: The given server has free batch WPs. Enqueue created.
* rc_disp_queue_too_long:
*       All batch WPs are occupied or will be occupied very soon by the
*       jobs, which are in the dispatcher queue.
* rc_server_cannot_be_enqueued: Server/WP cannot be enqueued.
* rc_no_free_btcwps:            No free batch WPs.
* + return codes from get_num_a_btcwps
*----------------------------------------------------------------------*
FORM check_if_server_free_and_lock
  USING    p_server   LIKE tbtco-execserver
           p_jobclass LIKE tbtco-jobclass
  CHANGING p_rc       TYPE i.

  DATA: index              TYPE i.
  DATA: wp                 TYPE wpinfo.
  DATA: wp_tab             TYPE TABLE OF wpinfo WITH HEADER LINE.
  DATA: diarec             LIKE pfdiarec.
  DATA: num_of_free_btcwps TYPE i.
  DATA: num_of_a_btcwps    TYPE i.
  DATA: free_btc_exist     VALUE 'X'.

  CLEAR p_rc.
  DATA: lock_jobname LIKE tbtco-jobname.
  lock_jobname = p_server.

  DATA: wait.
  wait = 'X'.

  CALL FUNCTION 'ENQUEUE_ESTBTCS'
    EXPORTING
      jobname        = lock_jobname
      jobcount       = 'SERVLOCK'
      _wait          = wait
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Schon gesperrt
    p_rc = rc_server_cannot_be_enqueued.
    EXIT.
  ENDIF.

  PERFORM get_num_of_free_btcwps
    USING p_server p_jobclass
    CHANGING num_of_free_btcwps p_rc.
  IF p_rc <> 0.
    EXIT.
  ENDIF.

  IF num_of_free_btcwps <= 0.
    p_rc = rc_no_free_btcwps.
    EXIT.
  ENDIF.

ENDFORM.                    " check_if_free_and_lock

*&---------------------------------------------------------------------*
*&      Form  CHECK_AND_START_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOB_HEAD  text
*      -->P_INSTANCE_NAME  text
*      -->P_DIALOG  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM check_and_start_job
    USING p_job_head      STRUCTURE tbtcjob
          p_instance_name LIKE tbtcstrt-instname
          p_dialog        LIKE btch0000-char1
          p_direct_start  LIKE btch0000-char1
          p_old_status    LIKE tbtco-status
          p_rc            TYPE i.

  DATA BEGIN OF i_th_msg.
          INCLUDE STRUCTURE tbtcm.
  DATA END OF i_th_msg.

  DATA: i_server LIKE tbtcstrt-instname.
  data: created_tbtcy.

  CLEAR p_rc.
  IF p_job_head-tgtsrvgrp IS INITIAL.
    i_server = p_instance_name.
  ENDIF.

* note 1650982    9.11.2011    d023157
* unfortunately, after enqueueing the job, the existence has not
* been checked yet. So we do it here, otherwise we send a start
* message for a not-existing job, which will lead to a dump
* LOAD_PROGRAM_NOT_FOUND, because in the kernel lateron
* SAPMSSY2 is called with an empty dynum (dynpro number).

  select single * from tbtco where
                             jobname  = p_job_head-jobname
                         and jobcount = p_job_head-jobcount.

  if sy-subrc ne 0.

*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBG'
*           ID 'DATA' FIELD p_job_head-jobname.
*
*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBD'
*           ID 'DATA' FIELD p_job_head-jobname.
*
*     CALL 'C_WRITE_SYSLOG_ENTRY'
*           ID 'TYP' FIELD ' '
*           ID 'KEY' FIELD 'EBD'
*           ID 'DATA' FIELD p_job_head-jobcount.

     p_rc = rc_job_cannot_be_started.
     exit.
  endif.

* end  note 1650982 *******************************************

  PERFORM check_if_free_and_lock
    USING p_job_head-jobclass
    CHANGING i_server p_job_head-tgtsrvgrp p_rc.

  IF p_rc = 0.
    MOVE-CORRESPONDING p_job_head TO i_th_msg.

    GET TIME.
    UPDATE tbtco SET strtdate = sy-datum
                     strttime = sy-uzeit
                     reaxserver = i_server
                     status = btc_ready
                 WHERE jobname = p_job_head-jobname AND
                       jobcount = p_job_head-jobcount.

* new treatment for 'ready'-jobs: write TBTCY entry here
    perform make_tbtcy using i_th_msg
                             i_server
                             tbtco-execserver
                             tbtco-tgtsrvgrp
                             created_tbtcy.

    CALL FUNCTION 'DB_COMMIT'
      EXPORTING
        IV_DEFAULT       = ABAP_TRUE.

    CALL 'SendSubmitReq'
      ID 'TMSG' FIELD i_th_msg
      ID 'TSYS' FIELD i_server.

    IF sy-subrc <> 0.
* Job konnte nicht gestartet werden

* !!!! Attention !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*  d023157    15.4.2013   ready jobs restart mechanism **********
*  I would say: If created_tbtcy = Y, we can skip the complete branch,
*  which deals with the failure of sending the start message.
*
*  Reason:
*  The TBTCY entry has already been created. This is
*  logically equivalent to successfully sending the start message.
*  Even if sending the the start message failed technically, the
*  job is subject to the restart mechanism and we can be behave here,
*  as if sending the start message succeeded.
*  So the following actions are not needed and therefore commented out
************************************************************************
************************************************************************

      if created_tbtcy ne 'Y'.

         DATA: job_id(41).
         CONCATENATE p_job_head-jobname '/' p_job_head-jobcount
                     INTO job_id.

         IF p_dialog EQ btc_yes.
            MESSAGE s122 WITH job_id.
         ENDIF.

         CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
               ID 'KEY'  FIELD job_start_failed
               ID 'DATA' FIELD p_job_head-jobname.
         CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
               ID 'KEY'  FIELD job_start_failed
               ID 'DATA' FIELD p_job_head-jobcount.

         IF p_old_status = btc_scheduled AND
            NOT p_direct_start IS INITIAL.
           UPDATE tbtco SET status = btc_scheduled
                   WHERE jobname = p_job_head-jobname AND
                         jobcount = p_job_head-jobcount.

           CALL FUNCTION 'DB_COMMIT'.
           p_rc = rc_job_cannot_be_started.
         ELSE.
           PERFORM transform_job_to_timebased
               USING p_job_head.
         ENDIF.

      endif.  " if created_tbtcy ne 'Y'.

    ELSE.   " SendSubmitReq  hat geklappt

***** d023157     30.1.2004   wg. Lastverteilung **********************

*    In der globalen internen Tabelle server_list_global registrieren,
*    auf welchem Server dieser Sofortstart durchgeführt wurde.
      READ TABLE server_list_global WITH KEY name = i_server.
      IF sy-subrc = 0.
* der Server muß natürlich einen Eintrag in server_list_global haben,
* aber vorsichtshalber noch mal sy-subrc abfragen
        server_list_global-cnt = server_list_global-cnt + 1.
        MODIFY server_list_global INDEX sy-tabix.
      ENDIF.

* last_server brauchen wir später nur noch als Merker dafür, daß
* schon mindestens ein Job aus diesem Prozess gestartet wurde.
      last_server = i_server.

******Ende  Lastverteilung  *******************************************

    ENDIF.

    DATA: lock_server LIKE tbtco-jobname.
    lock_server = i_server.
    CALL FUNCTION 'DEQUEUE_ESTBTCS'
      EXPORTING
        jobname  = lock_server
        jobcount = 'SERVLOCK'.
  ELSE.
* Es gibt keine Möglichleit den Job sofort zu starten
    IF p_old_status = btc_scheduled AND
       NOT p_direct_start IS INITIAL.
      UPDATE tbtco SET status = btc_scheduled
                 WHERE jobname = p_job_head-jobname AND
                       jobcount = p_job_head-jobcount.
      DELETE FROM tbtcs WHERE jobname = p_job_head-jobname AND
                       jobcount = p_job_head-jobcount.
      CALL FUNCTION 'DB_COMMIT'.
      p_rc = rc_job_cannot_be_started.
    ELSE.
      PERFORM transform_job_to_timebased
          USING p_job_head.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_AND_START_JOB

*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_JOB_TO_TIMEBASED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBHEAD  text
*----------------------------------------------------------------------*
FORM transform_job_to_timebased
  USING p_jobhead LIKE tbtcjob.

  DATA: wa_tbtcs LIKE tbtcs.
  GET TIME.
  p_jobhead-sdlstrtdt = sy-datum.
  p_jobhead-sdlstrttm = sy-uzeit.
  p_jobhead-status = 'S'.
  p_jobhead-strtdate = no_date.
  p_jobhead-strttime = no_time.
  p_jobhead-enddate = no_date.
  p_jobhead-endtime = no_time.
  CLEAR p_jobhead-jobgroup.
  CLEAR p_jobhead-wpnumber.
  CLEAR p_jobhead-wpprocid.
  CLEAR p_jobhead-joblog.
  CLEAR p_jobhead-reaxserver.
  CLEAR p_jobhead-btcsysreax.

  MOVE-CORRESPONDING p_jobhead TO wa_tbtcs.
  SELECT SINGLE * FROM tbtcs
      WHERE jobname  = p_jobhead-jobname AND
            jobcount = p_jobhead-jobcount.
  IF sy-subrc = 0.
    UPDATE tbtcs FROM wa_tbtcs.
  ELSE.
    INSERT tbtcs FROM wa_tbtcs.
  ENDIF.
  UPDATE tbtco FROM p_jobhead.
  CALL FUNCTION 'DB_COMMIT'.

ENDFORM.                    " TRANSFORM_JOB_TO_TIMEBASED

*&--------------------------------------------------------------------*
*&      Form  get_num_of_free_btcwps
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_SERVER   text
*      -->P_JOBCLASS text
*      -->P_NUM_OF_FRtextTCWPS
*      -->P_RC       text
*---------------------------------------------------------------------*
FORM get_num_of_free_btcwps
  USING    p_server             LIKE tbtco-execserver
           p_jobclass           LIKE tbtco-jobclass
  CHANGING p_num_of_free_btcwps TYPE i
           p_rc                 TYPE i.

* 26.6.2014   d023157
* due to int. message 1238860 2014 and cust. message 576917 / 2014
*
* the routine gets the number of free Batch WPs on a certain server -
* with regard to the jobclass.
* That means: If the jobclass is A, all free batch WPs may be used.
* Otherwise we must subtract the number of reserved class A WPs.

data: server_conv1 type msname2.
data: server_conv2 type SPFID-APSERVER.

data: nr_class_a_char   type char40.
data: nr_class_a_num(5) type n.
data: nr_class_a_int    type i.

server_conv1 = p_server.
server_conv2 = p_server.

CALL FUNCTION 'TH_COUNT_WPS'
  EXPORTING
    SERVER              = server_conv1
  IMPORTING
    FREE_BTC_WPS        = p_num_of_free_btcwps
  EXCEPTIONS
    FAILED              = 1
    OTHERS              = 2
            .
IF SY-SUBRC <> 0.
   p_rc = rc_tgt_host_chk_has_failed.
   EXIT.
ENDIF.

* read number of reserved class A work processes, if jobclass is not A
* if jobclass is A, we set the number of reserverd processes to 0, because
* then all BTC WP are available for the job.
if p_jobclass ne btc_jobclass_a.

   CALL FUNCTION 'RZL_STRG_READ_C'
     EXPORTING
       NAME                 = class_a_wp_ident
       SRVNAME              = server_conv2
     IMPORTING
       VALUE                = nr_class_a_char
     EXCEPTIONS
       ARGUMENT_ERROR       = 1
       NOT_FOUND            = 2
       SEND_ERROR           = 3
       OTHERS               = 4
          .
   IF SY-SUBRC <> 0.
* if reading the number of class A processes fails, we rather set
* the number to 0 instead of aborting here
      nr_class_a_int = 0.
   else.
      nr_class_a_num = nr_class_a_char.
      nr_class_a_int = nr_class_a_num.
   endif.

else.

   nr_class_a_int = 0.

endif.

p_num_of_free_btcwps = p_num_of_free_btcwps - nr_class_a_int.

if p_num_of_free_btcwps < 0.
   p_num_of_free_btcwps = 0.
endif.

ENDFORM.                               " get_num_of_free_btcwps

*&--------------------------------------------------------------------*
*&      Form  init_server_list
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_TAB      text
*---------------------------------------------------------------------*
FORM init_server_list
    TABLES p_tab STRUCTURE msxxlist.

* this form routine changes the order of the internal server_list_global
* randomly. The order of the table p_tab, which describes a subset of
* server_list_global, will then be changed accordingly.

  DATA:
    num_of_servers  TYPE i,
    random_num      TYPE i,
    time_stamp      TYPE timestampl,
    time_string(22) TYPE c.

  DATA:
    wp_nr  TYPE wpinfo-wp_index,
    c_wpnr(10),
    wp_pid TYPE wpinfo-wp_pid,
    add    TYPE i,
    rc     LIKE sy-subrc.

  CALL FUNCTION 'TH_GET_OWN_WP_NO'
    IMPORTING
      subrc  = rc
      wp_index  = wp_nr
      wp_pid = wp_pid.
  IF rc = 0.
*   Korrektur, da die wp_nr oder wp_pid wohl nicht
*   immer numerisch sind:
    c_wpnr = wp_nr.
    IF c_wpnr CO '0123456789 ' AND NOT c_wpnr CO ' '.
      add = wp_nr.
    ENDIF.
    IF wp_pid CO '0123456789 ' AND NOT wp_pid CO ' '.
      add = add + wp_pid.
    ENDIF.
  ENDIF.

  CLEAR server_list_global. FREE server_list_global.
  DESCRIBE TABLE p_tab LINES num_of_servers.

  WHILE num_of_servers > 0.
    IF num_of_servers = 1.
      random_num = 1.
    ELSE.
      GET TIME STAMP FIELD time_stamp.
      time_string = time_stamp.
      time_string = time_string+9(9).
      random_num = time_string * 1000 + add.
      random_num = random_num MOD num_of_servers + 1.
    ENDIF.

    READ TABLE p_tab INDEX random_num.
    MOVE-CORRESPONDING p_tab TO server_list_global.
    server_list_global-cnt = 0.
    APPEND server_list_global.

    DELETE p_tab INDEX random_num.

    num_of_servers = num_of_servers - 1.
  ENDWHILE.

* Jetzt noch die Reihenfolge von server_list_global
* auf p_tab projezieren.
  LOOP AT server_list_global.
    MOVE-CORRESPONDING server_list_global TO p_tab.
    APPEND p_tab.
  ENDLOOP.

ENDFORM.                    "init_server_list

*&--------------------------------------------------------------------*
*&      Form  change_table_order
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_TAB      text
*---------------------------------------------------------------------*
FORM change_table_order
  TABLES p_tab STRUCTURE msxxlist.

  DATA:
    new_global_list LIKE server_load_info OCCURS 0 WITH HEADER LINE,
    exit_flag(1)    TYPE c,
    num             TYPE i.

  CLEAR exit_flag.
  LOOP AT p_tab.
    READ TABLE server_list_global WITH KEY name = p_tab-name.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING server_list_global TO new_global_list.
      APPEND new_global_list.
      DELETE server_list_global WHERE name = p_tab-name.
    ELSE.
      PERFORM init_server_list TABLES p_tab.
      exit_flag = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF exit_flag IS INITIAL.
    DESCRIBE TABLE server_list_global LINES num.
    IF num <> 0.
      PERFORM init_server_list TABLES p_tab.
    ELSE.
      CLEAR server_list_global. FREE server_list_global.
      APPEND LINES OF new_global_list TO server_list_global.
      SORT server_list_global BY cnt ASCENDING.
      CLEAR p_tab. FREE p_tab.
      LOOP AT server_list_global.
        p_tab-name = server_list_global-name.
        APPEND p_tab.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    "change_table_order

*&--------------------------------------------------------------------*
*&      Form  project_table
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_VALID    text
*      -->P_SUB      text
*---------------------------------------------------------------------*
FORM project_table
    TABLES p_valid STRUCTURE msxxlist
           p_sub   STRUCTURE bpsrvline.

  DATA:
    temp LIKE msxxlist OCCURS 5 WITH HEADER LINE.

  LOOP AT p_valid.
    READ TABLE p_sub WITH KEY appsrvname = p_valid-name.
    IF sy-subrc = 0.
      temp-name = p_valid-name.
      APPEND temp.
    ENDIF.
  ENDLOOP.

  FREE p_valid.
  APPEND LINES OF temp TO p_valid.

ENDFORM.                    "project_table

*****************************************************************
* d023157     27.8.2004      note <xxx>
*
* if job has been started by a BAPI, retrieve event information.
* Formerly, the event information (if there were any), got lost.
* The job could not read its event info via JOB_GET_RUNTIME_INFO
*
*****************************************************************

FORM get_eventinfo USING  id LIKE tbtco-eventid
                          parm LIKE tbtco-eventparm
                          info TYPE c.

  IMPORT evid   = id   FROM MEMORY ID 'EVENTID_ICP'.
  IF sy-subrc = 0.
    info = 'X'.
    IMPORT evparm = parm FROM MEMORY ID 'EVENTPARM_ICP'.
    FREE MEMORY ID 'EVENTID_ICP'.
    FREE MEMORY ID 'EVENTPARM_ICP'.
  ENDIF.

ENDFORM.                    "get_eventinfo


** d023157  12.2.2008  due to requirement from internal project list
*********************************************************************
** the following routine checks, if the servers contained in a
** server group are alive at all.
** This is espacially important in regards to the default server group.
**
** parameters:  group_name  - name of the group to be checked
**              restr_time  - the check will only be performed every
**                            20 minutes, if this flag is 'X'.
**                            This makes sense, if the call comes from
**                            the time scheduler.
**
**              rc          - 0 : all servers of the group are alive
**
**                          - 1 : no check due to time restriction
**
**                          - 2 : at least one server is alive AND
**                                at least one server is not alive
**                                ==> appropriate syslog message
**
**                          - 3 : no server of the group is alive
**                                ==> appropriate syslog message
**
**                          - 4 : group does not exist
**
**                          - 99 : other error
**
*********************************************************************

FORM check_server_group USING    group_name TYPE bpsrvgrp
                                 restr_time TYPE c
                        CHANGING rc TYPE i.

  TABLES: btcoptions.

  DATA: btc_servers LIKE msxxlist OCCURS 0 WITH HEADER LINE.

  DATA: grp_server_list TYPE bpsrventry.

  DATA: tmp_grp TYPE REF TO cl_bp_server_group.

  DATA: nr_grp_srv      TYPE i.
  DATA: nr_act_grp_srv  TYPE i.

  DATA: last_date       LIKE sy-datum.
  DATA: last_time       LIKE sy-uzeit.
  DATA: diff_sec        TYPE i.
  DATA: current_time    LIKE sy-uzeit.
  DATA: no_btc_servers  TYPE i.
  CONSTANTS: batch LIKE msxxlist-msgtypes VALUE 8.

  rc = 0.

* shall check be performed at all ?

  IF restr_time = 'X'.
    GET TIME.
    current_time = sy-uzeit.
    IF current_time+2(2) NE '00' AND current_time+2(2) NE '20'
                             AND current_time+2(2) NE '40'.

      rc = 1.
      EXIT.
    ENDIF.
  ENDIF.

* Read all batch servers

  CALL FUNCTION 'TH_SERVER_LIST'
    EXPORTING
      services       = batch
    TABLES
      list           = btc_servers
    EXCEPTIONS
      no_server_list = 1
      OTHERS         = 99.

  IF sy-subrc NE 0.
    rc = 99.
    EXIT.
  ENDIF.

  DESCRIBE TABLE btc_servers LINES no_btc_servers.
  IF no_btc_servers = 0.
    rc = 99.
    EXIT.
  ENDIF.

* Read all servers of the specified server group

  TRY.
      CALL METHOD cl_bp_group_factory=>make_group_by_name
        EXPORTING
          i_name          = group_name
          i_only_existing = 'X'
        RECEIVING
          o_grp_instance  = tmp_grp.

      IF tmp_grp IS INITIAL.
        rc = 4.
        EXIT.
      ENDIF.

      CALL METHOD tmp_grp->get_list
        RECEIVING
          o_list = grp_server_list.

    CATCH cx_root.
      rc = 99.
      EXIT.

  ENDTRY.

  DESCRIBE TABLE grp_server_list LINES nr_grp_srv.

* Now we calculate the intersection ("Schnittmenge") of
* the set of group servers and the set of active batch servers

  PERFORM project_table TABLES btc_servers grp_server_list.

  DESCRIBE TABLE btc_servers LINES nr_act_grp_srv.

  IF nr_act_grp_srv = 0.
* no server of the server group is active !!!!
    rc = 3.
    EXIT.
  ENDIF.

  IF nr_act_grp_srv < nr_grp_srv.
* at least one server of the group is active AND
* at least one server of the group is not active
    rc = 2.
    EXIT.
  ENDIF.


ENDFORM.                    "check_server_group
*---------------------------------------------------------------------*
*  FORM check_icpt_crit_job_30
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_TBTCO
*  -->  P_IS_INTERCEPTED
*---------------------------------------------------------------------*
* This form checks if the given job fits at least to one of criteria in
* the intercept criteria table (TBCICPT1) or the Criteria Manager
* depending of the XBP setup.
* If it does, then the p_is_intercepted flag is checked.
FORM check_icpt_crit_job_30
    USING    p_tbtco          TYPE tbtco
    CHANGING p_is_intercepted TYPE c.

* Data declaration
  DATA: wa_criteria         LIKE tbcicpt1.

* Function code
  CLEAR p_is_intercepted.

  DATA: icpt_state.
  CALL FUNCTION 'BP_NEW_FUNC_CHECK'
    EXPORTING
      interception_action = 'r'
    IMPORTING
      interception        = icpt_state
    EXCEPTIONS
      wrong_action        = 1
      no_authority        = 2
      OTHERS              = 3.

  IF sy-subrc <> 0 OR icpt_state IS INITIAL.
    EXIT.
  ENDIF.

  IF icpt_state = 'X'.
    SELECT * FROM tbcicpt1 INTO wa_criteria.
      PERFORM correct_criteria_fields USING wa_criteria.
      IF p_tbtco-jobname CP wa_criteria-jobname AND
         p_tbtco-sdluname CP wa_criteria-jobcreator AND
         p_tbtco-authckman CP wa_criteria-clnt.
        p_is_intercepted = 'X'.
        EXIT.
      ENDIF.
    ENDSELECT.

  ELSEIF icpt_state = '3'.
* Check interception criteria using Criteria Manager
    DATA:    lr_criteria_profile   TYPE REF TO if_sbti_criteria_profile,
             lr_criteria_exception TYPE REF TO cx_sbti_exception,
             lv_error_text         TYPE string.
    TRY.
        CALL METHOD cl_sbti_criteria_manager=>get_instance_active_profile
          EXPORTING
            i_profiletype = if_sbti_criteria_type=>c_interception
          RECEIVING
            r_profile     = lr_criteria_profile.

        CALL METHOD lr_criteria_profile->if_sbti_criteria_checker~criteria_suit
          EXPORTING
            i_data  = p_tbtco
          RECEIVING
            r_match = p_is_intercepted.

      CATCH cx_sbti_exception INTO lr_criteria_exception.
        CALL METHOD lr_criteria_exception->get_text
          RECEIVING
            result = lv_error_text.
    ENDTRY.

  ENDIF.

ENDFORM.                    "check_icpt_crit_job_30

*********************************************************************************
* d023157   18.11.2010   EPP for Batch Jobs
*********************************************************************************
FORM get_and_save_epp USING p_jobname  LIKE tbtco-jobname
                            p_jobcount LIKE tbtco-jobcount.

  DATA: subrc(3).
  DATA: wp_trc_lvl TYPE i.

  CALL FUNCTION 'BP_EPP_GET_AND_SAVE_WITH_JOB'
    EXPORTING
      i_jobname                 = p_jobname
      i_jobcount                = p_jobcount
    EXCEPTIONS
      error_getting_epp         = 1
      error_inserting_into_db   = 2
      entry_in_db_already_exist = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
* if an error occurs, we will continue, but we write
* a message into the WP trace

    PERFORM get_batch_trace_level CHANGING wp_trc_lvl.
    IF wp_trc_lvl = 0.
      EXIT.
    ENDIF.

    WRITE sy-subrc TO subrc.

    CALL 'WriteTrace'
       ID 'CALL' FIELD 'BP_EPP_GET_AND_SAVE_WITH_JOB'       "#EC NOTEXT
       ID 'PAR1' FIELD 'Error:'
       ID 'PAR2' FIELD p_jobname
       ID 'PAR3' FIELD p_jobcount
       ID 'PAR4' FIELD 'sy-subrc ='
       ID 'PAR5' FIELD subrc .

  ENDIF.

ENDFORM.                    "get_and_save_epp

*********************************************************************************
* d023157      18.11.2010
*********************************************************************************
FORM get_batch_trace_level CHANGING p_lvl TYPE i.

  STATICS lvl_save TYPE i.
  STATICS trc_already_known.

  TYPE-POOLS thfb.
  DATA: trc TYPE thfb_trace.

  IF trc_already_known = 'X'.
    p_lvl = lvl_save.
    EXIT.
  ENDIF.


  CALL FUNCTION 'TH_GET_WP_TRACE'
*   EXPORTING
*     WP_ID         = -1
      IMPORTING
        trc           = trc
      EXCEPTIONS
        OTHERS        = 99       ##FM_SUBRC_OK.


  CASE  trc-level(1) .

    WHEN  '1'.
      lvl_save = 1.

    WHEN  '2'.
      lvl_save = 2.

    WHEN  '3'.
      lvl_save = 3.

    WHEN OTHERS.
      lvl_save = 0.

  ENDCASE.

  trc_already_known = 'X'.
  p_lvl = lvl_save.

ENDFORM.                    "get_batch_trace_level


*********************************************************************************
*  d023157   23.7.2010    note 1491633
*
*  form is_server_passive
*
*      p_rc = N:  server is not passive or checking not possible
*      p_rc = Y:  server is in state passive
*
*********************************************************************************

** this routine is in SAPMSSY2 now

*form is_server_passive using p_server type msname2
*                             p_rc     type c.
*
*data: all_servers    LIKE msxxlist OCCURS 5 WITH HEADER LINE.
*data: all_service    LIKE msxxlist-msgtypes VALUE 25.
*data: passive        LIKE msxxlist-state VALUE 2.
*
** the default is N (i.e. not passive)
*p_rc = 'N'.
*
*CALL FUNCTION 'TH_SERVER_LIST'
*    EXPORTING
*       services       = all_service
*       active_server  = 0
*    TABLES
*       list           = all_servers
*    EXCEPTIONS
*       no_server_list = 1
*       OTHERS         = 2.
*
*if sy-subrc = 0.
*    READ TABLE all_servers with key name = p_server..
*    if ( sy-subrc = 0 and all_servers-state = passive ).
*       p_rc = 'Y'.
*    endif.
*endif.
*
*endform.

****************************************************************************
* 3.2.2012    d023157   note 1679906

form get_free_btc_wp_only
                USING    p_server    LIKE tbtco-execserver
                         p_jobclass  LIKE tbtco-jobclass
                CHANGING p_num_of_free_btcwps TYPE i
                p_rc                          TYPE i.


DATA: btc_rqtyp(4) VALUE 'BTC ',
        i_length           TYPE i.

  DATA: BEGIN OF req_tbl OCCURS 5.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF req_tbl.

  DATA: BEGIN OF rsp_tbl OCCURS 20.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF rsp_tbl.

  DATA: BEGIN OF loc_int_tab OCCURS 10." Tabelle für das Auslesen von
          INCLUDE STRUCTURE salstintg. " 'privaten' Integerweten eines
  DATA: END OF loc_int_tab.            " SAP-Servers

  DATA: BEGIN OF loc_text_tab OCCURS 10. " Tabelle für das Auslesen von
          INCLUDE STRUCTURE salsttext. " 'privaten' Kurztexten eines
  DATA: END OF loc_text_tab.           " SAP-Servers

  DATA: BEGIN OF loc_long_text_tab OCCURS 10. " Tabelle für das Auslesen
          INCLUDE STRUCTURE salstltxt. " von 'privaten' Langtexten
  DATA: END OF loc_long_text_tab.      " eines SAP-Servers

  DATA: BEGIN OF wpstatus_tbl,
        wp      TYPE i,
        rqtyp(4),
        stat    TYPE i,
        END OF wpstatus_tbl.

  REFRESH req_tbl.
  REFRESH rsp_tbl.
*
* Request für das Ermitteln der Workprozeßstatus und der reservierten
* Klasse-A-Batchworkprozesse auf dem genannten Server aufbauen
*
  CLEAR req_tbl.
  req_tbl-opcode = ad_wpstat.
  APPEND req_tbl.

  CALL FUNCTION 'RZL_MAKE_STRG_READ_REQ'
    EXPORTING
      name    = class_a_wp_ident
      typ     = 'C'
    TABLES
      req_tbl = req_tbl
    EXCEPTIONS
      OTHERS  = 99.
  IF sy-subrc <> 0.
    p_rc = rc_tgt_host_chk_has_failed.
    EXIT.
  ENDIF.
*
* Request an Server schicken, Antwort abholen und Workprozeßstatus-
* tabelle aufbauen
*
  CALL FUNCTION 'RZL_EXECUTE_STRG_REQ'
    EXPORTING
      srvname = p_server
    TABLES
      req_tbl = req_tbl
      rsp_tbl = rsp_tbl
    EXCEPTIONS
      OTHERS  = 99.
  IF sy-subrc <> 0.
    p_rc = rc_tgt_host_chk_has_failed.
    EXIT.
  ENDIF.

  CALL FUNCTION 'RZL_MAKE_STRG_RSP'
    TABLES
      intg_tbl      = loc_int_tab
      text_tbl      = loc_text_tab
      long_text_tbl = loc_long_text_tab
      rsp_tbl       = rsp_tbl
    EXCEPTIONS
      OTHERS        = 99.
  IF sy-subrc <> 0.
    p_rc = rc_tgt_host_chk_has_failed.
    EXIT.
  ENDIF.

  MOVE space TO loc_text_tab.
  loc_text_tab-name = class_a_wp_ident.
  READ TABLE loc_text_tab.
  IF sy-subrc = 0 AND p_jobclass <> btc_jobclass_a.
    class_a_btc_wp = loc_text_tab-value.
  ELSE.
    class_a_btc_wp = 0.
  ENDIF.

  LOOP AT rsp_tbl.
    IF rsp_tbl-opcode EQ ad_wpstat AND rsp_tbl-errno EQ 0.
      raw_ad_wpstat_rec = rsp_tbl-buffer.
      MOVE-CORRESPONDING raw_ad_wpstat_rec TO wpstatus_tbl.
      IF wpstatus_tbl-rqtyp EQ btc_rqtyp AND
         wpstatus_tbl-stat EQ ad_wpstat_stat_wait.
        p_num_of_free_btcwps = p_num_of_free_btcwps + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  p_num_of_free_btcwps = p_num_of_free_btcwps - class_a_btc_wp.

endform.


*************************************************************************
* d023157    originally in BCE:            30.7.2009
*            copied to YI3 and enhanced:   25.1.2013

form make_tbtcy using p_msg           type tbtcm
                      p_reaxserver    type btcsrvname
                      p_execserver    type btcsrvname
                      p_targetgroup   type bpsrvgrpn
                      p_created       type c.

data: wa_tbtcy   like tbtcy.

statics: ready_restart.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  p_msg-jobname.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'make_tbtcy:'       "#EC NOTEXT
                                          'Job = '            "#EC NOTEXT
                                          p_msg-jobname
                                          p_msg-jobcount.

*********************************************************


* This parameter shall inform the caller, if a TBTCY entry was created.
p_created = 'N'.

*** check, if restart mechanism is activated    *******************

* if the variable ready_restart is initial, it is checked in
* BTCOPTIONS, if the restart mechanism has been activated.
* If yes, ready_restart is set to 'Y', otherwise to 'N'.

if ready_restart is initial.

   select single * from btcoptions
                           where btcoption = 'BATCHOPTION'
                             and value1    = 'READYJOBS_RESTART'
                             and value2    = 'OFF'.

   if sy-subrc = 0.
      ready_restart = 'N'.
      exit.
   else.
      ready_restart = 'Y'.
   endif.
endif.

if ready_restart ne 'Y'.
   exit.
endif.

*** end of check   ************************************************

get time.

move-corresponding p_msg to wa_tbtcy.

wa_tbtcy-creadate = sy-datum.
wa_tbtcy-creatime = sy-uzeit.

wa_tbtcy-lastchdate = sy-datum.
wa_tbtcy-lastchtime = sy-uzeit.

wa_tbtcy-execserver      = p_execserver.
wa_tbtcy-tgtsrvgrp       = p_targetgroup.

wa_tbtcy-reaxserver_1    = p_reaxserver.
wa_tbtcy-reaxserver_last = p_reaxserver.

wa_tbtcy-nroftries    = 1.


* Check, if an TBTCY entry already exists
select single * from tbtcy into wa_tbtcy
                    where jobname  = p_msg-jobname
                      and jobcount = p_msg-jobcount.

if sy-subrc = 0.

* This should only happen, if this is a restart attempt by
* BP_JOB_CHECKSTATE.
* we update the existing TBTCY entry here and increase
* the restart counter by 1.

   perform write_string_to_wptrace_btc using tracelevel_btc
                                          'make_tbtcy:'              "#EC NOTEXT
                                          'ATTENTION:'               "#EC NOTEXT
                                          'TBTCY already exists.'    "#EC NOTEXT
                                          ' '.


   CALL 'WriteTrace'
        ID 'CALL' FIELD 'MAKE_TBTCY'
        ID 'PAR1' FIELD 'ATTENTION: TBTCY already exists'
        ID 'PAR2' FIELD p_msg-jobname
        ID 'PAR3' FIELD p_msg-jobcount.

   wa_tbtcy-nroftries = wa_tbtcy-nroftries + 1.

   update tbtcy from wa_tbtcy.

   if sy-subrc ne 0.

      perform err_string_to_wptrace_btc using 'make_tbtcy:'             "#EC NOTEXT
                                              'update TBTCY failed'     "#EC NOTEXT
                                               p_msg-jobname
                                               p_msg-jobcount.

      exit.

   endif.

else.

   insert tbtcy from wa_tbtcy.
* to be sure: check return code of insert
* If sy-subrc ne 0 = > write WP trace and leave routine here
   if sy-subrc ne 0.

      perform err_string_to_wptrace_btc using 'make_tbtcy:'             "#EC NOTEXT
                                              'insert TBTCY failed'     "#EC NOTEXT
                                               p_msg-jobname
                                               p_msg-jobcount.

      exit.

   endif.

endif.

p_created = 'Y'.

* The following is important. The job message itself will contain
* the information, that the restart scenario is active.
* This is done by setting the status field in the message (not in
* the DB) to '1'. The receiving side in the batch kernel coding then
* sees, how to treat this job.
* Other solutions, where the sending side (ABAP) and the receiving
* side (kernel) check (e.g. in BTCOPTIONS), if the scenario is active,
* have the disadvantage, that they are performed at different points
* of times.
* If the scenario is switched on of off between these points of times
* for a certain job, this will lead to inconsistent behaviour.

p_msg-status = '1'.

* the following is for testing. It works only in an system of type SAP
* (not customer).
* It shall be possible to specify a certain jobname pattern and the
* number of failed starts for jobs, which contain this pattern.

perform test_ready_jobs using p_msg wa_tbtcy-nroftries.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'make_tbtcy:'            "#EC NOTEXT
                                          'TBTCY entry'            "#EC NOTEXT
                                          'created / updated.'     "#EC NOTEXT
                                          ' '.


endform.

************************************************************************

form test_ready_jobs using p_msg       like tbtcm
                           p_nroftries type i.


data: systemtype like SY-SYSID.
data: pattern    type string.
data: nr_char    type string.
data: nr         type i.

statics: testmode.

if testmode = 'N'.
   exit.
endif.

* now initialization
if testmode is initial.
   testmode = 'N'.
endif.

CALL FUNCTION 'TR_SYS_PARAMS'
  IMPORTING
    SYSTEMTYPE = systemtype
  EXCEPTIONS
    OTHERS     = 1.

if sy-subrc ne 0.
   exit.
endif.

if systemtype ne 'SAP'.
   exit.
endif.

select single * from btcoptions where btcoption = 'BATCHTEST'
                                  and value1    = 'READYJOBS_RESTART_TEST'.

if sy-subrc ne 0.
   exit.
endif.

if btcoptions-value2 is initial.
   exit.
endif.

split btcoptions-value2 at '#' into pattern nr_char.

if not nr_char co '0123456789 '.
   exit.
endif.

testmode = 'Y'.

nr = nr_char.

if ( p_msg-jobname cp pattern and p_nroftries <= nr ).
   p_msg-status = '2'.
*   p_msg-status = '1'.
endif.

endform.
