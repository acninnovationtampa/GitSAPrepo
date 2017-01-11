REPORT /1BEA/R_CRMB_BD_MASS_CANCEL .
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
TYPE-POOLS: slis.

INCLUDE BEA_BASICS_CON.

TABLES: beas_crp_select,
       /1BEA/CRMB_BDH.
CONSTANTS:
  GC_APPL               TYPE BEF_APPL    VALUE 'CRMB'.

DATA: lv_appl       TYPE beas_crp_select-appl,
      lv_crp_guid   TYPE beas_crp_select-guid,
      lv_number     TYPE beas_crp_select-cr_number,
      lv_type       TYPE beas_crp_select-type,
      lv_errors     TYPE beas_crp_select-errors,
      lv_documents  TYPE beas_crp_select-documents,
      lv_date       TYPE beas_crp_select-maint_date,
      lv_time       TYPE beas_crp_select-maint_time,
      lv_user       TYPE beas_crp_select-maint_user,
      lt_crp        TYPE beat_crp,
      lrs_type      TYPE bears_crp_type,
      lt_extab      TYPE slis_t_extab,
      lv_appl_pid   TYPE bef_appl,
      lv_test       TYPE BEA_BOOLEAN.

DATA:
  GV_APPL             TYPE BEF_APPL,
  GV_OK_CODE          TYPE SYUCOMM,
  gt_bdh              TYPE /1bea/t_CRMB_BDH_wrk,
  gt_crp_guid         TYPE beart_crp_guid.

************************************************************************
* Get selection: Collective Run Data
************************************************************************

SELECTION-SCREEN: BEGIN OF BLOCK crp WITH FRAME TITLE text-001.

SELECT-OPTIONS:    pappl   FOR lv_appl                 NO-DISPLAY,
                   pguid   FOR lv_crp_guid             NO-DISPLAY,
                   pnumber FOR lv_number.

* PARAMETERS          ptype   TYPE bea_crp_type.

SELECT-OPTIONS:     puser   FOR lv_user DEFAULT sy-uname,
                    pdate   FOR lv_date,
                    ptime   FOR lv_time.
*                     perrors FOR lv_errors,
*                     pdocum  FOR lv_documents.

* PARAMETERS          pmaxrows TYPE bea_maxsel DEFAULT 100.

SELECTION-SCREEN END OF BLOCK crp.
***********************************************************************
*  Get selection: Billing Document Data
***********************************************************************
 SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002. "#EC *
SELECT-OPTIONS S002_010 FOR /1BEA/CRMB_BDH-HEADNO_EXT.
SELECT-OPTIONS S002_020 FOR /1BEA/CRMB_BDH-PAYER.
SELECT-OPTIONS S002_030 FOR /1BEA/CRMB_BDH-BILL_DATE.
SELECT-OPTIONS S002_040 FOR /1BEA/CRMB_BDH-BILL_TYPE.
SELECT-OPTIONS S002_050 FOR /1BEA/CRMB_BDH-BILL_CATEGORY.
SELECT-OPTIONS S002_060 FOR /1BEA/CRMB_BDH-BILL_ORG.
 SELECTION-SCREEN END OF BLOCK 002.

START-OF-SELECTION.

INITIALIZATION.
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
************************************************************************
* Set selection screen status
************************************************************************
 CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
   EXPORTING
     p_status  = 'SELCN'
     p_program = 'SAPLBEFB_SCREEN_CENTER'
   TABLES
     p_exclude = LT_EXTAB
   EXCEPTIONS
     OTHERS    = 1.

************************************************************************
* Evaluate FCodes
************************************************************************
AT SELECTION-SCREEN.

    GV_OK_CODE = SY-UCOMM.
    CASE GV_OK_CODE.
      WHEN 'TEST'.
        LV_TEST = 'X'.
        PERFORM PROCESSING
             USING LV_TEST.
    ENDCASE.

START-OF-SELECTION.
LV_TEST = GC_FALSE.
clear gt_bdh.
PERFORM PROCESSING
          USING LV_TEST.

************************************************************************
*      FROM billing_documents_select
************************************************************************
FORM BILLING_DOCUMENTS_SELECT
      CHANGING
        CV_COUNT TYPE i.
  DATA: lrt_appl      TYPE befrt_appl,
        lrt_number    TYPE beart_crp_number,
        lrt_type      TYPE beart_crp_type,
        lrt_date      TYPE beart_maint_date,
        lrt_time      TYPE beart_maint_time,
        lrt_user      TYPE beart_maint_user,
        lrt_crp_guid  TYPE beart_crp_guid,
        lt_crp        TYPE beat_crp.

  DATA: ls_crp          TYPE beas_crp,
        ls_crp_guid     TYPE bears_crp_guid,
        lt_crp_guid     TYPE beart_crp_guid,
        lt_bdh          TYPE /1bea/t_CRMB_BDH_wrk.

  lrt_appl      = pappl[].
  lrt_crp_guid  = pguid[].
  lrt_number    = pnumber[].
  lrt_date      = pdate[].
  lrt_time      = ptime[].
  lrt_user      = puser[].

  IF lrt_number IS INITIAL AND
    lrt_user IS INITIAL and
    lrt_date IS INITIAL and
    lrt_time IS INITIAL.
     MESSAGE s305(BEA).
    exit.
  endif.

* Get collective run information

 CALL FUNCTION 'BEA_CRP_O_GETLIST'
   EXPORTING
     irt_appl      = lrt_appl
     irt_crp_guid  = lrt_crp_guid
     irt_type      = lrt_type
     irt_number    = lrt_number
     irt_date      = lrt_date
     irt_time      = lrt_time
     irt_user      = lrt_user
   IMPORTING
     et_crp        = lt_crp.

 LOOP AT lt_crp INTO ls_crp.
   if ls_crp-type <> gc_crp_type_cancel.
     ls_crp_guid-sign = gc_include.
     ls_crp_guid-option = gc_equal.
     ls_crp_guid-low = ls_crp-guid.
     append ls_crp_guid to lt_crp_guid.
   endif.
 ENDLOOP.

* Get the billing documents from the collective run

 if lt_crp_guid is not initial.
   CALL FUNCTION '/1BEA/CRMB_BD_O_BDGETLIST'
      EXPORTING
        IRT_BDH_CRP_GUID      = lt_crp_guid
* Selection options for BD head
        IRT_BDH_HEADNO_EXT = S002_010[]
        IRT_BDH_PAYER = S002_020[]
        IRT_BDH_BILL_DATE = S002_030[]
        IRT_BDH_BILL_TYPE = S002_040[]
        IRT_BDH_BILL_CATEGORY = S002_050[]
        IRT_BDH_BILL_ORG = S002_060[]
      IMPORTING
        ET_BDH                = lt_bdh.
   gt_bdh = lt_bdh.
   gt_crp_guid = lt_crp_guid.
   describe table lt_bdh lines cv_count.
 else.
   Message s130(BEA).
 endif.
ENDFORM.                    "BILLING_DOCUMENTS_SELECT
*---------------------------------------------------------------------
*       FORM Processing
*---------------------------------------------------------------------
FORM PROCESSING
       USING
         LV_TEST TYPE BEA_BOOLEAN.
  DATA:   lv_count        TYPE i.

  clear lv_count.
  perform billing_documents_select changing lv_count.
  if gt_bdh is not INITIAL.
    if lv_test is initial.
      CALL FUNCTION '/1BEA/CRMB_BD_O_COLL_RUN_CANC'
        EXPORTING
          it_crp_guid           = gt_crp_guid
          it_bdh                = gt_bdh
          iv_commit_flag        = 'A'
          .
      message s185(BEA) with lv_count.
    else.
      message s186(BEA) with lv_count.
    endif.

  else.
    MESSAGE s130(BEA).
    exit.
  endif.

ENDFORM.                    "PROCESSING
