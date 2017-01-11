REPORT /1BEA/R_CRMB_DL_JOBS_CREATE1 .
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:54:43
*
*======================================================================
*=====================================================================
* Definition part
*=====================================================================
*---------------------------------------------------------------------
* Includes
*---------------------------------------------------------------------
INCLUDE BEA_BASICS_CON.
*---------------------------------------------------------------------
* Type-Pools
*---------------------------------------------------------------------
TYPE-POOLS: SLIS.
TYPE-POOLS: KKBLO.
TYPE-POOLS: SSCR.
*---------------------------------------------------------------------
* Tables
*---------------------------------------------------------------------
TABLES : BEAS_BATCH_SERVER_NAME.
TABLES : /1BEA/CRMB_DLI.
*---------------------------------------------------------------------
* CONSTANTS
*---------------------------------------------------------------------
CONSTANTS: GV_TRDIR_DL_ERRORLIST TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_DL_ERRORLIST'.
CONSTANTS: GV_TRDIR_DL_RELEASE   TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_DL_RELEASE'.
CONSTANTS: GV_TRDIR_DL_PROCESS   TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_DL_PROCESS'.
CONSTANTS: GV_TRDIR_BD_PROCESS   TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_BD_PROCESS'.
CONSTANTS: GV_TRDIR_BD_RELEASE   TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_BD_TRANSFER'.
CONSTANTS: GV_TRDIR_CRP_DISPLAY  TYPE TRDIR-NAME
             VALUE '/1BEA/R_CRMB_BD_CRP_DISPLAY'.
CONSTANTS: GC_APPL               TYPE BEF_APPL    VALUE 'CRMB'.
*---------------------------------------------------------------------
* Data
*---------------------------------------------------------------------
DATA: L_RESTRICTION  TYPE SSCR_RESTRICT.
DATA: L_STR_OPT_LIST LIKE LINE OF L_RESTRICTION-OPT_LIST_TAB.
DATA: L_STR_ASS      LIKE LINE OF L_RESTRICTION-ASS_TAB.
DATA: LV_NOPOSI      TYPE NOPOSI.
DATA:
  BEGIN OF TY_DLI_FETCH.
    data:   bill_org      TYPE bea_bill_org.
    data:   SOLD_TO_PARTY    TYPE /1BEA/RS_CRMB_SOLD_TO_PARTY-LOW.
    data:   LOGSYS    TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID-LOGSYS.
    data:   OBJTYPE    TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID-OBJTYPE.
    data:   SRC_HEADNO    TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID-SRC_HEADNO.
DATA: END OF TY_DLI_FETCH.
DATA:
  BEGIN OF TY_PACKAGE_INFO.
    data:   bill_org      type bea_bill_org.
    data:   SOLD_TO_PARTY    type /1BEA/RS_CRMB_SOLD_TO_PARTY-LOW.
    DATA:   ITEM_NUMBER   TYPE NOPOSI.
    DATA:   DOC_NUMBER    TYPE NOPOSI.
    DATA:   JOB_NUMBER    TYPE I.
DATA: END OF TY_PACKAGE_INFO.
DATA:
  BEGIN OF TY_JOB_CONTROL.
    DATA: JOBNAME      TYPE TBTCJOB-JOBNAME.
    data: bill_org     type bea_bill_org.
    data: SOLD_TO_PARTY_low  type /1BEA/RS_CRMB_SOLD_TO_PARTY-LOW.
    data: SOLD_TO_PARTY_high type /1BEA/RS_CRMB_SOLD_TO_PARTY-HIGH.
    DATA: ITEM_NUMBER  TYPE NOPOSI.
    DATA: DOC_NUMBER TYPE NOPOSI.
    DATA: TARGETSERVER TYPE BTCTGTSRVR-SRVNAME.
DATA: END OF TY_JOB_CONTROL.
DATA: BEGIN OF TT_JOB_CONTROL OCCURS 0,
        JOBNAME       LIKE TBTCJOB-JOBNAME,
        bill_org      type bea_bill_org,
        SOLD_TO_PARTY_low  type /1BEA/RS_CRMB_SOLD_TO_PARTY-LOW,
        SOLD_TO_PARTY_high type /1BEA/RS_CRMB_SOLD_TO_PARTY-HIGH,
        ITEM_NUMBER  LIKE LV_NOPOSI,
        DOC_NUMBER TYPE NOPOSI,
        TARGETSERVER LIKE BTCTGTSRVR-SRVNAME,
     END OF TT_JOB_CONTROL.
DATA: gs_package_info         like ty_package_info.
DATA: gt_package_info         like SORTED TABLE OF gs_package_info
                              WITH UNIQUE KEY bill_org
                                             SOLD_TO_PARTY.
DATA: GV_ITEM_COUNT           TYPE I.
DATA: LV_TEST                 TYPE BEA_BOOLEAN.
DATA: LT_JOB_CONTROL          LIKE TY_JOB_CONTROL OCCURS 0.
DATA: LV_DD04V                TYPE DD04V.
DATA: LT_DFIES                TYPE BEFT_DFIES.
DATA: LS_TRDIR                TYPE TRDIR.
DATA: GT_EXTAB                TYPE SLIS_T_EXTAB WITH HEADER LINE.
DATA: LS_EXTAB                TYPE SLIS_EXTAB.
DATA: GV_OK_CODE              TYPE SYUCOMM.
DATA: LV_ERRORCODE            TYPE BEA_BOOLEAN.
DATA: LV_BETI                 TYPE BTCSTIME.
*=====================================================================
* Implementation part
*=====================================================================
*---------------------------------------------------------------------
* Selection Screen
*---------------------------------------------------------------------
*.....................................................................
* Definition for parallel processing
*.....................................................................
SELECTION-SCREEN BEGIN OF BLOCK CON2 WITH FRAME TITLE TEXT-F02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-J01 FOR FIELD P_BEDT.
PARAMETERS: P_BEDT  TYPE BTCSDATE DEFAULT SY-DATLO.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-J02 FOR FIELD P_BETI.
PARAMETERS: P_BETI  TYPE BTCSTIME DEFAULT SY-TIMLO.
SELECTION-SCREEN END OF LINE.
PARAMETERS: P_JOBC TYPE BEA_NUMBER_OF_JOBS1 DEFAULT 10.
SELECT-OPTIONS : S_SRVNAM FOR BEAS_BATCH_SERVER_NAME-BATCH_SERVER NO INTERVALS.
SELECTION-SCREEN END OF BLOCK CON2.
*.....................................................................
* Default data for the Billing
*.....................................................................
SELECTION-SCREEN BEGIN OF BLOCK CONT WITH FRAME TITLE TEXT-F01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (25) FOR FIELD P_TYPE.
PARAMETERS: P_TYPE TYPE BEAS_BILL_DEFAULT_F4-BILL_TYPE.
PARAMETERS: P_APPL TYPE BEAS_BILL_DEFAULT_F4-APPLICATION
              NO-DISPLAY DEFAULT 'CRMB'.
SELECTION-SCREEN POSITION 40.
SELECTION-SCREEN COMMENT (25) FOR FIELD P_BIL_DT.
PARAMETERS: P_BIL_DT TYPE BEAS_BILL_DEFAULT_F4-BILL_DATE.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK CONT.
*.....................................................................
* Definition of the Selection Screen
*.....................................................................
SELECTION-SCREEN BEGIN OF BLOCK ORG WITH FRAME TITLE TEXT-F03.
SELECT-OPTIONS S_BILORG FOR /1BEA/CRMB_DLI-BILL_ORG.
SELECTION-SCREEN END OF BLOCK ORG.

 SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001. "#EC *
SELECT-OPTIONS S001_020 FOR /1BEA/CRMB_DLI-INVCR_DATE.
SELECT-OPTIONS S001_030 FOR /1BEA/CRMB_DLI-PAYER.
SELECT-OPTIONS S001_040 FOR /1BEA/CRMB_DLI-SOLD_TO_PARTY.
SELECT-OPTIONS S001_050 FOR /1BEA/CRMB_DLI-BILL_TYPE.
SELECT-OPTIONS S001_060 FOR /1BEA/CRMB_DLI-BILL_CATEGORY.
 SELECTION-SCREEN END OF BLOCK 001.
*---------------------------------------------------------------------
* Event : INITIALIZATION
*---------------------------------------------------------------------
INITIALIZATION.
EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
L_STR_OPT_LIST-NAME = 'ONLY_EQ'.
L_STR_OPT_LIST-OPTIONS-EQ = 'X'.
INSERT L_STR_OPT_LIST INTO TABLE L_RESTRICTION-OPT_LIST_TAB.
L_STR_ASS-KIND    = 'S'.
L_STR_ASS-NAME    = 'S_SRVNAM'.
L_STR_ASS-SG_MAIN = 'I'.
L_STR_ASS-OP_MAIN = 'ONLY_EQ'.
INSERT L_STR_ASS INTO TABLE L_RESTRICTION-ASS_TAB.
CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
  EXPORTING
    RESTRICTION            = L_RESTRICTION
  EXCEPTIONS
    TOO_LATE               = 1
    REPEATED               = 2
    SELOPT_WITHOUT_OPTIONS = 3
    SELOPT_WITHOUT_SIGNS   = 4
    INVALID_SIGN           = 5
    EMPTY_OPTION_LIST      = 6
    INVALID_KIND           = 7
    REPEATED_KIND_A        = 8
    OTHERS                 = 9.
IF SY-SUBRC <> 0.
  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
*---------------------------------------------------------------------
* Setting of texts
*---------------------------------------------------------------------
*...................................................................
* Setting of the status
*...................................................................
LS_EXTAB-FCODE = 'SPAL'.
APPEND LS_EXTAB TO GT_EXTAB.
LS_EXTAB-FCODE = 'RSAP'.
APPEND LS_EXTAB TO GT_EXTAB.
CALL FUNCTION 'RS_TRDIR_SELECT'
  EXPORTING
    TRDIR_NAME      = GV_TRDIR_DL_ERRORLIST
  IMPORTING
    TRDIR_ROW       = LS_TRDIR
  EXCEPTIONS
    INTERNAL_ERROR  = 1
    PARAMETER_ERROR = 2
    NOT_FOUND       = 3
    OTHERS          = 4.
IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
  LS_EXTAB-FCODE = 'FVAN'.
  APPEND LS_EXTAB TO GT_EXTAB.
ENDIF.
CALL FUNCTION 'RS_TRDIR_SELECT'
  EXPORTING
    TRDIR_NAME      = GV_TRDIR_DL_RELEASE
  IMPORTING
    TRDIR_ROW       = LS_TRDIR
  EXCEPTIONS
    INTERNAL_ERROR  = 1
    PARAMETER_ERROR = 2
    NOT_FOUND       = 3
    OTHERS          = 4.
IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
  LS_EXTAB-FCODE = 'FVFR'.
  APPEND LS_EXTAB TO GT_EXTAB.
ENDIF.
CALL FUNCTION 'RS_TRDIR_SELECT'
  EXPORTING
    TRDIR_NAME      = GV_TRDIR_BD_PROCESS
  IMPORTING
    TRDIR_ROW       = LS_TRDIR
  EXCEPTIONS
    INTERNAL_ERROR  = 1
    PARAMETER_ERROR = 2
    NOT_FOUND       = 3
    OTHERS          = 4.
IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
  LS_EXTAB-FCODE = 'FABE'.
  APPEND LS_EXTAB TO GT_EXTAB.
ENDIF.
CALL FUNCTION 'RS_TRDIR_SELECT'
  EXPORTING
    TRDIR_NAME      = GV_TRDIR_BD_RELEASE
  IMPORTING
    TRDIR_ROW       = LS_TRDIR
  EXCEPTIONS
    INTERNAL_ERROR  = 1
    PARAMETER_ERROR = 2
    NOT_FOUND       = 3
    OTHERS          = 4.
IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
  LS_EXTAB-FCODE = 'FAFR'.
  APPEND LS_EXTAB TO GT_EXTAB.
ENDIF.
CALL FUNCTION 'RS_TRDIR_SELECT'
  EXPORTING
    TRDIR_NAME      = GV_TRDIR_CRP_DISPLAY
  IMPORTING
    TRDIR_ROW       = LS_TRDIR
  EXCEPTIONS
    INTERNAL_ERROR  = 1
    PARAMETER_ERROR = 2
    NOT_FOUND       = 3
    OTHERS          = 4.
IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
  LS_EXTAB-FCODE = 'SAAN'.
  APPEND LS_EXTAB TO GT_EXTAB.
ENDIF.
CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
  EXPORTING
    P_STATUS  = 'SELDLJ'
    P_PROGRAM = GC_PROG_STAT_TITLE
  TABLES
    P_EXCLUDE = GT_EXTAB
  EXCEPTIONS
    OTHERS    = 0.
*...................................................................
* Setting of title bar
*...................................................................
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN OUTPUT
*---------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  IF P_BEDT IS INITIAL OR P_BEDT <  SY-DATUM.
    P_BEDT = SY-DATUM.
    P_BETI = SY-TIMLO.
  ELSEIF P_BEDT =  SY-DATUM AND P_BETI < SY-TIMLO.
    P_BETI = SY-TIMLO.
  ENDIF.

AT SELECTION-SCREEN ON P_TYPE.
* check bill_type
 if not P_TYPE is initial.
   call function 'BEA_BTY_O_GETDETAIL'
        exporting
          iv_appl = gc_appl
          iv_bty  = p_type
        exceptions
          object_not_found = 1.
    if sy-subrc ne 0.
      MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
 endif.

*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN
*---------------------------------------------------------------------
AT SELECTION-SCREEN.
  IF P_BEDT IS INITIAL OR P_BEDT <  SY-DATUM.
    P_BEDT = SY-DATUM.
    P_BETI = SY-TIMLO.
  ELSEIF P_BEDT =  SY-DATUM AND P_BETI < SY-TIMLO.
    P_BETI = SY-TIMLO.
  ENDIF.
  IF P_JOBC IS INITIAL.
    P_JOBC = 1.
   ENDIF.
  GV_OK_CODE = SY-UCOMM.
  CASE GV_OK_CODE.
    WHEN 'TEST'.
      LV_TEST = 'X'.
      PERFORM PROCESSING
                USING    LV_TEST
                CHANGING LV_ERRORCODE.
      IF NOT LV_ERRORCODE IS INITIAL.
        MESSAGE S130(BEA).
      ELSE.
        PERFORM TEST_RESULT USING LV_TEST.
      ENDIF.
    WHEN 'FABE'.
      SUBMIT (GV_TRDIR_BD_PROCESS) VIA SELECTION-SCREEN AND RETURN.
    WHEN 'FAFR'.
      SUBMIT (GV_TRDIR_BD_RELEASE) VIA SELECTION-SCREEN AND RETURN.
    WHEN 'SAAN'.
      SUBMIT (GV_TRDIR_CRP_DISPLAY) VIA SELECTION-SCREEN AND RETURN.
    WHEN 'FVFR'.
      SUBMIT (GV_TRDIR_DL_RELEASE) VIA SELECTION-SCREEN AND RETURN.
    WHEN 'FVAN'.
      SUBMIT (GV_TRDIR_DL_ERRORLIST) VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN ON EXIT-COMMAND
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON EXIT-COMMAND.
*---------------------------------------------------------------------
* Event : START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.
LV_TEST = GC_FALSE.
PERFORM PROCESSING
          USING    LV_TEST
          CHANGING LV_ERRORCODE.
IF NOT LV_ERRORCODE IS INITIAL.
  MESSAGE S130(BEA).
ELSE.
  PERFORM TEST_RESULT USING LV_TEST.
ENDIF.
*---------------------------------------------------------------------
*       FORM duelist_select_items
*---------------------------------------------------------------------
*       select duelist-entries for further processing
*---------------------------------------------------------------------
FORM DUELIST_SELECT_ITEMS.

DATA:
  LRS_BILL_STATUS    TYPE BEARS_BILL_STATUS,
  LRT_BILL_STATUS    TYPE BEART_BILL_STATUS,
  LRS_BILL_BLOCK     TYPE BEARS_BILL_BLOCK,
  LRT_BILL_BLOCK     TYPE BEART_BILL_BLOCK,
  LRT_BILL_CATEGORY  TYPE BEART_BILL_CATEGORY,
  LRT_BILL_RELEVANCE TYPE BEART_ITEM_TYPE,
  LRT_BILL_ORG       TYPE BEART_BILL_ORG,
  LRT_BILL_TYPE      TYPE BEART_BILL_TYPE,
  LRT_ITEM_TYPE      TYPE BEART_ITEM_TYPE,
  LRT_ITEM_CATEGORY  TYPE BEART_ITEM_CATEGORY,
  LRT_CREDIT_DEBIT   TYPE BEART_CREDIT_DEBIT,
  LRT_MAINT_DATE     TYPE BEART_MAINT_DATE,
  LRT_MAINT_TIME     TYPE BEART_MAINT_TIME,
  LRT_MAINT_USER     TYPE BEART_MAINT_USER,
  LRT_SRVDOC_SOURCE  TYPE BEART_SRVDOC_SOURCE,
  LRT_BDI_GUID       TYPE BEART_BDI_GUID,
  LRT_DLI_GUID       TYPE BEART_DLI_GUID,
  LRS_INCOMP_ID      TYPE BEARS_INCOMP_ID,
  LRT_INCOMP_ID      TYPE BEART_INCOMP_ID,
  LRS_BILL_DATE      TYPE BEARS_BILL_DATE,
  LRT_BILL_DATE      TYPE BEART_BILL_DATE,
  LRS_PAYER          TYPE BEARS_PAYER,
  LRT_PAYER          TYPE BEART_PAYER,
  LRS_TERMS_OF_PAYMENT TYPE BEARS_TERMS_OF_PAYMENT,
  LRT_TERMS_OF_PAYMENT TYPE BEART_TERMS_OF_PAYMENT,
  LRT_DERIV_CATEGORY    TYPE /1BEA/RT_CRMB_DERIV_CATEGORY,
  LRT_INVCR_DATE    TYPE /1BEA/RT_CRMB_INVCR_DATE,
  LRT_LOGSYS    TYPE /1BEA/RT_CRMB_LOGSYS,
  LRT_OBJTYPE    TYPE /1BEA/RT_CRMB_OBJTYPE,
  LRT_P_LOGSYS    TYPE /1BEA/RT_CRMB_P_LOGSYS,
  LRT_P_OBJTYPE    TYPE /1BEA/RT_CRMB_P_OBJTYPE,
  LRT_P_SRC_HEADNO    TYPE /1BEA/RT_CRMB_P_SRC_HEADNO,
  LRT_SOLD_TO_PARTY    TYPE /1BEA/RT_CRMB_SOLD_TO_PARTY,
  LRT_SRC_DATE    TYPE /1BEA/RT_CRMB_SRC_DATE,
  LRT_SRC_GUID    TYPE /1BEA/RT_CRMB_SRC_GUID,
  LRT_SRC_HEADNO    TYPE /1BEA/RT_CRMB_SRC_HEADNO,
  LRT_SRC_ITEMNO    TYPE /1BEA/RT_CRMB_SRC_ITEMNO,
  LRT_SRC_USER    TYPE /1BEA/RT_CRMB_SRC_USER,
  LS_DLI_FETCH      LIKE TY_DLI_FETCH,
  LS_DLI_HEADKEY    TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID,
  lv_src_headno     type bea_src_headno,
  LV_CURSOR         TYPE cursor.

  LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW    = GC_BILLSTAT_TODO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_BILL_BLOCK-SIGN    = GC_INCLUDE.
  LRS_BILL_BLOCK-OPTION  = GC_EQUAL.
  LRS_BILL_BLOCK-LOW     = GC_FALSE.
  APPEND LRS_BILL_BLOCK TO LRT_BILL_BLOCK.
  LRS_INCOMP_ID-SIGN    = GC_INCLUDE.
  LRS_INCOMP_ID-OPTION  = GC_EQUAL.
  LRS_INCOMP_ID-LOW     = GC_INCOMP_OK.
  APPEND LRS_INCOMP_ID TO LRT_INCOMP_ID.

  LRT_INVCR_DATE[] = S001_020[].
  LRT_PAYER[] = S001_030[].
  LRT_SOLD_TO_PARTY[] = S001_040[].
  LRT_BILL_TYPE[] = S001_050[].
  LRT_BILL_CATEGORY[] = S001_060[].

CLEAR GV_ITEM_COUNT.

 OPEN CURSOR WITH HOLD LV_CURSOR FOR
   SELECT BILL_ORG
          SOLD_TO_PARTY
          LOGSYS OBJTYPE SRC_HEADNO FROM /1bea/CRMB_DLI
             WHERE incomp_id   IN lrt_incomp_id
               AND bill_status IN lrt_bill_status
               AND bill_block  IN lrt_bill_block
               AND bill_org    IN s_bilorg
               AND INVCR_DATE   IN S001_020[]
               AND PAYER   IN S001_030[]
               AND SOLD_TO_PARTY   IN S001_040[]
               AND BILL_TYPE   IN S001_050[]
               AND BILL_CATEGORY   IN S001_060[]
               ORDER BY LOGSYS OBJTYPE SRC_HEADNO.

 DO.

   FETCH NEXT CURSOR LV_CURSOR INTO CORRESPONDING FIELDS OF LS_DLI_FETCH.
   IF NOT sy-subrc IS INITIAL.
*    End of selection
     CLOSE CURSOR LV_CURSOR.
     EXIT.
   ENDIF.

   MOVE-CORRESPONDING LS_DLI_FETCH TO: GS_PACKAGE_INFO, LS_DLI_HEADKEY.

   ADD 1 TO GV_ITEM_COUNT.
   gs_package_info-item_number = 1.
   gs_package_info-doc_number = 0.
   if not ls_dli_headkey-src_headno = lv_src_headno.
     gs_package_info-doc_number = 1.
     lv_src_headno = ls_dli_headkey-src_headno.
   endif.
   collect gs_package_info into gt_package_info.

ENDDO.

ENDFORM.                    "DUELIST_SELECT_ITEMS
*---------------------------------------------------------------------
*       FORM Processing
*---------------------------------------------------------------------
FORM PROCESSING
       USING
         LV_TEST TYPE BEA_BOOLEAN
       CHANGING
         CV_ERRORCODE TYPE BEA_BOOLEAN.

  data: lv_current_srvnam(3)    type n.
  data: lv_docs_in_step         type i.
  data: lv_items_in_step        type i.
  data: lv_targetserver         type btctgtsrvr-srvname.
  data: ls_package_info         like ty_package_info.
  data: ls_job_control          like ty_job_control.
  data: lv_date_out6(6)         type c.
  data: lv_jobname              type tbtcjob-jobname.
  data: lv_jc(4)                type c.
  data: lv_job_count            type tbtcjob-jobcount.
  data: lv_jobname_billing      type tbtcjob-jobname
          value 'BILLING_+D_+T_++++_+H'.
  data: lv_job_to_be_closed     type bea_boolean.
  data: lv_job_number           type i.
  data: lv_current_job          type i.
  data: lv_item_count           type i.
  data: lv_target_job_size      type i.
  data: lv_bill_org             type bea_bill_org.
  data: lrs_bill_org            type bears_bill_org.
  data: lrt_bill_org            type beart_bill_org.
  data: lv_SOLD_TO_PARTY_low       type /1BEA/RS_CRMB_SOLD_TO_PARTY-LOW.
  data: lrs_SOLD_TO_PARTY          type /1BEA/RS_CRMB_SOLD_TO_PARTY.
  data: lrt_SOLD_TO_PARTY          type /1BEA/RT_CRMB_SOLD_TO_PARTY.

  data: lv_build_soldto_ranges  type bea_boolean.
  clear cv_errorcode.
  clear gt_package_info.
  clear lt_job_control.
  perform duelist_select_items.

  if gt_package_info is initial.
    cv_errorcode = gc_true.
    exit.
  endif.

  lv_target_job_size = gv_item_count / p_jobc.

  loop at gt_package_info into ls_package_info.
*   threashold reached or new billing organization?
    if lv_item_count >= lv_target_job_size or
       ls_package_info-bill_org <> lv_bill_org.
      add 1 to lv_job_number.
      clear lv_item_count.
    endif.
*   assign correct job number to package
    ls_package_info-job_number = lv_job_number.
    modify gt_package_info from ls_package_info.
    add ls_package_info-item_number to lv_item_count.
    lv_bill_org = ls_package_info-bill_org.
  endloop.

*   Check users select-option for Sold-To
*   In case there is either 'EQ' or 'NE'
*   we cannot build ranges
  LRT_SOLD_TO_PARTY[] = S001_040[].
  clear lv_build_soldto_ranges.
  find first occurrence of gc_equal
    in table LRT_SOLD_TO_PARTY.
  if sy-subrc <> 0.
    find first occurrence of gc_not_equal
    in table LRT_SOLD_TO_PARTY.
    if sy-subrc <> 0.
      lv_build_soldto_ranges = gc_true.
    endif.
  endif.

  do lv_job_number times.
    lv_current_job = sy-index.
    clear:
      lrs_bill_org,
      lrt_bill_org,
      lv_SOLD_TO_PARTY_low,
      lrs_SOLD_TO_PARTY,
      lrt_SOLD_TO_PARTY,
      lv_docs_in_step,
      lv_items_in_step.
*    handle job administration
    describe table s_srvnam lines sy-tfill.
    if sy-tfill = 0.
      clear s_srvnam.
    else.
      add 1 to lv_current_srvnam.
      read table s_srvnam index lv_current_srvnam.
      if not sy-subrc is initial.
        lv_current_srvnam = 001.
        read table s_srvnam index lv_current_srvnam.
      endif.
    endif.
    lv_targetserver = s_srvnam-low.
    unpack lv_current_job to lv_jc.
    lv_jobname = lv_jobname_billing.
    replace '++++' with lv_jc into lv_jobname.
    if p_bedt is initial or p_bedt <  sy-datum.
      p_bedt = sy-datum.
    endif.
    write p_bedt yymmdd to lv_date_out6.
    replace '+D' with lv_date_out6 into lv_jobname.
    replace '+T' with p_beti  into lv_jobname.
    replace '+H' with syst-host into lv_jobname.
    clear lv_job_count.
    if lv_test is initial.
      call function 'JOB_OPEN'
        exporting
          jobname  = lv_jobname
        importing
          jobcount = lv_job_count.
    endif.
*   determine selection criteria for job
    loop at gt_package_info into ls_package_info
      where job_number = lv_current_job.
      if lv_build_soldto_ranges = gc_false.
        lrs_SOLD_TO_PARTY-sign   = gc_include.
        lrs_SOLD_TO_PARTY-option = gc_rangeoption_eq.
        lrs_SOLD_TO_PARTY-low    = ls_package_info-SOLD_TO_PARTY.
        append lrs_SOLD_TO_PARTY to lrt_SOLD_TO_PARTY.
      else.
        if lv_SOLD_TO_PARTY_low is initial.
          lv_SOLD_TO_PARTY_low = ls_package_info-SOLD_TO_PARTY.
        endif.
      endif.
      add ls_package_info-item_number to lv_items_in_step.
      add ls_package_info-doc_number to lv_docs_in_step.
    endloop.
    lrs_bill_org-sign   = gc_include.
    lrs_bill_org-option = gc_rangeoption_eq.
    lrs_bill_org-low    = ls_package_info-bill_org.
    append lrs_bill_org to lrt_bill_org.
    if lv_build_soldto_ranges = gc_true.
      lrs_SOLD_TO_PARTY-sign   = gc_include.
      lrs_SOLD_TO_PARTY-option = gc_rangeoption_bt.
      lrs_SOLD_TO_PARTY-low    = lv_SOLD_TO_PARTY_low.
      lrs_SOLD_TO_PARTY-high   = ls_package_info-SOLD_TO_PARTY.
      append lrs_SOLD_TO_PARTY to lrt_SOLD_TO_PARTY.
    endif.
    if lv_test is initial.
        S001_040[] = LRT_SOLD_TO_PARTY[].
      submit (gv_trdir_dl_process)
        via job lv_jobname
        number  lv_job_count
        with p_type   = p_type
        with p_bil_dt = p_bil_dt
        with s002_010 IN lrt_bill_org
            WITH S002_020 IN S001_020[]
            WITH S002_030 IN S001_030[]
            WITH S002_040 IN S001_040[]
            WITH S002_050 IN S001_050[]
            WITH S002_060 IN S001_060[]
        and return.
    endif.
    clear ls_job_control.
    ls_job_control-jobname = lv_jobname.
    ls_job_control-targetserver = lv_targetserver.
    ls_job_control-item_number  = lv_items_in_step.
    ls_job_control-doc_number   = lv_docs_in_step.
    ls_job_control-bill_org     = ls_package_info-bill_org.
    ls_job_control-SOLD_TO_PARTY_low = lv_SOLD_TO_PARTY_low.
    ls_job_control-SOLD_TO_PARTY_high = ls_package_info-SOLD_TO_PARTY.
    append ls_job_control to lt_job_control.
    if lv_test is initial.
        lv_beti = p_beti.
        get time.
        if p_beti is initial or
          ( p_bedt = sy-datum and p_beti <  sy-uzeit ).
          lv_beti = sy-timlo + 10.
        endif.
        call function 'JOB_CLOSE'
          exporting
            jobname      = lv_jobname
            jobcount     = lv_job_count
            sdlstrtdt    = p_bedt
            sdlstrttm    = lv_beti
            targetserver = lv_targetserver.
    endif.
  enddo.
ENDFORM.
*---------------------------------------------------------------------
*       FORM Test_Result
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
*  -->
*---------------------------------------------------------------------
FORM TEST_RESULT USING LV_TEST TYPE C.

DATA: LT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV.
DATA: LS_FIELDCAT   TYPE SLIS_FIELDCAT_ALV.
DATA: LV_GRID_TITLE TYPE LVC_TITLE.

CLEAR LS_FIELDCAT.
LS_FIELDCAT-COL_POS = 1.
LS_FIELDCAT-FIELDNAME = 'JOBNAME'.
LS_FIELDCAT-TABNAME = 'TT_JOB_CONTROL'.
LS_FIELDCAT-SELTEXT_L = TEXT-AL1.
LS_FIELDCAT-SELTEXT_M = LS_FIELDCAT-SELTEXT_L.
LS_FIELDCAT-SELTEXT_S = LS_FIELDCAT-SELTEXT_L.
APPEND LS_FIELDCAT TO LT_FIELDCAT.
clear ls_fieldcat.
ls_fieldcat-col_pos = 2.
ls_fieldcat-fieldname = 'BILL_ORG'.
ls_fieldcat-tabname = 'TT_JOB_CONTROL'.
ls_fieldcat-seltext_l = text-al0.
ls_fieldcat-seltext_m = ls_fieldcat-seltext_l.
ls_fieldcat-seltext_s = ls_fieldcat-seltext_l.
append ls_fieldcat to lt_fieldcat.
clear ls_fieldcat.
ls_fieldcat-col_pos = 3.
ls_fieldcat-fieldname = 'SOLD_TO_PARTY_LOW'.
ls_fieldcat-tabname = 'TT_JOB_CONTROL'.
ls_fieldcat-seltext_l = text-al6.
ls_fieldcat-seltext_m = ls_fieldcat-seltext_l.
ls_fieldcat-seltext_s = ls_fieldcat-seltext_l.
append ls_fieldcat to lt_fieldcat.
ls_fieldcat-col_pos = 4.
ls_fieldcat-fieldname = 'SOLD_TO_PARTY_HIGH'.
ls_fieldcat-tabname = 'TT_JOB_CONTROL'.
ls_fieldcat-seltext_l = text-al7.
ls_fieldcat-seltext_m = ls_fieldcat-seltext_l.
ls_fieldcat-seltext_s = ls_fieldcat-seltext_l.
append ls_fieldcat to lt_fieldcat.
CLEAR LS_FIELDCAT.
LS_FIELDCAT-COL_POS = 5.
LS_FIELDCAT-FIELDNAME = 'ITEM_NUMBER'.
LS_FIELDCAT-TABNAME = 'TT_JOB_CONTROL'.
LS_FIELDCAT-SELTEXT_L = TEXT-AL3.
LS_FIELDCAT-SELTEXT_M = LS_FIELDCAT-SELTEXT_L.
LS_FIELDCAT-SELTEXT_S = LS_FIELDCAT-SELTEXT_L.
APPEND LS_FIELDCAT TO LT_FIELDCAT.
CLEAR LS_FIELDCAT.
LS_FIELDCAT-COL_POS = 6.
LS_FIELDCAT-FIELDNAME = 'DOC_NUMBER'.
LS_FIELDCAT-TABNAME = 'TT_JOB_CONTROL'.
LS_FIELDCAT-SELTEXT_L = TEXT-AL5.
LS_FIELDCAT-SELTEXT_M = LS_FIELDCAT-SELTEXT_L.
LS_FIELDCAT-SELTEXT_S = LS_FIELDCAT-SELTEXT_L.
APPEND LS_FIELDCAT TO LT_FIELDCAT.
CLEAR LS_FIELDCAT.
LS_FIELDCAT-COL_POS = 7.
LS_FIELDCAT-FIELDNAME = 'TARGETSERVER'.
LS_FIELDCAT-TABNAME = 'TT_JOB_CONTROL'.
LS_FIELDCAT-SELTEXT_L = TEXT-AL4.
LS_FIELDCAT-SELTEXT_M = LS_FIELDCAT-SELTEXT_L.
LS_FIELDCAT-SELTEXT_S = LS_FIELDCAT-SELTEXT_L.
APPEND LS_FIELDCAT TO LT_FIELDCAT.
TT_JOB_CONTROL[] = LT_JOB_CONTROL[].
CASE LV_TEST.
  WHEN ' '.
    LV_GRID_TITLE = TEXT-PR1.
  WHEN 'X'.
    LV_GRID_TITLE = TEXT-PR2.
ENDCASE.
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
       I_STRUCTURE_NAME   = 'LT_JOB_CONTROL'
       I_GRID_TITLE       = LV_GRID_TITLE
       IT_FIELDCAT        = LT_FIELDCAT
  TABLES
       T_OUTTAB = TT_JOB_CONTROL
  EXCEPTIONS
       PROGRAM_ERROR = 1
       OTHERS        = 2.
ENDFORM.
