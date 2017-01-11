FUNCTION /1BEA/CRMB_DL_PAR_O_REFRESH.
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
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  CLEAR:
    GT_PARSETS_DEL,
    GT_DOC_ADDR.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'COM_PARTNER_INIT_OW'
    EXPORTING
      IV_INIT_WHOLE_BUFFER         = GC_TRUE
      IV_INIT_DB_BUFFER            = GC_TRUE.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
