FUNCTION /1BEA/CRMB_DL_U_INT2EXT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     VALUE(IV_HEADER_ITEM) TYPE  BEA_DL_HEADER_ITEM DEFAULT 'I'
*"  EXPORTING
*"     VALUE(ES_DLI_DSP) TYPE  /1BEA/S_CRMB_DLI_DSP
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
* Time  : 13:53:02
*
*======================================================================
CONSTANTS:
  LC_ICON_LED_RED        TYPE BEA_BILL_STATUS_EXT
                              VALUE 'ICON_LED_RED',
  LC_ICON_LED_YELLOW     TYPE BEA_BILL_STATUS_EXT
                              VALUE 'ICON_LED_YELLOW',
  LC_ICON_LED_GREEN      TYPE BEA_BILL_STATUS_EXT
                              VALUE 'ICON_LED_GREEN'.
DATA:
  LS_DLI          TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DLI_DSP      TYPE /1BEA/S_CRMB_DLI_DSP,
  LS_DLI_DSP_MOD  TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
  LT_DLI_WRK      TYPE /1BEA/T_CRMB_DLI_WRK,
  LV_BILL_TYPE_DESCR     TYPE BEA_DESCRIPTION,
  LV_ITEM_CATEGORY_DESCR TYPE BEA_DESCRIPTION,
  LV_BILL_CATEGORY_DESCR TYPE BEA_BCA_DESCR.

INCLUDE BEA_BASICS_CON.

LS_DLI = IS_DLI.

MOVE-CORRESPONDING LS_DLI TO LS_DLI_DSP.

* sold-to party
  CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
       EXPORTING
         i_partner         = ls_dli-sold_to_party
       IMPORTING
         e_description      = ls_dli_dsp-sold_to_name
         e_description_name = ls_dli_dsp-sold_to_name_s
       EXCEPTIONS
         partner_not_found = 1
         wrong_parameters  = 2
         internal_error    = 3
         OTHERS            = 4.
  IF sy-subrc <> 0.
    ls_dli_dsp-sold_to_name   = ls_dli-sold_to_party.
    ls_dli_dsp-sold_to_name_s = ls_dli-sold_to_party.
  ENDIF.
*
* payer
  CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
       EXPORTING
         i_partner         = ls_dli-payer
       IMPORTING
         e_description      = ls_dli_dsp-payer_name
         e_description_name = ls_dli_dsp-payer_name_s
       EXCEPTIONS
         partner_not_found = 1
         wrong_parameters  = 2
         internal_error    = 3
         OTHERS            = 4.
  IF sy-subrc <> 0.
    ls_dli_dsp-payer_name   = ls_dli-payer.
    ls_dli_dsp-payer_name_s = ls_dli-payer.
  ENDIF.
*
* billing unit
  CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
       EXPORTING
         i_partner         = ls_dli-bill_org
       IMPORTING
         e_description     = ls_dli_dsp-bill_org_name
       EXCEPTIONS
         partner_not_found = 1
         wrong_parameters  = 2
         internal_error    = 3
         OTHERS            = 4.
  IF sy-subrc <> 0.
    ls_dli_dsp-bill_org_name = ls_dli-bill_org.
  ENDIF.
*
* Process type of source document
*
  DATA: LS_PROC_TYPE_T TYPE CRMC_PROC_TYPE_T.

  CALL FUNCTION 'CRM_ORDER_PROC_TYPE_T_SEL_CB'
    EXPORTING
      IV_PROCESS_TYPE            = IS_DLI-SRC_PROCESS_TYPE
      IV_LANGU                   = SY-LANGU
    IMPORTING
      ES_PROC_TYPE_T             = LS_PROC_TYPE_T
    EXCEPTIONS
      TEXT_ENTRY_NOT_FOUND       = 1
      OTHERS                     = 2.
  IF SY-SUBRC <> 0.
    LS_DLI_DSP-SRC_PROC_TYPE_D = LS_DLI-SRC_PROCESS_TYPE.
  ELSE.
    LS_DLI_DSP-SRC_PROC_TYPE_D = LS_PROC_TYPE_T-P_DESCRIPTION_20.
  ENDIF.

* Billing Type description
 LS_DLI_DSP-BILL_TYPE_D = LS_DLI-BILL_TYPE.
 CALL FUNCTION 'BEA_BTY_O_GET_DESCRIPTION'
   EXPORTING
     iv_appl                = 'CRMB'
     iv_bty                 = LS_DLI-BILL_TYPE
   IMPORTING
     EV_DESCRIPTION         = LV_BILL_TYPE_DESCR
   EXCEPTIONS
     OBJECT_NOT_FOUND       = 1
     OTHERS                 = 2.
 IF sy-subrc <> 0.
   LS_DLI_DSP-BILL_TYPE_DESCR = LS_DLI-BILL_TYPE.
 ELSE.
   LS_DLI_DSP-BILL_TYPE_DESCR = LV_BILL_TYPE_DESCR.
 ENDIF.

* Item Category description
 CALL FUNCTION 'BEA_ITC_O_GET_DESCRIPTION'
   EXPORTING
     iv_appl                = 'CRMB'
     iv_itc                 = LS_DLI-ITEM_CATEGORY
   IMPORTING
     EV_DESCRIPTION         = LV_ITEM_CATEGORY_DESCR
   EXCEPTIONS
     OBJECT_NOT_FOUND       = 1
     OTHERS                 = 2.
 IF sy-subrc <> 0.
   LS_DLI_DSP-ITEM_CATEGORY_DESCR = LS_DLI-ITEM_CATEGORY.
 ELSE.
   LS_DLI_DSP-ITEM_CATEGORY_DESCR = LV_ITEM_CATEGORY_DESCR.
 ENDIF.

* Billing Document Category description
 CALL FUNCTION 'BEA_BCA_O_GET_DESCRIPTION'
   EXPORTING
     iv_appl               = 'CRMB'
     iv_bill_category      = LS_DLI-BILL_CATEGORY
   IMPORTING
     EV_DESCRIPTION        = LV_BILL_CATEGORY_DESCR
   EXCEPTIONS
     OBJECT_NOT_FOUND       = 1
     OTHERS                 = 2.
 IF sy-subrc <> 0.
   LS_DLI_DSP-BILL_CATEGORY_DESCR = LS_DLI-BILL_CATEGORY.
 ELSE.
   LS_DLI_DSP-BILL_CATEGORY_DESCR = LV_BILL_CATEGORY_DESCR.
 ENDIF.

  IF LS_DLI-PRODUCT IS NOT INITIAL.
    CALL FUNCTION 'COM_PRODUCT_ID_GET'
      EXPORTING
        IV_PRODUCT_GUID = LS_DLI-PRODUCT
    IMPORTING
        EV_PRODUCT_ID   = LS_DLI_DSP-PRODUCT_ID
    EXCEPTIONS
        NOT_FOUND              = 1
        WRONG_CALL             = 2
        OTHERS                 = 3.
    IF SY-SUBRC <> 0.
      CLEAR:
        LS_DLI_DSP-PRODUCT_ID.
    ENDIF.
  ENDIF.

  LS_DLI_DSP-SRC_ITEMNO_EXT = LS_DLI-SRC_ITEMNO.
* set status
  IF LS_DLI-BILL_STATUS = GC_BILLSTAT_DONE.
    LS_DLI_DSP-BILL_STATUS_EXT = LC_ICON_LED_GREEN.
  ELSEIF ( LS_DLI-BILL_STATUS = GC_BILLSTAT_TODO  AND
           LS_DLI-INCOMP_ID   = GC_INCOMP_OK      AND
           LS_DLI-BILL_BLOCK  = GC_BILLBLOCK_NONE ).
    LS_DLI_DSP-BILL_STATUS_EXT = LC_ICON_LED_YELLOW.
  ELSE.
    LS_DLI_DSP-BILL_STATUS_EXT = LC_ICON_LED_RED.
  ENDIF.

* If it is a Due List Header enhance additional fields
 IF IV_HEADER_ITEM = GC_DL_TYPE_HEAD.
   CALL FUNCTION '/1BEA/CRMB_DL_O_DLIGETLIST'
     EXPORTING
       iv_dlh_guid       = LS_DLI_DSP-DLI_GUID
     IMPORTING
       ET_DLI_WRK        = LT_DLI_WRK
     EXCEPTIONS
       NOTFOUND          = 1
       OTHERS            = 2.
   IF sy-subrc <> 0.
   ENDIF.

   LOOP AT LT_DLI_WRK INTO LS_DLI_WRK.
     IF LS_DLI_DSP-DOC_CURRENCY IS INITIAL.
       LS_DLI_DSP-DOC_CURRENCY = LS_DLI_WRK-DOC_CURRENCY.
     ENDIF.
     IF LS_DLI_WRK-BILL_BLOCK <> GC_BILLBLOCK_NONE OR ( LS_DLI_WRK-BILL_STATUS <> GC_BILLSTAT_TODO AND LS_DLI_WRK-BILL_STATUS <> GC_BILLSTAT_DONE ).
       LS_DLI_DSP-BILL_BLOCK = gc_billblock_intern.
     ELSE.
       LS_DLI_DSP-BILL_BLOCK = gc_billblock_none.
     ENDIF.
     ADD LS_DLI_WRK-NET_VALUE TO LS_DLI_DSP-NET_VALUE.
   ENDLOOP.
 ENDIF.

* Feature attributes
* Event DL_UMAP0
  INCLUDE %2f1BEA%2fX_CRMBDL_UMAP0CSLUDL_ITT.
  INCLUDE %2f1BEA%2fX_CRMBDL_UMAP0CSVUDL_ITT.

ES_DLI_DSP = LS_DLI_DSP.

ENDFUNCTION.
