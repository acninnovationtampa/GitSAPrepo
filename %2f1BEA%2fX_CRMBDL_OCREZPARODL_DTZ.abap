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
*--------------------------------------------------------------------*
*      Form  Partner_Determine
*--------------------------------------------------------------------*
FORM PARODL_DTZ_PARTNER_DETERMINE
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    US_ITC        TYPE BEAS_ITC_WRK
  CHANGING
    CT_PAR_COM    TYPE BEAT_PAR_COM
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SYSUBRC.

  CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DETERMINE'
    EXPORTING
      IS_SRC_DLI = US_DLI_WRK
      IS_ITC     = US_ITC
    IMPORTING
      ET_PAR_COM = CT_PAR_COM
      ET_RETURN  = CT_RETURN
    EXCEPTIONS
      REJECT     = 1
      OTHERS     = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
  ENDIF.
ENDFORM.                 " Partner_Determine
