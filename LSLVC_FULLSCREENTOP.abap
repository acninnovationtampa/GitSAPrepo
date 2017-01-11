function-pool slvc_fullscreen.         "MESSAGE-ID ..
type-pools: kkblo.
* Dummy-Typdefinition : Kann entfernt werden falls es ohne diese
* Zeile nicht mehr zu einem Syntaxfehler kommt.
types dummy type ref to cl_gui_html_viewer.
types:
      begin of grid,
        repid type sy-repid,
        grid  type ref to cl_gui_alv_grid,
        toolbar type ref to CL_GUI_RU_ALV_TOOLBAR,
        lvc(1) type c,
        r_form_tol type ref to cl_salv_form_dydos,
        r_form_eol type ref to cl_salv_form_dydos,
        top type ref to cl_dd_document,
        bottom type ref to cl_dd_document,
        html_cntrl type ref to cl_gui_html_viewer,
        html_cntrl_bottom type ref to cl_gui_html_viewer,
        splitter type ref to cl_gui_splitter_container,
        container type ref to cl_gui_custom_container,
        i_callback_program       type  sy-repid,
        i_callback_pf_status_set type  slis_formname,
        i_callback_user_command  type  slis_formname,
        i_callback_top_of_page   type  slis_formname,
        i_callback_end_of_page   type  slis_formname,
        i_callback_html_top_of_page type  slis_formname,
        i_callback_html_end_of_list type  slis_formname,
        i_callback_subtotal_text type  slis_formname,
        i_callback_caller_exit type  slis_formname,
        i_callback_data_changed type  slis_formname,
        i_callback_top_of_list type slis_formname,
        i_callback_end_of_list type slis_formname,
        i_callback_context_menu type slis_formname,         "B20K8A0YFV
        t_fieldcat  type kkblo_t_fieldcat,
        t_fieldcat1 type kkblo_t_fieldcat,
        t_add_fieldcat type lvc_t_fc2,
        t_excluding type kkblo_t_extab,
        t_excluding_lvc type ui_functions,
        t_special_groups type kkblo_t_sp_group,
        t_sort      type kkblo_t_sortinfo,
        t_filter    type kkblo_t_filter,
        t_qinfo     type kkblo_t_qinfo,
        t_event_exit type kkblo_t_event_exit,
        s_variant    type disvariant,
        s_variant_save type disvariant,
        s_layout type kkblo_layout,
        t_lvc_fieldcat type lvc_t_fcat,
        t_lvc_spec     type lvc_t_sgrp,
        t_lvc_sort     type lvc_t_sort,
        t_lvc_filter   type lvc_t_filt,
        t_lvc_qinfo type lvc_t_qinf,
        t_lvc_hyperlink type lvc_t_hype,
        t_alv_graphics type dtc_t_tc,
        s_lvc_layout   type lvc_s_layo,
        s_lvc_print    type lvc_s_prnt,
        s_sel_hide     type slis_sel_hide_alv,
        flg_popup(1) type c,
        flg_called(1) type c,
        flg_no_html(1) type c,
        flg_no_html_end(1) type c,
        flg_no_toolbar(1) type c,
        flg_first_time(1) type c,
        flg_very_first_time(1) type c,
        flg_complex(1) type c,
        t_fccls  type c occurs 0,
        t_extab type kkblo_extab,
        r_salv_fullscreen_adapter type ref to
                          cl_salv_fullscreen_adapter,
      end of grid.

types: begin of tree,
         first_time type abap_bool,
         popup type abap_bool,
         title type string,
         r_container type ref to cl_gui_container,
         r_salv_tree_adapter type ref to cl_salv_fullscreen_tree_adapte,
       end of tree.

types     : begin of ys_splitter_id,
              grid        type int4,
              end_of_list type int4,
              top_of_list type int4,
              toolbar     type int4,
            end of ys_splitter_id.

data: gs_splitter_id type ys_splitter_id.


data: gt_grid type grid occurs 0 with header line.
data: gt_tree type tree occurs 0 with header line.
data: ok_code type sy-ucomm,
      g_temp_ok_code type sy-ucomm,
      g_repid like sy-repid,            "#EC NEEDED    " Function Group
      mycontainer type scrfname value 'GRID1'.

data: g_before(1) type c,
      g_after(1) type c.

data: mr_trace   type ref to cl_alv_trace,
      mr_variant type ref to cl_alv_variant.

*>>> new API
data: g_is_online_event type sap_bool.
data: g_badi_instance_exit type i.
data: g_exit type ref to IF_EX_ALV_SWITCH_GRID_TO_LIST.
*<<< new API

data: gr_fullscreen type ref to cl_alv_rm_fullscreen_model.
data: g_form_pf_status_executed type abap_bool.
data: go_alv_gui_data_source type ref to if_alv_gui_data_source.

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
class lcl_event_receiver definition.
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
  public section.

    interfaces IF_ALV_RM_GRID_FRIEND.
    methods register_event
      importing
        r_grid      type ref to cl_gui_alv_grid
        event_name  type string
        activation  type abap_bool.

    methods handle_user_command
      for event user_command of cl_gui_alv_grid
      importing e_ucomm.
    methods handle_before_user_command
      for event before_user_command of cl_gui_alv_grid
      importing e_ucomm.
    methods handle_data_changed
      for event data_changed of cl_gui_alv_grid
      importing er_data_changed.
    methods handle_after_user_command
      for event after_user_command of cl_gui_alv_grid
      importing e_ucomm.
    methods handle_double_click
      for event double_click of cl_gui_alv_grid
      importing e_row e_column.
    methods handle_hotspot_click
      for event hotspot_click of cl_gui_alv_grid
      importing e_row_id e_column_id.
    methods handle_top_of_list
      for event print_top_of_list of cl_gui_alv_grid.
    methods handle_end_of_list
      for event end_of_list of cl_gui_alv_grid
      importing e_dyndoc_id.
    methods handle_end_of_page
      for event print_end_of_page of cl_gui_alv_grid.
    methods handle_print_end_of_list
      for event print_end_of_list of cl_gui_alv_grid.
    methods handle_top_of_page
      for event top_of_page of cl_gui_alv_grid
      importing e_dyndoc_id table_index.
    methods handle_print_top_of_page
      for event print_top_of_page of cl_gui_alv_grid
      importing table_index.
    methods handle_after_refresh
      for event after_refresh of cl_gui_alv_grid.
    methods handle_subtotal_text
      for event subtotal_text of cl_gui_alv_grid
      importing es_subtottxt_info
                e_event_data
                ep_subtot_line.
    methods use_new_resources
      for event resources_changed of cl_gui_resources.
    methods context_menu_request
      for event context_menu_request of cl_gui_alv_grid
      importing e_object.

  private section.

    methods handle_before_refresh
      for event _before_refresh of cl_gui_alv_grid.

endclass.                    "lcl_event_receiver DEFINITION

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
class lcl_event_receiver implementation.
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
  method handle_before_refresh.
    perform pf_status_set using gt_grid-flg_popup.
*>>> Y3YK043656
    data: ls_layout type lvc_s_layo.
    gt_grid-grid->get_frontend_layout( importing es_layout = ls_layout ).
    if ls_layout-frontend eq cl_alv_bds=>mc_crystal_frontend.
      perform raise_top_of_list.
    endif.
*<<< Y3YK043656
  endmethod.
  method register_event.
    set handler me->handle_before_refresh for r_grid activation activation.
  endmethod.
*
  method handle_user_command.
    perform method_user_command using e_ucomm.
  endmethod.                    "handle_user_command
*
  method handle_before_user_command.
    if e_ucomm ne '&F12'.
      perform marks_save using e_ucomm.
    endif.

    g_before = 'B'.
    perform event_exit_check using e_ucomm
                                   g_before.
    if g_before = 'X'.
      perform method_user_command using e_ucomm.
    endif.
    clear g_before.
  endmethod.                    "handle_before_user_command
*
  method handle_after_user_command.
    g_after = 'A'.
    perform event_exit_check using e_ucomm
                                   g_after.
    if g_after = 'X'.
      perform method_user_command using e_ucomm.
    endif.

    if not gt_grid-i_callback_top_of_page is initial.
      call method gt_grid-grid->list_processing_events
        exporting
          i_event_name = 'TOP_OF_PAGE'
          i_dyndoc_id  = gt_grid-top.
    endif.
    if not gt_grid-i_callback_end_of_list is initial.
      call method gt_grid-grid->list_processing_events
        exporting
          i_event_name = 'END_OF_LIST'
          i_dyndoc_id  = gt_grid-bottom.
    endif.

*>>> new API
    perform salv_set_selections.
*<<< new API

    clear g_after.
  endmethod.                    "handle_after_user_command
*
  method handle_data_changed.
    perform method_data_changed using er_data_changed.
  endmethod.                    "handle_data_changed
*
  method handle_top_of_page.
    perform method_top_of_page using e_dyndoc_id table_index.
  endmethod.                    "handle_top_of_page
*
  method handle_top_of_list.
    perform method_top_of_list.
  endmethod.                    "handle_end_of_list
*
  method handle_end_of_list.
    perform method_end_of_list using e_dyndoc_id.
  endmethod.                    "handle_end_of_list
*
  method handle_end_of_page.
    perform method_end_of_page.
  endmethod.                    "handle_end_of_page
*
  method handle_print_top_of_page.
    perform method_print_top_of_page using table_index.
  endmethod.                    "handle_print_top_of_page
*
  method handle_print_end_of_list.
    perform method_print_end_of_list.
  endmethod.                    "handle_print_end_of_list
*
  method handle_after_refresh.
    perform method_after_refresh.
  endmethod.                    "handle_after_refresh
*
  method handle_subtotal_text.
    perform method_subtotal_text using es_subtottxt_info
                                       e_event_data
                                       ep_subtot_line.
  endmethod.                    "handle_subtotal_text
*
  method handle_double_click.
    perform method_double_click using g_temp_ok_code.
  endmethod.                    "handle_double_click

  method handle_hotspot_click.
    perform method_hotspot_click.
  endmethod.                    "handle_hotspot_click

  method use_new_resources.
    perform method_use_new_resources.
  endmethod.                    "use_new_resources

  method context_menu_request.
    perform context_menu_request using e_object.
  endmethod.                    "context_menu_request

endclass.                    "lcl_event_receiver IMPLEMENTATION
*
data: gc_event_receiver type ref to lcl_event_receiver.
data: g_parent_grid type ref to cl_gui_container,
      g_parent_html type ref to cl_gui_container,
      g_parent_toolbar type ref to cl_gui_container,
      g_parent_end  type ref to cl_gui_container.
* BRP, 17,1,00 used in forms html, html_bottom
data: my_receiver type ref to lcl_event_receiver.
