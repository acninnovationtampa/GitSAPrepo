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
  LV_READ_BY_INT_ID = GC_FALSE.
  IF NOT CS_DLI_INT-SRC_GUID IS INITIAL.
    LV_READ_BY_INT_ID = GC_TRUE.
    IF CS_DLI_INT-BILL_RELEVANCE_C <> GC_BILL_REL_LEAN AND
       CS_DLI_INT-BILL_RELEVANCE_C <> GC_BILL_REL_BILLREQ_I.
      LOOP AT GT_DLI_DOC INTO LS_DLI_WRK WHERE
                       DERIV_CATEGORY = CS_DLI_INT-DERIV_CATEGORY AND
                       SRC_GUID       = CS_DLI_INT-SRC_GUID.
        INSERT LS_DLI_WRK INTO TABLE LT_DLI_WRK.
      ENDLOOP.
    ENDIF.
  ENDIF.
