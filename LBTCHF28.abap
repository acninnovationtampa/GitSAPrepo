***INCLUDE LBTCHF28 .

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_MOVE_TO_TARGETSYSTEM     *
************************************************************************

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_MOVE_SYSLOG                                     *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM WRITE_JOB_MOVE_SYSLOG USING SYSLOGID DATA.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD JOB_MOVE_PROBLEM_DETECTED.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD SYSLOGID
        ID 'DATA' FIELD DATA.

ENDFORM. " WRITE_JOB_MOVE_SYSLOG


