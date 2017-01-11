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
  CLEAR CS_CANCEL_BDI-TEXT_ERROR.
  CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_CREATE'
    EXPORTING
      IS_BDI     = CS_CANCEL_BDI
      IS_ITC     = LS_ITC
    EXCEPTIONS
      REJECT     = 1
      INCOMPLETE = 2
      OTHERS     = 3.
  IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDI'
          IS_BDH         = US_BDH
          IS_BDI         = US_BDI.
    CS_CANCEL_BDI-TEXT_ERROR = GC_TRUE.
  ENDIF.
