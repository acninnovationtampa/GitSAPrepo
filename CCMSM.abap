TYPE-POOL CCMSM .

TYPES:
*
* Name eines MT ( SYSID\MCNAME\...\OBJECT\ATTRIBUT )
*
  CCMSM_MT_NAME TYPE ALMTNAME,
*
* Typ eines MT ( real / virtuell )
*
  CCMSM_MT_TYPE(1) TYPE C,
*
* Tabellen von TIDs
*
  CCMSM_TID_TBL LIKE ALGLOBTID OCCURS 0,
*
* Typ für Abbildung TID <--> Longname eines MT
*
  CCMSM_MT_LNAME           LIKE ALMTNAME_L,
  CCMSM_MT_LNAME_TBL       TYPE CCMSM_MT_LNAME OCCURS 0,
  CCMSM_TID_LNAME_INFO     LIKE ALGTIDLNRC,
  CCMSM_TID_LNAME_INFO_TBL TYPE CCMSM_TID_LNAME_INFO OCCURS 0,
*
* Typ für Abbildung TID <--> MT-Name
*
  BEGIN OF CCMSM_TID_MT_NAME_INFO,
    TID       LIKE ALGLOBTID,
    MT_NAME   TYPE CCMSM_MT_NAME,
    VALUNIT   TYPE ALUNIT,
  END OF CCMSM_TID_MT_NAME_INFO,

  CCMSM_TID_MT_NAME_INFO_TBL TYPE CCMSM_TID_MT_NAME_INFO OCCURS 0,
*
* Typ einer Zeile / Tabelle für den Warnungtexte des Fubst.
* SALM_MT_INVALID_ACTION_WARNING
*
  CCMSM_WARNING_TEXT_LINE(80) TYPE C,
  CCMSM_WARNING_TEXT_TBL TYPE CCMSM_WARNING_TEXT_LINE OCCURS 0,
*
* MT-Treeknoten und MT-Treetabelle
*
  CCMSM_MT_TREE_NODE LIKE ALMTTRNODE,
  CCMSM_MT_TREE      TYPE CCMSM_MT_TREE_NODE OCCURS 0,

  BEGIN OF CCMSM_MT_TREE_INFO,
     TID_LNAME TYPE CCMSM_TID_LNAME_INFO,
     TREE      TYPE CCMSM_MT_TREE,
  END OF CCMSM_MT_TREE_INFO,

  CCMSM_MT_TREE_TBL TYPE CCMSM_MT_TREE_INFO OCCURS 0,
*
* Name eines Monitors / Tabelle von Monitornamen
*
  CCMSM_MONITOR_NAME     LIKE SALM2010-MONINAME,
  CCMSM_MONITOR_NAME_TBL TYPE CCMSM_MONITOR_NAME OCCURS 0,
*
* Typen für die Beschreibung / Bearbeitung einer Monitordefinition (MD):
*
*    - Operationsmode des Editors für den Knoten einer MD
*    - Knotentyp  ( virt. Summary, Regel, phys. MTE )
*    - Knotenname
*    - Attribute eines realen MTE-Knotens
*    - Attribute eines Hilfsknotens für Präsentationszwecke
*    - Knotenregel
*    - Knoten eines Monitordefinitonsbaumes
*    - Tabelle zur Speicherung einer Monitordefinition
*    - Tabelle von Monitoren mit ihren Monitordefinitionen
*
  CCMSM_EDITOR_OPMODE(1)     TYPE C,
  CCMSM_MONIDEF_NODE_TYPE(1) TYPE C,
  CCMSM_MONIDEF_NODE_NAME    TYPE ALMDNNAME,

  BEGIN OF CCMSM_MONIDEF_REALMTE,
     TID                  LIKE ALGLOBTID,
     SHORT_NAME           TYPE ALMTNAMESH,
     SHOWLONGNAME         LIKE ALTYPES-CHAR1,
     VIRT_PARENT_NODE_KEY TYPE I,
  END OF CCMSM_MONIDEF_REALMTE,

  BEGIN OF CCMSM_MONIDEF_SUPPORT_NODE,
     MTE_REPOS_AVAIL(1) TYPE C,
  END OF CCMSM_MONIDEF_SUPPORT_NODE,

  BEGIN OF CCMSM_MONIDEF_RULE,
     RULE_KEY     LIKE ALMDRULES-RULE_KEY,
     PAR1_NAME    LIKE SALM2133-PAR1_NAME,
     PAR1_VALUE   LIKE SALM2133-PAR1_VALUE,
     PAR2_NAME    LIKE SALM2133-PAR2_NAME,
     PAR2_VALUE   LIKE SALM2133-PAR2_VALUE,
     PAR3_NAME    LIKE SALM2133-PAR3_NAME,
     PAR3_VALUE   LIKE SALM2133-PAR3_VALUE,
     PAR4_NAME    LIKE SALM2133-PAR4_NAME,
     PAR4_VALUE   LIKE SALM2133-PAR4_VALUE,
     SHVIRTSUM    LIKE SALM2133-SHVIRTSUM,
     SHOWLONGNAME LIKE ALTYPES-CHAR1,
  END OF CCMSM_MONIDEF_RULE,

  BEGIN OF CCMSM_MONITOR_DEFINITION_NODE,
     NODE_KEY           TYPE I,
     PARENT_KEY         TYPE I,
     LEVEL              TYPE I,
     NAME               TYPE CCMSM_MONIDEF_NODE_NAME,
     TYPE               TYPE CCMSM_MONIDEF_NODE_TYPE,
     REALMTE            TYPE CCMSM_MONIDEF_REALMTE,
     RULE               TYPE CCMSM_MONIDEF_RULE,
     PRES_SUPP_NODE     TYPE CCMSM_MONIDEF_SUPPORT_NODE,
     MARKED(1)          TYPE C,
     EXPAND(1)          TYPE C,
     HIGHLIGHT(1)       TYPE C,
  END OF CCMSM_MONITOR_DEFINITION_NODE,

  CCMSM_MONITOR_DEFINITION_TBL TYPE CCMSM_MONITOR_DEFINITION_NODE
                                    OCCURS 0,

  BEGIN OF CCMSM_MONITORDEF_DIR_ENTRY,
     MONITOR_NAME TYPE CCMSM_MONITOR_NAME,
     MONIDEF      TYPE CCMSM_MONITOR_DEFINITION_TBL,
  END OF CCMSM_MONITORDEF_DIR_ENTRY,

  CCMSM_MONITORDEF_DIR_TBL TYPE CCMSM_MONITORDEF_DIR_ENTRY OCCURS 0,
*
* Typen für die Beschreibung eines Monitortemplates
*
*    - Knotentyp  ( virt. Summary / phys. MTE )
*    - Knotenname
*    - Knoten eines Monitortemplatebaumes
*    - Tabelle zur Speicherung eines Monitortemplate
*
  CCMSM_MONITEMPL_NODE_TYPE TYPE ALTMPLNTYP,
  CCMSM_MONITEMPL_NODE_NAME TYPE ALTMPLNNAM,

  BEGIN OF CCMSM_MONITOR_TEMPLATE_NODE,
    TID             LIKE ALGLOBTID,
    NAME            TYPE CCMSM_MONITEMPL_NODE_NAME,
    TYPE            TYPE CCMSM_MONITEMPL_NODE_TYPE,
    SHOWLONGNAME    LIKE ALTYPES-CHAR1,
    NODE_INDEX      TYPE I,
    PARENT_INDEX    TYPE I,
    LEVEL           TYPE I,
  END OF CCMSM_MONITOR_TEMPLATE_NODE,

  CCMSM_MONITOR_TEMPLATE_TBL TYPE CCMSM_MONITOR_TEMPLATE_NODE OCCURS 0,
*
* Typ für die Beschreibung von Parametern eines Regelknotens
* in einer Monitordefinition
*
* BEGIN OF CCMSM_RULE_PARAM,               " up to Rel. 4.6B
*    PAR_NAME   LIKE SALM2133-PAR1_NAME,
*    PAR_VALUE  LIKE SALM2133-PAR1_VALUE,
* END OF CCMSM_RULE_PARAM,

  CCMSM_RULE_PARAM TYPE ALRLPARROW,        " since Rel. 4.6C

  CCMSM_RULE_PARAM_TBL TYPE ALRLPARTBL,
*
* Typ für die Prozessierung der F4-Hilfe für Regelparameterwerte
*
  CCMSM_RULE_PARAM_VALUE_F4_TBL LIKE ALRLPARF4 OCCURS 0,
*
* Ergebnisknoten eines Regelcallbacks einer Monitordefinition
*
  CCMSM_RULE_RESULT_NODE_TYPE(1) TYPE C,

  BEGIN OF CCMSM_RULE_CB_RESULT,
     NODE_NAME         TYPE CCMSM_MT_NAME,
     NODE_TYPE         TYPE CCMSM_MT_TYPE,
     TID               LIKE ALGLOBTID,
     PARAMS_TO_PASS_ON TYPE CCMSM_RULE_PARAM_TBL,
  END OF CCMSM_RULE_CB_RESULT,

  CCMSM_RULE_CB_RESULT_TBL TYPE CCMSM_RULE_CB_RESULT OCCURS 0,
*
* Fehlerinformation eines Regelcallbacks einer Monitordefinition
*
  BEGIN OF CCMSM_RULE_CB_ERROR_INFO,
    ERR_MSG_ID  LIKE SY-MSGID,
    ERR_MSG_NR  LIKE SY-MSGNO,
    ERR_PARAM1  LIKE SY-MSGV1,
    ERR_PARAM2  LIKE SY-MSGV2,
    ERR_PARAM3  LIKE SY-MSGV3,
    ERR_PARAM4  LIKE SY-MSGV4,
  END OF CCMSM_RULE_CB_ERROR_INFO,
*
* Name einer Monitorsammlung / Tabelle mit Namen von Monitorsammlungen
*
  CCMSM_MONISET_NAME     LIKE ALMONISETS-MONISET,
  CCMSM_MONISET_NAME_TBL TYPE CCMSM_MONISET_NAME OCCURS 0,
*
* Baumknoten eines Inhaltsverzeichnis von Monitorsammlungen
*
  BEGIN OF CCMSM_MONISET_DIR_NODE,
    ID                 TYPE I,         " Knoten-Id
    PARENT_ID          TYPE I,         " Id Parentknoten
    LEVEL              TYPE I,         " Knotenlevel im Baum
    NODE_NAME          TYPE CCMSM_MONISET_NAME, " Knotenname
    NODE_TYPE(1)       TYPE C,         " Überschrift / Monitor-
                                       " sammlung / Monitor
    MONISET            TYPE CCMSM_MONISET_NAME, " Name Monitorsammlung
    MONISET_TYPE(1)    TYPE C,         " Public / Privat / SAP
    MONISET_MODIF(1)   TYPE C,
    MONITOR_NR         TYPE I,         " Instanznummer Monitor
                                       " in Monitorsammlung
    OWNER              TYPE SY-UNAME,  " Eigner
    EXPAND(1)          TYPE C,         " Teilbaum ist expand.
  END OF CCMSM_MONISET_DIR_NODE,       " ja / nein
*
* Informationen zu einem MT ( Grunddaten / Alerts / MT-spezifische
* Daten )
*
* bei Änderung bitte auch die DDIC Typen ALMTDATATBL und ALMTDATA ändern
  BEGIN OF CCMSM_MT_DATA,
     TID                 LIKE ALGLOBTID,           " TID des MT-Knoten
     MT_NAME             TYPE CCMSM_MT_NAME,       " MT-Name
     BASE_DATA           TYPE CCMSM_MT_TREE_NODE,  " MT-Grunddaten
     SNGMSG_DATA         LIKE ALSMSGTYPE,          " Sngmsgdaten
     PERF_DATA           LIKE ALPERFTYPE,          " Performance-
     PERF_SMOOTH_DATA    LIKE ALGTIDSMO OCCURS 0,  " daten
     MSC_LINES           LIKE ALMSCTIDML OCCURS 0, " MSC-Zeilen
     MSC_DATA            LIKE ALMSCTYPE,           " MSC: Aktueller Wert
                                       " und Customizing
     AID_TBL             LIKE ALGLOBAID  OCCURS 0, " MT-Alertdaten
     SHOW_30MIN_PERFDAT  TYPE ALTYPES-CHAR1,       " Perf.-MTE: Optionen
     SHOW_15MIN_PERFDAT  TYPE ALTYPES-CHAR1,       " für Grafik-
     SHOW_24H_PERFDAT    TYPE ALTYPES-CHAR1,       " an-
     SHOW_PERF_DB_DAT    TYPE ALTYPES-CHAR1,       " zeige
     PERFHISTORY         TYPE ALPERFHIS  OCCURS 0, " anzuzeigende
     DISP_THESE_PERFHIST TYPE ALPERFHIS  OCCURS 0, " Historienwerte
     RC                  TYPE I,
  END OF CCMSM_MT_DATA,
*      = ALMTDATA
  CCMSM_MT_DATA_TBL TYPE CCMSM_MT_DATA OCCURS 0,
*      = ALMTDATATBL

  BEGIN OF CCMSM_MT_BASE_DATA_RC,
     TID        LIKE ALGLOBTID,
     BASE_DATA  TYPE CCMSM_MT_TREE_NODE,
     RC         TYPE I,
  END OF CCMSM_MT_BASE_DATA_RC,

  CCMSM_MT_BASE_DATA_RC_TBL TYPE CCMSM_MT_BASE_DATA_RC OCCURS 0,

  BEGIN OF CCMSM_SNGMSG_DATA_RC,
     TID          LIKE ALGLOBTID,
     SNGMSG_DATA  LIKE ALSMSGTYPE,
     RC           TYPE I,
  END OF CCMSM_SNGMSG_DATA_RC,

  CCMSM_SNGMSG_DATA_RC_TBL TYPE CCMSM_SNGMSG_DATA_RC OCCURS 0,

  BEGIN OF CCMSM_PERF_DATA_RC,
     TID       LIKE ALGLOBTID,
     PERF_DATA LIKE ALPERFTYPE,
     RC        TYPE I,
  END OF CCMSM_PERF_DATA_RC,

  CCMSM_PERF_DATA_RC_TBL TYPE CCMSM_PERF_DATA_RC OCCURS 0,

  BEGIN OF CCMSM_PERF_SMOOTH_DATA_RC,
     TID              LIKE ALGLOBTID,
     PERF_SMOOTH_DATA LIKE ALGTIDSMO OCCURS 0,
     RC               TYPE I,
  END OF CCMSM_PERF_SMOOTH_DATA_RC,

  CCMSM_PERF_SMOOTH_DATA_RC_TBL TYPE CCMSM_PERF_SMOOTH_DATA_RC OCCURS 0,

* Modus zur Auslösung von Alerts im Message Container
  BEGIN OF CCMSM_MSC_RAISE_ALERT_MODE,
     VALUE   LIKE ALMSCCUS-RAISEVALUE,
     SEVER   LIKE ALMSCCUS-RAISESEVER,
  END OF CCMSM_MSC_RAISE_ALERT_MODE,

* internes Format des Syslogfilter's analog zum DB format
  BEGIN OF CCMSM_MSC_INT_FILTER,
     LINENUMBER  LIKE  ALGRPMCFIL-LINENUMBER,
     FROMSGCLAS  LIKE  ALGRPMCFIL-FROMSGCLAS,
     FROMSGID    LIKE  ALGRPMCFIL-FROMSGID,
     TOMSGCLAS   LIKE  ALGRPMCFIL-TOMSGCLAS,
     TOMSGID     LIKE  ALGRPMCFIL-TOMSGID,
     MSGVALUE    LIKE  ALGRPMCFIL-MSGVALUE,
     SEVERITY    LIKE  ALGRPMCFIL-SEVERITY,
  END OF CCMSM_MSC_INT_FILTER,
*
* Zeitintervall bzw. Anzahl Minuten der anzuzeigenden MSC-Detaildaten
* bzw. Alertdaten
*
  BEGIN OF CCMSM_MSC_DISP_INTERVAL,
     FROM_UTC_TMSTMP TYPE ALTMSTPUTC,  " von Timestamp
     TO_UTC_TMSTMP   TYPE ALTMSTPUTC,  " bis Timestamp oder Alternativ:
     MSCDFLINTV      TYPE ALMSCDSPTM,  " letzten n Minuten
  END OF CCMSM_MSC_DISP_INTERVAL,
*
* Callbackroutinen für die Bearbeitung von MT-Bäumen
* ( nur SALM DB-Version 1 )
*
  BEGIN OF CCMSM_MT_TREE_REFRESH_CALLBACK,
    CBPROGRAM LIKE SY-REPID,
    CBFORM    LIKE SY-XFORM,
  END OF CCMSM_MT_TREE_REFRESH_CALLBACK,
*
* Callbackroutinen für die Bearbeitung von MT-Typen in MT-Bäumen
* ( nur SALM DB-Version 1 )
*
  BEGIN OF CCMSM_MT_CALLBACK,
    MTCLASS        LIKE ALGLOBTID-MTCLASS,
    CBPROGRAM      LIKE SY-REPID,
    CBFORM         LIKE SY-XFORM,
    BUTTONTEXT(20) TYPE C,
  END OF CCMSM_MT_CALLBACK,

  CCMSM_MT_CALLBACK_TBL TYPE CCMSM_MT_CALLBACK OCCURS 0,
*
* Beschreibung von Meßreihenkontexten für die Anzeige von Meßreihen
* von Performance-MT ( Fubst. SALM_MT_PERF_DATA_GRAPH_DISP )
*
  CCMSM_MT_SAMPLE_CONTEXT_NAME(120) TYPE C,

  BEGIN OF CCMSM_MT_SAMPLE_VALUE,
    X_VALUE(14) TYPE C,
    Y_VALUE     TYPE F,
    TIMESTAMP   TYPE P,
    SMOOTHCNT   TYPE I,
  END OF CCMSM_MT_SAMPLE_VALUE,

  CCMSM_MT_SAMPLE_VALUE_TBL TYPE CCMSM_MT_SAMPLE_VALUE OCCURS 0,

  BEGIN OF CCMSM_MT_SAMPLE_DATA,
    MT_NAME             TYPE CCMSM_MT_NAME,
    FIRSTDAY            TYPE ALDATE,   " für Anzeige von
    LASTDAY             TYPE ALDATE,   " Perf-DB-
    RECTYPE             TYPE ALPDBRTYP," Grafiken
    MT_VAL_UNIT(30)     TYPE C,
    VALUES_AVAILABLE(1) TYPE C,
    SECINACTIV          TYPE ALTIMSECS,
    VALUES              TYPE CCMSM_MT_SAMPLE_VALUE_TBL,
    RC                  TYPE I,
  END OF CCMSM_MT_SAMPLE_DATA,

  CCMSM_MT_SAMPLE_DATA_TBL TYPE CCMSM_MT_SAMPLE_DATA OCCURS 0,

  BEGIN OF CCMSM_MT_SAMPLE_CONTEXT,
    CONTEXT_NAME             TYPE CCMSM_MT_SAMPLE_CONTEXT_NAME,
    X_TICKS_DISTANCE_IN_SECS TYPE P,
    X_INTERVAL_START(14)     TYPE C,
    X_INTERVAL_END(14)       TYPE C,
    SAMPLES                  TYPE CCMSM_MT_SAMPLE_DATA_TBL,
  END OF CCMSM_MT_SAMPLE_CONTEXT,

  CCMSM_MT_SAMPLE_CONTEXT_TBL TYPE CCMSM_MT_SAMPLE_CONTEXT OCCURS 0,
*
* Typ der für die Information über das Refreshen von Listen verwendet
* wird
*
  CCMSM_LIST_REFRESH_FLAG(1) TYPE C,
*
* Typ der für die Information über das Ausführen einer bestimmten
* Aktion auf MT ( Fubst. SALM_MT_INVALID_ACTION_WARNING ) verwendet wird
*
  CCMSM_PERFORM_ACTION_FLAG(1) TYPE C,
*
* Typ der beim Fubst. SALM_INSTRUMENT_NAME_GET steuert, ob ein
* Instrumentenname vorgschlagen werden soll
*
  CCMSM_SUGGEST_NAME_FLAG(1) TYPE C,
*
* Typ mit dem festgelegt wird, welche Daten ( Grunddaten / Alerts )
* eines MT zu ermitteln sind
*
  CCMSM_DATA_GET_MODE(1) TYPE C,
*
* Typ mit dem festgelegt wird, ob Baumknoten, die zu einer bestimmten
* Klasse gehören markiert oder entmarkiert werden sollen ( Fubst.
* SALM_MT_CLASSES_MARK )
*
  CCMSM_MARKING_MODE(1) TYPE C,
*
* Typ für die Prozessierung der F4-Hilfe für Attributgruppen-Namen
*
  CCMSM_ATTR_GROUP_VALUE_F4_TBL TYPE TABLE OF ALATGRF4 INITIAL SIZE 0,
*
* Typ eines MT-Baumes ( Urinstanz, Instrument )
*
  CCMSM_MT_TREE_TYPE(1)  TYPE C,
*
* Uebergabestruktur (interne Tabelle) fuer FB. SALC_MT_GET_TREE,
* enthaelt neben Eingabe TID und RC fuer jede TID eine Ausgabetabelle
*
  BEGIN OF CCMSM_SALC_MT_TREE,
    TID  LIKE ALGLOBTID,
    RC   LIKE ALGTIDRC-RC,
    TREE LIKE ALMTTRE40B OCCURS 0,
  END OF CCMSM_SALC_MT_TREE,

  CCMSM_SALC_MT_TREE_TBL TYPE CCMSM_SALC_MT_TREE OCCURS 0,
*
* Uebergabestruktur (interne Tabelle) fuer FB. SALC_MT_GET_AID_BY_TID,
* enthaelt neben Eingabe TID und RC fuer jede TID eine Ausgabetabelle
*
* bei Änderung bitte auch die DDIC Typen ALTIDRCTIDAIDTBL und
* ALTIDRCTIDAID ändern
  BEGIN OF CCMSM_TID_RC_TIDAID,
    TID    LIKE ALGLOBTID,
    RC     LIKE ALGTIDRC-RC,
    TIDAID LIKE ALGTIDGAID OCCURS 0,
  END OF CCMSM_TID_RC_TIDAID,
*      = ALTIDRCTIDAID
  CCMSM_TID_RC_TIDAID_TBL TYPE CCMSM_TID_RC_TIDAID OCCURS 0,
*      = ALTIDRCTIDAIDTBL
*
* Uebergabestruktur (interne Tabelle) fuer FB. SALC_MT_READ_ALL,
* enthaelt neben Eingabe TID und RC fuer jede TID eine Ausgabetabelle
*
  BEGIN OF CCMSM_TID_RC_MSCLINE,
    TID    LIKE ALGLOBTID,
    RC     LIKE ALGTIDRC-RC,
    TIDMSCLINE LIKE ALMSCTIDML OCCURS 0,
  END OF CCMSM_TID_RC_MSCLINE,

  CCMSM_TID_RC_MSCLINE_TBL TYPE CCMSM_TID_RC_MSCLINE OCCURS 0,
*
* Übergabestruktur ( interne Tabelle ) für Fubst.
* SALM_MT_CLASS_MARKINGS_GET enthält MT-Klassennamen
*
  CCMSM_MT_CLASS_NAME_TBL LIKE ALMTYPEDEF-CUSGRPNAME OCCURS 0,
**********************************************************************
* Anzeigeoptionen eines Monitors
**********************************************************************
  CCMSM_MONITOR_DISPLAY_CONFIG LIKE ALMNDSPLC,

**********************************************************************
* Anzeigeoptionen einer Monitorsammlungung in der aktuellen DB-
* DB-Formatversion ( = '2' )
**********************************************************************
*
*   Achtung !
*
*   Wenn diese Struktur oder Elemente der Struktur geändert werden
*   dann muß:
*
*     - die aktuelle Formatversion erhöht werden
*     - die Fubst. SALM_MT_MONISET_READ_FROM_DB /
*       SALM_MT_MONISET_WRITE_TO_DB  müssen angepasst werden damit
*       'alte' in 'neue' Formatversionen konvertiert werden
*
  CCMSM_MT_DISPLAY_CONFIG LIKE ALSHTRCUV2,
**********************************************************************
* Konfigurationsdaten für die Darstellung des MT-Baumes, von MT-Detail-
* daten usw. in der DB-Formatversion ( = '1' )
**********************************************************************
  CCMSM_MT_DISPLAY_CONFIG_V1 LIKE ALSHTRCU,

**********************************************************************
* For Performance DB.   - Yue
**********************************************************************
  BEGIN OF CCMSM_PF_AGG_24,
    AGG_CONTROL LIKE ALAGGCTRC,
    AGG_DATA LIKE ALAGGDATA OCCURS 0,
  END OF CCMSM_PF_AGG_24,
  CCMSM_PF_AGG_24_TBL TYPE CCMSM_PF_AGG_24 OCCURS 0,

  BEGIN OF CCMSM_PF_TID_AGGS,
    TID LIKE ALGTIDRC,
    AGG_CTRL_DATA24 TYPE CCMSM_PF_AGG_24_TBL,
  END OF CCMSM_PF_TID_AGGS,
  CCMSM_PF_TID_AGGS_TBL TYPE CCMSM_PF_TID_AGGS OCCURS 0,
*-----------------------------------------------------------------

  BEGIN OF CCMSM_PF_TID_AGG,
    TID LIKE ALGLOBTID,
    AGG LIKE ALPERFCTCL OCCURS 0,
    RC TYPE ALRETCODE,
  END OF CCMSM_PF_TID_AGG,
  CCMSM_PF_TID_AGG_TBL TYPE CCMSM_PF_TID_AGG OCCURS 0,


*
* This type is use as return structure of SALR_MTE_GET_PERF_HISTORY_TBL
*
 BEGIN OF CCMSM_PF_TID_ALPERFHIS,
   TID LIKE ALGLOBTID,
   HIS_VALUES LIKE ALPERFHIS OCCURS 0,
   RC TYPE ALRETCODE,
 END OF CCMSM_PF_TID_ALPERFHIS,
 CCMSM_PF_TID_ALPERFHIS_TBL TYPE CCMSM_PF_TID_ALPERFHIS OCCURS 0.

 TYPES: BEGIN OF CCMSM_MT_MONITOR,
*
*   Achtung !
*
*   Wenn diese Struktur oder Elemente der Struktur geändert werden
*   dann muß:
*
*     - die aktuelle Formatversion erhöht werden
*     - der Fubst. SALM_MT_MONISET_READ_FROM_DB angepasst werden,
*       damit 'alte' Formatversionen in die neue Formatversion
*       konvertiert werden
*
    VISUAL_USER_LEVEL         TYPE  ALVISLVLRB,
    MONITOR_NR                TYPE  I,
    MONIDEF_TREE              TYPE  CCMSM_MONITOR_DEFINITION_TBL,
    MONITEMPL_TREE            TYPE  CCMSM_MONITOR_TEMPLATE_TBL,
    MT_TREE                   TYPE  CCMSM_MT_TREE,
    VISUALIZATION_MODE(1)     TYPE  C,
    MONITOR_NAME              TYPE  CCMSM_MONITOR_NAME,
    SLOT_IN_USE(1)            TYPE  C,
    LAST_TEMPL_GEN_TIMESTAMP  TYPE  ALTMSTPUTC,
    LAST_PRES_GEN_TIMESTAMP   TYPE  ALTMSTPUTC,
    MONIDEF_CHANGE_TIMESTAMP  TYPE  ALTMSTPUTC,
    MONIDEF_CHANGE_USER       LIKE  SY-UNAME,
  END OF CCMSM_MT_MONITOR,

  CCMSM_MT_MONITOR_TBL TYPE CCMSM_MT_MONITOR OCCURS 0.
