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
    LS_BDH_TXT           TYPE /1BEA/S_CRMB_BDH_WRK.

    CLEAR CS_CANCEL_BDH-TEXT_ERROR.
    CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_CREATE'
      EXPORTING
        IS_BDH     = CS_CANCEL_BDH
        IS_BTY     = US_BTY
      EXCEPTIONS
        REJECT     = 1
        INCOMPLETE = 2
        OTHERS     = 3.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      IF UV_CAUSE = GC_CAUSE_REJECT OR
         UV_CAUSE = GC_CAUSE_REJ_NEW.
        LS_BDH_TXT = CS_BDH.
        CV_RETURNCODE = 1.
      ELSE.
        LS_BDH_TXT = CS_CANCEL_BDH.
      ENDIF.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDH'
          IS_BDH         = LS_BDH_TXT.
      CS_CANCEL_BDH-TEXT_ERROR = GC_TRUE.
    ENDIF. "sy-subrc IS INITIAL
