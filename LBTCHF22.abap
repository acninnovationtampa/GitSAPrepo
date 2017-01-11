***INCLUDE LBTCHF22 .

***********************************************************************
* Hilfsfunktionen des Funktionsbausteins BP_JOBLOG_SHOW               *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM WRITE_JOBLOG_SHOW_SYSLOG                                  *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM WRITE_JOBLOG_SHOW_SYSLOG USING SYSLOGID DATA.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD JOBLOG_SH_PROBLEM_DETECTED.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD SYSLOGID
        ID 'DATA' FIELD DATA.

ENDFORM. " WRITE_JOBLOG_SHOW_SYSLOG
*---------------------------------------------------------------------*
*   FORM SHOW_JOBLOG_ENTRY_DETAILS                                    *
*---------------------------------------------------------------------*
* Diese Funktion zeigt Detailinformation zu einem Joblogeintrag an.   *
* Der Eintrag wird durch entsprechende HIDE-Variablen eindeutig       *
* identifiziert.                                                      *
*---------------------------------------------------------------------*
FORM show_joblog_entry_detail
  USING i_joblog_line TYPE tbtc5
        i_wpnum TYPE i.
*
* Hilfsfelder zur Parameter-Uebergabe an Langtext-Anzeige eines
* Job-Protokoll Eintrags
*
  TABLES: snap.
  FIELD-SYMBOLS: <rabaxkey>.
  DATA: msg_text LIKE shkontext-meldung,
        msg_arbgb LIKE shkontext-meld_id,
        msg_nr LIKE shkontext-meld_nr,
        msg_title LIKE shkontext-titel,
        p_temp_length TYPE i,
        p_length TYPE i.

*
* feststellen, ob es sich um eine RABAX- oder T100-Meldung handelt
* und danach den Eintrag entsprechend anzeigen
*
  IF i_joblog_line-rabaxkeyln > 0. " Rabax-Meldung
    DESCRIBE FIELD snap-mandt LENGTH p_temp_length IN CHARACTER MODE.
    p_length = p_length + p_temp_length.
    DESCRIBE FIELD snap-datum LENGTH p_temp_length IN CHARACTER MODE.
    p_length = p_length + p_temp_length.
    DESCRIBE FIELD snap-uzeit LENGTH p_temp_length IN CHARACTER MODE.
    p_length = p_length + p_temp_length.
    DESCRIBE FIELD snap-ahost LENGTH p_temp_length IN CHARACTER MODE.
    p_length = p_length + p_temp_length.
    DESCRIBE FIELD snap-uname LENGTH p_temp_length IN CHARACTER MODE.
    p_length = p_length + p_temp_length.

    ASSIGN i_joblog_line-rabaxkey+0(p_length) TO <rabaxkey>.
    MOVE <rabaxkey> TO snap.

    snap-modno = i_wpnum.

    CALL DIALOG 'RS_RUN_TIME_ERROR'
      EXPORTING
        snap-mandt
        snap-datum
        snap-uzeit
        snap-ahost
        snap-uname
        snap-modno.
  ELSE. " normale T100-Meldung
    msg_arbgb = i_joblog_line-msgid.
    msg_nr    = i_joblog_line-msgno.
    msg_text  = i_joblog_line-text.
    msg_title = sy-title.
    CALL FUNCTION 'HELPSCREEN_NA_CREATE'     "#EC FB_OLDED
      EXPORTING
        meldung = msg_text
        meld_id = msg_arbgb
        meld_nr = msg_nr
        msgv1   = i_joblog_line-msgv1
        msgv2   = i_joblog_line-msgv2
        msgv3   = i_joblog_line-msgv3
        msgv4   = i_joblog_line-msgv4
        titel   = msg_title
      EXCEPTIONS
        OTHERS  = 99.
  ENDIF.

ENDFORM. " SHOW_JOBLOG_ENTRY_DETAIL.
