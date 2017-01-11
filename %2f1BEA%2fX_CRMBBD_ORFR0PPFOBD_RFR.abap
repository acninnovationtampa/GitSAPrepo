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
*--------------------------------------------------------------------
* Refresh PPF Data
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_REFRESH'
         EXPORTING
              IT_BDH      = GT_BDH_WRK.
