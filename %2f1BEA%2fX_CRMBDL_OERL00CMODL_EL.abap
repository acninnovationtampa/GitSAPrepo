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

  MOVE LS_DLI_WRK-BILL_DATE TO LS_DLI_COM-BILL_DATE_C.
  MOVE LS_DLI_WRK-BILL_RELEVANCE TO LS_DLI_COM-BILL_RELEVANCE_C.
  MOVE LS_DLI_WRK-CREDIT_DEBIT TO LS_DLI_COM-CREDIT_DEBIT_C.
  MOVE LS_DLI_WRK-BILL_ORG TO LS_DLI_COM-BILL_ORG_C.
  MOVE LS_DLI_WRK-PAYER TO LS_DLI_COM-PAYER_C.
  MOVE LS_DLI_WRK-TERMS_OF_PAYMENT TO LS_DLI_COM-TERMS_OF_PMNT_C.
  IF LS_DLI_WRK-INDICATOR_IC = GC_DERIV_IC_REF_YES.
    MOVE LS_DLI_WRK-INDICATOR_IC TO LS_DLI_COM-INDICATOR_IC_C.
  ENDIF.

