TYPE-POOL scpr.


* Konstanten für lange Characterstrings
CONSTANTS: scpr_maxkeylen  TYPE i VALUE 1024,
           scpr_maxdatalen TYPE i VALUE 8192,  "max. Breite des TC
           scpr_maxcfldlen TYPE i VALUE 255.   "max. Breite eines
                                               "CHAR-Feldes

* verschiedene tabellentypen
TYPES: scpr_actp_tab     TYPE TABLE OF scpractp,
       scpr_attr_tab     TYPE TABLE OF scprattr,
       scpr_protabl_tab  TYPE TABLE OF scprotabl,
       scpr_reca_tab     TYPE TABLE OF scprreca,
       scpr_vals_tab     TYPE TABLE OF scprvals,
       scpr_vall_tab     TYPE TABLE OF scprvall,
       scpr_fldv_tab     TYPE TABLE OF scprfldv,
       scpr_fld_tab      TYPE TABLE OF scpr_fld,
*       scpr_oprof_tab    TYPE TABLE OF scproprof,  "use 'scproproftab'
       scpr_skeys_tab    TYPE TABLE OF scprskeys,
       scpr_text_tab     TYPE TABLE OF scprtext,
       scpr_clnt_tab     TYPE STANDARD TABLE OF t000,
       scpr_dd26v_tab    type standard table of dd26v,
       scpr_dd27p_tab    type standard table of dd27p,
       scpr_dd28j_tab    TYPE STANDARD TABLE OF dd28j,
       scpr_bccli_tab    TYPE STANDARD TABLE OF scprbccli,
       scpr_sald_tab     TYPE STANDARD TABLE OF scprsald,
       scpr_sali_tab     TYPE STANDARD TABLE OF scprsali,
       scpr_smli_tab     TYPE STANDARD TABLE OF scprsmli,
       scpr_smld_tab     TYPE STANDARD TABLE OF scprsmld,
       scpr_act_id_tab   TYPE STANDARD TABLE OF scpr_id. "used to roll back activations

* Ein Tabellenrecord mit den Feldnamen und Werten
TYPES: BEGIN OF scpr_record %_FINAL,
         tablename  TYPE scprdata-tablename,
         recnumber  TYPE i,
         values     TYPE scpr_value OCCURS 10,
       END OF scpr_record.

* Übergabestruktur für Profilaktivierung
TYPES: scpr_values TYPE scpr_record OCCURS 10.

* Lange RAW-Felder für die Aufnahme ganzer Tabellenrecords
TYPES: BEGIN OF scpr_raw %_FINAL,
         fdummy TYPE f,      "Dieses Feld benötige ich nur für die
                             "korrekte Ausrichtung des folgenden Feldes
         lines  LENGTH scpr_maxdatalen,
       END OF scpr_raw.

* Übergabetabelle für die Daten einer Tabelle in einem Stück
TYPES: scpr_rawtab TYPE scpr_raw OCCURS 10.

* Übergabestruktur für den Pflegedialog, 'mark' kennzeichnet Datensätze,
* die im BC-Set verwendet werden.
TYPES: BEGIN OF scpr_tablerecs_type %_FINAL,
         lines LENGTH scpr_maxdatalen,
         mark,
       END OF scpr_tablerecs_type.

TYPES: scpr_tablerecs TYPE scpr_tablerecs_type OCCURS 10.

TYPES: BEGIN OF scpr_tabrecsl_type %_FINAL,
         lines(32768),
         mark,
       END OF scpr_tabrecsl_type.

TYPES: scpr_tablecsl TYPE scpr_tabrecsl_type OCCURS 10.

* Übergabestruktur für den Pflegedialog
TYPES: BEGIN OF scpr_sellines_type %_FINAL,
        tablename    TYPE scprvals-tablename,
        recnumber    TYPE scprvals-recnumber,
        key          LENGTH scpr_maxkeylen,
        keylng       TYPE i,
      END OF scpr_sellines_type.

* Feldbeschreibung und Datum für ein Tabellenfeld
TYPES: scpr_flddescr TYPE scpr_descr.

* Tabelle von Feldbeschreibungen und Werten
TYPES: scpr_flddescrs TYPE scpr_flddescr OCCURS 10.

* Alle Feldbeschreibungen und Werte eines Tabellenrecords
TYPES: BEGIN OF scpr_record2 %_FINAL,
         tabname          TYPE scprdata-tablename,
         tabtype          TYPE objh-objecttype,
         tabtext          TYPE dd02t-ddtext,
         tablen           TYPE i,  "table length (bytes)
         keylen           TYPE i,  "key length (bytes)
         ckeylen          TYPE i,  "character like key length (bytes)
         objname          TYPE objh-objectname,
         objtype          TYPE objh-objecttype,
         activity         TYPE scprreca-activity,
*        importable       TYPE c,
         status(1)        TYPE c,
         delete(1)        TYPE c,
         descr_reduced(1) TYPE c,
         clnt_fld         TYPE scpr_fld,
         deliverycl       TYPE contflag,
         descr            TYPE scpr_flddescr OCCURS 10,
         sellist          TYPE vimsellist    OCCURS 10,
         header           TYPE vimdesc       OCCURS 10,
         namtab           TYPE vimnamtab     OCCURS 10,
       END OF scpr_record2.

* Feldbeschreibungen und Werte von Tabellenrecords unterschiedlicher
* Tabellen
TYPES: scpr_records TYPE scpr_record2 OCCURS 10.

* Typ für alle Tabellen, die in einem BC Set enthalten sind
TYPES: BEGIN OF scpr_table_in_bcset %_FINAL,
         tabname  TYPE scprdata-tablename,
         tabtype  TYPE objh-objecttype,
         objname  TYPE objh-objectname,
         objtype  TYPE objh-objecttype,
         activity TYPE scprreca-activity,
       END OF scpr_table_in_bcset.

* Tabelle mit allen Tabellen im BC Set
TYPES: scpr_tables_in_bcset TYPE scpr_table_in_bcset OCCURS 10.

* Typ für alle Felder, die in einem BC Set enthalten sind
TYPES: BEGIN OF scpr_field_in_bcset %_FINAL,
         tabname   TYPE scprvals-tablename,
         tabtype   TYPE objh-objecttype,
         fieldname TYPE scprvals-fieldname,
         flag      TYPE scprvals-flag,
       END OF scpr_field_in_bcset.

* Tabelle mit allen Feldern im BC Set
TYPES: scpr_fields_in_bcset TYPE scpr_field_in_bcset OCCURS 10.

* Einfache Tabelle+Feldbeschreibungen-Struktur
TYPES: BEGIN OF scpr_tab_fldescr %_FINAL,
         tabname  TYPE scprdata-tablename,
         tabtype  TYPE objh-objecttype,
         keylen   TYPE i,
         lang_fld TYPE scpr_flddescr-fieldname,
         lang_pos TYPE i,
         descr_reduced(1),
         descr    TYPE scpr_flddescr OCCURS 10,
       END OF scpr_tab_fldescr.
* Tabelle von "Tabelle+Feldbeschreibungen"
TYPES: scpr_tabs_fldescr TYPE STANDARD TABLE OF scpr_tab_fldescr.

* Struktur zur einfachen (Zwischen)Speicherung von Feldnamen
TYPES: BEGIN OF scpr_single_fld %_FINAL,
         fieldname TYPE scpr_fld,
       END OF scpr_single_fld.
TYPES: scpr_fieldnames TYPE scpr_single_fld OCCURS 10.

* Platz für Tabellenrecord in RAW-Format
TYPES: BEGIN OF scpr_rawrec %_FINAL,
         lines TYPE c LENGTH scpr_maxdatalen,
       END OF scpr_rawrec.

* Int. Tabelle mit Tabellenrecords im RAW-Format
TYPES: scpr_rawrecs TYPE scpr_rawrec OCCURS 10.


****************************************************************
* types for bcset activation
****************************************************************
* container for records
TYPES: BEGIN OF scpr_raw2 %_FINAL,
         range        TYPE i,
         tabname      TYPE scprdata-tablename,
         recnumber    TYPE scprreca-recnumber,
         profid       TYPE scprdata-id,
         version      TYPE scprdata-version,
         text         TYPE scprtext-text,
         objname      TYPE scprreca-objectname,
         objtype      TYPE scprreca-objecttype,
         tabtype      TYPE objh-objecttype,
         activity     TYPE scprreca-activity,
         key_complete(1) TYPE c,           "!!!!!!!!!!!!!
         uncomplete   TYPE scprreca-uncomplete,
         deleteflag   TYPE scprreca-deleteflag,
         genref       TYPE scprreca-genref,
         values       TYPE scprvals OCCURS 10,
         valuesl      TYPE scprvall OCCURS 10,
       END OF scpr_raw2.

TYPES: scpr_template TYPE scpr_raw2 OCCURS 10.
types  scpr_raw2_tab type standard table of scpr_raw2.

****************************************************************
* container for tables of subobjects
TYPES: BEGIN OF scpr_part_table %_FINAL,
         tabname  TYPE scpr_tabl,
         tabtype  TYPE objh-objecttype,
       END OF scpr_part_table.

TYPES: scpr_part_tables TYPE scpr_part_table OCCURS 10.

****************************************************************
* container for subobjects
TYPES: BEGIN OF scpr_objval_part %_FINAL,
         tabname    TYPE scpr_tabl,
         tabtype    TYPE objh-objecttype,
         activity   TYPE scprreca-activity,
         tables     TYPE scpr_part_tables,
         texttables TYPE scpr_part_tables,
       END OF scpr_objval_part.

TYPES: scpr_objval_parts TYPE scpr_objval_part OCCURS 10.

****************************************************************
* container for objects
TYPES: BEGIN OF scpr_objval %_FINAL,
         objectname       type objh-objectname,
         objecttype       type scprreca-objecttype,
         objectcategory   type e070-korrdev,
         clidep           type objh-clidep,
         transpcategory   type e070-korrdev,
         transpnumber     type e070-trkorr,
         importable(1)    TYPE c,
         act_flag(1)      TYPE c,
         afterimport      TYPE c,
         mult_obj_aftimp  TYPE objm-multi_obj,
         aftimp_method    TYPE objm-methodname,
         e071             type tr_objects,
       END OF scpr_objval.

TYPES: scpr_objvals TYPE STANDARD TABLE OF scpr_objval.

****************************************************************
* container for object stati during activation
TYPES:  BEGIN OF scpr_object_status %_FINAL,
          objectname     TYPE objh-objectname,
          objecttype     TYPE objh-objecttype,
          bcset          TYPE scpr_id,
          act_status     TYPE scpracst,
        END OF scpr_object_status.

TYPES: scpr_object_stati TYPE TABLE OF scpr_object_status.

****************************************************************
* container for object/table assignment during activation
TYPES:  BEGIN OF scpr_object_change %_FINAL,
          objectname     TYPE objh-objectname,
          objecttype     TYPE objh-objecttype,
          oldobjectname  TYPE objh-objectname,
          oldobjecttype  TYPE objh-objecttype,
          tablename      TYPE scpr_tabl,
          bcset          TYPE scpr_id,
        END OF scpr_object_change.

TYPES: scpr_objects_change TYPE STANDARD TABLE OF scpr_object_change
       WITH KEY objectname objecttype oldobjectname oldobjecttype
                tablename bcset.


****************************************************************
* container for error-messages at activation
TYPES:  BEGIN OF scpr_actmsg %_FINAL,
          msgnum         TYPE symsgno,
          status         TYPE scpracst,
          bcset          TYPE scpr_id,
          objectname     TYPE objh-objectname,
          objecttype     TYPE objh-objecttype,
        END OF scpr_actmsg.

TYPES: scpr_actmsgs TYPE STANDARD TABLE OF scpr_actmsg.


****************************************************************
* Typ für den Vergleich BC-Set / Customizing-Tabelle
TYPES: BEGIN OF scpr_compare %_FINAL,
         bc_set    TYPE scpr_raw2,
         cust_tab  TYPE scpr_raw2,
         conflict_flag TYPE scpr_txt20,
         flddescrs TYPE scpr_flddescrs,
       END OF scpr_compare.
* interne Tabelle dazu
TYPES: scpr_compare_s  TYPE STANDARD TABLE OF scpr_compare
                            INITIAL SIZE 10.


* Tabellenkey und Datenrecord in komprimierter Form
TYPES: BEGIN OF scpr_confl %_FINAL,
         severity,
         tabname   TYPE scprdata-tablename,
         key       LENGTH scpr_maxkeylen,
         rec       LENGTH scpr_maxdatalen,
       END OF scpr_confl.

* Komprimierte Keys und Datenteile
TYPES: scpr_conflicts TYPE scpr_confl OCCURS 10.


* Struktur für Listanzeige von Schlüsselkonflikten
TYPES: BEGIN OF scpr_data_type %_FINAL,
         key       LENGTH scpr_maxkeylen,
         bits(200) TYPE x,
         severity,
         id        TYPE scprvals-id,
         tabname   TYPE scprvals-tablename,
         recnumber TYPE scprvals-recnumber,
         values    TYPE scprvals OCCURS 10,
       END OF scpr_data_type.

* Interne Tabelle zu 'scpr_data_type'
TYPES: scpr_datatab_type TYPE scpr_data_type OCCURS 10.


* Struktur für Listanzeige von Schlüsselkonflikten
* 2. Version, Listanzeige überarbeitet, nur Felder mit Konflikten werden
* angezeigt.
TYPES: BEGIN OF scpr_confl_type %_FINAL,
         severity,
         tabname    TYPE scprvals-tablename,
         id1        TYPE scprvals-id,
         id2        TYPE scprvals-id,
         flddescrs  TYPE scpr_flddescrs,
         values1    TYPE scprvals OCCURS 10,
         values2    TYPE scprvals OCCURS 10,
       END OF scpr_confl_type.

* Interne Tabelle zu 'scpr_data_type'
TYPES: scpr_confltab_type TYPE scpr_confl_type OCCURS 10.


* Struktur zur Übergabe der unspezifizierten Keys an User Interface
TYPES: BEGIN OF scpr_undefkey %_FINAL,
         tablename    TYPE scpr_flddescr-tablename,
         fieldname    TYPE scpr_flddescr-fieldname,
         dataelem     TYPE scpr_flddescr-dataelem,
         fieldtext    TYPE scpr_flddescr-fieldtext,
         outputlen    TYPE scpr_flddescr-outputlen,
         intlen       TYPE scpr_flddescr-intlen,
         vtype        TYPE scpr_flddescr-vtype,
         datatype     TYPE scpr_flddescr-datatype,
         decimals     TYPE scpr_flddescr-decimals,
         convexit     TYPE scpr_flddescr-convexit,
         sign         TYPE scpr_flddescr-sign,
         lowercase    TYPE scpr_flddescr-lowercase,
         value        TYPE scpr_flddescr-value,
         oldvalue     TYPE scpr_flddescr-value,
       END OF scpr_undefkey.

* Int. Tabelle zu undef_key
TYPES: scpr_undefkeys TYPE scpr_undefkey OCCURS 10.

* Struktur zur Übergabe der unspezifizierten Keys an User Interface
TYPES: BEGIN OF scpr_undefkey2 %_FINAL,
         bcset        TYPE scpr_id,
         tablename    TYPE scpr_flddescr-tablename,
         recnumber    TYPE scpr_recnr,
         fieldname    TYPE scpr_flddescr-fieldname,
         dataelem     TYPE scpr_flddescr-dataelem,
         langu        TYPE scprvarl-langu,
         langutext    TYPE t002t-sptxt,
         fieldtext    TYPE scpr_flddescr-fieldtext,
         outputlen    TYPE scpr_flddescr-outputlen,
         intlen       TYPE scpr_flddescr-intlen,
         vtype        TYPE scpr_flddescr-vtype,
         datatype     TYPE scpr_flddescr-datatype,
         decimals     TYPE scpr_flddescr-decimals,
         convexit     TYPE scpr_flddescr-convexit,
         sign         TYPE scpr_flddescr-sign,
         lowercase    TYPE scpr_flddescr-lowercase,
         oldvalue     TYPE char255,
         value        TYPE char255,
       END OF scpr_undefkey2.

* Int. Tabelle zu undef_key2
* TYPES: scpr_undefkeys2 TYPE scpr_undefkey2 OCCURS 10.

* Struktur zum Sichern von Benutzereinstellungen beim Drucken
TYPES: BEGIN OF scpr_print_para %_FINAL,
         bcset_uebersicht       TYPE char1,
         tabellen_uebersicht    TYPE char1,
         datensatz_uebersicht   TYPE char1,
         felduebersicht         TYPE char1,
         mehrsprachig           TYPE char1,
         alle_tabellenfelder    TYPE char1,
         img_path               TYPE char1,
         maximale_ausgabebreite TYPE i,
         variablenuebersicht    TYPE char1,
       END OF scpr_print_para.

* Ranges für Profiltyp
TYPES: BEGIN OF scpr_xptype %_FINAL,
         sign     TYPE scprxdat-sign,
         option   TYPE scprxdat-option,
         low      TYPE scprattr-type,
         high     TYPE scprattr-type,
       END OF scpr_xptype.

* Int. Tabelle zu scpr_xptype
TYPES: scpr_xptypes TYPE scpr_xptype OCCURS 10.

* Ranges für Cust.objekt
TYPES: BEGIN OF scpr_xobject %_FINAL,
         sign     TYPE scprxdat-sign,
         option   TYPE scprxdat-option,
         low      TYPE scprreca-objectname,
         high     TYPE scprreca-objectname,
       END OF scpr_xobject.

* Int. Tabelle zu scpr_xobject
TYPES: scpr_xobjects TYPE scpr_xobject OCCURS 10.

* Ranges für Typen von Cust.objekten
TYPES: BEGIN OF scpr_xobjtype %_FINAL,
         sign     TYPE scprxdat-sign,
         option   TYPE scprxdat-option,
         low      TYPE scprreca-objecttype,
         high     TYPE scprreca-objecttype,
       END OF scpr_xobjtype.

* Int. Tabelle zu scpr_xobjtype
TYPES: scpr_xobjtypes TYPE scpr_xobjtype OCCURS 10.

* Ranges für Cust.aktivitäten
TYPES: BEGIN OF scpr_xactivity %_FINAL,
         sign     TYPE scprxdat-sign,
         option   TYPE scprxdat-option,
         low      TYPE scprreca-activity,
         high     TYPE scprreca-activity,
       END OF scpr_xactivity.

* Int. Tabelle zu scpr_xactivity
TYPES: scpr_xactivities TYPE scpr_xactivity OCCURS 10.

* Ranges für Firmenbezeichnung
TYPES: BEGIN OF scpr_xorgid %_FINAL,
         sign     TYPE scprxdat-sign,
         option   TYPE scprxdat-option,
         low      TYPE scprattr-orgid,
         high     TYPE scprattr-orgid,
       END OF scpr_xorgid.

* Int. Tabelle zu scpr_xptype
TYPES: scpr_xorgids TYPE scpr_xorgid OCCURS 10.

* Attribute zu den Datensätzen
TYPES: BEGIN OF scpr_recattr %_FINAL,
         tablename  TYPE scprreca-tablename,
         recnumber  TYPE scprreca-recnumber,
         objectname TYPE scprreca-objectname,
         objecttype TYPE scprreca-objecttype,
         objecttext TYPE objt-ddtext,
         activity   TYPE scprreca-activity,
* Changed by ACHACHADI - Message 0120031469 0003205911 2008
         acttext  TYPE hier_text,
*         acttext  TYPE dsyst-doktitle,
         clustname  TYPE scprreca-clustname,
         keylng     TYPE i,
         genkeylng  TYPE i,
         key        TYPE x LENGTH scpr_maxkeylen,
         uncomplete TYPE scprreca-uncomplete,
         deleteflag TYPE scprreca-deleteflag,
         genref     TYPE scprreca-genref,
       END OF scpr_recattr.

* Int. Tabelle zu scpr_recattr
TYPES: scpr_recattrs TYPE scpr_recattr OCCURS 10.

* Übergabe der Werte-Attribute beim Anlegen BC-Set über Transportauftrag
TYPES: BEGIN OF scpr_valattr %_FINAL,
         dataelem   TYPE vimnamtab-rollname,
         keyflag    TYPE scpr_flddescr-keyflag,
         value      TYPE scprvals-value,
         flag       TYPE scprvals-flag,
       END OF scpr_valattr.

* Int. Tabelle zu scpr_valattr
TYPES: scpr_valattrs TYPE scpr_valattr OCCURS 10.

* Hilfstyp zur Konsistenzerhaltung der RECNUMBER
TYPES: BEGIN OF scpr_orig_recnum_assign %_FINAL,
         tablename   TYPE scprreca-tablename,       "key of struc
         objectname  TYPE scprreca-objectname,      "key of struc
         objecttype  TYPE scprreca-objecttype,      "key of struc
         activity    TYPE scprreca-activity,        "key of struc
         key         TYPE x LENGTH scpr_maxkeylen,  "key of struc
         genkeylng   TYPE i,                        "key of struc(!)
         orig_recnum TYPE scprreca-recnumber,
         orig_genref TYPE scprreca-genref,
       END OF scpr_orig_recnum_assign.

* Int. Tabelle zu scpr_orig_recnum_assign
TYPES: scpr_orig_recnum_assigns
       TYPE STANDARD TABLE OF scpr_orig_recnum_assign.

* Hilfstyp zur Zwischenpufferung der zur Verfügung stehenden RECNUMBER
TYPES: BEGIN OF scpr_recnumber %_FINAL,
         recnumber  TYPE scprreca-recnumber,
       END OF scpr_recnumber.

* Int. Tabelle zu scpr_recnumber
*TYPES: scpr_recnumbers TYPE SORTED TABLE OF scpr_recnumber
*                       WITH UNIQUE KEY recnumber.
TYPES: scpr_recnumbers TYPE STANDARD TABLE OF scpr_recnumber.

* Datenelemente der Werte in einem Transportauftrag
TYPES: BEGIN OF scpr_dataelem %_FINAL,
         dataelem   TYPE scpr_flddescr-dataelem,
         domname    TYPE vimnamtab-domname,
         keyflag    TYPE scpr_flddescr-keyflag,
         value      TYPE scpr_flddescr-value,
         fieldtext  TYPE scpr_flddescr-fieldtext,
         tablename  TYPE scpr_flddescr-tablename,
       END OF scpr_dataelem.

* Int. Tabelle zu scpr_dataelem
TYPES: scpr_dataelems TYPE scpr_dataelem OCCURS 10.

* Organisationseinheiten
TYPES: BEGIN OF scpr_entity %_FINAL,
         domname TYPE vimnamtab-domname,
       END OF scpr_entity.

* Int. Tabelle zu scpr_entity
TYPES: scpr_entities TYPE scpr_entity OCCURS 10.

* Übergabestruktur für Belege bei BC-Set-Aktivierung
TYPES: BEGIN OF scpr_actf %_FINAL,
         tablename TYPE scpractr-tablename,
         tabkey    TYPE scpractr-tabkey,
         fieldname TYPE scprvals-fieldname,
         flag      TYPE scprvals-flag,
         bcset_id  TYPE scpractr-profid,
         recnumber TYPE scpractr-recnumber,
       END OF scpr_actf.

* Int. Tabelle zu scpr_actf
TYPES: scpr_actfs TYPE scpr_actf OCCURS 10.

* Übergabestruktur für Datensätze, die durch Viewpflege verändert
* wurden
TYPES: BEGIN OF scpr_viewdata %_FINAL,
         bcset_id  TYPE scpractr-profid,
         recnumber TYPE scpractr-recnumber,
         viewname  TYPE scpractr-tablename,
         data(4096),
       END OF scpr_viewdata.

* Int. Tabelle zu scpr_viewdata
TYPES: scpr_viewdatas TYPE scpr_viewdata OCCURS 10.

* Liste von Sprachen
TYPES: BEGIN OF scpr_langu %_FINAL,
         langu(1),
       END OF scpr_langu.
TYPES: BEGIN OF scpr_language %_FINAL,
         spras TYPE t002-spras,
         sptxt TYPE t002t-sptxt,
       END OF scpr_language.

* Int. Tabelle zu scpr_langu
TYPES: scpr_langus TYPE scpr_langu OCCURS 10.
TYPES: scpr_languages TYPE scpr_language OCCURS 10.

* ALV-Tree,Verbindung zwischen Knoten und Customizing Aktivität
TYPES: BEGIN OF scpr_node_activity %_FINAL,
*        node_number            TYPE lvc_nkey,
         node_number(12)        TYPE c,
         object        TYPE scprreca-objectname,
         objecttype    TYPE scprreca-objecttype,
         activity      TYPE scprreca-activity,
* Changed by ACHACHADI - Message 0120031469 0003205911 2008
         acttext  TYPE hier_text,
*         acttext  TYPE dsyst-doktitle,
         bcset_id      TYPE scprattr-id,      "Wichtig bei hier. BC Sets
         bcset_cat     TYPE scprattr-category,"Wichtig bei hier. BC Sets
         bcset_type    TYPE scprattr-type,    "Wichtig bei hier. BC Sets
         bcset_cli_dep TYPE scprattr-cli_dep, "Wichtig bei hier. BC Sets
         bcset_cli_cas TYPE scprattr-cli_cas, "Wichtig bei hier. BC Sets
         bcset_status(1)        TYPE c,
         obj_cre_possible(1)    TYPE c,  "Anlegen möglich?
         obj_act_possible(1)    TYPE c,  "Aktiviert von Objekt möglich?
         obj_fix_possible(1)    TYPE c,  "Fix-Werte wirksam (nach Akt.)?
         node_number_father(12) TYPE c,
         bcs_path_to_root       TYPE scpr_bcsets,
       END OF scpr_node_activity.

* Cust.aktivitäten
TYPES: BEGIN OF scpr_acttext %_FINAL,
         number     TYPE i,
         node_id    TYPE scprreca-activity,
         node_text  TYPE dsyst-doktitle,
       END OF scpr_acttext.

* Int. Tabelle zu scpr_acttext
TYPES: scpr_acttexts TYPE scpr_acttext OCCURS 10.

* Int. Tabelle für Fehlermeldungen aus Transportaufträgen
TYPES: BEGIN OF scpr_transp_error %_FINAL,
         main_objname TYPE objh-objectname,
         main_objtype TYPE objh-objecttype,
         objectname   TYPE objh-objectname,
         objecttype   TYPE objh-objecttype,
         msgid        TYPE sy-msgid,
         msgty        TYPE sy-msgty,
         msgno        TYPE sy-msgno,
         msgv1        TYPE sy-msgv1,
         msgv2        TYPE sy-msgv2,
         msgv3        TYPE sy-msgv3,
         msgv4        TYPE sy-msgv4,
         index        TYPE i,
       END OF scpr_transp_error.

TYPES: scpr_transp_errors TYPE scpr_transp_error OCCURS 10.

* Einträge in Transportauftrag mit Status
TYPES: BEGIN OF scpr_transp_entry %_FINAL,
         index         TYPE i,
         pgmid         TYPE e071-pgmid,
         object        TYPE e071-object,
         obj_name      TYPE e071-obj_name,
         cust_objname  TYPE objh-objectname,
         cust_objtype  TYPE objh-objecttype,
         tr_lang       TYPE e071-lang,
         tr_activity   TYPE e071-activity,   "Orig. Akt aus Auftrag
         activity      TYPE e071-activity,   "evtl. veränderte Akt.
         act_selected  TYPE c,               "Akt. aus System zugeordn.
         obj_cli_dep   TYPE scpr_cldep,
         obj_cli_cas   TYPE scpr_clcas,
         bcs_relevant  TYPE c,
         data_count    TYPE i,               "Total number of records
         valid_tr_keys TYPE i,               "Total number of valid keys
         take(1)       TYPE c,               "Daten übernehmen?
         status(4)     TYPE c,               "Berechnet aus "errors"
         errors        TYPE scpr_transp_errors,
         obj_tables    TYPE scprchktab OCCURS 1,
         tr_tables     TYPE scprchktab OCCURS 1,
       END OF scpr_transp_entry.

* Struktur einer Tabelle zu scpr_transp_entry
TYPES: scpr_transp_entries TYPE scpr_transp_entry OCCURS 10.

* Cust.aktivitäten mit Kennung, ob BC-Sets dazu existieren
TYPES: BEGIN OF scpr_act_and_bcset %_FINAL,
         activity   TYPE cus_img_ac,
         flag(1),
       END OF scpr_act_and_bcset.

* Int. Tabelle zu scpr_act_and_bcset
TYPES: scpr_act_and_bcsets TYPE scpr_act_and_bcset OCCURS 10.

* Struktur, um BC-Set Daten auf externes File zu schreiben
TYPES: BEGIN OF scpr_transfer %_FINAL,
         line(450),
       END OF scpr_transfer.

* Int. Tabelle zu scpr_transfer
TYPES: scpr_transfertab TYPE scpr_transfer OCCURS 10.

* Liste von BC-Sets plus Farbinformation und Doku-Ikon pro Zeile
TYPES: BEGIN OF scpr_bcset_list %_FINAL.
         INCLUDE STRUCTURE scproprof.
TYPES:   docu_exist_icon(4) TYPE c.
TYPES:   cli_dep_icon(4)    TYPE c.
TYPES:   cli_cas_icon(4)    TYPE c.
TYPES:   act_icon(4)        TYPE c.
TYPES:   act_date           TYPE SCPRACDATE.
TYPES:   act_time           TYPE SCPRACTIME.
TYPES:   act_user           TYPE SCPRACUSER.
TYPES:   linecolor(4)       TYPE c.
TYPES: END OF scpr_bcset_list.

* interne Tabelle zur Liste von BC-Sets
TYPES: scpr_it_bcset_list TYPE STANDARD TABLE OF scpr_bcset_list.

* Cust.aktivitäten
TYPES: BEGIN OF scpr_activity %_FINAL,
         depth     TYPE i,
         activity  TYPE cus_actt-act_id,
         fatheract TYPE cus_actt-act_id,
         acttext   TYPE cus_actt-text,
       END OF scpr_activity.

* interne Tabelle von Aktivitäten
TYPES: scpr_activities TYPE scpr_activity OCCURS 10.


* Versionsabgleich nach Import von BC-Sets
TYPES: BEGIN OF scpr_version_comp %_FINAL,
         activity TYPE scprreca-activity,
* Changed by ACHACHADI - Message 0120031469 0003205911 2008
         acttext  TYPE hier_text,
*         acttext  TYPE dsyst-doktitle,
         objname  TYPE objh-objectname,
         objecttext TYPE objt-ddtext,
         tabname  TYPE scprdata-tablename,
         tabtype  TYPE objh-objecttype,
         tabtext  TYPE dd02t-ddtext,
         raw_key  LENGTH scpr_maxkeylen,
         langu    TYPE scprvall-langu,
         values   TYPE scprvals OCCURS 10,
       END OF scpr_version_comp.

TYPES: scpr_version_comps TYPE STANDARD TABLE OF scpr_version_comp.

* Datenstruktur zur Übergabe von Datensatzschlüsseln
TYPES: BEGIN OF scpr_varkey %_FINAL,
         tablename TYPE scprvals-tablename,
         tabletype TYPE scprreca-objecttype,
         bcset_key LENGTH scpr_maxkeylen,
         table_key LENGTH scpr_maxkeylen,
         variables TYPE scpr_actx OCCURS 10,
       END OF scpr_varkey.
TYPES: scpr_varkeys TYPE scpr_varkey OCCURS 10.

* Hilfsstruktur für die nachfolgende Struktur
TYPES: BEGIN OF scpr_raw_data_and_variables %_FINAL,
         raw_data   TYPE scpr_rawrec,
         variables  TYPE scpr_actx OCCURS 10,
       END   OF scpr_raw_data_and_variables.

* Vergleich von zwei BC-Sets, z. B. beim Versionsabgleich nach Import
TYPES: BEGIN OF scpr_version_comp_result %_FINAL,
         activity TYPE scprreca-activity,
* Changed by ACHACHADI - Message 0120031469 0003205911 2008
         acttext  TYPE hier_text,
*         acttext  TYPE dsyst-doktitle,
         objname  TYPE objh-objectname,
         objecttext TYPE objt-ddtext,
         tabname  TYPE scprdata-tablename,
         tabtype  TYPE objh-objecttype,
         tabtext  TYPE dd02t-ddtext,
         raw_key  LENGTH scpr_maxkeylen,
         langu    TYPE scprvall-langu,
         values_c     TYPE scprvals OCCURS 10,
         values_n     TYPE scprvals OCCURS 10,
         values_o     TYPE scprvals OCCURS 10,
         cn_differ(1) TYPE c,
         cn_fields_flg TYPE scpr_fieldnames,
         cn_fields_val TYPE scpr_fieldnames,
         cn_fields_all TYPE scpr_fieldnames,
         cn_fields_fix TYPE scpr_fieldnames,
         on_differ(1) TYPE c,
         raw_dat_and_vari TYPE scpr_raw_data_and_variables OCCURS 10,
       END OF scpr_version_comp_result.

TYPES: scpr_version_comp_results TYPE STANDARD TABLE OF
                    scpr_version_comp_result.

* Versionsabgleich: Flags (bzw. Attribute) für einen Datensatz
TYPES: BEGIN OF scpr_fldflag %_FINAL,
         fieldname TYPE scprvals-fieldname,
         flag      TYPE scprvals-flag,
         dataelem  TYPE scpr_descr-dataelem,
       END OF scpr_fldflag.
TYPES: scpr_fldflags TYPE STANDARD TABLE OF scpr_fldflag.

* Versionsabgleich, Checkbox-Tabelle
TYPES: BEGIN OF scpr_version_checkbox %_FINAL,
         activity TYPE scprreca-activity,
         objname  TYPE objh-objectname,
         tabname  TYPE scprdata-tablename,
         raw_key        LENGTH scpr_maxkeylen,
         attr_or_dat(1) TYPE c,
         select_n(1)    TYPE c,
       END OF scpr_version_checkbox.
TYPES: scpr_version_checkboxs TYPE STANDARD TABLE OF
                    scpr_version_checkbox.

TYPES: scpr_x64(64)     TYPE x,
       scpr_x128(128)   TYPE x,
       scpr_x256(256)   TYPE x,
       scpr_x512(512)   TYPE x,
       scpr_x1024(1024) TYPE x,
       scpr_x2048(2048) TYPE x,
       scpr_x4096(4096) TYPE x,
       scpr_x8192(8192) TYPE x,
       scpr_x64s        TYPE STANDARD TABLE OF scpr_x64,
       scpr_x128s       TYPE STANDARD TABLE OF scpr_x128,
       scpr_x256s       TYPE STANDARD TABLE OF scpr_x256,
       scpr_x512s       TYPE STANDARD TABLE OF scpr_x512,
       scpr_x1024s      TYPE STANDARD TABLE OF scpr_x1024,
       scpr_x2048s      TYPE STANDARD TABLE OF scpr_x2048,
       scpr_x4096s      TYPE STANDARD TABLE OF scpr_x4096,
       scpr_x8192s      TYPE STANDARD TABLE OF scpr_x8192.

* C-Datentypen für Datencontainer
TYPES: BEGIN OF scpr_char64 %_FINAL,
         align     TYPE f,
         lines(64) TYPE c,
       END OF scpr_char64.
TYPES: scpr_char64s TYPE STANDARD TABLE OF scpr_char64.

TYPES: BEGIN OF scpr_char128 %_FINAL,
         align      TYPE f,
         lines(128) TYPE c,
       END OF scpr_char128.
TYPES: scpr_char128s TYPE STANDARD TABLE OF scpr_char128.

TYPES: BEGIN OF scpr_char256 %_FINAL,
         align      TYPE f,
         lines(256) TYPE c,
       END OF scpr_char256.
TYPES: scpr_char256s TYPE STANDARD TABLE OF scpr_char256.

TYPES: BEGIN OF scpr_char512 %_FINAL,
         align      TYPE f,
         lines(512) TYPE c,
       END OF scpr_char512.
TYPES: scpr_char512s TYPE STANDARD TABLE OF scpr_char512.

TYPES: BEGIN OF scpr_char1024 %_FINAL,
         align       TYPE f,
         lines(1024) TYPE c,
       END OF scpr_char1024.
TYPES: scpr_char1024s TYPE STANDARD TABLE OF scpr_char1024.

TYPES: BEGIN OF scpr_char2048 %_FINAL,
         align       TYPE f,
         lines(2048) TYPE c,
       END OF scpr_char2048.
TYPES: scpr_char2048s TYPE STANDARD TABLE OF scpr_char2048.

TYPES: BEGIN OF scpr_char4096 %_FINAL,
         align       TYPE f,
         lines(4096) TYPE c,
       END OF scpr_char4096.
TYPES: scpr_char4096s TYPE STANDARD TABLE OF scpr_char4096.

TYPES: BEGIN OF scpr_char8192 %_FINAL,
         align       TYPE f,
         lines(8192) TYPE c,
       END OF scpr_char8192.
TYPES: scpr_char8192s TYPE STANDARD TABLE OF scpr_char8192.
