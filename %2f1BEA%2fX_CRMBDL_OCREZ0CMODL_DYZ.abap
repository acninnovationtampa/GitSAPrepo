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
* -------------------------------------------------------------
* FORM MOVE_INT_TO_WRK
* -------------------------------------------------------------
* Fill WRK structure from INT structure
* -------------------------------------------------------------
FORM MOVE_INT_TO_WRK
  USING
    US_DLI_INT TYPE /1BEA/S_CRMB_DLI_INT
  CHANGING
    CS_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK.

  CHECK NOT US_DLI_INT IS INITIAL.
  MOVE US_DLI_INT-BILL_DATE_C TO CS_DLI_WRK-BILL_DATE.
  IF CS_DLI_WRK-BILL_DATE IS INITIAL.
    MOVE SY-DATLO TO CS_DLI_WRK-BILL_DATE.
  ENDIF.
  IF US_DLI_INT-INVCR_DATE IS INITIAL.
    MOVE CS_DLI_WRK-BILL_DATE TO CS_DLI_WRK-INVCR_DATE.
  ENDIF.
  MOVE US_DLI_INT-BILL_RELEVANCE_C TO CS_DLI_WRK-BILL_RELEVANCE.
  MOVE US_DLI_INT-CREDIT_DEBIT_C TO CS_DLI_WRK-CREDIT_DEBIT.
  IF NOT US_DLI_INT-BILL_ORG_C IS INITIAL.
    MOVE US_DLI_INT-BILL_ORG_C TO CS_DLI_WRK-BILL_ORG.
  ENDIF.
  MOVE US_DLI_INT-INDICATOR_IC_C TO CS_DLI_WRK-INDICATOR_IC.
  IF NOT US_DLI_INT-SRC_BILL_BLOCK IS INITIAL.
    MOVE GC_BILLBLOCK_EXTERN TO CS_DLI_WRK-BILL_BLOCK.
  ENDIF.
  IF NOT US_DLI_INT-PAYER_C IS INITIAL.
    MOVE US_DLI_INT-PAYER_C TO CS_DLI_WRK-PAYER.
  ENDIF.
  MOVE US_DLI_INT-TERMS_OF_PMNT_C TO CS_DLI_WRK-TERMS_OF_PAYMENT.
ENDFORM.
