FUNCTION /1BEA/CRMB_DL_O_GETLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_SORTREL) TYPE  BEA_SORTREL OPTIONAL
*"     REFERENCE(IV_AUTH_CHECK_DLI) TYPE  BEA_BOOLEAN DEFAULT SPACE
*"     REFERENCE(IV_AUTH_CHECK_BDH) TYPE  BEA_BOOLEAN DEFAULT SPACE
*"     REFERENCE(IRT_BDI_GUID) TYPE  BEART_BDI_GUID OPTIONAL
*"     REFERENCE(IRT_BILL_BLOCK) TYPE  BEART_BILL_BLOCK OPTIONAL
*"     REFERENCE(IRT_BILL_CATEGORY) TYPE  BEART_BILL_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_BILL_DATE) TYPE  BEART_BILL_DATE OPTIONAL
*"     REFERENCE(IRT_BILL_ORG) TYPE  BEART_BILL_ORG OPTIONAL
*"     REFERENCE(IRT_BILL_RELEVANCE) TYPE  BEART_BILL_RELEVANCE
*"         OPTIONAL
*"     REFERENCE(IRT_BILL_STATUS) TYPE  BEART_BILL_STATUS OPTIONAL
*"     REFERENCE(IRT_BILL_TYPE) TYPE  BEART_BILL_TYPE OPTIONAL
*"     REFERENCE(IRT_CREDIT_DEBIT) TYPE  BEART_CREDIT_DEBIT OPTIONAL
*"     REFERENCE(IRT_DERIV_CATEGORY) TYPE
*"                             /1BEA/RT_CRMB_DERIV_CATEGORY OPTIONAL
*"     REFERENCE(IRT_DLI_GUID) TYPE  BEART_DLI_GUID OPTIONAL
*"     REFERENCE(IRT_INCOMP_ID) TYPE  BEART_INCOMP_ID OPTIONAL
*"     REFERENCE(IRT_INVCR_DATE) TYPE  /1BEA/RT_CRMB_INVCR_DATE
*"         OPTIONAL
*"     REFERENCE(IRT_ITEM_CATEGORY) TYPE  BEART_ITEM_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_ITEM_TYPE) TYPE  BEART_ITEM_TYPE OPTIONAL
*"     REFERENCE(IRT_LOGSYS) TYPE  /1BEA/RT_CRMB_LOGSYS OPTIONAL
*"     REFERENCE(IRT_MAINT_DATE) TYPE  BEART_MAINT_DATE OPTIONAL
*"     REFERENCE(IRT_MAINT_TIME) TYPE  BEART_MAINT_TIME OPTIONAL
*"     REFERENCE(IRT_MAINT_USER) TYPE  BEART_MAINT_USER OPTIONAL
*"     REFERENCE(IRT_OBJTYPE) TYPE  /1BEA/RT_CRMB_OBJTYPE OPTIONAL
*"     REFERENCE(IRT_PAYER) TYPE  BEART_PAYER OPTIONAL
*"     REFERENCE(IRT_P_LOGSYS) TYPE  /1BEA/RT_CRMB_P_LOGSYS OPTIONAL
*"     REFERENCE(IRT_P_OBJTYPE) TYPE  /1BEA/RT_CRMB_P_OBJTYPE
*"         OPTIONAL
*"     REFERENCE(IRT_P_SRC_HEADNO) TYPE  /1BEA/RT_CRMB_P_SRC_HEADNO
*"         OPTIONAL
*"     REFERENCE(IRT_SOLD_TO_PARTY) TYPE  /1BEA/RT_CRMB_SOLD_TO_PARTY
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_DATE) TYPE  /1BEA/RT_CRMB_SRC_DATE OPTIONAL
*"     REFERENCE(IRT_SRC_GUID) TYPE  /1BEA/RT_CRMB_SRC_GUID OPTIONAL
*"     REFERENCE(IRT_SRC_HEADNO) TYPE  /1BEA/RT_CRMB_SRC_HEADNO
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_ITEMNO) TYPE  /1BEA/RT_CRMB_SRC_ITEMNO
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_USER) TYPE  /1BEA/RT_CRMB_SRC_USER OPTIONAL
*"     REFERENCE(IRT_SRVDOC_SOURCE) TYPE  BEART_SRVDOC_SOURCE
*"         OPTIONAL
*"     REFERENCE(IRT_TERMS_OF_PAYMENT) TYPE  BEART_TERMS_OF_PAYMENT
*"         OPTIONAL
*"     REFERENCE(IT_WHERE_CONDITION) TYPE  COMT_WHERE_CONDITION_TAB
*"         OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BAPIMAXROW
*"         DEFAULT                    0
*"  EXPORTING
*"     REFERENCE(ET_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
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
* Time  : 13:53:10
*
*======================================================================
 DATA:
    LS_RETURN           TYPE BEAS_RETURN,
    LT_RETURN           TYPE BEAT_RETURN,
    lt_dli_guid         TYPE BEAT_DLI_GUID,
    ls_dli_wrk          TYPE /1bea/s_CRMB_DLI_wrk,
    lrs_dli_guid        LIKE LINE OF IRT_DLI_GUID,
    lt_auth_obj         TYPE XUOBJECT_T,
    lt_range_appl       TYPE CRMT_RANGE_APPL,
    lt_range_bill_org   TYPE CRMT_RANGE_BILL_ORG,
    lt_range_bill_type  TYPE CRMT_RANGE_BILL_TYPE.

 FIELD-SYMBOLS:
    <LS_dli_WRK>     TYPE /1BEA/S_CRMB_DLI_WRK.


* First check in buffer, when GUIDs are provided
  CLEAR ET_DLI.
  IF IRT_BDI_GUID is not INITIAL.
    LOOP AT GT_DLI_WRK ASSIGNING <LS_dli_WRK>
      WHERE BDI_GUID IN IRT_BDI_GUID.
      append <LS_dli_WRK> TO ET_DLI.
    ENDLOOP.
  ENDIF.
  IF IRT_DLI_GUID is not INITIAL.
    LOOP AT GT_DLI_WRK ASSIGNING <LS_dli_WRK>
      WHERE DLI_GUID IN IRT_DLI_GUID.
      append <LS_dli_WRK> TO ET_DLI.
    ENDLOOP.
  ENDIF.

* If there's no hit, read from DB
  check ET_DLI is initial.
    TRY.
      IF IRT_DLI_GUID is not INITIAL.
        LOOP AT IRT_DLI_GUID INTO lrs_dli_guid.
          INSERT lrs_dli_guid-LOW INTO TABLE lt_dli_guid.
        ENDLOOP.

        SELECT * FROM /1BEA/CRMB_DLI
              INTO CORRESPONDING FIELDS OF TABLE ET_DLI
              FOR ALL ENTRIES IN lt_dli_guid
              WHERE DLI_GUID = lt_dli_guid-TABLE_LINE.

      ELSE.

        IF iv_auth_check_dli EQ gc_true.
          APPEND 'BEA_DLI' TO lt_auth_obj.
        ENDIF.
        IF iv_auth_check_bdh EQ gc_true.
          APPEND 'BEA_BDH' TO lt_auth_obj.
        ENDIF.
        IF iv_auth_check_dli EQ gc_true
        OR iv_auth_check_bdh EQ gc_true.
          CALL FUNCTION 'BEA_AUTH_RANGES'
            EXPORTING
              it_auth_objects          = lt_auth_obj
              iv_activity              = gc_actv_display
            IMPORTING
              ET_RANGE_APPL            = lt_range_appl
              ET_RANGE_BILL_ORG        = lt_range_bill_org
              ET_RANGE_BILL_TYPE       = lt_range_bill_type
            EXCEPTIONS
              NO_AUTH                  = 1
              OTHERS                   = 2.
          CHECK sy-subrc = 0.
* Check whether user has rights for this application
          CHECK gc_appl in lt_range_appl.

          SELECT * FROM /1BEA/CRMB_DLI
                  INTO CORRESPONDING FIELDS OF ls_dli_wrk
                  WHERE (IT_WHERE_CONDITION)
                  AND BILL_TYPE IN lt_range_bill_type
                  AND BILL_ORG IN lt_range_bill_org AND
                   BDI_GUID IN IRT_BDI_GUID
                  AND BILL_BLOCK IN IRT_BILL_BLOCK
                  AND BILL_CATEGORY IN IRT_BILL_CATEGORY
                  AND BILL_DATE IN IRT_BILL_DATE
                  AND BILL_ORG IN IRT_BILL_ORG
                  AND BILL_RELEVANCE IN IRT_BILL_RELEVANCE
                  AND BILL_STATUS IN IRT_BILL_STATUS
                  AND BILL_TYPE IN IRT_BILL_TYPE
                  AND CREDIT_DEBIT IN IRT_CREDIT_DEBIT
                  AND DERIV_CATEGORY IN IRT_DERIV_CATEGORY
                  AND DLI_GUID IN IRT_DLI_GUID
                  AND INCOMP_ID IN IRT_INCOMP_ID
                  AND INVCR_DATE IN IRT_INVCR_DATE
                  AND ITEM_CATEGORY IN IRT_ITEM_CATEGORY
                  AND ITEM_TYPE IN IRT_ITEM_TYPE
                  AND LOGSYS IN IRT_LOGSYS
                  AND MAINT_DATE IN IRT_MAINT_DATE
                  AND MAINT_TIME IN IRT_MAINT_TIME
                  AND MAINT_USER IN IRT_MAINT_USER
                  AND OBJTYPE IN IRT_OBJTYPE
                  AND PAYER IN IRT_PAYER
                  AND P_LOGSYS IN IRT_P_LOGSYS
                  AND P_OBJTYPE IN IRT_P_OBJTYPE
                  AND P_SRC_HEADNO IN IRT_P_SRC_HEADNO
                  AND SOLD_TO_PARTY IN IRT_SOLD_TO_PARTY
                  AND SRC_DATE IN IRT_SRC_DATE
                  AND SRC_GUID IN IRT_SRC_GUID
                  AND SRC_HEADNO IN IRT_SRC_HEADNO
                  AND SRC_ITEMNO IN IRT_SRC_ITEMNO
                  AND SRC_USER IN IRT_SRC_USER
                  AND SRVDOC_SOURCE IN IRT_SRVDOC_SOURCE
                  AND TERMS_OF_PAYMENT IN IRT_TERMS_OF_PAYMENT.
            INSERT ls_dli_wrk INTO TABLE et_dli.
            IF iv_maxrows IS NOT INITIAL.
              IF LINES( et_dli ) GE iv_maxrows.
                EXIT. "the select
              ENDIF.
            ENDIF.
          ENDSELECT.
        ELSE.

          SELECT * FROM /1BEA/CRMB_DLI
                INTO CORRESPONDING FIELDS OF TABLE ET_DLI
                UP TO IV_MAXROWS ROWS
                WHERE
                  (IT_WHERE_CONDITION)  AND
                   BDI_GUID IN IRT_BDI_GUID
                  AND BILL_BLOCK IN IRT_BILL_BLOCK
                  AND BILL_CATEGORY IN IRT_BILL_CATEGORY
                  AND BILL_DATE IN IRT_BILL_DATE
                  AND BILL_ORG IN IRT_BILL_ORG
                  AND BILL_RELEVANCE IN IRT_BILL_RELEVANCE
                  AND BILL_STATUS IN IRT_BILL_STATUS
                  AND BILL_TYPE IN IRT_BILL_TYPE
                  AND CREDIT_DEBIT IN IRT_CREDIT_DEBIT
                  AND DERIV_CATEGORY IN IRT_DERIV_CATEGORY
                  AND DLI_GUID IN IRT_DLI_GUID
                  AND INCOMP_ID IN IRT_INCOMP_ID
                  AND INVCR_DATE IN IRT_INVCR_DATE
                  AND ITEM_CATEGORY IN IRT_ITEM_CATEGORY
                  AND ITEM_TYPE IN IRT_ITEM_TYPE
                  AND LOGSYS IN IRT_LOGSYS
                  AND MAINT_DATE IN IRT_MAINT_DATE
                  AND MAINT_TIME IN IRT_MAINT_TIME
                  AND MAINT_USER IN IRT_MAINT_USER
                  AND OBJTYPE IN IRT_OBJTYPE
                  AND PAYER IN IRT_PAYER
                  AND P_LOGSYS IN IRT_P_LOGSYS
                  AND P_OBJTYPE IN IRT_P_OBJTYPE
                  AND P_SRC_HEADNO IN IRT_P_SRC_HEADNO
                  AND SOLD_TO_PARTY IN IRT_SOLD_TO_PARTY
                  AND SRC_DATE IN IRT_SRC_DATE
                  AND SRC_GUID IN IRT_SRC_GUID
                  AND SRC_HEADNO IN IRT_SRC_HEADNO
                  AND SRC_ITEMNO IN IRT_SRC_ITEMNO
                  AND SRC_USER IN IRT_SRC_USER
                  AND SRVDOC_SOURCE IN IRT_SRVDOC_SOURCE
                  AND TERMS_OF_PAYMENT IN IRT_TERMS_OF_PAYMENT.
        ENDIF.
      ENDIF.
    CATCH CX_SY_OPEN_SQL_DB.
      IF ES_RETURN IS REQUESTED.
        MESSAGE E180(BEA) INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
          EXPORTING
            IV_OBJECT          = 'DL'
            IV_CONTAINER       = 'DLI'
          IMPORTING
            ET_RETURN          = LT_RETURN.
        READ TABLE LT_RETURN INDEX 1 INTO LS_RETURN.
        ES_RETURN = LS_RETURN.
      ENDIF.
    ENDTRY.

 CASE IV_SORTREL.
   WHEN GC_SORT_BY_PRIMARY_KEY.
     SORT ET_DLI BY DLI_GUID.
   WHEN GC_SORT_BY_EXTERNAL_REF.
     SORT ET_DLI BY
          LOGSYS
          OBJTYPE
          SRC_HEADNO
          SRC_ITEMNO
          MAINT_DATE DESCENDING
          MAINT_TIME DESCENDING.
   WHEN GC_SORT_BY_EXT_GUID_REF.
     SORT ET_DLI BY
          SRC_GUID
          MAINT_DATE DESCENDING
          MAINT_TIME DESCENDING.
   WHEN GC_SORT_BY_INTERNAL_REF.
     SORT ET_DLI BY
          DERIV_CATEGORY
          LOGSYS
          OBJTYPE
          SRC_HEADNO
          SRC_ITEMNO
          MAINT_DATE DESCENDING
          MAINT_TIME DESCENDING.
   WHEN GC_SORT_BY_REFERENCES.
          SORT ET_DLI BY
          P_LOGSYS
          P_OBJTYPE
          P_SRC_HEADNO
          P_SRC_ITEMNO
          MAINT_DATE DESCENDING
          MAINT_TIME DESCENDING.
 ENDCASE.

ENDFUNCTION.
