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
    IF LV_EQUAL = GC_TRUE. "matching head has been found
      CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_HD_DELETE'
        EXPORTING
          IS_BDH          = CS_BDH_WRK
        EXCEPTIONS
          REJECT          = 0
          OTHERS          = 0.
    ENDIF.
