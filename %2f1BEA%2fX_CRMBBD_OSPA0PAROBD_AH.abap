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
* ANALYZE PARTNER
*---------------------------------------------------------------------
  PERFORM PAROBD_AHZ_ANALYZE_HEAD_PAR
    USING    IS_BDH_WRK_L-PARSET_GUID
             IS_BDH_WRK_R-PARSET_GUID
    CHANGING LT_SPLIT.
