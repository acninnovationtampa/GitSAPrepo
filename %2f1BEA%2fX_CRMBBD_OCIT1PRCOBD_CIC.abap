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
 CS_BDI_WRK-PRV_PRIDOC_GUID  = US_BDH_TC_WRK-PRIDOC_GUID.
 CS_BDI_WRK-PRV_ITEM_GUID    = US_BDI_TC_WRK-BDI_GUID.
 CS_BDI_WRK-BDI_PRICING_TYPE = 'D'.
 CS_BDI_WRK-BDI_PRCCOPY_TYPE = '02100'.
 CS_BDI_WRK-REF_QUANTITY     = US_BDI_TC_WRK-QUANTITY.
 CS_BDI_WRK-REF_QTY_UNIT     = US_BDI_TC_WRK-QTY_UNIT.
 CS_BDI_WRK-QUANTITY         = -1 * US_BDI_TC_WRK-QUANTITY.

* for value-based billing

IF us_bdi_tc_wrk-bill_relevance = gc_bill_rel_value.

  cs_bdi_wrk-bdi_prccopy_type = '01000'.
  cs_bdi_wrk-net_value = -1 * us_bdi_tc_wrk-net_value.
  cs_bdi_wrk-net_value_man = -1 * us_bdi_tc_wrk-net_value_man.
  cs_bdi_wrk-doc_currency = us_bdi_tc_wrk-doc_currency.
  cs_bdi_wrk-credit_debit = gc_debit.

* Initialize net_value and net_value_man for Accrual Items
  IF us_bdi_tc_wrk-item_type = gc_item_type_accrual.
    clear cs_bdi_wrk-net_value.
    clear cs_bdi_wrk-net_value_man.
  ENDIF.

ENDIF.
