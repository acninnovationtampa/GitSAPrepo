FUNCTION /1BEA/CRMB_DL_PRC_O_QTY_ADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IV_QUANTITY) TYPE  COMT_QUANTITY
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
  CONSTANTS:
    LC_CP_PRICING_TYPE TYPE PRCT_PRICING_TYPE VALUE 'D',
    LC_CP_PRCCOPY_TYPE TYPE PRCT_COPY_TYPE    VALUE '01000'.
  DATA:
    LS_PRC_HEAD            TYPE PRCT_HEAD_COM,
    LS_PRC_ITEM            TYPE PRCT_ITEM_COM_VAR,
    LV_PD_HANDLE_NEW       TYPE PRCT_HANDLE,
    LV_PRIDOC_GUID_NEW     TYPE PRCT_PRIDOC_GUID,
    LS_PRC_I_RET           TYPE PRCT_ITEM_RET.
  DATA:
    LV_PD_HANDLE           TYPE PRCT_HANDLE,
    LS_COPY_DATA           TYPE PRCT_COPY_DATA,
    LV_PRC_MGAME           TYPE PRCT_PROD_QUAN.
  DATA:
    LV_SESSION_ID_NEW      TYPE BEA_PRC_SESSION_ID,
    LV_PRC_EXT_ID          TYPE PRCT_EXT_DOC_GUID,
    LT_PRC_RETURN          TYPE BEAT_PRC_RETURN,
    LS_PRC_RETURN          TYPE BEAS_PRC_RETURN,
    LT_RETURN              TYPE BEAT_RETURN,
    LS_RETURN              TYPE BEAS_RETURN.
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_DLI = IS_DLI.
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
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  LS_COPY_DATA-ITEM_NO = LS_PRC_ITEM-KPOSN.
  IF NOT IS_DLI-SRVDOC_SOURCE IS INITIAL.
    LS_COPY_DATA-ITEM_NO = IS_DLI-SRC_GUID.
    IF IS_DLI-SRC_PRC_GUID IS INITIAL.
      LS_PRC_ITEM-KPOSN    = IS_DLI-SRC_GUID.
    ELSE.
      LS_PRC_ITEM-KPOSN    = IS_DLI-SRC_PRC_GUID.
    ENDIF.
  ENDIF.

  LV_PRC_MGAME      = LS_PRC_ITEM-MGAME.
  LS_PRC_ITEM-MGAME = LV_PRC_MGAME + IV_QUANTITY.

  LS_COPY_DATA-PD_GUID         = IS_DLI-PRIDOC_GUID.
  LS_COPY_DATA-PRICING_TYPE    = LC_CP_PRICING_TYPE.
  LS_COPY_DATA-COPY_TYPE       = LC_CP_PRCCOPY_TYPE.
  LS_COPY_DATA-NETVALUE_ORIG   = IS_DLI-NET_VALUE_MAN.
  LS_COPY_DATA-NETVALUE_NEW    = IS_DLI-NET_VALUE.
  LS_COPY_DATA-SALES_QTY_VALUE = LV_PRC_MGAME.
  LS_COPY_DATA-SALES_QTY_UNIT  = LS_PRC_ITEM-VRKME.

* open the existing document if necessary
  IF IS_DLI-PRC_SESSION_ID IS INITIAL.
    CLEAR LT_RETURN.
    CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_OPEN'
      EXPORTING
        IS_DLI              = IS_DLI
        IS_ITC              = IS_ITC
        IV_WRITE_MODE       = GC_PRC_PD_READWRIT
      IMPORTING
        EV_PD_HANDLE        = LV_PD_HANDLE
        ET_RETURN           = LT_RETURN
      EXCEPTIONS
        REJECT              = 1
        OTHERS              = 2.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN OTHERS.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
        MESSAGE E003(BEA_PRC) RAISING REJECT.
    ENDCASE.
  ELSE.
* get pricing handle from session id
    CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
      EXPORTING
        IV_SESSION_ID     = IS_DLI-PRC_SESSION_ID
      IMPORTING
        EV_PRICING_HANDLE = LV_PD_HANDLE.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      EV_GUID_16 = LV_PRC_EXT_ID.
  CALL FUNCTION 'PRC_PD_CREATE'
    EXPORTING
      IV_DOCUMENT_ID_EXT  = LV_PRC_EXT_ID
      IV_BAL_LOG          = GV_PRC_LOGHNDL
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
      IV_PRICING_HANDLE = LV_PD_HANDLE_NEW
      IV_PRIDOC_ID      = LV_PRIDOC_GUID_NEW
    IMPORTING
      EV_SESSION_ID     = LV_SESSION_ID_NEW.
  IF LV_SESSION_ID_NEW IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING ET_RETURN.
    MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDIF.
  MOVE LV_SESSION_ID_NEW  TO ES_DLI-PRC_SESSION_ID.
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
* create new item conditions with reference to item in is_dli
  CALL FUNCTION 'PRC_PD_ITEM_CREATE_WITH_REF'
    EXPORTING
      IV_PD_DST_HDL          = LV_PD_HANDLE_NEW
      IV_BAL_LOG             = GV_PRC_LOGHNDL
      IS_ITEM_DST_COM        = LS_PRC_ITEM
      IS_COPY_DATA           = LS_COPY_DATA
    IMPORTING
      ES_ITEM_RET            = LS_PRC_I_RET
    EXCEPTIONS
      NON_EXISTING_HANDLE    = 1
      WRONG_CALL             = 2
      IPC_ERROR              = 3
      NOT_ALLOWED            = 4
      OTHERS                 = 5.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      CLEAR ES_DLI-PRC_SESSION_ID.
      MESSAGE E006(BEA_PRC) WITH LS_PRC_HEAD-KALSM
                            INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
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
      CLEAR ES_DLI-PRC_SESSION_ID.
      MESSAGE E001(BEA_PRC) RAISING REJECT.
  ENDCASE.
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
  MOVE LV_PRIDOC_GUID_NEW TO ES_DLI-PRIDOC_GUID.
  CALL FUNCTION 'PRC_PD_DELETE'
    EXPORTING
      IV_PD_HANDLE           = LV_PD_HANDLE
      IV_SAVE_IMPLICIT       = GC_SAVE_IMPLICITLY
    EXCEPTIONS
      OTHERS                 = 0.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
ENDFUNCTION.
