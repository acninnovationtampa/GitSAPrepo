FUNCTION F4IF_START_VALUE_REQUEST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(DISPONLY) LIKE  DDSHF4CTRL-DISPONLY DEFAULT ' '
*"     VALUE(MAXRECORDS) LIKE  DDSHF4CTRL-MAXRECORDS DEFAULT 500
*"     VALUE(MULTISEL) LIKE  DDSHF4CTRL-MULTISEL DEFAULT ' '
*"     VALUE(CUCOL) LIKE  SY-CUCOL DEFAULT SY-CUCOL
*"     VALUE(CUROW) LIKE  SY-CUROW DEFAULT SY-CUROW
*"  EXPORTING
*"     VALUE(RC) LIKE  SY-SUBRC
*"  TABLES
*"      RETURN_VALUES STRUCTURE  DDSHRETVAL
*"----------------------------------------------------------------------
  DATA CALLCONTROL LIKE DDSHF4CTRL.
  DATA: OCXINTERFACE LIKE DDSHOCXINT.
  DATA: HELP_INFOS LIKE HELP_INFO.

  CALLCONTROL-DISPONLY = DISPONLY.
  CALLCONTROL-MAXRECORDS = MAXRECORDS.
  CALLCONTROL-MULTISEL = MULTISEL.
  CALLCONTROL-CUCOL = CUCOL.
  CALLCONTROL-CUROW = CUROW.
  CALLCONTROL-OCX_OFF = ' '.
* OCXINTERFACE wird bei F4 auf Selektionspopup exportiert, damit
* das OCX sein Parent-Control kennt. Damit nachfolgende F4-Aufrufe
* nicht durcheinander kommen, wird das Memory sofort danach gelöscht.
  IMPORT OCXINTERFACE FROM MEMORY ID 'OCXINT'.
* Falls es sich nicht um F4 auf dem OCX handelt, wird das ActiveX
* jetzt nicht mehr ausgeschaltet. Aber der modale Ablauf muß
* erzwungen werden.
  IF OCXINTERFACE-CTRLPARENT = 0.
    IMPORT HELP_INFOS FROM MEMORY ID 'HELP_INFOS'.
    IF SY-SUBRC = 0.
      CLEAR: HELP_INFOS-DYNPPROG, HELP_INFOS-DYNPRO.
      perform put_help_infos(saplsdsd) using help_infos changing shlp.
    ENDIF.
  ENDIF.

  REFRESH RETURN_VALUES.
  PERFORM F4PROZ(SAPLSDSD)
          TABLES RETURN_VALUES
          USING SHLP
          CHANGING CALLCONTROL OCXINTERFACE
                   RC.
  IF OCXINTERFACE-CTRLPARENT <> 0.
    EXPORT OCXINTERFACE TO MEMORY ID 'OCXINT'.
  ENDIF.
ENDFUNCTION.
