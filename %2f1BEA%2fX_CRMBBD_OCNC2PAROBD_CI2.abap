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
    LV_GUID_PAROBD_CI2 TYPE BEA_PARSET_GUID,
    LS_DLI1_PAROBD_CI2 TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI2_PAROBD_CI2 TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_PAROBD_CI2  TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_BDI_PAROBD_CI2  TYPE /1BEA/T_CRMB_BDI_WRK.
  CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_IT_COPY'
    EXPORTING
      IS_BDI           = US_BDI
      IS_BDI_NEW       = CS_CANCEL_BDI
      IS_ITC           = LS_ITC
    IMPORTING
      ES_BDI_NEW       = CS_CANCEL_BDI
    EXCEPTIONS
      REJECT           = 1
      OTHERS           = 2.
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
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.
  CLEAR LT_BDI_PAROBD_CI2.
  APPEND CS_CANCEL_BDI TO LT_BDI_PAROBD_CI2.
  IF NOT CT_CANCEL_BDI IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_COMPRESS'
         EXPORTING
            IT_BDI            = LT_BDI_PAROBD_CI2
            IT_BDI_PART       = CT_CANCEL_BDI
         IMPORTING
            ET_BDI            = LT_BDI_PAROBD_CI2
         EXCEPTIONS
            REJECT            = 0
            OTHERS            = 0.
    READ TABLE LT_BDI_PAROBD_CI2 INTO CS_CANCEL_BDI INDEX 1.
  ENDIF.
  LOOP AT LT_DLI_COMPRESS INTO LS_DLI1_PAROBD_CI2.
    LV_GUID_PAROBD_CI2 = LS_DLI1_PAROBD_CI2-PARSET_GUID.
    CLEAR LT_DLI_PAROBD_CI2.
    LOOP AT CT_DLI_REOPEN INTO LS_DLI2_PAROBD_CI2
          WHERE DLI_GUID     <> LS_DLI1_PAROBD_CI2-DLI_GUID
            AND DERIV_CATEGORY = LS_DLI1_PAROBD_CI2-DERIV_CATEGORY
            AND LOGSYS = LS_DLI1_PAROBD_CI2-LOGSYS
            AND OBJTYPE = LS_DLI1_PAROBD_CI2-OBJTYPE
            AND SRC_HEADNO = LS_DLI1_PAROBD_CI2-SRC_HEADNO
            AND PARSET_GUID  <> LS_DLI1_PAROBD_CI2-PARSET_GUID
            AND UPD_TYPE  <> GC_DELETE.
      INSERT LS_DLI2_PAROBD_CI2 INTO TABLE LT_DLI_PAROBD_CI2.
    ENDLOOP.
    IF NOT LT_DLI_PAROBD_CI2 IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_COMPRESS'
        EXPORTING
          IS_DLI      = LS_DLI1_PAROBD_CI2
          IT_DLI_PART = LT_DLI_PAROBD_CI2
        IMPORTING
          ES_DLI      = LS_DLI1_PAROBD_CI2
        EXCEPTIONS
          REJECT      = 0
          OTHERS      = 0.
      IF LV_GUID_PAROBD_CI2 <> LS_DLI1_PAROBD_CI2-PARSET_GUID.
        MODIFY CT_DLI_REOPEN FROM LS_DLI1_PAROBD_CI2
                     TRANSPORTING PARSET_GUID
                            WHERE DLI_GUID = LS_DLI1_PAROBD_CI2-DLI_GUID.
      ENDIF.
    ENDIF.
  ENDLOOP.
