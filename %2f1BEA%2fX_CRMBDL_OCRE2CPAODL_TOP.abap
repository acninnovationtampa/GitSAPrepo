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

  DATA:
    LV_CPAODL_TOP_RETURNCODE      TYPE SY-SUBRC,
    LS_CPAODL_TOP_BUPA_FRG0030    TYPE CRMT_BUS_SET0030.

  IF LS_DLI_WRK-TERMS_OF_PAYMENT IS INITIAL         AND
    LS_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_ORDER  AND
    ( LS_DLI_WRK-OBJTYPE EQ GC_BOR_LIKP OR
      LS_DLI_WRK-OBJTYPE EQ GC_BOR_INB_DLV OR
      LS_DLI_WRK-OBJTYPE EQ GC_BOR_INSPECTION )     AND
    LS_DLI_WRK-BILL_CATEGORY NE GC_BILL_CAT_PROFORMA.

    PERFORM CPAODL_GET_PARTNER_GET
      USING
        LS_DLI_WRK
      CHANGING
        LS_CPAODL_TOP_BUPA_FRG0030
        LV_CPAODL_TOP_RETURNCODE.

    IF LV_CPAODL_TOP_RETURNCODE IS INITIAL.
      LS_DLI_WRK-TERMS_OF_PAYMENT = LS_CPAODL_TOP_BUPA_FRG0030-PAYMENT_TERMS.
      LS_DLI_WRK-EXCHANGE_TYPE = LS_CPAODL_TOP_BUPA_FRG0030-EXCHANGE_TYPE.
      IF LS_DLI_WRK-DOC_CURRENCY IS INITIAL.
        LS_DLI_WRK-DOC_CURRENCY = LS_CPAODL_TOP_BUPA_FRG0030-CURRENCY.
      ENDIF.
*     Determine the exchange rate(Required for stock order billing)
      call function 'READ_EXCHANGE_RATE'
         exporting
           date              = ls_dli_wrk-exchange_date
           foreign_currency  = ls_dli_wrk-doc_currency
           local_currency    = ls_dli_wrk-ref_currency
           type_of_rate      = ls_dli_wrk-exchange_type
         importing
           exchange_rate     = ls_dli_wrk-exchange_rate
         exceptions
           no_rate_found     = 2
           error_message     = 1.
      if sy-subrc ne 0.
        clear ls_dli_wrk-exchange_rate.
      endif.
    ENDIF.
  ENDIF.
