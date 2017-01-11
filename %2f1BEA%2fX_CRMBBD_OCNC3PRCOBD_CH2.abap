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
   LS_BDI_PRCOBD_CH2    TYPE /1BEA/S_CRMB_BDI_WRK,
   LS_BDH_PRC           TYPE /1BEA/S_CRMB_BDH_WRK,
   LT_PRCOBD_CH2_RETURN TYPE BEAT_RETURN.
 CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_HD_CREATE'
   EXPORTING
     IS_BDH          = CS_CANCEL_BDH
     IV_EXTENDED_LOG = GC_TRUE
   IMPORTING
     ES_BDH          = CS_CANCEL_BDH
   EXCEPTIONS
     REJECT = 1.
 IF NOT SY-SUBRC IS INITIAL.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
             INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDH'
          IS_BDH         = CS_BDH.
   CS_CANCEL_BDH-PRICING_ERROR = GC_PRC_ERR_F.
   CV_RETURNCODE = 1.
 ENDIF.
 IF CV_RETURNCODE IS INITIAL.
   CLEAR CS_CANCEL_BDH-NET_VALUE.
   CLEAR CS_CANCEL_BDH-TAX_VALUE.
   CLEAR LT_PRCOBD_CH2_RETURN.
   CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_COPY'
     EXPORTING
       IS_BDH              = CS_BDH
       IT_BDI              = LT_CANCELLED_BDI
       IS_BDH_CANCEL       = CS_CANCEL_BDH
       IT_BDI_CANCEL       = CT_CANCEL_BDI
       IV_EXTENDED_LOG     = GC_TRUE
     IMPORTING
       ES_BDH_CANCEL       = CS_CANCEL_BDH
       ET_BDI_CANCEL       = CT_CANCEL_BDI
       ET_RETURN           = LT_PRCOBD_CH2_RETURN
     EXCEPTIONS
       REJECT              = 1
       OTHERS              = 2 .
   IF NOT SY-SUBRC IS INITIAL.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
             INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
       EXPORTING
         IV_OBJECT      = 'BD'
         IV_CONTAINER   = 'BDH'
         IS_BDH         = CS_BDH
         IT_RETURN      = LT_PRCOBD_CH2_RETURN.
     CV_RETURNCODE = 1.
   ELSEIF NOT LT_PRCOBD_CH2_RETURN IS INITIAL.
     IF UV_CAUSE = GC_CAUSE_REJECT OR
        UV_CAUSE = GC_CAUSE_REJ_NEW.
       MESSAGE E119(BEA_PRC) INTO GV_DUMMY.
       LS_BDH_PRC = CS_BDH.
       CV_RETURNCODE = 1.
     ELSE.
       MESSAGE W119(BEA_PRC) INTO GV_DUMMY.
       LS_BDH_PRC = CS_CANCEL_BDH.
     ENDIF.
     CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
       EXPORTING
         IV_OBJECT      = 'BD'
         IV_CONTAINER   = 'BDH'
         IS_BDH         = LS_BDH_PRC
         IT_RETURN      = LT_PRCOBD_CH2_RETURN.
   ENDIF.
   IF CV_RETURNCODE IS INITIAL.
     LOOP AT CT_CANCEL_BDI INTO LS_BDI_PRCOBD_CH2.
       ADD LS_BDI_PRCOBD_CH2-NET_VALUE TO CS_CANCEL_BDH-NET_VALUE.
       ADD LS_BDI_PRCOBD_CH2-TAX_VALUE TO CS_CANCEL_BDH-TAX_VALUE.
     ENDLOOP.
   ENDIF.
 ENDIF.
