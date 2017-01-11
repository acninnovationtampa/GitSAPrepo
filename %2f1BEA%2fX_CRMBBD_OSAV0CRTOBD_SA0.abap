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
*---------------------------------------------------------------------
* Service taxes
*---------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_BD_CRT_O_SAVE'
    EXPORTING
      IT_BDH_WRK = GT_BDH_WRK
      IV_POST    = GC_FALSE
    IMPORTING
      ET_BDH_WRK = GT_BDH_WRK.
