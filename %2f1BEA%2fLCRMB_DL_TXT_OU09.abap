FUNCTION /1BEA/CRMB_DL_TXT_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ET_DLI_FAULT) TYPE  /1BEA/T_CRMB_DLI_WRK
*"--------------------------------------------------------------------
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_DLI     TYPE /1BEA/S_CRMB_DLI_WRK,
    lt_dli_del type /1BEA/t_CRMB_DLI_WRK,
    lt_dli     type /1BEA/t_CRMB_DLI_WRK.

* EXPLAIN:
* Use generic functions to refresh text memory for this DL item
* Only DL items with initial REVERSAL flag may have texts
* attached to them, i.e. only those items need to be considered

* First, the DELETE flag in the texts must be set
* for all DL items with a DELETE flag.
  loop at it_dli into ls_dli
       where not upd_type is initial.
    append ls_dli to lt_dli.
    if ls_dli-upd_type = gc_delete.
      append ls_dli to lt_dli_del.
    endif.
  endloop.

  call function 'BEA_TXT_O_DELETE'
    exporting
      it_struc          = lt_dli_del
      iv_tdobject       = gc_dli_txtobj
      iv_typename       = gc_typename_dli_wrk
      iv_appl           = gc_appl
    exceptions
      error             = 0
      others            = 0.
*  do not react on errors from DELETE or SAVE

*  Now, save all texts
   CALL FUNCTION 'BEA_TXT_O_SAVE'
        EXPORTING
             it_struc    = lt_dli
             iv_tdobject = gc_dli_txtobj
             iv_typename = gc_typename_dli_wrk
             iv_appl     = gc_appl
        EXCEPTIONS
             error       = 0
             OTHERS      = 0.
*  do not react on errors from DELETE or SAVE

ENDFUNCTION.
