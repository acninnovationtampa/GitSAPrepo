*&---------------------------------------------------------------------*
*&  Include           LBTCHACC
*&---------------------------------------------------------------------*

******* Accessibility: function  bp_jobvariant_schedule **************

DATA: container_100  TYPE REF TO  cl_gui_custom_container.
DATA: grid_100       TYPE REF TO  cl_gui_alv_grid.
DATA: field_cat_100  TYPE lvc_t_fcat.

DATA: title_100          LIKE taplt-atext.
DATA: jobname_100        LIKE tbtcjob-jobname.
DATA: program_name_100   LIKE rsvar-report.
DATA: variant_name_100   LIKE varit-variant.
DATA: variant_text_100   LIKE varit-vtext.

DATA: variant_table_100  TYPE TABLE OF varit.

TABLES: btc_job_1.

DATA: container_105  TYPE REF TO  cl_gui_custom_container.
DATA: grid_105       TYPE REF TO  cl_gui_alv_grid.
DATA: field_cat_105  TYPE lvc_t_fcat.

DATA: variant_name_105   LIKE varit-variant.
DATA: job_table_105      TYPE TABLE OF btc_job_1.

DATA: act_dynpro     LIKE sy-dynnr.
DATA: prev_dynpro    LIKE sy-dynnr.

DATA: rows_acc  TYPE  lvc_t_row.

******* Accessibility: SM62  (function  bp_eventid_editor) *********

DATA: container_1070  TYPE REF TO  cl_gui_custom_container.
DATA: grid_1070       TYPE REF TO  cl_gui_alv_grid.
DATA: field_cat_1070  TYPE lvc_t_fcat.

DATA: evt_table_1070  TYPE TABLE OF btcevtinfo.
DATA: evt_1070        LIKE btcsed-eventid.
DATA: evtdescr_1070   LIKE btcsed-descript.

DATA: del_evt_tab     TYPE TABLE OF btcevtinfo.
DATA: trans_evt_tab   TYPE TABLE OF btcevtinfo.

DATA: rb_1090_sap.  " radio buttons for dynpro 1090
DATA: rb_1090_cust.

DATA: mode_1070(4).
DATA: dont_erase.

CONSTANTS:
      progid         LIKE e071-pgmid VALUE 'R3TR',
      obj_id         LIKE e071-object VALUE 'TABU'.


***********************************************************************

* Event handling

***********************************************************************
CLASS cl_event_receiver_100 DEFINITION.

  PUBLIC SECTION.

    METHODS:
    handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.


  PRIVATE SECTION.

ENDCLASS.                    "event_receiver_100 DEFINITION

*---------------------------------------------------------------------*
*       CLASS ext_lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS cl_event_receiver_100 IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

*    DELETE e_object->mt_toolbar WHERE function = '&MB_SUM'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_SUBTOT'.
*    DELETE e_object->mt_toolbar WHERE function = '&PRINT_BACK'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_VIEW'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_EXPORT'.
*    DELETE e_object->mt_toolbar WHERE function = '&GRAPH'.

    REFRESH e_object->mt_toolbar.

    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Sofortstart
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'IMMSTART'.
    ls_toolbar-icon      = icon_execute_object.
    ls_toolbar-text       = 'immediate start'(670).
    ls_toolbar-quickinfo  = 'immediate start'(670).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Freigabe
    CLEAR ls_toolbar.
    ls_toolbar-function   = 'RELEASE'.
    ls_toolbar-icon       = icon_release.
    ls_toolbar-text       = 'release'(797).
    ls_toolbar-quickinfo  = 'release'(797).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Ändern
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'CHANGE'.
    ls_toolbar-icon      = icon_change.
    ls_toolbar-text       = 'change variant'(086) .
    ls_toolbar-quickinfo  = 'change variant'(830).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Anlegen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'CREATE'.
    ls_toolbar-icon      = icon_create.
    ls_toolbar-text       = 'create variant'(086).
    ls_toolbar-quickinfo  = 'create variant'(831).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Übersicht
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'OVERVIEW'.
    ls_toolbar-icon      = icon_overview.
    ls_toolbar-text       = 'job overview'(798).
    ls_toolbar-quickinfo  = 'job overview'(798).

    APPEND ls_toolbar TO e_object->mt_toolbar.


  ENDMETHOD.                    "handle_toolbar

*-------------------------------------------------------------------

  METHOD handle_user_command.

    DATA: lt_rows  TYPE  lvc_t_row.
    DATA: wa_rows  TYPE  lvc_s_row.

    DATA: wa_var   TYPE  varit.

    DATA: lines    TYPE  i.
    DATA: rc       TYPE  i.

    IF variant_possible = btc_no.
      READ TABLE variant_table_100 INDEX 1 INTO wa_var.
      CLEAR wa_var-variant.
      CLEAR wa_var-vtext.
      MODIFY variant_table_100 INDEX 1 FROM wa_var.
    ENDIF.

* PICK = CHANGE
    IF e_ucomm = 'PICK'.
      e_ucomm = 'CHANGE'.
    ENDIF.

    CASE e_ucomm.

      WHEN 'IMMSTART'.

        PERFORM check_one_row USING grid_100 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE variant_table_100 INDEX wa_rows-index INTO wa_var.

        variant_name_100 = wa_var-variant.
        PERFORM schedule_immediately
                 USING jobname_100 program_name_100 wa_var-variant.
        CLEAR variant_name_100 .

      WHEN 'RELEASE'.

        PERFORM check_one_row USING grid_100 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE variant_table_100 INDEX wa_rows-index INTO wa_var.
        variant_name_100 = wa_var-variant.
        variant_text_100 = wa_var-vtext.

        PERFORM enter_startdate.
        CLEAR variant_name_100 .
        CLEAR variant_text_100.


      WHEN 'CHANGE'.

        IF variant_possible = btc_no.
          MESSAGE s078 WITH program_name_100.
          EXIT.
        ENDIF.

        PERFORM check_one_row USING grid_100 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE variant_table_100 INDEX wa_rows-index INTO wa_var.

        variant_name_100 = wa_var-variant.
        PERFORM show_variant.
        CLEAR variant_name_100 .

      WHEN 'CREATE'.

        IF variant_possible = btc_no.
          MESSAGE s657 WITH program_name_100.
          EXIT.
        ENDIF.

        PERFORM create_variant.

      WHEN 'OVERVIEW'.
        PERFORM fill_joblist_table_105 USING rc.
        IF rc = 0.
          CALL SCREEN 105.
        ENDIF.

    ENDCASE.


  ENDMETHOD.                           "handle_user_command
*-----------------------------------------------------------------

  METHOD handle_double_click.

    DATA: wa_var   TYPE  varit.

    READ TABLE variant_table_100 INDEX e_row INTO wa_var.

    variant_name_100 = wa_var-variant.
    PERFORM show_variant.
    CLEAR variant_name_100 .

  ENDMETHOD.                    "handle_double_click

ENDCLASS.                    "ext_lcl_event_receiver IMPLEMENTATION


DATA: event_receiver_100 TYPE REF TO cl_event_receiver_100.

***********************************************************************
***********************************************************************
CLASS cl_event_receiver_105 DEFINITION.

  PUBLIC SECTION.

    METHODS:
    handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.

  PRIVATE SECTION.

ENDCLASS.                    "event_receiver_105 DEFINITION

*---------------------------------------------------------------------*
*       CLASS ext_lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS cl_event_receiver_105 IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

*    DELETE e_object->mt_toolbar WHERE function = '&MB_SUM'.

    DELETE e_object->mt_toolbar WHERE function NE '&SORT_ASC'
                                  AND function NE '&SORT_DSC'.


*    refresh e_object->mt_toolbar.

    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Joblog
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'PROT'.
    ls_toolbar-icon      = icon_protocol.
    ls_toolbar-text       = 'protocol'(799).
    ls_toolbar-quickinfo  = 'protocol'(799)..

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Ergebnisse
    CLEAR ls_toolbar.
    ls_toolbar-function   = 'SPOOL'.
    ls_toolbar-icon       = icon_spool_request.
    ls_toolbar-text       = 'result'(800).
    ls_toolbar-quickinfo  = 'result'(800).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Ändern
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'CHANGE'.
    ls_toolbar-icon      = icon_change.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'change start condition'(331)..

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button löschen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'DELE'.
    ls_toolbar-icon      = icon_delete.
    ls_toolbar-text       = 'delete job'(801).
    ls_toolbar-quickinfo  = 'delete job'(801).

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button aktualisieren
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'REFRESH'.
    ls_toolbar-icon      = icon_refresh.
    ls_toolbar-text       = 'refresh'(782).
    ls_toolbar-quickinfo  = 'refresh'(782).

    APPEND ls_toolbar TO e_object->mt_toolbar.


  ENDMETHOD.                    "handle_toolbar

*-------------------------------------------------------------------

  METHOD handle_user_command.

    DATA: lt_rows  TYPE  lvc_t_row.
    DATA: wa_rows  TYPE  lvc_s_row.
    DATA: wa_job   TYPE  btc_job_1.
    DATA: job      TYPE  tbtcjob.

    DATA: lines    TYPE  i.
    DATA: rc       TYPE  i.
    DATA: antwort.

* PICK = CHANGE
    IF e_ucomm = 'PICK'.
      e_ucomm = 'CHANGE'.
    ENDIF.

    CASE e_ucomm.

      WHEN 'PROT'.

        PERFORM check_one_row USING grid_105 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE job_table_105 INDEX wa_rows-index INTO wa_job.

        CALL FUNCTION 'BP_JOBLOG_SHOW_SM37B'
          EXPORTING
            jobcount = wa_job-jobcount
            jobname  = wa_job-jobname
          EXCEPTIONS
            OTHERS   = 1.

        IF sy-subrc <> 0.
          MESSAGE s001(38) WITH text-306 DISPLAY LIKE 'E'.
        ENDIF.


      WHEN 'SPOOL'.

        PERFORM check_one_row USING grid_105 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE job_table_105 INDEX wa_rows-index INTO wa_job.

        PERFORM show_spoollist_acc USING wa_job-jobname
                                         wa_job-jobcount.


      WHEN 'CHANGE'.

        PERFORM check_one_row USING grid_105 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE job_table_105 INDEX wa_rows-index INTO wa_job.

        PERFORM change_job_105 USING wa_job.

        PERFORM fill_joblist_table_105 USING rc.
        IF rc = 0.
          CALL METHOD grid_105->refresh_table_display.
        ENDIF.


      WHEN 'DELE'.

        PERFORM get_selected_rows USING grid_105 rc.

* Sicherheitsabfrage vor dem Löschen
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar       = text-329
            text_question  = text-328
          IMPORTING
            answer         = antwort
          EXCEPTIONS
            OTHERS         = 99.

        IF antwort NE '1'.
          EXIT.
        ENDIF.

        LOOP AT rows_acc INTO wa_rows.
          READ TABLE job_table_105 INDEX wa_rows-index INTO wa_job.
          PERFORM delete_job_105 USING wa_job rc.
        ENDLOOP.

        IF rc = 0.
          PERFORM fill_joblist_table_105 USING rc.
          IF rc = 0 OR rc = 2.
            CALL METHOD grid_105->refresh_table_display.
          ENDIF.
        ENDIF.

      WHEN 'REFRESH'.

        PERFORM fill_joblist_table_105 USING rc.
        IF rc = 0.
          CALL METHOD grid_105->refresh_table_display.
        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "handle_user_command

*-------------------------------------------------------------------

  METHOD handle_double_click.

    DATA: rc       TYPE  i.
    DATA: wa_job   TYPE  btc_job_1.

    READ TABLE job_table_105 INDEX e_row INTO wa_job.

    PERFORM change_job_105 USING wa_job.

    PERFORM fill_joblist_table_105 USING rc.
    IF rc = 0.
      CALL METHOD grid_105->refresh_table_display.
    ENDIF.

  ENDMETHOD.                    "handle_double_click

ENDCLASS.                    "cl_event_receiver_105 IMPLEMENTATION

DATA: event_receiver_105 TYPE REF TO cl_event_receiver_105.

********************************************************************
********************************************************************

CLASS cl_event_receiver_1070 DEFINITION.

  PUBLIC SECTION.

    METHODS:
    handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.

  PRIVATE SECTION.

ENDCLASS.                    "event_receiver_100 DEFINITION

*---------------------------------------------------------------------*
*       CLASS ext_lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS cl_event_receiver_1070 IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

*    DELETE e_object->mt_toolbar WHERE function = '&MB_SUM'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_SUBTOT'.
*    DELETE e_object->mt_toolbar WHERE function = '&PRINT_BACK'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_VIEW'.
*    DELETE e_object->mt_toolbar WHERE function = '&MB_EXPORT'.
*    DELETE e_object->mt_toolbar WHERE function = '&GRAPH'.

    REFRESH e_object->mt_toolbar.

    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar.


* Button Event auslösen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'EXECUTE'.
    ls_toolbar-icon      = icon_execute_object.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'trigger event'(789)..

    APPEND ls_toolbar TO e_object->mt_toolbar.


* Button Anlegen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'CREATE'.
    ls_toolbar-icon      = icon_create.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'create event'(787)..

    APPEND ls_toolbar TO e_object->mt_toolbar.


* Button Ändern
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'CHANGE'.
    ls_toolbar-icon      = icon_change.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'change event'(788)..

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Löschen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'DELETE'.
    ls_toolbar-icon      = icon_delete.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'delete event'(790)..

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Auffrischen
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'REFRESH'.
    ls_toolbar-icon      = icon_refresh.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'refresh'(765)..

    APPEND ls_toolbar TO e_object->mt_toolbar.

* Button Transportieren
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'TRANSPORT'.
    ls_toolbar-icon      = icon_transport.
*    ls_toolbar-text       = ' .
    ls_toolbar-quickinfo  = 'transport'(807)..

    APPEND ls_toolbar TO e_object->mt_toolbar.



  ENDMETHOD.                    "handle_toolbar

*-------------------------------------------------------------------

  METHOD handle_user_command.

    DATA: lt_rows  TYPE  lvc_t_row.
    DATA: wa_rows  TYPE  lvc_s_row.

    DATA: wa_evt   TYPE  btcevtinfo.

    DATA: lines    TYPE  i.
    DATA: rc       TYPE  i.
    DATA: rc2      TYPE  i.
    DATA: cnt      TYPE  i.
    DATA: nr       TYPE  i.

    DATA: current_row    TYPE lvc_s_row.
    DATA: current_column TYPE lvc_s_col.


    CLEAR evt_1070.

    CASE e_ucomm.

      WHEN 'EXECUTE'.

        AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

        IF sy-subrc NE 0.
          MESSAGE s791 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        PERFORM check_one_row USING grid_1070 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE evt_table_1070 INDEX wa_rows-index INTO wa_evt.
        evt_1070 = wa_evt-eventid.

        prev_dynpro = sy-dynnr.
        CALL SCREEN 1250.


      WHEN 'CREATE'.

        AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

        IF sy-subrc NE 0.
          MESSAGE s791 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        mode_1070 = 'CREA'.

        CALL SCREEN 1090.

*       refresh table display
        PERFORM fill_table_1070.
        CALL METHOD grid_1070->refresh_table_display.



      WHEN 'CHANGE'.

        PERFORM check_one_row USING grid_1070 wa_rows rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        READ TABLE evt_table_1070 INDEX wa_rows-index INTO wa_evt.
        evt_1070 = wa_evt-eventid.
        evtdescr_1070 = wa_evt-descript.

        PERFORM enqueue_event USING wa_evt-eventid rc.
        IF rc NE 0.
          MESSAGE s792 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        mode_1070 = 'EDIT'.

        prev_dynpro = sy-dynnr.
        CALL SCREEN 1090.

        PERFORM dequeue_event USING wa_evt-eventid rc.

*       refresh table display
        PERFORM fill_table_1070.

        CALL METHOD grid_1070->get_current_cell
          IMPORTING
            es_row_id = current_row
            es_col_id = current_column.

        CALL METHOD grid_1070->refresh_table_display.

        CALL METHOD grid_1070->set_current_cell_via_id
          EXPORTING
            is_row_id    = current_row
            is_column_id = current_column.

*       dequeue is done in pai1090

      WHEN 'DELETE'.

        AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

        IF sy-subrc NE 0.
          MESSAGE s791 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        PERFORM check_at_least_one_row  USING  grid_1070 rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        REFRESH del_evt_tab.

* write the events to be deleted into table del_evt_tab
        LOOP AT rows_acc INTO wa_rows..
          READ TABLE evt_table_1070 INDEX wa_rows-index
                                                  INTO wa_evt.
          APPEND wa_evt TO del_evt_tab.
        ENDLOOP.

        PERFORM delete_events USING rc.

        CALL METHOD grid_1070->refresh_table_display.

      WHEN 'TRANSPORT'.

        AUTHORITY-CHECK
            OBJECT 'S_BTCH_ADM'
            ID 'BTCADMIN' FIELD 'Y'.

        IF sy-subrc NE 0.
          MESSAGE s791 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        PERFORM check_at_least_one_row  USING  grid_1070 rc.
        IF rc NE 0.
          EXIT.
        ENDIF.

        REFRESH trans_evt_tab.

* write the events to be transported into table trans_evt_tab
        LOOP AT rows_acc INTO wa_rows..
          READ TABLE evt_table_1070 INDEX wa_rows-index
                                                  INTO wa_evt.
          APPEND wa_evt TO trans_evt_tab.
        ENDLOOP.

* check if only user events are in table trans_evt_tab
        PERFORM check_only_user_events TABLES trans_evt_tab USING rc.
        IF rc = 1.
          MESSAGE s879 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        PERFORM transport_events TABLES trans_evt_tab USING rc.
        IF rc = 0.
          MESSAGE s881 DISPLAY LIKE 'E'.
        ELSE.
          MESSAGE s880 DISPLAY LIKE 'E'.
        ENDIF.

      WHEN 'REFRESH'.

        PERFORM fill_table_1070.

        CALL METHOD grid_1070->get_current_cell
          IMPORTING
            es_row_id = current_row
            es_col_id = current_column.

        CALL METHOD grid_1070->refresh_table_display.

        CALL METHOD grid_1070->set_current_cell_via_id
          EXPORTING
            is_row_id    = current_row
            is_column_id = current_column.


    ENDCASE.


  ENDMETHOD.                           "handle_user_command

*--------------------------------------------------------------------

  METHOD handle_double_click.

    DATA: wa_evt   TYPE  btcevtinfo.

    AUTHORITY-CHECK
       OBJECT 'S_BTCH_ADM'
       ID 'BTCADMIN' FIELD 'Y'.

    IF sy-subrc NE 0.
      MESSAGE s791 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    READ TABLE evt_table_1070 INDEX e_row INTO wa_evt.
    evt_1070 = wa_evt-eventid.

    prev_dynpro = sy-dynnr.
    CALL SCREEN 1250.

  ENDMETHOD.                    "handle_double_click

*-----------------------------------------------------------------
ENDCLASS.                    "ext_lcl_event_receiver IMPLEMENTATION


DATA: event_receiver_1070 TYPE REF TO cl_event_receiver_1070.
