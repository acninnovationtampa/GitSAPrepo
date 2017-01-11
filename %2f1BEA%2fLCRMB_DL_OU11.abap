FUNCTION /1BEA/CRMB_DL_O_REFRESH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_WITH_SERVICES) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_WITH_DOCFLOW) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_WITH_DLH) TYPE  BEA_BOOLEAN OPTIONAL
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
* Refresh service data (if any)
* Event DL_ORFR0
  INCLUDE %2f1BEA%2fX_CRMBDL_ORFR0PARODL_RFR.
  INCLUDE %2f1BEA%2fX_CRMBDL_ORFR0PRCODL_RFR.
  INCLUDE BETX_CRTODL_RFR.
  INCLUDE %2f1BEA%2fX_CRMBDL_ORFR0TXTODL_RFR.
  INCLUDE %2f1BEA%2fX_CRMBDL_ORFR0ICXODL_RFR.
  INCLUDE %2f1BEA%2fX_CRMBDL_ORFR0DRVODL_RFR.
*--------------------------------------------------------------------
* Refresh Document Flow Data
*--------------------------------------------------------------------
IF NOT IV_WITH_DOCFLOW IS INITIAL.
  CALL FUNCTION 'BEA_DFL_O_REFRESH'.
ENDIF.
*--------------------------------------------------------------------
* Refresh global data of the function pool
*--------------------------------------------------------------------

  CLEAR:
    GT_DLI_WRK,
    GS_DLI_HLP.
  IF IV_WITH_DLH IS NOT INITIAL.
    CLEAR: GT_DLH_WRK.
  ENDIF.

  CLEAR:
     GS_SRC_HID,
     GT_SRCDLHD_ENQ.
  CLEAR GT_DG_ID_ENQ.
  CLEAR GT_DLI_DGB.
  CLEAR GS_DLI_DGB.
ENDFUNCTION.
