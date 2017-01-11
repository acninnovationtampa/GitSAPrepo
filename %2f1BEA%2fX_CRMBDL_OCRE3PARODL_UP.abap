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
    PERFORM PARODL_DLZ_PARTNER_DELETE
      USING
        US_ITC
      CHANGING
        LS_DLI_WRK.
    PERFORM PARODL_CRZ_PARTNER_FILL
      USING
        UT_PARTNER
        US_ITC
        US_DLI_WRK
      CHANGING
        LS_DLI_WRK
        LT_RETURN
        LV_RETURNCODE.
    IF NOT LV_RETURNCODE IS INITIAL.
      IF LS_DLI_WRK-INCOMP_ID IS INITIAL.
        LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
      ENDIF.
    ENDIF.
