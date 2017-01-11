function /sapcnd/get_det_module_names.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_APPLICATION) TYPE  /SAPCND/APPLICATION
*"     REFERENCE(IV_USAGE) TYPE  /SAPCND/USAGE
*"     REFERENCE(IV_ACCESS_SEQUENCE) TYPE  /SAPCND/ACCESS_SEQUENCE
*"       OPTIONAL
*"     REFERENCE(IV_ACCESS_ID) TYPE  /SAPCND/ACCESS_ID OPTIONAL
*"     REFERENCE(IV_FUGR_APPL) TYPE  /SAPCND/DET_MODULE_NAMESPACE
*"       OPTIONAL
*"     REFERENCE(IV_FUGR_USAGE) TYPE  /SAPCND/DET_MODULE_NAMESPACE
*"       OPTIONAL
*"     REFERENCE(IV_FUGR_APPL_USAGE) TYPE  /SAPCND/DET_MODULE_NAMESPACE
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_FUGR_APPL) TYPE  RS38L_AREA
*"     REFERENCE(EV_FUGR_USAGE) TYPE  RS38L_AREA
*"     REFERENCE(EV_FUGR_APPL_USAGE) TYPE  RS38L_AREA
*"     REFERENCE(EV_FB_PRESTEP_READ) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_PRESTEP_INSERT) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_REFRESH) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_ACCESS) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_REQ_CHECK) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_US_GET_REC) TYPE  FUNCNAME
*"     REFERENCE(EV_FB_US_PUT_REC) TYPE  FUNCNAME
*"     REFERENCE(EV_INCL_TARGET) TYPE  PROGRAMM
*"     REFERENCE(EV_INCL_GEN_ACS) TYPE  PROGRAMM
*"     REFERENCE(EV_FORM_GEN_ACS) TYPE  PROGRAMM
*"  EXCEPTIONS
*"      EXC_INITIAL_KAPPL
*"      EXC_INITIAL_KVEWE
*"      EXC_INITIAL_ACCESS
*"      EXC_KAPPL_MISSING
*"      EXC_KVEWE_MISSING
*"      EXC_KAPPLKVEWE_MISSING
*"      EXC_GLOBAL_PARAM_MISSING
*"----------------------------------------------------------------------

  data:     lv_prefix_det             type /sapcnd/param_value,
            lv_gen_namespace_default  type /sapcnd/param_value,
            lv_prefix_a               type /sapcnd/det_module_namespace,
            lv_prefix_v               type /sapcnd/det_module_namespace,
            lv_prefix_z               type /sapcnd/det_module_namespace,
            lv_offset                 type i.

  constants: lc_global_prefix_det       type /sapcnd/param_name
                                        value 'GLOBAL_PREFIX_DET',
             lc_gen_namespace_default   type /sapcnd/param_name
                                        value 'GEN_NAMESPACE_DEFAULT'.

* assert the input values are valid
  if iv_application is initial.
    raise exc_initial_kappl.
  endif.

  if iv_usage is initial.
    raise exc_initial_kvewe.
  endif.

* read some consts from the general settings
  call function '/SAPCND/GET_GLOBAL_PARAMETER'
    exporting
      i_param_name        = lc_global_prefix_det
    importing
      e_param_value       = lv_prefix_det
    exceptions
      exc_param_not_found = 1
      others              = 2.
  if sy-subrc ne 0.
    raise exc_global_param_missing.
  endif.

  call function '/SAPCND/GET_GLOBAL_PARAMETER'
    exporting
      i_param_name        = lc_gen_namespace_default
    importing
      e_param_value       = lv_gen_namespace_default
    exceptions
      exc_param_not_found = 1
      others              = 2.
  if sy-subrc ne 0.
    raise exc_global_param_missing.
  endif.

* select namespace if necessary
  if iv_fugr_appl is initial.
    select single det_namespace from /sapcnd/t681a into lv_prefix_a
     where kappl = iv_application.
    if sy-subrc ne 0.
      raise exc_kappl_missing.
    endif.
  else.
    lv_prefix_a = iv_fugr_appl.
  endif.

  if iv_fugr_usage is initial.
    select single det_namespace from /sapcnd/t681v into lv_prefix_v
     where kvewe = iv_usage.
    if sy-subrc ne 0.
      raise exc_kvewe_missing.
    endif.
  else.
    lv_prefix_v = iv_fugr_usage.
  endif.

  if iv_fugr_appl_usage is initial.
    select single det_namespace from /sapcnd/t681z into lv_prefix_z
     where kappl = iv_application
       and kvewe = iv_usage.
    if sy-subrc ne 0.
      raise exc_kapplkvewe_missing.
    endif.
  else.
    lv_prefix_z = iv_fugr_appl_usage.
  endif.

* function groups
  ev_fugr_appl           = lv_prefix_a.
  ev_fugr_usage          = lv_prefix_v.
  ev_fugr_appl_usage     = lv_prefix_z.

* prestep function modules
  if ev_fb_prestep_read is requested.
    concatenate lv_prefix_a '_PRESTEP_READ'
           into ev_fb_prestep_read.
  endif.

  if ev_fb_prestep_insert is requested.
    concatenate lv_prefix_a '_PRESTEP_INSERT'
           into ev_fb_prestep_insert.
  endif.

  if ev_fb_refresh is requested.
    concatenate lv_prefix_a '_REFRESH'
           into ev_fb_refresh.
  endif.

* get/put records
  if ev_fb_us_get_rec is requested.
    concatenate lv_prefix_v '_RECORD_GET'
           into ev_fb_us_get_rec.
  endif.

  if ev_fb_us_put_rec is requested.
    concatenate lv_prefix_v '_RECORD_PUT'
           into ev_fb_us_put_rec.
  endif.

  if ev_fb_access is requested.
    concatenate lv_prefix_z '_ACCESS'
           into ev_fb_access.
  endif.

  if ev_fb_req_check is requested.
    concatenate lv_prefix_z '_REQ_CHECK'
           into ev_fb_req_check.
  endif.

* generated accesses
  if ev_incl_target is requested.
    concatenate 'L' lv_prefix_z 'F01' into ev_incl_target.
  endif.

  if ev_incl_gen_acs is requested.
    if iv_access_sequence is initial or iv_access_id is initial.
      raise exc_initial_access.
    endif.
    concatenate lv_gen_namespace_default lv_prefix_det 'F'
           into ev_incl_gen_acs.
    lv_offset = strlen( ev_incl_gen_acs ).
    ev_incl_gen_acs+lv_offset(3) = iv_application.
    lv_offset = lv_offset + 3.
    ev_incl_gen_acs+lv_offset(2) = iv_usage.
    lv_offset = lv_offset + 2.
    ev_incl_gen_acs+lv_offset(4) = iv_access_sequence.
    lv_offset = lv_offset + 4.
    ev_incl_gen_acs+lv_offset(3) = iv_access_id.
    lv_offset = lv_offset + 3.
    ev_incl_gen_acs+lv_offset(3) = 'ACS'.                   "#EC NOTEXT
    lv_offset = lv_offset + 3.
    translate ev_incl_gen_acs(lv_offset) using ' _'.
  endif.

  if ev_form_gen_acs is requested.
    if iv_access_sequence is initial or iv_access_id is initial.
      raise exc_initial_access.
    endif.
    ev_form_gen_acs(1) = 'F'.                               "#EC NOTEXT
    ev_form_gen_acs+1(4) = iv_access_sequence.
    ev_form_gen_acs+5(3) = iv_access_id.
    ev_form_gen_acs+8(3) = 'ACS'.                           "#EC NOTEXT
    translate ev_form_gen_acs(11) using ' _'.
  endif.

endfunction.
