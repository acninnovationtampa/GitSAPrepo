*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:01
*
*======================================================================
* Sales organization
 call method cl_crm_product_md=>badi_orgman->read_text_single
   exporting
     orgunit      = is_bdi-sales_org
   importing
     display_text = ls_bdi_dsp-sales_org_descr
   exceptions
     not_found    = 0
     others       = 0.

* Distribution channel
 call function 'CRM_ORGMAN_DISTCHAN_T_SEL_CB'
   exporting
     iv_distchan           = is_bdi-dis_channel
   importing
     ev_description        = ls_bdi_dsp-dis_chan_descr
   exceptions
     description_not_found = 0
     distchan_not_found    = 0
     others                = 0.

* Header Division
 call function 'CRM_ORGMAN_DIVISION_T_SEL_CB'
   exporting
     iv_division           = is_bdi-division_h
   importing
     ev_description        = ls_bdi_dsp-division_h_descr
   exceptions
     description_not_found = 0
     division_not_found    = 0
     others                = 0.

* Division
 call function 'CRM_ORGMAN_DIVISION_T_SEL_CB'
   exporting
     iv_division           = is_bdi-division
   importing
     ev_description        = ls_bdi_dsp-division_descr
   exceptions
     description_not_found = 0
     division_not_found    = 0
     others                = 0.
