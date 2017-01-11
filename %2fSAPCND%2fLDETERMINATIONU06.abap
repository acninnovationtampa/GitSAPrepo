FUNCTION /SAPCND/CNF_EVAL_RELSTAT .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_CALLMODE) TYPE  /SAPCND/KCALLMODE DEFAULT 'A'
*"     VALUE(IS_ACCESS) TYPE  /SAPCND/T682I
*"     VALUE(IV_PRESTEP) TYPE  /SAPCND/BOOLEAN
*"     VALUE(IV_PURELY_HEADER) TYPE  /SAPCND/BOOLEAN
*"     VALUE(IR_ANALYSIS) TYPE REF TO  /SAPCND/CL_DET_ANALYSIS_OW
*"     VALUE(IS_MESSAGE) TYPE  /SAPCND/DET_ANALYSIS_MESSAGE
*"  CHANGING
*"     REFERENCE(CT_COND_TAB) TYPE  /SAPCND/DET_COND_INT_T
*"----------------------------------------------------------------------

  data    ls_cond_tab       type /sapcnd/det_cond_int.
  data    ls_cond_allowed   type /sapcnd/det_cond_int.
  data    lv_prio_tabix     type sytabix.
  data    lv_del_tabix      type sytabix.

  data    lt_cond_allowed   type /sapcnd/det_cond_int_t.

  data    lt_priorities     type /sapcnd/kpriorities.

  if iv_callmode is initial.
    iv_callmode = 'A'.
  endif.

* get priority information
  call function '/SAPCND/CNF_GET_PRIORITIES_NEW'
       exporting
            iv_call_mode  = iv_callmode
       importing
            et_priorities = lt_priorities.

* only implemented if records read with defined date
  loop at ct_cond_tab into ls_cond_tab.

* compare current release status with call mode info
    read table lt_priorities with key
           table_line = ls_cond_tab-release_status
           transporting no fields.
    lv_prio_tabix = sy-tabix.
    if sy-subrc eq 0.
* release status is valid
* check if entry in internal table exists with the same vakey
      read table lt_cond_allowed into ls_cond_allowed
         with key object_id  = ls_cond_tab-object_id
                  fv_vakey   = ls_cond_tab-fv_vakey.
      lv_del_tabix = sy-tabix.
      if sy-subrc eq 0.
* check if priority of release status is higher
        if lv_prio_tabix > ls_cond_allowed-prio_index.
          if not ir_analysis is initial and
             ( iv_prestep eq no  or
               ( iv_prestep eq yes and
                 iv_purely_header eq yes and
                 is_access-gzugr ca 'AC' )
             ).
            call function '/SAPCND/CNF_ANALYSIS_REC'
                 exporting
                      ir_analysis       = ir_analysis
                      is_message        = is_message
                      iv_condition_id   = ls_cond_allowed-varnumh
                      iv_object_id      = ls_cond_allowed-object_id
                      iv_reject         =
                        /sapcnd/cl_det_analysis_ow=>reject_relstat
                      iv_tabix          = 0
                     iv_release_status = ls_cond_allowed-release_status.
          endif.
* delete version with lower priority
          delete lt_cond_allowed index lv_del_tabix.
* insert current record instead
          ls_cond_tab-prio_index = lv_prio_tabix.
          append ls_cond_tab to lt_cond_allowed.
        else.
* current priority is lower -> do not add to internal table
* but write information in analysis mode
          if not ir_analysis is initial and
             ( iv_prestep eq no  or
               ( iv_prestep eq yes and
                 iv_purely_header eq yes and
                 is_access-gzugr ca 'AC' )
             ).
            call function '/SAPCND/CNF_ANALYSIS_REC'
                 exporting
                      ir_analysis       = ir_analysis
                      is_message        = is_message
                      iv_condition_id   = ls_cond_allowed-varnumh
                      iv_object_id      = ls_cond_allowed-object_id
                      iv_reject         =
                        /sapcnd/cl_det_analysis_ow=>reject_relstat
                      iv_tabix          = 0
                     iv_release_status = ls_cond_allowed-release_status.
          endif.
        endif.
      else.
* insert current record into internal table and
* save priority index
        ls_cond_tab-prio_index = lv_prio_tabix.
        append ls_cond_tab to lt_cond_allowed.
      endif.
    else.
* release status in invalid
* do not append record to internal table but write info
* in analysis mode
      if not ir_analysis is initial and
         ( iv_prestep eq no  or
           ( iv_prestep eq yes and
             iv_purely_header eq yes and
             is_access-gzugr ca 'AC' )
         ).
        call function '/SAPCND/CNF_ANALYSIS_REC'
             exporting
                  ir_analysis       = ir_analysis
                  is_message        = is_message
                  iv_condition_id   = ls_cond_tab-varnumh
                  iv_object_id      = ls_cond_tab-object_id
                  iv_reject         =
                    /sapcnd/cl_det_analysis_ow=>reject_relstat
                  iv_tabix          = 0
                  iv_release_status = ls_cond_tab-release_status.
      endif.
    endif.

  endloop.

  ct_cond_tab[] = lt_cond_allowed[].

endfunction.
