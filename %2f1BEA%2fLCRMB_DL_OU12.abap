FUNCTION /1BEA/CRMB_DL_O_REJECT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_SRC_IID) TYPE  /1BEA/UT_CRMB_DL_DLI_SRC_IID
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_BILL_CATEGORY) TYPE  BEA_BILL_CATEGORY OPTIONAL
*"     REFERENCE(IV_BACKGROUND) TYPE  BEA_BOOLEAN OPTIONAL
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
*====================================================================
* Definitionsteil
*====================================================================
 DATA: lt_dli_src_iid     TYPE /1bea/ut_CRMB_DL_DLI_SRC_IID,
       ls_dli_src_iid     TYPE /1bea/us_CRMB_DL_DLI_SRC_IID,
       ls_dli_src_hid     TYPE /1bea/us_CRMB_DL_DLI_SRC_HID,
       ls_dli_src_hid_hlp TYPE /1bea/us_CRMB_DL_DLI_SRC_HID,
       ls_return          TYPE beas_return,
       ls_dli_wrk         TYPE /1bea/s_CRMB_DLI_wrk,
       lrs_LOGSYS   TYPE /1bea/rs_CRMB_LOGSYS,
       lrt_LOGSYS   TYPE /1bea/rt_CRMB_LOGSYS,
       lrs_OBJTYPE   TYPE /1bea/rs_CRMB_OBJTYPE,
       lrt_OBJTYPE   TYPE /1bea/rt_CRMB_OBJTYPE,
       lrs_SRC_HEADNO   TYPE /1bea/rs_CRMB_SRC_HEADNO,
       lrt_SRC_HEADNO   TYPE /1bea/rt_CRMB_SRC_HEADNO,
       lrs_SRC_ITEMNO   TYPE /1bea/rs_CRMB_SRC_ITEMNO,
       lrt_SRC_ITEMNO   TYPE /1bea/rt_CRMB_SRC_ITEMNO,
       lt_dli_wrk       TYPE /1bea/t_CRMB_DLI_wrk,
       lt_dli_all         TYPE /1bea/t_CRMB_DLI_wrk,
       ls_bdi           TYPE /1bea/s_CRMB_BDI_wrk,
       ls_bd_guids      TYPE beas_bd_guids,
       lt_bd_guids      TYPE beat_bd_guids,
       LRS_BILL_CATEGORY TYPE BEARS_BILL_CATEGORY,
       LRT_BILL_CATEGORY TYPE BEART_BILL_CATEGORY,
       lv_error         TYPE bea_boolean,
       lt_return        TYPE beat_return,
       lv_row           TYPE bapi_line.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Implementierungsteil
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  IF IV_BILL_CATEGORY IS SUPPLIED.
    LRS_BILL_CATEGORY-SIGN   = GC_INCLUDE.
    LRS_BILL_CATEGORY-OPTION = GC_EQUAL.
    LRS_BILL_CATEGORY-LOW    = IV_BILL_CATEGORY.
    APPEND LRS_BILL_CATEGORY TO LRT_BILL_CATEGORY.
  ENDIF.
*====================================================================
* SORT Input according to SRC_HEAD-Information
*====================================================================
 lt_dli_src_iid = it_dli_src_iid.
 SORT lt_dli_src_iid BY
                        LOGSYS
                        OBJTYPE
                        SRC_HEADNO.
*====================================================================
* LOOP at items (of the object in the source appl.) to be rejected
*====================================================================
 LOOP AT lt_dli_src_iid INTO ls_dli_src_iid.
*--------------------------------------------------------------------
* ENQUEUE for each new head from the Source-Appl.
*--------------------------------------------------------------------
   MOVE-CORRESPONDING ls_dli_src_iid TO ls_dli_src_hid.
   IF ls_dli_src_hid NE ls_dli_src_hid_hlp.
     ls_dli_src_hid_hlp = ls_dli_src_hid.
     CLEAR: lv_error, ls_return, ls_dli_wrk.
     MOVE-CORRESPONDING ls_dli_src_hid TO ls_dli_wrk.
     CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
       EXPORTING
         IS_DLI_WRK = LS_DLI_WRK
       IMPORTING
         ES_RETURN      = LS_RETURN.
     IF NOT ls_return IS INITIAL.
       IF et_return IS REQUESTED.
         PERFORM determine_row USING    ls_dli_src_iid
                                        it_dli_src_iid
                               CHANGING lv_row.
         ls_return-row = lv_row.
         lS_RETURN-PARAMETER = GC_BAPI_PAR_DLI.
         APPEND ls_return TO et_return.
       ENDIF.
       lv_error = gc_true.
       CLEAR ls_dli_src_hid_hlp.
       IF iv_background = gc_false.
         CONTINUE. "with next entry in lt_dli_src_iid
       ENDIF.
     ENDIF.
   ENDIF.
*--------------------------------------------------------------------
* READ all DLIs for the entry in lt_dli_src_iid
*--------------------------------------------------------------------
   CLEAR: lrs_LOGSYS, lrt_LOGSYS.
   lrs_LOGSYS-sign   = gc_include.
   lrs_LOGSYS-option = gc_equal.
   lrs_LOGSYS-low    = ls_dli_src_iid-LOGSYS.
   APPEND lrs_LOGSYS TO lrt_LOGSYS.
   CLEAR: lrs_OBJTYPE, lrt_OBJTYPE.
   lrs_OBJTYPE-sign   = gc_include.
   lrs_OBJTYPE-option = gc_equal.
   lrs_OBJTYPE-low    = ls_dli_src_iid-OBJTYPE.
   APPEND lrs_OBJTYPE TO lrt_OBJTYPE.
   CLEAR: lrs_SRC_HEADNO, lrt_SRC_HEADNO.
   lrs_SRC_HEADNO-sign   = gc_include.
   lrs_SRC_HEADNO-option = gc_equal.
   lrs_SRC_HEADNO-low    = ls_dli_src_iid-SRC_HEADNO.
   APPEND lrs_SRC_HEADNO TO lrt_SRC_HEADNO.
   CLEAR: lrs_SRC_ITEMNO, lrt_SRC_ITEMNO.
   lrs_SRC_ITEMNO-sign   = gc_include.
   lrs_SRC_ITEMNO-option = gc_equal.
   lrs_SRC_ITEMNO-low    = ls_dli_src_iid-SRC_ITEMNO.
   APPEND lrs_SRC_ITEMNO TO lrt_SRC_ITEMNO.
   CLEAR lt_dli_wrk.
   CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
     EXPORTING
       IRT_BILL_CATEGORY = LRT_BILL_CATEGORY
       irt_LOGSYS = lrt_LOGSYS
       irt_OBJTYPE = lrt_OBJTYPE
       irt_SRC_HEADNO = lrt_SRC_HEADNO
       irt_SRC_ITEMNO = lrt_SRC_ITEMNO
     IMPORTING
       et_dli         = lt_dli_wrk.
   IF lt_dli_wrk IS INITIAL.
     CONTINUE. "with next entry in lt_dli_src_iid
   ENDIF.
*--------------------------------------------------------------------
* The already rejected ones do not need to be considered
*--------------------------------------------------------------------
   DELETE lt_dli_wrk WHERE bill_status = gc_billstat_reject.
   IF lt_dli_wrk IS INITIAL.
     CONTINUE. "with next entry in lt_dli_src_iid
   ENDIF.
*--------------------------------------------------------------------
*  Care first about locking conflicts and build incomplete entries
*--------------------------------------------------------------------
   IF lv_error = gc_true.
     LOOP AT lt_dli_wrk INTO ls_dli_wrk.
       CALL FUNCTION 'GUID_CREATE'
         IMPORTING
           ev_guid_16 = ls_dli_wrk-dli_guid.
       ls_dli_wrk-incomp_id = gc_incomp_enq.
       if ls_dli_wrk-bill_status <> gc_billstat_no.
         ls_dli_wrk-bill_status =  gc_billstat_todo.
       endif.
       ls_dli_wrk-maint_user = sy-uname.
       ls_dli_wrk-maint_date = sy-datlo.
       ls_dli_wrk-maint_time = sy-timlo.
       ls_dli_wrk-upd_type = gc_insert.
       MODIFY lt_dli_wrk FROM ls_dli_wrk.
     ENDLOOP.
     APPEND LINES OF LT_DLI_WRK TO LT_DLI_ALL.
     CONTINUE. "with next entry in lt_dli_src_iid
   ENDIF.
*--------------------------------------------------------------------
* Care then about the already billed ones
*--------------------------------------------------------------------
   CLEAR: lv_error.
   LOOP AT lt_dli_wrk INTO ls_dli_wrk
                      WHERE bill_status = gc_billstat_done.
*....................................................................
* Read the Invoice Item and prepare the CANCEL
*....................................................................
     CLEAR ls_bdi.
     CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETDTL'
       EXPORTING
         iv_bdi_guid       = ls_dli_wrk-bdi_guid
       IMPORTING
         es_bdi            = ls_bdi.
     IF ls_bdi IS INITIAL.
       IF et_return IS REQUESTED.
         PERFORM determine_row USING    ls_dli_src_iid
                                        it_dli_src_iid
                               CHANGING lv_row.
         MESSAGE e229(bea) WITH gc_p_dli_itemno gc_p_dli_headno
                           INTO gv_dummy.
         CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
           EXPORTING
             IV_CONTAINER   = 'DLI'
             IS_DLI_WRK     = LS_DLI_WRK
             IT_RETURN      = ET_RETURN
             IV_TABIX       = LV_ROW
           IMPORTING
             ET_RETURN      = ET_RETURN.
       ENDIF.
       lv_error = gc_true.
       EXIT. "from LOOP at lt_dli_wrk
     ELSEIF ls_bdi-is_reversed EQ GC_IS_REVED_BY_CANC.
       delete LT_DLI_WRK.
       CONTINUE. "with next entry in lt_dli_wrk: BDI is cancelled
     ENDIF.
     CLEAR ls_bd_guids.
     ls_bd_guids-bdh_guid = ls_bdi-bdh_guid.
     ls_bd_guids-bdi_guid = ls_dli_wrk-bdi_guid.
     APPEND ls_bd_guids TO lt_bd_guids.
   ENDLOOP. " at lt_dli_wrk
   IF lv_error IS INITIAL.
     APPEND LINES OF LT_DLI_WRK TO LT_DLI_ALL.
   ENDIF.
 ENDLOOP.   " at lt_dli_src_iid
*....................................................................
* CANCEL without ADD (and thus without SAVE)
*....................................................................
   IF NOT lt_bd_guids IS INITIAL.
     CLEAR lt_return.
     CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
       EXPORTING
         it_bd_guids             = lt_bd_guids
         iv_cause                = gc_cause_reject
         iv_process_mode         = gc_proc_noadd
       IMPORTING
         et_return               = lt_return.
     IF NOT lt_return IS INITIAL.  " some error in cancel -> find src_iid
       LOOP AT LT_RETURN INTO LS_RETURN.
         CLEAR LS_DLI_WRK.
         CASE LS_RETURN-CONTAINER.
           WHEN 'BDH'.
             LOOP AT LT_BD_GUIDS INTO LS_BD_GUIDS WHERE BDH_GUID = LS_RETURN-OBJECT_GUID.
               READ TABLE LT_DLI_ALL INTO LS_DLI_WRK WITH KEY BDI_GUID = LS_BD_GUIDS-BDI_GUID.
               IF SY-SUBRC EQ 0.
                 IF ET_RETURN IS REQUESTED.
                   LS_RETURN-OBJECT_GUID = LS_DLI_WRK-DLI_GUID.
                   LS_RETURN-CONTAINER = 'DLI'.
                   INSERT LS_RETURN INTO TABLE ET_RETURN.
                 ENDIF.
                 DELETE LT_DLI_ALL WHERE    " do not touch DLIs for which cancel was required, but failed
                   LOGSYS = LS_DLI_WRK-LOGSYS AND
                   OBJTYPE = LS_DLI_WRK-OBJTYPE AND
                   SRC_HEADNO = LS_DLI_WRK-SRC_HEADNO AND
                   SRC_ITEMNO = LS_DLI_WRK-SRC_ITEMNO.
               ENDIF.
             ENDLOOP.
           WHEN 'BDI'.
             READ TABLE LT_BD_GUIDS INTO LS_BD_GUIDS WITH KEY BDI_GUID = LS_RETURN-OBJECT_GUID.
             READ TABLE LT_DLI_ALL INTO LS_DLI_WRK WITH KEY BDI_GUID = LS_RETURN-OBJECT_GUID.
             IF SY-SUBRC EQ 0.
               IF ET_RETURN IS REQUESTED.
                 LS_RETURN-OBJECT_GUID = LS_DLI_WRK-DLI_GUID.
                 LS_RETURN-CONTAINER = 'DLI'.
                 INSERT LS_RETURN INTO TABLE ET_RETURN.
               ENDIF.
               DELETE LT_DLI_ALL WHERE    " do not touch DLIs for which cancel was required, but failed
                 LOGSYS = LS_DLI_WRK-LOGSYS AND
                 OBJTYPE = LS_DLI_WRK-OBJTYPE AND
                 SRC_HEADNO = LS_DLI_WRK-SRC_HEADNO AND
                 SRC_ITEMNO = LS_DLI_WRK-SRC_ITEMNO.
             ENDIF.
         ENDCASE.
       ENDLOOP.
     ENDIF.
   ENDIF.
*--------------------------------------------------------------------
* Care now about the DLIs not yet rejected and still being incomplete
*--------------------------------------------------------------------
   LOOP AT lt_dli_all INTO ls_dli_wrk
                      WHERE bill_status <> gc_billstat_reject.
     IF LS_DLI_WRK-BILL_STATUS = GC_BILLSTAT_DONE AND
        LS_DLI_WRK-INCOMP_ID  <> GC_INCOMP_REJECT.
       CONTINUE.
     ENDIF.
     IF LS_DLI_WRK-INCOMP_ID = GC_INCOMP_REJECT.
       CLEAR LS_DLI_WRK-INCOMP_ID.
     ENDIF.
     ls_dli_wrk-src_reject  = gc_src_delete.
     if ls_dli_wrk-upd_type <> gc_insert.
       ls_dli_wrk-bill_status = gc_billstat_reject.
       ls_dli_wrk-upd_type    = gc_update.
     endif.
     CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
       EXPORTING
         is_dli_wrk       = ls_dli_wrk.
   ENDLOOP.
*--------------------------------------------------------------------
* Everything is in the buffers -> ADD and SAVE
*--------------------------------------------------------------------
   IF NOT lt_bd_guids IS INITIAL.
     CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
       EXPORTING
         iv_process_mode     = gc_proc_add
         iv_commit_flag      = iv_commit_flag
         iv_dli_no_save      = gc_true.
   ENDIF.
   CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
     EXPORTING
       iv_commit_flag   = iv_commit_flag
       iv_with_services = gc_true.
   CLEAR lt_return.
*====================================================================
* Endeverarbeitung
*====================================================================
 CASE IV_COMMIT_FLAG.
   WHEN GC_NOCOMMIT.
   WHEN GC_COMMIT_ASYNC.
     COMMIT WORK.
   WHEN GC_COMMIT_SYNC.
     COMMIT WORK AND WAIT.
 ENDCASE.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Form Routines
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FORM determine_row
  USING
    us_dli_src_iid TYPE /1bea/us_CRMB_DL_DLI_SRC_IID
    ut_dli_src_iid TYPE /1bea/ut_CRMB_DL_DLI_SRC_IID
  CHANGING
    cv_row         TYPE BAPI_LINE.
   READ TABLE ut_dli_src_iid WITH KEY
              LOGSYS = us_dli_src_iid-LOGSYS
              OBJTYPE = us_dli_src_iid-OBJTYPE
              SRC_HEADNO = us_dli_src_iid-SRC_HEADNO
              SRC_ITEMNO = us_dli_src_iid-SRC_ITEMNO
                             TRANSPORTING NO FIELDS.
   cv_row = sy-tabix.
ENDFORM. " determine_row
