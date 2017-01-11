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
* Service organization
 call method cl_crm_product_md=>badi_orgman->read_text_single
   exporting
     orgunit      = is_bdi-service_org
   importing
     display_text = ls_bdi_dsp-service_org_desc
   exceptions
     not_found    = 0
     others       = 0.
