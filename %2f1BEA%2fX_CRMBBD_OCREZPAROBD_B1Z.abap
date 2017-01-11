*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================
*------------------------------------------------------------------*
*     FORM PARTNER_GET
*------------------------------------------------------------------*
FORM PAROBD_B1Z_PARTNER_GET
  USING
    IT_DLI      TYPE /1BEA/T_CRMB_DLI_WRK.

  CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_GET_MULTI'
    EXPORTING
      IT_DLI        = IT_DLI.

ENDFORM.       "PARTNER_GET
