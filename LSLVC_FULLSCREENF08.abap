*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  globals_tree_pop
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM globals_tree_pop .
* this read is absolutly necessary to fill the table header
  read table gt_tree index 1.
*
  delete gt_tree index 1.
ENDFORM.                    " globals_tree_pop
