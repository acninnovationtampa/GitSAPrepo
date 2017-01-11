*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RT_OUTTAB  text
*----------------------------------------------------------------------*
form data_download tables rt_outtab type standard table.

  data: table type ref to data.

  get reference of rt_outtab[] into table.

  data: lt_fcat_lvc type lvc_t_fcat,
        lt_sort_lvc type lvc_t_sort,
        ls_lyout_lvc type lvc_s_layo,
        lt_filter_lvc type lvc_t_filt.

  call method gt_grid-grid->get_frontend_fieldcatalog
    importing et_fieldcatalog = lt_fcat_lvc.

  call method gt_grid-grid->get_frontend_layout
    importing es_layout = ls_lyout_lvc.

  call method gt_grid-grid->get_sort_criteria
    importing et_sort = lt_sort_lvc.

  call method gt_grid-grid->get_filter_criteria
    importing et_filter = lt_filter_lvc.

  call function 'SALV_WD_FULL_METADATA'
    exporting
      is_layout                      = ls_lyout_lvc
      it_fieldcatalog                = lt_fcat_lvc
      it_sort                        = lt_sort_lvc
      it_filter                      = lt_filter_lvc
      ir_table                       = table.
*  if sy-subrc eq 1.
*    message x000(0k) with 'INTERFACE_CHECK'.
*  endif.

endform.                    " data_download

form data_download_to_java_browser tables rt_outtab type standard table.

  perform data_download tables rt_outtab.

  call function 'CALL_BROWSER'
    exporting
      url = 'http://us4181.wdf.sap.corp:54500/webdynpro/dispatcher/sap.com/bi~alv~sample/Upload'.

endform.                    " data_download

form data_download_to_abap_browser tables rt_outtab type standard table.

  perform data_download tables rt_outtab.

  data: urlstr type string,
        url(128) type c.

*  urlstr = CL_SALV_SUBMIT_REPORT=>create_url( 'SALV_WD_DEMO_FILE_UPLOAD' ). Y1AK092671
   call method ('CL_SALV_SUBMIT_REPORT')=>('CREATE_URL') EXPORTING name = 'SALV_WD_DEMO_FILE_UPLOAD'
                                                         RECEIVING url  = urlstr.

    move urlstr to url.

  call function 'CALL_BROWSER'
    exporting
      url = url.

endform.

form wd_download tables rt_outtab type standard table.

  data: table type ref to data.

  get reference of rt_outtab[] into table.

  data: lt_fcat_lvc type lvc_t_fcat,
        lt_sort_lvc type lvc_t_sort,
        ls_lyout_lvc type lvc_s_layo,
        lt_filter_lvc type lvc_t_filt.

  call method gt_grid-grid->get_frontend_fieldcatalog
    importing et_fieldcatalog = lt_fcat_lvc.

  call method gt_grid-grid->get_frontend_layout
    importing es_layout = ls_lyout_lvc.

  call method gt_grid-grid->get_sort_criteria
    importing et_sort = lt_sort_lvc.

  call method gt_grid-grid->get_filter_criteria
    importing et_filter = lt_filter_lvc.

  data: r_model type ref to cl_salv_table,
        r_tol type ref to cl_salv_form_element,
        r_eol type ref to cl_salv_form_element.

  if gt_grid-r_salv_fullscreen_adapter is bound.
      r_model ?= gt_grid-r_salv_fullscreen_adapter->r_controller->r_model.

      r_tol = r_model->get_top_of_list( ).

      r_eol = r_model->get_end_of_list( ).
  endif.

  call function 'SALV_WD_DOWNLOAD'
    exporting
      is_layout                      = ls_lyout_lvc
      it_fieldcatalog                = lt_fcat_lvc
      it_sort                        = lt_sort_lvc
      it_filter                      = lt_filter_lvc
      ir_eol                         = r_eol
      ir_tol                         = r_tol
    changing  ir_table               = table.

endform.
