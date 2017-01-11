*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  create_excluding_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_EXTAB  text
*----------------------------------------------------------------------*
form adapt_excluding_tab changing rt_extab type kkblo_t_extab.
  data: lflg_input(1) type c.
  data: l_fcode type sy-ucomm.
  data: lt_extab type kkblo_t_extab with header line.
  data: ls_fccls(1) type c.
  data: lflg_changed(1) type c.

  data: begin of lt_fields occurs 0,
          fieldname type kkblo_fieldname,
        end of lt_fields.

  data: ls_layout   type lvc_s_layo,
        ls_fieldcat type lvc_s_fcat,
        lt_fieldcat type lvc_t_fcat,
        lt_sort     type lvc_t_sort,
        lt_filter   type lvc_t_filt,
        l_save      type char1.

  data: l_count_field type char1.

  field-symbols: <fs>.

*... fill data
  lt_extab[] = rt_extab[].

*...IDA Service: ALV functions are located in the Grid toolbar instead of Status menu
  if ( cl_alv_z_params=>get_parameter( cl_alv_z_params=>c_param-alv_gui_instance_builder ) is not initial )
  and ( cl_alv_gui_ist_builder_factory=>get_alv_gui_instance_builder( )->is_ida_active( ) eq abap_true ).
    lt_extab-fcode = '&FG_VIEW'.             append lt_extab.
    lt_extab-fcode = '&GRAPH'.               append lt_extab.
    lt_extab-fcode = '&FG_SUM'.              append lt_extab.
    lt_extab-fcode = '&ETA'.                 append lt_extab.
    lt_extab-fcode = '&XINT'.                append lt_extab.
    lt_extab-fcode = '%SC'.                  append lt_extab.
    lt_extab-fcode = '%SC+'.                 append lt_extab.
    lt_extab-fcode = '&FG_MARK'.             append lt_extab.
    lt_extab-fcode = '&XXL'.                 append lt_extab.
    lt_extab-fcode = '&FG_SORT'.             append lt_extab.
    lt_extab-fcode = '&CFI'.                 append lt_extab.
    lt_extab-fcode = '&OPT'.                 append lt_extab.
    lt_extab-fcode = '&FG_SUM'.              append lt_extab.
    lt_extab-fcode = '&CRTEMPL'.             append lt_extab.
    lt_extab-fcode = '&CRDESIG'.             append lt_extab.
    lt_extab-fcode = '&RNT_PREV'.            append lt_extab.
    lt_extab-fcode = '&RNT'.                 append lt_extab.
    lt_extab-fcode = '&ALL'.                 append lt_extab.
    lt_extab-fcode = '&SAL'.                 append lt_extab.
    lt_extab-fcode = '&FG_FILTER'.           append lt_extab.
    lt_extab-fcode = '&FG_VARIANT'.          append lt_extab.
    lt_extab-fcode = '&FG_EXPORT'.           append lt_extab.
    lt_extab-fcode = '&INFO'.                append lt_extab.
    delete ADJACENT DUPLICATES FROM lt_extab COMPARING fcode.
  endif.

*... retrieve necessary data from Grid
  call method gt_grid-grid->get_backend_fieldcatalog
    importing
      et_fieldcatalog = lt_fieldcat.

  call method gt_grid-grid->get_frontend_layout
    importing
      es_layout = ls_layout.

  call method gt_grid-grid->get_filter_criteria
    importing
      et_filter = lt_filter.

  call method gt_grid-grid->get_variant
    importing
      e_save = l_save.

*... Editable
  read table lt_fieldcat transporting no fields
             with key edit = 'X'.
  if sy-subrc eq 0 or ls_layout-edit = 'X'.
    lflg_input = 'X'.
  endif.

*... Offline
  if gt_grid-grid->offline( ) eq '1'.
    lt_extab-fcode = '&GRAPH'.
    append lt_extab.
    lt_extab-fcode = '&FG_SUM'.
    append lt_extab.
  endif.

*... WEBGUI
  if cl_gui_object=>www_active eq 'X'.
*    lt_extab-fcode = '%SC'.
*    append lt_extab.
*    lt_extab-fcode = '&GRAPH'.             "Y7AK091306
*    append lt_extab.
*    lt_extab-fcode = '&INFO'.              "Y7AK091306
*    append lt_extab.
*>>> B20K8A0PL4
*    lt_extab-fcode = '&FG_VIEW'.
*    append lt_extab.
*<<< B20K8A0PL4
*>>> B20K8A0PL4
    lt_extab-fcode = '&VGRID'.
    append lt_extab.
    lt_extab-fcode = '&VEXCEL'.
    append lt_extab.
    lt_extab-fcode = '&VCRYSTAL'.
    append lt_extab.
    lt_extab-fcode = '&VLOTUS'.
    append lt_extab.
*<<< B20K8A0PL4
    lt_extab-fcode = '&CRBATCH'.
    append lt_extab.
*Menu extended with XML Downloads -> available in WEB GUI
*    lt_extab-fcode = '&XXL'.
*    append lt_extab.
    lt_extab-fcode = '&AQW'.
    append lt_extab.
*    lt_extab-fcode = '%ML'.
*    append lt_extab.
*    lt_extab-fcode = '&ABC'.
*    append lt_extab.
    lt_extab-fcode = '&XINT'.
    append lt_extab.
    lt_extab-fcode = '&CRDESIG'.
    append lt_extab.
    lt_extab-fcode = '&CRTEMPL'.
    append lt_extab.
    lt_extab-fcode = '&URL'.
    append lt_extab.
*    if lflg_input eq 'X'.
*      lt_extab-fcode = '&FG_SUM'.
*      append lt_extab.
*      lt_extab-fcode = '&FG_SUBTOT'.
*      append lt_extab.
*    endif.
  endif.

*... JavaGUI
  data: is_java type sap_bool.
  call function 'GUI_HAS_JAVABEANS'
    importing
      return = is_java.

  if is_java ne space.
*>>> B20K8A0PL4
*    lt_extab-fcode = '&FG_VIEW'.
*    append lt_extab.
*<<< B20K8A0PL4
*>>> B20K8A0PL4
    lt_extab-fcode = '&VGRID'.
    append lt_extab.
    lt_extab-fcode = '&VEXCEL'.
    append lt_extab.
    lt_extab-fcode = '&VCRYSTAL'.
    append lt_extab.
    lt_extab-fcode = '&VLOTUS'.
    append lt_extab.
*<<< B20K8A0PL4
*Menu extended with XML Downloads -> available in Java GUI
*    lt_extab-fcode = '&XXL'.
*    append lt_extab.
    lt_extab-fcode = '&AQW'.
    append lt_extab.
    lt_extab-fcode = '%ML'.
    append lt_extab.
    lt_extab-fcode = '&CRBATCH'.
    append lt_extab.
    lt_extab-fcode = '&CRDESIG'.
    append lt_extab.
    lt_extab-fcode = '&CRTEMPL'.
    append lt_extab.
  endif.

*... View Functions
*...... View Grid is not allowed to be eliminated
  read table lt_extab transporting no fields
                      with key fcode = '&VGRID'.
  if sy-subrc eq 0.
    delete lt_extab index sy-tabix.
  endif.
*...... if no View functionality is requested -> eliminate
  read table lt_extab transporting no fields
                      with key fcode = '&FG_VIEW'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&VGRID'.
    append lt_extab.
    lt_extab-fcode = '&VEXCEL'.
    append lt_extab.
    lt_extab-fcode = '&VCRYSTAL'.
    append lt_extab.
    lt_extab-fcode = '&VLOTUS'.
    append lt_extab.
    lt_extab-fcode = '&RNT_PREV'.
    append lt_extab.
  endif.
*...... depending on View eliminate certain functions
  data: l_view type ui_func.
  call method gt_grid-grid->get_actual_view
    importing
      e_view = l_view.
  if l_view eq cl_gui_alv_grid=>mc_fc_view_excel.
    lt_extab-fcode = '&VEXCEL'.
    append lt_extab.
    lt_extab-fcode = '&ETA'.
    append lt_extab.
    lt_extab-fcode = '&XINT'.
    append lt_extab.
    lt_extab-fcode = '%SC'.
    append lt_extab.
    lt_extab-fcode = '%SC+'.
    append lt_extab.
    lt_extab-fcode = '&FG_MARK'.
    append lt_extab.
    lt_extab-fcode = '&XXL'.
    append lt_extab.
  elseif l_view eq cl_gui_alv_grid=>mc_fc_view_grid.
    lt_extab-fcode = '&VGRID'.
    append lt_extab.
  elseif l_view eq cl_gui_alv_grid=>mc_fc_view_crystal.
    lt_extab-fcode = '&VCRYSTAL'.
    append lt_extab.
    lt_extab-fcode = '&ETA'.
    append lt_extab.
    lt_extab-fcode = '&XINT'.
    append lt_extab.
    lt_extab-fcode = '%SC'.
    append lt_extab.
    lt_extab-fcode = '%SC+'.
    append lt_extab.
    lt_extab-fcode = '&FG_SORT'.
    append lt_extab.
    lt_extab-fcode = '&FG_MARK'.
    append lt_extab.
    lt_extab-fcode = '&CFI'.
    append lt_extab.
    lt_extab-fcode = '&OPT'.
    append lt_extab.
    lt_extab-fcode = '&FG_SUM'.
    append lt_extab.
    lt_extab-fcode = '&CRTEMPL'.
    append lt_extab.
    lt_extab-fcode = '&CRDESIG'.
    append lt_extab.
    lt_extab-fcode = '&RNT'.
    append lt_extab.
    lt_extab-fcode = '&RNT_PREV'.
    append lt_extab.
    lt_extab-fcode = '&CRBATCH'.
    append lt_extab.
    lt_extab-fcode = '&GRAPH'.
    append lt_extab.
  elseif l_view eq cl_gui_alv_grid=>mc_fc_view_lotus.
    lt_extab-fcode = '&VLOTUS'.
    append lt_extab.
    lt_extab-fcode = '&ETA'.
    append lt_extab.
    lt_extab-fcode = '&XINT'.
    append lt_extab.
    lt_extab-fcode = '%SC'.
    append lt_extab.
    lt_extab-fcode = '%SC+'.
    append lt_extab.
    lt_extab-fcode = '&FG_MARK'.
    append lt_extab.
  endif.

*... check products activbe
  data: boolean type sap_bool.
  boolean = cl_alv_check_third_party=>is_supported(
                 cl_alv_bds=>mc_excel_frontend ).
  if boolean eq abap_false.
    lt_extab-fcode = '&VEXCEL'.
    append lt_extab.
  endif.
  boolean = cl_alv_check_third_party=>is_supported(
                 cl_alv_bds=>mc_crystal_frontend ).
  if boolean eq abap_false.
    lt_extab-fcode = '&VCRYSTAL'.
    append lt_extab.
  endif.
  boolean = cl_alv_check_third_party=>is_supported(
                 cl_alv_bds=>mc_lotus_frontend ).
  if boolean eq abap_false.
    lt_extab-fcode = '&VLOTUS'.
    append lt_extab.
  endif.
* onyl active not installed at this place -> 2 roundtrips

*... Variant
  if l_save is initial
     or gt_grid-s_variant is initial.
    lt_extab-fcode = '&AVE'.
    append lt_extab.
    lt_extab-fcode = '&ERW'.
    append lt_extab.
  endif.
  if gt_grid-s_variant is initial.
    lt_extab-fcode = '&OAD'.
    append lt_extab.
    lt_extab-fcode = '&ERW'.
    append lt_extab.
  endif.
*...... if no Variant Functionality is requested -> eliminate
  read table lt_extab transporting no fields
             with key fcode = '&FG_VARIANT'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&OAD'.
    append lt_extab.
    lt_extab-fcode = '&AVE'.
    append lt_extab.
    lt_extab-fcode = '&OL0'.
    append lt_extab.
    lt_extab-fcode = '&OLX'.
    append lt_extab.
    lt_extab-fcode = '&ERW'.
    append lt_extab.
  endif.

  lt_extab-fcode = '%ML'.
  append lt_extab.
  lt_extab-fcode = '&LIS'.
  append lt_extab.
  lt_extab-fcode = '&LFO'.
  append lt_extab.
  lt_extab-fcode = '&NFO'.
  append lt_extab.
  lt_extab-fcode = '&CRB'.
  append lt_extab.
  lt_extab-fcode = '&CRE'.
  append lt_extab.
  lt_extab-fcode = '&CRR'.
  append lt_extab.
  lt_extab-fcode = '&CRL'.
  append lt_extab.

  lt_extab-fcode = '&OL1'.
  append lt_extab.
  lt_extab-fcode = '&OL2'.
  append lt_extab.
  lt_extab-fcode = '&OL3'.
  append lt_extab.
  lt_extab-fcode = '&OL4'.
  append lt_extab.
  lt_extab-fcode = '&OL5'.
  append lt_extab.

*... Export Functions
  if cl_alv_check_third_party=>is_supported( if_alv_z=>c_frontend-word ) = abap_false.
    lt_extab-fcode = '&AQW'.
    append lt_extab.
  endif.
  read table lt_extab transporting no fields
                      with key fcode = '&FG_EXPORT'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&XXL'.
    append lt_extab.
    lt_extab-fcode = '&AQW'.
    append lt_extab.
    lt_extab-fcode = '%PC'.
    append lt_extab.
    lt_extab-fcode = '%SL'.
    append lt_extab.
    lt_extab-fcode = '%ML'.
    append lt_extab.
    lt_extab-fcode = '&ABC'.
    append lt_extab.
    lt_extab-fcode = '&XINT'.
    append lt_extab.
    lt_extab-fcode = '&CRDESIG'.
    append lt_extab.
    lt_extab-fcode = '&CRTEMPL'.
    append lt_extab.
    lt_extab-fcode = '&URL'.
    append lt_extab.
    lt_extab-fcode = '&XML'.
    append lt_extab.
  endif.
  data: l_class  type seoclsname,
        l_method type seoclsname,
        l_active type boolean.
  l_class  = 'CL_ALV_XSLT_TRANSFORM'.
  l_method = 'IS_XML_ACTIVE'.
  call method (l_class)=>(l_method)
    receiving
      r_active = l_active.
  if l_active ne 'X'.
    lt_extab-fcode = '&XML'.
    append lt_extab.
  endif.

*... Sum Functions
*...... if Count Field not requested -> eliminate
  if ls_layout-countfname is initial.
    lt_extab-fcode = '&COUNT'.
    append lt_extab.
  else.
    l_count_field = 'X'.
  endif.
*...... if no field allows a sum then eliminate sum function
  read table lt_fieldcat transporting no fields
             with key no_sum = space
                      tech   = space.
  if sy-subrc ne 0.
    lt_extab-fcode = '&FG_SUM'.
    append lt_extab.
  endif.
*...... if one field allows a sum and is not displayable then
*       sum function must be deactivated
*...... if one field allows a sum and is displayable then
*       sum function must be available
  read table lt_fieldcat transporting no fields
             with key no_sum = space
                      no_out = space
                      tech   = space.
  if sy-subrc ne 0.
    lt_extab-fcode = '&FG_SUM'.
    append lt_extab.
  endif.
*...... if no Sum Functionality is requested -> eliminate
  if gt_grid-s_layout-no_sumchoice eq abap_true or
    ( gt_grid-s_layout-no_totalline = abap_true and
      gt_grid-s_layout-no_subtotals = abap_true ).
    lt_extab-fcode = '&FG_SUM'.
    append lt_extab.
  endif.
  read table lt_extab transporting no fields with key fcode = '&FG_SUM'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&UMC'.
    append lt_extab.
    lt_extab-fcode = '&AVR'.
    append lt_extab.
    lt_extab-fcode = '&MIN'.
    append lt_extab.
    lt_extab-fcode = '&MAX'.
    append lt_extab.
    if l_count_field eq space.
      lt_extab-fcode = '&COUNT'.
      append lt_extab.
    else.
      delete lt_extab where fcode eq '&FG_SUM'.
    endif.
  endif.

*... Subtotal Functions
*...... if no Sum Functions are available -> eliminate
  read table lt_extab transporting no fields
                      with key fcode = '&FG_SUM'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&FG_SUBTOT'.
    append lt_extab.
  endif.
  if gt_grid-s_layout-no_subchoice eq abap_true.
    lt_extab-fcode = '&FG_SUBTOT'.
    append lt_extab.
  else.
    call function 'LVC_KKB_SUBTOTALS_CHECK'
         exporting
              it_fieldcat_lvc         = lt_fieldcat[]
              is_layout_lvc           = ls_layout
*           I_LISTTYPE              =
*           I_INCL_INVISIBLE_FIELDS =
         exceptions
              no_subtotals_by_layout  = 1
              no_subchoice_by_layout  = 2
              no_do_sum_by_fieldcat   = 3
              others                  = 4.
    if sy-subrc <> 0.
      lt_extab-fcode = '&FG_SUBTOT'.
      append lt_extab.
    else.
*      call method gt_grid-grid->get_sort_criteria
*        importing
*          et_sort = lt_sort.
*      read table lt_sort with key subtot = 'X' transporting no fields.
*      if sy-subrc ne   0.
*        lt_extab-fcode = '&AUF'.
*        append lt_extab.
*      endif.
    endif.
  endif.
*...... if no Subtotal Functionality is requested -> eliminate
  read table lt_extab transporting no fields
                      with key fcode = '&FG_SUBTOT'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&SUM'.
    append lt_extab.
    lt_extab-fcode = '&AUF'.
    append lt_extab.
  endif.

*... Sort Functions
*...... if no Sort Functionality is requested -> eliminate
  read table lt_extab transporting no fields
                      with key fcode = '&FG_SORT'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&OUP'.
    append lt_extab.
    lt_extab-fcode = '&ODN'.
    append lt_extab.
  endif.

*... Filter Functions
*...... if no Filter Functionality is requested -> eliminate
  read table lt_extab transporting no fields
                      with key fcode = '&FG_FILTER'.
  if sy-subrc eq 0.
    lt_extab-fcode = '&ILT'.
    append lt_extab.
    lt_extab-fcode = '&ILD'.
    append lt_extab.
  endif.
  if lt_filter is initial.
    lt_extab-fcode = '&ILD'.
    append lt_extab.
  endif.

*>>new api
  if gt_grid-r_salv_fullscreen_adapter is bound.
    data: l_sel_mode type salv_de_constant.
    l_sel_mode = gt_grid-r_salv_fullscreen_adapter->get_selection_mode( ).
    if l_sel_mode eq if_salv_c_selection_mode=>none
    or l_sel_mode eq if_salv_c_selection_mode=>single.
      lt_extab-fcode = '&ALL'.
      append lt_extab.
      lt_extab-fcode = '&SAL'.
      append lt_extab.
    endif.
  else.
*... Mark Functions
    if gt_grid-s_layout-box_fieldname is initial.
      lt_extab-fcode = '&ALL'.
      append lt_extab.
      lt_extab-fcode = '&SAL'.
      append lt_extab.
    endif.
*...... if no Mark Functionality is requested -> eliminate
    read table lt_extab transporting no fields
                        with key fcode = '&FG_MARK'.
    if sy-subrc eq 0.
      lt_extab-fcode = '&ALL'.
      append lt_extab.
      lt_extab-fcode = '&SAL'.
      append lt_extab.
    endif.
  endif.
*<<new api

*... Fixation Functions on Columns
  read table lt_fieldcat transporting no fields
                         with key fix_column = 'X'
                                  no_out     = space
                                  tech       = space.
  if sy-subrc ne 0.
    lt_extab-fcode = '&CDF'.
    append lt_extab.
  endif.

*... Scroll Functions
  lt_extab-fcode = 'P--'.
  append lt_extab.
  lt_extab-fcode = 'P-'.
  append lt_extab.
  lt_extab-fcode = 'P++'.
  append lt_extab.
  lt_extab-fcode = 'P+'.
  append lt_extab.

*... Search More
  if gt_grid-grid is bound.
    data: lr_search type ref to if_alv_lvc_search.
    lr_search = gt_grid-grid->get_search_data( ).   "YI2K009535
    if lr_search is bound.
      if lr_search->modus eq if_alv_lvc_search=>c_modus_next.
        read table lt_extab with key fcode = '%SC+'
                            transporting no fields.
        if sy-subrc eq 0.
          delete lt_extab index sy-tabix.
        endif.
      else.
        lt_extab-fcode = '%SC+'.
        append lt_extab.
      endif.
    else.
      lt_extab-fcode = '%SC+'.
      append lt_extab.
    endif.
  else.
    lt_extab-fcode = '%SC+'.
    append lt_extab.
  endif.

**... Crystal Functions
*  boolean = cl_alv_check_third_party=>is_supported(
*                 cl_alv_bds=>mc_crystal_frontend ).
*  if boolean eq abap_false.
**  data: l_getid type char30.
**  get parameter id 'SLI' field l_getid.
**  translate l_getid to upper case.                       "#EC TRANSLANG
**  if ( l_getid ne 'CRYSTAL' ) and
**    ( not cl_gui_alv_grid=>m_third_party ca 'C' ).          "B5AK006349
*    lt_extab-fcode = '&CRTEMPL'.
*    append lt_extab.
*    lt_extab-fcode = '&CRDESIG'.
*    append lt_extab.
*    lt_extab-fcode = '&VCRYSTAL'. "CR
*    append lt_extab.
*    lt_extab-fcode = '&CRBATCH'. "CR
*    append lt_extab.
*  endif.

*... Disable XINT when no Extended Interaction Functions are activated
* >>B5AK000316
  data xint_number type int4.
  call function 'RSAQ_XINT_INITIALIZATION'
    importing
      function_number = xint_number.
  if ( xint_number eq 0 ).
    lt_extab-fcode = '&XINT'.
    append lt_extab.
  endif. "<<B5AK000316

*... if deep structure the exclude export functions
  data: lr_structdescr type ref to cl_abap_structdescr,
        lr_datadescr type ref to cl_abap_datadescr,
        lr_tabledescr type ref to cl_abap_tabledescr.

  lr_datadescr ?= cl_abap_tabledescr=>describe_by_data( t_outtab ).
  case lr_datadescr->type_kind.
    when cl_abap_datadescr=>typekind_table.
      lr_tabledescr ?= lr_datadescr.
      lr_structdescr ?= lr_tabledescr->get_table_line_type( ).
    when others.
      lr_structdescr ?= lr_datadescr.
  endcase.

  if lr_structdescr->struct_kind eq cl_abap_structdescr=>structkind_nested.
    gt_grid-flg_complex = 'X'.
  endif.

  if gt_grid-flg_complex = 'X'.
    lt_extab-fcode = '&ABC'.
    append lt_extab.
    lt_extab-fcode = '&XXL'.
    append lt_extab.
    lt_extab-fcode = '&AQW'.
    append lt_extab.
    lt_extab-fcode = '&AQI'.
    append lt_extab.
  endif.

  loop at lt_fieldcat into ls_fieldcat.
    check ls_fieldcat-tech is initial and
          ls_fieldcat-no_out ne 'X'.
*     ABC-Analyse möglich bei mindestens einem numerischen Feld
    if lflg_changed is initial and
       ls_fieldcat-inttype ca 'IPF' or
       ( ls_fieldcat-inttype = 'X' and
         ls_fieldcat-datatype(3) = 'INT' ).
      lflg_changed = 'X'.
    endif.
  endloop.
  if not ( ( lflg_input = 'X' or ls_layout-edit = 'X' ) and
     ls_layout-edit_mode is initial ).
    lt_extab-fcode = '&NTE'.
    append lt_extab.
    lt_extab-fcode = '&REFRESH'.
    append lt_extab.
    lt_extab-fcode = '&DATA_SAVE'.
    append lt_extab.
  else.
    lflg_input = 'X'.
  endif.
  if lflg_changed is initial and gt_grid-flg_complex is initial.
    lt_extab-fcode = '&ABC'.
    append lt_extab.
  endif.

*... Report/Report interface
  lt_extab-fcode = '&EB1'.
  append lt_extab.
  lt_extab-fcode = '&EB3'.
  append lt_extab.
  lt_extab-fcode = '&EB9'.
  append lt_extab.
  lt_extab-fcode = '&EBA'.
  append lt_extab.
  lt_extab-fcode = '&EBB'.
  append lt_extab.
  lt_extab-fcode = '&EBC'.
  append lt_extab.
  lt_extab-fcode = '&EBD'.
  append lt_extab.
  lt_extab-fcode = '&EBN'.
  append lt_extab.

  loop at gt_grid-t_fccls into ls_fccls.
    concatenate '&EB' ls_fccls into l_fcode.
    loop at lt_extab where fcode = l_fcode.
      delete lt_extab.
    endloop.
  endloop.
  if gt_grid-flg_called = 'X'.
    loop at lt_extab where fcode = '&EBN'.
      delete lt_extab.
    endloop.
  endif.

*... Disable Download-Functions if S_GUI/61 fails.
*    note: Download is disabled since 4.6D
  data: ls_excluding type kkblo_extab.
  data: download_allowed type flag value 'X'.
  authority-check object 'S_GUI' id 'ACTVT' field '61'.        "download
  if sy-subrc <> 0.
    download_allowed = ' '.
  endif.

*SAPLGRAP:
  if cl_alv_variant=>m_apply_saplgrap eq abap_true
  and download_allowed is not initial.
    data: check_result type i.
    perform check_grap_security
                                in program SAPLGRAP
                                using 'X' check_result
                                if found.
    if check_result > 0.
      download_allowed = ' '.
    endif.
  endif.

  if download_allowed is initial.
    define macro_disable_function.
      ls_excluding-fcode = &1.
      read table lt_extab transporting no fields
           with table key fcode = ls_excluding-fcode.
      if ( sy-subrc ne 0 ).
        append ls_excluding to lt_extab.
      endif.
    end-of-definition.
    macro_disable_function cl_gui_alv_grid=>mc_fc_pc_file.
    macro_disable_function cl_gui_alv_grid=>mc_fc_call_xxl.
    macro_disable_function '%PC'.          "PC
    macro_disable_function '%SL'.          "SL
    macro_disable_function cl_gui_alv_grid=>mc_fc_word_processor.
    macro_disable_function cl_gui_alv_grid=>mc_fc_expcrdesig.
    macro_disable_function cl_gui_alv_grid=>mc_fc_expcrtempl.
    macro_disable_function cl_gui_alv_grid=>mc_fc_expcrdata.
    macro_disable_function cl_gui_alv_grid=>mc_fc_html.
    macro_disable_function cl_gui_alv_grid=>mc_fc_view_grid.
    macro_disable_function cl_gui_alv_grid=>mc_fc_view_excel.
    macro_disable_function cl_gui_alv_grid=>mc_fc_view_crystal.
    macro_disable_function cl_gui_alv_grid=>mc_fc_view_lotus.
    macro_disable_function cl_gui_alv_grid=>mc_fc_graph.
    macro_disable_function cl_gui_alv_grid=>mc_fc_call_crbatch.
    macro_disable_function cl_gui_alv_grid=>mc_fc_call_xml_export.   "Y7AK117946
  endif.

*... generally disabled functions
  lt_extab-fcode = '&CRTEMPL'.
  append lt_extab.
  lt_extab-fcode = '&CRDESIG'.
  append lt_extab.
  lt_extab-fcode = '&CRBATCH'.
  append lt_extab.

*... data back
  rt_extab[] = lt_extab[].

endform.                    " create_excluding_tab
