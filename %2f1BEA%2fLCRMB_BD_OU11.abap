FUNCTION /1BEA/CRMB_BD_O_MESSAGE_ADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OBJECT) TYPE  BEF_OBJ
*"     REFERENCE(IV_CONTAINER) TYPE  BEF_CONTAINER
*"     REFERENCE(IS_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK OPTIONAL
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK OPTIONAL
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK OPTIONAL
*"     REFERENCE(IT_RETURN) TYPE  BEAT_RETURN OPTIONAL
*"     REFERENCE(IV_DLI_GUID) TYPE  BEA_DLI_GUID OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  BEAS_RETURN
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
     LS_MSG_VAR      TYPE  BEAS_MESSAGE_VAR
    ,LS_BAPI_RETURN  TYPE  BAPIRET2
    ,LV_PARAMETER    TYPE  BAPI_PARAM
    ,LV_OBJECT_TYPE  TYPE  BEA_OBJECT_TYPE
    ,LV_OBJECT_GUID  TYPE  BEA_OBJECT_GUID
    ,LS_RETURN       TYPE  BEAS_RETURN
    ,LS_RTCONTEXT    TYPE  BEAS_RTCONTEXT
    ,LV_REFERENZ_STD TYPE  C
    ,LV_CONTEXT_STD  TYPE  C
    ,LV_IDX          TYPE  SYTABIX
    ,LV_IDX_LOGSYS   TYPE  SYTABIX
    ,LV_IDX_OBJTYP   TYPE  SYTABIX
    ,LV_IDX_HEADNO   TYPE  SYTABIX
    ,LV_IDX_ITEMNO   TYPE  SYTABIX
    ,LS_SRC_IID   TYPE  /1BEA/US_CRMB_DL_DLI_SRC_IID
      .
  FIELD-SYMBOLS: <FS_LOGSYS>  TYPE ANY,
                 <FS_OBJTYP>  TYPE ANY,
                 <FS_HEADNO>  TYPE ANY,
                 <FS_ITEMNO>  TYPE ANY.

  CONSTANTS:
     LC_DLI        TYPE   BEF_CONTAINER  VALUE  'DLI',
     LC_BDH        TYPE   BEF_CONTAINER  VALUE  'BDH',
     LC_BDI        TYPE   BEF_CONTAINER  VALUE  'BDI'.

*--------------------------------------------------------------------
* Initialize for default process
*--------------------------------------------------------------------
  MOVE  SY-MSGV1 TO LS_MSG_VAR-MSGV1.
  MOVE  SY-MSGV2 TO LS_MSG_VAR-MSGV2.
  MOVE  SY-MSGV3 TO LS_MSG_VAR-MSGV3.
  MOVE  SY-MSGV4 TO LS_MSG_VAR-MSGV4.

  LV_REFERENZ_STD = GC_TRUE.
  LV_CONTEXT_STD = GC_TRUE.
  LV_IDX_LOGSYS = 1.
  LV_IDX_OBJTYP = 2.
  LV_IDX_HEADNO = 3.
  LV_IDX_ITEMNO = 4.


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
    ENDIF.
    IF LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV2 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV2 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV2.
    ENDIF.
    IF LS_MSG_VAR-MSGV3 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV3 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV3 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV3.
    ENDIF.
    IF LS_MSG_VAR-MSGV4 = GC_P_DLI_HEADNO AND
       <FS_HEADNO> IS ASSIGNED.
      WRITE <FS_HEADNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
    ELSEIF LS_MSG_VAR-MSGV4 = GC_P_DLI_ITEMNO AND
       <FS_ITEMNO> IS ASSIGNED.
      WRITE <FS_ITEMNO> TO LS_MSG_VAR-MSGV4 NO-ZERO.
      CONDENSE LS_MSG_VAR-MSGV4.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------
* Create message-context
*--------------------------------------------------------------------
  IF LV_CONTEXT_STD = GC_TRUE.
    CLEAR:
      LV_PARAMETER,
      LS_RTCONTEXT.
      LS_RTCONTEXT-APPL = 'CRMB'.
      LS_RTCONTEXT-OBJECT = IV_OBJECT.
      LS_RTCONTEXT-CONTAINER = IV_CONTAINER.
    IF IV_CONTAINER = LC_DLI.
      LV_PARAMETER = GC_BAPI_PAR_DLI.
      LV_OBJECT_TYPE = GC_DLI.
      IF NOT IV_DLI_GUID IS INITIAL.
        LV_OBJECT_GUID = IV_DLI_GUID.
      ELSE.
        LV_OBJECT_GUID = IS_DLI_WRK-DLI_GUID.
      ENDIF.
      LS_RTCONTEXT-OBJECT_GUID_C = IS_DLI_WRK-DLI_GUID.
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
    ELSEIF IV_CONTAINER = LC_BDI.
      LV_OBJECT_TYPE = GC_BDI.
      LV_OBJECT_GUID = IS_BDI-BDI_GUID.
      LS_RTCONTEXT-SRC_HEADNO = IS_BDH-HEADNO_EXT.
      LS_RTCONTEXT-SRC_ITEMNO = IS_BDI-ITEMNO_EXT.
      LS_RTCONTEXT-OBJTYPE = GC_BOR_BDI.
      LS_RTCONTEXT-LOGSYS = IS_BDH-LOGSYS.
    ELSEIF IV_CONTAINER = LC_BDH.
      LV_OBJECT_TYPE = GC_BDH.
      LV_OBJECT_GUID = IS_BDH-BDH_GUID.
      LS_RTCONTEXT-SRC_HEADNO = IS_BDH-HEADNO_EXT.
      LS_RTCONTEXT-OBJECT_GUID_C = IS_BDH-BDH_GUID.
      IF NOT IS_BDH-OBJTYPE IS INITIAL.
        LS_RTCONTEXT-OBJTYPE = IS_BDH-OBJTYPE.
      ELSE.
        LS_RTCONTEXT-OBJTYPE = GC_BOR_BDH.
      ENDIF.
        LS_RTCONTEXT-LOGSYS = IS_BDH-LOGSYS.
    ENDIF.
  ENDIF.


*--------------------------------------------------------------------
* Add completed message into global table
*--------------------------------------------------------------------
  CLEAR LS_RETURN.

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
*     ROW       = LV_ROW
    IMPORTING
      RETURN    = LS_BAPI_RETURN.

  MOVE-CORRESPONDING LS_BAPI_RETURN TO LS_RETURN.
  MOVE LV_OBJECT_TYPE TO LS_RETURN-OBJECT_TYPE.
  MOVE LV_OBJECT_GUID TO LS_RETURN-OBJECT_GUID.
  MOVE-CORRESPONDING LS_RTCONTEXT TO LS_RETURN.

  IF es_return IS REQUESTED.
*--- Export ls_return or store it into global table
    es_return = ls_return.
  ELSE.
*--- Add message into global table
    APPEND ls_return TO gt_return.
  ENDIF.

  IF GS_CRP IS INITIAL  AND
     NOT IT_RETURN IS INITIAL.
    LOOP AT IT_RETURN INTO LS_RETURN.
      MOVE-CORRESPONDING LS_RTCONTEXT TO LS_RETURN.
      APPEND LS_RETURN TO GT_RETURN.
    ENDLOOP.
  ENDIF.

  ENDFUNCTION.
