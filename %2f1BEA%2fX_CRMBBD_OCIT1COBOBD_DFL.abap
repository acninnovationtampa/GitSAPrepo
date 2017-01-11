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
DATA:
  LS_COBOBD_DFL           TYPE BEAS_DFL_WRK.

CS_BDI_WRK-REVERSED_BDI_GUID = US_BDI_TC_WRK-BDI_GUID.

LS_COBOBD_DFL-PRE_GUID    = CS_BDI_WRK-REVERSED_BDI_GUID.
LS_COBOBD_DFL-SUC_GUID    = CS_BDI_WRK-BDI_GUID.
LS_COBOBD_DFL-PRE_OBJTYPE = GC_BOR_BDI.
LS_COBOBD_DFL-SUC_OBJTYPE = GC_BOR_BDI.
LS_COBOBD_DFL-APPL        = GC_APPL.
LS_COBOBD_DFL-UPD_TYPE    = GC_INSERT.

CALL FUNCTION 'BEA_DFL_O_CREATE'
  EXPORTING
    IS_DFL        = LS_COBOBD_DFL.

GV_WITH_DOCFLOW = GC_TRUE.
