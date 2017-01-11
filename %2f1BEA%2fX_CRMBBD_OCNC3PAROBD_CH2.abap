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
    CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_HD_COPY'
      EXPORTING
        IS_BDH     = CS_BDH
        IS_BDH_NEW = CS_CANCEL_BDH
        IS_BTY     = US_BTY
      IMPORTING
        ES_BDH_NEW = CS_CANCEL_BDH
      EXCEPTIONS
        REJECT     = 1
        OTHERS     = 2.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
       CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
         EXPORTING
           IV_OBJECT      = 'BD'
           IV_CONTAINER   = 'BDH'
           IS_BDH         = CS_BDH.
      CV_RETURNCODE = 1.
      RETURN.
    ENDIF. "sy-subrc IS INITIAL
