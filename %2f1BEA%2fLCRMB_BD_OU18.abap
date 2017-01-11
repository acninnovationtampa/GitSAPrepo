FUNCTION /1BEA/CRMB_BD_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IT_RETURN) TYPE  BEAT_RETURN OPTIONAL
*"     REFERENCE(IV_DL_WITH_SERVICES) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_NO_PPF) TYPE  BEA_BOOLEAN OPTIONAL
*"     REFERENCE(IV_WITH_DOCFLOW) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_DLI_NO_SAVE) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(ET_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
    LV_NUMBER(10)      TYPE N,
    LV_COLLECTOR_TABIX TYPE SYTABIX,
    LV_QUANTITY_IN     TYPE INRI-QUANTITY,
    LV_QUANTITY_OUT    TYPE INRI-QUANTITY,
    LV_NRNR            TYPE NRNR,
    LV_NRRETURN        TYPE NRRETURN,
    LV_DOCUMENTS       TYPE BEA_CRP_DOCUMENTS,
    LV_ERRORS          TYPE BEA_CRP_ERRORS,
    LV_ERRORS_hlp      TYPE BEA_CRP_ERRORS,
    LV_COMMIT_FLAG     TYPE BEF_COMMIT,
    lt_return          TYPE beat_return,
    LS_RETURN          TYPE BEAS_RETURN,
    LS_BDH_WRK         TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BTY_WRK         TYPE BEAS_BTY_WRK,
    LS_MWC_PARAM       TYPE BEAS_MWC_PARAM,
    LS_COLLECTOR       TYPE BEAS_BILL_TYPE_COLLECTOR,
    LT_COLLECTOR       TYPE BEAT_BILL_TYPE_COLLECTOR,
    LS_NRIV            TYPE NRIV,
    LV_RETURNCODE      TYPE NRRETURN,
    LV_HEADNO_EXT      TYPE BEA_HEADNO_EXT.
**********************************************************************
* Call the SAVE-Methods of the Services:
**********************************************************************
  LV_COMMIT_FLAG = IV_COMMIT_FLAG.
  IF LV_COMMIT_FLAG = GC_COMMIT_LOCAL.
    CALL FUNCTION 'BEA_MWC_O_GETDETAIL'
      EXPORTING
        IV_APPL            = GC_APPL
      IMPORTING
        ES_MWC_PARAM       = LS_MWC_PARAM
      EXCEPTIONS
       NOT_FOUND          = 0
       OTHERS             = 0.
    IF NOT LS_MWC_PARAM-PROCESS_TIME IS INITIAL.
      LV_COMMIT_FLAG = GC_COMMIT_ASYNC.
    ENDIF.
  ENDIF.
  IF LV_COMMIT_FLAG = GC_COMMIT_LOCAL.
    SET UPDATE TASK LOCAL.
  ENDIF.
* Event BD_OSAV0
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV0PAROBD_SAV.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV0PRCOBD_SAV.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV0CRTOBD_SA0.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV0PPFOBD_DET.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV0TXTOBD_SAV.
**********************************************************************
* SAVE the Protocolls
**********************************************************************
  IF NOT gs_CRP-GUID IS INITIAL.
*---------------------------------------------------------------------
* Collective Run Protocol
*---------------------------------------------------------------------
*.....................................................................
* Determine number of new created documents
*.....................................................................
    read table GT_BDH_WRK with key UPD_TYPE = gc_update
                          transporting no fields.
    if sy-subrc NE 0.
       DESCRIBE TABLE GT_BDH_WRK LINES LV_DOCUMENTS.
    else.
       clear LV_DOCUMENTS.
       loop at GT_BDH_WRK transporting no fields
                          where UPD_TYPE = gc_insert.
         add 1 to LV_DOCUMENTS.
       endloop.
    endif.
*.....................................................................
* Determine number of errors
*.....................................................................
    DESCRIBE TABLE GT_RETURN LINES LV_ERRORS.
    DESCRIBE TABLE iT_RETURN LINES LV_ERRORS_hlp.
    ADD LV_ERRORS_hlp TO LV_ERRORS.
*.....................................................................
* Call SAVE-Method of CRP
*.....................................................................
    CALL FUNCTION 'BEA_CRP_O_SAVE'
      EXPORTING
        iv_appl           = gc_appl
        iv_guid           = gs_crp-guid
        iv_documents      = lv_documents
        iv_errors         = lv_errors
      EXCEPTIONS
        wrong_input       = 0
        OTHERS            = 0.
  ENDIF.
*---------------------------------------------------------------------
* Application Log
*---------------------------------------------------------------------
  if not gv_loghndl is initial.
    if    NOT gt_return IS INITIAL
       OR NOT it_return IS INITIAL.
*---------------------------------------------------------------------
* Modify gt_return for bdh-headno_ext
*---------------------------------------------------------------------
       lt_return = gt_return.
       APPEND LINES OF it_return TO lt_return.
       CALL FUNCTION 'BEA_AL_O_SAVE'
          EXPORTING
            iv_loghndl     = gv_loghndl
            it_return      = lt_return
            iv_commit_flag = gc_false
            iv_upd_task    = gc_true
          EXCEPTIONS
            error_at_save  = 0
            wrong_input    = 0
            OTHERS         = 0.
    endif.
  ENDIF.
  LOOP AT GT_BDH_WRK INTO LS_BDH_WRK WHERE UPD_TYPE = GC_INSERT.
    PERFORM ADD_BTY_GET USING    LS_BDH_WRK
                        CHANGING LS_BTY_WRK.
    LS_COLLECTOR-BILL_TYPE   = LS_BDH_WRK-BILL_TYPE.
    LS_COLLECTOR-CANCEL_FLAG = LS_BDH_WRK-CANCEL_FLAG.
    LS_COLLECTOR-NUMRA       = LS_BTY_WRK-NUMRA.
    IF NOT LS_BDH_WRK-CANCEL_FLAG IS INITIAL.
      LS_COLLECTOR-NUMRA = LS_BTY_WRK-NUMRACAN.
    ENDIF.
    LS_COLLECTOR-COUNTER = 1.
    COLLECT LS_COLLECTOR INTO LT_COLLECTOR.
  ENDLOOP.
  SORT LT_COLLECTOR BY BILL_TYPE.
  LOOP AT LT_COLLECTOR INTO LS_COLLECTOR WHERE EXTERNIND IS INITIAL.
    MOVE LS_COLLECTOR-COUNTER TO LV_QUANTITY_IN.
    MOVE LS_COLLECTOR-NUMRA TO LV_NRNR.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR                   = LV_NRNR
        OBJECT                        = GC_NROBJ_BDH
        QUANTITY                      = LV_QUANTITY_IN
        SUBOBJECT                     = GC_APPL
        IGNORE_BUFFER                 = GC_FALSE
      IMPORTING
        NUMBER                        = LS_COLLECTOR-ENDNO
        QUANTITY                      = LV_QUANTITY_OUT
        RETURNCODE                    = LV_NRRETURN
      EXCEPTIONS
        INTERVAL_NOT_FOUND            = 1
        NUMBER_RANGE_NOT_INTERN       = 2
        OBJECT_NOT_FOUND              = 3
        QUANTITY_IS_0                 = 4
        QUANTITY_IS_NOT_1             = 5
        INTERVAL_OVERFLOW             = 6
        BUFFER_OVERFLOW               = 7
        OTHERS                        = 8.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      RETURN.
    ELSE.
      CASE LV_NRRETURN.
        WHEN 1.
          MESSAGE W210(BEA) WITH GC_NROBJ_BDH LV_NRNR INTO GV_DUMMY.
          PERFORM MSG_ADD
              USING    GC_BDH SPACE SPACE SPACE
              CHANGING ET_RETURN.
        WHEN 2.
          MESSAGE W211(BEA) WITH GC_NROBJ_BDH LV_NRNR INTO GV_DUMMY.
          PERFORM MSG_ADD
              USING    GC_BDH SPACE SPACE SPACE
              CHANGING ET_RETURN.
        WHEN 3.
          MESSAGE A290(BEA) WITH GC_NROBJ_BDH LV_NRNR.
      ENDCASE.
    ENDIF.
    LV_NUMBER = LS_COLLECTOR-ENDNO.
    LV_NUMBER = LV_NUMBER - LS_COLLECTOR-COUNTER.
    LV_NUMBER = LV_NUMBER + 1.
    LS_COLLECTOR-ACTUAL_NO = LV_NUMBER.
    MODIFY LT_COLLECTOR FROM LS_COLLECTOR TRANSPORTING ENDNO ACTUAL_NO.
  ENDLOOP.
  LOOP AT GT_BDH_WRK INTO LS_BDH_WRK.
    IF    LS_BDH_WRK-UPD_TYPE = GC_INSERT
       OR LS_BDH_WRK-UPD_TYPE = GC_UPDATE.
       PERFORM ADD_BTY_GET USING    LS_BDH_WRK
                           CHANGING LS_BTY_WRK.
    ELSE.
       CLEAR LS_BTY_WRK.
    ENDIF.
    IF LS_BDH_WRK-UPD_TYPE EQ GC_INSERT.
      READ TABLE LT_COLLECTOR
            INTO LS_COLLECTOR
        WITH KEY BILL_TYPE = LS_BDH_WRK-BILL_TYPE.
      LV_COLLECTOR_TABIX = SY-TABIX.
      IF SY-SUBRC IS INITIAL.
        IF LS_COLLECTOR-EXTERNIND IS INITIAL.
          LS_BDH_WRK-HEADNO_EXT = LS_COLLECTOR-ACTUAL_NO.
          LV_NUMBER = LS_COLLECTOR-ACTUAL_NO.
          ADD 1 TO LV_NUMBER.
          LS_COLLECTOR-ACTUAL_NO = LV_NUMBER.
          MODIFY LT_COLLECTOR
            FROM LS_COLLECTOR
           INDEX LV_COLLECTOR_TABIX TRANSPORTING ACTUAL_NO.
          IF LS_BDH_WRK-REFERENCE_NO IS INITIAL.
            LS_BDH_WRK-REFERENCE_NO = LS_BDH_WRK-HEADNO_EXT.
          ENDIF.
        ELSE.
        ENDIF.
        MODIFY GT_BDH_WRK
          FROM LS_BDH_WRK.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Event BD_OSAV1
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV1CRTOBD_SA1.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV1MWCOBD_SAV.
  INCLUDE %2f1BEA%2fX_CRMBBD_OSAV1PPFOBD_SA1.
**********************************************************************
* Call the POST-Method of the object BD
**********************************************************************
* Wir rufen immer IN UPDATE TASK.
* Der Aufrufer kann bei Bedarf SET UPDATE TASK LOCAL sagen
  CALL FUNCTION '/1BEA/CRMB_BD_P_POST' IN UPDATE TASK
         EXPORTING
            IT_BDH_WRK = GT_BDH_WRK
            IT_BDI_WRK = GT_BDI_WRK.
**********************************************************************
* Save new or altered duelist items
**********************************************************************
  IF IV_DLI_NO_SAVE IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
      EXPORTING
        IV_COMMIT_FLAG   = GC_FALSE
        IV_WITH_SERVICES = IV_DL_WITH_SERVICES
        IV_WITH_DOCFLOW  = IV_WITH_DOCFLOW.
  ENDIF.
**********************************************************************
* eventually COMMIT WORK
**********************************************************************
  CASE LV_COMMIT_FLAG.
    WHEN GC_NOCOMMIT.
*     do nothing
    WHEN GC_COMMIT_ASYNC.
      COMMIT WORK.
    WHEN GC_COMMIT_SYNC.
      COMMIT WORK AND WAIT.
    WHEN GC_COMMIT_LOCAL.
      COMMIT WORK.
  ENDCASE.

**********************************************************************
* Fill export parameter on request
**********************************************************************

IF ET_BDH IS SUPPLIED.
  ET_BDH = GT_BDH_WRK.
ENDIF.

IF ET_BDI IS SUPPLIED.
  ET_BDI = GT_BDI_WRK.
ENDIF.

**********************************************************************
* Refresh Buffer
**********************************************************************
* Globale Daten REFRESHen, damit Puffer "sauber" ist für
* eventuelle Aufrufe im Testmodus
  CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'
    EXPORTING
      IV_DLI_NO_SAVE = IV_DLI_NO_SAVE.
ENDFUNCTION.
*********************************************************************
*       FORM add_bty_get
*********************************************************************
FORM add_bty_get
     USING    uS_BDH_WRK TYPE /1BEA/S_CRMB_BDH_WRK
     CHANGING cS_BTY_WRK TYPE BEAS_BTY_WRK.
*....................................................................
* Declaration
*....................................................................
  STATICS: LS_BTY      TYPE BEAS_BTY_WRK.
*====================================================================
* Implementation
*====================================================================
  CLEAR CS_BTY_WRK.
  IF LS_BTY-BILL_TYPE <> uS_BDH_WRK-BILL_TYPE.
    CLEAR LS_BTY.
    CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
      EXPORTING
        IV_APPL                = GC_APPL
        IV_BTY                 = uS_BDH_WRK-BILL_TYPE
      IMPORTING
        ES_BTY_WRK             = LS_BTY
      EXCEPTIONS
        OBJECT_NOT_FOUND       = 0
        OTHERS                 = 0.
  ENDIF.
  CS_BTY_WRK = LS_BTY.
ENDFORM. " add_bty_get
