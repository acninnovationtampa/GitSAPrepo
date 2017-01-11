FUNCTION /1BEA/CRMB_DL_PRC_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ET_DLI_FAULT) TYPE  /1BEA/T_CRMB_DLI_WRK
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LV_PD_HANDLE      TYPE PRCT_HANDLE,
    LT_PD_HANDLE      TYPE PRCT_HANDLE_T,
    LT_HANDLES_FAULT  TYPE PRCT_HANDLE_T,
    LT_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID,
    LS_SESSION_ID     TYPE BEA_PRC_SESSION_ID,
    LT_DLI_FAULT      TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI            TYPE /1BEA/S_CRMB_DLI_WRK.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
  LOOP AT IT_DLI INTO LS_DLI
         WHERE NOT UPD_TYPE       IS INITIAL AND
               NOT PRC_SESSION_ID IS INITIAL.
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
    APPEND LS_DLI-PRC_SESSION_ID TO LT_PRC_SESSION_ID.
    CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
         EXPORTING
              IV_SESSION_ID     = LS_DLI-PRC_SESSION_ID
         IMPORTING
              EV_PRICING_HANDLE = LV_PD_HANDLE
         EXCEPTIONS
              SESSION_NOT_FOUND = 1
              OTHERS            = 2.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
    IF NOT LS_DLI-PRIDOC_GUID IS INITIAL.
      APPEND LV_PD_HANDLE TO LT_PD_HANDLE.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'PRC_PD_SAVE_MULTI'
    EXPORTING
      IT_PD_HANDLE                  = LT_PD_HANDLE
    IMPORTING
      ET_HANDLES_FAULT              = LT_HANDLES_FAULT.

  IF ET_DLI_FAULT IS REQUESTED.
    CLEAR LT_DLI_FAULT.
    LOOP AT LT_HANDLES_FAULT INTO LV_PD_HANDLE.
      CALL FUNCTION 'BEA_PRC_O_SESSION_CHANGE_GET'
           EXPORTING
                IV_PRICING_HANDLE = LV_PD_HANDLE
           IMPORTING
                EV_SESSION_ID     = LS_SESSION_ID
           EXCEPTIONS
                SESSION_NOT_FOUND = 1
                OTHERS            = 2.
      IF SY-SUBRC NE 0.
        CONTINUE.
      ELSE.
        READ TABLE IT_DLI WITH KEY PRC_SESSION_ID = LS_SESSION_ID
                          INTO  LS_DLI.
        APPEND LS_DLI TO LT_DLI_FAULT.
      ENDIF.
    ENDLOOP.
    ET_DLI_FAULT = LT_DLI_FAULT.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
       EXPORTING
            IT_SESSION_ID = LT_PRC_SESSION_ID.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
ENDFUNCTION.
