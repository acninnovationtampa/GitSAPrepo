*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================
*--------------------------------------------------------------------
* Refresh condition data
*--------------------------------------------------------------------
  IF NOT iv_with_services IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_ICX_O_REFRESH'.
  ENDIF.
