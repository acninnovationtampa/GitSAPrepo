FUNCTION /1BEA/CRMB_BD_PAR_O_IT_MERGE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_REF_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
*"      INCOMPLETE
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
   LT_PAR         TYPE COMT_PARTNER_WRKT,
   LS_PAR         TYPE COMT_PARTNER_WRK,
   LT_REF_PAR     TYPE COMT_PARTNER_WRKT,
   LT_PAR_BDI     TYPE COMT_PARTNER_WRKT,
   LV_MAND_ERROR  TYPE BEA_BOOLEAN,
   LV_DESCRIPTION TYPE TEXT30,
   LT_BDI_PROC    TYPE COMT_PARTNER_PDP_TAB,
   LS_BDI_PROC    TYPE CRMC_PARTNER_PDP.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN INITIAZITATION
*---------------------------------------------------------------------
  BREAK-POINT ID BEA_PAR.
  PERFORM INIT_BD_PAR_O.
  ES_BDI = IS_BDI.
  CLEAR: ES_BDI-PARSET_GUID.
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'COM_PARTNER_DETERM_PROC_GET_CB'
    EXPORTING
      IV_DETERM_PROC                   = IS_ITC-BDI_PAR_PROC
*     IV_REFRESH_BUFFER                = ' '
    IMPORTING
      ET_DETERM_PROC                   = LT_BDI_PROC
    EXCEPTIONS
      DETERM_PROC_DOES_NOT_EXIST       = 1
      OTHERS                           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING ET_RETURN.
    PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*
  IF is_dli-parset_guid IS NOT INITIAL.
    CALL FUNCTION 'COM_PARTNER_GET'
         EXPORTING
              IV_PARTNERSET_GUID   = IS_DLI-PARSET_GUID
         IMPORTING
              ET_PARTNER           = LT_PAR
         EXCEPTIONS
              PARTNERSET_NOT_FOUND = 1
              PARTNER_NOT_FOUND    = 2
              OTHERS               = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING ET_RETURN.
      PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
      MESSAGE E001(BEA_PAR) RAISING REJECT.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'COM_PARTNER_GET'
       EXPORTING
            IV_PARTNERSET_GUID   = IS_REF_DLI-PARSET_GUID
       IMPORTING
            ET_PARTNER           = LT_REF_PAR
       EXCEPTIONS
            PARTNERSET_NOT_FOUND = 1
            PARTNER_NOT_FOUND    = 2
            OTHERS               = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                 CHANGING ET_RETURN.
    PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  LOOP AT LT_BDI_PROC INTO LS_BDI_PROC
          WHERE DETERM_PROC = IS_ITC-BDI_PAR_PROC
            AND COUNT_LOW  >= 0
            AND COUNT_HIGH >  0.
    READ TABLE LT_PAR INTO LS_PAR
          WITH KEY GUID        = IS_DLI-PARSET_GUID
                   PARTNER_FCT = LS_BDI_PROC-PARTNER_FCT
                   MAINPARTNER = GC_TRUE.
    IF SY-SUBRC = 0.
      PERFORM BD_PARSET_GUID CHANGING ES_BDI-PARSET_GUID
                                      LS_PAR-PARTNER_GUID
                                      LS_PAR-GUID.
      INSERT LS_PAR INTO TABLE LT_PAR_BDI.
    ELSE.
      READ TABLE LT_REF_PAR INTO LS_PAR
            WITH KEY GUID        = IS_REF_DLI-PARSET_GUID
                     PARTNER_FCT = LS_BDI_PROC-PARTNER_FCT
                     MAINPARTNER = GC_TRUE.
      IF SY-SUBRC = 0.
        PERFORM BD_PARSET_GUID CHANGING ES_BDI-PARSET_GUID
                                        LS_PAR-PARTNER_GUID
                                        LS_PAR-GUID.
        INSERT LS_PAR INTO TABLE LT_PAR_BDI.
      ELSE.
        IF LS_BDI_PROC-COUNT_LOW > 0.
          LV_MAND_ERROR = GC_TRUE.
          CALL FUNCTION 'COM_PARTNER_GET_DESCRIPTION_CB'
               EXPORTING
                 IV_PARTNER_FCT = LS_BDI_PROC-PARTNER_FCT
               IMPORTING
                 EV_DESCRIPTION = LV_DESCRIPTION.
          MESSAGE E011(BEA_PAR) WITH LS_BDI_PROC-DETERM_PROC
                  LV_DESCRIPTION INTO GV_DUMMY.
          PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                       CHANGING ET_RETURN.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF LV_MAND_ERROR = GC_TRUE.
    CLEAR ES_BDI-PARSET_GUID.
    PERFORM MSG_BD_PAR_O_2_RETURN CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING INCOMPLETE.
  ENDIF.
  IF NOT LT_PAR_BDI IS INITIAL.
    CALL FUNCTION 'COM_PARTNER_CREATE_OW'
         EXPORTING
              IV_PARTNERSET_GUID     = ES_BDI-PARSET_GUID
              IT_PARTNER_WRK         = LT_PAR_BDI
              IV_REFRESH_ADDRESS_REF = GC_FALSE
              IV_WITHOUT_FILL        = GC_TRUE
         EXCEPTIONS
              ERROR_OCCURRED         = 1
              OTHERS                 = 2.
    IF SY-SUBRC <> 0.
      CLEAR ES_BDI-PARSET_GUID.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING ET_RETURN.
      PERFORM MSG_BD_PAR_O_2_RETURN CHANGING ET_RETURN.
      MESSAGE E001(BEA_PAR) RAISING REJECT.
    ENDIF.
*     derive information for pricing and taxes
    PERFORM DERIVE
      USING
        ES_BDI-PARSET_GUID
        LT_PAR_BDI
      CHANGING
        ES_BDI.
  ELSE.
    CLEAR ES_BDI-PARSET_GUID.
  ENDIF.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
