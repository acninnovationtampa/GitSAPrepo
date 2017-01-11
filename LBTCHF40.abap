*----------------------------------------------------------------------*
*   INCLUDE LBTCHF40                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  get_where_username
*&---------------------------------------------------------------------*
*       build where_statement for jobname
*----------------------------------------------------------------------*
*      -->p_jobname_where  text
*      -->p_select_values  text
*----------------------------------------------------------------------*
FORM get_where_jobname USING    p_jobname_where TYPE where_type
                                p_select_values STRUCTURE btcselectp.

  DATA jo TYPE where_type VALUE IS INITIAL.

  CLEAR p_jobname_where.
  jo = p_select_values-jobname.

  IF jo <> space AND NOT jo IS INITIAL AND jo <> '*'.
    PERFORM check_comma USING jo.
    IF jo CA '*'.
      TRANSLATE jo USING '*%'.
      CONCATENATE 'JOBNAME LIKE '''jo '''' INTO jo.
    ELSE.
      CONCATENATE 'JOBNAME = '''jo '''' INTO jo.
    ENDIF.
    p_jobname_where = jo.
  ELSE.
    CLEAR p_jobname_where.
  ENDIF.

ENDFORM.                    " get_where_jobname
*&---------------------------------------------------------------------*
*&      Form  get_where_username
*&---------------------------------------------------------------------*
*       build where_statement for username
*----------------------------------------------------------------------*
*      -->P_USERNAME_WHERE  text
*      -->p_select_values  text
*----------------------------------------------------------------------*
FORM get_where_username USING   p_username_where TYPE where_type
                                p_select_values STRUCTURE btcselectp.

  DATA us TYPE where_type VALUE IS INITIAL.

  CLEAR p_username_where.
  us = p_select_values-username.

  IF us <> space AND NOT us IS INITIAL AND us <> '*'.
    PERFORM check_comma USING us.
    IF us CA '*'.
      TRANSLATE us USING '*%'.
      CONCATENATE 'SDLUNAME LIKE '''us '''' INTO us.
    ELSE.
      CONCATENATE 'SDLUNAME = '''us '''' INTO us.
    ENDIF.
    p_username_where = us.
  ELSE.
    CLEAR p_username_where.
  ENDIF.

ENDFORM.                    " get_where_username

*&---------------------------------------------------------------------*
*&      Form  build_where_statement
*&---------------------------------------------------------------------*
*       build complete where_statement dynamic
*----------------------------------------------------------------------*
*      -->P_WHERE_TAB  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM build_where_statement USING p_where_tab
                                 select_values STRUCTURE btcselectp
                                 p_execserver TYPE tbtco-execserver
                                 p_reaxserver TYPE tbtco-reaxserver
                                 rc TYPE i.

  DATA: where_statement TYPE where_type,
        i_where_tab TYPE TABLE OF where_type,
        i TYPE i VALUE IS INITIAL,
        tmp_state TYPE where_type VALUE IS INITIAL,
        tmp_from TYPE where_type VALUE IS INITIAL,
        tmp_event TYPE where_type VALUE IS INITIAL,
        tmp_job TYPE where_type VALUE IS INITIAL,
        tmp_opmode TYPE where_type VALUE IS INITIAL,
        tmp_scheduled TYPE where_type VALUE IS INITIAL,
        tmp_abap TYPE where_type VALUE IS INITIAL,
        tmp_extcmd TYPE where_type VALUE IS INITIAL,
        tmp_extprg TYPE where_type VALUE IS INITIAL,
        tmp_authcknam TYPE where_type VALUE IS INITIAL,
        tmp_active_start_from TYPE where_type VALUE IS INITIAL,
        tmp_active_stop_from TYPE where_type VALUE IS INITIAL,
        tmp_active_in_from TYPE where_type VALUE IS INITIAL,
        first_value_set TYPE c VALUE IS INITIAL,
        value_len TYPE i,
        state_set TYPE c VALUE IS INITIAL.

  CLEAR p_where_tab.
  CLEAR i_where_tab.

***********************************************************************
*
*check admin rights
*
***********************************************************************
  PERFORM get_where_admin USING where_statement
                                rc.
  IF rc = 0.
    APPEND where_statement TO i_where_tab.
  ENDIF.

***********************************************************************
*
*jobname, username, execserver(execgroup) and reaxserver
*
***********************************************************************

* Build where-statement for jobname
  PERFORM get_where_jobname USING where_statement
                                  jobsel_param_in_p.
*   save where-statement for jobname
  IF NOT where_statement IS INITIAL.
    IF NOT i_where_tab IS INITIAL.
      APPEND 'AND' TO i_where_tab.
    ENDIF.
    APPEND where_statement TO i_where_tab.
  ENDIF.


* Build where-statement for username
  PERFORM get_where_username USING where_statement
                                   jobsel_param_in_p.
*   save where-statement for username
  IF NOT where_statement IS INITIAL.
    IF NOT i_where_tab IS INITIAL.
      APPEND 'AND' TO i_where_tab.
    ENDIF.
    APPEND where_statement TO i_where_tab.
  ENDIF.


* Build where-statement for execserver and execgroup
  PERFORM get_where_execserver USING where_statement
                                     p_execserver
                                     rc.
  IF rc = 0.
*   save where-statement for execserver and execgroup
    IF NOT where_statement IS INITIAL.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
      APPEND where_statement TO i_where_tab.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.
  rc = 0.

* Build where-statement for reaxserver
  PERFORM get_where_reaxserver USING where_statement
                                     p_reaxserver
                                     rc.
  IF rc = 0.
*   save where-statement for reaxserver
    IF NOT where_statement IS INITIAL.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
      APPEND where_statement TO i_where_tab.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.
  rc = 0.

***********************************************************************
*
*register state
*
***********************************************************************
* Build where-statement for job state
  PERFORM get_where_jobstate USING where_statement
                                   jobsel_param_in_p
                                   state_set
                                   rc.
  IF rc = 0.
*   save where-statement for job state to set this value
*   later ( in start parameter )
    tmp_state = where_statement.
  ENDIF.


***********************************************************************
*
*register start selection
*
***********************************************************************
  IF state_set = 'O' OR state_set = 'B'.
    i = 0.
* Build where-statement for date triggered jobs
    PERFORM get_where_dt USING where_statement
                                     jobsel_param_in_p
                                     'S'
                                     rc.
    IF rc = 0 AND NOT where_statement IS INITIAL.
      tmp_from = where_statement.
      i = i + 1.
    ENDIF.

* Build where-statement for event triggered jobs
    PERFORM get_where_event USING where_statement
                                     jobsel_param_in_p
                                     rc.
    IF rc = 0.
      tmp_event = where_statement.
      i = i + 1.
    ENDIF.


* Build where-statement for job triggerd jobs
    PERFORM get_where_job USING where_statement
                                     jobsel_param_in_p
                                     rc.
    IF rc = 0.
      tmp_job = where_statement.
      i = i + 1.
    ENDIF.

* Build where-statement for opmode triggerd jobs
    PERFORM get_where_opmode USING where_statement
                                     jobsel_param_in_p
                                     rc.
    IF rc = 0.
      tmp_opmode = where_statement.
      i = i + 1.
    ENDIF.

    IF state_set = 'B'.
* Build where-statement for only scheduled jobs
      PERFORM get_where_schedule USING where_statement
                                       jobsel_param_in_p
                                       rc.
      IF rc = 0.
        tmp_scheduled = where_statement.
      ENDIF.

    ENDIF.


* Build where-statement for start selection
    IF NOT tmp_scheduled IS INITIAL OR NOT tmp_state IS INITIAL.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND (' TO i_where_tab.
      ELSE.
        APPEND '(' TO i_where_tab.
      ENDIF.

      IF i > 0.
        APPEND '( (' TO i_where_tab.

        value_len = STRLEN( tmp_from ).
        IF value_len > 0.
          APPEND tmp_from TO i_where_tab.
        ELSE.
          APPEND 'SDLSTRTDT LIKE ''%''' TO i_where_tab.
        ENDIF.

        value_len = STRLEN( tmp_event ).
        IF value_len > 0.
          APPEND 'OR' TO i_where_tab.
          APPEND tmp_event TO i_where_tab.
        ENDIF.

        value_len = STRLEN( tmp_job ).
        IF value_len > 0.
          APPEND 'OR' TO i_where_tab.
          APPEND tmp_job TO i_where_tab.
        ENDIF.

        value_len = STRLEN( tmp_opmode ).
        IF value_len > 0.
          APPEND 'OR' TO i_where_tab.
          APPEND tmp_opmode TO i_where_tab.
        ENDIF.

        APPEND ')' TO i_where_tab.

*       Set status criteria
        IF NOT tmp_state IS INITIAL.
          APPEND 'AND' TO i_where_tab.
          APPEND tmp_state TO i_where_tab.
        ENDIF.

        APPEND ')' TO i_where_tab.
      ELSE.
*       Set status criteria
        IF NOT tmp_state IS INITIAL.
          APPEND tmp_state TO i_where_tab.
        ENDIF.
      ENDIF.

      IF NOT tmp_scheduled IS INITIAL.
        IF NOT tmp_state IS INITIAL.
          APPEND 'OR' TO i_where_tab.
          APPEND tmp_scheduled TO i_where_tab.
        ELSE.
          APPEND tmp_scheduled TO i_where_tab.
        ENDIF.
      ENDIF.

      APPEND ')' TO i_where_tab.
    ENDIF.

  ELSEIF state_set = 'P'.
*   Build where-statement for only scheduled jobs
    PERFORM get_where_schedule USING where_statement
                                     jobsel_param_in_p
                                     rc.
    IF rc = 0.
      tmp_scheduled = where_statement.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
      APPEND tmp_scheduled TO i_where_tab.
    ENDIF.

  ELSE.
*   no other state
  ENDIF.
***********************************************************************
*
*register steps
*
***********************************************************************
  i = 0.
  CLEAR first_value_set.
* Build where-statement for abap step
  PERFORM get_where_step_abap USING where_statement
                                   jobsel_param_in_p
                                   rc.
  IF rc = 0.
    tmp_abap = where_statement.
    i = i + 1.
  ENDIF.


* Build where-statement for external command step
  PERFORM get_where_step_cmd USING where_statement
                                   jobsel_param_in_p
                                   rc.
  IF rc = 0.
    tmp_extcmd = where_statement.
    i = i + 1.
  ENDIF.

* Build where-statement for external program step
  PERFORM get_where_step_extprg USING where_statement
                                   jobsel_param_in_p
                                   rc.
  IF rc = 0.
    tmp_extprg = where_statement.
    i = i + 1.
  ENDIF.

* Build where-statement for step user
  PERFORM get_where_step_user USING where_statement
                                   jobsel_param_in_p
                                   rc.
  IF rc = 0.
    tmp_authcknam = where_statement.
    i = i + 1.
  ENDIF.
****************************************************

  IF i > 0.

    IF i = 1.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
    ELSEIF i > 1.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND (' TO i_where_tab.
      ENDIF.
    ENDIF.

    value_len = STRLEN( tmp_abap ).
    IF value_len > 0.
      first_value_set = 'X'.
      APPEND tmp_abap TO i_where_tab.
    ENDIF.

    value_len = STRLEN( tmp_extcmd ).
    IF value_len > 0.
      IF first_value_set = 'X'.
        APPEND 'OR' TO i_where_tab.
      ENDIF.
      APPEND tmp_extcmd TO i_where_tab.
      first_value_set = 'X'.
    ENDIF.

    value_len = STRLEN( tmp_extprg ).
    IF value_len > 0.
      IF first_value_set = 'X'.
        APPEND 'OR' TO i_where_tab.
      ENDIF.
      APPEND tmp_extprg TO i_where_tab.
      first_value_set = 'X'.
    ENDIF.

    value_len = STRLEN( tmp_authcknam ).
    IF value_len > 0.
      IF first_value_set = 'X'.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
      APPEND tmp_authcknam TO i_where_tab.
      first_value_set = 'X'.
    ENDIF.

    IF i > 1.
      APPEND ')' TO i_where_tab.
    ENDIF.
  ENDIF.

***********************************************************************
*
*register active
*
***********************************************************************
  i = 0.
  CLEAR first_value_set.

  IF NOT jobsel_param_in_p-st_active IS INITIAL.
    PERFORM get_where_dt USING where_statement
                                     jobsel_param_in_p
                                     'A'
                                     rc.
    IF rc = 0 AND NOT where_statement IS INITIAL.
      tmp_active_start_from = where_statement.
      i = i + 1.
    ENDIF.
  ENDIF.


  IF NOT jobsel_param_in_p-en_active IS INITIAL.
* Build where-statement for job stop active

    PERFORM get_where_dt USING where_statement
                                     jobsel_param_in_p
                                     'E'
                                     rc.
    IF rc = 0 AND NOT where_statement IS INITIAL.
      tmp_active_stop_from = where_statement.
      i = i + 1.
    ENDIF.
  ENDIF.

  IF NOT jobsel_param_in_p-be_active IS INITIAL.
* Build where-statement for active in time
    PERFORM get_where_was_active
        USING jobsel_param_in_p-f_date_b jobsel_param_in_p-f_time_b
              jobsel_param_in_p-t_date_b jobsel_param_in_p-t_time_b
        CHANGING where_statement.

    IF NOT where_statement IS INITIAL.
      tmp_active_in_from = where_statement.
      i = i + 1.
    ENDIF.
  ENDIF.

  IF i > 0.

    IF i = 1.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ENDIF.
    ELSEIF i > 1.
      IF NOT i_where_tab IS INITIAL.
        APPEND 'AND (' TO i_where_tab.
      ENDIF.
    ENDIF.

    IF state_set = 'B' OR state_set = 'P'.
      APPEND '(' TO i_where_tab.
    ENDIF.

*   Save start job
    value_len = STRLEN( tmp_active_start_from ).
    IF value_len > 0.
      first_value_set = 'X'.
      APPEND tmp_active_start_from TO i_where_tab.
      IF NOT tmp_active_stop_from IS INITIAL.
        APPEND 'AND' TO i_where_tab.
      ELSE.
        IF NOT tmp_active_in_from IS INITIAL.
          APPEND 'OR' TO i_where_tab.
        ENDIF.
      ENDIF.
    ENDIF.


*   Save stop job
    IF NOT tmp_active_stop_from IS INITIAL.
      first_value_set = 'X'.
      APPEND tmp_active_stop_from TO i_where_tab.

      IF NOT tmp_active_in_from IS INITIAL.
        APPEND 'OR' TO i_where_tab.
      ENDIF.
    ENDIF.


*   Save job in
    IF NOT tmp_active_in_from IS INITIAL.
      first_value_set = 'X'.
      APPEND '(' TO i_where_tab.
      APPEND tmp_active_in_from TO i_where_tab.
      APPEND ')' TO i_where_tab.
    ENDIF.


    IF i > 1.
      APPEND ')' TO i_where_tab.
    ENDIF.

    IF state_set = 'B' OR state_set = 'P'.
      APPEND 'OR' TO i_where_tab.
      APPEND tmp_scheduled TO i_where_tab.
      APPEND ')' TO i_where_tab.
    ENDIF.

  ENDIF.

***********************************************************************
*
*register period
*
***********************************************************************
* Build where-statement for period
  PERFORM get_where_period USING where_statement
                                  jobsel_param_in_p
                                  rc.
  IF rc = 0.
*   save where-statement for period
    IF NOT i_where_tab IS INITIAL.
      APPEND 'AND (' TO i_where_tab.
    ELSE.
      APPEND '(' TO i_where_tab.
    ENDIF.
    APPEND where_statement TO i_where_tab.
    APPEND ')' TO i_where_tab.
  ENDIF.

  rc = 0.
  p_where_tab = i_where_tab.

ENDFORM.                    " build_where_statement

*&---------------------------------------------------------------------*
*&      Form  get_where_jobstate
*&---------------------------------------------------------------------*
*       build where statement for jobstate
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_jobstate USING   p_jobstate_where TYPE where_type
                                select_values STRUCTURE btcselectp
                                state_set TYPE c
                                rc TYPE i.


  DATA v TYPE where_type VALUE IS INITIAL.

* state set flags:
* P = planned
* O = other
* B = both
  CLEAR state_set.

* put scheduled job
  IF NOT status_set-scheduled_flag IS INITIAL.
*    CONCATENATE 'IN (''' status_set-scheduled_flag '''' INTO v.
    state_set = 'P'.
  ENDIF.

* put/append released job
  IF NOT status_set-released_flag IS INITIAL.
    IF state_set = 'P'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-released_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-released_flag '''' INTO v.
    ENDIF.
  ENDIF.

* put/append ready job
  IF NOT status_set-ready_flag IS INITIAL.
    IF state_set = 'P' OR state_set = 'B'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-ready_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-ready_flag '''' INTO v.
    ENDIF.
  ENDIF.

* put/append active job
  IF NOT status_set-active_flag IS INITIAL.
    IF state_set = 'P' OR state_set = 'B'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-active_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-active_flag '''' INTO v.
    ENDIF.
  ENDIF.


* put/append finished job
  IF NOT status_set-finished_flag IS INITIAL.
    IF state_set = 'P' OR state_set = 'B'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-finished_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-finished_flag '''' INTO v.
    ENDIF.
  ENDIF.


* put/append cancelled job
  IF NOT status_set-cancelled_flag IS INITIAL.
    IF state_set = 'P' OR state_set = 'B'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-cancelled_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-cancelled_flag '''' INTO v.
    ENDIF.
  ENDIF.


* put/append suspended job
  IF NOT status_set-suspended_flag IS INITIAL.
    IF state_set = 'P' OR state_set = 'B'.
      state_set = 'B'.
    ELSE.
      state_set = 'O'.
    ENDIF.
    IF NOT v IS INITIAL.
      CONCATENATE v ',''' status_set-suspended_flag '''' INTO v.
    ELSE.
      CONCATENATE 'IN (''' status_set-suspended_flag '''' INTO v.
    ENDIF.
  ENDIF.

  IF NOT v IS INITIAL.
    SHIFT v RIGHT.
    CONCATENATE 'Status' v ')' INTO v.                      "#EC NOTEXT
  ENDIF.

  p_jobstate_where = v.
  IF NOT p_jobstate_where IS INITIAL.
    rc = 0.
  ELSE.
    rc = no_status_selected.
  ENDIF.
ENDFORM.                    " get_where_jobstate

*&---------------------------------------------------------------------*
*&      Form  get_where_event
*&---------------------------------------------------------------------*
*       Build where-statement for event triggered jobs
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_event USING    p_event_where TYPE where_type
                              select_values STRUCTURE btcselectp
                              rc TYPE i.

  DATA: ev TYPE where_type VALUE IS INITIAL,
        only_event(14) TYPE c VALUE IS INITIAL,
        eid(17) TYPE c VALUE IS INITIAL.

  IF NOT select_values-eventid IS INITIAL.

    ev = select_values-eventid.

    IF ev = '*' AND select_values-jobid IS INITIAL.
*   only event triggered jobs wanted (no job triggered)
      only_event = 'SAP_END_OF_JOB'.
    ENDIF.

    IF ev = '*' AND select_values-opmodeid IS INITIAL.
*   only event triggered jobs wanted (no opmode triggered)
      eid = 'SAP_OPMODE_SWITCH'.
    ENDIF.

    IF  ev  CA '*'.
      TRANSLATE ev USING '*%'.
      CONCATENATE ' EVENTID LIKE '''ev '''' INTO ev.
    ELSE.
      CONCATENATE ' EVENTID = '''ev '''' INTO ev.
    ENDIF.

    CONCATENATE ev ' AND EVENTID ne '''space '''' INTO ev.  "#EC NOTEXT

    IF NOT only_event IS INITIAL.
      CONCATENATE ev ' AND EVENTID ne '''only_event '''' INTO ev.  "#EC NOTEXT
    ENDIF.

    IF NOT eid IS INITIAL.
      CONCATENATE ev ' AND EVENTID ne '''eid '''' INTO ev.         "#EC NOTEXT
    ENDIF.

    CONCATENATE '(' ev ' )' INTO ev.

    rc = 0.

  ELSE.
    rc = no_event_triggered.
  ENDIF.

  p_event_where = ev.

ENDFORM.                    " get_where_event
*&---------------------------------------------------------------------*
*&      Form  get_where_job
*&---------------------------------------------------------------------*
*       Build where-statement for job triggered jobs
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_job USING    p_job_where TYPE where_type
                            select_values STRUCTURE btcselectp
                            rc TYPE i.

  DATA jo TYPE where_type VALUE IS INITIAL.

  IF NOT select_values-jobid IS INITIAL.
    DATA eid(14) TYPE c VALUE 'SAP_END_OF_JOB'.

    jo = select_values-jobid.

    PERFORM check_comma USING jo.

    IF jo CA '*'.
      TRANSLATE jo USING '*%'.
    ELSE.
      DATA: jo_len TYPE i,
            mul_job(255) TYPE c VALUE '%'.

     DESCRIBE FIELD select_values-jobid LENGTH jo_len IN CHARACTER MODE.
      jo_len = jo_len - STRLEN( jo ).
      SHIFT mul_job RIGHT BY jo_len PLACES.
      CONCATENATE jo mul_job INTO jo.
    ENDIF.

    CONCATENATE ' EVENTPARM LIKE '''jo'''' INTO jo.
    CONCATENATE 'EVENTID = ''' eid'''' ' AND' jo INTO jo.

    rc = 0.

  ELSE.
    rc = no_job_triggered.
  ENDIF.

  p_job_where = jo.

ENDFORM.                    " get_where_job
*&---------------------------------------------------------------------*
*&      Form  get_where_opmode
*&---------------------------------------------------------------------*
*       Build where-statement for opmode switch triggered jobs
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_opmode USING  p_opmode_where TYPE where_type
                             select_values STRUCTURE btcselectp
                             rc TYPE i.

  DATA op TYPE where_type VALUE IS INITIAL.

  IF NOT select_values-opmodeid IS INITIAL.
    DATA eid(17) TYPE c VALUE 'SAP_OPMODE_SWITCH'.

    op = select_values-opmodeid.
    IF op CA '*'.
      TRANSLATE op USING '*%'.
      CONCATENATE ' EVENTPARM LIKE '''op'''' INTO op.
    ELSE.
      CONCATENATE ' EVENTPARM = '''op'''' INTO op.
    ENDIF.

    CONCATENATE 'EVENTID = ''' eid'''' ' AND' op INTO op.

    rc = 0.

  ELSE.
    rc = no_opmode_triggered.
  ENDIF.

  p_opmode_where = op.

ENDFORM.                    " get_where_opmode

*&---------------------------------------------------------------------*
*&      Form  get_where_step_abap
*&---------------------------------------------------------------------*
*       Build where-statement for abap steps
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_step_abap USING  p_abap_where TYPE where_type
                                select_values STRUCTURE btcselectp
                                rc TYPE i.

  DATA abpr TYPE where_type VALUE IS INITIAL.

  abpr = select_values-abapname.

  IF abpr EQ space.
    rc = no_abap_specified.
  ELSE.

    PERFORM check_comma USING abpr.

    IF  abpr  CA '*'.
      TRANSLATE abpr USING '*%'.
      CONCATENATE 'PROGNAME LIKE '''abpr '''' INTO abpr.
    ELSE.
      CONCATENATE 'PROGNAME = '''abpr '''' INTO abpr.
    ENDIF.
    rc = 0.
  ENDIF.
  p_abap_where = abpr.
ENDFORM.                    " get_where_step_abap

*&---------------------------------------------------------------------*
*&      Form  get_where_step_cmd
*&---------------------------------------------------------------------*
*       Build where-statement for external command steps
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_step_cmd USING   p_extcmd_where TYPE where_type
                                select_values STRUCTURE btcselectp
                                rc TYPE i.

  DATA extc TYPE where_type VALUE IS INITIAL.

  extc = select_values-extcmd.

  IF extc EQ space.
    rc = no_extcmd_specified.
  ELSE.
    IF  extc  CA '*'.
      TRANSLATE extc USING '*%'.
      CONCATENATE 'EXTCMD LIKE '''extc '''' INTO extc.
    ELSE.
      CONCATENATE 'EXTCMD = '''extc '''' INTO extc.
    ENDIF.
    rc = 0.
  ENDIF.
  p_extcmd_where = extc.
ENDFORM.                    " get_where_step_cmd

*&---------------------------------------------------------------------*
*&      Form  get_where_step_extprg
*&---------------------------------------------------------------------*
*       Build where-statement for external program steps
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_step_extprg USING  p_extprg_where TYPE where_type
                                  select_values STRUCTURE btcselectp
                                  rc TYPE i.

  DATA extp TYPE where_type VALUE IS INITIAL.

  extp = select_values-extprog.

  IF extp EQ space.
    rc = no_extprg_specified.
  ELSE.

    PERFORM check_comma USING extp.

    IF  extp  CA '*'.
      TRANSLATE extp USING '*%'.
      CONCATENATE 'XPGPROG LIKE '''extp '''' INTO extp.
    ELSE.
      CONCATENATE 'XPGPROG = '''extp '''' INTO extp.
    ENDIF.
    rc = 0.
  ENDIF.

  p_extprg_where = extp.

ENDFORM.                    " get_where_step_extprg

*&---------------------------------------------------------------------*
*&      Form  get_where_step_user
*&---------------------------------------------------------------------*
*       Build where-statement for step user
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_step_user USING  p_stepuser_where TYPE where_type
                                select_values STRUCTURE btcselectp
                                rc TYPE i.

  DATA stepuser TYPE where_type VALUE IS INITIAL.

  stepuser = select_values-authcknam.

  IF stepuser EQ space.
    rc = no_stepuser_specified.
  ELSE.

    PERFORM check_comma USING stepuser.

    IF  stepuser  CA '*'.
      TRANSLATE stepuser USING '*%'.
      CONCATENATE 'AUTHCKNAM LIKE '''stepuser '''' INTO stepuser.
    ELSE.
      CONCATENATE 'AUTHCKNAM = '''stepuser '''' INTO stepuser.
    ENDIF.
    rc = 0.
  ENDIF.
  p_stepuser_where = stepuser.

ENDFORM.                    " get_where_step_user
*&---------------------------------------------------------------------*
*&      Form  get_where_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_period USING    p_period_where TYPE where_type
                               select_values STRUCTURE btcselectp
                               rc TYPE i.

  DATA: per TYPE where_type VALUE IS INITIAL,
        value_set TYPE c VALUE IS INITIAL.

  IF select_values-non_perd = 'X'.
    CONCATENATE 'PERIODIC = '''space '''' INTO per.
    rc = 0.
  ELSEIF select_values-period = 'X'.

    IF select_values-nrmonths > 0.
      CONCATENATE 'PRDMONTHS = '''select_values-nrmonths '''' INTO per.
      value_set = 'X'.
    ENDIF.

    IF select_values-nrweeks > 0.
      IF value_set = 'X'.
     CONCATENATE per ' OR PRDWEEKS = '''select_values-nrweeks '''' INTO
                                                                    per.
      ELSE.
        CONCATENATE 'PRDWEEKS = '''select_values-nrweeks '''' INTO per.
        value_set = 'X'.
      ENDIF.
    ENDIF.

    IF select_values-nrdays > 0.
      IF value_set = 'X'.
       CONCATENATE per ' OR PRDDAYS = '''select_values-nrdays '''' INTO
                                               per.
      ELSE.
        CONCATENATE 'PRDDAYS = '''select_values-nrdays '''' INTO per.
        value_set = 'X'.
      ENDIF.
    ENDIF.

    IF select_values-nrhours > 0.
      IF value_set = 'X'.
     CONCATENATE per ' OR PRDHOURS = '''select_values-nrhours '''' INTO
                                                                    per.
      ELSE.
        CONCATENATE 'PRDHOURS = '''select_values-nrhours '''' INTO per.
        value_set = 'X'.
      ENDIF.
    ENDIF.

    IF select_values-nrminutes > 0.
      IF value_set = 'X'.
        CONCATENATE per ' OR PRDMINS = '''select_values-nrminutes ''''
INTO per.
      ELSE.
        CONCATENATE 'PRDMINS = '''select_values-nrminutes '''' INTO
 per.
        value_set = 'X'.
      ENDIF.
    ENDIF.

    IF value_set IS INITIAL.
      value_set = 'X'.
      CONCATENATE 'PERIODIC = '''value_set '''' INTO per.
    ENDIF.
    rc = 0.

  ELSE.
    rc = no_period_specified.
  ENDIF.
  p_period_where = per.
ENDFORM.                    " get_where_period


*&---------------------------------------------------------------------*
*&      Form  get_where_admin
*&---------------------------------------------------------------------*
*       Build where statement for the admin rights
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_admin USING  p_admin_where TYPE where_type
                            rc TYPE i.

  DATA ad TYPE where_type VALUE IS INITIAL.

  IF batch_admin_privilege_given = btc_no.
    rc = 0.
    CONCATENATE 'AUTHCKMAN = '''sy-mandt '''' INTO ad.
  ELSE.
    rc = no_admin_specified.
  ENDIF.

  p_admin_where = ad.
ENDFORM.                    " get_where_admin


*&---------------------------------------------------------------------*
*&      Form  get_where_schedule
*&---------------------------------------------------------------------*
*       Build where statement for scheduled jobs
*----------------------------------------------------------------------*
*      -->P_WHERE_STATEMENT  text
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM get_where_schedule USING    p_schedule_where TYPE where_type
                                 select_values STRUCTURE btcselectp
                                 rc TYPE i.

  DATA: s TYPE where_type VALUE IS INITIAL,
        f TYPE c VALUE IS INITIAL.

  f = status_set-scheduled_flag.
  IF NOT f IS INITIAL.
    CONCATENATE 'STATUS = ''' f '''' INTO s.
    rc = 0.
  ELSE.
    rc = no_scheduled_specified.
  ENDIF.

  p_schedule_where = s.
ENDFORM.                    " get_where_schedule


*----------------------------------------------------------------------*
*   INCLUDE LBTCHF40                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           LBTCHF40                                         *
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM check_comma                                              *
*---------------------------------------------------------------------*
*       check for single quotation mark
*---------------------------------------------------------------------*
*  -->  p_text                                                        *
*---------------------------------------------------------------------*
FORM check_comma USING p_text TYPE where_type.

  TYPES commatext(255) TYPE c.
  DATA: comma_one(1) TYPE c VALUE '''',
        comma_two(2) TYPE c VALUE '''''',
        commatab TYPE TABLE OF commatext,
        wa_commatab TYPE commatext VALUE IS INITIAL,
        last_pos TYPE i VALUE IS INITIAL,
        last_tab_pos TYPE i VALUE IS INITIAL,
        last_hit TYPE c VALUE IS INITIAL,
        new_text TYPE commatext VALUE IS INITIAL.

  IF p_text CA comma_one.
    SPLIT p_text AT comma_one INTO TABLE commatab.

    DESCRIBE TABLE commatab LINES last_tab_pos.
    last_pos = STRLEN( p_text ).

    SEARCH p_text FOR comma_one STARTING AT last_pos.
    IF sy-subrc = 0.
      last_hit = 'X'.
    ENDIF.

    LOOP AT commatab INTO wa_commatab.
      IF sy-tabix = last_tab_pos.
        IF last_hit = 'X'.
          CONCATENATE new_text wa_commatab comma_two INTO new_text.
        ELSE.
          CONCATENATE new_text wa_commatab INTO new_text.
        ENDIF.
      ELSE.
        CONCATENATE new_text wa_commatab comma_two INTO new_text.
      ENDIF.
    ENDLOOP.
    p_text = new_text.
  ENDIF.
ENDFORM.                    "check_comma

*----------------------------------------------------------*
* Form to build date(d) and time(t) values in SQL statement
*
* field: S - schedule
*        A - start active
*        E - end active
*        I - in period
*
FORM get_where_dt USING p_dt_where TYPE where_type
                        p_select_values STRUCTURE btcselectp
                        p_field TYPE c
                        p_rc TYPE i.

  DATA: v TYPE where_type VALUE IS INITIAL, "sql statement
        d1(10) TYPE c VALUE IS INITIAL, "from date
        t1(8)  TYPE c VALUE IS INITIAL, "from time
        d2(10) TYPE c VALUE IS INITIAL, "to date
        t2(8)  TYPE c VALUE IS INITIAL, "to time
        d1_set TYPE c VALUE IS INITIAL, "flag-from_date is set
        t1_set TYPE c VALUE IS INITIAL, "flag-from_time is set
        d2_set TYPE c VALUE IS INITIAL, "flag-to_date is set
        t2_set TYPE c VALUE IS INITIAL, "flag-to_time is set
        dbf_d TYPE db_field_type, "fieldname date
        dbf_t TYPE db_field_type. "fieldname time

  CLEAR p_rc.

  CASE p_field.
    WHEN 'S'.
      d1 = p_select_values-from_date.
      t1 = p_select_values-from_time.
      d2 = p_select_values-to_date.
      t2 = p_select_values-to_time.
      dbf_d ='SDLSTRTDT'.
      dbf_t ='SDLSTRTTM'.
    WHEN 'A'.
      IF NOT p_select_values-st_active IS INITIAL.
        d1 = p_select_values-f_date_e.
        t1 = p_select_values-f_time_e.
        d2 = p_select_values-t_date_e.
        t2 = p_select_values-t_time_e.
      ENDIF.
      dbf_d ='STRTDATE'.
      dbf_t ='STRTTIME'.
    WHEN 'E'.
      IF NOT p_select_values-en_active IS INITIAL.
        d1 = p_select_values-f_date_l.
        t1 = p_select_values-f_time_l.
        d2 = p_select_values-t_date_l.
        t2 = p_select_values-t_time_l.
      ENDIF.
      dbf_d ='ENDDATE'.
      dbf_t ='ENDTIME'.
    WHEN 'I'.
      IF NOT p_select_values-be_active IS INITIAL.
        d1 = p_select_values-f_date_b.
        t1 = p_select_values-f_time_b.
        d2 = p_select_values-t_date_b.
        t2 = p_select_values-t_time_b.
      ENDIF.
      dbf_d ='ENDDATE'.
      dbf_t ='ENDTIME'.
  ENDCASE.

  IF NOT ( d1 IS INITIAL OR d1 = no_date OR d1 = zero_date ).
    d1_set = 'X'.
  ENDIF.
  IF NOT ( d2 IS INITIAL OR d2 = no_date OR d2 = zero_date ).
    d2_set = 'X'.
  ENDIF.
  IF NOT ( t1 IS INITIAL OR t1 = no_time ).
    t1_set = 'X'.
  ENDIF.
  IF NOT ( t2 IS INITIAL OR t2 = no_time ).
    t2_set = 'X'.
  ENDIF.

* Auswertung
  IF d1 = d2.
* d = d1 = d2
    IF d1_set = 'X'.
      CONCATENATE dbf_d ' = '''d1'''' INTO v.
    ENDIF.
    IF t1 = t2.
      IF t1_set = 'X'.
* date = d AND time = t
        IF d1_set = 'X'.
          SHIFT v RIGHT.
          CONCATENATE ' AND' v INTO v.
        ENDIF.
        CONCATENATE dbf_t ' = '''t1'''' v INTO v.
      ENDIF.
    ELSE.
      IF t1 > t2 AND t1_set = 'X' AND t2_set = 'X'.
        p_rc = no_date_specified.
        EXIT.
      ENDIF.
      IF t2_set = 'X'.
* date = d AND time <= t2
        IF d1_set = 'X'.
          SHIFT v RIGHT.
          CONCATENATE ' AND' v INTO v.
        ENDIF.
        IF t1_set = 'X' AND t1 <> zero_time.
          CONCATENATE dbf_t ' <= '''t2'''' v INTO v.
        ELSE.
          IF t2 = zero_time.
            CONCATENATE dbf_t ' = '''t2'''' v INTO v.
          ELSE.
            CONCATENATE dbf_t ' <= '''t2'''' v INTO v.
          ENDIF.
        ENDIF.
      ENDIF.
      IF t1_set = 'X' AND t1 <> zero_time.
* date = d AND time <= t2
* date = d AND time >= t1 AND time <= t2
        IF d1_set = 'X' OR t2_set = 'X'.
          SHIFT v RIGHT.
          CONCATENATE ' AND' v INTO v.
        ENDIF.
        CONCATENATE dbf_t ' >= '''t1'''' v INTO v.
      ENDIF.
    ENDIF.
  ELSE.
* d1 <> d2
    IF d1 > d2 AND d1_set = 'X' AND d2_set = 'X'.
      p_rc = no_date_specified.
      EXIT.
    ENDIF.
    IF d2_set = 'X'.
      IF t2_set = 'X'.
        IF t2 <> zero_time.
          CONCATENATE dbf_d ' < '''d2'''' ' )' INTO v.
          SHIFT v RIGHT.
          CONCATENATE ' OR' v INTO v.
          CONCATENATE dbf_t ' <= '''t2'''' ' )' v INTO v.
          SHIFT v RIGHT.
          CONCATENATE dbf_d ' = '''d2'''' ' AND ' v INTO v.
          SHIFT v RIGHT.
          CONCATENATE '(' v INTO v.
          SHIFT v RIGHT.
          CONCATENATE '(' v INTO v.
        ELSE.
          CONCATENATE dbf_d ' < '''d2'''' INTO v.
        ENDIF.
      ELSE.
        CONCATENATE dbf_d ' <= '''d2'''' v INTO v.
      ENDIF.
    ELSE.
      IF t2_set = 'X'.
        IF t2 = zero_time.
          CONCATENATE dbf_t ' = '''t2'''' v INTO v.
        ELSE.
          CONCATENATE dbf_t ' <= '''t2'''' v INTO v.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ( d2_set = 'X' OR t2_set = 'X' ) AND
       ( d1_set = 'X' OR t1_set = 'X' ).
      SHIFT v RIGHT.
      CONCATENATE ' AND' v INTO v.
    ENDIF.

    IF d1_set = 'X'.
      IF t1_set = 'X' AND t1 > zero_time.
        CONCATENATE dbf_d ' > '''d1'''' ' )' v INTO v.
        SHIFT v RIGHT.
        CONCATENATE ' OR' v INTO v.
        CONCATENATE dbf_t ' >= '''t1'''' ' )' v INTO v.
        SHIFT v RIGHT.
        CONCATENATE dbf_d ' = '''d1'''' ' AND ' v INTO v.
        SHIFT v RIGHT.
        CONCATENATE '(' v INTO v.
        SHIFT v RIGHT.
        CONCATENATE '(' v INTO v.
      ELSE.
        CONCATENATE dbf_d ' >= '''d1'''' v INTO v.
      ENDIF.
    ELSE.
      IF t1_set = 'X'.
        IF t1 = zero_time.
          CONCATENATE dbf_t ' = '''t1'''' v INTO v.
        ELSE.
          CONCATENATE dbf_t ' >= '''t1'''' v INTO v.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  p_dt_where = v.

ENDFORM.                    " get_where_dt

*&---------------------------------------------------------------------*
*&      Form  get_where_execserver
*&---------------------------------------------------------------------*
*       build where_statement for execserver
*----------------------------------------------------------------------*
*      -->P_JOBNAME_WHERE  text
*----------------------------------------------------------------------*
FORM get_where_execserver
  USING p_execserver_where TYPE where_type
        p_execserver LIKE tbtco-execserver
        p_rc TYPE i.

  DATA: jo TYPE where_type VALUE IS INITIAL.
  DATA: batch LIKE msxxlist-msgtypes VALUE 8.
  DATA: servers TYPE TABLE OF msxxlist INITIAL SIZE 10 WITH HEADER LINE.
  DATA: wa_tsrvgrp TYPE tsrvgrp.

  CLEAR p_rc.
  CLEAR p_execserver_where.
  IF p_execserver IS INITIAL OR p_execserver CO '*'.
    EXIT.
  ENDIF.

  jo = p_execserver.
  PERFORM check_comma USING jo.
  REPLACE ALL OCCURENCES OF '>' IN jo WITH ''.
  REPLACE ALL OCCURENCES OF '<' IN jo WITH ''.

  IF jo CA '*'.
    TRANSLATE jo USING '*%'.
    CONCATENATE
  '( EXECSERVER LIKE '''jo ''' OR TGTSRVGRP LIKE '''jo ''' )' INTO jo.
    p_execserver_where = jo.
    EXIT.
  ELSE.
    CALL FUNCTION 'TH_SERVER_LIST'
      EXPORTING
        services       = batch
      TABLES
        list           = servers
      EXCEPTIONS
        no_server_list = 1
        OTHERS         = 99.
    IF sy-subrc = 0.
      READ TABLE servers WITH KEY name = jo.
      IF sy-subrc = 0.
* p_execserver is an existing server
        CONCATENATE 'EXECSERVER = '''jo '''' INTO jo.
        p_execserver_where = jo.
        EXIT.
      ENDIF.
    ENDIF.

* p_execserver is NOT an existing server
    TRANSLATE jo TO UPPER CASE.
    SELECT SINGLE * FROM tsrvgrp INTO wa_tsrvgrp
      WHERE grpname = jo.
    IF sy-subrc = 0.
* p_execserver is an existing servergroup
      CONCATENATE 'TGTSRVGRP = '''wa_tsrvgrp-guid '''' INTO jo.
      p_execserver_where = jo.
    ELSE.
      p_rc = incorrect_servername.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_where_execserver


*&---------------------------------------------------------------------*
*&      Form  get_where_reaxserver
*&---------------------------------------------------------------------*
*       build where_statement for jobname
*----------------------------------------------------------------------*
*      -->P_JOBNAME_WHERE  text
*----------------------------------------------------------------------*
FORM get_where_reaxserver
  USING p_reaxserver_where TYPE where_type
        p_reaxserver LIKE tbtco-reaxserver
        p_rc TYPE i.

  DATA: jo TYPE where_type VALUE IS INITIAL.
  DATA: batch LIKE msxxlist-msgtypes VALUE 8.
  DATA: servers TYPE TABLE OF msxxlist INITIAL SIZE 10 WITH HEADER LINE.

  CLEAR p_rc.
  CLEAR p_reaxserver_where.
  IF p_reaxserver IS INITIAL OR p_reaxserver CO '*'.
    EXIT.
  ENDIF.

  jo = p_reaxserver.
  PERFORM check_comma USING jo.

  IF jo CA '*'.
    TRANSLATE jo USING '*%'.
    CONCATENATE 'REAXSERVER LIKE '''jo '''' INTO jo.
    p_reaxserver_where = jo.
    EXIT.
  ELSE.
    CALL FUNCTION 'TH_SERVER_LIST'
      EXPORTING
        services       = batch
      TABLES
        list           = servers
      EXCEPTIONS
        no_server_list = 1
        OTHERS         = 99.
    IF sy-subrc = 0.
      READ TABLE servers WITH KEY name = jo.
      IF sy-subrc = 0.
* p_execserver is an existing server
        CONCATENATE 'REAXSERVER = '''jo '''' INTO jo.
        p_reaxserver_where = jo.
        EXIT.
      ENDIF.
    ENDIF.

    p_rc = incorrect_servername.
  ENDIF.

ENDFORM.                    " get_where_reaxserver

*---------------------------------------------------------------------*
*       FORM get_where_was_active                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FR_DATE                                                       *
*  -->  FR_TIME                                                       *
*  -->  TO_DATE                                                       *
*  -->  TO_TIME                                                       *
*  -->  P_WHERE                                                       *
*---------------------------------------------------------------------*
FORM get_where_was_active
    USING fr_date LIKE sy-datum
          fr_time LIKE sy-uzeit
          to_date LIKE sy-datum
          to_time LIKE sy-uzeit
    CHANGING p_where TYPE where_type.

  DATA:
    str TYPE where_type.

* Fall 1
  IF fr_date IS INITIAL AND to_date IS INITIAL.
    p_where = 'STRTDATE <> '''''.
  ENDIF.

* Fall 2
  IF fr_date IS INITIAL AND NOT to_date IS INITIAL.
    PERFORM print_ls_eq
        USING 'STRTDATE' to_date 'STRTTIME' to_time
        CHANGING str.
    CONCATENATE 'STRTDATE <> '''' AND' str
        INTO p_where SEPARATED BY space.
  ENDIF.

* Fall 3
  IF NOT fr_date IS INITIAL AND to_date IS INITIAL.
    PERFORM print_gr_eq
        USING 'STRTDATE' fr_date 'STRTTIME' fr_time
        CHANGING p_where.
  ENDIF.

* Fall 4
  IF NOT fr_date IS INITIAL AND NOT to_date IS INITIAL.
    PERFORM print_ls_eq
        USING 'STRTDATE' to_date 'STRTTIME' to_time
        CHANGING str.
    CONCATENATE 'STRTDATE <> '''' AND' str 'AND ( ENDDATE = '''' OR'
        INTO p_where SEPARATED BY space.
    PERFORM print_gr_eq
        USING 'ENDDATE' fr_date 'ENDTIME' fr_time
        CHANGING str.
    CONCATENATE p_where str ')' INTO p_where SEPARATED BY space.
  ENDIF.

ENDFORM.                    "get_where_was_active

*---------------------------------------------------------------------*
*       FORM print_ls_eq                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_STR1                                                        *
*  -->  P_DATE                                                        *
*  -->  P_STR2                                                        *
*  -->  P_TIME                                                        *
*  -->  P_STR                                                         *
*---------------------------------------------------------------------*
FORM print_ls_eq
    USING p_str1 TYPE c
          p_date LIKE sy-datum
          p_str2 TYPE c
          p_time LIKE sy-uzeit
    CHANGING p_str TYPE where_type.

  DATA:
    i_date(10) TYPE c,
    i_time(8)  TYPE c.

  CLEAR p_str.
  CONCATENATE '''' p_date '''' INTO i_date.
  CONCATENATE '''' p_time '''' INTO i_time.
  IF p_time IS INITIAL OR p_time CO ' '.
    CONCATENATE p_str1 '<=' i_date INTO p_str SEPARATED BY space.
  ELSE.
    CONCATENATE '(' p_str1 '<' i_date 'OR ('
                p_str1 '=' i_date 'AND' p_str2 '<=' i_time ') )'
        INTO p_str SEPARATED BY space.
  ENDIF.

ENDFORM.                    "print_ls_eq

*---------------------------------------------------------------------*
*       FORM print_gr_eq                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_STR1                                                        *
*  -->  P_DATE                                                        *
*  -->  P_STR2                                                        *
*  -->  P_TIME                                                        *
*  -->  P_STR                                                         *
*---------------------------------------------------------------------*
FORM print_gr_eq
    USING p_str1 TYPE c
          p_date LIKE sy-datum
          p_str2 TYPE c
          p_time LIKE sy-uzeit
    CHANGING p_str TYPE where_type.

  DATA:
    i_date(10) TYPE c,
    i_time(8)  TYPE c.

  CLEAR p_str.
  CONCATENATE '''' p_date '''' INTO i_date.
  CONCATENATE '''' p_time '''' INTO i_time.
  IF p_time IS INITIAL OR p_time CO ' '.
    CONCATENATE p_str1 '>=' i_date INTO p_str SEPARATED BY space.
  ELSE.
    CONCATENATE '(' p_str1 '>' i_date 'OR ('
                p_str1 '=' i_date 'AND' p_str2 '>=' i_time ') )'
        INTO p_str SEPARATED BY space.
  ENDIF.

ENDFORM.                    "print_gr_eq
