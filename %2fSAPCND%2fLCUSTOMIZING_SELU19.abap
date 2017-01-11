function /sapcnd/cus_t681a_sel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_APPLICATION) TYPE  /SAPCND/APPLICATION OPTIONAL
*"     VALUE(I_BYPASSING_BUFFER) TYPE  /SAPCND/BOOLEAN DEFAULT
*"       CTCUS_FALSE
*"     VALUE(I_FOR_UPDATE) TYPE  /SAPCND/BOOLEAN DEFAULT CTCUS_FALSE
*"  EXPORTING
*"     REFERENCE(E_SELECTED_DATA) TYPE  /SAPCND/T681A_S
*"     REFERENCE(ET_SELECTED_DATA) TYPE  /SAPCND/T681A_S_T
*"----------------------------------------------------------------------

  data: lt_where_clause type gtt_dynsql,
        ls_where_clause type line of gtt_dynsql.

  clear e_selected_data.
  clear et_selected_data[].

  sy-tabix = 0.
  append_where_clause  i_application 'KAPPL ='.

  if sy-tabix > 0.
    delete lt_where_clause index sy-tabix.
  endif.

  if sy-tabix = 2.
*   complete key ==> select single
    select_single_from_table /sapcnd/t681a
                             e_selected_data.
  else.
*   incomplete key ==> range select
    select_range_from_table /sapcnd/t681a
                            et_selected_data.
    if sy-dbcnt = 1.
      read table et_selected_data into e_selected_data index 1.
    endif.
  endif.

endfunction.
