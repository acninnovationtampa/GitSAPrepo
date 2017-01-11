FUNCTION-POOL /1BEA/CRMB_BD_TXT_O.          "MESSAGE-ID ..
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

INCLUDE BEA_BASICS.
INCLUDE BEA_TXT_CON.
INCLUDE COM_TEXT_CON.

DATA:
    gv_mapping_exit         TYPE REF TO bea_CRMB_BD_txt.

CONSTANTS:
    GC_APPL                 TYPE BEF_APPL VALUE 'CRMB',
    GC_TYPENAME_BDH_WRK
                            TYPE   DDOBJNAME
                            VALUE  '/1BEA/S_CRMB_BDH_WRK',
    GC_TYPENAME_BDI_WRK
                            TYPE   DDOBJNAME
                            VALUE  '/1BEA/S_CRMB_BDI_WRK'.

 LOAD-OF-PROGRAM.
   TRY.
     GET BADI GV_MAPPING_EXIT.
     catch cx_badi_not_implemented.
   ENDTRY.
