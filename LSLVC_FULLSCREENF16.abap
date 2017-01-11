*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PBO_WITH_ADDITIONAL_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pbo_with_additional_toolbar .

  data: ls_variant type disvariant.
  data: ls_reprep_id type lvc_s_rprp.
  data: l_i type i value 1,
        l_fcat_complete type sap_bool.
  data: l_number_rows type i value 1.
  data: ls_event type slis_alv_event.

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
    if gt_grid-flg_no_toolbar is initial.
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
        create object gt_grid-grid
          exporting
            i_appl_events   = 'X'
            i_parent        = gt_grid-container
            i_fcat_complete = l_fcat_complete.
      else.
        create object gt_grid-splitter
          exporting
            parent  = gt_grid-container
            rows    = l_number_rows
            columns = 1.
        gt_grid-splitter->set_border( abap_false ).


        data: splitter_row_counter type i value 1.
*...Top-Of-List
        if gt_grid-flg_no_html is initial.
          gs_splitter_id-top_of_list = splitter_row_counter.
          call method gt_grid-splitter->get_container
            exporting
              row       = splitter_row_counter
              column    = 1
            receiving
              container = g_parent_html.
          add 1 to splitter_row_counter.
        endif.
*...Grid
        gs_splitter_id-grid = splitter_row_counter.
        call method gt_grid-splitter->get_container
          exporting
            row       = splitter_row_counter
            column    = 1
          receiving
            container = g_parent_grid.
        add 1 to splitter_row_counter.
        if gt_grid-flg_no_toolbar is initial.
          gs_splitter_id-toolbar = splitter_row_counter.
          call method gt_grid-splitter->get_container
            exporting
              row       = splitter_row_counter
              column    = 1
            receiving
              container = g_parent_toolbar.
          add 1 to splitter_row_counter.

          call method gt_grid-splitter->set_row_sash  " Splitter-Bar für
               exporting                       " Header ist fix
                  id     = gs_splitter_id-toolbar
                  type   = cl_gui_splitter_container=>type_movable
                  value  = cl_gui_splitter_container=>false
               exceptions
                  others = 99.

        endif.
*...End-Of-List
        if gt_grid-flg_no_html_end is initial.
          gs_splitter_id-end_of_list = splitter_row_counter.
          call method gt_grid-splitter->get_container
            exporting
              row       = splitter_row_counter
              column    = 1
            receiving
              container = g_parent_end.
          add 1 to splitter_row_counter.
        endif.

*...Splitter Size Calculation
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

*...add 1 for Toolbar
        data: l_height2 type int4.
        if gt_grid-flg_no_html eq abap_false.
          l_height2 = 23.
        else.
          l_height2  = 3.
        endif.
        call method gt_grid-splitter->set_row_height
          exporting
            id     = gs_splitter_id-toolbar
            height = l_height2.
        if gt_grid-flg_no_html is initial.
          call method gt_grid-splitter->set_row_height
            exporting
              id     = gs_splitter_id-top_of_list
              height = l_html_height_top.
        endif.
        if gt_grid-flg_no_html_end is initial.
          call method gt_grid-splitter->set_row_height
            exporting
              id     = gs_splitter_id-end_of_list
              height = l_html_height_end.
        endif.

        create object gt_grid-toolbar
          exporting
            i_appl_events   = abap_true
            i_parent        = g_parent_toolbar.

        types: begin of ys_button,
                 name    type string,
                 icon(4) type c,
                 text    type char40,
               end of ys_button.
        types: yt_button type table of ys_button.
        data: ls_button type ys_button.
        data: lt_button type yt_button.

        gt_grid-toolbar->add_button( fcode = cl_gui_alv_grid=>mc_fc_view_grid
                                     icon  = space          "'@3W@'
                                     butn_type = 0
                                     text  = text-vgr
                                   ).

        gt_grid-toolbar->add_button( fcode = cl_gui_alv_grid=>mc_fc_view_excel
                                     icon  = space          "'@J2@'
                                     butn_type = 0
                                     text  = text-vex
                                   ).
        gt_grid-toolbar->add_button( fcode = cl_gui_alv_grid=>mc_fc_view_crystal
                                     icon  = space "'@QH@'
                                     butn_type = 0
                                     text  = text-vcr
                                   ).
        gt_grid-toolbar->add_button( fcode = cl_gui_alv_grid=>mc_fc_graph
                                     icon  = space          "'@0N@'
                                     butn_type = 0
                                     text  = text-vgc
                                   ).

        create object gt_grid-grid
          exporting
            i_appl_events   = 'X'
            i_parent        = g_parent_grid
            i_fcat_complete = l_fcat_complete.

*...Fullscreen Adapter
        create object gr_fullscreen exporting
                     r_grid = gt_grid-grid
                     r_toolbar = gt_grid-toolbar.

      endif.

      if gt_grid-lvc is initial.
        perform transfer_slis_to_lvc.
      else.
        perform transfer_lvc_to_lvc.
      endif.

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
*        ls_reprep_id = is_reprep_id_lvc.
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
      perform raise_top_of_list.

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
    field-symbols: <t_cntrl> type table.

    call function 'GET_ACCESSIBILITY_MODE'
      importing
        accessibility     = l_accessibility_mode
      exceptions
        its_not_available = 0
        others            = 0.

    if l_accessibility_mode eq abap_true
        and gt_grid-splitter is bound
        and not gt_grid-splitter->children is initial.

      assign gt_grid-splitter->children to <t_cntrl>.
      read table <t_cntrl> index 1 into lr_focus_container.
    else.
      lr_focus_container = gt_grid-grid.
    endif.

    if not ( gt_grid-flg_popup eq abap_false
    and l_accessibility_mode eq abap_true ).
      call method cl_gui_control=>set_focus
        exporting
          control = lr_focus_container.
    endif.

    if g_form_pf_status_executed eq abap_false.
      perform pf_status_set using gt_grid-flg_popup.
    endif.
  else.

    if gt_grid-grid is initial.
      create object gt_grid-grid
        exporting
          i_parent        = g_parent_grid
          i_fcat_complete = l_fcat_complete.

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
*        ls_reprep_id = is_reprep_id_lvc.
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

endform.                               " PBOendform.                    " PBO_WITH_ADDITIONAL_TOOLBAR
