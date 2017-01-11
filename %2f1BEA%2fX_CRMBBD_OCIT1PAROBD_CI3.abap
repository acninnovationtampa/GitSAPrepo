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
  CLEAR CS_BDI_WRK-PARSET_GUID.
  CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_IT_COPY'
    EXPORTING
      IS_BDI           = US_BDI_TC_WRK
      IS_BDI_NEW       = CS_BDI_WRK
      IS_ITC           = US_ITC
    IMPORTING
      ES_BDI_NEW       = CS_BDI_WRK
   EXCEPTIONS
     REJECT           = 1
     OTHERS           = 2.
  IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
       PERFORM MSG_ADD USING GC_BDI US_BDI_TC_WRK-BDI_GUID
                             SPACE SPACE
                       CHANGING GT_RETURN.
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.
