FUNCTION /1BEA/CRMB_BD_O_ENQUEUE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BDH_GUID) TYPE  BEA_BDH_GUID
*"  EXPORTING
*"     REFERENCE(ES_RETURN) TYPE  BEAS_RETURN
*"     REFERENCE(EV_ALREADY_LOCKED) TYPE  BEA_BOOLEAN
*"     REFERENCE(EV_LOCK_FAILED) TYPE  BEA_BOOLEAN
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
* Time  : 13:52:50
*
*======================================================================
  DATA:
    LS_BDH_WRK        TYPE /1BEA/S_CRMB_BDH_WRK,
    LV_USER           TYPE SYMSGV,
    LV_SUBRC          TYPE SYSUBRC,
    LS_ENQUEUE_BDH    TYPE TY_ENQUEUE_BDH_S.

  CHECK NOT IV_BDH_GUID IS INITIAL.

  READ TABLE GT_ENQUEUE_BDH WITH KEY
      APPL = GC_APPL
      BDH_GUID = IV_BDH_GUID
      TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    EV_ALREADY_LOCKED = GC_TRUE.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_E_BEA_BD'
    EXPORTING
      CLIENT         = SY-MANDT
      BDH_GUID       = IV_BDH_GUID
      APPL           = GC_APPL
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  LV_SUBRC = SY-SUBRC.
  IF LV_SUBRC NE 0.
    LV_USER = SY-MSGV1.
    CASE LV_SUBRC.
      WHEN 1.
        EV_ALREADY_LOCKED = GC_TRUE.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
          EXPORTING
            IV_BDH_GUID = IV_BDH_GUID
          IMPORTING
            ES_BDH      = LS_BDH_WRK
          EXCEPTIONS
            NOTFOUND    = 1
            OTHERS      = 2.
        IF SY-SUBRC NE 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO GV_DUMMY.
        ELSE.
          MESSAGE E223(BEA)
             WITH LS_BDH_WRK-HEADNO_EXT LV_USER INTO GV_DUMMY.
        ENDIF.
      WHEN OTHERS.
        EV_LOCK_FAILED = GC_TRUE.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
          INTO GV_DUMMY.
    ENDCASE.
    PERFORM MSG_LINE_ADD USING GC_BDH IV_BDH_GUID
      CHANGING ES_RETURN.
  ENDIF.
  IF LV_SUBRC = 0.
    LS_ENQUEUE_BDH-BDH_GUID = IV_BDH_GUID.
    LS_ENQUEUE_BDH-APPL = GC_APPL.
    INSERT LS_ENQUEUE_BDH INTO TABLE GT_ENQUEUE_BDH.
  ENDIF.
ENDFUNCTION.
*---------------------------------------------------------------------
*      FORM  MSG_LINE_ADD
*---------------------------------------------------------------------
FORM MSG_LINE_ADD
  USING
    CV_OBJ_TYPE TYPE BEA_OBJECT_TYPE
    CV_OBJ_ID   TYPE BEA_OBJECT_GUID
  CHANGING
    CS_RETURN   TYPE BEAS_RETURN.
  DATA:
    LS_RETURN TYPE BAPIRET2.
   CALL FUNCTION 'BALW_BAPIRETURN_GET2'
     EXPORTING
       TYPE   = SY-MSGTY
       CL     = SY-MSGID
       NUMBER = SY-MSGNO
       PAR1   = SY-MSGV1
       PAR2   = SY-MSGV2
       PAR3   = SY-MSGV3
       PAR4   = SY-MSGV4
     IMPORTING
       RETURN = LS_RETURN.
   MOVE-CORRESPONDING LS_RETURN TO CS_RETURN.
   CS_RETURN-OBJECT_TYPE = CV_OBJ_TYPE.
   CS_RETURN-OBJECT_GUID = CV_OBJ_ID.
ENDFORM.
