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
  IF US_DLI_WRK-BILL_RELEVANCE <> GC_BILL_REL_DLV_TPOP.
    MOVE US_DLI_WRK-INCOTERMS1 TO CS_BDH_WRK-INCOTERMS1.
    MOVE US_DLI_WRK-INCOTERMS2 TO CS_BDH_WRK-INCOTERMS2.
  ENDIF.
