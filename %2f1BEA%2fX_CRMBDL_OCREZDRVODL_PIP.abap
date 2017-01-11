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
* Include           BETX_DRVODL_PIP                                  *
*--------------------------------------------------------------------*
*---------------------------------------------------------------------
*       FORM PREPARE_INT_FROM_PREDECESSOR
*---------------------------------------------------------------------
FORM DRVODL_PIP_PREP_INT_FORM_PRE
  USING
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_INT     TYPE /1BEA/S_CRMB_DLI_INT.

  MOVE US_DLI_WRK-BILL_DATE TO CS_DLI_INT-BILL_DATE_C.
  MOVE: US_DLI_WRK-PRC_INDICATOR TO CS_DLI_INT-PRC_INDICATOR,
        US_DLI_WRK-EXCHANGE_DATE TO CS_DLI_INT-EXCHANGE_DATE,
        US_DLI_WRK-EXCHANGE_RATE TO CS_DLI_INT-EXCHANGE_RATE,
        US_DLI_WRK-EXCHANGE_TYPE TO CS_DLI_INT-EXCHANGE_TYPE.
  MOVE US_DLI_WRK-SRC_GUID TO CS_DLI_INT-SRC_GUID.
  MOVE US_DLI_WRK-TERMS_OF_PAYMENT TO  CS_DLI_INT-TERMS_OF_PMNT_C.
ENDFORM.                    "DRVODL_PIP_PREP_INT_FORM_PRE
