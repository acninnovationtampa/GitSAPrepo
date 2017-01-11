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
  DATA:
    LS_PRCODL_COP_ITC TYPE BEAS_ITC_WRK.

  IF CS_DLI-SRVDOC_SOURCE IS INITIAL.
    CLEAR: CS_DLI-PRIDOC_GUID,
           CS_DLI-PRC_SESSION_ID.

    LS_PRCODL_COP_ITC = US_ITC.
    IF NOT LS_DLI_OLD-PRIDOC_GUID IS INITIAL.
      CALL FUNCTION 'BEA_PRC_O_GET_PROC'
        EXPORTING
          IV_PRIDOC_GUID = LS_DLI_OLD-PRIDOC_GUID
        IMPORTING
          EV_PRIC_PROC   = LS_PRCODL_COP_ITC-DLI_PRC_PROC.
    ENDIF.

    CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_COPY'
      EXPORTING
        IS_DLI           = LS_DLI_OLD
        IS_ITC           = LS_PRCODL_COP_ITC
        IS_DLI_NEW       = CS_DLI
      IMPORTING
        ES_DLI_NEW       = CS_DLI
      EXCEPTIONS
        REJECT           = 1
        OTHERS           = 2.
    IF SY-SUBRC NE 0.
      CS_DLI-INCOMP_ID = GC_INCOMP_FATAL.
      IF NOT LS_DLI_OLD-INCOMP_ID = GC_INCOMP_FATAL.
*   stop processing if pricing returns an error
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                INTO GV_DUMMY.
        CV_RETURNCODE = SY-SUBRC.
        RETURN. "from FORM
      ENDIF.
    ENDIF.
  ENDIF.
