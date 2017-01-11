FUNCTION /1BEA/CRMB_BD_CRT_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH_WRK) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IV_POST) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_BDH_WRK) TYPE  /1BEA/T_CRMB_BDH_WRK
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LV_UPDATE_TASK TYPE BEA_BOOLEAN,
    LS_BDH_HLP     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_BDH_WRK     TYPE /1BEA/T_CRMB_BDH_WRK,
    LV_PD_HANDLE   TYPE PRCT_HANDLE,
    LS_HEAD_DATA   TYPE PRCT_HEAD_DATA,
    LS_SAVE_HANDLE TYPE ttepdt_save_handle_st,
    LT_SAVE_HANDLE TYPE ttepdt_save_handle_tt,
    LT_FAIL_HANDLE TYPE ttepdt_save_handle_tt,
    LS_SAVE_HEADER TYPE TTEPDT_COPY_DOC_HANDLE_ST.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  ET_BDH_WRK = IT_BDH_WRK.
  IF IV_POST = GC_TRUE.
    LV_UPDATE_TASK = GC_TRUE.
  ENDIF.
  LOOP AT ET_BDH_WRK INTO LS_BDH_WRK
    WHERE NOT UPD_TYPE IS INITIAL.

    IF NOT LS_BDH_WRK-PRC_SESSION_ID IS INITIAL.
      CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
         EXPORTING
              IV_SESSION_ID     = LS_BDH_WRK-PRC_SESSION_ID
         IMPORTING
              EV_PRICING_HANDLE = LV_PD_HANDLE
         EXCEPTIONS
              SESSION_NOT_FOUND = 1
              OTHERS            = 2.
      IF SY-SUBRC <> 0.
        IF LS_BDH_WRK-PRICING_ERROR IS INITIAL.
          LS_BDH_WRK-PRICING_ERROR = GC_PRC_ERR_C.
          MODIFY ET_BDH_WRK FROM LS_BDH_WRK TRANSPORTING PRICING_ERROR.
        ENDIF.
        CONTINUE.
      ENDIF.
      CALL FUNCTION 'PRC_PD_HEAD_READ'
        EXPORTING
          iv_pd_handle              = LV_PD_HANDLE
        IMPORTING
          ES_HEAD_DATA              = LS_HEAD_DATA
        EXCEPTIONS
          NON_EXISTING_HANDLE       = 1
          OTHERS                    = 2.
      IF SY-SUBRC <> 0.
        IF LS_BDH_WRK-PRICING_ERROR IS INITIAL.
          LS_BDH_WRK-PRICING_ERROR = GC_PRC_ERR_C.
          MODIFY ET_BDH_WRK FROM LS_BDH_WRK TRANSPORTING PRICING_ERROR.
        ENDIF.
        CONTINUE.
      ENDIF.
      IF NOT LS_HEAD_DATA-TTE_REQUIRED IS INITIAL.
        IF  ( LS_BDH_WRK-CANCEL_FLAG = GC_CANCEL OR
              LS_BDH_WRK-CANCEL_FLAG = GC_PARTIAL_CANCEL )
          AND LV_UPDATE_TASK = GC_FALSE.
*         for cancellation-documents don't retrieve from TTE-Kernel,
*         because the rigt document is already copied by ABAP-shell
          CONTINUE.
        ELSE.
          CLEAR LS_SAVE_HANDLE.
          PERFORM FILL_TTE_HANDLE
            USING
              LS_BDH_WRK
              LS_HEAD_DATA
            CHANGING
              LS_SAVE_HANDLE.
          APPEND LS_SAVE_HANDLE TO LT_SAVE_HANDLE.
        ENDIF.
      ENDIF.
    ENDIF.
*     Update header in case of cancellation
    IF LS_BDH_WRK-CANCEL_FLAG IS INITIAL AND
       LS_BDH_WRK-UPD_TYPE = GC_UPDATE AND
       LV_UPDATE_TASK = GC_TRUE.
      IF LT_BDH_WRK IS INITIAL.
        LT_BDH_WRK = IT_BDH_WRK.
      ENDIF.
      READ TABLE LT_BDH_WRK INTO LS_BDH_HLP
                 WITH KEY CANC_BDH_GUID = LS_BDH_WRK-BDH_GUID.
      IF SY-SUBRC = 0.
        CLEAR:
          LS_SAVE_HANDLE,
          LS_SAVE_HEADER.
        PERFORM FILL_TTE_HANDLE
          using
            LS_BDH_WRK
            LS_HEAD_DATA
          changing
            LS_SAVE_HANDLE.
        MOVE-CORRESPONDING LS_SAVE_HANDLE TO LS_SAVE_HEADER.
        LS_SAVE_HEADER-FROM_DOCUMENT_ID = LS_BDH_WRK-BDH_GUID.
        LS_SAVE_HEADER-TO_DOCUMENT_ID = LS_BDH_HLP-BDH_GUID.
        CALL FUNCTION 'TTE_4_DOCUMENT_SAVE_HEADER'
          EXPORTING
            IS_DOC_HANDLE            = LS_SAVE_HEADER
          EXCEPTIONS
            OTHERS                   = 0.
      ENDIF.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'TTE_4_DOCUMENT_SAVE_MULTI'
    EXPORTING
      IT_HANDLE                = LT_SAVE_HANDLE
      I_CALL_UPDATE_TASK       = LV_UPDATE_TASK
    IMPORTING
      OT_HANDLE                = LT_FAIL_HANDLE
    EXCEPTIONS
      OTHERS                   = 1.
  IF SY-SUBRC <> 0.
    LOOP AT LT_FAIL_HANDLE INTO LS_SAVE_HANDLE.
      READ TABLE ET_BDH_WRK INTO LS_BDH_WRK
                 WITH KEY BDH_GUID = LS_SAVE_HANDLE-REFTOORIGINAL.
      IF SY-SUBRC = 0 AND
         LS_BDH_WRK-PRICING_ERROR IS INITIAL.
        LS_BDH_WRK-PRICING_ERROR = GC_PRC_ERR_C.
        MODIFY ET_BDH_WRK FROM LS_BDH_WRK INDEX SY-TABIX
               TRANSPORTING PRICING_ERROR.
      ENDIF.
    ENDLOOP.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
*---------------------------------------------------------------------
* FORM FILL_TTE_HANDLE
*---------------------------------------------------------------------
FORM FILL_TTE_HANDLE
  using
    US_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
    US_HEAD_DATA   TYPE PRCT_HEAD_DATA
  changing
    CS_SAVE_HANDLE TYPE ttepdt_save_handle_st.
  STATICS:
    LV_LOGSYS      TYPE LOGSYS.
  IF LV_LOGSYS IS INITIAL.
    call function 'OWN_LOGICAL_SYSTEM_GET'
      importing
        own_logical_system = lv_logsys.
  ENDIF.
  if us_bdh_wrk-upd_Type = gc_insert.
    CS_SAVE_HANDLE-XCHANGE = GC_TRUE.
  else.
    CS_SAVE_HANDLE-XCHANGE = GC_FALSE.
  endif.
  CS_SAVE_HANDLE-REFTOORIGINAL = US_BDH_WRK-BDH_GUID.
  CS_SAVE_HANDLE-PRIDOCGUID = US_BDH_WRK-PRIDOC_GUID.
  CS_SAVE_HANDLE-OBJ_SYS       = LV_LOGSYS.
  CS_SAVE_HANDLE-OBJ_type      = gc_obj_type_bebd.
  CS_SAVE_HANDLE-OBJ_key+10(4) = GC_APPL.
  if us_bdh_wrk-headno_ext co gc_numeric.
    unpack us_bdh_wrk-headno_ext to CS_SAVE_HANDLE-OBJ_key(10).
  else.
    move us_bdh_wrk-headno_ext to CS_SAVE_HANDLE-OBJ_key(10).
  endif.
ENDFORM.
