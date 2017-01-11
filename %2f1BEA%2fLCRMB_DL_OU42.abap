FUNCTION /1BEA/CRMB_DL_O_DOCFL_BDH_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IV_COMPLETE) TYPE  BOOLEAN OPTIONAL
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
*-------------------------------------------------------------------
* BEGIN DEFINITION
*-------------------------------------------------------------------
  DATA:
    LV_TABIX      TYPE SYTABIX,
    LV_TABIX_BDH  TYPE SYTABIX,
    LV_TABIX_ORD  TYPE SYTABIX,
    LV_TABIX_DLV  TYPE SYTABIX,
    LV_TABIX_INS  TYPE SYTABIX,
    LV_LEVEL      TYPE BEA_DFL_LEVEL,
    LV_TABIX_PRE  TYPE SYTABIX,
    LV_TABIX_SUC  TYPE SYTABIX,
    LV_MARK_GUID  TYPE BEA_BDH_GUID,
    LS_DFL_OUT    TYPE BEAS_DFL_OUT,
    LT_DFL_OUT    TYPE BEAT_DFL_OUT,
    LT_DFL_WRK    TYPE BEAT_DFL_WRK,
    LT_DLI        TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_BDI        TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI        TYPE /1BEA/T_CRMB_BDI_WRK,
    LT_BDI1       TYPE /1BEA/T_CRMB_BDI_WRK,
    LV_TRANS_TYPE TYPE BEA_TRANSFER_TYPE,
    LV_SUCCESSOR  TYPE BEA_BOOLEAN.

*--------------------------------------------------------------------
* END DEFINITION
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* BEGIN PROCESS
*--------------------------------------------------------------------
  LV_MARK_GUID = IS_BDH-BDH_GUID..
  IF IV_COMPLETE IS INITIAL.
    LV_LEVEL = GC_DFL_HEAD.
* Item Level docflow needed for Printing
  ELSE.
    LV_LEVEL = GC_DFL_ITEM.
  ENDIF.

  PERFORM GET_BDI
    USING    IS_BDH-BDH_GUID
    CHANGING LT_BDI.
*   care about sorting the relevant entries
  SORT LT_BDI BY ITEMNO_EXT.
  LOOP AT LT_BDI INTO LS_BDI.
    CLEAR: LT_DFL_OUT,
           LT_BDI1,
           LT_DLI.
*     get DLI / BDI / DFL
    PERFORM GET_DOCFLOW_LINKS_DLI
      USING    LS_BDI
      CHANGING LT_DLI
               LT_DFL_WRK
               LT_BDI1.
    PERFORM BUILD_DOCFLOW_DLI
      USING    LT_DLI
               LT_DFL_WRK
               LT_BDI1
               IS_BDH-BDH_GUID
               LV_LEVEL
      CHANGING LT_DFL_OUT
               ET_RETURN.

   IF LV_LEVEL = GC_DFL_ITEM.
*  Item Detail Docflow Needed For Printing
     INSERT LINES OF LT_DFL_OUT INTO TABLE ET_DOCFLOW.
   ELSE.

*     for every entry in BDI look for new entries,
*     that could belong to the docflow
     CLEAR LV_SUCCESSOR.
     LOOP AT LT_DFL_OUT INTO LS_DFL_OUT
            WHERE OBJTYPE <> GC_BOR_DLI.
       IF LV_MARK_GUID = LS_DFL_OUT-OBJ_GUID.
         LV_SUCCESSOR = GC_TRUE.
       ENDIF.
       READ TABLE ET_DOCFLOW TRANSPORTING NO FIELDS WITH KEY
                      LOGSYS     = LS_DFL_OUT-LOGSYS
                      OBJTYPE    = LS_DFL_OUT-OBJTYPE
                      SRC_HEADNO = LS_DFL_OUT-SRC_HEADNO.
       IF SY-SUBRC <> 0.
         CASE LS_DFL_OUT-OBJTYPE.
           WHEN GC_BOR_BDH.
             IF LV_MARK_GUID = LS_DFL_OUT-OBJ_GUID.
               LS_DFL_OUT-MARKED_ENTRY = GC_TRUE.
             ENDIF.
             IF LV_SUCCESSOR EQ GC_TRUE.
               LV_TABIX_INS = LV_TABIX + 1.
             ELSE.
               ADD 1 TO LV_TABIX_BDH.
               LV_TABIX_INS = LV_TABIX_BDH.
             ENDIF.
           WHEN OTHERS.
             IF LS_DFL_OUT-DFL_PRE_KIND = 'O'. "Order
               ADD 1 TO LV_TABIX_ORD.
               ADD 1 TO LV_TABIX_DLV.
               ADD 1 TO LV_TABIX_BDH.
               LV_TABIX_INS = LV_TABIX_ORD.
             ELSEIF LS_DFL_OUT-DFL_PRE_KIND = 'D'. "Delivery
               ADD 1 TO LV_TABIX_DLV.
               ADD 1 TO LV_TABIX_BDH.
               LV_TABIX_INS = LV_TABIX_DLV.
             ENDIF.
         ENDCASE.
         ADD 1 TO LV_TABIX.
         INSERT LS_DFL_OUT INTO ET_DOCFLOW INDEX LV_TABIX_INS.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDLOOP.
* Enrich data by accounting information
 PERFORM GET_DOCFLOW_ACC
   USING LV_TRANS_TYPE
   CHANGING ET_DOCFLOW.
* Enrich data by follow-up (CRM OneOrder)
 PERFORM GET_DOCFLOW_FOLLOWUP
   CHANGING ET_DOCFLOW.

* Event DL_ODFL5 for header specific enhancements
*--------------------------------------------------------------------
* END PROCESS
*--------------------------------------------------------------------
  IF NOT ET_RETURN IS INITIAL.
    MESSAGE E121(BEA) WITH IS_BDH-HEADNO_EXT RAISING REJECT.
  ENDIF.
ENDFUNCTION.
*--------------------------------------------------------------------*
*      Form GET_BDI
*--------------------------------------------------------------------*
FORM GET_BDI
  USING    IV_BDH_GUID TYPE BEA_BDH_GUID
  CHANGING CT_BDI      TYPE /1BEA/T_CRMB_BDI_WRK.
  DATA:
    LRS_BDH_GUID       TYPE BEARS_BDH_GUID,
    LRT_BDH_GUID       TYPE BEART_BDH_GUID,
    LT_BDI_WRK TYPE /1BEA/T_CRMB_BDI_WRK.

  FIELD-SYMBOLS:
    <LS_BDI_WRK> TYPE /1BEA/S_CRMB_BDI_WRK.

* Check in buffer first
  CALL FUNCTION '/1BEA/CRMB_BD_O_BUFFER_GET'
    IMPORTING
      ET_BDI_WRK = LT_BDI_WRK.
  IF LT_BDI_WRK is not initial.
    LOOP AT LT_BDI_WRK ASSIGNING <LS_BDI_WRK>
      WHERE BDH_GUID = IV_BDH_GUID.
      append <LS_BDI_WRK> TO CT_BDI.
    ENDLOOP.
  ENDIF.

* Otherwise read from DB
  CHECK CT_BDI is initial.
  LRS_BDH_GUID-SIGN    = GC_SIGN_INCLUDE.
  LRS_BDH_GUID-OPTION  = GC_RANGEOPTION_EQ.
  LRS_BDH_GUID-LOW     = IV_BDH_GUID.
  APPEND LRS_BDH_GUID TO LRT_BDH_GUID.
  CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
    EXPORTING
      IRT_BDH_GUID = LRT_BDH_GUID
    IMPORTING
      ET_BDI       = CT_BDI.
ENDFORM.    "GET_BDI
*--------------------------------------------------------------------*
*      Form GET_DOCFLOW_ACC
*--------------------------------------------------------------------*
 FORM GET_DOCFLOW_ACC
   USING    IV_TRANS_TYPE TYPE BEA_TRANSFER_TYPE
   CHANGING CT_DOCFLOW TYPE BEAT_DFL_OUT.

 CONSTANTS:
   lc_awtyp_bebd   TYPE awtyp    VALUE 'BEBD',
   lc_rec_type(5)                VALUE 'BKPF'.

 data:
   lv_appl        type bef_appl value gc_appl,
   lv_awref       type awref,
   lv_awtyp       type awtyp,
   lv_aworg       type aworg,
   ls_return      type bapiret2,
   lv_rfcdest     type rfcdest,
   lv_erp_logsys  type logsys,
   lv_own_system  type awsys,
   lt_bkpf        type standard table of bkpf,
   ls_bkpf        type bkpf,
   lv_shorttext   type swotbasdat-shorttext,
   LS_ACC_DFL_OUT type BEAS_DFL_OUT,
   lv_acc_index   type SYTABIX,
   lv_rfc_msg     type bapi_msg.

   LOOP AT CT_DOCFLOW INTO LS_ACC_DFL_OUT
     WHERE MARKED_ENTRY = GC_TRUE.
     LV_ACC_INDEX = SY-TABIX.
     EXIT.
   ENDLOOP.

   IF LS_ACC_DFL_OUT-TRANSFER_STATUS = gc_transfer_done.
* Get R/3 Destination
     CALL FUNCTION 'BEA_OBJ_O_ERP_DESTINATION'
       EXPORTING
         iv_appl        = lv_appl
       IMPORTING
         ev_rfcdest     = lv_rfcdest
         ev_logsys      = lv_erp_logsys
       EXCEPTIONS
         error_occurred = 1
         OTHERS         = 2.
     check sy-subrc = 0.
* Fill parameters
     unpack LS_ACC_DFL_OUT-SRC_HEADNO to lv_awref.
     lv_aworg = lv_appl.

* Call R/3- API
       CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
          IMPORTING
            own_logical_system = lv_own_system.
            lv_awtyp = lc_awtyp_bebd.
* Get description
       CALL FUNCTION 'SWO_TEXT_OBJTYPE'
        DESTINATION lv_rfcdest
          EXPORTING
            LANGUAGE  = sy-langu
            objtype   = lc_rec_type
          IMPORTING
            shorttext = lv_shorttext
          EXCEPTIONS
            communication_failure = 1  MESSAGE lv_rfc_msg
            system_failure        = 2  MESSAGE lv_rfc_msg.
       check sy-subrc = 0.
       CALL FUNCTION 'FI_DOCUMENT_READ'
        DESTINATION lv_rfcdest
          EXPORTING
            i_awtyp     = lv_awtyp
            i_awref     = lv_awref
            i_aworg     = lv_aworg
            i_awsys     = lv_own_system
          TABLES
            t_bkpf      = lt_bkpf
          EXCEPTIONS
            wrong_input = 1
            not_found   = 2
            others      = 3.
       check sy-subrc = 0.
* Enrich ET_DOCFLOW with Accounting Documents
       loop at lt_bkpf into ls_bkpf.
          LV_ACC_INDEX = LV_ACC_INDEX + 1.
          CLEAR LS_ACC_DFL_OUT.
          LS_ACC_DFL_OUT-description = lv_shorttext.
          LS_ACC_DFL_OUT-SRC_HEADNO  = ls_bkpf-belnr.
          LS_ACC_DFL_OUT-objtype     = lc_rec_type.
          LS_ACC_DFL_OUT-logsys      = lv_erp_logsys.
          LS_ACC_DFL_OUT-maint_date  = ls_bkpf-cpudt.
          LS_ACC_DFL_OUT-maint_time  = ls_bkpf-cputm.
          CONCATENATE ls_bkpf-bukrs ls_bkpf-belnr ls_bkpf-gjahr INTO ls_acc_dfl_out-obj_key RESPECTING BLANKS.
          INSERT LS_ACC_DFL_OUT INTO CT_DOCFLOW INDEX LV_ACC_INDEX.
       endloop.
   ENDIF.
 ENDFORM.
*--------------------------------------------------------------------*
*      Form GET_DOCFLOW_FOLLOWUP
*--------------------------------------------------------------------*
 FORM GET_DOCFLOW_FOLLOWUP
   CHANGING CT_DOCFLOW TYPE BEAT_DFL_OUT.

 data:
   LS_FUP_DFL_OUT TYPE BEAS_DFL_OUT,
   ls_object      type borident,
   lt_rolerange   type rolrange,
   ls_rolerange   like line of lt_rolerange,
   lt_links       type standard table of RELGRAPHLK,
   ls_links       type RELGRAPHLK,
   ls_orderadm_h  type CRMT_ORDERADM_H_WRK.

* Get current Billing Doc (marked entry)
   LOOP AT CT_DOCFLOW INTO LS_FUP_DFL_OUT
     WHERE MARKED_ENTRY = GC_TRUE.
     EXIT.
   ENDLOOP.

* Get DocFlow entries of OneOrder documents, where current Billing Doc is successor
   ls_object-objkey    = ls_fup_dfl_out-src_headno.
   ls_object-objtype   = 'BUS20810'.
   ls_rolerange-sign   = GC_INCLUDE.
   ls_rolerange-option = GC_EQUAL.
   ls_rolerange-low    = 'VORGAENGER'.
   append ls_rolerange to lt_rolerange.

   CALL FUNCTION 'NREL_GET_NEIGHBOURHOOD'
     EXPORTING
       is_object            = ls_object
       IT_ROLERANGE         = lt_rolerange
       I_DEPTH              = 1
     TABLES
       LINKS                = lt_links.

* Put OneOrder documents to DocFlow
   loop at lt_links into ls_links.
     clear LS_FUP_DFL_OUT.
     LS_FUP_DFL_OUT-obj_guid = ls_links-OBJKEY_B.

     CALL FUNCTION 'CRM_ORDERADM_H_READ_OW'
       EXPORTING
         iv_orderadm_h_guid               = ls_fup_dfl_out-obj_guid
       IMPORTING
         ES_ORDERADM_H_WRK                = ls_orderadm_h
       EXCEPTIONS
         ADMIN_HEADER_NOT_FOUND           = 1
         OTHERS                           = 2.
     IF sy-subrc = 0.
       LS_FUP_DFL_OUT-SRC_HEADNO       = ls_orderadm_h-object_id.
       LS_FUP_DFL_OUT-objtype          = ls_orderadm_h-OBJECT_TYPE.
       LS_FUP_DFL_OUT-SRC_PROCESS_TYPE = ls_orderadm_h-PROCESS_TYPE.
       LS_FUP_DFL_OUT-DFL_PRE_KIND     = 'O'.
       LS_FUP_DFL_OUT-logsys           = ls_orderadm_h-LOGICAL_SYSTEM.
       CONVERT TIME STAMP ls_orderadm_h-created_at
               TIME ZONE sy-zonlo INTO
               DATE LS_FUP_DFL_OUT-maint_date
               TIME LS_FUP_DFL_OUT-maint_time.
       INSERT LS_FUP_DFL_OUT INTO TABLE CT_DOCFLOW.
     endif.
   endloop.
 ENDFORM.
