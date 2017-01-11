*----------------------------------------------------------------------*
*   INCLUDE LBTCHREO                                                   *
*----------------------------------------------------------------------*

* data definitions for standard jobs shortcut

tables: btch1141, btch1142, reorgjobs.
data: jobtab   like reorgjobs occurs 20 with header line.
* data: job_has_variant like btch1142-jobvariant.


data: G_CONTAINER TYPE SCRFNAME VALUE 'BCALV_GRID',
      GRID1  TYPE REF TO CL_GUI_ALV_GRID,
      G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

data: G_CONTAINER2 TYPE SCRFNAME VALUE 'ALV_GRID2',
      GRID2  TYPE REF TO CL_GUI_ALV_GRID,
      G_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

DATA: INFO_TAB  type table of rjsta1.
DATA: INFO_TAB2 type table of rjsta2.
data: oj_tab    type table of rjoj.

data: begin of comptab occurs 20,
          component like btch1141-component,
          comptext  like btch1141-comptext,
      end of comptab.

data: rj_init type i.

data: b_imme, b_date,  b_date_h,
      b_period_none,   b_period_daily,
      b_period_weekly, b_period_monthly,
      b_period_hourly.


data: g_repid like sy-repid.
data: save_ok like sy-ucomm.

*data: begin of variant_hlp_tbl_reo occurs 20.
*          include structure btcvarhtbl.
*data: end of variant_hlp_tbl_reo.


CLASS lcl_event_receiver DEFINITION DEFERRED.

data: event_receiver TYPE REF TO lcl_event_receiver.

* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS:
    handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm.


  PRIVATE SECTION.

ENDCLASS.
*

* class lcl_event_receiver (Implementation)
*
*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_toolbar.
* § 2.In event handler method for event TOOLBAR: Append own functions
*   by using event parameter E_OBJECT.
    DATA: ls_toolbar  TYPE stb_button.
*....................................................................
* E_OBJECT of event TOOLBAR is of type REF TO CL_ALV_EVENT_TOOLBAR_SET.
* This class has got one attribute, namly MT_TOOLBAR, which
* is a table of type TTB_BUTTON. One line of this table is
* defined by the Structure STB_BUTTON (see data deklaration above).
*

* A remark to the flag E_INTERACTIVE:
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*         'e_interactive' is set, if this event is raised due to
*         the call of 'set_toolbar_interactive' by the user.
*         You can distinguish this way if the event was raised
*         by yourself or by ALV
*         (e.g. in method 'refresh_table_display').
*         An application of this feature is still unknown... :-)

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
* append refresh-icon
    CLEAR ls_toolbar.
    MOVE 'REFRESH' TO ls_toolbar-function.
    MOVE icon_refresh TO ls_toolbar-icon.
    write text-765 TO ls_toolbar-quickinfo.

    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append refresh-icon
    CLEAR ls_toolbar.
    MOVE 'DELETE' TO ls_toolbar-function.
    MOVE icon_delete TO ls_toolbar-icon.
    write text-766 TO ls_toolbar-quickinfo.

    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
*-------------------------------------------------------------------
  METHOD handle_user_command.

    DATA: lt_rows TYPE lvc_t_row.
    data: txt(25).
    data: changed type btcchar1.

    CASE e_ucomm.
      WHEN 'REFRESH'.

        CALL METHOD cl_gui_cfw=>flush.
        IF sy-subrc ne 0.
          write text-767 to txt.

          CALL FUNCTION 'POPUP_TO_INFORM'
               EXPORTING
                    titel = g_repid
                    txt2  = sy-subrc
                    txt1  = txt.
         else.
                  perform read_status changing changed.
                  CALL METHOD grid1->refresh_table_display.

        ENDIF.

      when 'DELETE'.
        CALL METHOD grid1->get_selected_rows
                  IMPORTING et_index_rows = lt_rows.

        CALL METHOD cl_gui_cfw=>flush.
        IF sy-subrc ne 0.
          write text-771 to txt.

          CALL FUNCTION 'POPUP_TO_INFORM'
               EXPORTING
                    titel = g_repid
                    txt2  = sy-subrc
                    txt1  = txt.
         else.
                  perform delete_reojob tables lt_rows.
                  perform read_status changing changed.
                  CALL METHOD grid1->refresh_table_display.

        endif.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
*-----------------------------------------------------------------
ENDCLASS.
*
* lcl_event_receiver (Implementation)
*===================================================================
