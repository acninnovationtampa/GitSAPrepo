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
* Include           BETX_ICBODL_CUZ
*--------------------------------------------------------------------*
*---------------------------------------------------------------------
*       FORM ICBODL_DETERMINE_CURRENCY
*---------------------------------------------------------------------
FORM ICBODL_DETERMINE_CURRENCY
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK.

  constants:
    lc_bus_sales_com type strukname value 'CRMT_BUS_SALES_COM'.
  data:
    ls_bupa_frg0030  type crmt_bus_set0030,
    lv_partner_guid  type bu_partner_guid,
    ls_sales_area    type crmt_bus_sales_area,
    ls_sales_area_ib type ofit_sales_area_ib.

  if us_dli_wrk-deriv_category = gc_deriv_orgdata.
    call function 'CRM_OFI_SALES_AREA_IB_READ'
     exporting
       iv_bill_org         = us_dli_wrk-bill_org
     importing
       es_sales_area_ib    = ls_sales_area_ib
     exceptions
       reject              = 1
       others              = 2.
    if sy-subrc = 0.
      if not ls_sales_area_ib is initial.
        ls_sales_area-sales_org = ls_sales_area_ib-sales_org_ib.
        ls_sales_area-channel   = ls_sales_area_ib-dis_channel_ib.
        ls_sales_area-division  = ls_sales_area_ib-division_ib.
        call function 'CRM_BUPA_FRG0030_READ'
          exporting
            iv_partner_guid             = us_dli_wrk-payer_guid
            iv_com_structure_name       = lc_bus_sales_com
            is_com_structure            = ls_sales_area
          importing
            es_data                     = ls_bupa_frg0030
          exceptions
            no_valid_record_found       = 1
            key_structure_not_supported = 2
            others                      = 3.
        if sy-subrc = 0.
          if not ls_bupa_frg0030-currency is initial.
            cs_dli_wrk-doc_currency = ls_bupa_frg0030-currency.
          endif.
          if not ls_bupa_frg0030-exchange_type is initial.
            cs_dli_wrk-exchange_type = ls_bupa_frg0030-exchange_type.
          endif.
*         Take over Payment Terms / Price List Type / Price Group / Customer Group
          cs_dli_wrk-terms_of_payment = ls_bupa_frg0030-payment_terms.
        endif.
      endif.
    endif.
*   Determine the exchange rate(Required for IC billing)
    call function 'READ_EXCHANGE_RATE'
       exporting
         date              = cs_dli_wrk-exchange_date
         foreign_currency  = cs_dli_wrk-doc_currency
         local_currency    = cs_dli_wrk-ref_currency
         type_of_rate      = cs_dli_wrk-exchange_type
       importing
         exchange_rate     = cs_dli_wrk-exchange_rate
       exceptions
         no_rate_found     = 2
         error_message     = 1.
    if sy-subrc ne 0.
      clear cs_dli_wrk-exchange_rate.
    endif.
  endif.
ENDFORM.                    "ICBODL_DETERMINE_CURRENCY
