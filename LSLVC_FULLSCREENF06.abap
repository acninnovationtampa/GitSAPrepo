*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  tree_pbo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tree_pbo .

    gt_tree-r_container->set_visible( abap_true ).

    gt_tree-first_time = abap_false.

  perform salv_tree_pf_status_set.

  data: l_title type string.

  set titlebar '003' of program 'SAPLKKBL' with gt_tree-title.

ENDFORM.                    " tree_pbo
