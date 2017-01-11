*&---------------------------------------------------------------------*
*&      Form  METHOD_HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_user_command using r_ucomm type sy-ucomm.
  data: lflg_refresh(1) type c.
  data: lflg_exit(1) type c.
  data: ls_stable type lvc_s_stbl.

  case r_ucomm.
    when others.
      perform user_command using r_ucomm lflg_refresh lflg_exit
                                         ls_stable             .
      if lflg_exit eq 'X'.
        e_exit_caused_by_caller = 'X'.
        perform exit.
      else.
*>>> new API
        if lflg_refresh is not initial.
          perform salv_get_selections.
        endif.
*<<< new API
        case lflg_refresh.
          when 'X'.
            call method gt_grid-grid->refresh_table_display
              exporting
                is_stable = ls_stable.
          when 'S'.
            call method gt_grid-grid->refresh_table_display
              exporting
                is_stable      = ls_stable
                i_soft_refresh = 'X'.
        endcase.
*>>> new API
        perform salv_set_selections.
*<<< new API
      endif.
  endcase.

endform.                               " METHOD_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  METHOD_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_DYNDOC_ID  text
*----------------------------------------------------------------------*
form method_top_of_page using r_dyndoc_id
                                     type ref to cl_dd_document
                              value(i_table_index) type syindex.
  data: lflg_grid type c value 'X'.

  export alv_form_html from abap_true
         to memory id 'ALV_FORM_HTML'.

  if not gt_grid-i_callback_html_top_of_page is initial and
     not i_callback_program is initial.
    "B5AK000316: call two ALV Grids with different header set
    "Y9D,Y9C,Y9B transport req.: Y9BK012434 in Reuse_alv_grid_commentary_set
    free memory id 'DYNDOS_FOR_ALV'.    "Call B1 from B2 correct header
    perform (gt_grid-i_callback_html_top_of_page)
       in program (i_callback_program) using r_dyndoc_id if found.
    gt_grid-top = r_dyndoc_id.                              "18.10.2002
  endif.
  if not gt_grid-i_callback_top_of_page is initial and
     not i_callback_program is initial.
    export lflg_grid to memory id 'ALV_GRID_TOP_OF_PAGE'.
    if gt_grid-r_salv_fullscreen_adapter is bound.
      perform (gt_grid-i_callback_top_of_page)
        in program (i_callback_program) using i_table_index.
    else.
      perform (gt_grid-i_callback_top_of_page)
        in program (i_callback_program) if found.
    endif.
    free memory id 'ALV_GRID_TOP_OF_PAGE'.
  endif.

  export alv_form_html from abap_false
         to memory id 'ALV_FORM_HTML'.

endform.                               " METHOD_TOP_OF_PAGE

*&--------------------------------------------------------------------*
*&      Form  method_top_of_list
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form method_top_of_list.

  if not gt_grid-i_callback_top_of_list is initial and
     not i_callback_program is initial.
    perform (gt_grid-i_callback_top_of_list)
      in program (i_callback_program) if found.
  endif.

endform.                    "method_top_of_list

*---------------------------------------------------------------------*
*       FORM METHOD_END_OF_LIST                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_DYNDOC_ID                                                   *
*  -->  to                                                            *
*  -->  cl_dd_document                                                *
*---------------------------------------------------------------------*
form method_end_of_list using r_dyndoc_id
                                     type ref to cl_dd_document.
  data: lflg_grid type c value 'X'.

  export alv_form_html from abap_true
         to memory id 'ALV_FORM_HTML'.

  if not gt_grid-i_callback_html_end_of_list is initial and
      not i_callback_program is initial.
    "B5AK000316: call two ALV Grids with different bottom set
    "Y9D,Y9C,Y9B transport req.: Y9BK012434 in Reuse_alv_grid_commentary_set
    free memory id 'DYNDOS_FOR_ALV_BOTTOM'.
    perform (gt_grid-i_callback_html_end_of_list)
      in program (i_callback_program) using r_dyndoc_id if found.
    gt_grid-bottom = r_dyndoc_id.                           "16.11.2003
  endif.
  if not gt_grid-i_callback_end_of_list is initial and
     not i_callback_program is initial.
    export lflg_grid to memory id 'ALV_GRID_TOP_OF_PAGE'.
    perform (gt_grid-i_callback_end_of_list)
      in program (i_callback_program) if found.
    free memory id 'ALV_GRID_TOP_OF_PAGE'.
  endif.

  export alv_form_html from abap_false
         to memory id 'ALV_FORM_HTML'.

endform.                               " METHOD_END_OF_LIST
*&---------------------------------------------------------------------*
*&      Form  METHOD_PRINT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_print_top_of_page using value(i_table_index) type syindex.

  if gt_grid-r_salv_fullscreen_adapter is bound.
    if not gt_grid-i_callback_top_of_page is initial and
       not i_callback_program is initial.
      perform (gt_grid-i_callback_top_of_page)
        in program (i_callback_program) using i_table_index.
    endif.
  else.
    if not gt_grid-i_callback_top_of_page is initial and
       not i_callback_program is initial.
      perform (gt_grid-i_callback_top_of_page)
        in program (i_callback_program).
    endif.
  endif.

endform.                               " METHOD_PRINT_TOP_OF_PAGE
*---------------------------------------------------------------------*
*       FORM METHOD_PRINT_END_OF_LIST                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form method_print_end_of_list.
  if not gt_grid-i_callback_end_of_list is initial and
     not i_callback_program is initial.
    perform (gt_grid-i_callback_end_of_list)
      in program (i_callback_program).
  endif.

endform.                               " METHOD_PRINT_END_OF_LIST
*&---------------------------------------------------------------------*
*&      Form  METHOD_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_double_click using r_ucomm type sy-ucomm.
  data: l_ucomm type sy-ucomm.
  data: l_save_ucomm   type sy-ucomm.
  data: lflg_refresh(1) type c.
  data: lflg_exit(1) type c.
  data: ls_stable type lvc_s_stbl.
*
  l_ucomm = gt_grid-s_layout-f2code.
  if l_ucomm(1) = '&'.
    call method gt_grid-grid->set_function_code
      changing
        c_ucomm = l_ucomm.
  else.
    if l_ucomm = space.
      if r_ucomm is initial.  "Customer Wrapper
*     if r_ucomm ne '&IC2'  " see method_hotspot_click
        l_ucomm = '&IC1'.
      else.
        l_ucomm = r_ucomm.
      endif.
    endif.
    l_save_ucomm = l_ucomm.
    perform user_command using l_ucomm
                               lflg_refresh lflg_exit ls_stable.
    if l_ucomm ne l_save_ucomm.
      r_ucomm = l_ucomm.
    else.
      r_ucomm = space.
    endif.
    if lflg_exit = 'X'.
      e_exit_caused_by_caller = 'X'.
      perform exit.
    else.
      if lflg_refresh = 'X'.
        call method gt_grid-grid->refresh_table_display
          exporting
            is_stable = ls_stable.
      elseif lflg_refresh = 'S'.
        call method gt_grid-grid->refresh_table_display
          exporting
            is_stable      = ls_stable
            i_soft_refresh = 'X'.
      endif.
    endif.
  endif.
endform.                               " METHOD_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  METHOD_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_hotspot_click.
*ALV Customer Wrapper
  data: l_ucomm type sy-ucomm value '&IC2'.
  if gt_grid-r_salv_fullscreen_adapter is bound.
    perform method_double_click using l_ucomm.
  else.
    perform method_double_click using g_temp_ok_code.
  endif.
endform.                               " METHOD_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  EVENT_RECEIVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form event_receiver.

  create object gc_event_receiver.
  set handler gc_event_receiver->handle_top_of_list for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_end_of_list for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_print_end_of_list for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_end_of_page for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_top_of_page for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_print_top_of_page for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_user_command for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_data_changed for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_after_user_command for
                                               gt_grid-grid.

  gc_event_receiver->register_event( r_grid      = gt_grid-grid
                                     event_name  = '_BEFORE_REFRESH'
                                     activation  = abap_true ).

  if not gt_grid-s_layout-box_fieldname is initial.
    set handler gc_event_receiver->handle_before_user_command for
                                             gt_grid-grid.
    set handler gc_event_receiver->handle_after_refresh for
                                             gt_grid-grid.
  endif.
  if not it_event_exit[] is initial.
    read table it_event_exit with key before = 'X'
      transporting no fields.
    if sy-subrc = 0.
      set handler gc_event_receiver->handle_before_user_command for
                                               gt_grid-grid.
    endif.

    read table it_event_exit with key after = 'X'
      transporting no fields.
    if sy-subrc = 0.
      set handler gc_event_receiver->handle_after_user_command for
                                               gt_grid-grid.
    endif.
  endif.
  set handler gc_event_receiver->handle_double_click for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_hotspot_click for
                                               gt_grid-grid.
  set handler gc_event_receiver->handle_subtotal_text for
                                               gt_grid-grid.

  set handler gc_event_receiver->context_menu_request for
                                              gt_grid-grid.

  if i_grid_settings-edt_cll_cb = 'X'.
    call method gt_grid-grid->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  endif.
endform.                               " EVENT_RECEIVER
*&---------------------------------------------------------------------*
*&      Form  METHOD_SUBTOTAL_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_SUBTOTTXT_INFO  text
*      -->P_E_SUBTOTTXT  text
*      -->P_EP_SUBTOT_LINE  text
*----------------------------------------------------------------------*
form method_subtotal_text using rs_subtottxt_info type lvc_s_stxt
                                e_event_data   type
                                               ref to cl_alv_event_data
                                rp_subtot_line type ref to data.
  data: ls_subtottxt_info_slis type slis_subtot_text.

  field-symbols: <l_total>.
  field-symbols: <l_text>.
  assign rp_subtot_line->* to <l_total>.
  assign e_event_data->m_data->* to <l_text>.

  ls_subtottxt_info_slis-criteria = rs_subtottxt_info-criteria.
  ls_subtottxt_info_slis-keyword  = rs_subtottxt_info-keyword .
  ls_subtottxt_info_slis-criteria_text  = rs_subtottxt_info-crit_text.
  ls_subtottxt_info_slis-max_len   = '128'.
  ls_subtottxt_info_slis-display_text_for_subtotal
                                       = <l_text>.

  if not gt_grid-i_callback_subtotal_text is initial and
     not i_callback_program is initial.
    perform (gt_grid-i_callback_subtotal_text)
      in program (i_callback_program) using <l_total>
                                            ls_subtottxt_info_slis
                                            if found.
    <l_text> = ls_subtottxt_info_slis-display_text_for_subtotal.
  endif.

endform.                               " METHOD_SUBTOTAL_TEXT

*&---------------------------------------------------------------------*
*&      Form  METHOD_END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_end_of_page.
  if not gt_grid-i_callback_end_of_page is initial and
     not i_callback_program is initial.
    perform (gt_grid-i_callback_end_of_page)
      in program (i_callback_program).
  endif.

endform.                               " METHOD_END_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  LVC_TRANSFER_TO_KKBLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_FIELDCAT_LVC  text
*      -->P_LT_SORT_LVC  text
*      -->P_LT_FILTER_LVC  text
*      -->P_LT_COLS  text
*      -->P_LT_FILTERED_ENTRIES_LVC  text
*      -->P_LT_FIELDCAT_SAV  text
*      -->P_LT_SORT  text
*      -->P_LT_FILTER  text
*      -->P_LT_FITLERED_ENTRIES  text
*      -->P_LS_LAYOUT  text
*----------------------------------------------------------------------*
form lvc_transfer_to_kkblo tables
                                rt_fieldcat_lvc type lvc_t_fcat
                                rt_sort_lvc type lvc_t_sort
                                rt_filter_lvc type lvc_t_filt
                                rt_cols type lvc_t_col
                                rt_fieldcat_sav type kkblo_t_fieldcat
                                rt_sort type kkblo_t_sortinfo
                                rt_filter type kkblo_t_filter
                                rt_filtered_entries type kkblo_t_sfinfo
                           using
                                rt_filtered_entries_lvc type lvc_t_fidx
                                rs_layout_lvc type lvc_s_layo
                                rs_print_lvc type lvc_s_prnt"B20K8A0N5D
                                rs_layout type kkblo_layout."#EC *

  call function 'LVC_TRANSFER_TO_KKBLO'
       exporting
            it_fieldcat_lvc           = rt_fieldcat_lvc[]
            it_sort_lvc               = rt_sort_lvc[]
            it_filter_lvc             = rt_filter_lvc[]
            it_selected_cols          = rt_cols[]
*           IT_SPECIAL_GROUPS_LVC     =
            it_filter_index_lvc       = rt_filtered_entries_lvc
*           IT_GROUPLEVELS_LVC        =
*           IS_TOTAL_OPTIONS_LVC      =
            is_layout_lvc             = rs_layout_lvc
*           IS_VARIANT_LVC            =
*           I_VARIANT_SAVE_LVC        =
*           I_VARIANT_DEFAULT_LVC     =
            is_print_info_lvc         = rs_print_lvc        "B20K8A0N5D
*           IS_REPREP_LVC             =
*           I_REPREP_ACTIVE_LVC       =
*           IS_SELFIELD_LVC           =
       importing
            et_fieldcat_kkblo         = rt_fieldcat_sav[]
            et_sort_kkblo             = rt_sort[]
            et_filter_kkblo           = rt_filter[]
*           ET_SPECIAL_GROUPS_KKBLO   =
            et_filtered_entries_kkblo = rt_filtered_entries[]
*           ET_GROUPLEVELS_KKBLO      =
*           ES_SUBTOT_OPTIONS_KKBLO   =
            es_layout_kkblo           = rs_layout
*           ES_REPREP_ID_KKBLO        =
*           ES_SELFIELD_KKBLO         =
       tables
            it_data                   = t_outtab
*      EXCEPTIONS
*           IT_DATA_MISSING           = 1
*           IT_FIELDCAT_LVC_MISSING   = 2
*           OTHERS                    = 3
            .
endform.                               " LVC_TRANSFER_TO_KKBLO
*&---------------------------------------------------------------------*
*&      Form  EVENT_EXIT_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_BEFORE  text
*----------------------------------------------------------------------*
form event_exit_check using r_ucomm type sy-ucomm
                            r_go type c.

  if 1 eq 2.
    statics: begin of lt_trans occurs 0,
               from_ucomm type sy-ucomm,
               to_ucomm   type sy-ucomm,
             end of lt_trans.

    if lt_trans[] is initial.
      lt_trans-from_ucomm = '&COL0'.
      lt_trans-to_ucomm   = '&OL0'.
      append lt_trans.

      lt_trans-from_ucomm = '&PC'.
      lt_trans-to_ucomm   = '%PC'.
      append lt_trans.

      lt_trans-from_ucomm = '&FIND'.
      lt_trans-to_ucomm   = '%SC'.
      append lt_trans.

      lt_trans-from_ucomm = '&SEND'.
      lt_trans-to_ucomm   = '%SL'.
      append lt_trans.

      lt_trans-from_ucomm = '&SAVE'.
      lt_trans-to_ucomm   = '&AVE'.
      append lt_trans.

      lt_trans-from_ucomm = '&MAINTAIN'.
      lt_trans-to_ucomm   = '&ERW'.
      append lt_trans.

      lt_trans-from_ucomm = '&FILTER'.
      lt_trans-to_ucomm   = '&ILT'.
      append lt_trans.

      lt_trans-from_ucomm = '&LOAD'.
      lt_trans-to_ucomm   = '&OAD'.
      append lt_trans.

      lt_trans-from_ucomm = '&SORT_DSC'.
      lt_trans-to_ucomm   = '&ODN'.
      append lt_trans.

      lt_trans-from_ucomm = '&SORT_ASC'.
      lt_trans-to_ucomm   = '&OUP'.
      append lt_trans.

      lt_trans-from_ucomm = '&PRINT_BACK'.
      lt_trans-to_ucomm   = '&RNT'.
      append lt_trans.

      lt_trans-from_ucomm = '&SUMC'.
      lt_trans-to_ucomm   = '&UMC'.
      append lt_trans.

      lt_trans-from_ucomm = '&SUBTOT'.
      lt_trans-to_ucomm   = '&SUM'.
      append lt_trans.

      lt_trans-from_ucomm = '&HELP'.
      lt_trans-to_ucomm   = '&ELP'.
      append lt_trans.

      lt_trans-from_ucomm = '&OPTIMIZE'.
      lt_trans-to_ucomm   = '&OPT'.
      append lt_trans.

      lt_trans-from_ucomm = '&PRINT_BACK_PREVIEW'.
      lt_trans-to_ucomm   = '&RNT_PREV'.
      append lt_trans.

      lt_trans-from_ucomm = '&DELETE_FILTER'.
      lt_trans-to_ucomm   = '&ILD'.
      append lt_trans.

      lt_trans-from_ucomm = '&BEB1'.
      lt_trans-to_ucomm   = '&EB1'.
      append lt_trans.

      lt_trans-from_ucomm = '&BEB2'.
      lt_trans-to_ucomm   = '&EB2'.
      append lt_trans.

      lt_trans-from_ucomm = '&BEB3'.
      lt_trans-to_ucomm   = '&EB3'.
      append lt_trans.

      lt_trans-from_ucomm = '&BEB9'.
      lt_trans-to_ucomm   = '&EB9'.
      append lt_trans.

      lt_trans-from_ucomm = '&BEBN'.
      lt_trans-to_ucomm   = '&EBN'.
      append lt_trans.

      lt_trans-from_ucomm = '&DETAIL'.
      lt_trans-to_ucomm   = '&ETA'.
      append lt_trans.

      sort lt_trans by from_ucomm.
    endif.

    read table lt_trans with key from_ucomm = r_ucomm
         binary search.
    if sy-subrc = 0.
      r_ucomm = lt_trans-to_ucomm.
    endif.
  endif.

  cl_gui_alv_grid=>transfer_fcode_lvc_to_slis(
    exporting
      i_fcode_lvc    = r_ucomm
    importing
      e_fcode_slis   = r_ucomm
    exceptions
      no_match_found = 1 ).                                 "#EC *

  sy-subrc = 4.
  case r_go.
    when 'B'.
      read table it_event_exit with key ucomm = r_ucomm
                                        before = 'X'
           transporting no fields.
    when 'A'.
      read table it_event_exit with key ucomm = r_ucomm
                                        after = 'X'
           transporting no fields.
  endcase.

  if sy-subrc eq 0.
    r_go = 'X'.
  else.
    clear r_go.
  endif.

endform.                               " EVENT_EXIT_CHECK
*&---------------------------------------------------------------------*
*&      Form  LVC_TRANSFER_FROM_KKBLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_FIELDCAT  text
*      -->P_LT_SORT  text
*      -->P_LT_FILTER  text
*      -->P_LT_FIELDCAT_LVC  text
*      -->P_LT_SORT_LVC  text
*      -->P_LT_FILTER_LVC  text
*      -->P_LS_LAYOUT  text
*      -->P_LS_LAYOUT_LVC  text
*----------------------------------------------------------------------*
form lvc_transfer_from_kkblo tables  rt_fieldcat type kkblo_t_fieldcat
                                     rt_sort type kkblo_t_sortinfo
                                     rt_filter type kkblo_t_filter
                                     rt_fieldcat_lvc type lvc_t_fcat
                                     rt_sort_lvc type lvc_t_sort
                                     rt_filter_lvc type lvc_t_filt
                             using   rs_layout type kkblo_layout
                                     rs_layout_lvc type lvc_s_layo
                               rs_print_lvc type lvc_s_prnt."B20K8A0N5D
                                                            "#EC *

  call function 'LVC_TRANSFER_FROM_KKBLO'
       exporting
            it_fieldcat_kkblo         = rt_fieldcat[]
            it_sort_kkblo             = rt_sort[]
            it_filter_kkblo           = rt_filter[]
*           IT_SPECIAL_GROUPS_KKBLO   =
*           IT_FILTERED_ENTRIES_KKBLO =
*           IT_GROUPLEVELS_KKBLO      =
*           IS_SUBTOT_OPTIONS_KKBLO   =
            is_layout_kkblo           = rs_layout
*           IS_REPREP_ID_KKBLO        =
*           I_CALLBACK_PROGRAM_KKBLO  =
       importing
            et_fieldcat_lvc           = rt_fieldcat_lvc[]
            et_sort_lvc               = rt_sort_lvc[]
            et_filter_lvc             = rt_filter_lvc[]
*           ET_SPECIAL_GROUPS_LVC     =
*           ET_FILTER_INDEX_LVC       =
*           ET_GROUPLEVELS_LVC        =
*           ES_TOTAL_OPTIONS_LVC      =
            es_layout_lvc             = rs_layout_lvc
*           ES_VARIANT_LVC            =
*           E_VARIANT_SAVE_LVC        =
            es_print_info_lvc         = rs_print_lvc        "B20K8A0N5D
*           ES_REPREP_LVC             =
*           E_REPREP_ACTIVE_LVC       =
     tables
          it_data                   = t_outtab
     exceptions
          it_data_missing           = 0
          others                    = 0.
  if sy-subrc eq 0.
  endif.

endform.                               " LVC_TRANSFER_FROM_KKBLO
*---------------------------------------------------------------------*
*       FORM marks_save                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  r_ucomm                                                       *
*---------------------------------------------------------------------*
form marks_save using r_ucomm like sy-ucomm.
  field-symbols: <l_box>.
  data: l_tabix type sy-tabix.
  data: lt_rows type lvc_t_row.
  data: l_ucomm type sy-ucomm.

  if not gt_grid-s_layout-box_fieldname is initial.
    call method gt_grid-grid->get_selected_rows
      importing
        et_index_rows = lt_rows.
    delete lt_rows where rowtype ne ' '.
    sort lt_rows by index.
    assign component gt_grid-s_layout-box_fieldname
                                             of structure t_outtab
    to <l_box>.
    data: l_sel_lines type i.
    data: l_tab_lines type i.
    data: ls_rows type lvc_s_row.
* check
    if r_ucomm = '&SAL' or r_ucomm = '&ALL'.
      l_ucomm = r_ucomm.
    else.
      describe table lt_rows lines l_sel_lines.
      describe table t_outtab lines l_tab_lines.
      if l_sel_lines = 0.
        l_ucomm = '&SAL'.
      endif.
      if l_sel_lines = l_tab_lines.
        l_ucomm = '&ALL'.
      endif.
    endif.
* set/unset <box> of all items
    if l_ucomm eq '&SAL' or l_ucomm eq '&ALL'.
      if l_ucomm eq '&SAL'.
        loop at t_outtab.
          l_tabix = l_tabix + 1.
          <l_box> = ' '.
          modify t_outtab index l_tabix.
        endloop.
      endif.
      if l_ucomm eq '&ALL'.
        loop at t_outtab.
          l_tabix = l_tabix + 1.
          <l_box> = 'X'.
          modify t_outtab index l_tabix.
        endloop.
      endif.
    else.
*delete all existing marks of <box>
      loop at t_outtab.
        l_tabix = l_tabix + 1.
        <l_box> = ' '.
        modify t_outtab index l_tabix.
      endloop.
*insert new marks in <box>
      loop at lt_rows into ls_rows.
        read table t_outtab index ls_rows-index.
        if sy-subrc eq 0.
          <l_box> = 'X'.
          modify t_outtab index ls_rows-index.
        endif.
      endloop.
    endif.
  endif.

*  if not gt_grid-s_layout-box_fieldname is initial.
*    call method gt_grid-grid->get_selected_rows
*      importing
*        et_index_rows = lt_rows.
*    sort lt_rows by index.
*    assign component gt_grid-s_layout-box_fieldname
*                                             of structure t_outtab
*    to <l_box>.
*    loop at t_outtab.
*      l_tabix = l_tabix + 1.
*      if r_ucomm = '&ALL'.
*        <l_box> = 'X'.
*        modify t_outtab index l_tabix.
*      elseif r_ucomm = '&SAL'.
*        <l_box> = ' '.
*        modify t_outtab index l_tabix.
*      else.
*        move l_tabix to l_index.
*        read table lt_rows with key index = l_index rowtype = ' '
*                           transporting no fields.
*        if sy-subrc = 0.
*          if <l_box> ne 'X'.
*            <l_box> = 'X'.
*            modify t_outtab index l_tabix.
*          endif.
*        else.
*          if <l_box> = 'X'.
*            <l_box> = ' '.
*            modify t_outtab index l_tabix.
*          endif.
*        endif.
*      endif.
*    endloop.
*  endif.

endform.                               " MARKS_SAVE
*&---------------------------------------------------------------------*
*&      Form  METHOD_AFTER_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form method_after_refresh.
  field-symbols: <l_box>.
  data: l_tabix type sy-tabix.
  data: ls_rows type lvc_s_row.
  data: lt_rows type lvc_t_row.

  if not gt_grid-s_layout-box_fieldname is initial.

    assign component gt_grid-s_layout-box_fieldname
                                             of structure t_outtab
    to <l_box>.
    loop at t_outtab.
      l_tabix = l_tabix + 1.
      check <l_box> = 'X'.
      ls_rows-index = l_tabix.
      append ls_rows to lt_rows.
    endloop.
    call method gt_grid-grid->set_selected_rows
      exporting
        it_index_rows = lt_rows.

  endif.

endform.                               " METHOD_AFTER_REFRESH
*&---------------------------------------------------------------------*
*&      Form  METHOD_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
form method_data_changed using rr_data_changed type ref to
                                          cl_alv_changed_data_protocol.
  if not gt_grid-i_callback_data_changed is initial and
     not i_callback_program is initial.
    perform (gt_grid-i_callback_data_changed)
      in program (i_callback_program) using
                                      rr_data_changed.
  endif.


endform.                               " METHOD_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  METHOD_USE_NEW_RESOURCES
*&---------------------------------------------------------------------*
form method_use_new_resources.
  IF gt_grid-flg_no_html IS INITIAL
     AND NOT gt_grid-top IS INITIAL.
    perform html.
  endif.
  IF gt_grid-flg_no_html_end IS INITIAL
     AND NOT gt_grid-bottom IS INITIAL.
    perform html_bottom.
  endif.
endform.                               " METHOD_USE_NEW_RESOURCES
*&---------------------------------------------------------------------*
*&      Form  context_menu_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form context_menu_request using e_object type ref to cl_ctmenu.

  data: lt_excluding_lvc type ui_functions.

  call method cl_gui_alv_grid=>transfer_fcode_slis_to_lvc
    exporting
      it_fcodes_slis = gt_grid-t_excluding[]
    importing
      et_fcodes_lvc  = lt_excluding_lvc[].

  call method e_object->hide_functions
    exporting
      fcodes = lt_excluding_lvc.

  perform (gt_grid-i_callback_context_menu)                 "B20K8A0YFV
    in program (i_callback_program) using e_object if found.

endform.                    " context_menu_request
*>>> INSERT BRAUNMI HEADER INFO B20K8A0OM8
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form fill_header using is_header
                       value(i_oo_alv) type ref to cl_gui_alv_grid.

  if gt_grid-grid is initial or gt_grid-grid ne i_oo_alv.
    exit.
  endif.

  move is_header to t_outtab.

endform.                    " fill_header
*<<< INSERT BRAUNMI HEADER INFO B20K8A0OM8
*&---------------------------------------------------------------------*
*&      Form  METHOD_ENTER_ON_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form method_enter_on_grid using r_ucomm type sy-ucomm.
  data: lt_rseul_keys type table of rseul_keys.
  data: ls_rseul_keys type rseul_keys.
  data: l_status      type sypfkey.                         "#EC NEEDED
  data: l_pname       type trdir-name.
  data: l_repid       type syrepid.
  data: lr_model      type ref to cl_salv_table.

  if gt_grid-i_callback_pf_status_set is initial.
    l_pname = 'SAPLKKBL'.
  else.
    l_pname = i_callback_program.
  endif.
  if gt_grid-r_salv_fullscreen_adapter is bound.
*  statusname must be asked, own status can exist
*    if i_callback_program eq 'SAPLSLVC_FULLSCREEN'.
*      l_pname = 'SAPLSALV_METADATA_STATUS'.
*    else.
      lr_model ?=
          gt_grid-r_salv_fullscreen_adapter->r_controller->r_model.
      call method lr_model->get_screen_status
        importing
          report   = l_repid
          pfstatus = l_status.
      l_pname = l_repid.
*    endif.
  endif.
  call function 'RS_CUA_GET_STATUS'
    exporting
*     LANGUAGE                    = ' '
      program                     = l_pname
      status                      = sy-pfkey
*     SUPPRESS_CMOD_ENTRIES       = 'X'
    tables
*     STATUS_LIST                 =
      fkeys                       = lt_rseul_keys
*     TREE                        =
*     NOT_FOUND_LIST              =
*     MENUTREE                    =
*     FUNCTIONKEYS                =
    EXCEPTIONS                            "Y6DK038775
      NOT_FOUND_PROGRAM           = 1
      NOT_FOUND_STATUS            = 2
      RECURSIVE_MENUES            = 3
      EMPTY_LIST                  = 4
      NOT_FOUND_MENU              = 5
      OTHERS                      = 6.

*<<<Y6DK038775
  if sy-subrc eq 0.
  read table lt_rseul_keys into ls_rseul_keys
             with key pfno = '00'.
  if sy-subrc = 0.
    r_ucomm = ls_rseul_keys-code.
*    cl_gui_cfw=>set_new_ok_code( r_ucomm ).  "no event
    ok_code = r_ucomm.
    perform pai.
  endif.
   endif.
*>>>Y6DK038775
endform.                               " METHOD_ENTER_ON_GRID
