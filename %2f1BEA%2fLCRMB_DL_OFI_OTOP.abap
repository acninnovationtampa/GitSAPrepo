FUNCTION-POOL /1BEA/CRMB_DL_OFI_O.          "MESSAGE-ID ..
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

  CONSTANTS:
    GC_APPL        TYPE BEF_APPL            VALUE 'CRMB',
    GC_USAGE_BD    TYPE /SAPCND/USAGE       VALUE 'BD',
    GC_APPLICATION TYPE /SAPCND/APPLICATION VALUE 'BEA'.
  DATA:
    GV_DRV_LOG     TYPE BEA_BOOLEAN,
    GV_DETERM_TYPE TYPE BEA_BILL_ORG_DET_TYPE.

INCLUDE: BEA_PAR_PFT,
         OFI_CONSTANTS,
         BEA_BASICS.

LOAD-OF-PROGRAM.
  GET PARAMETER ID 'BEA_DRV_LOG' FIELD GV_DRV_LOG.
