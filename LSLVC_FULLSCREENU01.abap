function reuse_alv_grid_display.                            "#EC *
*"----------------------------------------------------------------------
*"*"Globale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_INTERFACE_CHECK) DEFAULT SPACE
*"     VALUE(I_BYPASSING_BUFFER) TYPE  CHAR01 DEFAULT SPACE
*"     VALUE(I_BUFFER_ACTIVE) DEFAULT SPACE
*"     REFERENCE(I_CALLBACK_PROGRAM) LIKE  SY-REPID DEFAULT SPACE
*"     REFERENCE(I_CALLBACK_PF_STATUS_SET) TYPE  SLIS_FORMNAME DEFAULT
*"       SPACE
*"     REFERENCE(I_CALLBACK_USER_COMMAND) TYPE  SLIS_FORMNAME DEFAULT
*"       SPACE
*"     REFERENCE(I_CALLBACK_TOP_OF_PAGE) TYPE  SLIS_FORMNAME DEFAULT
*"       SPACE
*"     REFERENCE(I_CALLBACK_HTML_TOP_OF_PAGE) TYPE  SLIS_FORMNAME
*"       DEFAULT SPACE
*"     REFERENCE(I_CALLBACK_HTML_END_OF_LIST) TYPE  SLIS_FORMNAME
*"       DEFAULT SPACE
*"     REFERENCE(I_STRUCTURE_NAME) LIKE  DD02L-TABNAME OPTIONAL
*"     REFERENCE(I_BACKGROUND_ID) TYPE  SDYDO_KEY DEFAULT SPACE
*"     REFERENCE(I_GRID_TITLE) TYPE  LVC_TITLE OPTIONAL
*"     REFERENCE(I_GRID_SETTINGS) TYPE  LVC_S_GLAY OPTIONAL
*"     REFERENCE(IS_LAYOUT) TYPE  SLIS_LAYOUT_ALV OPTIONAL
*"     REFERENCE(IT_FIELDCAT) TYPE  SLIS_T_FIELDCAT_ALV OPTIONAL
*"     REFERENCE(IT_EXCLUDING) TYPE  SLIS_T_EXTAB OPTIONAL
*"     REFERENCE(IT_SPECIAL_GROUPS) TYPE  SLIS_T_SP_GROUP_ALV OPTIONAL
*"     REFERENCE(IT_SORT) TYPE  SLIS_T_SORTINFO_ALV OPTIONAL
*"     REFERENCE(IT_FILTER) TYPE  SLIS_T_FILTER_ALV OPTIONAL
*"     REFERENCE(IS_SEL_HIDE) TYPE  SLIS_SEL_HIDE_ALV OPTIONAL
*"     REFERENCE(I_DEFAULT) DEFAULT 'X'
*"     REFERENCE(I_SAVE) DEFAULT SPACE
*"     REFERENCE(IS_VARIANT) LIKE  DISVARIANT STRUCTURE  DISVARIANT
*"       OPTIONAL
*"     REFERENCE(IT_EVENTS) TYPE  SLIS_T_EVENT OPTIONAL
*"     REFERENCE(IT_EVENT_EXIT) TYPE  SLIS_T_EVENT_EXIT OPTIONAL
*"     REFERENCE(IS_PRINT) TYPE  SLIS_PRINT_ALV OPTIONAL
*"     REFERENCE(IS_REPREP_ID) TYPE  SLIS_REPREP_ID OPTIONAL
*"     REFERENCE(I_SCREEN_START_COLUMN) DEFAULT 0
*"     REFERENCE(I_SCREEN_START_LINE) DEFAULT 0
*"     REFERENCE(I_SCREEN_END_COLUMN) DEFAULT 0
*"     REFERENCE(I_SCREEN_END_LINE) DEFAULT 0
*"     REFERENCE(I_HTML_HEIGHT_TOP) TYPE  I DEFAULT 0
*"     REFERENCE(I_HTML_HEIGHT_END) TYPE  I DEFAULT 0
*"     REFERENCE(IT_ALV_GRAPHICS) TYPE  DTC_T_TC OPTIONAL
*"     REFERENCE(IT_HYPERLINK) TYPE  LVC_T_HYPE OPTIONAL
*"     REFERENCE(IT_ADD_FIELDCAT) TYPE  SLIS_T_ADD_FIELDCAT OPTIONAL
*"     REFERENCE(IT_EXCEPT_QINFO) TYPE  SLIS_T_QINFO_ALV OPTIONAL
*"     REFERENCE(IR_SALV_FULLSCREEN_ADAPTER) TYPE REF TO
*"        CL_SALV_FULLSCREEN_ADAPTER OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_EXIT_CAUSED_BY_CALLER)
*"     REFERENCE(ES_EXIT_CAUSED_BY_USER) TYPE  SLIS_EXIT_BY_USER
*"  TABLES
*"      T_OUTTAB
*"  EXCEPTIONS
*"      PROGRAM_ERROR
*"----------------------------------------------------------------------
  data: boolean type sap_bool.
  data: l_getid type char30.
*  data: exit    type ref to IF_EX_ALV_SWITCH_GRID_TO_LIST.

  constants: c_badi_not_checked        type  i value 0,
             c_badi_no_instance        type  i value 1,
             c_badi_has_implementation type  i value 2.

*>>AT
  perform salv_at_reuse_display.
*<<AT

*Call of the BADI Interface IF_EX_ALV_SWITCH_GRID_TO_LIST
  class cl_exithandler definition load.

  if g_badi_instance_exit eq c_badi_not_checked.
    call method cl_exithandler=>get_instance      "Aufruf der Factory-
            exporting                                "Methode
               exit_name                = 'ALV_SWITCH_GRID_LIST'
               null_instance_accepted   = 'X'
            changing
               instance = g_exit.
    if g_exit is initial.
      g_badi_instance_exit = c_badi_no_instance.
    else.
      g_badi_instance_exit = c_badi_has_implementation.
    endif.
  endif.

  if g_badi_instance_exit eq c_badi_has_implementation.
    if not g_exit is initial.
      call method g_exit->IS_SWITCH_TO_LIST_REQUESTED   "Aufruf des Add-Ins
            exporting
               alv_layout        = is_variant
               username          = sy-uname
            changing
               value             = boolean.
    endif.
  endif.

  get parameter id 'SALV_SWITCH_TO_LIST' field l_getid.
  if sy-subrc eq 0.
    translate l_getid to upper case.                     "#EC TRANSLANG
    If l_getid eq 'X'.
      boolean = if_salv_c_bool_sap=>true.
    endif.
  endif.

  if ( is_layout-allow_switch_to_list ne space
  and boolean eq if_salv_c_bool_sap=>true )
  or ( sy-binpt eq abap_true ).
    perform globals_push.
    call function 'REUSE_ALV_LIST_DISPLAY'
      exporting
        i_interface_check        = i_interface_check
        i_bypassing_buffer       = i_bypassing_buffer
        i_buffer_active          = i_buffer_active
        i_callback_program       = i_callback_program
        i_callback_pf_status_set = i_callback_pf_status_set
        i_callback_user_command  = i_callback_user_command
        i_structure_name         = i_structure_name
        is_layout                = is_layout
        it_fieldcat              = it_fieldcat
        it_excluding             = it_excluding
        it_special_groups        = it_special_groups
        it_sort                  = it_sort
        it_filter                = it_filter
        is_sel_hide              = is_sel_hide
        i_default                = i_default
        i_save                   = i_save
        is_variant               = is_variant
        it_events                = it_events
        it_event_exit            = it_event_exit
        is_print                 = is_print
        is_reprep_id             = is_reprep_id
        i_screen_start_column    = i_screen_start_column
        i_screen_start_line      = i_screen_start_line
        i_screen_end_column      = i_screen_end_column
        i_screen_end_line        = i_screen_end_line
        it_except_qinfo          = it_except_qinfo
      importing
        e_exit_caused_by_caller  = e_exit_caused_by_caller
        es_exit_caused_by_user   = es_exit_caused_by_user
      tables
        t_outtab                 = t_outtab
      exceptions
        program_error            = 1
        others                   = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    perform globals_pop.
    exit.
  endif.

  clear e_exit_caused_by_caller.
  clear es_exit_caused_by_user.

*... Trace?
  if ( cl_alv_trace=>is_trace_on( ) eq 1 ).
    create object mr_trace.

    call method mr_trace->add_trace_item
      exporting
        i_trace_item = 'REUSE_ALV_GRID_DISPLAY'
        is_vari_slis = is_variant
        is_layo_slis = is_layout
        is_prnt_slis = is_print
        it_fcat_slis = it_fieldcat
        it_sort_slis = it_sort
        it_filt_slis = it_filter.
  endif.

  free memory id 'DYNDOS_FOR_ALV'.

  perform globals_push.

  gt_grid-flg_first_time = 'X'.

  perform reprep_check.

  g_repid = sy-repid.

  if i_screen_start_column is initial and
     i_screen_start_line   is initial and
     i_screen_start_column   is initial and
     i_screen_end_line     is initial.
    gt_grid-flg_popup = space.
    call screen 500.
  else.
    gt_grid-flg_popup = 'X'.
    call screen 700
              starting at i_screen_start_column i_screen_start_line
              ending   at i_screen_end_column i_screen_end_line.
  endif.

  perform globals_pop.

  clear g_repid.

endfunction.
