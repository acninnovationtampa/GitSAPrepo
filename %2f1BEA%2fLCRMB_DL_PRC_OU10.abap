FUNCTION /1BEA/CRMB_DL_PRC_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
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
  DATA:
    LS_DLI            TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID,
    LS_PD_GUID        TYPE BEA_PRIDOC_GUID.
  IF IT_DLI IS INITIAL.
    RETURN.
  ENDIF.
  CLEAR LS_PD_GUID.
  LOOP AT IT_DLI INTO LS_DLI.
    IF LS_DLI-PRC_SESSION_ID IS INITIAL.
* Delete all the buffered information from database buffer
      CALL FUNCTION 'PRC_PRIDOC_INIT_DB'
        EXPORTING
          iv_pd_guid = LS_PD_GUID.
    ELSE.
      APPEND LS_DLI-PRC_SESSION_ID TO LT_PRC_SESSION_ID.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
      EXPORTING
         IT_SESSION_ID = LT_PRC_SESSION_ID.
  IF NOT GV_PRC_LOGHNDL IS INITIAL.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        I_LOG_HANDLE        = GV_PRC_LOGHNDL
      EXCEPTIONS
        OTHERS              = 0.
    CLEAR GV_PRC_LOGHNDL.
  ENDIF.
  CALL FUNCTION 'BEA_PRC_O_REFRESH'.
ENDFUNCTION.
