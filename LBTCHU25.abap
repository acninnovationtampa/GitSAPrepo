FUNCTION job_close.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(AT_OPMODE) LIKE  SPFBA-BANAME DEFAULT SPACE
*"     VALUE(AT_OPMODE_PERIODIC) LIKE  BTCH0000-CHAR1 DEFAULT SPACE
*"     VALUE(CALENDAR_ID) LIKE  TBTCJOB-CALENDARID DEFAULT SPACE
*"     VALUE(EVENT_ID) LIKE  TBTCJOB-EVENTID DEFAULT SPACE
*"     VALUE(EVENT_PARAM) LIKE  TBTCJOB-EVENTPARM DEFAULT SPACE
*"     VALUE(EVENT_PERIODIC) LIKE  BTCH0000-CHAR1 DEFAULT SPACE
*"     VALUE(JOBCOUNT) LIKE  TBTCJOB-JOBCOUNT
*"     VALUE(JOBNAME) LIKE  TBTCJOB-JOBNAME
*"     VALUE(LASTSTRTDT) LIKE  TBTCJOB-LASTSTRTDT DEFAULT NO_DATE
*"     VALUE(LASTSTRTTM) LIKE  TBTCJOB-LASTSTRTTM DEFAULT NO_TIME
*"     VALUE(PRDDAYS) LIKE  TBTCJOB-PRDDAYS DEFAULT 0
*"     VALUE(PRDHOURS) LIKE  TBTCJOB-PRDHOURS DEFAULT 0
*"     VALUE(PRDMINS) LIKE  TBTCJOB-PRDMINS DEFAULT 0
*"     VALUE(PRDMONTHS) LIKE  TBTCJOB-PRDMONTHS DEFAULT 0
*"     VALUE(PRDWEEKS) LIKE  TBTCJOB-PRDWEEKS DEFAULT 0
*"     VALUE(PREDJOB_CHECKSTAT) LIKE  TBTCSTRT-CHECKSTAT DEFAULT SPACE
*"     VALUE(PRED_JOBCOUNT) LIKE  TBTCJOB-JOBCOUNT DEFAULT SPACE
*"     VALUE(PRED_JOBNAME) LIKE  TBTCJOB-JOBNAME DEFAULT SPACE
*"     VALUE(SDLSTRTDT) LIKE  TBTCJOB-SDLSTRTDT DEFAULT NO_DATE
*"     VALUE(SDLSTRTTM) LIKE  TBTCJOB-SDLSTRTTM DEFAULT NO_TIME
*"     VALUE(STARTDATE_RESTRICTION) LIKE  TBTCJOB-PRDBEHAV DEFAULT
*"       BTC_PROCESS_ALWAYS
*"     VALUE(STRTIMMED) LIKE  BTCH0000-CHAR1 DEFAULT SPACE
*"     VALUE(TARGETSYSTEM) DEFAULT SPACE
*"     VALUE(START_ON_WORKDAY_NOT_BEFORE) LIKE  TBTCSTRT-NOTBEFORE
*"       DEFAULT SY-DATUM
*"     VALUE(START_ON_WORKDAY_NR) LIKE  TBTCSTRT-WDAYNO DEFAULT 0
*"     VALUE(WORKDAY_COUNT_DIRECTION) LIKE  TBTCSTRT-WDAYCDIR DEFAULT 0
*"     VALUE(RECIPIENT_OBJ) LIKE  SWOTOBJID STRUCTURE  SWOTOBJID
*"       OPTIONAL
*"     VALUE(TARGETSERVER) LIKE  BTCTGTSRVR-SRVNAME DEFAULT SPACE
*"     VALUE(DONT_RELEASE) LIKE  BTCH0000-CHAR1 DEFAULT SPACE
*"     VALUE(TARGETGROUP) TYPE  BPSRVGRP DEFAULT SPACE
*"     VALUE(DIRECT_START) LIKE  BTCH0000-CHAR1 OPTIONAL
*"     VALUE(INHERIT_RECIPIENT) TYPE  BTCH0000-CHAR1 OPTIONAL
*"     VALUE(INHERIT_TARGET) TYPE  BTCH0000-CHAR1 OPTIONAL
*"     VALUE(REGISTER_CHILD) TYPE  BTCCHAR1 DEFAULT ABAP_FALSE
*"  EXPORTING
*"     VALUE(JOB_WAS_RELEASED) LIKE  BTCH0000-CHAR1
*"  CHANGING
*"     REFERENCE(RET) TYPE  I OPTIONAL
*"  EXCEPTIONS
*"      CANT_START_IMMEDIATE
*"      INVALID_STARTDATE
*"      JOBNAME_MISSING
*"      JOB_CLOSE_FAILED
*"      JOB_NOSTEPS
*"      JOB_NOTEX
*"      LOCK_FAILED
*"      INVALID_TARGET
*"----------------------------------------------------------------------
  DATA: BEGIN OF relstdt.       " Zwischenspeicher für die vom Rufer
          INCLUDE STRUCTURE tbtcstrt. " übergebenen Starttermindaten in auf-
  DATA: END OF relstdt.         " bereiteter Form für BP_JOB_MODIFY

  DATA: modify_opcode          LIKE btch0000-int4,
        fubst_caller           LIKE sy-repid,
        suppress_release_check LIKE btch0000-char1.

  DATA: rc    TYPE i,
        subrc TYPE sy-subrc,
        l_msg TYPE symsg.


*** for tracing *****************************************

  data: tracelevel_btc type i.

  perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  jobname.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'JOB_CLOSE:'                "#EC NOTEXT
                                          'Jobname / Jobcount = '     "#EC NOTEXT
                                          jobname
                                          jobcount.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'STRTIMMED ='               "#EC NOTEXT
                                          strtimmed
                                          ' '
                                          ' '.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'DONT_RELEASE ='            "#EC NOTEXT
                                          dont_release
                                          'DIRECT_START ='            "#EC NOTEXT
                                          direct_start.

*********************************************************

  CLEAR job_was_released.

***** c5034979 XBP20, change *****
  CLEAR ret.
*
* kein Jobname angegeben ?
*
  IF jobname EQ space.
    MESSAGE e093 RAISING jobname_missing.
  ENDIF.

* 27.10.2006   d023157
* first of all: lock the job

* 28.2.2007    d023157
* wir müssen den Sperraufruf in eine neue Funktion umleiten,
* die mit 'wait-Flag' sperrt.

*  PERFORM enq_job USING jobname jobcount 'N' rc.
  perform  enq_job_for_jobclose using    jobname jobcount
                                changing rc.

  IF rc NE 0.

* store precise error information ********************************
         xbp_msgpar2 = jobname.
         xbp_msgpar3 = jobcount.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'XM'
                     i_msgno     = msg_job_lock_failed
                     i_msg2      = xbp_msgpar2
        i_msg3  = xbp_msgpar3.
         clear xbp_msgpar2.
         clear xbp_msgpar3.
******************************************************************

    MESSAGE e366 WITH jobname jobcount RAISING lock_failed.
  ENDIF.

*
* Jobkopfdaten lesen
*

* d023157    19.11.2010   note 1530713
  perform time_to_immstart changing SDLSTRTDT
                                    SDLSTRTTM
                                    STRTIMMED.

  CLEAR global_job.

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_jobhead_only
    IMPORTING
      job_read_jobhead  = global_job
    TABLES
      job_read_steplist = global_step_tbl  " Dummy, wird hier
    EXCEPTIONS                                " nicht gebraucht
      job_doesnt_exist  = 1
      OTHERS            = 99.

  subrc = sy-subrc.
  IF subrc <> 0.
    MOVE-CORRESPONDING syst TO l_msg.
  ENDIF.
  CASE subrc.
    WHEN 0.
      " o.K.
    WHEN 1.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING job_notex.
    WHEN OTHERS.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING job_close_failed.
  ENDCASE.

***** c5034979 XBP20, change *****
* Intercepted jobs are only released only if the current user
* has proper authorization.
  DATA: wa_tbtccntxt LIKE tbtccntxt.
  GET TIME.
  IF global_job-status = btc_scheduled AND
     (
       ( NOT dont_release IS INITIAL AND
         ( sdlstrtdt < sy-datum OR
           ( sdlstrtdt = sy-datum AND sdlstrttm < sy-uzeit
           )
         )
       ) OR
       ( dont_release IS INITIAL AND NOT strtimmed IS INITIAL
       )
     ).
    IF sy-subrc = 0.
      SELECT SINGLE * FROM tbtccntxt INTO wa_tbtccntxt
        WHERE jobname  = jobname AND
              jobcount = jobcount AND
              ctxttype = 'INTERCEPTED'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
                 ID 'ACTVT' FIELD '01'.
        IF sy-subrc <> 0.

* store precise error information ********************************
         xbp_msgpar2 = 'S_RZL_ADM'.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'XM'
                     i_msgno     = msg_no_authority
              i_msg2  = xbp_msgpar2.
         clear xbp_msgpar2.
******************************************************************

          ret = err_no_authority.
          PERFORM deq_job USING jobname jobcount 'N' rc.
          MESSAGE e791 RAISING job_close_failed.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*
* wenn das NEWFLAG auf Open sitzt, wurden noch keine Steps definiert
*
  IF global_job-newflag = 'O'.
    PERFORM deq_job USING jobname jobcount 'N' rc.

* store precise error information ********************************

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'XM'
        i_msgno = msg_no_jobsteps.
******************************************************************

    MESSAGE e659 RAISING job_nosteps.
  ENDIF.
*
* evtl. vorhandene Starttermindaten fuer BP_JOB_MODFIY aufbereiten
*
  CLEAR relstdt.

  IF start_on_workday_nr NE 0.
    relstdt-wdayno    = start_on_workday_nr.
    relstdt-wdaycdir  = workday_count_direction.
    relstdt-sdlstrttm = sdlstrttm.
    relstdt-notbefore = start_on_workday_not_before.
    IF prdmonths NE 0.
      relstdt-periodic  = 'X'.
      relstdt-prdmonths = prdmonths.
    ENDIF.
    relstdt-startdttyp = btc_stdt_onworkday.
  ELSEIF sdlstrtdt NE no_date.
    relstdt-sdlstrtdt  = sdlstrtdt.
    relstdt-sdlstrttm  = sdlstrttm.
    relstdt-laststrtdt = laststrtdt.
    relstdt-laststrttm = laststrttm.
    relstdt-startdttyp = btc_stdt_datetime.
  ELSEIF strtimmed EQ 'X'.
    relstdt-startdttyp = btc_stdt_immediate.
  ELSEIF event_id NE space.
    relstdt-eventid    = event_id.
    relstdt-eventparm  = event_param.
    IF event_periodic EQ 'X'.
      relstdt-periodic = 'X'.
    ENDIF.
    relstdt-startdttyp = btc_stdt_event.
  ELSEIF pred_jobname NE space.
    IF pred_jobname = jobname AND
          pred_jobcount = jobcount.
      PERFORM deq_job USING jobname jobcount '' CHANGING rc.
      RAISE invalid_startdate.
    ENDIF.
    relstdt-predjob    = pred_jobname.
    relstdt-predjobcnt = pred_jobcount.
    relstdt-checkstat  = predjob_checkstat.
    relstdt-startdttyp = btc_stdt_afterjob.
  ELSEIF at_opmode NE space.
    relstdt-eventid   = oms_eventid.
    relstdt-eventparm = at_opmode.
    IF at_opmode_periodic EQ 'X'.
      relstdt-periodic = 'X'.
    ENDIF.
    relstdt-startdttyp = btc_stdt_event.
  ENDIF.

  IF relstdt-startdttyp EQ btc_stdt_immediate OR
     relstdt-startdttyp EQ btc_stdt_datetime.
    relstdt-prdmins   = prdmins.
    relstdt-prdhours  = prdhours.
    relstdt-prddays   = prddays.
    relstdt-prdweeks  = prdweeks.
    relstdt-prdmonths = prdmonths.

    sum = prdmins  +
          prdhours +
          prddays  +
          prdweeks +
          prdmonths.

    IF sum > 0.
      relstdt-periodic = 'X'.
    ENDIF.
  ENDIF.

  relstdt-calendarid = calendar_id.
  relstdt-prdbehav   = startdate_restriction.
*
* Abhängig davon, ob Starttermindaten vorhanden sind bzw. ob der Be-
* nutzer Freigabeberechtigung hat, den Job freigeben bzw. 'closen'.
* Wird JOB_CLOSE von den SAP-Systemprogrammen 'SAPLARFC' ( Asynchroner
* RFC ), 'SAPLSEUQ' ( Entwicklungsumgebung ), 'RSWWDHEX' ( Work-
* flow ) oder 'SAPLSO04' ( SAP-Office ) gerufen, dann ist automatisch
* Freigabeberechtigung für den Job gegeben.
*
  CALL 'AB_GET_CALLER' ID 'PROGRAM' FIELD fubst_caller.

  IF fubst_caller EQ 'SAPLARFC' OR
     fubst_caller EQ 'SAPLSEUQ' OR
     fubst_caller EQ 'RSWWDHEX' OR
     fubst_caller EQ 'SAPLSO04'.
    release_privilege_given = btc_yes.
    suppress_release_check  = 'X'.
  ELSE.
    CLEAR suppress_release_check.
    PERFORM check_release_privilege.
  ENDIF.

  IF relstdt-startdttyp NE space.
    IF release_privilege_given EQ btc_yes.
******************
* for dont release
******************
      IF dont_release EQ 'X'.
        modify_opcode = btc_close_job.
      ELSE.
        modify_opcode = btc_release_job.
      ENDIF.
    ELSE.
      modify_opcode = btc_close_job.
    ENDIF.
  ELSE.
    modify_opcode = btc_close_job.
  ENDIF.

  IF inherit_recipient = abap_true AND recipient_obj IS NOT SUPPLIED
     AND global_job-recobjkey IS INITIAL.
    PERFORM copy_parent_recipient CHANGING recipient_obj.
  ENDIF.

  IF inherit_target = abap_true AND
    targetsystem IS NOT SUPPLIED AND
    targetserver IS NOT SUPPLIED AND
    targetgroup IS NOT SUPPLIED AND
    global_job-TGTSRVGRP IS INITIAL AND
    global_job-execserver IS INITIAL.
    PERFORM get_parent_target CHANGING targetserver targetgroup.
  ENDIF.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      dialog                     = btc_no
      opcode                     = modify_opcode
      jobname                    = global_job-jobname
      jobcount                   = global_job-jobcount
      release_stdt               = relstdt
      release_targetsystem       = targetsystem
      release_targetserver       = targetserver
      suppress_release_check     = suppress_release_check
      recipient_obj              = recipient_obj
      dont_release               = dont_release
      targetgroup                = targetgroup
      direct_start               = direct_start
    TABLES
      new_steplist               = global_step_tbl  " Dummy
    CHANGING
      ret                        = ret
      emsg                       = l_msg
    EXCEPTIONS
      cant_enq_job               = 1
      cant_start_job_immediately = 2
      invalid_startdate          = 3
      no_release_privilege_given = 4
      target_host_not_defined    = 5
      tgt_host_chk_has_failed    = 5
      invalid_targetgroup        = 5
      no_batch_server_found      = 5
      OTHERS                     = 99.

  subrc = sy-subrc.
  IF subrc <> 0.
    IF l_msg-msgno IS INITIAL.
      l_msg-msgid = 'BT'.
      l_msg-msgno = '383'.
      l_msg-msgty = 'E'.
      l_msg-msgv1 = jobname.
      l_msg-msgv2 = jobcount.
    ELSE.
      IF l_msg-msgty IS INITIAL.
        l_msg-msgty = 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
  CASE subrc.
    WHEN 0. " ok
      IF release_privilege_given EQ btc_yes AND
         relstdt-startdttyp NE space.
        job_was_released = 'X'.
      ENDIF.
    WHEN 1.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING lock_failed.
    WHEN 2.
      IF NOT ret IS INITIAL.
        PERFORM deq_job USING jobname jobcount 'N' rc.
        MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
          WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING job_close_failed.
      ELSE.
        PERFORM deq_job USING jobname jobcount 'N' rc.
        MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
          WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING cant_start_immediate.
      ENDIF.
    WHEN 3.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING invalid_startdate.
    WHEN 4.
      " nix tun, Info wird über Parameter 'JOB_WAS_RELEASED' mitgeteilt
    WHEN 5.
      PERFORM deq_job USING jobname jobcount 'N' rc.

* store precise error information ********************************
         if targetgroup is initial or targetgroup co ' '.
            xbp_msgpar2 = targetserver.
         else.
            xbp_msgpar2 = targetgroup.
         endif.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'XM'
                     i_msgno     = msg_invalid_target
          i_msg2  = xbp_msgpar2.
          clear xbp_msgpar2.
******************************************************************

      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING invalid_target.
    WHEN OTHERS.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING job_close_failed.
  ENDCASE.

***** c5034979 XBP20, change *****
* hgk   19.11.2001
* if this runs within a batch job, the released job will
* be registered as a child.

  IF sy-batch = 'X' AND dont_release EQ space.

    CALL FUNCTION 'BP_CHILD_REGISTER'
      EXPORTING
        jobcount             = jobcount
        jobname              = jobname
        always               = register_child
      EXCEPTIONS
        not_in_batch         = 1
        no_runtime_info      = 2
        context_add_error    = 3
        context_select_error = 4
        OTHERS               = 5.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING syst TO l_msg.
      ret = err_child_register_error.
      PERFORM deq_job USING jobname jobcount 'N' rc.
      MESSAGE ID l_msg-msgid TYPE l_msg-msgty NUMBER l_msg-msgno
        WITH l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4 RAISING job_close_failed.
    ENDIF.

    CALL FUNCTION 'DB_COMMIT'.
  ENDIF.

  PERFORM deq_job USING jobname jobcount 'N' rc.

ENDFUNCTION.

************************************************************************

form  enq_job_for_jobclose using    jobname jobcount
                           changing rc.

  data:
    p_lock TYPE t_lock,
    p_tbtco_key TYPE tbtck,
    p_arg TYPE seqg3-garg,
    p_locks TYPE tt_lock,
    p_number TYPE i.

  DATA: TAB_NAME(5) VALUE 'TBTCO'.

*   PERFORM ENQ_TBTCO_ENTRY USING JOBNAME JOBCOUNT RC.

   rc = 0.

   CALL FUNCTION 'ENQUEUE_ESTBTCO'
    EXPORTING
      jobname        = jobname
                   JOBCOUNT       = JOBCOUNT
                   _WAIT          = 'X'
                   _SCOPE         = '1'
    EXCEPTIONS
      foreign_lock   = 1
                   SYSTEM_FAILURE = 2
                   OTHERS         = 99.

   CASE SY-SUBRC.
     WHEN 0.
       " Sperre erfolgreich gesetzt

     WHEN 1.   " Sperre schon belegt

          p_tbtco_key-jobname = jobname.
          p_tbtco_key-jobcount = jobcount.
          p_arg = p_tbtco_key.
          PERFORM enq_read
            USING 'TBTCO' p_arg CHANGING p_locks p_number rc.
          IF rc = 0.
            CASE p_number.
              WHEN 0.
*     Entry is already unlocked:
                p_lock-guname = '<unknown>'.
                rc = TABLE_ENTRY_ALREADY_LOCKED.
              WHEN 1.
*     Single lock:
                READ TABLE p_locks INDEX 1 INTO p_lock.
                rc = TABLE_ENTRY_ALREADY_LOCKED.
              WHEN OTHERS.
*     Multiple lock:
                READ TABLE p_locks INDEX 1 INTO p_lock.
                rc = TABLE_ENTRY_ALREADY_LOCKED.
            ENDCASE.
          ELSE.
            rc = TABLE_ENTRY_ALREADY_LOCKED.
          ENDIF.

        CALL FUNCTION 'RSLG_WRITE_SYSLOG_ENTRY'
          EXPORTING
            data_word1         = jobname
            data_word2         = jobcount
            sl_message_area    = JOBENTRY_ALREADY_LOCKED(2)
            sl_message_subid   = JOBENTRY_ALREADY_LOCKED+2(1)
          EXCEPTIONS
            data_missing       = 0
            data_words_problem = 0
            other_problem      = 0
            pre_params_problem = 0
            OTHERS             = 0.
        CALL FUNCTION 'RSLG_WRITE_SYSLOG_ENTRY'
          EXPORTING
            data_word1         = p_lock-gtwp
            data_word2         = p_lock-gthost
            data_word3         = p_lock-guname
            sl_message_area    = JOBENTRY_ALREADY_LOCKED(2)
            sl_message_subid   = JOBENTRY_ALREADY_LOCKED+2(1)
          EXCEPTIONS
            data_missing       = 0
            data_words_problem = 0
            other_problem      = 0
            pre_params_problem = 0
            OTHERS             = 0.

       RC = 1.
       EXIT.


     WHEN OTHERS.  " Enqueue-Problem aufgetreten
       RC = 1.
       CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
             ID 'KEY'  FIELD ENQUEUE_ERROR_DETECTED
             ID 'DATA' FIELD TAB_NAME.
       exit.

   ENDCASE.

ENDFORM. " ENQ_JOB_FOR_JOBCLOSE

*****************************************************************

form time_to_immstart changing p_date    type TBTCJOB-SDLSTRTDT
                               p_time    type TBTCJOB-SDLSTRTTM
                               p_immflag type BTCH0000-CHAR1.

data: diff_seconds type i.

if ( p_date is initial or p_date co ' ' or p_date co '0' ).
    exit.
endif.

if ( p_time is initial or p_time co ' ' ).
    exit.
endif.

* first case: date and time are system date and system time
if ( p_date = sy-datum and p_time = sy-uzeit ).
    p_date = no_date.
    p_time = no_time.
    p_immflag = 'X'.
    exit.
endif.

* second case: date and time are already a few seconds in the past.
* if it is 10 seconds or less, we transform to immediate start.
PERFORM calculate_time_diff_in_sec
                          USING p_date p_time
                          sy-datum sy-uzeit diff_seconds.

if ( diff_seconds > 0 and diff_seconds < 11 ).
    p_date = no_date.
    p_time = no_time.
    p_immflag = 'X'.
    exit.
endif.


endform.

*---------------------------------------------------------------------*
*       FORM COPY_PARENT_RECIPIENT                                    *
*---------------------------------------------------------------------*
* This routine will copy the recipient of the job that is currently   *
* running so it can be passed to a child job.                         *
*                                                                     *
* It will only be called if the caller of JOB_CLOSE allows it and     *
* if there is no recipient passed to JOB_CLOSE or set for the job to  *
* be modified by JOB_CLOSE                                            *
*---------------------------------------------------------------------*
FORM copy_parent_recipient CHANGING child_recobj TYPE swotobjid.

  swc_container container.

  DATA: parent_recobj TYPE swotobjid,
        parent_count  TYPE btcjobcnt,
        parent_name   TYPE btcjob,
        l_recipient   TYPE swc_object,
        lv_reckey     TYPE swo_typeid.

  DATA: BEGIN OF l_recobj,
          reclogsys  TYPE logsys,
          recobjtype TYPE swo_objtyp,
          recobjkey  TYPE swo_typeid,
          recdescrib TYPE swo_descrb,
        END OF l_recobj.

  IF sy-batch = abap_true.

    CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
      IMPORTING
        jobcount        = parent_count
        jobname         = parent_name
      EXCEPTIONS
        no_runtime_info = 1
        OTHERS          = 2.
    IF sy-subrc = 0.

      SELECT SINGLE * FROM tbtco INTO CORRESPONDING FIELDS OF l_recobj WHERE
      jobname = parent_name AND jobcount = parent_count.
      IF l_recobj IS NOT INITIAL.
        parent_recobj-logsys = l_recobj-reclogsys.
        parent_recobj-objtype = l_recobj-recobjtype.
        parent_recobj-objkey = l_recobj-recobjkey.
        parent_recobj-describe = l_recobj-recdescrib.
        swc_object_from_persistent parent_recobj l_recipient.
        IF sy-subrc = 0.
          swc_call_method l_recipient 'Copy' container.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING parent_recobj TO child_recobj.
            swc_get_element container result l_recipient.
            IF sy-subrc = 0.
              swc_get_object_key l_recipient lv_reckey.
              swc_free_object l_recipient.
              child_recobj-objkey = lv_reckey.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF child_recobj-objkey IS INITIAL.
    CLEAR child_recobj.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM GET_PARENT_TARGET                                    *
*---------------------------------------------------------------------*
* This routine will find out the target of the job that is currently  *
* running so it can be passed to a child job.                         *
*                                                                     *
* It will only be called if the caller of JOB_CLOSE allows it and     *
* if there is no target passed to JOB_CLOSE or set for the job to     *
* be modified by JOB_CLOSE                                            *
*---------------------------------------------------------------------*
FORM get_parent_target CHANGING p_ts TYPE btcsrvname p_tg TYPE bpsrvgrp.

  DATA: parent_count TYPE btcjobcnt,
        parent_name  TYPE btcjob,
        l_reaxserver TYPE btcsrvname,
        i_tg         TYPE bpsrvgrpn.

  IF sy-batch = abap_true.

    CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
      IMPORTING
        jobcount        = parent_count
        jobname         = parent_name
      EXCEPTIONS
        no_runtime_info = 1
        OTHERS          = 2.
    IF sy-subrc = 0.
      SELECT SINGLE execserver tgtsrvgrp reaxserver FROM tbtco INTO (p_ts, i_tg, l_reaxserver) WHERE
      jobname = parent_name AND jobcount = parent_count.
      IF i_tg IS NOT INITIAL.
        PERFORM map_id_to_name USING i_tg p_tg.
      ELSEIF l_reaxserver IS NOT INITIAL.
        p_ts = l_reaxserver.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
