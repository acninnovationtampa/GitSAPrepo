REPORT /1BEA/R_CRMB_BD_TRANSFER .
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
TYPE-POOLS: SLIS.
INCLUDE: BEA_BASICS.

TABLES:
        /1BEA/CRMB_BDH,
        /1BEA/CRMB_BDI.
CONSTANTS:
  GC_APPL             TYPE BEF_APPL VALUE 'CRMB',
  GC_YES              TYPE C        VALUE 'J',
  GC_TRANS_STAT_ALL   TYPE BEA_TRANS_STAT VALUE ' ',
  GC_TRANS_STAT_BLOCK TYPE BEA_TRANS_STAT VALUE 'A',
  GC_TRANS_STAT_ERROR TYPE BEA_TRANS_STAT VALUE 'B'.
DATA:
  GV_APPL             TYPE BEF_APPL,
  GS_VARIANT          LIKE DISVARIANT,
  GV_ANSWER           TYPE C,
  GT_RETURN           TYPE beat_return,
  GT_EXTAB            TYPE SLIS_T_EXTAB WITH HEADER LINE,
  GV_OK_CODE          TYPE SYUCOMM,
  LT_BDH              TYPE /1BEA/T_CRMB_BDH_WRK,
  LT_BDI              TYPE /1BEA/T_CRMB_BDI_WRK.

*.....................................................................
* Definition of the Subsreens for the Selection Screen
*.....................................................................
 SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001. "#EC *
SELECT-OPTIONS S001_010 FOR /1BEA/CRMB_BDH-HEADNO_EXT.
SELECT-OPTIONS S001_020 FOR /1BEA/CRMB_BDH-PAYER.
SELECT-OPTIONS S001_030 FOR /1BEA/CRMB_BDH-BILL_DATE.
SELECT-OPTIONS S001_040 FOR /1BEA/CRMB_BDH-BILL_TYPE.
SELECT-OPTIONS S001_050 FOR /1BEA/CRMB_BDH-BILL_CATEGORY.
SELECT-OPTIONS S001_060 FOR /1BEA/CRMB_BDH-BILL_ORG.
 SELECTION-SCREEN END OF BLOCK 001.
 SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002. "#EC *
SELECT-OPTIONS S002_010 FOR /1BEA/CRMB_BDI-SRC_HEADNO.
SELECT-OPTIONS S002_020 FOR /1BEA/CRMB_BDI-SRC_ITEMNO.
SELECT-OPTIONS S002_030 FOR /1BEA/CRMB_BDI-SALES_ORG.
SELECT-OPTIONS S002_040 FOR /1BEA/CRMB_BDI-DIS_CHANNEL.
SELECT-OPTIONS S002_050 FOR /1BEA/CRMB_BDI-SERVICE_ORG.
 SELECTION-SCREEN END OF BLOCK 002.
 SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE TEXT-003. "#EC *
SELECT-OPTIONS S003_010 FOR /1BEA/CRMB_BDH-MAINT_USER.
SELECT-OPTIONS S003_020 FOR /1BEA/CRMB_BDH-MAINT_DATE.
 SELECTION-SCREEN END OF BLOCK 003.
*---------------------------------------------------------------------
* Threshold for selection
*---------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK ROW WITH FRAME TITLE TEXT-ROW. "#EC *
PARAMETERS: P_TRSTAT     TYPE BEA_TRANS_STAT AS LISTBOX VISIBLE LENGTH 35.
PARAMETERS: P_MAXROW     TYPE BEA_NR_OF_ENTRIES DEFAULT 100.
SELECTION-SCREEN END OF BLOCK ROW.

INITIALIZATION.
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
*.....................................................................
* Definition of the Subsreens for the Tabstrips
*.....................................................................
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
       EXPORTING
            P_STATUS  = 'SELRB'
            P_PROGRAM = 'SAPLBEFB_SCREEN_CENTER'
       TABLES
            P_EXCLUDE = GT_EXTAB
       EXCEPTIONS
            OTHERS    = 0.


* Setting of "old" tabstrip (important after START-OF-SELECTION event)

AT SELECTION-SCREEN.

    GV_OK_CODE = SY-UCOMM.
    CASE GV_OK_CODE.
      WHEN 'RSAP'.
        CLEAR GV_APPL.
        SET PARAMETER ID 'GC_APPL_ID' FIELD GV_APPL.
        MESSAGE S003(BEA).
      WHEN 'SPAL'.
        PERFORM ALV_VARIANT_SELECT.
      WHEN 'RELB'.
        PERFORM AUTHORITY_CHECK USING GC_ACTV_TRANSITION.
        PERFORM POPUP_TO_CONFIRM_STEP USING GV_ANSWER.
        IF GV_ANSWER = gc_yes.
          PERFORM DATA_INITIALIZATION.
          PERFORM DOCUMENTS_SELECT.
          IF LT_BDH IS INITIAL.
            MESSAGE S130(BEA).
            EXIT.
          ENDIF.
          PERFORM DOCUMENTS_RELEASE_TO_ACCOUNT.
        ENDIF.
      WHEN 'PROTE'.
        IF NOT GT_RETURN IS INITIAL.
          PERFORM DISPLAY_PROTOCOL.
        ELSE.
          MESSAGE S199(BEA).
        ENDIF.
    ENDCASE.

*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN ON EXIT-COMMAND
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON EXIT-COMMAND.

START-OF-SELECTION.
*---------------------------------------------------------------------
* Event : START-OF-SELECTION
* --------------------------------------------------------------------
    PERFORM DATA_INITIALIZATION.
    PERFORM AUTHORITY_CHECK USING GC_ACTV_DISPLAY.
    PERFORM DOCUMENTS_SELECT.
    IF LT_BDH IS INITIAL.
      MESSAGE S130(BEA).
      EXIT.
    ENDIF.
*---------------------------------------------------------------------
* Event : END-OF-SELECTION
*---------------------------------------------------------------------
  IF SY-BATCH IS INITIAL.
    PERFORM BD_DOCUMENT_DISPLAY.
  ELSE.
    PERFORM DOCUMENTS_RELEASE_TO_ACCOUNT.
    PERFORM DISPLAY_PROTOCOL.
  ENDIF.
*---------------------------------------------------------------------
*       FORM documents_release_to_account
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM DOCUMENTS_RELEASE_TO_ACCOUNT.

  CALL FUNCTION '/1BEA/CRMB_BD_O_TRANSFER'
       EXPORTING
            IT_BDH         = LT_BDH
            IV_COMMIT_FLAG = GC_COMMIT_ASYNC
       IMPORTING
            ET_RETURN      = GT_RETURN.
  IF GT_RETURN IS INITIAL.
    MESSAGE S131(BEA).
  ELSE.
    MESSAGE S132(BEA).
  ENDIF.
ENDFORM.


*********************************************************************
*       FORM documents_select
*********************************************************************
FORM DOCUMENTS_SELECT.
*....................................................................
* Declaration
*....................................................................
  DATA: lrs_TRANSFER_STATUS TYPE BEARS_TRANSFER_STATUS,
        lrt_TRANSFER_STATUS TYPE BEARt_TRANSFER_STATUS,
        LV_NR_OF_ENTRIES    TYPE BEA_NR_OF_ENTRIES,
        LV_RS_NR_OF_ENTRIES TYPE BEA_NR_OF_ENTRIES,
        LT_BDH_HLP          TYPE /1BEA/T_CRMB_BDH_WRK,
        LS_BDH              TYPE /1BEA/S_CRMB_BDH_WRK,
        LRS_BDH_GUID        TYPE BEARS_BDH_GUID,
        LRT_BDH_GUID        TYPE BEART_BDH_GUID.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Determine FIX Selection Criteria
*--------------------------------------------------------------------
   CLEAR: lrs_transfer_status, lrt_transfer_status.
   lrs_transfer_status-sign   = gc_include.
   lrs_transfer_status-option = gc_equal.
   CASE p_trstat.
     WHEN gc_trans_stat_block.
       lrs_transfer_status-low    = gc_transfer_block.
       APPEND lrs_transfer_status TO lrt_transfer_status.
     WHEN gc_trans_stat_error.
       lrs_transfer_status-low    = gc_transfer_todo.
       APPEND lrs_transfer_status TO lrt_transfer_status.
     WHEN OTHERS.
       lrs_transfer_status-low    = gc_transfer_todo.
       APPEND lrs_transfer_status TO lrt_transfer_status.
       lrs_transfer_status-low    = gc_transfer_block.
       APPEND lrs_transfer_status TO lrt_transfer_status.
   ENDCASE.

  EXPORT
    LRT_BDH_HEADNO_EXT = S001_010[]
    LRT_BDH_PAYER = S001_020[]
    LRT_BDH_BILL_DATE = S001_030[]
    LRT_BDH_BILL_TYPE = S001_040[]
    LRT_BDH_BILL_CATEGORY = S001_050[]
    LRT_BDH_BILL_ORG = S001_060[]
    LRT_BDH_MAINT_USER = S003_010[]
    LRT_BDH_MAINT_DATE = S003_020[]
    LRT_BDI_SRC_HEADNO = S002_010[]
    LRT_BDI_SRC_ITEMNO = S002_020[]
    LRT_BDI_SALES_ORG = S002_030[]
    LRT_BDI_DIS_CHANNEL = S002_040[]
    LRT_BDI_SERVICE_ORG = S002_050[]
    LRT_TRANSFER_STATUS = LRT_TRANSFER_STATUS
    TO MEMORY ID 'SEL_CRIT_BD'.
*--------------------------------------------------------------------
* Select BDs
*--------------------------------------------------------------------
  IF SY-BATCH EQ GC_TRUE.
*....................................................................
*   BATCH? ->  only BDHs
*....................................................................
    IF
      S002_010[] IS INITIAL AND
      S002_020[] IS INITIAL AND
      S002_030[] IS INITIAL AND
      S002_040[] IS INITIAL AND
      S002_050[] IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDHGETLIST'
        EXPORTING
           IRT_TRANSFER_STATUS = LRT_TRANSFER_STATUS
           IRT_HEADNO_EXT = S001_010[]
           IRT_PAYER = S001_020[]
           IRT_BILL_DATE = S001_030[]
           IRT_BILL_TYPE = S001_040[]
           IRT_BILL_CATEGORY = S001_050[]
           IRT_BILL_ORG = S001_060[]
           IRT_MAINT_USER = S003_010[]
           IRT_MAINT_DATE = S003_020[]
         IMPORTING
           ET_BDH           = LT_BDH.
    ELSE.
      CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
        EXPORTING
           IRT_BDH_TRANSFER_STATUS = LRT_TRANSFER_STATUS
           IRT_BDH_HEADNO_EXT = S001_010[]
           IRT_BDH_PAYER = S001_020[]
           IRT_BDH_BILL_DATE = S001_030[]
           IRT_BDH_BILL_TYPE = S001_040[]
           IRT_BDH_BILL_CATEGORY = S001_050[]
           IRT_BDH_BILL_ORG = S001_060[]
           IRT_BDH_MAINT_USER = S003_010[]
           IRT_BDH_MAINT_DATE = S003_020[]
           IRT_BDI_SRC_HEADNO = S002_010[]
           IRT_BDI_SRC_ITEMNO = S002_020[]
           IRT_BDI_SALES_ORG = S002_030[]
           IRT_BDI_DIS_CHANNEL = S002_040[]
           IRT_BDI_SERVICE_ORG = S002_050[]
         IMPORTING
           ET_BDH           = LT_BDH.
    ENDIF.
  ELSE.
    IF GV_OK_CODE NE 'RELD'.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDGETCOUNT'
        EXPORTING
          irt_BDH_TRANSFER_STATUS = lrt_TRANSFER_STATUS
          IRT_BDH_HEADNO_EXT = S001_010[]
          IRT_BDH_PAYER = S001_020[]
          IRT_BDH_BILL_DATE = S001_030[]
          IRT_BDH_BILL_TYPE = S001_040[]
          IRT_BDH_BILL_CATEGORY = S001_050[]
          IRT_BDH_BILL_ORG = S001_060[]
          IRT_BDH_MAINT_USER = S003_010[]
          IRT_BDH_MAINT_DATE = S003_020[]
          IRT_BDI_SRC_HEADNO = S002_010[]
          IRT_BDI_SRC_ITEMNO = S002_020[]
          IRT_BDI_SALES_ORG = S002_030[]
          IRT_BDI_DIS_CHANNEL = S002_040[]
          IRT_BDI_SERVICE_ORG = S002_050[]
        IMPORTING
          EV_NR_OF_ENTRIES = LV_NR_OF_ENTRIES.

      CALL FUNCTION 'BEA_RESTRICT_SELECTION'
           EXPORTING
             IV_NR_OF_ENTRIES  = LV_NR_OF_ENTRIES
             IV_MAXROWS        = P_MAXROW
          IMPORTING
             EV_NR_OF_ENTRIES  = LV_RS_NR_OF_ENTRIES.
      IF LV_RS_NR_OF_ENTRIES = 0.
        EXIT.
      ENDIF.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDGETLIST'
        EXPORTING
          IV_MAXROWS = LV_RS_NR_OF_ENTRIES
          irt_BDH_TRANSFER_STATUS = lrt_TRANSFER_STATUS
          IRT_BDH_HEADNO_EXT = S001_010[]
          IRT_BDH_PAYER = S001_020[]
          IRT_BDH_BILL_DATE = S001_030[]
          IRT_BDH_BILL_TYPE = S001_040[]
          IRT_BDH_BILL_CATEGORY = S001_050[]
          IRT_BDH_BILL_ORG = S001_060[]
          IRT_BDH_MAINT_USER = S003_010[]
          IRT_BDH_MAINT_DATE = S003_020[]
          IRT_BDI_SRC_HEADNO = S002_010[]
          IRT_BDI_SRC_ITEMNO = S002_020[]
          IRT_BDI_SALES_ORG = S002_030[]
          IRT_BDI_DIS_CHANNEL = S002_040[]
          IRT_BDI_SERVICE_ORG = S002_050[]
        IMPORTING
          ET_BDH = LT_BDH_HLP.

      LOOP AT LT_BDH_HLP INTO LS_BDH.
        lrs_BDH_GUID-sign   = gc_include.
        lrs_BDH_GUID-option = gc_equal.
        lrs_BDH_GUID-low    = ls_bdh-bdh_guid.
        APPEND lrs_BDH_GUID TO lrt_BDH_GUID.
      ENDLOOP.
      REFRESH S001_010[].
      REFRESH S001_020[].
      REFRESH S001_030[].
      REFRESH S001_040[].
      REFRESH S001_050[].
      REFRESH S001_060[].
      REFRESH S003_010[].
      REFRESH S003_020[].
      REFRESH S002_010[].
      REFRESH S002_020[].
      REFRESH S002_030[].
      REFRESH S002_040[].
      REFRESH S002_050[].
      CLEAR LV_RS_NR_OF_ENTRIES.
    ENDIF.

    CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
         EXPORTING
           IRT_BDH_BDH_GUID = LRT_BDH_GUID
           irt_BDH_TRANSFER_STATUS = lrt_TRANSFER_STATUS
             IRT_BDH_HEADNO_EXT = S001_010[]
             IRT_BDH_PAYER = S001_020[]
             IRT_BDH_BILL_DATE = S001_030[]
             IRT_BDH_BILL_TYPE = S001_040[]
             IRT_BDH_BILL_CATEGORY = S001_050[]
             IRT_BDH_BILL_ORG = S001_060[]
             IRT_BDH_MAINT_USER = S003_010[]
             IRT_BDH_MAINT_DATE = S003_020[]
             IRT_BDI_SRC_HEADNO = S002_010[]
             IRT_BDI_SRC_ITEMNO = S002_020[]
             IRT_BDI_SALES_ORG = S002_030[]
             IRT_BDI_DIS_CHANNEL = S002_040[]
             IRT_BDI_SERVICE_ORG = S002_050[]
             IV_MAXROWS  = LV_RS_NR_OF_ENTRIES
         IMPORTING
             ET_BDH      = LT_BDH
             ET_BDI      = LT_BDI.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------
*       FORM bd_document_display
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM BD_DOCUMENT_DISPLAY.

  CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
       EXPORTING
            IT_BDH                   = LT_BDH
            IT_BDI                   = LT_BDI
            IV_MODE                  = GC_BD_TRANSFER
            IS_VARIANT               = GS_VARIANT.

ENDFORM.
*---------------------------------------------------------------------
*       FORM alv_variant_select
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM ALV_VARIANT_SELECT.
  TYPE-POOLS: SLIS.
  DATA : LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LS_LAYOUT   TYPE SLIS_LAYOUT_ALV.
  DATA :
   LV_REPORT TYPE SYREPID VALUE '/1BEA/SAPLCRMB_BD_U'.

  IF GS_VARIANT IS INITIAL.
    GS_VARIANT-REPORT   = LV_REPORT.
    GS_VARIANT-HANDLE = 'BDH'.
  ENDIF.
  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
       EXPORTING
            I_USER_SPECIFIC           = GC_VARIANT_ALL
            I_DEFAULT                 = SPACE
            IT_DEFAULT_FIELDCAT       = LT_FIELDCAT[]
            I_LAYOUT                  = LS_LAYOUT
       IMPORTING
            ET_FIELDCAT               = LT_FIELDCAT[]
       CHANGING
            CS_VARIANT                = GS_VARIANT
       EXCEPTIONS
            WRONG_INPUT               = 1
            FC_NOT_COMPLETE           = 2
            NOT_FOUND                 = 3
            PROGRAM_ERROR             = 4
            OTHERS                    = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------
*       FORM popup_to_confirm_step
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
*  -->  GV_ANSWER
*---------------------------------------------------------------------
FORM POPUP_TO_CONFIRM_STEP USING UV_ANSWER TYPE C.
  CONSTANTS: LC_YES TYPE C VALUE 'Y'.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            TITEL          = TEXT-PT1
            TEXTLINE1      = TEXT-P01
            TEXTLINE2      = TEXT-P02
            DEFAULTOPTION  = LC_YES
            CANCEL_DISPLAY = GC_FALSE
       IMPORTING
            ANSWER         = UV_ANSWER.
ENDFORM.
*---------------------------------------------------------------------
*       FORM authority_check
*---------------------------------------------------------------------
FORM AUTHORITY_CHECK
  USING LV_ACTION_TYPE TYPE ACTIV_AUTH.
  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
      EXPORTING
          IV_BILL_TYPE           = SPACE
          IV_BILL_ORG            = SPACE
          IV_ACTVT               = LV_ACTION_TYPE
          IV_APPL                = GC_APPL
          IV_CHECK_DLI           = GC_FALSE
          IV_CHECK_BDH           = GC_TRUE
      EXCEPTIONS
          NO_AUTH                = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------
*       FORM DATA_INITIALIZATION
*---------------------------------------------------------------------
FORM DATA_INITIALIZATION.
  CLEAR:
    GT_RETURN.
ENDFORM.     "DATA_INITIALIZATION
*---------------------------------------------------------------------
*       FORM DISPLAY_PROTOCOL
*---------------------------------------------------------------------
FORM DISPLAY_PROTOCOL.
  DATA:
    lv_loghndl            type balloghndl.
  IF NOT GT_RETURN IS INITIAL.
    CALL FUNCTION 'BEA_AL_O_CREATE'
      EXPORTING
         iv_appl            = gc_appl
      IMPORTING
         ev_loghndl         = lv_loghndl
      EXCEPTIONS
         log_already_exists = 1
         log_not_created    = 2
         OTHERS             = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'BEA_AL_U_SHOW'
      EXPORTING
           iv_appl        = gc_appl
           iv_loghndl     = lv_loghndl
           it_return      = gt_return
           iv_title       = sy-title
      EXCEPTIONS
           wrong_input    = 1
           no_log         = 2
           internal_error = 3
           no_authority   = 4
           OTHERS         = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'BEA_AL_O_REFRESH'.
ENDFORM.     "DISPLAY_PROTOCOL
