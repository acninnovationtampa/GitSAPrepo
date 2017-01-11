FUNCTION BEA_AL_O_GETBUFFER .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(EV_LOGHNDL) TYPE  BALLOGHNDL
*"     REFERENCE(ES_LOGHDR) TYPE  BAL_S_LOG
*"----------------------------------------------------------------------

    ev_loghndl = gv_loghndl.
    es_loghdr  = gs_loghdr.

ENDFUNCTION.
