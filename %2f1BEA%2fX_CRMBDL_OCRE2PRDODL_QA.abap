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
IF ls_dli_wrk-bill_relevance = gc_bill_rel_value.
  PERFORM PRDODL_NET_VALUE_ADAPT
    USING
      US_DLI_INT
      UT_DLI_WRK
    CHANGING
      LS_DLI_WRK
      LV_BUFFER_ADD
      CT_RETURN
      LV_RETURNCODE.
ELSE.
  PERFORM PRDODL_QAZ_QUANTITY_ADAPT
    USING
      US_DLI_INT
      UT_DLI_WRK
    CHANGING
      LS_DLI_WRK
      LV_BILLED_QUANTITY
      LV_BUFFER_ADD
      CT_RETURN
      LV_RETURNCODE.
ENDIF.
