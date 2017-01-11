FUNCTION /1BEA/CRMB_BD_PRC_O_IT_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IS_BDH_CANCEL) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI_CANCEL) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IV_EXTENDED_LOG) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_BDH_CANCEL) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(ET_BDI_CANCEL) TYPE  /1BEA/T_CRMB_BDI_WRK
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
  CONSTANTS:
    LC_CANCEL_PRCTYPE TYPE PRCT_PRICING_TYPE VALUE 'D',
    LC_CANCEL_COPTYPE TYPE PRCT_COPY_TYPE    VALUE '02000'.
  DATA:
    LS_BDI_CANCEL_WRK   TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_BDI_WRK          TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_PRC_ITEM         TYPE PRCT_ITEM_COM_VAR,
    LS_PRC_ITEM_TC      TYPE PRCT_ITEM_COM_VAR,
    LT_PRC_ITEM         TYPE PRCT_ITEM_COM_T,
    LS_PRC_COPY         TYPE PRCT_COPY_DATA,
    LT_PRC_COPY         TYPE PRCT_COPY_DATA_T,
    LS_PRC_I_RET        TYPE PRCT_ITEM_RET,
    LT_PRC_I_RET_COM    TYPE PRCT_ITEM_RET_T,
    LS_PRC_I_RET_COM    TYPE PRCT_ITEM_RET_COM,
    LV_PD_CNL_HNDL      TYPE PRCT_HANDLE,
    LV_ITEM_NO          TYPE PRCT_ITEM_NO,
    LS_RETURN           TYPE BEAS_RETURN,
    LT_RETURN           TYPE BEAT_RETURN,
    LS_PRC_RETURN       TYPE BEAS_PRC_RETURN,
    LT_PRC_RETURN       TYPE BEAT_PRC_RETURN,
    LV_PRICING_STATUS   TYPE BEA_PRICING_STATUS.
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_BDH_CANCEL = IS_BDH_CANCEL.
  ET_BDI_CANCEL = IT_BDI_CANCEL.
  CLEAR ES_BDH_CANCEL-PRICING_ERROR.
  CHECK NOT IS_BDH-PRIDOC_GUID IS INITIAL.
  IF IS_BDH_CANCEL-PRC_SESSION_ID IS INITIAL.
    IF NOT IV_EXTENDED_LOG IS INITIAL.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
  IF GV_PRC_LOGHNDL IS INITIAL.
    PRC_LOG_INIT.
  ENDIF.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
    EXPORTING
      IV_SESSION_ID     = IS_BDH_CANCEL-PRC_SESSION_ID
    IMPORTING
      EV_PRICING_HANDLE = LV_PD_CNL_HNDL.

  LOOP AT ET_BDI_CANCEL INTO LS_BDI_CANCEL_WRK.
    READ TABLE IT_BDI INTO LS_BDI_WRK
      WITH KEY BDI_GUID = LS_BDI_CANCEL_WRK-REVERSED_BDI_GUID.
    IF SY-SUBRC NE 0.
      IF NOT IV_EXTENDED_LOG IS INITIAL.
        MESSAGE E109(BEA_PRC) INTO GV_DUMMY.
        PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
      ENDIF.
      MESSAGE E109(BEA_PRC) RAISING REJECT.
    ENDIF.
    CLEAR LS_PRC_ITEM.
    CLEAR LS_PRC_ITEM_TC.
    CLEAR LT_RETURN.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPIN'
      EXPORTING
        IS_BDH_WRK         = IS_BDH_CANCEL
        IS_BDI_WRK         = LS_BDI_CANCEL_WRK
      IMPORTING
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
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPIN'
      EXPORTING
        IS_BDH_WRK         = IS_BDH
        IS_BDI_WRK         = LS_BDI_WRK
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
    IF LS_BDI_WRK-PRICING_STATUS EQ GC_PRC_STAT_NOTREL.
      LS_BDI_CANCEL_WRK-PRICING_STATUS = GC_PRC_STAT_NOTREL.
      CLEAR LS_PRC_ITEM-PRICING_RELEVANT.
    ENDIF.

    CLEAR LS_PRC_COPY.
    LS_PRC_COPY-PD_GUID         = IS_BDH-PRIDOC_GUID.
    LS_PRC_COPY-ITEM_NO         = LS_PRC_ITEM_TC-KPOSN.
    LS_PRC_COPY-PRICING_TYPE    = LC_CANCEL_PRCTYPE.
    LS_PRC_COPY-COPY_TYPE       = LC_CANCEL_COPTYPE.
    LS_PRC_COPY-SALES_QTY_VALUE = LS_PRC_ITEM_TC-MGAME.
    LS_PRC_COPY-SALES_QTY_UNIT  = LS_PRC_ITEM_TC-VRKME.

    APPEND LS_PRC_ITEM  TO LT_PRC_ITEM.
    APPEND LS_PRC_COPY  TO LT_PRC_COPY.

    MODIFY ET_BDI_CANCEL FROM LS_BDI_CANCEL_WRK.
  ENDLOOP.
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_PREPARE'
    EXPORTING
      IS_BDH_WRK   = IS_BDH_CANCEL
      IT_BDI_WRK   = ET_BDI_CANCEL
    IMPORTING
      ET_RETURN    = LT_RETURN.
  IF NOT LT_RETURN IS INITIAL.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E118(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'PRC_PD_ITEM_CREATE_WITH_REFM'
    EXPORTING
      IV_PD_HANDLE              = LV_PD_CNL_HNDL
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
        IF NOT IV_EXTENDED_LOG IS INITIAL.
          CLEAR LT_PRC_RETURN.
          CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
            EXPORTING
              IV_LOGHNDL   = GV_PRC_LOGHNDL
              IV_PD_HANDLE = LV_PD_CNL_HNDL
            IMPORTING
              ET_PRC_MSG   = LT_PRC_RETURN.
          LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
            CLEAR LS_RETURN.
            MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
            APPEND LS_RETURN TO ET_RETURN.
          ENDLOOP.
        ENDIF.
        IF IS_BDH-PRICING_ERROR EQ GC_PRC_ERR_F.
          ES_BDH_CANCEL-PRICING_ERROR = GC_PRC_ERR_F.
          RETURN.
        ELSE.
          MESSAGE E005(BEA_PRC) RAISING REJECT.
        ENDIF.
    ENDCASE.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
  LOOP AT ET_BDI_CANCEL INTO LS_BDI_CANCEL_WRK.
    CLEAR LV_PRICING_STATUS.
    READ TABLE LT_PRC_ITEM INTO LS_PRC_ITEM INDEX SY-TABIX.
    IF SY-SUBRC NE 0 OR LS_PRC_ITEM-KPOSN IS INITIAL.
      MESSAGE E006(BEA_PRC) RAISING REJECT.
    ENDIF.
    CHECK LS_BDI_CANCEL_WRK-PRICING_STATUS NE GC_PRC_STAT_NOTREL.
    PRC_SET_STATUS GC_PRC_STAT_OK
                   LS_BDI_CANCEL_WRK-PRICING_STATUS
                   ES_BDH_CANCEL-PRICING_ERROR.
    LV_ITEM_NO = LS_PRC_ITEM-KPOSN.
    CLEAR LT_PRC_RETURN.
    CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
      EXPORTING
        IV_LOGHNDL   = GV_PRC_LOGHNDL
        IV_PD_HANDLE = LV_PD_CNL_HNDL
        IV_ITEM_NO   = LV_ITEM_NO
      IMPORTING
        EV_MSG_FLAG  = LV_PRICING_STATUS
        ET_PRC_MSG   = LT_PRC_RETURN.
    PRC_SET_STATUS LV_PRICING_STATUS
                   LS_BDI_CANCEL_WRK-PRICING_STATUS
                   ES_BDH_CANCEL-PRICING_ERROR.
    IF NOT LV_PRICING_STATUS IS INITIAL.
      IF NOT IV_EXTENDED_LOG IS INITIAL.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF ES_BDH_CANCEL-PRICING_ERROR EQ GC_PRC_ERR_X.
      IF IS_BDH-PRICING_ERROR IS INITIAL.
        PRC_LOG_CLEAR.
        MESSAGE E115(BEA_PRC) RAISING REJECT.
      ENDIF.
    ELSEIF ES_BDH_CANCEL-PRICING_ERROR EQ GC_PRC_ERR_F
       AND IS_BDH-PRICING_ERROR NE GC_PRC_ERR_F.
      PRC_LOG_CLEAR.
      MESSAGE E115(BEA_PRC) RAISING REJECT.
    ENDIF.
    IF IS_BDH-PRICING_ERROR EQ GC_PRC_ERR_F.
      ES_BDH_CANCEL-PRICING_ERROR = GC_PRC_ERR_F.
    ENDIF.
    READ TABLE LT_PRC_I_RET_COM INTO LS_PRC_I_RET_COM
      WITH KEY KPOSN = LV_ITEM_NO.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_PRC_I_RET_COM TO LS_PRC_I_RET.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
      CLEAR LT_RETURN.
      CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPOUT'
        EXPORTING
          IS_BDH_WRK         = ES_BDH_CANCEL
          IS_BDI_WRK         = LS_BDI_CANCEL_WRK
          IS_PRC_I_RET       = LS_PRC_I_RET
        IMPORTING
          ES_BDH_WRK         = ES_BDH_CANCEL
          ES_BDI_WRK         = LS_BDI_WRK
          ET_RETURN          = LT_RETURN
        EXCEPTIONS
          REJECT             = 1
          OTHERS             = 2.
      IF SY-SUBRC NE 0.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
        PRC_LOG_CLEAR.
        MESSAGE E117(BEA_PRC) RAISING REJECT.
      ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
    ELSE.
      PRC_LOG_CLEAR.
      MESSAGE E006(BEA_PRC) RAISING REJECT.
    ENDIF.
    MODIFY ET_BDI_CANCEL FROM LS_BDI_CANCEL_WRK.
  ENDLOOP.
  PRC_LOG_CLEAR.

ENDFUNCTION.
