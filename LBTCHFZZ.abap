*----------------------------------------------------------------------*
***INCLUDE LBTCHFZZ .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_TIME_ONLY_W
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_time_only_w USING select_values STRUCTURE btcselect
                                 status_set    STRUCTURE status_set
                                 batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  IF batch_admin_privilege EQ btc_yes.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR
                    (
                      sdlstrtdt EQ no_date AND
                      eventid   EQ space
                    )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            (
                (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                 )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ELSE.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            authckman EQ sy-mandt
            AND
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR
                    (
                      sdlstrtdt EQ no_date AND
                      eventid   EQ space
                    )
            )
            AND jobname  EQ select_values-jobname
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            authckman EQ sy-mandt
            AND
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
            )
            AND jobname  EQ select_values-jobname
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ENDIF.
  total_selection_count = sy-dbcnt.

ENDFORM.                               " DO_SELECT_TIME_ONLY_W
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_TIME_AND_EVENT_W
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_time_and_event_w USING select_values STRUCTURE btcselect
                                      status_set STRUCTURE status_set
                                      batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  IF batch_admin_privilege EQ btc_yes.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR sdlstrtdt EQ no_date
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ELSE.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR sdlstrtdt EQ no_date
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND authckman EQ sy-mandt
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  EQ select_values-jobname
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND authckman EQ sy-mandt
            AND (p_status_clause).
    ENDIF.
  ENDIF.
  total_selection_count = sy-dbcnt.

ENDFORM.                               " DO_SELECT_TIME_AND_EVENT_W
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_EVENT_ONLY_W
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_event_only_w USING select_values STRUCTURE btcselect
                                  status_set    STRUCTURE status_set
                                  batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  IF batch_admin_privilege EQ btc_yes.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  EQ select_values-jobname
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   ( eventid NE space AND
            eventid  LIKE select_values-eventid AND
            eventparm LIKE select_values-eventparm
            )
    AND (p_status_clause).
  ELSE.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  EQ select_values-jobname
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   ( eventid NE space AND
            eventid  LIKE select_values-eventid AND
            eventparm LIKE select_values-eventparm
            )
    AND   authckman EQ sy-mandt
    AND (p_status_clause).
  ENDIF.
  total_selection_count = sy-dbcnt.

ENDFORM.                               " DO_SELECT_EVENT_ONLY_W
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_GENERAL_W
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_general_w USING select_values STRUCTURE btcselect
                               status_set    STRUCTURE status_set
                               batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  DATA: event_flag LIKE tbtco-eventid.
  event_flag = '%'.

  IF batch_admin_privilege EQ btc_yes.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  EQ select_values-jobname
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   eventid  LIKE event_flag
    AND (p_status_clause).
  ELSE.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  EQ select_values-jobname
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   eventid  LIKE event_flag
    AND authckman EQ sy-mandt
    AND (p_status_clause).
  ENDIF.
  total_selection_count = sy-dbcnt.

ENDFORM.                               " DO_SELECT_GENERAL_W

*&---------------------------------------------------------------------*
*&      Form  RESET_SM37C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_sm37c.
  btch3070-jobname     = '*'.
*  btch3070-username   = sy-uname.
  btch3070-username    = '*'.
  btch3071-from_date   = sy-datum.
  btch3071-to_date     = sy-datum.
  btch3071-from_time   = '        '.
  btch3071-to_time     = '        '.
  btch3071-eventid     = space.
  btch3071-jobid       = space.
  btch3071-opmodeid    = space.
  btch3072-f_date_e    = '          '.
  btch3072-t_date_e    = '          '.
  btch3072-f_time_e    = '        '.
  btch3072-t_time_e    = '        '.
  btch3072-st_active   = space.
  btch3072-en_active   = space.
  btch3072-be_active   = space.
  btch3073-f_date_l    = '          '.
  btch3073-t_date_l    = '          '.
  btch3073-f_time_l    = '        '.
  btch3073-t_time_l    = '        '.
  btch3074-f_date_b    = '          '.
  btch3074-t_date_b    = '          '.
  btch3074-f_time_b    = '        '.
  btch3074-t_time_b    = '        '.
  btch3075-prelim     = space.
*  btch3075-prelim      = 'X'.
  btch3075-schedul     = 'X'.
  btch3075-ready       = 'X'.
  btch3075-running     = 'X'.
  btch3075-finished    = 'X'.
  btch3075-aborted     = 'X'.
  btch3076-dontcare    = 'X'.
  btch3076-period      = space.
  btch3076-non_perd    = space.
  btch3076-nrmonths    = '0'.
  btch3076-nrweeks     = '0'.
  btch3076-nrdays      = '0'.
  btch3076-nrhours     = '0'.
  btch3076-nrminutes   = '0'.
  btch3077-abapname    = space.
  btch3077-extprog     = space.
  btch3077-extcmd      = space.
  btch3077-authcknam   = space.
  btch3070-selfav      = '_DEFAULT'.
ENDFORM.                               " RESET_SM37C
*&---------------------------------------------------------------------*
*&      Form  START_MINI_WIZARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_mini_wizard.
  DATA: jobclass LIKE btch4100-jobclass.

  swc_container container.
  CLEAR definition.

  CLEAR wiz_mode.
  wiz_mode = 'MINI'.

  definition-program = 'SAPLBTCH'.
  definition-text    = text-663.
  definition-form    = 'SM36WIZ_GENERAL_INFO_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-665.
  definition-form    = 'SM36WIZ_ABAP_STEP_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-669.
  definition-form    = 'MINI_START_COND_DEF_MINI'.
  APPEND definition.

  definition-text    = text-670.
  definition-form    = 'SM36WIZ_START_IMM_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-671.
  definition-form    = 'SM36WIZ_START_DT_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-720.
  definition-form    = 'SM36WIZ_PERD_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-677.
  definition-form    = 'SM36WIZ_REST_DEF_SCRN'.
  APPEND definition.

  definition-text    = text-678.
  definition-form    = 'SM36WIZ_FINISHING_SCRN'.
  APPEND definition.

  CONCATENATE btc_jobclass_c text-725 INTO jobclass.
  btch4100-status = text-079.
  btch4100-jobname  = fixed_info-jname.
  btch4100-jobclass = jobclass.
  swc_set_element  container 'btch4100' btch4100.

  btch4210-progname = fixed_info-repname.
  btch4210-variant  = fixed_info-varname.
  btch4210-lang = sy-langu.
  swc_set_element  container 'btch4210' btch4210.

  btch4420-from_date = sy-datum.
  swc_set_element  container 'btch4420' btch4420.

  CALL FUNCTION 'SWF_WIZARD_PROCESS'
    EXPORTING
*     CONTAINER_COMPENSATION      = ' '
      process_logging             = 'X'
      roadmap                     = 'X'
*     OCX                         = 'X'
*     START_COLUMN                = 2
*     START_ROW                   = 2
    TABLES
      definition                  = definition
      container_parameter         = container
    EXCEPTIONS
      operation_cancelled_by_user = 1
      process_in_error            = 2
      OTHERS                      = 3.
  IF sy-subrc <> 0.
    MESSAGE s643
    RAISING operation_cancelled_by_user.
    EXIT.
  ENDIF.

  swc_get_element container 'BTCHWIZALL' btchwizall.

ENDFORM.                               " START_MINI_WIZARD
*--------
* FORM MINI_START_COND_DEF_MINI
*--------
FORM mini_start_cond_def_mini TABLES container USING command.
  DATA: l_wizard LIKE swf_wizard.

  l_wizard-title      = text-686.
  l_wizard-headline   = text-687.
  l_wizard-subscreen1 = '4401'.
  l_wizard-subscpool1 = 'SAPLBTCH'.
  l_wizard-descobject = 'BP_SM36WIZ_START_DEF_MINI'.
  l_wizard-exit_titel = text-680.
  l_wizard-exit_line1 = text-681.
  l_wizard-graphic    = 'SM36WIZ_MID_IMAGE'.

  CALL FUNCTION 'SWF_WIZARD_CALL'
    EXPORTING
      wizard_data                 = l_wizard
      specific_data_import        = btch4400
    IMPORTING
      specific_data_export        = btch4400
    EXCEPTIONS
      operation_cancelled_by_user = 1
      back                        = 2
      OTHERS                      = 3.

  CASE sy-subrc.
    WHEN 1.
      command = wizard_command_cancel.
      EXIT.
    WHEN 2.
      command = wizard_command_back.
      EXIT.
    WHEN 0.
      command = wizard_command_continue.
  ENDCASE.

ENDFORM.                               " MINI_START_COND_DEF_MINI
*&---------------------------------------------------------------------*
*&      Form  INIT_XPG_CONTROL_FLAGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_xpg_control_flags.
* initialize the structure btch1160
  btch1160-stdoutinm  = 'X'.
  btch1160-stderrinm  = 'X'.
  btch1160-termbyctlp = 'X'.
  btch1160-trclvl3    = space.
ENDFORM.                               " INIT_XPG_CONTROL_FLAGS
*&---------------------------------------------------------------------*
*&      Form  REACT_ON_RADIOBUTTON_3076
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM react_on_radiobutton_3076.

  IF BTCH3076-DONTCARE IS NOT INITIAL.
    SET CURSOR FIELD 'BTCH3076-DONTCARE'.
  ELSEIF BTCH3076-NON_PERD IS NOT INITIAL.
    SET CURSOR FIELD 'BTCH3076-NON_PERD'.
  ELSE.
    SET CURSOR FIELD 'BTCH3076-PERIOD'.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-name = 'BTCH3076-NRMONTHS' OR
       screen-name = 'BTCH3076-NRWEEKS'  OR
       screen-name = 'BTCH3076-NRDAYS'   OR
       screen-name = 'BTCH3076-NRHOURS'  OR
       screen-name = 'BTCH3076-NRMINUTES'.
      IF btch3076-period IS INITIAL.
        " warning for existing input
        IF btch3076-nrmonths NE 0 OR
           btch3076-nrweeks NE 0 OR
           btch3076-nrdays NE 0 OR
           btch3076-nrhours NE 0 OR
           btch3076-nrminutes NE 0.
          MESSAGE s649.
          " reset values
          btch3076-nrmonths = 0.
          btch3076-nrweeks = 0.
          btch3076-nrdays = 0.
          btch3076-nrminutes = 0.
          btch3076-nrhours = 0.
        ENDIF.
        CLEAR screen-input.
      ELSE.
        screen-input = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " REACT_ON_RADIOBUTTON_3076
*&---------------------------------------------------------------------*
*&      Form  REACT_ON_RADIOBUTTON_4500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM react_on_radiobutton_4500.
  LOOP AT SCREEN.
    IF screen-name = 'OTHERPERD_BUTTON'.
      IF btch4500-none IS INITIAL.
        screen-invisible = '1'.
      ELSE.
        CLEAR screen-invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " REACT_ON_RADIOBUTTON_4500
*&---------------------------------------------------------------------*
*&      Form  REACT_ON_RADIOBUTTON_3072
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM react_on_radiobutton_3072.
  LOOP AT SCREEN.
    IF screen-name = 'BTCH3072-F_DATE_E' OR
       screen-name = 'BTCH3072-F_TIME_E' OR
       screen-name = 'BTCH3072-T_DATE_E' OR
       screen-name = 'BTCH3072-T_TIME_E'.
      IF btch3072-st_active IS INITIAL.
        " warning for existing input
        IF btch3072-f_date_e NE '          ' OR
           btch3072-f_time_e NE '        ' OR
           btch3072-t_date_e NE '          ' OR
           btch3072-t_time_e NE '        '.
          MESSAGE s649.
          " reset values
          btch3072-f_date_e = '          '.
          btch3072-f_time_e = '        '.
          btch3072-t_date_e = '          '.
          btch3072-t_time_e = '        '.
        ENDIF.
        CLEAR screen-input.
      ELSE.
        screen-input = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'BTCH3073-F_DATE_L' OR
       screen-name = 'BTCH3073-F_TIME_L' OR
       screen-name = 'BTCH3073-T_DATE_L' OR
       screen-name = 'BTCH3073-T_TIME_L'.
      IF btch3072-en_active IS INITIAL.
        " warning for existing input
        IF btch3073-f_date_l NE '          ' OR
           btch3073-f_time_l NE '        ' OR
           btch3073-t_date_l NE '          ' OR
           btch3073-t_time_l NE '        '.
          MESSAGE s649.
          " reset values
          btch3073-f_date_l = '          '.
          btch3073-f_time_l = '        '.
          btch3073-t_date_l = '          '.
          btch3073-t_time_l = '        '.
        ENDIF.
        CLEAR screen-input.
      ELSE.
        screen-input = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'BTCH3074-F_DATE_B' OR
       screen-name = 'BTCH3074-F_TIME_B' OR
       screen-name = 'BTCH3074-T_DATE_B' OR
       screen-name = 'BTCH3074-T_TIME_B'.
      IF btch3072-be_active IS INITIAL.
        " warning for existing input
        IF btch3074-f_date_b NE '          ' OR
           btch3074-f_time_b NE '        ' OR
           btch3074-t_date_b NE '          ' OR
           btch3074-t_time_b NE '        '.
          MESSAGE s649.
          " reset values
          btch3074-f_date_b = '          '.
          btch3074-f_time_b = '        '.
          btch3074-t_date_b = '          '.
          btch3074-t_time_b = '        '.
        ENDIF.
        CLEAR screen-input.
      ELSE.
        screen-input = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " REACT_ON_RADIOBUTTON_3072
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_SM37C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input_sm37c.
  IF btch3070-jobname EQ space.
    MESSAGE e093.
  ENDIF.

  IF btch3070-username EQ space.
    MESSAGE e069.
  ENDIF.

  IF btch3075-prelim EQ space AND
     btch3075-schedul EQ space AND
     btch3075-ready EQ space AND
     btch3075-running EQ space AND
     btch3075-finished EQ space AND
     btch3075-aborted EQ space.
    MESSAGE w651.
  ENDIF.


  PERFORM check_valid_date_time USING btch3071-from_date
                                      btch3071-to_date
                                      btch3071-from_time
                                      btch3071-to_time.
  PERFORM check_valid_date_time USING btch3072-f_date_e
                                      btch3072-t_date_e
                                      btch3072-f_time_e
                                      btch3072-t_time_e.
  PERFORM check_valid_date_time USING btch3073-f_date_l
                                      btch3073-t_date_l
                                      btch3073-f_time_l
                                      btch3073-t_time_l.
  PERFORM check_valid_date_time USING btch3074-f_date_b
                                      btch3074-t_date_b
                                      btch3074-f_time_b
                                      btch3074-t_time_b.

ENDFORM.                               " CHECK_INPUT_SM37C
*&---------------------------------------------------------------------*
*&      Form  REACT_ON_LISTBOX_3070
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM react_on_listbox_3070.
  DATA: sel_criteria LIKE favsels.
  LOOP AT SCREEN.
    IF btch3070-selfav NE space.
      SELECT * FROM favsels INTO sel_criteria
        WHERE favname = btch3070-selfav.
      ENDSELECT.
      MOVE-CORRESPONDING sel_criteria TO btch3070.
      MOVE-CORRESPONDING sel_criteria TO btch3071.
      MOVE-CORRESPONDING sel_criteria TO btch3072.
      MOVE-CORRESPONDING sel_criteria TO btch3073.
      MOVE-CORRESPONDING sel_criteria TO btch3074.
      MOVE-CORRESPONDING sel_criteria TO btch3075.
      MOVE-CORRESPONDING sel_criteria TO btch3076.
      MOVE-CORRESPONDING sel_criteria TO btch3077.
      btch3070-selfav = sel_criteria-favname.  " resume the listbox item
    ENDIF.
  ENDLOOP.
  MODIFY SCREEN.
ENDFORM.                               " REACT_ON_LISTBOX_3070
