FUNCTION bea_al_o_create.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_APPL) TYPE  BEF_APPL
*"     REFERENCE(IV_CRP_GUID) TYPE  BEA_CRP_GUID OPTIONAL
*"     REFERENCE(IV_DLI_GUID) TYPE  BEA_DLI_GUID OPTIONAL
*"     REFERENCE(IV_EXTNUMBER) TYPE  BALNREXT OPTIONAL
*"     REFERENCE(IV_SUBOBJECT) TYPE  BALSUBOBJ OPTIONAL
*"     REFERENCE(IV_MAINT_USER) TYPE  BEA_MAINT_USER OPTIONAL
*"     REFERENCE(IV_MAINT_DATE) TYPE  BEA_MAINT_DATE OPTIONAL
*"     REFERENCE(IV_MAINT_TIME) TYPE  BEA_MAINT_TIME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_LOGHNDL) TYPE  BALLOGHNDL
*"     REFERENCE(ES_LOGHDR) TYPE  BAL_S_LOG
*"  EXCEPTIONS
*"      LOG_ALREADY_EXISTS
*"      LOG_NOT_CREATED
*"----------------------------------------------------------------------
************************************************************************
* Processing Logic
************************************************************************
* The AL object is always set to 'BEA'.
* For the subobject and the external number there are three options:
* 1. Depending on the CRP_GUID:
*    - If IV_CRP_GUID is filled, the subobject is set to 'CRP' and the
*      external number concatenated as <APPL>_<CRP_GUID>
*    - If IV_CRP_GUID is not filled (and IV_SUBOBJECT is not given), the
*      subobject is set to 'NO_CRP'
* 1. Depending on the DLI_GUID:
*    - If IV_DLI_GUID is filled, the subobject is set to 'DLI' and the
*      external number concatenated as
*      <IV_EXTNUMBER>_<APPL>_<DLI_GUID>
* 2. Explixitly given in IV_SUBOBJECT (no external number)
*
************************************************************************
* Local Data Declaration
************************************************************************
  DATA: ls_loghdr         TYPE bal_s_log,
        lv_returncode     TYPE sysubrc.
************************************************************************
* Implementation
************************************************************************
*-----------------------------------------------------------------------
* Check out, if function module is called at the right place:
* (do only for collective run, not for DL)
*-----------------------------------------------------------------------
  IF NOT gv_loghndl IS INITIAL AND iv_dli_guid is initial AND gs_loghdr-subobject NE gc_alsubobject_dli.
    MESSAGE e899(bea) RAISING log_already_exists.
  ENDIF.
*-----------------------------------------------------------------------
* Now, fill the structure of the Protocoll Header...
*-----------------------------------------------------------------------
*.......................................................................
* General Part
*.......................................................................
  ls_loghdr-object    = gc_alobject_bea.
  IF iv_maint_user IS INITIAL.
    ls_loghdr-aluser    = sy-uname.
  ELSE.
    ls_loghdr-aluser    = iv_maint_user.
  ENDIF.
  IF iv_maint_date IS INITIAL.
    ls_loghdr-aldate    = sy-datlo.
  ELSE.
    ls_loghdr-aldate    = iv_maint_date.
  ENDIF.
  IF iv_maint_time IS INITIAL.
    ls_loghdr-altime    = sy-timlo.
  ELSE.
    ls_loghdr-altime    = iv_maint_time.
  ENDIF.
  ls_loghdr-alprog    = sy-repid.
*.......................................................................
* Part, that depends on: CRP or NO_CRP:
*.......................................................................
  IF iv_subobject IS INITIAL.
    IF iv_crp_guid IS INITIAL.
      ls_loghdr-subobject = gc_alsubobject_no_crp.
      ls_loghdr-extnumber = iv_appl.
    ELSE.
      ls_loghdr-subobject = gc_alsubobject_crp.
      CALL FUNCTION 'BEA_AL_O_EXTNUMBER_FILL'
        EXPORTING
          iv_appl     = iv_appl
          iv_crp_guid = iv_crp_guid
        IMPORTING
          ev_balnrext = ls_loghdr-extnumber.
    ENDIF.
    IF NOT iv_dli_guid IS INITIAL.
      ls_loghdr-subobject = gc_alsubobject_dli.
      CALL FUNCTION 'BEA_AL_O_EXTNUMBER_FILL'
        EXPORTING
          iv_appl      = iv_appl
          iv_dli_guid  = iv_dli_guid
          iv_extnumber = iv_extnumber
        IMPORTING
          ev_balnrext  = ls_loghdr-extnumber.
    ENDIF.
  ELSE.
    ls_loghdr-subobject = iv_subobject.
  ENDIF.

*-----------------------------------------------------------------------
* ... and create such a header.
*-----------------------------------------------------------------------
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = ls_loghdr
    IMPORTING
      e_log_handle            = gv_loghndl
    EXCEPTIONS
      log_header_inconsistent = 1
      error_message           = 2
      OTHERS                  = 3.
  IF sy-subrc = 0.

    gs_loghdr  = ls_loghdr.

    es_loghdr  = gs_loghdr.
    ev_loghndl = gv_loghndl.

  ELSE.
*.......................................................................
* Handle errors:
*.......................................................................
    lv_returncode = sy-subrc.
    CASE lv_returncode.
      WHEN 1.            "log_header_inconsistent
        MESSAGE e879(bea) WITH 'BEA_AL_O_CREATE' RAISING log_not_created.
      WHEN 2.            "error_message
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING log_not_created.
      WHEN OTHERS.                     "OTHERS and more
        MESSAGE e874(bea) WITH 'BAL_LOG_CREATE' RAISING log_not_created.
    ENDCASE.
  ENDIF.
ENDFUNCTION.
