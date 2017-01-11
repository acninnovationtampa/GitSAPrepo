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
* Refresh Partner Data
*--------------------------------------------------------------------
  IF NOT iv_with_services IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_REFRESH'
         EXPORTING
              IT_DLI = GT_DLI_WRK.
  ENDIF.
