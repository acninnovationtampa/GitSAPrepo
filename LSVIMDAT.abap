TABLES: e070, e071k, e071, tadir, dderr, tddat, objh. "#EC NEEDED

TYPE-POOLS: cxtab, cmpwl, vimty, slctr, trwbo, scpr, slis, szadr.

CLASS: cl_abap_char_utilities DEFINITION LOAD.

* Adresspflege Übergangslösung anfang
TABLES: sadr, sadr2, sadr3, sadr4, sadr5.
DATA: sadr_keylen  TYPE i,             "key length of table SADR
      sadr_namtab_read TYPE c.                              "flag:

* Adresspflege Übergangslösung ende

DATA: maint_stat LIKE vimstatus.

FIELD-SYMBOLS: <vim_ctotal> TYPE ANY, <vim_cextract> TYPE ANY,
               <vim_xtotal> TYPE x, <vim_xextract> TYPE x,
               <vim_total_struc> TYPE ANY,
               <vim_extract_struc> TYPE ANY,
               <vim_tot_txt_struc> TYPE ANY,
               <vim_ext_txt_struc> TYPE ANY.
FIELD-SYMBOLS: <f1> TYPE ANY, <name> TYPE ANY, <table1> TYPE ANY,
               <table2> TYPE ANY, <orig_key> TYPE x,
               <client> TYPE ANY, <vim_total_key> TYPE ANY,
               <vim_extract_key> TYPE ANY,
               <vim_xtotal_key> TYPE x,
               <vim_xextract_key> TYPE x,
               <vim_client_initial> TYPE ANY.
* unicode
FIELD-SYMBOLS: <table1_x> TYPE x,
               <table2_x> TYPE x,
               <f1_x> TYPE x,
               <table1_wa> TYPE ANY,
               <table1_wax> TYPE x,
               <f1_wax> TYPE x,
               <vim_corr_keyx> TYPE x,
               <initial_x> TYPE x.
FIELD-SYMBOLS: <mark> TYPE ANY, <action> TYPE ANY,
               <xmark> TYPE ANY, <xact> TYPE ANY, <initial> TYPE ANY,
               <status> STRUCTURE vimstatus DEFAULT maint_stat,
               <address_number> TYPE ANY,
               <user_exit_field> TYPE ANY,                  "#EC NEEDED
               <replace_field> TYPE ANY,
               <vim_begdate>     LIKE sy-datum,
               <vim_new_begdate> LIKE sy-datum,
               <vim_enddate>     LIKE sy-datum.
FIELD-SYMBOLS: <vim_enddate_mask> TYPE ANY,
               <vim_mainkey_mask> TYPE ANY,
               <vim_prtfky_wa> TYPE ANY, <vim_prtfky_extract> TYPE ANY,
               <vim_prtfky_total> TYPE ANY,
               <vim_begdate_mask> TYPE ANY,
               <vim_collapsed_keyx> TYPE x,
               <vim_collapsed_logkeyx> TYPE x.
FIELD-SYMBOLS: <vim_collapsed_key_afx> TYPE x,
               <vim_merged_keyx> TYPE x,
               <vim_total_address_number> TYPE ANY,
               <vim_addr_handle_x> TYPE x.
* Unicode
FIELD-SYMBOLS:
  <vim_h_mkey> TYPE x, <vim_h_old_mkey> TYPE x,
  <vim_h_coll_mkey> TYPE x, <vim_h_merged_key> TYPE x,
  <vim_h_coll_bfkey> TYPE x, <vim_h_coll_logkey> TYPE x,
  <vim_f1_beforex> TYPE x, <vim_f1_afterx> TYPE x,
  <vim_mkey_beforex> TYPE x, <vim_mkey_afterx> TYPE x.
FIELD-SYMBOLS:
  <vim_tot_mkey_beforex> TYPE x, <vim_tot_mkey_afterx> TYPE x,
  <vim_ext_mkey_beforex> TYPE x, <vim_ext_mkey_afterx> TYPE x,
  <vim_old_mkey_beforex> TYPE x, <vim_old_mkey_afterx> TYPE x,
  <vim_collapsed_mkey_bfx> TYPE x.
* for downward-compatibility only:
FIELD-SYMBOLS:
  <vim_f1_before>, <vim_f1_after>,                          "#EC NEEDED
  <vim_mkey_before>, <vim_mkey_after>,                      "#EC NEEDED
  <vim_tot_mkey_before>, <vim_tot_mkey_after>,              "#EC NEEDED
  <vim_ext_mkey_before>, <vim_ext_mkey_after>,              "#EC NEEDED
  <vim_old_mkey_before>, <vim_old_mkey_after>,              "#EC NEEDED
  <vim_collapsed_key_af>, <vim_collapsed_logkey>,           "#EC NEEDED
  <vim_merged_key>, <vim_collapsed_key>.                    "#EC NEEDED
*
FIELD-SYMBOLS: <subsetfield> TYPE ANY,
               <rdonlyfield> TYPE ANY,                      "#EC NEEDED
               <value> TYPE ANY,
               <state> STRUCTURE vimstatus DEFAULT maint_stat,
               <vim_tctrl> TYPE cxtab_control, <vim_sellist> TYPE table,
               <vim_ck_sellist> TYPE table,
               <vim_field_value> TYPE ANY,                  "#EC NEEDED
               <vim_scrform_name> TYPE ANY,
               <vim_auth_sellist> TYPE table.
FIELD-SYMBOLS: <table1_text> TYPE ANY, <table1_xtext> TYPE x,
               <total_text> TYPE ANY, <extract_text> TYPE ANY,
               <vim_xtotal_text> TYPE x, <vim_xextract_text> TYPE x,
               <action_text> TYPE ANY,
               <xact_text> TYPE ANY,
               <extract_enti> TYPE ANY, <vim_xextract_enti> TYPE x,
               <textkey> TYPE ANY, <initial_textkey> TYPE ANY,
               <textkey_x> TYPE x, <initial_textkey_x> TYPE x,
               <text_initial> TYPE ANY, <text_initial_x> TYPE x,
               <vim_text_enddate> TYPE ANY.
FIELD-SYMBOLS: <vim_texttab> TYPE table,               "SW Texttransl ..
*                            Type VIM_TAB_US/ .. /VIM_TAB_UL
               <vim_read_langus> TYPE table. "SW Texttransl
*----------------------------------------------------------------------*
* Declaration of types                                                 *
*----------------------------------------------------------------------*
TYPES: vim_ko200_tab_type TYPE TABLE OF ko200.
TYPES: BEGIN OF state_vector,
         type(1)   TYPE c,             " E=Einstufig Z=Zweistufig
         action(1) TYPE c,             " S=Anz., U=Änd., A=Hinzuf., T=Tr
         mode(1)   TYPE c,             " L=Liste, D=Detail
         data(1)   TYPE c, " G=gesamt, X=Extract, D=Geloeschte
         mark(1)   TYPE c,             " M=Markiert,  =Nicht Markiert
         delete(1) TYPE c,             " D=Gelöscht,  =Nicht Gelöscht
         fill1(1)  TYPE c,             "filler, not used
         fill2(1)  TYPE c,                                  "     - " -
       END OF state_vector.
TYPES: vim_tabkey TYPE tabl4096,
       BEGIN OF vim_tabkey_c,
        line(255) TYPE c,
       END OF vim_tabkey_c.
TYPES: BEGIN OF vim_ck_selcond,
         field LIKE vimnamtab-bastabfld,
         operator(2) TYPE c,
         hk1(1) TYPE c,
         value LIKE vimsellist-value,
         hk2(1) TYPE c,
         and LIKE vimsellist-and_or,
       END OF vim_ck_selcond.
TYPES: vimexclfldtab TYPE STANDARD TABLE OF vimexclfld
                          WITH DEFAULT KEY  INITIAL SIZE 10,
       BEGIN OF vimexclfldtabsline,
         viewname LIKE tvdir-tabname,
         excl_pos_tab TYPE vimexclfldtab,
         excl_rpl_tab TYPE vimexclfldtab,
         excl_que_tab TYPE vimexclfldtab,
       END OF vimexclfldtabsline,
       vimexclfldtabs TYPE SORTED TABLE OF vimexclfldtabsline
                           WITH UNIQUE KEY viewname,
       BEGIN OF vim_delim_entr_tl, "indizes of delim. entries
         index1 TYPE i,            "entries with mainkey in total
         index2 TYPE i,
         index3 TYPE i,            "current entry in extract in
                                   "collapsed mode
         index_corr(1) TYPE c,
       END OF vim_delim_entr_tl.
TYPES: BEGIN OF vim_collapsed_mkeys_tl,"collapsed mainkeys
         mkey_bf TYPE vim_tabkey_c,
         mainkey TYPE vim_tabkey_c,
         log_key TYPE vim_tabkey_c,
       END OF vim_collapsed_mkeys_tl,
       BEGIN OF vim_merged_entr_tl,    "merged entries
         new_key TYPE vim_tabkey,
         merged_key TYPE vim_tabkey,
         new_begdate TYPE d,
         new_enddate TYPE d,
         merged_begdate TYPE d,
         merged_enddate TYPE d,
       END OF vim_merged_entr_tl.
TYPES: BEGIN OF vim_ale_keyspec_objs,
         oname LIKE objh-objectname,
         otype LIKE objh-objecttype,
       END OF vim_ale_keyspec_objs,
       vim_flds_tab_type TYPE TABLE OF fieldname,           "fieldlist
       vimnamtab_type TYPE TABLE OF vimnamtab.

* Definitionen für Texterfassung in mehreren Sprachen  "SW Texttransl ..
CONSTANTS:
      ultra_short_tab TYPE i VALUE 32,
      very_short_tab TYPE i VALUE 48,
      short_tab TYPE i VALUE 64,
      middle_tab TYPE i VALUE 128,
      long_tab TYPE i VALUE 256,
      very_long_tab TYPE i VALUE 512,
      ultra_long_tab TYPE i VALUE 4096,
      vim_max_keylen_show TYPE i VALUE 120,                 "#EC NEEDED
      vim_max_textfields TYPE i VALUE 8,   "Anzahl Textfelder auf D0100
      vim_max_keyfields TYPE i VALUE 10.   "  "    Keyfelder   "     "

TYPES: vim_line_ul(ultra_long_tab)  TYPE c,
       vim_line_vl(very_long_tab)   TYPE c,
       vim_line_l(long_tab)         TYPE c,
       vim_line_m(middle_tab)       TYPE c,
       vim_line_s(short_tab)        TYPE c,
       vim_line_vs(very_short_tab)  TYPE c,
       vim_line_us(ultra_short_tab) TYPE c,

       vim_tab_ul  TYPE vim_line_ul OCCURS 0,
       vim_tab_vl  TYPE vim_line_vl OCCURS 0,
       vim_tab_l   TYPE vim_line_l OCCURS 0,
       vim_tab_m   TYPE vim_line_m OCCURS 0,
       vim_tab_s   TYPE vim_line_s OCCURS 0,
       vim_tab_vs  TYPE vim_line_vs OCCURS 0,
       vim_tab_us  TYPE vim_line_us OCCURS 0.

TYPES: BEGIN OF vim_variable_tab,
         valid_idx LIKE sy-index,      " Index der gefüllten Tabelle
         tab_us TYPE vim_tab_us,       " falls benutzt -> valid_idx = 2
         tab_vs TYPE vim_tab_vs,       "     "                "     = 3
         tab_s  TYPE vim_tab_s,
         tab_m  TYPE vim_tab_m,
         tab_l  TYPE vim_tab_l,
         tab_vl TYPE vim_tab_vl,
         tab_ul TYPE vim_tab_ul,
        END OF vim_variable_tab.

TYPES: BEGIN OF vim_tabdata_record,
         viewname   LIKE tvdir-tabname,
         sel_langus LIKE t002-spras OCCURS 0,
         all_langus(1) TYPE c,
         tabdata    TYPE vim_variable_tab,
       END OF vim_tabdata_record.

* lok. Hilfsvariable für Absprung in Langtextpflege über User-Exit
DATA: vim_internal_ltext_call(1) TYPE c.              ".. SW Texttransl

* flags for ALS activation status
DATA: als_active(25) TYPE c,
      als_enabled(25) TYPE c.
* ALS declarations
DATA: als_sel_langus LIKE H_T002 OCCURS 0 WITH HEADER LINE,
      als_langus_selected(1) TYPE c.

*----------------------------------------------------------------------*
* Declaration of constants                                             *
*----------------------------------------------------------------------*
CONSTANTS:
      read(4) TYPE c VALUE 'READ',
      edit(4) TYPE c VALUE 'EDIT',
      read_and_edit(4) TYPE c VALUE 'RDED',
      vim_read_text(4) TYPE c VALUE 'RTXT',                 "SW Textimp
        " FCODE: Einlesen + zusätzl. Lesen der Texttab in allen Sprachen
      save(4) TYPE c VALUE 'SAVE',
      reset_list(4) TYPE c VALUE 'ORGL',
      reset_entry(4) TYPE c VALUE 'ORGD',
      switch_to_show_mode(4) TYPE c VALUE 'ANZG',
      switch_to_update_mode(4) TYPE c VALUE 'AEND'.
CONSTANTS:
      switch_transp_to_upd_mode(4) TYPE c VALUE 'TRAE',
      get_another_view(4) TYPE c VALUE 'ATAB',
      back(4) TYPE c VALUE 'BACK',
      end(4) TYPE c VALUE 'ENDE',
      canc(4) TYPE c VALUE 'ABR ',                          "#EC NEEDED
      transport(4) VALUE 'TRSP',
      subset(1) TYPE c VALUE 'S',
      authority TYPE sychar01 VALUE 'A',
      ddic_marks(2)   TYPE c VALUE 'XB', "ddic marks for ddic-flag
      vim_subset_marks(2) TYPE c VALUE 'SB', "subset marks for ddic-flag
      vim_subset_marks_mult(4) TYPE c VALUE 'SBMA'.         "#EC NEEDED
      "including authority
CONSTANTS:                                                     "and mult
      rdonly(1) TYPE c VALUE 'R',
      vim_hidden(1) TYPE c VALUE 'H',                        "#EC NEEDED
      adrnbr(1) TYPE c VALUE 'A',
      usrexi(1) TYPE c VALUE 'X',
      client_length LIKE sy-fdpos VALUE '3', "#EC STR_NUM  "in characters
      vim_datum_length LIKE sy-fdpos VALUE '8', "#EC STR_NUM
      vim_spras_length LIKE sy-fdpos VALUE '1', "#EC STR_NUM
      fname_length  TYPE i VALUE '30',  "#EC STR_NUM  "max. fieldname length
      compl_form_offs LIKE sy-fdpos VALUE '6', "#EC STR_NUM
      corr_form_offs LIKE sy-fdpos VALUE '11'. "#EC STR_NUM
CONSTANTS:
      transporter LIKE tadir-pgmid VALUE 'R3TR', "name of transport pgm
      transp_object LIKE tadir-object VALUE 'TABU', "object to transport
      vim_view_type LIKE e071k-mastertype VALUE 'VDAT',
      vim_clus_type LIKE e071k-mastertype VALUE 'CDAT',
      vim_tran_type LIKE e071k-mastertype VALUE 'TDAT',
      vim_deleted_key LIKE tadir-pgmid VALUE '(DL)',
      vim_unlockable_object LIKE e071k-mastertype VALUE '(UO)',
      vim_lockable_object LIKE e071k-mastertype VALUE '(LO)',
      vim_long_objname LIKE e071k-objname VALUE '(?TABKEY?)'.
CONSTANTS:
      vim_71k_name_length TYPE i VALUE '30', "#EC STR_NUM
      vim_transport_denied(1) TYPE c VALUE 'V',
      bc_transport_denied(1) TYPE c VALUE 'Y', "No trsp at bc_set act.
      sortflag_with_existency LIKE e071k-sortflag VALUE '2',
      sortflag_without_existency LIKE e071k-sortflag VALUE '3',
      e071_objfunc LIKE e071-objfunc VALUE 'K',
      state_vect_prefix(7) TYPE c VALUE 'STATUS_',
      state_vect_prefix_length TYPE i VALUE '7', "#EC STR_NUM
      sap_cust_classes(2) TYPE c VALUE 'EG',    "tabclasses to check
      sap_only_classes(1) TYPE c VALUE 'S',                 "      -"-
      sap_cust_ctrl_classes(1) TYPE c VALUE 'E',            "      -"-
      no_transport_classes(1) TYPE c VALUE 'L',             "       -"-
      no_transport_log_classes(1) TYPE c VALUE 'W',"   -"-
      application_delivery_classes(1) TYPE c VALUE 'A'.
CONSTANTS:
      customizing_delivery_classes(3) TYPE c VALUE 'CEG',
      nbrd_texts_prefix(10) TYPE c VALUE 'SVIM_TEXT_',
      nbrd_texts_prefix_length TYPE i VALUE '10', "#EC STR_NUM
      master_fpool(8) TYPE c VALUE 'SAPLSVIM',
      vim_position_info_len TYPE i VALUE '30', "#EC STR_NUM  "length of dynpro field
      vim_position_info_lg1 TYPE i VALUE '13', "#EC STR_NUM "length of 'Eintrag'
      vim_position_info_lg2 TYPE i VALUE '6',  "#EC STR_NUM  "length of 'von'
      vim_position_info_lg3 TYPE i VALUE '10', "#EC STR_NUM  "max length of entry nbr.
      vim_reset(1) TYPE c VALUE 'O'.
CONSTANTS:
      vim_replace(1) TYPE c VALUE 'R',
      vim_upgrade(1) TYPE c VALUE 'U',
      vim_direct_upgrade(1) TYPE c VALUE 'C',
      vim_undelete(1) TYPE c VALUE 'D',
      vim_delimit(1) TYPE c VALUE 'G',
      vim_delete(1) TYPE c VALUE 'L',
      vim_extedit(1) TYPE c VALUE 'E',                        "#EC NEEDED
      vim_import(1) TYPE c VALUE 'I',                         "#EC NEEDED
      vim_import_no_dialog TYPE c VALUE 'D',                  "#EC NEEDED
      vim_import_with_dialog TYPE c VALUE 'H'.
CONSTANTS:
      vim_time_dep_dpl_modif_form(30) TYPE c
                                  VALUE 'TIME_DEPENDENT_DISPLAY_MODIF',
      vim_view(1) TYPE c VALUE 'V',    "OBJH-type for views
      vim_tabl(1) TYPE c VALUE 'S',    "OBJH-type for tables
      vim_clst(1) TYPE c VALUE 'C',    "OBJH-type for clusters
      vim_tran(1) TYPE c VALUE 'T',    "OBJH-type for transact.
      vim_logo(1) TYPE c VALUE 'L',    "OBJH-type for TLOGO-obj.
      vim_cust(4) TYPE c VALUE 'CUST', "OBJ-category CUST
      vim_syst(4) TYPE c VALUE 'SYST'. "OBJ-category SYST
CONSTANTS:
      vim_cust_syst(4) TYPE c VALUE 'CUSY',    "OBJ-category CUSY
      vim_appl(4) TYPE c VALUE 'APPL', "OBJ-category APPL
      vim_noact(1) TYPE c VALUE 'N',   "client state: no action
      vim_log(1)   TYPE c VALUE '1',   "client state: log chngs.
      vim_locked(1) TYPE c VALUE '2',  "client state: no chngs.
      vim_local_clnt(1) TYPE c VALUE '3',      "client state: no transp.
      vim_nocliindep_cust(1) TYPE c VALUE '1', "client state: ....
      vim_noreposichanges(1) TYPE c VALUE '2', "client state: ....
      vim_noreposiandcust(1) TYPE c VALUE '3'. "client state: ....
CONSTANTS:
      vim_frm_text_upd_flag(19) TYPE c VALUE 'SET_TXT_UPDATE_FLAG',
      vim_frm_fill_textkey(19) TYPE c VALUE 'FILL_TEXTTAB_KEY_UC',
*      vim_frm_fill_textkey(16) TYPE c VALUE 'FILL_TEXTTAB_KEY',
      vim_max_trsp_keylength TYPE i VALUE '120', "#EC STR_NUM
      vim_max_trsp_identical_key TYPE i VALUE '119', "#EC STR_NUM
      vim_char_inttypes(5) TYPE c VALUE 'CDNST', "char types for transp.
      vim_not_importable TYPE objimp VALUE '1'.

CONSTANTS:
* Type
  einstufig(1)       TYPE c VALUE 'E',
  zweistufig(1)      TYPE c VALUE 'Z',
* Action
  anzeigen(1)        TYPE c VALUE 'S',
  aendern(1)         TYPE c VALUE 'U',
  vim_ds_loeschen(1) TYPE c VALUE 'D',             "MF BCSet-DS loeschen
  hinzufuegen(1)     TYPE c VALUE 'A',
  kopieren(1)        TYPE c VALUE 'C',
  profil_hinzufuegen TYPE c VALUE 'R',                      "UFprofile
  transportieren(1)  TYPE c VALUE 'T',
  pruefen(1)         TYPE c VALUE 'P',
  zurueckholen(1)    TYPE c VALUE 'Z',
  task_add(1)        TYPE c VALUE 'E',
  task_del(1)        TYPE c VALUE 'F'.
* Data
CONSTANTS:
  gesamtdaten(1)     TYPE c VALUE 'G',
  auswahldaten(1)    TYPE c VALUE 'X',
* Mark
  markiert(1)        TYPE c VALUE 'M',
  nicht_markiert(1)  TYPE c VALUE ' ',
* Mode
  detail_bild(1)     TYPE c VALUE 'D',
  list_bild(1)       TYPE c VALUE 'L',
* Delete
  geloescht(1)       TYPE c VALUE 'D',
  nicht_geloescht(1) TYPE c VALUE ' ',
* selected
  by_field_contents(1) TYPE c VALUE 'I',
* time dependent objects: display mode
  expanded(1)          TYPE c VALUE ' ',                "#EC NEEDED
  collapsed(1)         TYPE c VALUE 'C',                "#EC NEEDED
  collapsed_displd(1)  TYPE c VALUE 'D'.                "#EC NEEDED
* others
CONSTANTS:
  update_geloescht(1) TYPE c VALUE 'Y',
  neuer_geloescht(1)  TYPE c VALUE 'X',
  dummy_geloescht(1)  TYPE c VALUE 'Z',
  neuer_eintrag(1)    TYPE c VALUE 'N',
  uebergehen(1)       TYPE c VALUE '*',
  leer(1)             TYPE c VALUE 'L',
  original(1)         TYPE c VALUE ' ',
  bcset_only(1)       TYPE c VALUE 'B'.      "Show only data from bcset

CONSTANTS: vim_scrform_domain LIKE dd03p-domname VALUE 'TDFORM',
           vim_delim_date_domain LIKE dd03p-domname VALUE 'DATUM',
           vim_begdate_dtel1 LIKE dd03p-rollname VALUE 'BEGDATUM',
           vim_begdate_dtel2 LIKE dd03p-rollname VALUE 'BEGDA',
           vim_begdate_dtel3 LIKE dd03p-rollname VALUE 'ISH_BEGDT',
           vim_begdate_dtel4 LIKE dd03p-rollname VALUE 'VIM_BEGDA',
           vim_enddate_dtel1 LIKE dd03p-rollname VALUE 'ENDDATUM',
           vim_enddate_dtel2 LIKE dd03p-rollname VALUE 'ENDDA',
           vim_enddate_dtel3 LIKE dd03p-rollname VALUE 'ISH_ENDDT',
           vim_enddate_dtel4 LIKE dd03p-rollname VALUE 'VIM_ENDDA'.
CONSTANTS: BEGIN OF vim_adrnbr_domains,
             dom1 LIKE dd03p-domname VALUE 'ADRNR',
             dom2 LIKE dd03p-domname VALUE 'CADRNR',
             dom3 LIKE dd03p-domname VALUE 'AD_ADDRNUM',
           END OF vim_adrnbr_domains,
           vim_addr_e071k_master TYPE sobj_name VALUE 'ADDRESS',
                                                "UF688403/2000
           vim_addr_e071k_master_46 TYPE sobj_name VALUE 'ADDRESS_4.6'.
"UF688403/2000


CONSTANTS: vim_sbscr_prog LIKE d020s-prog VALUE 'SAPLSVCM', "#EC NEEDED
           vim_sbscr_dnum LIKE d020s-dnum VALUE '0101',     "#EC NEEDED
           vim_locked_in_corr LIKE vimstatus-corr_nbr VALUE 'LOCKED',
           vim_dummy_mainkey TYPE c VALUE 'K',
           vim_no_mkey_not_procsd(1) TYPE c VALUE 'X',
           vim_no_mkey_procsd_patt(2) TYPE c VALUE 'XY',
           vim_no_mkey_not_procsd_patt(2) TYPE c VALUE 'YX',
           vim_source_entry(1) TYPE c VALUE 'O',
           vim_clidep(1) TYPE x VALUE '02',
           vim_auth_initial_check(1) TYPE c VALUE 'I',
           vim_auth_switch_to_update_mode(1) TYPE c VALUE 'U',
           vim_auth_requested_check(1) TYPE c VALUE 'R'.

CONSTANTS: vim_tb_read_single_form(23) TYPE c
                                  VALUE 'TABLE_READ_SINGLE_ENTRY'.
DATA:      compl_formname(30) TYPE c VALUE 'COMPL_',
           corr_formname(30) TYPE c VALUE 'CORR_MAINT_',
           BEGIN OF vim_read_single_form,
            prefix(18) TYPE c VALUE 'READ_SINGLE_ENTRY_',
            viewname LIKE tvdir-tabname,
           END OF vim_read_single_form,
           BEGIN OF vim_read_single_form_40,
            prefix(12) TYPE c VALUE 'READ_SINGLE_',
            viewname LIKE tvdir-tabname,
           END OF vim_read_single_form_40.

* state fields
DATA: status TYPE state_vector,
* BEGIN OF STATUS,
*   TYPE(1)   TYPE C VALUE '2',        " E=Einstufig Z=Zweistufig
*   ACTION(1) TYPE C VALUE 'U',   " S=Anz., U=Änd., A=Hinzuf.,T=Tr
*   MODE(1)   TYPE C VALUE 'L',   " L=Liste, D=Detail
*   DATA(1)   TYPE C VALUE 'G',   " G=gesamt, X=Extract, D=Geloeschte
*   MARK(1)   TYPE C VALUE ' ',        " M=Markiert,  =Nicht Markiert
*   DELETE(1) TYPE C VALUE ' ',        " D=Gelöscht,  =Nicht Gelöscht
*   FILL1(1)  TYPE C VALUE ' ',        "filler, not used
*   FILL2(1)  TYPE C VALUE ' ',        "     - " -
* END OF STATUS,

  BEGIN OF title,
   action(1) TYPE c VALUE 'U',    " S=Anzeigen, U=Ändern, H=Hinzufügen
   mode(1)   TYPE c VALUE 'L',         " L=Liste, D=Detail
   data(1)   TYPE c VALUE 'G',    " G=Gesamt, X=Extrakt, D=Geloeschte
  END OF title.

* data containers and description
************************************************************************
DATA:  vim_for_alignment_only TYPE f,   "never remove!!!
       vim_view_wax TYPE tabl8000,
       vim_ctabkeylen TYPE sy-fleng.    "key length in characters

* other fields
DATA:
  vim_ale_keyspec_check(1) TYPE c,     "Flag: .......
  vim_sync_keyspec_check(1) TYPE c,     "Flag: keys locked by sync
  vim_sync_key_lock(1) TYPE c,  "Flag: current dataset locked by sync
  vim_sync_key_lock_del(1) TYPE c, "Flag: current dataset locked by sync
  vim_sctm_sourcesys TYPE logsys, "Logic system to maintain locked data
  vim_ale_keyspec_objtab TYPE vim_ale_keyspec_objs OCCURS 1
                              WITH HEADER LINE,
  vim_delim_expa_excluded(1) TYPE c,   "Flag: .....
  vim_auth_event(1) TYPE c,
  vim_auth_action(1) TYPE c.
DATA:
  vim_auth_rc LIKE sy-subrc, "0-ok, 4-show only, 8-no_authority->exit
  vim_auth_msgid LIKE sy-msgid,
  vim_auth_msgno LIKE sy-msgno,
  vim_auth_msgv1 LIKE sy-msgv1,
  vim_auth_msgv2 LIKE sy-msgv2,
  vim_auth_msgv3 LIKE sy-msgv3,
  vim_auth_msgv4 LIKE sy-msgv4,
  vim_no_warning_for_cliindep(1) TYPE c, "Flag: ......
  vim_begdate_is_ro(1) TYPE c, "Flag: nokey-datefield is readonly
  vim_addr_field_selection LIKE addr1_fsel-fisel,  "for ADDR_DIALOG_PREPA
  vim_addr_keywords LIKE addr1_keyw,    "  - " -
  vim_addr_titlebar LIKE sy-title,     "  - " -
  vim_addr_chng_deflt_comm_types LIKE addr_comm,   "  - " -
  vim_addr_frame_text LIKE addr_frame,  "  - " -
  vim_addr_excluded_functions LIKE vimexclfun     "  - " -
                              OCCURS 0 WITH HEADER LINE,
  vim_upgr_address_number LIKE addr1_sel-addrnumber.
DATA:
  vim_skip_adr_maint TYPE xfeld,                            "UF120400
  vim_texttab_is_ro(1) TYPE c,
  vim_system_type(10) TYPE c,          "SAP/CUSTOMER
  vim_nbr_of_scrfrm_pointers TYPE i,
  vim_enq_s_u_rc LIKE sy-subrc,
  vim_addr_e071k_tab LIKE TABLE OF e071k INITIAL SIZE 0,
  vim_addr_e071_tab LIKE TABLE OF e071 INITIAL SIZE 0,
  vim_tsadrv LIKE tsadrv,              "Addresses: TSADRV-entry
  vim_addr_group LIKE tsadrv-addr_group,
  vim_addr_basetable LIKE dd03l-tabname,
  vim_addr_bastab_field LIKE dd03l-fieldname.
DATA:
  vim_show_consistency_alert(1) TYPE c VALUE 'X',
  vim_import_testmode(1) TYPE c,
  vim_import_forcemode(1) TYPE c,
  vim_import_profile(1) TYPE c,        "Profilimport
  vim_profile_errorkey LIKE scpracpr-tablekey,
  vim_abort_saving(1) TYPE c,          " 'X' -> Sichern abbrechen
  vim_import_no_message(1) TYPE c,
  vim_single_entry_function TYPE vimty_tcode,
  vim_single_entry_ins_key_input LIKE tvdir-flag,
  vim_import_mode_active(1) TYPE c.
DATA:
  vim_last_logged_message TYPE vimty_message,
  vim_copy_call_level TYPE i,
  vim_nr_entries_to_copy TYPE i,       "SW 510129/1999
  vim_no_dialog(1) TYPE c,             "flag:......
  vim_modify_screen(1) TYPE c,         "Modul-lokales Flag
  vim_object LIKE vimdesc-viewname,
  vim_objfield LIKE vimnamtab-viewfield,
  vim_results_of_ext_mod LIKE vimmodres,
  vim_called_by_cluster(1) TYPE c,
  vim_calling_cluster TYPE vcl_name,
  vim_enqueue_range(1) TYPE c,
  vim_view_name LIKE vimdesc-viewname.
DATA:
  replace_mode(1) TYPE c,
  vim_restore_mode(1) TYPE c,
  vim_external_mode(1) TYPE c,
  vim_extcopy_mode(1) TYPE c,
  vim_special_mode(1) TYPE c,          "O-reset,R-replace,U-upgrade
  vim_special_adjust_mode(1) TYPE c,
  vim_adjust_middle_level_mode(1) TYPE c,
  maint_mode TYPE c,
  update_flag(1) TYPE c VALUE ' ',
  adrnbr_roflag(1) TYPE c VALUE ' '.
DATA:
  block_sw    TYPE c VALUE ' ',
  block_1     LIKE sy-tabix,
  block_2     LIKE sy-tabix,
  liste       LIKE d020s-dnum,
  detail      LIKE d020s-dnum,
  returncode  LIKE ocus-returncode,                         "#EC NEEDED
  viewtitle   LIKE ocus-tabtitle,                           "#EC NEEDED
  tablen      LIKE ocus-tablen,                             "#EC NEEDED
  keylen      LIKE ocus-keylen,                             "#EC NEEDED
  anzahl      TYPE i,
  answer(1)   TYPE c,
  neuer(1)    TYPE c VALUE 'N',
  ok_code     LIKE sy-ucomm,           "(4) type c,    SW, wg Controls
  function    LIKE sy-ucomm,           "(4) type c,
  relation(2) TYPE c VALUE 'EQ',                              "#EC NEEDED
  counter LIKE sy-fdpos.
DATA:
  mark_extract TYPE i,
  mark_total   TYPE i,
  l LIKE sy-tabix,
  o TYPE i,
  old_nl LIKE sy-tabix,                                     "GKPR - 0001009660
  pos TYPE i,
  refcnt TYPE i,
  newcnt TYPE i,
  orgcnt TYPE i,
  last_view_info LIKE dd02v-tabname,
  vim_last_objh_view LIKE dd02v-tabname,
  vim_act_dynp_view LIKE dd02v-tabname,
  vim_ale_edit_lock(1) TYPE c,                              "flag:.....
  vim_sync_edit_lock(1) TYPE c,
  vim_ale_msgid LIKE sy-msgid,
  vim_ale_msgno LIKE sy-msgno,
  vim_ale_msgv1 LIKE sy-msgv1,
  vim_ale_msgv2 LIKE sy-msgv2,
  vim_ale_msgv3 LIKE sy-msgv3,
  vim_ale_msgv4 LIKE sy-msgv4.
DATA:                                                       "#EC NEEDED
  last_corr_number LIKE e070-trkorr,
  fill_extr_first_proc TYPE c,       "flag: Fill_extract first time proc
* F(30) TYPE C,  "4.0 name extension "max. Länge ABAP-Feldnamen: 30 Zchn
  f LIKE d021s-fnam,
* SUBSETID_RECEIVED TYPE C,          "flag: subset ID already received
  e071k_tab_modified TYPE c,          "flag:                 "#EC NEEDED
  sel_field_for_replace(30) TYPE c,    "field selected for replace
*  sel_field_for_replace_l(30) TYPE c,  "field selected for replace long
* XB H655767
  sel_field_for_replace_l(40) type c,  "field selected for replace long
* CORR_NBR LIKE TADIR-KORRNUM,       "current corr.nbr
  corr_nbr LIKE e070-trkorr,           "current corr.nbr
  master_type LIKE tadir-object VALUE 'TABU', "master object to transp.
  master_name LIKE tadir-obj_name,     "name of object to transport
  vim_client_state LIKE t000-cccoractiv,   " state of client for transport
  get_corr_keytab(1) TYPE c,           "Flag: keytab is to read
  last_ext_modif_view LIKE tvdir-tabname,                   "flag:
  deta_mark_safe(1) TYPE c,
  ignored_entries_exist(1) TYPE c,                          "flag:
  corr_action(1) TYPE c,             "current action for UPDATE_CORR_KEY
  replace_texttable_field(1) TYPE c, "flag: replace function for textfld
  nbrd_texts_alr_read(1) TYPE c.     "flag: texts from SVIM already read
DATA:
  svim_text_001(35) TYPE c,            "numbered text of SVIM
  svim_text_002(35) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_003(35) TYPE c,            "numbered text of SVIM
  svim_text_004(35) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_005(35) TYPE c,            "numbered text of SVIM
  svim_text_006(35) TYPE c,            "numbered text of SVIM
  svim_text_007(35) TYPE c,            "numbered text of SVIM
  svim_text_008(35) TYPE c,            "numbered text of SVIM
  svim_text_009(36) TYPE c,            "numbered text of SVIM
  svim_text_010(35) TYPE c,            "numbered text of SVIM
  svim_text_011(35) TYPE c,            "numbered text of SVIM
  svim_text_012(35) TYPE c,            "numbered text of SVIM
  svim_text_013(35) TYPE c,            "numbered text of SVIM
  svim_text_014(35) TYPE c,            "numbered text of SVIM
  svim_text_015(35) TYPE c,            "numbered text of SVIM
  svim_text_016(35) TYPE c,            "numbered text of SVIM
  svim_text_017(35) TYPE c,            "numbered text of SVIM
  svim_text_018(35) TYPE c,            "numbered text of SVIM
  svim_text_019(35) TYPE c,            "numbered text of SVIM
  svim_text_020(35) TYPE c,            "numbered text of SVIM
  svim_text_021(35) TYPE c,            "numbered text of SVIM
  svim_text_022(35) TYPE c,            "numbered text of SVIM
  svim_text_023(35) TYPE c,            "numbered text of SVIM
  svim_text_024(35) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_025(35) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_026(35) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_027(13) TYPE c,            "numbered text of SVIM
  svim_text_028(06) TYPE c,            "numbered text of SVIM
  svim_text_029(20) TYPE c,            "numbered text of SVIM
  svim_text_030(35) TYPE c,            "numbered text of SVIM
  svim_text_031(35) TYPE c,            "numbered text of SVIM
  svim_text_032(35) TYPE c,            "numbered text of SVIM
  svim_text_033(35) TYPE c,            "numbered text of SVIM
  svim_text_034(35) TYPE c,            "numbered text of SVIM
  svim_text_035(35) TYPE c,            "numbered text of SVIM
  svim_text_036(35) TYPE c,            "numbered text of SVIM
  svim_text_037(35) TYPE c,            "numbered text of SVIM
  svim_text_038(35) TYPE c,            "numbered text of SVIM
  svim_text_039(35) TYPE c,            "numbered text of SVIM
  svim_text_040(35) TYPE c,            "numbered text of SVIM
  svim_text_041(20) TYPE c,            "numbered text of SVIM
  svim_text_042(20) TYPE c,            "numbered text of SVIM
  svim_text_043(40) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_044(40) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_045(20) TYPE c,            "numbered text of SVIM
  svim_text_046(20) TYPE c,            "numbered text of SVIM
  svim_text_104(19) TYPE c,            "numbered text of SVIM
  svim_text_p01(20) TYPE c,            "numbered text of SVIM
  svim_text_p02(20) TYPE c,            "numbered text of SVIM
  svim_text_p03(20) TYPE c,            "numbered text of SVIM
  svim_text_prb(40) TYPE c,            "numbered text of SVIM
  svim_text_prc(40) TYPE c,            "numbered text of SVIM
  svim_text_pre(40) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_prf(70) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_prg(70) TYPE c,            "numbered text of SVIM "#EC NEEDED
  svim_text_pri(40) TYPE c,            "numbered text of SVIM
  svim_text_prj(40) TYPE c,            "numbered text of SVIM
  svim_text_det(40) TYPE c.            "numbered text of SVIM

DATA:
      TCTRL_MEREP_801T TYPE TABLE OF merep_801T,
      TCTRL_MEREP_807 TYPE TABLE OF merep_807.
DATA:
  vim_marked(1) TYPE c,                "mark-checkbox field
  vim_frame_field LIKE dd25v-ddtext,   "name of frame (subset fields only)
  vim_position_info(42) TYPE c,        "field for 'entry x of y'
  vim_position_info_mask(42) TYPE c, "mask for field for 'entry x of y'
  vim_fpool_name LIKE trdir-name,                             "#EC NEEDED
  vim_posi_push(25) TYPE c,          "push button to posit on list scrn
  temporal_delimitation_happened TYPE c,                    "flag: ....
  vim_mkey_after_exists(1) TYPE c,                          "flag: ....
  vim_no_mainkey_exists(1) TYPE c,                          "flag: ....
  nbr_of_added_dummy_entries TYPE i,   "for function NEWL: ...
  vim_next_screen LIKE tvdir-liste,    "next screen number
  vim_leave_screen(1) TYPE c,          "flag: leave screen necessary
  vim_prtfky_assigned(1) TYPE c,                            "flag...
* VIM_EXTRACT_MODIFIED(1) TYPE C,    "flag...
  vim_temp_delim_alr_checked(1) TYPE c,                     "flag...
  vim_ignore_collapsed_mainkeys(1) TYPE c,                  "flag...
  vim_corr_obj_viewname LIKE tvdir-tabname.
DATA:
  vim_last_source_system LIKE tadir-srcsystem,
  vim_slct_functiontext(40) TYPE c,"HCG HW711274              "#EC NEEDED
  vim_comp_menue_text(40) TYPE c,
  vim_key_alr_checked(1) TYPE c,       "flag: .....
  vim_keyrange_alr_checked(1) TYPE c,  "flag: .....
  vim_prt_fky_flds_updated(1) TYPE c,  "flag: .....
  vim_exit_11_12_active(1) TYPE c,     "flag: .....
  BEGIN OF vim_default_rfc_dest,       "global vector for default
    viewname LIKE tvdir-tabname,       "RFC-destination
    rfcdest LIKE rfcdes-rfcdest,
  END OF vim_default_rfc_dest.
DATA:
  BEGIN OF vim_default_upgr_clnt,      "global vector for default
    viewname LIKE tvdir-tabname,        "client for upgrade
    client LIKE sy-mandt,
  END OF vim_default_upgr_clnt,
  vim_title_name LIKE vimdesc-ddtext,
  vim_tabctrl_active(1) TYPE c,
  vim_tc_cols TYPE cxtab_column,
  vim_local_char1(1) TYPE c.           "Modul-lok. Hilfsvariable  "#EC NEEDED

* data for time-dependent routines (VCX)
FIELD-SYMBOLS: <key_date> TYPE ANY.
DATA: BEGIN OF d0001_field_tab OCCURS 10,
        begin TYPE d, end TYPE d, mark(1) TYPE c,
      END OF d0001_field_tab,
      d0001_cursor TYPE i,
      BEGIN OF d0001_status,
        type(1)   TYPE c,
        action(1) TYPE c,
        mode(1)   TYPE c,
        data(1)   TYPE c,
        mark(1)   TYPE c,
        delete(1) TYPE c,
        fill1(1)  TYPE c,              "filler, not used
        fill2(1)  TYPE c,                                   "     - " -
        spec_mode TYPE c,
      END OF d0001_status.
DATA: d0001_input_flag(1) TYPE c,
      vim_mainkey TYPE vim_tabkey_c,   "field for mainkey (prt. forkey)
      current_date TYPE d,
      date_to_delimit TYPE d,
      date_to_posit TYPE d,
      vim_old_viewkey TYPE vim_tabkey_c,
      date_safe TYPE d,
      vim_old_st_selected(1) TYPE c,
      BEGIN OF vim_memory_id_1,  "memory-ID for vim_collapsed_entries
        viewname LIKE vimdesc-viewname,
        user     LIKE sy-uname,
      END OF vim_memory_id_1.
DATA: BEGIN OF vim_memory_id_2,  "memory-ID for date subscreen data
        viewname LIKE vimdesc-viewname,
        user     LIKE sy-uname,
      END OF vim_memory_id_2,
      vim_date_mask(8) TYPE c VALUE '++++++++',
      vim_coll_mkeys_first(1) TYPE c,
      vim_merge_begin TYPE i,
      vim_merge_end TYPE i,
      vim_begdate_entered(1) TYPE c,
      BEGIN OF vim_begdate_name,
        tabname LIKE vimdesc-viewname,
        dash(1) TYPE c VALUE '-',
        fieldname LIKE vimnamtab-viewfield,
      END OF  vim_begdate_name.
DATA: BEGIN OF vim_enddate_name,
        tabname LIKE vimdesc-viewname,
        dash(1) TYPE c VALUE '-',
        fieldname LIKE vimnamtab-viewfield,
      END OF  vim_enddate_name,
      vim_last_coll_mainkeys_ix TYPE i,
      vim_coll_mainkeys_beg_ix TYPE i VALUE 1,
      check_all_keyr_scnd_time(1) TYPE c, "Flag: .........
      vim_tdep_title(19) TYPE c.
CONSTANTS: vim_init_date TYPE d VALUE '00000000'.         "#EC VALUE_OK


* data for navigation within internal tables
DATA:
  aktuell(10) TYPE n,
  maximal(10) TYPE n,
  index     LIKE sy-tabix,
  exind     LIKE sy-tabix,
  mandant   LIKE sy-mandt,
  curline   LIKE sy-tabix,             "Cursor-Position in Tab. "#EC NEEDED
  curpage   LIKE sy-tabix VALUE 1,     "aktuelle Seite          "#EC NEEDED
  firstline LIKE sy-tabix VALUE 1,
  nextline  LIKE sy-tabix VALUE 1,
                            "Pos. erste Zeile der akt. Seite in Tab.
  anz_lines LIKE sy-tabix,             "Anzahl vorhandener Tab.-Zeilen  "#EC NEEDED
  anz_pages LIKE sy-tabix,             "Anzahl vorhandener Tab.-Seiten
  maxlines  LIKE sy-tabix,             "Anzahl vorhandener Tab.-Zeilen
  destpage  LIKE sy-tabix,  "Seite, auf die geblättert werden soll
  looplines LIKE sy-tabix.  "Anzahl Step-loop-Zeilen im Dynpro

* declarations for activating bc-sets                 "UF profile
TYPES: BEGIN OF vim_pr_tab_type,
                recnumber LIKE scprvals-recnumber,
                action TYPE char1,
                keys_fix,                                   "#EC NEEDED
                align TYPE f,
                keys(1024) TYPE x,
                txt_in_sy_langu_exsts TYPE xfeld,
                align2 TYPE f,
                textrecord TYPE vim_line_ul,
       END OF vim_pr_tab_type.
TYPES: BEGIN OF vim_pr_fields_type,
                recnumber LIKE scprvals-recnumber,
                keys_fix(1),
                fields TYPE vimty_fields_tab_type,
       END OF vim_pr_fields_type,
       vimsellist_type TYPE TABLE OF vimsellist,
       BEGIN OF  bc_key_type,   "HCG like e072k but tabkey 255
          trkorr like e071k-trkorr,
          pgmid like e071k-pgmid,
          object like e071k-object,
          objname like e071k-objname,
          as4pos like e071k-as4pos,
          mastertype like e071k-mastertype,
          mastername like e071k-mastername,
          viewname like e071k-viewname,
          objfunc like e071k-objfunc,
          bc_tabkey like scpractr-tabkey,
          sortflag like e071k-sortflag,
          flag like e071k-flag,
          lang like e071k-lang,
          activity like e071k-activity,
       END OF bc_key_type,
       bc_keytab_type type table of bc_key_type,
* For managing entries coming from bc-sets
vim_bc_tab_logs type table of scpractr,
vim_bc_del_records type table of scprreca,
vim_bc_values_lang_type type table of scpr_vall.
DATA:  vim_pr_fields TYPE TABLE OF vim_pr_fields_type INITIAL SIZE 15,
       vim_pr_fields_wa TYPE vim_pr_fields_type,
       vim_coming_from_img,                                 "#EC NEEDED "'Y': coming from IMG, 'N': not
       vim_pr_tab TYPE TABLE OF vim_pr_tab_type,
       vim_profile_values TYPE TABLE OF scpr_vals INITIAL SIZE 50,
       vim_bc_entry_list TYPE vimty_bc_entry_list_ttype,
       vim_bc_entry_list_wa TYPE vimty_bc_entry_list_type,
       vim_pr_activating, vim_bc_keys_fix(3),               "#EC NEEDED
       vim_set_from_bc_pbo,
       vim_bc_chng_allowed TYPE xfeld, "fix bc-set values modifiable
       vim_pr_records TYPE i.    "number of activated profile records
DATA:  vim_actlinks TYPE vimdesc-viewname. "View: actlinks are valid for
DATA:  vim_actopts TYPE scpractopt, "Activation options at BC-SET import
       vim_bcset_id TYPE scpr_id.                        "Name of BC-SET
* field attributes in profiles
CONSTANTS: vim_profile_fix(3)    VALUE 'FIX',
           vim_profile_fixkey(3) VALUE 'FKY',
           vim_profile_use(3)    VALUE 'USE',
           vim_profile_key(3)    VALUE 'KEY',
           vim_profile_usekey(3) VALUE 'UKY',                "#EC NEEDED
           vim_profile_var(3)    VALUE 'VAR',               "824950
* for flag KEYS_FIX
           vim_pr_error    VALUE 'E',                       "key error
           vim_pr_open     VALUE 'O',  "no key field fix
           vim_pr_some_fix VALUE 'S',                       "some fix
           vim_pr_all_fix  VALUE 'A',  "all key fields fix
* others
           vim_pr_into_view VALUE 'V',
           vim_profile_found VALUE 'X',
           vim_pr_imp_unchecked VALUE 'Y',
           vim_writing_bc_imp_log VALUE 'W'.
DATA:      vim_pr_stat_txt_me LIKE smp_dyntxt,  "dynamic texts for dynpro
           vim_pr_stat_txt_ch LIKE smp_dyntxt,
           vim_pr_stat_txt_ta LIKE smp_dyntxt,
           vim_pr_stat_txt_or LIKE smp_dyntxt.
* internal tables
DATA: vim_adj_header LIKE vimdesc OCCURS 1,
      vim_adj_namtab LIKE vimnamtab OCCURS 0,
      vim_adj_dbasellist LIKE vimsellist OCCURS 0.
DATA: vim_locked_addresses LIKE SORTED TABLE OF adrc-addrnumber
                           WITH UNIQUE KEY table_line
                           INITIAL SIZE 10
                           WITH HEADER LINE.

DATA: BEGIN OF vim_addresses_to_save OCCURS 10,
        viewname LIKE tvdir-tabname,
        addrnumber LIKE adrc-addrnumber,
        handle LIKE addr1_dia-handle,
      END OF vim_addresses_to_save.

DATA: BEGIN OF textpool_tab OCCURS 30.                       "textpool
        INCLUDE STRUCTURE textpool.
DATA: END OF textpool_tab.

DATA: BEGIN OF exclude_tab OCCURS 10,   "fields to exclude from repl
        field LIKE d021s-fnam,         "functions (old version)
      END OF exclude_tab.

DATA: excl_rpl_tab TYPE vimexclfldtab  "fields to exclude from repl
        WITH HEADER LINE,
      excl_que_tab TYPE vimexclfldtab  "fields to exclude from query
        WITH HEADER LINE,
      excl_pos_tab TYPE vimexclfldtab  "fields to exclude from posit
        WITH HEADER LINE,
      vim_excl_xxx_tab_safe TYPE vimexclfldtabs "safe for all excl tabs
        WITH HEADER LINE.

DATA: BEGIN OF vim_corr_objtab OCCURS 10.       "transport objects on the
        INCLUDE STRUCTURE e071.       "vim-object level
DATA:   lockable(1) TYPE c,
      END OF vim_corr_objtab.

DATA: BEGIN OF vim_corr_entryobjtab OCCURS 10.  "transport objects "#EC NEEDED
        INCLUDE STRUCTURE ko200.       "on the vim-obj-entries level
DATA:   lockable(1) TYPE c,
      END OF vim_corr_entryobjtab.

DATA: BEGIN OF e071k_tab OCCURS 100.    "keys of changed entries
        INCLUDE STRUCTURE e071k.       "(used as parameter for VIEWPROC)
DATA: END OF e071k_tab.

DATA: vim_alv_fcat TYPE slis_t_fieldcat_alv,  "ABAP List Viewer
*      vim_alv_excluding TYPE slis_t_extab,
*      vim_alv_special_groups TYPE slis_t_sp_group_alv,
*      vim_alv_sort TYPE slis_t_sortinfo_alv,
*      vim_alv_sel_hide TYPE slis_sel_hide_alv,
      vim_alv_events TYPE slis_t_event,
*      vim_alv_event_exit TYPE slis_t_event_exit,
      vim_alv_print TYPE slis_print_alv,
      vim_alv_layout TYPE slis_layout_alv,
      vim_alv_variant LIKE disvariant,
      vim_var_save, vim_var_default, vim_alv_value_length TYPE intlen,
      vim_alv_called_by TYPE char30,
      alv_value_tab TYPE TABLE OF tabl8000 INITIAL SIZE 500.
*DATA: BEGIN OF alv_value_tab OCCURS 1,
*      line(4096),
*      END OF alv_value_tab.

DATA: align_value_tab TYPE f,                                       "#EC NEEDED
      BEGIN OF value_tab OCCURS 1,     "Printing with ALV ==>
        line(4096),                                         "
      END OF value_tab.                                      "obsolete

DATA: BEGIN OF structure_table OCCURS 20.   "Printing with ALV ==>
        INCLUDE STRUCTURE dfies.                           "
DATA: END OF structure_table.                               "obsolete

DATA: vim_list_header TYPE slis_t_listheader. "List header for ALV-list

DATA: vim_delim_entries TYPE STANDARD TABLE  "indizes of delim. entries
        OF vim_delim_entr_tl WITH DEFAULT KEY INITIAL SIZE 10
        WITH HEADER LINE.

DATA: BEGIN OF vim_sval_tab OCCURS 1.  "fields for POPUP_GET_VALUES
        INCLUDE STRUCTURE sval.
DATA: END OF vim_sval_tab.

DATA: vim_collapsed_mainkeys TYPE STANDARD TABLE  "collapsed mainkeys
        OF vim_collapsed_mkeys_tl WITH DEFAULT KEY INITIAL SIZE 1
        WITH HEADER LINE.

DATA: vim_merged_entries TYPE STANDARD TABLE      "merged entries
        OF vim_merged_entr_tl WITH DEFAULT KEY INITIAL SIZE 1
        WITH HEADER LINE.

DATA: BEGIN OF vim_copied_indices OCCURS 10,
        ix LIKE sy-tabix, ex_ix LIKE sy-tabix, level TYPE i,
      END OF vim_copied_indices.

DATA: vim_wheretab LIKE vimwheretb OCCURS 10,
      imp_results TYPE slctr_tables_keys WITH HEADER LINE.

* Datencontainer für Texttabelle in mehreren Sprachen     "SW Texttransl
DATA: vim_texttab_container TYPE vim_tabdata_record OCCURS 0
      WITH HEADER LINE,  "da 'read table .. assigning <fs>' nicht unterst
      vim_texttab_container_index LIKE sy-tabix,
      vim_d0100_fdescr_ini TYPE vimty_screen_fdescr_tab.

RANGES: mark_functions FOR sy-ucomm,   "fct. which need marked entries
        adrnbr_domain FOR sadr-adrnr,  "domains for address numbers
        exted_functions FOR sy-ucomm,  "fct. used by external edit
        vim_guid_domain FOR vimnamtab-domname,  "domains for GUIDs
        vim_begda_types FOR dd03p-rollname,  "types for time-dependence
        vim_endda_types FOR dd03p-rollname.  "types for time-dependence

* constants for documentation 'User Instructions'
CONSTANTS: vim_docu_prog LIKE iwreferenc-programm VALUE 'SAPLSVIM',
           vim_docu_extension LIKE iwreferenc-spec_text
                   VALUE 'SM30 USER INTERFACE'.

* Konstanten für Dynpro
CONSTANTS: vim_template_dynpro TYPE x VALUE '20',  " Vorlagedynpro
           vim_standard_dynpro TYPE x VALUE 'C0'.               "#EC NEEDED
            " Komprimierung ein

* Organisation criteria (linedependent authorisations)
DATA:  vim_oc_inst TYPE REF TO cl_viewfields_org_crit.

* Backup for DBA_SELLIST
DATA  vim_dba_sel_kept TYPE svorg_vimsellist_type.              "#EC NEEDED

Data  addr_comp TYPE c.

DATA  vim_first_recnum TYPE scprvals-recnumber.

* Handling of GUID's while Copying in View Cluster.
DATA: vim_guid_copy TYPE C.

*Suppression of transport dialogs in view maintenance
DATA: vim_no_dialog_req TYPE sap_bool,
      vim_cts_messages  TYPE cts_messages.
