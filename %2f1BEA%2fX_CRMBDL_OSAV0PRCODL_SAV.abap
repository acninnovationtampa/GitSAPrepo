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
* Save Pricing Data
*--------------------------------------------------------------------

  DATA: LT_DLI_FAULT TYPE /1BEA/T_CRMB_DLI_WRK.

    CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_SAVE'
      EXPORTING
        IT_DLI       = GT_DLI_WRK
      IMPORTING
        ET_DLI_FAULT = LT_DLI_FAULT.

    IF NOT LT_DLI_FAULT IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_DL_O_BUFFER_MODIFY'
        EXPORTING
          IT_DLI_WRK   = LT_DLI_FAULT
          IV_INCOMP_ID = GC_INCOMP_FATAL.
    ENDIF.
