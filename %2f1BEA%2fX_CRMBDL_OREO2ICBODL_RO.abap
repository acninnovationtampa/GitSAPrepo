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
*   for compatability reason:
*   handle derived items with initial derivation category
  IF CS_DLI-BILL_CATEGORY  = GC_BILL_CAT_INT AND
     CS_DLI-INDICATOR_IC   = GC_DERIV_IC_YES AND
     CS_DLI-DERIV_CATEGORY = SPACE.
    CS_DLI-DERIV_CATEGORY = GC_DERIV_ORGDATA.
  ENDIF.
