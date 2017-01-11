function /sapcnd/cnf_determine .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_APPLICATION) TYPE  /SAPCND/APPLICATION
*"     VALUE(IV_USAGE) TYPE  /SAPCND/USAGE
*"     REFERENCE(IS_HEAD_DOC) TYPE  ANY OPTIONAL
*"     REFERENCE(IS_ITEM_DOC) TYPE  ANY OPTIONAL
*"     REFERENCE(IS_DOC) TYPE  ANY OPTIONAL
*"     REFERENCE(IT_COND_COLLECTION) TYPE
*"        /SAPCND/DET_COND_COLLECTION_T
*"     VALUE(IV_VALID_FROM) TYPE  /SAPCND/TIMESTAMP_FROM OPTIONAL
*"     VALUE(IV_VALID_TO) TYPE  /SAPCND/TIMESTAMP_TO OPTIONAL
*"     VALUE(IR_ANALYSIS) TYPE REF TO  /SAPCND/CL_DET_ANALYSIS_OW
*"       OPTIONAL
*"     REFERENCE(IS_ACCESS_CONTROL) TYPE  /SAPCND/DET_ACCESS_CONTROL
*"       OPTIONAL
*"     REFERENCE(IT_MULTIPLE_ACCESS) TYPE  /SAPCND/KEY_VALUE_PAIR_TABLE
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_DET_RECORDS) TYPE  /SAPCND/DET_RESULT_T
*"     REFERENCE(EV_FB_US_RECORD_GET) TYPE  FUNCNAME
*"  EXCEPTIONS
*"      FATAL_ERROR
*"      EXC_NO_T681A
*"      EXC_NO_T681V
*"      EXC_NO_T681Z
*"----------------------------------------------------------------------

  field-symbols:
        <head_doc>           type any,
        <item_doc>           type any,
        <doc>                type any.

* condition records
  data  lt_det_recs          type /sapcnd/det_cond_ext_t.
  data  ls_det_recs          type /sapcnd/det_cond_ext.
  data  ls_access_control    type /sapcnd/det_access_control.

  data  lv_purely_header     type /sapcnd/boolean.

* flag to save result of prestep and complete access
  data: lv_read_and_found    type /sapcnd/boolean,
        lv_prestep_and_found type /sapcnd/boolean.

* return code prestep
  data  lv_vors_subrc        type sysubrc.
  data  lv_subrc_req         type sysubrc.
  data  lv_pre_subrc         type sysubrc.

  data  lv_returncode        type /sapcnd/det_access_returncode.

  data: lv_stunr_temp type /sapcnd/cond_coll_id value 'AAA',
        lv_zaehk_temp type /sapcnd/cond_coll_id_sub,
        lv_kzexl_temp type /sapcnd/flag_exclusive_access.

  data  lw_cond_coll    type /sapcnd/det_cond_collection.
  data  ls_message      type /sapcnd/det_analysis_message.
  data  hs_message      type /sapcnd/det_analysis_message.
  data  lw_prestep      type /sapcnd/det_prestep.
  data  lw_conddet_tab  type /sapcnd/det_result.

  data  ls_t682i        type /sapcnd/t682i_s.
  data  ls_t685         type /sapcnd/t685.

  data  lv_func_insert_prestep  type funcname.
  data  lv_func_read_prestep    type funcname.
  data  lv_func_refresh         type funcname.
  data  lv_func_req_check       type funcname.

  data  ls_analysis_header      type /sapcnd/det_analysis_header.

  data  lv_head_doc_ref         type ref to data.
  data  lv_item_doc_ref         type ref to data.
  data  lv_doc_ref              type ref to data.
  data  lv_subrc                type sysubrc.

* END OF DEFINITION

* BEGIN OF PREPARATION

  ls_access_control = is_access_control.

* reads usage and application and provides global field symbols
* <HEAD>, <ITEM>, <DATA>
* access_control-buffer_usag_data gets changed if there is no
* usage-dependent cond-table-part defined in t681v
  call function '/SAPCND/CNF_GET_APPL_USAGE'
       exporting
            iv_application    = iv_application
            iv_usage          = iv_usage
            is_access_control = ls_access_control
       importing
            es_access_control = ls_access_control
       exceptions
            fatal_error       = 1
            exc_no_t681a      = 2
            exc_no_t681v      = 3
            others            = 4.
  case sy-subrc.
    when 0.
    when 2.
      raise exc_no_t681a.
    when 3.
      raise exc_no_t681v.
    when others.
      raise fatal_error.
  endcase.

* prepare analysis (fills GS_T681AT, GS_T681VT)
  if not ir_analysis is initial.
    ls_analysis_header = ir_analysis->get_header( ).
    if ls_analysis_header-application ne iv_application or
       ls_analysis_header-usage       ne iv_usage.
      clear ir_analysis.
    else.
      perform kvewe_kappl_select_text using iv_usage
                                            iv_application.
    endif.
  endif.

* clean up
  clear et_det_records.
  clear gt_conddet_tab.

  call function '/SAPCND/GET_DET_MODULE_NAMES'
       exporting
            iv_application         = iv_application
            iv_usage               = iv_usage
            iv_fugr_appl           = gs_t681a-det_namespace
            iv_fugr_usage          = gs_t681v-det_namespace
       importing
            ev_fb_prestep_read     = lv_func_read_prestep
            ev_fb_prestep_insert   = lv_func_insert_prestep
            ev_fb_refresh          = lv_func_refresh
            ev_fb_req_check        = lv_func_req_check
            ev_fb_us_get_rec       = ev_fb_us_record_get
       exceptions
            exc_kapplkvewe_missing = 4
            others                 = 8.
  case sy-subrc.
    when 0.
    when 4.
      raise exc_no_t681z.
    when others.
      raise fatal_error.
  endcase.

  call function lv_func_refresh.

  if is_doc is supplied.
    get reference of is_doc into lv_doc_ref.
    try.
        assign lv_doc_ref->* to <doc>.
        lv_subrc = sy-subrc.
      catch cx_sy_assign_error.
        lv_subrc = 16.
    endtry.
    if lv_subrc ne 0.
      raise fatal_error.
    endif.
    move-corresponding <doc> to <head>.
    move-corresponding <doc> to <item>.
  else.
    get reference of is_head_doc into lv_head_doc_ref.
    get reference of is_item_doc into lv_item_doc_ref.
    try.
        assign lv_head_doc_ref->* to <head_doc>.
        if sy-subrc eq 0.
          assign lv_item_doc_ref->* to <item_doc>.
          lv_subrc = sy-subrc.
        else.
          lv_subrc = sy-subrc.
        endif.
      catch cx_sy_assign_error.
        lv_subrc = 16.
    endtry.
    if lv_subrc ne 0.
      raise fatal_error.
    endif.
    move-corresponding <head_doc> to <head>.
    move-corresponding <item_doc> to <head>.
    move-corresponding <item_doc> to <item>.
  endif.

* prepare access procedure (GT_CONDDET_TAB)
  loop at it_cond_collection into lw_cond_coll.
    clear gw_conddet_tab.
    move-corresponding lw_cond_coll to gw_conddet_tab.
    if lw_cond_coll-kschl is initial.
      append gw_conddet_tab to gt_conddet_tab.
    else.
* SPÄTER GEPUFFERT ERSETZEN
      select single * from /sapcnd/t685 into ls_t685
             where kvewe = iv_usage
             and   kappl = iv_application
             and   kschl = lw_cond_coll-kschl.
* Error
      if sy-subrc ne 0.
        continue.
        if not ir_analysis is initial.
          clear ls_message.
          ls_message-coll_id = gw_conddet_tab-stunr.
          ls_message-coll_id_sub = gw_conddet_tab-zaehk.
          ls_message-cond_type = lw_cond_coll-kschl.
          ls_message-type   = /sapcnd/cl_det_analysis_ow=>type_error.
          ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
          ls_message-msgno = '301'.
          ls_message-msgv1 = lw_cond_coll-kschl.
          ls_message-msgv2 = gs_t681vt-vtext.
          ls_message-msgv3 = gs_t681at-vtext.
          call method ir_analysis->add_message( ls_message ).
        endif.
      endif.

      move-corresponding ls_t685 to gw_conddet_tab.
      if gw_conddet_tab-rkschl is initial.
        gw_conddet_tab-rkschl = gw_conddet_tab-kschl.
      endif.

      if ls_t685-kozgf is initial.
        append gw_conddet_tab to gt_conddet_tab.
      else.
        select * from /sapcnd/t682i into ls_t682i
               where kvewe = iv_usage
               and   kappl = iv_application
               and   kozgf = ls_t685-kozgf.
          move-corresponding ls_t682i to gw_conddet_tab.
          gw_conddet_tab-kobed_zgr = ls_t682i-kobed.
          append gw_conddet_tab to gt_conddet_tab.
        endselect.
* Error
        if sy-subrc ne 0.
          continue.
          if not ir_analysis is initial.
            clear ls_message.
            ls_message-coll_id = gw_conddet_tab-stunr.
            ls_message-coll_id_sub = gw_conddet_tab-zaehk.
            ls_message-cond_type = lw_cond_coll-kschl.
            ls_message-access_sequence = ls_t685-kozgf.
            ls_message-type   = /sapcnd/cl_det_analysis_ow=>type_error.
          ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '302'.
            ls_message-msgv1 = ls_t685-kozgf.
            ls_message-msgv2 = gs_t681vt-vtext.
            ls_message-msgv3 = gs_t681at-vtext.
            call method ir_analysis->add_message( ls_message ).
          endif.
        endif.

      endif.
    endif.
  endloop.

* order of determination is important
  sort gt_conddet_tab by stunr zaehk kolnr.

* read prestep optimization info
  select * from /sapcnd/t682v into table gt_t682v_tab
       where kvewe = iv_usage
         and kappl = iv_application.

* certain stop mode requires prestep
  if ls_access_control-stop_mode eq gc_stop_mode_prestep.
    ls_access_control-force_prestep = yes.
  endif.

* END OF PREPARATION

* BEGIN OF MAIN PART

  loop at gt_conddet_tab into gw_conddet_tab.
    clear lt_det_recs.
* these fields in ls_message must not be changed in this loop
    ls_message-coll_id     = gw_conddet_tab-stunr.
    ls_message-coll_id_sub = gw_conddet_tab-zaehk.
    ls_message-access_id   = gw_conddet_tab-kolnr.
    ls_message-cond_type   = gw_conddet_tab-kschl.
    ls_message-access_sequence = gw_conddet_tab-kozgf.
* no new line (still the same condition)
    if lv_stunr_temp eq gw_conddet_tab-stunr and
       lv_zaehk_temp eq gw_conddet_tab-zaehk.
      if ls_access_control-stop_mode eq gc_stop_mode_do_not and
             not lv_kzexl_temp is initial       and
             lv_read_and_found eq yes.
* record has been found in exclusive access - stop
* return information if required
        if not ls_access_control-return_all is initial.
          append gw_conddet_tab to et_det_records.
        endif.
* analysis
        if not ir_analysis is initial.
          ls_message-type   = /sapcnd/cl_det_analysis_ow=>type_message.
          ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
          ls_message-msgno = '050'.
          call method ir_analysis->add_message( ls_message ).
        endif.
        continue.
      endif.
    else.
      clear lv_read_and_found.
      clear lv_prestep_and_found.
    endif.
* set temp information for next loop
    lv_stunr_temp = gw_conddet_tab-stunr.
    lv_zaehk_temp = gw_conddet_tab-zaehk.
    lv_kzexl_temp = gw_conddet_tab-kzexl.
    case ls_access_control-stop_mode.
      when gc_stop_mode_do_not.
* usual case
      when gc_stop_mode_read.
* stop if first condition record has been found
        if lv_read_and_found eq yes.
* return information if required
          if not ls_access_control-return_all is initial.
            append gw_conddet_tab to et_det_records.
          endif.
* analysis
          if not ir_analysis is initial.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype =
                   /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '051'.
            call method ir_analysis->add_message( ls_message ).
          endif.
* next line
          continue.
        endif.
      when gc_stop_mode_prestep.
* stop if first record has been found in prestep-mode
        if lv_prestep_and_found eq yes.
* return information if required
          if not ls_access_control-return_all is initial.
            append gw_conddet_tab to et_det_records.
          endif.
* analysis
          if not ir_analysis is initial.
            ls_message-type  = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype =
                  /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '051'.
            call method ir_analysis->add_message( ls_message ).
          endif.
* next line
          continue.
        endif.
    endcase.

* return condition without access just as is
    if gw_conddet_tab-kozgf is initial.
      append gw_conddet_tab to et_det_records.
* analysis
      if not ir_analysis is initial.
* message on cond_type level
        hs_message = ls_message.
        clear hs_message-access_id.
        hs_message-type   = /sapcnd/cl_det_analysis_ow=>type_message.
        hs_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        hs_message-msgno = '020'.
        hs_message-msgv1 = gw_conddet_tab-kschl.
        call method ir_analysis->add_message( hs_message ).
      endif.
* next line
      continue.
    endif.

* check if prestep is desired
    clear lv_pre_subrc.
    if not iv_valid_from is initial and
       not iv_valid_to   is initial.
      lv_pre_subrc = 4.
    else.
      if gw_conddet_tab-kkopf           eq yes or
         ls_access_control-force_prestep eq yes.
        lv_pre_subrc = 0.
      else.
        read table gt_t682v_tab
             with table key
                      kvewe = iv_usage
                      kappl = iv_application
                      kschl = gw_conddet_tab-kschl
                      kolnr = gw_conddet_tab-kolnr
             transporting no fields.
        lv_pre_subrc = sy-subrc.
      endif.
    endif.

*PRESTEP
    if lv_pre_subrc eq 0.
* CURRENTLY THERE IS NO REQUIREMENT CHECK IN PRESTEP MODE

** execute requirement (access)
*      IF NOT GW_CONDDET_TAB-KOBED_ZGR IS INITIAL.
** read prestep information
*        CLEAR LW_PRESTEP.
*        MOVE-CORRESPONDING GW_CONDDET_TAB TO LW_PRESTEP.
*        LW_PRESTEP-KOBED = GW_CONDDET_TAB-KOBED_ZGR.
*        LV_VORS_SUBRC = 4.
*        CALL FUNCTION LV_FUNC_READ_PRESTEP
*             EXPORTING
*                  I_HEAD_COMM_AREA = <HEAD>
*                  I_PRESTEP_WA     = LW_PRESTEP
*             IMPORTING
*                  E_PRE_SUBRC      = LV_VORS_SUBRC
*                  E_VORRC          = GW_CONDDET_TAB-VORRC.
** do not execute requirement twice
*        IF LV_VORS_SUBRC EQ 0.
*          IF GW_CONDDET_TAB-VORRC EQ GC_VORRC_NOT_FOUND.
** return information if required
*            IF NOT ls_access_control-RETURN_ALL IS INITIAL.
*              APPEND GW_CONDDET_TAB TO ET_DET_RECORDS.
*            ENDIF.
** analysis
*            IF NOT IR_ANALYSIS IS INITIAL.
*              LS_MESSAGE-TYPE  =
*                 /SAPCND/CL_DET_ANALYSIS_OW=>TYPE_MESSAGE.
*              LS_MESSAGE-SUBTYPE =
*                 /SAPCND/CL_DET_ANALYSIS_OW=>SUBTYPE_MAIN.
*              LS_MESSAGE-MSGNO = '121'.
*              LS_MESSAGE-MSGV1 = GW_CONDDET_TAB-KOBED_ZGR.
*              CALL METHOD IR_ANALYSIS->ADD_MESSAGE( LS_MESSAGE ).
*            ENDIF.
** next line
*            CONTINUE.
*          ENDIF.
*        ELSE.
*          LV_SUBRC_ACCESS = 0.
** save prestep information
*          IF LV_SUBRC_ACCESS EQ 0.
*            GW_CONDDET_TAB-VORRC = GC_VORRC_FOUND.
*          ELSE.
*            GW_CONDDET_TAB-VORRC = GC_VORRC_NOT_FOUND.
*          ENDIF.
*          CLEAR LW_PRESTEP.
*          MOVE-CORRESPONDING GW_CONDDET_TAB TO LW_PRESTEP.
*          LW_PRESTEP-KOBED = GW_CONDDET_TAB-KOBED_ZGR.
*
*          CALL FUNCTION LV_FUNC_INSERT_PRESTEP
*               EXPORTING
*                    I_HEAD_COMM_AREA = <HEAD>
*                    I_PRESTEP_WA     = LW_PRESTEP.
*
*          IF LV_SUBRC_ACCESS NE 0.
** return information if required
*            IF NOT ls_access_control-RETURN_ALL IS INITIAL.
*              APPEND GW_CONDDET_TAB TO ET_DET_RECORDS.
*            ENDIF.
** analysis
*            IF NOT IR_ANALYSIS IS INITIAL.
*              LS_MESSAGE-TYPE  =
*                  /SAPCND/CL_DET_ANALYSIS_OW=>TYPE_MESSAGE.
*              LS_MESSAGE-SUBTYPE =
*                  /SAPCND/CL_DET_ANALYSIS_OW=>SUBTYPE_MAIN.
*              LS_MESSAGE-MSGNO = '121'.
*              LS_MESSAGE-MSGV1 = GW_CONDDET_TAB-KOBED_ZGR.
*              CALL METHOD IR_ANALYSIS->ADD_MESSAGE( LS_MESSAGE ).
*            ENDIF.
** next line
*            CONTINUE.
*          ENDIF.
*        ENDIF.
*      ENDIF.
* read prestep information
      clear lw_prestep.
      move-corresponding gw_conddet_tab to lw_prestep.
      clear lw_prestep-kobed.
      lv_vors_subrc = 4.
      call function lv_func_read_prestep
           exporting
                i_head_comm_area = <head>
                i_prestep_wa     = lw_prestep
           importing
                e_pre_subrc      = lv_vors_subrc
                e_vorrc          = gw_conddet_tab-vorrc
                e_records        = lt_det_recs.
* read once
      if lv_vors_subrc eq 0 and ir_analysis is initial.
        if gw_conddet_tab-vorrc eq gc_vorrc_not_found.
* return information if required
          if not ls_access_control-return_all is initial.
            append gw_conddet_tab to et_det_records.
          endif.
* next line
          continue.
        endif.
* set variables to publish prestep result
        if gw_conddet_tab-vorrc eq gc_vorrc_found_exact or
           gw_conddet_tab-vorrc eq gc_vorrc_found.
          lv_prestep_and_found = yes.
        endif.
* that's it
        if gw_conddet_tab-vorrc eq gc_vorrc_found_exact.
* return information
          lw_conddet_tab = gw_conddet_tab.
          loop at lt_det_recs into ls_det_recs.
            move ls_det_recs to lw_conddet_tab-record.
            append lw_conddet_tab to et_det_records.
          endloop.
* TODO exit ?
          lv_read_and_found = yes.
* next line
          continue.
        endif.
      else.
* access in prestep mode
        clear lv_returncode.
        clear ls_t682i.
        move-corresponding gw_conddet_tab to ls_t682i.
        ls_t682i-kappl     = iv_application.
        ls_t682i-kvewe     = iv_usage.
        ls_t682i-kobed_num = gw_conddet_tab-kobed_zgr.
        ls_access_control-prestep_mode = 'X'.
        call function '/SAPCND/CNF_ACCESS'
             exporting
                  iv_cond_type        = gw_conddet_tab-rkschl
                  is_access           = ls_t682i
                  is_head_comm_area   = <head>
                  is_item_comm_area   = <item>
                  ir_analysis         = ir_analysis
                  is_analysis_message = ls_message
                  is_access_control   = ls_access_control
                  iv_valid_from       = iv_valid_from
                  iv_valid_to         = iv_valid_to
                  iv_field_timestamp  = gw_conddet_tab-field_timestamp
                  it_multiple_access  = it_multiple_access
             importing
                  ev_purely_header    = lv_purely_header
                  ev_returncode       = lv_returncode
                  et_det_records      = lt_det_recs
             exceptions
                  fatal_error         = 5
                  customizing_error   = 4
                  others              = 6.
        case sy-subrc.
          when 0.
          when 4.
            if not ir_analysis is initial.
              ls_message-type =
                /sapcnd/cl_det_analysis_ow=>type_message.
              ls_message-subtype =
                /sapcnd/cl_det_analysis_ow=>subtype_main.
              ls_message-msgno = '308'.
              call method ir_analysis->add_message( ls_message ).
            endif.
            continue.
          when others.
            raise fatal_error.
        endcase.
* prestep successful
        if lv_returncode eq gc_found.
* save prestep information
          if lv_purely_header eq yes.
            gw_conddet_tab-vorrc = gc_vorrc_found_exact.
          else.
            gw_conddet_tab-vorrc = gc_vorrc_found.
          endif.
        else.
          gw_conddet_tab-vorrc = gc_vorrc_not_found.
        endif.
* set variables to publish prestep result
        if gw_conddet_tab-vorrc eq gc_vorrc_found_exact or
           gw_conddet_tab-vorrc eq gc_vorrc_found.
          lv_prestep_and_found = yes.
        endif.
* check prestep result
        if gw_conddet_tab-vorrc eq gc_vorrc_found_exact.
* TODO exit ?
          lv_read_and_found = yes.
        endif.
* save prestep information
        if lv_vors_subrc ne 0.
          clear lw_prestep.
          move-corresponding gw_conddet_tab to lw_prestep.
          clear lw_prestep-kobed.
          lw_prestep-records = lt_det_recs.
          call function lv_func_insert_prestep
               exporting
                    i_head_comm_area = <head>
                    i_prestep_wa     = lw_prestep.
        endif.
* check prestep result
        if gw_conddet_tab-vorrc eq gc_vorrc_found_exact or
           gw_conddet_tab-vorrc eq gc_vorrc_not_found.
* analysis
          if not ir_analysis is initial.
* everything has been found in prestep mode
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
            ls_message-subtype =
               /sapcnd/cl_det_analysis_ow=>subtype_main.
            if gw_conddet_tab-vorrc eq gc_vorrc_found_exact.
              ls_message-msgno = '190'.
            else.
              if lv_vors_subrc eq 0.
                ls_message-msgno = '151'.
              else.
                case lv_returncode.
                  when gc_field_initial.
                    ls_message-msgno = '130'.
                  when gc_not_found.
                    ls_message-msgno = '150'.
                  when gc_blocked.
                    ls_message-msgno = '170'.
                  when others.
                    ls_message-type =
                         /sapcnd/cl_det_analysis_ow=>type_error.
                    ls_message-subtype =
                        /sapcnd/cl_det_analysis_ow=>subtype_main.
                    ls_message-msgno = '008'.
                endcase.
              endif.
            endif.
            call method ir_analysis->add_message( ls_message ).
          endif.
* return information
          lw_conddet_tab = gw_conddet_tab.
          if gw_conddet_tab-vorrc eq gc_vorrc_found_exact.
            loop at lt_det_recs into ls_det_recs.
              move ls_det_recs to lw_conddet_tab-record.
              append lw_conddet_tab to et_det_records.
            endloop.
          else.
            if not ls_access_control-return_all is initial.
              append lw_conddet_tab to et_det_records.
            endif.
          endif.
* next line
          continue.
        endif.
      endif.
    else.
      gw_conddet_tab-vorrc = gc_vorrc_not_done.
    endif.

*COMPLETE ACCESS

    if not gw_conddet_tab-kobed_zgr is initial.
      call function lv_func_req_check
           exporting
                i_cust_info       = gw_conddet_tab
                i_acs_head        = <head>
                i_acs_item        = <item>
           exceptions
                req_not_fulfilled = 1
                others            = 2.
      lv_subrc_req = sy-subrc.
      if lv_subrc_req ne 0.
* return information if required
        if not ls_access_control-return_all is initial.
          append gw_conddet_tab to et_det_records.
        endif.
* analysis
        if not ir_analysis is initial.
          ls_message-type   = /sapcnd/cl_det_analysis_ow=>type_message.
          ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
          ls_message-msgno = '221'.
          ls_message-msgv1 = gw_conddet_tab-kobed_zgr.
          call method ir_analysis->add_message( ls_message ).
        endif.
* next line
        continue.
      endif.
    endif.

* execute complete access
    clear lv_returncode.
    clear ls_t682i.
    move-corresponding gw_conddet_tab to ls_t682i.
    ls_t682i-kappl = iv_application.
    ls_t682i-kvewe = iv_usage.
    ls_t682i-kobed_num = gw_conddet_tab-kobed_zgr.
    clear ls_access_control-prestep_mode.
    call function '/SAPCND/CNF_ACCESS'
         exporting
              iv_cond_type        = gw_conddet_tab-rkschl
              is_access           = ls_t682i
              is_head_comm_area   = <head>
              is_item_comm_area   = <item>
              ir_analysis         = ir_analysis
              is_analysis_message = ls_message
              is_access_control   = ls_access_control
              iv_valid_from       = iv_valid_from
              iv_valid_to         = iv_valid_to
              iv_field_timestamp  = gw_conddet_tab-field_timestamp
              it_multiple_access  = it_multiple_access
         importing
              ev_purely_header    = lv_purely_header
              ev_returncode       = lv_returncode
              et_det_records      = lt_det_recs
         exceptions
              fatal_error         = 5
              customizing_error   = 4
              others              = 6.
    case sy-subrc.
      when 0.
      when 4.
        if not ir_analysis is initial.
          ls_message-type =
            /sapcnd/cl_det_analysis_ow=>type_message.
          ls_message-subtype =
            /sapcnd/cl_det_analysis_ow=>subtype_main.
          ls_message-msgno = '308'.
          call method ir_analysis->add_message( ls_message ).
        endif.
        continue.
      when others.
        raise fatal_error.
    endcase.
* return information
    if lv_returncode eq gc_found.
      lw_conddet_tab = gw_conddet_tab.
      loop at lt_det_recs into ls_det_recs.
        move ls_det_recs to lw_conddet_tab-record.
        append lw_conddet_tab to et_det_records.
      endloop.
* TODO exit ?
      lv_read_and_found = yes.
* analysis
      if not ir_analysis is initial and
         lv_read_and_found eq yes.
        ls_message-type   = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        ls_message-msgno = '290'.
        call method ir_analysis->add_message( ls_message ).
      endif.
    else.
* return information if required
      if not ls_access_control-return_all is initial.
        append gw_conddet_tab to et_det_records.
      endif.
* analysis
      if not ir_analysis is initial.
        ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
        ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
        case lv_returncode.
          when gc_field_initial.
            ls_message-msgno = '230'.
          when gc_not_found.
            ls_message-msgno = '250'.
          when gc_blocked.
            ls_message-msgno = '270'.
          when others.
            ls_message-type = /sapcnd/cl_det_analysis_ow=>type_error.
            ls_message-subtype =
                /sapcnd/cl_det_analysis_ow=>subtype_main.
            ls_message-msgno = '008'.
        endcase.
        call method ir_analysis->add_message( ls_message ).
      endif.
    endif.
* post last message on access level on cond_type level again
* the one with highest msgno will be displayed in analysis
    if not ir_analysis is initial.
      hs_message = ls_message.
      clear hs_message-access_id.
      call method ir_analysis->add_message( hs_message ).
    endif.
  endloop.

endfunction.
