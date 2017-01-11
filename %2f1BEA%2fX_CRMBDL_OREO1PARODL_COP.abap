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
* for lean billing Partner will be inherited from main item
  IF CS_DLI-DERIV_CATEGORY <> GC_DERIV_LEANBILLING AND
     CS_DLI-DERIV_CATEGORY <> GC_DERIV_CONDITION.
    CLEAR CS_DLI-PARSET_GUID.
    CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_COPY'
      EXPORTING
        IS_DLI           = LS_DLI_OLD
        IS_ITC           = US_ITC
        IS_DLI_NEW       = CS_DLI
      IMPORTING
        ES_DLI_NEW       = CS_DLI
      EXCEPTIONS
        REJECT           = 1
        OTHERS           = 2.
    IF SY-SUBRC NE 0.
* stop processing if partners return an error
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CV_RETURNCODE = SY-SUBRC.
      RETURN. "from FORM
    ENDIF.
  ENDIF.
