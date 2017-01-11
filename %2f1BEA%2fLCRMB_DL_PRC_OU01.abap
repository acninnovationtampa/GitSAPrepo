FUNCTION /1BEA/CRMB_DL_PRC_O_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IS_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
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
    LC_CP_PRICING_TYPE TYPE PRCT_PRICING_TYPE VALUE 'D',
    LC_CP_PRCCOPY_TYPE TYPE PRCT_COPY_TYPE    VALUE '01000'.
  DATA:
    LS_PRC_HEAD            TYPE PRCT_HEAD_COM,
    LS_PRC_ITEM            TYPE PRCT_ITEM_COM_VAR,
    LS_PRC_ITEM_TC         TYPE PRCT_ITEM_COM_VAR,
    LT_PRC_ITEM            TYPE PRCT_ITEM_COM_T,
    LS_PRC_COPY            TYPE PRCT_COPY_DATA,
    LT_PRC_COPY            TYPE PRCT_COPY_DATA_T,
    LS_PRC_I_RET           TYPE PRCT_ITEM_RET,
    LT_PRC_I_RET_COM       TYPE PRCT_ITEM_RET_T,
    LS_PRC_I_RET_COM       TYPE PRCT_ITEM_RET_COM,
    LV_PD_HANDLE_NEW       TYPE PRCT_HANDLE,
    LV_PRIDOC_GUID_NEW     TYPE PRCT_PRIDOC_GUID.
  DATA:
    LV_SESSION_ID_NEW      TYPE BEA_PRC_SESSION_ID,
    LV_PRC_EXT_ID          TYPE PRCT_EXT_DOC_GUID,
    LT_PRC_RETURN          TYPE BEAT_PRC_RETURN,
    LS_PRC_RETURN          TYPE BEAS_PRC_RETURN,
    LT_RETURN              TYPE BEAT_RETURN,
    LS_RETURN              TYPE BEAS_RETURN.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_DLI_NEW = IS_DLI_NEW.
  CHECK NOT IS_DLI-PRIDOC_GUID IS INITIAL.
  CHECK NOT IS_ITC-DLI_PRC_PROC IS INITIAL.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
  IF GV_PRC_LOGHNDL IS INITIAL.
    PRC_LOG_INIT.
  ENDIF.
  PRC_LOG_CLEAR.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPIN'
    EXPORTING
      IS_DLI_WRK         = IS_DLI_NEW
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

  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPIN'
    EXPORTING
      IS_DLI_WRK         = IS_DLI
      IS_ITC             = IS_ITC
    IMPORTING
      ES_PRC_ITEM        = LS_PRC_ITEM_TC
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  CLEAR LS_PRC_COPY.
  LS_PRC_COPY-PD_GUID         = IS_DLI-PRIDOC_GUID.
  LS_PRC_COPY-ITEM_NO         = LS_PRC_ITEM_TC-KPOSN.
  LS_PRC_COPY-PRICING_TYPE    = LC_CP_PRICING_TYPE.
  LS_PRC_COPY-COPY_TYPE       = LC_CP_PRCCOPY_TYPE.
  LS_PRC_COPY-NETVALUE_ORIG   = IS_DLI-NET_VALUE_MAN.
  LS_PRC_COPY-NETVALUE_NEW    = IS_DLI-NET_VALUE.
  LS_PRC_COPY-SALES_QTY_VALUE = LS_PRC_ITEM_TC-MGAME.
  LS_PRC_COPY-SALES_QTY_UNIT  = LS_PRC_ITEM_TC-VRKME.

  LV_PRC_EXT_ID = LS_PRC_ITEM-KPOSN.

  APPEND LS_PRC_ITEM  TO LT_PRC_ITEM.
  APPEND LS_PRC_COPY  TO LT_PRC_COPY.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'PRC_PD_CREATE'
    EXPORTING
      IV_DOCUMENT_ID_EXT  = LV_PRC_EXT_ID
      IS_HEAD_COM         = LS_PRC_HEAD
      IV_USE_NAME_VALUE   = GC_TRUE
    IMPORTING
      EV_PD_HANDLE        = LV_PD_HANDLE_NEW
      EV_PD_GUID          = LV_PRIDOC_GUID_NEW
    EXCEPTIONS
      WRONG_CALL          = 1
      IPC_ERROR           = 2
      SESSION_BEGIN       = 3
      OTHERS              = 4.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      MESSAGE E101(BEA_PRC) WITH LS_PRC_HEAD-KALSM
        INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
    WHEN 2.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
    WHEN 3.
      MESSAGE E103(BEA_PRC) WITH LS_PRC_HEAD-KALSM
        INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
    WHEN OTHERS.
      MESSAGE E005(BEA_PRC) INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDCASE.
  CALL FUNCTION 'BEA_PRC_O_REGISTER'
    EXPORTING
      IV_PRICING_HANDLE = LV_PD_HANDLE_NEW
      IV_PRIDOC_ID      = LV_PRIDOC_GUID_NEW
    IMPORTING
      EV_SESSION_ID     = LV_SESSION_ID_NEW.
  IF LV_SESSION_ID_NEW IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING ET_RETURN.
    MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDIF.
  MOVE LV_SESSION_ID_NEW  TO ES_DLI_NEW-PRC_SESSION_ID.
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_PREPARE'
    EXPORTING
      IS_DLI_WRK   = ES_DLI_NEW
    IMPORTING
      ET_RETURN    = LT_RETURN.
  IF NOT LT_RETURN IS INITIAL.
    CLEAR ES_DLI_NEW-PRC_SESSION_ID.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E118(BEA_PRC) RAISING REJECT.
  ENDIF.
* create new item conditions with reference to item in is_dli
  CALL FUNCTION 'PRC_PD_ITEM_CREATE_WITH_REFM'
    EXPORTING
      IV_PD_HANDLE              = LV_PD_HANDLE_NEW
      IV_BAL_LOG                = GV_PRC_LOGHNDL
      IT_ITEM_COM               = LT_PRC_ITEM
      IT_COPY_DATA              = LT_PRC_COPY
    IMPORTING
      ET_ITEM_RET               = LT_PRC_I_RET_COM
    EXCEPTIONS
      NON_EXISTING_HANDLE       = 1
      WRONG_CALL                = 2
      IPC_ERROR                 = 3
      NOT_ALLOWED               = 4
      OTHERS                    = 5.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN OTHERS.
      CLEAR LT_RETURN.
      CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
        EXPORTING
          IV_LOGHNDL        = GV_PRC_LOGHNDL
          IV_PD_HANDLE      = LV_PD_HANDLE_NEW
          IV_ITEM_NO        = LS_PRC_ITEM-KPOSN
        IMPORTING
          ET_PRC_MSG        = LT_PRC_RETURN.
      LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
        CLEAR LS_RETURN.
        MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
        APPEND LS_RETURN TO ET_RETURN.
      ENDLOOP.
      CLEAR ES_DLI_NEW-PRC_SESSION_ID.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDCASE.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
  READ TABLE LT_PRC_I_RET_COM INTO LS_PRC_I_RET_COM
    WITH KEY KPOSN = LS_PRC_ITEM-KPOSN.
  IF SY-SUBRC NE 0.
    CLEAR ES_DLI_NEW-PRC_SESSION_ID.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
  MOVE-CORRESPONDING LS_PRC_I_RET_COM TO LS_PRC_I_RET.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPOUT'
    EXPORTING
      IS_DLI_WRK         = ES_DLI_NEW
      IS_PRC_I_RET       = LS_PRC_I_RET
    IMPORTING
      ES_DLI_WRK         = ES_DLI_NEW
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    CLEAR ES_DLI_NEW-PRC_SESSION_ID.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
  MOVE LV_PRIDOC_GUID_NEW TO ES_DLI_NEW-PRIDOC_GUID.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
ENDFUNCTION.
