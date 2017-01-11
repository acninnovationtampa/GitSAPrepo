FUNCTION /1BEA/CRMB_DL_O_MESSAGE_ADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OBJECT) TYPE  BEF_OBJ OPTIONAL
*"     REFERENCE(IV_CONTAINER) TYPE  BEF_CONTAINER OPTIONAL
*"     REFERENCE(IS_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK OPTIONAL
*"     REFERENCE(IT_RETURN) TYPE  BEAT_RETURN OPTIONAL
*"     REFERENCE(IV_TABIX) TYPE  SYTABIX OPTIONAL
*"     REFERENCE(IS_MSG_VAR) TYPE  BEAS_MESSAGE_VAR OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_MSG_VAR) TYPE  BEAS_MESSAGE_VAR
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
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
  DATA:
     LS_MSG_VAR      TYPE  BEAS_MESSAGE_VAR
    ,LS_BAPI_RETURN  TYPE  BAPIRET2
    ,LV_PARAMETER    TYPE  BAPI_PARAM
    ,LV_ROW          TYPE  SYTABIX
    ,LV_OBJECT_TYPE  TYPE  BEA_OBJECT_TYPE
    ,LV_OBJECT_GUID  TYPE  BEA_OBJECT_GUID
    ,LV_CONTAINER    TYPE  BEF_CONTAINER
    ,LS_RETURN       TYPE  BEAS_RETURN
    ,LS_RTCONTEXT    TYPE  BEAS_RTCONTEXT
    ,LV_REFERENZ_STD TYPE  C
    ,LV_CONTEXT_STD  TYPE  C
    ,LV_IDX          TYPE  SYTABIX
    ,LV_IDX_LOGSYS   TYPE  SYTABIX
    ,LV_IDX_OBJTYP   TYPE  SYTABIX
    ,LV_IDX_HEADNO   TYPE  SYTABIX
    ,LV_IDX_ITEMNO   TYPE  SYTABIX
    ,LV_IDX_P_HEADNO TYPE  SYTABIX
    ,LV_IDX_P_ITEMNO TYPE  SYTABIX
    ,LS_SRC_IID   TYPE  /1BEA/US_CRMB_DL_DLI_SRC_IID
    ,LS_PSRCIID   TYPE  /1BEA/US_CRMB_DL_DLI_PSRCIID
      .
  FIELD-SYMBOLS: <FS_LOGSYS>    TYPE ANY,
                 <FS_OBJTYP>    TYPE ANY,
                 <FS_HEADNO>    TYPE ANY,
                 <FS_ITEMNO>    TYPE ANY,
                 <FS_P_HEADNO>  TYPE ANY,
                 <FS_P_ITEMNO>  TYPE ANY.

  CONSTANTS:
     LC_DLI        TYPE   BEF_CONTAINER  VALUE  'DLI'.

*--------------------------------------------------------------------
* Initialize for default process
*--------------------------------------------------------------------
  IF NOT IS_MSG_VAR IS INITIAL.
    LS_MSG_VAR-MSGV1 = IS_MSG_VAR-MSGV1.
    LS_MSG_VAR-MSGV2 = IS_MSG_VAR-MSGV2.
    LS_MSG_VAR-MSGV3 = IS_MSG_VAR-MSGV3.
    LS_MSG_VAR-MSGV4 = IS_MSG_VAR-MSGV4.
  ELSE.
    LS_MSG_VAR-MSGV1 = SY-MSGV1.
    LS_MSG_VAR-MSGV2 = SY-MSGV2.
    LS_MSG_VAR-MSGV3 = SY-MSGV3.
    LS_MSG_VAR-MSGV4 = SY-MSGV4.
  ENDIF.

  LV_REFERENZ_STD = GC_TRUE.
  LV_CONTEXT_STD = GC_TRUE.
  LV_IDX_LOGSYS = 0.
  LV_IDX_OBJTYP = 0.
  LV_IDX_HEADNO = 3.
  LV_IDX_ITEMNO = 4.
  LV_IDX_P_HEADNO = 3.
  LV_IDX_P_ITEMNO = 4.


*--------------------------------------------------------------------
* Assign reference
*--------------------------------------------------------------------
  IF LV_REFERENZ_STD = GC_TRUE.
    IF IV_CONTAINER = LC_DLI.
      MOVE-CORRESPONDING IS_DLI_WRK TO LS_SRC_IID.
      IF NOT LV_IDX_LOGSYS = 0.
        LV_IDX = LV_IDX_LOGSYS.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_SRC_IID
                                TO <FS_LOGSYS>.
      ENDIF.
      IF NOT LV_IDX_OBJTYP = 0.
        LV_IDX = LV_IDX_OBJTYP.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_SRC_IID
                                TO <FS_OBJTYP>.
      ENDIF.
      IF NOT LV_IDX_HEADNO = 0.
        LV_IDX = LV_IDX_HEADNO.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_SRC_IID
                                TO <FS_HEADNO>.
      ENDIF.
      IF NOT LV_IDX_ITEMNO = 0.
        LV_IDX = LV_IDX_ITEMNO.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_SRC_IID
                                TO <FS_ITEMNO>.
      ENDIF.
    ENDIF.
    IF IV_CONTAINER = LC_DLI.
      MOVE-CORRESPONDING IS_DLI_WRK TO LS_PSRCIID.
      IF NOT LV_IDX_P_HEADNO = 0.
        LV_IDX = LV_IDX_P_HEADNO.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_PSRCIID
                                TO <FS_P_HEADNO>.
      ENDIF.
      IF NOT LV_IDX_P_ITEMNO = 0.
        LV_IDX = LV_IDX_P_ITEMNO.
        ASSIGN COMPONENT LV_IDX OF STRUCTURE LS_PSRCIID
                                TO <FS_P_ITEMNO>.
      ENDIF.
    ENDIF.

*--------------------------------------------------------------------
* Displace headno and itemno of billingduelist
*--------------------------------------------------------------------
    IF LS_MSG_VAR-MSGV1 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV1 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV1 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV1 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV1.
    ELSEIF LS_MSG_VAR-MSGV1 = GC_P_DLI_P_HEADNO AND
       <FS_P_HEADNO> IS ASSIGNED.
      WRITE <FS_P_HEADNO> TO LS_MSG_VAR-MSGV1 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV1 = GC_P_DLI_P_ITEMNO AND
       <FS_P_ITEMNO> IS ASSIGNED.
      WRITE <FS_P_ITEMNO> TO LS_MSG_VAR-MSGV1 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV1.
    ENDIF.
    IF LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV2 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV2.
    ELSEIF LS_MSG_VAR-MSGV2 = GC_P_DLI_P_HEADNO AND
       <FS_P_HEADNO> IS ASSIGNED.
      WRITE <FS_P_HEADNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV2 = GC_P_DLI_P_ITEMNO AND
       <FS_P_ITEMNO> IS ASSIGNED.
      WRITE <FS_P_ITEMNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV2.
    ENDIF.
    IF LS_MSG_VAR-MSGV3 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV3 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV3.
    ELSEIF LS_MSG_VAR-MSGV3 = GC_P_DLI_P_HEADNO AND
       <FS_P_HEADNO> IS ASSIGNED.
      WRITE <FS_P_HEADNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV3 = GC_P_DLI_P_ITEMNO AND
       <FS_P_ITEMNO> IS ASSIGNED.
      WRITE <FS_P_ITEMNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV3.
    ENDIF.
    IF LS_MSG_VAR-MSGV4 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV4 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV4.
    ELSEIF LS_MSG_VAR-MSGV4 = GC_P_DLI_P_HEADNO AND
       <FS_P_HEADNO> IS ASSIGNED.
      WRITE <FS_P_HEADNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV4 = GC_P_DLI_P_ITEMNO AND
       <FS_P_ITEMNO> IS ASSIGNED.
      WRITE <FS_P_ITEMNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV4.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------
* Create message-context
*--------------------------------------------------------------------
  IF LV_CONTEXT_STD = GC_TRUE.
    IF IV_CONTAINER = LC_DLI.
      LV_PARAMETER = GC_BAPI_PAR_DLI.
      LV_OBJECT_TYPE = GC_DLI.
      LV_OBJECT_GUID = IS_DLI_WRK-DLI_GUID.
      LV_CONTAINER = IV_CONTAINER.
      LV_ROW  = IV_TABIX.
      IF <FS_HEADNO> IS ASSIGNED.
        LS_RTCONTEXT-SRC_HEADNO = <FS_HEADNO>.
      ENDIF.
      IF <FS_ITEMNO> IS ASSIGNED.
        LS_RTCONTEXT-SRC_ITEMNO = <FS_ITEMNO>.
      ENDIF.
      IF <FS_OBJTYP> IS ASSIGNED.
        LS_RTCONTEXT-OBJTYPE = <FS_OBJTYP>.
      ENDIF.
      IF <FS_LOGSYS> IS ASSIGNED.
        LS_RTCONTEXT-LOGSYS = <FS_LOGSYS>.
      ENDIF.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------
* complete message-var if requested
*--------------------------------------------------------------------
  IF ES_MSG_VAR IS REQUESTED.
    ES_MSG_VAR-MSGV1 = LS_MSG_VAR-MSGV1.
    ES_MSG_VAR-MSGV2 = LS_MSG_VAR-MSGV2.
    ES_MSG_VAR-MSGV3 = LS_MSG_VAR-MSGV3.
    ES_MSG_VAR-MSGV4 = LS_MSG_VAR-MSGV4.
  ENDIF.
*--------------------------------------------------------------------
* Add completed message into Return-table if requested
*--------------------------------------------------------------------
  IF ET_RETURN IS REQUESTED.
    IF NOT IT_RETURN IS INITIAL.
      ET_RETURN = IT_RETURN.
    ENDIF.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        TYPE      = SY-MSGTY
        CL        = SY-MSGID
        NUMBER    = SY-MSGNO
        PAR1      = LS_MSG_VAR-MSGV1
        PAR2      = LS_MSG_VAR-MSGV2
        PAR3      = LS_MSG_VAR-MSGV3
        PAR4      = LS_MSG_VAR-MSGV4
        PARAMETER = LV_PARAMETER
        ROW       = LV_ROW
      IMPORTING
        RETURN    = LS_BAPI_RETURN.

    MOVE-CORRESPONDING LS_BAPI_RETURN TO LS_RETURN.
    MOVE LV_OBJECT_TYPE TO LS_RETURN-OBJECT_TYPE.
    MOVE LV_OBJECT_GUID TO LS_RETURN-OBJECT_GUID.
    MOVE-CORRESPONDING LS_RTCONTEXT TO LS_RETURN.
    MOVE LV_CONTAINER TO LS_RETURN-CONTAINER.
    APPEND LS_RETURN TO ET_RETURN.
  ENDIF.

  ENDFUNCTION.
