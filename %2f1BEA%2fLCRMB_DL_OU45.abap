FUNCTION /1BEA/CRMB_DL_O_DOCFL_REV_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXCEPTIONS
*"      REJECT
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_BDH   TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DFL   TYPE BEAS_DFL_WRK,
    LT_DFL   TYPE BEAT_DFL_WRK,
    LRS_GUID TYPE BEARS_BDI_GUID,
    LRT_GUID TYPE BEART_BDI_GUID.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
  LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
  LRS_GUID-LOW    = IS_BDI-BDI_GUID.
  APPEND LRS_GUID TO LRT_GUID.
  IF IS_BDI-REVERSAL IS INITIAL.
  CALL FUNCTION 'BEA_DFL_O_GETLIST'
    EXPORTING
       IRT_PRE_GUID  = LRT_GUID
    IMPORTING
       ET_DFL        = LT_DFL.
*   Look for the successor in docflow
    READ TABLE LT_DFL INTO LS_DFL
      WITH KEY PRE_GUID = IS_BDI-BDI_GUID.
    IF SY-SUBRC = 0.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETDTL'
        EXPORTING
          IV_BDI_GUID = LS_DFL-SUC_GUID
        IMPORTING
          ES_BDI      = ES_BDI
        EXCEPTIONS
          NOTFOUND    = 0
          OTHERS      = 0.
      IF ES_BDH IS REQUESTED.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
          EXPORTING
            IV_BDH_GUID = ES_BDI-BDH_GUID
          IMPORTING
            ES_BDH      = ES_BDH
          EXCEPTIONS
            NOTFOUND    = 0
            OTHERS      = 0.
      ENDIF.
    ELSE.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
        EXPORTING
          IV_BDH_GUID = IS_BDI-BDH_GUID
        IMPORTING
          ES_BDH      = LS_BDH
        EXCEPTIONS
          NOTFOUND    = 0
          OTHERS      = 0.
      MESSAGE E129(BEA) WITH LS_BDH-HEADNO_EXT RAISING REJECT.
    ENDIF.
  ELSEIF IS_BDI-REVERSAL = GC_REVERSAL_CANCEL.
  CALL FUNCTION 'BEA_DFL_O_GETLIST'
    EXPORTING
       IRT_SUC_GUID  = LRT_GUID
    IMPORTING
       ET_DFL        = LT_DFL.
*   Look for the predecessor in docflow
    READ TABLE LT_DFL INTO LS_DFL
      WITH KEY SUC_GUID = IS_BDI-BDI_GUID.
    IF SY-SUBRC = 0.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETDTL'
        EXPORTING
          IV_BDI_GUID = LS_DFL-PRE_GUID
        IMPORTING
          ES_BDI      = ES_BDI
        EXCEPTIONS
          NOTFOUND    = 0
          OTHERS      = 0.
      IF ES_BDH IS REQUESTED.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
          EXPORTING
            IV_BDH_GUID = ES_BDI-BDH_GUID
          IMPORTING
            ES_BDH      = ES_BDH
          EXCEPTIONS
            NOTFOUND    = 0
            OTHERS      = 0.
      ENDIF.
    ELSE.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
        EXPORTING
          IV_BDH_GUID = IS_BDI-BDH_GUID
        IMPORTING
          ES_BDH      = LS_BDH
        EXCEPTIONS
          NOTFOUND    = 0
          OTHERS      = 0.
      MESSAGE E129(BEA) WITH LS_BDH-HEADNO_EXT RAISING REJECT.
    ENDIF.
  ELSEIF IS_BDI-REVERSAL = GC_REVERSAL_CORREC.
  CALL FUNCTION 'BEA_DFL_O_GETLIST'
    EXPORTING
       IRT_SUC_GUID  = LRT_GUID
    IMPORTING
       ET_DFL        = LT_DFL.
*   Look for the predecessor in docflow
    READ TABLE LT_DFL INTO LS_DFL
      WITH KEY SUC_GUID = IS_BDI-BDI_GUID.
    IF SY-SUBRC = 0.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETDTL'
        EXPORTING
          IV_BDI_GUID = LS_DFL-PRE_GUID
        IMPORTING
          ES_BDI      = ES_BDI
        EXCEPTIONS
          NOTFOUND    = 0
          OTHERS      = 0.
      IF ES_BDH IS REQUESTED.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
          EXPORTING
            IV_BDH_GUID = ES_BDI-BDH_GUID
          IMPORTING
            ES_BDH      = ES_BDH
          EXCEPTIONS
            NOTFOUND    = 0
            OTHERS      = 0.
      ENDIF.
    ENDIF.  " no error message as IPM is NOT using doc flow in diff. inv.
  ENDIF.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
