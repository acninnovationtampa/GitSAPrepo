FUNCTION /1BEA/CRMB_DL_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI_INT) TYPE  /1BEA/S_CRMB_DLI_INT
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IT_CONDITION) TYPE  BEAT_PRC_COM OPTIONAL
*"     REFERENCE(IT_PARTNER) TYPE  BEAT_PAR_COM OPTIONAL
*"     REFERENCE(IT_TEXTLINE) TYPE  COMT_TEXT_TEXTDATA_T OPTIONAL
*"     REFERENCE(IV_TESTRUN) TYPE  TESTRUN DEFAULT ' '
*"     REFERENCE(IT_RETURN) TYPE  BEAT_RETURN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK
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
* Time  : 13:53:10
*
*======================================================================
*====================================================================
* Definition part
*====================================================================
*--------------------------------------------------------------------
* Definition of local data
*--------------------------------------------------------------------
  DATA:
    LS_ITC           TYPE BEAS_ITC_WRK.
*==================================================================
* Implementation part
*==================================================================
  ET_RETURN = IT_RETURN.
  PERFORM CREATE
    USING
      IS_DLI_INT
      IT_DLI_WRK
      IT_CONDITION
      IT_PARTNER
      IT_TEXTLINE
      IV_TESTRUN
    CHANGING
      ES_DLI_WRK
      LS_ITC
      ET_RETURN.
  PERFORM UPDATE
    USING
      IS_DLI_INT
      LS_ITC
      IT_DLI_WRK
      IT_CONDITION
      IT_PARTNER
      IT_TEXTLINE
      ES_DLI_WRK
      IV_TESTRUN
    CHANGING
      ET_RETURN.
ENDFUNCTION.
*-----------------------------------------------------------------*
*     FORM Item_Category_get
*-----------------------------------------------------------------*
FORM ITEM_CATEGORY_GET
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_ITC_WRK    TYPE BEAS_ITC_WRK
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SYSUBRC.

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
    CV_RETURNCODE = SY-SUBRC.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
  ENDIF.
ENDFORM.                    "item_category_get
*-----------------------------------------------------------------*
*       FORM CREATE
*-----------------------------------------------------------------*
*       Create new duelist item from the data sent by the
*       source application
*-----------------------------------------------------------------*
FORM CREATE
  USING
    US_DLI_INT    TYPE /1BEA/S_CRMB_DLI_INT
    UT_DLI_WRK    TYPE /1BEA/T_CRMB_DLI_WRK
    UT_CONDITION     TYPE BEAT_PRC_COM
    UT_PARTNER     TYPE BEAT_PAR_COM
    UT_TEXTLINE     TYPE COMT_TEXT_TEXTDATA_T
    UV_TESTRUN    TYPE TESTRUN
  CHANGING
    CS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    CS_ITC        TYPE BEAS_ITC_WRK
    CT_RETURN     TYPE BEAT_RETURN.

  DATA:
    LV_RETURNCODE       TYPE SYSUBRC,
    LV_BUFFER_ADD       TYPE BEA_BOOLEAN,
    LS_BTY_WRK          TYPE BEAS_BTY_WRK,
    LV_BILLED_QUANTITY  TYPE BEA_QUANTITY,
    LS_DLI_NV           TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_WRK          TYPE /1BEA/S_CRMB_DLI_WRK.



* don't create a new open entry, if data are missing at all, because
* only an update of billed or deletion of open entries is requested.
  CHECK NOT US_DLI_INT IS INITIAL.
* takeover public and protected attributes
  MOVE-CORRESPONDING US_DLI_INT TO LS_DLI_WRK.
* set invariant data
  LS_DLI_WRK-MAINT_USER = SY-UNAME.
  LS_DLI_WRK-MAINT_DATE = SY-DATLO.
  LS_DLI_WRK-MAINT_TIME = SY-TIMLO.
  LS_DLI_WRK-UPD_TYPE   = GC_INSERT.
  LV_BUFFER_ADD         = GC_TRUE.
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      EV_GUID_16 = LS_DLI_WRK-DLI_GUID.
* check and takeover customizing settings
  PERFORM ITEM_CATEGORY_GET
    USING
      LS_DLI_WRK
    CHANGING
      CS_ITC
      CT_RETURN
      LV_RETURNCODE.
  LS_DLI_WRK-BILL_BLOCK = CS_ITC-BILL_BLOCK.
  LS_DLI_WRK-BILL_TYPE  = CS_ITC-BILL_TYPE.
* determine bill status
  LS_DLI_WRK-BILL_STATUS =  GC_BILLSTAT_TODO.
  IF CS_ITC-BILL_RELEV = GC_BILL_REL_INDIRECT
     AND US_DLI_INT-DERIV_CATEGORY = GC_DERIV_ORIGIN.
    LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_NO.
  ELSEIF US_DLI_INT-BILL_RELEVANCE_C = GC_BILL_REL_BILLREQ_I
     AND US_DLI_INT-DERIV_CATEGORY = GC_DERIV_ORIGIN.
    LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_NO.
  ELSEIF NOT US_DLI_INT-INCOMP_ID = GC_INCOMP_ENQ
     AND NOT US_DLI_INT-SRC_REJECT IS INITIAL.
    LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_REJECT.
  ELSE.
    PERFORM BTY_GET
      USING
        LS_DLI_WRK
      CHANGING
        LS_BTY_WRK
        CT_RETURN
        LV_RETURNCODE.
  ENDIF.
* Respect Billing Category different from customer billing document
  IF LS_DLI_WRK-BILL_CATEGORY IS INITIAL.
    LS_DLI_WRK-BILL_CATEGORY = LS_BTY_WRK-BILL_CATEGORY.
  ENDIF.

* Event DL_OCRE2
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE20CMODL_CUS.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE20CMODL_DYP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2PRDODL_QA.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2OFIODL_BO.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2PARODL_CR.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2ICBODL_CUD.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2ICBODL_CHK.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2CPAODL_TOP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2PRCODL_CR.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2TXTODL_CR.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2DI0ODL_CHK.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2DRBODL_CHK.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE2DRVODL_S1O.

  IF LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_TODO.
    PERFORM BILL_CATEGORY_CHECK
      USING
        LS_DLI_WRK
        LS_BTY_WRK
      CHANGING
        CT_RETURN
        LV_RETURNCODE.
  ENDIF.
  PERFORM AL_CREATE
      CHANGING
        LS_DLI_WRK
        CT_RETURN.

  IF NOT LV_RETURNCODE IS INITIAL.
    IF LS_DLI_WRK-INCOMP_ID IS INITIAL.
      LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
    ENDIF.
  ENDIF.
  CS_DLI_WRK = LS_DLI_WRK.
  IF UV_TESTRUN    = GC_FALSE AND
     LV_BUFFER_ADD = GC_TRUE.
    PERFORM ADD_TO_BUFFER
      CHANGING
        LS_DLI_WRK.
  ENDIF.
ENDFORM.                    "create
*-----------------------------------------------------------------*
*       FORM UPDATE
*-----------------------------------------------------------------*
*       Update billed duelist items whose invoice might still
*       be cancelled. Then, after a cancellation of the invoice,
*       the new invoice will be created from the updated data, i.e.
*       with the most recent data sent from the source application.
*-----------------------------------------------------------------*
FORM UPDATE
    USING
      US_DLI_INT    TYPE /1BEA/S_CRMB_DLI_INT
      US_ITC        TYPE BEAS_ITC_WRK
      UT_DLI_WRK    TYPE /1BEA/T_CRMB_DLI_WRK
      UT_CONDITION     TYPE BEAT_PRC_COM
      UT_PARTNER     TYPE BEAT_PAR_COM
      UT_TEXTLINE     TYPE COMT_TEXT_TEXTDATA_T
      US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
      UV_TESTRUN    TYPE TESTRUN
    CHANGING
      CT_RETURN     TYPE BEAT_RETURN.

  DATA:
    LV_BUFFER_ADD   TYPE BEA_BOOLEAN,
    LV_RETURNCODE   TYPE SYSUBRC,
    LT_RETURN       TYPE BEAT_RETURN,
    LS_DLICI        TYPE BEAS_DLICI,
    LS_DLI_CTRL_UPD TYPE BEAS_DLI_CTRL_UPD,
    LS_DLI_PRTC_UPD TYPE /1BEA/S_CRMB_DLI_SRV,
    LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_WRK_OLD  TYPE /1BEA/S_CRMB_DLI_WRK.

  CHECK UV_TESTRUN = GC_FALSE.
  CHECK: US_DLI_INT-SRC_ACTIVITY <> GC_SRC_ACTIVITY_INSERT.
  LV_BUFFER_ADD = GC_TRUE.
  LOOP AT UT_DLI_WRK INTO LS_DLI_WRK.
    CLEAR LT_RETURN.
    IF LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_DONE.
      LS_DLI_WRK_OLD = LS_DLI_WRK.

      MOVE-CORRESPONDING LS_DLI_WRK TO LS_DLICI.
      IF NOT US_DLI_INT IS INITIAL.
        MOVE-CORRESPONDING US_DLI_INT TO LS_DLI_WRK.
        MOVE-CORRESPONDING US_DLI_WRK TO LS_DLI_CTRL_UPD.
        MOVE-CORRESPONDING US_DLI_WRK TO LS_DLI_PRTC_UPD.
        MOVE-CORRESPONDING LS_DLI_PRTC_UPD TO LS_DLI_WRK.
        MOVE-CORRESPONDING LS_DLI_CTRL_UPD TO LS_DLI_WRK.
      ENDIF.
      MOVE-CORRESPONDING LS_DLICI   TO LS_DLI_WRK.
*     updated billed entries basically may become complete
      CLEAR LS_DLI_WRK-INCOMP_ID.
*     reset references to service containers
      LS_DLI_WRK-PRIDOC_GUID = LS_DLI_WRK_OLD-PRIDOC_GUID.
      LS_DLI_WRK-PARSET_GUID = LS_DLI_WRK_OLD-PARSET_GUID.

* Event DL_OCRE3
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE30CMODL_UP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3PRDODL_RVQ.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3OFIODL_BO1.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3PARODL_UP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3PRCODL_UP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3TXTODL_UP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE30CMODL_DYP.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE3DRBODL_UP.

      PERFORM AL_CREATE
        CHANGING
          LS_DLI_WRK
          LT_RETURN.

      LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
    ELSE.
      LS_DLI_WRK-UPD_TYPE = GC_DELETE.

* Event DL_OCRE4
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE4PARODL_DL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE4PRCODL_DL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE4TXTODL_DL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE4DRVODL_S1O.

      PERFORM AL_DELETE
        USING
          LS_DLI_WRK
        CHANGING
          LT_RETURN.

    ENDIF.
    IF LV_BUFFER_ADD = GC_TRUE.
      CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
        EXPORTING
          IS_DLI_WRK       = LS_DLI_WRK.
    ENDIF.
    INSERT LINES OF LT_RETURN INTO TABLE CT_RETURN.
  ENDLOOP.
ENDFORM.                    "update
*---------------------------------------------------------------------
*      Form  row_upd_and_app_to_beatreturn
*---------------------------------------------------------------------
* Shall be used after having called a
* Service function module in order to update the row-field with the
* sytabix of the DueListItem and in order to append the error-table
* of the service to the error-table of the function group DLI_O
* In addition missing context information are filled.
*---------------------------------------------------------------------
FORM row_upd_and_app_to_beatreturn
    USING    iv_parameter TYPE bapi_param
             iv_row       TYPE bapi_line
             it_beareturn TYPE beat_return
             is_dli_wrk   TYPE /1BEA/S_CRMB_DLI_WRK
    CHANGING ct_beareturn TYPE beat_return.

 DATA: ls_beareturn TYPE beas_return,
       lt_beareturn TYPE beat_return.

 lt_beareturn = it_beareturn.
 LOOP AT lt_beareturn INTO ls_beareturn.
   ls_beareturn-row = iv_row.
   ls_beareturn-parameter = iv_parameter.
   IF ls_beareturn-src_headno IS INITIAL.
     ls_beareturn-src_headno = is_dli_wrk-src_headno.
     ls_beareturn-src_itemno = is_dli_wrk-src_itemno.
   ENDIF.
   APPEND ls_beareturn TO ct_beareturn.
 ENDLOOP.

ENDFORM.                "row_upd_and_app_to_beatreturn
*---------------------------------------------------------------------
*       FORM BILL_CATEGORY_CHECK
*---------------------------------------------------------------------
FORM BILL_CATEGORY_CHECK
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    US_BTY_WRK    TYPE BEAS_BTY_WRK
  CHANGING
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SYSUBRC.

  IF US_DLI_WRK-BILL_CATEGORY <> US_BTY_WRK-BILL_CATEGORY.
    MESSAGE E112(BEA)
            WITH US_DLI_WRK-BILL_CATEGORY US_BTY_WRK-BILL_TYPE
                 GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
    CV_RETURNCODE = 1.
  ENDIF.
ENDFORM.                    "bill_category_check
*---------------------------------------------------------------------
*       FORM BTY_GET
*---------------------------------------------------------------------
FORM BTY_GET
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_BTY_WRK    TYPE BEAS_BTY_WRK
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SYSUBRC.
  CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
    EXPORTING
      IV_APPL          = GC_APPL
      IV_BTY           = US_DLI_WRK-BILL_TYPE
    IMPORTING
      ES_BTY_WRK       = CS_BTY_WRK
    EXCEPTIONS
      OBJECT_NOT_FOUND = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO gv_dummy.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
  ENDIF.
ENDFORM.                    "BTY_GET
*       FORM ADD_TO_BUFFER
*-----------------------------------------------------------------*
FORM ADD_TO_BUFFER
  CHANGING
    CS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK.

  IF NOT CS_DLI_WRK IS INITIAL.
    CS_DLI_WRK-UPD_TYPE = GC_INSERT.
    CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
      EXPORTING
       IS_DLI_WRK = CS_DLI_WRK.
  ENDIF.
ENDFORM.                    "add_to_buffer
*---------------------------------------------------------------------
*       FORM al_create
*---------------------------------------------------------------------
FORM AL_CREATE
  CHANGING
    CS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    CT_RETURN     TYPE BEAT_RETURN.

DATA:
  LV_EXTNUMBER     TYPE BALNREXT,
  LV_EXTNUMBER_HLP TYPE BALNREXT.

CHECK NOT CT_RETURN IS INITIAL.

IF CS_DLI_WRK-LOGHNDL IS INITIAL.
  WRITE CS_DLI_WRK-LOGSYS TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE CS_DLI_WRK-OBJTYPE TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE CS_DLI_WRK-SRC_HEADNO TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE CS_DLI_WRK-SRC_ITEMNO TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  CALL FUNCTION 'BEA_AL_O_CREATE'
    EXPORTING
      IV_APPL            = GC_APPL
      IV_DLI_GUID        = CS_DLI_WRK-DLI_GUID
      IV_EXTNUMBER       = LV_EXTNUMBER
    IMPORTING
      EV_LOGHNDL         = CS_DLI_WRK-LOGHNDL
    EXCEPTIONS
      LOG_ALREADY_EXISTS = 1
      LOG_NOT_CREATED    = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = CS_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
    RETURN.  " from form
  ENDIF.
ENDIF.
CALL FUNCTION 'BEA_AL_O_MSGS_ADD'
  EXPORTING
    iv_loghndl   = cs_dli_wrk-loghndl
    it_return    = ct_return
  EXCEPTIONS
    error_at_add = 1
    OTHERS       = 2.
IF sy-subrc <> 0.
  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
          INTO GV_DUMMY.
  CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
    EXPORTING
      IV_CONTAINER   = 'DLI'
      IS_DLI_WRK     = CS_DLI_WRK
      IT_RETURN      = CT_RETURN
    IMPORTING
      ET_RETURN      = CT_RETURN.
ELSE.
  INSERT CS_DLI_WRK-LOGHNDL INTO TABLE GT_LOGHNDL.
ENDIF.

ENDFORM.                    " AL_CREATE
*---------------------------------------------------------------------
*       FORM al_delete
*---------------------------------------------------------------------
FORM AL_DELETE
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_RETURN     TYPE BEAT_RETURN.

DATA:
  LV_EXTNUMBER     TYPE BALNREXT,
  LV_EXTNUMBER_HLP TYPE BALNREXT,
  LT_BALHDR        TYPE BALHDR_T.

IF NOT US_DLI_WRK-INCOMP_ID IS INITIAL.
  WRITE US_DLI_WRK-LOGSYS TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE US_DLI_WRK-OBJTYPE TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE US_DLI_WRK-SRC_HEADNO TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  WRITE US_DLI_WRK-SRC_ITEMNO TO LV_EXTNUMBER_HLP.
  CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
  CALL FUNCTION 'BEA_AL_O_GETLIST'
    EXPORTING
      IV_APPL              = GC_APPL
      IV_DLI_GUID          = US_DLI_WRK-DLI_GUID
      IV_EXTNUMBER         = LV_EXTNUMBER
    IMPORTING
      ET_BALHDR_T          = LT_BALHDR
   EXCEPTIONS
      LOG_NOT_FOUND        = 1
      INTERNAL_ERROR       = 2
      WRONG_INPUT          = 3
      OTHERS               = 4.
  IF SY-SUBRC > 1.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
    RETURN.  " from form
  ENDIF.
  INSERT LINES OF LT_BALHDR INTO TABLE GT_BALHDR_DEL.
ENDIF.

ENDFORM.                    " AL_DELETE

* Event DL_OCREZ
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZOFIODL_BOZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPARODL_CRZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPARODL_DLZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPRCODL_CRZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPRCODL_MRG.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPRDODL_QAZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZTXTODL_CRZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZICBODL_BOZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPARODL_DTZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZICBODL_DRZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZICBODL_CHZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZICBODL_CUZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZICXODL_DRZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZPSRODL_GET.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZ0CMODL_DYZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZDRBODL_CHZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZCPAODL_GET.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZDRVODL_PIP.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZDRVODL_CSZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCREZDRVODL_SAZ.
