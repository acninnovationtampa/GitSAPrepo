FUNCTION-POOL bea_crp_u.               "MESSAGE-ID ..
************************************************************************
* General Includes
************************************************************************
INCLUDE %3CICON%3E.
INCLUDE BEA_BASICS.
************************************************************************
* Define global constants
************************************************************************
CONSTANTS:
  gc_struc_name_crp          TYPE  tabname         VALUE 'BEAS_CRP_ALV',
  gc_lay_sel_mode_single     TYPE  c               VALUE 'A',
  gc_crp_container           TYPE  scrfname        VALUE 'CRP',
  gc_ucomm_back              TYPE  syucomm         VALUE '&F03',
  gc_ucomm_exit              TYPE  syucomm         VALUE '&F15',
  gc_ucomm_canc              TYPE  syucomm         VALUE '&F12',
  gc_status_crp_full(14)     TYPE  c
                             VALUE 'CRP_FULLSCREEN',
  gc_status_crp_contr(11)    TYPE  c               VALUE 'CRP_TOOLBAR',
  gc_title_crp(3)            TYPE  c               VALUE 'CRP',
  gc_ucomm_detail            TYPE  syucomm         VALUE 'DETAIL',
  gc_ucomm_appllog           TYPE  syucomm         VALUE 'APPLLOG',
  gc_splitter_pos            TYPE  i               VALUE 69,
  gc_errtype_s               TYPE  symsgty         VALUE 'S',
  gc_field_icon(4)           TYPE  c               VALUE 'ICON'.
************************************************************************
* Define global data
************************************************************************
DATA:
  gv_okcode        TYPE syucomm,
* Show head flag
  gv_show_head     TYPE char1,
  gv_toolbar       TYPE char1,
  gt_toolbar       TYPE ttb_button,
  gs_outtab        TYPE beas_crp_alv,
  gt_outtab        TYPE beat_crp_alv,
  go_alv_grid      TYPE REF TO cl_gui_alv_grid,
  gt_fieldcat      TYPE lvc_t_fcat,
  gs_fieldcat      TYPE lvc_s_fcat,
  gs_layout        TYPE lvc_s_layo,
  gs_variant       TYPE disvariant,
  gv_mode          TYPE char1,
* Controls
  go_splitter      TYPE REF TO cl_gui_splitter_container,
  go_container     TYPE REF TO cl_gui_custom_container,
  go_alv_container TYPE REF TO cl_gui_container,
  go_container_1   TYPE REF TO cl_gui_container,
  go_container_2   TYPE REF TO cl_gui_container,
  go_dd            TYPE REF TO cl_dd_document,
* Parameters
  gt_crp           TYPE beat_crp.
***********************************************************************
* Define global classes
***********************************************************************
*---------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION                            *
*---------------------------------------------------------------------*
*       Collective Run: Event Handler                                 *
*---------------------------------------------------------------------*
CLASS go_event_handler DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:  handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
                    IMPORTING e_object e_interactive,

                    handle_context_menu
                    FOR EVENT context_menu_request OF cl_gui_alv_grid
                    IMPORTING e_object,

                    handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
                    IMPORTING e_ucomm,

                    handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
                    IMPORTING e_row e_column es_row_no.

ENDCLASS.                    "lo_event_handler DEFINITION

CLASS cl_exithandler DEFINITION LOAD.
