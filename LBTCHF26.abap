***INCLUDE LBTCHF26.

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_ABORT                    *
************************************************************************

*---------------------------------------------------------------------*
*      FORM CHECK_FOR_JOB_STILL_ACTIVE                                *
*---------------------------------------------------------------------*
* Überprüfe, ob ein als aktiv gekennzeichneter Job noch im entspre-
* chenden Workprozess wirklich aktiv ist:
*
*   - Information über Workprozesse vom Ausführungsrechner des Jobs
*     besorgen ( SM50-Information )
*   - Job ist noch aktiv im Workprozess, wenn
*     - der Ausführungsrechner für Batch konfiguriert ist und
*     - die Workprozess-Id noch existiert und
*     - der Workprozess vom Typ Batch ist und
*     - der in den Kopfdaten des Jobs genannte User / Mandant
*       im Workprozess läuft
*
* Wird festgestellt, daß ein Job nicht mehr aktiv ist in einem Batch-
* workprozess und er externe Programme als Steps besitzt, dann ist es
* möglich, daß diese externen Programme noch aktiv sind. Dies wird
* über einen entsprechenden Returncode an den Rufer weitergemeldet.
* Besitzt ein Job keine externen Programme und ist er in keinem Work-
* prozess aktiv, dann ist auch der Job nicht mehr aktiv sein.
*
* Inputparameter : - Ausführungsrechner des Jobs
*                  - PID des Batchworkprozesses in dem Job läuft bzw.
*                    gelaufen ist
*                  - Mandant unter dem der Job läuft bzw. gelaufen ist
*                  - Stepliste des Jobs
* Outputparameter: - Servername auf dem der Job läuft ( falls Job noch
*                    aktiv ist )
*                  - Benutzername unter dem der gerade aktive Step des
*                    Jobs läuft ( falls Job noch aktiv ist )
*                  - Nummer des Batchworkprozesses in dem der Job läuft
*                  - RC = 0 : Job ist noch aktiv im WP
*                    RC = 1 : Job ist nicht mehr aktiv im WP
*                    RC = 2 : Fehler beim Ermitteln der WP-Info
*
*---------------------------------------------------------------------*

FORM check_for_job_still_active TABLES abort_steplist STRUCTURE tbtcstep
                                USING  job_name
                                       job_count
                                       job_exec_btc_wpnumber
                                       job_exec_servername
                                       active_step_username
                                       rc.

  INCLUDE RSXPGDEF.

  DATA: jobactive LIKE tbtcjob-checkstat,
        extactive LIKE tbtcjob-checkstat,
        laststep TYPE i,
        rfcdest LIKE tbtcjob-execserver,
        ext_convid LIKE gwy_struct-convid,
        ext_target LIKE tbtcstep-xpgtgtsys,
        ext_step_termcntl LIKE tbtcstep-termcntl,
        local_server_name TYPE btcctl-btcserver,      " note 1234863
        rfc_msg  TYPE btcxpgprox-rfcmsg,              " note 1234863
        lt_servers TYPE TABLE OF msxxlist,            " note 1605123
        ls_server TYPE msxxlist.                      " note 1605123

*** for tracing *****************************************

data: tracelevel_btc    type i value 0.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  job_name.

*********************************************************


  CLEAR rc.
  CLEAR rfc_msg.                                      " note 1234863

* Analyze the last step of the job. External?
  DESCRIBE TABLE abort_steplist LINES laststep.
  READ TABLE abort_steplist INDEX laststep.

  active_step_username = abort_steplist-authcknam.

  IF abort_steplist-typ <> btc_abap.
    extactive = 'X'.
    ext_convid = abort_steplist-convid.
    ext_target = abort_steplist-xpgtgtsys.
    ext_step_termcntl = abort_steplist-termcntl.
  ELSE.
    extactive = ' '.
  ENDIF.

* note 1234863
  CALL 'C_SAPGPARAM'
    ID 'NAME'  FIELD 'rdisp/myname'
    ID 'VALUE' FIELD local_server_name.

*** for tracing *****************************************

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'local_server_name ='
                                            local_server_name
                                            ' '.


  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'job_exec_servername ='
                                            job_exec_servername
                                            ' '.

*********************************************************

*** Begin note 1548581 ***********************************
**********************************************************
*
* d023157    13.1.2011    note 1548581
* we continue only, if the server has the status 'active'.
* For any other status, like 'shutdown' or 'deactivated',
* we don't touch the job, because it may lead to unexpected
* results.
* If the server is not alive at all, we set the job to
* 'canceled', of course.

  data: rc1.
  data: syslog_txt(70).

  PERFORM use_server_for_checkstate USING job_exec_servername rc1.

* for the values of rc, see comments in the definition
* of the form routine

  if rc1 = '0'.
* we don't touch the job.
* we treat this, as if the job is still active

**** write also appropriate syslog messages *************
     concatenate 'Server'      "#EC NOTEXT
                  job_exec_servername(20)
                  'alive, but not active => no status check' "#EC NOTEXT
              into syslog_txt separated by ' '.

     CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD 'S9Q'
          ID 'DATA' FIELD syslog_txt.

    clear syslog_txt.

    concatenate 'Job:'      "#EC NOTEXT
                 job_name
                 job_count
                 into syslog_txt separated by ' '.

    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD 'S9Q'
          ID 'DATA' FIELD syslog_txt.

**********************************************************

     rc = job_active_in_wp.
     EXIT.
  endif.

  IF rc1 = 'N' AND job_exec_servername IS NOT INITIAL.
     rc = job_not_active_anymore.
     EXIT.
  endif.

*** End note 1548581 ***********************************


  IF local_server_name NE job_exec_servername.

    IF job_exec_servername IS NOT INITIAL.

* 30.9.2014  we don't need the call of BP_MAP_SERVER_TO_RFCDEST
*            any more.

        rfcdest = job_exec_servername.

    ELSE.
                                 " note 1605123
      CALL FUNCTION 'TH_SERVER_LIST'
*     EXPORTING
*       SERVICES             = 255
*       SYSSERVICE           = 0
*       ACTIVE_SERVER        = 1
       TABLES
         list                 = lt_servers
*       LIST_IPV6            =
       EXCEPTIONS
         no_server_list       = 1
         OTHERS               = 2
                .
      IF sy-subrc <> 0.
        rc = cant_get_btc_wp_info.
        EXIT.
      ELSE.

        IF lines( lt_servers ) = 1.
          READ TABLE lt_servers INDEX 1 INTO ls_server.
          IF ls_server-name = local_server_name.
            rfcdest = space.
          ELSE.
            rc = cant_get_btc_wp_info.
            EXIT.
          ENDIF.
        ELSE.
          rc = cant_get_btc_wp_info.
          EXIT.
        ENDIF.

      ENDIF.

    ENDIF.

  ELSE.
    rfcdest = space.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'                 "#EC NOTEXT
                                            'now call BP_IS_JOB_ACTIVE_IN_WP on dest:'    "#EC NOTEXT
                                            rfcdest
                                            ' '.


* Is the job ("jobname"/"jobcount") active on server "execserver"
* in work process "wp" ?
  CALL FUNCTION 'BP_IS_JOB_ACTIVE_IN_WP'
    DESTINATION rfcdest
    EXPORTING
      jobname               = job_name
      jobcount              = job_count
      wpnumber              = job_exec_btc_wpnumber
    IMPORTING
      jobactive             = jobactive
    EXCEPTIONS
      communication_failure = 1  MESSAGE rfc_msg
      system_failure        = 2  MESSAGE rfc_msg
      OTHERS                = 3.

  IF sy-subrc <> 0.

    IF rfc_msg IS NOT INITIAL.                       " note 1234863
      CALL 'WriteTrace'
      ID 'CALL' FIELD 'BP_JOB_CHECKSTATE'
      ID 'PAR1' FIELD rfc_msg.
      IF sy-batch IS NOT INITIAL.
        MESSAGE s351 WITH rfc_msg.
      ENDIF.
    ENDIF.

* Problems occurred while checking the status of the job.
* -> The status is still undefined.
    rc = cant_get_btc_wp_info.
    EXIT.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'jobactive ='
                                            jobactive
                                            ' '.


  IF jobactive = 'X'.
* The job is still active.
    rc = job_active_in_wp.
    EXIT.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'extactive ='
                                            extactive
                                            ' '.

* The job is not active in a BWP.
* -> Is the last step of this job external?
  IF extactive = ' '.
* The job is not active in a BWP and the last step is not
* external. -> The job is not active anymore.
    rc = job_not_active_anymore.
    EXIT.
  ENDIF.

* Do we wait for the external program/command?
  IF ext_step_termcntl = term_dont_wait.
* No! -> The job is not active anymore.
    rc = job_not_active_anymore.
    EXIT.
  ENDIF.

* d023157       31.8.2005
* The target of the external program/command is not necessarily
* the server, where the job runs.
* But further checks are only possible, if the target of the
* program/command is an application server of the local system.

  DATA: target LIKE rfcdisplay-rfchost.
  DATA: dest   LIKE rfcdes-rfcdest.
  DATA: i_host TYPE tbtco-btcsystem.

  IF ext_target IS NOT INITIAL.
    target = ext_target.
  ELSE.                                 " command was executed locally
    CALL FUNCTION 'BP_MAP_SERVER_TO_HOST'
      EXPORTING
        servname                  = job_exec_servername
      IMPORTING
        hostname                  = i_host
      EXCEPTIONS
        no_valid_name_to_map      = 1
        cannot_get_list           = 2
        cannot_find_matching_name = 3
        OTHERS                    = 4.

    IF sy-subrc <> 0.
      CLEAR target.
    ELSE.
      target = i_host.
    ENDIF.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'target ='
                                            target
                                            ' '.


  CALL FUNCTION 'SXPG_APPSERV_RFCDEST_GET_INT'
    EXPORTING
      targetsystem         = target
    IMPORTING
      appserv_destination  = dest
    EXCEPTIONS
      no_applicationserver = 1
      OTHERS               = 99.

  IF sy-subrc NE 0.
    rc = xpgm_maybe_still_active.
    EXIT.
  ENDIF.

* if dest is initial, that means, we are already on the target host.
  IF dest IS INITIAL.
    rfcdest = space.
  ELSE.
    rfcdest = dest.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active: rfcdest ='
                                            rfcdest
                                            'convid ='
                                            ext_convid.


* Is the external program/command still active?
  CALL FUNCTION 'BP_IS_EXT_STEP_ACTIVE'
    EXPORTING
      convid  = ext_convid
      target  = ext_target
      rfcdest = rfcdest
    IMPORTING
      active  = jobactive
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc <> 0.
* Problems occurred while checking the status of the
* external program/command. -> The status is still undefined.
    rc = cant_get_btc_wp_info.
    EXIT.
  ENDIF.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                            'check_for_job_still_active:'
                                            'jobactive ='
                                            jobactive
                                            ' '.

  IF jobactive = 'X'.
* The last, external step of the job is active.
* -> The job is still active.
    rc = job_active_ext.
  ELSE.
* The last, external step of the job is not active.
* -> The job is not active anymore.
    rc = job_not_active_anymore.
  ENDIF.

ENDFORM.                               " CHECK_FOR_JOB_STILL_ACTIVE

*---------------------------------------------------------------------*
*      FORM PULVERIZE_JOB_IN_WP                                       *
*---------------------------------------------------------------------*
* Einen Job, der in einem Batch-Workprozess' läuft, zum Abbruch zwingen
*
* Inputparameter : - Jobname
*                  - Nummer des Batch-Workprozesses in dem der Job läuft
*                  - Mandant in dem der Job läuft
*                  - Benutzername unter dem der gerade aktive Step
*                    des Jobs läuft
*                  - Name des SAP-Servers auf dem der Job läuft
* Outputparameter: - RC = 0 : Job erfolgreich abgebrochen
*                    RC = 1 : Job abbrechen misslungen
*
*---------------------------------------------------------------------*
FORM pulverize_job_in_wp USING job_exec_btc_wpnumber
                               job_exec_client
                               active_step_username
                               job_exec_servername
                               rc.

  DATA: srvname_new LIKE msxxlist-name.

  DATA:
    p_requests  TYPE TABLE OF sthcmlist,
    p_request   TYPE sthcmlist,
    p_responses TYPE TABLE OF sthcmlist,
    p_response  TYPE sthcmlist,
    p_server    TYPE spfid-apserver,
    p_buffer    LIKE raw_ad_wpstat_rec.

*
*   Aufbau der ADM-Message zum 'Abschießen' des Workprozesses
*
  CLEAR ad_wpkill_rec.
  ad_wpkill_rec-wp       = job_exec_btc_wpnumber.
  ad_wpkill_rec-killtype = ad_wpkill_soft.
  ad_wpkill_rec-mandt    = job_exec_client.

***********************************************************
* Retrieve actual user of process <job_exec_btc_wpnumber>
* on server <job_exec_servername>
***********************************************************
  " Get all processes on server <job_exec_servername>:
  p_request-opcode = ad_wpstat.
  APPEND p_request TO p_requests.
  p_server = job_exec_servername.
  CALL FUNCTION 'RZL_EXECUTE_STRG_REQ'
    EXPORTING
      srvname    = p_server
    TABLES
      req_tbl    = p_requests
      rsp_tbl    = p_responses
    EXCEPTIONS
      send_error = 1
      OTHERS     = 99.
  IF sy-subrc = 0.
    " Get actual user of process <job_exec_btc_wpnumber>:
    LOOP AT p_responses INTO p_response.
      p_buffer = p_response-buffer.
      IF p_buffer-wp = job_exec_btc_wpnumber.
        ad_wpkill_rec-bname = p_buffer-bname.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    ad_wpkill_rec-bname = active_step_username.
  ENDIF.

  CLEAR p_requests. FREE p_requests.
  CLEAR p_responses. FREE p_responses.
  CLEAR p_request.
  p_request-opcode = ad_wpkill.
  p_request-buffer = ad_wpkill_rec.
  APPEND p_request TO p_requests.

  MOVE job_exec_servername TO srvname_new.
  CALL FUNCTION 'TH_SEND_ADM_MESS'
    EXPORTING
      server_name     = srvname_new
      server_types    = th_adm_srvtypes_none
      wait_for_answer = th_adm_answer_wait_no
      level           = th_adm_level_dp
      trace           = th_adm_trace_off
    TABLES
      in_data         = p_requests
      out_data        = p_responses
    EXCEPTIONS
      bad_parameter   = 1
      send_error      = 2
      OTHERS          = 99.

  rc = sy-subrc.


ENDFORM.                               " PULVERIZE_JOB_IN_WP

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_ABORT_SYSLOG                                    *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM write_job_abort_syslog USING syslogid data.
*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD job_abort_problem_detected.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD syslogid
        ID 'DATA' FIELD data.

ENDFORM.                               " WRITE_JOB_ABORT_SYSLOG

********************************************************************
*   d023157     13.1.2011    note 1548581
*
*  this routine decides, how the status check shall continue for a job,
*  which has the server i_server as executing server.
*
*  return values of p_rc:
*
*     Y - status check shall continue, because server has status 'active'
*
*     0 - don't touch the job, because server is alive, but does not
*         have the status 'active'
*
*     N - server is not alive => correct the job status
*
**********************************************************************

FORM use_server_for_checkstate using p_server like tbtcjob-reaxserver
                               p_rc     type c.

data: all_servers    LIKE msxxlist OCCURS 5 WITH HEADER LINE.
data: all_service    LIKE msxxlist-msgtypes VALUE 25.
data: active         LIKE msxxlist-state VALUE 1.
data: passive        LIKE msxxlist-state VALUE 2.


CALL FUNCTION 'TH_SERVER_LIST'
    EXPORTING
       services       = all_service
       active_server  = 0
    TABLES
       list           = all_servers
    EXCEPTIONS
       no_server_list = 1
       OTHERS         = 2.

if sy-subrc = 0.

    READ TABLE all_servers with key name = p_server..
    if sy-subrc = 0.
*      server is alive
       if ( all_servers-state = active or
            all_servers-state = passive ).
*         server is alive and (active or passive)
          p_rc = 'Y'.
       else.
*         server is alive, but not active
          p_rc = '0'.
       endif.

    else.

*      server is NOT alive
       p_rc = 'N'.
    endif.

else.

* error in the call of TH_SERVER_LIST => we don't touch the job
    p_rc = '0'.
endif.

ENDFORM.                    "use_server_for_checkstate
