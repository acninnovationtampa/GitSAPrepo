FUNCTION /1BEA/CRMB_BD_PRC_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
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
    LS_BDH_WRK        TYPE /1BEA/S_CRMB_BDH_WRK,
    LV_SESSION_ID     TYPE BEA_PRC_SESSION_ID,
    LT_HANDLES_FAULT  TYPE PRCT_HANDLE_T,
    LV_PD_HANDLE      TYPE PRCT_HANDLE,
    LT_PD_HANDLE      TYPE PRCT_HANDLE_T.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  ET_BDH = IT_BDH.
  LOOP AT ET_BDH INTO LS_BDH_WRK
    WHERE NOT PRC_SESSION_ID IS INITIAL
    AND   NOT UPD_TYPE IS INITIAL.

    CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
       EXPORTING
            IV_SESSION_ID     = LS_BDH_WRK-PRC_SESSION_ID
       IMPORTING
            EV_PRICING_HANDLE = LV_PD_HANDLE
       EXCEPTIONS
            SESSION_NOT_FOUND = 1
            OTHERS            = 2.
    IF SY-SUBRC = 0.
      APPEND LV_PD_HANDLE TO LT_PD_HANDLE.
    ELSE.
      LS_BDH_WRK-PRICING_ERROR = GC_PRC_ERR_F.
      MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING PRICING_ERROR.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'PRC_PD_SAVE_MULTI'
    EXPORTING
      IT_PD_HANDLE                = LT_PD_HANDLE
    IMPORTING
      ET_HANDLES_FAULT            = LT_HANDLES_FAULT.
  LOOP AT LT_HANDLES_FAULT INTO LV_PD_HANDLE.
    CALL FUNCTION 'BEA_PRC_O_SESSION_CHANGE_GET'
       EXPORTING
            IV_PRICING_HANDLE = LV_PD_HANDLE
       IMPORTING
            EV_SESSION_ID     = LV_SESSION_ID
       EXCEPTIONS
            SESSION_NOT_FOUND = 1
            OTHERS            = 2.
    IF SY-SUBRC = 0.
      READ TABLE ET_BDH INTO LS_BDH_WRK
                 WITH KEY PRC_SESSION_ID = LV_SESSION_ID.
      IF SY-SUBRC = 0.
        LS_BDH_WRK-PRICING_ERROR = GC_PRC_ERR_F.
        MODIFY ET_BDH FROM LS_BDH_WRK INDEX SY-TABIX
                               TRANSPORTING PRICING_ERROR.
      ENDIF.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
