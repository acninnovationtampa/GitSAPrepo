FUNCTION /1BEA/CRMB_BD_PPF_O_PREPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BTY) TYPE  BEAS_BTY_WRK
*"     REFERENCE(IV_VIEWMODE) TYPE  PPFDMODE DEFAULT 'D'
*"     REFERENCE(IT_EXCL_FCODES) TYPE  UI_FUNCTIONS OPTIONAL
*"     REFERENCE(IV_HEADER) TYPE  BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_SHOW_INACTIVE) TYPE  BOOLEAN DEFAULT SPACE
*"     REFERENCE(IV_CONTEXT_ONLY) TYPE  BOOLEAN DEFAULT SPACE
*"  EXPORTING
*"     REFERENCE(EO_CONTEXT) TYPE REF TO CL_BEA_CONTEXT_PPF
*"     REFERENCE(ET_CONTEXT) TYPE  PPFTCNTXTS
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"--------------------------------------------------------------------
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:02
*
*======================================================================

  DATA: lo_context      TYPE REF TO cl_bea_context_ppf,
        ls_context      TYPE ppfdctxtir,
        lt_context      TYPE ppftcntxts,
        lv_applkey      TYPE ppfdappkey,
        lv_prot_hndl    TYPE balloghndl,
        lo_appl_object  TYPE REF TO cl_bea_ppf,
        lo_manager      TYPE REF TO cl_manager_ppf,
        lt_ppf_procs    TYPE BEAT_PPF_PROCS,
        ls_ppf_procs    TYPE BEAS_PPF_PROCS,
        lo_partner      TYPE REF TO cl_bea_partner_ppf,
        lo_partner_coll TYPE REF TO cl_partner_coll_ppf,
        lt_partner      TYPE beat_par_wrk,
        ls_partner      TYPE beas_par_wrk,
        lt_excl_fcodes  TYPE ui_functions.

  FIELD-SYMBOLS <lf_context> TYPE ppfdctxtir.
  CONSTANTS:
        lc_fcode_execute TYPE ui_func VALUE 'EXECUTE',
        lc_fcode_delete  TYPE ui_func VALUE 'DELETE'.

  DATA: LV_OP           TYPE BOOLE_D.

* DEFINITION PART ----------------------------------------------------

  class ca_bea_ppf definition load.

* IMPLEMENTATION PART ------------------------------------------------

* it only make sense to run this function when ppf_proc or ap_det_proc is not initial
  CHECK is_bty-ppf_proc    IS NOT INITIAL OR
        is_bty-ap_det_proc IS NOT INITIAL.

* get application key
  call function 'BEA_PPF_O_GET_APPLKEY'
    exporting
      iv_application = is_bty-application
      iv_headno_ext  = is_bdh-headno_ext
    importing
      ev_applkey     = lv_applkey.

* -> check if the omnipresent object pool was used and if so use it as well
     LV_OP = CL_OBJECT_POOL=>INSTANCE_EXISTS( ).
     IF NOT LV_OP IS INITIAL.
       CL_OBJECT_POOL=>SET_GUID( IS_BDH-BDH_GUID ).
     ENDIF.

* set key fields of application
  try.
      lo_appl_object =
        ca_bea_ppf=>agent->get_persistent( is_bdh-bdh_guid ).
    CATCH cx_os_object_not_found.
      lo_appl_object =
        ca_bea_ppf=>agent->create_persistent( is_bdh-bdh_guid ).
      lo_appl_object->set_bea_name( is_bty-application ).
  endtry.

* create context
  IF is_bty-ppf_proc IS NOT INITIAL.
    create object lo_context.
*  set context attributes
    lo_context->applctn = gc_ppfappl.
    lo_context->name    = is_bty-ppf_proc.
    lo_context->appl    = lo_appl_object.
* insert context into table of contexts
    ls_context = lo_context.
    APPEND ls_context TO lt_context.
  ENDIF.

 IF is_bty-ap_det_proc IS NOT INITIAL.
* start determination of action profiles
  CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_PROCS_DET'
   EXPORTING
     IS_BDH       = IS_BDH
     IS_BTY       = IS_BTY
   IMPORTING
     ET_PPF_PROCS = LT_PPF_PROCS
     ET_RETURN    = ET_RETURN.
  IF lt_ppf_procs IS NOT INITIAL.
    LOOP AT LT_PPF_PROCS INTO LS_PPF_PROCS.
* create context
      CREATE OBJECT LO_CONTEXT.
* set context attributes
      lo_context->applctn = gc_ppfappl.
      lo_context->name    = ls_ppf_procs.
      lo_context->appl    = lo_appl_object.
* insert context into table of contexts
      ls_context = lo_context.
      APPEND ls_context TO lt_context.
    ENDLOOP.
  ENDIF.
 ENDIF.

  CHECK lt_context IS NOT INITIAL.

*   create partner collection
    CREATE OBJECT lo_partner_coll.

*   begin of partner processing
*   get partnerset
    CALL FUNCTION 'BEA_PAR_O_GET'
      EXPORTING
        iv_parset_guid = is_bdh-parset_guid
      IMPORTING
        et_par         = lt_partner
      EXCEPTIONS
        reject         = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
*     fill et_return
      MESSAGE ID     sy-msgid
              TYPE   sy-msgty
              NUMBER sy-msgno
              WITH   sy-msgv1 sy-msgv2
                     sy-msgv3 sy-msgv4
              INTO   gv_dummy.
      PERFORM msg_add USING space space space space CHANGING et_return.
    ENDIF.

*   loop:     read partner from partner set,
*             create partner object and
*             add to partner collection
    LOOP AT lt_partner INTO ls_partner.
*     create a partner object
      CREATE OBJECT lo_partner
        EXPORTING
          ip_partner_role  = ls_partner-partner_fct
          ip_partner_no    = ls_partner-partner_no
          ip_partner_text  = ''
          ip_zav_addressno = ls_partner-addr_nr
          ip_zav_persno    = ls_partner-addr_np
          ip_zav_addr_type = ls_partner-addr_type.
*     add partner object to partner collection
      CALL METHOD lo_partner_coll->add_element( lo_partner ).
    ENDLOOP.
* update partner collection to context
    LOOP AT lt_context ASSIGNING <lf_context>.
      <lf_context>->partner = lo_partner_coll.
    ENDLOOP.
*   end of partner processing

* get manager instance
  lo_manager = cl_manager_ppf=>get_instance( ).

* call function determine in maintenance mode
  IF iv_viewmode = 'M'.
    LOOP AT lt_context ASSIGNING <lf_context>.
*   start action determination in ppf
      CALL METHOD lo_manager->determine
        exporting
          io_context  = <lf_context>
        importing
          ep_protocol = lv_prot_hndl.
      CALL METHOD lo_manager->set_applkey
        EXPORTING
          ip_applkey = lv_applkey
          io_context = <lf_context>.
    ENDLOOP.
  ELSE.
    LOOP AT lt_context ASSIGNING <lf_context>.
      CALL METHOD lo_manager->set_applkey
        EXPORTING
          ip_applkey = lv_applkey
          io_context = <lf_context>.
    ENDLOOP.
  ENDIF.

* if only context is required (as in NewUI), exit here
* IF not iv_context_only IS INITIAL.
    eo_context = lo_context.
    et_context = lt_context.
*   RETURN.
* ENDIF.

* exclude fcodes
  lt_excl_fcodes = it_excl_fcodes.

*  COLLECT lc_fcode_execute INTO lt_excl_fcodes.
*  COLLECT lc_fcode_delete  INTO lt_excl_fcodes.

* -> finish object pool session
  CL_OBJECT_POOL=>SAVE_GUIDS( IP_GUID = is_bdh-bdh_guid ).

* call control to display the action list

  call function 'SPPF_VIEW_START_CRM'
    exporting
      it_context             = lt_context
      ip_applkey             = lv_applkey
      ip_viewmode            = iv_viewmode
      it_excl_fcodes         = lt_excl_fcodes
      ip_detlog              = lv_prot_hndl
      ip_header              = iv_header
      ip_show_inactive       = iv_show_inactive.

ENDFUNCTION.
