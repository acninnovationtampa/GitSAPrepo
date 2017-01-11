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
    CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_DELETE'
         EXPORTING
           IS_DLI = LS_DLI_WRK
           IS_ITC = US_ITC.              "#EC ENHOK
    PERFORM TXTODL_CRZ_TEXT_FILL
      USING
        UT_TEXTLINE
        US_ITC
      CHANGING
        LS_DLI_WRK
        LT_RETURN
        LV_RETURNCODE.
      IF NOT LV_RETURNCODE IS INITIAL.
        IF LS_DLI_WRK-INCOMP_ID IS INITIAL.
          LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
        ENDIF.
      ENDIF.
