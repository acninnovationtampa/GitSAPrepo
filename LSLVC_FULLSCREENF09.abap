*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF09 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  salv_tree_pf_status_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM salv_tree_pf_status_set..

  data: lr_events type ref to if_salv_events_adapter,
        lt_extab type kkblo_t_extab.

  data: l_report   type syrepid,
        l_pfstatus type sypfkey.

  check gt_tree-r_salv_tree_adapter is bound.

  gt_tree-r_salv_tree_adapter->build_uifunction(
    changing
      pfstatus = l_pfstatus
      report   = l_report
      t_extab  = lt_extab[] ).

  perform adapt_excluding_tree_tab changing lt_extab[].

  set pf-status l_pfstatus excluding lt_extab[] of program l_report.


ENDFORM.                    " salv_tree_pf_status_set
