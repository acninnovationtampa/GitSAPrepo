*&---------------------------------------------------------------------
*
*&      Form  GLOBALS_PUSH
*&---------------------------------------------------------------------
*
*       text
*----------------------------------------------------------------------
*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
*
form globals_push.
  data: l_status_set       type  slis_formname,
        l_user_command     type  slis_formname,
        l_top_of_page      type  slis_formname,
        l_top_of_list      type  slis_formname,
        l_end_of_list      type  slis_formname,
        l_end_of_page      type  slis_formname,
        l_subtotal_text    type  slis_formname,
        l_html_top_of_page type  slis_formname,
        l_data_changed     type  slis_formname,
        l_caller_exit      type  slis_formname,
        l_html_end_of_list type  slis_formname,
        l_context_menu     type  slis_formname.
*
  insert gt_grid index 1.
  clear  gt_grid.
  clear:
    g_parent_grid,
    g_parent_html,
    g_parent_end.

  gt_grid-repid = sy-repid.

  perform events_get using l_status_set
                           l_user_command
                           l_top_of_page
                           l_end_of_page
                           l_subtotal_text
                           l_html_top_of_page
                           l_html_end_of_list
                           l_data_changed
                           l_caller_exit
                           l_top_of_list
                           l_end_of_list
                           l_context_menu.

  gt_grid-r_salv_fullscreen_adapter = ir_salv_fullscreen_adapter.

  gt_grid-i_callback_program          = i_callback_program.

  gt_grid-i_callback_pf_status_set    = l_status_set.
  gt_grid-i_callback_user_command     = l_user_command.
  gt_grid-i_callback_top_of_page      = l_top_of_page.
  gt_grid-i_callback_end_of_page      = l_end_of_page.
  gt_grid-i_callback_top_of_list      = l_top_of_list.
  gt_grid-i_callback_end_of_list      = l_end_of_list.
  gt_grid-i_callback_subtotal_text    = l_subtotal_text.
  gt_grid-i_callback_caller_exit      = l_caller_exit.
  gt_grid-i_callback_data_changed     = l_data_changed.
  gt_grid-i_callback_context_menu     = l_context_menu.
  if not l_html_top_of_page is initial.
    gt_grid-i_callback_html_top_of_page = l_html_top_of_page.
  else.
    if gt_grid-r_salv_fullscreen_adapter is bound.
      if l_top_of_list is initial or
        i_grid_settings-top_p_only = 'X'.
        gt_grid-flg_no_html = 'X'.
      endif.
    else.
      if l_top_of_page is initial or
        i_grid_settings-top_p_only = 'X'.
        gt_grid-flg_no_html = 'X'.
      endif.
    endif.
  endif.
  gt_grid-s_variant = is_variant.

*>>> new API
  if gt_grid-r_salv_fullscreen_adapter is not bound.
*<<< new API
    if is_variant-report is initial and not i_save is initial.
      gt_grid-s_variant-report = i_callback_program.
    endif.
    if is_variant-report is initial and i_save is initial.
      gt_grid-s_variant_save-report = i_callback_program.
    endif.
*>>> new API
  endif.
*<<< new API
  if not l_html_end_of_list is initial.
    gt_grid-i_callback_html_end_of_list = l_html_end_of_list.
  else.
    if l_end_of_list is initial or
      i_grid_settings-eol_p_only = 'X'.
      gt_grid-flg_no_html_end = 'X'.
    endif.
  endif.

  gt_grid-s_sel_hide = is_sel_hide.

  gt_grid-t_alv_graphics = it_alv_graphics.

  data: ls_alv_graphics type dtc_s_tc.
  ls_alv_graphics-prop_id  = 'FULLSCREEN_MODE'.
  ls_alv_graphics-prop_val = abap_true.
  append ls_alv_graphics to gt_grid-t_alv_graphics.

endform.                               " GLOBALS_PUSH

*&---------------------------------------------------------------------
*
*&      Form  events_get
*&---------------------------------------------------------------------
*
form events_get using r_status_set       type slis_formname
                      r_user_command     type slis_formname
                      r_top_of_page      type slis_formname
                      r_end_of_page      type slis_formname
                      r_subtotal_text    type slis_formname
                      r_html_top_of_page type slis_formname
                      r_html_end_of_list type slis_formname
                      r_data_changed     type slis_formname
                      r_caller_exit      type slis_formname
                      r_top_of_list      type slis_formname
                      r_end_of_list      type slis_formname
                      r_context_menu     type slis_formname.

  data: ls_events type slis_alv_event.

  r_status_set       = i_callback_pf_status_set.
  r_user_command     = i_callback_user_command.
  r_top_of_page      = i_callback_top_of_page.
  r_html_top_of_page = i_callback_html_top_of_page.
  r_html_end_of_list = i_callback_html_end_of_list.

  loop at it_events into ls_events where not form is initial.
    case ls_events-name.
      when slis_ev_top_of_page.
        r_top_of_page  = ls_events-form.
      when slis_ev_data_changed.
        r_data_changed = ls_events-form.
      when slis_ev_end_of_page.
        r_end_of_page  = ls_events-form.
      when slis_ev_user_command.
        r_user_command = ls_events-form.
      when slis_ev_pf_status_set.
        r_status_set   = ls_events-form.
      when slis_ev_subtotal_text.
        r_subtotal_text = ls_events-form.
      when slis_ev_top_of_list.
        r_top_of_list = ls_events-form.
      when slis_ev_end_of_list.
        r_end_of_list = ls_events-form.
      when slis_ev_caller_exit_at_start.
        r_caller_exit = ls_events-form.
      when slis_ev_context_menu.
        r_context_menu = ls_events-form.
    endcase.
  endloop.

endform.                               " events_get

*&---------------------------------------------------------------------
*
*&      Form  REPREP_CHECK
*&---------------------------------------------------------------------
*
form reprep_check.
  data: l_subrc type sy-subrc.
  if is_layout-reprep = 'X'.
    perform reprep_exit_check in program saplkkbl
                              using l_subrc.
    if l_subrc = 0 .
      perform reprep_trsti_check in program saplkkbl
                                 using gt_grid-t_fccls
                                       i_callback_program
                                       is_reprep_id
                                       l_subrc.

      perform reprep_stack_check in program saplkkbl
                                 using i_callback_program
                                       is_reprep_id
                                       gt_grid-flg_called.

    endif.
  endif.

endform.                               " REPREP_CHECK
*---------------------------------------------------------------------*
*       FORM REPREP_CHECK_lvc                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form reprep_check_lvc.
  data: l_subrc type sy-subrc.
  data: ls_reprep_id type slis_reprep_id.

  perform reprep_exit_check in program saplkkbl
                            using l_subrc.
  if l_subrc = 0 .
    call function 'LVC_TRANSFER_TO_KKBLO'
      exporting
        is_reprep_lvc      = is_reprep_id_lvc
      importing
        es_reprep_id_kkblo = ls_reprep_id.

    perform reprep_trsti_check in program saplkkbl
                               using gt_grid-t_fccls
                                     i_callback_program
                                     ls_reprep_id
                                     l_subrc.

    perform reprep_stack_check in program saplkkbl
                               using i_callback_program
                                     ls_reprep_id
                                     gt_grid-flg_called.

  endif.


endform.                               " REPREP_CHECK

*&---------------------------------------------------------------------
*
*&      Form  TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------
*
form transfer_slis_to_lvc.
  data: ls_fieldcat type kkblo_fieldcat.
  data: l_tabname type kkblo_tabname.                       "#EC NEEDED

  call function 'REUSE_ALV_TRANSFER_DATA'
    exporting
      is_print          = is_print
      it_fieldcat       = it_fieldcat
      is_layout         = is_layout
      it_sort           = it_sort
      it_filter         = it_filter
      it_excluding      = it_excluding
      it_special_groups = it_special_groups
      it_event_exit     = it_event_exit
      it_except_qinfo   = it_except_qinfo
    importing
      et_event_exit     = gt_grid-t_event_exit
      et_fieldcat       = gt_grid-t_fieldcat
      es_layout         = gt_grid-s_layout
      et_sort           = gt_grid-t_sort
      et_filter         = gt_grid-t_filter
      et_excluding      = gt_grid-t_excluding
      et_special_groups = gt_grid-t_special_groups
      et_except_qinfo   = gt_grid-t_qinfo.

  loop at gt_grid-t_fieldcat into ls_fieldcat
                             where not tabname is initial.
    l_tabname = ls_fieldcat-tabname.
    exit.
  endloop.
  if sy-subrc ne 0.
    l_tabname = '1'.
  endif.

  call function 'LVC_TRANSFER_FROM_KKBLO'
    exporting
      i_structure_name        = i_structure_name
      it_fieldcat_kkblo       = gt_grid-t_fieldcat
      it_sort_kkblo           = gt_grid-t_sort
      it_filter_kkblo         = gt_grid-t_filter
      it_special_groups_kkblo = gt_grid-t_special_groups
      is_layout_kkblo         = gt_grid-s_layout
      it_add_fieldcat         = it_add_fieldcat
      it_excluding_kkblo      = gt_grid-t_excluding[]
      it_except_qinfo_kkblo   = gt_grid-t_qinfo[]
    importing
      et_fieldcat_lvc         = gt_grid-t_lvc_fieldcat
      et_sort_lvc             = gt_grid-t_lvc_sort
      et_filter_lvc           = gt_grid-t_lvc_filter
      et_special_groups_lvc   = gt_grid-t_lvc_spec
      es_layout_lvc           = gt_grid-s_lvc_layout
      es_print_info_lvc       = gt_grid-s_lvc_print
      et_excluding_lvc        = gt_grid-t_excluding_lvc[]
      et_except_qinfo_lvc     = gt_grid-t_lvc_qinfo[]
    tables
      it_data                 = t_outtab.
  gt_grid-s_lvc_layout-no_toolbar = 'X'.
  gt_grid-s_lvc_layout-grid_title = i_grid_title.
  gt_grid-s_lvc_layout-no_rowmove = 'X'.
  gt_grid-t_add_fieldcat = it_add_fieldcat.
  gt_grid-t_lvc_hyperlink = it_hyperlink.

*>>> new API
  if gt_grid-r_salv_fullscreen_adapter is bound.
    call method gt_grid-r_salv_fullscreen_adapter->if_salv_adapter~complete_metadata
      changing
        t_fieldcatalog = gt_grid-t_lvc_fieldcat
        s_layout       = gt_grid-s_lvc_layout.
  endif.
*<<< new API

endform.                               " TRANSFER_SLIS_TO_LVC

*---------------------------------------------------------------------*
*       FORM TRANSFER_lvc_TO_LVC                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form transfer_lvc_to_lvc.
  call function 'REUSE_ALV_TRANSFER_DATA'
    exporting
      it_excluding  = it_excluding
      it_event_exit = it_event_exit
    importing
      et_event_exit = gt_grid-t_event_exit
      et_excluding  = gt_grid-t_excluding.

  gt_grid-t_lvc_fieldcat = it_fieldcat_lvc.
  gt_grid-t_lvc_sort     = it_sort_lvc.
  gt_grid-t_lvc_filter   = it_filter_lvc.
  gt_grid-t_lvc_spec     = it_special_groups_lvc.
  gt_grid-s_lvc_layout   = is_layout_lvc.
  gt_grid-s_lvc_print    = is_print_lvc.
  gt_grid-t_lvc_hyperlink = it_hyperlink.
  gt_grid-t_lvc_qinfo    = it_except_qinfo_lvc.

  if not is_layout_lvc-box_fname is initial.
    gt_grid-s_lvc_layout-sel_mode = 'A'.
  endif.

  gt_grid-s_lvc_layout-no_toolbar = 'X'.
  gt_grid-s_lvc_layout-grid_title = i_grid_title.
*>>> INSERT BRAUNMI B20K8A0OM8 DRAG AND DROP ROWS
  gt_grid-s_lvc_layout-no_rowmove = 'X'.
*<<< INSERT BRAUNMI B20K8A0OM8 DRAG AND DROP ROWS
  gt_grid-s_layout-box_fieldname = gt_grid-s_lvc_layout-box_fname.
endform.                               " TRANSFER_SLIS_TO_LVC

*&---------------------------------------------------------------------
*
*&      Form  GLOBALS_POP
*&---------------------------------------------------------------------
*
*       text
*----------------------------------------------------------------------
*
form globals_pop.
* this read is absolutly necessary to fill the table header
  read table gt_grid index 1.
*
  delete gt_grid index 1.
endform.                               " GLOBALS_POP

*&---------------------------------------------------------------------
*
*&      Form  PBO
*&---------------------------------------------------------------------
*
form pbo.

  data: ls_variant type disvariant.
  data: ls_reprep_id type lvc_s_rprp.
  data: l_i type i value 1,
        l_fcat_complete type sap_bool.
  data: l_number_rows type i value 1.

*>>> INSERT BRAUNMI RepRep
  data: ls_event type slis_alv_event.
*<<< INSERT BRAUNMI RepRep

  data: l_html_height_top type i,
        l_html_height_end type i.

  data: l_height type i.

  constants: con_hex02      type x value '02'.    " Druckmodus

  if gt_grid-s_variant_save-report is initial.
    ls_variant = gt_grid-s_variant.
  else.
    ls_variant = gt_grid-s_variant_save.
  endif.

* >>> for object model:
  if not gt_grid-r_salv_fullscreen_adapter is initial.
*fieldcatalog is complete
    l_fcat_complete = abap_true.
  endif.
* <<<<<

  if cl_gui_alv_grid=>offline( ) is initial.
    if not gt_grid-s_layout-box_fieldname is initial.
      set handler gc_event_receiver->handle_before_user_command for
                                               gt_grid-grid.
      set handler gc_event_receiver->handle_after_refresh for
                                               gt_grid-grid.
    endif.

* create TOP-Document
    if gt_grid-flg_no_html is initial and gt_grid-top is initial.
      create object gt_grid-top
        exporting
          style = 'ALV_GRID'.
    endif.
* create BOTTOM-Document
    if gt_grid-flg_no_html_end is initial and gt_grid-bottom is initial
.
      create object gt_grid-bottom
        exporting
          style = 'ALV_GRID'.
    endif.
*
    if gt_grid-flg_no_html is initial.
      add 1 to l_i.
    endif.
    if gt_grid-flg_no_html_end is initial.
      add 1 to l_i.
    endif.
    l_number_rows = l_i.
    if gt_grid-container is initial.
      create object gt_grid-container
        exporting
          container_name = mycontainer
          lifetime       = cntl_lifetime_dynpro.
    endif.
*
    if gt_grid-grid is initial.
      if l_number_rows = 1.
        "Factory method instead of constructor
        if cl_alv_z_params=>get_parameter( cl_alv_z_params=>c_param-alv_gui_instance_builder ) is not initial.
        gt_grid-grid = cl_alv_gui_ist_builder_factory=>new_alv_gui_instance_builder( )->create_alv_grid_at_pbo(
          exporting
            i_appl_events   = 'X'
            i_parent        = gt_grid-container
            i_fcat_complete = l_fcat_complete ).
        else.
        create object gt_grid-grid  "Factory
          exporting
            i_appl_events   = 'X'
            i_parent        = gt_grid-container
            i_fcat_complete = l_fcat_complete.
        endif.
      else.
        create object gt_grid-splitter
          exporting
            parent  = gt_grid-container
            rows    = l_number_rows
            columns = 1.
        if gt_grid-flg_no_html is initial.
          call method gt_grid-splitter->get_container
            exporting
              row       = 1
              column    = 1
            receiving
              container = g_parent_html.
          call method gt_grid-splitter->get_container
            exporting
              row       = 2
              column    = 1
            receiving
              container = g_parent_grid.
        else.
          call method gt_grid-splitter->get_container
            exporting
              row       = 1
              column    = 1
            receiving
              container = g_parent_grid.
        endif.
        if gt_grid-flg_no_html_end is initial.
          if gt_grid-flg_no_html is initial.
            call method gt_grid-splitter->get_container
              exporting
                row       = 3
                column    = 1
              receiving
                container = g_parent_end.
          else.
            call method gt_grid-splitter->get_container
              exporting
                row       = 2
                column    = 1
              receiving
                container = g_parent_end.
          endif.
        endif.

        if i_grid_settings-coll_top_p eq 'X'.
          l_html_height_top = 0.
        elseif i_html_height_top is initial.
          l_html_height_top = 20.
        else.
          l_html_height_top = i_html_height_top.
        endif.
        if i_grid_settings-coll_end_l eq 'X'.
          l_html_height_end = 0.
        elseif i_html_height_end is initial.
          l_html_height_end = 20.
        else.
          l_html_height_end = i_html_height_end.
        endif.

        case l_i.
          when 2.
            if gt_grid-flg_no_html is initial.
              call method gt_grid-splitter->set_row_height
                exporting
                  id     = 1
                  height = l_html_height_top.
            else.
              call method gt_grid-splitter->set_row_height
                exporting
                  id     = 2
                  height = l_html_height_end.
            endif.
          when 3.
            call method gt_grid-splitter->set_row_height
              exporting
                id     = 1
                height = l_html_height_top.
            call method gt_grid-splitter->set_row_height
              exporting
                id     = 3
                height = l_html_height_end.
        endcase.

        "Factory method instead of constructor
        if cl_alv_z_params=>get_parameter( cl_alv_z_params=>c_param-alv_gui_instance_builder ) is not initial.
        gt_grid-grid = cl_alv_gui_ist_builder_factory=>new_alv_gui_instance_builder( )->create_alv_grid_at_pbo(
          exporting
            i_appl_events   = 'X'
            i_parent        = g_parent_grid
            i_fcat_complete = l_fcat_complete ).
        else.
        create object gt_grid-grid  "Factory
          exporting
            i_appl_events   = 'X'
            i_parent        = g_parent_grid
            i_fcat_complete = l_fcat_complete.  " ).
        endif.
      endif.

      if gt_grid-lvc is initial.
*        if cl_salv_test=>on eq 'X'.
*          cl_salv_test=>export_data_grid(
*            grid            = me
*            point_in_time_x = CL_SALV_TEST=>X_REUSE_ALV_GRID_DISPLAY
*            point_in_time_y = CL_SALV_TEST=>Y_DATA ).
*        endif.
        perform transfer_slis_to_lvc.
      else.
        perform transfer_lvc_to_lvc.
      endif.

*      if cl_salv_veri_run=>on = 'X'.
*        perform salv_at_99_2_stack.
*      endif.

      if gt_grid-s_lvc_layout-edit = 'X'.
        call method gt_grid-grid->register_edit_event
          exporting
            i_event_id = cl_gui_alv_grid=>mc_evt_enter.
      endif.
*ENTER on Popupmodus
      if i_screen_end_column > 0.
        call method gt_grid-grid->register_edit_event
          exporting
            i_event_id = cl_gui_alv_grid=>mc_evt_enter.
      endif.
* put to function module lvc_transfer_from_kkblo, because
* in use of Reuse_alv_grid_layout_info_get/set the sel_mode
* has not the right value when box_fieldname not initial
* css: 416654 2000 / kds
*      if not gt_grid-s_layout-box_fieldname is initial.
*        if gt_grid-s_lvc_layout-sel_mode <> 'C'.
*          gt_grid-s_lvc_layout-sel_mode = 'A'.
*        endif.
*      endif.

      perform event_receiver.
      gt_grid-s_lvc_print-no_colwopt = i_grid_settings-no_colwopt.

      data: ls_data                    type slis_data_caller_exit.
      if not gt_grid-i_callback_caller_exit is initial.
        perform (gt_grid-i_callback_caller_exit)
                               in program (gt_grid-i_callback_program)
                               using ls_data.

        call method gt_grid-grid->set_header_transport
          exporting
            i_header_transport = ls_data-callback_header_transport.
      endif.

      if gt_grid-lvc is initial.
        if is_reprep_id is initial.
          ls_reprep_id-s_rprp_id-tool = 'RT'.
          ls_reprep_id-s_rprp_id-onam = i_callback_program.
        else.
          ls_reprep_id = is_reprep_id.
        endif.
*>>> INSERT BRAUNMI RepRep
        read table it_events into ls_event
                   with key name = slis_ev_reprep_sel_modify.
        if sy-subrc eq 0.
          ls_reprep_id-cb_repid   = ls_reprep_id-s_rprp_id-onam.
          ls_reprep_id-cb_frm_mod = ls_event-form.
        endif.
*<<< INSERT BRAUNMI RepRep
      else.
        ls_reprep_id = is_reprep_id_lvc.
      endif.
      call method gt_grid-grid->activate_reprep_interface
        exporting
          is_reprep = ls_reprep_id
        exceptions
          no_sender = 1.

*>>> new API
      perform salv_set_selmode changing gt_grid-s_lvc_layout.
*<<< new API

*>>>Mendocino Extraction
* TOP-OF-LIST and END-OF-LIST must processed at first because of
* set screen 0. leave screen. in method set_table_for_first_display
      data: l_mode(1).
      import l_mode to l_mode from memory id 'ALV_EXTRACT_MODE'.
      if l_mode eq 'M'.
        perform raise_top_of_list.
        perform raise_end_of_list.
      endif.
*<<<Mendocino Extraction

      call method gt_grid-grid->set_table_for_first_display
        exporting
          i_consistency_check  = i_interface_check
          i_bypassing_buffer   = i_bypassing_buffer
          i_buffer_active      = i_buffer_active
          i_structure_name     = i_structure_name
          is_variant           = ls_variant
          i_save               = i_save
          i_default            = i_default
          is_layout            = gt_grid-s_lvc_layout
          is_print             = gt_grid-s_lvc_print
          it_special_groups    = gt_grid-t_lvc_spec
          it_hyperlink         = gt_grid-t_lvc_hyperlink
          it_toolbar_excluding = gt_grid-t_excluding_lvc
          it_except_qinfo      = gt_grid-t_lvc_qinfo
          ir_salv_adapter      = gt_grid-r_salv_fullscreen_adapter
          it_alv_graphics      = gt_grid-t_alv_graphics
        changing
          it_fieldcatalog      = gt_grid-t_lvc_fieldcat
          it_sort              = gt_grid-t_lvc_sort
          it_filter            = gt_grid-t_lvc_filter
          it_outtab            = t_outtab[].
    endif.

*>>> new API : wird 40 Zeilen weiter unten erledigt
*    perform salv_set_selections.
*<<< new API

    data: lr_content type ref to cl_salv_form_element.

*    if not sy-subty o con_hex02.
    if cl_gui_alv_grid=>offline( ) is initial. "Batch, Druck
      if not gt_grid-top is initial.
        call method gt_grid-top->initialize_document.
      endif.
      if not gt_grid-bottom is initial.
        call method gt_grid-bottom->initialize_document.
      endif.

*... TOP OF PAGE
*>>> Y3YK043656
      data: ls_layout type lvc_s_layo.
      gt_grid-grid->get_frontend_layout( importing es_layout = ls_layout ).
      if ls_layout-frontend ne cl_alv_bds=>mc_crystal_frontend.
        perform raise_top_of_list.
      endif.
*<<< Y3YK043656

*... END OF PAGE
      if not gt_grid-r_salv_fullscreen_adapter is bound.
        call method gt_grid-grid->list_processing_events
          exporting
            i_event_name = 'END_OF_PAGE'.
      endif.

*... END OF LIST
      perform raise_end_of_list.
    endif.

* create and fill HTML-CONTROL
    if gt_grid-flg_no_html is initial.
      if gt_grid-r_form_tol is not bound.
        perform html.
      endif.
*B20K8A0R55 for Excel Inplace HTML Header
      call method gt_grid-grid->set_html_header.
    endif.

    if gt_grid-r_form_eol is not bound.
      if gt_grid-flg_no_html_end is initial.
        perform html_bottom.
      endif.
    endif.

*>>> new API
    perform salv_set_selections.
*<<< new API

    data: lr_focus_container type ref to cl_gui_control,
          l_accessibility_mode type abap_bool.
*    field-symbols: <t_cntrl> type table.
*<<< Y7AK113139
*    call function 'GET_ACCESSIBILITY_MODE'
*      importing
*        accessibility     = l_accessibility_mode
*      exceptions
*        its_not_available = 0
*        others            = 0.

*    if l_accessibility_mode eq abap_true
*        and gt_grid-splitter is bound
*        and not gt_grid-splitter->children is initial.
*
*      assign gt_grid-splitter->children to <t_cntrl>.
*      read table <t_cntrl> index 1 into lr_focus_container.
*    else.
*      lr_focus_container = gt_grid-grid.
*    endif.
*
*    if not ( gt_grid-flg_popup eq abap_false
*    and l_accessibility_mode eq abap_true ).
*      call method cl_gui_control=>set_focus
*        exporting
*          control = lr_focus_container.
*    elseif gt_grid-flg_no_html eq abap_true and
*           l_accessibility_mode eq abap_true.
*      call method cl_gui_control=>set_focus
*        exporting
*          control = lr_focus_container.
*    endif.


* usability: focus has always to be set to the fullscreen grid,
* idependent of accessibility_mode, popup, HTML-TOP
* <<< Y7AK130495
   data: l_view type UI_FUNC.

    call method gt_grid-grid->get_actual_view( importing e_view = l_view ).

* focus may only be set to grid container in case of grid view!
    if l_view eq '&VGRID'.
      lr_focus_container = gt_grid-grid.
      call method cl_gui_control=>set_focus
            exporting
              control = lr_focus_container.
*>>> Y7AK113139
    else.
* do nothing in case of Excel or Crystal view!
    endif.
*>>> Y7AK130495

    if g_form_pf_status_executed eq abap_false.
      perform pf_status_set using gt_grid-flg_popup.
    endif.
  else.

    if gt_grid-grid is initial.
      "Factory method instead of constructor
        if cl_alv_z_params=>get_parameter( cl_alv_z_params=>c_param-alv_gui_instance_builder ) is not initial.
        gt_grid-grid = cl_alv_gui_ist_builder_factory=>new_alv_gui_instance_builder( )->create_alv_grid_at_pbo(
          exporting
            i_appl_events   = 'X'
            i_parent        = g_parent_grid
            i_fcat_complete = l_fcat_complete ).
        else.
        create object gt_grid-grid  "Factory
          exporting
            i_appl_events   = 'X'
            i_parent        = g_parent_grid
            i_fcat_complete = l_fcat_complete.
        endif.

      if gt_grid-lvc is initial.
        perform transfer_slis_to_lvc.
      else.
        perform transfer_lvc_to_lvc.
      endif.

      if not gt_grid-s_layout-box_fieldname is initial.
        gt_grid-s_lvc_layout-sel_mode = 'A'.
      endif.
      gt_grid-s_lvc_print-no_colwopt = i_grid_settings-no_colwopt.
      perform event_receiver.

*      if not sy-subty o con_hex02.
      if cl_gui_alv_grid=>offline( ) is initial. "Batch, Druck
* create TOP-Document
        if gt_grid-flg_no_html is initial and gt_grid-top is initial.
          create object gt_grid-top
            exporting
              style = 'ALV_GRID'.
        endif.
* create BOTTOM-Document
        if gt_grid-flg_no_html_end is initial and
        gt_grid-bottom is initial.
          create object gt_grid-bottom
            exporting
              style = 'ALV_GRID'.
        endif.


        call method gt_grid-grid->list_processing_events
          exporting
            i_event_name = 'TOP_OF_PAGE'
            i_dyndoc_id  = gt_grid-top.
        ">>>new 13.11.03
        call method gt_grid-grid->list_processing_events
          exporting
            i_event_name = 'END_OF_LIST'
            i_dyndoc_id  = gt_grid-bottom.
        "<<<new
      endif.

      if not gt_grid-i_callback_caller_exit is initial.
        perform (gt_grid-i_callback_caller_exit)
                               in program (gt_grid-i_callback_program)
                               using ls_data.

        call method gt_grid-grid->set_header_transport
          exporting
            i_header_transport = ls_data-callback_header_transport.
      endif.

      if gt_grid-lvc is initial.
        if is_reprep_id is initial.
          ls_reprep_id-s_rprp_id-tool = 'RT'.
          ls_reprep_id-s_rprp_id-onam = i_callback_program.
        else.
          ls_reprep_id = is_reprep_id.
        endif.
*>>> INSERT BRAUNMI RepRep
        read table it_events into ls_event
                   with key name = slis_ev_reprep_sel_modify.
        if sy-subrc eq 0.
          ls_reprep_id-cb_repid   = ls_reprep_id-s_rprp_id-onam.
          ls_reprep_id-cb_frm_mod = ls_event-form.
        endif.
*<<< INSERT BRAUNMI RepRep
      else.
        ls_reprep_id = is_reprep_id_lvc.
      endif.
      call method gt_grid-grid->activate_reprep_interface
        exporting
          is_reprep = ls_reprep_id
        exceptions
          no_sender = 1.

      call method gt_grid-grid->set_table_for_first_display
        exporting
          i_consistency_check  = i_interface_check
          i_buffer_active      = i_buffer_active
          i_structure_name     = i_structure_name
          is_variant           = ls_variant
          i_save               = i_save
          i_default            = i_default
          is_layout            = gt_grid-s_lvc_layout
          is_print             = gt_grid-s_lvc_print
          it_special_groups    = gt_grid-t_lvc_spec
          it_hyperlink         = gt_grid-t_lvc_hyperlink
          it_toolbar_excluding = gt_grid-t_excluding_lvc
          it_except_qinfo      = gt_grid-t_lvc_qinfo
          ir_salv_adapter      = gt_grid-r_salv_fullscreen_adapter
          it_alv_graphics      = gt_grid-t_alv_graphics
        changing
          it_fieldcatalog      = gt_grid-t_lvc_fieldcat
          it_sort              = gt_grid-t_lvc_sort
          it_filter            = gt_grid-t_lvc_filter
          it_outtab            = t_outtab[].
    endif.

* create and fill HTML-CONTROL
    if gt_grid-flg_no_html is initial.
      perform html.
    endif.
    if gt_grid-flg_no_html_end is initial.
      perform html_bottom.
    endif.

*>>> new API
    perform salv_set_selections.
*<<< new API

    if g_form_pf_status_executed eq abap_false.
      perform pf_status_set using gt_grid-flg_popup.
    endif.
  endif.

  if gt_grid-flg_first_time eq abap_true.
*... Accessibility Description
    data:
      l_text type string.

    if g_parent_html is bound.
      l_text = text-a02.
      g_parent_html->set_accdescription( l_text ).
      if gt_grid-html_cntrl is bound.
        gt_grid-html_cntrl->set_accdescription( l_text ).
      endif.
      if gt_grid-r_form_tol is bound.
        gt_grid-r_form_tol->if_salv_form~set_accdescription( l_text ).
      endif.
    endif.

    if g_parent_end is bound.
      l_text = text-a03.
      g_parent_end->set_accdescription( l_text ).
      if gt_grid-html_cntrl_bottom is bound.
        gt_grid-html_cntrl_bottom->set_accdescription( l_text ).
      endif.
      if gt_grid-r_form_eol is bound.
        gt_grid-r_form_eol->if_salv_form~set_accdescription( l_text ).
      endif.
    endif.

    if g_parent_grid is bound.
      l_text = text-a01.
      g_parent_grid->set_accdescription( l_text ).
      if gt_grid-grid is bound.
        l_text = text-a04.
        gt_grid-grid->set_accdescription( l_text ).
      endif.
    endif.
  endif.

  if cl_gui_alv_grid=>offline( ) is initial.
    clear gt_grid-flg_first_time.
  endif.

  g_form_pf_status_executed = abap_false.

endform.                               " PBO
*&---------------------------------------------------------------------
*
*&      Form  HTML
*&---------------------------------------------------------------------
*
form html.
  data l_length  type i.
*
  if gt_grid-html_cntrl is initial.
    create object gt_grid-html_cntrl
      exporting
        parent = g_parent_html.
  endif.
  if my_receiver is initial.
* set handler for change of gui-resources (fonts, colors, ...)
    create object my_receiver.
    set handler my_receiver->use_new_resources.
  endif.
* reuse_alv_grid_commentary_set
  call function 'REUSE_ALV_GRID_COMMENTARY_SET'
    exporting
      document = gt_grid-top
      bottom   = space
    importing
      length   = l_length.
  if l_length > 0 and i_grid_settings-coll_top_p is initial and
    gt_grid-i_callback_html_top_of_page is initial and
    gt_grid-i_callback_html_end_of_list is initial.
    call method gt_grid-splitter->set_row_mode
      exporting
        mode = cl_gui_splitter_container=>mode_absolute.
    call method gt_grid-splitter->set_row_height
      exporting
        height = l_length
        id     = 1.
  endif.
* get TOP->HTML_TABLE ready
  call method gt_grid-top->merge_document.
* set wallpaper
  call method gt_grid-top->set_document_background
    exporting
      picture_id = i_background_id.
* export to Memory for HTML Conversion
  export grid_top_html from  gt_grid-top->html_table
*** put in next line as soon as 5.0(B20) has cl_dd_area->table_of_pictu
*         top_pictures  from  gt_grid-top->table_of_pictures
                                    to memory id 'TOP_HTML_FOR_ALV'.
* connect TOP document to HTML-Control
  gt_grid-top->html_control = gt_grid-html_cntrl.
* display TOP document
  call method gt_grid-top->display_document
    exporting
      reuse_control      = 'X'
      parent             = g_parent_html
    exceptions
      html_display_error = 1.
  if sy-subrc ne 0.
* ??????????
  endif.
endform.                               " HTML
*---------------------------------------------------------------------*
*       FORM HTML_BOTTOM                                              *
*---------------------------------------------------------------------*
form html_bottom.
  data l_length type i.
*
  if gt_grid-html_cntrl_bottom is initial.
    create object gt_grid-html_cntrl_bottom
      exporting
        parent = g_parent_end.
  endif.
  if my_receiver is initial.
* set handler for change of gui-resources (fonts, colors, ...)
    create object my_receiver.
    set handler my_receiver->use_new_resources.
  endif.
* reuse_alv_grid_commentary_set
  call function 'REUSE_ALV_GRID_COMMENTARY_SET'
    exporting
      document = gt_grid-bottom
      bottom   = 'X'
    importing
      length   = l_length.
  if l_length > 0 and i_grid_settings-coll_end_l is initial and
    gt_grid-i_callback_html_top_of_page is initial and
    gt_grid-i_callback_html_end_of_list is initial.
    call method gt_grid-splitter->set_row_mode
      exporting
        mode = cl_gui_splitter_container=>mode_absolute.
    if gt_grid-flg_no_html is initial.
      call method gt_grid-splitter->set_row_height
        exporting
          height = l_length
          id     = 3.
    else.
      call method gt_grid-splitter->set_row_height
        exporting
          height = l_length
          id     = 2.
    endif.
  endif.
* get HTML_TABLE ready
  call method gt_grid-bottom->merge_document.
* set wallpaper
  call method gt_grid-bottom->set_document_background
    exporting
      picture_id = i_background_id.
* export to Memory for HTML Conversion
  export grid_bottom_html from  gt_grid-bottom->html_table
*** put in next line as soon as 5.0(B20) has cl_dd_area->table_of_pictu
*         bottom_pictures  from  gt_grid-bottom->table_of_pictures
                                    to memory id 'BOTTOM_HTML_FOR_ALV'.
* connect BOTTOM document to HTML-Control
  gt_grid-bottom->html_control = gt_grid-html_cntrl_bottom.
* display BOTTOM document
  call method gt_grid-bottom->display_document
    exporting
      reuse_control      = 'X'
      parent             = g_parent_end
    exceptions
      html_display_error = 1.
  if sy-subrc ne 0.
* ??????????
  endif.
endform.                    "html_bottom

*&---------------------------------------------------------------------
*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------
form pf_status_set using r_flg_popup.

  data: l_title type sy-title.
  data: lt_extab type kkblo_t_extab with header line.
  data: lt_extab_ida type kkblo_t_extab with header line.
  data: boolean type sap_bool.  "ACC

  "Take it_excluding every Roundtrip into account - before application gets the control
  lt_extab[] = it_excluding.
  perform adapt_excluding_tab changing lt_extab[].

*... Set the requested Status
  if not gt_grid-s_layout-window_titlebar is initial.
    set titlebar '003' of program 'SAPLKKBL' with
                 gt_grid-s_layout-window_titlebar.
  else.
    l_title = sy-title.
    set titlebar '003' of program 'SAPLKKBL' with l_title.
  endif.

  if not gt_grid-i_callback_pf_status_set is initial.
    "SALV or Application: calls ABAP command SET PF-STATUS....
    perform (gt_grid-i_callback_pf_status_set)
            in program (i_callback_program)
            using lt_extab[] if found.
  else.
    case gt_grid-s_layout-def_status.
      when ' ' or '1'.
        if r_flg_popup = 'X'.
          if not gt_grid-s_layout-box_fieldname is initial.
            set pf-status 'STDPOPBX_FULLSCREEN' excluding lt_extab
                          of program 'SAPLKKBL'.
          else.
            set pf-status 'STDPOPUP_FULLSCREEN' excluding lt_extab
                          of program 'SAPLKKBL'.
          endif.
        else.
          if gt_grid-s_layout-countfname eq space.
            boolean = cl_alv_check_third_party=>is_supported(
                           cl_alv_bds=>mc_crystal_frontend ).
            if boolean eq abap_true.
              set pf-status 'STANDARD_FULLSCR_CR' excluding lt_extab
                              of program 'SAPLKKBL'.
            else.
              set pf-status 'STANDARD_FULLSCREEN' excluding lt_extab
                              of program 'SAPLKKBL'.
            endif.
          else.
            set pf-status 'STANDARD_FULLSCR_CNT' excluding lt_extab
                            of program 'SAPLKKBL'.
          endif.
        endif.
      when '2'.
        if r_flg_popup = 'X'.
          if not gt_grid-s_layout-box_fieldname is initial.
            set pf-status 'STDPOPBX_FULLSCREEN' excluding lt_extab
                          of program 'SAPLKKBL'.
          else.
            set pf-status 'STDPOPUP_FULLSCREEN' excluding lt_extab
                          of program 'SAPLKKBL'.
          endif.
        else.
          set pf-status 'STANDARD_FULLSCR_HR' excluding lt_extab
                          of program 'SAPLKKBL'.
        endif.
      when '3'.
        if r_flg_popup = 'X'.
          if not gt_grid-s_layout-box_fieldname is initial.
            set pf-status 'STDPOPBX_FS_LIGHT' excluding lt_extab
                          of program 'SAPLKKBL'.
          else.
            set pf-status 'STDPOPUP_FS_LIGHT' excluding lt_extab
                          of program 'SAPLKKBL'.
          endif.
        else.
          set pf-status 'STD_LIGHT_FULLSCREEN' excluding lt_extab
                          of program 'SAPLKKBL'.
        endif.
    endcase.
  endif.

  gt_grid-t_excluding[] = lt_extab[].

  g_form_pf_status_executed = abap_true.

endform.                               " PF_STATUS_SET
*&---------------------------------------------------------------------
*
*&      Form  GRID
*&---------------------------------------------------------------------
*
form grid using rr_grid type ref to cl_gui_alv_grid.        "#EC CALLED
  rr_grid = gt_grid-grid.
endform.                    "grid
*&---------------------------------------------------------------------
*
*&      Form  USER
*&---------------------------------------------------------------------
*
form user_command using r_ucomm type sy-ucomm
                        r_refresh
                        r_exit
                        rs_stable type lvc_s_stbl.
  data: ls_selfield type slis_selfield.
*
  check not gt_grid-i_callback_user_command is initial.
  check not i_callback_program is initial.

  perform selfield_get using ls_selfield.
  if r_ucomm is initial.
    r_ucomm = '&IC1'.
  endif.

  perform (gt_grid-i_callback_user_command)
                                    in program (i_callback_program)
                                    using r_ucomm
                                          ls_selfield.

  rs_stable-row = ls_selfield-row_stable.
  rs_stable-col = ls_selfield-col_stable.

  r_refresh = ls_selfield-refresh.
  r_exit    = ls_selfield-exit.

endform.                    "user_command
*&---------------------------------------------------------------------
*
*&      Form  PAI
*&---------------------------------------------------------------------
*
form pai.
  class cl_gui_cfw definition load.
  data: ls_stable type lvc_s_stbl.
  data: l_ucomm type sy-ucomm.
  data: lflg_refresh(1) type c.
  data: lt_rows type lvc_t_row.                             "#EC *
  data: lflg_exit(1) type c.
  data: ls_event_exit type slis_event_exit.                 "#EC NEEDED
  data: l_subrc like sy-subrc.

  data: l_okcode type sy-ucomm.

  l_okcode = ok_code.
  clear ok_code.

  check l_okcode ne space.

  g_repid = sy-repid.

  case l_okcode.
    when 'BACK'.
      l_okcode = '&F03'.
    when 'RW'.
      l_okcode = '&F12'.
    when '%EX'.
      l_okcode = '&F15'.
  endcase.

  clear g_temp_ok_code.
  do 2 times.
    check not l_okcode is initial.
    l_ucomm = l_okcode.

    if not gt_grid-s_layout-f2code is initial and
      l_okcode eq '&IC1'.
      l_okcode = gt_grid-s_layout-f2code.
    endif.

    call method gt_grid-grid->set_function_code
      changing
        c_ucomm = l_okcode.

    if l_okcode eq '&F15' or
       l_okcode eq '&F03' or
       l_okcode eq '&F12'.

      read table it_event_exit into ls_event_exit
                               with key ucomm = l_okcode.
      if sy-subrc = 0.
        g_before = 'X'.
        perform user_command using l_okcode lflg_refresh lflg_exit
                                   ls_stable.
        clear g_before.
      endif.
    endif.

    case l_okcode.
      when space.

      when '&ONT'.
        perform user_command using l_okcode lflg_refresh lflg_exit
                                   ls_stable.
        clear l_okcode.
        perform exit.

      when '&F15'.
        l_subrc = 0.
        if not gt_grid-s_layout-confirmation_prompt is initial.
          perform confirmation_prompt using l_subrc.
        endif.
        if l_subrc eq 0.
          es_exit_caused_by_user-exit = 'X'.
          clear l_okcode.
          perform exit.
        endif.

      when '&F03'.
        l_subrc = 0.
        if not gt_grid-s_layout-confirmation_prompt is initial.
          perform confirmation_prompt using l_subrc.
        endif.
        if l_subrc eq 0.
          es_exit_caused_by_user-back = 'X'.
          clear l_okcode.
          perform exit.
        endif.

      when '&F12'.
        l_subrc = 0.
        if not gt_grid-s_layout-confirmation_prompt is initial.
          perform confirmation_prompt using l_subrc.
        endif.
        if l_subrc eq 0.
          es_exit_caused_by_user-cancel = 'X'.
          clear l_okcode.
          perform exit.
        endif.

      when '&AC1'.
        l_subrc = 0.
        if not gt_grid-s_layout-confirmation_prompt is initial.
          perform confirmation_prompt using l_subrc.
        endif.
        if l_subrc eq 0.
          es_exit_caused_by_user-back = 'X'.
          clear l_okcode.
          perform exit.
        endif.

      when '&IC1'.
        if not gt_grid-s_layout-f2code is initial.
          perform method_double_click using l_okcode.
        endif.

*      when '&EXPORT_ALVXML'.
*        perform salv_export_alvxml.

      when '&ADM'.
        perform memory_download.

      when '&ADMB'.
        perform download_to_memory.

      when '&ADX'.
        perform data_download tables t_outtab.

      when '&ADXBJ'.
        perform data_download_to_java_browser tables t_outtab.

      when '&ADXBA'.
        perform data_download_to_abap_browser tables t_outtab.

      when '&WD_DL'.
        perform wd_download tables t_outtab.

      when others.
        if l_okcode(4) eq '%_GC'.
          call method cl_gui_cfw=>dispatch.
          l_okcode = g_temp_ok_code.    "via double_click
        else.
          perform user_command using l_okcode lflg_refresh lflg_exit
                                     ls_stable.
          if lflg_exit eq 'X'.
            e_exit_caused_by_caller = 'X'.
            perform exit.
          else.
            if lflg_refresh is not initial.
*>>> new API
              perform salv_get_selections.
*<<< new API
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

*... TOP OF LIST
              perform raise_top_of_list.

*... END OF LIST
              perform raise_end_of_list.
            endif.
*>>> new API
            perform salv_set_selections.
*<<< new API
          endif.
        endif.
    endcase.

    if l_ucomm ne l_okcode.
      l_ucomm = l_okcode.
    else.
      clear l_ucomm.
      clear l_okcode.
    endif.
  enddo.

endform.                               " PAI
*&---------------------------------------------------------------------
*
*&      Form  SELFIELD_GET
*&---------------------------------------------------------------------
*
form selfield_get using rs_selfield type slis_selfield.

* ...
  data: ls_row_id type lvc_s_row.
  data: ls_col_id type lvc_s_col.
  data: l_value type lvc_s_data-value.
  data: ls_selfield type lvc_s_self.
  data: ls_fieldcat type slis_fieldcat_alv.
  data: ls_fieldcat_lvc type lvc_s_fcat.

  call method gt_grid-grid->get_current_cell
    importing
      es_row_id = ls_row_id
      es_col_id = ls_col_id
      e_value   = l_value.
  call method cl_gui_cfw=>flush.
  ls_selfield-s_row_id = ls_row_id.
  ls_selfield-s_col_id = ls_col_id.
  ls_selfield-value    = l_value.


  call function 'LVC_TRANSFER_TO_KKBLO'
    exporting
      is_selfield_lvc   = ls_selfield
    importing
      es_selfield_kkblo = rs_selfield.
*  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.

  if gt_grid-lvc = 'X'.
    loop at it_fieldcat_lvc into ls_fieldcat_lvc where tabname ne space
.
      move-corresponding ls_fieldcat_lvc to ls_fieldcat.
      exit.
    endloop.
  else.
    loop at it_fieldcat into ls_fieldcat where tabname ne space.
      exit.
    endloop.
  endif.
  if sy-subrc = 0.
    rs_selfield-tabname = ls_fieldcat-tabname.
    replace '1' with ls_fieldcat-tabname into rs_selfield-sel_tab_field
.
    condense rs_selfield-sel_tab_field no-gaps.
  endif.
  rs_selfield-before_action = g_before.
  rs_selfield-after_action  = g_after.

endform.                               " SELFIELD_GET
*---------------------------------------------------------------------*
*       FORM exit                                                     *
*&--------------------------------------------------------------------*
form exit.
* <<< YI3K165259
  data: lr_salv_adapter type REF TO cl_salv_adapter,
        lr_salv_controller type REF TO cl_salv_controller_model,
        lt_changelist TYPE standard table of if_salv_controller_changelist=>salv_s_changelist,
        ls_changelist type if_salv_controller_changelist=>salv_s_changelist,
        valid type abap_bool.
*>>> YI3K165259

  perform salv_get_metadata.
  perform salv_get_selections.
*  endif.

  call method gt_grid-container->free.
  if gt_grid-r_salv_fullscreen_adapter is bound.
    gt_grid-r_salv_fullscreen_adapter->remove_grid( ).

* <<< YI3K165259
*adjust SALV objects, no return to SALV to update settings, function handled only here!

    lr_salv_adapter ?= gt_grid-r_salv_fullscreen_adapter.
    lr_salv_controller ?= lr_salv_adapter->R_CONTROLLER.

    read table lr_salv_controller->t_changelist into ls_changelist
                                   with key  method = 'CLOSE_SCREEN' .

    if ls_changelist-change eq abap_true.

      CALL METHOD LR_SALV_CONTROLLER->CLEAR_CHANGELIST
        EXPORTING
          METHOD       = 'CLOSE_SCREEN'
        RECEIVING
          BOOLEAN      = valid.
    else.
      "do nothing
    endif.

    clear lr_salv_adapter->close_screen.  " parameter has to be cleared additionally
*>>> YI3K165259
  endif.

  call method cl_gui_cfw=>flush.

  if g_parent_html is bound.
    clear g_parent_html.
  endif.

  if g_parent_grid is bound.
    clear g_parent_grid.
  endif.

  if g_parent_end is bound.
    clear g_parent_end.
  endif.

  set screen 0.
  leave screen.

endform.                    "exit

*&--------------------------------------------------------------------*
*&      Form  raise_top_of_list
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form raise_top_of_list.

  export alv_form_html from abap_true
         to memory id 'ALV_FORM_HTML'.

  cl_salv_form_content=>free( ).

  g_is_online_event = if_salv_c_bool_sap=>true.

  if gt_grid-r_salv_fullscreen_adapter is bound.
    call method gt_grid-grid->list_processing_events
      exporting
        i_event_name = 'TOP_OF_LIST'.
  else.
    call method gt_grid-grid->list_processing_events
      exporting
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = gt_grid-top.
  endif.

  if cl_salv_form_content=>is_active( ) eq abap_true.
    if gt_grid-i_callback_html_top_of_page is initial.
      perform set_salv_form_content_tol.
    endif.

    export alv_form_html from abap_false
           to memory id 'ALV_FORM_HTML'.
  else.
    clear g_is_online_event.
  endif.

endform.                    "raise_top_of_list

*&--------------------------------------------------------------------*
*&      Form  raise_end_of_list
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form raise_end_of_list.

  export alv_form_html from abap_true
         to memory id 'ALV_FORM_HTML'.

  cl_salv_form_content=>free( ).

  g_is_online_event = if_salv_c_bool_sap=>true.

  call method gt_grid-grid->list_processing_events
    exporting
      i_event_name = 'END_OF_LIST'
      i_dyndoc_id  = gt_grid-bottom.

  if cl_salv_form_content=>is_active( ) eq abap_true.
    if gt_grid-i_callback_html_end_of_list is initial.
      perform set_salv_form_content_eol.
    endif.

    export alv_form_html from abap_false
           to memory id 'ALV_FORM_HTML'.
  else.
    clear g_is_online_event.
  endif.

endform.                    "raise_end_of_list

*&--------------------------------------------------------------------*
*&      Form  set_salv_form_content_tol
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form set_salv_form_content_tol.

  data:
    lr_content type ref to cl_salv_form_element,
    l_height   type i.

  check gt_grid-flg_no_html eq abap_false.

  check cl_salv_form_content=>is_active( ) eq abap_true.

  lr_content = cl_salv_form_content=>get( ).

  if gt_grid-r_form_tol is bound.
    check lr_content ne gt_grid-r_form_tol->get_content( ).
  endif.

  if gt_grid-r_form_tol is not bound.
    create object gt_grid-r_form_tol
      exporting
        r_container = g_parent_html
        r_content   = lr_content
        wallpaper   = i_background_id.
  endif.

  gt_grid-r_form_tol->set_content( lr_content ).
  l_height = gt_grid-r_form_tol->get_height( ).
  gt_grid-r_form_tol->display( ).

  check gt_grid-splitter is not initial.

  if i_grid_settings-coll_top_p is initial and
    gt_grid-i_callback_html_top_of_page is initial and
    gt_grid-i_callback_html_end_of_list is initial.
    gt_grid-splitter->set_visible( abap_true ).
    call method gt_grid-splitter->set_row_mode
      exporting
        mode = cl_gui_splitter_container=>mode_absolute.
    if i_html_height_top is initial.
*      if cl_alv_z_params=>get_parameter(
*         cl_alv_z_params=>c_flag-gui_alv_grid_bridge_on ) eq abap_true.
*        call method gt_grid-splitter->set_row_height
*          exporting
*            height = l_height
*            id     = gs_splitter_id-top_of_list.
*      else.
        call method gt_grid-splitter->set_row_height
          exporting
            height = l_height
            id     = 1.
*      endif.
    endif.
  endif.

endform.                    "set_salv_form_content_tol

*&---------------------------------------------------------------------*
*&      Form  set_salv_form_content_eol
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_salv_form_content_eol .

  data:
    lr_content type ref to cl_salv_form_element,
    l_height   type i.

  check gt_grid-flg_no_html_end eq abap_false.

  check cl_salv_form_content=>is_active( ) eq abap_true.

  lr_content = cl_salv_form_content=>get( ).

  if gt_grid-r_form_eol is bound.
    check lr_content ne gt_grid-r_form_eol->get_content( ).
  endif.

  if gt_grid-r_form_eol is not bound.
    create object gt_grid-r_form_eol
      exporting
        r_container = g_parent_end
        r_content   = lr_content.
  endif.

  gt_grid-r_form_eol->set_content( lr_content ).
  l_height = gt_grid-r_form_eol->get_height( ).
  gt_grid-r_form_eol->display( ).

  check gt_grid-splitter is not initial.

  if i_grid_settings-coll_end_l is initial and
    gt_grid-i_callback_html_top_of_page is initial and
    gt_grid-i_callback_html_end_of_list is initial.
    call method gt_grid-splitter->set_row_mode
      exporting
        mode = cl_gui_splitter_container=>mode_absolute.
*    if cl_alv_z_params=>get_parameter(
*       cl_alv_z_params=>c_flag-gui_alv_grid_bridge_on ) eq abap_true.
*      call method gt_grid-splitter->set_row_height
*        exporting
*          height = l_height
*          id     = gs_splitter_id-end_of_list.
*    else.
      if gt_grid-flg_no_html is initial.
        if i_html_height_end is initial.
          call method gt_grid-splitter->set_row_height
            exporting
              height = l_height
              id     = 3.
        endif.
      else.
        if i_html_height_end is initial.
          call method gt_grid-splitter->set_row_height
            exporting
              height = l_height
              id     = 2.
        endif.
      endif.
*    endif.  "brigde
  endif.

endform.                    " set_salv_form_content_eol
