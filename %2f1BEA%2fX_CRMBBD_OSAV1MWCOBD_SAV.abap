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
* Middleware - always the last service
*---------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_BD_MWC_O_FLOW'
    EXPORTING
      IT_BDH           = GT_BDH_WRK
      IT_BDI           = GT_BDI_WRK
      IT_ADD_CUM_DFL   = GT_CUM_DFL
      IV_MAX_NO_QUEUES = 10
    IMPORTING
      ET_BDH = GT_BDH_WRK.
