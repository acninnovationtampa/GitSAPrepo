REPORT /1BEA/R_CRMB_BD_INTRASTAT .
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:54:43
*
*======================================================================
DATA:
  gv_feature_active TYPE bea_boolean.

IF gv_feature_active IS INITIAL.
  MESSAGE i101(bea_sll).
ENDIF.
