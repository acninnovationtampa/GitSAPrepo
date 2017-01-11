FUNCTION /1BEA/CRMB_DL_O_DOCFL_BDI_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK OPTIONAL
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_DOCFLOW) TYPE  BEAT_DFL_OUT
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_BDI_WRK      TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_WRK      TYPE /1BEA/T_CRMB_BDI_WRK,
    LT_DFL          TYPE BEAT_DFL_WRK,
    LS_BDH          TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_BDI          TYPE /1BEA/T_CRMB_BDI_WRK,
    LT_DLI          TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_TRANS_TYPE   TYPE BEA_TRANSFER_TYPE.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  LT_BDI_WRK = IT_BDI.
  IF NOT IS_BDI IS INITIAL.
    APPEND IS_BDI TO LT_BDI_WRK.
  ENDIF.


  LOOP AT LT_BDI_WRK INTO LS_BDI_WRK.
    PERFORM GET_DOCFLOW_LINKS_DLI
      USING    LS_BDI_WRK
      CHANGING LT_DLI
               LT_DFL
               LT_BDI.
    PERFORM BUILD_DOCFLOW_DLI
      USING    LT_DLI
               LT_DFL
               LT_BDI
               LS_BDI_WRK-BDI_GUID
               GC_DFL_ITEM
      CHANGING ET_DOCFLOW
               ET_RETURN.
   ENDLOOP.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
  IF NOT ET_RETURN IS INITIAL AND LS_BDH IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
      EXPORTING
        IV_BDH_GUID = IS_BDI-BDH_GUID
      IMPORTING
        ES_BDH      = LS_BDH
      EXCEPTIONS
        NOTFOUND    = 1.
    MESSAGE E120(BEA) WITH LS_BDH-HEADNO_EXT IS_BDI-ITEMNO_EXT
            RAISING REJECT.
  ENDIF.
ENDFUNCTION.
*--------------------------------------------------------------------*
*      Form GET_DOCFLOW_LINKS
*--------------------------------------------------------------------*
FORM GET_DOCFLOW_LINKS
  USING    IS_BDI   TYPE /1BEA/S_CRMB_BDI_WRK
  CHANGING CS_DLI   TYPE /1BEA/S_CRMB_DLI_WRK
           CT_DFL   TYPE BEAT_DFL_WRK
           CT_BDI   TYPE /1BEA/T_CRMB_BDI_WRK.
  DATA:
    LS_DFL       TYPE BEAS_DFL_WRK,
    LT_DLI       TYPE /1BEA/T_CRMB_DLI_WRK,
    LRS_GUID     TYPE BEARS_BDI_GUID,
    LRT_DLI_GUID TYPE BEART_BDI_GUID,
    LRT_BDI_GUID TYPE BEART_BDI_GUID.
  LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
  LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
  LRS_GUID-LOW    = IS_BDI-BDI_GUID.
  APPEND LRS_GUID TO LRT_DLI_GUID.
  APPEND LRS_GUID TO LRT_BDI_GUID.

  IF NOT IS_BDI-REVERSAL IS INITIAL.
    CALL FUNCTION 'BEA_DFL_O_GETLIST'
      EXPORTING
         IRT_SUC_GUID       = LRT_BDI_GUID
      IMPORTING
         ET_DFL             = CT_DFL.
    READ TABLE CT_DFL INTO LS_DFL
      WITH KEY SUC_GUID = IS_BDI-BDI_GUID.
    IF NOT LS_DFL IS INITIAL.
      LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
      LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
      LRS_GUID-LOW    = LS_DFL-PRE_GUID.
      APPEND LRS_GUID TO LRT_DLI_GUID.
      APPEND LRS_GUID TO LRT_BDI_GUID.
    ENDIF.
  ENDIF.
  IF NOT IS_BDI-IS_REVERSED IS INITIAL.
    CALL FUNCTION 'BEA_DFL_O_GETLIST'
      EXPORTING
         IRT_PRE_GUID       = LRT_BDI_GUID
      IMPORTING
         ET_DFL             = CT_DFL.
    READ TABLE CT_DFL INTO LS_DFL
      WITH KEY PRE_GUID = IS_BDI-BDI_GUID.
    IF NOT LS_DFL IS INITIAL.
      LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
      LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
      LRS_GUID-LOW    = LS_DFL-SUC_GUID.
      APPEND LRS_GUID TO LRT_BDI_GUID.
    ENDIF.
  ENDIF.
  IF NOT LRT_DLI_GUID IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IRT_BDI_GUID = LRT_DLI_GUID
      IMPORTING
        ET_DLI       = LT_DLI.
     IF NOT LT_DLI IS INITIAL.
       READ TABLE LT_DLI INTO CS_DLI INDEX 1.
     ENDIF.
  ENDIF.
  IF NOT LRT_BDI_GUID IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
      EXPORTING
        IRT_BDI_GUID = LRT_BDI_GUID
      IMPORTING
        ET_BDI       = CT_BDI.
  ENDIF.
ENDFORM.    "GET_DOCFLOW_LINKS
*--------------------------------------------------------------------*
*      Form GET_DOCFLOW_LINKS_DLI
*--------------------------------------------------------------------*
FORM GET_DOCFLOW_LINKS_DLI
  USING    IS_BDI   TYPE /1BEA/S_CRMB_BDI_WRK
  CHANGING CT_DLI   TYPE /1BEA/T_CRMB_DLI_WRK
           CT_DFL   TYPE BEAT_DFL_WRK
           CT_BDI   TYPE /1BEA/T_CRMB_BDI_WRK.
  DATA:
    LS_DFL       TYPE BEAS_DFL_WRK,
    LT_DLI       TYPE /1BEA/T_CRMB_DLI_WRK,
    LRS_GUID     TYPE BEARS_BDI_GUID,
    LRT_DLI_GUID TYPE BEART_BDI_GUID,
    LRT_BDI_GUID TYPE BEART_BDI_GUID.
  LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
  LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
  LRS_GUID-LOW    = IS_BDI-BDI_GUID.
  APPEND LRS_GUID TO LRT_DLI_GUID.
  APPEND LRS_GUID TO LRT_BDI_GUID.

  IF NOT IS_BDI-REVERSAL IS INITIAL.
    CALL FUNCTION 'BEA_DFL_O_GETLIST'
      EXPORTING
         IRT_SUC_GUID       = LRT_BDI_GUID
      IMPORTING
         ET_DFL             = CT_DFL.
    READ TABLE CT_DFL INTO LS_DFL
      WITH KEY SUC_GUID = IS_BDI-BDI_GUID.
    IF NOT LS_DFL IS INITIAL.
      LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
      LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
      LRS_GUID-LOW    = LS_DFL-PRE_GUID.
      APPEND LRS_GUID TO LRT_DLI_GUID.
      APPEND LRS_GUID TO LRT_BDI_GUID.
    ENDIF.
  ENDIF.
  IF NOT IS_BDI-IS_REVERSED IS INITIAL.
    CALL FUNCTION 'BEA_DFL_O_GETLIST'
      EXPORTING
         IRT_PRE_GUID       = LRT_BDI_GUID
      IMPORTING
         ET_DFL             = CT_DFL.
    READ TABLE CT_DFL INTO LS_DFL
      WITH KEY PRE_GUID = IS_BDI-BDI_GUID.
    IF NOT LS_DFL IS INITIAL.
      LRS_GUID-SIGN   = GC_SIGN_INCLUDE.
      LRS_GUID-OPTION = GC_RANGEOPTION_EQ.
      LRS_GUID-LOW    = LS_DFL-SUC_GUID.
      APPEND LRS_GUID TO LRT_BDI_GUID.
    ENDIF.
  ENDIF.
  IF NOT LRT_DLI_GUID IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IRT_BDI_GUID = LRT_DLI_GUID
      IMPORTING
        ET_DLI       = CT_DLI.
*    IF NOT LT_DLI IS INITIAL.
*      READ TABLE LT_DLI INTO CS_DLI INDEX 1.
*    ENDIF.
  ENDIF.
  IF NOT LRT_BDI_GUID IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
      EXPORTING
        IRT_BDI_GUID = LRT_BDI_GUID
      IMPORTING
        ET_BDI       = CT_BDI.
  ENDIF.
ENDFORM.    "GET_DOCFLOW_LINKS
*--------------------------------------------------------------------*
*      Form BUILD_DOCFLOW
*--------------------------------------------------------------------*
FORM BUILD_DOCFLOW
  USING
    IS_DLI       TYPE /1BEA/S_CRMB_DLI_WRK
    IT_DFL_WRK   TYPE BEAT_DFL_WRK
    IT_BDI       TYPE /1BEA/T_CRMB_BDI_WRK
    IV_MARK_GUID TYPE BEA_BDI_GUID
    IV_LEVEL     TYPE BEA_DFL_LEVEL
  CHANGING
    CT_DFL_OUT   TYPE BEAT_DFL_OUT
    CT_RETURN    TYPE BEAT_RETURN.
  DATA:
    LV_SUBRC   TYPE SYSUBRC,
    LS_BDI     TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_BDH     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DFL_WRK TYPE BEAS_DFL_WRK,
    LS_DFL_OUT TYPE BEAS_DFL_OUT.

    PERFORM PREDECESSOR
      USING    IS_DLI
               IV_LEVEL
    CHANGING CT_DFL_OUT.
    IF IS_DLI-BILL_STATUS = GC_BILLSTAT_DONE.
      PERFORM BD_DETAIL
        USING    IS_DLI-BDI_GUID
                 IT_BDI
        CHANGING LS_BDI
                 LS_BDH
                 CT_RETURN
                 LV_SUBRC.
      IF LV_SUBRC = 0.
*       Create entry for billing document
        PERFORM BILLING_DOCUMENT
          USING    LS_BDI
                   LS_BDH
                   IV_LEVEL
                   LS_DFL_WRK-SUC_GUID
          CHANGING CT_DFL_OUT.
      ENDIF.
      IF NOT LS_BDI-IS_REVERSED IS INITIAL.
        READ TABLE IT_DFL_WRK INTO LS_DFL_WRK
          WITH KEY PRE_GUID = LS_BDI-BDI_GUID.
        IF NOT LS_DFL_WRK IS INITIAL.
          PERFORM BD_DETAIL
            USING    LS_DFL_WRK-SUC_GUID
                     IT_BDI
            CHANGING LS_BDI
                     LS_BDH
                     CT_RETURN
                     LV_SUBRC.
          IF LV_SUBRC = 0.
*           Create entry for cancel billing document
            PERFORM BILLING_DOCUMENT
              USING    LS_BDI
                       LS_BDH
                       IV_LEVEL
                       LS_DFL_WRK-SUC_GUID
              CHANGING CT_DFL_OUT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  LOOP AT CT_DFL_OUT INTO LS_DFL_OUT
       WHERE OBJ_GUID = IV_MARK_GUID.
    LS_DFL_OUT-MARKED_ENTRY = GC_TRUE.
    MODIFY CT_DFL_OUT FROM LS_DFL_OUT.
    EXIT.
  ENDLOOP.
ENDFORM.    "BUILD_DOCFLOW
*--------------------------------------------------------------------*
*      Form BUILD_DOCFLOW_DLI
*--------------------------------------------------------------------*
FORM BUILD_DOCFLOW_DLI
  USING
    IT_DLI       TYPE /1BEA/T_CRMB_DLI_WRK
    IT_DFL_WRK   TYPE BEAT_DFL_WRK
    IT_BDI       TYPE /1BEA/T_CRMB_BDI_WRK
    IV_MARK_GUID TYPE BEA_BDI_GUID
    IV_LEVEL     TYPE BEA_DFL_LEVEL
  CHANGING
    CT_DFL_OUT   TYPE BEAT_DFL_OUT
    CT_RETURN    TYPE BEAT_RETURN.
  DATA:
    LS_DLI     TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_SUBRC   TYPE SYSUBRC,
    LS_BDI     TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_BDH     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_DFL_WRK TYPE BEAS_DFL_WRK,
    LS_DFL_OUT TYPE BEAS_DFL_OUT,
    LV_BDI_INS TYPE BEA_BOOLEAN.

  LOOP AT IT_DLI INTO LS_DLI.
    PERFORM PREDECESSOR
      USING    LS_DLI
               IV_LEVEL
    CHANGING CT_DFL_OUT.
    IF LS_DLI-BILL_STATUS = GC_BILLSTAT_DONE.
      PERFORM BD_DETAIL
        USING    LS_DLI-BDI_GUID
                 IT_BDI
        CHANGING LS_BDI
                 LS_BDH
                 CT_RETURN
                 LV_SUBRC.
      IF LS_BDI-CREATION_CODE = GC_CC_CUMULATION.
        LV_BDI_INS = GC_FALSE.
        AT LAST.
          LV_BDI_INS = GC_TRUE.
        ENDAT.
      ELSE.
        LV_BDI_INS = GC_TRUE.
      ENDIF.
      IF LV_SUBRC = 0 AND LV_BDI_INS = GC_TRUE.
*       Create entry for billing document
            PERFORM BILL_DOCUMENT
              USING    LS_BDI
                       LS_BDH
                       LS_DLI
                       IV_LEVEL
              CHANGING CT_DFL_OUT.
      ENDIF.
      IF NOT LS_BDI-IS_REVERSED IS INITIAL AND
         LV_BDI_INS = GC_TRUE.
        READ TABLE IT_DFL_WRK INTO LS_DFL_WRK
          WITH KEY PRE_GUID = LS_BDI-BDI_GUID.
        IF NOT LS_DFL_WRK IS INITIAL.
          PERFORM BD_DETAIL
            USING    LS_DFL_WRK-SUC_GUID
                     IT_BDI
            CHANGING LS_BDI
                     LS_BDH
                     CT_RETURN
                     LV_SUBRC.
          IF LV_SUBRC = 0.
*           Create entry for cancel billing document
            PERFORM BILLING_DOCUMENT
              USING    LS_BDI
                       LS_BDH
                       IV_LEVEL
                       LS_DFL_WRK-SUC_GUID
              CHANGING CT_DFL_OUT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  LOOP AT CT_DFL_OUT INTO LS_DFL_OUT
       WHERE OBJ_GUID = IV_MARK_GUID.
    LS_DFL_OUT-MARKED_ENTRY = GC_TRUE.
    MODIFY CT_DFL_OUT FROM LS_DFL_OUT.
    EXIT.
  ENDLOOP.
ENDFORM.    "BUILD_DOCFLOW
*--------------------------------------------------------------------*
*      Form PREDECESSOR
*--------------------------------------------------------------------*
FORM PREDECESSOR
  USING    IS_DLI TYPE /1BEA/S_CRMB_DLI_WRK
           IV_LEV TYPE C
  CHANGING CT_DFL TYPE BEAT_DFL_OUT.
  DATA:
    LV_FLT_VAL   TYPE BEA_SCENARIO,
    LV_SUBRC     TYPE SYSUBRC,
    LS_DFL       TYPE BEAS_DFL_OUT.
*  Internal tables and Structures
  DATA:
    LRS_LOGSYS TYPE /1BEA/RS_CRMB_LOGSYS,
    LRT_LOGSYS TYPE /1BEA/RT_CRMB_LOGSYS,
    LRS_OBJTYPE TYPE /1BEA/RS_CRMB_OBJTYPE,
    LRT_OBJTYPE TYPE /1BEA/RT_CRMB_OBJTYPE,
    LRS_SRC_HEADNO TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    LRT_SRC_HEADNO TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    LRS_SRC_ITEMNO TYPE /1BEA/RS_CRMB_SRC_ITEMNO,
    LRT_SRC_ITEMNO TYPE /1BEA/RT_CRMB_SRC_ITEMNO,
    LS_RETURN      TYPE  BEAS_RETURN,
    LS_DLI         TYPE /1BEA/S_CRMB_DLI_WRK,
    CT_DLI         TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI         TYPE /1BEA/T_CRMB_DLI_WRK.

  CLEAR: LRS_LOGSYS, LRT_LOGSYS.
  CLEAR: LRS_OBJTYPE, LRT_OBJTYPE.
  CLEAR: LRS_SRC_HEADNO, LRT_SRC_HEADNO.
  CLEAR: LRS_SRC_ITEMNO, LRT_SRC_ITEMNO.

*   CREATE  PREDECESSOR ENTRY
* Event DL_ODFL3
  INCLUDE %2f1BEA%2fX_CRMBDL_ODFL3DOCOBD_DEL.

*   create predeccessor
  LS_DFL-SRC_PROCESS_TYPE = IS_DLI-SRC_PROCESS_TYPE.
  LS_DFL-MAINT_DATE = IS_DLI-SRC_DATE.
  LS_DFL-MAINT_TIME = IS_DLI-MAINT_TIME.
  LS_DFL-BILL_RELEVANCE   = IS_DLI-BILL_RELEVANCE.


* Event DL_ODFL2
  INCLUDE %2f1BEA%2fX_CRMBDL_ODFL2SRFODL_EDF.

  IF GO_DFL_DATA IS INITIAL.
    CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
      EXPORTING
        EXIT_NAME              = GC_EXIT_DFL_DATA
        NULL_INSTANCE_ACCEPTED = ' '
      CHANGING
        INSTANCE               = GO_DFL_DATA
      EXCEPTIONS
        OTHERS = 1.
    LV_SUBRC = SY-SUBRC.
  ENDIF.
  IF LV_SUBRC = 0.
    CALL FUNCTION 'BEA_OBJ_O_GET_SCENARIO'
      EXPORTING
        IV_OBJTYPE        = LS_DFL-OBJTYPE
      IMPORTING
        EV_SCENARIO       = LV_FLT_VAL.
    IF NOT LV_FLT_VAL IS INITIAL.
      CALL METHOD GO_DFL_DATA->DATA_GET
        EXPORTING
          FLT_VAL           = LV_FLT_VAL
          IS_DFL            = LS_DFL
          IV_LEVEL          = IV_LEV
        IMPORTING
          ES_DFL            = LS_DFL.
    ENDIF.
  ENDIF.
  INSERT LS_DFL INTO TABLE CT_DFL.
ENDFORM.    "PREDECESSOR
*--------------------------------------------------------------------*
*      Form BILLING_DOCUMENT
*--------------------------------------------------------------------*
FORM BILLING_DOCUMENT
  USING    IS_BDI      TYPE /1BEA/S_CRMB_BDI_WRK
           IS_BDH      TYPE /1BEA/S_CRMB_BDH_WRK
           IV_LEVEL    TYPE BEA_DFL_LEVEL
           IV_BDI_GUID TYPE BEA_BDI_GUID
  CHANGING CT_DFL      TYPE BEAT_DFL_OUT.
  DATA:
    LS_DFL    TYPE BEAS_DFL_OUT.

  LS_DFL-SRC_HEADNO     = IS_BDH-HEADNO_EXT.
  LS_DFL-SRC_ITEMNO     = IS_BDI-ITEMNO_EXT.
  LS_DFL-DFL_PRE_KIND   = 'I'.
  CASE IV_LEVEL.
    WHEN GC_DFL_HEAD.
      IF IS_BDI-REVERSAL = GC_REVERSAL_CANCEL.
        LS_DFL-REVERSAL = IS_BDI-REVERSAL.
        LS_DFL-REVERSED_BDI_GUID = IV_BDI_GUID.
      ENDIF.
      LS_DFL-OBJ_GUID   = IS_BDH-BDH_GUID.
      LS_DFL-OBJTYPE    = GC_BOR_BDH.
    WHEN GC_DFL_ITEM.
      LS_DFL-REVERSAL = IS_BDI-REVERSAL.
      LS_DFL-OBJ_GUID      = IS_BDI-BDI_GUID.
      LS_DFL-OBJTYPE       = GC_BOR_BDI.
  ENDCASE.
  LS_DFL-MAINT_DATE = IS_BDH-MAINT_DATE.
  LS_DFL-MAINT_TIME = IS_BDH-MAINT_TIME.
  LS_DFL-BILL_TYPE  = IS_BDH-BILL_TYPE.
  LS_DFL-TRANSFER_STATUS = IS_BDH-TRANSFER_STATUS.
  PERFORM OWN_LOGSYS CHANGING LS_DFL-LOGSYS.

* Event DL_ODFL1
  INCLUDE %2f1BEA%2fX_CRMBDL_ODFL1ACCODL_DFE.

  INSERT LS_DFL INTO TABLE CT_DFL.
ENDFORM.    "BILLING_DOCUMENT
*--------------------------------------------------------------------*
*      Form BD_DETAIL
*--------------------------------------------------------------------*
FORM BD_DETAIL
  USING    IV_BDI_GUID TYPE BEA_BDI_GUID
           IT_BDI      TYPE /1BEA/T_CRMB_BDI_WRK
  CHANGING CS_BDI      TYPE /1BEA/S_CRMB_BDI_WRK
           CS_BDH      TYPE /1BEA/S_CRMB_BDH_WRK
           CT_RETURN   TYPE BEAT_RETURN
           CV_SUBRC    TYPE SYSUBRC.
  CONSTANTS:
    LC_TABNAME TYPE SYMSGV VALUE '/1BEA/CRMB_BDI'.

  CLEAR: CS_BDI,
         CS_BDH.
  READ TABLE IT_BDI INTO CS_BDI
    WITH KEY BDI_GUID = IV_BDI_GUID.
  CV_SUBRC = SY-SUBRC.
  IF CV_SUBRC = 0.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETDTL'
      EXPORTING
        IV_BDH_GUID = CS_BDI-BDH_GUID
      IMPORTING
        ES_BDH      = CS_BDH
      EXCEPTIONS
        NOTFOUND    = 1
        OTHERS      = 2.
    CV_SUBRC = SY-SUBRC.
    IF CV_SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM msg_add
        using space space space space
        CHANGING CT_RETURN.
    ENDIF.
  ELSE.
    MESSAGE E104(BEA) WITH IV_BDI_GUID LC_TABNAME INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING CT_RETURN.
  ENDIF.
ENDFORM.   "BD_DETAIL

*--------------------------------------------------------------------*
*      Form BILL_DOCUMENT
*--------------------------------------------------------------------*
FORM BILL_DOCUMENT
  USING    IS_BDI      TYPE /1BEA/S_CRMB_BDI_WRK
           IS_BDH      TYPE /1BEA/S_CRMB_BDH_WRK
           IS_DLI      TYPE /1BEA/S_CRMB_DLI_WRK
           IV_LEVEL    TYPE BEA_DFL_LEVEL
  CHANGING CT_DFL      TYPE BEAT_DFL_OUT.
  DATA:
    LS_DFL    TYPE BEAS_DFL_OUT.

  LS_DFL-SRC_HEADNO = IS_BDH-HEADNO_EXT.
  LS_DFL-SRC_ITEMNO = IS_BDI-ITEMNO_EXT.
  LS_DFL-DFL_PRE_KIND       = 'I'.
  CASE IV_LEVEL.
    WHEN GC_DFL_HEAD.
      LS_DFL-OBJ_GUID   = IS_BDH-BDH_GUID.
      LS_DFL-OBJTYPE    = GC_BOR_BDH.
    WHEN GC_DFL_ITEM.
      LS_DFL-OBJ_GUID      = IS_BDI-BDI_GUID.
      LS_DFL-OBJTYPE       = GC_BOR_BDI.
  ENDCASE.
  LS_DFL-MAINT_DATE = IS_BDH-MAINT_DATE.
  LS_DFL-MAINT_TIME = IS_BDH-MAINT_TIME.
  LS_DFL-BILL_TYPE  = IS_BDH-BILL_TYPE.
  LS_DFL-TRANSFER_STATUS = IS_BDH-TRANSFER_STATUS.
  LS_DFL-REVERSAL = IS_BDI-REVERSAL.
  PERFORM OWN_LOGSYS CHANGING LS_DFL-LOGSYS.

* Event DL_ODFL4
  INCLUDE %2f1BEA%2fX_CRMBDL_ODFL4ACCODL_DFE.

  INSERT LS_DFL INTO TABLE CT_DFL.
ENDFORM.    "BILL_DOCUMENT

*--------------------------------------------------------------------*
*      Form OWN_LOGSYS
*--------------------------------------------------------------------*
FORM OWN_LOGSYS
  CHANGING CV_LOGSYS TYPE LOGSYS.
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM = CV_LOGSYS.
ENDFORM.   "OWN_LOGSYS
