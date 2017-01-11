FUNCTION /1BEA/CRMB_BD_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_DLI_NO_SAVE) TYPE  BEA_BOOLEAN OPTIONAL
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
* Time  : 13:52:50
*
*======================================================================


*---------------------------------------------------------------------
* Refresh service data (if services are activated)
*---------------------------------------------------------------------
* Event BD_ORFR0
  INCLUDE %2f1BEA%2fX_CRMBBD_ORFR0PRCOBD_RFR.
  INCLUDE %2f1BEA%2fX_CRMBBD_ORFR0CRTOBD_RFR.
  INCLUDE %2f1BEA%2fX_CRMBBD_ORFR0PAROBD_RFR.
  INCLUDE %2f1BEA%2fX_CRMBBD_ORFR0TXTOBD_RFR.
  INCLUDE %2f1BEA%2fX_CRMBBD_ORFR0PPFOBD_RFR.
  INCLUDE BETX_CSAOBD_RFR.

*---------------------------------------------------------------------
* Refresh global data of the function pool
*---------------------------------------------------------------------
  CLEAR : GS_DLI_HLP,
          GS_DLI_HLP_REF.

  CLEAR:
    GT_BDH_WRK,
    GS_BDH_HLP,
    GT_BDI_WRK,
    GS_BDI_HLP.

  CLEAR gt_return.
  CLEAR GV_LOGHNDL.
  CLEAR gs_crp.
  CLEAR GT_CUM_DFL.

ENDFUNCTION.
