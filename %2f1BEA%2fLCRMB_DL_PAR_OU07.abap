FUNCTION /1BEA/CRMB_DL_PAR_O_GET_CTRL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_PAR_CTRL) TYPE  COMT_PARTNER_CONTROL
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
*--------------------------------------------------------------------*
* BEGIN PROCESS
*--------------------------------------------------------------------*
  ES_PAR_CTRL-CALLER      = 'BEA'.
  ES_PAR_CTRL-DOCUMENT_ID = IS_DLI-DLI_GUID.
* ES_PAR_CTRL-OBJECT_ID   =                     has not to be filled ?
  ES_PAR_CTRL-OBJECT_TYPE = GC_BOR_DLI.
* ES_PAR_CTRL-MASTER_DATA_STRUCTURE             has not to be filled
  ES_PAR_CTRL-DETERM_PROC = IS_ITC-DLI_PAR_PROC.
  ES_PAR_CTRL-SCOPE       = GC_SCOPE.
* ES_PAR_CTRL-CASH_ON_DELIVERY                    has not to be filled
  ES_PAR_CTRL-NO_DEFAULT_FOR_CALENDAR_FLAG = GC_TRUE.
* ES_PAR_CTRL-POPULATE_MODE                       has not to be filled
*--------------------------------------------------------------------*
* END PROCESS
*--------------------------------------------------------------------*
ENDFUNCTION.
