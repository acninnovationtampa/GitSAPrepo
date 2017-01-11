FUNCTION /1BEA/CRMB_DL_TXT_O_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
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
  DATA:
    lt_dli          TYPE /1BEA/T_CRMB_DLI_WRK.

  APPEND IS_DLI TO LT_DLI.
  CALL FUNCTION 'BEA_TXT_O_DELETE'
    EXPORTING
      it_struc          = lt_dli
      iv_tdobject       = gc_dli_txtobj
      iv_typename       = gc_typename_dli_wrk
      iv_appl           = gc_appl
    EXCEPTIONS
      error             = 0
      others            = 0.
*  do not react on errors from DELETE or SAVE
ENDFUNCTION.
