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
* Close Pricing Session
  DATA: LT_PRCUBD_RFR_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID.
IF LV_OKCODE = GC_PREV OR
   LV_OKCODE = GC_NEXT.
  IF NOT GS_SRV_PREPARED-PRC IS INITIAL.
     IF NOT GV_PRC_SESSION_ID IS INITIAL.
         REFRESH LT_PRCUBD_RFR_PRC_SESSION_ID.
         APPEND GV_PRC_SESSION_ID TO LT_PRCUBD_RFR_PRC_SESSION_ID.
         CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
            EXPORTING
               IT_SESSION_ID = LT_PRCUBD_RFR_PRC_SESSION_ID.
       CLEAR GV_PRC_SESSION_ID.
     ENDIF.
     CALL FUNCTION 'BEA_PRC_U_FREE'.
  ENDIF.
ENDIF.
