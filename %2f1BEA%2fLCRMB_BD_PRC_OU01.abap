FUNCTION /1BEA/CRMB_BD_PRC_O_CHANGE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(ET_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      INCOMPLETE
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
    LS_BDI_WRK        TYPE /1BEA/S_CRMB_BDI_WRK,
    LV_PD_HANDLE      TYPE PRCT_HANDLE,
    LS_PRC_I_RET      TYPE PRCT_ITEM_RET,
    LS_PRC_ITEM       TYPE PRCT_ITEM_COM_VAR,
    LS_PRC_ITEM_WRK   TYPE PRCT_ITEM_WRK,
    LV_ERROR          TYPE BEA_BOOLEAN,
    LS_RETURN         TYPE BEAS_RETURN,
    LT_RETURN         TYPE BEAT_RETURN,
    LS_PRC_RETURN     TYPE BEAS_PRC_RETURN,
    LT_PRC_RETURN     TYPE BEAT_PRC_RETURN,
    LV_PRICING_STATUS TYPE BEA_PRICING_STATUS,
    LV_LAST_ITEM      TYPE PRCT_ITEM_NO,
    LV_LAST_STATUS    TYPE BEA_PRICING_STATUS.
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_BDH = IS_BDH.
  ET_BDI = IT_BDI.
  CLEAR ES_BDH-PRICING_ERROR.
  CHECK NOT IS_BDH-PRIC_PROC IS INITIAL.
  IF IS_BDH-PRC_SESSION_ID IS INITIAL.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    ENDIF.
    PRC_SET_ERROR ES_BDH-PRICING_ERROR GC_PRC_ERR_F.
    MESSAGE E006(BEA_PRC) RAISING INCOMPLETE.
  ENDIF.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
    EXPORTING
      IV_SESSION_ID     = IS_BDH-PRC_SESSION_ID
    IMPORTING
      EV_PRICING_HANDLE = LV_PD_HANDLE.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_U_LAST_CHANGE_GET'
    IMPORTING
      EV_MSG_FLAG       = LV_LAST_STATUS
      EV_ITEM_NO        = LV_LAST_ITEM.
  LOOP AT ET_BDI INTO LS_BDI_WRK.
    CHECK LS_BDI_WRK-PRICING_STATUS NE GC_PRC_STAT_NOTREL.
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPIN'
      EXPORTING
        IS_BDH_WRK         = ES_BDH
        IS_BDI_WRK         = LS_BDI_WRK
      IMPORTING
        ES_PRC_ITEM        = LS_PRC_ITEM
      EXCEPTIONS
        OTHERS             = 0.
    CHECK NOT LS_PRC_ITEM-KPOSN IS INITIAL.
    CLEAR LS_BDI_WRK-PRICING_STATUS.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
    CALL FUNCTION 'PRC_PD_ITEM_READ'
      EXPORTING
        IV_PD_HANDLE        = LV_PD_HANDLE
        IV_ITEM_NO          = LS_PRC_ITEM-KPOSN
      IMPORTING
        ES_ITEM_WRK         = LS_PRC_ITEM_WRK
      EXCEPTIONS
        NON_EXISTING_HANDLE = 1
        NON_EXISTING_ITEM   = 2
        OTHERS              = 3.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN OTHERS.
        PRC_SET_STATUS GC_PRC_STAT_INTERR
                       LS_BDI_WRK-PRICING_STATUS
                       ES_BDH-PRICING_ERROR.
        MODIFY ET_BDI FROM LS_BDI_WRK.
        LV_ERROR = GC_TRUE.
        CONTINUE.
    ENDCASE.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
    CLEAR LV_PRICING_STATUS.
    CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
      EXPORTING
        IV_LOGHNDL   = GV_PRC_LOGHNDL
        IV_PD_HANDLE = LV_PD_HANDLE
        IV_ITEM_NO   = LS_PRC_ITEM-KPOSN
      IMPORTING
        EV_MSG_FLAG  = LV_PRICING_STATUS.
    IF NOT LV_PRICING_STATUS IS INITIAL.
      IF ET_RETURN IS REQUESTED.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
      ENDIF.
      PRC_SET_STATUS LV_PRICING_STATUS
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
    ENDIF.
    IF LS_PRC_ITEM-KPOSN EQ LV_LAST_ITEM AND
       NOT LV_LAST_STATUS IS INITIAL.
      PRC_SET_STATUS LV_LAST_STATUS
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
    ENDIF.
    MOVE-CORRESPONDING LS_PRC_ITEM_WRK TO LS_PRC_I_RET.
    CLEAR LT_RETURN.
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPOUT'
      EXPORTING
        IS_BDH_WRK         = ES_BDH
        IS_BDI_WRK         = LS_BDI_WRK
        IS_PRC_I_RET       = LS_PRC_I_RET
      IMPORTING
        ES_BDH_WRK         = ES_BDH
        ES_BDI_WRK         = LS_BDI_WRK
        ET_RETURN          = LT_RETURN
      EXCEPTIONS
        REJECT             = 1
        OTHERS             = 2.
    IF SY-SUBRC NE 0.
      IF ET_RETURN IS REQUESTED.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
      ENDIF.
      PRC_SET_STATUS GC_PRC_STAT_MAP
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
    ENDIF.
    MODIFY ET_BDI FROM LS_BDI_WRK.
  ENDLOOP.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
  PRC_LOG_CLEAR.
  IF LV_ERROR EQ GC_TRUE.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E005(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E005(BEA_PRC) RAISING INCOMPLETE.
  ENDIF.
ENDFUNCTION.
