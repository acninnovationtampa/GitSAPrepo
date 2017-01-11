TYPE-POOL szadr.
***********************************************************************
*   Typen der   Z e n t r a l e n   A d r e ß v e r w a l t u n g
***********************************************************************

*{   (Alles aufreißen/verbergen)
*{  Allgemeine Typen
TYPES: szadr_bool(1) TYPE c,
       szadr_boole(1) TYPE c,
       szadr_length TYPE i,
       szadr_index LIKE sy-tabix,
       szadr_name_line LIKE adrs-line0.

TYPES: szadr_error_table LIKE addr_error OCCURS 0,
       szadr_error_line TYPE LINE OF szadr_error_table.
*}

*{  Typen für die Namensaufbereitung
TYPES: szadr_t005o LIKE t005o,
       szadr_it005o TYPE szadr_t005o OCCURS 0.

TYPES: BEGIN OF szadr_name_fields_line,
         fieldname LIKE t005o-fieldname,
         value LIKE name_parts-name_text,
         fieldconv LIKE t005o-fieldconv,
       END OF szadr_name_fields_line,
       szadr_name_fields_tab TYPE szadr_name_fields_line OCCURS 0.

TYPES: BEGIN OF szadr_name_values_line,
         fieldname LIKE t005o-fieldname,
         value LIKE name_parts-name_text,            "Ausgabewert
         length TYPE i,
         offset TYPE i,
*        TOTAL_LENGTH TYPE I,
         fieldconv LIKE t005o-fieldconv,
        END OF szadr_name_values_line,
        szadr_name_values_tab TYPE szadr_name_values_line OCCURS 0.
*}

*{ Typen für die komplexen Datenobjekte
* Komplexes Datenobjekt zum Adreßtyp 1
TYPES: BEGIN OF szadr_addr1_line,
         nation LIKE adrc-nation,
         data LIKE addr1_data,
       END OF szadr_addr1_line,
       szadr_addr1_tab TYPE szadr_addr1_line OCCURS 0,
* Komplexes Datenobjekt zum Adreßtyp 2
       BEGIN OF szadr_addr2_line,
         nation LIKE adrc-nation,
         data LIKE addr2_data,
       END OF szadr_addr2_line,
       szadr_addr2_tab TYPE szadr_addr2_line OCCURS 0,
* Komplexes Datenobjekt zum Adreßtyp 3
       BEGIN OF szadr_addr3_line,
         nation LIKE adrc-nation,
         data LIKE addr3_data,
* field-names can look like:
*   addr3_complete-addr3_tab-data-so_key (!)    ( don't forget -DATA- )
       END OF szadr_addr3_line,
       szadr_addr3_tab TYPE szadr_addr3_line OCCURS 0,

       BEGIN OF szadr_adtel_line,
         date_from LIKE adrc-date_from,
         adtel LIKE adtel,
       END OF szadr_adtel_line,
       szadr_adtel_tab TYPE szadr_adtel_line OCCURS 0,
       BEGIN OF szadr_adfax_line,
         date_from LIKE adrc-date_from,
         adfax LIKE adfax,
       END OF szadr_adfax_line,
       szadr_adfax_tab TYPE szadr_adfax_line OCCURS 0,
       BEGIN OF szadr_adttx_line,
         date_from LIKE adrc-date_from,
         adttx LIKE adttx,
       END OF szadr_adttx_line,
       szadr_adttx_tab TYPE szadr_adttx_line OCCURS 0,
       BEGIN OF szadr_adtlx_line,
         date_from LIKE adrc-date_from,
         adtlx LIKE adtlx,
       END OF szadr_adtlx_line,
       szadr_adtlx_tab TYPE szadr_adtlx_line OCCURS 0,
       BEGIN OF szadr_adsmtp_line,
         date_from LIKE adrc-date_from,
         adsmtp LIKE adsmtp,
       END OF szadr_adsmtp_line,
       szadr_adsmtp_tab TYPE szadr_adsmtp_line OCCURS 0,
       BEGIN OF szadr_adrml_line,
         date_from LIKE adrc-date_from,
         adrml LIKE adrml,
       END OF szadr_adrml_line,
       szadr_adrml_tab TYPE szadr_adrml_line OCCURS 0,
       BEGIN OF szadr_adx400_line,
         date_from LIKE adrc-date_from,
         adx400 LIKE adx400,
       END OF szadr_adx400_line,
       szadr_adx400_tab TYPE szadr_adx400_line OCCURS 0,
       BEGIN OF szadr_adrfc_line,
         date_from LIKE adrc-date_from,
         adrfc LIKE adrfc,
       END OF szadr_adrfc_line,
       szadr_adrfc_tab TYPE szadr_adrfc_line OCCURS 0,
*------------------------------- "*178i+
       BEGIN OF szadr_adprt_line,
         date_from LIKE adrc-date_from,
         adprt LIKE adprt,
       END OF szadr_adprt_line,
       szadr_adprt_tab TYPE szadr_adprt_line OCCURS 0,
       BEGIN OF szadr_adssf_line,
         date_from LIKE adrc-date_from,
         adssf LIKE adssf,
       END OF szadr_adssf_line,
       szadr_adssf_tab TYPE szadr_adssf_line OCCURS 0,
       BEGIN OF szadr_aduri_line,
         date_from LIKE adrc-date_from,
         aduri LIKE aduri,
       END OF szadr_aduri_line,
       szadr_aduri_tab TYPE szadr_aduri_line OCCURS 0,
       BEGIN OF szadr_adpag_line,
         date_from LIKE adrc-date_from,
         adpag LIKE adpag,
       END OF szadr_adpag_line,
       szadr_adpag_tab TYPE szadr_adpag_line OCCURS 0,
*------------------------------ "*178i-
       BEGIN OF szadr_adrct_line,
         addr_rem LIKE addr_rem,
       END OF szadr_adrct_line,
       szadr_adrct_tab TYPE szadr_adrct_line OCCURS 0,
       BEGIN OF szadr_adrt_line,
         adcomrem LIKE adcomrem,
       END OF szadr_adrt_line,
       szadr_adrt_tab TYPE szadr_adrt_line OCCURS 0,
       BEGIN OF szadr_adru_line,                            "*981i+
         aduse LIKE aduse,                                  "*981i+
       END OF szadr_adru_line,                              "*981i+
       szadr_adru_tab TYPE szadr_adru_line OCCURS 0,        "*981i+
*-------------------------------- "*201d+
       BEGIN OF szadr_adrt_c_line,
         adcomrem LIKE adcomrem,
       END OF szadr_adrt_c_line,
       szadr_adrt_c_tab TYPE szadr_adrt_c_line OCCURS 0,
*-------------------------------- "*201d-
       BEGIN OF szadr_addr1_complete,
         addrnumber LIKE addr1_sel-addrnumber,
         addrhandle LIKE addr1_sel-addrhandle,
         addr1_tab TYPE szadr_addr1_line OCCURS 0,
         adtel_tab TYPE szadr_adtel_line OCCURS 0,
         adfax_tab TYPE szadr_adfax_line OCCURS 0,
         adttx_tab TYPE szadr_adttx_line OCCURS 0,
         adtlx_tab TYPE szadr_adtlx_line OCCURS 0,
         adsmtp_tab TYPE szadr_adsmtp_line OCCURS 0,
         adrml_tab TYPE szadr_adrml_line OCCURS 0,
         adx400_tab TYPE szadr_adx400_line OCCURS 0,
         adrfc_tab TYPE szadr_adrfc_line OCCURS 0,
         adprt_tab TYPE szadr_adprt_line OCCURS 0,          "*178i
         adssf_tab TYPE szadr_adssf_line OCCURS 0,          "*178i
         aduri_tab TYPE szadr_aduri_line OCCURS 0,          "*178i
         adpag_tab TYPE szadr_adpag_line OCCURS 0,          "*178i
         adrct_tab TYPE szadr_adrct_line OCCURS 0,
         adrt_tab TYPE szadr_adrt_line OCCURS 0,
         adru_tab TYPE szadr_adru_line OCCURS 0,            "*981i
      END OF szadr_addr1_complete,

      szadr_addr1_table TYPE szadr_addr1_complete OCCURS 0, "*1785i+

      BEGIN OF szadr_st_adrc,
          ADDRNUMBER LIKE ADRC-ADDRNUMBER,
      END OF szadr_st_adrc,

      szadr_adrc_table TYPE szadr_st_adrc OCCURS 0,         "*1785i-
*
       BEGIN OF szadr_addr2_complete,
         addrnumber LIKE addr2_sel-addrnumber,
         addrhandle LIKE addr2_sel-addrhandle,
         persnumber LIKE addr2_sel-persnumber,
         pershandle LIKE addr2_sel-pershandle,
         addr2_tab TYPE szadr_addr2_line OCCURS 0,
         adtel_tab TYPE szadr_adtel_line OCCURS 0,
         adfax_tab TYPE szadr_adfax_line OCCURS 0,
         adttx_tab TYPE szadr_adttx_line OCCURS 0,
         adtlx_tab TYPE szadr_adtlx_line OCCURS 0,
         adsmtp_tab TYPE szadr_adsmtp_line OCCURS 0,
         adrml_tab TYPE szadr_adrml_line OCCURS 0,
         adx400_tab TYPE szadr_adx400_line OCCURS 0,
         adrfc_tab TYPE szadr_adrfc_line OCCURS 0,
         adprt_tab TYPE szadr_adprt_line OCCURS 0,          "*178i
         adssf_tab TYPE szadr_adssf_line OCCURS 0,          "*178i
         aduri_tab TYPE szadr_aduri_line OCCURS 0,          "*178i
         adpag_tab TYPE szadr_adpag_line OCCURS 0,          "*178i
         adrct_tab TYPE szadr_adrct_line OCCURS 0,
         adrt_tab TYPE szadr_adrt_line OCCURS 0,
         adru_tab TYPE szadr_adru_line OCCURS 0,            "*981i
      END OF szadr_addr2_complete,
*
       BEGIN OF szadr_addr3_complete,
         addrnumber LIKE addr3_sel-addrnumber,
         addrhandle LIKE addr3_sel-addrhandle,
         persnumber LIKE addr3_sel-persnumber,
         pershandle LIKE addr3_sel-pershandle,
         addr3_tab TYPE szadr_addr3_line OCCURS 0,
         adtel_tab TYPE szadr_adtel_line OCCURS 0,
         adfax_tab TYPE szadr_adfax_line OCCURS 0,
         adttx_tab TYPE szadr_adttx_line OCCURS 0,
         adtlx_tab TYPE szadr_adtlx_line OCCURS 0,
         adsmtp_tab TYPE szadr_adsmtp_line OCCURS 0,
         adrml_tab TYPE szadr_adrml_line OCCURS 0,
         adx400_tab TYPE szadr_adx400_line OCCURS 0,
         adrfc_tab TYPE szadr_adrfc_line OCCURS 0,
         adprt_tab TYPE szadr_adprt_line OCCURS 0,          "*178i
         adssf_tab TYPE szadr_adssf_line OCCURS 0,          "*178i
         aduri_tab TYPE szadr_aduri_line OCCURS 0,          "*178i
         adpag_tab TYPE szadr_adpag_line OCCURS 0,          "*178i
*         adrct_tab TYPE szadr_adrct_line OCCURS 0,              "*201d
         adrt_tab TYPE szadr_adrt_line OCCURS 0,
*         adrt_c_tab TYPE szadr_adrt_c_line OCCURS 0,            "*201d
         adru_tab TYPE szadr_adru_line OCCURS 0,            "*981i
      END OF szadr_addr3_complete.
*
TYPES: BEGIN OF szadr_addr_complete_sample,
         addr_type TYPE ad_adrtype,
         address1 TYPE szadr_addr1_complete,
         address2 TYPE szadr_addr2_complete,
         address3 TYPE szadr_addr3_complete,
       END OF szadr_addr_complete_sample.
*}

*{ Typen für die Sperrbausteine:
TYPES:  szadr_enq_mode LIKE dd26e-enqmode,
        szadr_enq_scope(1) TYPE c,
        szadr_enq_wait(1) TYPE c,
        szadr_enq_collect LIKE ddenq_like-collect,
        szadr_enq_synchron(1) TYPE c.
*}

*{ Typen für das Handling von SO_KEY:
TYPES: BEGIN OF szadr_so_key_line1,
       so_key LIKE adcp-so_key,
       END OF szadr_so_key_line1,
       szadr_so_key_tab1 TYPE szadr_so_key_line1 OCCURS 0.


TYPES: BEGIN OF szadr_so_key_line2,
       so_key LIKE adcp-so_key,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       addr_type  LIKE szad_field-addr_type,
       error_flag LIKE szad_field-flag,
       END OF szadr_so_key_line2,
       szadr_so_key_tab2 TYPE szadr_so_key_line2 OCCURS 0.

TYPES: BEGIN OF szadr_so_key_line3,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       so_key LIKE adcp-so_key,
       error_flag LIKE szad_field-flag,
       relation_index LIKE sy-tabix,
       END OF szadr_so_key_line3,
       szadr_so_key_tab3 TYPE szadr_so_key_line3 OCCURS 0.

TYPES: BEGIN OF szadr_so_key_line4,
       so_key LIKE adcp-so_key,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       name_text  LIKE adrp-name_text,
       addr_type  LIKE szad_field-addr_type,
       error_flag LIKE szad_field-flag,
       END OF szadr_so_key_line4,
       szadr_so_key_tab4 TYPE szadr_so_key_line4 OCCURS 0.

TYPES: BEGIN OF szadr_so_key_line5,
       so_key LIKE adcp-so_key,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       addr_type  LIKE szad_field-addr_type,
       error_flag LIKE szad_field-flag,
       deflt_comm LIKE adrc-deflt_comm,
       consnumber LIKE adr2-consnumber,
       home_consnumber LIKE adr2-consnumber,                "*288i
*      COMM_TABLE   "beliebiger Tabellentyp
       END OF szadr_so_key_line5,
       szadr_so_key_tab5 TYPE szadr_so_key_line5 OCCURS 0.

TYPES: BEGIN OF szadr_so_key_line6,
       so_key LIKE adcp-so_key,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       comp_pers  LIKE adcp-comp_pers,
       END OF szadr_so_key_line6,
       szadr_so_key_tab6 TYPE szadr_so_key_line6 OCCURS 0.
*}

TYPES: BEGIN OF szadr_get_type_line,
       addrnumber LIKE adcp-addrnumber,
       persnumber LIKE adcp-persnumber,
       addr_type  LIKE szad_field-addr_type,
       error_flag LIKE szad_field-flag,
       END OF szadr_get_type_line,
       szadr_get_type_tab TYPE szadr_get_type_line OCCURS 0.


*{ Typen für den FB ADDR_PERS_COMP_NAME_SEARCH:
TYPES: BEGIN OF szadr_person_group_line,
       pers_group LIKE adpgroups-pers_group,
       sign(1),
       END OF szadr_person_group_line.
TYPES: szadr_person_group_tab TYPE szadr_person_group_line OCCURS 0.
* TYPES: SZADR_PERSON_GROUPS LIKE ADPGROUPS OCCURS 0.

TYPES: szadr_name_search_string LIKE adrp-name_text.

TYPES: BEGIN OF szadr_name_search_fields,
        name_last    LIKE   adrp-name_last,
        name_first   LIKE   adrp-name_first,
        name_comp    LIKE   adrc-mc_name1,
      END OF szadr_name_search_fields.
*}

*{ Typen für die Adreßaufbereitung                                   .
TYPES: BEGIN OF szadr_printform_table_line,
         line_type TYPE ad_line_tp,
         address_line LIKE adrs-line0,
       END OF szadr_printform_table_line.
TYPES: szadr_printform_table TYPE szadr_printform_table_line OCCURS 0.
*}

*{ Typen für das Referenzhandling
TYPES: BEGIN OF szadr_addr_ref_switch_line,
         appl_table_old LIKE addr_ref-appl_table,
         appl_field_old LIKE addr_ref-appl_field,
         appl_key_old   LIKE addr_ref-appl_key,
         appl_table_new LIKE addr_ref-appl_table,
         appl_field_new LIKE addr_ref-appl_field,
         appl_key_new   LIKE addr_ref-appl_key,
         check_error    LIKE szad_field-flag,
         read_error     LIKE szad_field-flag,
        END OF szadr_addr_ref_switch_line.
TYPES: szadr_addr_ref_switch_tab TYPE szadr_addr_ref_switch_line
         OCCURS 0.

TYPES: BEGIN OF szadr_addr_ref_read_line,
       addrnumber LIKE adrc-addrnumber,
       addr_ref LIKE addr_ref,
       obj_type TYPE swo_objtyp,
       obj_key TYPE swo_typeid,
       obj_key_extension TYPE swo_typeid,                   "*465i
       reference_not_valid LIKE szad_field-flag,
       obj_type_unknown LIKE szad_field-flag,
       obj_key_unknown LIKE szad_field-flag,
       dummy_reference TYPE ad_refdflt,
       END OF szadr_addr_ref_read_line.
TYPES: szadr_addr_ref_read_tab TYPE szadr_addr_ref_read_line OCCURS 0.

TYPES: BEGIN OF szadr_pers_ref_read_line,
       persnumber LIKE adrp-persnumber,
       pers_ref LIKE pers_ref,
       obj_type TYPE swo_objtyp,
       obj_key TYPE swo_typeid,
       reference_not_valid LIKE szad_field-flag,
       obj_type_unknown LIKE szad_field-flag,
       obj_key_unknown LIKE szad_field-flag,
       dummy_reference TYPE ad_refdflt,
       END OF szadr_pers_ref_read_line.
TYPES: szadr_pers_ref_read_tab TYPE szadr_pers_ref_read_line OCCURS 0.

TYPES: BEGIN OF szadr_adownerref_read_line,
        adownerref LIKE adownerref,
        not_found LIKE szad_field-flag,
       END OF szadr_adownerref_read_line.
TYPES: szadr_adownerref_read_tab TYPE szadr_adownerref_read_line
                                      OCCURS 0.
*}

*{ Typen für die inverse Suche mit Kommunikationsdaten
TYPES: BEGIN OF szadr_comm_key_line,
          addrnumber LIKE adr2-addrnumber,
          persnumber LIKE adr2-persnumber,
          date_from  LIKE adr2-date_from,
          consnumber LIKE adr2-consnumber,
          flgdefault LIKE adr2-flgdefault,
          home_flag  LIKE adr2-home_flag,                   "*288i
          dft_receiv LIKE adr2-dft_receiv,
          valid_from TYPE ad_valfrom,                       "*981i
          valid_to   TYPE ad_valto,                         "*981i
        END OF szadr_comm_key_line.
TYPES: szadr_comm_key_tab TYPE szadr_comm_key_line OCCURS 0.

TYPES: BEGIN OF szadr_comm_strategy_line,
         strategy LIKE tcstr-strategy,
         position LIKE tcstrp-pos,
         comm_type TYPE ad_comm,
         skip_flag LIKE szad_field-flag,
         status TYPE adcstrstat,
       END OF szadr_comm_strategy_line.
TYPES: szadr_comm_strategy_tab TYPE szadr_comm_strategy_line OCCURS 0.

*}

*{ Typen für die Kommunikationsstrategien
TYPES: BEGIN OF szadr_comm_values,
       adtel  LIKE adtel,
       adfax  LIKE adfax,
       adttx  LIKE adttx,
       adtlx  LIKE adtlx,
       adsmtp LIKE adsmtp,
       adrml  LIKE adrml,
       adx400 LIKE adx400,
       adrfc  LIKE adrfc,
       adprt  LIKE adprt,                                   "*178i
       adssf  LIKE adssf,                                   "*178i
       aduri  LIKE aduri,                                   "*178i
       adpag  LIKE adpag,                                   "*178i
       END OF szadr_comm_values.
*}

*{ Typen für die ALE-Verteilung
TYPES: BEGIN OF szadr_object_addr1_key_line,
         object_type LIKE swotobjid-objtype,
         object_id LIKE swotobjid-objkey,
         address_number LIKE adrc-addrnumber,
         appl_table LIKE adrv-appl_table,
         appl_field LIKE adrv-appl_field,
         gen_key LIKE adownerref-gen_key,
         object_not_found LIKE szad_field-flag,
         address_number_not_found LIKE szad_field-flag,
         parameter_error LIKE szad_field-flag,
         block_flag TYPE AD_BLKFLAG,                     "1976i
         error_table LIKE addr_error,
       END OF szadr_object_addr1_key_line.
TYPES: szadr_object_addr1_key_tab TYPE szadr_object_addr1_key_line
       OCCURS 0.

TYPES: BEGIN OF szadr_object_addr2_key_line,
         object_type LIKE swotobjid-objtype,
         object_id LIKE swotobjid-objkey,
         person_number LIKE adrp-persnumber,
         address_number LIKE adrc-addrnumber,
         appl_table_p LIKE adrv-appl_table,
         appl_field_p LIKE adrv-appl_field,
         gen_key_p LIKE adownerref-gen_key,
         appl_table_a LIKE adrv-appl_table,
         appl_field_a LIKE adrv-appl_field,
         gen_key_a LIKE adownerref-gen_key,
         object_not_found LIKE szad_field-flag,
         person_number_not_found LIKE szad_field-flag,
         address_number_not_found LIKE szad_field-flag,
         parameter_error LIKE szad_field-flag,
         block_flag TYPE AD_BLKFLAG,                     "1976i
         error_table LIKE addr_error,
       END OF szadr_object_addr2_key_line.
TYPES: szadr_object_addr2_key_tab TYPE szadr_object_addr2_key_line
       OCCURS 0.

TYPES: BEGIN OF szadr_object_addr3_key_line,
         object_type LIKE swotobjid-objtype,
         object_id LIKE swotobjid-objkey,
         person_number LIKE adrp-persnumber,
         address_number LIKE adrc-addrnumber,
         appl_table_p LIKE adrv-appl_table,
         appl_field_p LIKE adrv-appl_field,
         gen_key_p LIKE adownerref-gen_key,
         appl_table_a LIKE adrv-appl_table,
         appl_field_a LIKE adrv-appl_field,
         gen_key_a LIKE adownerref-gen_key,
         object_not_found LIKE szad_field-flag,
         person_number_not_found LIKE szad_field-flag,
         address_number_not_found LIKE szad_field-flag,
         parameter_error LIKE szad_field-flag,
         block_flag TYPE AD_BLKFLAG,                     "1976i
         error_table LIKE addr_error,
       END OF szadr_object_addr3_key_line.
TYPES: szadr_object_addr3_key_tab TYPE szadr_object_addr3_key_line
       OCCURS 0.



*}
*{ Typen für ADDR_COMPARE
TYPES: BEGIN OF szadr_compare_addr1_line,
         addrnumber LIKE addr1_sel-addrnumber,
         addrhandle LIKE addr1_sel-addrhandle,
         remote_addrnumber LIKE addr1_sel-addrnumber,
         address_is_equal LIKE szad_field-flag,
         address_not_exist LIKE szad_field-flag,
         rem_address_not_exist LIKE szad_field-flag,
         parameter_error LIKE szad_field-flag,
         internal_error LIKE szad_field-flag,
         error_table LIKE addr_error,
       END OF szadr_compare_addr1_line.
TYPES: szadr_compare_addr1_tab TYPE szadr_compare_addr1_line
       OCCURS 0.

*}
