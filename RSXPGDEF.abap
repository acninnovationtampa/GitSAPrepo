*****************************************************************
*
*  Konstanten fuer die verschiedenen Nachrichten-Komponenten
*  bei Starten externer Programme
*
*  Diese Datei ist ein Abbild einer C-Header Datei (sapxpg.h),
*  welche nicht ausgeliefert wird. Die beiden Datei muessen
*  uebereinstimmen!
*
*****************************************************************

*  Nachricht zum Starten eines externen Programms (BTCXP1)
*
*  Komponente: FORMAT
*              kennzeichnet das Protokoll-Format fuer die
*              Kommunikation zwischen Sender und externem
*              Programm
*
 DATA format_id_0(1) VALUE '0'.                             "#EC NEEDED

*
*  Komponente: CONNECTCNTL
*              steuert den Abbau des Kommunikationsweges
*              zwischen Auftraggeber und externem Programm
*              - Kommunikationsweg wird nach dem Starten des
*                externen Programms gehalten
*              - Kommunikationsweg wird nach dem Starten des
*                externen Programms abgebaut
*
 DATA comchannel_release(1) VALUE 'R'.                      "#EC NEEDED
 DATA comchannel_hold(1)    VALUE 'H'.                      "#EC NEEDED

*
*  Komponente: STDINCNTL
*              steuert die Anpassung der Standard-Eingabe
*              des externen Programms
*              - keine Veraenderung
*              - schliesse Standard-Eingabe
*              - lenke Standard-Eingabe um
*
 DATA stdin_nomanip(1)  VALUE 'N'.                          "#EC NEEDED
 DATA stdin_close(1)    VALUE 'C'.                          "#EC NEEDED
 DATA stdin_redirect(1) VALUE 'R'.

*
*  Komponente: STDOUTCNTL
*              steuert die Anpassung der Standard-Ausgabe
*              des externen Programms
*              - keine Veraenderung
*              - schliesse Standard-Ausgabe
*              - lenke Standard-Ausgabe um
*              - lenke Standard-Ausgabe in die Trace-Datei um
*              - schreibe Standard-Ausgabe in den Hauptspeicher
*
 DATA stdout_nomanip(1)  VALUE 'N'.                         "#EC NEEDED
 DATA stdout_close(1)    VALUE 'C'.
 DATA stdout_redirect(1) VALUE 'R'.                         "#EC NEEDED
 DATA stdout_trace(1)    VALUE 'T'.                         "#EC NEEDED
 DATA stdout_inmemory(1) VALUE 'M'.

*
*  Komponente: STDERRCNTL
*              steuert die Anpassung der Standard-Fehler-Ausgabe
*              des externen Programms
*              - keine Veraenderung
*              - schliesse Standard-Fehler-Ausgabe
*              - lenke Standard-Fehler-Ausgabe um
*              - schreibe Standard-Fehler-Ausgabe in den Hauptspeicher
*
 DATA stderr_nomanip(1)  VALUE 'N'.                         "#EC NEEDED
 DATA stderr_close(1)    VALUE 'C'.
 DATA stderr_redirect(1) VALUE 'R'.                         "#EC NEEDED
 DATA stderr_inmemory(1) VALUE 'M'.

*
*  Komponente: TRACECNTL
*              steuert die Einstellung des Trace-Levels
*              - Level 0, kein Trace
*              - Level 1, Funktions-Aufruf-Trace
*              - Level 2, Protokoll-Trace
*              - Level 3, Ausdruck aller Nachrichten
*
 DATA trace_level0(1) VALUE '0'.
 DATA trace_level1(1) VALUE '1'.                            "#EC NEEDED
 DATA trace_level2(1) VALUE '2'.                            "#EC NEEDED
 DATA trace_level3(1) VALUE '3'.

*
*  Komponente: TERMCNTL
*              steuert die Ueberwachung der Terminierung
*              des externen Programms
*              - auf die Terminierung wird ueberhaupt
*                nicht gewartet (d.h. nur Starten)
*              - das Steuerprogramm wartet auf die
*                Terminierung
*              - das externe Programm selbst signalisiert
*                seine Terminierung ueber ein Event an das
*                SAP-System
*
 DATA term_dont_wait(1)  VALUE 'W'.
 DATA term_by_cntlpgm(1) VALUE 'C'.
 DATA term_by_event(1)   VALUE 'E'.                         "#EC NEEDED


*  Start-Status-Nachricht (BTCXP2)
*
*  Komponente: STARTSTAT
*              sagt aus, ob das externe Programm gestartet
*              werden konnte
*
 DATA start_ok(1)     VALUE 'O'.                            "#EC NEEDED
 DATA start_failed(1) VALUE 'F'.                            "#EC NEEDED


*  Terminierungs-Nachricht (BTCXP3)
*
*  Komponente: EXITSTAT
*              sagt aus, ie das externe Programm beendet
*              wurde
*
 DATA exit_ok(1)          VALUE 'O'.                        "#EC NEEDED
 DATA exit_with_error(1)  VALUE 'E'.                        "#EC NEEDED
 DATA exit_with_signal(1) VALUE 'S'.                        "#EC NEEDED
 DATA exit_cant_tell(1)   VALUE 'C'.                        "#EC NEEDED

 TYPES: retcode TYPE i.

************************************************************************
* Error handling
************************************************************************
* constants
 CONSTANTS:
* errors for missing parameters
   rc_first_missing_error         TYPE retcode VALUE 100,   "#EC NEEDED
   rc_empty_name                  TYPE retcode VALUE 101,
   rc_empty_opsystem              TYPE retcode VALUE 102,
   rc_empty_command               TYPE retcode VALUE 103,
   rc_empty_command_type          TYPE retcode VALUE 104,
   rc_empty_target_server         TYPE retcode VALUE 105,
   rc_empty_destination           TYPE retcode VALUE 106,
   rc_parameter_expected          TYPE retcode VALUE 107,
   rc_empty_list                  TYPE retcode VALUE 108,
   rc_last_missing_error          TYPE retcode VALUE 199,   "#EC NEEDED

* DB errors
   rc_first_db_error              TYPE retcode VALUE 200,   "#EC NEEDED
   rc_db_insert_sxpgcotabe_error  TYPE retcode VALUE 201,
   rc_db_insert_sxpgcostab_error  TYPE retcode VALUE 202,
   rc_db_delete_sxpgcotabe_error  TYPE retcode VALUE 203,
   rc_db_delete_sxpgcostab_error  TYPE retcode VALUE 204,
   rc_db_update_sxpgcotabe_error  TYPE retcode VALUE 205,
   rc_db_update_sxpgcostab_error  TYPE retcode VALUE 206,
   rc_error_update_tbtcp          TYPE retcode VALUE 207,
   rc_last_db_error               TYPE retcode VALUE 299,   "#EC NEEDED

* lock errors
   rc_first_lock_error            TYPE retcode VALUE 300,   "#EC NEEDED
   rc_foreign_lock                TYPE retcode VALUE 301,
   rc_lock_system_failure         TYPE retcode VALUE 302,
   rc_unknown_lock_error          TYPE retcode VALUE 303,
   rc_last_lock_error             TYPE retcode VALUE 399,   "#EC NEEDED

* 'cannot get' errors
   rc_first_cannot_get_error      TYPE retcode VALUE 400,   "#EC NEEDED
   rc_no_server_list              TYPE retcode VALUE 401,
   rc_no_servers_found            TYPE retcode VALUE 402,
   rc_cannot_determine_local_host TYPE retcode VALUE 403,
   rc_unknown_server_list_error   TYPE retcode VALUE 404,
   rc_cannot_get_rfc_dests        TYPE retcode VALUE 405,
   rc_cant_enq_tbtco_entry        TYPE retcode VALUE 406,   "#EC NEEDED
*   rc_jobcount_generation_error   TYPE retcode VALUE 407,   "#EC NEEDED
   rc_last_cannot_get_error       TYPE retcode VALUE 499,   "#EC NEEDED

* no authority
   rc_first_no_authority_error    TYPE retcode VALUE 500,   "#EC NEEDED
   rc_no_permission               TYPE retcode VALUE 501,
   rc_no_change_authority         TYPE retcode VALUE 502,
   rc_no_execute_authority        TYPE retcode VALUE 503,
   rc_cannot_change_sap_command   TYPE retcode VALUE 504,
   rc_last_no_authority_error     TYPE retcode VALUE 599,   "#EC NEEDED

* errors for wrong parameters
   rc_first_wrong_par_error       TYPE retcode VALUE 600,   "#EC NEEDED
   rc_prohibited_command_name     TYPE retcode VALUE 601,
   rc_prohibited_sap_command_name TYPE retcode VALUE 602,
   rc_parameters_too_long         TYPE retcode VALUE 603,
   rc_too_many_parameters         TYPE retcode VALUE 604,
   rc_wrong_check_call_interface  TYPE retcode VALUE 605,
   rc_illegal_command             TYPE retcode VALUE 606,
   rc_screen_not_init             TYPE retcode VALUE 607,
   rc_last_wrong_par_error        TYPE retcode VALUE 699,   "#EC NEEDED

* errors for 'object exists already'
   rc_first_already_exists_error  TYPE retcode VALUE 700,   "#EC NEEDED
   rc_sap_command_exists_already  TYPE retcode VALUE 701,
   rc_cus_command_exists_already  TYPE retcode VALUE 702,
   rc_command_already_exists      TYPE retcode VALUE 703,
   rc_last_already_exists_error   TYPE retcode VALUE 799,   "#EC NEEDED

* errors for 'object does not exist'
   rc_first_does_not_exist_error  TYPE retcode VALUE 800,   "#EC NEEDED
   rc_command_not_found           TYPE retcode VALUE 801,
   rc_host_does_not_exist         TYPE retcode VALUE 802,   "#EC NEEDED
   rc_job_does_not_exist          TYPE retcode VALUE 803,
   rc_last_does_not_exist_error   TYPE retcode VALUE 899,   "#EC NEEDED

* unknown errors
   rc_first_unknown_error         TYPE retcode VALUE 900,   "#EC NEEDED
   rc_unknown_error               TYPE retcode VALUE 901,
   rc_x_error                     TYPE retcode VALUE 902,
   rc_external_error              TYPE retcode VALUE 903,
   rc_last_unknown_error          TYPE retcode VALUE 999,   "#EC NEEDED

* action cancelled
   rc_first_cancelled_error       TYPE retcode VALUE 1000,  "#EC NEEDED
   rc_security_risk               TYPE retcode VALUE 1001,
   rc_action_cancelled            TYPE retcode VALUE 1002,
   rc_program_start_error         TYPE retcode VALUE 1003,
   rc_program_termination_error   TYPE retcode VALUE 1004,
   rc_communication_error         TYPE retcode VALUE 1005,
   rc_system_error                TYPE retcode VALUE 1006,
   rc_cannot_get_rfc_dest         TYPE retcode VALUE 1007,  "#EC NEEDED
   rc_wrong_asynch_params         TYPE retcode VALUE 1008,  "#EC NEEDED
   rc_cant_gen_sapxpg_local       TYPE retcode VALUE 1009,  "#EC NEEDED
   rc_last_cancelled_error        TYPE retcode VALUE 1099,  "#EC NEEDED

* error while pasring parameters
   rc_first_parse_error          TYPE retcode VALUE 1100,   "#EC NEEDED
   rc_parse_separator_missing    TYPE retcode VALUE 1101,   "#EC NEEDED
   rc_parse_result_too_long      TYPE retcode VALUE 1102,   "#EC NEEDED
   rc_parse_lgflnm_doesnt_exist  TYPE retcode VALUE 1103,   "#EC NEEDED
   rc_parse_error_file_set_name  TYPE retcode VALUE 1104,   "#EC NEEDED
   rc_parse_par_expected         TYPE retcode VALUE 1105,   "#EC NEEDED
   rc_parse_add_par_not_allowed  TYPE retcode VALUE 1106,   "#EC NEEDED
   rc_parse_cust_fm_doesnt_exist TYPE retcode VALUE 1107,   "#EC NEEDED
   rc_parse_sap_fm_doesnt_exist  TYPE retcode VALUE 1108,   "#EC NEEDED
   rc_parse_opsys_conv_broken    TYPE retcode VALUE 1109,   "#EC NEEDED
   rc_parse_wrong_interface      TYPE retcode VALUE 1110,   "#EC NEEDED
   rc_last_parse_error           TYPE retcode VALUE 1199,   "#EC NEEDED

* last error
   rc_last_error                  TYPE retcode VALUE 9999.  "#EC NEEDED


 CONSTANTS:
   sapxpg            LIKE rfcopt-rfcexec VALUE 'sapxpg',    "#EC *
   sapxpg_uc            LIKE rfcopt-rfcexec VALUE 'sapxpg_uc',    "#EC *
   sapxpg_nonuc_bytes   type  RFCDISPLAY-RFCUNICODE value '1',
   sapxpg_uc_bytes      type  RFCDISPLAY-RFCUNICODE value '2',
   ignore_conv_error    LIKE rfcdisplay-rfcconvert VALUE 'X',  "#EC NEEDED
   default_char      TYPE rfcraw04 VALUE '########',        "#EC NEEDED
   obj_external_program LIKE btcctl-ctlobj VALUE 'SXPG'.    "#EC NEEDED


* Ende der Datei RSXPGDEF
