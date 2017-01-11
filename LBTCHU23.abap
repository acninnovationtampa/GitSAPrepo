FUNCTION job_open.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DELANFREP) LIKE  TBTCJOB-DELANFREP DEFAULT SPACE
*"     VALUE(JOBGROUP) LIKE  TBTCJOB-JOBGROUP DEFAULT SPACE
*"     VALUE(JOBNAME) LIKE  TBTCJOB-JOBNAME
*"     VALUE(SDLSTRTDT) LIKE  TBTCJOB-SDLSTRTDT DEFAULT NO_DATE
*"     VALUE(SDLSTRTTM) LIKE  TBTCJOB-SDLSTRTTM DEFAULT NO_TIME
*"     VALUE(JOBCLASS) LIKE  TBTCJOB-JOBCLASS OPTIONAL
*"     VALUE(CHECK_JOBCLASS) TYPE  BTCH0000-CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(JOBCOUNT) LIKE  TBTCJOB-JOBCOUNT
*"     VALUE(INFO) TYPE  I
*"  CHANGING
*"     REFERENCE(RET) TYPE  I OPTIONAL
*"  EXCEPTIONS
*"      CANT_CREATE_JOB
*"      INVALID_JOB_DATA
*"      JOBNAME_MISSING
*"----------------------------------------------------------------------
  DATA: calling_abap           LIKE sy-repid.
  DATA: jobname_class_a        LIKE tbtco-jobname.

* 14.3.2012   d023157    note 1695812 ******
* allowed values for new return parameter INFO
  data: change_class_2_c type i value 2.
  DATA: subrc TYPE sy-subrc,
        l_msg TYPE symsg.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  jobname.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'JOB_OPEN:'       "#EC NOTEXT
                                          'Jobname = '      "#EC NOTEXT
                                          jobname
                                          ' '.

*********************************************************


***** c5034979 XBP20, change *****
  CLEAR ret.

*
* Parameter verproben
*
  IF jobname EQ space.
    RAISE jobname_missing.
  ENDIF.
* break-point.
  REFRESH global_step_tbl.
  CLEAR   global_step_tbl.
  CLEAR   global_job.

* Name des Aufrufers ermitteln
  CALL 'AB_GET_CALLER' ID 'PROGRAM' FIELD calling_abap.
*
* Uebergabe-Struktur fuer Jobdaten fuellen. Starttermindaten werden
* absichtlich nicht mehr berücksichtigt, sondern nur aus Kompatibili-
* tätsgründen in der Schnittstelle belassen ( wird später entfernt )
*
  global_job-jobname   = jobname.
* global_job-delanfrep = delanfrep.
* GLOBAL_JOB-SDLSTRTDT = SDLSTRTDT.
* GLOBAL_JOB-SDLSTRTTM = SDLSTRTTM.


* 14.3.2012   d023157    note 1695812 ******
if check_jobclass = 'X'.

   if jobclass = 'A'.
      AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

      if sy-subrc ne 0.
         AUTHORITY-CHECK
               OBJECT 'S_BTCH_ADM'
               ID 'BTCADMIN' FIELD 'A'.

         if sy-subrc ne 0.
            jobclass = 'C'.
            info = change_class_2_c.   " value is 2
         endif.
      endif.
   endif.

   if jobclass = 'B'.
      AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

      if sy-subrc ne 0.
         AUTHORITY-CHECK
               OBJECT 'S_BTCH_ADM'
               ID 'BTCADMIN' FIELD 'B'.

         if sy-subrc ne 0.
            jobclass = 'C'.
            info = change_class_2_c.  " value is 2
         endif.
      endif.
   endif.

endif.
********** end note 1695812 *******************


***** c5034979 XBP20, change *****
* Jobklasse zunächst gemäß dem Parameter jobclass setzen.
* Dies kann danach noch übersteuert werden.
  translate jobclass to upper case.          "#EC TRANSLANG
  IF jobclass = btc_jobclass_a.
    global_job-jobclass  = btc_jobclass_a.
  ELSEIF jobclass = btc_jobclass_b.
    global_job-jobclass  = btc_jobclass_b.
  ELSEIF jobclass = btc_jobclass_c.
    global_job-jobclass  = btc_jobclass_c.
  ELSEIF jobclass IS INITIAL.
    global_job-jobclass  = btc_jobclass_c.
  ELSE.
    ret = err_invalid_jobclass.
    MESSAGE e095 RAISING cant_create_job.
  ENDIF.

* Jobklasse setzen / NEWFLAG auf 'O'(Open) setzen
* (der Workflow-Job 'SWWDHEX_' bekommt immer Jobklasse A).
* Weiterhin bekommt ein spezieller Einplaner immer Jobklasse A
* wg. der Archivierung auf Datenbankhosts (->F.Hoffmann).
  IF ( jobname EQ 'SWWDHEX' ) OR ( calling_abap EQ central_adk_abap ).
    global_job-jobclass  = btc_jobclass_a.
  ENDIF.

*** hgk  begin
  IMPORT job_a = jobname_class_a FROM MEMORY ID 'BW_JOBNAME_CLASS_A'.
  IF sy-subrc = 0.
    IF jobname_class_a = jobname.
      global_job-jobclass  = btc_jobclass_a.
      FREE MEMORY ID 'BW_JOBNAME_CLASS_A'.
    ENDIF.
  ENDIF.
***hgk  end

  global_job-newflag   = 'O'.
*
* Steptabelle mit Dummy-ABAP fuellen
*
  global_step_tbl-program = 'RSBTCPT3'.
  global_step_tbl-typ     = btc_abap.
  global_step_tbl-status  = btc_scheduled.
  global_step_tbl-authcknam = sy-uname.
  APPEND global_step_tbl.

  CALL FUNCTION 'BP_JOB_CREATE'
    EXPORTING
      job_cr_dialog    = btc_no
      job_cr_head_inp  = global_job
    IMPORTING
      job_cr_head_out  = global_job
      job_cr_stdt_out  = global_start_date
    TABLES
      job_cr_steplist  = global_step_tbl
    EXCEPTIONS
      invalid_job_data = 1
      OTHERS           = 99.

  CASE sy-subrc.
    WHEN 0.
      jobcount = global_job-jobcount.
    WHEN 1.
      IF sy-msgty IS INITIAL.
        RAISE invalid_job_data.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING invalid_job_data.
      ENDIF.
    WHEN OTHERS.
      IF sy-msgty IS INITIAL.
        RAISE cant_create_job.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING cant_create_job.
      ENDIF.
  ENDCASE.

  perform write_string_to_wptrace_btc using tracelevel_btc
                                          'JOB_OPEN:'        "#EC NOTEXT
                                          'Jobcount = '      "#EC NOTEXT
                                          jobcount
                                          ' '.

ENDFUNCTION.
