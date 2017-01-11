FUNCTION-POOL /1BEA/CRMB_BD_MWC_O.          "MESSAGE-ID ..
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:02
*
*======================================================================
  INCLUDE BEA_BASICS_CON.
  INCLUDE BEA_PRC_CON.
  INCLUDE BEA_ACC_CON.
  INCLUDE BEA_CLASS_F1_CON.

  CONSTANTS:
    GC_APPL TYPE BEF_APPL VALUE 'CRMB',
    GC_OBJ  TYPE BEF_OBJ  VALUE 'BD'.
  DATA:
    GV_MAX_ITEMS    TYPE I VALUE '100',
    GS_MWC_PARAM    TYPE BEAS_MWC_PARAM.
  TYPES: tt_bdi_wrk2 type sorted table of /1BEA/S_CRMB_BDI_WRK
                     with non-unique key p_src_headno_d.
LOAD-OF-PROGRAM.
CALL FUNCTION 'BEA_MWC_O_GETDETAIL'
  EXPORTING
    IV_APPL            = GC_APPL
  IMPORTING
    ES_MWC_PARAM       = GS_MWC_PARAM
  EXCEPTIONS
    NOT_FOUND          = 0
    OTHERS             = 0.
