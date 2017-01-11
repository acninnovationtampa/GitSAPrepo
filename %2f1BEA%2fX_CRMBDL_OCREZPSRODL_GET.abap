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
*       FORM GET_REF_DLI
*-----------------------------------------------------------------*
* Enqueue and Get referenced DLI and buffering on document level
*-----------------------------------------------------------------*
FORM GET_REF_DLI
  USING
    US_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK
    CT_RETURN        TYPE BEAT_RETURN
    CV_RETURNCODE    TYPE SYSUBRC.

  STATICS:
    SS_REF_DLI_WRK  TYPE /1BEA/S_CRMB_DLI_WRK,
    ST_REF_DLI_WRK  TYPE /1BEA/T_CRMB_DLI_WRK,
    SS_PREV_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK.
  DATA:
    LV_LOGSYS       TYPE /1BEA/S_CRMB_DLI_WRK-LOGSYS,
    LRS_LOGSYS      TYPE /1BEA/RS_CRMB_LOGSYS,
    LRT_LOGSYS      TYPE /1BEA/RT_CRMB_LOGSYS,
    LV_OBJTYPE       TYPE /1BEA/S_CRMB_DLI_WRK-OBJTYPE,
    LRS_OBJTYPE      TYPE /1BEA/RS_CRMB_OBJTYPE,
    LRT_OBJTYPE      TYPE /1BEA/RT_CRMB_OBJTYPE,
    LV_SRC_HEADNO       TYPE /1BEA/S_CRMB_DLI_WRK-SRC_HEADNO,
    LRS_SRC_HEADNO      TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    LRT_SRC_HEADNO      TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_RETURN       TYPE BEAS_RETURN.

  CLEAR CS_DLI_WRK.
**********************************************************************
* Check buffer: if the last call was done with the same source fields.
* --> just return the entries from the static buffer.
**********************************************************************
  IF (
     US_DLI_WRK-P_LOGSYS <> SS_PREV_DLI_WRK-P_LOGSYS OR
     US_DLI_WRK-P_OBJTYPE <> SS_PREV_DLI_WRK-P_OBJTYPE OR
     US_DLI_WRK-P_SRC_HEADNO <> SS_PREV_DLI_WRK-P_SRC_HEADNO
     ).
**********************************************************************
* Prepare Read
**********************************************************************
    LV_LOGSYS = US_DLI_WRK-P_LOGSYS.
    LV_OBJTYPE = US_DLI_WRK-P_OBJTYPE.
    LV_SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO.
    IF
       US_DLI_WRK-P_LOGSYS IS INITIAL OR
       US_DLI_WRK-P_OBJTYPE IS INITIAL OR
       US_DLI_WRK-P_SRC_HEADNO IS INITIAL
    .
      RETURN.
    ENDIF.
* Save the previous DLI for buffering
    SS_PREV_DLI_WRK = US_DLI_WRK.
* Clear the buffer and the return table
    CLEAR: ST_REF_DLI_WRK,
           SS_REF_DLI_WRK.
**********************************************************************
* Enqueue
**********************************************************************
    LS_DLI_WRK-LOGSYS = LV_LOGSYS.
    LS_DLI_WRK-OBJTYPE = LV_OBJTYPE.
    LS_DLI_WRK-SRC_HEADNO = LV_SRC_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
      EXPORTING
        IS_DLI_WRK = LS_DLI_WRK
      IMPORTING
      ES_RETURN  = LS_RETURN.
    IF NOT LS_RETURN IS INITIAL.
      MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
              NUMBER LS_RETURN-NUMBER
              WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                   LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
              INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
      CV_RETURNCODE = 1.
      RETURN.
    ENDIF.
**********************************************************************
* Read
**********************************************************************
    LRS_LOGSYS-SIGN   = GC_INCLUDE.
    LRS_LOGSYS-OPTION = GC_EQUAL.
    LRS_LOGSYS-LOW    = US_DLI_WRK-P_LOGSYS.
    APPEND LRS_LOGSYS TO LRT_LOGSYS.
    LRS_OBJTYPE-SIGN   = GC_INCLUDE.
    LRS_OBJTYPE-OPTION = GC_EQUAL.
    LRS_OBJTYPE-LOW    = US_DLI_WRK-P_OBJTYPE.
    APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
    LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
    LRS_SRC_HEADNO-OPTION = GC_EQUAL.
    LRS_SRC_HEADNO-LOW    = US_DLI_WRK-P_SRC_HEADNO.
    APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IV_SORTREL      = GC_SORT_BY_EXTERNAL_REF
        IRT_LOGSYS  = LRT_LOGSYS
        IRT_OBJTYPE  = LRT_OBJTYPE
        IRT_SRC_HEADNO  = LRT_SRC_HEADNO
      IMPORTING
        ET_DLI          = ST_REF_DLI_WRK.
  ENDIF.
  IF (
     US_DLI_WRK-P_LOGSYS <> SS_REF_DLI_WRK-LOGSYS OR
     US_DLI_WRK-P_OBJTYPE <> SS_REF_DLI_WRK-OBJTYPE OR
     US_DLI_WRK-P_SRC_HEADNO <> SS_REF_DLI_WRK-SRC_HEADNO OR
     US_DLI_WRK-P_SRC_ITEMNO <> SS_REF_DLI_WRK-SRC_ITEMNO
     ).
    READ TABLE ST_REF_DLI_WRK INTO SS_REF_DLI_WRK WITH KEY
            LOGSYS = US_DLI_WRK-P_LOGSYS
            OBJTYPE = US_DLI_WRK-P_OBJTYPE
            SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO
            SRC_ITEMNO = US_DLI_WRK-P_SRC_ITEMNO
            BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CV_RETURNCODE = 1.
      LS_DLI_WRK = US_DLI_WRK.
      LS_DLI_WRK-LOGSYS = US_DLI_WRK-P_LOGSYS.
      LS_DLI_WRK-OBJTYPE = US_DLI_WRK-P_OBJTYPE.
      LS_DLI_WRK-SRC_HEADNO = US_DLI_WRK-P_SRC_HEADNO.
      LS_DLI_WRK-SRC_ITEMNO = US_DLI_WRK-P_SRC_ITEMNO.
      MESSAGE E263(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
      EXIT. "from form
    ENDIF.
  ENDIF.
  CS_DLI_WRK = SS_REF_DLI_WRK.
ENDFORM.                        "GET_REF_DLI
