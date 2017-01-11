FUNCTION /1BEA/CRMB_DL_PRC_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IT_COND_COM) TYPE  BEAT_PRC_COM
*"     REFERENCE(IS_REF_QUANTITY) TYPE  BEAS_REF_QUANTITY OPTIONAL
*"     VALUE(IV_EXT_COND_SUPPLY) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  CONSTANTS:
    LC_APPLICATION         TYPE /SAPCND/APPLICATION VALUE 'CRM',
    LC_USAGE               TYPE /SAPCND/USAGE VALUE 'PR',
    LC_KNTYP_G             TYPE PRCT_COND_CATEGORY  VALUE 'G'.
  DATA:
    LS_PRC_HEAD            TYPE PRCT_HEAD_COM,
    LS_PRC_ITEM            TYPE PRCT_ITEM_COM_VAR,
    LS_PRC_I_QUAN          TYPE BEAS_PRC_REF_QUANTITY,
    LV_PD_HANDLE           TYPE PRCT_HANDLE,
    LV_PRIDOC_GUID         TYPE PRCT_PRIDOC_GUID,
    LT_PRC_COND_TAB        TYPE PRCT_COND_DU_TAB,
    LT_PRC_COND_TAB_EXT    TYPE PRCT_COND_DU_TAB,
    LS_PRC_COND_TAB        TYPE PRCT_COND_DU,
    LT_EXT_COND_TYPE       TYPE PRCT_EXT_COND_TYPE_T,
    LT_EXT_COND_TAB        TYPE PRCT_COND_EXTERNAL_INPUTM_T,
    LS_EXT_COND_TAB        TYPE PRCT_COND_EXTERNAL_INPUTM,
    LV_SUPPRESS_PRICING    TYPE PRCT_SUPPRESS_PRICING,
    LT_PRC_RETURN          TYPE BEAT_PRC_RETURN,
    LS_PRC_RETURN          TYPE BEAS_PRC_RETURN,
    LT_RETURN              TYPE BEAT_RETURN,
    LS_RETURN              TYPE BEAS_RETURN,
    LS_PRC_I_RET           TYPE PRCT_ITEM_RET,
    LS_PRC_I_RET_COM       TYPE PRCT_ITEM_RET_COM,
    LT_PRC_I_RET           TYPE PRCT_ITEM_RET_T,
    LV_SESSION_ID          TYPE BEA_PRC_SESSION_ID,
    LV_EXT_PRC_ID          TYPE PRCT_EXT_DOC_GUID,
    LS_COND_COM            TYPE BEAS_PRC_COM,
    LS_IMPORT_DATA         TYPE PRCT_IMPORT_DATA.

*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_DLI = IS_DLI.
  CHECK NOT IS_ITC-DLI_PRC_PROC IS INITIAL.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
  IF GV_PRC_LOGHNDL IS INITIAL.
    PRC_LOG_INIT.
  ENDIF.
  PRC_LOG_CLEAR.
  CALL FUNCTION 'BEA_PRC_O_REFRESH'.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_GET_INFO'
    EXPORTING
      IV_APPLICATION           = LC_APPLICATION
      IV_USAGE                 = LC_USAGE
      IV_PRIC_PROC             = IS_ITC-DLI_PRC_PROC
    IMPORTING
      ET_EXT_COND_TYPES        = LT_EXT_COND_TYPE
    EXCEPTIONS
      WRONG_CALL               = 0
      IPC_ERROR                = 0
      SESSION_BEGIN            = 0
      OTHERS                   = 0.
*---------------------------------------------------------------------
* BEGIN MAPPING
*--------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPIN'
    EXPORTING
      IS_DLI_WRK         = IS_DLI
      IS_ITC             = IS_ITC
    IMPORTING
      ES_PRC_HEAD        = LS_PRC_HEAD
      ES_PRC_ITEM        = LS_PRC_ITEM
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.

  LS_PRC_I_QUAN-REF_QUANTITY = ABS( IS_REF_QUANTITY-REF_QUANTITY ).
  LS_PRC_I_QUAN-REF_QTY_UNIT = IS_REF_QUANTITY-REF_QTY_UNIT.
  IF LS_PRC_I_QUAN-REF_QUANTITY IS INITIAL.
    LS_PRC_I_QUAN-REF_QUANTITY = LS_PRC_ITEM-MGAME.
  ENDIF.
  IF LS_PRC_I_QUAN-REF_QTY_UNIT IS INITIAL.
    LS_PRC_I_QUAN-REF_QTY_UNIT = LS_PRC_ITEM-VRKME.
  ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  LV_EXT_PRC_ID     = LS_PRC_ITEM-KPOSN.
  IF IV_EXT_COND_SUPPLY IS INITIAL.
    LS_IMPORT_DATA-PRICING_TYPE    = IS_ITC-DLI_PRICING_TYPE.
    LS_IMPORT_DATA-COPY_TYPE       = IS_ITC-DLI_PRCCOPY_TYPE.
    LS_IMPORT_DATA-SALES_QTY_VALUE = LS_PRC_I_QUAN-REF_QUANTITY.
    LS_IMPORT_DATA-SALES_QTY_UNIT  = LS_PRC_I_QUAN-REF_QTY_UNIT.
    LS_IMPORT_DATA-NETVALUE_ORIG   = IS_DLI-NET_VALUE_MAN.
    LS_IMPORT_DATA-NETVALUE_NEW    = IS_DLI-NET_VALUE.
* currently a simple mapping since there is no other
* condition interface defined
    LOOP AT IT_COND_COM INTO LS_COND_COM.
      MOVE-CORRESPONDING LS_COND_COM TO LS_PRC_COND_TAB.
      MOVE LS_PRC_ITEM-KPOSN TO LS_PRC_COND_TAB-KPOSN.
      READ TABLE LT_EXT_COND_TYPE WITH KEY
                 KSCHL = LS_COND_COM-KSCHL
                 TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        INSERT LS_PRC_COND_TAB INTO TABLE LT_PRC_COND_TAB_EXT.
      ENDIF.
      INSERT LS_PRC_COND_TAB INTO TABLE LT_PRC_COND_TAB.
    ENDLOOP.
    CALL FUNCTION 'BEA_PRC_O_ADD_TO_BUFFER'
      EXPORTING
        IT_CONDITION       = LT_PRC_COND_TAB_EXT.
    LS_IMPORT_DATA-CONDITIONS = LT_PRC_COND_TAB.
  ELSE.
    LOOP AT IT_COND_COM INTO LS_COND_COM.
      MOVE LS_COND_COM-KSCHL TO LS_EXT_COND_TAB-KSCHL.
      MOVE LS_COND_COM-KBETR TO LS_EXT_COND_TAB-KBETR.
      MOVE LS_COND_COM-WAERS TO LS_EXT_COND_TAB-WAERS.
      MOVE LS_COND_COM-KPEIN TO LS_EXT_COND_TAB-KPEIN.
      MOVE LS_COND_COM-KMEIN TO LS_EXT_COND_TAB-KMEIN.
      LS_EXT_COND_TAB-KPOSN = LS_PRC_ITEM-KPOSN.
      INSERT LS_EXT_COND_TAB INTO TABLE LT_EXT_COND_TAB.
    ENDLOOP.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'PRC_PD_CREATE'
    EXPORTING
      IV_DOCUMENT_ID_EXT  = LV_EXT_PRC_ID
      IV_BAL_LOG          = GV_PRC_LOGHNDL
      IS_HEAD_COM         = LS_PRC_HEAD
      IV_GROUP_PROCESSING = GC_TRUE
      IV_USE_NAME_VALUE   = GC_TRUE
    IMPORTING
      EV_PD_HANDLE        = LV_PD_HANDLE
      EV_PD_GUID          = LV_PRIDOC_GUID
    EXCEPTIONS
      WRONG_CALL          = 1
      IPC_ERROR           = 2
      SESSION_BEGIN       = 3
      OTHERS              = 4.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN OTHERS.
      CLEAR LT_PRC_RETURN.
      CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
        EXPORTING
          IV_LOGHNDL        = GV_PRC_LOGHNDL
          IV_PD_HANDLE      = LV_PD_HANDLE
        IMPORTING
          ET_PRC_MSG        = LT_PRC_RETURN.
      LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
        CLEAR LS_RETURN.
        MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
        APPEND LS_RETURN TO ET_RETURN.
      ENDLOOP.
      MESSAGE E100(BEA_PRC) RAISING REJECT.
  ENDCASE.
  CALL FUNCTION 'BEA_PRC_O_REGISTER'
    EXPORTING
      IV_PRICING_HANDLE = LV_PD_HANDLE
      IV_PRIDOC_ID      = LV_PRIDOC_GUID
    IMPORTING
      EV_SESSION_ID     = LV_SESSION_ID.
  IF LV_SESSION_ID IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING ET_RETURN.
    MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDIF.
  MOVE LV_SESSION_ID  TO ES_DLI-PRC_SESSION_ID.
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_PREPARE'
    EXPORTING
      IS_DLI_WRK   = ES_DLI
    IMPORTING
      ET_RETURN    = LT_RETURN.
  IF NOT LT_RETURN IS INITIAL.
    CLEAR ES_DLI-PRC_SESSION_ID.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E118(BEA_PRC) RAISING REJECT.
  ENDIF.
  IF IV_EXT_COND_SUPPLY IS INITIAL.
    CALL FUNCTION 'PRC_PD_ITEM_CREATE_BY_IMPORT'
       EXPORTING
         IV_PD_HANDLE                  = LV_PD_HANDLE
         IV_BAL_LOG                    = GV_PRC_LOGHNDL
         IS_ITEM_DST_COM               = LS_PRC_ITEM
         IS_IMPORT_DATA                = LS_IMPORT_DATA
       IMPORTING
         ES_ITEM_RET                   = LS_PRC_I_RET
       EXCEPTIONS
         NON_EXISTING_HANDLE           = 1
         NOT_ALLOWED                   = 2
         OTHERS                        = 3.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        CLEAR ES_DLI-PRC_SESSION_ID.
        MESSAGE E006(BEA_PRC) WITH LS_PRC_HEAD-KALSM
                              INTO GV_DUMMY.
        PERFORM msg_add using space space space space CHANGING ET_RETURN.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
      WHEN OTHERS.
        CLEAR ES_DLI-PRC_SESSION_ID.
        CLEAR LT_PRC_RETURN.
        CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
          EXPORTING
            IV_LOGHNDL        = GV_PRC_LOGHNDL
            IV_PD_HANDLE      = LV_PD_HANDLE
            IV_ITEM_NO        = LS_PRC_ITEM-KPOSN
          IMPORTING
            ET_PRC_MSG        = LT_PRC_RETURN.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
    ENDCASE.
  ELSE.
    IF LT_EXT_COND_TAB IS NOT INITIAL.
      LV_SUPPRESS_PRICING = GC_TRUE.
    ENDIF.
    CALL FUNCTION 'PRC_PD_ITEM_CREATE'
      EXPORTING
        IV_PD_HANDLE        = LV_PD_HANDLE
        IV_BAL_LOG          = GV_PRC_LOGHNDL
        IS_ITEM_COM         = LS_PRC_ITEM
        IV_SUPPRESS_PRICING = LV_SUPPRESS_PRICING
      IMPORTING
        ES_ITEM_RET         = LS_PRC_I_RET
      EXCEPTIONS
        NON_EXISTING_HANDLE = 1
        WRONG_CALL          = 2
        IPC_ERROR           = 3
        NOT_ALLOWED         = 4
        OTHERS              = 5.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        CLEAR ES_DLI-PRC_SESSION_ID.
        MESSAGE E006(BEA_PRC) WITH LS_PRC_HEAD-KALSM
                              INTO GV_DUMMY.
        PERFORM msg_add using space space space space CHANGING ET_RETURN.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
      WHEN OTHERS.
        CLEAR LT_PRC_RETURN.
        CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
          EXPORTING
            IV_LOGHNDL        = GV_PRC_LOGHNDL
            IV_PD_HANDLE      = LV_PD_HANDLE
            IV_ITEM_NO        = LS_PRC_ITEM-KPOSN
          IMPORTING
            ET_PRC_MSG        = LT_PRC_RETURN.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
        CLEAR ES_DLI-PRC_SESSION_ID.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
    ENDCASE.
    CALL FUNCTION 'PRC_PD_ITEM_ADD_COND_MULTI'
      EXPORTING
        IV_PD_HANDLE             = LV_PD_HANDLE
        IV_BAL_LOG               = GV_PRC_LOGHNDL
        IT_COND_ADD              = LT_EXT_COND_TAB
        IV_SUPPRESS_CHECKS       = GC_FALSE
      IMPORTING
        ET_ITEM_RET              = LT_PRC_I_RET
      EXCEPTIONS
        NON_EXISTING_HANDLE      = 1
        IPC_ERROR                = 2
        NOT_ALLOWED              = 3
        OTHERS                   = 4.
    CASE SY-SUBRC.
      WHEN 0.
        IF LV_SUPPRESS_PRICING = GC_TRUE.
          READ TABLE LT_PRC_I_RET INTO LS_PRC_I_RET_COM
            WITH KEY KPOSN = LS_PRC_ITEM-KPOSN.
          IF SY-SUBRC NE 0.
            CLEAR ES_DLI-PRC_SESSION_ID.
            MESSAGE E001(BEA_PRC) RAISING REJECT.
          ELSE.
            CLEAR LS_PRC_I_RET.
            MOVE-CORRESPONDING LS_PRC_I_RET_COM TO LS_PRC_I_RET.
          ENDIF.
        ENDIF.
      WHEN 1.
        CLEAR ES_DLI-PRC_SESSION_ID.
        MESSAGE E006(BEA_PRC) WITH LS_PRC_HEAD-KALSM
                              INTO GV_DUMMY.
        PERFORM msg_add using space space space space CHANGING ET_RETURN.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
      WHEN OTHERS.
        CLEAR LT_PRC_RETURN.
        CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
          EXPORTING
            IV_LOGHNDL        = GV_PRC_LOGHNDL
            IV_PD_HANDLE      = LV_PD_HANDLE
            IV_ITEM_NO        = LS_PRC_ITEM-KPOSN
          IMPORTING
            ET_PRC_MSG        = LT_PRC_RETURN.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
        CLEAR ES_DLI-PRC_SESSION_ID.
        MESSAGE E001(BEA_PRC) RAISING REJECT.
    ENDCASE.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPOUT'
    EXPORTING
      IS_DLI_WRK         = ES_DLI
      IS_PRC_I_RET       = LS_PRC_I_RET
    IMPORTING
      ES_DLI_WRK         = ES_DLI
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    CLEAR ES_DLI-PRC_SESSION_ID.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
  MOVE LV_PRIDOC_GUID TO ES_DLI-PRIDOC_GUID.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
ENDFUNCTION.
