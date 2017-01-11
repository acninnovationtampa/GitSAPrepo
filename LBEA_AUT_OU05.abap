FUNCTION bea_aut_o_check_all.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BILL_TYPE) TYPE  BEA_BILL_TYPE
*"     REFERENCE(IV_BILL_ORG) TYPE  BEA_BILL_ORG
*"     REFERENCE(IV_APPL) TYPE  BEF_APPL
*"     REFERENCE(IV_ACTVT) TYPE  ACTIV_AUTH
*"     REFERENCE(IV_CHECK_DLI) TYPE  BEA_BOOLEAN
*"     REFERENCE(IV_CHECK_BDH) TYPE  BEA_BOOLEAN
*"     REFERENCE(IV_OBJTYPE) TYPE  BEA_OBJTYPE OPTIONAL
*"     REFERENCE(IV_OBJECT_GUID) TYPE  BEA_OBJECT_GUID OPTIONAL
*"  EXCEPTIONS
*"      NO_AUTH
*"----------------------------------------------------------------------

  DATA:
        lv_object_type   TYPE crmt_prt_otype,
        lv_object_guid   TYPE crms_ace_object_guid,
        lv_ace_required  TYPE bea_boolean,
        lv_bill_org      TYPE BEA_BILL_ORG.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
     EXPORTING
       INPUT    = iv_bill_org
     IMPORTING
       OUTPUT    = lv_bill_org.

*---------------------------------------------
* call standard authority check
*---------------------------------------------

  CALL FUNCTION 'BEA_AUT_O_CHECK_GEN'
    EXPORTING
      iv_bill_type = iv_bill_type
      iv_bill_org  = lv_bill_org
      iv_appl      = iv_appl
      iv_actvt     = iv_actvt
      iv_check_dli = iv_check_dli
      iv_check_bdh = iv_check_bdh
    EXCEPTIONS
      no_auth      = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    RAISE no_auth.
  ENDIF.

*---------------------------------------------
* Call ACE (acess control engine)
*---------------------------------------------

* ACE-Switch is active
  IF gv_ace_active = abap_true.
    IF iv_objtype NE space AND iv_object_guid NE space.
      lv_object_type = iv_objtype.
      lv_object_guid-object_guid = iv_object_guid.

* Is ACE Check required?
      CALL FUNCTION 'BEA_AUT_ACE_CHECK_REQUIRED'
        EXPORTING
          iv_action             = iv_actvt
          iv_object_type        = lv_object_type
          iv_is_bor_type        = abap_true
        IMPORTING
          ev_ace_check_required = lv_ace_required.

      CHECK lv_ace_required NE abap_false.

      TRY.
          CALL METHOD cl_crm_ace_runtime=>check_single_object_guid
            EXPORTING
              im_action       = iv_actvt
              im_object_type  = lv_object_type
              im_is_bor_otype = abap_true
              im_object_guid  = lv_object_guid.
        CATCH cx_crm_ace_unsupported_action
              cx_crm_ace_access_denied .                "#EC NO_HANDLER
          RAISE no_auth.
      ENDTRY.
    ENDIF.
  ENDIF.
ENDFUNCTION.
