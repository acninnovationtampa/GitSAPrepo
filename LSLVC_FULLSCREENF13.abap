*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF13 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  salv_get_selections_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form salv_get_selections_tree .

  check gt_tree-r_salv_tree_adapter is bound.

  cl_salv_controller_selections=>get_selections( gt_tree-r_salv_tree_adapter->r_controller ).


endform.                    " salv_get_tree_selections
