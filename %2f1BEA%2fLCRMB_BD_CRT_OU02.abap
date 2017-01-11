FUNCTION /1BEA/CRMB_BD_CRT_O_DOC_SET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH_WRK) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI_WRK) TYPE  /1BEA/T_CRMB_BDI_WRK
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
   LC_DIR_01            TYPE CRMT_TAX_DIRECTION_IND     VALUE '01',
   LC_WITHOUT_REG       TYPE CRMT_TAX_REGION_INDICATOR  VALUE 'X',
   LC_BD_PREFIX         TYPE C                          VALUE '$',
   LC_INV               TYPE TTET_BUSTRANSACTION_PD     VALUE 'INV',
   LC_CRM_FINANCE       TYPE CHAR11                     VALUE 'CRM_FINANCE'.

 DATA:
   LV_BILL_ORG          TYPE BU_PARTNER,
   LV_BILL_ORG_G        TYPE BU_PARTNER_GUID,
   LV_HEADNO_EXT        TYPE BEA_HEADNO_EXT,
   LV_CRM_ITEM_TYPE     TYPE CRMT_ITEM_TYPE,
   LS_CRM_ITEM_TYPE     TYPE CRMC_ITEM_TYPE,
   LV_PD_HANDLE         TYPE PRCT_HANDLE,
   LS_PD_HEAD_DATA      TYPE PRCT_HEAD_DATA,
   LS_TTE_HANDLE        TYPE TTEPDT_SAVE_HANDLE_ST,
   LS_TTE_DOCUMENT      TYPE TTEPDT_DOCUMENT,
   LS_BDI_WRK           TYPE /1BEA/S_CRMB_BDI_WRK,
   LS_CRT_HEADER        TYPE CRMT_TAX_HEADER_DATA,
   LS_CRT_ITEM          TYPE CRMT_TAX_ITEM_LIST,
   LT_CRT_ITEM          TYPE CRMT_TAX_ITEM_LIST_TAB.

 CHECK NOT IS_BDH_WRK-PRC_SESSION_ID IS INITIAL.

 CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
   EXPORTING
     IV_SESSION_ID     = IS_BDH_WRK-PRC_SESSION_ID
   IMPORTING
     EV_PRICING_HANDLE = LV_PD_HANDLE
   EXCEPTIONS
     OTHERS            = 0.
 CHECK NOT LV_PD_HANDLE IS INITIAL.

 CALL FUNCTION 'PRC_PD_HEAD_READ'
   EXPORTING
     IV_PD_HANDLE              = LV_PD_HANDLE
   IMPORTING
     ES_HEAD_DATA              = LS_PD_HEAD_DATA
   EXCEPTIONS
     NON_EXISTING_HANDLE       = 1
     OTHERS                    = 2.
 IF SY-SUBRC <> 0 OR LS_PD_HEAD_DATA-TTE_REQUIRED IS INITIAL.
   RETURN.
 ENDIF.

 IF IS_BDH_WRK-HEADNO_EXT(1) NE LC_BD_PREFIX.
   CALL FUNCTION 'TTE_4_DOCUMENT_EXISTS'
     EXPORTING
       I_DOCUMENT_ID   = IS_BDH_WRK-BDH_GUID
     IMPORTING
       O_DOCUMENT_ATR  = LS_TTE_DOCUMENT
     EXCEPTIONS
       NO_TTE_DOCUMENT = 1
       OTHERS          = 2.
   IF ( SY-SUBRC = 0 AND NOT LS_TTE_DOCUMENT IS INITIAL ).
     CLEAR LS_TTE_HANDLE.
     LS_TTE_HANDLE-REFTOORIGINAL = IS_BDH_WRK-BDH_GUID.
     LS_TTE_HANDLE-PRIDOCGUID    = LS_PD_HEAD_DATA-DOCUMENT_ID.
     PERFORM SET_EXISTING_TTE_DOCUMENT USING LS_TTE_HANDLE
                                             LS_PD_HEAD_DATA
                                             IT_BDI_WRK.
     RETURN.
   ENDIF.
 ENDIF.

 LV_BILL_ORG = IS_BDH_WRK-BILL_ORG.
 CALL FUNCTION 'COM_PARTNER_CONVERT_GUID_TO_NO'
   EXPORTING
     IV_PARTNER       = LV_BILL_ORG
   IMPORTING
     EV_PARTNER_GUID  = LV_BILL_ORG_G
   EXCEPTIONS
     OTHERS           = 0.

 LS_CRT_HEADER-OWN_BUS_PARTNER = LV_BILL_ORG_G.

 LOOP AT IT_BDI_WRK INTO LS_BDI_WRK.
   CHECK LS_BDI_WRK-PRICING_STATUS NE GC_PRC_STAT_NOTREL.
   CLEAR LS_CRT_ITEM.
   LS_CRT_ITEM-WITHOUT_REGION = LC_WITHOUT_REG.
   LS_CRT_ITEM-BILLING_UNIT   = LV_BILL_ORG_G.

   MOVE IS_BDH_WRK-INCOTERMS1 TO LS_CRT_ITEM-INCOTERMS1.
   MOVE IS_BDH_WRK-INCOTERMS2 TO LS_CRT_ITEM-INCOTERMS2.
   MOVE LS_BDI_WRK-BDI_GUID TO LS_CRT_ITEM-ITEM_GUID.
   MOVE LS_BDI_WRK-PRODUCT TO LS_CRT_ITEM-PRODUCT_GUID.
   MOVE LS_BDI_WRK-SALES_ORG TO LS_CRT_ITEM-SALES_ORG.
   MOVE LS_BDI_WRK-SERVICE_ORG TO LS_CRT_ITEM-SERVICE_ORG.
   MOVE LS_BDI_WRK-TAX_DEST_COUNTRY TO LS_CRT_ITEM-TAX_DEST_CTY.
   MOVE LS_BDI_WRK-RENDERED_DATE TO LS_CRT_ITEM-RENDERED_DATE.
   MOVE LS_BDI_WRK-ITEMNO_EXT TO LS_CRT_ITEM-POS_NUM.

   LS_CRT_ITEM-OBJECT_TYPE = GC_BOR_BDI.
   LV_CRM_ITEM_TYPE = LS_BDI_WRK-SRC_ITEM_TYPE.
   CALL FUNCTION 'CRM_ORDER_ITEM_TYPE_SELECT_CB'
     EXPORTING
       IV_ITEM_TYPE = LV_CRM_ITEM_TYPE
     IMPORTING
       ES_ITEM_TYPE = LS_CRM_ITEM_TYPE
     EXCEPTIONS
       OTHERS       = 0.
   LS_CRT_ITEM-BOR_OBJECT_TYPE = LS_CRM_ITEM_TYPE-OBJECT_TYPE.
   IF LS_CRT_ITEM-DIRECTION_IND IS INITIAL.
     LS_CRT_ITEM-DIRECTION_IND   = LC_DIR_01.
   ENDIF.
   IF LS_BDI_WRK-BUSINESSSCENARIO EQ GC_SCENARIO_FINANCE.
     LS_CRT_ITEM-BUS_SCENARIO = LC_CRM_FINANCE.
   ENDIF.
* Event _CRTDSI1
  INCLUDE %2f1BEA%2fX_CRMB_CRTDSI1_DSOBD_MFA.
   APPEND LS_CRT_ITEM TO LT_CRT_ITEM.
 ENDLOOP.

 CALL FUNCTION 'CRM_TAX_TTE_DOCUMENT_SET'
   EXPORTING
     IV_PD_HANDLE             = LV_PD_HANDLE
     IS_HEADER_DATA           = LS_CRT_HEADER
     IT_ITEM_LIST             = LT_CRT_ITEM
     IV_BUSTRANSACTION        = LC_INV
     IV_BEA_APPLICATION       = 'CRMB'
   EXCEPTIONS
     OTHERS                   = 0.

ENDFUNCTION.

*---------------------------------------------------------------------
* FORM SET_EXISTING_TTE_DOCUMENT
*---------------------------------------------------------------------
FORM SET_EXISTING_TTE_DOCUMENT
  USING
    US_TTE_HANDLE     TYPE TTEPDT_SAVE_HANDLE_ST
    US_PD_HEAD_DATA   TYPE PRCT_HEAD_DATA
    UT_BDI_WRK        TYPE /1BEA/T_CRMB_BDI_WRK.

  CONSTANTS:
    LC_READ_FROM_DB            TYPE C    VALUE ' '.

  DATA:
    LS_TTE_DOCUMENT            TYPE BEAS_PRC_TTE_O_DOCUMENT,
    LT_I_HEADER                TYPE TTEPDT_HEADER_COM_TT,
    LT_I_ITEM                  TYPE TTEPDT_ITEM_COM_TT,
    LT_I_TAXEVENT              TYPE TTEPDT_TAXEVENT_COM_TT,
    LT_I_TAXEL                 TYPE TTEPDT_TAXEL_COM_TT,
    LT_I_TAXVALUE              TYPE TTEPDT_TAXVALUE_COM_TT,
    LT_I_CURRCONV              TYPE TTEPDT_CURRCONV_COM_TT,
    LT_I_COUNTRIES             TYPE TTEPDT_COUNTRIES_COM_TT,
    LT_O_TRACE                 TYPE TTEPDT_TRACE_COM_TT,
    LS_BDI_WRK                 TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_I_ITEM                  TYPE TTEPDT_ITEM_COM_ST,
    LS_CRM_ITEM_TYPE           TYPE CRMC_ITEM_TYPE,
    LV_TABIX                   TYPE SYTABIX,
    LV_ERROR_NUMBER(8)         TYPE C,
    LV_ERROR_MESSAGE(1024)     TYPE C,
    lr_ttedoc type ref to cl_tte_document_ext,
    lr_ttecom type ref to if_tte_communication.

* create instance of tte-document
 create object lr_ttedoc.
 CALL FUNCTION 'TTE_4_DOCUMENT_GET_PERS'
   EXPORTING
     I_HANDLE              = US_TTE_HANDLE
     I_READ_FROM_TTE       = US_PD_HEAD_DATA-EDIT_MODE
     IR_TTEDOC             = lr_ttedoc
   EXCEPTIONS
     COMMUNICATION_FAILURE = 1
     NO_TTE_DOCUMENT       = 2
     SYSTEM_FAILURE        = 3
     IMPORT_ERROR          = 4
     OTHERS                = 5.

 IF SY-SUBRC = 0.
   call method lr_ttedoc->get_input_document
     importing
       IT_HEADER_TAB                 = LT_I_HEADER
       IT_ITEM_TAB                   = LT_I_ITEM
       IT_TRANPROP_TAB               = LS_TTE_DOCUMENT-I_TRANPROP
       IT_ORGUNIT_TAB                = LS_TTE_DOCUMENT-I_ORGUNIT
       IT_ITEMPART_TAB               = LS_TTE_DOCUMENT-I_ITEMPART
       IT_PRICEL_TAB                 = LS_TTE_DOCUMENT-I_PRICEL
       IT_TAXDATE_TAB                = LS_TTE_DOCUMENT-I_TAXDATE
       IT_TAXEVENT_TAB               = LT_I_TAXEVENT
       IT_TAXEL_TAB                  = LT_I_TAXEL
       IT_TAXVALUE_TAB               = LT_I_TAXVALUE
       IT_PRODUCT_TAB                = LS_TTE_DOCUMENT-I_PRODUCT
       IT_PRTAXCL_TAB                = LS_TTE_DOCUMENT-I_PRTAXCL
       IT_PRPROP_TAB                 = LS_TTE_DOCUMENT-I_PRPROP
       IT_PARTNER_TAB                = LS_TTE_DOCUMENT-I_PARTNER
       IT_PATAXCL_TAB                = LS_TTE_DOCUMENT-I_PATAXCL
       IT_PAPROP_TAB                 = LS_TTE_DOCUMENT-I_PAPROP
       IT_PATAXNUM_TAB               = LS_TTE_DOCUMENT-I_PATAXNUM
       IT_CURRCONV_TAB               = LT_I_CURRCONV .

    LOOP AT UT_BDI_WRK INTO LS_BDI_WRK.
      READ TABLE LT_I_ITEM INTO LS_I_ITEM
           WITH KEY ITEMID = LS_BDI_WRK-BDI_GUID.
      IF SY-SUBRC = 0.
        LV_TABIX = SY-TABIX.
        CALL FUNCTION 'CRM_ORDER_ITEM_TYPE_SELECT_CB'
          EXPORTING
            IV_ITEM_TYPE               = LS_BDI_WRK-SRC_ITEM_TYPE
          IMPORTING
            ES_ITEM_TYPE               = LS_CRM_ITEM_TYPE
          EXCEPTIONS
            ENTRY_NOT_FOUND            = 1
            TEXT_ENTRY_NOT_FOUND       = 2
            OTHERS                     = 3.
        IF SY-SUBRC = 0.
          CALL FUNCTION 'CRM_TAX_BUS_PROC_DETERMINE'
            EXPORTING
              IV_BOR_OBJECT_TYPE = LS_CRM_ITEM_TYPE-OBJECT_TYPE
            IMPORTING
              EV_BUS_PROCESS     = LS_I_ITEM-BUSPROCESSTYPE.
          MODIFY LT_I_ITEM FROM LS_I_ITEM INDEX LV_TABIX
                           TRANSPORTING BUSPROCESSTYPE.
        ENDIF.
      ENDIF.
    ENDLOOP.

   call method lr_ttedoc->set_input_document
     exporting
       IT_HEADER_TAB                 = LT_I_HEADER
       IT_ITEM_TAB                   = LT_I_ITEM
       IT_TRANPROP_TAB               = LS_TTE_DOCUMENT-I_TRANPROP
       IT_ORGUNIT_TAB                = LS_TTE_DOCUMENT-I_ORGUNIT
       IT_ITEMPART_TAB               = LS_TTE_DOCUMENT-I_ITEMPART
       IT_PRICEL_TAB                 = LS_TTE_DOCUMENT-I_PRICEL
       IT_TAXDATE_TAB                = LS_TTE_DOCUMENT-I_TAXDATE
       IT_TAXEVENT_TAB               = LT_I_TAXEVENT
       IT_TAXEL_TAB                  = LT_I_TAXEL
       IT_TAXVALUE_TAB               = LT_I_TAXVALUE
       IT_PRODUCT_TAB                = LS_TTE_DOCUMENT-I_PRODUCT
       IT_PRTAXCL_TAB                = LS_TTE_DOCUMENT-I_PRTAXCL
       IT_PRPROP_TAB                 = LS_TTE_DOCUMENT-I_PRPROP
       IT_PARTNER_TAB                = LS_TTE_DOCUMENT-I_PARTNER
       IT_PATAXCL_TAB                = LS_TTE_DOCUMENT-I_PATAXCL
       IT_PAPROP_TAB                 = LS_TTE_DOCUMENT-I_PAPROP
       IT_PATAXNUM_TAB               = LS_TTE_DOCUMENT-I_PATAXNUM
       IT_CURRCONV_TAB               = LT_I_CURRCONV .

* create communication interface to TTE
 create object lr_ttecom type cl_tte_communication.
 lr_ttedoc->TTEDOCUMENTID_COM = US_TTE_HANDLE-PRIDOCGUID.

* call TTE.
 call method lr_ttecom->calculate_taxes
   EXPORTING
     ir_tte_document_ext = lr_ttedoc
   EXCEPTIONS
     COM_FAILURE         = 1
     others              = 2.


  ENDIF.

ENDFORM.
