**INCLUDE LBTCHF01 .

************************************************************************
*   Hilfsroutinen Funktionsbaustein SHOW_BATCH_JOBS_SNAPSHOT           *
************************************************************************

*---------------------------------------------------------------------*
* FORM GET_BATCH_JOBS_STATUS                                          *
*---------------------------------------------------------------------*
* diese Routine liest alle zu einem User gehörenden Batchjobinfor-    *
* mationen aus der Tabelle TBTCO in eine interne Tabelle, ermittelt   *
* die Anzahl der Jobs pro Status und die 5 jüngsten aktiven bzw. die  *
* 3 jüngsten abgebrochenen Jobs                                       *
*---------------------------------------------------------------------*

FORM get_batch_jobs_status.

  DATA: time_diff   TYPE p,
        num_of_job  TYPE i.

  DATA: BEGIN OF job_select_params.
          INCLUDE STRUCTURE btcselect.
  DATA: END OF job_select_params.
*
* initialisiere die Zustandszaehler und Jobwerte auf dem Dynpro
*
  CLEAR btch1230.
*
* lies Batchjobdaten des Users
*
  CLEAR job_select_params.

  job_select_params-jobname  = wildcard.
  job_select_params-username = sy-uname.
  job_select_params-prelim   = 'X'.
  job_select_params-schedul  = 'X'.
  job_select_params-ready    = 'X'.
  job_select_params-running  = 'X'.
  job_select_params-finished = 'X'.
  job_select_params-aborted  = 'X'.

  CALL FUNCTION 'BP_JOB_SELECT'
    EXPORTING
      jobselect_dialog  = btc_no
      jobsel_param_in   = job_select_params
    TABLES
      jobselect_joblist = global_job_list
    EXCEPTIONS
      OTHERS            = 99.

  IF sy-subrc NE 0. " keine Jobs gefunden, es gibt hier nichts mehr
    EXIT.          " zu tun.
  ENDIF.
*
*  ermittle die Anzahl der Jobs in den verschiedenen Zustaenden und
*  streue die Werte in das Dynpro 1230 ein
*
  LOOP AT global_job_list.
    CASE global_job_list-status.
      WHEN btc_scheduled.
        btch1230-scheduled = btch1230-scheduled + 1.
      WHEN btc_released.
        btch1230-released  = btch1230-released + 1.
      WHEN btc_ready.
        btch1230-ready     = btch1230-ready + 1.
      WHEN btc_running.
        btch1230-active    = btch1230-active + 1.
      WHEN btc_finished.
        btch1230-finished  = btch1230-finished + 1.
      WHEN btc_aborted.
        btch1230-aborted   = btch1230-aborted + 1.
    ENDCASE.
  ENDLOOP.
*
*  ermittle die 5 jüngsten aktiven Jobs und streue die Jobwerte in das
*  Dynpro 1230 ein
*
  GET TIME.

  SORT global_job_list BY strtdate DESCENDING
                          strttime DESCENDING.

  num_of_job = 0.

  LOOP AT global_job_list WHERE status EQ btc_running.
    num_of_job = num_of_job + 1.
    IF num_of_job > 5.
      EXIT.
    ENDIF.

    CONDENSE global_job_list-strtdate.
    IF NOT ( global_job_list-strtdate IS INITIAL
             OR global_job_list-strtdate = ' ' ).
      time_diff = ( sy-datum * sec_per_day + sy-uzeit ) -
                  ( global_job_list-strtdate * sec_per_day +
                    global_job_list-strttime ).
    ELSE.
      time_diff = 0.
    ENDIF.

    CASE num_of_job.
      WHEN 1.
        btch1230-rjob1     = global_job_list-jobname.
        btch1230-rjob1cnt  = global_job_list-jobcount.
        btch1230-runtrjob1 = time_diff.
        btch1230-tgtsrjob1 = global_job_list-btcsysreax.
      WHEN 2.
        btch1230-rjob2     = global_job_list-jobname.
        btch1230-rjob2cnt  = global_job_list-jobcount.
        btch1230-runtrjob2 = time_diff.
        btch1230-tgtsrjob2 = global_job_list-btcsysreax.
      WHEN 3.
        btch1230-rjob3     = global_job_list-jobname.
        btch1230-rjob3cnt  = global_job_list-jobcount.
        btch1230-runtrjob3 = time_diff.
        btch1230-tgtsrjob3 = global_job_list-btcsysreax.
      WHEN 4.
        btch1230-rjob4     = global_job_list-jobname.
        btch1230-rjob4cnt  = global_job_list-jobcount.
        btch1230-runtrjob4 = time_diff.
        btch1230-tgtsrjob4 = global_job_list-btcsysreax.
      WHEN 5.
        btch1230-rjob5     = global_job_list-jobname.
        btch1230-rjob5cnt  = global_job_list-jobcount.
        btch1230-runtrjob5 = time_diff.
        btch1230-tgtsrjob5 = global_job_list-btcsysreax.
    ENDCASE.
  ENDLOOP.
*
*  ermittle die 3 jüngsten abgebrochenen Jobs und streue die Jobwerte
*  in das Dynpro 1230 ein
*
  SORT global_job_list BY enddate DESCENDING
                          endtime DESCENDING.

  num_of_job = 0.

  LOOP AT global_job_list WHERE status EQ btc_aborted.
    num_of_job = num_of_job + 1.
    IF num_of_job > 3.
      EXIT.
    ENDIF.

    CASE num_of_job.
      WHEN 1.
        btch1230-ajob1     = global_job_list-jobname.
        btch1230-ajob1cnt  = global_job_list-jobcount.
        btch1230-runtajob1 = global_job_list-endtime.
        btch1230-tgtsajob1 = global_job_list-btcsysreax.
      WHEN 2.
        btch1230-ajob2     = global_job_list-jobname.
        btch1230-ajob2cnt  = global_job_list-jobcount.
        btch1230-runtajob2 = global_job_list-endtime.
        btch1230-tgtsajob2 = global_job_list-btcsysreax.
      WHEN 3.
        btch1230-ajob3     = global_job_list-jobname.
        btch1230-ajob3cnt  = global_job_list-jobcount.
        btch1230-runtajob3 = global_job_list-endtime.
        btch1230-tgtsajob3 = global_job_list-btcsysreax.
    ENDCASE.
  ENDLOOP.

ENDFORM. " GET_BATCH_JOBS_STATUS.

*&---------------------------------------------------------------------*
*&      Module  STATUS_1146  OUTPUT
*&---------------------------------------------------------------------*
*       Show/hide "no start aftet" data group
*----------------------------------------------------------------------*
MODULE status_1146 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'END'.
      IF btch114x-laststrtdt IS INITIAL OR
        btch114x-laststrtdt EQ space.
        screen-active = off.
        screen-invisible = on.
      ELSE.
        screen-active =  on.
        screen-invisible = off.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " STATUS_1146  OUTPUT
