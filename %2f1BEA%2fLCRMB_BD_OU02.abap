FUNCTION /1BEA/CRMB_BD_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IS_CRP) TYPE  BEAS_CRP OPTIONAL
*"     REFERENCE(IV_LOGHNDL) TYPE  BALLOGHNDL OPTIONAL
*"     REFERENCE(IS_BILL_DEFAULT) TYPE  BEAS_BILL_DEFAULT OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_DLI_DB) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_CRP) TYPE  BEAS_CRP
*"     REFERENCE(EV_LOGHNDL) TYPE  BALLOGHNDL
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
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
  DATA:
    LV_DLI_NO_SAVE TYPE BEA_BOOLEAN,
    LS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK     TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_TABIX_DLI   TYPE SYTABIX,
    LT_RETURN      TYPE BEAT_RETURN.
*====================================================================
* Implementation
*====================================================================
 BREAK-POINT ID BEA_BD.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Create billing documents
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 IF NOT IV_PROCESS_MODE = GC_PROC_NOADD.
   IF IV_DLI_DB = GC_FALSE.
     CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
   ELSE.
     LV_DLI_NO_SAVE = GC_TRUE.
   ENDIF.
   CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'
     EXPORTING
       IV_DLI_NO_SAVE = LV_DLI_NO_SAVE.
 ENDIF.
 PERFORM HANDLE_CRP_AL
   USING
     IS_CRP
     IV_LOGHNDL
   CHANGING
     ES_CRP
     EV_LOGHNDL.
 CALL FUNCTION '/1BEA/CRMB_DL_O_DLI_INV_SORT'
   EXPORTING
     IT_DLI = IT_DLI_WRK
   IMPORTING
     ET_DLI = LT_DLI_WRK.
* Collect/Prefetch Data for Billing Run
 LOOP AT LT_DLI_WRK INTO LS_DLI_WRK.
   LV_TABIX_DLI = SY-TABIX.
   PERFORM DOCUMENT_CREATE
     USING
       LV_TABIX_DLI
       IS_BILL_DEFAULT
       IV_DLI_DB
       LS_DLI_WRK.
 ENDLOOP.

* Enhancements for BD (final processing)
* Event BD_OCRE0
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE0PRCOBD_B1.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Final processing
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF NOT IV_PROCESS_MODE = GC_PROC_NOADD.
    IF ET_RETURN IS REQUESTED.
      ET_RETURN = GT_RETURN.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
      EXPORTING
        IV_PROCESS_MODE     = IV_PROCESS_MODE
        IV_COMMIT_FLAG      = IV_COMMIT_FLAG
        IV_DL_WITH_SERVICES = GC_FALSE
        IV_WITH_DOCFLOW     = GV_WITH_DOCFLOW
        IV_DLI_NO_SAVE      = IV_DLI_DB
      IMPORTING
        ET_RETURN           = LT_RETURN.
    IF ET_RETURN IS REQUESTED.
      APPEND LINES OF LT_RETURN TO ET_RETURN.
    ENDIF.
  ELSE.
    IF ET_RETURN IS REQUESTED.
      ET_RETURN = GT_RETURN.
    ENDIF.
  ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Initialization
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF IV_PROCESS_MODE = GC_PROC_TEST.
    IF IV_DLI_DB = GC_FALSE.
     CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'
      EXPORTING
        IV_DLI_NO_SAVE = LV_DLI_NO_SAVE.
  ENDIF.
ENDFUNCTION.
*---------------------------------------------------------------------
*       FORM BTY_GET
*---------------------------------------------------------------------
  FORM BTY_GET
    USING
      UV_BILL_TYPE TYPE BEA_BILL_TYPE
    CHANGING
      CS_BTY_WRK     TYPE BEAS_BTY_WRK
      CV_RETURN_CODE TYPE SYSUBRC.
    CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
      EXPORTING
        IV_APPL          = GC_APPL
        IV_BTY           = UV_BILL_TYPE
      IMPORTING
        ES_BTY_WRK       = CS_BTY_WRK
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.
    IF SY-SUBRC NE 0.
      CV_RETURN_CODE = SY-SUBRC.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO gv_dummy.
    ENDIF.

  ENDFORM.                    "BTY_GET
*---------------------------------------------------------------------
*       FORM ITC_GET
*---------------------------------------------------------------------
  FORM ITC_GET
    USING
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      UV_TABIX_DLI   TYPE SYTABIX
    CHANGING
      CS_ITC_WRK     TYPE BEAS_ITC_WRK
      CV_RETURN_CODE TYPE SYSUBRC.

    CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
      EXPORTING
        IV_APPL          = GC_APPL
        IV_ITC           = US_DLI_WRK-ITEM_CATEGORY
      IMPORTING
        ES_ITC_WRK       = CS_ITC_WRK
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.
    IF SY-SUBRC <> 0.
      CV_RETURN_CODE = SY-SUBRC.
      MESSAGE E205(BEA) WITH US_DLI_WRK-ITEM_CATEGORY
                             GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'DL'
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK.
    ENDIF.
  ENDFORM.                    "itc_get
*---------------------------------------------------------------------
*       FORM DLI_ENQUEUE
*---------------------------------------------------------------------
FORM DLI_ENQUEUE
  using
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    uv_tabix_dli  type sytabix
  CHANGING
    CV_RETURNCODE TYPE SYSUBRC.
 DATA:
   LV_X_DERIV_CATEGORY TYPE BEA_BOOLEAN,
   LS_RETURN           TYPE BEAS_RETURN,
   LS_DLI_WRK          TYPE /1BEA/S_CRMB_DLI_WRK.

  LV_X_DERIV_CATEGORY = GC_TRUE.
**********************************************************************
* Check if Enqueue-Fields are not initial
**********************************************************************
  IF (
         US_DLI_WRK-LOGSYS IS INITIAL
       OR  US_DLI_WRK-OBJTYPE IS INITIAL
       OR  US_DLI_WRK-SRC_HEADNO IS INITIAL
     ).
    RETURN.
   " no queues are performed if one of the relevant fields IS INITIAL
  ELSE.
    LS_DLI_WRK-DERIV_CATEGORY = US_DLI_WRK-DERIV_CATEGORY.
    LS_DLI_WRK-LOGSYS = US_DLI_WRK-LOGSYS.
    LS_DLI_WRK-OBJTYPE = US_DLI_WRK-OBJTYPE.
    LS_DLI_WRK-SRC_HEADNO = US_DLI_WRK-SRC_HEADNO.
  ENDIF.
**********************************************************************
* Enqueue
**********************************************************************
  CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
    EXPORTING
      IS_DLI_WRK          = LS_DLI_WRK
      IV_X_DERIV_CATEGORY = LV_X_DERIV_CATEGORY
    IMPORTING
      ES_RETURN    = LS_RETURN.
  IF NOT LS_RETURN IS INITIAL.
    MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
            NUMBER LS_RETURN-NUMBER
            WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.
ENDFORM.                    "dli_enqueue
*---------------------------------------------------------------------
*       FORM DLI_GET
*---------------------------------------------------------------------
FORM DLI_GET
  using
    US_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK
    uv_tabix_dli       TYPE syindex
  CHANGING
    CT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK
    CV_RETURN_CODE     TYPE SYSUBRC.
  DATA:
    LV_SORTREL     TYPE BEA_SORTREL VALUE GC_SORT_BY_EXTERNAL_REF,
    LRS_DERIV_CATEGORY TYPE /1BEA/RS_CRMB_DERIV_CATEGORY,
    LRT_DERIV_CATEGORY TYPE /1BEA/RT_CRMB_DERIV_CATEGORY,
    LRS_LOGSYS TYPE /1BEA/RS_CRMB_LOGSYS,
    LRT_LOGSYS TYPE /1BEA/RT_CRMB_LOGSYS,
    LRS_OBJTYPE TYPE /1BEA/RS_CRMB_OBJTYPE,
    LRT_OBJTYPE TYPE /1BEA/RT_CRMB_OBJTYPE,
    LRS_SRC_HEADNO TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    LRT_SRC_HEADNO TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    LRS_BILL_STATUS   TYPE BEARS_BILL_STATUS,
    LRT_BILL_STATUS   TYPE BEART_BILL_STATUS.

  IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_LEANBILLING.
    LV_SORTREL = GC_SORT_BY_INTERNAL_REF.
  ENDIF.
  LRS_DERIV_CATEGORY-SIGN   = GC_INCLUDE.
  LRS_DERIV_CATEGORY-OPTION = GC_EQUAL.
  LRS_DERIV_CATEGORY-LOW    = US_DLI_WRK-DERIV_CATEGORY.
  APPEND LRS_DERIV_CATEGORY TO LRT_DERIV_CATEGORY.
  LRS_LOGSYS-SIGN   = GC_INCLUDE.
  LRS_LOGSYS-OPTION = GC_EQUAL.
  LRS_LOGSYS-LOW    = US_DLI_WRK-LOGSYS.
  APPEND LRS_LOGSYS TO LRT_LOGSYS.
  LRS_OBJTYPE-SIGN   = GC_INCLUDE.
  LRS_OBJTYPE-OPTION = GC_EQUAL.
  LRS_OBJTYPE-LOW    = US_DLI_WRK-OBJTYPE.
  APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
  LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
  LRS_SRC_HEADNO-OPTION = GC_EQUAL.
  LRS_SRC_HEADNO-LOW    = US_DLI_WRK-SRC_HEADNO.
  APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
  LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW    = GC_BILLSTAT_TODO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
    EXPORTING
      IV_SORTREL        = LV_SORTREL
      IRT_BILL_STATUS   = LRT_BILL_STATUS
      IRT_DERIV_CATEGORY       = LRT_DERIV_CATEGORY
      IRT_LOGSYS       = LRT_LOGSYS
      IRT_OBJTYPE       = LRT_OBJTYPE
      IRT_SRC_HEADNO       = LRT_SRC_HEADNO
    IMPORTING
      ET_DLI               = CT_DLI_WRK.
  IF CT_DLI_WRK IS INITIAL.
    CV_RETURN_CODE = 1.
    MESSAGE e222(bea) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO gv_dummy.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
    EXIT. "from form
  ENDIF.
ENDFORM.                    "dli_get
*---------------------------------------------------------------------
*       FORM AUTHORITY_CHECK_DLI
*---------------------------------------------------------------------
FORM AUTHORITY_CHECK_DLI
  USING
    UV_ACTIVITY  TYPE ACTIV_AUTH
    UV_BILL_TYPE TYPE BEA_BILL_TYPE
    US_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK
    uv_tabix_dli type sytabix
  CHANGING
    CV_RETURN_CODE TYPE SYSUBRC.

    CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
      EXPORTING
        IV_BILL_TYPE                 = UV_BILL_TYPE
        IV_BILL_ORG                  = US_DLI_WRK-BILL_ORG
        IV_APPL                      = GC_APPL
        IV_ACTVT                     = UV_ACTIVITY
        IV_CHECK_DLI                 = GC_FALSE
        IV_CHECK_BDH                 = GC_TRUE
      EXCEPTIONS
        NO_AUTH                      = 1
        OTHERS                       = 2.
  IF SY-SUBRC <> 0.
    CV_RETURN_CODE = SY-SUBRC.
    IF UV_ACTIVITY = GC_ACTV_CREATE.
      MESSAGE E212(BEA) WITH UV_BILL_TYPE US_DLI_WRK-BILL_ORG
                             GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
    ELSE.
      MESSAGE E206(BEA) WITH UV_BILL_TYPE US_DLI_WRK-BILL_ORG
                             GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
  ENDIF.
ENDFORM.                    "authority_check_dli
*********************************************************************
*       FORM BDI_PREPARE
*********************************************************************
  FORM BDI_PREPARE
    USING
      US_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
      US_ITC_WRK TYPE BEAS_ITC_WRK
    CHANGING
      CS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK.

    DATA: BEGIN OF ls_bdi_bta.
      INCLUDE STRUCTURE beas_bdi_dp.
      INCLUDE STRUCTURE /1BEA/S_CRMB_BDI_COM.
    DATA  END OF ls_bdi_bta.

    CLEAR CS_BDI_WRK.
    MOVE-CORRESPONDING US_DLI_WRK TO ls_bdi_bta.
    MOVE-CORRESPONDING ls_bdi_bta TO CS_BDi_WRK.
    CS_BDI_WRK-ITEM_CATEGORY    = US_DLI_WRK-ITEM_CATEGORY.
    CS_BDI_WRK-ITEM_TYPE        = US_DLI_WRK-ITEM_TYPE.
    CS_BDI_WRK-SRVDOC_SOURCE    = US_DLI_WRK-SRVDOC_SOURCE.
    CS_BDI_WRK-BILL_RELEVANCE   = US_DLI_WRK-BILL_RELEVANCE.
    CS_BDI_WRK-CREDIT_DEBIT     = US_DLI_WRK-CREDIT_DEBIT.
    CS_BDI_WRK-BDI_PRICING_TYPE = US_ITC_WRK-BDI_PRICING_TYPE.
    CS_BDI_WRK-BDI_PRCCOPY_TYPE = US_ITC_WRK-BDI_PRCCOPY_TYPE.
    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        EV_GUID_16 = CS_BDI_WRK-BDI_GUID.
    CS_BDI_WRK-ROOT_DLITEM_GUID = US_DLI_WRK-DLI_GUID.

* Transfer of fields from Due List to Bill Doc Item
* Event BD_OCRE1
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE1PRCOBD_I1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE1ICBOBD_I1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE1CMLOBD_I1.

  ENDFORM.                    "bdi_prepare
*********************************************************************
*       FORM BDH_PREPARE
*********************************************************************
  FORM BDH_PREPARE
    USING
      US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
      US_BILL_DEFAULT TYPE BEAS_BILL_DEFAULT
      US_BTY_WRK      TYPE BEAS_BTY_WRK
      UV_CRP_GUID     TYPE BEA_CRP_GUID
      UV_TABIX_DLI    TYPE SYINDEX
    CHANGING
      CS_BDH_WRK      TYPE /1BEA/S_CRMB_BDH_WRK
      CV_RETURNCODE   TYPE SYSUBRC.
    DATA: BEGIN OF ls_bdh_bta,
      bill_category TYPE bea_bill_category,
      bill_org      TYPE bea_bill_org.
      INCLUDE STRUCTURE beas_bdh_dp.
      INCLUDE STRUCTURE /1BEA/S_CRMB_BDH_com.
    DATA  END OF ls_bdh_bta.

    CLEAR CS_BDH_WRK.

    MOVE-CORRESPONDING US_DLI_WRK TO ls_bdh_bta.
    MOVE-CORRESPONDING ls_bdh_bta TO CS_BDH_WRK.

    IF NOT US_BILL_DEFAULT-BILL_DATE IS INITIAL.
      CS_BDH_WRK-BILL_DATE = US_BILL_DEFAULT-BILL_DATE.
    ENDIF.
    IF CS_BDH_WRK-BILL_DATE IS INITIAL.
      CS_BDH_WRK-BILL_DATE = SY-DATLO.
    ENDIF.

* set TRANSFER_DATE equal to BILL_DATE as default
    IF CS_BDH_WRK-TRANSFER_DATE IS INITIAL.
      CS_BDH_WRK-TRANSFER_DATE = CS_BDH_WRK-BILL_DATE.
    ENDIF.

* move all relevant fields from the Bill-Type to the BDH:
    CS_BDH_WRK-BILL_TYPE = US_BTY_WRK-BILL_TYPE.
    CS_BDH_WRK-PRIC_PROC = US_BTY_WRK-PRIC_PROC.

    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        EV_GUID_16 = CS_BDH_WRK-BDH_GUID.
    CS_BDH_WRK-MAINT_DATE = SY-DATUM.
    CS_BDH_WRK-MAINT_TIME = SY-UZEIT.
    CS_BDH_WRK-MAINT_USER = SY-UNAME.

    CS_BDH_WRK-CRP_GUID = UV_CRP_GUID.
    IF US_BTY_WRK-TRANSFER_BLOCK IS INITIAL.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_TODO.
    ELSE.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_BLOCK.
    ENDIF.
    IF CS_BDH_WRK-BILL_CATEGORY = GC_BILL_CAT_PROFORMA.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_NOT_REL.
    ENDIF.
    CS_BDH_WRK-OBJTYPE = GC_BOR_BDH.
    CS_BDH_WRK-LOGSYS  = GV_OWN_LOGSYS.

* Event BD_OCREH
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREHPRCOBD_B0.
  ENDFORM.                    "bdh_prepare
*---------------------------------------------------------------------
*       FORM  BDH_PROCESS
*---------------------------------------------------------------------
  FORM BDH_PROCESS
    USING
      US_BTY_WRK   TYPE BEAS_BTY_WRK
    CHANGING
      CS_BDH_WRK  TYPE /1BEA/S_CRMB_BDH_WRK
      CV_NEW_HEAD TYPE BEA_BOOLEAN.

    DATA:
      LV_EQUAL        TYPE BEA_BOOLEAN,
      LS_BDH_HLP_CMP  TYPE /1BEA/S_CRMB_BDH_CMP,
      LS_BDH_CMP      TYPE /1BEA/S_CRMB_BDH_CMP,
      LS_BDH_WRK      TYPE /1BEA/S_CRMB_BDH_WRK.

      MOVE-CORRESPONDING CS_BDH_WRK TO LS_BDH_CMP.
      LV_EQUAL = GC_FALSE.
      LOOP AT GT_BDH_WRK INTO LS_BDH_WRK.
        MOVE-CORRESPONDING LS_BDH_WRK TO LS_BDH_HLP_CMP.
*   The Components Excluded from Comparison (CEC) are
*   artificially assigned the same values
        LS_BDH_HLP_CMP-NET_VALUE = LS_BDH_CMP-NET_VALUE.
        LS_BDH_HLP_CMP-TAX_VALUE = LS_BDH_CMP-TAX_VALUE.
        IF LS_BDH_HLP_CMP = LS_BDH_CMP.
          LV_EQUAL = GC_TRUE.

* Influence grouping of billing documents (split)
* Event BD_OCRE6
        INCLUDE %2f1BEA%2fX_CRMBBD_OCRE6PAROBD_HC1.

          IF LV_EQUAL = GC_TRUE.
            IF NOT LS_BDH_WRK-MAX_ITEMS IS INITIAL.
              IF LS_BDH_WRK-MAX_ITEMS > LS_BDH_WRK-ITEMNO_HI.
                EXIT.
              ELSE.
                LV_EQUAL = GC_FALSE.
              ENDIF.
            ELSE.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

* Process results of grouping (split of billing documents)
* Event BD_OCRE7
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE7TXTOBD_HC1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE7PAROBD_HC2.


    IF LV_EQUAL = GC_FALSE. "no matching head has been found
      CV_NEW_HEAD = GC_TRUE.
      CS_BDH_WRK-UPD_TYPE = GC_INSERT.
    ELSE.                   "matching head has been found
      CV_NEW_HEAD = GC_FALSE.
      CS_BDH_WRK = LS_BDH_WRK.
    ENDIF.
  ENDFORM.                    "bdh_process
*---------------------------------------------------------------------
*       FORM BDI_PROCESS
*---------------------------------------------------------------------
  FORM BDI_PROCESS
    USING
      US_BTY_WRK     TYPE BEAS_BTY_WRK
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      UV_NEW_HEAD    TYPE BEA_BOOLEAN
    CHANGING
      CS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK
      CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK.

    DATA:
      LV_ITEMINC       TYPE BEA_ITEMINC VALUE GC_ITEMINC_10.

    CS_BDI_WRK-BDH_GUID = CS_BDH_WRK-BDH_GUID.
    IF NOT US_BTY_WRK-ITEMINC IS INITIAL.
      LV_ITEMINC = US_BTY_WRK-ITEMINC.
    ELSE.
      LV_ITEMINC = GC_ITEMINC_10.
    ENDIF.
    CS_BDI_WRK-ITEMNO_EXT  = LV_ITEMINC + CS_BDH_WRK-ITEMNO_HI.

* Event BD_OCRED
    INCLUDE %2f1BEA%2fX_CRMBBD_OCREDPITOBD_RN.

    IF CS_BDI_WRK-CREATION_CODE NE GC_CC_CUMULATION.
      CS_BDH_WRK-ITEMNO_HI  = CS_BDI_WRK-ITEMNO_EXT.
    ENDIF.
    CS_BDI_WRK-UPD_TYPE = GC_INSERT.
  ENDFORM.                    "BDI_PROCESS
*---------------------------------------------------------------------
*       FORM BD_COMPLETE
*---------------------------------------------------------------------
  FORM BD_COMPLETE
    USING
      US_ITC_WRK     TYPE BEAS_ITC_WRK
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      UV_NEW_HEAD    TYPE BEA_BOOLEAN
      UV_TABIX_DLI   TYPE SYTABIX
    CHANGING
      CT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK
      CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
      CV_RETURN_CODE TYPE SYSUBRC.

    DATA:
      BEGIN OF LS_DOC_ID,
        PREFIX(1) TYPE C VALUE '$',
        ID(9)     TYPE N VALUE '000000000',
      END OF LS_DOC_ID.

    DATA:
      LV_LINES       TYPE SYTABIX,
      LV_TABIX       TYPE SYTABIX,
      LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK,
      LT_RETURN      TYPE BEAT_RETURN.

* Event BD_OCREA
    INCLUDE %2f1BEA%2fX_CRMBBD_OCREAPAROBD_CM.
    INCLUDE %2f1BEA%2fX_CRMBBD_OCREATXTOBD_I1.


    IF UV_NEW_HEAD = GC_TRUE.
* new BD head is inserted into global table AFTER BD item,
* because errors are more likely to occure with BD item
* (and no itemless head is wanted in the global table)

* Enhancements for BDH (Completion)
* Event BD_OCRE9
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE9PRCOBD_H1.

* keep table GT_BDH_WRK sorted by head guids
      DESCRIBE TABLE GT_BDH_WRK LINES LV_LINES.
      ADD 1 TO LV_LINES.
      LS_DOC_ID-ID = LV_LINES.
      CS_BDH_WRK-HEADNO_EXT = LS_DOC_ID.
      READ TABLE GT_BDH_WRK
        WITH KEY HEADNO_EXT = CS_BDH_WRK-HEADNO_EXT
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
      LV_TABIX = SY-TABIX.
      CASE SY-SUBRC.
        WHEN 0.
          MODIFY GT_BDH_WRK FROM CS_BDH_WRK INDEX LV_TABIX.
        WHEN 4.
          INSERT CS_BDH_WRK INTO GT_BDH_WRK INDEX LV_TABIX.
        WHEN 8.
          APPEND CS_BDH_WRK TO GT_BDH_WRK.
      ENDCASE.
    ELSE.
      READ TABLE GT_BDH_WRK
        WITH KEY HEADNO_EXT = CS_BDH_WRK-HEADNO_EXT
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
      MODIFY GT_BDH_WRK FROM CS_BDH_WRK INDEX SY-TABIX.
    ENDIF.
* insert new item into global table at the
* appropriate position
    LOOP AT CT_BDI_WRK INTO LS_BDI_WRK.
      READ TABLE GT_BDI_WRK
          WITH KEY BDH_GUID   = CS_BDH_WRK-BDH_GUID
                   ITEMNO_EXT = LS_BDI_WRK-ITEMNO_EXT
         BINARY SEARCH TRANSPORTING NO FIELDS.
      CASE SY-SUBRC.
        WHEN 4.
          INSERT LS_BDI_WRK INTO GT_BDI_WRK INDEX SY-TABIX.
        WHEN 8.
          APPEND LS_BDI_WRK TO GT_BDI_WRK.
        WHEN OTHERS.
          IF LS_BDI_WRK-CREATION_CODE EQ GC_CC_CUMULATION.
            MODIFY GT_BDI_WRK FROM LS_BDI_WRK INDEX SY-TABIX.
          ELSE.
            CV_RETURN_CODE = 1.
            MESSAGE A209(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                              INTO GV_DUMMY.
            CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
              EXPORTING
                IV_OBJECT      = 'DL'
                IV_CONTAINER   = 'DLI'
                IS_DLI_WRK     = US_DLI_WRK.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
* Enhancements for BDI (End of Completion)
  ENDFORM.                    "BD_COMPLETE
*---------------------------------------------------------------------
*       FORM STATUS_AND_DOCFLOW_MAINTAIN
*---------------------------------------------------------------------
  FORM STATUS_AND_DOCFLOW_MAINTAIN
    USING
      US_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
      US_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK.

    DATA:
      LV_BILL_STATUS TYPE BEA_BILL_STATUS,
      LV_BDI_GUID    TYPE BEA_BDI_GUID.

    LV_BILL_STATUS = GC_BILLSTAT_DONE.
    LV_BDI_GUID    = US_BDI_WRK-BDI_GUID.
    CALL FUNCTION '/1BEA/CRMB_DL_O_DOCFLOW_MAINT'
      EXPORTING
        IS_DLI_WRK     = US_DLI_WRK
        IV_BILL_STATUS = LV_BILL_STATUS
        IV_BDI_GUID    = LV_BDI_GUID.
  ENDFORM.                    "STATUS_AND_DOCFLOW_MAINTAIN
*--------------------------------------------------------------------*
*     FORM BDI_CPREQ_EXECUTE
*--------------------------------------------------------------------*
  FORM BDI_CPREQ_EXECUTE
    USING
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      US_BTY_WRK     TYPE BEAS_BTY_WRK
      US_ITC_WRK     TYPE BEAS_ITC_WRK
      UV_TABIX_DLI   TYPE SYTABIX
      US_REF_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
    CHANGING
      CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
      CS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK
      CV_RETURNCODE  TYPE SYSUBRC.

    DATA:
      LS_FILTER      TYPE  BEAS_BDCPREQFLT,
      LR_CPREQ       TYPE REF TO bea_CRMB_BD_CPREQ.

    IF NOT US_ITC_WRK-BDI_COPYREQ IS INITIAL.
      TRY.
          GET BADI lr_cpreq FILTERS CPREQ = US_ITC_WRK-BDI_COPYREQ.
        CATCH cx_badi_not_implemented.
      ENDTRY.
    ENDIF.
    IF LR_CPREQ IS NOT INITIAL.
      LS_FILTER-APPL = US_ITC_WRK-APPLICATION.
      LS_FILTER-FILTERVALUE = US_ITC_WRK-BDI_COPYREQ.
      CALL BADI LR_CPREQ->COPY_REQUIREMENT
        EXPORTING
          FLT_VAL        = LS_FILTER
          IS_ITC         = US_ITC_WRK
          IS_BTY         = US_BTY_WRK
          IS_DLI_WRK     = US_DLI_WRK
          IS_REF_DLI_WRK = US_REF_DLI_WRK
        CHANGING
          CS_BDH_WRK     = CS_BDH_WRK
          CS_BDI_WRK     = CS_BDI_WRK
        EXCEPTIONS
          ABORTED        = 1.
      CV_RETURNCODE = SY-SUBRC.
      IF NOT CV_RETURNCODE IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
          EXPORTING
            IV_OBJECT      = 'DL'
            IV_CONTAINER   = 'DLI'
            IS_DLI_WRK     = US_DLI_WRK.
      ENDIF.
    ENDIF.
  ENDFORM.                    "BDI_CPREQ_EXECUTE
*--------------------------------------------------------------------*
*      Form  handle_crp_al
*--------------------------------------------------------------------*
FORM handle_crp_al
    USING    us_crp     TYPE beas_crp
             uv_loghndl type balloghndl
    CHANGING cs_crp     TYPE beas_crp
             cv_loghndl type balloghndl.
      IF     NOT gs_crp is initial
         AND gs_crp NE us_crp.
        cs_crp = gs_crp.
      ELSE.
        cs_crp = us_crp.
        gs_crp = us_crp.
      ENDIF.
      IF     NOT gv_loghndl is initial
         AND gv_loghndl NE uv_loghndl.
        cv_loghndl = gv_loghndl.
      ELSE.
        cv_loghndl = uv_loghndl.
        gv_loghndl = uv_loghndl.
      ENDIF.
ENDFORM.                    " handle_crp
*------------------------------------------------------------------*
*     FORM DOCUMENT_CREATE
*------------------------------------------------------------------*
FORM DOCUMENT_CREATE
  USING
    UV_TABIX_DLI    TYPE SYTABIX
    US_BILL_DEFAULT TYPE BEAS_BILL_DEFAULT
    UV_DLI_GET      TYPE BEA_BOOLEAN
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK.

  STATICS:
    LT_DLI_WRK    TYPE /1BEA/T_CRMB_DLI_WRK.
  DATA:
    LS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_ITC_WRK    TYPE BEAS_ITC_WRK,
    LV_BILL_TYPE  TYPE BEA_BILL_TYPE,
    LS_BTY_WRK    TYPE BEAS_BTY_WRK,
    LV_RETURNCODE TYPE SYSUBRC.

  IF
    (
     US_DLI_WRK-DERIV_CATEGORY NE GS_DLI_HLP-DERIV_CATEGORY OR
     US_DLI_WRK-LOGSYS NE GS_DLI_HLP-LOGSYS OR
     US_DLI_WRK-OBJTYPE NE GS_DLI_HLP-OBJTYPE OR
     US_DLI_WRK-SRC_HEADNO NE GS_DLI_HLP-SRC_HEADNO
     ).
    IF UV_DLI_GET is initial.
      PERFORM DLI_ENQUEUE
        USING
          US_DLI_WRK
          UV_TABIX_DLI
        CHANGING
          LV_RETURNCODE.
      CHECK LV_RETURNCODE IS INITIAL.
      CLEAR:
        GS_DLI_HLP,
        LT_DLI_WRK.
      PERFORM DLI_GET
        USING
          US_DLI_WRK
          UV_TABIX_DLI
        CHANGING
          LT_DLI_WRK
          LV_RETURNCODE.
      CHECK LV_RETURNCODE IS INITIAL.
      GS_DLI_HLP = US_DLI_WRK.
    ELSE.
      LS_DLI_WRK = US_DLI_WRK.
    ENDIF.
* Collect data for billing
* Event BD_OCRE8
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE8PAROBD_B1.

  ENDIF.
  IF UV_DLI_GET IS INITIAL.
    CLEAR LS_DLI_WRK.
      READ TABLE LT_DLI_WRK INTO LS_DLI_WRK WITH KEY
                        LOGSYS = US_DLI_WRK-LOGSYS
                        OBJTYPE = US_DLI_WRK-OBJTYPE
                        SRC_HEADNO = US_DLI_WRK-SRC_HEADNO
                        SRC_ITEMNO = US_DLI_WRK-SRC_ITEMNO
                        BINARY SEARCH.
      CHECK SY-SUBRC IS INITIAL.
  ENDIF.

  IF NOT LS_DLI_WRK-INCOMP_ID IS INITIAL.
    MESSAGE E237(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
     RETURN.
  ENDIF.
  IF US_BILL_DEFAULT-BILL_TYPE IS INITIAL.
    LV_BILL_TYPE = LS_DLI_WRK-BILL_TYPE.
  ELSE.
    LV_BILL_TYPE = US_BILL_DEFAULT-BILL_TYPE.
  ENDIF.
*  Take over the "manual" split criteria from the interface structure
  LS_DLI_WRK-SRC_HEADNO_BSGL = US_DLI_WRK-SRC_HEADNO_BSGL.
  LS_DLI_WRK-SPLIT_CRITERIA = US_DLI_WRK-SPLIT_CRITERIA.
  PERFORM BTY_GET
    USING
      LV_BILL_TYPE
    CHANGING
      LS_BTY_WRK
      LV_RETURNCODE.
  IF NOT LV_RETURNCODE IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
    RETURN.
  ENDIF.
  PERFORM BILL_CATEGORY_CHECK
    USING
      LS_DLI_WRK
      LS_BTY_WRK
      UV_TABIX_DLI
    CHANGING
      LV_RETURNCODE.
  CHECK LV_RETURNCODE IS INITIAL.
*  Check that the billing type used for the invoicing
*  carries the same transfer type as the due list item
  PERFORM ITC_GET
    USING
      LS_DLI_WRK
      UV_TABIX_DLI
    CHANGING
      LS_ITC_WRK
      LV_RETURNCODE.
  CHECK LV_RETURNCODE IS INITIAL.
  IF NOT LS_ITC_WRK-BILL_RELEV IS INITIAL.
     MESSAGE E204(BEA) WITH US_DLI_WRK-ITEM_CATEGORY
                            GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                       INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
       EXPORTING
         IV_OBJECT      = 'DL'
         IV_CONTAINER   = 'DLI'
         IS_DLI_WRK     = US_DLI_WRK.
     RETURN.
  ENDIF.
  PERFORM AUTHORITY_CHECK_DLI
    USING
      GC_ACTV_CREATE
      LV_BILL_TYPE
      LS_DLI_WRK
      UV_TABIX_DLI
    CHANGING
      LV_RETURNCODE.
  CHECK LV_RETURNCODE IS INITIAL.
  IF ( US_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_DELIVERY OR
       US_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_DELIV_IC OR
       US_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_DLV_TPOP ).
    IF (
       US_DLI_WRK-P_LOGSYS IS INITIAL OR
       US_DLI_WRK-P_OBJTYPE IS INITIAL OR
       US_DLI_WRK-P_SRC_HEADNO IS INITIAL OR
       US_DLI_WRK-P_SRC_ITEMNO IS INITIAL
       ).
      MESSAGE E253(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                             US_DLI_WRK-BILL_RELEVANCE
                       INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'DL'
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK.
      RETURN.
    ENDIF.
    PERFORM CREATE_WITH_REF
      USING
        LS_DLI_WRK
        US_BILL_DEFAULT
        LS_ITC_WRK
        LS_BTY_WRK
        GS_CRP-GUID
        UV_TABIX_DLI
      CHANGING
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
  ELSEIF US_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_UN_DEF AND
     NOT US_DLI_WRK-P_LOGSYS IS INITIAL AND
     NOT US_DLI_WRK-P_OBJTYPE IS INITIAL AND
     NOT US_DLI_WRK-P_SRC_HEADNO IS INITIAL AND
     NOT US_DLI_WRK-P_SRC_ITEMNO IS INITIAL.
    PERFORM CREATE_WITH_REF
      USING
        LS_DLI_WRK
        US_BILL_DEFAULT
        LS_ITC_WRK
        LS_BTY_WRK
        GS_CRP-GUID
        UV_TABIX_DLI
      CHANGING
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
  ELSE.
    PERFORM CREATE_WITHOUT_REF
      USING
        LS_DLI_WRK
        US_BILL_DEFAULT
        LS_ITC_WRK
        LS_BTY_WRK
        GS_CRP-GUID
        UV_TABIX_DLI
      CHANGING
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------
*      Form  CREATE_WITH_REF
*---------------------------------------------------------------------
FORM CREATE_WITH_REF
  USING
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
    US_BILL_DEFAULT TYPE BEAS_BILL_DEFAULT
    US_ITC_WRK      TYPE BEAS_ITC_WRK
    US_BTY_WRK      TYPE BEAS_BTY_WRK
    US_CRP_GUID     TYPE BEA_CRP_GUID
    UV_TABIX_DLI    TYPE SYTABIX
  CHANGING
    CV_RETURNCODE   TYPE SYSUBRC.

  STATICS:
    LT_REF_DLI_WRK  TYPE /1BEA/T_CRMB_DLI_WRK.
  DATA:
    LS_REF_DLI_WRK  TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_BDI_WRK      TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_WRK      TYPE /1BEA/T_CRMB_BDI_WRK,
    LS_BDH_WRK      TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_NEW_HEAD     TYPE BEA_BOOLEAN,
    LV_RETURNCODE   TYPE SYSUBRC.

  IF (
     US_DLI_WRK-P_LOGSYS NE GS_DLI_HLP_REF-P_LOGSYS OR
     US_DLI_WRK-P_OBJTYPE NE GS_DLI_HLP_REF-P_OBJTYPE OR
     US_DLI_WRK-P_SRC_HEADNO NE GS_DLI_HLP_REF-P_SRC_HEADNO
     ).
    PERFORM REFERENCED_DLI_ENQUEUE
      USING
        US_DLI_WRK
        UV_TABIX_DLI
      CHANGING
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
    CLEAR:
      GS_DLI_HLP_REF,
      LT_REF_DLI_WRK.
    PERFORM REFERENCED_DLI_GET
      USING
        US_DLI_WRK
        uv_tabix_dli
      CHANGING
        LT_REF_DLI_WRK
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.

* Collect data for billing (referenced dli)
* Event BD_OCREE
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREEPAROBD_B2.

    GS_DLI_HLP_REF = US_DLI_WRK.
  ENDIF.
  CLEAR LS_REF_DLI_WRK.
  READ TABLE LT_REF_DLI_WRK INTO LS_REF_DLI_WRK WITH KEY
    LOGSYS = US_DLI_WRK-P_LOGSYS
    OBJTYPE = US_DLI_WRK-P_OBJTYPE
    SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO
    SRC_ITEMNO = US_DLI_WRK-P_SRC_ITEMNO
    BINARY SEARCH.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE E254(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_REF_DLI_WRK
        IV_DLI_GUID    = US_DLI_WRK-DLI_GUID.
     CV_RETURNCODE = 1.
  ENDIF.
  CHECK CV_RETURNCODE IS INITIAL.
  IF NOT LS_REF_DLI_WRK-INCOMP_ID IS INITIAL.
    MESSAGE E237(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_REF_DLI_WRK
        IV_DLI_GUID    = US_DLI_WRK-DLI_GUID.
     CV_RETURNCODE = 1.
  ENDIF.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BDH_PREPARE
    USING
      LS_REF_DLI_WRK
      US_BILL_DEFAULT
      US_BTY_WRK
      US_CRP_GUID
      UV_TABIX_DLI
    CHANGING
      LS_BDH_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BDH_PREPARE_FROM_SUC
    USING
      US_DLI_WRK
      US_BILL_DEFAULT
      US_BTY_WRK
      US_CRP_GUID
    CHANGING
      LS_BDH_WRK.
  PERFORM BDI_PREPARE
    USING
      LS_REF_DLI_WRK
      US_ITC_WRK
    CHANGING
      LS_BDI_WRK.
  PERFORM BDI_PREPARE_FROM_SUC
    USING
      US_DLI_WRK
      US_ITC_WRK
    CHANGING
      LS_BDI_WRK.
  PERFORM BDI_CPREQ_EXECUTE
    USING
      US_DLI_WRK
      US_BTY_WRK
      US_ITC_WRK
      UV_TABIX_DLI
      LS_REF_DLI_WRK
    CHANGING
      LS_BDH_WRK
      LS_BDI_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.

* Enhancements for BDH (DLI with reference)
* Event BD_OCRE4
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE4PAROBD_H2.

  PERFORM BDH_PROCESS
    USING
      US_BTY_WRK
    CHANGING
      LS_BDH_WRK
      LV_NEW_HEAD.
  PERFORM BDI_PROCESS
    USING
      US_BTY_WRK
      US_DLI_WRK
      LV_NEW_HEAD
    CHANGING
      LS_BDI_WRK
      LS_BDH_WRK.

* Enhancements for BDI (DLI with reference)
* Event BD_OCRE5
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE5PAROBD_I2.

  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BDI_ADD_PROCESS
    USING
      US_BTY_WRK
      US_ITC_WRK
      US_DLI_WRK
      LS_BDI_WRK
    CHANGING
      LT_BDI_WRK
      LS_BDH_WRK
      LS_DLI_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BD_COMPLETE
    USING
      US_ITC_WRK
      LS_DLI_WRK
      LV_NEW_HEAD
      UV_TABIX_DLI
    CHANGING
      LT_BDI_WRK
      LS_BDH_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM STATUS_AND_DOCFLOW_MAINTAIN
    USING
      LS_DLI_WRK
      LS_BDI_WRK.

ENDFORM.                "CREATE_WITH_REF
*---------------------------------------------------------------------
*      Form  CREATE_WITHOUT_REF
*---------------------------------------------------------------------
FORM CREATE_WITHOUT_REF
  USING
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
    US_BILL_DEFAULT TYPE BEAS_BILL_DEFAULT
    US_ITC_WRK      TYPE BEAS_ITC_WRK
    US_BTY_WRK      TYPE BEAS_BTY_WRK
    US_CRP_GUID     TYPE BEA_CRP_GUID
    UV_TABIX_DLI    TYPE SYTABIX
  CHANGING
    CV_RETURNCODE   TYPE SYSUBRC.

  DATA:
    LS_REF_DLI_WRK2 TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_BDI_WRK      TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_WRK      TYPE /1BEA/T_CRMB_BDI_WRK,
    LS_BDH_WRK      TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_NEW_HEAD     TYPE BEA_BOOLEAN.

  PERFORM BDH_PREPARE
    USING
      US_DLI_WRK
      US_BILL_DEFAULT
      US_BTY_WRK
      US_CRP_GUID
      UV_TABIX_DLI
    CHANGING
      LS_BDH_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BDI_PREPARE
    USING
      US_DLI_WRK
      US_ITC_WRK
    CHANGING
      LS_BDI_WRK.
  CLEAR LS_REF_DLI_WRK2.
  PERFORM BDI_CPREQ_EXECUTE
    USING
      US_DLI_WRK
      US_BTY_WRK
      US_ITC_WRK
      UV_TABIX_DLI
      LS_REF_DLI_WRK2
    CHANGING
      LS_BDH_WRK
      LS_BDI_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.

* Enhancements for BDH (DLI without reference)
* Event BD_OCRE2
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE2PAROBD_H1.

  PERFORM BDH_PROCESS
    USING
      US_BTY_WRK
    CHANGING
      LS_BDH_WRK
      LV_NEW_HEAD.
  PERFORM BDI_PROCESS
    USING
      US_BTY_WRK
      US_DLI_WRK
      LV_NEW_HEAD
    CHANGING
      LS_BDI_WRK
      LS_BDH_WRK.

* Enhancements for BDI (DLI without reference)
* Event BD_OCRE3
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRE3PAROBD_I1.

  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BDI_ADD_PROCESS
    USING
      US_BTY_WRK
      US_ITC_WRK
      US_DLI_WRK
      LS_BDI_WRK
    CHANGING
      LT_BDI_WRK
      LS_BDH_WRK
      LS_DLI_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM BD_COMPLETE
    USING
      US_ITC_WRK
      LS_DLI_WRK
      LV_NEW_HEAD
      UV_TABIX_DLI
    CHANGING
      LT_BDI_WRK
      LS_BDH_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
  PERFORM STATUS_AND_DOCFLOW_MAINTAIN
    USING
      LS_DLI_WRK
      LS_BDI_WRK.

ENDFORM.                "CREATE_WITHOUT_REF
*---------------------------------------------------------------------
*       FORM REFERENCED_DLI_GET
*---------------------------------------------------------------------
  FORM REFERENCED_DLI_GET
    using
      US_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK
      uv_tabix_dli       TYPE syindex
    CHANGING
      CT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK
      CV_RETURN_CODE     TYPE SYSUBRC.
 DATA:
   LRS_LOGSYS      TYPE /1BEA/RS_CRMB_LOGSYS,
   LRT_LOGSYS      TYPE /1BEA/RT_CRMB_LOGSYS,
   LRS_OBJTYPE      TYPE /1BEA/RS_CRMB_OBJTYPE,
   LRT_OBJTYPE      TYPE /1BEA/RT_CRMB_OBJTYPE,
   LRS_SRC_HEADNO      TYPE /1BEA/RS_CRMB_SRC_HEADNO,
   LRT_SRC_HEADNO      TYPE /1BEA/RT_CRMB_SRC_HEADNO,
   LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
   LRS_BILL_STATUS TYPE BEARS_BILL_STATUS,
   LRT_BILL_STATUS TYPE BEART_BILL_STATUS.

    LRS_LOGSYS-SIGN   = GC_INCLUDE.
    LRS_LOGSYS-OPTION = GC_EQUAL.
    LRS_LOGSYS-LOW    = US_DLI_WRK-P_LOGSYS.
    APPEND LRS_LOGSYS TO LRT_LOGSYS.
    LRS_OBJTYPE-SIGN   = GC_INCLUDE.
    LRS_OBJTYPE-OPTION = GC_EQUAL.
    LRS_OBJTYPE-LOW    = US_DLI_WRK-P_OBJTYPE.
    APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
    LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
    LRS_SRC_HEADNO-OPTION = GC_EQUAL.
    LRS_SRC_HEADNO-LOW    = US_DLI_WRK-P_SRC_HEADNO.
    APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
    LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
    LRS_BILL_STATUS-OPTION = GC_EQUAL.
    LRS_BILL_STATUS-LOW    = GC_BILLSTAT_NO.
    APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
    LRS_BILL_STATUS-LOW    = GC_BILLSTAT_REJECT.
    APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
    EXPORTING
      IV_SORTREL      = GC_SORT_BY_EXTERNAL_REF
      IRT_BILL_STATUS = LRT_BILL_STATUS
      IRT_LOGSYS       = LRT_LOGSYS
      IRT_OBJTYPE       = LRT_OBJTYPE
      IRT_SRC_HEADNO       = LRT_SRC_HEADNO
    IMPORTING
      ET_DLI               = CT_DLI_WRK.
  IF Ct_dli_wrk IS INITIAL.
    cv_return_code = 1.
    LS_DLI_WRK = US_DLI_WRK.
    LS_DLI_WRK-LOGSYS = US_DLI_WRK-P_LOGSYS.
    LS_DLI_WRK-OBJTYPE = US_DLI_WRK-P_OBJTYPE.
    LS_DLI_WRK-SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO.
    LS_DLI_WRK-SRC_ITEMNO = US_DLI_WRK-P_SRC_ITEMNO.
    MESSAGE e222(bea) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO gv_dummy.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_DLI_WRK.
    EXIT. "from form
  ENDIF.
ENDFORM.                    "referenced_dli_get
*---------------------------------------------------------------------
*       FORM REFERENCED_DLI_ENQUEUE
*---------------------------------------------------------------------
  FORM REFERENCED_DLI_ENQUEUE
    using
      US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
      uv_tabix_dli  type sytabix
    CHANGING
      CV_RETURNCODE TYPE SYSUBRC.
 DATA:
   LV_LOGSYS   TYPE /1BEA/S_CRMB_DLI_WRK-LOGSYS,
   LV_OBJTYPE   TYPE /1BEA/S_CRMB_DLI_WRK-OBJTYPE,
   LV_SRC_HEADNO   TYPE /1BEA/S_CRMB_DLI_WRK-SRC_HEADNO,
   LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
   LS_RETURN       TYPE BEAS_RETURN.

  LV_LOGSYS = US_DLI_WRK-P_LOGSYS.
  LV_OBJTYPE = US_DLI_WRK-P_OBJTYPE.
  LV_SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO.
  IF
     LV_LOGSYS IS INITIAL OR
     LV_OBJTYPE IS INITIAL OR
     LV_SRC_HEADNO IS INITIAL
  .
    RETURN.
  ENDIF.
**********************************************************************
* Enqueue
**********************************************************************
  LS_DLI_WRK-LOGSYS = LV_LOGSYS.
  LS_DLI_WRK-OBJTYPE = LV_OBJTYPE.
  LS_DLI_WRK-SRC_HEADNO = LV_SRC_HEADNO.
  CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
    EXPORTING
      IS_DLI_WRK = LS_DLI_WRK
    IMPORTING
      ES_RETURN  = LS_RETURN.
  IF NOT LS_RETURN IS INITIAL.
    MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
            NUMBER LS_RETURN-NUMBER
            WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.
ENDFORM.                    "dli_get
*********************************************************************
*       FORM BDH_PREPARE_FROM_SUC
*********************************************************************
  FORM BDH_PREPARE_FROM_SUC
    USING
      US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
      US_BILL_DEFAULT TYPE BEAS_BILL_DEFAULT
      US_BTY_WRK      TYPE BEAS_BTY_WRK
      UV_CRP_GUID     TYPE BEA_CRP_GUID
    CHANGING
      CS_BDH_WRK      TYPE /1BEA/S_CRMB_BDH_WRK.

* Transfer of fields from successional due list item to bill doc head
* Event BD_OCREB
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREBCPAOBD_H1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREBINCOBD_H1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREBICBOBD_H1.

    MOVE US_DLI_WRK-BILL_DATE TO CS_BDH_WRK-BILL_DATE.
    IF NOT US_BILL_DEFAULT-BILL_DATE IS INITIAL.
      CS_BDH_WRK-BILL_DATE = US_BILL_DEFAULT-BILL_DATE.
    ENDIF.
    IF CS_BDH_WRK-BILL_DATE IS INITIAL.
      CS_BDH_WRK-BILL_DATE = SY-DATLO.
    ENDIF.
    IF NOT US_DLI_WRK-TRANSFER_DATE IS INITIAL.
*    Take Transfer Date from Delivery related Due List
      CS_BDH_WRK-TRANSFER_DATE = US_DLI_WRK-TRANSFER_DATE.
    ELSE.
*    Take Bill Date as Transfer Date
      CS_BDH_WRK-TRANSFER_DATE = CS_BDH_WRK-BILL_DATE.
    ENDIF.
    CS_BDH_WRK-BILL_TYPE  = US_BTY_WRK-BILL_TYPE.
    CS_BDH_WRK-BILL_CATEGORY = US_DLI_WRK-BILL_CATEGORY.
    CS_BDH_WRK-MAINT_DATE = SY-DATLO.
    CS_BDH_WRK-MAINT_TIME = SY-TIMLO.
    CS_BDH_WRK-MAINT_USER = SY-UNAME.
    CS_BDH_WRK-CRP_GUID = UV_CRP_GUID.
    IF US_BTY_WRK-TRANSFER_BLOCK IS INITIAL.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_TODO.
    ELSE.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_BLOCK.
    ENDIF.
    IF CS_BDH_WRK-BILL_CATEGORY = GC_BILL_CAT_PROFORMA.
      CS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_NOT_REL.
    ENDIF.
  ENDFORM.                    "bdh_prepare_from_suc
*********************************************************************
*       FORM BDI_PREPARE_FROM_SUC
*********************************************************************
  FORM BDI_PREPARE_FROM_SUC
    USING
      US_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
      US_ITC_WRK TYPE BEAS_ITC_WRK
    CHANGING
      CS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK.
  DATA:
    LS_SRC_IID TYPE /1BEA/US_CRMB_DL_DLI_SRC_IID.

* Transfer of fields from successional due list item to bill doc item
    CS_BDI_WRK-ITEM_CATEGORY    = US_DLI_WRK-ITEM_CATEGORY.
    CS_BDI_WRK-ITEM_TYPE        = US_DLI_WRK-ITEM_TYPE.
    CS_BDI_WRK-BILL_RELEVANCE   = US_DLI_WRK-BILL_RELEVANCE.
    CS_BDI_WRK-CREDIT_DEBIT     = US_DLI_WRK-CREDIT_DEBIT.
    CS_BDI_WRK-BDI_PRICING_TYPE = US_ITC_WRK-BDI_PRICING_TYPE.
    CS_BDI_WRK-BDI_PRCCOPY_TYPE = US_ITC_WRK-BDI_PRCCOPY_TYPE.
    CS_BDI_WRK-ROOT_DLITEM_GUID = US_DLI_WRK-DLI_GUID.

* Event BD_OCREC
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRECWGTOBD_I1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRECPRDOBD_I1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRECPRCOBD_I2.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCRECICBOBD_I1.
  INCLUDE BETX_PSROBD_I0.

    MOVE-CORRESPONDING US_DLI_WRK TO LS_SRC_IID.
    MOVE-CORRESPONDING LS_SRC_IID TO CS_BDI_WRK.
  ENDFORM.                    "bdi_prepare_from_suc
*---------------------------------------------------------------------
*       FORM BILL_CATEGORY_CHECK
*---------------------------------------------------------------------
FORM BILL_CATEGORY_CHECK
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    US_BTY_WRK    TYPE BEAS_BTY_WRK
    UV_TABIX_DLI  TYPE SYTABIX
  CHANGING
    CV_RETURNCODE TYPE SYSUBRC.

  IF US_DLI_WRK-BILL_CATEGORY <> US_BTY_WRK-BILL_CATEGORY.
    CV_RETURNCODE = 1.
    MESSAGE E112(BEA)
            WITH US_DLI_WRK-BILL_CATEGORY US_BTY_WRK-BILL_TYPE
                 GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK.
  ENDIF.
ENDFORM.                    "bill_category_check
*---------------------------------------------------------------------
*       FORM BDI_ADD_PROCESS
*---------------------------------------------------------------------
  FORM BDI_ADD_PROCESS
    USING
      US_BTY_WRK     TYPE BEAS_BTY_WRK
      US_ITC_WRK     TYPE BEAS_ITC_WRK
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      US_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK
    CHANGING
      CT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK
      CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
      CS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      CV_RETURNCODE  TYPE SYSUBRC.

DATA: LT_BDI_TC_WRK  TYPE /1BEA/T_CRMB_BDI_WRK,
      LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK.

     CS_DLI_WRK = US_DLI_WRK.
     LS_BDI_WRK = US_BDI_WRK.

* Event BD_OCREF
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREFDI0OBD_CIC.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREFDI0OBD_CIU.
     CHECK CV_RETURNCODE IS INITIAL.

     INSERT LS_BDI_WRK INTO CT_BDI_WRK INDEX 1.

   ENDFORM.
* Form Routines for BD_O_CREATE
* Event BD_OCREZ
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPRCOBD_B1Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPRCOBD_B0Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_H1Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_I1Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_H2Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_I2Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_B1Z.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPAROBD_CMZ.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZPITOBD_RNZ.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCREZDI0OBD_CIZ.
