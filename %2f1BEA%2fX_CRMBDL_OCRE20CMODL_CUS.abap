*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================
  IF cs_itc IS NOT INITIAL AND
     us_dli_int-bill_relevance_c = gc_bill_rel_value.
    ls_dli_wrk-item_type = gc_item_type_value.
    IF cs_itc-bill_relev = gc_bill_rel_indirect.
      MESSAGE e106(bea) WITH gc_p_dli_itemno gc_p_dli_headno
                        INTO gv_dummy.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          iv_container = 'DLI'
          is_dli_wrk   = ls_dli_wrk
          it_return    = ct_return
        IMPORTING
          et_return    = ct_return.
      lv_returncode = 1.
    ENDIF.
  ENDIF.
