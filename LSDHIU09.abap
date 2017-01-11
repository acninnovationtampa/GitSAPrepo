FUNCTION F4IF_GET_SHLP_DESCR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(SHLPNAME) TYPE  SHLPNAME
*"     VALUE(SHLPTYPE) TYPE  DDSHLPTYP DEFAULT 'SH'
*"  EXPORTING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"----------------------------------------------------------------------
  SHLP-SHLPNAME = SHLPNAME.
  SHLP-SHLPTYPE = SHLPTYPE.
  CALL FUNCTION 'DD_SHLP_GET_HELPMETHOD'
       EXPORTING
            TABNAME   = SPACE
            FIELDNAME = SPACE
            LANGU     = SY-LANGU
       CHANGING
            SHLP      = SHLP
       EXCEPTIONS
            OTHERS    = 0.

  CALL FUNCTION 'DD_SHLP_GET_DIALOG_INFO'
       CHANGING
            SHLP   = SHLP
       EXCEPTIONS
            OTHERS = 0.

ENDFUNCTION.
