FUNCTION /1BEA/CRMB_BD_PAR_O_COMPRESS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IT_BDI_PART) TYPE  /1BEA/T_CRMB_BDI_WRK
*"  EXPORTING
*"     REFERENCE(ET_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
* Time  : 13:53:02
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_BDI         TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_BDI_PART    TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_PART    TYPE /1BEA/T_CRMB_BDI_WRK,
    LV_EQUAL       TYPE BEA_BOOLEAN.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN INITIAZITATION
*---------------------------------------------------------------------
  PERFORM INIT_BD_PAR_O.
  ET_BDI = IT_BDI.
  LT_BDI_PART = IT_BDI_PART.
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
*   ckeck, if partnersets are equal
  LOOP AT ET_BDI INTO LS_BDI.
    LV_EQUAL = GC_FALSE.
    LOOP AT LT_BDI_PART INTO LS_BDI_PART.
      CALL FUNCTION 'COM_PARTNER_COMPARE_SETS'
           EXPORTING
                IV_PARTNERSET_GUID_A = LS_BDI_PART-PARSET_GUID
                IV_PARTNERSET_GUID_B = LS_BDI-PARSET_GUID
           IMPORTING
                EV_SETS_ARE_EQUAL    = LV_EQUAL
           EXCEPTIONS
                SET_NOT_FOUND        = 1
                OTHERS               = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
        PERFORM msg_add using space space space space
                        CHANGING ET_RETURN.
        PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
        MESSAGE E001(BEA_PAR) RAISING REJECT.
      ENDIF.
      IF LV_EQUAL = GC_TRUE.
*       Remove compressed Partnerset from buffer
        CALL FUNCTION 'COM_PARTNER_REMOVE_MULTI_OB'
             EXPORTING
                  IV_PARTNERSET_GUID = LS_BDI-PARSET_GUID
             EXCEPTIONS
                  ERROR_OCCURRED     = 1
                  OTHERS             = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
          PERFORM msg_add using space space space space
                       CHANGING ET_RETURN.
          PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
          MESSAGE E001(BEA_PAR) RAISING REJECT.
        ENDIF.
        LS_BDI-PARSET_GUID = LS_BDI_PART-PARSET_GUID.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_EQUAL = GC_TRUE.
      MODIFY ET_BDI FROM LS_BDI TRANSPORTING PARSET_GUID.
    ELSE.
      IF SY-SUBRC = 0.
        INSERT LS_BDI INTO TABLE LT_BDI_PART.
      ENDIF.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
