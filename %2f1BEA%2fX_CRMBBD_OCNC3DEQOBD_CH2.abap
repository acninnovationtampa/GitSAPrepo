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
  LV_SESSION_ID    TYPE BEA_PRC_SESSION_ID,
  LT_SESSION_ID    TYPE BEAT_PRC_SESSION_ID.
 IF CV_RETURNCODE IS NOT INITIAL.
*  Dequeue the created price document lock
   IF CS_CANCEL_BDH-PRC_SESSION_ID IS NOT INITIAL.
     LV_SESSION_ID = CS_CANCEL_BDH-PRC_SESSION_ID.
     CLEAR LT_SESSION_ID.
     INSERT LV_SESSION_ID INTO TABLE LT_SESSION_ID.
     CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
       EXPORTING
         it_session_id       = LT_SESSION_ID.
   ENDIF.
 ENDIF.
