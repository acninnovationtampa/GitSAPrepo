FUNCTION RS_SET_SELSCREEN_STATUS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_STATUS) LIKE  SY-PFKEY
*"             VALUE(P_PROGRAM) LIKE  SY-REPID DEFAULT SPACE
*"       TABLES
*"              P_EXCLUDE
*"----------------------------------------------------------------------

  PERFORM SET_USER_STATUS(RSDBRUNT) TABLES P_EXCLUDE
                                    USING P_STATUS P_PROGRAM.


ENDFUNCTION.
