FUNCTION-POOL bea_aut_o                  MESSAGE-ID bea.

CONSTANTS: gc_charx       TYPE bea_boolean     VALUE 'X'.

DATA: gt_buffer_dli TYPE beat_dli_auth_buffer,
      gt_buffer_bdh TYPE beat_bdh_auth_buffer.

* ACE-Enablement
DATA:
  gv_ace_active TYPE bea_boolean VALUE space.

LOAD-OF-PROGRAM.
*---------------Check ACE-Switching--------------
  IF ( cl_crm_sfw_ehp1_switch_check=>is_switch_active( cl_crm_sfw_ehp1_switch_check=>gc_crm_ace_sfws_obj_enablement ) EQ abap_true ).
    gv_ace_active = abap_true.
  ELSE.
    gv_ace_active = abap_false.
  ENDIF.
