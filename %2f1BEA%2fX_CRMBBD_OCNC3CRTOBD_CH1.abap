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
 CALL FUNCTION '/1BEA/CRMB_BD_CRT_O_IT_COPY'
   EXPORTING
     IS_BDH              = CS_BDH
     IS_BDH_CANCEL       = CS_CANCEL_BDH
     IT_BDI_CANCEL       = CT_CANCEL_BDI
   EXCEPTIONS
     REJECT              = 1
     OTHERS              = 2 .
 IF NOT SY-SUBRC IS INITIAL.
   IF CS_CANCEL_BDH-PRICING_ERROR IS INITIAL.
     CS_CANCEL_BDH-PRICING_ERROR = GC_PRC_ERR_C.
   ENDIF.
   IF CS_BDH-PRICING_ERROR IS INITIAL.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
             INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
       EXPORTING
         IV_OBJECT      = 'BD'
         IV_CONTAINER   = 'BDH'
         IS_BDH         = CS_BDH.
     CV_RETURNCODE = 1.
   ENDIF.
 ENDIF. "sy-subrc IS INITIAL
