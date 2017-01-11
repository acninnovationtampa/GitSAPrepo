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
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Pricing
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  LOOP AT GT_BDH_WRK INTO LS_BDH_WRK.
    PERFORM PRCOBD_B1Z_BDH_PRICING
      CHANGING
        LS_BDH_WRK.
    MODIFY GT_BDH_WRK FROM LS_BDH_WRK.
  ENDLOOP.
