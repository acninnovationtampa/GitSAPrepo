FUNCTION-POOL btch MESSAGE-ID bt.

***********************************************************************
*                                                                     *
* Top-Include der Funktionsgruppe BTCH ( Hintergrundverarbeitung )    *
*                                                                     *
***********************************************************************

***********************************************************************
*
* Definitionen von funktionsgruppenübergreifenden Konstanten inkludieren
*
***********************************************************************
INCLUDE LBTCHDEF.   " Konstanten, Opcodes der BI-API-Funktionsbausteine
INCLUDE MS01CTC2.   " Konstanten der Berechtigungsprüfung
INCLUDE USER_CONSTANTS. "Constants for user-types
INCLUDE RSADMKEY.   " Konstanten für Konfigurationsabfragen von Servern
" ( ADM-Kommunikation )
INCLUDE %3CCNTN01%3E.   " Business Object Repository (Versenden Spoollisten)
INCLUDE RSALEXTI.                      " Anbindung an CCMS MONI
INCLUDE BPALDEFS.   " eigene Definitionen für Anbindung
INCLUDE %3CICON%3E.
INCLUDE RSCSMEXTI.  " Connect to the central system repository

INCLUDE WIZARDEF.                      " sm36wiz definition file
INCLUDE CTRLDEFN.                      " include for controls in BATCH
INCLUDE LBTCHCLS.                      " include classes
INCLUDE LBTCHREO.
INCLUDE LBTCHACC.   "Include for accessibility
* the following includes were moved from SAPLBTCH (WO)
INCLUDE RSBTCA2C . " Konstanten für batchspezifische Kernelfunktionen
INCLUDE RSXPGDEF . " Konstanten fuer das Anstarten externer Programme

INCLUDE RSXMIBAPI_MSG.
INCLUDE BTCOPT.

***********************************************************************
*
*  Tabellen
*
***********************************************************************
TABLES:
*
*       Datenbanktabellen
*
        tbtco,                         " Jobkopfdaten
        *tbtco,   " weiterer Arbeitsbereich für Jobkopfdaten
        tbtci,    " Verwaltungstabelle für "alte" Jobstruktur
        tbtcp,                         " Job-Steplisten-Tabelle
        tbtcs,                         " Batchscheduler-Steuertabelle
        btclog_cod, "der codierte Joblog ohne Datum/Uhrzeit
        btcctl,   " Steuertabelle mit Kontrollobjekten für die Hinter-
                                       " grundverarbeitung.
        btcsev,   " Prüftabelle für System-EventIds.
        btcuev,                        " Prüftabelle für User-EventIds.
        btcsed,   " Textliche Beschreibung von System-EventIds.
        btcued,   " Textliche Beschreibung von User-EventIds.
        btcevtjob," Liste der Jobs, die auf Events warten
        usr02,    " Tabelle mit allen definierten Usern
        trdir,                         " Tabelle mit Reportangaben
        vari,     " Variantentabelle des SAP-Systems
        btcdelay, " Steuertabelle für "verzögertes" Syslogschreiben
        tbtc5,                         " Joblog Ausgabeformat uncodiert
        tsp01,                         " Spool-Verwaltungstabelle
        spfba,                         " Beschreibung von Betriebsarten
        tfacd,                         " Fabrikkalender-Id's
        tfact,                         " Texte zu Fabrikkalender-Id's
* ein paar Tabellen für BP_JOBVARIANT_SCHEDULE/OVERVIEW (HW)
        d010sinf, " Tabelle aller Programme im System
        rsvar,    " Variantenstruktur - nur Feld VARIANT wird verwendet
        tbtcjob,  " Beschreibungsstruktur für Batchjobs
        varid,    " Beschreibungsstruktur für Reportvarianten
        varit,    " Beschreibungsstruktur fuer Variantenkurztexte
        favsels,  " user defined job selection favorite
* Zeitstatistiktabelle für Performanceanalyse

        btcjstat, " Tabelle mit der durchschnittlichen Laufzeit eines
                                       " eines Batchjobs
        btcselectp, " structure for powerful job selection
*
*       Dynprostrukturen
*
        btch1000, " komprimierte Batchjobstatusanzeige (alt)
        btch1010,                      " Starttermineingabe
        btch1011, " Starttermineingabe 'an Arbeitstag'
        btch1030, " Anzeigen / Editieren von BTCCTL-Feldern
        btch1040, " Anzeigen von BTCCTL Timestamps eines Objekts
        btch1050, " Einstieg SM61: Pflegetransaktion Tabelle BTCCTL
        btch1060, " Anzeige bzw. Pflege von Periodenwerten eines
                                       " Batchjobs.
        btch1080, " Einstieg SM62: Pflegetransaktion für Eventids
        btch1090, " Anzeigen / Editieren von System- bzw. UsereventIds
        btch1100, " Anzeigen des Actionlogs einer EventId
        btch1120, " Anzeigen / Editieren eines Steps
        btch1140, " Anzeigen / Editieren von Jobdaten
        btch1150,                      " Anzeigen von Jobdetaildaten
        btch1160, " Anzeigen / Editieren von Steuerflags ext. Programme
        btch1170, " Selektiondsdynpro für BP_JOB_SELECT
        btch1180, " Name des kopierten Jobs erfragen (BP_JOB_COPY)
        btch1190, " Anzeigen / Editieren von expliz. Periodenwerten
        btch1230, " komprimierte Batchjobstatusanzeige (neu)
        btch1250,                      " Event auslösen
        btch1260, " Periodenverhalten von Jobs an Nichtarbeitstagen
        btch1270, " Name des neuen Zielrechners eines Jobs erfragen
        btch1280,                      " Programme in Jobs suchen
        btch2000, " Einstieg Transaktion SBIT: BI-API-Testumgebung
        btch2010, " BP-API-Testumgebung Startterminangaben
        btch2020, " BP-API-Testumgebung Prüfung von EventIds
        btch2030, " BP-API-Testumgebung Steplisteneditor
        btch2040,                      " BP-API-Testumgebung Jobeditor
        btch2060, " BP-API-Testumgebung Kopieren von Jobs (BP_JOB_COPY)
        btch2080, " BP-API-Testumgebung Anzeigen Joblog (BP_JOBLOG_SHOW)
        btch2090, " BP-API-Testumgebung Joblistenprozessor
                                       " (BP_JOBLIST_PROCESSOR)
        btch2100, " BP-API-Testumgebung Jobs überwachen und steuern
                                       " (BP_JOB_MAINTENANCE)
        btch2110, " BP-API-Testumgebung Job löschen (BP_JOB_DELETE)
        btch2120, " BP-API-Testumgebung Joblog lesen (BP_JOBLOG_READ)
        btch2130, " BP-API-Testumgebung Selektieren von Jobs
                                       " (BP_JOB_SELECT)
        btch2170,
        btch3070, " powerful job selection main screen
        btch3071, " subscreen 1: starting time selection
        btch3072, " subscreen 2: entering active time selection
        btch3073, " subscreen 3: leaving active time selection
        btch3074, " subscreen 4: being active time selection
        btch3075,                      " subscreen 5: status selection
        btch3076, " subscreen 6: periodicity selection
        btch3077, " subscreen 7: ABAP step selection
        btch3090, " user defined job selection favorite
        btch4900. " Ask user for next system/client etc...

TYPES: where_type(255) TYPE c,
       db_field_type(20) TYPE c.
DATA p_where_tab TYPE TABLE OF where_type.
DATA: BEGIN OF where_line,
  line TYPE where_type,
END OF where_line.

DATA: old_period_text(16).
DATA: new_period_text(16).
DATA: recursive_call TYPE i VALUE 0.

*
*  Interne Tabellen
*
*  Tabelle, in die die DB-Tabelle BTCCTL zum Editiern bzw. Anzeigen
*  eingelesen wird
*
DATA BEGIN OF btcctl_tbl OCCURS 20.
        INCLUDE STRUCTURE btcctl.
DATA END OF btcctl_tbl.
*
*
*  Tabellen, in die die DB-Tabelle BTCSEV bzw. BTCUEV (System- bzw.
*  UsereventIds ) und die zugehörigen Dokutabellen BTCSED bzw. BTCUED
*  zur Bearbeitung eingelesen werden.
*
*
DATA BEGIN OF btcevtid_tbl OCCURS 20.
        INCLUDE STRUCTURE btcsev.
DATA END OF btcevtid_tbl.

DATA BEGIN OF btcevtdescr_tbl OCCURS 20.
        INCLUDE STRUCTURE btcsed.
DATA END OF btcevtdescr_tbl.
*
* Tabellen GLOBAL_STEP_TBL und GLOBAL_JOBLIST und Feldleisten GLOBAL_JOB
* und GLOBAL_START_DATE für das Abspeichern von Job-, Step- und Start-
* termindaten. Diese Bereiche werden sowohl für den Austausch von
* Daten zwischen den einzelnen Funktionsbausteinen als auch für das
* Testen der einzelnen Fubst. gebraucht. Ebenfalls wird eine globale
* Tabelle GLOBAL_JLG_TBL zur Anzeige von Joblogs angelegt
*
DATA BEGIN OF global_step_tbl OCCURS 10.
        INCLUDE STRUCTURE tbtcstep.
DATA END OF global_step_tbl.

DATA: global_step_tbl_entries TYPE i VALUE 0,
      global_step_tbl_index TYPE i VALUE 0.

DATA BEGIN OF global_job.
        INCLUDE STRUCTURE tbtcjob.
DATA END OF global_job.

DATA BEGIN OF global_job_list OCCURS 50.
        INCLUDE STRUCTURE tbtcjob.
DATA END OF global_job_list.

DATA BEGIN OF global_start_date.
        INCLUDE STRUCTURE tbtcstrt.
DATA END OF global_start_date.

DATA BEGIN OF global_jlg_tbl OCCURS 50.
        INCLUDE STRUCTURE tbtc5.
DATA END OF global_jlg_tbl.

DATA:
  global_joblogid LIKE tbtcjob-joblog,
  global_client   LIKE tbtcjob-authckman.
*
* Katalog der Varianten (Systeminfo)
*
DATA: BEGIN OF varcat OCCURS 20.
        INCLUDE STRUCTURE rvarc.
" DATA:   VARIANT(14),
"         ENVIRONMT,
"         PROTECTED,
"         VERSION,
"         ENAME(12),
"         EDAT TYPE D,
"         AENAME(12),
"         AEDAT TYPE D.
DATA END OF varcat.
*
* VARIANTENTEXTE (Systeminfo)
*
DATA: BEGIN OF varcatt OCCURS 20.
        INCLUDE STRUCTURE rvart.
" DATA:   SPRSL,
"         VARIANT(14),
"         VTEXT(30).
DATA END OF varcatt.
*
* eine aus VARCAT und VARCATT "zusammengebaute" Variantentabelle mit
* deren Hilfe ein Anwender eine Variante auswählen kann
*
DATA: BEGIN OF vari_tbl OCCURS 10,
         name       LIKE raldb-variant,
         text(30),
         aename     LIKE rvarc-aename,
         environmt  LIKE rvarc-environmt,
         protected  LIKE rvarc-protected,
      END OF vari_tbl.
*
*     Tabelle zur Zwischenspeicherung von Steplisten die an den
*     Funktionsbaustein BP_JOB_EDITOR übergeben werden
*
DATA BEGIN OF job_steplist_copy OCCURS 20.
        INCLUDE STRUCTURE tbtcstep.
DATA END OF job_steplist_copy.
*
*     Tabelle zur Zwischenspeicherung von Steplisten die an den
*     Funktionsbaustein BP_STEPLIST_EDITOR übergeben werden
*
DATA BEGIN OF steplist_copy OCCURS 20.
        INCLUDE STRUCTURE tbtcstep.
DATA END OF steplist_copy.
*
*  Tabelle der z.Zt. aktiven Batch-Systeme
*

* Liste der Rechner- und Servernamen
DATA BEGIN OF btc_sys_tbl OCCURS 10.
        INCLUDE STRUCTURE btctgtitbl.
DATA END OF btc_sys_tbl.

* Liste der Servernamen
DATA BEGIN OF btc_sys_srv_tbl OCCURS 10.
        INCLUDE STRUCTURE btctgtsrvr.
DATA END OF btc_sys_srv_tbl.


*data begin of btc_sys_host_tbl occurs 10.
*        include structure btctgthtbl.
*data end of btc_sys_host_tbl.

*
*  Betriebsarten- und Instanzenbeschreibungstabelle
*
DATA BEGIN OF ba_descr OCCURS 10.
        INCLUDE STRUCTURE spfba.
DATA END OF ba_descr.

DATA BEGIN OF inst_descr OCCURS 10.
        INCLUDE STRUCTURE spfid.
DATA END OF inst_descr.
*
*   Hilfsfelder zur Parameter-Uebergabe an Programm-Doku Anzeige
*   eines Programms
*
DATA BEGIN OF iline OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA END OF iline.

DATA: pgm_object LIKE dokhl-object.
*
* Hilfstabelle für PF4-Behandlung (Help) eines Dynprofeldes
*
DATA BEGIN OF field_tbl OCCURS 10.
        INCLUDE STRUCTURE help_value.
DATA END OF field_tbl.

DATA: fieldtbl LIKE dfies OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF dynpfields OCCURS 5.
        INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.

DATA: BEGIN OF command_tbl OCCURS 0.
        INCLUDE STRUCTURE sxpgcolist.
DATA: END OF command_tbl.
DATA: entered_extcmd LIKE btch1120-extcmdname.
*
* Tabelle zum Ausschliessen von Funktionen beim Setzen eines CUA-Status
*
DATA: BEGIN OF fcodes_to_exclude OCCURS 2,
      fcode(4),
      END OF fcodes_to_exclude.

*
*Number ranges for external job selection
*
RANGES ext_jobname_select_crit_str FOR tbtcjob-jobname.
RANGES ext_username_select_crit_str FOR tbtcjob-sdluname.
DATA: ext_jobname_select_crit LIKE TABLE
  OF ext_jobname_select_crit_str WITH HEADER LINE INITIAL SIZE 0.
DATA: ext_username_select_crit LIKE TABLE
  OF ext_username_select_crit_str WITH HEADER LINE INITIAL SIZE 0.


***********************************************************************
*
*  Feldsymbole
*
***********************************************************************

FIELD-SYMBOLS: <s>, <t>.

***********************************************************************
*
*  Feldleisten
*
***********************************************************************
*
*  Werte eines Vorgaenger-Jobs
*
DATA BEGIN OF pred_tbl OCCURS 20.
        INCLUDE STRUCTURE tbtco.
DATA END OF pred_tbl.

*
*  Druck- und Archiveparameter eines Users (Default / veränderte Werte)
*
DATA: BEGIN OF default_print_params.
        INCLUDE STRUCTURE pri_params.
DATA: END OF default_print_params.
DATA: BEGIN OF user_print_params.
        INCLUDE STRUCTURE pri_params.
DATA: END OF user_print_params.

DATA: BEGIN OF default_arc_params.
        INCLUDE STRUCTURE arc_params.
DATA: END OF default_arc_params.

DATA: BEGIN OF user_arc_params.
        INCLUDE STRUCTURE arc_params.
DATA: END OF user_arc_params.
*
* Hilfsvariable, in der sich der Fubst. BP_JOB_EDITOR die Starttermin-
* daten eines Jobs merkt (extrahiert aus Parameter JOB_HEAD_INPUT)
*
DATA: BEGIN OF job_stdt_input.
        INCLUDE STRUCTURE tbtcstrt.
DATA: END OF job_stdt_input.
*
* Hilfsvariable: Referenz für initiale Startterminwerte (BP_JOB_MODIFY)
*
DATA: BEGIN OF initial_stdt.
        INCLUDE STRUCTURE tbtcstrt.
DATA: END OF initial_stdt.

TYPES: BEGIN OF t_joblog.
TYPES:
  joblog   TYPE tbtco-joblog,
  client   TYPE symandt,
  jobname  TYPE btcjob,
  jobcount TYPE btcjobcnt,
  wpnum    TYPE btcwpno,
*  contents TYPE tt_joblog_contents,
END OF t_joblog.

DATA:
  g_joblog TYPE t_joblog.

*
* Hilfsvariable: Dynprodaten 1010 zwischenspeichern
* (BP_START_DATE_EDITOR)
*
DATA: BEGIN OF btch1010_tmp.
        INCLUDE STRUCTURE btch1010.
DATA: END OF btch1010_tmp.
***********************************************************************
*
*  globale Hilfsvariablen
*
***********************************************************************
* gemeinsames OKCODE-Feld fuer alle Dynpros
DATA: okcode LIKE sy-ucomm,
* Schalter fuer das Aktivieren / Deaktivieren von Feldattributen
* in einem Dynpro
      on(1)     VALUE '1',
      off(1)    VALUE '0',
* Bool'sche Werte TRUE und FALSE
      true      VALUE '1',
      false     VALUE '0',
*
* aktivierbare / deaktivierbare Feldattribute eines Dynpros
*
      intensified(1) VALUE 'I',
      required(1)    VALUE 'R',
      input(1)       VALUE 'Y',
      output(1)      VALUE 'O',
      invisible(1)   VALUE 'V',
      activate(1)    VALUE 'A',
*   Flag zur Anzeige wie der Starttermin eines Bacth-Jobs
*   spezifiziert wurde ( mögliche Werte befinden sich in LBTCHDEF)
      stdt_typ,
*   Flags zur Anzeige, ob Ausfuehrungs-Datum und Uhrzeit angegeben
*   wurde sowie deren Initialwerte
      exec_date_given,
      exec_time_given,
      no_date              LIKE  sy-datum        VALUE '        ',
      no_time              LIKE  sy-uzeit        VALUE '      ',
      zero_date            LIKE  sy-datum        VALUE '00000000',
      zero_time            LIKE  sy-uzeit        VALUE '000000',
* some ABAPs are bound to create class-A Jobs
      central_adk_abap(8) VALUE 'RSARDISP',
*   'leeres' Datum und 'leere' Zeit
      empty_date(10)       VALUE '--.--.----',
      empty_time(8)        VALUE '--:--:--',
*   'Ankreuzzähler' für die durch den Benutzer 'angekreuzten'
*   Auswahlmöglichkeiten
      num_spec             TYPE i,
*   Flag das anzeigt, ob Starttermindaten auf dem Dynpro 1010 bzw.
*   1060 eingegeben bzw. verändert wurden
      startdate_modified   LIKE true,
* Anzahl Tage pro Jahr (kein Schaltjahr) / Sekunden pro Tag
      days_per_year        TYPE i VALUE '365',
      sec_per_day          TYPE i VALUE '86400',
* Hilfsfeld fuer Uebergabeparameter, die in Modulen gebraucht werden
      fieldname(30),
* Felder für Event-Id und Event-Parameter
      event_id    LIKE btch1010-eventid,
* Steuerfelder für das Initialisieren des Dynpros 1010 (Starttermin)
      everything   VALUE  'X',
      not_immed    VALUE  'I',
      not_datetime VALUE  'D',
      not_eventid  VALUE  'E',
      not_predjob  VALUE  'P',
      not_prd_none VALUE  'X',
      not_prd_time VALUE  'T',
      not_prd_event VALUE 'Y',
* Hilfsfeld das anzeigt, ob innerhalb der Startterminverarbeitung
* 'nach Event' das Event vom Typ 'Betriebsartenumschaltung' aktiv ist.
* Dient der Steuerung des Dynpros 1010 ( Starttermineditor )
      stdt_oms_is_active  LIKE true,
* Konstante für das Event 'Betriebsartenumschaltung'
      oms_eventid LIKE btcsev-eventid VALUE 'SAP_OPMODE_SWITCH',
* Hilfsfeld für Returncodes von FORM-Routinen
      retcode,
* Returncode für FORM-Routinen
      ok    VALUE '0',
      error VALUE '1',
* Feld zum ein-/ausschalten des Debug-Modus
      debug VALUE '0',
* Feld zum Aufnehmen von Ja/Nein-Antworten in PopUps
      popup_answer,
* Hilfsfelder für Längen- und Offsetberechnung
      offset TYPE i,
      len    TYPE i,
* Feld mit dem entschieden wird, in welchem Kontext die Listverarbeitung
* stattfindet
      list_processing_context LIKE btch0000-int4 VALUE 0,
* wird eine feste Liste übergeben?
      stable_list LIKE btch0000-int4 VALUE 0,
* Titelzeile der festen Liste
      stable_title TYPE lvc_title,
* Anzahl Zeileneinträge in der Steuertabelle BTCCTL
      btcctl_entries    TYPE i VALUE '0',
* Positionen der Felder der Tabelle BTCCTL in einer Liste
      btcsystem_pos     TYPE i,
      ctlobj_pos        TYPE i,
      btcctl_tbl_width  TYPE i,
* Hilfsfeld, mit dem entschieden wird, ob die Zeilenauswahl in einer
* Liste gültig ist
      valid_row_selected,
*   Flag das anzeigt, ob ein BTCCTL-Eintrag auf Dynpro 1030
*   eingegeben bzw. verändert wurden
      btcctl_entry_modified,
* Verarbeitungsmdous für das Editieren der BTCCTL-Tabelle
* (neu anlegen / editieren )
      edit_modus(4),
* Verarbeitungsmdous für das Anzeigen / Editieren von Steuerflags
* externer Programme.
      xpgflags_edit_mode(4),
* Radiobutton-Anzeige
      radio_button VALUE '.',
* Aktuelle Seite und Kopfzeile einer Liste und aktuelle Cursorposition
      current_page      LIKE sy-cpage,
      current_head_row  LIKE sy-staro,
      current_row       LIKE sy-curow,
      current_col       LIKE sy-cucol,
* Feld zur Speicherung von BTCCTL-Objekttexten.
      ctlobjtxt LIKE btcctl-ctlobj,
* Feld zur Aufnahme von Summen
      sum TYPE i,
* Anzahl Zeileneinträge in den EventId-Tabellen BTCSEV bzw. BTCUEV
      btcevtid_entries TYPE i VALUE '0',
* Positionen der Felder der Tabelle BTCEVT in einer Liste
      eventid_pos         TYPE i VALUE '0',
      eventid_comment_pos TYPE i VALUE '0',
      eventid_list_width  TYPE i VALUE '0',
* Flag, das anzeigt, ob Eventdaten auf Dynpro 1090 verändert wurden
      eventid_modified,
* Prefix zur eindeutigen Kennzeichnung von SAP-SystemeventIds
      sap_sys_eventid_prefix(4) VALUE 'SAP_',
* Index einer Listzeile in zugehöriger internen Tabelle
      list_row_index LIKE sy-tabix,
* vom User auf einem Dynpro ausgewählte Verarbeitung
      requested_action LIKE btch0000-int4,
* Returncodes der Formroutine MOVE_INTTAB_ROW
      invalid_source_row   LIKE ok VALUE '1',
      invalid_after_row    LIKE ok VALUE '2',
      inttab_read_error    LIKE ok VALUE '3',
      inttab_insert_error  LIKE ok VALUE '4',
      inttab_delete_error  LIKE ok VALUE '6',
* Positionen und Länge der Spalten innerhalb der Steplistanzeige
      step_count_pos             TYPE i,
      step_pgmname_extract_pos   TYPE i,
      step_extpgm_pos            TYPE i,
      step_listexists_pos        TYPE i,
      step_status_pos            TYPE i,
      step_parameter_pos         TYPE i,
      step_user_pos              TYPE i,
      step_count_len             TYPE i,
      step_pgmname_extract_len   TYPE i,
      step_extpgm_len            TYPE i,
      step_listexists_len        TYPE i,
      step_status_len            TYPE i,
      step_parameter_extract_len TYPE i,
      step_list_width            TYPE i,
* Anzahl von Steplisteinträgen
      step_list_entries          TYPE i VALUE 0,
* Nächster freier Eintrag beim Editieren einer Stepliste
      next_free_steplist_entry   TYPE i VALUE 0,
* Flag, das anzeigt, ob Daten eines Stepeintrags auf Dynpro 1120
* eingegeben bzw. modifiziert worden sind
      stepentry_modified,
* Flag, das anzeigt, ob Steuerflags eines externen Programmes im
* Rahmen einer Stepdefinition auf Dynpro 1160 modifiziert worden sind
      xpgflags_modified,
* Fortsetzungszeichen für Listen
      continue_sign(3)           VALUE '...',
* Hilfsfeld für Programmname
      report_title                 LIKE raldb-report,
* interne Returncodes der Variantenprüfung
      report_has_syntax_error      TYPE i VALUE 1,
      generation_of_report_failed  TYPE i VALUE 2,
      report_has_no_variants       TYPE i VALUE 3,
      invalid_variant_name         TYPE i VALUE 4,
      couldnt_read_variant_catalog TYPE i VALUE 5,
      no_variants_defined          TYPE i VALUE 6,
      variant_selection_aborted    TYPE i VALUE 7,
      variant_name_missing         TYPE i VALUE 8,
* Positionen der einzelenen Felder einer Variantenliste
      variant_name_pos             TYPE i VALUE 0,
      variant_meaning_pos          TYPE i VALUE 0,
      variant_protected_pos        TYPE i VALUE 0,
      variant_modifier_pos         TYPE i VALUE 0,
      variant_name_len             TYPE i VALUE 14,
      variant_meaning_len          TYPE i VALUE 30,
      variant_protected_len        TYPE i VALUE 11,
* Anzahl Zeileneinträge in interner Tabeller VARI_TABL (Variantenliste)
      variant_list_entries         TYPE i VALUE 0,
* Breite einer Variantenliste
      variant_list_width           TYPE i VALUE 0,
* Feld zur Kennzeichnung, ob explizite Eingabe von ABAP- bzw. Externen
* Programmangaben auf Dynpro 1120 (Stepwerte) aktiv ist oder nicht
      abap_data_input,
      extcmd_data_input,
      extpgm_data_input,
* Felder,die fuer die Funktionen 'Markieren' und 'Verschieben' von
* Steps in einer Stepliste benoetigt werden ( BP_STEPLIST_EDITOR )
      steplist_row_to_move         TYPE i VALUE 0,
      steplist_target_row          TYPE i VALUE 0,
* Felder, in denen festgehalten wird, ob ein User Freigabe-/Batchadmini-
* strator- bzw. Early-Watch-Berechtigung hat
      release_privilege_given      LIKE btc_no,
      batch_admin_privilege_given  LIKE btc_no,
      early_watch_privilege_given  LIKE btc_no,
      batch_user_assign_privilege  LIKE btc_no,
* Flag, das anzeigt, ob Jobdaten auf Dynpro 1140 eingegeben bzw.
* verändert wurden
      jobdata_modified,
      recipient_modified,
* Returncodes der Benutzerprüfung ( FORM AUTH_CHECK_NAM )
      no_user_assign_privilege     TYPE i VALUE 1,
      invalid_username             TYPE i VALUE 2,
      bad_user_type                TYPE i VALUE 3,
* Returncodes der Zielrechnerprüfung ( CHECK_TARGET_HOST,
* ACQUIRE_DEFAULT_BTCHOST, GET_SRVNAME_FOR_JOB_EXEC und GET_BTC_SYSTEMS)
      tgt_host_chk_has_failed      TYPE i VALUE 1,
      no_batch_on_target_host      TYPE i VALUE 2,
      no_free_batch_wp_now         TYPE i VALUE 3,
      no_batch_server_found        TYPE i VALUE 4,
      target_host_not_defined      TYPE i VALUE 5,
      no_batch_wp_for_jobclass     TYPE i VALUE 6,
** Returncodes der start_job_immediately
*      rc_cannot_get_num_of_a_btcwps TYPE i VALUE 1,
*      rc_server_cannot_be_enqueued  TYPE i VALUE 2,
*      rc_no_free_btcwps             TYPE i VALUE 3,
*      rc_disp_queue_too_long        TYPE i VALUE 4,
*      rc_cannot_get_all_servers     TYPE i VALUE 5,
*      rc_tgt_host_chk_has_failed    TYPE i VALUE 6,
*      rc_cannot_read_server_group   TYPE i VALUE 7,
*      rc_job_cannot_be_started      TYPE i VALUE 8,
* Wildcard-Character für DB- und Enqueuefunktionen
      wildcard VALUE '*',
*     Jobgruppenflag, daß dem Batchscheduler anzeigt, daß ein Job
*     per Sofortausführung gestartet wurde. Wird gebraucht bei der
*     Einplanung von periodischen Jobs, deren Initiatorjob per Sofort-
*     ausführung gestartet wurde.
      immediate_flag(11)          VALUE '%_IMMEDIATE',
*     Flag, daß dem Batchscheduler anzeigt, daß es sich um einen Job
*     handelt, der mit der "neuen Form der Stepinformation" arbeitet
      newstep_flag LIKE tbtco-intreport VALUE '%NEWSTEP',
* Flag, daß anzeigt, in welchem Testmodus die BI-API-Testumgebung läuft
* und die zugehörigen, möglichen Flagwerte (wird benötigt für Dynpro-
* steuerung innerhalb der Testumgebung)
      job_test_mode(3),
      bp_job_edit(3)              VALUE 'JED',
      bp_job_create(3)            VALUE 'JCR',
      bp_job_modify(3)            VALUE 'JMO',
      bp_job_select(3)            VALUE 'JSL',
      bp_job_delete(3)            VALUE 'JDL',
      bp_job_read(3)              VALUE 'JRD',
      bp_job_checkstat(3)         VALUE 'JCS',
      bp_job_abort(3)             VALUE 'JAB',
      bp_joblog_read(3)           VALUE 'JLR',
* Flags, die von der Routine UPDATE_NUM_OF_SUCCJOBS benötigt werden
      increment                   VALUE 'I',
      decrement                   VALUE 'D',
* Flags, die für die Steuerung der Routine CHECK_TARGET_HOST benötigt
* werden
      check_for_immediate_start   VALUE 'I',
      check_for_defined_at_all    VALUE 'D',
* Returncodes der Formroutine CHECK_JOB_MODIFY_PRIVILEGE
      modification_not_possible LIKE btch0000-int4 VALUE 1,
      no_modif_privilege_given  LIKE btch0000-int4 VALUE 2,
      invalid_new_jobstatus     LIKE btch0000-int4 VALUE 3,
      cant_release_job          LIKE btch0000-int4 VALUE 4,
* Hilfsvariable für das Füllen der Titelzeile des Dynpros 1180
      name_of_job_to_copy LIKE tbtcjob-jobname,
* Variable die angibt, nach welchem Kriterium die Jobliste innerhalb
* des Funktionsbausteins BP_JOBLIST_PROCESSOR sortiert und die
* möglichen Werte:
     joblist_sort_criteria,
     btc_alphabetical   VALUE 'A',
     btc_chronological  VALUE 'C',
     btc_jobsbyclass    VALUE 'X',
     btc_jobsbyclient   VALUE 'Y',
     btc_jobsbytgtsys   VALUE 'T',
     btc_jobsbyexecsys  VALUE 'W',
* Variable die angibt, ob eine Jobliste neu zu sortieren ist
     joblist_sort_necessary LIKE true,
* Positionen und Länge der Spalten innerhalb der Joblistanzeige
     jnm_hdr_pos     TYPE i,
     jcl_hdr_pos     TYPE i,
     jcl_x_pos       TYPE i,
     sch_hdr_pos     TYPE i,
     sch_x_pos       TYPE i,
     rel_hdr_pos     TYPE i,
     rel_x_pos       TYPE i,
     rdy_hdr_pos     TYPE i,
     rdy_x_pos       TYPE i,
     run_hdr_pos     TYPE i,
     run_x_pos       TYPE i,
     fin_hdr_pos     TYPE i,
     fin_x_pos       TYPE i,
     abo_hdr_pos     TYPE i,
     abo_x_pos       TYPE i,
     jnm_hdr_len     TYPE i,
     jcl_hdr_len     TYPE i,
     sch_hdr_len     TYPE i,
     rel_hdr_len     TYPE i,
     rdy_hdr_len     TYPE i,
     run_hdr_len     TYPE i,
     fin_hdr_len     TYPE i,
     abo_hdr_len     TYPE i,
     joblist_width   TYPE i,
* Hilfsfeld für die Ausgabe von Zeitangaben in BP_JOB_MAINTENANCE
     59_min          TYPE i,
* Hilfsfeld für die Ausgabe von Ueberschriften (BP_JOB_MAINTENANCE)
     joblist_header(128),
* Hilfsfelder für das Identifizieren von Zeilen in einer Jobliste
* (BP_JOB_MAINTENANCE)
     jobname_selected  LIKE tbtcjob-jobname,
     jobcount_selected LIKE tbtcjob-jobcount,
* "Returncode" der Jobsteuerung- und Überwachung mit zulässigen Werten
     bp_job_maintenance_rc    TYPE i,
     job_maintenance_canceled TYPE i VALUE 1,
* "Returncode" der joblistspezifischen Anzeigenlistverarbeitung mit
* zulässigen Werten
     bp_joblist_proc_rc         TYPE i,
     joblist_processor_canceled TYPE i VALUE 1,
     joblist_is_empty           TYPE i VALUE 2,
* Anzahl von Jobs in einer Jobliste
     num_of_jobs_in_list        TYPE i,
*
* Variablen, die für die Steuerung der Blockverarbeitung innerhalb von
* BP_JOB_MAINTENANCE benötigt werden
*
     block_marking_is_active LIKE true,
     block_starts_at_row     TYPE i,
     block_ends_at_row       TYPE i,
* Positionen und Länge der Spalten innerhalb der Jobloganzeige und
* Breite der Jobloganzeige in Spalten
     dat_hdr_pos             TYPE i,
     tim_hdr_pos             TYPE i,
     mid_hdr_pos             TYPE i,
     msg_hdr_pos             TYPE i,
     mno_hdr_pos             TYPE i,
     mty_hdr_pos             TYPE i,
     joblog_list_width       TYPE i,
     msgid_ln                TYPE i,
     msgno_ln                TYPE i,
     msgty_ln                TYPE i,
* "Returncode" der joblogspezifischen Anzeigenlistverarbeitung mit
* zulässigen Werten
     bp_joblog_show_rc       TYPE i,
     joblog_show_canceled    TYPE i VALUE 1,
* Hilfsfeld für Gestaltung der Titelzeile Dynpro 1210 (Jobloganzeige)
     joblog_owner_name(43),
* Name der Transaktion für die Jobdefinition und Jobüberwachung
     jobdefinition_transaction LIKE sy-tcode VALUE 'SM36',
     jobmaintenance_transaction LIKE sy-tcode VALUE 'SM37',
     jobmaintenance_transaction_p LIKE sy-tcode VALUE 'SM37C',
     appserverlist_transaction LIKE sy-tcode VALUE 'SM51',
     workproclist_transaction LIKE sy-tcode VALUE 'SM50',
     jobwizard_transaction LIKE sy-tcode VALUE 'SM36WIZ',

* Hilfsfeld zur Uebergabe des CUA-Status an den Dialogbaustein
* `DISPLAY_VARIANT'
     displ_vari_cua(4),
* Hilfsfelder zur Parameter-Uebergabe an Fukntionsbaustein zur
* Anzeige von Benutzer-Berechtigungen
     user_data_p1 LIKE usr12-auth,
     user_data_p2 LIKE usr12-objct,
     user_data_p3 LIKE usr12-aktps,
* Hilfsfeld für das Lesen einer zu einem Step gehörigen Spoolliste
     spool_rqid   LIKE tsp01-rqident,
* Returncodes die beim Speichern von Starttermindaten in Jobkopf-
* daten auftreten können
     eventcnt_generation_error  TYPE i VALUE 1,
* Kennzeichnungen für die Angabe eines Periodentyps auf Dynpro 1060
     hourly_period    VALUE 'H',
     daily_period     VALUE 'D',
     weekly_period    VALUE 'W',
     monthly_period   VALUE 'M',
     explicit_period  VALUE 'E',
* Flags zur Steuerung der Abbruchbehandlung (PF12) Dynpro 1060 und 1190
* (Periodenwerte und explizite Periodenwerte) und Dynpro 1260 (Perioden-
* verhalten an Nichtarbeitstagen)
     period_data_modified          LIKE true,
     explicit_period_data_modified LIKE true,
     period_behaviour_modified     LIKE true,
* Kennung für Workprozesse vom Typ 'Batch' ( SM50-Info)
     wp_type_btc            LIKE raw_ad_wpstat_rec-rqtyp VALUE 'BTC ',
* Returncodes der Routinen CHECK_FOR_JOB_STILL_ACTIVE /
* CHECK_FOR_JOB_STILL_READY
     job_not_active_anymore  TYPE i VALUE 1,
     cant_get_btc_wp_info    TYPE i VALUE 2,
     job_not_ready_anymore   TYPE i VALUE 3,
     cant_get_batchq_size    TYPE i VALUE 4,
     xpgm_maybe_still_active TYPE i VALUE 5,
     job_active_in_wp        TYPE i VALUE 6,
     job_active_ext          TYPE i VALUE 7,
* Returncodes der Routine CORRECT_JOB_STATUS
     correcting_job_status_failed TYPE i VALUE 1,
     ready_switch_too_dangerous   TYPE i VALUE 2,
     job_already_locked           TYPE i VALUE 3,
* Flag das anzeigt, ob der Benutzer die Korrektur eines Jobstatus er-
* zwingen will ( BP_JOB_ABORT / BP_JOB_CHECKSTATE ) bzw. ob ein abzu-
* brechender Job ( gespeichert in den globalen Variablen GLOBA_JOB und
* GLOBAL_STEPLIST ) als Steps ext. Pgm. hat ( Form CORRECT_JOB_STATUS )
     correct_job_status     LIKE true,
* Positionen und Länge der Spalten innerhalb der Anzeige von externen
* Programmen eines Jobs ( CORRECT_JOB_STATUS )
     xpgm_hdr_pos             TYPE i,
     xpgm_hdr_len             TYPE i,
     xpgm_tgtsys_hdr_pos      TYPE i,
     xpgm_tgtsys_hdr_len      TYPE i,
     xpgm_pid_hdr_pos         TYPE i,
     xpgm_pid_hdr_len         TYPE i,
     xpgm_list_width          TYPE i,
* Profileparameter 'installierte Systemsprachen' und Variable zum
* Ablegen des Systemsprachenstrings
     parameter_installed_languages(24) VALUE 'zcsa/installed_languages',
*   installed_languages(30),
    installed_languages(255),
* Returncodes der Routine GET_SERVER_LIST
     cant_get_server_info             TYPE i VALUE 1,
     no_server_found                  TYPE i VALUE 2,
* Returncodes der Routine CHECK_REPORT
     report_doesnt_exist              TYPE i VALUE 1,
     report_not_to_be_scheduled       TYPE i VALUE 2,
     no_assign_privilege_for_job      TYPE i VALUE 3,
* Hilfsvariable für PBO/PAI-Verarbeitung Dynpro 2030
     restlen TYPE i,
* Konstante für Release 3.0A. Wird für Variantenbearbeitung benötigt,
* weil diese sich ab 3.0A grundlegend geändert hat.
     sap_release_30a                  LIKE sy-saprl VALUE '30 '.
*
* Message-Ids, die mit der Routine INSERT_JOBLOG_MESSAGE in das Job-
* protokoll eines Jobs geschrieben werden können
*
DATA: abort_msg_id(3) VALUE '608'.
*
*  Funktionsbausteinübergreifende Syslogkennungen
*
DATA:
   invalid_dialog_type(3)              VALUE  'EFH',
   invalid_opcode(3)                   VALUE  'EFP',
   jobdefinition_pending(3)            VALUE  'EIF',
   write_msg_failed(3)                 VALUE  'ECJ',
   job_name(3)                         VALUE  'EBC'.
*
* Syslogkennungen für Syslogeinträge des Funktionsbausteins
* BP_SIMPLE_BATCH_JOB_SUBMIT
*
DATA: invalid_variant(3)  VALUE 'ED1',
      job_submit_error(3) VALUE 'EBI',
      job_info(3)         VALUE 'ED2'.
*
* Syslogkennungen fuer Syslogeinträge der Startterminpruefung
* (Funktionsbaustein BP_START_DATE_EDITOR)
*
DATA:
   no_startdate_given(3)               VALUE  'EDW',
   specify_only_one_startdate(3)       VALUE  'EBV',
   no_period_data_given(3)             VALUE  'EDY',
   specify_only_one_period(3)          VALUE  'EDZ',
   no_predecessor_jobname_given(3)     VALUE  'EDQ',
   invalid_predecessor_jobname(3)      VALUE  'EDR',
   predecessor_jobname_not_unique(3)   VALUE  'EDS',
   incomplete_startdate(3)             VALUE  'EDT',
   startdate_in_the_past(3)            VALUE  'EBP',
   incomplete_last_startdate(3)        VALUE  'ED9',
   last_startdate_in_the_past(3)       VALUE  'EDA',
   startdate_interval_too_large(3)     VALUE  'EDB',
   no_eventid_given(3)                 VALUE  'EDU',
   invalid_eventid(3)                  VALUE  'EDV',
   invalid_startdate_detected(3)       VALUE  'EDX',
   unknown_startdate_exception(3)      VALUE  'EF0',
   period_and_predjob_no_way(3)        VALUE  'EF1',
   invalid_opmode_name(3)              VALUE  'EIT',
   cant_get_calendar_id(3)             VALUE  'EIU',
   startdate_out_of_fcal_range_id(3)   VALUE  'EIW',
   fcal_id_not_defined_id(3)           VALUE  'EIX',
   unknown_fcal_error_occured_id(3)    VALUE  'EIY',
   startdate_is_a_holiday_id(3)        VALUE  'EIZ',
   stdt_before_holiday_in_past_id(3)   VALUE  'EI0',
   invalid_periodbehaviour_id(3)       VALUE  'EJ1',
   no_plan_privilege_given_id(3)       VALUE  'EJ2',
   period_too_small_for_limit_id(3)    VALUE  'EJ3',
   invalid_workday_nr_id(3)            VALUE  'EJ9',
   workday_starttime_missing_id(3)     VALUE  'EJ0',
   invalid_workday_countdir_id(3)      VALUE  'EJA',
   no_workday_nr_given_id(3)           VALUE  'EJB',
   notbefore_stdt_missing_id(3)        VALUE  'EJC',
   predjob_wrong_status(3)             VALUE  'EM0'.

*
* Syslogkennungen fuer Syslogeinträge der Report- und Variantenpruefung
* (Funktionsbaustein BP_CHECK_REPORT_VALUES)
*
DATA:
   invalid_report_values_detected(3)   VALUE  'EFK',
   report_name_missing(3)              VALUE  'EF6',
   invalid_report_name(3)              VALUE  'EF9',
   invalid_variant_name_id(3)          VALUE  'ED1',
   no_variants_defined_id(3)           VALUE  'EFA',
   report_can_not_be_scheduled(3)      VALUE  'EFB',
   report_has_no_variants_id(3)        VALUE  'EFC',
   variant_check_has_failed(3)         VALUE  'EFD',
   variant_name_missing_id(3)          VALUE  'EFE',
   invalid_check_type(3)               VALUE  'EFL',
   syntax_error(3)                     VALUE  'EDN',
   generation_error(3)                 VALUE  'EDO',
   catalog_read_error(3)               VALUE  'EDP',
   no_plan_authority(3)                VALUE  'EG1',
   unknown_chkrp_exception(3)          VALUE  'EFM'.
*
* Syslogkennungen fuer Syslogeinträge der Stepwertepruefung
* (Funktionsbaustein BP_STEPLIST_EDITOR)
*
DATA:
   invalid_step_detected(3)            VALUE  'EF2',
   unknown_step_exception(3)           VALUE  'EF3',
   invalid_step_typ(3)                 VALUE  'EF4',
   invalid_step_status(3)              VALUE  'EF5',
   user_name_missing(3)                VALUE  'EF7',
   name_of_extpgm_missing(3)           VALUE  'EFF',
   target_host_name_missing(3)         VALUE  'EFG',
   invalid_step_index(3)               VALUE  'EFI',
   error_reading_step_values(3)        VALUE  'EFJ',
   reading_print_params_failed(3)      VALUE  'EFZ',
   cant_get_installed_languages(3)     VALUE  'EJ7',
   invalid_system_language(3)          VALUE  'EJ8',
   name_of_extcmd_missing(3)           VALUE  'EHE',
   operating_system_missing(3)         VALUE  'EHF',
   extcmd_unknown(3)                   VALUE  'EHG',
   extcmd_params_too_long(3)           VALUE  'EHH',
   extcmd_security_risk(3)             VALUE  'EHI',
   extcmd_wrong_check_interface(3)     VALUE  'EHJ',
   extcmd_x_error(3)                   VALUE  'EHK',
   extcmd_too_many_parameters(3)       VALUE  'EHL',
   extcmd_parameters_expected(3)       VALUE  'EHM',
   extcmd_illegal_command(3)           VALUE  'EHN',
   extcmd_communication_failure(3)     VALUE  'EHO',
   extcmd_system_failure(3)            VALUE  'EHO'.

*
* Syslogkennungen fuer Syslogeinträge des Jobdatenpruefung
* (Funktionsbaustein BP_JOB_EDITOR)
*
DATA:
   invalid_job_values_detected(3)      VALUE  'EFN',
   jobname_missing(3)                  VALUE  'EFO',
   unknown_job_exception(3)            VALUE  'EFQ',
   job_not_modifiable_anymore(3)       VALUE  'EFR',
   no_stepdata_given(3)                VALUE  'EFS',
   invalid_stepdata(3)                 VALUE  'EFT',
   invalid_jobstatus(3)                VALUE  'EFU',
   jobcount_generation_error_id(3)     VALUE  'EFW',
   slg_jobcount_generation_failed TYPE char3 VALUE 'EFW',
   eventcnt_generation_error_id(3)     VALUE  'EFX',
   invalid_jobclass(3)                 VALUE  'EFY',
   no_release_privilege_given(3)       VALUE  'EGU'.
*
* Syslogkennungen fuer Syslogeinträge der Benutzerpruefung
* (Formroutine AUTH_CHECK_NAM und CHECK_PLAN_AUTH)
*
DATA:
   no_user_assign_privilege_id(3)     VALUE   'EG0',
   invalid_username_id(3)             VALUE   'EF8',
   bad_user_type_id(3)                VALUE   'EFV'.
*
* Syslogkennungen fuer Syslogeinträge der Zielrechnerprüfung bzw.
* Ermittlung des Defaultrechners für einen auszuführenden Job
*
DATA:
   tgt_host_chk_has_failed_id(3)      VALUE   'EG3',
   no_free_batch_wp_id(3)             VALUE   'EG4',
   no_batch_wp_for_jobclass_id(3)     VALUE   'EIV',
   no_batch_server_found_id(3)        VALUE   'EG5',
   no_batch_on_target_host_id(3)      VALUE   'EG6',
   target_host_not_defined_id(3)      VALUE   'EGX'.
*
* Syslogkennungen die beim Erzeugen eines neuen Jobs geschrieben
* werden können ( Fubst. BP_JOB_CREATE )
*
DATA:
   job_create_problem_detected(3)     VALUE   'EG7',
   unknown_job_create_problem(3)      VALUE   'EG8',
   cant_create_job(3)                 VALUE   'EG9',
   invalid_job_data(3)                VALUE   'EGA'.
*
* Syslogkennungen die beim Modifizieren eines Jobs geschrieben
* werden können ( Fubst. BP_JOB_MODIFY )
*
DATA:
   job_modify_problem_detcted(3)      VALUE   'EGZ',
   unknown_job_modify_problem(3)      VALUE   'EI1',
   cant_modify_job(3)                 VALUE   'EI2',
   no_steps_found_in_db(3)            VALUE   'EI3',
   unknown_job_read_error(3)          VALUE   'EI4',
   no_job_modify_privilege(3)         VALUE   'EI5',
   new_jobdata_id_mismatch(3)         VALUE   'EI6',
   no_startdate_no_release(3)         VALUE   'EIA'.
*
* Syslogkennungen die beim Kopierenn eines Jobs geschrieben
* werden können ( Fubst. BP_JOB_COPY )
*
DATA:
   job_copy_problem_detected(3)      VALUE   'EI7',
   no_copy_privilege_given(3)        VALUE   'EII'.
*
* Syslogkennungen die beim Steuern und Ueberwachen von Jobs geschrieben
* werden können ( Fubst. BP_JOB_MAINTENANCE)
*
DATA:
   job_maint_problem_detected(3)     VALUE   'EI8',
   unknown_selection_error(3)        VALUE   'EI9'.
*
* Syslogkennungen die beim Bearbeiten von Joblisten geschrieben werden
* können ( Fubst. BP_JOBLIST_PROCESSOR)
*
DATA:
   joblst_problem_detected(3)        VALUE   'EIE'.
*
* Syslogkennungen die beim Anzeigen eines Joblogs geschrieben werden
* können ( Fubst. BP_JOBLOG_SHOW )
*
DATA:
   joblog_sh_problem_detected(3)     VALUE   'EIB',
   jobcount_missing(3)               VALUE   'EIC',
   joblog_read_error(3)              VALUE   'EID'.
*
* Syslogkennungen die beim Selektieren von Jobs aus der DB geschrieben
* werden können ( Fubst. BP_JOB_SELECT )
*
DATA:
   job_select_problem_detected(3)    VALUE   'EIG',
   unknown_job_select_problem(3)     VALUE   'EIH'.
*
* Syslogkennungen die beim Abbrechen von Jobs geschrieben werden
* können ( Fubst. BP_JOB_ABORT )
*
DATA:
   job_abort_problem_detected(3)     VALUE   'EIM',
   no_job_abort_privilege_given(3)   VALUE   'EIN',
   job_active_checking_failed(3)     VALUE   'EIO',
   pulverizing_job_failed(3)         VALUE   'EIP'.
*
* Syslogkennungen die beim Überprüfen des Jobstatus geschrieben werden
* können ( Fubst. BP_JOB_CHECKSTAT )
*
DATA:
   job_checkstat_problem_detected(3)  VALUE   'EIQ',
   no_job_check_privilege_given(3)    VALUE   'EIR',
   job_ready_checking_failed(3)       VALUE   'EIS',
   job_checkstate_successful(3)       VALUE   'EJH'.
*
* Syslogkennungen die bei Datenbankoperationen geschrieben werden
* können ( Formroutinen STORE_NEW_JOB_IN_DB, UPDATE_JOB_IN_DB,
* DELETE_JOB_IN_DB, STORE_NEW_STEPLIST_IN_DB, UPDATE_STEPLIST_IN_DB
* DELETE_STEPLIST_IN_DB )
*
DATA:
   jobentry_already_exists(3)         VALUE   'EGB',
   jobentry_already_locked(3)         VALUE   'EGC',
   jobentry_doesnt_exist(3)           VALUE   'EGE',
   predjob_doesnt_exist(3)            VALUE   'EGF',
   tbtco_insert_db_error(3)           VALUE   'EGG',
   tbtco_update_db_error(3)           VALUE   'EGH',
   tbtco_delete_db_error(3)           VALUE   'EGI',
   tbtcp_insert_db_error(3)           VALUE   'EGJ',
   tbtcp_update_db_error(3)           VALUE   'EGK',
   tbtcp_delete_db_error(3)           VALUE   'EGL',
   tbtcs_insert_db_error(3)           VALUE   'EGM',
   tbtcs_update_db_error(3)           VALUE   'EGN',
   tbtcs_delete_db_error(3)           VALUE   'EGO',
   btcevtjob_insert_db_error(3)       VALUE   'EGP',
   btcevtjob_update_db_error(3)       VALUE   'EGQ',
   btcevtjob_delete_db_error(3)       VALUE   'EGR',
   eoj_eventid_locked(3)              VALUE   'EGT',
   eventid_already_locked(3)          VALUE   'EGS',
   eventid_in_error_info(3)           VALUE   'EGY'.
*
* Returncodes von Enqueueformroutinen
*
DATA:
   table_entry_doesnt_exist   TYPE i VALUE 1,
   table_entry_already_locked TYPE i VALUE 2,
   enqueue_error              TYPE i VALUE 3.
*
*  Syslogkennungen, die bei Enqueueoperationen geschrieben werden
*  können
*
DATA:
   enqueue_error_detected(3)  VALUE  'EGD'.
*
*  Syslogkennungen, die beim Anstarten von Jobs geschrieben werden
*  können
*
DATA:
   cant_start_job_immediately(3) VALUE 'EGU',
   job_start_failed(3)           VALUE 'EAW'.
*
*  Syslogkennungen die beim Schreiben von Joblogeinträgen geschrieben
*  werden können (Routine WRITE_MESSAE_IN_JOBLOG)
*
DATA:
  unknown_joblog_message_id(3) VALUE 'EGV',
  cant_start_pretended_job(3)  VALUE 'EGW'.
*
*  Syslogkennungen die beim 'Umziehen' eines Jobs auf einen anderen
*  Zielrechner (Fubst. BP_JOB_MOVE_TO_TARGETSYSTEM)
*
DATA:
  job_move_problem_detected(3) VALUE 'EJ4',
  no_move_privilege_given(3)   VALUE 'EJ5',
  new_target_system_missing(3) VALUE 'EJ6',
  job_count(3)                 VALUE 'EJK'.
*
*   Kennung eines ABAP-LAufzeit-Fehlers
*
DATA:
  abap_rabax_msgnr LIKE t100-msgnr VALUE '671',
  abap_rabax_arbgb LIKE t100-arbgb VALUE '00'.
*
* Variablen für BP_JOB_SELECT
*
DATA:
* Initialwerte für Datum / Uhrzeit
  initial_from_date   LIKE tbtco-sdlstrtdt VALUE '19000101',
  initial_from_time   LIKE tbtco-sdlstrttm VALUE '000000',
  initial_to_date     LIKE tbtco-sdlstrtdt VALUE '99991231',
  initial_to_time     LIKE tbtco-sdlstrttm VALUE '240000', "#EC VALUE_OK
* Returncodes der Routine TRANSLATE_SEL_FIELDS
  no_jobname_specified      TYPE i VALUE 1,
  no_user_specified         TYPE i VALUE 2,
  no_status_selected        TYPE i VALUE 3,
  no_time_specified         TYPE i VALUE 4,
  no_event_triggered        TYPE i VALUE 5,
  no_job_triggered          TYPE i VALUE 6,
  no_opmode_triggered       TYPE i VALUE 7,
  no_date_specified         TYPE i VALUE 8,
  no_abap_specified         TYPE i VALUE 9,
  no_extcmd_specified       TYPE i VALUE 10,
  no_extprg_specified       TYPE i VALUE 11,
  no_period_specified       TYPE i VALUE 12,
  no_admin_specified        TYPE i VALUE 13,
  no_scheduled_specified    TYPE i VALUE 14,
  incorrect_servername      TYPE i VALUE 15,
  empty_execserver          TYPE i VALUE 16,
  no_stepuser_specified     TYPE i VALUE 17,

* Werte die angeben, ob Benutzer Selektionswerte auf Dynpro modifiziert
* hat
  select_params_modified,

* globale Datendeklarationen für BP_JOBVARIANT_SCHEDULE/OVERVIEW (HW)
       batchjob_name     LIKE tbtco-jobname,
       program_name      LIKE rsvar-report,
                         " Name des auszuführenden Programms - der Job
                         " wird nur aus einem Step aufgebaut
       workarea_name     LIKE taplt-atext,
                         " Name des Arbeitsgebiets, für das Jobs
                                       " eingeplant werden
       default_params    LIKE rsvar-variant,
                         " Variante für das auszuführende Programm -
                                       " kann im Dialog eingeben werden
       ok_code LIKE sy-ucomm,       " für Rückgabewerte von Drucktasten
       radio_months, radio_weeks, radio_days,
       radio_hours, radio_minutes,     " Auswahlknöpfe
       retval TYPE i,                  " Rückgabewert (Forms)
       status_text(11),                " Beschreibungstext für Jobstatus
*       old_period_text(16),      " Beschreibungstext für Periodendauer
*                                 " nach LBTCHACC verschoben
*       new_period_text   LIKE old_period_text,
       vline2_pos TYPE i, vline3_pos TYPE i, vline4_pos TYPE i,
       vline5_pos TYPE i, vline6_pos TYPE i,
       status_pos TYPE i,
       sdldate_pos TYPE i, sdltime_pos TYPE i, varname_pos TYPE i,
       uname_pos TYPE i, vline2_pos2 TYPE i,
       vline3_pos2 TYPE i, vname_pos TYPE i, vtext_pos TYPE i,
                         " Feldpositionen für Listenausgabe
       read_joblist TYPE i VALUE 1,    " Flag für Neulesen der Jobliste
*       recursive_call TYPE i VALUE 0,  " Flag für rekursiven Dynprocall
*                                       " nach LBTCHACC verschoben
       read_vartab  TYPE i VALUE 1,    " Flag für Neulesen der Varianten
       var_num TYPE i,                 " Anzahl gefundener Varianten
       sorting_field(30) TYPE c.       " Sortierfeldname

DATA  BEGIN OF variant_table OCCURS 1. " Tabelle der zum eingeplanten
DATA:   variant  LIKE rsvar-variant,   " Programm (-> PROG_NAME)
        vtext LIKE varit-vtext,        " gehörenden Varianten und deren
      END   OF variant_table.          " Beschreibungskurztexte


DATA  BEGIN OF jobsteplist OCCURS 5.   " Tabelle der Jobsteps
        INCLUDE STRUCTURE tbtcstep.    "   zu jedem Job wird nur der
DATA:   jobcount LIKE tbtcjob-jobcount,
      END   OF jobsteplist.            "   erste Step festgehalten


DATA  BEGIN OF vjoblist OCCURS 10.     " Tabelle eingeplanter Jobs
        INCLUDE STRUCTURE tbtcjob AS tbtcjob.
        INCLUDE STRUCTURE variant_table.
DATA  END   OF vjoblist.

* Spoollisten Empfänger-Verwaltung
*
DATA: BEGIN OF btch1140aux,
      recipient TYPE swc_object,
      END OF btch1140aux.
DATA result(32) VALUE '_RESULT'.

*
* ALV def.
*
TYPE-POOLS: slis.
TYPE-POOLS: kkblo.
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout  TYPE slis_layout_alv,
      fieldcat_tbl  TYPE slis_t_fieldcat_alv,
      gt_sort TYPE slis_t_sortinfo_alv,
      gt_filter TYPE slis_t_filter_alv,
      dummy_event TYPE slis_t_event,
      g_tabname_header TYPE slis_tabname,
      g_tabname_item   TYPE slis_tabname,
      gs_keyinfo TYPE slis_keyinfo_alv,
      g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      rs_selfield TYPE slis_selfield,
      gt_list_header TYPE slis_t_listheader,
      event_row TYPE slis_alv_event,
      event_tbl TYPE slis_t_event,
      event_exit_row  TYPE slis_event_exit,
      event_exit_tbl  TYPE  slis_t_event_exit,
      joblog_user_command TYPE slis_formname VALUE 'JLOG_USER_COMMAND',
      event_row_end TYPE slis_alv_event,
      event_tbl_end TYPE slis_t_event,
      g_pf_status TYPE slis_formname VALUE 'JOV_PF_STATUS',
      joblog_pf_status TYPE slis_formname VALUE 'JLOG_PF_STATUS',
      cua_excl_tab TYPE slis_t_extab,
      gs_variant TYPE disvariant,
      gs_log_variant TYPE disvariant,
      gs_steps_variant TYPE disvariant,
      gs_jov_variant type disvariant,
      jov_handle TYPE slis_handl VALUE 'JOVH',
      jov_log_group TYPE slis_loggr VALUE 'JOVL',
      jov_variant TYPE slis_vari VALUE 'JOV_VARIANT',
      jov_text TYPE slis_varbz
                 VALUE 'Job overview list variant',         "#EC NOTEXT
      jov_dependvars TYPE slis_depvs VALUE 'dummy',
*
* Memory for the field catalog, layout and sort criterias
* of the single list OUTPUT_JOBLIST
*
      prev_fieldcat TYPE slis_t_fieldcat_alv,
      prev_sort     TYPE slis_t_sortinfo_alv,
      prev_filter   TYPE slis_t_filter_alv,
      prev_step_fieldcat TYPE slis_t_fieldcat_alv,
      prev_step_sort     TYPE slis_t_sortinfo_alv,
      prev_step_filter   TYPE slis_t_filter_alv,
*
* PF status set
*
      jov_list_scroll_info  TYPE slis_list_scroll,
      jov_grid_scroll_info  TYPE lvc_s_scrl,
      step_list_scroll_info  TYPE slis_list_scroll,
      step_grid_scroll_info  TYPE lvc_s_scrl,

*
* colorize status field
*
      col_status TYPE slis_t_specialcol_alv.

*
* some itab with additional fields
*
DATA: BEGIN OF output_joblist OCCURS 0.
        INCLUDE STRUCTURE tbtcjob.
DATA:
      statusname(15)        TYPE c,
      slide_type_status(5)  TYPE c,
      duration              TYPE i,
      delaytime             TYPE i,
      marked(1)             TYPE c,
      colorize_status TYPE slis_t_specialcol_alv,
      spool_icon(4)         TYPE c,
      jsm_icon(4),
      END OF output_joblist.

DATA: BEGIN OF sel_joblist_b OCCURS 0.
        INCLUDE STRUCTURE tbtcjob.
DATA: progname LIKE tbtcp-progname,
      xpgprog  LIKE tbtcp-xpgprog,
      extcmd   LIKE tbtcp-extcmd.
DATA: END OF sel_joblist_b.

DATA: BEGIN OF sel_joblist OCCURS 0.
        INCLUDE STRUCTURE tbtcjob.
* data: listident like tbtcp-listident.
DATA: END OF sel_joblist.

*
* workaround global vars
*
DATA: refresh_list_flag(1) VALUE space,
      display_advanced_flag(1) VALUE space,
      disp_own_job_advanced_flag(1) VALUE space.
*
* status set
*
DATA: BEGIN OF status_set,
         scheduled_flag(1) VALUE ' ',
         released_flag(1)  VALUE ' ',
         ready_flag(1)     VALUE ' ',
         active_flag(1)    VALUE ' ',
         finished_flag(1)  VALUE ' ',
         cancelled_flag(1) VALUE ' ',
         suspended_flag(1) VALUE ' ',
         clause(100)       TYPE c,
      END OF status_set.
*
* selection count
*
DATA: total_selection_count TYPE i VALUE 0.
*
* globals for SM37 powerful version
*
CONTROLS: selection_tab TYPE TABSTRIP.
DATA: dynpronr(4) TYPE c,
      modul(30) TYPE c VALUE 'SAPLBTCH'.
* selection criteria structures
DATA: init_selection_param LIKE btcselectp OCCURS 0 WITH HEADER LINE,
      init_btch3071 LIKE btch3071 OCCURS 0 WITH HEADER LINE,
      init_btch3072 LIKE btch3072 OCCURS 0 WITH HEADER LINE,
      init_btch3073 LIKE btch3073 OCCURS 0 WITH HEADER LINE,
      init_btch3074 LIKE btch3074 OCCURS 0 WITH HEADER LINE,
      init_btch3075 LIKE btch3075 OCCURS 0 WITH HEADER LINE,
      init_btch3076 LIKE btch3076 OCCURS 0 WITH HEADER LINE,
      init_btch3077 LIKE btch3077 OCCURS 0 WITH HEADER LINE.
* marker for the previous screen number and old ok_code
DATA: old_dynpro LIKE sy-dynnr.
* ok_code stack
DATA: BEGIN OF okcode_stack OCCURS 100.
DATA: okcode LIKE sy-ucomm.
DATA: END OF okcode_stack.
DATA: counter TYPE int4 VALUE 0,
      old_code LIKE sy-ucomm,
      idx LIKE sy-tabix.
* documentation param
DATA: dokuid LIKE dokhl-object.        "BTCH+Dynpronr
DATA: BEGIN OF default_select_params.
        INCLUDE STRUCTURE btcselectp.
DATA: END OF default_select_params.
* data for the progress indicator
DATA: done_part TYPE i VALUE 0,
      done_text(50) TYPE c,
      parts TYPE i VALUE 4.
* data for the filtered entries
DATA: current_entries      TYPE kkblo_t_sfinfo,
      current_entries_item TYPE kkblo_t_sfinfo,
      current_list_control TYPE kkblo_list_scroll.

* no of btc wp
DATA: free_btc_wp  TYPE i,
      total_btc_wp TYPE i.

* for own job maintenance.
DATA: exit_signal(1) TYPE c.

* for job tree.
DATA: marked_itab LIKE output_joblist OCCURS 10 WITH HEADER LINE.

* for job copy with different client
DATA: original_client LIKE tbtco-authckman.

* change job step list into ALV.
DATA: xcode LIKE sy-xcode.
DATA: step_fieldcat TYPE slis_t_fieldcat_alv,
      step_layout TYPE slis_layout_alv,
      step_user_command TYPE slis_formname
                        VALUE 'STEPLIST_USER_COMMAND',
      step_pf_status TYPE slis_formname VALUE 'STEPLIST_STATUS',
      step_event_row TYPE slis_alv_event,
      step_event_tbl TYPE slis_t_event.

* step list display internal table
DATA: BEGIN OF steplist_itab OCCURS 0.
  INCLUDE STRUCTURE tbtcstep.
  DATA: index_no TYPE I,
        prog_type(15),
        list_flag(1),
        colorize_no TYPE slis_t_specialcol_alv,
        statusname(15) TYPE C,
        strtdate TYPE BTCSDLDATE,
        strttime TYPE BTCSDLTIME,
        enddate TYPE BTCSDLDATE,
        endtime TYPE BTCSDLTIME,
        duration TYPE I,
END OF steplist_itab.

* job list snapshot
DATA: btc_joblist_snap LIKE btch0000-int4 VALUE 221.

* user-defined favorite job selection
DATA: fav_item TYPE REF TO bp_jobsel_favorite_item,
      fav_list TYPE REF TO bp_jobsel_favorite_container.

DATA: sys_default_item TYPE btcjob VALUE '_DEFAULT'.

* job selection wildcard escape character.
DATA: jobname_escape(1),
      username_escape(1),
      abapname_escape(1).

* expanded job selection indicator.
DATA: abap_wildcard_flag(1) VALUE space,
      extprog_wildcard_flag(1) VALUE space,
      extcmd_wildcard_flag(1) VALUE space.

DATA: call_from_submit LIKE btch0000-char1.
DATA: ppktab LIKE tbtcp OCCURS 10 WITH HEADER LINE.

* user-specific settings (function names) for GRID <-> LIST switch
* see form get_current_display_function for list of available values
DATA: reuse_alv_type.
DATA: reuse_alv_xxx_display(40).
DATA: reuse_alv_xxx_layout_info_get(40).
DATA: reuse_alv_xxx_layout_info_set(40).

DATA: temp_execserver LIKE btch1140-execserver,
      temp_reaxserver LIKE btch1140-reaxserver.


* d023157       30.1.2004
* global variable, which stores the server, which got an
* immediate start job last recently
DATA: last_server TYPE msxxlist-name.

DATA: BEGIN OF server_load_info,
          name LIKE msxxlist-name,
          cnt   TYPE i,
      END OF server_load_info.

DATA: server_list_global LIKE server_load_info
                                    OCCURS 0 WITH HEADER LINE.

* c5035006
* dynpro constants
CONSTANTS: c_def1140 TYPE scradnum VALUE '1151',
      c_time1140 TYPE scradnum VALUE '1146',
      c_event1140 TYPE scradnum VALUE '1145',
      c_job1140 TYPE scradnum VALUE '1149',
      c_bart1140 TYPE scradnum VALUE '1152',
      c_wcal1140 TYPE scradnum VALUE '1147',
      c_sofort1140 TYPE scradnum VALUE '1148'.
*new display structure
DATA: BEGIN OF btch114x,
   sdlstrtdt   TYPE btcsdate,
   sdlstrttm   TYPE btcstime,
   laststrtdt  TYPE btclsdate,
   laststrttm  TYPE btclstime,
   eventid     TYPE btceventid,
   eventparm   TYPE btcevtparm,
   opmode      TYPE pfebaname,
   checkstat   TYPE btcckstat,
   dynpro      TYPE scradnum,
   immed       TYPE btcstrtmod,
   predjob     TYPE btcprednam.
DATA: END OF btch114x.

* d023157       29.4.2004
* Deklarationen für neue Version von SMX wegen accessibility

DATA: container_smx  TYPE REF TO  cl_gui_custom_container.

DATA: grid_smx       TYPE REF TO  cl_gui_alv_grid.

DATA: jobs_smx       LIKE tbtcjob OCCURS 0 WITH HEADER LINE.

DATA: output_list_smx TYPE TABLE OF output_smx.

DATA: field_cat_smx  TYPE lvc_t_fcat.

* XBP präzise Fehlermeldungen:
* globale Variablen zur Typkonvertierung vor Methodenaufruf
* Da beim Methodenaufruf eine strenge Typprüfung stattfindet,
* muß vor dem Aufruf konvertiert werden.
* Dazu werden diese globalen Variablen benutzt, um nicht an
* tausend Stellen lokale Variablen zu definieren.

DATA: xbp_msgpar1 TYPE sy-msgv1.
DATA: xbp_msgpar2 TYPE sy-msgv2.
DATA: xbp_msgpar3 TYPE sy-msgv3.
DATA: xbp_msgpar4 TYPE sy-msgv4.
DATA: xbp_error_text TYPE char50.

* note 1077959
CONSTANTS: c_hex04 TYPE x VALUE '04'.

* note 850885
DATA: trace_job_deletion.

DATA: bp_ext_refresh TYPE btch0000-char1.

* global variable to store the info, if (sy-mandt, sy-uname)
* matches JSM criteria
* With this global variable, we do not need to check so often
DATA: redirect_to_solman TYPE c.

* transaction variant
DATA: tvariant TYPE tcvariant.

DATA: change_repid_not_allowed type btcchar1. " note 2156763
