FUNCTION /1BEA/CRMB_BD_PRC_O_PREPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH_WRK) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI_WRK) TYPE  /1BEA/T_CRMB_BDI_WRK OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
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

* Event _PRCIPI3
  INCLUDE %2f1BEA%2fX_CRMB_PRCIPI3CRTOBD_DS.

ENDFUNCTION.
