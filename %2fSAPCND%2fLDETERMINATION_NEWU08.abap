FUNCTION /SAPCND/CNF_GET_PRIORITIES_NEW .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_CALL_MODE) TYPE  /SAPCND/KCALLMODE
*"  EXPORTING
*"     REFERENCE(ET_PRIORITIES) TYPE  /SAPCND/KPRIORITIES
*"----------------------------------------------------------------------
*       priority is dependent from CALL_MODUS:                        *
*                                                                     *
*                    'A'         'B'        'C'                       *
*         'D'                     1                                   *
*         'B'                                1                        *
*         'C'                     2          2                        *
*         ' '         1           3          3                        *
*         'A'                                                         *
*      first row: CALL_MODUS = 'A' for pricing                        *
*                            = 'B' for planning                       *
*                            = 'C' for simulation                     *
*      first column: KFRST                                            *
*      entries (1, 2, 3) refer to priority: the higher the number,    *
*                        the higher the priority                      *
*      entry SPACE means: KFRST not allowed for this CALL_MODUS       *
*      entries (1, 2, 3) are also the TABIX of table PRIORITIES       *
*"----------------------------------------------------------------------

  data: da_table_initialized(1) type c,
        priorities_a            type /sapcnd/kpriorities, "for pricing
        priorities_b            type /sapcnd/kpriorities, "for planning
        priorities_c            type /sapcnd/kpriorities.   "for simul

  if da_table_initialized is initial.
    da_table_initialized = 'X'.

* initialize internal table for CallMode 'A' (pricing)
    clear priorities_a.
    append ' ' to priorities_a.

* initialize internal table for CallMode 'B' (planning)
    clear priorities_b.
    append ' ' to priorities_b.
    append 'C' to priorities_b.
    append 'D' to priorities_b.

* initialize internal table for CallMode 'C' (simulation)
    clear priorities_c.
    append ' ' to priorities_c.
    append 'C' to priorities_c.
    append 'B' to priorities_c.
  endif.

* determine appropiate internal table for exporting
  case iv_call_mode.
    when ' ' or 'A'.
      et_priorities[] = priorities_a[].
    when 'B'.
      et_priorities[] = priorities_b[].
    when 'C'.
      et_priorities[] = priorities_c[].
  endcase.

endfunction.
