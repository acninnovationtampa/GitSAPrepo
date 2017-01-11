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
  LOOP AT CT_BDI_WRK INTO LS_BDI_WRK.
    CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_CREATE'
         EXPORTING
            IS_DLI     = US_DLI_WRK
            IS_BDI     = LS_BDI_WRK
            IS_ITC     = US_ITC_WRK
         IMPORTING
*           ES_BDI           =
            ET_RETURN        = LT_RETURN
         EXCEPTIONS
            REJECT           = 1
            INCOMPLETE       = 1
            OTHERS           = 1.
    IF SY-SUBRC Ne 0.
      LS_BDI_WRK-TEXT_ERROR = GC_TRUE.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'BD'
          IV_CONTAINER   = 'BDH'
          IS_BDH         = CS_BDH_WRK
          IT_RETURN      = LT_RETURN.
      MODIFY CT_BDI_WRK FROM LS_BDI_WRK.
    ENDIF.
  ENDLOOP.
