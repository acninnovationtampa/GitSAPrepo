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
    MOVE US_DLI_WRK-INDICATOR_IC TO CS_BDI_WRK-INDICATOR_IC.

*  for IB take Sales Area and exchange rate from derived item
    IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA.
      CS_BDI_WRK-SALES_ORG = US_DLI_WRK-SALES_ORG.
      CS_BDI_WRK-DIS_CHANNEL = US_DLI_WRK-DIS_CHANNEL.
      CS_BDI_WRK-DIVISION = US_DLI_WRK-DIVISION.
      CS_BDI_WRK-DOC_CURRENCY = US_DLI_WRK-DOC_CURRENCY.
      IF us_dli_wrk-exchange_rate is initial.
*       exchange rate has to be cleared to force pricing to determine
        clear cs_bdi_wrk-exchange_rate.
      ELSE.
*       Copy exchange rate from due list item
        cs_bdi_wrk-exchange_rate = us_dli_wrk-exchange_rate.
      ENDIF.
    ENDIF.
