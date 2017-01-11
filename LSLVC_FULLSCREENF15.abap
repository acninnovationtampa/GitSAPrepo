*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  memory_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form memory_download .

*Infoset(Designtime) Extraction
  data: table type ref to data.

  data: lt_fcat_lvc type lvc_t_fcat,
        lt_sort_lvc type lvc_t_sort,
        ls_lyout_lvc type lvc_s_layo,
        lt_filter_lvc type lvc_t_filt,
        lt_fcat_kkbl type KKBLO_T_FIELDCAT,
        lt_sort_kkbl type KKBLO_T_sortinfo,
        ls_lyout_kkbl type KKBLO_layout,
        lt_filter_kkbl type KKBLO_T_filter.

  call method gt_grid-grid->get_frontend_fieldcatalog
    importing et_fieldcatalog = lt_fcat_lvc.

  call method gt_grid-grid->get_frontend_layout
    importing es_layout = ls_lyout_lvc.

  call method gt_grid-grid->get_sort_criteria
    importing et_sort = lt_sort_lvc.

  call method gt_grid-grid->get_filter_criteria
    importing et_filter = lt_filter_lvc.

  if gt_grid-r_salv_fullscreen_adapter is bound.
      data: r_model type ref to cl_salv_table,
            r_tol type ref to cl_salv_form_element,
            r_eol type ref to cl_salv_form_element.

      r_model ?= gt_grid-r_salv_fullscreen_adapter->r_controller->r_model.

      r_tol = r_model->get_top_of_list( ).

      r_eol = r_model->get_end_of_list( ).

    endif.

  try.
      cl_salv_wd_adapt_shm_util=>write( data = t_outtab[]
                                      t_fcat = lt_fcat_lvc
                                      t_sort = lt_sort_lvc
                                      t_filter = lt_filter_lvc
                                      s_layout = ls_lyout_lvc
                                      r_tol    = r_tol
                                      r_eol    = r_eol ).
    catch cx_salv_wd_sc_shm_error.
  endtry.

endform.                    " memory_download

form download_to_memory.

  perform memory_download.

  data: urlstr type string,
        url(128) type c.

*  urlstr = CL_SALV_SUBMIT_REPORT=>create_url( 'SALV_WD_SUBMIT' ). Y1AK092671
   call method ('CL_SALV_SUBMIT_REPORT')=>('CREATE_URL') EXPORTING name = 'SALV_WD_SUBMIT'
                                                         RECEIVING url  = urlstr.

    move urlstr to url.

  call function 'CALL_BROWSER'
    exporting
      url = url.

endform.
