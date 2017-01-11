FUNCTION /1BEA/CRMB_BD_O_CANCEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BD_GUIDS) TYPE  BEAT_BD_GUIDS
*"     REFERENCE(IS_CRP) TYPE  BEAS_CRP OPTIONAL
*"     REFERENCE(IV_LOGHNDL) TYPE  BALLOGHNDL OPTIONAL
*"     REFERENCE(IV_CAUSE) TYPE  BEA_CANCEL_REASON DEFAULT 'D'
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
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
    LV_CANCEL_TYPE    TYPE CHAR1,
    LT_BD_GUIDS       TYPE BEAT_BD_GUIDS,
    lt_bd_guids_loc   TYPE beat_bd_guids,
    LS_BD_GUIDS       TYPE BEAS_BD_GUIDS,
    LS_BTY            TYPE BEAS_BTY_WRK,
    LS_BDH            TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_CANCEL_BDH     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDI            TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_CANCEL_BDI     TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI            TYPE /1BEA/T_CRMB_BDI_WRK,
    LT_CANCEL_BDI     TYPE /1BEA/T_CRMB_BDI_WRK,
    LT_DLI            TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_REOPEN     TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_bdh_rc         TYPE SYSUBRC,
    LV_bdi_rc         TYPE SYSUBRC,
    LT_RETURN         TYPE BEAT_RETURN,
    lv_bdh_guid_hlp   TYPE bea_bdh_guid,
    LV_DLI_NO_SAVE    TYPE BEA_BOOLEAN.
*====================================================================
* Implementierungsteil
*====================================================================
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Anfangsverarbeitung
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF IV_CAUSE EQ GC_CAUSE_REJ_NEW.
    LV_DLI_NO_SAVE = GC_TRUE.
  ENDIF.
  IF NOT IV_PROCESS_MODE = GC_PROC_NOADD.
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
  LT_BD_GUIDS = IT_BD_GUIDS.
  SORT LT_BD_GUIDS BY BDH_GUID.
  LOOP AT LT_BD_GUIDS INTO LS_BD_GUIDS.
     IF LS_BD_GUIDS-BDH_GUID NE lv_bdh_guid_hlp.
      lv_bdh_guid_hlp = LS_BD_GUIDS-BDH_GUID.
      CLEAR LT_DLI_REOPEN.
      CLEAR LV_CANCEL_TYPE.
      CLEAR LS_BDH.
      CLEAR LT_BDI.
      CLEAR LS_CANCEL_BDH.
      CLEAR LT_CANCEL_BDI.
      CLEAR LV_BDH_RC.
      CLEAR lt_bd_guids_loc.
      PERFORM BD_GET
        USING
          LS_BD_GUIDS-BDH_GUID
          LT_BD_GUIDS
          IV_CAUSE
        CHANGING
          LS_BDH
          LT_BDI
          LV_CANCEL_TYPE
          lt_bd_guids_loc
          LV_BDH_RC.
      CHECK LV_BDH_RC IS INITIAL.
      PERFORM AUTHORITY_CHECK
        USING
          GC_ACTV_CANCEL
          LS_BDH
        CHANGING
          GT_RETURN
          LV_BDH_RC.
      CHECK LV_BDH_RC IS INITIAL.
      PERFORM CANCELLATION_CHECK
        USING
          LS_BDH
        CHANGING
          LV_BDH_RC.
      CHECK LV_BDH_RC IS INITIAL.
      PERFORM BTY_GET
        USING
          LS_BDH-BILL_TYPE
        CHANGING
          LS_BTY
          LV_BDH_RC.
      IF NOT LV_BDH_RC IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
           EXPORTING
             IV_OBJECT      = 'BD'
             IV_CONTAINER   = 'BDH'
             IS_BDH         = LS_BDH.
         CONTINUE.
      ENDIF.
      SORT LT_BDI BY ITEMNO_EXT.
      CLEAR GO_CPREQC.
      PERFORM CANCEL_BDCPREQC_INITIALIZE
        USING
          LS_BTY
        CHANGING
          GO_CPREQC.
      PERFORM BD_ENQUEUE
        USING
          LS_BD_GUIDS-BDH_GUID
        CHANGING
          LV_BDH_RC.
      CHECK LV_BDH_RC IS INITIAL.
      LOOP AT LT_BDI INTO LS_BDI.
        IF LV_CANCEL_TYPE = GC_CANCEL_PARTIAL.
          READ TABLE lt_bd_guids_loc
            WITH KEY bdh_guid = ls_bdi-bdh_guid
                     bdi_guid = ls_bdi-bdi_guid
            TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            CONTINUE. "with next BDI
          ENDIF.
        ENDIF.
        IF LV_CANCEL_TYPE = GC_CANCEL_COMPLETE AND
           LS_BDI-IS_REVERSED = GC_IS_REVED_BY_CANC.
          CONTINUE. "with next BDI
        ENDIF.
        CLEAR LS_CANCEL_BDI.
        CLEAR LV_BDI_RC.
        CLEAR LT_DLI.
        IF LS_BDI-REVERSAL NE GC_REVERSAL_CORREC AND
           LS_BDI-ITEM_TYPE NE GC_ITEM_TYPE_ACCRUAL.
          PERFORM DL_GET
            USING
              LS_BDI
              LS_BDH
            CHANGING
              LT_DLI
              LV_BDI_RC.
          CHECK LV_BDI_RC IS INITIAL.
          PERFORM DL_ENQUEUE
            USING
              LT_DLI
              LS_BDH
              LS_BDI
            CHANGING
              LV_BDI_RC.
          CHECK LV_BDI_RC IS INITIAL.
        ENDIF.
        PERFORM CANCEL_BDH_FILL
          USING
            LS_BDH
            LS_BTY
          CHANGING
            LS_CANCEL_BDH
            LV_BDI_RC.
        CHECK LV_BDI_RC IS INITIAL.
        PERFORM CANCEL_BDI_FILL
          USING
            LS_BDI
            LS_CANCEL_BDH
          CHANGING
            LS_CANCEL_BDI
            LV_BDI_RC.
        CHECK LV_BDI_RC IS INITIAL.
        PERFORM CANCEL_BDI_CHECK
          USING
            LS_BDH
            LS_BDI
            LT_DLI
            LT_BDI
          CHANGING
            LV_BDI_RC.
        CHECK LV_BDI_RC IS INITIAL.
        PERFORM CANCEL_BDCPREQC_EXECUTE
          USING
            GO_CPREQC
            LS_BTY
            LS_BDH
            LS_BDI
            IV_CAUSE
          CHANGING
            LS_CANCEL_BDH
            LS_CANCEL_BDI
            LV_BDI_RC.
        CHECK LV_BDI_RC IS INITIAL.
        PERFORM CANCEL_BDI_ADD
          USING
            IV_CAUSE
            LS_BDI
            LS_BDH
            LT_DLI
          CHANGING
            LT_DLI_REOPEN
            LS_CANCEL_BDI
            LT_CANCEL_BDI
            LV_BDI_RC.
        CHECK LV_BDI_RC IS INITIAL.
      ENDLOOP.
      PERFORM CANCEL_BDH_COMPLETE
        USING
          LT_DLI_REOPEN
          LS_BTY
          IV_CAUSE
        CHANGING
          LS_BDH
          LT_BDI
          LS_CANCEL_BDH
          LT_CANCEL_BDI
          LV_BDH_RC.
     ENDIF.
  ENDLOOP.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Endeverarbeitung
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF NOT IV_PROCESS_MODE = GC_PROC_NOADD.
    IF ET_RETURN IS REQUESTED.
      ET_RETURN = gT_RETURN.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
      EXPORTING
        IV_PROCESS_MODE  = IV_PROCESS_MODE
        IV_COMMIT_FLAG   = IV_COMMIT_FLAG
        IV_DLI_NO_SAVE   = LV_DLI_NO_SAVE
      IMPORTING
        ET_RETURN           = LT_RETURN.
    IF ET_RETURN IS REQUESTED.
      APPEND LINES OF lt_return TO et_return.
    ENDIF.
  ELSE.
    IF ET_RETURN IS REQUESTED.
      ET_RETURN = GT_RETURN.
    ENDIF.
 ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Initialisierung
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF IV_PROCESS_MODE = GC_PROC_TEST.
    CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
  ENDIF.
ENDFUNCTION.
*-----------------------------------------------------------------*
*       FORM BD_ENQUEUE                                           *
*-----------------------------------------------------------------*
FORM BD_ENQUEUE
  USING
   UV_BDH_GUID   TYPE BEA_BDH_GUID
  CHANGING
   CV_RETURNCODE TYPE SYSUBRC.
  DATA: ls_bdh   TYPE /1bea/S_CRMB_BDH_WRK,
        lv_user  TYPE symsgv,
        lv_subrc TYPE sysubrc,
        LS_ENQUEUE_BDH TYPE TY_ENQUEUE_BDH_S.
  CALL FUNCTION 'ENQUEUE_E_BEA_BD'
    EXPORTING
      CLIENT         = SY-MANDT
      BDH_GUID       = UV_BDH_GUID
      APPL           = GC_APPL
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC = 0.
    LS_ENQUEUE_BDH-BDH_GUID = UV_BDH_GUID.
    LS_ENQUEUE_BDH-APPL = GC_APPL.
    INSERT LS_ENQUEUE_BDH INTO TABLE GT_ENQUEUE_BDH.
  ELSE.
    lv_user = sy-msgv1.
    lv_subrc = sy-subrc.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
      EXPORTING
        iv_bdh_guid = uv_bdh_guid
      IMPORTING
        es_bdh      = ls_bdh
      EXCEPTIONS
        notfound    = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO gv_dummy.
      ls_bdh-bdh_guid = uv_bdh_guid.
    ELSE.
      CASE lv_subrc.
        WHEN 1.
            MESSAGE e223(bea)
               WITH ls_bdh-headno_ext lv_user INTO gv_dummy.
        WHEN OTHERS.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              INTO gv_dummy.
      ENDCASE.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = LS_BDH.
    CV_RETURNCODE = 1.
  ENDIF.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM BD_GET                                               *
*-----------------------------------------------------------------*
FORM BD_GET
  USING
    UV_BDH_GUID     TYPE BEA_BDH_GUID
    UT_BD_GUIDS     TYPE BEAT_BD_GUIDS
    UV_CAUSE        TYPE BEA_CANCEL_REASON
  CHANGING
    CS_BDH          TYPE /1BEA/S_CRMB_BDH_WRK
    CT_BDI          TYPE /1BEA/T_CRMB_BDI_WRK
    CV_CANCEL_TYPE  TYPE CHAR1
    ct_bd_guids_loc TYPE beat_bd_guids
    CV_RETURNCODE   TYPE SYSUBRC.

DATA:
  LS_BD_GUIDS  TYPE BEAS_BD_GUIDS,
  LRS_BDH_GUID TYPE BEARS_BDH_GUID,
  LRT_BDH_GUID TYPE BEART_BDH_GUID,
  LT_BDH       TYPE /1BEA/T_CRMB_BDH_WRK,
  LS_BDH       TYPE /1BEA/S_CRMB_BDH_WRK.

  LRS_BDH_GUID-SIGN   = GC_INCLUDE.
  LRS_BDH_GUID-OPTION = GC_EQUAL.
  LRS_BDH_GUID-LOW    = UV_BDH_GUID.
  APPEND LRS_BDH_GUID TO LRT_BDH_GUID.
  CV_CANCEL_TYPE = GC_CANCEL_FULL.
  LOOP AT UT_BD_GUIDS INTO LS_BD_GUIDS
                      WHERE BDH_GUID = UV_BDH_GUID.
    IF NOT LS_BD_GUIDS-BDI_GUID IS INITIAL.
      CV_CANCEL_TYPE = GC_CANCEL_PARTIAL.
      APPEND LS_BD_GUIDS TO ct_bd_guids_loc.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
    EXPORTING
      IRT_BDH_BDH_GUID = LRT_BDH_GUID
    IMPORTING
      ET_BDH           = LT_BDH
      ET_BDI           = CT_BDI.
  READ TABLE LT_BDH INTO CS_BDH INDEX 1.
  IF NOT SY-SUBRC IS INITIAL.
   MESSAGE E231(BEA) WITH UV_BDH_GUID INTO GV_DUMMY.
   CLEAR LS_BDH.
   LS_BDH-BDH_GUID = UV_BDH_GUID.
   CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
     EXPORTING
       IV_OBJECT      = 'BD'
       IV_CONTAINER   = 'BDH'
       IS_BDH         = LS_BDH.
    CV_RETURNCODE = 1.
  ENDIF.

  READ TABLE CT_BDI WITH KEY is_reversed = gc_is_reved_by_canc
                   TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    IF CV_CANCEL_TYPE = GC_CANCEL_FULL.
      CV_CANCEL_TYPE = GC_CANCEL_COMPLETE.
    ENDIF.
  ENDIF.
* Event BD_OCNC4
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC4DI0OBD_PCA.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC4COBOBD_PCA.

ENDFORM.
*-----------------------------------------------------------------*
*       FORM AUTHORITY_CHECK                                      *
*-----------------------------------------------------------------*
FORM AUTHORITY_CHECK
  USING
    UV_ACTIVITY    TYPE ACTIV_AUTH
    US_BDH         TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING
    CT_RETURN      TYPE BEAT_RETURN
    CV_RETURNCODE  TYPE SYSUBRC.

  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
      IV_BILL_TYPE           = US_BDH-BILL_TYPE
      IV_BILL_ORG            = US_BDH-BILL_ORG
      IV_APPL                = GC_APPL
      IV_ACTVT               = UV_ACTIVITY
      IV_CHECK_DLI           = GC_FALSE
      IV_CHECK_BDH           = GC_TRUE
    EXCEPTIONS
      NO_AUTH                = 1
      OTHERS                 = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
    CASE UV_ACTIVITY.
      WHEN GC_ACTV_CANCEL.
        MESSAGE E215(BEA) WITH US_BDH-BILL_TYPE US_BDH-BILL_ORG
        US_BDH-HEADNO_EXT INTO GV_DUMMY.
          PERFORM MSG_ADD
             USING    GC_BDH SPACE SPACE SPACE
             CHANGING CT_RETURN.
      WHEN GC_ACTV_TRANSITION.
        MESSAGE E228(BEA) WITH US_BDH-BILL_TYPE US_BDH-BILL_ORG
        US_BDH-HEADNO_EXT INTO GV_DUMMY.
          PERFORM MSG_ADD
             USING    GC_BDH SPACE SPACE SPACE
             CHANGING CT_RETURN.
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    ENDCASE.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = US_BDH.
  ENDIF.

ENDFORM.
*-----------------------------------------------------------------*
*       FORM                                                      *
*-----------------------------------------------------------------*
FORM CANCELLATION_CHECK
  USING
    US_BDH        TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING
    CV_RETURNCODE TYPE SYSUBRC.


  IF NOT US_BDH-CANCEL_FLAG IS INITIAL.
    CV_RETURNCODE = 1.
    MESSAGE E217(BEA) WITH US_BDH-HEADNO_EXT INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = US_BDH.
  ELSEIF    US_BDH-transfer_status = gc_transfer_in_work
         OR US_BDH-transfer_status = gc_transfer_cancel.
    CV_RETURNCODE = 1.
    MESSAGE E219(BEA) WITH US_BDH-HEADNO_EXT INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = US_BDH.
  ELSEIF    US_BDH-archivable      = gc_true.
    CV_RETURNCODE = 1.
    MESSAGE E239(BEA) WITH US_BDH-HEADNO_EXT INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = US_BDH.
  ENDIF.


ENDFORM.
*-----------------------------------------------------------------*
*       FORM DL_GET                                               *
*-----------------------------------------------------------------*
FORM DL_GET
  USING
    US_BDI          TYPE /1BEA/S_CRMB_BDI_WRK
    US_BDH          TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING
    CT_DLI          TYPE /1BEA/T_CRMB_DLI_WRK
    CV_RETURNCODE   TYPE SYSUBRC.

DATA :
  LV_ERROR            TYPE BEA_BOOLEAN,
  LRS_BDI_GUID        TYPE BEARS_BDI_GUID,
  LRT_BDI_GUID        TYPE BEART_BDI_GUID.

  LRS_BDI_GUID-SIGN   = GC_INCLUDE.
  LRS_BDI_GUID-OPTION = GC_EQUAL.
  LRS_BDI_GUID-LOW    = US_BDI-BDI_GUID.
  APPEND LRS_BDI_GUID TO LRT_BDI_GUID.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
    EXPORTING
      IRT_BDI_GUID = LRT_BDI_GUID
    IMPORTING
      ET_DLI       = CT_DLI.
  IF CT_DLI IS INITIAL.
    LV_ERROR = GC_TRUE.
  ENDIF.


  IF LV_ERROR = GC_TRUE.
    MESSAGE E233(bea) WITH US_BDI-ITEMNO_EXT INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDI'
        IS_BDH         = US_BDH
        IS_BDI         = US_BDI.
    CV_RETURNCODE = 1.
  ENDIF.

ENDFORM.
*-----------------------------------------------------------------*
*       FORM DL_ENQUEUE                                           *
*-----------------------------------------------------------------*
FORM DL_ENQUEUE
  USING
    UT_DLI        TYPE /1BEA/T_CRMB_DLI_WRK
    US_BDH        TYPE /1BEA/S_CRMB_BDH_WRK
    US_BDI        TYPE /1BEA/S_CRMB_BDI_WRK
  CHANGING
    CV_RETURNCODE TYPE SYSUBRC.

DATA :
  LS_RETURN  TYPE BEAS_RETURN,
  LS_DLI     TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DLI_ENQ TYPE /1BEA/S_CRMB_DLI_WRK,
  LT_DLI     TYPE /1BEA/T_CRMB_DLI_WRK.

  LT_DLI = UT_DLI.
  SORT LT_DLI BY
    LOGSYS
    OBJTYPE
    SRC_HEADNO.
  LOOP AT LT_DLI INTO LS_DLI.
    CLEAR LS_DLI_ENQ.
    LS_DLI_ENQ-LOGSYS = LS_DLI-LOGSYS.
    LS_DLI_ENQ-OBJTYPE = LS_DLI-OBJTYPE.
    LS_DLI_ENQ-SRC_HEADNO = LS_DLI-SRC_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
      EXPORTING
        IS_DLI_WRK = LS_DLI_ENQ
      IMPORTING
        ES_RETURN  = LS_RETURN.
    IF NOT LS_RETURN IS INITIAL.
      CV_RETURNCODE = 1.
      MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
              NUMBER LS_RETURN-NUMBER
              WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                   LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
             INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDI'
          IS_BDH         = US_BDH
          IS_BDI         = US_BDI.
    ENDIF.
  ENDLOOP.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDH_FILL                                      *
*-----------------------------------------------------------------*
FORM CANCEL_BDH_FILL
  USING
    US_BDH        TYPE /1BEA/S_CRMB_BDH_WRK
    US_BTY        TYPE BEAS_BTY_WRK
  CHANGING
    CS_CANCEL_BDH TYPE /1BEA/S_CRMB_BDH_WRK
    CV_RETURNCODE TYPE SYSUBRC.

  DATA:
    BEGIN OF LS_DOC_ID,
      PREFIX(1) TYPE C VALUE '$',
      ID(9)     TYPE N VALUE '000000000',
    END OF LS_DOC_ID.

  DATA:
    LV_LINES       TYPE SYTABIX.

  CHECK : CS_CANCEL_BDH IS INITIAL.
  MOVE-CORRESPONDING US_BDH TO CS_CANCEL_BDH.

* Initialize copied fields in cancel BDH
* Event BD_OCNC0
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC0PAROBD_CH1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC0PRCOBD_CH1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC0TXTOBD_CH1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC0MWCOBD_CH1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC0ACCOBD_CH1.

  CLEAR:
    CS_CANCEL_BDH-CRP_GUID,
    CS_CANCEL_BDH-HEADNO_EXT,
    CS_CANCEL_BDH-TRANSFER_STATUS,
    CS_CANCEL_BDH-SPLIT_CRITERIA,
    CS_CANCEL_BDH-ITEMNO_HI.
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      EV_GUID_16 = CS_CANCEL_BDH-BDH_GUID.
  CS_CANCEL_BDH-CANC_BDH_GUID = US_BDH-BDH_GUID.
  CS_CANCEL_BDH-MAINT_USER    = SY-UNAME.
  CS_CANCEL_BDH-MAINT_DATE    = SY-DATLO.
  CS_CANCEL_BDH-MAINT_TIME    = SY-TIMLO.
  CS_CANCEL_BDH-CRP_GUID      = GS_CRP-GUID.
  CS_CANCEL_BDH-UPD_TYPE      = GC_INSERT.
  CS_CANCEL_BDH-CANCEL_FLAG   = GC_CANCEL.
  DESCRIBE TABLE GT_BDH_WRK LINES LV_LINES.
  LV_LINES = LV_LINES DIV 2.
  ADD 1 TO LV_LINES.
  LS_DOC_ID-ID = LV_LINES.
  CS_CANCEL_BDH-HEADNO_EXT = LS_DOC_ID.
  CLEAR CV_RETURNCODE.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM   CANCEL_BDI_FILL                                    *
*-----------------------------------------------------------------*
FORM CANCEL_BDI_FILL
  USING
    US_BDI        TYPE /1BEA/S_CRMB_BDI_WRK
    US_CANCEL_BDH TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING
    CS_CANCEL_BDI TYPE /1BEA/S_CRMB_BDI_WRK
    CV_RETURNCODE TYPE SYSUBRC.

  MOVE-CORRESPONDING US_BDI TO CS_CANCEL_BDI.

* Initialize copied fields in cancel BDI
* Event BD_OCNC1
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC1PAROBD_CI1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC1PRCOBD_CI1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC1TXTOBD_CI1.

   CALL FUNCTION 'GUID_CREATE'
     IMPORTING
       EV_GUID_16 = CS_CANCEL_BDI-BDI_GUID.

   CS_CANCEL_BDI-BDH_GUID          = US_CANCEL_BDH-BDH_GUID.
   CS_CANCEL_BDI-REVERSAL          = GC_REVERSAL_CANCEL.
   CLEAR CS_CANCEL_BDI-IS_REVERSED.
   CS_CANCEL_BDI-REVERSED_BDI_GUID = US_BDI-BDI_GUID.
   CS_CANCEL_BDI-UPD_TYPE          = GC_INSERT.
   CLEAR CV_RETURNCODE.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDI_ADD                                       *
*-----------------------------------------------------------------*
FORM CANCEL_BDI_ADD
  USING
    UV_CAUSE      TYPE BEA_CANCEL_REASON
    US_BDI        TYPE /1BEA/S_CRMB_BDI_WRK
    US_BDH        TYPE /1BEA/S_CRMB_BDH_WRK
    UT_DLI        TYPE /1BEA/T_CRMB_DLI_WRK
  CHANGING
    CT_DLI_REOPEN TYPE /1BEA/T_CRMB_DLI_WRK
    CS_CANCEL_BDI TYPE /1BEA/S_CRMB_BDI_WRK
    CT_CANCEL_BDI TYPE /1BEA/T_CRMB_BDI_WRK
    CV_RETURNCODE TYPE SYSUBRC.
DATA :
  LS_ITC          TYPE BEAS_ITC_WRK,
  LS_DLI_REOPEN   TYPE /1BEA/S_CRMB_DLI_WRK,
  LT_DLI_COMPRESS TYPE /1BEA/T_CRMB_DLI_WRK,
  LS_DLI          TYPE /1BEA/S_CRMB_DLI_WRK.

  IF NOT UV_CAUSE EQ GC_CAUSE_REJ_NEW.
    LOOP AT UT_DLI INTO LS_DLI.
      CALL FUNCTION '/1BEA/CRMB_DL_O_REOPEN'
        EXPORTING
          IS_DLI          = LS_DLI
          IV_CAUSE        = UV_CAUSE
        IMPORTING
          ES_DLI          = LS_DLI_REOPEN
        EXCEPTIONS
          OTHERS          = 1.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
          EXPORTING
            IV_OBJECT      = 'BD'
            IV_CONTAINER   = 'BDI'
            IS_BDH         = US_BDH
            IS_BDI         = US_BDI.
        CV_RETURNCODE = 1.
        EXIT.
      ELSE.
        APPEND LS_DLI_REOPEN TO CT_DLI_REOPEN.
        APPEND LS_DLI_REOPEN TO LT_DLI_COMPRESS.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CHECK CV_RETURNCODE IS INITIAL.
  CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
    EXPORTING
      IV_APPL          = GC_APPL
      IV_ITC           = US_BDI-ITEM_CATEGORY
    IMPORTING
      ES_ITC_WRK       = LS_ITC
    EXCEPTIONS
      OBJECT_NOT_FOUND = 1
      OTHERS           = 2.
  IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDI'
          IS_BDH         = US_BDH
          IS_BDI         = US_BDI.
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.

* Enhancements for cancel BDI
* Event BD_OCNC2
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC2PAROBD_CI2.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC2TXTOBD_CI2.

  APPEND CS_CANCEL_BDI TO CT_CANCEL_BDI.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDH_COMPLETE                                  *
*-----------------------------------------------------------------*
FORM CANCEL_BDH_COMPLETE
  USING
    UT_DLI_REOPEN  TYPE /1BEA/T_CRMB_DLI_WRK
    US_BTY        TYPE BEAS_BTY_WRK
    UV_CAUSE      TYPE BEA_CANCEL_REASON
  CHANGING
    CS_BDH         TYPE /1BEA/S_CRMB_BDH_WRK
    CT_BDI         TYPE /1BEA/T_CRMB_BDI_WRK
    CS_CANCEL_BDH  TYPE /1BEA/S_CRMB_BDH_WRK
    CT_CANCEL_BDI  TYPE /1BEA/T_CRMB_BDI_WRK
    CV_RETURNCODE  TYPE SYSUBRC.

DATA :
  LS_DLI_REOPEN    TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DFL           TYPE BEAS_DFL_WRK,
  LV_LINES         TYPE SYTFILL,
  LV_LINES_CANCEL  TYPE SYTFILL,
  LS_CANCEL_BDI    TYPE /1BEA/S_CRMB_BDI_WRK,
  LT_CANCELLED_BDI TYPE /1BEA/T_CRMB_BDI_WRK,
  LS_CANCELLED_BDI TYPE /1BEA/S_CRMB_BDI_WRK,
  lv_full_cancel   TYPE bea_boolean.

 CHECK NOT CT_CANCEL_BDI IS INITIAL.
 CLEAR CV_RETURNCODE.
 LOOP AT CT_CANCEL_BDI INTO LS_CANCEL_BDI.
   LOOP AT CT_BDI INTO LS_CANCELLED_BDI
                  WHERE BDI_GUID = LS_CANCEL_BDI-REVERSED_BDI_GUID.
     LS_CANCELLED_BDI-UPD_TYPE = GC_UPDATE.
     LS_CANCELLED_BDI-IS_REVERSED = gc_is_reved_by_canc.
     MODIFY ct_bdi FROM ls_cancelled_bdi.
     APPEND LS_CANCELLED_BDI TO LT_CANCELLED_BDI.
   ENDLOOP.
 ENDLOOP.
 IF NOT CT_CANCEL_BDI IS INITIAL.
   DESCRIBE TABLE CT_BDI LINES LV_LINES.
   DESCRIBE TABLE CT_CANCEL_BDI LINES LV_LINES_CANCEL.
   IF NOT LV_LINES = LV_LINES_CANCEL.
     lv_full_cancel = gc_false.
   ELSE.
     lv_full_cancel = gc_true.
   ENDIF.

* Enhancements for cancel BDH
* Event BD_OCNC3
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC3PAROBD_CH2.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC3TXTOBD_CH2.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC3PRCOBD_CH2.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC3CRTOBD_CH1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNC3DEQOBD_CH2.

  ENDIF. "NOT CT_CANCEL_BDI IS INITIAL
 IF CV_RETURNCODE IS INITIAL.
   LOOP AT CT_CANCEL_BDI INTO LS_CANCEL_BDI.
     LS_DFL-CLIENT      = SY-MANDT.
     LS_DFL-PRE_GUID    = LS_CANCEL_BDI-REVERSED_BDI_GUID.
     LS_DFL-SUC_GUID    = LS_CANCEL_BDI-BDI_GUID.
     LS_DFL-PRE_OBJTYPE = GC_BOR_BDI.
     LS_DFL-SUC_OBJTYPE = GC_BOR_BDI.
     LS_DFL-APPL        = GC_APPL.
     LS_DFL-UPD_TYPE    = GC_INSERT.
     CALL FUNCTION 'BEA_DFL_O_CREATE'
       EXPORTING
         IS_DFL        = LS_DFL.
   ENDLOOP.

   IF lv_full_cancel = gc_false.
     CS_CANCEL_BDH-CANCEL_FLAG = GC_PARTIAL_CANCEL.
   ELSE.
     CS_CANCEL_BDH-CANCEL_FLAG = GC_CANCEL.
   ENDIF.
*--------------------------------------------------------------------
* Transfer Status are set
*--------------------------------------------------------------------
   IF CS_BDH-TRANSFER_STATUS = GC_TRANSFER_DONE.
     CS_CANCEL_BDH-TRANSFER_STATUS = GC_TRANSFER_TODO.
   ELSEIF CS_BDH-TRANSFER_STATUS = GC_TRANSFER_NOT_REL.
     CS_CANCEL_BDH-TRANSFER_STATUS = CS_BDH-TRANSFER_STATUS.
   ELSE.
     IF lv_full_cancel = gc_true.
       CS_BDH-TRANSFER_STATUS        = GC_TRANSFER_CANCEL.
       CS_CANCEL_BDH-TRANSFER_STATUS = GC_TRANSFER_CANCEL.
     ELSE.
*No immediate transfer of partially cancelled invoices with transfer error
       CS_BDH-TRANSFER_STATUS = GC_TRANSFER_BLOCK.
       CS_CANCEL_BDH-TRANSFER_STATUS = CS_BDH-TRANSFER_STATUS.
     ENDIF.
   ENDIF.
   LS_CANCELLED_BDI-UPD_TYPE = GC_UPDATE.
*  make sure that all items of cancelled document appear in the result
   MODIFY CT_BDI FROM LS_CANCELLED_BDI TRANSPORTING UPD_TYPE
          WHERE UPD_TYPE IS INITIAL.
   CS_BDH-UPD_TYPE = GC_UPDATE.
   CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
     EXPORTING
       IS_BDH        = CS_BDH
       IT_BDI        = CT_BDI.
   CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
     EXPORTING
       IS_BDH        = CS_CANCEL_BDH
       IT_BDI        = CT_CANCEL_BDI.
   LOOP AT UT_DLI_REOPEN INTO LS_DLI_REOPEN.
       CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
         EXPORTING
           IS_DLI_WRK       = LS_DLI_REOPEN.
   ENDLOOP.
 ENDIF.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDI_CHECK                                     *
*-----------------------------------------------------------------*
FORM CANCEL_BDI_CHECK
  USING
    US_BDH        TYPE /1BEA/S_CRMB_BDH_WRK
    US_BDI        TYPE /1BEA/S_CRMB_BDI_WRK
    UT_DLI        TYPE /1BEA/T_CRMB_DLI_WRK
    UT_BDI        TYPE /1BEA/T_CRMB_BDI_WRK
  CHANGING
    CV_RETURNCODE TYPE SYSUBRC.

  IF US_BDI-IS_REVERSED EQ GC_IS_REVED_BY_CANC.
    CV_RETURNCODE = 1.
    MESSAGE E227(BEA) WITH US_BDH-HEADNO_EXT US_BDI-ITEMNO_EXT
                      INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDI'
        IS_BDH         = US_BDH
        IS_BDI         = US_BDI.
  ENDIF.

* Enhanced Checks: Item Can/Cannot be Cancelled

ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDCPREQC_EXECUTE                              *
*-----------------------------------------------------------------*
FORM CANCEL_BDCPREQC_EXECUTE
  USING
    UO_CPREQC         TYPE REF TO BEA_CRMB_BD_CPREQC
    US_BTY_WRK        TYPE BEAS_BTY_WRK
    US_BDH_WRK        TYPE /1BEA/S_CRMB_BDH_WRK
    US_BDI_WRK        TYPE /1BEA/S_CRMB_BDI_WRK
    UV_CAUSE          TYPE BEA_CANCEL_REASON
  CHANGING
    CS_CANCEL_BDH_WRK TYPE /1BEA/S_CRMB_BDH_WRK
    CS_CANCEL_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK
    CV_RETURNCODE     TYPE SYSUBRC.
  DATA :
    LS_FILTER     TYPE BEAS_BDCPREQCFLT.

  IF uo_cpreqc IS NOT INITIAL.
    LS_FILTER-APPL        = US_BTY_WRK-APPLICATION.
    LS_FILTER-FILTERVALUE = US_BTY_WRK-CANCEL_REQ.
    CALL BADI UO_CPREQC->CANCEL_REQUIREMENT
      EXPORTING
        FLT_VAL           = LS_FILTER
        IS_BTY_WRK        = US_BTY_WRK
        IS_BDH_WRK        = US_BDH_WRK
        IS_BDI_WRK        = US_BDI_WRK
        IV_CAUSE          = UV_CAUSE
      CHANGING
        CS_CANCEL_BDH_WRK = CS_CANCEL_BDH_WRK
        CS_CANCEL_BDI_WRK = CS_CANCEL_BDI_WRK
      EXCEPTIONS
        ABORTED    = 1.
    CV_RETURNCODE = SY-SUBRC.
    IF NOT CV_RETURNCODE IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDI'
          IS_BDH         = US_BDH_WRK
          IS_BDI         = US_BDI_WRK.
    ENDIF.
  ENDIF.
ENDFORM.
*-----------------------------------------------------------------*
*       FORM CANCEL_BDCPREQC_INITIALIZE                           *
*-----------------------------------------------------------------*
FORM CANCEL_BDCPREQC_INITIALIZE
  USING
    US_BTY_WRK        TYPE BEAS_BTY_WRK
  CHANGING
    CO_CPREQC         TYPE REF TO BEA_CRMB_BD_CPREQC.
  IF NOT us_bty_wrk-cancel_req IS INITIAL.
    TRY.
        GET BADI co_cpreqc
          FILTERS
            cpreqc = us_bty_wrk-cancel_req.
      CATCH cx_badi_not_implemented.
    ENDTRY.
  ENDIF.
ENDFORM.
* Event BD_OCNCZ
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNCZDI0OBD_PCZ.
  INCLUDE %2f1BEA%2fX_CRMBBD_OCNCZCOBOBD_PCZ.
