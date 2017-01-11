FUNCTION /1BEA/CRMB_DL_O_RELEASE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"     REFERENCE(IS_BILL_DEFAULT) TYPE  BEAS_BILL_DEFAULT OPTIONAL
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
* Time  : 13:53:10
*
*======================================================================
*====================================================================
* Definitionsteil
*====================================================================
  DATA:
    LV_COUNT         TYPE I,
    LS_RETURN        TYPE BEAS_RETURN,
    LS_RETURN2       TYPE BEAS_RETURN,
    LT_RETURN        TYPE BEAT_RETURN,
    LV_ENQUEUED      TYPE BEA_BOOLEAN,
    LS_DLI_HLP       TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_RETURNCODE    TYPE SYSUBRC,
    LRS_DLI_GUID     TYPE BEARS_DLI_GUID,
    LRT_DLI_GUID     TYPE BEART_DLI_GUID,
    LRS_BILL_STATUS  TYPE BEARS_BILL_STATUS,
    LRT_BILL_STATUS  TYPE BEART_BILL_STATUS,
    LRS_BILL_BLOCK   TYPE BEARS_BILL_BLOCK,
    LRT_BILL_BLOCK   TYPE BEART_BILL_BLOCK,
    LS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK       TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_WRK_CLT   TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_WRK_HLP   TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_TABIX         TYPE SYTABIX.
*====================================================================
* Implementierungsteil
*====================================================================
*--------------------------------------------------------------------
* Queue and Building of the Range for the GETLIST
*--------------------------------------------------------------------
  LRS_BILL_STATUS-SIGN = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW = GC_BILLSTAT_TODO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_BILL_BLOCK-SIGN = GC_INCLUDE.
  LRS_BILL_BLOCK-OPTION = GC_EQUAL.
  LRS_BILL_BLOCK-LOW = GC_BILLBLOCK_INTERN.
  APPEND LRS_BILL_BLOCK TO LRT_BILL_BLOCK.
  LRS_BILL_BLOCK-SIGN = GC_INCLUDE.
  LRS_BILL_BLOCK-OPTION = GC_EQUAL.
  LRS_BILL_BLOCK-LOW = GC_BILLBLOCK_QC.
  APPEND LRS_BILL_BLOCK TO LRT_BILL_BLOCK.
  LRS_BILL_BLOCK-SIGN = GC_INCLUDE.
  LRS_BILL_BLOCK-OPTION = GC_EQUAL.
  LRS_BILL_BLOCK-LOW = GC_BILLBLOCK_PROCESS.
  APPEND LRS_BILL_BLOCK TO LRT_BILL_BLOCK.

  LT_DLI_WRK = IT_DLI_WRK.
  SORT LT_DLI_WRK BY
       LOGSYS
       OBJTYPE
       SRC_HEADNO.
  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
    WHERE BILL_STATUS = GC_BILLSTAT_TODO
      AND ( BILL_BLOCK = GC_BILLBLOCK_INTERN
         OR BILL_BLOCK = GC_BILLBLOCK_PROCESS
         OR BILL_BLOCK = GC_BILLBLOCK_QC ).
    LV_TABIX = SY-TABIX.
    CLEAR:
      LS_RETURN,
      LV_RETURNCODE.
    IF (
      LS_DLI_WRK-LOGSYS <> LS_DLI_HLP-LOGSYS OR
      LS_DLI_WRK-OBJTYPE <> LS_DLI_HLP-OBJTYPE OR
      LS_DLI_WRK-SRC_HEADNO <> LS_DLI_HLP-SRC_HEADNO
       ).
      CLEAR LS_RETURN2.
      LV_ENQUEUED = GC_FALSE.
      LS_DLI_HLP-LOGSYS = LS_DLI_WRK-LOGSYS.
      LS_DLI_HLP-OBJTYPE = LS_DLI_WRK-OBJTYPE.
      LS_DLI_HLP-SRC_HEADNO = LS_DLI_WRK-SRC_HEADNO.
      CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
        EXPORTING
          IS_DLI_WRK = LS_DLI_HLP
        IMPORTING
          ES_RETURN  = LS_RETURN.
      IF NOT LS_RETURN IS INITIAL.
        LS_RETURN-ROW = LV_TABIX.
        lS_RETURN-PARAMETER = GC_BAPI_PAR_DLI.
        APPEND LS_RETURN TO LT_RETURN.
        LS_RETURN2 = LS_RETURN.
      ELSE.
        LV_ENQUEUED = GC_TRUE.
      ENDIF.
    ELSEIF NOT LS_RETURN2 IS INITIAL.
      MESSAGE ID LS_RETURN2-ID TYPE LS_RETURN2-TYPE
              NUMBER LS_RETURN2-NUMBER
              WITH LS_RETURN2-MESSAGE_V1 LS_RETURN2-MESSAGE_V2
                   LS_RETURN2-MESSAGE_V3 LS_RETURN2-MESSAGE_V4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = LS_DLI_WRK
          IT_RETURN      = LT_RETURN
          IV_TABIX       = LV_TABIX
        IMPORTING
          ET_RETURN      = LT_RETURN.
    ENDIF.
    CHECK LV_ENQUEUED = GC_TRUE.
    PERFORM AUTHORITY_CHECK
      USING
        GC_ACTV_UNLOCK
        LS_DLI_WRK
        LV_TABIX
      CHANGING
        LT_RETURN
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
*     Sperren und Berechtigung erfolgreich => Daten lesen
    LRS_DLI_GUID-SIGN = GC_INCLUDE.
    LRS_DLI_GUID-OPTION = GC_EQUAL.
    LRS_DLI_GUID-LOW = LS_DLI_WRK-DLI_GUID.
    APPEND LRS_DLI_GUID TO LRT_DLI_GUID.
    ADD 1 TO LV_COUNT.
    IF LV_COUNT = GC_MAX_SEL_OPT.
      CLEAR:
        LV_COUNT,
        LT_DLI_WRK_CLT.
*--------------------------------------------------------------------
* Read the collected data via method GETLIST
*--------------------------------------------------------------------
      CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
        EXPORTING
          IRT_DLI_GUID              = LRT_DLI_GUID
          IRT_BILL_STATUS           = LRT_BILL_STATUS
          IRT_BILL_BLOCK            = LRT_BILL_BLOCK
        IMPORTING
          ET_DLI                    = LT_DLI_WRK_CLT.
      APPEND LINES OF LT_DLI_WRK_CLT TO LT_DLI_WRK_HLP.
      CLEAR:
        LRT_DLI_GUID.
    ENDIF.
  ENDLOOP.
  IF NOT LRT_DLI_GUID IS INITIAL.
    CLEAR:
      LT_DLI_WRK_CLT.
*--------------------------------------------------------------------
* Read the collected data via method GETLIST
*--------------------------------------------------------------------
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IRT_DLI_GUID              = LRT_DLI_GUID
        IRT_BILL_STATUS           = LRT_BILL_STATUS
        IRT_BILL_BLOCK            = LRT_BILL_BLOCK
      IMPORTING
        ET_DLI                    = LT_DLI_WRK_CLT.
    APPEND LINES OF LT_DLI_WRK_CLT TO LT_DLI_WRK_HLP.
    CLEAR:
      LRT_DLI_GUID.
  ENDIF.
  IF ET_RETURN IS REQUESTED.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
  ENDIF.
  CHECK NOT LT_DLI_WRK_HLP IS INITIAL.
  CLEAR:
    LT_DLI_WRK.

  LT_DLI_WRK = LT_DLI_WRK_HLP.

  CLEAR:
    LT_DLI_WRK_HLP.
*--------------------------------------------------------------------
* Do the real work
*--------------------------------------------------------------------
  IF is_bill_default IS INITIAL.
    LOOP AT LT_DLI_WRK INTO LS_DLI_WRK.
      CLEAR LS_DLI_WRK-BILL_BLOCK.
      LS_DLI_WRK-UPD_TYPE          = GC_UPDATE.
      CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
           EXPORTING
             IS_DLI_WRK = LS_DLI_WRK.
    ENDLOOP.
  ELSE.
    LOOP AT LT_DLI_WRK INTO LS_DLI_WRK.
      ls_dli_wrk-bill_type  = is_bill_default-bill_type.
      CLEAR LS_DLI_WRK-BILL_BLOCK.
      LS_DLI_WRK-UPD_TYPE   = GC_UPDATE.
      CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
           EXPORTING
             IS_DLI_WRK = LS_DLI_WRK.
    ENDLOOP.
  ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Endeverarbeitung
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 IF IV_PROCESS_MODE = GC_PROC_ADD.
  CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
    EXPORTING
      IV_COMMIT_FLAG   = IV_COMMIT_FLAG
      IV_WITH_SERVICES = GC_FALSE.
 endif.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Initialisierung
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 IF IV_PROCESS_MODE = GC_PROC_TEST.
   CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
 ENDIF.
ENDFUNCTION.
*-----------------------------------------------------------------*
*       FORM AUTHORITY_CHECK                                      *
*-----------------------------------------------------------------*
FORM AUTHORITY_CHECK
  USING
    UV_ACTIVITY    TYPE ACTIV_AUTH
    US_DLI         TYPE /1BEA/S_CRMB_DLI_WRK
    UV_TABIX_DLI   TYPE SYTABIX
  CHANGING
    CT_RETURN      TYPE BEAT_RETURN
    CV_RETURNCODE  TYPE SYSUBRC.
  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
      IV_BILL_TYPE           = US_DLI-BILL_TYPE
      IV_BILL_ORG            = US_DLI-BILL_ORG
      IV_APPL                = GC_APPL
      IV_ACTVT               = UV_ACTIVITY
      IV_CHECK_DLI           = GC_TRUE
      IV_CHECK_BDH           = GC_FALSE
    EXCEPTIONS
      NO_AUTH                = 1
      OTHERS                 = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
    CASE UV_ACTIVITY.
      WHEN GC_ACTV_UNLOCK.
        message e238(bea) with US_DLI-BILL_TYPE US_DLI-BILL_ORG
                               GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                          into gv_dummy.
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    ENDCASE.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI
        IT_RETURN      = CT_RETURN
        IV_TABIX       = UV_TABIX_DLI
      IMPORTING
        ET_RETURN      = CT_RETURN.
  ENDIF.
ENDFORM.
