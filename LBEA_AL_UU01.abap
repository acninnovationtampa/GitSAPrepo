function bea_al_u_show.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_APPL) TYPE  BEF_APPL
*"     REFERENCE(IV_CRP_GUID) TYPE  BEA_CRP_GUID OPTIONAL
*"     REFERENCE(IV_LOGHNDL) TYPE  BALLOGHNDL OPTIONAL
*"     REFERENCE(IT_RETURN) TYPE  BEAT_RETURN OPTIONAL
*"     REFERENCE(IV_TITLE) TYPE  BALTITLE OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  BEA_AL_MODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_EXITCOMMAND) TYPE  BAL_S_EXCM
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NO_LOG
*"      INTERNAL_ERROR
*"      NO_AUTHORITY
*"----------------------------------------------------------------------
************************************************************************
* Local Data Declarations:
************************************************************************
  data: ls_loghdr    type bal_s_log,
        lv_loghndl   type balloghndl,
        lv_load      type bea_boolean,
        lv_mode      type bea_al_mode,
        lv_balnrext  type balnrext,
        lt_balhdr_t  type balhdr_t,
        ls_balhdr    type balhdr,
        lt_msgh      type bal_t_msgh,
        ls_msgh      type balmsghndl,
        ls_crp       type beas_crp,
        lv_rc        type sysubrc,
        lt_loghandle type bal_t_logh,
        ls_profile   type bal_s_prof.
************************************************************************
* Implementation Part
************************************************************************
*=======================================================================
* Check
*=======================================================================
  if    ( iv_crp_guid is initial and iv_loghndl is initial )
     or ( not iv_crp_guid is initial and not iv_loghndl is initial ) .
    message e001(bea) with 'BEA_AL_U_SHOW' raising wrong_input.
  endif.
*=======================================================================
* If CRP given, get ID
*=======================================================================
  if not iv_crp_guid is initial.
    call function 'BEA_AL_O_EXTNUMBER_FILL'
      exporting
        iv_appl     = iv_appl
        iv_crp_guid = iv_crp_guid
      importing
        ev_balnrext = lv_balnrext.
  endif.
*=======================================================================
* Current Log?
*=======================================================================
  call function 'BEA_AL_O_GETBUFFER'
    importing
      ev_loghndl = lv_loghndl
      es_loghdr  = ls_loghdr.
  if lv_loghndl is initial.
    lv_load = gc_true.
  elseif not iv_loghndl is initial.
    if lv_loghndl ne iv_loghndl.
      lv_load = gc_true.
    endif.
  elseif not iv_crp_guid is initial.
    if ls_loghdr-extnumber ne lv_balnrext.
      lv_load = gc_true.
    endif.
  endif.
*========================================================================
* No! => Load the Log & Check that it_return is initial!
*========================================================================
  if not lv_load is initial.
*------------------------------------------------------------------------
* Check
*------------------------------------------------------------------------
    if not it_return is initial.
      message e001(bea) with 'BEA_AL_U_SHOW' raising wrong_input.
    endif.
*------------------------------------------------------------------------
* Get the log header
*------------------------------------------------------------------------
    call function 'BEA_AL_O_GETLIST'
      exporting
        iv_appl        = iv_appl
        iv_crp_guid    = iv_crp_guid
        iv_loghndl     = iv_loghndl
      importing
        et_balhdr_t    = lt_balhdr_t
      exceptions
        log_not_found  = 1
        internal_error = 2
        wrong_input    = 3
        others         = 4.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              raising no_log.
    endif.
*------------------------------------------------------------------------
* Load the log to the buffer
*------------------------------------------------------------------------
    call function 'BAL_DB_LOAD'
      exporting
        i_t_log_header     = lt_balhdr_t
      exceptions
        no_logs_specified  = 1
        log_not_found      = 2
        log_already_loaded = 3
        error_message      = 4
        others             = 5.
    if sy-subrc <> 0.
      lv_rc = sy-subrc.
      case lv_rc.
        when 1 or 2.
          message e879(bea) with 'BEA_AL_U_SHOW' raising internal_error.
        when 3.
          "do nothing: It is great, that the log is already loaded!
        when 4.
          message id sy-msgid type sy-msgty number sy-msgno
                          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          raising internal_error.
        when others.                     "OTHERS and more
          message e874(bea) with 'BAL_DB_LOAD'
                            raising internal_error.
      endcase.
    endif.
    loop at lt_balhdr_t into ls_balhdr.
      insert ls_balhdr-log_handle into table lt_loghandle.
    endloop.
  else.
*========================================================================
* Yes: it is the current one!
*========================================================================
*------------------------------------------------------------------------
* Messages to display? Put them to the AL-Buffer
*------------------------------------------------------------------------
    if not it_return is initial.
      call function 'BEA_AL_O_MSGS_ADD'
        exporting
          iv_loghndl   = lv_loghndl
          it_return    = it_return
        importing
          et_msgh      = lt_msgh
        exceptions
          error_at_add = 0
          others       = 0.
    endif.
    insert lv_loghndl into table lt_loghandle.
  endif.
*========================================================================
* Determine the Profile for the Display
*========================================================================
*----------------------------------------------------------------------
* Get the CRP Number
*----------------------------------------------------------------------
  if not iv_crp_guid is initial.
    call function 'BEA_CRP_O_GETDETAIL'
      exporting
        iv_appl          = iv_appl
        iv_crp_guid      = iv_crp_guid
      importing
        es_crp           = ls_crp
      exceptions
        object_not_found = 0
        others           = 0.
  endif.
*----------------------------------------------------------------------
* PROFILE_BUILD
*----------------------------------------------------------------------
  lv_mode = iv_mode.
  if lv_mode is initial.
    if not iv_crp_guid is initial.
      lv_mode = gc_al_dsp_x.
    else.
      lv_mode = gc_al_dsp_n.
    endif.
  endif.
  perform profile_build using    ls_crp-cr_number
                                 iv_title
                                 lv_mode
                                 iv_no_tree
                        changing ls_profile.

*========================================================================
* Display the protocoll in the Fullscreen-mode
*========================================================================
*........................................................................
* Only several messages
*........................................................................
  if not lt_msgh is initial.
    call function 'BAL_DSP_LOG_DISPLAY'
      exporting
        i_s_display_profile  = ls_profile
        i_t_msg_handle       = lt_msgh
      importing
        e_s_exit_command     = es_exitcommand
      exceptions
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4
        error_message        = 5
        others               = 6.
  else.
    call function 'BAL_DSP_LOG_DISPLAY'
      exporting
        i_s_display_profile  = ls_profile
        i_t_log_handle       = lt_loghandle
      importing
        e_s_exit_command     = es_exitcommand
      exceptions
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4
        error_message        = 5
        others               = 6.
  endif.
  if sy-subrc <> 0.
    lv_rc = sy-subrc.
    case lv_rc.
      when 1.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                raising internal_error.
      when 2 or 3 or 5.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                raising internal_error.
      when 4.
        message e873(bea) raising no_authority.
      when others.                     "OTHERS and more
        message e874(bea) with 'BAL_DSP_LOG_DISPLAY'
                          raising internal_error.
    endcase.
  endif.
*======================================================================
* Delete the message from the buffer of the Application Log
*======================================================================
  loop at lt_msgh into ls_msgh.
    call function 'BAL_LOG_MSG_DELETE'
      exporting
        i_s_msg_handle = ls_msgh
      exceptions
        msg_not_found  = 0
        log_not_found  = 0
        others         = 0.
  endloop.
endfunction.
