*-------------------------------------------------------------------
***INCLUDE USER_CONSTANTS .
*-------------------------------------------------------------------
SET EXTENDED CHECK OFF.

* ---------------------------------------------------------------------
* - global C O N S T A N T S
* ---------------------------------------------------------------------
CONSTANTS:
  "--- status flags in global internal buffers
  c_empty                     TYPE c               VALUE 'E',  " empty, existing user
  c_new                       TYPE c               VALUE 'N',  " new
  c_new_changed               TYPE c               VALUE 'M',  " new  --> insert required
  c_filled                    TYPE c               VALUE 'F',  " filled, existing user
  c_changed                   TYPE c               VALUE 'C',  " changed --> update required
  c_deleted                   TYPE c               VALUE 'D',  " deleted

  "--- Längenkonstanten
  c_proflng                   TYPE syfdpos         VALUE 12,   " -    Profile
  c_maxrec                    TYPE i               VALUE 3750, "Max. Laenge eines Datenrecords
  c_max_prof_per_user         TYPE i               VALUE 312,  "Max. amount of profiles per user
  c_maxusr                    TYPE i               VALUE 312,
  "    Maximale Anzahl Knoten, die auf einmal in Tree geladen werden kann
  c_max_no_of_nodes           TYPE i               VALUE 30,

  "--- date related constants
  c_low_date                  TYPE d               VALUE '19000101',
  c_high_date                 TYPE d               VALUE '99991231',

  "--- user types
  c_usertype_dialog           TYPE c               VALUE 'A',
  c_usertype_system           TYPE c               VALUE 'B',
  c_usertype_cpic             TYPE c               VALUE 'C',
  c_usertype_reference        TYPE c               VALUE 'L',
  c_usertype_service          TYPE c               VALUE 'S',
  "obsolete user types
  c_usertype_bdc              TYPE c               VALUE 'D',
  c_usertype_batch            TYPE c               VALUE 'B',

  "--- profile status
  c_active                    TYPE c               VALUE 'A',  "Aktivversion

  c_locked_by_admin           TYPE x               VALUE '40',
  c_locked_by_failed_logon    TYPE x               VALUE '80',
  c_locked_by_global_admin    TYPE x               VALUE '20',

  "--- status of change record for user (us[r/h]04)
  c_rec_type_create           TYPE c               VALUE 'C',  "user created
  c_rec_type_modify           TYPE c               VALUE 'M',  "user changed
  c_rec_type_delete           TYPE c               VALUE 'D',  "user deleted

  "--- centrale user management (CUA)
  c_identifier(32)            TYPE c               VALUE 'CUA_IDOC_PROCESSING',
  c_id_scum_flag(32)          TYPE c               VALUE 'CUA_SCUM_FLAG_GROUPS',
  c_id_clientsystem(32)       TYPE c               VALUE 'CLIENTSYSTEM',
  "--- CUA - status flags for distribution
  c_no_maint                  TYPE c               VALUE 'N',
  c_maint                     TYPE c               VALUE 'Y',
  c_maint_back                TYPE c               VALUE 'B',  "pflegen, rückverteilen
  c_local                     TYPE c               VALUE 'L',
  c_global                    TYPE c               VALUE 'G',
  c_template                  TYPE c               VALUE 'T', " Feld wird als Template ausgeliefert
  "--- CUA - Features
  c_feature_law(2)            TYPE c               VALUE 'L0',
  c_feature_atcr(4)           TYPE c               VALUE 'ATCR', "Automatic Text Comparison for Roles
  c_feature_atcl(4)           TYPE c               VALUE 'ATCL', "Automatic Text Comparison for License data
  "--- CUA - minimal USERCLONE version needed to support LAW
  c_idoctyp_law               TYPE edidocs-idoctyp VALUE 'USERCLONE05',
  "--- CUA - tabnames like provided by  SUSR_ZBV_FILTERS_GET
  c_tabname_logondata         TYPE dfies-tabname   VALUE 'BAPILOGOND',
  c_tabname_defaults          TYPE dfies-tabname   VALUE 'BAPIDEFAUL',
  c_tabname_address           TYPE dfies-tabname   VALUE 'BAPIADDR3',
  c_tabname_parameter         TYPE dfies-tabname   VALUE 'BAPIPARAM',
  c_tabname_profile           TYPE dfies-tabname   VALUE 'BAPIPROF',
  c_tabname_agr               TYPE dfies-tabname   VALUE 'BAPIAGR',
  c_tabname_company           TYPE dfies-tabname   VALUE 'BAPIUSCOMP',
  c_tabname_snc               TYPE dfies-tabname   VALUE 'BAPISNCU',
  c_tabname_lock              TYPE dfies-tabname   VALUE 'USZBV_LOCK',
  c_tabname_refuser           TYPE dfies-tabname   VALUE 'BAPIREFUS',
  c_tabname_alias             TYPE dfies-tabname   VALUE 'BAPIALIAS',
  c_tabname_groups            TYPE dfies-tabname   VALUE 'BAPIGROUPS',
  "--------- Personalization
  c_tabname_persdata          TYPE dfies-tabname   VALUE 'BAPIPERS',
  "--------- LAW and ExtID
  c_tabname_lawdata           TYPE dfies-tabname   VALUE 'BAPIUCLASS',
  "c_extids                  TYPE dfies-tabname   VALUE 'EXTIDS',
  "--------- Address data
  c_addtel                    TYPE dfies-tabname   VALUE 'ADTEL',
  c_addfax                    TYPE dfies-tabname   VALUE 'ADFAX',
  c_addttx                    TYPE dfies-tabname   VALUE 'ADTTX',
  c_addtlx                    TYPE dfies-tabname   VALUE 'ADTLX',
  c_addsmtp                   TYPE dfies-tabname   VALUE 'ADSMTP',
  c_addrml                    TYPE dfies-tabname   VALUE 'ADRML',
  c_addx400                   TYPE dfies-tabname   VALUE 'ADX400',
  c_addrfc                    TYPE dfies-tabname   VALUE 'ADRFC',
  c_addprt                    TYPE dfies-tabname   VALUE 'ADPRT',
  c_addssf                    TYPE dfies-tabname   VALUE 'ADSSF',
  c_adduri                    TYPE dfies-tabname   VALUE 'ADURI',
  c_addpag                    TYPE dfies-tabname   VALUE 'ADPAG',
  c_addcomrem                 TYPE dfies-tabname   VALUE 'ADCOMREM',

  "--- communication types
  c_comm_tel                  TYPE tsac-comm_type  VALUE 'TEL',
  c_comm_fax                  TYPE tsac-comm_type  VALUE 'FAX',
  c_comm_ttx                  TYPE tsac-comm_type  VALUE 'TTX',
  c_comm_tlx                  TYPE tsac-comm_type  VALUE 'TLX',
  c_comm_smtp                 TYPE tsac-comm_type  VALUE 'INT',
  c_comm_rml                  TYPE tsac-comm_type  VALUE 'RML',
  c_comm_x400                 TYPE tsac-comm_type  VALUE 'X40',
  c_comm_rfc                  TYPE tsac-comm_type  VALUE 'RFC',
  c_comm_let                  TYPE tsac-comm_type  VALUE 'LET',
  c_comm_prt                  TYPE tsac-comm_type  VALUE 'PRT',
  c_comm_ssf                  TYPE tsac-comm_type  VALUE 'SSF',
  c_comm_uri                  TYPE tsac-comm_type  VALUE 'URI',
  c_comm_pag                  TYPE tsac-comm_type  VALUE 'PAG',

  "--- Constants for Licensedata
  c_table_replace             TYPE bapiupmodx      VALUE 'R',
  c_table_single              TYPE bapiupmodx      VALUE 'S',
  c_law_log_field(11)         TYPE c               VALUE 'LICENCEDATA',


  "--- new activity group
  "    vorübergehend nicht als konstante, damit sie abhängig von sy-uname
  "    gesetzt werden kann
  c_new_agr                   TYPE c               VALUE 'X',

  "--- Early Watch Mandant: Adresspflege wird inaktiviert
  c_earlywatchmandt           TYPE sy-mandt        VALUE '066',
  "--- colors
  c_color_off                 TYPE snodetext-color VALUE '0',
  c_color_grayblue            TYPE snodetext-color VALUE '1',
  c_color_gray                TYPE snodetext-color VALUE '2',
  c_color_yellow              TYPE snodetext-color VALUE '3',
  c_color_bluegreen           TYPE snodetext-color VALUE '4',
  c_color_green               TYPE snodetext-color VALUE '5',
  c_color_red                 TYPE snodetext-color VALUE '6',
  c_color_violet              TYPE snodetext-color VALUE '7',
  c_color_open                TYPE snodetext-color VALUE '2',
  c_color_warning             TYPE snodetext-color VALUE '3',
  c_color_success             TYPE snodetext-color VALUE '5',
  c_color_error               TYPE snodetext-color VALUE '6',

  "--- activities for authority check
  c_act_show(2)               TYPE c               VALUE '03',  " anzeigen
  c_act_change(2)             TYPE c               VALUE '02',  " ändern
  c_act_create(2)             TYPE c               VALUE '01',  " anlegen
  c_act_assign(2)             TYPE c               VALUE '78',  " zuordnen für s_user_sys
  c_act_model(2)              TYPE c               VALUE '68',  " zuordnung modelieren
  c_act_import(2)             TYPE c               VALUE '59',  " für s_user_sys
  c_act_migrate(2)            TYPE c               VALUE '90',  " für s_user_sys übernehmen
  c_act_status(2)             TYPE c               VALUE 'A3',  "für s_user_sys Status ändern
  "    for relations (fixed values for domain USRELTYP_U, USRELTYP_S, USRELTYP_A )
  c_typ_usergroup(2)          TYPE c               VALUE 'UG',
  c_typ_user(2)               TYPE c               VALUE 'US',
  c_typ_system(2)             TYPE c               VALUE 'SY',
  c_typ_systemtype(2)         TYPE c               VALUE 'ST',
  c_typ_agr(2)                TYPE c               VALUE 'AG',
  c_typ_agrgroup(2)           TYPE c               VALUE 'AU',
  c_typ_role(2)               TYPE c               VALUE 'S',
  c_typ_orguser(2)            TYPE c               VALUE 'UO',
  "    in user management
  c_distribute                TYPE usactivity      VALUE 'DISTRIBUTE',
  c_migrate                   TYPE usactivity      VALUE 'MIGRATE',
  c_batch                     TYPE usactivity      VALUE 'BATCH',
  c_assign                    TYPE usactivity      VALUE 'ASSIGN',
  c_unassign                  TYPE usactivity      VALUE 'UNASSIGN',
  c_delete                    TYPE usactivity      VALUE 'DELETE',
  c_create                    TYPE usactivity      VALUE 'CREATE',
  c_display                   TYPE usactivity      VALUE 'DISPLAY',
  "    Werte für das Feld BAPIUSEXTIDPART-FIELDNAME ("zerhackte" lange Felder der externen IDs)
  c_lfieldname_extid          TYPE extid_fname     VALUE 'EXTID',
  c_lfieldname_issuer         TYPE extid_fname     VALUE 'ISSUER',
  c_lfieldname_serial         TYPE extid_fname     VALUE 'SERIAL',
  "   Constants for assignment types
  c_asg_usr_sys(3)            TYPE c               VALUE 'AUS', " add:    User <-> System
  c_rmv_usr_sys(3)            TYPE c               VALUE 'RUS', " remove: User <-> System
  c_asg_usr_agr(3)            TYPE c               VALUE 'UA',  " change: User <-> Role.
  c_asg_usr_pro(3)            TYPE c               VALUE 'UP',  " change: User <-> Profile.
  c_asg_usr_agr_sys(3)        TYPE c               VALUE 'USA', " change: User <-> System <-> Role.
  c_asg_usr_pro_sys(3)        TYPE c               VALUE 'USP', " change: User <-> System <-> Profile
  " In case of S_USER_SAS, SUBSYSTEM is always checked!!!
  " Even in non-CUA case we check ' ' or local logical system
  " So we need type of general assignment, when SUBSYSTEM is not checked.
  c_asg_only_usr_agr(3)       TYPE c               VALUE  'OUA', " General assignment: User <-> Role.
  c_asg_only_usr_pro(3)       TYPE c               VALUE  'OUP', " Assignment: User <-> Profile.

  "--- possible parameters in BAPI_USER_GETLIST
  c_param_logondata(9)        TYPE c               VALUE 'LOGONDATA',
  c_param_defaults(8)         TYPE c               VALUE 'DEFAULTS',
  c_param_ref_user(8)         TYPE c               VALUE 'REF_USER',
  c_param_alias(5)            TYPE c               VALUE 'ALIAS',
  c_param_profiles(8)         TYPE c               VALUE 'PROFILES',
  c_param_locprofiles(11)     TYPE c               VALUE 'LOCPROFILES',
  c_param_activitygroups(14)  TYPE c               VALUE 'ACTIVITYGROUPS',
  c_param_locactgroups(12)    TYPE c               VALUE 'LOCACTGROUPS',
  c_param_address(7)          TYPE c               VALUE 'ADDRESS',
  c_param_company(7)          TYPE c               VALUE 'COMPANY',
  c_param_lastmodified(12)    TYPE c               VALUE 'LASTMODIFIED',
  c_param_islocked(8)         TYPE c               VALUE 'ISLOCKED',
  c_param_system(6)           TYPE c               VALUE 'SYSTEM',
  c_param_user(4)             TYPE c               VALUE 'USER',
  c_param_usrsection(10)      TYPE c               VALUE 'USRSECTION',
  c_param_status(6)           TYPE c               VALUE 'STATUS',

  "--- fixed values of the STATUS field in table USZBVSYS:
  " a) intermediate states at database: until the acknowledge/error
  "    message from child system has arrived:
  c_clone_sent(1)             TYPE c               VALUE 'O',
  c_delete_sent(1)            TYPE c               VALUE 'A',
  " b) usual states: At database until the next IDoc distribution
  "    will be triggered.
  c_user_changed(1)           TYPE c               VALUE 'S',
  c_user_deleted(1)           TYPE c               VALUE 'D',
  c_warning(1)                TYPE c               VALUE 'W',
  c_locked(1)                 TYPE c               VALUE 'L',
  c_error(1)                  TYPE c               VALUE 'E',
  c_got_from_child(1)         TYPE c               VALUE 'G',
  " c) temporary states during processing: They must not appear
  "    permanently at the database:
  c_new_system(1)             TYPE c               VALUE 'N',
  c_marked_for_deletion(1)    TYPE c               VALUE 'X',

  "--- fixed values of field usrsection in table USZBVSYS:
  gc_user(4)                  TYPE c               VALUE 'USER',
  gc_roles(6)                 TYPE c               VALUE 'ACTGRP',
  gc_profiles(7)              TYPE c               VALUE 'PROFILE',

  "--- modus
  gc_pfcg_mode(13)            TYPE c               VALUE 'GMS_PFCG_MODE',

  "--- IDoc-Types of a CUA:
  gc_userclone                TYPE edi_mestyp      VALUE 'USERCLONE',
  gc_company_clone            TYPE edi_mestyp      VALUE 'CCLONE'.



* ---------------------------------------------------------------------
* - global D A T A
* ---------------------------------------------------------------------
DATA:       gd_central_logsys       TYPE uszbvlndsc-sendsystem,
            gd_rc                   TYPE sysubrc,
            gf_clientsystem(1)      TYPE c,
            gd_scum_flag_groups     TYPE usrfield-uflag.

DATA:
  gt_field_maintenance_flags  TYPE STANDARD TABLE OF usrfield.


SET EXTENDED CHECK ON.
