FUNCTION /1BEA/CRMB_BD_PRC_O_IT_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IV_SUPPRESS_COPY) TYPE  BEA_BOOLEAN OPTIONAL
*"     REFERENCE(IV_EXTENDED_LOG) TYPE  BEA_BOOLEAN OPTIONAL
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
  CONSTANTS:
    LC_KNTYP_G            TYPE PRCT_COND_CATEGORY  VALUE 'G',
    LC_SIGN_I             TYPE BAPISIGN            VALUE 'I',
    LC_OPTION_EQ          TYPE BAPIOPTION          VALUE 'EQ'.
  DATA:
    LS_BDI_WRK            TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_PRC_ITEM           TYPE PRCT_ITEM_COM_VAR,
    LT_PRC_ITEM           TYPE PRCT_ITEM_COM_T,
    LT_PRC_ITEM_COPY      TYPE PRCT_ITEM_COM_T,
    LRS_KNTYP             TYPE PRCT_COND_CATEGORY_RS,
    LRT_KNTYP             TYPE PRCT_COND_CATEGORY_RT,
    LT_PRIDOC_GUID        TYPE PRCT_PRIDOC_GUID_T,
    LT_PRCD_COND          TYPE PRCT_COND_DU_TAB,
    LS_PRCD_COND          TYPE PRCD_COND,
    LS_PD2ITEMNO          TYPE TY_PD2ITEMNO,
    LT_PD2ITEMNO          TYPE SORTED TABLE OF TY_PD2ITEMNO
                               WITH NON-UNIQUE KEY PRIDOC_GUID ITEM_NO,
    LS_PRC_COPY           TYPE PRCT_COPY_DATA,
    LT_PRC_COPY           TYPE PRCT_COPY_DATA_T,
    LV_PD_HANDLE          TYPE PRCT_HANDLE,
    LS_PRC_I_RET          TYPE PRCT_ITEM_RET,
    LT_PRC_I_RET_COM      TYPE PRCT_ITEM_RET_T,
    LS_PRC_I_RET_COM      TYPE PRCT_ITEM_RET_COM,
    LT_PRC_I_RET_COM_COPY TYPE PRCT_ITEM_RET_T,
    LV_ITEM_NO            TYPE PRCT_ITEM_NO,
    LV_TABIX_NOCOPY       TYPE SYTABIX,
    LV_TABIX_COPY         TYPE SYTABIX,
    LS_RETURN             TYPE BEAS_RETURN,
    LT_RETURN             TYPE BEAT_RETURN,
    LS_PRC_RETURN         TYPE BEAS_PRC_RETURN,
    LT_PRC_RETURN         TYPE BEAT_PRC_RETURN,
    LV_PRICING_STATUS     TYPE BEA_PRICING_STATUS,
    LV_ANY_PROBLEM        TYPE BEA_PRICING_STATUS.
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  ES_BDH = IS_BDH.
  ET_BDI = IT_BDI.
  CLEAR LV_ANY_PROBLEM.
  IF IS_BDH-PRC_SESSION_ID IS INITIAL.
    RETURN.
  ENDIF.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
  IF GV_PRC_LOGHNDL IS INITIAL.
    PRC_LOG_INIT.
  ENDIF.
  CALL FUNCTION 'BEA_PRC_O_REFRESH'.
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
    EXPORTING
      IV_SESSION_ID     = IS_BDH-PRC_SESSION_ID
    IMPORTING
      EV_PRICING_HANDLE = LV_PD_HANDLE
    EXCEPTIONS
      SESSION_NOT_FOUND = 1
      OTHERS            = 2.
  IF SY-SUBRC NE 0.
    PRC_SET_ERROR ES_BDH-PRICING_ERROR GC_PRC_ERR_F.
    MESSAGE E006(BEA_PRC) RAISING INCOMPLETE.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* SECOND PART
*---------------------------------------------------------------------
  LOOP AT ET_BDI INTO LS_BDI_WRK.
    CLEAR LS_BDI_WRK-PRICING_STATUS.
    CLEAR LS_PRC_ITEM.
    CLEAR LT_RETURN.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
    CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_MAPIN'
      EXPORTING
        IS_BDH_WRK         = IS_BDH
        IS_BDI_WRK         = LS_BDI_WRK
      IMPORTING
        ES_PRC_ITEM        = LS_PRC_ITEM
        ET_RETURN          = LT_RETURN
      EXCEPTIONS
        REJECT             = 1
        OTHERS             = 2.
    IF SY-SUBRC NE 0.
      PRC_SET_STATUS GC_PRC_STAT_MAP
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
      IF LV_ANY_PROBLEM IS INITIAL.
        LV_ANY_PROBLEM = GC_PRC_STAT_MAP.
      ENDIF.
      APPEND LINES OF LT_RETURN TO ET_RETURN.
    ENDIF.

    IF IV_SUPPRESS_COPY IS INITIAL AND
     ( LS_BDI_WRK-PRV_PRIDOC_GUID IS INITIAL OR
       LS_BDI_WRK-PRV_ITEM_GUID   IS INITIAL ) AND
       LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_COPY.
      PRC_SET_STATUS GC_PRC_STAT_NOTREL
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
      CLEAR LS_PRC_ITEM-PRICING_RELEVANT.
    ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
    IF IV_SUPPRESS_COPY IS INITIAL AND LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_COPY.
      CLEAR LS_PRC_COPY.
      LS_PRC_COPY-PD_GUID         = LS_BDI_WRK-PRV_PRIDOC_GUID.
      LS_PRC_COPY-ITEM_NO         = LS_BDI_WRK-PRV_ITEM_GUID.
      LS_PRC_COPY-PRICING_TYPE    = LS_BDI_WRK-BDI_PRICING_TYPE.
      LS_PRC_COPY-COPY_TYPE       = LS_BDI_WRK-BDI_PRCCOPY_TYPE.
      LS_PRC_COPY-SALES_QTY_VALUE = LS_BDI_WRK-REF_QUANTITY.
      LS_PRC_COPY-SALES_QTY_UNIT  = LS_BDI_WRK-REF_QTY_UNIT.
      LS_PRC_COPY-NETVALUE_ORIG   = LS_BDI_WRK-NET_VALUE_MAN.
      LS_PRC_COPY-NETVALUE_NEW    = LS_BDI_WRK-NET_VALUE.
      IF LS_PRC_COPY-SALES_QTY_VALUE LT 0.
         LS_PRC_COPY-SALES_QTY_VALUE = ABS( LS_PRC_COPY-SALES_QTY_VALUE ).
      ENDIF.

      IF NOT LS_BDI_WRK-SUC_PRIDOC_GUID IS INITIAL AND
         NOT LS_BDI_WRK-SUC_ITEM_GUID   IS INITIAL.
        COLLECT LS_BDI_WRK-SUC_PRIDOC_GUID INTO LT_PRIDOC_GUID.
        LS_PD2ITEMNO-PRIDOC_GUID = LS_BDI_WRK-SUC_PRIDOC_GUID.
        LS_PD2ITEMNO-ITEM_NO     = LS_BDI_WRK-SUC_ITEM_GUID.
        LS_PD2ITEMNO-ITEM_NO_NEW = LS_PRC_ITEM-KPOSN.
        INSERT LS_PD2ITEMNO INTO TABLE LT_PD2ITEMNO.
      ELSE.
        COLLECT LS_BDI_WRK-PRV_PRIDOC_GUID INTO LT_PRIDOC_GUID.
        LS_PD2ITEMNO-PRIDOC_GUID = LS_BDI_WRK-PRV_PRIDOC_GUID.
        LS_PD2ITEMNO-ITEM_NO     = LS_BDI_WRK-PRV_ITEM_GUID.
        LS_PD2ITEMNO-ITEM_NO_NEW = LS_PRC_ITEM-KPOSN.
        INSERT LS_PD2ITEMNO INTO TABLE LT_PD2ITEMNO.
      ENDIF.
      APPEND LS_PRC_COPY  TO LT_PRC_COPY.
      APPEND LS_PRC_ITEM  TO LT_PRC_ITEM_COPY.
    ELSE.
      APPEND LS_PRC_ITEM  TO LT_PRC_ITEM.
    ENDIF.

    MODIFY ET_BDI FROM LS_BDI_WRK.
  ENDLOOP.
  CLEAR LT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_PREPARE'
    EXPORTING
      IS_BDH_WRK   = IS_BDH
      IT_BDI_WRK   = ET_BDI
    IMPORTING
      ET_RETURN    = LT_RETURN.
  IF NOT LT_RETURN IS INITIAL.
    PRC_SET_ERROR ES_BDH-PRICING_ERROR GC_PRC_ERR_F.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
    MESSAGE E118(BEA_PRC) RAISING INCOMPLETE.
  ENDIF.
  IF NOT LT_PRIDOC_GUID IS INITIAL.
    CALL FUNCTION 'PRC_PRIDOC_SELECT_MULTI_DB'
      EXPORTING
        IT_PRIDOC_GUID       = LT_PRIDOC_GUID
      IMPORTING
        ET_COND              = LT_PRCD_COND.
    LOOP AT LT_PRCD_COND INTO LS_PRCD_COND.
      READ TABLE LT_PD2ITEMNO INTO LS_PD2ITEMNO
        WITH TABLE KEY PRIDOC_GUID = LS_PRCD_COND-KNUMV
                       ITEM_NO     = LS_PRCD_COND-KPOSN.
      IF SY-SUBRC EQ 0.
        LS_PRCD_COND-KPOSN = LS_PD2ITEMNO-ITEM_NO_NEW.
        MODIFY LT_PRCD_COND FROM LS_PRCD_COND.
      ENDIF.
    ENDLOOP.
    CALL FUNCTION 'BEA_PRC_O_ADD_TO_BUFFER'
      EXPORTING
        IT_CONDITION = LT_PRCD_COND.
  ENDIF.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  IF NOT LT_PRC_ITEM IS INITIAL.  "Create new pricing items
    CALL FUNCTION 'PRC_PD_ITEM_CREATE_MULTI'
      EXPORTING
        IV_PD_HANDLE              = LV_PD_HANDLE
        IV_BAL_LOG                = GV_PRC_LOGHNDL
        IT_ITEM_COM               = LT_PRC_ITEM
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
              IV_PD_HANDLE = LV_PD_HANDLE
            IMPORTING
              ET_PRC_MSG   = LT_PRC_RETURN.
          LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
            CLEAR LS_RETURN.
            MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
            APPEND LS_RETURN TO ET_RETURN.
          ENDLOOP.
        ENDIF.
        PRC_SET_ERROR ES_BDH-PRICING_ERROR GC_PRC_ERR_F.
        MESSAGE E005(BEA_PRC) RAISING INCOMPLETE.
    ENDCASE.
  ENDIF.
  IF NOT LT_PRC_ITEM_COPY IS INITIAL.
    CALL FUNCTION 'PRC_PD_ITEM_CREATE_WITH_REFM'
      EXPORTING
        IV_PD_HANDLE              = LV_PD_HANDLE
        IV_BAL_LOG                = GV_PRC_LOGHNDL
        IT_ITEM_COM               = LT_PRC_ITEM_COPY
        IT_COPY_DATA              = LT_PRC_COPY
      IMPORTING
        ET_ITEM_RET               = LT_PRC_I_RET_COM_COPY
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
              IV_PD_HANDLE = LV_PD_HANDLE
            IMPORTING
              ET_PRC_MSG   = LT_PRC_RETURN.
          LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
            CLEAR LS_RETURN.
            MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
            APPEND LS_RETURN TO ET_RETURN.
          ENDLOOP.
        ENDIF.
        PRC_SET_ERROR ES_BDH-PRICING_ERROR GC_PRC_ERR_F.
        MESSAGE E005(BEA_PRC) RAISING INCOMPLETE.
    ENDCASE.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
  LOOP AT ET_BDI INTO LS_BDI_WRK.
    CLEAR LV_PRICING_STATUS.
    IF LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_COPY.
      ADD 1 TO LV_TABIX_COPY.
      READ TABLE LT_PRC_ITEM_COPY INTO LS_PRC_ITEM INDEX LV_TABIX_COPY.
    ELSEIF LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_NOCOPY.
      ADD 1 TO LV_TABIX_NOCOPY.
      READ TABLE LT_PRC_ITEM INTO LS_PRC_ITEM INDEX LV_TABIX_NOCOPY.
    ENDIF.
    IF SY-SUBRC NE 0 OR LS_PRC_ITEM-KPOSN IS INITIAL.
      PRC_SET_STATUS GC_PRC_STAT_INTERR
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
      LV_ANY_PROBLEM = GC_PRC_STAT_INTERR.
    ENDIF.
    LV_ITEM_NO = LS_PRC_ITEM-KPOSN.
    CLEAR LT_PRC_RETURN.
    CALL FUNCTION 'BEA_PRC_O_MSG_CHECK'
      EXPORTING
        IV_LOGHNDL   = GV_PRC_LOGHNDL
        IV_PD_HANDLE = LV_PD_HANDLE
        IV_ITEM_NO   = LV_ITEM_NO
      IMPORTING
        EV_MSG_FLAG  = LV_PRICING_STATUS
        ET_PRC_MSG   = LT_PRC_RETURN.
    IF NOT LV_PRICING_STATUS IS INITIAL.
      IF NOT IV_EXTENDED_LOG IS INITIAL.
        LOOP AT LT_PRC_RETURN INTO LS_PRC_RETURN.
          CLEAR LS_RETURN.
          MOVE-CORRESPONDING LS_PRC_RETURN TO LS_RETURN.
          APPEND LS_RETURN TO ET_RETURN.
        ENDLOOP.
      ENDIF.
      PRC_SET_STATUS LV_PRICING_STATUS
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
      CASE LV_ANY_PROBLEM.
        WHEN GC_PRC_STAT_OK OR GC_PRC_STAT_MAP.
          LV_ANY_PROBLEM = LV_PRICING_STATUS.
        WHEN GC_PRC_STAT_WARN.
          LV_ANY_PROBLEM = LV_PRICING_STATUS.
        WHEN GC_PRC_STAT_ERR.
          IF LV_PRICING_STATUS EQ GC_PRC_STAT_INTERR.
            LV_ANY_PROBLEM = LV_PRICING_STATUS.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_COPY.
      READ TABLE LT_PRC_I_RET_COM_COPY INTO LS_PRC_I_RET_COM
                                   WITH KEY KPOSN = LV_ITEM_NO.
    ELSEIF LS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_NOCOPY.
      READ TABLE LT_PRC_I_RET_COM INTO LS_PRC_I_RET_COM
                              WITH KEY KPOSN = LV_ITEM_NO.
    ENDIF.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_PRC_I_RET_COM TO LS_PRC_I_RET.
      CLEAR LT_RETURN.
*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
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
        APPEND LINES OF LT_RETURN TO ET_RETURN.
        PRC_SET_STATUS GC_PRC_STAT_MAP
                       LS_BDI_WRK-PRICING_STATUS
                       ES_BDH-PRICING_ERROR.
        IF LV_ANY_PROBLEM IS INITIAL.
          LV_ANY_PROBLEM = GC_PRC_STAT_MAP.
        ENDIF.
      ELSEIF LT_RETURN is not initial.
        APPEND LINES OF LT_RETURN TO ET_RETURN.
      ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------
    ELSE.
      PRC_SET_STATUS GC_PRC_STAT_INTERR
                     LS_BDI_WRK-PRICING_STATUS
                     ES_BDH-PRICING_ERROR.
      LV_ANY_PROBLEM = GC_PRC_STAT_INTERR.
    ENDIF.
    MODIFY ET_BDI FROM LS_BDI_WRK.
  ENDLOOP.
  PRC_LOG_CLEAR.
  CASE LV_ANY_PROBLEM.
    WHEN GC_PRC_STAT_OK.
    WHEN GC_PRC_STAT_WARN.
      MESSAGE W007(BEA_PRC) RAISING INCOMPLETE.
    WHEN GC_PRC_STAT_ERR.
      MESSAGE W008(BEA_PRC) RAISING INCOMPLETE.
    WHEN GC_PRC_STAT_MAP.
      MESSAGE W117(BEA_PRC) RAISING INCOMPLETE.
    WHEN GC_PRC_STAT_INTERR.
      MESSAGE W005(BEA_PRC) RAISING INCOMPLETE.
  ENDCASE.

ENDFUNCTION.
