FUNCTION-POOL /1BEA/CRMB_DL_ICX_O.          "MESSAGE-ID ..
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
  GC_MAX_BUFFER_SIZE TYPE I VALUE 10,
  GC_APPL            TYPE BEF_APPL VALUE 'CRMB'.

TYPES: BEGIN OF TY_RESULT_BUFFER,
          PATTERN     TYPE /SAPCND/DDPAT,
          ICX_COM     TYPE BEAS_CND_ACS_TOTL,
          RESULT      TYPE /SAPCND/DD_DET_RESULT_T,
       END   OF TY_RESULT_BUFFER.

DATA:
  GT_RESULT_BUFFER TYPE STANDARD TABLE OF TY_RESULT_BUFFER,
  GS_RESULT_BUFFER TYPE TY_RESULT_BUFFER,
  GV_BUFFER_SIZE TYPE I.
