FUNCTION-POOL /1BEA/CRMB_BD_PPF_O.          "MESSAGE-ID ..
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
include BEA_BASICS.
**********************************************************************
* Definition of types
**********************************************************************
TYPES:
  BEGIN OF GS_PPF_CONTEXT,
     BDH_GUID  TYPE BEA_BDH_GUID,
     CONTEXT   TYPE REF TO CL_BEA_CONTEXT_PPF,
  END OF GS_PPF_CONTEXT.
*
DATA:
  GV_PRINTER_PROFILE TYPE BEA_PRINTER_PROFILE,
  GT_TDATA           TYPE PPFTTRDATA,
  GT_PPF_CONTEXT     TYPE SORTED TABLE OF GS_PPF_CONTEXT
                               WITH UNIQUE KEY BDH_GUID CONTEXT.
*
