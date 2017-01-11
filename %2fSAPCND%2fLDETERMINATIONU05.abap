FUNCTION /sapcnd/cnf_dynamic_access.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_COND_TYPE) TYPE  /SAPCND/COND_TYPE
*"     REFERENCE(IS_ACCESS) TYPE  /SAPCND/T682I
*"     REFERENCE(IS_ACCESS_CONTROL) TYPE  /SAPCND/DET_ACCESS_CONTROL
*"     REFERENCE(IR_ANALYSIS) TYPE REF TO  /SAPCND/CL_DET_ANALYSIS_OW
*"     REFERENCE(IS_ANALYSIS_MESSAGE) TYPE
*"        /SAPCND/DET_ANALYSIS_MESSAGE
*"     REFERENCE(IV_VALID_FROM) TYPE  /SAPCND/TIMESTAMP_FROM
*"     REFERENCE(IV_VALID_TO) TYPE  /SAPCND/TIMESTAMP_TO
*"     REFERENCE(IT_MULTIPLE_ACCESS) TYPE  /SAPCND/KEY_VALUE_PAIR_TABLE
*"  EXPORTING
*"     REFERENCE(EV_PURELY_HEADER) TYPE  /SAPCND/BOOLEAN
*"     REFERENCE(EV_RETURNCODE) TYPE  /SAPCND/DET_ACCESS_RETURNCODE
*"  CHANGING
*"     REFERENCE(CT_DET_RECORDS) TYPE  /SAPCND/DET_COND_INT_T
*"  EXCEPTIONS
*"      FATAL_ERROR
*"      FIELD_IS_INITIAL
*"      CUSTOMIZING_ERROR
*"      READ_BUT_NOT_FOUND
*"      READ_BUT_BLOCKED
*"----------------------------------------------------------------------

* THIS FUNCTION MODULE MUST NOT BE CALLED DIRECTLY
* PREREQUISITES
* - CNF_ACCESS_PREPARE

  DATA  lv_purely_header TYPE /sapcnd/boolean.
  DATA  lv_read_all_pre  TYPE /sapcnd/boolean.
  DATA  ls_message       TYPE /sapcnd/det_analysis_message.
  DATA  lv_hstring(15)   TYPE x.
  DATA  lv_htabix        TYPE sytabix.
  DATA  lv_logkey        TYPE /sapcnd/logical_key.
  DATA  lt_fv_vakey      TYPE /sapcnd/det_field_value_t.
  DATA  lt_fv_vadat      TYPE /sapcnd/det_field_value_t.
  DATA  ls_fv_vakvad     TYPE /sapcnd/det_field_value.

* clean up
  CLEAR  gt_proto_fld_tab.
  CLEAR  gw_proto_fld_tab.
  CLEAR  gt_coding_tab.
  CLEAR  gt_range_tab.
  CLEAR  gw_range_tab.
  CLEAR  gw_range_fields.
  CLEAR  gw_range_sel.
  CLEAR  gt_where_tab.
  CLEAR  gw_where_tab.

* interface
  ls_message = is_analysis_message.
  lv_read_all_pre  = is_access_control-read_all_prestep.

* set flag
  lv_purely_header = yes.
  CLEAR ev_returncode.

* prepare structure to convert range into where
  gw_range_tab-tablename = gv_koview.

* each field of T682Z is analysed regarding relevance,
* access type, fieldname and value in comm-structure
  LOOP AT gt_t682z_tab INTO gw_t682z_tab.
* Hierarchical access type 'A' not supported for pricing-related usages.
* Due to legal reasons changes of the subsequent lines of code are not allowed.
* In case of doubts read the SAP note 1600482.
*    IF gw_t682z_tab-fstst = 'A' AND
*     ( gw_t682z_tab-kvewe = 'PR' OR
*       gw_t682z_tab-kvewe = 'BO' OR
*       gw_t682z_tab-kvewe = 'DD' OR
*       gw_t682z_tab-kvewe = 'CD' OR
*       gw_t682z_tab-kvewe = 'PD' OR
*       gw_t682z_tab-kvewe = 'FG' OR
*       gw_t682z_tab-kvewe = 'FA' OR
*       gw_t682z_tab-kvewe = 'LM' OR
*       gw_t682z_tab-kvewe = 'MM').
*      MESSAGE x050(/sapcnd/det) WITH gw_t682z_tab-kozgf gw_t682z_tab-kolnr gw_t682z_tab-zifna.
*    ENDIF.
* Due to legal reasons changes of the preceding lines of code are not allowed.

    IF gw_t682z_tab-fstst NA gc_fstst_nosel OR
       is_access-gzugr     EQ no.
* field is relevant for access
* check if access contains header fields only
      IF gw_t682z_tab-qustr NE gs_t681a-str_head_acs AND
         gw_t682z_tab-qudiw IS INITIAL  AND
            gw_t682z_tab-kzini NE 'X'.
        lv_purely_header = no.
      ENDIF.
* in prestep use header fields only
      IF NOT is_access_control-prestep_mode IS INITIAL.
        CHECK gw_t682z_tab-qustr EQ gs_t681a-str_head_acs OR
          NOT gw_t682z_tab-qudiw IS INITIAL.
      ENDIF.
* determine fields from field information
      CLEAR gw_proto_fld_tab.
* only relevant in analysis
      IF NOT ir_analysis IS INITIAL.
        gw_proto_fld_tab-table = is_access-kotabnr.
        gw_proto_fld_tab-tablefield = gw_t682z_tab-zifna.
        gw_proto_fld_tab-fstst = gw_t682z_tab-fstst.
      ENDIF.
* Field is not of table type
      IF gw_t682z_tab-flag_is_tab IS INITIAL.
* get field value
        IF gw_t682z_tab-qudiw IS INITIAL AND
            gw_t682z_tab-kzini NE 'X'.
          gw_proto_fld_tab-structure = gw_t682z_tab-qustr.
          gw_proto_fld_tab-field = gw_t682z_tab-qufna.
          IF     gw_t682z_tab-qustr EQ gs_t681a-str_head_acs.
            ASSIGN COMPONENT gw_t682z_tab-qufna
              OF STRUCTURE <head> TO <f>.
          ELSEIF gw_t682z_tab-qustr EQ gs_t681a-str_item_com.
            ASSIGN COMPONENT gw_t682z_tab-qufna
              OF STRUCTURE <item> TO <f>.
          ENDIF.
          IF sy-subrc NE 0.
            IF NOT ir_analysis IS INITIAL.
              ls_message-type  =
                 /sapcnd/cl_det_analysis_ow=>type_error.
              ls_message-subtype =
                 /sapcnd/cl_det_analysis_ow=>subtype_main.
              ls_message-msgno = '307'.                     "#EC NOTEXT
              ls_message-msgv1 = gw_t682z_tab-kommfield.
              ls_message-msgv2 = gw_t682z_tab-kozgf.
              ls_message-msgv3 = gw_t682z_tab-kolnr.
              CLEAR ls_message-msgv4.
              CALL METHOD ir_analysis->add_message( ls_message ).
            ENDIF.
            RAISE customizing_error.
          ENDIF.
* initial
* that will be reset for free fields later
          IF ( ( is_access-gzugr CA 'AC' AND
                 gw_t682z_tab-fstst EQ gc_fstst_free ) OR
             gw_t682z_tab-kzini IS INITIAL ) AND <f> IS INITIAL.
            gw_proto_fld_tab-initial = yes.
          ENDIF.
          gw_proto_fld_tab-contents = <f>.
        ELSE.
* fixed source
          gw_proto_fld_tab-contents = gw_t682z_tab-qudiw.
        ENDIF.
        APPEND gw_proto_fld_tab TO gt_proto_fld_tab.
        lv_htabix = sy-tabix.
* in case it is a free field with a doc value not initial set flag to
* make it relevant for priority calculation
        IF is_access-gzugr           CA 'AC' AND
           gw_t682z_tab-fstst       EQ gc_fstst_free AND
           gw_proto_fld_tab-initial EQ no.
          gw_t682z_tab-btype = yes.
        ELSE.
          gw_t682z_tab-btype = no.
        ENDIF.
* modify to set flag (saves checks later)
        MODIFY gt_t682z_tab FROM gw_t682z_tab.
* build range part
        CLEAR gw_range_fields.
        gw_range_fields-fieldname = gw_t682z_tab-zifna.
        CLEAR gw_range_sel.
        gw_range_sel-sign = 'I'.
        gw_range_sel-option = 'EQ'.
        gw_range_sel-low = gw_proto_fld_tab-contents.
        APPEND gw_range_sel TO gw_range_fields-selopt_t.
        IF gw_t682z_tab-fstst EQ gc_fstst_free AND
           gw_proto_fld_tab-initial EQ no.
* free field which is not initial in doc
          CLEAR gw_range_sel.
          gw_range_sel-sign = 'I'.
          gw_range_sel-option = 'EQ'.
          APPEND gw_range_sel TO gw_range_fields-selopt_t.
        ENDIF.
* free fields are now allowed to be initial
        IF gw_t682z_tab-fstst EQ gc_fstst_free AND
           gw_proto_fld_tab-initial EQ yes.
          gw_proto_fld_tab-initial = no.
          MODIFY gt_proto_fld_tab FROM gw_proto_fld_tab
            INDEX lv_htabix TRANSPORTING initial.
        ENDIF.
* if not in protocol mode an initial field could stop processing
        IF ir_analysis   IS INITIAL   AND
           gw_proto_fld_tab-initial EQ yes.
          ev_returncode = gc_field_initial.
          EXIT.
        ENDIF.
      ELSE.
* field is of table type
        gw_proto_fld_tab-field = gw_t682z_tab-qufna.
        CLEAR gw_range_fields.
        gw_range_fields-fieldname = gw_t682z_tab-zifna.
        lv_logkey = gw_t682z_tab-qufna.
        CALL FUNCTION '/SAPCND/CNF_LOGTAB_2_RANGE'
          EXPORTING
            it_logtab        = it_multiple_access
            iv_logkey        = lv_logkey
            iv_table         = is_access-kotabnr
            iv_tablefield    = gw_t682z_tab-zifna
            iv_field         = gw_proto_fld_tab-field
            iv_kzini         = gw_t682z_tab-kzini
            iv_fstst         = gw_t682z_tab-fstst
          IMPORTING
            et_ranges        = gw_range_fields-selopt_t
          CHANGING
            ct_proto_fld     = gt_proto_fld_tab
          EXCEPTIONS
            field_is_initial = 1
            OTHERS           = 2.
        IF sy-subrc EQ 1 AND ir_analysis IS INITIAL.
          ev_returncode = gc_field_initial.
          EXIT.
        ENDIF.
* make it relevant for priority calculation
        IF is_access-gzugr           CA 'AC' AND
           gw_t682z_tab-fstst       EQ gc_fstst_free AND
           sy-subrc                 EQ 1.
          gw_t682z_tab-btype = yes.
        ELSE.
          gw_t682z_tab-btype = no.
        ENDIF.
* modify to set flag (saves checks later)
        MODIFY gt_t682z_tab FROM gw_t682z_tab.
      ENDIF.
      APPEND gw_range_fields TO gw_range_tab-frange_t.
    ENDIF.
  ENDLOOP.
  IF NOT ev_returncode IS INITIAL.
    EXIT.
  ENDIF.

* analysis
  IF NOT ir_analysis IS INITIAL.
    CALL FUNCTION '/SAPCND/CNF_ANALYSIS_FLD'
      EXPORTING
        ir_analysis  = ir_analysis
        is_message   = ls_message
        iv_prestep   = is_access_control-prestep_mode
        iv_header    = lv_purely_header
        it_proto_fld = gt_proto_fld_tab.

* check initial fields (in analysis mode)
    IF NOT ir_analysis IS INITIAL.
      LOOP AT gt_proto_fld_tab INTO gw_proto_fld_tab
           WHERE initial = yes.
* and exit
        ev_returncode = gc_field_initial.
        EXIT.
      ENDLOOP.
      IF NOT ev_returncode IS INITIAL.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

* add timestamp information to range table
  IF iv_valid_to IS INITIAL.
    CLEAR gw_range_fields.
    gw_range_fields-fieldname = gc_timestamp_to_str.
    CLEAR gw_range_sel.
    gw_range_sel-sign = 'I'.
    gw_range_sel-option = 'GE'.
    gw_range_sel-low = iv_valid_from.
    APPEND gw_range_sel TO gw_range_fields-selopt_t.
    APPEND gw_range_fields TO gw_range_tab-frange_t.
    CLEAR gw_range_fields.
    gw_range_fields-fieldname = gc_timestamp_from_str.
    CLEAR gw_range_sel.
    gw_range_sel-sign = 'I'.
    gw_range_sel-option = 'LE'.
    gw_range_sel-low = iv_valid_from.
    APPEND gw_range_sel TO gw_range_fields-selopt_t.
    APPEND gw_range_fields TO gw_range_tab-frange_t.
  ELSE.
    CLEAR gw_range_fields.
    gw_range_fields-fieldname = gc_timestamp_to_str.
    CLEAR gw_range_sel.
    gw_range_sel-sign = 'I'.
    gw_range_sel-option = 'BT'.
    gw_range_sel-low  = iv_valid_from.
    gw_range_sel-high = iv_valid_to.
    APPEND gw_range_sel TO gw_range_fields-selopt_t.
    APPEND gw_range_fields TO gw_range_tab-frange_t.
    CLEAR gw_range_fields.
    gw_range_fields-fieldname = gc_timestamp_from_str.
    CLEAR gw_range_sel.
    gw_range_sel-sign = 'I'.
    gw_range_sel-option = 'BT'.
    gw_range_sel-low  = iv_valid_from.
    gw_range_sel-high = iv_valid_to.
    APPEND gw_range_sel TO gw_range_fields-selopt_t.
    APPEND gw_range_fields TO gw_range_tab-frange_t.
  ENDIF.

* add release status to range table
  IF is_access_control-call_mode IS INITIAL OR
     is_access_control-call_mode = 'A'.
    CLEAR gw_range_fields.
    gw_range_fields-fieldname = gc_release_status_str.
    CLEAR gw_range_sel.
    gw_range_sel-sign = 'I'.
    gw_range_sel-option = 'EQ'.
    gw_range_sel-low  = ' '.
    APPEND gw_range_sel TO gw_range_fields-selopt_t.
    APPEND gw_range_fields TO gw_range_tab-frange_t.
  ENDIF.

  APPEND gw_range_tab TO gt_range_tab.

* translate range into where-clause
  CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_WHERE'
    EXPORTING
      field_ranges  = gt_range_tab
    IMPORTING
      where_clauses = gt_where_tab.

* get coding table
  READ TABLE gt_where_tab INTO gw_where_tab
      WITH KEY tablename = gv_koview.
  IF sy-subrc EQ 0.
    gt_coding_tab = gw_where_tab-where_tab.
  ELSE.
* horrible
    MESSAGE a893(/sapcnd/analysis) WITH '0002' 'LV61ZU01'.
  ENDIF.

* prestep for hierarchy access with header fields only - read all
  IF is_access_control-prestep_mode                    EQ yes  AND
     is_access-gzugr                CA 'AC' AND
     lv_purely_header EQ yes.
    lv_read_all_pre = yes.
  ENDIF.

  TRY.

* select from database
      IF is_access_control-prestep_mode              EQ yes OR
         is_access_control-only_one_record EQ yes.

        IF lv_read_all_pre IS INITIAL.
          SELECT * FROM (gv_koview) APPENDING TABLE <sel_t>
                 UP TO 1 ROWS
                 WHERE kschl = iv_cond_type
                   AND (gt_coding_tab).

        ELSE.
          SELECT * FROM (gv_koview) APPENDING TABLE <sel_t>
                 WHERE kschl = iv_cond_type
                   AND (gt_coding_tab).
        ENDIF.
      ELSE.
        SELECT * FROM (gv_koview) APPENDING TABLE <sel_t>
               WHERE  kschl = iv_cond_type
                 AND (gt_coding_tab).
      ENDIF.

    CATCH cx_sy_sql_error.

      IF NOT ir_analysis IS INITIAL.
        ls_message-type  =
           /sapcnd/cl_det_analysis_ow=>type_error.
        ls_message-subtype =
           /sapcnd/cl_det_analysis_ow=>subtype_main.
        ls_message-msgno = '310'.                           "#EC NOTEXT
        CLEAR ls_message-msgv1.
        CLEAR ls_message-msgv2.
        CLEAR ls_message-msgv3.
        CLEAR ls_message-msgv4.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
      RAISE customizing_error.

  ENDTRY.

* something found
  IF sy-subrc EQ 0.
    LOOP AT <sel_t> INTO <result>.
* save index - we might need to refer to <sel_t> again
      gw_cond_tab-sel_t_index = sy-tabix.
* fill template of table templates i.e.
* a condition record without application or usage data
      MOVE-CORRESPONDING <result> TO gw_cond_tab-record_nul.
* extract VAKEY - used to evaluate release_status
* we might do a bit too much since blocked records are handled, too
      CLEAR lt_fv_vakey.
      CLEAR lt_fv_vadat.
      LOOP AT gt_t682z_tab INTO gw_t682z_tab.
        ASSIGN COMPONENT gw_t682z_tab-zifna
            OF STRUCTURE <result> TO <f>.
        IF sy-subrc EQ 0.
* VAKEY
          IF gw_t682z_tab-fstst CA ' A'.
            CLEAR ls_fv_vakvad.
            ls_fv_vakvad-field = gw_t682z_tab-zifna.
            ls_fv_vakvad-value = <f>.
            ls_fv_vakvad-fstst = gw_t682z_tab-fstst.
            APPEND ls_fv_vakvad TO lt_fv_vakey.
          ELSEIF gw_t682z_tab-fstst EQ 'B'.
            IF NOT gw_t682z_tab-qufna IS INITIAL.
              CLEAR ls_fv_vakvad.
              ls_fv_vakvad-field = gw_t682z_tab-qufna.
              ls_fv_vakvad-value = <f>.
              ls_fv_vakvad-fstst = gw_t682z_tab-fstst.
              APPEND ls_fv_vakvad TO lt_fv_vakey.
            ELSE.
              CLEAR ls_fv_vakvad.
              ls_fv_vakvad-field = gw_t682z_tab-zifna.
              ls_fv_vakvad-value = <f>.
              ls_fv_vakvad-fstst = gw_t682z_tab-fstst.
              APPEND ls_fv_vakvad TO lt_fv_vakey.
            ENDIF.
          ELSE.
* VADAT
            IF NOT gw_t682z_tab-qufna IS INITIAL.
              CLEAR ls_fv_vakvad.
              ls_fv_vakvad-field = gw_t682z_tab-qufna.
              ls_fv_vakvad-value = <f>.
              ls_fv_vakvad-fstst = gw_t682z_tab-fstst.
              APPEND ls_fv_vakvad TO lt_fv_vadat.
            ELSE.
              CLEAR ls_fv_vakvad.
              ls_fv_vakvad-field = gw_t682z_tab-zifna.
              ls_fv_vakvad-value = <f>.
              ls_fv_vakvad-fstst = gw_t682z_tab-fstst.
              APPEND ls_fv_vakvad TO lt_fv_vadat.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      gw_cond_tab-fv_vakey = lt_fv_vakey.
      gw_cond_tab-fv_vadat = lt_fv_vadat.
      APPEND gw_cond_tab TO gt_cond_tab.
    ENDLOOP.

* delete all blocked records with respect to release status
    CALL FUNCTION '/SAPCND/CNF_EVAL_RELSTAT'
      EXPORTING
        iv_callmode      = is_access_control-call_mode
        is_access        = is_access
        iv_prestep       = is_access_control-prestep_mode
        iv_purely_header = lv_purely_header
        ir_analysis      = ir_analysis
        is_message       = ls_message
      CHANGING
        ct_cond_tab      = gt_cond_tab.
    DESCRIBE TABLE gt_cond_tab LINES lv_htabix.
    IF lv_htabix EQ 0 AND (
     ( is_access_control-prestep_mode                    EQ no ) OR
     ( is_access_control-prestep_mode                    EQ yes AND
       lv_purely_header EQ yes ) ).
      ev_returncode = gc_blocked.
      EXIT.
    ENDIF.

* extract application or usage data depending on flag in
* access_control and write analysis if necessary
    IF is_access-gzugr CA ' B'         OR
       is_access_control-only_one_record EQ yes OR
     ( is_access-gzugr CA 'AC' AND
       is_access_control-prestep_mode     EQ yes  AND
       lv_purely_header EQ no ).
* no priority calculation
      LOOP AT gt_cond_tab INTO gw_cond_tab.
* save and return record
        APPEND gw_cond_tab TO ct_det_records.
        IF NOT is_access_control-buffer_usag_data IS INITIAL AND
           NOT gv_fb_us_put IS INITIAL.
          READ TABLE <sel_t> INTO <result>
            INDEX gw_cond_tab-sel_t_index.
          MOVE-CORRESPONDING <result> TO <data>.
          CALL FUNCTION gv_fb_us_put
            EXPORTING
              i_condition_id = gw_cond_tab-varnumh
              i_application  = is_access-kappl
              i_table_id     = is_access-kotabnr
              i_supp_key     = gw_cond_tab-supp_part
              i_prstp_flag   = is_access_control-prestep_mode
              i_record       = gr_koview
              i_data         = <data>.
        ENDIF.
* protocol
        IF NOT ir_analysis IS INITIAL.
          IF is_access_control-prestep_mode                    EQ no OR
             lv_purely_header EQ yes.
            CALL FUNCTION '/SAPCND/CNF_ANALYSIS_REC'
              EXPORTING
                ir_analysis       = ir_analysis
                is_message        = ls_message
                iv_condition_id   = gw_cond_tab-varnumh
                iv_object_id      = gw_cond_tab-object_id
                iv_reject         = /sapcnd/cl_det_analysis_ow=>reject_no
                iv_tabix          = 0
                iv_release_status = gw_cond_tab-release_status.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
* priority calculation
      LOOP AT gt_cond_tab INTO gw_cond_tab.
        CLEAR gw_cond_tab-bit_string.
        READ TABLE <sel_t> INTO <result> INDEX gw_cond_tab-sel_t_index.
        LOOP AT gt_t682z_tab INTO gw_t682z_tab
          WHERE btype EQ yes.
          ASSIGN COMPONENT gw_t682z_tab-zifna
            OF STRUCTURE <result> TO <f>.
          IF sy-subrc EQ 0      AND
             NOT <f> IS INITIAL AND
             gw_t682z_tab-mbwrt GE 1.
            SET BIT gw_t682z_tab-mbwrt OF gw_cond_tab-bit_string.
          ENDIF.
        ENDLOOP.
        MODIFY gt_cond_tab FROM gw_cond_tab.
      ENDLOOP.
      SORT gt_cond_tab BY bit_string DESCENDING.

      LOOP AT gt_cond_tab INTO gw_cond_tab.
        IF sy-tabix EQ 1.
          lv_hstring = gw_cond_tab-bit_string.
        ENDIF.
        IF gw_cond_tab-bit_string EQ lv_hstring.
          APPEND gw_cond_tab TO ct_det_records.
          IF NOT is_access_control-buffer_usag_data IS INITIAL AND
           NOT gv_fb_us_put IS INITIAL.
            READ TABLE <sel_t> INTO <result>
               INDEX gw_cond_tab-sel_t_index.
            MOVE-CORRESPONDING <result> TO <data>.
            CALL FUNCTION gv_fb_us_put
              EXPORTING
                i_condition_id = gw_cond_tab-varnumh
                i_application  = is_access-kappl
                i_table_id     = is_access-kotabnr
                i_supp_key     = gw_cond_tab-supp_part
                i_prstp_flag   = is_access_control-prestep_mode
                i_record       = gr_koview
                i_data         = <data>.
          ENDIF.
          lv_htabix = sy-tabix.
          IF NOT ir_analysis IS INITIAL.
            IF is_access_control-prestep_mode EQ no OR
              lv_purely_header EQ yes.
              CALL FUNCTION '/SAPCND/CNF_ANALYSIS_REC'
                EXPORTING
                  ir_analysis       = ir_analysis
                  is_message        = ls_message
                  iv_condition_id   = gw_cond_tab-varnumh
                  iv_object_id      = gw_cond_tab-object_id
                  iv_reject         = /sapcnd/cl_det_analysis_ow=>reject_no
                  iv_tabix          = lv_htabix
                  iv_release_status = gw_cond_tab-release_status.
            ENDIF.
          ENDIF.
        ELSE.
* for protocol only
          IF NOT ir_analysis IS INITIAL.
            lv_htabix = lv_htabix + 1.
            IF is_access_control-prestep_mode EQ no OR
               lv_purely_header EQ yes.
              CALL FUNCTION '/SAPCND/CNF_ANALYSIS_REC'
                EXPORTING
                  ir_analysis       = ir_analysis
                  is_message        = ls_message
                  iv_condition_id   = gw_cond_tab-varnumh
                  iv_object_id      = gw_cond_tab-object_id
                  iv_reject         = /sapcnd/cl_det_analysis_ow=>reject_prio
                  iv_tabix          = lv_htabix
                  iv_release_status = gw_cond_tab-release_status.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    ev_purely_header = lv_purely_header.
  ELSE.
    ev_purely_header = lv_purely_header.
    ev_returncode    = gc_not_found.
  ENDIF.

ENDFUNCTION.
