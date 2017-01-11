FUNCTION /1BEA/CRMB_BD_PRC_O_HD_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IV_EXTENDED_LOG) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
* Time  : 13:53:02
*
*======================================================================
  DATA:
    LS_PRC_HEAD         TYPE PRCT_HEAD_COM,
    LV_PD_HANDLE        TYPE PRCT_HANDLE,
    LV_PRIDOC_GUID      TYPE PRCT_PRIDOC_GUID,
    LV_SESSION_ID       TYPE BEA_PRC_SESSION_ID,
    LT_RETURN           TYPE BEAT_RETURN,
    LS_RETURN           TYPE BEAS_RETURN,
    LT_PRC_RETURN       TYPE BEAT_PRC_RETURN,
    LS_PRC_RETURN       TYPE BEAS_PRC_RETURN,
    LV_PRC_EXT_ID       TYPE PRCT_EXT_DOC_GUID.

*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_BDH   = IS_BDH.
  CLEAR ES_BDH-PRICING_ERROR.
  CHECK NOT IS_BDH-PRIC_PROC IS INITIAL.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
  IF GV_PRC_LOGHNDL IS INITIAL.
    PRC_LOG_INIT.
  ENDIF.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_HD_MAPIN'
    EXPORTING
      IS_BDH_WRK         = IS_BDH
    IMPORTING
      ES_PRC_HEAD        = LS_PRC_HEAD
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    IF ET_RETURN IS REQUESTED.
      APPEND LINES OF LT_RETURN TO ET_RETURN.
    ENDIF.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  LV_PRC_EXT_ID = IS_BDH-BDH_GUID.
  CALL FUNCTION 'PRC_PD_CREATE'
    EXPORTING
      IV_DOCUMENT_ID_EXT  = LV_PRC_EXT_ID
      IV_BAL_LOG          = GV_PRC_LOGHNDL
      IS_HEAD_COM         = LS_PRC_HEAD
      IV_GROUP_PROCESSING = GC_GROUP_PROC
      IV_USE_NAME_VALUE   = GC_TRUE
    IMPORTING
      EV_PD_HANDLE        = LV_PD_HANDLE
      EV_PD_GUID          = LV_PRIDOC_GUID
    EXCEPTIONS
      WRONG_CALL          = 1
      IPC_ERROR           = 2
      SESSION_BEGIN       = 3
      OTHERS              = 4.
  IF SY-SUBRC NE 0.
    IF NOT IV_EXTENDED_LOG IS INITIAL.
      CLEAR LT_PRC_RETURN.
      CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
        EXPORTING
          IV_LOGHNDL          = GV_PRC_LOGHNDL
          IV_PD_HANDLE        = LV_PD_HANDLE
        IMPORTING
          ET_PRC_MSG          = LT_PRC_RETURN.
      LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
        CLEAR LS_RETURN.
        MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
        APPEND LS_RETURN TO ET_RETURN.
      ENDLOOP.
    ENDIF.
    PRC_LOG_CLEAR.
    MESSAGE E100(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_REGISTER'
    EXPORTING
      IV_PRICING_HANDLE = LV_PD_HANDLE
      IV_PRIDOC_ID      = LV_PRIDOC_GUID
    IMPORTING
      EV_SESSION_ID     = LV_SESSION_ID.
  IF LV_SESSION_ID IS INITIAL.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
  ES_BDH-PRC_SESSION_ID       = LV_SESSION_ID.
  ES_BDH-PRIDOC_GUID          = LV_PRIDOC_GUID.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
ENDFUNCTION.
