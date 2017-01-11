FUNCTION /1BEA/CRMB_BD_U_HD_INT2EXT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
*"     VALUE(ES_BDH_DSP) TYPE  /1BEA/S_CRMB_BDH_DSP
*"--------------------------------------------------------------------
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:01
*
*======================================================================
  include BEA_BASICS_CON.

 CONSTANTS:
   lc_c             TYPE char3 VALUE '(',
   lc_j             TYPE char3 VALUE ')',
   lc_icon_document TYPE bea_cancel_status_icon VALUE 'ICON_DOCUMENT',
   lc_icon_cancel   TYPE bea_cancel_status_icon VALUE 'ICON_CANCEL',
   lc_icon_storno   TYPE bea_cancel_status_icon VALUE 'ICON_STORNO'.

  DATA:
    LS_BDH            TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDH_DSP        TYPE /1BEA/S_CRMB_BDH_DSP,
    LT_BDI_WRK        TYPE /1bea/T_CRMB_BDI_wrk,
    LS_BDI_WRK        TYPE /1bea/S_CRMB_BDI_wrk,
    lrs_bdh_guid      TYPE bears_bdh_guid,
    lrt_bdh_guid      TYPE beart_bdh_guid,
    lv_description    TYPE bea_description,
    ls_dd07v          TYPE dd07v,
    lv_value          TYPE domvalue_l,
    ls_crp            TYPE beas_crp,
    ls_user_address   TYPE addr3_val.

  CONSTANTS:
    LC_PFCT_BILLTO   TYPE CRMT_PARTNER_FCT VALUE '00000003'.
  DATA:
    LS_PARTNER       TYPE COMT_PARTNER_TO_DISPLAY,
    LT_PARTNER       TYPE COMT_PARTNER_TO_DISPLAY_TAB.
  LS_BDH = IS_BDH.
  MOVE-CORRESPONDING LS_BDH TO LS_BDH_DSP.

* bill type
   CALL FUNCTION 'BEA_BTY_O_GET_DESCRIPTION'
     EXPORTING
       iv_appl          = gc_appl
       iv_bty           = ls_bdh-bill_type
     IMPORTING
       ev_description   = lv_description
     EXCEPTIONS
       object_not_found = 1
       OTHERS           = 2.
   IF sy-subrc <> 0.
     concatenate '<' ls_bdh-bill_type '>' INTO ls_bdh_dsp-bill_type_descr.
   ELSE.
     IF NOT ls_bdh-cancel_flag IS INITIAL.
       lv_value = ls_bdh-cancel_flag.
       CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
         EXPORTING
           domname  = 'BEA_REVERSAL'
           value    = lv_value
        IMPORTING
           dd07v_wa = ls_dd07v.
     CONCATENATE lc_c ls_dd07v-ddtext lc_j INTO ls_bdh_dsp-bill_type_descr.
     CONCATENATE lv_description ls_bdh_dsp-bill_type_descr
       INTO ls_bdh_dsp-bill_type_descr SEPARATED BY space.
     ELSE.
       ls_bdh_dsp-bill_type_descr = lv_description.
     ENDIF.
   ENDIF.

* payer
   CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
     EXPORTING
       i_partner         = ls_bdh-payer
     IMPORTING
       e_description      = ls_bdh_dsp-payer_name
       e_description_name = ls_bdh_dsp-payer_name_short
     EXCEPTIONS
       partner_not_found = 1
       wrong_parameters  = 2
       internal_error    = 3
       OTHERS            = 4.
   IF sy-subrc <> 0.
     ls_bdh_dsp-payer_name       = ls_bdh-payer.
     ls_bdh_dsp-payer_name_short = ls_bdh-payer.
   ENDIF.

* bill org
   CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
     EXPORTING
       i_partner         = ls_bdh-bill_org
     IMPORTING
       e_description     = ls_bdh_dsp-bill_org_name
     EXCEPTIONS
       partner_not_found = 1
       wrong_parameters  = 2
       internal_error    = 3
       OTHERS            = 4.
   IF sy-subrc <> 0.
     ls_bdh_dsp-bill_org_name = ls_bdh-bill_org.
   ENDIF.

* bill to
   CALL FUNCTION 'COM_PARTNER_TO_DISPLAY_OW'
     EXPORTING
       iv_partnerset_guid     = ls_bdh-parset_guid
     IMPORTING
       ET_PARTNER             = lt_partner
   EXCEPTIONS
     PARTNERSET_NOT_FOUND        = 1
     OTHERS                      = 2
         .
   IF sy-subrc <> 0.
     clear: ls_bdh_dsp-bill_to, ls_bdh_dsp-bill_to_name.
   ELSE.
     read table lt_partner into ls_partner
       with key PARTNER_FCT = lc_pfct_billto.
     if sy-subrc = 0.
       ls_bdh_dsp-bill_to      = ls_partner-PARTNER_NUMBER.
       ls_bdh_dsp-bill_to_name = ls_partner-short.
     endif.
   ENDIF.
* collective run
   IF NOT ls_bdh-crp_guid IS INITIAL.
     CALL FUNCTION 'BEA_CRP_O_GETDETAIL'
       EXPORTING
         iv_appl     = gc_appl
         iv_crp_guid = ls_bdh-crp_guid
       IMPORTING
         es_crp      = ls_crp
       EXCEPTIONS
         OTHERS      = 0.
     IF NOT ls_crp IS INITIAL.
       ls_bdh_dsp-cr_number = ls_crp-cr_number.
     ENDIF.
   ENDIF.

* maintenance user
   CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
     EXPORTING
       user_name              = ls_bdh-maint_user
     IMPORTING
       user_address           = ls_user_address
     EXCEPTIONS
       user_address_not_found = 1
       OTHERS                 = 2.
   IF sy-subrc EQ 0.
     ls_bdh_dsp-maint_user_name = ls_user_address-name_text.
   ELSE.
     ls_bdh_dsp-maint_user_name = ls_bdh-maint_user.
   ENDIF.

* currency fields
  ls_bdh_dsp-net_value_currency = ls_bdh-doc_currency.
  ls_bdh_dsp-tax_value_currency = ls_bdh-doc_currency.
  ls_bdh_dsp-GROSS_VALUE_CURRENCY = ls_bdh-doc_currency.

* gross value
  ls_bdh_dsp-GROSS_VALUE = ls_bdh_dsp-NET_VALUE + ls_bdh_dsp-TAX_VALUE.

* document status
  IF    ls_bdh_dsp-cancel_flag = gc_cancel
     OR ls_bdh_dsp-cancel_flag = gc_partial_cancel.
* It is a Cancel-Invoice -> ICON_STORNO
    ls_bdh_dsp-cancel_status_icon    = lc_icon_storno.
    ls_bdh_dsp-cancel_status_tooltip = text-sto.
  ELSE.
* read BDI's
    lrs_bdh_guid-sign   = gc_include.
    lrs_bdh_guid-option = gc_equal.
    lrs_bdh_guid-low    = ls_bdh_dsp-bdh_guid.
    APPEND lrs_bdh_guid TO lrt_bdh_guid.
    CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
      EXPORTING
        irt_bdh_bdh_guid = lrt_bdh_guid
      IMPORTING
        et_bdi           = lt_bdi_wrk.
    LOOP AT lt_bdi_wrk INTO ls_bdi_wrk
      WHERE bdh_guid    = ls_bdh_dsp-bdh_guid
      AND ( is_reversed = gc_is_not_reversed OR
            is_reversed = gc_is_reved_by_corr ).
       EXIT.
    ENDLOOP.
    IF sy-subrc <> 0 and lt_bdi_wrk is not initial.
* It is a cancelled invoice -> ICON_CANCEL
      ls_bdh_dsp-cancel_status_icon    = lc_icon_cancel.
      ls_bdh_dsp-cancel_status_tooltip = text-cac.
    ELSE.
* Nothing special -> ICON_DOCUMENT
      ls_bdh_dsp-cancel_status_icon    = lc_icon_document.
      ls_bdh_dsp-cancel_status_tooltip = text-do2.
    ENDIF.
  ENDIF.



* Feature attributes

ES_BDH_DSP = LS_BDH_DSP.

ENDFUNCTION.
