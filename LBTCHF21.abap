***INCLUDE LBTCHF21 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_MAINTENANCE             *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_MAINTEN_SYSLOG                                  *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM WRITE_JOB_MAINTEN_SYSLOG USING SYSLOGID DATA.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD JOB_MAINT_PROBLEM_DETECTED.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD SYSLOGID
        ID 'DATA' FIELD DATA.

ENDFORM. " WRITE_JOB_MAINTEN_SYSLOG

