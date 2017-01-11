*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF03 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SALV_PF_STATUS_SET
*&---------------------------------------------------------------------*
*       PF Status Handling for Customer API
*----------------------------------------------------------------------*
form salv_pf_status_set using rt_extab type kkblo_t_extab.  "#EC CALLED

  data: lr_events type ref to if_salv_events_adapter.

  data: l_report   type syrepid,
        l_pfstatus type sypfkey.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
    lr_events ?= gt_grid-r_salv_fullscreen_adapter.
  endtry.

*force refresh  "Y7AK006860
  data: lr_controller type ref to cl_salv_controller_list.
  data: ls_changelist type if_salv_controller_changelist=>salv_s_changelist.

  lr_controller ?= gt_grid-r_salv_fullscreen_adapter->r_controller.
  ls_changelist-flavour = cl_salv_controller_model=>c_functions.
  append ls_changelist to lr_controller->t_changelist.

  lr_events->raise_build_uifunction(
    changing
      pfstatus = l_pfstatus
      report   = l_report
      t_extab  = rt_extab[] ).

  perform adapt_excluding_tab changing rt_extab[].

  set pf-status l_pfstatus excluding rt_extab[] of program l_report.

*>>AT
  perform salv_at_functions using l_pfstatus l_report rt_extab[].
*<<AT

endform.                    " SALV_PF_STATUS_SET

*&---------------------------------------------------------------------*
*&      Form  SALV_USER_COMMAND
*&---------------------------------------------------------------------*
*       PF Status Handling for Customer API
*----------------------------------------------------------------------*
*  <-->  rt_extab type kkblo_t_extab
*----------------------------------------------------------------------*
form salv_user_command using r_ucomm     type sy-ucomm
                             rs_selfield type slis_selfield."#EC CALLED

  data: l_function type salv_de_function.
  data: lr_events type ref to if_salv_events_adapter.
  data: l_row type salv_de_row.
  data: l_column type salv_de_column.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
    lr_events ?= gt_grid-r_salv_fullscreen_adapter.
  endtry.

  l_row    = rs_selfield-tabindex.
  l_column = rs_selfield-fieldname.

  case r_ucomm.
    when '&IC1'.
      lr_events->raise_double_click( row    = l_row
                                     column = l_column ).
    when '&IC2'.
      lr_events->raise_hotspot_click( row    = l_row
                                      column = l_column ).
    when others.
      l_function = cl_salv_controller_metadata=>get_function_from_slis_fcode( r_ucomm ).
      if l_function is initial.
        if rs_selfield-before_action is initial and
           rs_selfield-after_action is initial.
          lr_events->raise_added_function( r_ucomm ).
        endif.
      else.
        if rs_selfield-before_action eq 'X'.
          lr_events->raise_before_salv_function( r_ucomm ).
        endif.

        if rs_selfield-after_action eq 'X'.
          lr_events->raise_after_salv_function( r_ucomm ).
        endif.
      endif.
  endcase.

  perform salv_get_refresh_mode changing rs_selfield.
  rs_selfield-exit = gt_grid-r_salv_fullscreen_adapter->close_screen.

endform.                    " SALV_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  SALV_TOP_OF_LIST
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form salv_top_of_list.                                      "#EC CALLED

  data: lr_salv_events_adapter type ref to if_salv_events_adapter.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
      lr_salv_events_adapter ?= gt_grid-r_salv_fullscreen_adapter.
    catch cx_sy_assign_cast_illegal_cast.
      exit.
  endtry.

  case g_is_online_event.
    when if_salv_c_bool_sap=>true.
      lr_salv_events_adapter->raise_top_of_list( ).
    when if_salv_c_bool_sap=>false.
      lr_salv_events_adapter->raise_top_of_list_print( ).
  endcase.

  clear g_is_online_event.

endform.                    " SALV_TOP_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  SALV_END_OF_LIST
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form salv_end_of_list.                                      "#EC CALLED

  data: lr_salv_events_adapter type ref to if_salv_events_adapter.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
      lr_salv_events_adapter ?= gt_grid-r_salv_fullscreen_adapter.
    catch cx_sy_assign_cast_illegal_cast.
      exit.
  endtry.

  case g_is_online_event.
    when if_salv_c_bool_sap=>true.
      lr_salv_events_adapter->raise_end_of_list( ).
    when if_salv_c_bool_sap=>false.
      lr_salv_events_adapter->raise_end_of_list_print( ).
  endcase.

  clear g_is_online_event.

endform.                    " SALV_TOP_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  SALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form salv_top_of_page using i_table_index type syindex.     "#EC CALLED

  data: lr_salv_events_adapter type ref to if_salv_events_adapter.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
      lr_salv_events_adapter ?= gt_grid-r_salv_fullscreen_adapter.
    catch cx_sy_assign_cast_illegal_cast.
      exit.
  endtry.

  lr_salv_events_adapter->raise_top_of_page(
    table_index = i_table_index
    page        = sy-pagno ).

endform.                    " SALV_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  SALV_END_OF_PAGE
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form salv_end_of_page.                                      "#EC CALLED

  data: lr_salv_events_adapter type ref to if_salv_events_adapter.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  try.
      lr_salv_events_adapter ?= gt_grid-r_salv_fullscreen_adapter.
    catch cx_sy_assign_cast_illegal_cast.
      exit.
  endtry.

  lr_salv_events_adapter->raise_end_of_page( ).

endform.                    " SALV_END_OF_PAGE

*&--------------------------------------------------------------------*
*&      Form  salv_get_metadata
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form salv_get_metadata.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  gt_grid-r_salv_fullscreen_adapter->if_salv_adapter~get_metadata( ).

endform.                    "salv_get_metadata

*&--------------------------------------------------------------------*
*&      Form  salv_get_metadata_tree
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form salv_get_metadata_tree.

  check gt_tree-r_salv_tree_adapter is bound.

  gt_tree-r_salv_tree_adapter->if_salv_adapter~get_metadata( ).

endform.                    "salv_get_metadata

*&---------------------------------------------------------------------*
*&      Form  salv_set_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form salv_set_selections .

  check gt_grid-r_salv_fullscreen_adapter is bound.

  data: is_selected type sap_bool.

  is_selected =
    cl_salv_controller_selections=>set_selections( gt_grid-r_salv_fullscreen_adapter->r_controller ).

* flush ist unnötig ? Es konnte keine Fehlanzeige der Selectionen gefunden werden
*  if is_selected eq abap_true.
*    cl_gui_cfw=>flush( ).
*  endif.
endform.                    " salv_set_selections

*&--------------------------------------------------------------------*
*&      Form  salv_get_selections
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form salv_get_selections.

  check gt_grid-r_salv_fullscreen_adapter is bound.

* to avoid getting the selected cells (causing a frontend call),
* add an changelist entry for them
  gt_grid-r_salv_fullscreen_adapter->r_controller->set_changed(
    name    = 'EXIT'
    method  = 'SET_SELECTED_CELLS'
    object  = if_salv_controller_changelist=>c_selection_cells
*    ref     =
    flavour = if_salv_c_changelist_flavour=>selections ).

********************************************************************

  cl_salv_controller_selections=>get_selections( gt_grid-r_salv_fullscreen_adapter->r_controller ).

endform.                    "salv_get_selections

*&--------------------------------------------------------------------*
*&      Form  salv_set_selmode
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form salv_set_selmode changing cs_layout type lvc_s_layo.

  data: lr_display type ref to if_salv_display_adapter.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  cs_layout-grid_title = SPACE.

  try.
      lr_display ?= gt_grid-r_salv_fullscreen_adapter.
      case lr_display->get_selection_mode( ).
        when if_salv_c_selection_mode=>single.
          cs_layout-sel_mode = 'B'.
        when if_salv_c_selection_mode=>multiple.
          cs_layout-sel_mode = 'C'.
        when if_salv_c_selection_mode=>row_column.
          cs_layout-sel_mode = 'A'.
        when if_salv_c_selection_mode=>cell.
          cs_layout-sel_mode = 'D'.
      endcase.
    catch cx_sy_move_cast_error.
      exit.
  endtry.

endform.                    "salv_set_selmode

*&---------------------------------------------------------------------*
*&      form  salv_get_refresh_mode
*&---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form salv_get_refresh_mode changing cs_selfield type slis_selfield.

  check gt_grid-r_salv_fullscreen_adapter is bound.

  case gt_grid-r_salv_fullscreen_adapter->refresh_mode.
    when if_salv_c_refresh=>none.

    when if_salv_c_refresh=>soft.
      if cs_selfield-refresh is initial.
        cs_selfield-refresh    = 'S'.
      endif.

    when if_salv_c_refresh=>full.
      if cs_selfield-refresh ne 'X'.
        cs_selfield-refresh    = 'X'.
      endif.
  endcase.

  clear gt_grid-r_salv_fullscreen_adapter->refresh_mode.

  if cs_selfield-col_stable is initial.
    cs_selfield-col_stable = gt_grid-r_salv_fullscreen_adapter->s_stable-col.
  endif.

  if cs_selfield-row_stable is initial.
    cs_selfield-row_stable = gt_grid-r_salv_fullscreen_adapter->s_stable-row.
  endif.

  clear gt_grid-r_salv_fullscreen_adapter->s_stable.

endform.                    " salv_get_refresh_mode
