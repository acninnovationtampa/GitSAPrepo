FUNCTION /1BEA/CRMB_BD_PRC_O_OPEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     VALUE(IV_WRITE_MODE) TYPE  C OPTIONAL
*"     VALUE(IV_PARTIAL_PROCESSING) TYPE  PRCT_PARTIAL_PROCESSING
*"         OPTIONAL
*"     VALUE(IV_GROUP_PROCESSING) TYPE  C DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(EV_SESSION_ID) TYPE  BEA_PRC_SESSION_ID
*"     REFERENCE(EV_PD_HANDLE) TYPE  PRCT_HANDLE
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
    LS_BDH_WRK          TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDI_WRK          TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_PRC_HEAD         TYPE PRCT_HEAD_COM,
    LS_PRC_ITEM         TYPE PRCT_ITEM_COM_VAR,
    LT_PRC_ITEM         TYPE PRCT_ITEM_COM_T,
    LV_PD_HANDLE        TYPE PRCT_HANDLE,
    LV_SESSION_ID       TYPE BEA_PRC_SESSION_ID,
    LV_EXT_PRC_ID       TYPE PRCT_EXT_DOC_GUID,
    LT_RETURN           TYPE BEAT_RETURN,
    LV_NEW_SESSION_ONLY TYPE BEA_BOOLEAN.
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  CHECK NOT IS_BDH-PRIC_PROC IS INITIAL.
  IF IS_BDH-PRIDOC_GUID IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    MESSAGE E003(BEA_PRC) RAISING REJECT.
  ENDIF.
  LS_BDH_WRK = IS_BDH.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROJECTION / MAPPING
*---------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_HD_MAPIN'
    EXPORTING
      IS_BDH_WRK         = LS_BDH_WRK
    IMPORTING
      ES_PRC_HEAD        = LS_PRC_HEAD
      ET_RETURN          = LT_RETURN
    EXCEPTIONS
      REJECT             = 1
      OTHERS             = 2.
  IF SY-SUBRC NE 0.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E117(BEA_PRC) RAISING REJECT.
  ENDIF.

  LOOP AT IT_BDI INTO LS_BDI_WRK.
    CLEAR LS_PRC_ITEM.
    CLEAR LT_RETURN.
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPIN'
      EXPORTING
        IS_BDH_WRK         = LS_BDH_WRK
        IS_BDI_WRK         = LS_BDI_WRK
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

    APPEND LS_PRC_ITEM  TO LT_PRC_ITEM.
  ENDLOOP.
*---------------------------------------------------------------------
* END PROJECTION / MAPPING
*---------------------------------------------------------------------
  LV_EXT_PRC_ID = IS_BDH-BDH_GUID.
  CALL FUNCTION 'BEA_PRC_O_PD_OPEN'
    EXPORTING
      IV_PRIDOC_ID               = LS_BDH_WRK-PRIDOC_GUID
      IV_DOCUMENT_ID_EXT         = LV_EXT_PRC_ID
      IS_HEAD_COM                = LS_PRC_HEAD
      IT_ITEM_COM                = LT_PRC_ITEM
      IV_GROUP_PROCESSING        = IV_GROUP_PROCESSING
      IV_PARTIAL_PROCESSING      = IV_PARTIAL_PROCESSING
      IV_WRITE_MODE              = IV_WRITE_MODE
      IV_USE_NAME_VALUE          = GC_TRUE
    IMPORTING
      EV_SESSION_ID              = LV_SESSION_ID
      EV_PRICING_HANDLE          = LV_PD_HANDLE
      EV_NEW_SESSION_ONLY        = LV_NEW_SESSION_ONLY
    EXCEPTIONS
      ALREADY_OPEN_IN_WRITE_MODE = 1
      PRICING_ERROR              = 2
      MISSING_DATA               = 3
      OTHERS                     = 4.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      MESSAGE E107(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
    WHEN 2.
      MESSAGE E108(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
    WHEN OTHERS.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
  ENDCASE.
  IF LV_SESSION_ID IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    MESSAGE E003(BEA_PRC) RAISING REJECT.
  ELSE.
    LS_BDH_WRK-PRC_SESSION_ID = LV_SESSION_ID.
    IF LV_NEW_SESSION_ONLY IS INITIAL.
      CLEAR LT_RETURN.
      CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_PREPARE'
        EXPORTING
          IS_BDH_WRK   = LS_BDH_WRK
          IT_BDI_WRK   = IT_BDI
        IMPORTING
          ET_RETURN    = LT_RETURN.
      IF NOT LT_RETURN IS INITIAL.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
        MESSAGE E118(BEA_PRC) RAISING REJECT.
      ENDIF.
    ENDIF.
    EV_SESSION_ID = LV_SESSION_ID.
  ENDIF.
  IF LV_PD_HANDLE IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    MESSAGE E003(BEA_PRC) RAISING REJECT.
  ELSE.
    EV_PD_HANDLE = LV_PD_HANDLE.
  ENDIF.
ENDFUNCTION.
