FUNCTION /1BEA/CRMB_DL_PRC_O_OPEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IV_WRITE_MODE) TYPE  BEA_BOOLEAN OPTIONAL
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
* Time  : 13:53:10
*
*======================================================================
*--------------------------------------------------------------------
* BEGIN DEFINITION
*--------------------------------------------------------------------
  CONSTANTS:
    LC_CP_PRICING_TYPE  TYPE PRCT_PRICING_TYPE VALUE 'D',
    LC_CP_PRCCOPY_TYPE  TYPE PRCT_COPY_TYPE    VALUE '01000'.
  DATA:
    LS_PRC_ITEM         TYPE PRCT_ITEM_COM_VAR,
    LT_PRC_ITEM         TYPE PRCT_ITEM_COM_T,
    LV_PD_HANDLE        TYPE PRCT_HANDLE,
    LV_SESSION_ID       TYPE BEA_PRC_SESSION_ID,
    LV_EXT_PRC_ID       TYPE PRCT_EXT_DOC_GUID,
    LT_RETURN           TYPE BEAT_RETURN,
    LS_DLI              TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_COND_COM         TYPE BEAT_PRC_COM,
    LS_COND_COM         TYPE BEAS_PRC_COM,
    LT_COND             TYPE PRCT_COND_DU_TAB,
    LS_COND             TYPE PRCT_COND_DU,
    LT_HEAD             TYPE PRCT_HEAD_DU_TAB,
    LS_HEAD             TYPE PRCT_HEAD_DU,
    LT_PRIDOC           TYPE PRCT_PRIDOC_GUID_T,
    LS_PRIDOC           TYPE PRCT_PRIDOC_GUID,
    LRT_ITEM            TYPE PRCT_ITEM_NO_RT,
    LRS_ITEM            TYPE PRCT_ITEM_NO_RS,
    LS_ITC              TYPE BEAS_ITC_WRK,
    LV_EXT_COND_SUPPLY  TYPE BEA_BOOLEAN,
    LV_NEW_SESSION_ONLY TYPE BEA_BOOLEAN.

*--------------------------------------------------------------------
* END DEFINITION
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*--------------------------------------------------------------------
  IF NOT IS_DLI-SRVDOC_SOURCE IS INITIAL.
    IF NOT IS_DLI-PRIDOC_GUID IS INITIAL.
      LV_EXT_COND_SUPPLY = GC_FALSE.
      LS_PRIDOC = IS_DLI-PRIDOC_GUID.
      APPEND LS_PRIDOC TO LT_PRIDOC.
      LRS_ITEM-SIGN   = GC_INCLUDE.
      LRS_ITEM-OPTION = GC_RANGEOPTION_EQ.
      IF IS_DLI-SRC_PRC_GUID IS INITIAL.
        LRS_ITEM-LOW    = IS_DLI-SRC_GUID.
      ELSE.
        LRS_ITEM-LOW    = IS_DLI-SRC_PRC_GUID.
      ENDIF.
      APPEND LRS_ITEM TO LRT_ITEM.
      CALL FUNCTION 'PRC_PRIDOC_SELECT_MULTI_DB'
        EXPORTING
          IT_PRIDOC_GUID          = LT_PRIDOC
          IRT_ITEM_NO             = LRT_ITEM
        IMPORTING
          ET_HEAD                 = LT_HEAD
          ET_COND                 = LT_COND.
      LOOP AT LT_COND INTO LS_COND.
        CLEAR LS_COND_COM.
        MOVE-CORRESPONDING LS_COND TO LS_COND_COM.
        APPEND LS_COND_COM TO LT_COND_COM.
      ENDLOOP.
    ELSE.
      LV_EXT_COND_SUPPLY = GC_TRUE.
    ENDIF.
    LS_ITC = IS_ITC.
    READ TABLE LT_HEAD INTO LS_HEAD INDEX 1.
    IF SY-SUBRC EQ 0.
      LS_ITC-DLI_PRC_PROC = LS_HEAD-KALSM.
    ENDIF.
    LS_ITC-DLI_PRICING_TYPE  = LC_CP_PRICING_TYPE.
    LS_ITC-DLI_PRCCOPY_TYPE  = LC_CP_PRCCOPY_TYPE.
    CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_CREATE'
      EXPORTING
        IS_DLI            = IS_DLI
        IS_ITC            = LS_ITC
        IT_COND_COM       = LT_COND_COM
        IV_EXT_COND_SUPPLY = LV_EXT_COND_SUPPLY
      IMPORTING
        ES_DLI            = LS_DLI
      EXCEPTIONS
        OTHERS            = 0.

*   Creation only for display purposes.
*   Dequeue immediately again
    IF ls_dli-pridoc_guid IS NOT INITIAL.
      CALL FUNCTION 'PRC_LOCK'
        EXPORTING
          iv_pd_guid   = ls_dli-pridoc_guid
          iv_lock_mode = prcon_lock_dequeue
        EXCEPTIONS
          OTHERS       = 0.
    ENDIF.

    LV_SESSION_ID = LS_DLI-PRC_SESSION_ID.
    CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
      EXPORTING
        IV_SESSION_ID           = LV_SESSION_ID
      IMPORTING
        EV_PRICING_HANDLE       = LV_PD_HANDLE
      EXCEPTIONS
        OTHERS                  = 0.
  ELSE.
  IF IS_DLI-PRIDOC_GUID IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    MESSAGE E003(BEA_PRC) RAISING REJECT.
  ENDIF.
*--------------------------------------------------------------------
* END CHECK INTERFACE
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* BEGIN MAPPING
*--------------------------------------------------------------------
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_IT_MAPIN'
    EXPORTING
      IS_DLI_WRK         = IS_DLI
      IS_ITC             = IS_ITC
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
*--------------------------------------------------------------------
* END MAPPING
*--------------------------------------------------------------------
  LV_EXT_PRC_ID = LS_PRC_ITEM-KPOSN.
  CALL FUNCTION 'BEA_PRC_O_PD_OPEN'
    EXPORTING
      IV_PRIDOC_ID               = IS_DLI-PRIDOC_GUID
      IV_DOCUMENT_ID_EXT         = LV_EXT_PRC_ID
      IT_ITEM_COM                = LT_PRC_ITEM
      IV_GROUP_PROCESSING        = GC_FALSE
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
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
              CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
    WHEN 2.
      MESSAGE E108(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
              CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
    WHEN OTHERS.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
              CHANGING ET_RETURN.
      MESSAGE E003(BEA_PRC) RAISING REJECT.
  ENDCASE.
  IF NOT LV_SESSION_ID IS INITIAL.
    LS_DLI = IS_DLI.
    LS_DLI-PRC_SESSION_ID = LV_SESSION_ID.
    IF LV_NEW_SESSION_ONLY IS INITIAL.
      CLEAR LT_RETURN.
      CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_PREPARE'
        EXPORTING
          IS_DLI_WRK   = LS_DLI
        IMPORTING
          ET_RETURN    = LT_RETURN.
      IF NOT LT_RETURN IS INITIAL.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
        MESSAGE E118(BEA_PRC) RAISING REJECT.
      ENDIF.
    ENDIF.
  ENDIF.
  ENDIF.
  IF LV_SESSION_ID IS INITIAL.
    MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
              CHANGING ET_RETURN.
    MESSAGE E003(BEA_PRC) RAISING REJECT.
  ELSE.
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
