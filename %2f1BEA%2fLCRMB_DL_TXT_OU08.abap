FUNCTION /1BEA/CRMB_DL_TXT_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
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

* EXPLAIN:
* Use generic functions to refresh text memory for this DL item

  CALL FUNCTION 'BEA_TXT_O_REFRESH'
       EXPORTING
            it_struc    = it_dli
            iv_tdobject = gc_dli_txtobj
            iv_typename = gc_typename_dli_wrk
            IV_APPL     = GC_APPL
       EXCEPTIONS
            error       = 0
            OTHERS      = 0.
*   do not react on errors from REFRESH

ENDFUNCTION.
