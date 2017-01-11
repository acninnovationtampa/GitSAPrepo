function /sapcnd/cnf_get_appl_usage.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_APPLICATION) TYPE  /SAPCND/APPLICATION
*"     REFERENCE(IV_USAGE) TYPE  /SAPCND/USAGE
*"     REFERENCE(IS_ACCESS_CONTROL) TYPE  /SAPCND/DET_ACCESS_CONTROL
*"  EXPORTING
*"     REFERENCE(ES_ACCESS_CONTROL) TYPE  /SAPCND/DET_ACCESS_CONTROL
*"  EXCEPTIONS
*"      FATAL_ERROR
*"      EXC_NO_T681A
*"      EXC_NO_T681V
*"----------------------------------------------------------------------

  data ls_access_control type /sapcnd/det_access_control.
* TODO - replace selects by read-function modules

  ls_access_control = is_access_control.
* read application
  if gs_t681a-kappl ne iv_application.
    select single * from /sapcnd/t681a into gs_t681a
      where  kappl = iv_application.
    if sy-subrc ne 0.
      raise exc_no_t681a.
    endif.
    clear gr_head_comm.
    clear gr_item_comm.
    try.
        create data gr_head_comm type (gs_t681a-str_head_acs).
        create data gr_item_comm type (gs_t681a-str_item_com).
      catch cx_sy_create_data_error.
        raise fatal_error.
    endtry.
    assign gr_head_comm->* to <head>.
    assign gr_item_comm->* to <item>.
  endif.

* read usage
  if gs_t681v-kvewe ne iv_usage.
    select single * from /sapcnd/t681v into gs_t681v
      where  kvewe = iv_usage.
    if sy-subrc ne 0.
      raise exc_no_t681v.
    endif.
  endif.

  if not ls_access_control-buffer_usag_data is initial.
    clear gr_usdata.
    if not gs_t681v-str_tmpl_tabl is initial.
      try.
          create data gr_usdata type (gs_t681v-str_tmpl_tabl).
        catch cx_sy_create_data_error.
          clear ls_access_control-buffer_usag_data.
          clear gr_usdata.
      endtry.
      if gr_usdata is bound.
        assign gr_usdata->* to <data>.
      endif.
    else.
      clear ls_access_control-buffer_usag_data.
    endif.
  endif.

  if es_access_control is requested.
    es_access_control = ls_access_control.
  endif.

endfunction.
