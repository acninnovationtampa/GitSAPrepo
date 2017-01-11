***INCLUDE LBTCHDEF .

*****************************************************************
*
*  Dieses Includefile ist für Anwender der Funktionsgruppe BTCH u. SOMS
*  (Funktionsbausteine der Hintergrundverarbeitung) gedacht, die
*  hier Definitionen von Konstanten finden, die die Benutzung
*  der entsprchenden Funktionsbausteine erleichtern soll. In den
*  Dokumentationen der einzelnen Funktionsbausteine ist fest-
*  gehalten, welche Konstanten jeweils benötigt werden.
*
*  Anwender sollen dieses Include in ihre eigenen Reports in-
*  kludieren. Bitte verändern Sie die Werte nicht !
*
*****************************************************************

*****************************************************************
*
* Global types
*
*****************************************************************
TYPES: BEGIN OF t_lock,
  gclient TYPE seqg3-gclient,
  guname TYPE seqg3-guname,
  gthost TYPE seqg3-gthost,
  gtwp TYPE seqg3-gtwp,
  gtdate TYPE seqg3-gtdate,
  gttime TYPE seqg3-gttime,
  gtusec TYPE seqg3-gtusec,
  lockedby(52) TYPE c,
  locktime(22) TYPE c,
END OF t_lock.

TYPES:
  tt_lock TYPE TABLE OF t_lock.

TYPES: BEGIN OF t_period,
  prdmins TYPE btcpmin,
  prdhours TYPE btcphour,
  prddays TYPE btcpday,
  prdweeks TYPE btcpweek,
  prdmonths TYPE btcpmnth,
  emergmode TYPE tbtco-emergmode,
  calendarid TYPE tbtco-calendarid,
  prdbehav TYPE tbtco-prdbehav,
  calcorrect TYPE tbtco-calcorrect,
  eomcorrect TYPE tbtco-eomcorrect,
END OF t_period.

TYPES: BEGIN OF t_start_cond,
  sdlstrtdt TYPE tbtco-sdlstrtdt,
  sdlstrttm TYPE tbtco-sdlstrttm,
  laststrtdt TYPE tbtco-laststrtdt,
  laststrttm TYPE tbtco-laststrttm,
END OF t_start_cond.

*****************************************************************
*
*  Konstanten fuer die verschiedenen Komponenten der
*  Steuertabelle BTCCTL
*
*****************************************************************

*  Komponente: CTLOBJ
*              kennzeichent das jeweilige Objekt bzw. die
*              jeweilige Instanz, fuer welche die bestehenden
*              Einstellungen wirken sollen

CONSTANTS:
  btc_obj_time_based_sdl        TYPE btcctl-ctlobj VALUE 'TIMESDL',
  btc_obj_evt_based_sdl         TYPE btcctl-ctlobj VALUE 'EVTSDL',
  btc_obj_job_start             TYPE btcctl-ctlobj VALUE 'JOBSTART',
  btc_obj_zombie_cleanup        TYPE btcctl-ctlobj VALUE 'ZOMBIE',
  btc_obj_external_program      TYPE btcctl-ctlobj VALUE 'XPG',
  btc_obj_auto_del              TYPE btcctl-ctlobj VALUE 'AUTODEL',
  btc_obj_opmode                TYPE btcctl-ctlobj VALUE 'OPMODE'.

*  Texte fuer die oben definierten Objekte
*  (z.B. zur Verwendung in Dynpros)
CONSTANTS:
  btc_obj_time_based_sdl_text        TYPE btcctl-ctlobj
                         VALUE 'Zeitbasierter Scheduler',   "#EC NOTEXT
  btc_obj_evt_based_sdl_text         TYPE btcctl-ctlobj
                         VALUE 'Eventbasierter Scheduler',  "#EC NOTEXT
  btc_obj_job_text                   TYPE btcctl-ctlobj
                         VALUE 'Job-Starter',               "#EC NOTEXT
  btc_obj_zombie_text                TYPE btcctl-ctlobj
                         VALUE 'Zombie-Cleanup',            "#EC NOTEXT
  btc_obj_external_text              TYPE btcctl-ctlobj
                         VALUE 'External Program',          "#EC NOTEXT
  btc_obj_auto_del_text              TYPE btcctl-ctlobj
                         VALUE 'Automatisches Jobloeschen', "#EC NOTEXT
  btc_obj_opmode_text                TYPE btcctl-ctlobj
                         VALUE 'Betriebsartenumschaltung'.  "#EC NOTEXT

*  Komponente: TRACELEVEL
*              steuert die Einstellung des Trace-Levels
*              - Level 0, kein Trace
*              - Level 1, Funktions-Aufruf- und Schleifen-Trace
*              - Level 2, Protokoll-Trace
*              - Level 8, schalte Trace-Level 1 fuer einen Ablauf
*                         ein, danach Abschalten des Trace
*              - Level 9: schalte Trace-Level 2 fuer einen Ablauf
*                         ein, danach Abschalten des Trace

CONSTANTS:
  btc_trace_level0  TYPE btcctl-tracelevel VALUE 0,
  btc_trace_level1  TYPE btcctl-tracelevel VALUE 1,
  btc_trace_level2  TYPE btcctl-tracelevel VALUE 2,
  btc_trace_single1 TYPE btcctl-tracelevel VALUE 8,
  btc_trace_single2 TYPE btcctl-tracelevel VALUE 9.

 DATA: trace_level2_on TYPE btch0000-char1.                     " insert WO

*  Komponente: OPMODE
*              steuert die Verarbeitungsweise der jeweiligen
*              Instanz
*              - Mode A: aktiviert, d.h. die betroffene Instanz
*                        soll ihre normalen Aktivitaeten
*                        ausfuehren
*              - Mode D: deaktiviert, d.h. die betroffene Instanz
*                        soll keine Aktivitaeten ausfuehren
*              - Mode S: Simualtionsmodus, die Instanz simuliert
*                        ihre Aktivitaeten lediglich
*
*              Beachte: Soweit nicht anders vereinbart, beinhalten
*                       alle Modes den Mode A.
CONSTANTS:
  btc_mode_activated     TYPE btcctl-opmode VALUE 'A',
  btc_mode_deactivated   TYPE btcctl-opmode VALUE 'D',
  btc_mode_simulation    TYPE btcctl-opmode VALUE 'S'.

*****************************************************************
*
*  Konstanten fuer die verschiedenen Starttermintypen, die der
*  Funktionsbaustein BP_GET_START_DATE_EDITOR zurückliefern kann,
*  Modifikationstypen eines Starttermins und möglichen Zählrichtungen
*  für Starttermintyp 'an Arbeitstag'.
*
*****************************************************************
CONSTANTS:
  btc_stdt_immediate  TYPE  tbtcstrt-startdttyp VALUE 'I',
  btc_stdt_datetime   TYPE  tbtcstrt-startdttyp VALUE 'D',
  btc_stdt_event      TYPE  tbtcstrt-startdttyp VALUE 'E',
  btc_stdt_afterjob   TYPE  tbtcstrt-startdttyp VALUE 'A',
  btc_stdt_onworkday  TYPE  tbtcstrt-startdttyp VALUE 'W'.

CONSTANTS:
  btc_stdt_modified      TYPE  btch0000-int4  VALUE 1,
  btc_stdt_not_modified  TYPE  btch0000-int4  VALUE 2.

CONSTANTS:
  btc_beginning_of_month TYPE tbtcstrt-wdaycdir VALUE '1',
  btc_end_of_month       TYPE tbtcstrt-wdaycdir VALUE '2'.

CONSTANTS:
  hours_per_day TYPE i VALUE 24,
  seconds_per_day TYPE i VALUE 86400.

*****************************************************************
*
* Konstanten für den Funktionsbaustein BP_CHECK_EVENTID
* (Typ der EventId, der untersucht werden soll)
*
*****************************************************************
CONSTANTS:
  system_eventid    TYPE btch0000-char1 VALUE 'S',
  user_eventid      TYPE btch0000-char1 VALUE 'U',
  any_eventid_type  TYPE btch0000-char1 VALUE 'X'.

*****************************************************************
*
* Konstanten für den Funktionsbaustein BP_STEPLIST_EDITOR
* (Typ der Modifikation der Stepliste)
*
*****************************************************************
CONSTANTS:
  btc_stpl_unchanged   TYPE btch0000-int4 VALUE 1,
  btc_stpl_new_count   TYPE btch0000-int4 VALUE 2,
  btc_stpl_updated     TYPE btch0000-int4 VALUE 3.

*****************************************************************
*
* Konstanten für den Funktionsbaustein BP_JOB_EDITOR
* (Typ der Modifikation des Jobs)
*
*****************************************************************
CONSTANTS:
  btc_job_not_modified      TYPE btch0000-int4 VALUE 1,
  btc_job_modified          TYPE btch0000-int4 VALUE 2,
  btc_job_steps_updated     TYPE btch0000-int4 VALUE 3,
  btc_job_new_step_count    TYPE btch0000-int4 VALUE 4.
*****************************************************************
*
*  Operationscodes für die Funktionsbausteine
*
*    - Kontrollobjekteditor (BP_BTCCTL_EDITRO)
*    - EventIdeditor (BP_EVENTID_EDITOR)
*    - Steplisteneditor (BP_STEPLIST_EDITOR)
*    - Jobdateneditor (BP_JOB_EDITOR)
*    - Starttermineditor (BP_START_DATE_EDITOR)
*    - Jobmodifikation  (BP_JOB_MODIFY)
*    - Jobdaten lesen   (BP_JOB_READ)
*    - Jobs steuern und überwachen (BP_JOBLIST_PROCESSOR)
*    - Joblog anzeigen (BP_JOBLOG_SHOW)
*    - Betriebsartensets bearbeiten ( OMS_OMSET_EDITOR )
*    - Anzeigen der Schedulertabelle für die Betriebsartenumschaltung
*      ( OMS_SCHEDULER_TBL_SHOW )
*    - Anzeigen eines Textes der besagt, das Benutzer prüfen soll, ob
*      ext. Pgm. eines Jobs noch aktiv sind.
*      ( Fubst. BP_JOB_ABORT / BP_JOB_CHECKSTATE )
*    - Einfache Jobeinplanung über Variantenauswahl
*      (BP_JOBVARIANT_SCHEDULE)
*    - Jobübersicht der einfachen Jobeinplanung (BP_JOBVARIANT_OVERVIEW)
*    - Performanceanalyse Anzeige der Jobliste (BP_PERFORMANCE_LIST)
*
*  Diese Codes dienen u.a. auch als Identifier für die entsprechenden
*  Listverarbeitungskontexte der genannten Editoren
*
*****************************************************************

CONSTANTS:
  btc_edit_btcctl_tbl       TYPE btch0000-int4 VALUE  1,
  btc_show_btcctl_tbl       TYPE btch0000-int4 VALUE  2,
  btc_edit_user_eventids    TYPE btch0000-int4 VALUE  3,
  btc_show_user_eventids    TYPE btch0000-int4 VALUE  4,
  btc_edit_system_eventids  TYPE btch0000-int4 VALUE  5,
  btc_show_system_eventids  TYPE btch0000-int4 VALUE  6,
  btc_edit_steplist         TYPE btch0000-int4 VALUE  7,
  btc_show_steplist         TYPE btch0000-int4 VALUE  8,
  btc_show_variantlist      TYPE btch0000-int4 VALUE  9,
  btc_create_job            TYPE btch0000-int4 VALUE 10,
  btc_edit_job              TYPE btch0000-int4 VALUE 11,
  btc_show_job              TYPE btch0000-int4 VALUE 12,
  btc_check_only            TYPE btch0000-int4 VALUE 13,
  btc_edit_startdate        TYPE btch0000-int4 VALUE 14,
  btc_show_startdate        TYPE btch0000-int4 VALUE 15,
  btc_modify_whole_job      TYPE btch0000-int4 VALUE 16,
  btc_release_job           TYPE btch0000-int4 VALUE 17,
  btc_derelease_job         TYPE btch0000-int4 VALUE 18,
  btc_read_jobhead_only     TYPE btch0000-int4 VALUE 19,
  btc_read_all_jobdata      TYPE btch0000-int4 VALUE 20,
  btc_joblist_edit          TYPE btch0000-int4 VALUE 21,
  btc_joblist_show          TYPE btch0000-int4 VALUE 22,
  btc_joblist_select        TYPE btch0000-int4 VALUE 23,
  btc_joblog_show           TYPE btch0000-int4 VALUE 24,
  btc_edit_omset            TYPE btch0000-int4 VALUE 25,
  btc_show_omset            TYPE btch0000-int4 VALUE 26,
  btc_show_oms_sdl_tbl      TYPE btch0000-int4 VALUE 27,
  btc_show_xpgm_list        TYPE btch0000-int4 VALUE 28,
  btc_close_job             TYPE btch0000-int4 VALUE 29,
  btc_varjoblist_select     TYPE btch0000-int4 VALUE 30,
  btc_varlist_select        TYPE btch0000-int4 VALUE 31,
  btc_performance_list      TYPE btch0000-int4 VALUE 32,
  btc_performance_info      TYPE btch0000-int4 VALUE 33,
  btc_batchproces_list      TYPE btch0000-int4 VALUE 34,
  btc_dont_read_priparams   TYPE btch0000-int4 VALUE 35,  " note 770158
  btc_xbp_all_jobdata       TYPE btch0000-int4 VALUE 36,  " note 792767
  btc_xbp_jobhead_only      TYPE btch0000-int4 VALUE 37,   " note 792767
  btc_crea_job_keep_repid   TYPE btch0000-int4 VALUE 40,   " note 2156763
  btc_edit_job_keep_repid   TYPE btch0000-int4 VALUE 41.   " note 2156763


*****************************************************************
*
*  Typen von Programmen, die zu einem Step gehören können
*
*    - ABAPs
*    - externe Programme
*
*****************************************************************

CONSTANTS:
  btc_abap TYPE tbtcstep-typ VALUE 'A',
  btc_xpg  TYPE tbtcstep-typ VALUE 'X',
  btc_xcmd TYPE tbtcstep-typ VALUE 'C'.

*****************************************************************
*
*  mögliche Programm- bzw. Stepstatus
*
*    - running
*    - ready
*    - freigegeben
*    - geplant
*    - abgebrochen
*    - beendet
*    - ausgeplant, weil Put gerade aktiv ist (wird nur benutzt von den
*      Reports BTCTRNS1 und BTCTRNS2)
*    - unbekannt
*
*****************************************************************

CONSTANTS:
  btc_running       TYPE tbtco-status VALUE 'R',
  btc_ready         TYPE tbtco-status VALUE 'Y',
  btc_scheduled     TYPE tbtco-status VALUE 'P',
  btc_intercepted   TYPE btcstatus VALUE btc_scheduled,
  btc_released      TYPE tbtco-status VALUE 'S',
  btc_aborted       TYPE tbtco-status VALUE 'A',
  btc_finished      TYPE tbtco-status VALUE 'F',
  btc_put_active    TYPE tbtco-status VALUE 'Z',
  btc_unknown_state TYPE tbtco-status VALUE 'X'.

*****************************************************************
*
*  Konstanten für den Funktionsbaustein BP_CHECK_REPORT_VALUES
*  für das Prüfen von Report- und Variantenangaben
*
*****************************************************************
CONSTANTS:
   btc_no                       TYPE btch0000-char1 VALUE 'N',
   btc_yes                      TYPE btch0000-char1 VALUE 'Y',
   btc_check_report_only        TYPE btch0000-char1 VALUE 'R',
   btc_check_report_and_variant TYPE btch0000-char1 VALUE 'A'.

*****************************************************************
*
*  Konstanten des Eventhandlings
*
*****************************************************************
CONSTANTS:
   btc_event_activated                     VALUE 'X',
   btc_predjob_checkstat                   VALUE 'X',
   btc_eventid_eoj TYPE btcevtjob-eventid  VALUE 'SAP_END_OF_JOB'.

*****************************************************************
*
*  Konstanten für die Bezeichnung von Jobklassen
*
*****************************************************************

CONSTANTS:
   btc_jobclass_a VALUE 'A',
   btc_jobclass_b VALUE 'B',
   btc_jobclass_c VALUE 'C'.

*****************************************************************
*
*  Konstanten, die für das Anstarten von sogenannten "vorge-
*  täuschten Jobs" gebraucht werden. Sie bezeichnen Reportnamen,
*  die von vorgetäuschten Jobs ausgeführt werden können, z.B.
*  bei Fehlersitutationen, um einen Eintrag im Joblog zu schreiben.
*
*****************************************************************

CONSTANTS:
  immed_start_error_report TYPE sy-repid VALUE 'RSBTCPT3'.

*****************************************************************
*
*  Konstanten für die Pflege und Steuerung der Betriebsartenum-
*  schaltung:
*
*    - Identifier für normalen bzw. Exceptionbetriebsartenset
*    - Namen des normalen bzw. Exceptionbetriebsartenset
*
*****************************************************************

CONSTANTS:
  btc_opmode_except TYPE btcomset-settype VALUE 'E',
  btc_opmode_normal TYPE btcomset-settype VALUE 'N',
  btc_omset_except  TYPE btcomset-setname VALUE '%_EXCEPT',
  btc_omset_normal  TYPE btcomset-setname VALUE '%_NORMAL'.

*****************************************************************
*
*  Konstanten für Default Servergruppen
*
*****************************************************************

CONSTANTS:
  sap_default_srvgrp TYPE bpsrvgrp VALUE 'SAP_DEFAULT_BTC'.

*****************************************************************
*
*  Konstanten für die Benennung des Protokollmediums für das
*  Analystetool der Hintergrundverarbeitung ( Programm BTCSPY )
*
*    - Liste
*    - Liste + File
*    - File
*
*****************************************************************

CONSTANTS:
  btc_protmedium_list          TYPE btch0000-char1 VALUE 'L',
  btc_protmedium_file          TYPE btch0000-char1 VALUE 'F',
  btc_protmedium_list_and_file TYPE btch0000-char1 VALUE 'B'.

*****************************************************************
*
*  Konstanten für die Beschreibung des Ausführungsverhaltens
*  von periodischen Jobs an Nichtarbeitstagen
*
*    - Keine Ausführung des Jobs an Nichtarbeitstagen
*    - Job an Arbeitstag vor dem Nichtarbeitstag ausführen
*    - Job an Arbeitstag nach dem Nichtarbeitstag ausführen
*    - Job immer ausführen
*
*****************************************************************

CONSTANTS:
  btc_dont_process_on_holiday  TYPE btch0000-char1  VALUE 'D',
  btc_process_before_holiday   TYPE btch0000-char1  VALUE 'B',
  btc_process_after_holiday    TYPE btch0000-char1  VALUE 'A',
  btc_process_always           TYPE btch0000-char1  VALUE ' '.

*****************************************************************
*
* Constants for the function module BP_SET_MSG_HANDLING
* (Type of the message handling)
*
*****************************************************************
CONSTANTS:
  btc_show_msgs_on_handler      TYPE btch0000-int4 VALUE 1,
  btc_suppress_msgs_on_handler  TYPE btch0000-int4 VALUE 2.


*****************************************************************
*
* Constants for the XBP-Interface
*
*****************************************************************

CONSTANTS: btc_job_is_parent            TYPE btch0000-char1  VALUE 'P'.
CONSTANTS: btc_job_is_child             TYPE btch0000-char1  VALUE 'C'.
CONSTANTS: btc_job_is_parent_and_child  TYPE btch0000-char1  VALUE 'B'.


CONSTANTS: err_invalid_step_number          TYPE i VALUE 1.
CONSTANTS: err_no_authority                 TYPE i VALUE 2.
CONSTANTS: err_job_doesnt_have_this_step    TYPE i VALUE 3.
CONSTANTS: err_child_register_error         TYPE i VALUE 4.
CONSTANTS: err_wrong_selection_par          TYPE i VALUE 5.
CONSTANTS: err_invalid_jobclass             TYPE i VALUE 6.
CONSTANTS: err_spoollist_recipient          type i value 7.
CONSTANTS: err_plain_recipient              type i value 8.


*****************************************************************
*
* constants for print parameter initial values
*
*****************************************************************

CONSTANTS:       c_char_unknown     TYPE c VALUE '_', "Unbekannt C
                 c_int_unknown      TYPE i VALUE -1,  "Unbekannt I
                 c_num1_unknown     TYPE n VALUE '0',"Unbekannt N(1)
                 c_char_space       TYPE c VALUE '$'. "will be SPACE

DATA: valid_pri_params  TYPE c.

*****************************************************************
*
* constants for message types
*
*****************************************************************

CONSTANTS:      message_type_status TYPE c VALUE 'S',
                message_type_info   TYPE c VALUE 'I',
                message_type_error  TYPE c VALUE 'E',
                message_type_warning TYPE c VALUE 'W',
                message_type_abort TYPE c VALUE 'A',
                message_type_x TYPE c VALUE 'X'.

DATA: trc_caller TYPE btcctl-ctlobj.

*****************************************************************
*
* constants for size of spool list
*
*****************************************************************
CONSTANTS: btc_firstline TYPE tspoptions-spoption VALUE 'BTC_FIRSTLINE',
btc_lastline TYPE tspoptions-spoption VALUE 'BTC_LASTLINE'.

CONSTANTS: empty_server_group TYPE bpsrvgrp VALUE '$<}'.  " note 1658978


* ######################################################################
*                       E R R O R     C O D E S
* ######################################################################

CONSTANTS:

* ######################################################################
*                 D I S P A T C H E R  and  Q U E U E
* ######################################################################
  rc_cant_get_th_queues         TYPE i VALUE 101,           "#EC NEEDED
  rc_btc_queue_is_empty         TYPE i VALUE 102,           "#EC NEEDED

* ######################################################################
*                 E N Q U E U E  and  D E Q U E U E
* ######################################################################
  rc_job_already_locked         TYPE i VALUE 201,           "#EC NEEDED
  rc_btcevtjob_already_locked   TYPE i VALUE 202,           "#EC NEEDED
  rc_lock_system_failed         TYPE i VALUE 203,           "#EC NEEDED
  rc_no_free_jobcounts          TYPE i VALUE 204,           "#EC NEEDED
  rc_jobcount_generation_error  TYPE i VALUE 205,           "#EC NEEDED
  rc_scheduler_already_locked   TYPE i VALUE 206,           "#EC NEEDED
  rc_enqueue_cannot_read        TYPE i VALUE 207,           "#EC NEEDED
  rc_job_quickly_unlocked       TYPE i VALUE 208,           "#EC NEEDED
  rc_enqueues_not_expired       TYPE i VALUE 209,           "#EC NEEDED
  rc_rzl_str_remove_failed      TYPE i VALUE 210,           "#EC NEEDED
  rc_rzl_str_get_failed         TYPE i VALUE 211,           "#EC NEEDED
  rc_rzl_str_set_failed         TYPE i VALUE 212,           "#EC NEEDED
  rc_rzl_str_check_failed       TYPE i VALUE 213,           "#EC NEEDED
  rc_rzl_str_empty_name         TYPE i VALUE 214,           "#EC NEEDED

* ######################################################################
*               S E R V E R S   and   P R O C E S S E S
* ######################################################################
  rc_cannot_get_num_of_a_btcwps TYPE i VALUE 301,           "#EC NEEDED
  rc_server_cannot_be_enqueued  TYPE i VALUE 302,           "#EC NEEDED
  rc_no_free_btcwps             TYPE i VALUE 303,           "#EC NEEDED
  rc_disp_queue_too_long        TYPE i VALUE 304,           "#EC NEEDED
  rc_cannot_get_all_servers     TYPE i VALUE 305,           "#EC NEEDED
  rc_tgt_host_chk_has_failed    TYPE i VALUE 306,           "#EC NEEDED
  rc_cannot_read_server_group   TYPE i VALUE 307,           "#EC NEEDED
  rc_job_cannot_be_started      TYPE i VALUE 308,           "#EC NEEDED
  rc_cannot_get_own_wp          TYPE i VALUE 309,           "#EC NEEDED
  rc_server_is_inactive         TYPE i VALUE 310,           "#EC NEEDED

* ######################################################################
*                      DB   O P E R A T I O N S
* ######################################################################
  rc_insert_tbtcp_mass_failed   TYPE i VALUE 401,           "#EC NEEDED
  rc_update_tbtcp_mass_failed   TYPE i VALUE 402,           "#EC NEEDED
  rc_store_print_params_failed  TYPE i VALUE 403,           "#EC NEEDED

* ######################################################################
*          C A L E N D E R    A N D    R E S C H E D U L I N G
* ######################################################################
  rc_calendar_load_failed       TYPE i VALUE 501,
  rc_no_date_found              TYPE i VALUE 502,
  rc_date_corrupted             TYPE i VALUE 503,
  rc_cant_convert_fdate         TYPE i VALUE 504,

* ######################################################################
*                      A U T H O R I Z A T I O N S
* ######################################################################
  rc_no_auth_read_joblog        TYPE i VALUE 601,           "#EC NEEDED

  rc_last_btc_error             TYPE i VALUE 99999.         "#EC NEEDED

* ######################################################################
  DATA: variant_possible(1).

* Ende der Datei LBTCHDEF
