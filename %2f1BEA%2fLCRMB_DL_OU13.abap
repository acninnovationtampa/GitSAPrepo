FUNCTION /1BEA/CRMB_DL_O_REJECT_INCOMP.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"  EXPORTING
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
*--------------------------------------------------------------------
* Definitionsteil
*--------------------------------------------------------------------
  DATA:
    ls_dli_wrk       TYPE /1bea/s_CRMB_DLI_wrk,
    LT_DLI_WRK       TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_WRK_CLT   TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_HLP       TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK_HLP   TYPE /1BEA/T_CRMB_DLI_WRK,
    ls_bdi_wrk       TYPE /1bea/s_CRMB_BDI_wrk,
    lt_bdi_wrk       TYPE /1bea/t_CRMB_BDI_wrk,
    LRS_BILL_STATUS  TYPE BEARS_BILL_STATUS,
    LRT_BILL_STATUS  TYPE BEART_BILL_STATUS,
    LRS_INCOMP_ID    TYPE BEARS_INCOMP_ID,
    LRT_INCOMP_ID    TYPE BEART_INCOMP_ID,
    LRS_DLI_GUID     TYPE BEARS_DLI_GUID,
    LRT_DLI_GUID     TYPE BEART_DLI_GUID,
    lrs_BDI_GUID     TYPE BEARS_BDI_GUID,
    lrt_BDI_GUID     TYPE BEART_BDI_GUID,
    ls_bd_guids      TYPE beas_bd_guids,
    lt_bd_guids      TYPE beat_bd_guids,
    LV_ENQUEUED      TYPE BEA_BOOLEAN,
    LV_RETURNCODE    TYPE SYSUBRC,
    LV_TABIX         TYPE SYTABIX,
    LV_COUNT         TYPE SYTABIX,
    LS_RETURN        TYPE BEAS_RETURN,
    lt_return        TYPE beat_return.
*--------------------------------------------------------------------
* prepare ranges for date selection via method GETLIST
*--------------------------------------------------------------------
  LRS_BILL_STATUS-SIGN    = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION  = GC_EQUAL.
  LRS_BILL_STATUS-LOW     = GC_BILLSTAT_DONE.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_BILL_STATUS-LOW     = GC_BILLSTAT_TODO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_INCOMP_ID-SIGN       = GC_INCLUDE.
  LRS_INCOMP_ID-OPTION     = GC_EQUAL.
  LRS_INCOMP_ID-LOW        = GC_INCOMP_REJECT.
  APPEND LRS_INCOMP_ID TO LRT_INCOMP_ID.
  LT_DLI_WRK = IT_DLI_WRK.
  SORT LT_DLI_WRK BY
       LOGSYS
       OBJTYPE
       SRC_HEADNO.
*--------------------------------------------------------------------
* LOOP at items to be canceled
*--------------------------------------------------------------------
  LOOP AT lt_dli_wrk INTO ls_dli_wrk
    WHERE incomp_id   = GC_INCOMP_REJECT.
    LV_TABIX = SY-TABIX.
    CLEAR:
      LV_RETURNCODE.
    IF (
      LS_DLI_WRK-LOGSYS <> LS_DLI_HLP-LOGSYS OR
      LS_DLI_WRK-OBJTYPE <> LS_DLI_HLP-OBJTYPE OR
      LS_DLI_WRK-SRC_HEADNO <> LS_DLI_HLP-SRC_HEADNO
       ).
      CLEAR LS_RETURN.
      LV_ENQUEUED = GC_FALSE.
      LS_DLI_HLP-LOGSYS = LS_DLI_WRK-LOGSYS.
      LS_DLI_HLP-OBJTYPE = LS_DLI_WRK-OBJTYPE.
      LS_DLI_HLP-SRC_HEADNO = LS_DLI_WRK-SRC_HEADNO.
      CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
        EXPORTING
          IS_DLI_WRK = LS_DLI_HLP
        IMPORTING
          ES_RETURN  = LS_RETURN.
      IF NOT LS_RETURN IS INITIAL.
        LS_RETURN-ROW = LV_TABIX.
        lS_RETURN-PARAMETER = GC_BAPI_PAR_DLI.
        APPEND LS_RETURN TO LT_RETURN.
        CLEAR LS_DLI_HLP.
      ELSE.
        LV_ENQUEUED = GC_TRUE.
      ENDIF.
    ENDIF.
    CHECK LV_ENQUEUED = GC_TRUE.
    PERFORM AUTHORITY_CHECK
      USING
        GC_ACTV_UNLOCK
        LS_DLI_WRK
        LV_TABIX
      CHANGING
        LT_RETURN
        LV_RETURNCODE.
    CHECK LV_RETURNCODE IS INITIAL.
*     Sperren und Berechtigung erfolgreich => Daten lesen
    LRS_DLI_GUID-SIGN = GC_INCLUDE.
    LRS_DLI_GUID-OPTION = GC_EQUAL.
    LRS_DLI_GUID-LOW = LS_DLI_WRK-DLI_GUID.
    APPEND LRS_DLI_GUID TO LRT_DLI_GUID.
    IF LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_DONE.
      CLEAR lrs_bdi_guid.
      lrs_bdi_guid-low = ls_dli_wrk-bdi_guid.
      lrs_bdi_guid-sign   = gc_include.
      lrs_bdi_guid-option = gc_equal.
      APPEND lrs_bdi_guid TO lrt_bdi_guid.
    ENDIF.
    ADD 1 TO LV_COUNT.
    IF LV_COUNT = GC_MAX_SEL_OPT.
      CLEAR:
        LV_COUNT,
        LT_DLI_WRK_CLT,
        LT_BDI_WRK.
*--------------------------------------------------------------------
*     Read the collected data via method GETLIST
*--------------------------------------------------------------------
      CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
        EXPORTING
          IRT_DLI_GUID              = LRT_DLI_GUID
          IRT_BILL_STATUS           = LRT_BILL_STATUS
          IRT_INCOMP_ID             = LRT_INCOMP_ID
        IMPORTING
          ET_DLI                    = LT_DLI_WRK_CLT.
      APPEND LINES OF LT_DLI_WRK_CLT TO LT_DLI_WRK_HLP.
*--------------------------------------------------------------------
*     Read the billed items in order to prepare CANCEL
*--------------------------------------------------------------------
      IF NOT LRT_BDI_GUID IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
          EXPORTING
            IRT_BDI_GUID    = LRT_BDI_GUID
          IMPORTING
            et_bdi          = lt_bdi_wrk.
        LOOP AT lt_bdi_wrk INTO ls_bdi_wrk
          WHERE is_reversed <> GC_IS_REVED_BY_CANC.
          CLEAR ls_bd_guids.
          ls_bd_guids-bdh_guid = ls_bdi_wrk-bdh_guid.
          ls_bd_guids-bdi_guid = ls_bdi_wrk-bdi_guid.
          APPEND ls_bd_guids TO lt_bd_guids.
        ENDLOOP.
      ENDIF.
      CLEAR:
        LRT_BDI_GUID,
        LRT_DLI_GUID.
    ENDIF.
  ENDLOOP.
  IF NOT LRT_DLI_GUID IS INITIAL.
    CLEAR:
      LT_DLI_WRK_CLT.
*--------------------------------------------------------------------
*   Read the collected data via method GETLIST
*--------------------------------------------------------------------
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IRT_DLI_GUID              = LRT_DLI_GUID
        IRT_BILL_STATUS           = LRT_BILL_STATUS
        IRT_INCOMP_ID             = LRT_INCOMP_ID
      IMPORTING
        ET_DLI                    = LT_DLI_WRK_CLT.
    APPEND LINES OF LT_DLI_WRK_CLT TO LT_DLI_WRK_HLP.
*--------------------------------------------------------------------
*   Read the billed items in order to prepare CANCEL
*--------------------------------------------------------------------
    IF NOT LRT_BDI_GUID IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
        EXPORTING
          IRT_BDI_GUID    = LRT_BDI_GUID
        IMPORTING
          et_bdi          = lt_bdi_wrk.
      LOOP AT lt_bdi_wrk INTO ls_bdi_wrk
        WHERE is_reversed <> GC_IS_REVED_BY_CANC.
        CLEAR ls_bd_guids.
        ls_bd_guids-bdh_guid = ls_bdi_wrk-bdh_guid.
        ls_bd_guids-bdi_guid = ls_bdi_wrk-bdi_guid.
        APPEND ls_bd_guids TO lt_bd_guids.
      ENDLOOP.
    ENDIF.
    CLEAR:
      LRT_BDI_GUID,
      LRT_DLI_GUID.
  ENDIF.
  IF ET_RETURN IS REQUESTED.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
  ENDIF.
  CHECK NOT LT_DLI_WRK_HLP IS INITIAL.
  CLEAR:
    LT_RETURN,
    LT_DLI_WRK.
  LT_DLI_WRK = LT_DLI_WRK_HLP.
  CLEAR:
    LT_DLI_WRK_HLP.
*--------------------------------------------------------------------
*  CANCEL
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
    EXPORTING
      it_bd_guids             = lt_bd_guids
      iv_cause                = gc_cause_reject
      iv_process_mode         = gc_proc_noadd
    IMPORTING
      et_return               = lt_return.
  IF NOT lt_return IS INITIAL.
    PERFORM complete_return
      USING
        lt_dli_wrk
        lt_bdi_wrk
        lt_return
      CHANGING
        et_return.
  ENDIF.
*--------------------------------------------------------------------
* Care now about the DLIs still being incomplete and open
*--------------------------------------------------------------------
  LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
                    WHERE BILL_STATUS <> GC_BILLSTAT_REJECT.
    READ TABLE ET_RETURN WITH KEY
            OBJECT_GUID = LS_DLI_WRK-DLI_GUID
            CONTAINER   = 'DLI'
            TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC <> 0.
    CLEAR LS_DLI_WRK-INCOMP_ID.
    IF LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_TODO.
      LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_REJECT.
    ENDIF.
    LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
    CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
         EXPORTING
           IS_DLI_WRK = LS_DLI_WRK.
  ENDLOOP.
*--------------------------------------------------------------------
* Everything is in the buffers -> ADD and SAVE
*--------------------------------------------------------------------
  IF LT_BD_GUIDS IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
      EXPORTING
        iv_commit_flag   = iv_commit_flag
        iv_with_services = gc_false.
  ELSE.               "DLI's are saved as well
    IF IV_PROCESS_MODE = GC_PROC_ADD.
      CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
        EXPORTING
          iv_process_mode     = gc_proc_add
          iv_commit_flag      = iv_commit_flag
          iv_dl_with_services = gc_true.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------
* Initialization
*--------------------------------------------------------------------
  IF IV_PROCESS_MODE = GC_PROC_TEST.
    CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
  ENDIF.
*--------------------------------------------------------------------
* Processing end
*--------------------------------------------------------------------
  CASE IV_COMMIT_FLAG.
    WHEN GC_NOCOMMIT.
    WHEN GC_COMMIT_ASYNC.
      COMMIT WORK.
    WHEN GC_COMMIT_SYNC.
      COMMIT WORK AND WAIT.
  ENDCASE.
ENDFUNCTION.
