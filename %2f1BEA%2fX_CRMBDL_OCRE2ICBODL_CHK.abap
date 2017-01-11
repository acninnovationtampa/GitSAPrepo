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
*     Intercompany process active and Intercompany item given?
    PERFORM ICBODL_CHZ_INTERCOMPANY_CHECK
      USING
        LS_DLI_WRK
      CHANGING
        LS_DLI_WRK
        CT_RETURN
        LV_RETURNCODE.
