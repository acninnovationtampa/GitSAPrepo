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
  IF CS_DLI_INT-BILL_RELEVANCE_C = GC_BILL_REL_ORDER_IC OR
     CS_DLI_INT-BILL_RELEVANCE_C = GC_BILL_REL_DELIV_IC.
*   for compatability reason:
*   handle derived items with initial derivation category
    IF LV_UPD_DRV = GC_FALSE.
      LS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA.
      MODIFY GT_DLI_DOC FROM LS_DLI_WRK TRANSPORTING DERIV_CATEGORY
                       WHERE BILL_CATEGORY  = GC_BILL_CAT_INT
                         AND INDICATOR_IC   = GC_TRUE
                         AND DERIV_CATEGORY = SPACE.
      LV_UPD_DRV = GC_TRUE.
    ENDIF.
  ENDIF.
