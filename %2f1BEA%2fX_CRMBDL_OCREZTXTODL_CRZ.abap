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
 FORM TXTODL_CRZ_TEXT_FILL
   USING
     UT_TEXT       TYPE COMT_TEXT_TEXTDATA_T
     US_ITC        TYPE BEAS_ITC_WRK
   CHANGING
     CS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
     CT_RETURN     TYPE BEAT_RETURN
     CV_RETURNCODE TYPE SYSUBRC.

   CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_CREATE'
     EXPORTING
       IS_DLI    = CS_DLI_WRK
       IS_ITC    = US_ITC
       IT_TEXT   = UT_TEXT
     IMPORTING
       ES_DLI    = CS_DLI_WRK
       ET_RETURN = CT_RETURN
     EXCEPTIONS
       REJECT    = 1
       OTHERS    = 2.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
       EXPORTING
         IV_CONTAINER   = 'DLI'
         IS_DLI_WRK     = CS_DLI_WRK
         IT_RETURN      = CT_RETURN
       IMPORTING
         ET_RETURN      = CT_RETURN.
   ENDIF.
 ENDFORM.
