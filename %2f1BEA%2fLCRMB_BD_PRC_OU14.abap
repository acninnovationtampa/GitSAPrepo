FUNCTION /1BEA/CRMB_BD_PRC_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
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
    LS_BDH            TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID.
  IF IT_BDH IS INITIAL.
    RETURN.
  ENDIF.
  LOOP AT IT_BDH INTO LS_BDH.
    APPEND LS_BDH-PRC_SESSION_ID TO LT_PRC_SESSION_ID.
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
