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
* No re-pricing possible for milestone billing in any case
* -> set pricing type to "Copy pricing elements unchanged and
*    redetermine taxes"
IF NOT CS_BDI_WRK-NET_VALUE_MAN IS INITIAL.
  CS_BDI_WRK-BDI_PRICING_TYPE = 'G'.
ENDIF.
