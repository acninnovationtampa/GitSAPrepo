FUNCTION /1BEA/CRMB_DL_O_GET_CHANGEABL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI_OV) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"     REFERENCE(ET_DLI_OV) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(ET_DLI_CANC) TYPE  /1BEA/T_CRMB_DLI_WRK
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
    LT_DLI     TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI     TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI1    TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DFL     TYPE BEAS_DFL_WRK,
    LS_MSG_VAR TYPE BEAS_MESSAGE_VAR.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* PREPARE PROCESS
*---------------------------------------------------------------------
  LT_DLI = IT_DLI.
  READ TABLE LT_DLI INTO LS_DLI INDEX 1.
  IF SY-SUBRC = 0.
    LS_DLI1 = LS_DLI.
  ELSE.
    EXIT.      "from function, no longer process necessary
  ENDIF.
*   It could be possible, that more than 1 billing item belonging
*   to the same source-reference get cancelled at the same time, so
*   look for entries in the global buffer, which are not selected
  LOOP AT GT_DLI_WRK INTO LS_DLI WHERE
           DERIV_CATEGORY = LS_DLI1-DERIV_CATEGORY AND
           LOGSYS = LS_DLI1-LOGSYS AND
           OBJTYPE = LS_DLI1-OBJTYPE AND
           SRC_HEADNO = LS_DLI1-SRC_HEADNO AND
           SRC_ITEMNO = LS_DLI1-SRC_ITEMNO.
    READ TABLE LT_DLI TRANSPORTING NO FIELDS
      WITH KEY DLI_GUID = LS_DLI-DLI_GUID.
    IF SY-SUBRC <> 0.
      INSERT LS_DLI INTO TABLE LT_DLI.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  LOOP AT LT_DLI INTO LS_DLI.
    CLEAR LS_DFL.
    CASE LS_DLI-BILL_STATUS.
      WHEN GC_BILLSTAT_TODO.
*         entry not billed and not reversed
        ES_DLI_OV = LS_DLI.
        APPEND ES_DLI_OV TO ET_DLI_OV.
      WHEN GC_BILLSTAT_NO.
        ES_DLI_OV = LS_DLI.
        APPEND ES_DLI_OV TO ET_DLI_OV.
      WHEN GC_BILLSTAT_DONE.
        PERFORM GET_DOCFLOW
          USING    LS_DLI-BDI_GUID
          CHANGING LS_DFL.
        IF NOT LS_DFL IS INITIAL.
*           entry is a reversed billed version
          CONTINUE.
        ENDIF.
      WHEN GC_BILLSTAT_REJECT.
        IF  ET_DLI_CANC IS SUPPLIED
            AND LS_DLI-SRC_REJECT EQ gc_src_reject.
*         entry rejected by source application
          INSERT LS_DLI INTO TABLE ET_DLI_CANC.
        ELSE.
*         entry is rejected
        ENDIF.
        CONTINUE.
      WHEN OTHERS.
        MESSAGE E126(BEA) WITH LS_DLI-BILL_STATUS GC_P_DLI_ITEMNO
                               GC_P_DLI_HEADNO
                          INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
          EXPORTING
            IV_CONTAINER   = 'DLI'
            IS_DLI_WRK     = LS_DLI
            IT_RETURN      = ET_RETURN
          IMPORTING
            ET_RETURN      = ET_RETURN.
        CONTINUE.
    ENDCASE.
    INSERT LS_DLI INTO TABLE ET_DLI_WRK.
  ENDLOOP.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
  IF NOT ET_RETURN IS INITIAL.
    LS_MSG_VAR-MSGV1 = GC_P_DLI_ITEMNO.
    LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_DLI
        IS_MSG_VAR     = LS_MSG_VAR
      IMPORTING
        ES_MSG_VAR     = LS_MSG_VAR.
    MESSAGE E127(BEA) WITH LS_MSG_VAR-MSGV1 LS_MSG_VAR-MSGV2 RAISING REJECT.
  ENDIF.
ENDFUNCTION.
*--------------------------------------------------------------------*
*      Form GET_DOCFLOW
*--------------------------------------------------------------------*
FORM GET_DOCFLOW
  USING    IV_PRE_GUID TYPE BEA_PRE_GUID
  CHANGING CS_DFL      TYPE BEAS_DFL_WRK.
  DATA:
    LRS_PRE_GUID TYPE BEARS_DLI_GUID,
    LRT_PRE_GUID TYPE BEART_DLI_GUID,
    LS_DFL TYPE BEAS_DFL_WRK,
    LT_DFL TYPE BEAT_DFL_WRK.

  CLEAR CS_DFL.
  LRS_PRE_GUID-SIGN    = GC_SIGN_INCLUDE.
  LRS_PRE_GUID-OPTION  = GC_RANGEOPTION_EQ.
  LRS_PRE_GUID-LOW     = IV_PRE_GUID.
  APPEND LRS_PRE_GUID TO LRT_PRE_GUID.

  CALL FUNCTION 'BEA_DFL_O_GETLIST'
    EXPORTING
*    IRT_SUC_GUID       =
     IRT_PRE_GUID       = LRT_PRE_GUID
     IV_MAXROWS         = 0
   IMPORTING
     ET_DFL             = LT_DFL.
  LOOP AT LT_DFL INTO LS_DFL
       WHERE PRE_GUID = IV_PRE_GUID.
    MOVE-CORRESPONDING LS_DFL TO CS_DFL.
    EXIT.
  ENDLOOP.
ENDFORM.    "GET_DOCFLOW
