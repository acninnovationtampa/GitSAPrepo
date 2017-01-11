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
INCLUDE CRM_BILLING_CON.
INCLUDE CRM_CUMULATED_I_CON.
*-----------------------------------------------------------------*
*     FORM PRDODL_ELZ_ERL_GET_REF_QTY
*-----------------------------------------------------------------*
FORM PRDODL_ELZ_ERL_GET_REF_QTY
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_COM     TYPE /1BEA/S_CRMB_DLI_COM.

  DATA:
    ls_sales_item  type crmc_sales_item,
    ls_cumulated_i type crmt_cumulated_i_wrk.

  CS_DLI_COM-REF_QUANTITY = US_DLI_WRK-QUANTITY.
  CS_DLI_COM-REF_QTY_UNIT = US_DLI_WRK-QTY_UNIT.
  if   ( us_dli_wrk-objtype    <> gc_bor_likp OR
         us_dli_wrk-objtype    <> gc_bor_inb_dlv )  and
     not us_dli_wrk-src_item_type is initial.
*   get billing relevance from order item category
    call function 'CRM_ORDER_SALES_ITEM_SELECT_CB'
      exporting
        iv_item_type    = us_dli_wrk-src_item_type
      importing
        es_sales_item   = ls_sales_item
      exceptions
        entry_not_found = 0
        others          = 0.
    if ls_sales_item-billing_relevant = gc_billing_relevance-delivered_qty.
*     retrieve cumultated goods issued delivered quantity from order item
      call function 'CRM_CUMULATED_I_READ_OW'
        exporting
          iv_guid                      = us_dli_wrk-src_guid
          iv_cum_type                  = gc_cum_type-goods_issue
          iv_cum_rule                  = gc_cum_rule-quantity
        importing
          es_cumulated_i_wrk           = ls_cumulated_i
        exceptions
          at_least_one_entry_not_found = 1
          entry_not_found              = 2
          inconsistent_import          = 3
          inconsistent_data            = 4
          others                       = 5.
      if sy-subrc = 0.
        CS_DLI_COM-REF_QUANTITY = ls_cumulated_i-QUANTITY.
        CS_DLI_COM-REF_QTY_UNIT = ls_cumulated_i-QUANTITY_UNIT.
*       perform quantity adaptation in method CREATE
        CLEAR CS_DLI_COM-SRC_ACTIVITY.
      endif.
    endif.
  endif.
ENDFORM.
*-----------------------------------------------------------------*
*     FORM PRDODL_ELZ_ERL_GET_REF_QTY_DRV
*-----------------------------------------------------------------*
FORM PRDODL_ELZ_ERL_GET_REF_QTY_DRV
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_INT     TYPE /1BEA/S_CRMB_DLI_INT.

  DATA:
    ls_sales_item  type crmc_sales_item,
    ls_cumulated_i type crmt_cumulated_i_wrk.

* do not perform quantity adaptation in method CREATE
  CS_DLI_INT-SRC_ACTIVITY = GC_SRC_ACTIVITY_DL04.
  CS_DLI_INT-REF_QUANTITY = US_DLI_WRK-QUANTITY.
  CS_DLI_INT-REF_QTY_UNIT = US_DLI_WRK-QTY_UNIT.
  if   ( us_dli_wrk-objtype    <> gc_bor_likp OR
         us_dli_wrk-objtype    <> gc_bor_inb_dlv )  and
     not us_dli_wrk-src_item_type is initial.
*   get billing relevance from order item category
    call function 'CRM_ORDER_SALES_ITEM_SELECT_CB'
      exporting
        iv_item_type    = us_dli_wrk-src_item_type
      importing
        es_sales_item   = ls_sales_item
      exceptions
        entry_not_found = 0
        others          = 0.
    if ls_sales_item-billing_relevant = gc_billing_relevance-delivered_qty.
*     retrieve cumultated goods issued delivered quantity from order item
      call function 'CRM_CUMULATED_I_READ_OW'
        exporting
          iv_guid                      = us_dli_wrk-src_guid
          iv_cum_type                  = gc_cum_type-goods_issue
          iv_cum_rule                  = gc_cum_rule-quantity
        importing
          es_cumulated_i_wrk           = ls_cumulated_i
        exceptions
          at_least_one_entry_not_found = 1
          entry_not_found              = 2
          inconsistent_import          = 3
          inconsistent_data            = 4
          others                       = 5.
      if sy-subrc = 0.
        CS_DLI_INT-REF_QUANTITY = ls_cumulated_i-QUANTITY.
        CS_DLI_INT-REF_QTY_UNIT = ls_cumulated_i-QUANTITY_UNIT.
*       perform quantity adaptation in method CREATE
        CLEAR CS_DLI_INT-SRC_ACTIVITY.
      endif.
    endif.
  endif.
ENDFORM.
