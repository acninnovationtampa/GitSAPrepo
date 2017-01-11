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
        CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_COMPARE'
          EXPORTING
            IS_BDH_NEW = CS_BDH_WRK
            IS_BDH     = LS_BDH_WRK
          IMPORTING
            EV_EQUAL   = LV_EQUAL.
