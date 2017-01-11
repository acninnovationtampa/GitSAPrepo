REPORT /1BEA/R_CRMB_DL_ERRORLIST .
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
INCLUDE BEA_BASICS_CON.
TYPE-POOLS:
  SLIS,
  KKBLO.
TABLES :
  /1BEA/CRMB_DLI.
CONSTANTS:
  GC_APPL                 TYPE BEF_APPL    VALUE 'CRMB',
  GC_YES                  TYPE C           VALUE 'J'.
DATA:
  GV_APPL                 TYPE BEF_APPL,
  GS_VARIANT              LIKE DISVARIANT,
  GV_ANSWER               TYPE C,
  GT_DLI_WRK              TYPE /1BEA/T_CRMB_DLI_WRK,
  GT_DLI_DRV              TYPE /1BEA/T_CRMB_DLI_WRK,
  GT_EXTAB                TYPE SLIS_T_EXTAB WITH HEADER LINE,
  GV_OK_CODE              TYPE SYUCOMM,
  GV_LOGHNDL              TYPE BALLOGHNDL,
  GV_RC                   TYPE SY-SUBRC,
  GV_AUTH_ERROR           TYPE C,
  GT_RETURN               TYPE BEAT_RETURN.

* Event DL_RERR0
  INCLUDE %2f1BEA%2fX_CRMBDL_RERR00INC_F1CON.
****************
*=====================================================================
* Implementation part
*=====================================================================
*---------------------------------------------------------------------
* Selection Screen
*---------------------------------------------------------------------
*.....................................................................
* Definition of the Selection Screen
*.....................................................................
 SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001. "#EC *
SELECT-OPTIONS S001_010 FOR /1BEA/CRMB_DLI-SRC_HEADNO.
SELECT-OPTIONS S001_020 FOR /1BEA/CRMB_DLI-P_SRC_HEADNO.
 SELECTION-SCREEN END OF BLOCK 001.
 SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002. "#EC *
SELECT-OPTIONS S002_010 FOR /1BEA/CRMB_DLI-BILL_ORG.
SELECT-OPTIONS S002_020 FOR /1BEA/CRMB_DLI-INVCR_DATE.
SELECT-OPTIONS S002_030 FOR /1BEA/CRMB_DLI-PAYER.
SELECT-OPTIONS S002_040 FOR /1BEA/CRMB_DLI-SOLD_TO_PARTY.
SELECT-OPTIONS S002_050 FOR /1BEA/CRMB_DLI-BILL_TYPE.
SELECT-OPTIONS S002_060 FOR /1BEA/CRMB_DLI-BILL_CATEGORY.
 SELECTION-SCREEN END OF BLOCK 002.
 SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE TEXT-003. "#EC *
SELECT-OPTIONS S003_010 FOR /1BEA/CRMB_DLI-SRC_USER.
SELECT-OPTIONS S003_020 FOR /1BEA/CRMB_DLI-SRC_DATE.
 SELECTION-SCREEN END OF BLOCK 003.
*---------------------------------------------------------------------
* Threshold for selection
*---------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK ROW WITH FRAME TITLE TEXT-ROW. "#EC *
PARAMETERS: P_MAXROW     TYPE BEA_NR_OF_ENTRIES DEFAULT 100.
SELECTION-SCREEN END OF BLOCK ROW.
*-------------------------------------------------------------
* Event : INITIALIZATION
*--------------------------------------------------------------
INITIALIZATION.
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
*...................................................................
* Setting of texts
*...................................................................
*...................................................................
* Setting of the status
*...................................................................
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
       EXPORTING
            P_STATUS  = 'SELEL'
            P_PROGRAM = GC_PROG_STAT_TITLE
       TABLES
            P_EXCLUDE = GT_EXTAB
       EXCEPTIONS
            OTHERS    = 0.
*...................................................................
* Setting of title bar
*...................................................................
  SET TITLEBAR 'DL_ERRORLIST' OF PROGRAM GC_PROG_STAT_TITLE.
*---------------------------------------------------------------------
* Setting of "old" tabstrip (important after START-OF-SELECTION event)
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN
*---------------------------------------------------------------------
AT SELECTION-SCREEN.

    GV_OK_CODE = SY-UCOMM.
    CASE GV_OK_CODE.
      WHEN 'RSAP'.
        CLEAR GV_APPL.
        SET PARAMETER ID 'GC_APPL_ID' FIELD GV_APPL.
        MESSAGE S003(BEA).
      WHEN 'ERLI'.
        PERFORM POPUP_TO_CONFIRM_STEP CHANGING GV_ANSWER.
        IF GV_ANSWER = gc_yes.
          PERFORM DATA_INITIALIZATION.
          PERFORM DUELIST_SELECT_ITEMS.
          IF GT_DLI_WRK IS INITIAL AND GT_DLI_DRV IS INITIAL.
            MESSAGE S130(BEA).
            EXIT.
          ENDIF.
          PERFORM DUELIST_ERRORLIST.
        ENDIF.
      WHEN 'SPAL'.                 "display variant
        PERFORM ALV_VARIANT_SELECT.
      WHEN 'PROTE'.
        IF NOT Gt_return[] IS INITIAL.
          PERFORM DISPLAY_PROTOCOL.
        ELSE.
          MESSAGE S199(BEA).
        ENDIF.
    ENDCASE.
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN ON EXIT-COMMAND
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON EXIT-COMMAND.
*---------------------------------------------------------------------
* Event : START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.
  PERFORM DATA_INITIALIZATION.
  PERFORM DUELIST_SELECT_ITEMS.
  IF GT_DLI_WRK IS INITIAL AND
     GT_DLI_DRV IS INITIAL AND
     GV_AUTH_ERROR IS INITIAL.
    MESSAGE S130(BEA).
    EXIT.
  ENDIF.
  IF SY-BATCH IS INITIAL.
    PERFORM DUELIST_DISPLAY.
  ENDIF.
*---------------------------------------------------------------------
* Event : END-OF-SELECTION
*---------------------------------------------------------------------
END-OF-SELECTION.
  IF NOT SY-BATCH IS INITIAL.
     PERFORM DUELIST_ERRORLIST.
     PERFORM DISPLAY_PROTOCOL.
  ENDIF.

*-------------------------------------------------------------------*
*       FORM duelist_select_items                                   *
*-------------------------------------------------------------------*
*     select duelist-entries for further processing                 *
*-------------------------------------------------------------------*
FORM DUELIST_SELECT_ITEMS.
DATA :
  LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
  LS_DLI_WRK_HLP  TYPE /1BEA/S_CRMB_DLI_WRK,
  LRS_BILL_STATUS TYPE BEARS_BILL_STATUS,
  LRT_BILL_STATUS TYPE BEART_BILL_STATUS,
  LRS_INCOMP_ID   TYPE BEARS_INCOMP_ID,
  LRT_INCOMP_ID   TYPE BEART_INCOMP_ID,
  LV_TABIX        LIKE SY-TABIX,
  LV_NR_OF_ENTRIES TYPE BEA_NR_OF_ENTRIES.
DATA :
  LRS_DERIV_CATEGORY   TYPE BEARS_DERIV_CATEGORY,
  LRT_DERIV_CATEGORY   TYPE BEART_DERIV_CATEGORY,
  LRS_BILL_STATUS_DRV  TYPE BEARS_BILL_STATUS,
  LRT_BILL_STATUS_DRV  TYPE BEART_BILL_STATUS,
  LRS_INCOMP_ID_DRV    TYPE BEARS_INCOMP_ID,
  LRT_INCOMP_ID_DRV    TYPE BEART_INCOMP_ID,
  LV_NR_OF_ENTRIES_DRV TYPE BEA_NR_OF_ENTRIES.

* Ranges for normal Items
* BILL_STATUS in der Selektion ??
  LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW    = GC_BILLSTAT_TODO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW    = GC_BILLSTAT_NO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.
  LRS_INCOMP_ID-SIGN    = GC_INCLUDE.
  LRS_INCOMP_ID-OPTION  = GC_NOT_EQUAL.
  LRS_INCOMP_ID-LOW     = GC_INCOMP_OK.
  APPEND LRS_INCOMP_ID TO LRT_INCOMP_ID.

* Ranges for derived items
  LRS_DERIV_CATEGORY-SIGN   = GC_EXCLUDE.
  LRS_DERIV_CATEGORY-OPTION = GC_EQUAL.
  LRS_DERIV_CATEGORY-LOW    = GC_DERIV_ORIGIN.
  APPEND LRS_DERIV_CATEGORY TO LRT_DERIV_CATEGORY.
  LRS_BILL_STATUS_DRV-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS_DRV-OPTION = GC_EQUAL.
  LRS_BILL_STATUS_DRV-LOW    = GC_BILLSTAT_DONE.
  APPEND LRS_BILL_STATUS_DRV TO LRT_BILL_STATUS_DRV.
  LRS_INCOMP_ID_DRV-SIGN    = GC_INCLUDE.
  LRS_INCOMP_ID_DRV-OPTION  = GC_EQUAL.
  LRS_INCOMP_ID_DRV-LOW     = GC_INCOMP_REJECT.
  APPEND LRS_INCOMP_ID_DRV TO LRT_INCOMP_ID_DRV.
  LRS_INCOMP_ID_DRV-LOW     = GC_INCOMP_CANCEL.
  APPEND LRS_INCOMP_ID_DRV TO LRT_INCOMP_ID_DRV.

IF SY-BATCH IS INITIAL AND GV_OK_CODE NE 'ERLI'.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETCOUNT'
      EXPORTING
           IRT_INCOMP_ID   = LRT_INCOMP_ID
           IRT_BILL_STATUS = LRT_BILL_STATUS
           IRT_SRC_HEADNO   = S001_010[]
           IRT_P_SRC_HEADNO   = S001_020[]
           IRT_BILL_ORG   = S002_010[]
           IRT_INVCR_DATE   = S002_020[]
           IRT_PAYER   = S002_030[]
           IRT_SOLD_TO_PARTY   = S002_040[]
           IRT_BILL_TYPE   = S002_050[]
           IRT_BILL_CATEGORY   = S002_060[]
           IRT_SRC_USER   = S003_010[]
           IRT_SRC_DATE   = S003_020[]
       IMPORTING
           EV_NR_OF_ENTRIES = LV_NR_OF_ENTRIES.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETCOUNT'
      EXPORTING
         IRT_BILL_STATUS     = LRT_BILL_STATUS_DRV
         IRT_DERIV_CATEGORY  = LRT_DERIV_CATEGORY
         IRT_INCOMP_ID       = LRT_INCOMP_ID_DRV
           IRT_SRC_HEADNO   = S001_010[]
           IRT_P_SRC_HEADNO   = S001_020[]
           IRT_BILL_ORG   = S002_010[]
           IRT_INVCR_DATE   = S002_020[]
           IRT_PAYER   = S002_030[]
           IRT_SOLD_TO_PARTY   = S002_040[]
           IRT_BILL_TYPE   = S002_050[]
           IRT_BILL_CATEGORY   = S002_060[]
           IRT_SRC_USER   = S003_010[]
           IRT_SRC_DATE   = S003_020[]
       IMPORTING
           EV_NR_OF_ENTRIES = LV_NR_OF_ENTRIES_DRV.
  LV_NR_OF_ENTRIES = LV_NR_OF_ENTRIES + LV_NR_OF_ENTRIES_DRV.

  CALL FUNCTION 'BEA_RESTRICT_SELECTION'
       EXPORTING
         IV_NR_OF_ENTRIES  = LV_NR_OF_ENTRIES
         IV_OBJTYPE        = GC_BOR_DLI
         IV_MAXROWS        = P_MAXROW
      IMPORTING
         EV_NR_OF_ENTRIES  = LV_NR_OF_ENTRIES.
  IF LV_NR_OF_ENTRIES = 0.
    CLEAR GT_DLI_WRK.
    EXIT.
  ENDIF.
ENDIF.

* select normal items
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
       EXPORTING
            IRT_BILL_STATUS     = LRT_BILL_STATUS
            IRT_INCOMP_ID       = LRT_INCOMP_ID
           IRT_SRC_HEADNO = S001_010[]
           IRT_P_SRC_HEADNO = S001_020[]
           IRT_BILL_ORG = S002_010[]
           IRT_INVCR_DATE = S002_020[]
           IRT_PAYER = S002_030[]
           IRT_SOLD_TO_PARTY = S002_040[]
           IRT_BILL_TYPE = S002_050[]
           IRT_BILL_CATEGORY = S002_060[]
           IRT_SRC_USER = S003_010[]
           IRT_SRC_DATE = S003_020[]
           IV_MAXROWS      = LV_NR_OF_ENTRIES
       IMPORTING
            ET_DLI              = GT_DLI_WRK.
  SORT GT_DLI_WRK BY
                  DERIV_CATEGORY
                  LOGSYS
                  OBJTYPE
                  SRC_HEADNO
                  SRC_ITEMNO
                  INCOMP_ID DESCENDING.
  LOOP AT GT_DLI_WRK INTO LS_DLI_WRK.
    LV_TABIX = SY-TABIX.
    PERFORM AUTHORITY_CHECK USING GC_ACTV_DISPLAY
                                  LS_DLI_WRK-BILL_ORG
                                  LS_DLI_WRK-BILL_TYPE
                            CHANGING GV_RC.
    IF GV_RC NE 0.    "no authority
      DELETE GT_DLI_WRK INDEX LV_TABIX.
      GV_AUTH_ERROR = GC_YES.
    ENDIF.
    IF
       LS_DLI_WRK-DERIV_CATEGORY = LS_DLI_WRK_HLP-DERIV_CATEGORY AND
       LS_DLI_WRK-LOGSYS = LS_DLI_WRK_HLP-LOGSYS AND
       LS_DLI_WRK-OBJTYPE = LS_DLI_WRK_HLP-OBJTYPE AND
       LS_DLI_WRK-SRC_HEADNO = LS_DLI_WRK_HLP-SRC_HEADNO AND
       LS_DLI_WRK-SRC_ITEMNO = LS_DLI_WRK_HLP-SRC_ITEMNO
       .
       DELETE GT_DLI_WRK INDEX LV_TABIX.
    ENDIF.
    MOVE-CORRESPONDING LS_DLI_WRK TO LS_DLI_WRK_HLP.
  ENDLOOP.
  IF GV_AUTH_ERROR = GC_YES.
    MESSAGE I136(BEA).
  ENDIF.

* select derived items
  IF NOT LV_NR_OF_ENTRIES IS INITIAL.
    DESCRIBE TABLE GT_DLI_WRK LINES LV_TABIX.
    IF LV_NR_OF_ENTRIES GT LV_TABIX.
      LV_NR_OF_ENTRIES = LV_NR_OF_ENTRIES - LV_TABIX.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
       EXPORTING
         IV_SORTREL          = GC_SORT_BY_INTERNAL_REF
         IRT_BILL_STATUS     = LRT_BILL_STATUS_DRV
         IRT_DERIV_CATEGORY  = LRT_DERIV_CATEGORY
         IRT_INCOMP_ID       = LRT_INCOMP_ID_DRV
           IRT_SRC_HEADNO = S001_010[]
           IRT_P_SRC_HEADNO = S001_020[]
           IRT_BILL_ORG = S002_010[]
           IRT_INVCR_DATE = S002_020[]
           IRT_PAYER = S002_030[]
           IRT_SOLD_TO_PARTY = S002_040[]
           IRT_BILL_TYPE = S002_050[]
           IRT_BILL_CATEGORY = S002_060[]
           IRT_SRC_USER = S003_010[]
           IRT_SRC_DATE = S003_020[]
         IV_MAXROWS      = LV_NR_OF_ENTRIES
       IMPORTING
            ET_DLI              = GT_DLI_DRV.
  LOOP AT GT_DLI_DRV INTO LS_DLI_WRK.
    LV_TABIX = SY-TABIX.
*     check authority for billing org and bill-type
    PERFORM AUTHORITY_CHECK USING GC_ACTV_DISPLAY
                                  LS_DLI_WRK-BILL_ORG
                                  LS_DLI_WRK-BILL_TYPE
                            CHANGING GV_RC.
    IF GV_RC NE 0.    "no authority
      DELETE GT_DLI_DRV INDEX LV_TABIX.
      GV_AUTH_ERROR = GC_YES.
    ENDIF.
    IF
       LS_DLI_WRK-DERIV_CATEGORY = LS_DLI_WRK_HLP-DERIV_CATEGORY AND
       LS_DLI_WRK-LOGSYS = LS_DLI_WRK_HLP-LOGSYS AND
       LS_DLI_WRK-OBJTYPE = LS_DLI_WRK_HLP-OBJTYPE AND
       LS_DLI_WRK-SRC_HEADNO = LS_DLI_WRK_HLP-SRC_HEADNO AND
       LS_DLI_WRK-SRC_ITEMNO = LS_DLI_WRK_HLP-SRC_ITEMNO
       .
       DELETE GT_DLI_DRV INDEX LV_TABIX.
    ENDIF.
    MOVE-CORRESPONDING LS_DLI_WRK TO LS_DLI_WRK_HLP.
  ENDLOOP.
  IF GV_AUTH_ERROR = GC_YES.
    MESSAGE I136(BEA).
  ENDIF.

ENDFORM.

*-------------------------------------------------------------------*
*       FORM duelist_display                                        *
*-------------------------------------------------------------------*
*       start the display of the duelist                            *
*-------------------------------------------------------------------*
FORM DUELIST_DISPLAY.
  IF NOT GT_DLI_DRV IS INITIAL.
    APPEND LINES OF GT_DLI_DRV TO GT_DLI_WRK.
    SORT GT_DLI_WRK BY
                    LOGSYS
                    OBJTYPE
                    SRC_HEADNO.
  ENDIF.
  CALL FUNCTION '/1BEA/CRMB_DL_U_SHOWLIST'
       EXPORTING
            IT_DLI     = GT_DLI_WRK
            IS_VARIANT = GS_VARIANT
            IV_MODE    = GC_DL_ERRORLIST.

*  CALL SCREEN 100.
*  CLEAR Gv_ok_code.
ENDFORM.

*-------------------------------------------------------------------*
*       FORM duelist_errorlist                                      *
*-------------------------------------------------------------------*
*       Remove incmop_id  from selected duelist items               *
*-------------------------------------------------------------------*
FORM DUELIST_ERRORLIST.
  IF NOT GT_DLI_DRV IS INITIAL.
    APPEND LINES OF GT_DLI_DRV TO GT_DLI_WRK.
    SORT GT_DLI_WRK BY
                    LOGSYS
                    OBJTYPE
                    SRC_HEADNO.
  ENDIF.
*     create bill-documents
  CALL FUNCTION '/1BEA/CRMB_DL_O_ERRORLIST'
       EXPORTING
            IT_DLI_WRK      = GT_DLI_WRK
            IV_COMMIT_FLAG  = GC_COMMIT_ASYNC
       IMPORTING
            ET_RETURN   = GT_RETURN.

  IF GT_RETURN[] IS INITIAL.
    MESSAGE S131(BEA).
  ELSE.
    MESSAGE S132(BEA).
  ENDIF.
ENDFORM.

*-------------------------------------------------------------------*
*       FORM popup_to_confirm_step                                  *
*-------------------------------------------------------------------*
*       ........                                                    *
*-------------------------------------------------------------------*
*  -->  GV_ANSWER                                                   *
*-------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP CHANGING CV_ANSWER.
  CONSTANTS: LC_YES TYPE C VALUE 'Y'.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            TITEL          = TEXT-PT1
            TEXTLINE1      = TEXT-P01
            TEXTLINE2      = TEXT-P02
            DEFAULTOPTION  = LC_YES
            CANCEL_DISPLAY = GC_FALSE
       IMPORTING
            ANSWER         = CV_ANSWER.
ENDFORM.

*-------------------------------------------------------------------*
*       FORM authority_check                                        *
*-------------------------------------------------------------------*
*       ........                                                    *
*-------------------------------------------------------------------*
FORM AUTHORITY_CHECK USING UV_ACTION_TYPE   TYPE ACTIV_AUTH
                           UV_BILL_ORG      TYPE BEA_BILL_ORG
                           UV_BILL_TYPE     TYPE BEA_BILL_TYPE
                     CHANGING UV_RC       TYPE SY-SUBRC.

 CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
     EXPORTING
         IV_BILL_TYPE           = UV_BILL_TYPE
         IV_BILL_ORG            = UV_BILL_ORG
         IV_APPL                = GC_APPL
         IV_ACTVT               = UV_ACTION_TYPE
         IV_CHECK_DLI           = GC_TRUE
         IV_CHECK_BDH           = GC_FALSE
     EXCEPTIONS
         NO_AUTH                = 1.
 UV_RC = SY-SUBRC.

ENDFORM.

*-------------------------------------------------------------------*
*       FORM alv_variant_select                                     *
*-------------------------------------------------------------------*
*       ........                                                    *
*-------------------------------------------------------------------*
FORM ALV_VARIANT_SELECT.
  TYPE-POOLS: SLIS.
  DATA : LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LS_LAYOUT   TYPE SLIS_LAYOUT_ALV.
  DATA :
   LV_REPORT TYPE SYREPID VALUE '/1BEA/SAPLCRMB_DL_U'.

  IF GS_VARIANT IS INITIAL.
    GS_VARIANT-REPORT   = LV_REPORT.
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
*-------------------------------------------------------------------*
*       FORM display_protocol.                                      *
*-------------------------------------------------------------------*
*       ........                                                    *
*-------------------------------------------------------------------*
FORM DISPLAY_PROTOCOL.
    CALL FUNCTION 'BEA_AL_O_CREATE'
         EXPORTING
              iv_appl            = gc_appl
         IMPORTING
              ev_loghndl         = Gv_loghndl
         EXCEPTIONS
              log_already_exists = 1
              log_not_created     = 2
              others             = 3.
    IF sy-subrc = 1.
*get log handle from global buffer
      CALL FUNCTION 'BEA_AL_O_GETBUFFER'
            IMPORTING
                EV_LOGHNDL = Gv_loghndl.
    ELSEIF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  CALL FUNCTION 'BEA_AL_U_SHOW'
       EXPORTING
            iv_appl        = gc_appl
            iv_loghndl     = Gv_loghndl
            it_return      = gt_return
       EXCEPTIONS
            wrong_input    = 1
            no_log         = 2
            internal_error = 3
            no_authority   = 4
            others         = 5.
  IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CALL FUNCTION 'BEA_AL_O_REFRESH'.
ENDFORM.
*---------------------------------------------------------------------
*       FORM DATA_INITIALIZATION
*---------------------------------------------------------------------
FORM DATA_INITIALIZATION.
  CLEAR:
    GT_RETURN.
ENDFORM.     "DATA_INITIALIZATION
