TYPE-POOL vimty .
TYPES: BEGIN OF vimty_message,
         id LIKE sy-msgid, type LIKE sy-msgty, nbr LIKE sy-msgno,
         v1 LIKE sy-msgv1, v2 LIKE sy-msgv2, v3 LIKE sy-msgv3,
         v4 LIKE sy-msgv4,
       END OF vimty_message,

       vimty_tablename LIKE vimdesc-viewname,
       vimty_tablefield LIKE vimnamtab-viewfield,
       vimty_viewfields TYPE vimty_tablefield OCCURS 1,
       BEGIN OF vimty_relation,
         tablename TYPE vimty_tablename,
         tabfield TYPE vimty_tablefield,
         tablength TYPE i,             " internal length of TABFIELD
         taboffset TYPE i,             " offset of TABFIELD in TABLENAME
         prevtabname TYPE vimty_tablename,
         prevtabfield TYPE vimty_tablefield,
       END OF vimty_relation,
       BEGIN OF vimty_basetabledata,
         line(4096) TYPE x,
       END OF vimty_basetabledata,

       vimty_relations TYPE vimty_relation OCCURS 1,

       BEGIN OF vimty_viewbasetable,
         tablename TYPE vimty_tablename,
         prevtab   TYPE vimty_tablename,
         tabkeylen TYPE i,             "length of keyfields of TABLENAME
         keyorder(1) TYPE c,  "'X' ident. Schlüsselaufbau in TAB u. View
                              "'T'   "       "       " bis auf SPRASL
         direction(1) TYPE c,
         update(1) TYPE c,
         no_flds_in_view(1) TYPE c,
         must_be_read(1) TYPE c,
         data_alr_read(1) TYPE c,
         data      TYPE vimty_basetabledata OCCURS 0,
         relations TYPE vimty_relations,
       END OF vimty_viewbasetable,

       vimty_viewbasetables TYPE vimty_viewbasetable OCCURS 1,

       BEGIN OF vimty_viewdata,
         header LIKE vimdesc OCCURS 1,
         namtab LIKE vimnamtab OCCURS 1,
         sellist LIKE vimsellist OCCURS 1,
         data TYPE vimty_viewbasetables,
       END OF vimty_viewdata,

       vimty_tcode(4) TYPE c.

* Definitionen für Texterfassung in mehreren Sprachen  "SW Texttransl ..
CONSTANTS: vimty_max_keylen TYPE i VALUE 255,
           vimty_max_textlen TYPE i VALUE 255.

TYPES: vimty_max_textline(vimty_max_textlen) TYPE c,

       BEGIN OF vimty_textfield,
         namtab_idx LIKE sy-tabix,     " Index in VIMNAMTAB für Text
         outplen LIKE vimnamtab-outputlen, " max. Länge von TEXTLx
         text TYPE vimty_max_textline,
       END OF vimty_textfield,

       BEGIN OF vimty_textmaint_record,
         keys(vimty_max_keylen) TYPE c," interne Repr.
         keytab TYPE vimty_textfield OCCURS 0,
         spras LIKE t002-spras,
         sptxt LIKE t002t-sptxt,
         action(1) TYPE c,
         texttab TYPE vimty_textfield OCCURS 0,
       END OF vimty_textmaint_record,

       vimty_multilangu_texttab TYPE vimty_textmaint_record OCCURS 0,

       BEGIN OF vimty_screen_fdescr,
         name(30)  TYPE c,
         title LIKE vimnamtab-scrtext,
         textfld(1) TYPE c,            " 'X' -> Textfeld
         active(1) TYPE c,
         fixlength TYPE i,
         vislength TYPE i,
       END OF vimty_screen_fdescr,

       vimty_screen_fdescr_tab TYPE vimty_screen_fdescr OCCURS 0.
*                                                     ".. SW Texttransl
* Types for importing BC-sets
TYPES: BEGIN OF vimty_fields_type,
                fieldname TYPE scpr_fld,
                flag TYPE scpr_flag,
       END OF vimty_fields_type,
       vimty_fields_tab_type TYPE STANDARD TABLE OF
        vimty_fields_type WITH NON-UNIQUE KEY fieldname INITIAL SIZE 30,
       BEGIN OF vimty_langu_line,
                 forlangu TYPE sy-langu,
       END OF vimty_langu_line,
       vimty_forlangu_type TYPE STANDARD TABLE OF vimty_langu_line WITH
        NON-UNIQUE KEY forlangu INITIAL SIZE 20,
       BEGIN OF vimty_bc_entry_list_type,
         viewname TYPE tabname,
         id TYPE scpr_id,
         recnumber LIKE scprvals-recnumber,
         align type f,
         keys(1024) TYPE x,
         action TYPE char1,
         fields TYPE vimty_fields_tab_type,
         forlangu TYPE vimty_forlangu_type,
       END OF vimty_bc_entry_list_type,
       vimty_bc_entry_list_ttype TYPE SORTED TABLE OF
        vimty_bc_entry_list_type WITH UNIQUE KEY viewname keys.
* types for using organisation criteria
TYPES: vimty_oc_type TYPE REF TO cl_viewfields_org_crit.

CONSTANTS: vimty_langufld TYPE vimty_tablefield VALUE '@LANGU@'.
*          VIMTY_VIEW TYPE VIMTY_TABLENAME VALUE '@VIEW@',
*          VIMTY_OTHERS TYPE VIMTY_TABLENAME VALUE '@OTHERS@'.
