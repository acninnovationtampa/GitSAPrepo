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
  CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_COPY'
    EXPORTING
      IS_DLI           = LS_DLI_OLD
      IS_ITC           = US_ITC
      IS_DLI_NEW       = CS_DLI
    EXCEPTIONS
      REJECT           = 0
      OTHERS           = 0.
