FUNCTION /1BEA/CRMB_DL_O_ERRORLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
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
* Time  : 13:53:10
*
*======================================================================
  DATA:
    LV_COUNT                TYPE I,
    LV_PARENTRECNO          TYPE SYTABIX,
    LV_RETURNCODE           TYPE SYSUBRC,
    LS_RETURN               TYPE BEAS_RETURN,
    LT_RETURN               TYPE BEAT_RETURN,
    LV_ENQUEUED             TYPE BEA_BOOLEAN,
    LS_DLI_HLP              TYPE /1BEA/S_CRMB_DLI_WRK,
    LRS_DLI_GUID            TYPE BEARS_DLI_GUID,
    LRT_DLI_GUID            TYPE BEART_DLI_GUID,
    LRS_BILL_STATUS         TYPE BEARS_BILL_STATUS,
    LRT_BILL_STATUS         TYPE BEART_BILL_STATUS,
    LRS_INCOMP_ID           TYPE BEARS_INCOMP_ID,
    LRT_INCOMP_ID           TYPE BEART_INCOMP_ID,
    LS_DLI_WRK              TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK              TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_WRK_CLT          TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_WRK_HLP          TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK_HLP          TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_INT              TYPE /1BEA/S_CRMB_DLI_INT,
    LS_DLI_COM              TYPE /1BEA/S_CRMB_DLI_COM,
    LT_DLI_COM              TYPE /1BEA/T_CRMB_DLI_COM,
    LT_CONDITION               TYPE BEAT_DLI_PRC_COM,
    LT_PARTNER               TYPE BEAT_DLI_PAR_COM,
    LT_TEXTHEAD               TYPE BEAT_DLI_TXT_HEAD_COM,
    LT_TEXTLINE               TYPE BEAT_DLI_TXT_LINE_COM,
    LT_CONDITION_DRV           TYPE BEAT_PRC_COM,
    LT_PARTNER_DRV           TYPE BEAT_PAR_COM,
    LT_TEXTLINE_DRV           TYPE COMT_TEXT_TEXTDATA_T,
    LV_DLI_GUID             TYPE BEA_DLI_GUID,
    LV_DERIV_CATEGORY       TYPE BEA_DERIV_CATEGORY,
    LV_TABIX                TYPE SYTABIX.

*--------------------------------------------------------------------
* prepare ranges for date selection via method GETLIST
*--------------------------------------------------------------------
  LRS_BILL_STATUS-SIGN     = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION   = GC_NOT_EQUAL.
  LRS_BILL_STATUS-LOW      = GC_BILLSTAT_REJECT.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_INCOMP_ID-SIGN       = GC_INCLUDE.
  LRS_INCOMP_ID-OPTION     = GC_NOT_EQUAL.
  LRS_INCOMP_ID-LOW        = GC_INCOMP_OK.
  APPEND LRS_INCOMP_ID TO LRT_INCOMP_ID.

  LT_DLI_WRK = IT_DLI_WRK.
  SORT LT_DLI_WRK BY
       LOGSYS
       OBJTYPE
       SRC_HEADNO.
  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
    WHERE NOT INCOMP_ID IS INITIAL.
    IF LS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORIGIN.
      CHECK LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_TODO
         OR LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_NO.
    ENDIF.
    LV_TABIX = SY-TABIX.
    CLEAR:
      LV_RETURNCODE.
    IF (
      LS_DLI_WRK-LOGSYS NE LS_DLI_HLP-LOGSYS OR
      LS_DLI_WRK-OBJTYPE NE LS_DLI_HLP-OBJTYPE OR
      LS_DLI_WRK-SRC_HEADNO NE LS_DLI_HLP-SRC_HEADNO
       ).
      CLEAR LS_RETURN.
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
        LS_RETURN-ROW       = LV_TABIX.
        LS_RETURN-PARAMETER = GC_BAPI_PAR_DLI.
        APPEND LS_RETURN TO LT_RETURN.
      ELSE.
        LV_ENQUEUED = GC_TRUE.
      ENDIF.
    ELSEIF NOT LS_RETURN IS INITIAL.
      MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
              NUMBER LS_RETURN-NUMBER
              WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                   LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
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
        GC_ACTV_CHECK
        LS_DLI_WRK
        LV_TABIX
      CHANGING
        LT_RETURN
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
*     Sperren und Berechtigung erfolgreich => Daten lesen
    LRS_DLI_GUID-SIGN   = GC_INCLUDE.
    LRS_DLI_GUID-OPTION = GC_EQUAL.
    LRS_DLI_GUID-LOW    = LS_DLI_WRK-DLI_GUID.
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
          IV_SORTREL        = GC_SORT_BY_EXTERNAL_REF
          IRT_DLI_GUID      = LRT_DLI_GUID
          IRT_BILL_STATUS   = LRT_BILL_STATUS
          IRT_INCOMP_ID     = LRT_INCOMP_ID
        IMPORTING
          ET_DLI            = LT_DLI_WRK_CLT.
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
        IV_SORTREL        = GC_SORT_BY_EXTERNAL_REF
        IRT_DLI_GUID      = LRT_DLI_GUID
        IRT_BILL_STATUS   = LRT_BILL_STATUS
        IRT_INCOMP_ID     = LRT_INCOMP_ID
      IMPORTING
        ET_DLI            = LT_DLI_WRK_CLT.
    APPEND LINES OF LT_DLI_WRK_CLT TO LT_DLI_WRK_HLP.
    CLEAR:
      LRT_DLI_GUID.
  ENDIF.
  IF ET_RETURN IS REQUESTED.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
  ENDIF.
*--------------------------------------------------------------------
* Build the interface for the method CREATE
*--------------------------------------------------------------------
  CHECK NOT LT_DLI_WRK_HLP IS INITIAL.
  CLEAR:
    LT_DLI_WRK.

  LT_DLI_WRK = LT_DLI_WRK_HLP.

  CLEAR:
    LT_DLI_WRK_HLP.
  SORT LT_DLI_WRK BY
                      LOGSYS
                      OBJTYPE
                      SRC_HEADNO
                      SRC_ITEMNO
                      MAINT_DATE DESCENDING
                      MAINT_TIME DESCENDING.

*--------------------------------------------------------------------
* Clear table DLI from entries with INCOMP_ID = E and D
*--------------------------------------------------------------------
  CLEAR LT_RETURN.
  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
       WHERE INCOMP_ID = GC_INCOMP_CANCEL
          OR INCOMP_ID = GC_INCOMP_FATAL.
    IF LS_DLI_WRK-INCOMP_ID = GC_INCOMP_CANCEL.
      MESSAGE E261(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
    ENDIF.
    IF LS_DLI_WRK-INCOMP_ID = GC_INCOMP_FATAL.
      MESSAGE E264(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_DLI_WRK
        IT_RETURN      = LT_RETURN
*       IV_TABIX       = SY-TABIX
      IMPORTING
        ET_RETURN      = LT_RETURN.
    DELETE LT_DLI_WRK.
  ENDLOOP.
  IF ET_RETURN IS REQUESTED AND
     NOT LT_RETURN IS INITIAL.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    CLEAR LT_RETURN.
  ENDIF.

  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK.
    CHECK LS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORIGIN.
    LV_PARENTRECNO = SY-TABIX.
*   Build the interface structure COM of the method CREATE
    MOVE-CORRESPONDING LS_DLI_WRK TO LS_DLI_COM.
*   do not perform quantity adaptation
    LS_DLI_COM-SRC_ACTIVITY = GC_SRC_ACTIVITY_DL04.
* Event DL_OERL0
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL00CMODL_EL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL0PARODL_EL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL0PRDODL_EL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL0PRCODL_EL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL0TXTODL_EL.

    APPEND LS_DLI_COM TO LT_DLI_COM.

  ENDLOOP.
*--------------------------------------------------------------------
* Process the method CREATE
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_DL_O_PROCESS'
    EXPORTING
      IT_DLI          = LT_DLI_COM
      IT_CONDITION       = LT_CONDITION
      IT_PARTNER       = LT_PARTNER
      IT_TEXTHEAD       = LT_TEXTHEAD
      IT_TEXTLINE       = LT_TEXTLINE
      IV_COMMIT_FLAG  = IV_COMMIT_FLAG
      IV_PROCESS_MODE = IV_PROCESS_MODE
    IMPORTING
      ET_RETURN       = LT_RETURN.
  IF ET_RETURN IS REQUESTED.
* Translate return table to DLI_GUIDs
    LOOP AT LT_RETURN INTO LS_RETURN.
      IF NOT LS_RETURN-ROW IS INITIAL.
        READ TABLE LT_DLI_WRK INTO LS_DLI_WRK INDEX LS_RETURN-ROW.
        LS_RETURN-OBJECT_GUID = LS_DLI_WRK-DLI_GUID.
        LS_RETURN-CONTAINER = 'DLI'.
      ENDIF.
      INSERT LS_RETURN INTO TABLE ET_RETURN.
    ENDLOOP.
  ENDIF.
*--------------------------------------------------------------------
* Process the method CREATE_INT for reprocessing of derived data
*--------------------------------------------------------------------
  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
       WHERE DERIV_CATEGORY <> GC_DERIV_ORIGIN.
    LV_DLI_GUID = LS_DLI_WRK-DLI_GUID.
    CLEAR:
      LV_DERIV_CATEGORY,
      LS_DLI_INT,
      LT_DLI_WRK_HLP,
      LT_CONDITION_DRV,
      LT_PARTNER_DRV,
      LT_TEXTLINE_DRV,
      LT_DLI_COM,
      LT_RETURN.
* Event DL_OERL1
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL1ICBODL_EL.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL10CMODL_ELD.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL1PARODL_ELD.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL1PRDODL_ELD.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL1PRCODL_ELD.
    INCLUDE %2f1BEA%2fX_CRMBDL_OERL1TXTODL_ELD.

*   Interface structure build up with original data for simulation
*   retrieve valid billed items for quantity adaptation
    PERFORM GET
      CHANGING
        LS_DLI_INT
        LT_DLI_WRK_HLP
        LT_RETURN.
    CALL FUNCTION '/1BEA/CRMB_DL_O_CREATE'
      EXPORTING
        IS_DLI_INT      = LS_DLI_INT
        IT_DLI_WRK      = LT_DLI_WRK_HLP
        IT_CONDITION       = LT_CONDITION_DRV
        IT_PARTNER       = LT_PARTNER_DRV
        IT_TEXTLINE       = LT_TEXTLINE_DRV
        IV_TESTRUN      = GC_TRUE
      IMPORTING
        ES_DLI_WRK      = LS_DLI_WRK_HLP
        ET_RETURN       = LT_RETURN.

    CLEAR:
      LT_RETURN.
*   Build the interface structure COM
    MOVE-CORRESPONDING LS_DLI_WRK_HLP TO LS_DLI_INT.
*   Reset Quantity according as given during initial derivation
    LS_DLI_INT-QUANTITY = LS_DLI_WRK-QUANTITY.
    LS_DLI_INT-QTY_UNIT = LS_DLI_WRK-QTY_UNIT.
    CALL FUNCTION '/1BEA/CRMB_DL_O_DERIVE'
      EXPORTING
        IV_DERIV_CATEGORY = LV_DERIV_CATEGORY
        IS_DLI_INT        = LS_DLI_INT
        IS_DLI_WRK        = LS_DLI_WRK_HLP
        IT_DLI_WRK        = LT_DLI_WRK_HLP
        IT_CONDITION         = LT_CONDITION_DRV
        IT_PARTNER         = LT_PARTNER_DRV
        IT_TEXTLINE         = LT_TEXTLINE_DRV
      IMPORTING
        ET_RETURN         = LT_RETURN.
    IF ET_RETURN IS REQUESTED.
*     Translate return table to DLI_GUIDs
      LOOP AT LT_RETURN INTO LS_RETURN.
        LS_RETURN-OBJECT_GUID = LV_DLI_GUID.
        LS_RETURN-CONTAINER = 'DLI'.
        INSERT LS_RETURN INTO TABLE ET_RETURN.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
*--------------------------------------------------------------------
* Save Derived Data
*--------------------------------------------------------------------
  IF IV_PROCESS_MODE = GC_PROC_ADD.
    CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
      EXPORTING
        IV_COMMIT_FLAG = IV_COMMIT_FLAG.
  ENDIF.
*--------------------------------------------------------------------
* Refresh Buffer
*--------------------------------------------------------------------
  IF IV_PROCESS_MODE = GC_PROC_TEST.
    CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
  ENDIF.
ENDFUNCTION.

* Event DL_OERLZ
  INCLUDE %2f1BEA%2fX_CRMBDL_OERLZICBODL_ELZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OERLZPARODL_ELZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OERLZPRCODL_ELZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OERLZTXTODL_ELZ.
  INCLUDE %2f1BEA%2fX_CRMBDL_OERLZPRDODL_ELZ.

