***INCLUDE LBTCHF06 .
*

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_BTCCTL_EDITOR                *
************************************************************************

*---------------------------------------------------------------------*
*       FORM READ_BTCCTL_TABLE                                        *
*---------------------------------------------------------------------*
*  Lesen der DB-Tabelle BTCCTL in die interne Tabelle BTCCTL_TBL      *
*---------------------------------------------------------------------*

FORM READ_BTCCTL_TABLE.

   FREE BTCCTL_TBL.

   SELECT * FROM BTCCTL INTO TABLE BTCCTL_TBL ORDER BY PRIMARY KEY.

   IF SY-SUBRC EQ 0.
      BTCCTL_ENTRIES = SY-DBCNT.
   ELSE.
      BTCCTL_ENTRIES = 0.
   ENDIF.

ENDFORM. " READ_BTCCTL_TABLE

*---------------------------------------------------------------------*
*      FORM SET_SELECTION_1030                                        *
*---------------------------------------------------------------------*
*  "Anknipsen" von Perationsmodus- bzw. Tracelevelauswahl auf Dynpro  *
*  1030 mit der Maus (Anlegen bzw. Editieren eines BTCCTL-Eintrages)  *
*---------------------------------------------------------------------*

FORM SET_SELECTION_1030.
* so tun, als ob Daten eingegeben wurden
  SY-DATAR = 'X'.  "#EC WRITE_OK


  GET CURSOR FIELD FIELDNAME.

  CASE FIELDNAME.
    WHEN 'BTCH1030-TRCOFF'.
      PERFORM SET_TRCLVL_1030 USING FIELDNAME.
    WHEN 'BTCH1030-TRCLVL1'.
      PERFORM SET_TRCLVL_1030 USING FIELDNAME.
    WHEN 'BTCH1030-TRCLVL2'.
      PERFORM SET_TRCLVL_1030 USING FIELDNAME.
    WHEN 'BTCH1030-TRCPERMAN'.
      PERFORM SET_TRCLVL_ACT_1030 USING FIELDNAME.
    WHEN 'BTCH1030-TRCONCE'.
      PERFORM SET_TRCLVL_ACT_1030 USING FIELDNAME.
    WHEN 'BTCH1030-OPMODACT'.
      PERFORM SET_OPMODE_1030 USING FIELDNAME.
    WHEN 'BTCH1030-OPMODDEACT'.
      PERFORM SET_OPMODE_1030 USING FIELDNAME.
    WHEN 'BTCH1030-OPMODSIMUL'.
      PERFORM SET_OPMODE_1030 USING FIELDNAME.
    WHEN OTHERS.
      CLEAR SY-DATAR.  "#EC WRITE_OK
  ENDCASE.

  IF SY-DATAR EQ 'X'.
     BTCCTL_ENTRY_MODIFIED = TRUE.
  ENDIF.

ENDFORM. " SET_SELECTION_1030

*---------------------------------------------------------------------*
*      FORM CHECK_SELECT_1030                                         *
*---------------------------------------------------------------------*
*  Prüfen der Tracelevel- und Operationsmodusauswahl auf Dynpro 1030  *
*  (Anlegen / Editieren eines BTCCTL-Eintrages)                       *
*---------------------------------------------------------------------*

FORM CHECK_SELECT_1030.

*
*  Auswahl des Operationsmodus prüfen
*
   NUM_SPEC = 0.

   IF BTCH1030-OPMODACT EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF BTCH1030-OPMODDEACT EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF BTCH1030-OPMODSIMUL EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF NUM_SPEC EQ 0.
      MESSAGE E012.
   ENDIF.

   IF NUM_SPEC > 1.
      MESSAGE E013.
   ENDIF.
*
*  Auswahl des Tracelevels prüfen
*
   NUM_SPEC = 0.

   IF BTCH1030-TRCOFF EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF BTCH1030-TRCLVL1 EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF BTCH1030-TRCLVL2 EQ 'X'.
      NUM_SPEC = NUM_SPEC + 1.
   ENDIF.

   IF NUM_SPEC EQ 0.
      MESSAGE E014.
   ENDIF.

   IF NUM_SPEC > 1.
      MESSAGE E015.
   ENDIF.
*
*  Auswahl der Traceaktivierungsart (einmalig / permanent) überprüfen,
*  falls ein Tracelevel aktiviert wurde
*
   IF BTCH1030-TRCOFF NE 'X'.
      NUM_SPEC = 0.

      IF BTCH1030-TRCPERMAN EQ 'X'.
         NUM_SPEC = NUM_SPEC + 1.
      ENDIF.

      IF BTCH1030-TRCONCE EQ 'X'.
         NUM_SPEC = NUM_SPEC + 1.
      ENDIF.

      IF NUM_SPEC > 1.
         MESSAGE E018.
      ENDIF.
   ENDIF.

ENDFORM. " CHECK_SELECT_1030

*---------------------------------------------------------------------*
*      FORM SET_TRCLVL_1030                                           *
*---------------------------------------------------------------------*
*  "Anknipsen" eines Tracelevels auf Dynpro 1030 ( Anlegen / Editier- *
*  en eines BTCCTL-Eintrages) mittels Maus                            *
*---------------------------------------------------------------------*

FORM SET_TRCLVL_1030 USING TRC_LEVEL.

  BTCH1030-TRCOFF    = SPACE.
  BTCH1030-TRCLVL1   = SPACE.
  BTCH1030-TRCLVL2   = SPACE.

  CASE TRC_LEVEL.
    WHEN 'BTCH1030-TRCOFF'.
      BTCH1030-TRCOFF = 'X'.
    WHEN 'BTCH1030-TRCLVL1'.
      BTCH1030-TRCLVL1 = 'X'.
    WHEN 'BTCH1030-TRCLVL2'.
      BTCH1030-TRCLVL2 = 'X'.
  ENDCASE.

ENDFORM. " SET_TRCLVL_1030

*---------------------------------------------------------------------*
*      FORM SET_TRCLVL_ACT_1030                                       *
*---------------------------------------------------------------------*
*  "Anknipsen" einer Tracelevelaktivierungsart auf Dynpro 1030        *
*  ( Anlegen / Editieren eines BTCCTL-Eintrages) mittels Maus         *
*---------------------------------------------------------------------*

FORM SET_TRCLVL_ACT_1030 USING TRC_ACT.

  BTCH1030-TRCPERMAN = SPACE.
  BTCH1030-TRCONCE   = SPACE.

  CASE TRC_ACT.
    WHEN 'BTCH1030-TRCPERMAN'.
      BTCH1030-TRCPERMAN = 'X'.
    WHEN 'BTCH1030-TRCONCE'.
      BTCH1030-TRCONCE = 'X'.
  ENDCASE.

ENDFORM. " SET_TRCLVL_ACT_1030

*---------------------------------------------------------------------*
*      FORM SET_OPMODE_1030                                           *
*---------------------------------------------------------------------*
*  "Anknipsen" eines Operationsmodus auf Dynpro 1030 (Anlegen / Edi-  *
*  tieren einess BTCCTL-Eintrages) mittels Maus                       *
*---------------------------------------------------------------------*

FORM SET_OPMODE_1030 USING OP_MODE.

  BTCH1030-OPMODACT   = SPACE.
  BTCH1030-OPMODDEACT = SPACE.
  BTCH1030-OPMODSIMUL = SPACE.

  CASE OP_MODE.
    WHEN 'BTCH1030-OPMODACT'.
      BTCH1030-OPMODACT = 'X'.
    WHEN 'BTCH1030-OPMODDEACT'.
      BTCH1030-OPMODDEACT = 'X'.
    WHEN 'BTCH1030-OPMODSIMUL'.
      BTCH1030-OPMODSIMUL = 'X'.
  ENDCASE.

ENDFORM. " SET_OPMODE_1030

*---------------------------------------------------------------------*
*      FORM CHECK_SELECT_1050                                         *
*---------------------------------------------------------------------*
*  Prüfen der Verarbeitungsauswahl auf Dynpro 1050 (Einstiegsdynpro   *
*  Transaktion SM61 - Pflege Tabelle BTCCTL)                          *
*---------------------------------------------------------------------*

FORM CHECK_SELECT_1050.

  NUM_SPEC = 0.

  IF BTCH1050-SHOW EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF BTCH1050-EDIT EQ 'X'.
     NUM_SPEC = NUM_SPEC + 1.
  ENDIF.

  IF NUM_SPEC EQ 0.
     MESSAGE E010.
  ENDIF.

  IF NUM_SPEC > 1.
     MESSAGE E011.
  ENDIF.

ENDFORM. " CHECK_SELECT_1050.

*---------------------------------------------------------------------*
*      FORM SET_CHOICE_1050                                           *
*---------------------------------------------------------------------*
*  "Anknipsen" eines Verarbeitungsmodus auf Dynpro 1050 ( Einstieg in *
*   Transaktion SM61 - Pflege Tabelle BTCCTL)                         *
*---------------------------------------------------------------------*

FORM SET_CHOICE_1050 USING CHOICE.

  BTCH1050-EDIT = SPACE.
  BTCH1050-SHOW = SPACE.

  CASE CHOICE.
    WHEN 'BTCH1050-SHOW'.
      BTCH1050-SHOW = 'X'.
      CALL FUNCTION 'BP_BTCCTL_EDITOR'
                     EXPORTING OPCODE  = BTC_SHOW_BTCCTL_TBL
                     EXCEPTIONS OTHERS = 99.
    WHEN 'BTCH1050-EDIT'.
      BTCH1050-EDIT = 'X'.
      CALL FUNCTION 'BP_BTCCTL_EDITOR'
                     EXPORTING OPCODE  = BTC_EDIT_BTCCTL_TBL
                     EXCEPTIONS OTHERS = 99.
  ENDCASE.

ENDFORM. " SET_CHOICE_1050

*---------------------------------------------------------------------*
*      FORM GET_BTCCTL_OBJTXT                                         *
*---------------------------------------------------------------------*
*  Zu einer BTCCTTL Objekt-Id wird der zugehörige Text zurückgeliefert*
*---------------------------------------------------------------------*

FORM GET_BTCCTL_OBJTXT USING OBJID OBJTXT.

  CASE OBJID.
    WHEN BTC_OBJ_TIME_BASED_SDL.
      OBJTXT = TEXT-335.
    WHEN BTC_OBJ_EVT_BASED_SDL.
      OBJTXT = TEXT-336.
    WHEN BTC_OBJ_JOB_START.
      OBJTXT = TEXT-337.
    WHEN BTC_OBJ_ZOMBIE_CLEANUP.
      OBJTXT = TEXT-338.
    WHEN BTC_OBJ_EXTERNAL_PROGRAM.
      OBJTXT = TEXT-339.
    WHEN BTC_OBJ_AUTO_DEL.
      OBJTXT = TEXT-340.
    WHEN BTC_OBJ_OPMODE.
      OBJTXT = TEXT-341.
    WHEN OTHERS.
      OBJTXT = OBJID.
  ENDCASE.

ENDFORM. " GET_BTCCTL_OBJTXT

*---------------------------------------------------------------------*
*      FORM GET_BTCCTL_OBJID                                          *
*---------------------------------------------------------------------*
*  Zu einem BTCCTTL Objekt-Text wird die zugehrige Objekt-Id zurück-  *
*  geliefert.                                                         *
*---------------------------------------------------------------------*

FORM GET_BTCCTL_OBJID USING OBJTXT OBJID.

  CASE OBJTXT.
    WHEN TEXT-335.
      OBJID = BTC_OBJ_TIME_BASED_SDL.
    WHEN TEXT-336.
      OBJID = BTC_OBJ_EVT_BASED_SDL.
    WHEN TEXT-337.
      OBJID = BTC_OBJ_JOB_START.
    WHEN TEXT-338.
      OBJID = BTC_OBJ_ZOMBIE_CLEANUP.
    WHEN TEXT-339.
      OBJID = BTC_OBJ_EXTERNAL_PROGRAM.
    WHEN TEXT-340.
      OBJID = BTC_OBJ_AUTO_DEL.
    WHEN TEXT-341.
      OBJID = BTC_OBJ_OPMODE.
    WHEN OTHERS.
      CLEAR OBJID.
  ENDCASE.

ENDFORM. " GET_BTCCTL_OBJID

*---------------------------------------------------------------------*
*      FORM PROCESS_BTCCTL_ENTRY                                 *
*---------------------------------------------------------------------*
*  Anzeigen bzw. Editieren eines BTCCTL-Eintrags (der Eintrag ist     *
*  durch die globale Variable LIST_ROW_INDEX bestimmt) abhängig       *
*  vom übergebenen Parameter HOW                                      *
*---------------------------------------------------------------------*

FORM PROCESS_BTCCTL_ENTRY USING HOW.

  READ TABLE BTCCTL_TBL INDEX LIST_ROW_INDEX.

  IF SY-SUBRC NE 0.
     MESSAGE E044.
  ENDIF.

  CLEAR BTCH1030.
  BTCH1030-BTCSERVER = BTCCTL_TBL-BTCSERVER.

  PERFORM GET_BTCCTL_OBJTXT USING BTCCTL_TBL-CTLOBJ
                                  BTCH1030-CTLOBJ.
  CASE BTCCTL_TBL-TRACELEVEL.
    WHEN BTC_TRACE_LEVEL0.
       BTCH1030-TRCOFF = 'X'.
    WHEN BTC_TRACE_LEVEL1.
       BTCH1030-TRCLVL1 = 'X'.
       BTCH1030-TRCPERMAN = 'X'.
    WHEN BTC_TRACE_LEVEL2.
       BTCH1030-TRCLVL2 = 'X'.
       BTCH1030-TRCPERMAN = 'X'.
    WHEN BTC_TRACE_SINGLE1.
       BTCH1030-TRCLVL1 = 'X'.
       BTCH1030-TRCONCE = 'X'.
    WHEN BTC_TRACE_SINGLE2.
       BTCH1030-TRCLVL2 = 'X'.
       BTCH1030-TRCONCE = 'X'.
  ENDCASE.

  CASE BTCCTL_TBL-OPMODE.
    WHEN BTC_MODE_ACTIVATED.
      BTCH1030-OPMODACT = 'X'.
    WHEN BTC_MODE_DEACTIVATED.
      BTCH1030-OPMODDEACT = 'X'.
    WHEN BTC_MODE_SIMULATION.
      BTCH1030-OPMODSIMUL = 'X'.
  ENDCASE.

  IF HOW EQ 'EDIT'.
     BTCH1030-OLDTRCLVL = BTCCTL_TBL-TRACELEVEL.
     BTCH1030-OLDOPMODE = BTCCTL_TBL-OPMODE.
     EDIT_MODUS = 'EDIT'.
  ELSE.
     EDIT_MODUS = 'SHOW'.
  ENDIF.

  CALL SCREEN 1030 STARTING AT 12 2
                   ENDING   AT 59 23.

ENDFORM. " PROCESS_BTCCTL_ENTRY
