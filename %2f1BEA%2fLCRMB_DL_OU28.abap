FUNCTION /1BEA/CRMB_DL_O_BUFFER_MODIFY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_ADD_CRITERIA) TYPE  BEA_ADD_CRITERIA OPTIONAL
*"     REFERENCE(IV_BASE_TIMEZONE) TYPE  PRCT_BASE_TIMEZONE OPTIONAL
*"     REFERENCE(IV_BASE_TIME_FROM) TYPE  PRCT_BASE_TIME_FROM
*"         OPTIONAL
*"     REFERENCE(IV_BASE_TIME_TO) TYPE  PRCT_BASE_TIME_TO OPTIONAL
*"     REFERENCE(IV_BILL_TO_GUID) TYPE  CRMT_BILL_TO_PARTY OPTIONAL
*"     REFERENCE(IV_BUSINESSSCENARIO) TYPE  BEA_BUSINESS_SCENARIO
*"         OPTIONAL
*"     REFERENCE(IV_DERIV_CATEGORY) TYPE  BEA_DERIV_CATEGORY OPTIONAL
*"     REFERENCE(IV_DG_LOGSYS) TYPE  BEA_LOGSYS OPTIONAL
*"     REFERENCE(IV_DG_OBJTYPE) TYPE  BEA_OBJTYPE OPTIONAL
*"     REFERENCE(IV_DG_SRC_HEADNO) TYPE  BEA_SRC_HEADNO OPTIONAL
*"     REFERENCE(IV_DG_SRC_ITEMNO) TYPE  BEA_SRC_ITEMNO OPTIONAL
*"     REFERENCE(IV_DIRECT_BILLING) TYPE  BEA_DIRECT_BILLING OPTIONAL
*"     REFERENCE(IV_DIS_CHANNEL) TYPE  CRMT_DISTRIBUTION_CHANNEL
*"         OPTIONAL
*"     REFERENCE(IV_DIVISION) TYPE  CRMT_DIVISION OPTIONAL
*"     REFERENCE(IV_DIVISION_H) TYPE  BEA_DIVISION_H OPTIONAL
*"     REFERENCE(IV_DOC_CURRENCY) TYPE  CRMT_CURRENCY OPTIONAL
*"     REFERENCE(IV_EXCHANGE_DATE) TYPE  CRMT_EXCHG_DATE OPTIONAL
*"     REFERENCE(IV_EXCHANGE_RATE) TYPE  CRMT_EXCHG_RATE OPTIONAL
*"     REFERENCE(IV_EXCHANGE_TYPE) TYPE  CRMT_EXCHG_TYPE OPTIONAL
*"     REFERENCE(IV_GROSS_WEIGHT) TYPE  CRMT_GROSS_WEIGHT OPTIONAL
*"     REFERENCE(IV_INCOTERMS1) TYPE  CRMT_INCOTERMS1 OPTIONAL
*"     REFERENCE(IV_INCOTERMS2) TYPE  CRMT_INCOTERMS2 OPTIONAL
*"     REFERENCE(IV_INDICATOR_IC) TYPE  BEA_INDICATOR_IC OPTIONAL
*"     REFERENCE(IV_INVCR_DATE) TYPE  BEA_INVCR_DATE OPTIONAL
*"     REFERENCE(IV_LOGSYS) TYPE  CRMT_LOGSYS OPTIONAL
*"     REFERENCE(IV_NET_VALUE) TYPE  CRMT_NET_VALUE OPTIONAL
*"     REFERENCE(IV_NET_VALUE_MAN) TYPE  CRMT_NET_VALUE_MAN OPTIONAL
*"     REFERENCE(IV_NET_WEIGHT) TYPE  CRMT_NET_WEIGHT OPTIONAL
*"     REFERENCE(IV_OBJTYPE) TYPE  BEA_OBJTYPE OPTIONAL
*"     REFERENCE(IV_PARENT_ITEMNO) TYPE  BEA_PARENT_ITEMNO OPTIONAL
*"     REFERENCE(IV_PARSET_GUID) TYPE  BEA_PARSET_GUID OPTIONAL
*"     REFERENCE(IV_PAYER_GUID) TYPE  CRMT_PAYER OPTIONAL
*"     REFERENCE(IV_PAYMENT_METHOD) TYPE  DZLSCH OPTIONAL
*"     REFERENCE(IV_PRC_INDICATOR) TYPE  CRMT_PRICING_INDICATOR
*"         OPTIONAL
*"     REFERENCE(IV_PRC_SESSION_ID) TYPE  BEA_PRC_SESSION_ID OPTIONAL
*"     REFERENCE(IV_PRICING_DATE) TYPE  CRMT_PRICE_DATE OPTIONAL
*"     REFERENCE(IV_PRIDOC_GUID) TYPE  BEA_PRIDOC_GUID OPTIONAL
*"     REFERENCE(IV_PROC_QTY_DEN) TYPE  CRMT_PROCESS_QTY_DEN OPTIONAL
*"     REFERENCE(IV_PROC_QTY_EXP10) TYPE  CRMT_EXPONENT10 OPTIONAL
*"     REFERENCE(IV_PROC_QTY_NUM) TYPE  CRMT_PROCESS_QTY_NUM OPTIONAL
*"     REFERENCE(IV_PRODUCT) TYPE  COMT_PRODUCT_GUID OPTIONAL
*"     REFERENCE(IV_PRODUCT_DESCR) TYPE  COMT_PRSHTEXTX OPTIONAL
*"     REFERENCE(IV_P_LOGSYS) TYPE  CRMT_LOGSYS OPTIONAL
*"     REFERENCE(IV_P_OBJTYPE) TYPE  BEA_OBJTYPE OPTIONAL
*"     REFERENCE(IV_P_SRC_HEADNO) TYPE  BEA_P_SRC_HEADNO OPTIONAL
*"     REFERENCE(IV_P_SRC_ITEMNO) TYPE  CRMT_ITEM_NO OPTIONAL
*"     REFERENCE(IV_QTY_UNIT) TYPE  CRMT_PROCESS_QTY_UNIT OPTIONAL
*"     REFERENCE(IV_QUANTITY) TYPE  BEA_QUANTITY OPTIONAL
*"     REFERENCE(IV_REFERENCE_NO) TYPE  BEA_REFERENCE_NO OPTIONAL
*"     REFERENCE(IV_REF_CURRENCY) TYPE  CRMT_REF_CURRENCY OPTIONAL
*"     REFERENCE(IV_RENDERED_DATE) TYPE  BEA_RENDERED_DATE OPTIONAL
*"     REFERENCE(IV_SALES_ORG) TYPE  CRMT_SALES_ORG OPTIONAL
*"     REFERENCE(IV_SERVICE_ORG) TYPE  CRMT_SERVICE_ORG OPTIONAL
*"     REFERENCE(IV_SERVICE_TYPE) TYPE  CRMT_SERVICE_TYPE OPTIONAL
*"     REFERENCE(IV_SOLD_TO_GUID) TYPE  CRMT_SOLD_TO_PARTY OPTIONAL
*"     REFERENCE(IV_SOLD_TO_PARTY) TYPE  CRMT_SOLD_TO_PARTY_ID
*"         OPTIONAL
*"     REFERENCE(IV_SRC_BILL_BLOCK) TYPE  BEA_BILLING_BLOCK OPTIONAL
*"     REFERENCE(IV_SRC_DATE) TYPE  SYSTDATLO OPTIONAL
*"     REFERENCE(IV_SRC_GUID) TYPE  CRMT_OBJECT_GUID OPTIONAL
*"     REFERENCE(IV_SRC_HEADNO) TYPE  BEA_SRC_HEADNO OPTIONAL
*"     REFERENCE(IV_SRC_ITEMNO) TYPE  CRMT_ITEM_NO OPTIONAL
*"     REFERENCE(IV_SRC_ITEM_TYPE) TYPE  CRMT_ITEM_TYPE OPTIONAL
*"     REFERENCE(IV_SRC_PRC_GUID) TYPE  CRMT_OBJECT_GUID OPTIONAL
*"     REFERENCE(IV_SRC_PROCESS_TYPE) TYPE  CRMT_PROCESS_TYPE
*"         OPTIONAL
*"     REFERENCE(IV_SRC_REJECT) TYPE  BEA_REJECT OPTIONAL
*"     REFERENCE(IV_SRC_USER) TYPE  BEA_CREATE_USER OPTIONAL
*"     REFERENCE(IV_TAX_DEST_COUNTRY) TYPE  CRMT_TAX_DEST_CTY
*"         OPTIONAL
*"     REFERENCE(IV_TRANSFER_DATE) TYPE  BEA_TRANSFER_DATE OPTIONAL
*"     REFERENCE(IV_VALUATION_TYPE) TYPE  CRMT_VALUATION_TYPE
*"         OPTIONAL
*"     REFERENCE(IV_VENDOR) TYPE  BU_PARTNER_GUID OPTIONAL
*"     REFERENCE(IV_WEIGHT_UNIT) TYPE  COMT_WEIGHT_UNIT OPTIONAL
*"     REFERENCE(IV_CLIENT) TYPE  MANDT OPTIONAL
*"     REFERENCE(IV_DLI_GUID) TYPE  BEA_DLI_GUID OPTIONAL
*"     REFERENCE(IV_BDI_GUID) TYPE  BEA_BDI_GUID OPTIONAL
*"     REFERENCE(IV_ITEM_CATEGORY) TYPE  BEA_ITEM_CATEGORY OPTIONAL
*"     REFERENCE(IV_ITEM_TYPE) TYPE  BEA_ITEM_TYPE OPTIONAL
*"     REFERENCE(IV_BILL_TYPE) TYPE  BEA_BILL_TYPE OPTIONAL
*"     REFERENCE(IV_BILL_CATEGORY) TYPE  BEA_BILL_CATEGORY OPTIONAL
*"     REFERENCE(IV_BILL_ORG) TYPE  BEA_BILL_ORG OPTIONAL
*"     REFERENCE(IV_BILL_DATE) TYPE  BEA_BILL_DATE OPTIONAL
*"     REFERENCE(IV_BILL_RELEVANCE) TYPE  BEA_BILL_RELEVANCE OPTIONAL
*"     REFERENCE(IV_SRVDOC_SOURCE) TYPE  BEA_SRVDOC_SOURCE OPTIONAL
*"     REFERENCE(IV_INCOMP_ID) TYPE  BEA_INCOMP_ID OPTIONAL
*"     REFERENCE(IV_CREDIT_DEBIT) TYPE  BEA_CREDIT_DEBIT OPTIONAL
*"     REFERENCE(IV_PAYER) TYPE  BEA_PAYER OPTIONAL
*"     REFERENCE(IV_TERMS_OF_PAYMENT) TYPE  BEA_TERMS_OF_PAYMENT
*"         OPTIONAL
*"     REFERENCE(IV_BILL_STATUS) TYPE  BEA_BILL_STATUS OPTIONAL
*"     REFERENCE(IV_BILL_BLOCK) TYPE  BEA_BILL_BLOCK OPTIONAL
*"     REFERENCE(IV_MAINT_DATE) TYPE  BEA_MAINT_DATE OPTIONAL
*"     REFERENCE(IV_MAINT_TIME) TYPE  BEA_MAINT_TIME OPTIONAL
*"     REFERENCE(IV_MAINT_USER) TYPE  BEA_MAINT_USER OPTIONAL
*"     REFERENCE(IV_UPD_TYPE) TYPE  UPDATE_TYPE OPTIONAL
*"     REFERENCE(IV_DLI_UITYPE) TYPE  BEA_DLI_UITYPE OPTIONAL
*"     REFERENCE(IV_SPLIT_CRITERIA) TYPE  BEA_SPLIT_CRITERIA OPTIONAL
*"     REFERENCE(IV_LOGHNDL) TYPE  BALLOGHNDL OPTIONAL
*"     REFERENCE(IV_SRC_HEADNO_BSGL) TYPE  BEA_SRC_HEADNO_BSGL
*"         OPTIONAL
*"     REFERENCE(IV_BILL_TYPE_D) TYPE  BEA_BILL_TYPE_D OPTIONAL
*"     REFERENCE(IV_BILL_DATE_D) TYPE  BEA_BILL_DATE_D OPTIONAL
*"     REFERENCE(IV_RENDERED_DATE_D) TYPE  BEA_RENDERED_DATE_D
*"         OPTIONAL
*"     REFERENCE(IV_PRICING_DATE_D) TYPE  BEA_PRICING_DATE_D OPTIONAL
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
* Time  : 13:53:10
*
*======================================================================
DATA :
  LS_DLI_WRK_HLP TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK,
  LV_TABIX           TYPE SYTABIX.

  SORT GT_DLI_WRK BY DLI_GUID.
  LOOP AT IT_DLI_WRK INTO LS_DLI_WRK_HLP.
    READ TABLE GT_DLI_WRK
      WITH KEY DLI_GUID = LS_DLI_WRK_HLP-DLI_GUID
      INTO LS_DLI_WRK
      BINARY SEARCH.
    LV_TABIX = SY-TABIX.
    IF SY-SUBRC IS INITIAL.
      IF IV_ADD_CRITERIA IS SUPPLIED.
        LS_DLI_WRK-ADD_CRITERIA = IV_ADD_CRITERIA.
      ENDIF.
      IF IV_BASE_TIMEZONE IS SUPPLIED.
        LS_DLI_WRK-BASE_TIMEZONE = IV_BASE_TIMEZONE.
      ENDIF.
      IF IV_BASE_TIME_FROM IS SUPPLIED.
        LS_DLI_WRK-BASE_TIME_FROM = IV_BASE_TIME_FROM.
      ENDIF.
      IF IV_BASE_TIME_TO IS SUPPLIED.
        LS_DLI_WRK-BASE_TIME_TO = IV_BASE_TIME_TO.
      ENDIF.
      IF IV_BILL_TO_GUID IS SUPPLIED.
        LS_DLI_WRK-BILL_TO_GUID = IV_BILL_TO_GUID.
      ENDIF.
      IF IV_BUSINESSSCENARIO IS SUPPLIED.
        LS_DLI_WRK-BUSINESSSCENARIO = IV_BUSINESSSCENARIO.
      ENDIF.
      IF IV_DERIV_CATEGORY IS SUPPLIED.
        LS_DLI_WRK-DERIV_CATEGORY = IV_DERIV_CATEGORY.
      ENDIF.
      IF IV_DG_LOGSYS IS SUPPLIED.
        LS_DLI_WRK-DG_LOGSYS = IV_DG_LOGSYS.
      ENDIF.
      IF IV_DG_OBJTYPE IS SUPPLIED.
        LS_DLI_WRK-DG_OBJTYPE = IV_DG_OBJTYPE.
      ENDIF.
      IF IV_DG_SRC_HEADNO IS SUPPLIED.
        LS_DLI_WRK-DG_SRC_HEADNO = IV_DG_SRC_HEADNO.
      ENDIF.
      IF IV_DG_SRC_ITEMNO IS SUPPLIED.
        LS_DLI_WRK-DG_SRC_ITEMNO = IV_DG_SRC_ITEMNO.
      ENDIF.
      IF IV_DIRECT_BILLING IS SUPPLIED.
        LS_DLI_WRK-DIRECT_BILLING = IV_DIRECT_BILLING.
      ENDIF.
      IF IV_DIS_CHANNEL IS SUPPLIED.
        LS_DLI_WRK-DIS_CHANNEL = IV_DIS_CHANNEL.
      ENDIF.
      IF IV_DIVISION IS SUPPLIED.
        LS_DLI_WRK-DIVISION = IV_DIVISION.
      ENDIF.
      IF IV_DIVISION_H IS SUPPLIED.
        LS_DLI_WRK-DIVISION_H = IV_DIVISION_H.
      ENDIF.
      IF IV_DOC_CURRENCY IS SUPPLIED.
        LS_DLI_WRK-DOC_CURRENCY = IV_DOC_CURRENCY.
      ENDIF.
      IF IV_EXCHANGE_DATE IS SUPPLIED.
        LS_DLI_WRK-EXCHANGE_DATE = IV_EXCHANGE_DATE.
      ENDIF.
      IF IV_EXCHANGE_RATE IS SUPPLIED.
        LS_DLI_WRK-EXCHANGE_RATE = IV_EXCHANGE_RATE.
      ENDIF.
      IF IV_EXCHANGE_TYPE IS SUPPLIED.
        LS_DLI_WRK-EXCHANGE_TYPE = IV_EXCHANGE_TYPE.
      ENDIF.
      IF IV_GROSS_WEIGHT IS SUPPLIED.
        LS_DLI_WRK-GROSS_WEIGHT = IV_GROSS_WEIGHT.
      ENDIF.
      IF IV_INCOTERMS1 IS SUPPLIED.
        LS_DLI_WRK-INCOTERMS1 = IV_INCOTERMS1.
      ENDIF.
      IF IV_INCOTERMS2 IS SUPPLIED.
        LS_DLI_WRK-INCOTERMS2 = IV_INCOTERMS2.
      ENDIF.
      IF IV_INDICATOR_IC IS SUPPLIED.
        LS_DLI_WRK-INDICATOR_IC = IV_INDICATOR_IC.
      ENDIF.
      IF IV_INVCR_DATE IS SUPPLIED.
        LS_DLI_WRK-INVCR_DATE = IV_INVCR_DATE.
      ENDIF.
      IF IV_LOGSYS IS SUPPLIED.
        LS_DLI_WRK-LOGSYS = IV_LOGSYS.
      ENDIF.
      IF IV_NET_VALUE IS SUPPLIED.
        LS_DLI_WRK-NET_VALUE = IV_NET_VALUE.
      ENDIF.
      IF IV_NET_VALUE_MAN IS SUPPLIED.
        LS_DLI_WRK-NET_VALUE_MAN = IV_NET_VALUE_MAN.
      ENDIF.
      IF IV_NET_WEIGHT IS SUPPLIED.
        LS_DLI_WRK-NET_WEIGHT = IV_NET_WEIGHT.
      ENDIF.
      IF IV_OBJTYPE IS SUPPLIED.
        LS_DLI_WRK-OBJTYPE = IV_OBJTYPE.
      ENDIF.
      IF IV_PARENT_ITEMNO IS SUPPLIED.
        LS_DLI_WRK-PARENT_ITEMNO = IV_PARENT_ITEMNO.
      ENDIF.
      IF IV_PARSET_GUID IS SUPPLIED.
        LS_DLI_WRK-PARSET_GUID = IV_PARSET_GUID.
      ENDIF.
      IF IV_PAYER_GUID IS SUPPLIED.
        LS_DLI_WRK-PAYER_GUID = IV_PAYER_GUID.
      ENDIF.
      IF IV_PAYMENT_METHOD IS SUPPLIED.
        LS_DLI_WRK-PAYMENT_METHOD = IV_PAYMENT_METHOD.
      ENDIF.
      IF IV_PRC_INDICATOR IS SUPPLIED.
        LS_DLI_WRK-PRC_INDICATOR = IV_PRC_INDICATOR.
      ENDIF.
      IF IV_PRC_SESSION_ID IS SUPPLIED.
        LS_DLI_WRK-PRC_SESSION_ID = IV_PRC_SESSION_ID.
      ENDIF.
      IF IV_PRICING_DATE IS SUPPLIED.
        LS_DLI_WRK-PRICING_DATE = IV_PRICING_DATE.
      ENDIF.
      IF IV_PRIDOC_GUID IS SUPPLIED.
        LS_DLI_WRK-PRIDOC_GUID = IV_PRIDOC_GUID.
      ENDIF.
      IF IV_PROC_QTY_DEN IS SUPPLIED.
        LS_DLI_WRK-PROC_QTY_DEN = IV_PROC_QTY_DEN.
      ENDIF.
      IF IV_PROC_QTY_EXP10 IS SUPPLIED.
        LS_DLI_WRK-PROC_QTY_EXP10 = IV_PROC_QTY_EXP10.
      ENDIF.
      IF IV_PROC_QTY_NUM IS SUPPLIED.
        LS_DLI_WRK-PROC_QTY_NUM = IV_PROC_QTY_NUM.
      ENDIF.
      IF IV_PRODUCT IS SUPPLIED.
        LS_DLI_WRK-PRODUCT = IV_PRODUCT.
      ENDIF.
      IF IV_PRODUCT_DESCR IS SUPPLIED.
        LS_DLI_WRK-PRODUCT_DESCR = IV_PRODUCT_DESCR.
      ENDIF.
      IF IV_P_LOGSYS IS SUPPLIED.
        LS_DLI_WRK-P_LOGSYS = IV_P_LOGSYS.
      ENDIF.
      IF IV_P_OBJTYPE IS SUPPLIED.
        LS_DLI_WRK-P_OBJTYPE = IV_P_OBJTYPE.
      ENDIF.
      IF IV_P_SRC_HEADNO IS SUPPLIED.
        LS_DLI_WRK-P_SRC_HEADNO = IV_P_SRC_HEADNO.
      ENDIF.
      IF IV_P_SRC_ITEMNO IS SUPPLIED.
        LS_DLI_WRK-P_SRC_ITEMNO = IV_P_SRC_ITEMNO.
      ENDIF.
      IF IV_QTY_UNIT IS SUPPLIED.
        LS_DLI_WRK-QTY_UNIT = IV_QTY_UNIT.
      ENDIF.
      IF IV_QUANTITY IS SUPPLIED.
        LS_DLI_WRK-QUANTITY = IV_QUANTITY.
      ENDIF.
      IF IV_REFERENCE_NO IS SUPPLIED.
        LS_DLI_WRK-REFERENCE_NO = IV_REFERENCE_NO.
      ENDIF.
      IF IV_REF_CURRENCY IS SUPPLIED.
        LS_DLI_WRK-REF_CURRENCY = IV_REF_CURRENCY.
      ENDIF.
      IF IV_RENDERED_DATE IS SUPPLIED.
        LS_DLI_WRK-RENDERED_DATE = IV_RENDERED_DATE.
      ENDIF.
      IF IV_SALES_ORG IS SUPPLIED.
        LS_DLI_WRK-SALES_ORG = IV_SALES_ORG.
      ENDIF.
      IF IV_SERVICE_ORG IS SUPPLIED.
        LS_DLI_WRK-SERVICE_ORG = IV_SERVICE_ORG.
      ENDIF.
      IF IV_SERVICE_TYPE IS SUPPLIED.
        LS_DLI_WRK-SERVICE_TYPE = IV_SERVICE_TYPE.
      ENDIF.
      IF IV_SOLD_TO_GUID IS SUPPLIED.
        LS_DLI_WRK-SOLD_TO_GUID = IV_SOLD_TO_GUID.
      ENDIF.
      IF IV_SOLD_TO_PARTY IS SUPPLIED.
        LS_DLI_WRK-SOLD_TO_PARTY = IV_SOLD_TO_PARTY.
      ENDIF.
      IF IV_SRC_BILL_BLOCK IS SUPPLIED.
        LS_DLI_WRK-SRC_BILL_BLOCK = IV_SRC_BILL_BLOCK.
      ENDIF.
      IF IV_SRC_DATE IS SUPPLIED.
        LS_DLI_WRK-SRC_DATE = IV_SRC_DATE.
      ENDIF.
      IF IV_SRC_GUID IS SUPPLIED.
        LS_DLI_WRK-SRC_GUID = IV_SRC_GUID.
      ENDIF.
      IF IV_SRC_HEADNO IS SUPPLIED.
        LS_DLI_WRK-SRC_HEADNO = IV_SRC_HEADNO.
      ENDIF.
      IF IV_SRC_ITEMNO IS SUPPLIED.
        LS_DLI_WRK-SRC_ITEMNO = IV_SRC_ITEMNO.
      ENDIF.
      IF IV_SRC_ITEM_TYPE IS SUPPLIED.
        LS_DLI_WRK-SRC_ITEM_TYPE = IV_SRC_ITEM_TYPE.
      ENDIF.
      IF IV_SRC_PRC_GUID IS SUPPLIED.
        LS_DLI_WRK-SRC_PRC_GUID = IV_SRC_PRC_GUID.
      ENDIF.
      IF IV_SRC_PROCESS_TYPE IS SUPPLIED.
        LS_DLI_WRK-SRC_PROCESS_TYPE = IV_SRC_PROCESS_TYPE.
      ENDIF.
      IF IV_SRC_REJECT IS SUPPLIED.
        LS_DLI_WRK-SRC_REJECT = IV_SRC_REJECT.
      ENDIF.
      IF IV_SRC_USER IS SUPPLIED.
        LS_DLI_WRK-SRC_USER = IV_SRC_USER.
      ENDIF.
      IF IV_TAX_DEST_COUNTRY IS SUPPLIED.
        LS_DLI_WRK-TAX_DEST_COUNTRY = IV_TAX_DEST_COUNTRY.
      ENDIF.
      IF IV_TRANSFER_DATE IS SUPPLIED.
        LS_DLI_WRK-TRANSFER_DATE = IV_TRANSFER_DATE.
      ENDIF.
      IF IV_VALUATION_TYPE IS SUPPLIED.
        LS_DLI_WRK-VALUATION_TYPE = IV_VALUATION_TYPE.
      ENDIF.
      IF IV_VENDOR IS SUPPLIED.
        LS_DLI_WRK-VENDOR = IV_VENDOR.
      ENDIF.
      IF IV_WEIGHT_UNIT IS SUPPLIED.
        LS_DLI_WRK-WEIGHT_UNIT = IV_WEIGHT_UNIT.
      ENDIF.
      IF IV_CLIENT IS SUPPLIED.
        LS_DLI_WRK-CLIENT = IV_CLIENT.
      ENDIF.
      IF IV_DLI_GUID IS SUPPLIED.
        LS_DLI_WRK-DLI_GUID = IV_DLI_GUID.
      ENDIF.
      IF IV_BDI_GUID IS SUPPLIED.
        LS_DLI_WRK-BDI_GUID = IV_BDI_GUID.
      ENDIF.
      IF IV_ITEM_CATEGORY IS SUPPLIED.
        LS_DLI_WRK-ITEM_CATEGORY = IV_ITEM_CATEGORY.
      ENDIF.
      IF IV_ITEM_TYPE IS SUPPLIED.
        LS_DLI_WRK-ITEM_TYPE = IV_ITEM_TYPE.
      ENDIF.
      IF IV_BILL_TYPE IS SUPPLIED.
        LS_DLI_WRK-BILL_TYPE = IV_BILL_TYPE.
      ENDIF.
      IF IV_BILL_CATEGORY IS SUPPLIED.
        LS_DLI_WRK-BILL_CATEGORY = IV_BILL_CATEGORY.
      ENDIF.
      IF IV_BILL_ORG IS SUPPLIED.
        LS_DLI_WRK-BILL_ORG = IV_BILL_ORG.
      ENDIF.
      IF IV_BILL_DATE IS SUPPLIED.
        LS_DLI_WRK-BILL_DATE = IV_BILL_DATE.
      ENDIF.
      IF IV_BILL_RELEVANCE IS SUPPLIED.
        LS_DLI_WRK-BILL_RELEVANCE = IV_BILL_RELEVANCE.
      ENDIF.
      IF IV_SRVDOC_SOURCE IS SUPPLIED.
        LS_DLI_WRK-SRVDOC_SOURCE = IV_SRVDOC_SOURCE.
      ENDIF.
      IF IV_INCOMP_ID IS SUPPLIED.
        LS_DLI_WRK-INCOMP_ID = IV_INCOMP_ID.
      ENDIF.
      IF IV_CREDIT_DEBIT IS SUPPLIED.
        LS_DLI_WRK-CREDIT_DEBIT = IV_CREDIT_DEBIT.
      ENDIF.
      IF IV_PAYER IS SUPPLIED.
        LS_DLI_WRK-PAYER = IV_PAYER.
      ENDIF.
      IF IV_TERMS_OF_PAYMENT IS SUPPLIED.
        LS_DLI_WRK-TERMS_OF_PAYMENT = IV_TERMS_OF_PAYMENT.
      ENDIF.
      IF IV_BILL_STATUS IS SUPPLIED.
        LS_DLI_WRK-BILL_STATUS = IV_BILL_STATUS.
      ENDIF.
      IF IV_BILL_BLOCK IS SUPPLIED.
        LS_DLI_WRK-BILL_BLOCK = IV_BILL_BLOCK.
      ENDIF.
      IF IV_MAINT_DATE IS SUPPLIED.
        LS_DLI_WRK-MAINT_DATE = IV_MAINT_DATE.
      ENDIF.
      IF IV_MAINT_TIME IS SUPPLIED.
        LS_DLI_WRK-MAINT_TIME = IV_MAINT_TIME.
      ENDIF.
      IF IV_MAINT_USER IS SUPPLIED.
        LS_DLI_WRK-MAINT_USER = IV_MAINT_USER.
      ENDIF.
      IF IV_UPD_TYPE IS SUPPLIED.
        LS_DLI_WRK-UPD_TYPE = IV_UPD_TYPE.
      ENDIF.
      IF IV_DLI_UITYPE IS SUPPLIED.
        LS_DLI_WRK-DLI_UITYPE = IV_DLI_UITYPE.
      ENDIF.
      IF IV_SPLIT_CRITERIA IS SUPPLIED.
        LS_DLI_WRK-SPLIT_CRITERIA = IV_SPLIT_CRITERIA.
      ENDIF.
      IF IV_LOGHNDL IS SUPPLIED.
        LS_DLI_WRK-LOGHNDL = IV_LOGHNDL.
      ENDIF.
      IF IV_SRC_HEADNO_BSGL IS SUPPLIED.
        LS_DLI_WRK-SRC_HEADNO_BSGL = IV_SRC_HEADNO_BSGL.
      ENDIF.
      IF IV_BILL_TYPE_D IS SUPPLIED.
        LS_DLI_WRK-BILL_TYPE_D = IV_BILL_TYPE_D.
      ENDIF.
      IF IV_BILL_DATE_D IS SUPPLIED.
        LS_DLI_WRK-BILL_DATE_D = IV_BILL_DATE_D.
      ENDIF.
      IF IV_RENDERED_DATE_D IS SUPPLIED.
        LS_DLI_WRK-RENDERED_DATE_D = IV_RENDERED_DATE_D.
      ENDIF.
      IF IV_PRICING_DATE_D IS SUPPLIED.
        LS_DLI_WRK-PRICING_DATE_D = IV_PRICING_DATE_D.
      ENDIF.
      MODIFY GT_DLI_WRK FROM LS_DLI_WRK INDEX LV_TABIX.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
