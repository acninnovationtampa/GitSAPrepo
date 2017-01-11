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
*-----------------------------------------------------------------*
*     FORM ITC_DERIVE
*-----------------------------------------------------------------*
* Derive item category from data provided by the source application
* for check of and processing control of required derivation
*-----------------------------------------------------------------*
FORM ITC_DERIVE
  USING
    US_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
    UV_PATTERN    TYPE  /SAPCND/DDPAT
    UV_DFIELD     TYPE FIELDNAME
  CHANGING
    CS_ITC_WRK    TYPE BEAS_ITC_WRK
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SYSUBRC.
  DATA:
    LS_DLI_WRK          TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_MSGV             TYPE SYMSGV.

  LS_DLI_WRK = US_DLI_WRK.
  CALL FUNCTION '/1BEA/CRMB_DL_ICX_O_DERIVE'
    EXPORTING
       IS_DLI     = LS_DLI_WRK
       IS_ITC     = CS_ITC_WRK
       IV_PATTERN = UV_PATTERN
       IV_DFIELD  = UV_DFIELD
     IMPORTING
       ES_DLI     = LS_DLI_WRK.
  IF NOT LS_DLI_WRK-ITEM_CATEGORY IS INITIAL.
    CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
      EXPORTING
        IV_APPL          = GC_APPL
        IV_ITC           = LS_DLI_WRK-ITEM_CATEGORY
      IMPORTING
        ES_ITC_WRK       = CS_ITC_WRK
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.
    IF SY-SUBRC <> 0.
      CV_RETURNCODE = SY-SUBRC.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = LS_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
    ENDIF.
  ELSE.
    IF GV_DRV_LOG = GC_TRUE.
      MESSAGE W145(BEA) WITH UV_PATTERN US_DLI_WRK-ITEM_CATEGORY
                        INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
    ENDIF.
  ENDIF.
ENDFORM.                    "ITC_DERIVE
