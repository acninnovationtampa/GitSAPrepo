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
    LOOP AT GT_BDH_WRK INTO LS_BDH_WRK.
*--------------------------------------------------------------------
* Get Bill Type
*--------------------------------------------------------------------
      IF    LS_BDH_WRK-UPD_TYPE = GC_INSERT
         OR LS_BDH_WRK-UPD_TYPE = GC_UPDATE.
         PERFORM ADD_BTY_GET USING    LS_BDH_WRK
                           CHANGING LS_BTY_WRK.
      ELSE.
         CLEAR LS_BTY_WRK.
      ENDIF.
      IF ls_bty_wrk-AP_DET_PROC IS INITIAL AND
         ls_bty_wrk-PPF_PROC    IS INITIAL.
           CONTINUE.
      ENDIF.
      CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_DETERMINE'
           EXPORTING
                IS_BDH              = LS_BDH_WRK
                IS_BTY              = LS_BTY_WRK
           EXCEPTIONS
                PARTNER_ERROR       = 0
                OTHERS              = 0.
    ENDLOOP.
  ENDIF.
