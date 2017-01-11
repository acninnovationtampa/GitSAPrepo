FUNCTION /sapcnd/cnf_access .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_COND_TYPE) TYPE  /SAPCND/COND_TYPE
*"     VALUE(IS_ACCESS) TYPE  /SAPCND/T682I_S
*"     VALUE(IS_HEAD_COMM_AREA) TYPE  ANY
*"     VALUE(IS_ITEM_COMM_AREA) TYPE  ANY
*"     VALUE(IR_ANALYSIS) TYPE REF TO  /SAPCND/CL_DET_ANALYSIS_OW
*"       OPTIONAL
*"     VALUE(IS_ANALYSIS_MESSAGE) TYPE  /SAPCND/DET_ANALYSIS_MESSAGE
*"     VALUE(IS_ACCESS_CONTROL) TYPE  /SAPCND/DET_ACCESS_CONTROL
*"       OPTIONAL
*"     VALUE(IV_VALID_FROM) TYPE  /SAPCND/TIMESTAMP_FROM OPTIONAL
*"     VALUE(IV_VALID_TO) TYPE  /SAPCND/TIMESTAMP_TO OPTIONAL
*"     VALUE(IV_FIELD_TIMESTAMP) TYPE  /SAPCND/FIELD_TIMESTAMP
*"     REFERENCE(IT_MULTIPLE_ACCESS) TYPE  /SAPCND/KEY_VALUE_PAIR_TABLE
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_PURELY_HEADER) TYPE  /SAPCND/BOOLEAN
*"     REFERENCE(EV_RETURNCODE) TYPE  /SAPCND/DET_ACCESS_RETURNCODE
*"     REFERENCE(ET_DET_RECORDS) TYPE  /SAPCND/DET_COND_EXT_T
*"     REFERENCE(ES_ANALYSIS_MESSAGE) TYPE
*"        /SAPCND/DET_ANALYSIS_MESSAGE
*"  EXCEPTIONS
*"      FATAL_ERROR
*"      CUSTOMIZING_ERROR
*"----------------------------------------------------------------------

  DATA  lv_func_access TYPE funcname.
  DATA  ls_message     TYPE /sapcnd/det_analysis_message.
  DATA  lv_subrc       TYPE sysubrc.
  DATA  lv_returncode  TYPE /sapcnd/det_access_returncode.

  DATA  lt_det_recs    TYPE /sapcnd/det_cond_int_t.
  DATA  ls_det_recs    TYPE /sapcnd/det_cond_int.           "#EC NEEDED

* interface
  ls_message = is_analysis_message.

* initialization
  PERFORM  cnf_access_init     CHANGING et_det_records
                                        ev_purely_header
                                        ls_message.

* read customizing
* changes GZUGR in IS_ACCESS
  PERFORM  cnf_access_prepare CHANGING  is_access
                                        ir_analysis
                                        is_access_control
                                        ls_message.

* get header communication structure
* field symbols assigned in cnf_access_prepare
  MOVE is_head_comm_area TO <head>.
  MOVE is_item_comm_area TO <item>.

* check date
  IF NOT iv_valid_from IS INITIAL.
    IF NOT iv_valid_to IS INITIAL AND
           iv_valid_to LE iv_valid_from.                  "#EC PORTABLE
      CLEAR iv_valid_to.
    ENDIF.
  ELSE.
    CLEAR iv_valid_to.
    IF iv_field_timestamp IS INITIAL OR
       iv_field_timestamp EQ ctcus_def_timestamp.
      CONCATENATE sy-datum '000000' INTO iv_valid_from.
    ELSE.
      ASSIGN COMPONENT iv_field_timestamp OF STRUCTURE <head>
             TO <time>.
      IF sy-subrc EQ 0.
        iv_valid_from = <time>.
        TRANSLATE iv_valid_from USING ' 0'.
      ELSE.
        CONCATENATE sy-datum '000000' INTO iv_valid_from.
      ENDIF.
    ENDIF.
  ENDIF.
* TODO protocol date
  CHECK NOT iv_valid_from IS INITIAL.

* do access
  lv_subrc = 16.
  IF is_access-gzugr NA 'AC'.
* check consistency I and Z
    READ TABLE gt_t682z_tab INTO gw_t682z_tab
         WITH KEY kappl = is_access-kappl
                  kvewe = is_access-kvewe
                  kozgf = is_access-kozgf
                  kolnr = is_access-kolnr.
    IF sy-subrc EQ 0 AND gw_t682z_tab-cccgf EQ is_access-cccgf AND
                         NOT is_access-cccgf IS INITIAL.

      CALL FUNCTION '/SAPCND/GET_DET_MODULE_NAMES'
        EXPORTING
          iv_application = is_access-kappl
          iv_usage       = is_access-kvewe
        IMPORTING
          ev_fb_access   = lv_func_access
        EXCEPTIONS
          OTHERS         = 8.
      IF sy-subrc NE 0.
        RAISE fatal_error.
      ENDIF.

* Hierarchical access type 'A' not supported for pricing-related usages.
* Due to legal reasons changes of the subsequent lines of code are not allowed.
* In case of doubts read the SAP note 1600482.
*      IF is_access-gzugr = 'A' AND
*       ( is_access-kvewe = 'PR' OR
*         is_access-kvewe = 'BO' OR
*         is_access-kvewe = 'DD' OR
*         is_access-kvewe = 'CD' OR
*         is_access-kvewe = 'PD' OR
*         is_access-kvewe = 'FG' OR
*         is_access-kvewe = 'FA' OR
*         is_access-kvewe = 'LM' OR
*         is_access-kvewe = 'MM').
*        MESSAGE x050(/sapcnd/det) WITH is_access-kozgf is_access-kolnr gw_t682z_tab-zifna.
*      ENDIF.
* Due to legal reasons changes of the preceding lines of code are not allowed.

      CALL FUNCTION lv_func_access
        EXPORTING
          i_condition_type   = iv_cond_type
          i_access           = is_access
          i_head_comm_area   = <head>
          i_item_comm_area   = <item>
          i_analysis         = ir_analysis
          i_analysis_message = ls_message
          i_access_control   = is_access_control
          i_valid_from       = iv_valid_from
          i_valid_to         = iv_valid_to
          i_multiple_access  = it_multiple_access
        IMPORTING
          e_purely_header    = ev_purely_header
        CHANGING
          c_det_records      = lt_det_recs
        EXCEPTIONS
          field_is_initial   = 1
          read_but_not_found = 2
          read_but_blocked   = 3
          missing_form       = 4
          magic_error        = 5
          fatal_error        = 6
          OTHERS             = 7.
      lv_subrc = sy-subrc.
    ELSE.
* TODO variant condition access not generated at the moment
      READ TABLE gt_t682z_tab INTO gw_t682z_tab
         WITH KEY kappl = is_access-kappl
                  kvewe = is_access-kvewe
                  kozgf = is_access-kozgf
                  kolnr = is_access-kolnr
                  flag_is_tab = 'X'.
      IF sy-subrc EQ 0.
        lv_subrc = 16.
      ELSE.
        lv_subrc = 5.
      ENDIF.
    ENDIF.
  ENDIF.
  CASE lv_subrc.
    WHEN 0.
      lv_returncode = gc_found.
    WHEN 1.
      lv_returncode = gc_field_initial.
    WHEN 2.
      lv_returncode = gc_not_found.
    WHEN 3.
      lv_returncode = gc_blocked.
    WHEN 4 OR 5.
      IF NOT ir_analysis IS INITIAL.
        ls_message-type  = /sapcnd/cl_det_analysis_ow=>type_warning.
        ls_message-subtype  =
                /sapcnd/cl_det_analysis_ow=>subtype_additional.
        ls_message-msgno = '303'.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
      CALL FUNCTION '/SAPCND/CNF_DYNAMIC_ACCESS'
        EXPORTING
          iv_cond_type        = iv_cond_type
          is_access           = is_access
          is_access_control   = is_access_control
          ir_analysis         = ir_analysis
          is_analysis_message = ls_message
          iv_valid_from       = iv_valid_from
          iv_valid_to         = iv_valid_to
          it_multiple_access  = it_multiple_access
        IMPORTING
          ev_purely_header    = ev_purely_header
          ev_returncode       = lv_returncode
        CHANGING
          ct_det_records      = lt_det_recs
        EXCEPTIONS
          fatal_error         = 1
          customizing_error   = 2
          OTHERS              = 5.
      CASE sy-subrc.
        WHEN 0.
        WHEN 2.
          IF NOT ir_analysis IS INITIAL AND
             NOT is_access_control-access_mess_add IS INITIAL.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '308'.
            CALL METHOD ir_analysis->add_message( ls_message ).
          ENDIF.
          RAISE customizing_error.
        WHEN OTHERS.
          IF NOT ir_analysis IS INITIAL AND
          NOT is_access_control-access_mess_add IS INITIAL.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '309'.
            CALL METHOD ir_analysis->add_message( ls_message ).
          ENDIF.
          RAISE fatal_error.
      ENDCASE.
    WHEN 16.
      CALL FUNCTION '/SAPCND/CNF_DYNAMIC_ACCESS'
        EXPORTING
          iv_cond_type        = iv_cond_type
          is_access           = is_access
          is_access_control   = is_access_control
          ir_analysis         = ir_analysis
          is_analysis_message = ls_message
          iv_valid_from       = iv_valid_from
          iv_valid_to         = iv_valid_to
          it_multiple_access  = it_multiple_access
        IMPORTING
          ev_purely_header    = ev_purely_header
          ev_returncode       = lv_returncode
        CHANGING
          ct_det_records      = lt_det_recs
        EXCEPTIONS
          fatal_error         = 1
          customizing_error   = 2
          OTHERS              = 5.
      CASE sy-subrc.
        WHEN 0.
        WHEN 2.
          IF NOT ir_analysis IS INITIAL AND
             NOT is_access_control-access_mess_add IS INITIAL.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '308'.
            CALL METHOD ir_analysis->add_message( ls_message ).
          ENDIF.
          RAISE customizing_error.
        WHEN OTHERS.
          IF NOT ir_analysis IS INITIAL AND
             NOT is_access_control-access_mess_add IS INITIAL.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '309'.
            CALL METHOD ir_analysis->add_message( ls_message ).
          ENDIF.
          RAISE fatal_error.
      ENDCASE.
    WHEN OTHERS.
      MESSAGE a893(/sapcnd/analysis) WITH '0001' 'LV61ZU03'.
  ENDCASE.

  CASE lv_returncode.
    WHEN gc_found.
      IF NOT ir_analysis IS INITIAL AND
         NOT is_access_control-access_mess_add IS INITIAL.
        ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        IF is_access_control-prestep_mode IS INITIAL.
          ls_message-msgno = '290'.
        ELSE.
          ls_message-msgno = '190'.
        ENDIF.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
* return determined records
      LOOP AT lt_det_recs INTO ls_det_recs.
        APPEND ls_det_recs-det_cond_ext TO et_det_records.
      ENDLOOP.
      es_analysis_message = ls_message.
      ev_returncode       = lv_returncode.
    WHEN gc_field_initial.
      IF NOT ir_analysis IS INITIAL AND
         NOT is_access_control-access_mess_add IS INITIAL.
        ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        IF is_access_control-prestep_mode IS INITIAL.
          ls_message-msgno = '230'.
        ELSE.
          ls_message-msgno = '130'.
        ENDIF.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
      es_analysis_message = ls_message.
      ev_returncode       = lv_returncode.
    WHEN gc_not_found.
      IF NOT ir_analysis IS INITIAL AND
         NOT is_access_control-access_mess_add IS INITIAL.
        ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        IF is_access_control-prestep_mode IS INITIAL.
          ls_message-msgno = '250'.
        ELSE.
          ls_message-msgno = '150'.
        ENDIF.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
      es_analysis_message = ls_message.
      ev_returncode       = lv_returncode.
    WHEN gc_blocked.
      IF NOT ir_analysis IS INITIAL AND
         NOT is_access_control-access_mess_add IS INITIAL.
        ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        IF is_access_control-prestep_mode IS INITIAL.
          ls_message-msgno = '270'.
        ELSE.
          ls_message-msgno = '170'.
        ENDIF.
        CALL METHOD ir_analysis->add_message( ls_message ).
      ENDIF.
      es_analysis_message = ls_message.
      ev_returncode       = lv_returncode.
  ENDCASE.

ENDFUNCTION.
