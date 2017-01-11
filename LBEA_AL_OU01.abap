FUNCTION bea_al_o_refresh.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Refresh of the buffer of the Application Log
*-----------------------------------------------------------------------
  IF not gv_loghndl is initial.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = gv_loghndl
      EXCEPTIONS
        log_not_found = 0
        error_message = 0
        OTHERS        = 0.
  ENDIF.
*-----------------------------------------------------------------------
* Refresh of own buffer
*-----------------------------------------------------------------------
  CLEAR: gv_loghndl, gs_loghdr.
ENDFUNCTION.
