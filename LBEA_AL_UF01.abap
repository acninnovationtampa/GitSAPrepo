*&---------------------------------------------------------------------*
*&  Include           LBEA_AL_UF01                                     *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  profile_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_CRP_CR_NUMBER  text
*      <--P_LS_PROFILE  text
*----------------------------------------------------------------------*
form profile_build  using    uv_crp_number type bea_crp_number
                             uv_title      type baltitle
                             uv_mode       type bea_al_mode
                             uv_no_tree    type bea_boolean
                    changing cs_profile    type bal_s_prof.
***********************************************************************
* Local Data
***********************************************************************
  constants:
    lc_headsize  type balheadsiz value 55,
    lc_slishandl type slis_handl value 'LOG',
    lc_callback_form type c      value ' '.
  data: ls_fcat  type bal_s_fcat,
        lv_tabix type sytabix.
***********************************************************************
* Implementation
***********************************************************************
*----------------------------------------------------------------------
* Build Standard Profiles
*----------------------------------------------------------------------
  if uv_no_tree is initial.
*  CALL FUNCTION 'BAL_DSP_PROFILE_DETLEVEL_GET'
*       IMPORTING
*            e_s_display_profile = cs_profile.
    call function 'BAL_DSP_PROFILE_STANDARD_GET'
      importing
        e_s_display_profile = cs_profile.
*----------------------------------------------------------------------
* Suppress Output Columns
*----------------------------------------------------------------------
*......................................................................
* Prepare
*......................................................................
    ls_fcat-ref_table = 'BAL_S_SHOW'.
    ls_fcat-no_out    = gc_true.
*......................................................................
* Field ALTCODE
*......................................................................
    ls_fcat-ref_field = 'ALTCODE'.
    read table cs_profile-lev1_fcat
         with key ref_table = ls_fcat-ref_table
                  ref_field = ls_fcat-ref_field
         transporting no fields.
    lv_tabix = sy-tabix.
    modify cs_profile-lev1_fcat index lv_tabix from ls_fcat
           transporting no_out.
*......................................................................
* Field ALPROG
*......................................................................
    ls_fcat-ref_field = 'ALPROG'.
    read table cs_profile-lev1_fcat
         with key ref_table = ls_fcat-ref_table
                  ref_field = ls_fcat-ref_field
         transporting no fields.
    lv_tabix = sy-tabix.
    modify cs_profile-lev1_fcat index lv_tabix from ls_fcat
           transporting no_out.
*......................................................................
* Field T_ALMODE
*......................................................................
    ls_fcat-ref_field = 'T_ALMODE'.
    read table cs_profile-lev1_fcat
         with key ref_table = ls_fcat-ref_table
                  ref_field = ls_fcat-ref_field
         transporting no fields.
    lv_tabix = sy-tabix.
    modify cs_profile-lev1_fcat index lv_tabix from ls_fcat
           transporting no_out.
*......................................................................
* Field LOGNUMBER
*......................................................................
    ls_fcat-ref_field = 'LOGNUMBER'.
    read table cs_profile-lev1_fcat
         with key ref_table = ls_fcat-ref_table
                  ref_field = ls_fcat-ref_field
         transporting no fields.
    lv_tabix = sy-tabix.
    modify cs_profile-lev1_fcat index lv_tabix from ls_fcat
           transporting no_out.
*......................................................................
* Field EXTNUMBER
*......................................................................
    if not uv_crp_number is initial.
      ls_fcat-ref_field = 'EXTNUMBER'.
      read table cs_profile-lev1_fcat
           with key ref_table = ls_fcat-ref_table
                    ref_field = ls_fcat-ref_field
           transporting no fields.
      lv_tabix = sy-tabix.
      modify cs_profile-lev1_fcat index lv_tabix from ls_fcat
             transporting no_out.
    endif.
  else.
    call function 'BAL_DSP_PROFILE_NO_TREE_GET'
      importing
        e_s_display_profile = cs_profile.
  endif.
*----------------------------------------------------------------------
* add fields into message-line
*----------------------------------------------------------------------
  if uv_mode = gc_al_dsp_x.
    clear ls_fcat.
* Field ICON_ACTION
*   ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
*   ls_fcat-ref_field = 'ICON_ACTION'.
*   ls_fcat-is_extern = 'X'.
*   ls_fcat-col_pos   = 10.
*   APPEND ls_fcat TO cs_profile-mess_fcat.

* Field SRC_HEADNO
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'SRC_HEADNO'.
    ls_fcat-col_pos   = 11.
    ls_fcat-is_extern = gc_true.
    append ls_fcat to cs_profile-mess_fcat.

    clear ls_fcat.
* Field SRC_ITEMNO
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'SRC_ITEMNO'.
    ls_fcat-col_pos   = 12.
    append ls_fcat to cs_profile-mess_fcat.

* Field OBJ_STEXT
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'OBJ_STEXT'.
    ls_fcat-col_pos   = 13.
    append ls_fcat to cs_profile-mess_fcat.

* Field LOGSYS
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'LOGSYS'.
    ls_fcat-col_pos   = 14.
    append ls_fcat to cs_profile-mess_fcat.

* define callback routine to read external data
    cs_profile-clbk_read-userexitt = lc_callback_form.
    cs_profile-clbk_read-userexitp = sy-repid.
    cs_profile-clbk_read-userexitf = 'CALLBACK_READ'.

  elseif uv_mode = gc_al_dsp_e.
    clear ls_fcat.

* Field SRC_HEADNO
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'SRC_HEADNO'.
    ls_fcat-col_pos   = 11.
    ls_fcat-is_extern = gc_true.
    append ls_fcat to cs_profile-mess_fcat.

    clear ls_fcat.
* Field SRC_ITEMNO
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'SRC_ITEMNO'.
    ls_fcat-col_pos   = 12.
    append ls_fcat to cs_profile-mess_fcat.

* Field ADD_ID
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'ADD_ID'.
    ls_fcat-col_pos   = 13.
    ls_fcat-is_extern = gc_true.
    append ls_fcat to cs_profile-mess_fcat.

* Field OBJ_STEXT
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'OBJ_STEXT'.
    ls_fcat-col_pos   = 14.
    append ls_fcat to cs_profile-mess_fcat.

* Field LOGSYS
    ls_fcat-ref_table = 'BEAS_RTCONTEXT'.
    ls_fcat-ref_field = 'LOGSYS'.
    ls_fcat-col_pos   = 15.
    append ls_fcat to cs_profile-mess_fcat.

* define callback routine to read external data
    cs_profile-clbk_read-userexitt = lc_callback_form.
    cs_profile-clbk_read-userexitp = sy-repid.
    cs_profile-clbk_read-userexitf = 'CALLBACK_READ'.

  endif.
*----------------------------------------------------------------------
* Do Billing Engine Specific Changes:
*----------------------------------------------------------------------
  if uv_title is initial.
    if uv_crp_number is initial.
      message i755(bea) into cs_profile-title.
    else.
      message i756(bea) with uv_crp_number into cs_profile-title.
    endif.
  else.
    cs_profile-title = uv_title.
  endif.
  cs_profile-use_grid   = gc_true.
  cs_profile-head_size  = lc_headsize.
  cs_profile-tree_ontop = gc_true.
  cs_profile-tree_adjst = gc_true.
  cs_profile-show_all   = gc_true.
* cs_profile-exp_level  = gc_detlevel_2.
* Set report to allow saving of variants:
  cs_profile-disvariant-report = sy-repid.
* When you use also other ALV lists in your report,
* please specify a handle to distinguish between the display
* variants of these different lists, e.g:
  cs_profile-disvariant-handle = lc_slishandl.
endform.                    " profile_build

*--------------------------------------------------------------------
* FORM CALLBACK_READ
*--------------------------------------------------------------------
form callback_read                                          "#EC CALLED
       using
         i_s_info            type bal_s_cbrd                "#EC NEEDED
       changing
         c_display_data      type bal_s_show                "#EC NEEDED
         c_context_header    type bal_s_cont                "#EC NEEDED
         c_context_message   type bal_s_cont                "#EC NEEDED
         c_field             type any.                      "#EC NEEDED

  statics:
    ls_context              type beas_rtcontext.

  field-symbols:
    <f1>         type any,
    <struktur>   type any.

  data:
    ls_fmseq         type befs_fmseq,
    ls_object_guid   type bea_bdh_guid,
    lv_func_module   type funcname,
    lv_struktur      type strukname,
    dref             type ref to data.

  constants:
    lc_headno_tmp    type c              value '$',
    lc_ref_table     type lvc_rtname     value 'BEAS_RTCONTEXT',
    lc_ref_field     type lvc_rfname     value 'SRC_HEADNO',
    lc_struc_fix     type bef_structure  value 'WRK',
    lc_struc_field(10) type c            value 'HEADNO_EXT',
    lc_layer         type c              value 'O',
    lc_methode       type string         value 'BDHGETDTL'.


* only add data when come from message context 'BEAS_RTCONTEXT'.
  check c_context_message-tabname = lc_ref_table.
  if i_s_info-ref_table  = lc_ref_table  and
     i_s_info-ref_field  = lc_ref_field  and
     i_s_info-is_message = gc_true.

    ls_context = c_context_message-value.
    if ls_context-appl is initial       or
       ls_context-object is initial     or
       ls_context-container is initial  or
       ls_context-object_guid_c is initial.
      return.
    endif.

    if c_field(1) = lc_headno_tmp.

* define Read-Methode of Object
      clear ls_fmseq.
      ls_fmseq-appl    = ls_context-appl.
      ls_fmseq-obj     = ls_context-object.
      ls_fmseq-layer   = lc_layer.
      ls_fmseq-method  = lc_methode.
      call function 'BEFG_FUNCTIONMODULE_NAME_GET'
        exporting
          is_fmseq          = ls_fmseq
        importing
          ev_functionmodule = lv_func_module
        exceptions
          no_name           = 1
          others            = 2.
      if not sy-subrc is initial.
        return.
      endif.
*
      call function 'FUNCTION_EXISTS'
        exporting
          funcname           = lv_func_module
        exceptions
          function_not_exist = 1
          others             = 2.
      if not sy-subrc is initial.
        return.
      endif.
* define structure of container
      call function 'BEFG_STRUCTURE_NAME_GET'
        exporting
          iv_appl           = ls_context-appl
          iv_container      = ls_context-container
          iv_structure      = lc_struc_fix
        importing
          ev_structure_name = lv_struktur
        exceptions
          no_name           = 1
          others            = 2.
      if not sy-subrc is initial.
        return.
      endif.

      create data dref type (lv_struktur).
      assign dref->* to <struktur>.
      ls_object_guid = ls_context-object_guid_c.

      call function lv_func_module
        exporting
          iv_bdh_guid = ls_object_guid
        importing
          es_bdh      = <struktur>
        exceptions
          notfound    = 1
          others      = 2.
      if not sy-subrc is initial.
        return.
      else.
        assign component lc_struc_field of structure <struktur> to <f1>.
        if sy-subrc is initial.
          c_field = <f1>.
        endif.
        ls_context-src_headno = <f1>.
        c_context_message-value = ls_context.
      endif.

* For cross reference purpose only - Do not delete !
      if 1 = 2.
        call function '/1BEA/CRMB_BD_O_BDHGETDTL'           "#EC EXISTS
          exporting
            iv_bdh_guid = ls_object_guid.
      endif.
    endif.
  endif.

endform.                    "callback_read
