*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF07 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  globals_tree_push
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM globals_tree_push .
  gt_tree-r_container = gt_tree-r_salv_tree_adapter->r_tree->parent.

  data: lr_settings type ref to cl_salv_tree_settings,
        lr_tree type ref to cl_salv_tree.
  lr_tree ?= gt_tree-r_salv_tree_adapter->r_controller->r_model.
  lr_settings = lr_tree->get_tree_settings( ).
  gt_tree-title = lr_settings->get_header( ).
ENDFORM.                    " globals_tree_push
