FUNCTION /1BEA/CRMB_BD_CRT_O_IT_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BDH_CANCEL) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI_CANCEL) TYPE  /1BEA/T_CRMB_BDI_WRK
*"  EXPORTING
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
    LV_PD_HANDLE        TYPE PRCT_HANDLE,
    LS_HEAD_DATA        TYPE PRCT_HEAD_DATA,
    LS_DOC_HANDLE       TYPE TTEPDT_COPY_DOC_HANDLE_ST,
    LS_ITEMS_HANDLE     TYPE TTEPDT_COPY_ITEMS_HANDLE_ST,
    LT_ITEMS_HANDLE     TYPE TTEPDT_COPY_ITEMS_HANDLE_TT,
    LS_BDI_CANCEL       TYPE /1BEA/S_CRMB_BDI_WRK.
*---------------------------------------------------------------------
* PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
    EXPORTING
      IV_SESSION_ID     = IS_BDH_CANCEL-PRC_SESSION_ID
    IMPORTING
      EV_PRICING_HANDLE = LV_PD_HANDLE
    EXCEPTIONS
      SESSION_NOT_FOUND = 1.
  IF SY-SUBRC <> 0.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
  CALL FUNCTION 'PRC_PD_HEAD_READ'
    EXPORTING
      IV_PD_HANDLE         = LV_PD_HANDLE
     IMPORTING
       ES_HEAD_DATA        = LS_HEAD_DATA
     EXCEPTIONS
       NON_EXISTING_HANDLE = 1
       OTHERS              = 2.
  IF SY-SUBRC <> 0.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E110(BEA_PRC) INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E110(BEA_PRC) RAISING REJECT.
  ENDIF.
  IF NOT LS_HEAD_DATA-TTE_REQUIRED IS INITIAL.
    LS_DOC_HANDLE-FROM_DOCUMENT_ID = IS_BDH-BDH_GUID.
    LS_DOC_HANDLE-TO_DOCUMENT_ID   = IS_BDH_CANCEL-BDH_GUID.
    LOOP AT IT_BDI_CANCEL INTO LS_BDI_CANCEL.
      CLEAR LS_ITEMS_HANDLE.
      LS_ITEMS_HANDLE-FROM_ITEMID = LS_BDI_CANCEL-REVERSED_BDI_GUID.
      LS_ITEMS_HANDLE-TO_ITEMID   = LS_BDI_CANCEL-BDI_GUID.
      APPEND LS_ITEMS_HANDLE TO LT_ITEMS_HANDLE.
    ENDLOOP.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
    CALL FUNCTION 'TTE_4_DOCUMENT_COPY'
      EXPORTING
        IS_DOC_HANDLE           = LS_DOC_HANDLE
        IT_ITEMS_HANDLE         = LT_ITEMS_HANDLE
      EXCEPTIONS
        NO_TTE_DOCUMENT         = 1
        FOREIGN_LOCK_ERROR      = 2
        SYSTEM_FAILURE          = 3
        OTHERS                  = 4.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN OTHERS.
        IF ET_RETURN IS REQUESTED.
          MESSAGE E116(BEA_PRC) WITH IS_BDH-HEADNO_EXT INTO GV_DUMMY.
          PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                          CHANGING ET_RETURN.
        ENDIF.
        MESSAGE E116(BEA_PRC) WITH IS_BDH-HEADNO_EXT RAISING REJECT.
    ENDCASE.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
