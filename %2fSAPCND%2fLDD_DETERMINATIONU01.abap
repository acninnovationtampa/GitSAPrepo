function /sapcnd/dd_determine.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_APPLICATION) TYPE  /SAPCND/APPLICATION
*"     REFERENCE(IV_DDPAT_TYPE) TYPE  /SAPCND/DDPAT_TYPE OPTIONAL
*"     REFERENCE(IV_PATTERN) TYPE  /SAPCND/DDPAT
*"     VALUE(IS_COMM_STRUC) TYPE  ANY
*"     REFERENCE(IR_ANALYSIS) TYPE REF TO  /SAPCND/CL_DET_ANALYSIS_OW
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RESULT) TYPE  /SAPCND/DD_DET_RESULT_T
*"  EXCEPTIONS
*"      EXC_INVALID_CONDTECH_SETTING
*"      EXC_INVALID_DD_SETTING
*"----------------------------------------------------------------------

* Definitionen
  constants: lc_usage_dd     type /sapcnd/usage value 'DD',
             lc_fstst_b      type /sapcnd/access_field_proc_type
                                                value 'B',
             lc_par_id(17)   type c             value '/SAPCND/DET_TRACE'.

  field-symbols:
        <f>                  type any,
        <com>                type any.

  data: lt_dd_t683s          type /sapcnd/dd_t683s_t,
        ls_dd_t683s          type /sapcnd/dd_t683s,
        lt_conditions        type /sapcnd/det_cond_collection_t,
        ls_conditions        type /sapcnd/det_cond_collection,
        lt_det_result        type /sapcnd/det_result_t,
        ls_det_result        type /sapcnd/det_result,
        ls_dd_det_result     type /sapcnd/dd_det_result,
        ls_dd_det_result_2   type /sapcnd/dd_det_result,
        lt_dd_det_result     type /sapcnd/dd_det_result_t,
        ls_field_value       type /sapcnd/det_field_value,
        ls_access_control    type /sapcnd/det_access_control,
        lv_steps             type i,
        lv_tabix             type sy-tabix,
        ls_fv_vadat          type /sapcnd/det_field_value,
        lv_trace             type /sapcnd/boolean,
        lo_analysis          type ref to /sapcnd/cl_det_analysis_ow,
        ls_header            type /sapcnd/det_analysis_header.

  data: ls_t681a             type /sapcnd/t681a_s.

* get structure names
  call function '/SAPCND/CUS_T681A_SEL'
    exporting
      i_application      = iv_application
    importing
      e_selected_data    = ls_t681a.
  if ls_t681a is initial.
    raise exc_invalid_condtech_setting.
  endif.

* read customizing
  call function '/SAPCND/DD_CUS_DD_T683S_SEL'
    exporting
      i_application      = iv_application
      i_ddpat_type       = iv_ddpat_type
    importing
      e_selection_result = lt_dd_t683s
    exceptions
      exc_locking_failed = 1
      others             = 2.
  if sy-subrc ne 0.
    raise exc_invalid_dd_setting.
  endif.

  delete lt_dd_t683s where ddpat ne iv_pattern.
  sort   lt_dd_t683s by ddpat ddstep.
  describe table lt_dd_t683s lines lv_steps.

  if lv_steps eq 0.
    return.
  endif.

  get parameter id lc_par_id field lv_trace.
  if ir_analysis is initial.
    if not lv_trace is initial.
      ls_header-application = iv_application.
      ls_header-usage       = lc_usage_dd.
      ls_header-collection  = iv_pattern.
      ls_header-collection_text = iv_ddpat_type.
      create object lo_analysis
        exporting  i_header = ls_header
        exceptions others   = 0.
    endif.
  else.
    lo_analysis = ir_analysis.
  endif.

* process all steps subsequently
  loop at lt_dd_t683s into ls_dd_t683s.
    lv_tabix = sy-tabix.

*   one step in a determination pattern corresponds to exactly one
*   condition type
    clear lt_conditions.
    ls_conditions-kschl = ls_dd_t683s-kschl.
    ls_conditions-stunr = ls_dd_t683s-ddstep.
    append ls_conditions to lt_conditions.

*   the first step uses the given information in is_comm_struc only
    if lv_tabix eq 1.

      try.
          assign is_comm_struc to <com> casting type (ls_t681a-str_total_com).
        catch cx_root.
          if not lo_analysis is initial.
            call method lo_analysis->close.
          endif.
          raise exc_invalid_condtech_setting.
      endtry.

      call function '/SAPCND/CNF_DETERMINE'
        exporting
          iv_application     = iv_application
          iv_usage           = lc_usage_dd
          is_doc             = <com>
          it_cond_collection = lt_conditions
          ir_analysis        = lo_analysis
          is_access_control  = ls_access_control
        importing
          et_det_records     = lt_det_result
        exceptions
          fatal_error        = 1
          exc_no_t681a       = 2
          exc_no_t681v       = 3
          exc_no_t681z       = 4
          others             = 5.
      case sy-subrc.
        when 0.
        when 1.
          if not lo_analysis is initial.
            if not lv_trace is initial.
              call method lo_analysis->save.
            endif.
            call method lo_analysis->close.
          endif.
          return.
        when others.
          if not lo_analysis is initial.
            if not lv_trace is initial.
              call method lo_analysis->save.
            endif.
            call method lo_analysis->close.
          endif.
          raise exc_invalid_condtech_setting.
      endcase.
*     Prüfung auf Einzelermittlung und Anzahl der Ergebnisse
      loop at lt_det_result into ls_det_result.
        clear ls_dd_det_result.
        loop at ls_det_result-record-fv_vakey into ls_fv_vadat
          where fstst = lc_fstst_b.
          append ls_fv_vadat to ls_dd_det_result-fv_table.
        endloop.
        loop at ls_det_result-record-fv_vadat into ls_fv_vadat.
          append ls_fv_vadat to ls_dd_det_result-fv_table.
        endloop.
        append ls_dd_det_result to et_result.
      endloop.

    else.

      clear lt_dd_det_result[].
      loop at et_result into ls_dd_det_result_2.

        loop at ls_dd_det_result_2-fv_table into ls_field_value.
          assign component ls_field_value-field
            of structure <com> to <f>.
          if sy-subrc eq 0.
            move ls_field_value-value to <f>.
          endif.
        endloop.

        clear lt_det_result[].
        call function '/SAPCND/CNF_DETERMINE'
          exporting
            iv_application     = iv_application
            iv_usage           = lc_usage_dd
            is_doc             = <com>
            it_cond_collection = lt_conditions
            ir_analysis        = lo_analysis
            is_access_control  = ls_access_control
          importing
            et_det_records     = lt_det_result
          exceptions
            fatal_error        = 1
            exc_no_t681a       = 2
            exc_no_t681v       = 3
            exc_no_t681z       = 4
            others             = 5.
        case sy-subrc.
          when 0.
          when 1.
            if not lo_analysis is initial.
              if not lv_trace is initial.
                call method lo_analysis->save.
              endif.
              call method lo_analysis->close.
            endif.
            return.
          when others.
            if not lo_analysis is initial.
              if not lv_trace is initial.
                call method lo_analysis->save.
              endif.
              call method lo_analysis->close.
            endif.
            raise exc_invalid_condtech_setting.
        endcase.
*       Prüfung auf Einzelermittlung und Anzahl der Ergebnisse
        loop at lt_det_result into ls_det_result.
          clear ls_dd_det_result.
          loop at ls_det_result-record-fv_vakey into ls_fv_vadat
            where fstst = lc_fstst_b.
            append ls_fv_vadat to ls_dd_det_result-fv_table.
          endloop.
          loop at ls_det_result-record-fv_vadat into ls_fv_vadat.
            append ls_fv_vadat to ls_dd_det_result-fv_table.
          endloop.
          append ls_dd_det_result to lt_dd_det_result.
        endloop.

      endloop.

      et_result = lt_dd_det_result.

    endif.

  endloop.

  if not lo_analysis is initial.
    if not lv_trace is initial.
      call method lo_analysis->save.
    endif.
    call method lo_analysis->close.
  endif.

endfunction.
