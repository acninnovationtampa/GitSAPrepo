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
*--------------------------------------------------------------------
* PPF
*--------------------------------------------------------------------
  IF IV_NO_PPF IS INITIAL.
    LOOP AT    GT_BDH_WRK
         INTO  LS_BDH_WRK
         WHERE UPD_TYPE = GC_INSERT.
       CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_RENAME'
         EXPORTING
           IS_BDH              = LS_BDH_WRK.
    ENDLOOP.
  ENDIF.
