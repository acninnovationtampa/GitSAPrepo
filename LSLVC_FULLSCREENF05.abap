*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  tree_pai
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tree_pai .

  data: l_subrc like sy-subrc.

  data: l_okcode type sy-ucomm.

  l_okcode = ok_code.
  clear ok_code.

  check l_okcode ne space.

  g_repid = sy-repid.

  case l_okcode.
    when '&F03'.
      perform tree_exit.
    when '&F12'.
      perform tree_exit.
    when '&F15'.
      perform tree_exit.
    when '&PRT_VIEW'.
      l_okcode = CL_ALV_TREE_BASE=>MC_FC_PRINT_BACK.
    when '&PRT_PREV'.
      l_okcode = CL_ALV_TREE_BASE=>MC_FC_PRINT_PREV.
    when '&PRT_ALL'.
      l_okcode = CL_ALV_TREE_BASE=>MC_FC_PRINT_BACK_ALL.
    when '&PRT_ALL_P'.
      l_okcode = CL_ALV_TREE_BASE=>MC_FC_PRINT_PREV_ALL.
  endcase.


  clear g_temp_ok_code.

  gt_tree-r_salv_tree_adapter->set_function_code( l_okcode ).
*    if not gt_grid-s_layout-f2code is initial and
*      l_okcode eq '&IC1'.
*      l_okcode = gt_grid-s_layout-f2code.
*    endif.

*    if l_okcode eq '&F15' or
*       l_okcode eq '&F03' or
*       l_okcode eq '&F12'.
*
*      read table it_event_exit into ls_event_exit
*                               with key ucomm = l_okcode.
*      if sy-subrc = 0.
*        g_before = 'X'.
*        perform user_command using l_okcode lflg_refresh lflg_exit
*                                   ls_stable.
*        clear g_before.
*      endif.
*    endif.

  clear l_okcode.

ENDFORM.                    " tree_pai
