FUNCTION /1BEA/CRMB_DL_O_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_DERIV_CATEGORY) TYPE  BEA_DERIV_CATEGORY OPTIONAL
*"     REFERENCE(IS_DLI_INT) TYPE  /1BEA/S_CRMB_DLI_INT
*"     REFERENCE(IS_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IT_CONDITION) TYPE  BEAT_PRC_COM
*"     REFERENCE(IT_PARTNER) TYPE  BEAT_PAR_COM
*"     REFERENCE(IT_TEXTLINE) TYPE  COMT_TEXT_TEXTDATA_T
*"  EXPORTING
*"     REFERENCE(ET_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
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
* Time  : 13:53:10
*
*======================================================================
  DATA:
    LT_RETURN TYPE BEAT_RETURN.

  BREAK-POINT ID BEA_DRV.

* Event DL_OCRE6
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE6ICBODL_DRV.

  INSERT LINES OF LT_RETURN INTO TABLE ET_RETURN.

ENDFUNCTION.
