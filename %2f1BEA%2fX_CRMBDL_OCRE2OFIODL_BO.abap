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
    PERFORM OFIODL_BOZ_BILL_ORG_FILL
      USING
        US_DLI_INT
        UT_PARTNER
        CS_ITC
      CHANGING
        LS_DLI_WRK
        CT_RETURN
        LV_RETURNCODE.
