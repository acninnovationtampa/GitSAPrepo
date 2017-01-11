FUNCTION /1BEA/CRMB_BD_TXT_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
* Time  : 13:53:02
*
*======================================================================

  CALL FUNCTION 'COM_TEXT_DETERMINATION_FLAG_CL'.

* REFRESH texts for BD heads
  CALL FUNCTION 'BEA_TXT_O_REFRESH'
       EXPORTING
            IT_STRUC    = IT_BDH
            IV_TDOBJECT = GC_BDH_TXTOBJ
            IV_TYPENAME = GC_TYPENAME_BDH_WRK
            IV_APPL     = GC_APPL
       EXCEPTIONS
            ERROR       = 0
            OTHERS      = 0.
* do not react on errors from REFRESH

* REFRESH texts for BD items
  CALL FUNCTION 'BEA_TXT_O_REFRESH'
       EXPORTING
            IT_STRUC    = IT_BDI
            IV_TDOBJECT = GC_BDI_TXTOBJ
            IV_TYPENAME = GC_TYPENAME_BDI_WRK
            IV_APPL     = GC_APPL
       EXCEPTIONS
            ERROR       = 0
            OTHERS      = 0.
* do not react on errors from REFRESH

ENDFUNCTION.
