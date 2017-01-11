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
    PERFORM PARODL_CRZ_PARTNER_FILL
      USING
        UT_PARTNER
        CS_ITC
        LS_DLI_NV
      CHANGING
        LS_DLI_WRK
        CT_RETURN
        LV_RETURNCODE.
