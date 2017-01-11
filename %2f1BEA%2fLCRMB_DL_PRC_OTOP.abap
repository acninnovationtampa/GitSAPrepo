FUNCTION-POOL /1BEA/CRMB_DL_PRC_O.          "MESSAGE-ID ..
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
INCLUDE BEA_BASICS.
INCLUDE BEA_PRC_CON.

DATA:
  GV_MAPPING_EXIT TYPE REF TO BEA_CRMB_DL_PRC,
  GV_PRC_LOGHNDL  TYPE BALLOGHNDL.
DATA:
  GT_HEAD_ATTR_NAMES TYPE PRCT_ATTR_NAME_T,
  GT_ITEM_ATTR_NAMES TYPE PRCT_ATTR_NAME_T,
  GT_TIMESTAMP_NAMES TYPE PRCT_ATTR_NAME_T,
  GT_ALL_ATTR_NAMES  TYPE PRCT_ATTR_NAME_T.

DEFINE PRC_LOG_INIT.
  DATA LS_LOG TYPE BAL_S_LOG.
  LS_LOG-EXTNUMBER = 'PRC'.
  LS_LOG-OBJECT    = 'BEA'.
  LS_LOG-SUBOBJECT = 'PRC'.
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
       I_S_LOG      = LS_LOG
    IMPORTING
      E_LOG_HANDLE  = GV_PRC_LOGHNDL
    EXCEPTIONS
      OTHERS        = 0.
END-OF-DEFINITION.
DEFINE PRC_LOG_CLEAR.
  IF NOT GV_PRC_LOGHNDL IS INITIAL.
    CALL FUNCTION 'BAL_LOG_MSG_DELETE_ALL'
      EXPORTING
        I_LOG_HANDLE = GV_PRC_LOGHNDL
      EXCEPTIONS
        OTHERS       = 0.
  ENDIF.
END-OF-DEFINITION.

LOAD-OF-PROGRAM.
  try.
    GET BADI GV_MAPPING_EXIT.
    catch cx_badi_not_implemented.
  endtry.
