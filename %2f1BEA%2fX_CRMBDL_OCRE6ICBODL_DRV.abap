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
*--------------------------------------------------------------------*
* Include           BETX_ICBODL_DRV                                  *
*--------------------------------------------------------------------*
  IF IV_DERIV_CATEGORY IS INITIAL OR
     IV_DERIV_CATEGORY = GC_DERIV_ORGDATA.
    PERFORM ICBODL_DRZ_DERIVE_INTERCOMPANY
      USING
        IS_DLI_INT
        IS_DLI_WRK
        IT_CONDITION
        IT_PARTNER
        IT_TEXTLINE
      CHANGING
        ET_DLI_WRK
        LT_RETURN.
  ENDIF.
