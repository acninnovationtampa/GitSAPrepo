FUNCTION /1BEA/CRMB_BD_O_GETLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_COMPLIT) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IRT_BDH_ARCHIVABLE) TYPE  BEART_ARCHIVABLE OPTIONAL
*"     REFERENCE(IRT_BDH_BDH_GUID) TYPE  BEART_BDH_GUID OPTIONAL
*"     REFERENCE(IRT_BDH_BILL_CATEGORY) TYPE  BEART_BILL_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_BILL_DATE) TYPE  BEART_BILL_DATE OPTIONAL
*"     REFERENCE(IRT_BDH_BILL_ORG) TYPE  BEART_BILL_ORG OPTIONAL
*"     REFERENCE(IRT_BDH_BILL_TYPE) TYPE  BEART_BILL_TYPE OPTIONAL
*"     REFERENCE(IRT_BDH_CANCEL_FLAG) TYPE  BEART_CANCEL_FLAG
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_CRP_GUID) TYPE  BEART_CRP_GUID OPTIONAL
*"     REFERENCE(IRT_BDH_DOC_CURRENCY) TYPE  BEART_DOC_CURRENCY
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_HEADNO_EXT) TYPE  BEART_HEADNO_EXT OPTIONAL
*"     REFERENCE(IRT_BDH_LOGSYS) TYPE  BEART_LOGSYS OPTIONAL
*"     REFERENCE(IRT_BDH_MAINT_DATE) TYPE  BEART_MAINT_DATE OPTIONAL
*"     REFERENCE(IRT_BDH_MAINT_TIME) TYPE  BEART_MAINT_TIME OPTIONAL
*"     REFERENCE(IRT_BDH_MAINT_USER) TYPE  BEART_MAINT_USER OPTIONAL
*"     REFERENCE(IRT_BDH_NET_VALUE) TYPE  BEART_NET_VALUE OPTIONAL
*"     REFERENCE(IRT_BDH_OBJTYPE) TYPE  BEART_OBJTYPE OPTIONAL
*"     REFERENCE(IRT_BDH_PAYER) TYPE  BEART_PAYER OPTIONAL
*"     REFERENCE(IRT_BDH_PRIC_PROC) TYPE  BEART_PRIC_PROC OPTIONAL
*"     REFERENCE(IRT_BDH_REFERENCE_NO) TYPE  BEART_REFERENCE_NO
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_REF_CURRENCY) TYPE  BEART_REF_CURRENCY
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_SPLIT_CRITERIA) TYPE  BEART_SPLIT_CRITERIA
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_TAX_VALUE) TYPE  BEART_TAX_VALUE OPTIONAL
*"     REFERENCE(IRT_BDH_TERMS_OF_PAYMENT) TYPE
*"                             BEART_TERMS_OF_PAYMENT OPTIONAL
*"     REFERENCE(IRT_BDH_TRANSFER_DATE) TYPE  BEART_TRANSFER_DATE
*"         OPTIONAL
*"     REFERENCE(IRT_BDH_TRANSFER_ERROR) TYPE
*"                             /1BEA/RT_CRMB_TRANSFER_ERROR OPTIONAL
*"     REFERENCE(IRT_BDH_TRANSFER_STATUS) TYPE  BEART_TRANSFER_STATUS
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_BDH_GUID) TYPE  BEART_BDH_GUID OPTIONAL
*"     REFERENCE(IRT_BDI_BDI_GUID) TYPE  BEART_BDI_GUID OPTIONAL
*"     REFERENCE(IRT_BDI_BILL_RELEVANCE) TYPE  BEART_BILL_RELEVANCE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_CREATION_CODE) TYPE  BEART_CREATION_CODE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_CREDIT_DEBIT) TYPE  BEART_CREDIT_DEBIT
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_DIS_CHANNEL) TYPE  /1BEA/RT_CRMB_DIS_CHANNEL
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_DIVISION) TYPE  /1BEA/RT_CRMB_DIVISION
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_DOC_CURRENCY) TYPE  BEART_DOC_CURRENCY
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_EXCHANGE_DATE) TYPE  BEART_EXCHANGE_DATE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_EXCHANGE_RATE) TYPE  BEART_EXCHANGE_RATE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_GROSS_VALUE) TYPE  BEART_GROSS_VALUE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_IS_REVERSED) TYPE  BEART_IS_REVERSED
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_ITEMNO_EXT) TYPE  BEART_ITEMNO_EXT OPTIONAL
*"     REFERENCE(IRT_BDI_ITEM_CATEGORY) TYPE  BEART_ITEM_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_ITEM_TYPE) TYPE  BEART_ITEM_TYPE OPTIONAL
*"     REFERENCE(IRT_BDI_LOGSYS) TYPE  /1BEA/RT_CRMB_LOGSYS OPTIONAL
*"     REFERENCE(IRT_BDI_NET_VALUE) TYPE  BEART_NET_VALUE OPTIONAL
*"     REFERENCE(IRT_BDI_OBJTYPE) TYPE  /1BEA/RT_CRMB_OBJTYPE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_PARENT_ITEMNO) TYPE
*"                             /1BEA/RT_CRMB_PARENT_ITEMNO OPTIONAL
*"     REFERENCE(IRT_BDI_PRODUCT) TYPE  /1BEA/RT_CRMB_PRODUCT
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_PRODUCT_DESCR) TYPE
*"                             /1BEA/RT_CRMB_PRODUCT_DESCR OPTIONAL
*"     REFERENCE(IRT_BDI_REVERSAL) TYPE  BEART_REVERSAL OPTIONAL
*"     REFERENCE(IRT_BDI_SALES_ORG) TYPE  /1BEA/RT_CRMB_SALES_ORG
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SERVICE_ORG) TYPE  /1BEA/RT_CRMB_SERVICE_ORG
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SRC_GUID) TYPE  /1BEA/RT_CRMB_SRC_GUID
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SRC_HEADNO) TYPE  /1BEA/RT_CRMB_SRC_HEADNO
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SRC_ITEMNO) TYPE  /1BEA/RT_CRMB_SRC_ITEMNO
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SRC_ITEM_TYPE) TYPE
*"                             /1BEA/RT_CRMB_SRC_ITEM_TYPE OPTIONAL
*"     REFERENCE(IRT_BDI_SRC_PROCESS_TYPE) TYPE
*"                             /1BEA/RT_CRMB_SRC_PROCESS_TYPE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_SRVDOC_SOURCE) TYPE  BEART_SRVDOC_SOURCE
*"         OPTIONAL
*"     REFERENCE(IRT_BDI_TAX_VALUE) TYPE  BEART_TAX_VALUE OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BAPIMAXROW
*"         DEFAULT                    0
*"  EXPORTING
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(ET_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(ES_RETURN) TYPE  BEAS_RETURN
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
* Time  : 13:52:50
*
*======================================================================
*********************************************************************
* Declaration Part
*********************************************************************
  CONSTANTS: lc_max_range TYPE i VALUE '100'.
  DATA: BEGIN OF LS_BD,
          BDH TYPE /1BEA/S_CRMB_BDH,
          BDI TYPE /1BEA/S_CRMB_BDI,
        END OF LS_BD,
        LS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK,
        LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK,
        LS_RETURN      TYPE BEAS_RETURN,
        LRT_DUMMY      TYPE BEART_BDH_GUID,
        lv_complit     TYPE bea_boolean,
        ls_bdh         TYPE /1bea/s_CRMB_BDH_wrk,
        lrs_bdh_guid   TYPE bears_bdh_guid,
        lrt_bdh_guid   TYPE beart_bdh_guid,
        lt_bdi         TYPE /1bea/t_CRMB_BDI_wrk,
        lv_range_count TYPE i.
*********************************************************************
* Implementation Part
*********************************************************************
*====================================================================
* Prepare and Check
*====================================================================
  CLEAR ET_BDH.
  CLEAR ET_BDI.
  IF NOT ET_BDH IS REQUESTED AND
     NOT ET_BDI IS REQUESTED.
    EXIT.
  ENDIF.
*====================================================================
* Is it necessary and desired to complete items?
*====================================================================
  IF     NOT iv_complit IS INITIAL
     AND (    NOT lrt_dummy IS INITIAL
           OR NOT IRT_BDI_BDH_GUID IS INITIAL
           OR NOT IRT_BDI_BDI_GUID IS INITIAL
           OR NOT IRT_BDI_BILL_RELEVANCE IS INITIAL
           OR NOT IRT_BDI_CREATION_CODE IS INITIAL
           OR NOT IRT_BDI_CREDIT_DEBIT IS INITIAL
           OR NOT IRT_BDI_DIS_CHANNEL IS INITIAL
           OR NOT IRT_BDI_DIVISION IS INITIAL
           OR NOT IRT_BDI_DOC_CURRENCY IS INITIAL
           OR NOT IRT_BDI_EXCHANGE_DATE IS INITIAL
           OR NOT IRT_BDI_EXCHANGE_RATE IS INITIAL
           OR NOT IRT_BDI_GROSS_VALUE IS INITIAL
           OR NOT IRT_BDI_IS_REVERSED IS INITIAL
           OR NOT IRT_BDI_ITEMNO_EXT IS INITIAL
           OR NOT IRT_BDI_ITEM_CATEGORY IS INITIAL
           OR NOT IRT_BDI_ITEM_TYPE IS INITIAL
           OR NOT IRT_BDI_LOGSYS IS INITIAL
           OR NOT IRT_BDI_NET_VALUE IS INITIAL
           OR NOT IRT_BDI_OBJTYPE IS INITIAL
           OR NOT IRT_BDI_PARENT_ITEMNO IS INITIAL
           OR NOT IRT_BDI_PRODUCT IS INITIAL
           OR NOT IRT_BDI_PRODUCT_DESCR IS INITIAL
           OR NOT IRT_BDI_REVERSAL IS INITIAL
           OR NOT IRT_BDI_SALES_ORG IS INITIAL
           OR NOT IRT_BDI_SERVICE_ORG IS INITIAL
           OR NOT IRT_BDI_SRC_GUID IS INITIAL
           OR NOT IRT_BDI_SRC_HEADNO IS INITIAL
           OR NOT IRT_BDI_SRC_ITEMNO IS INITIAL
           OR NOT IRT_BDI_SRC_ITEM_TYPE IS INITIAL
           OR NOT IRT_BDI_SRC_PROCESS_TYPE IS INITIAL
           OR NOT IRT_BDI_SRVDOC_SOURCE IS INITIAL
           OR NOT IRT_BDI_TAX_VALUE IS INITIAL
          ) .
    lv_complit = gc_true.
  ELSE.
    lv_complit = gc_false.
  ENDIF.
*====================================================================
* SELECT all Heads and Items according to the criteria
*====================================================================

    TRY.
    SELECT *
          INTO LS_BD
          FROM /1BEA/CRMB_BDH AS BDH
          JOIN /1BEA/CRMB_BDI AS BDI
          ON BDH~BDH_GUID = BDI~BDH_GUID
          UP TO IV_MAXROWS ROWS
          WHERE BDH~BDH_GUID IN LRT_DUMMY
            AND BDH~ARCHIVABLE IN IRT_BDH_ARCHIVABLE
            AND BDH~BDH_GUID IN IRT_BDH_BDH_GUID
            AND BDH~BILL_CATEGORY IN IRT_BDH_BILL_CATEGORY
            AND BDH~BILL_DATE IN IRT_BDH_BILL_DATE
            AND BDH~BILL_ORG IN IRT_BDH_BILL_ORG
            AND BDH~BILL_TYPE IN IRT_BDH_BILL_TYPE
            AND BDH~CANCEL_FLAG IN IRT_BDH_CANCEL_FLAG
            AND BDH~CRP_GUID IN IRT_BDH_CRP_GUID
            AND BDH~DOC_CURRENCY IN IRT_BDH_DOC_CURRENCY
            AND BDH~HEADNO_EXT IN IRT_BDH_HEADNO_EXT
            AND BDH~LOGSYS IN IRT_BDH_LOGSYS
            AND BDH~MAINT_DATE IN IRT_BDH_MAINT_DATE
            AND BDH~MAINT_TIME IN IRT_BDH_MAINT_TIME
            AND BDH~MAINT_USER IN IRT_BDH_MAINT_USER
            AND BDH~NET_VALUE IN IRT_BDH_NET_VALUE
            AND BDH~OBJTYPE IN IRT_BDH_OBJTYPE
            AND BDH~PAYER IN IRT_BDH_PAYER
            AND BDH~PRIC_PROC IN IRT_BDH_PRIC_PROC
            AND BDH~REFERENCE_NO IN IRT_BDH_REFERENCE_NO
            AND BDH~REF_CURRENCY IN IRT_BDH_REF_CURRENCY
            AND BDH~SPLIT_CRITERIA IN IRT_BDH_SPLIT_CRITERIA
            AND BDH~TAX_VALUE IN IRT_BDH_TAX_VALUE
            AND BDH~TERMS_OF_PAYMENT IN IRT_BDH_TERMS_OF_PAYMENT
            AND BDH~TRANSFER_DATE IN IRT_BDH_TRANSFER_DATE
            AND BDH~TRANSFER_ERROR IN IRT_BDH_TRANSFER_ERROR
            AND BDH~TRANSFER_STATUS IN IRT_BDH_TRANSFER_STATUS
            AND BDI~BDH_GUID IN IRT_BDI_BDH_GUID
            AND BDI~BDI_GUID IN IRT_BDI_BDI_GUID
            AND BDI~BILL_RELEVANCE IN IRT_BDI_BILL_RELEVANCE
            AND BDI~CREATION_CODE IN IRT_BDI_CREATION_CODE
            AND BDI~CREDIT_DEBIT IN IRT_BDI_CREDIT_DEBIT
            AND BDI~DIS_CHANNEL IN IRT_BDI_DIS_CHANNEL
            AND BDI~DIVISION IN IRT_BDI_DIVISION
            AND BDI~DOC_CURRENCY IN IRT_BDI_DOC_CURRENCY
            AND BDI~EXCHANGE_DATE IN IRT_BDI_EXCHANGE_DATE
            AND BDI~EXCHANGE_RATE IN IRT_BDI_EXCHANGE_RATE
            AND BDI~GROSS_VALUE IN IRT_BDI_GROSS_VALUE
            AND BDI~IS_REVERSED IN IRT_BDI_IS_REVERSED
            AND BDI~ITEMNO_EXT IN IRT_BDI_ITEMNO_EXT
            AND BDI~ITEM_CATEGORY IN IRT_BDI_ITEM_CATEGORY
            AND BDI~ITEM_TYPE IN IRT_BDI_ITEM_TYPE
            AND BDI~LOGSYS IN IRT_BDI_LOGSYS
            AND BDI~NET_VALUE IN IRT_BDI_NET_VALUE
            AND BDI~OBJTYPE IN IRT_BDI_OBJTYPE
            AND BDI~PARENT_ITEMNO IN IRT_BDI_PARENT_ITEMNO
            AND BDI~PRODUCT IN IRT_BDI_PRODUCT
            AND BDI~PRODUCT_DESCR IN IRT_BDI_PRODUCT_DESCR
            AND BDI~REVERSAL IN IRT_BDI_REVERSAL
            AND BDI~SALES_ORG IN IRT_BDI_SALES_ORG
            AND BDI~SERVICE_ORG IN IRT_BDI_SERVICE_ORG
            AND BDI~SRC_GUID IN IRT_BDI_SRC_GUID
            AND BDI~SRC_HEADNO IN IRT_BDI_SRC_HEADNO
            AND BDI~SRC_ITEMNO IN IRT_BDI_SRC_ITEMNO
            AND BDI~SRC_ITEM_TYPE IN IRT_BDI_SRC_ITEM_TYPE
            AND BDI~SRC_PROCESS_TYPE IN IRT_BDI_SRC_PROCESS_TYPE
            AND BDI~SRVDOC_SOURCE IN IRT_BDI_SRVDOC_SOURCE
            AND BDI~TAX_VALUE IN IRT_BDI_TAX_VALUE
            .
      IF    ET_BDH IS REQUESTED
        OR NOT lv_complit IS INITIAL. " in this case, we need et_bdh
                                      " to complete the items
        READ TABLE ET_BDH TRANSPORTING NO FIELDS
                          WITH KEY BDH_GUID = LS_BD-BDH-BDH_GUID
                          BINARY SEARCH.
        CASE SY-SUBRC.
          WHEN 4.
            MOVE-CORRESPONDING LS_BD-BDH TO LS_BDH_WRK.
            INSERT LS_BDH_WRK INTO ET_BDH INDEX SY-TABIX.
          WHEN 8.
            MOVE-CORRESPONDING LS_BD-BDH TO LS_BDH_WRK.
            APPEND LS_BDH_WRK TO ET_BDH.
        ENDCASE.
      ENDIF.
      IF     ET_BDI IS REQUESTED
        AND lv_complit IS INITIAL. " otherwise the items are
                                    " selected afterwards
        MOVE-CORRESPONDING LS_BD-BDI TO LS_BDI_WRK.
        APPEND LS_BDI_WRK TO ET_BDI.
      ENDIF.
    ENDSELECT.

    CATCH CX_SY_OPEN_SQL_DB.
      IF ES_RETURN IS REQUESTED.
        MESSAGE E180(BEA) INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
          EXPORTING
            IV_OBJECT      = 'BD'
            IV_CONTAINER   = 'BDH'
          IMPORTING
            ES_RETURN          = ES_RETURN.
      ELSE.
       MESSAGE E180(BEA).
      ENDIF.
      EXIT.
    ENDTRY.
*====================================================================
* Now, complete eventually items -> Complete Documents
*====================================================================
  IF    NOT lv_complit IS INITIAL
    AND et_bdi IS REQUESTED.
    CLEAR: lv_range_count, lrt_bdh_guid, lrs_bdh_guid.
    lrs_bdh_guid-sign   = gc_include.
    lrs_bdh_guid-option = gc_equal.
    LOOP AT et_bdh INTO ls_bdh.
      ADD 1 TO lv_range_count.
      lrs_bdh_guid-low = ls_bdh-bdh_guid.
      APPEND lrs_bdh_guid TO lrt_bdh_guid.
      IF lv_range_count GE lc_max_range.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
          EXPORTING
            irt_bdh_guid = lrt_bdh_guid
          IMPORTING
            ET_BDI       = lt_bdi.
        APPEND LINES OF lt_bdi TO et_bdi.
        CLEAR: lrt_bdh_guid, lv_range_count.
      ENDIF.
    ENDLOOP.
    IF NOT lv_range_count IS INITIAL.
       CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
         EXPORTING
           irt_bdh_guid = lrt_bdh_guid
         IMPORTING
           ET_BDI       = lt_bdi.
       APPEND LINES OF lt_bdi TO et_bdi.
    ENDIF.
  ENDIF.
ENDFUNCTION.