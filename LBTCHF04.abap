***INCLUDE LBTCHF04 .

************************************************************************
* Hilfsroutinen des Funktionsbaustein BP_EVENTID_EDITOR                *
************************************************************************

*---------------------------------------------------------------------*
*       FORM READ_EVTIDTBL                                            *
*---------------------------------------------------------------------*
*  Lesen der DB-Tabelle BTCSEV bzw. BTCUEV abhängig vom gerade aktu-  *
*  Listenverarbeitungskontext ( Systemid- bzw. Usereventidverarb.).   *
*  Da BTCSEV / BTCUEV von der gleichen Struktur sind, wird nur eine   *
*  interne Tabelle benötigt ( BTCEVTID_TBL ) auf der die Anzeige-     *
*  bzw. Pflegefunktionen operieren um die Liste von EventIds zu er-   *
*  stellen. Ebenfalls eingelesen wird die entsprechende Dokumen-      *
*  tationstabelle BTCSED bzw. BTCUED                                  *
*---------------------------------------------------------------------*

FORM READ_EVTIDTBL.

   FREE BTCEVTID_TBL.
   FREE BTCEVTDESCR_TBL.

   IF LIST_PROCESSING_CONTEXT EQ BTC_EDIT_SYSTEM_EVENTIDS OR
      LIST_PROCESSING_CONTEXT EQ BTC_SHOW_SYSTEM_EVENTIDS.
*
*  SystemeventIds mit sprachabhängigen Kommentaren einlesen
*
      SELECT * FROM BTCSEV INTO TABLE BTCEVTID_TBL
               ORDER BY PRIMARY KEY.

      IF SY-SUBRC EQ 0.
         BTCEVTID_ENTRIES = SY-DBCNT.

         SELECT * FROM BTCSED INTO TABLE BTCEVTDESCR_TBL
                  WHERE LANGUAGE EQ SY-LANGU
                  AND   EVENTID LIKE '%'
                  ORDER BY PRIMARY KEY.
      ELSE.
        BTCEVTID_ENTRIES = 0.
      ENDIF.
   ELSE.
*
*  UsereventIds mit sprachabhängigen Kommentaren einlesen
*
      SELECT * FROM BTCUEV INTO TABLE BTCEVTID_TBL
               ORDER BY PRIMARY KEY.

      IF SY-SUBRC EQ 0.
         BTCEVTID_ENTRIES = SY-DBCNT.

         SELECT * FROM BTCUED INTO TABLE BTCEVTDESCR_TBL
                  WHERE LANGUAGE EQ SY-LANGU
                  AND   EVENTID LIKE '%'
                  ORDER BY PRIMARY KEY.
      ELSE.
         BTCEVTID_ENTRIES = 0.
      ENDIF.
   ENDIF.

ENDFORM. " READ_EVTID_TABLE

*---------------------------------------------------------------------*
*       FORM GET_EVENTID_DESCRIPT                                     *
*---------------------------------------------------------------------*
*  zu einer vorgegebenen EventId wird versucht aus der internen       *
*  Tabelle BTCEVTDESCR_TBL die zugehörige sprachabhängige Beschreibung*
*  zu lesen um diese dem Caller zur Verfügung zu stellen.             *
*  Wird keine Beschreibung gefunden, so wird der Rückgabeparameter    *
*  DESCRIPTION mit SPACE gefüllt.                                     *
*---------------------------------------------------------------------*

FORM GET_EVENTID_DESCRIPT USING EVENT_ID DESCRIPTION.

   BTCEVTDESCR_TBL = SPACE.
   BTCEVTDESCR_TBL-EVENTID  = EVENT_ID.
   BTCEVTDESCR_TBL-LANGUAGE = SY-LANGU.

   READ TABLE BTCEVTDESCR_TBL.

   IF SY-SUBRC EQ 0.
      DESCRIPTION = BTCEVTDESCR_TBL-DESCRIPT.
   ELSE.
      DESCRIPTION = SPACE.
   ENDIF.

   append btcevtdescr_tbl.

ENDFORM. " GET_EVENTID_DESCRIPT USING

*---------------------------------------------------------------------*
*      FORM CHECK_SELECT_1080                                         *
*---------------------------------------------------------------------*
*  Prüfen der Verarbeitungsauswahl auf Dynpro 1080 (Einstiegsdynpro   *
*  Transaktion SM62 - Anzeigen / Pflegen EventIds)                    *
*---------------------------------------------------------------------*

FORM CHECK_SELECT_1080.

  NUM_SPEC = 0.

  IF BTCH1080-SHOW_SYSEV EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF BTCH1080-EDIT_SYSEV EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF BTCH1080-SHOW_USREV EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF BTCH1080-EDIT_USREV EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF NUM_SPEC EQ 0.
     MESSAGE E010.
  ENDIF.

  IF NUM_SPEC > 1.
     MESSAGE E011.
  ENDIF.

ENDFORM. " CHECK_SELECT_1080.

*---------------------------------------------------------------------*
*      FORM SET_CHOICE_1080                                           *
*---------------------------------------------------------------------*
*  "Anknipsen" eines Verarbeitungsmodus auf Dynpro 1080 ( Einstieg in *
*   Transaktion SM62 - Pflegen von Eventids)                          *
*---------------------------------------------------------------------*

FORM SET_CHOICE_1080 USING CHOICE.

  BTCH1080-SHOW_SYSEV = SPACE.
  BTCH1080-EDIT_SYSEV = SPACE.
  BTCH1080-SHOW_USREV = SPACE.
  BTCH1080-EDIT_USREV = SPACE.

  CLEAR REQUESTED_ACTION.

  CASE CHOICE.
    WHEN 'BTCH1080-EDIT_SYSEV'.
      BTCH1080-EDIT_SYSEV = 'X'.
      REQUESTED_ACTION = BTC_EDIT_SYSTEM_EVENTIDS.
    WHEN 'BTCH1080-SHOW_SYSEV'.
      BTCH1080-SHOW_SYSEV = 'X'.
      REQUESTED_ACTION = BTC_SHOW_SYSTEM_EVENTIDS.
    WHEN 'BTCH1080-EDIT_USREV'.
      BTCH1080-EDIT_USREV = 'X'.
      REQUESTED_ACTION = BTC_EDIT_USER_EVENTIDS.
    WHEN 'BTCH1080-SHOW_USREV'.
      BTCH1080-SHOW_USREV = 'X'.
      REQUESTED_ACTION = BTC_SHOW_USER_EVENTIDS.
  ENDCASE.

  IF NOT ( REQUESTED_ACTION IS INITIAL ).
     CALL FUNCTION 'BP_EVENTID_EDITOR'
                   EXPORTING  OPCODE = REQUESTED_ACTION
                   EXCEPTIONS OTHERS = 99.
  ENDIF.

ENDFORM. " SET_CHOICE_1080
