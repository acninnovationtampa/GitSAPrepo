*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  tree_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tree_exit .
*>>> new API
*  if sy-uname ne 'GRUBERJ'.
    perform salv_get_metadata_tree.
    perform salv_get_selections_tree.
*  endif.
*<<< new API

  call method gt_tree-r_container->free.
  call method cl_gui_cfw=>flush.

  set screen 0.
  leave screen.
ENDFORM.                    " tree_exit
