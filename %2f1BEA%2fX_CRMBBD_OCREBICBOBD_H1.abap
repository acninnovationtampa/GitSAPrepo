*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================
  IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA OR
     US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_PARTNER.
*     for IB and SB take Bill Org and Payer from derived item
    CS_BDH_WRK-BILL_ORG = US_DLI_WRK-BILL_ORG.
    CS_BDH_WRK-PAYER    = US_DLI_WRK-PAYER.
  ENDIF.
  IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA.
*     for IB take Doc Currency, Ref Currency and Exhchange Type from derived item
    IF NOT US_DLI_WRK-DOC_CURRENCY IS INITIAL.
      CS_BDH_WRK-DOC_CURRENCY = US_DLI_WRK-DOC_CURRENCY.
    ENDIF.
    IF NOT US_DLI_WRK-REF_CURRENCY IS INITIAL.
      CS_BDH_WRK-REF_CURRENCY = US_DLI_WRK-REF_CURRENCY.
    ENDIF.
    IF NOT US_DLI_WRK-EXCHANGE_TYPE IS INITIAL.
      CS_BDH_WRK-EXCHANGE_TYPE = US_DLI_WRK-EXCHANGE_TYPE.
    ENDIF.
*   Take over Payment Terms from derived item
    cs_bdh_wrk-terms_of_payment = us_dli_wrk-terms_of_payment.
  ENDIF.
