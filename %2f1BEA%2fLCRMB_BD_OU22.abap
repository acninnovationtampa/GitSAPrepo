FUNCTION /1BEA/CRMB_BD_O_TRANSFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_SHOW_STATISTICS) TYPE  BEA_BOOLEAN OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"  EXPORTING
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
    LV_COUNT            TYPE I,
    LS_BDH_HLP          TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDH              TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_BDH              TYPE /1BEA/T_CRMB_BDH_WRK,
    LT_BDH_WRK_CLT      TYPE /1BEA/T_CRMB_BDH_WRK,
    LT_BDI_WRK_CLT      TYPE /1BEA/T_CRMB_BDI_WRK,
    LRS_BDH_GUID        TYPE BEARS_BDH_GUID,
    LRT_BDH_GUID        TYPE BEART_BDH_GUID,
    LRS_TRANSFER_STATUS TYPE BEARS_TRANSFER_STATUS,
    LRT_TRANSFER_STATUS TYPE BEART_TRANSFER_STATUS,
    LT_RETURN           TYPE BEAT_RETURN,
    LV_RETURNCODE       TYPE SYSUBRC,
    lv_user             TYPE symsgv,
    LS_RETURN           TYPE BEAS_RETURN,
    LV_COUNT_ALL        TYPE I,
    LV_COUNT_OK         TYPE I,
    LV_COUNT_ERROR      TYPE I,
    LS_ENQUEUE_BDH      TYPE TY_ENQUEUE_BDH_S.

* Only process mode A and B are supported, no test runs
  CHECK iv_process_mode EQ gc_proc_add OR iv_process_mode EQ gc_proc_noadd.

* refresh workareas
  CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.

  LT_BDH = IT_BDH.
  DESCRIBE TABLE LT_BDH LINES LV_COUNT_ALL.

  SORT LT_BDH BY
      BILL_TYPE
      BILL_ORG.

* nur Abrechnungsbelege selektieren, die noch nicht
* übergeleitet wurden
*
* => Fill range for billing documents, if locking possible
  LRS_BDH_GUID-SIGN = GC_INCLUDE.
  LRS_BDH_GUID-OPTION = GC_EQUAL.
*
* => Fill range for transfer status
  LRS_TRANSFER_STATUS-SIGN   = GC_INCLUDE.
  LRS_TRANSFER_STATUS-OPTION = GC_EQUAL.
  LRS_TRANSFER_STATUS-LOW    = GC_TRANSFER_TODO.
  APPEND LRS_TRANSFER_STATUS TO LRT_TRANSFER_STATUS.
  LRS_TRANSFER_STATUS-LOW    = GC_TRANSFER_BLOCK.
  APPEND LRS_TRANSFER_STATUS TO LRT_TRANSFER_STATUS.
*
  LOOP AT LT_BDH INTO LS_BDH.
    CLEAR:
      LV_RETURNCODE.
* Abrechnungsbeleg sperren
    CALL FUNCTION 'ENQUEUE_E_BEA_BD'
      EXPORTING
        CLIENT         = SY-MANDT
        BDH_GUID       = LS_BDH-BDH_GUID
        APPL           = GC_APPL
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
* Beleg kann nicht verarbeitet werden
      lv_user = sy-msgv1.
      MESSAGE E214(BEA) WITH LS_BDH-HEADNO_EXT lv_user INTO GV_DUMMY.
      PERFORM MSG_ADD USING GC_BDH LS_BDH-BDH_GUID SPACE SPACE
                      CHANGING LT_RETURN.
      ADD 1 TO LV_COUNT_ERROR.
      CONTINUE.
    ENDIF.
    LS_ENQUEUE_BDH-BDH_GUID = LS_BDH-BDH_GUID.
    LS_ENQUEUE_BDH-APPL = GC_APPL.
    INSERT LS_ENQUEUE_BDH INTO TABLE GT_ENQUEUE_BDH.
    PERFORM AUTHORITY_CHECK
      USING
        GC_ACTV_TRANSITION
        LS_BDH
      CHANGING
        LT_RETURN
        LV_RETURNCODE.
    IF LV_RETURNCODE IS NOT INITIAL.
      ADD 1 TO LV_COUNT_ERROR.
    ENDIF.
    CHECK LV_RETURNCODE IS INITIAL.
* Sperre und Berechtigung erfolgreich => Daten des Beleges lesen
    IF
       LS_BDH-BILL_TYPE <> LS_BDH_HLP-BILL_TYPE OR
       LS_BDH-BILL_ORG <> LS_BDH_HLP-BILL_ORG OR
       LV_COUNT = GV_MAX_SEL_OPT.
      IF NOT LS_BDH_HLP IS INITIAL.
        CLEAR:
          LV_COUNT,
          LT_BDH_WRK_CLT,
          LT_BDI_WRK_CLT.
        CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
          EXPORTING
            IRT_BDH_BDH_GUID          = LRT_BDH_GUID
            IRT_BDH_TRANSFER_STATUS   = LRT_TRANSFER_STATUS
          IMPORTING
            ET_BDH                    = LT_BDH_WRK_CLT
            ET_BDI                    = LT_BDI_WRK_CLT.

        APPEND LINES OF LT_BDH_WRK_CLT TO GT_BDH_WRK.
        APPEND LINES OF LT_BDI_WRK_CLT TO GT_BDI_WRK.
        CLEAR:
          LRT_BDH_GUID.
*       set transfer status and UPDATE-flag for ADD-processing
        LS_BDH-TRANSFER_STATUS = GC_TRANSFER_TODO.
        LS_BDH-UPD_TYPE = GC_UPDATE.
        MODIFY GT_BDH_WRK FROM LS_BDH
               TRANSPORTING TRANSFER_STATUS UPD_TYPE
               WHERE UPD_TYPE IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
          EXPORTING
*           IV_PROCESS_MODE         = 'B'
            IV_COMMIT_FLAG          = IV_COMMIT_FLAG
            IV_NO_PPF               = GC_TRUE
            IV_DLI_NO_SAVE          = GC_TRUE.
      ENDIF.
      LS_BDH_HLP = LS_BDH.
    ENDIF.
    ADD 1 TO LV_COUNT.
    LRS_BDH_GUID-LOW = LS_BDH-BDH_GUID.
    APPEND LRS_BDH_GUID TO LRT_BDH_GUID.
  ENDLOOP.
  IF NOT LRT_BDH_GUID IS INITIAL.
    CLEAR:
      LT_BDH_WRK_CLT,
      LT_BDI_WRK_CLT.
    CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
      EXPORTING
        IRT_BDH_BDH_GUID          = LRT_BDH_GUID
        IRT_BDH_TRANSFER_STATUS   = LRT_TRANSFER_STATUS
      IMPORTING
        ET_BDH                    = LT_BDH_WRK_CLT
        ET_BDI                    = LT_BDI_WRK_CLT.
    APPEND LINES OF LT_BDH_WRK_CLT TO GT_BDH_WRK.
    APPEND LINES OF LT_BDI_WRK_CLT TO GT_BDI_WRK.
    CLEAR:
      LRT_BDH_GUID.
  ENDIF.
  IF ET_RETURN IS REQUESTED.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    IF IV_SHOW_STATISTICS IS NOT INITIAL.
*     Show info message with number of documents processed successfully
      LV_COUNT_OK = LV_COUNT_ALL - LV_COUNT_ERROR.
      MESSAGE I770(BEA) WITH LV_COUNT_OK INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                      CHANGING LT_RETURN.
      IF LV_COUNT_ERROR > 0.
        MESSAGE I771(BEA) WITH LV_COUNT_ERROR INTO GV_DUMMY.
        PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                        CHANGING LT_RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  ET_RETURN = LT_RETURN.
  CHECK NOT GT_BDH_WRK IS INITIAL.

* Überleitungsstatus und UPDATE-Flag setzen,
* damit im ADD das Richtige passiert
  LS_BDH-TRANSFER_STATUS = GC_TRANSFER_TODO.
  LS_BDH-UPD_TYPE = GC_UPDATE.
  MODIFY GT_BDH_WRK FROM LS_BDH
         TRANSPORTING TRANSFER_STATUS UPD_TYPE
         WHERE UPD_TYPE IS INITIAL.

  CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
    EXPORTING
      IV_PROCESS_MODE       = IV_PROCESS_MODE
      IV_COMMIT_FLAG        = IV_COMMIT_FLAG
      IV_NO_PPF             = GC_TRUE
      IV_DLI_NO_SAVE        = GC_TRUE.

ENDFUNCTION.
