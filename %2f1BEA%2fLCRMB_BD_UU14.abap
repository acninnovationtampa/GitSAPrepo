FUNCTION /1BEA/CRMB_BD_U_IT_INT2EXT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"  EXPORTING
*"     VALUE(ES_BDI_DSP) TYPE  /1BEA/S_CRMB_BDI_DSP
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

 DATA:
   LS_BDI      TYPE  /1BEA/S_CRMB_BDI_WRK,
   LS_BDI_DSP  TYPE  /1BEA/S_CRMB_BDI_DSP,
   LS_PRSHTEXT TYPE  COMM_PRSHTEXT,
   lt_dd07_t TYPE dd07v_t,
   ls_dd07_t LIKE LINE OF lt_dd07_t.
  LS_BDI = IS_BDI.
  MOVE-CORRESPONDING LS_BDI TO LS_BDI_DSP.

* item category
     CALL FUNCTION 'BEA_ITC_O_GET_DESCRIPTION'
       EXPORTING
         iv_appl          = gc_appl
         iv_itc           = ls_bdi-item_category
       IMPORTING
         ev_description   = ls_bdi_dsp-item_category_descr
       EXCEPTIONS
         object_not_found = 1
         OTHERS           = 2.
   IF sy-subrc <> 0.
     concatenate '<' ls_bdi-item_category '>'
       INTO ls_bdi_dsp-item_category_descr.
   ENDIF.

* product
 IF ls_bdi-product IS NOT INITIAL.
   CALL FUNCTION 'COM_PRODUCT_ID_GET'
     EXPORTING
       iv_product_guid = ls_bdi-product
     IMPORTING
       ev_product_id   = ls_bdi_dsp-product_id
     EXCEPTIONS
       OTHERS          = 0.
   IF ls_bdi-product_descr IS INITIAL.
     CALL FUNCTION 'COM_PRSHTEXT_READ_SINGLE'
       EXPORTING
         I_PRODUCT_GUID = ls_bdi-product
         I_LANGU        = SY-LANGU
       IMPORTING
         ES_PRSHTEXT    = LS_PRSHTEXT
       EXCEPTIONS
         NOT_FOUND      = 1
         OTHERS         = 2.
     IF SY-SUBRC EQ 0.
       ls_bdi_dsp-PRODUCT_DESCR = LS_PRSHTEXT-SHORT_TEXT.
     ENDIF.
   ENDIF.
 ENDIF.

LS_BDI_DSP-ITEMNO_ALPHA = LS_BDI-ITEMNO_EXT.

* calculation of gross_value
  if ls_bdi_dsp-gross_value is initial.
    ls_bdi_dsp-gross_value = ls_bdi_dsp-net_value + ls_bdi_dsp-tax_value.
  endif.

* currency fields
  ls_bdi_dsp-net_value_currency   = ls_bdi-doc_currency.
  ls_bdi_dsp-tax_value_currency   = ls_bdi-doc_currency.
  ls_bdi_dsp-gross_value_currency = ls_bdi-doc_currency.

* Determine IS_REVERSED_FIELD values
 CLEAR : lt_dd07_t,
         ls_dd07_t.
 CALL FUNCTION 'DDIF_DOMA_GET'
   EXPORTING
     name                = 'BEA_IS_REVERSED'
     langu               = sy-langu
  TABLES
    dd07v_tab           = lt_dd07_t
  EXCEPTIONS
    illegal_input       = 1
    OTHERS              = 2
           .
 IF sy-subrc <> 0.
 ELSE.
   READ TABLE lt_dd07_t INTO ls_dd07_t
     WITH KEY
     domvalue_l = ls_bdi-is_reversed.
   IF sy-subrc EQ 0.
     ls_bdi_dsp-is_reversed_descr = ls_dd07_t-ddtext.
   ENDIF.
 ENDIF.

* quantity fields
  ls_bdi_dsp-net_weight_unit = ls_bdi-weight_unit.
  ls_bdi_dsp-gross_weight_unit = ls_bdi-weight_unit.

* Feature attributes
* Event BD_UIMP0
  INCLUDE %2f1BEA%2fX_CRMBBD_UIMP0CSLUBD_ITT.
  INCLUDE %2f1BEA%2fX_CRMBBD_UIMP0CSVUBD_ITT.

ES_BDI_DSP = LS_BDI_DSP.

ENDFUNCTION.
