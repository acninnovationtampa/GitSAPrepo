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
  IF NOT GS_SRV_PREPARED-txt IS INITIAL.
    CALL FUNCTION 'BEA_TXT_O_RESET_UI'
      EXPORTING
        it_struc    = gt_dli_det
        iv_tdobject = gc_dli_txtobj
        iv_typename = gc_typename_dli_wrk
     EXCEPTIONS
        error       = 0
        OTHERS      = 0.
  ENDIF.
