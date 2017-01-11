function bea_restrict_selection.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_NR_OF_ENTRIES) TYPE  BEA_NR_OF_ENTRIES
*"     REFERENCE(IV_OBJTYPE) TYPE  BEA_OBJTYPE OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BEA_NR_OF_ENTRIES OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_NR_OF_ENTRIES) TYPE  BEA_NR_OF_ENTRIES
*"     REFERENCE(EV_NO_DIALOG) TYPE  BEA_BOOLEAN
*"----------------------------------------------------------------------

  constants:
    lc_max_docs    type i value 100,
    lc_max_items   type i value 500,
    lc_first       type c value '1',
    lc_all         type c value '2',
    lc_abort       type c value 'A',
    lc_bor_dli     type oj_name value 'BUS20800',
    lc_bor_bdi     type oj_name value 'BUS20820'.

  data:
    lv_max_rows    type i,
    lv_msg(70)     type c,
    lv_text(200)   type c,
    lv_icon        type iconname value 'NO_ICON',
    lv_answer      type c.

  if iv_maxrows is initial.
    if iv_objtype = lc_bor_dli or iv_objtype = lc_bor_bdi.
      lv_max_rows = lc_max_items.
    else.
      lv_max_rows = lc_max_docs.
    endif.
  else.
    lv_max_rows = iv_maxrows.
  endif.

  if iv_nr_of_entries le lv_max_rows.
    ev_nr_of_entries = iv_nr_of_entries.
    ev_no_dialog     = 'X'.
  else.
    if iv_objtype = lc_bor_dli or iv_objtype = lc_bor_bdi.
      message e009(bea) with iv_nr_of_entries into lv_msg.
    else.
      message e010(bea) with iv_nr_of_entries into lv_msg.
    endif.
    lv_text = lv_msg.
    message e011(bea) into lv_msg.
    concatenate lv_text lv_msg into lv_text separated by space.
    message e012(bea)  with lv_max_rows into lv_msg.
    concatenate lv_text lv_msg into lv_text separated by space.
    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar       = text-t01
        text_question  = lv_text
        text_button_1  = text-b01
        text_button_2  = text-b02
        popup_type     = lv_icon
      importing
        answer         = lv_answer
      exceptions
        text_not_found = 0
        others         = 0.
    case lv_answer.
      when lc_first.
        ev_nr_of_entries = lv_max_rows.
      when lc_all.
        ev_nr_of_entries = iv_nr_of_entries.
      when lc_abort.
        ev_nr_of_entries = 0.
    endcase.
  endif.

endfunction.
