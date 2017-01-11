FUNCTION /1BEA/CRMB_DL_PAR_O_COMPRESS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IT_DLI_PART) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
*"--------------------------------------------------------------------
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
* BEGIN DEFINITION
*--------------------------------------------------------------------*
  DATA:
    LS_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_EQUAL     TYPE BEA_BOOLEAN.
*--------------------------------------------------------------------*
* END DEFINITION
*--------------------------------------------------------------------*
*---------------------------------------------------------------------
* BEGIN INITIAZITATION
*---------------------------------------------------------------------
  ES_DLI = IS_DLI.
  PERFORM INIT_DLI_PAR_O.
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*--------------------------------------------------------------------*
* BEGIN SERVICE
*--------------------------------------------------------------------*
*   ckeck, if partnersets are equal
  LOOP AT IT_DLI_PART INTO LS_DLI_WRK.
    CALL FUNCTION 'COM_PARTNER_COMPARE_SETS'
         EXPORTING
              IV_PARTNERSET_GUID_A = LS_DLI_WRK-PARSET_GUID
              IV_PARTNERSET_GUID_B = IS_DLI-PARSET_GUID
         IMPORTING
              EV_SETS_ARE_EQUAL    = LV_EQUAL
         EXCEPTIONS
              SET_NOT_FOUND        = 1
              OTHERS               = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING ET_RETURN.
      PERFORM MSG_DLI_PAR_O_2_RETURN CHANGING ET_RETURN.
      MESSAGE E001(BEA_PAR) RAISING REJECT.
    ENDIF.
    IF LV_EQUAL = GC_TRUE.
*       Remove compressed Partnerset from buffer
      CALL FUNCTION 'COM_PARTNER_REMOVE_SET_OW'
        EXPORTING
          IV_PARTNERSET_GUID        = IS_DLI-PARSET_GUID
        EXCEPTIONS
          SET_NOT_FOUND             = 1
          ERROR_OCCURRED            = 2
          OTHERS                    = 3.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
        PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                     CHANGING ET_RETURN.
        PERFORM MSG_DLI_PAR_O_2_RETURN CHANGING ET_RETURN.
        MESSAGE E001(BEA_PAR) RAISING REJECT.
      ENDIF.
      ES_DLI-PARSET_GUID = LS_DLI_WRK-PARSET_GUID.
      EXIT.
    ENDIF.
  ENDLOOP.
*--------------------------------------------------------------------*
* END SERVICE
*--------------------------------------------------------------------*
ENDFUNCTION.
