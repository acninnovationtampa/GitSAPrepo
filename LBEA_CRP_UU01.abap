FUNCTION bea_crp_u_show.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IT_CRP) TYPE  BEAT_CRP
*"     REFERENCE(IV_MODE) TYPE  BEA_CRP_MODE DEFAULT 'A'
*"     REFERENCE(IV_SHOW_HEAD) TYPE  CHAR1 DEFAULT SPACE
*"     REFERENCE(IV_TOOLBAR) TYPE  CHAR1 DEFAULT 'X'
*"----------------------------------------------------------------------
***********************************************************************
* Transfer Data in Global Variables
***********************************************************************
  gt_crp = it_crp.
  gv_show_head  = iv_show_head.
  gv_toolbar    = iv_toolbar.
  gv_mode       = iv_mode.
*----------------------------------------------------------------------
* Check if any Collective Runs are given
*----------------------------------------------------------------------
  IF gt_crp IS INITIAL.
    MESSAGE s159(bea).
    RETURN. "from function module
  ENDIF.
***********************************************************************
* Call Underlying Dynpro
***********************************************************************
  CALL SCREEN 0100.
ENDFUNCTION.
