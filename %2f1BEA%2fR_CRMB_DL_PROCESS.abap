REPORT /1BEA/R_CRMB_DL_PROCESS .
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
  GV_TRDIR_DL_ERRORLIST TYPE TRDIR-NAME  VALUE '/1BEA/R_CRMB_DL_ERRORLIST',
  GV_TRDIR_DL_RELEASE   TYPE TRDIR-NAME  VALUE '/1BEA/R_CRMB_DL_RELEASE',
  GV_TRDIR_BD_PROCESS   TYPE TRDIR-NAME  VALUE '/1BEA/R_CRMB_BD_PROCESS',
  GV_TRDIR_BD_RELEASE   TYPE TRDIR-NAME  VALUE '/1BEA/R_CRMB_BD_TRANSFER',
  GV_TRDIR_CRP_DISPLAY  TYPE TRDIR-NAME  VALUE '/1BEA/R_CRMB_BD_CRP_DISPLAY',
  GC_APPL               TYPE BEF_APPL    VALUE 'CRMB',
  gc_yes                type c           value 'J'.
DATA:
  LS_TRDIR            TYPE TRDIR,
  GV_APPL             TYPE BEF_APPL,
  GS_VARIANT          LIKE DISVARIANT,
  GV_ANSWER           TYPE C,
  GT_DLI_WRK          TYPE /1BEA/T_CRMB_DLI_WRK,
  GS_BILL_DEFAULT     TYPE BEAS_BILL_DEFAULT,
  GT_EXTAB            TYPE SLIS_T_EXTAB WITH HEADER LINE,
  LS_EXTAB            TYPE SLIS_EXTAB,
  GV_OK_CODE          TYPE SYUCOMM,
  GV_COMMIT           TYPE BEF_COMMIT,
  GRT_CRP_GUID        TYPE BEART_CRP_GUID,
  GRS_CRP_GUID        TYPE BEARS_CRP_GUID,
  GV_CRP_GUID         TYPE BEA_CRP_GUID,
  GV_NO_AUTHORITY     TYPE BEA_BOOLEAN,
  GV_RC               TYPE SY-SUBRC,
  GV_AUTH_ERROR       TYPE C,
  lt_crp              TYPE beat_crp.
*=====================================================================
* Implementation part
*=====================================================================
*---------------------------------------------------------------------
* Selection Screen
*---------------------------------------------------------------------
*.....................................................................
* Default data for the Billing
*.....................................................................
SELECTION-SCREEN BEGIN OF BLOCK CONT WITH FRAME
                                TITLE TEXT-F01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (31) FOR FIELD P_TYPE.
PARAMETERS: P_TYPE   TYPE BEAS_BILL_DEFAULT_F4-BILL_TYPE.
PARAMETERS: P_APPL TYPE BEAS_BILL_DEFAULT_F4-APPLICATION NO-DISPLAY
                             DEFAULT 'CRMB'.
SELECTION-SCREEN POSITION 52.
SELECTION-SCREEN COMMENT (24) FOR FIELD P_BIL_DT.
PARAMETERS: P_BIL_DT TYPE BEAS_BILL_DEFAULT_F4-BILL_DATE.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS S_DLIGD FOR /1BEA/CRMB_DLI-DLI_GUID NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK CONT.
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
*---------------------------------------------------------------------
* Event : INITIALIZATION
*---------------------------------------------------------------------
INITIALIZATION.
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
*---------------------------------------------------------------------
* Setting of texts
*---------------------------------------------------------------------
*...................................................................
* Setting of the status
*...................................................................
     CALL FUNCTION 'RS_TRDIR_SELECT'
       EXPORTING
         TRDIR_NAME            = GV_TRDIR_DL_ERRORLIST
       IMPORTING
         TRDIR_ROW             = LS_TRDIR
       EXCEPTIONS
         INTERNAL_ERROR        = 1
         PARAMETER_ERROR       = 2
         NOT_FOUND             = 3
         OTHERS                = 4.
     IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
       LS_EXTAB-FCODE = 'FVAN'.
       APPEND LS_EXTAB TO GT_EXTAB.
     ENDIF.
     CALL FUNCTION 'RS_TRDIR_SELECT'
       EXPORTING
         TRDIR_NAME            = GV_TRDIR_DL_RELEASE
       IMPORTING
         TRDIR_ROW             = LS_TRDIR
       EXCEPTIONS
         INTERNAL_ERROR        = 1
         PARAMETER_ERROR       = 2
         NOT_FOUND             = 3
         OTHERS                = 4.
     IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
       LS_EXTAB-FCODE = 'FVFR'.
       APPEND LS_EXTAB TO GT_EXTAB.
     ENDIF.
     CALL FUNCTION 'RS_TRDIR_SELECT'
       EXPORTING
         TRDIR_NAME            = GV_TRDIR_BD_PROCESS
       IMPORTING
         TRDIR_ROW             = LS_TRDIR
       EXCEPTIONS
         INTERNAL_ERROR        = 1
         PARAMETER_ERROR       = 2
         NOT_FOUND             = 3
         OTHERS                = 4.
     IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
       LS_EXTAB-FCODE = 'FABE'.
       APPEND LS_EXTAB TO GT_EXTAB.
     ENDIF.
     CALL FUNCTION 'RS_TRDIR_SELECT'
       EXPORTING
         TRDIR_NAME            = GV_TRDIR_BD_RELEASE
       IMPORTING
         TRDIR_ROW             = LS_TRDIR
       EXCEPTIONS
         INTERNAL_ERROR        = 1
         PARAMETER_ERROR       = 2
         NOT_FOUND             = 3
         OTHERS                = 4.
     IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
       LS_EXTAB-FCODE = 'FAFR'.
       APPEND LS_EXTAB TO GT_EXTAB.
     ENDIF.
     CALL FUNCTION 'RS_TRDIR_SELECT'
       EXPORTING
         TRDIR_NAME            = GV_TRDIR_CRP_DISPLAY
       IMPORTING
         TRDIR_ROW             = LS_TRDIR
       EXCEPTIONS
         INTERNAL_ERROR        = 1
         PARAMETER_ERROR       = 2
         NOT_FOUND             = 3
         OTHERS                = 4.
     IF SY-SUBRC <> 0 OR LS_TRDIR IS INITIAL.
       LS_EXTAB-FCODE = 'SAAN'.
       APPEND LS_EXTAB TO GT_EXTAB.
     ENDIF.
     CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
       EXPORTING
            P_STATUS  = 'SELDL'
            P_PROGRAM = GC_PROG_STAT_TITLE
       TABLES
            P_EXCLUDE = GT_EXTAB
       EXCEPTIONS
            OTHERS    = 0.
*...................................................................
* Setting of title bar
*...................................................................
  SET TITLEBAR 'DL_ITEM_LIST' OF PROGRAM GC_PROG_STAT_TITLE.
*---------------------------------------------------------------------
* Setting of "old" tabstrip (important after START-OF-SELECTION event)
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN
*---------------------------------------------------------------------
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

AT SELECTION-SCREEN.

   GS_BILL_DEFAULT-BILL_TYPE     = P_TYPE.
   GS_BILL_DEFAULT-BILL_DATE     = P_BIL_DT.

    GV_OK_CODE = SY-UCOMM.
    CASE GV_OK_CODE.
      WHEN 'RSAP'.
        CLEAR GV_APPL.
        SET PARAMETER ID 'GC_APPL_ID' FIELD GV_APPL.
        MESSAGE S003(BEA).
      WHEN 'SAMD'.
        PERFORM POPUP_TO_CONFIRM_STEP USING GV_ANSWER.
        IF GV_ANSWER = gc_yes.
          PERFORM DUELIST_SELECT_ITEMS.
          IF GT_DLI_WRK IS INITIAL.
            MESSAGE S130(BEA).
            EXIT.
          ENDIF.
          GV_COMMIT = GC_COMMIT_LOCAL.
          PERFORM DUELIST_BILL.
          IF GV_NO_AUTHORITY = GC_FALSE.
            MESSAGE S135(BEA).
          ELSE.
            MESSAGE E501(BEA).
          ENDIF.
        ENDIF.
      when 'PROT'.
        IF NOT GV_CRP_GUID IS INITIAL.
          CLEAR GRT_CRP_GUID.
          GRS_CRP_GUID-SIGN   = GC_INCLUDE.
          GRS_CRP_GUID-OPTION = GC_EQUAL.
          GRS_CRP_GUID-LOW    = GV_CRP_GUID.
          APPEND GRS_CRP_GUID TO GRT_CRP_GUID.
          CALL FUNCTION 'BEA_CRP_O_GETLIST'
            EXPORTING
              irt_crp_guid = grt_crp_guid
            IMPORTING
              et_crp       = lt_crp.
          IF NOT lt_crp IS INITIAL.
            CALL FUNCTION 'BEA_CRP_U_SHOW'
              EXPORTING
                it_crp = lt_crp.
          ELSE.
            MESSAGE S134(BEA).
          ENDIF.
        ELSE.
            MESSAGE s757(bea).
        ENDIF.
      WHEN 'SPAL'.
        PERFORM ALV_VARIANT_SELECT.
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
  PERFORM DUELIST_SELECT_ITEMS.
  IF GT_DLI_WRK IS INITIAL AND
     GV_AUTH_ERROR IS INITIAL.
    MESSAGE S130(BEA).
    EXIT.
  ENDIF.
*---------------------------------------------------------------------
* Event : END-OF-SELECTION
*---------------------------------------------------------------------
END-OF-SELECTION.
  GV_COMMIT = GC_COMMIT_ASYNC.
  IF SY-BATCH IS INITIAL.
    PERFORM DUELIST_DISPLAY.
  ELSE.
    GV_COMMIT = GC_COMMIT_LOCAL.
    PERFORM DUELIST_BILL.
    IF GV_NO_AUTHORITY = GC_FALSE.
      MESSAGE S135(BEA).
    ELSE.
      MESSAGE E501(BEA).
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
*       FORM duelist_select_items
*---------------------------------------------------------------------
*       select duelist-entries for further processing
*---------------------------------------------------------------------
FORM DUELIST_SELECT_ITEMS.
DATA :
  LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
  LRS_BILL_STATUS TYPE BEARS_BILL_STATUS,
  LRT_BILL_STATUS TYPE BEART_BILL_STATUS,
  LRS_BILL_BLOCK  TYPE BEARS_BILL_BLOCK,
  LRT_BILL_BLOCK  TYPE BEART_BILL_BLOCK,
  LRS_INCOMP_ID   TYPE BEARS_INCOMP_ID,
  LRT_INCOMP_ID   TYPE BEART_INCOMP_ID,
  LV_TABIX        LIKE SY-TABIX,
  LV_NR_OF_ENTRIES TYPE BEA_NR_OF_ENTRIES,
  LRT_DLI_GUID     TYPE BEART_DLI_GUID,
  LRS_DLI_GUID     TYPE BEARS_DLI_GUID,
  LS_DLIGUID       LIKE LINE OF S_DLIGD.

* BILL_STATUS in der Selektion ??
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
  EXPORT
    LRT_SRC_HEADNO   = S001_010[]
    LRT_P_SRC_HEADNO   = S001_020[]
    LRT_BILL_ORG   = S002_010[]
    LRT_INVCR_DATE   = S002_020[]
    LRT_PAYER   = S002_030[]
    LRT_SOLD_TO_PARTY   = S002_040[]
    LRT_BILL_TYPE   = S002_050[]
    LRT_BILL_CATEGORY   = S002_060[]
    LRT_SRC_USER   = S003_010[]
    LRT_SRC_DATE   = S003_020[]
    LRT_DLI_GUID    = S_DLIGD[]
    LRT_BILL_STATUS = LRT_BILL_STATUS
    LRT_BILL_BLOCK  = LRT_BILL_BLOCK
    LRT_INCOMP_ID   = LRT_INCOMP_ID
    TO MEMORY ID 'SEL_CRIT_DL'.

LOOP AT S_DLIGD[] INTO LS_DLIGUID.
  MOVE-CORRESPONDING LS_DLIGUID TO LRS_DLI_GUID.
  INSERT LRS_DLI_GUID INTO TABLE LRT_DLI_GUID.
ENDLOOP.

IF SY-BATCH IS INITIAL AND GV_OK_CODE NE 'SAMD'.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETCOUNT'
      EXPORTING
           IRT_INCOMP_ID   = LRT_INCOMP_ID
           IRT_BILL_STATUS = LRT_BILL_STATUS
           IRT_BILL_BLOCK  = LRT_BILL_BLOCK
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

  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
           IV_SORTREL      = GC_SORT_BY_EXTERNAL_REF
           IRT_INCOMP_ID   = LRT_INCOMP_ID
           IRT_BILL_STATUS = LRT_BILL_STATUS
           IRT_BILL_BLOCK  = LRT_BILL_BLOCK
           IRT_DLI_GUID    = LRT_DLI_GUID
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
           IV_MAXROWS      = LV_NR_OF_ENTRIES
       IMPORTING
           ET_DLI      = GT_DLI_WRK.

IF SY-BATCH IS INITIAL AND GV_OK_CODE NE 'SAMD'.
   LOOP AT GT_DLI_WRK INTO LS_DLI_WRK.
     LV_TABIX = SY-TABIX.
     PERFORM AUTHORITY_CHECK USING GC_ACTV_DISPLAY
                                   LS_DLI_WRK-BILL_ORG
                                   LS_DLI_WRK-BILL_TYPE
                             CHANGING GV_RC.
     IF GV_RC NE 0.    "no authority
       DELETE GT_DLI_WRK INDEX LV_TABIX.
       GV_AUTH_ERROR = GC_YES.
       CONTINUE.
     ENDIF.
  ENDLOOP.
  IF GV_AUTH_ERROR = GC_YES.
    MESSAGE I136(BEA).
  ENDIF.
 ENDIF.
ENDFORM.

*---------------------------------------------------------------------
*       FORM duelist_display
*---------------------------------------------------------------------
*       start the display of the duelist
*---------------------------------------------------------------------
FORM DUELIST_DISPLAY.
  CALL FUNCTION '/1BEA/CRMB_DL_U_SHOWLIST'
       EXPORTING
            IT_DLI              = GT_DLI_WRK
            IS_BILL_DEFAULT     = GS_BILL_DEFAULT
            IS_VARIANT          = GS_VARIANT.
ENDFORM.

*---------------------------------------------------------------------
*       FORM duelist_bill
*---------------------------------------------------------------------
*       direct billing of selected duelist-items                     *
*---------------------------------------------------------------------
FORM DUELIST_BILL.
 CALL FUNCTION '/1BEA/CRMB_DL_O_COLL_RUN'
      EXPORTING
           IT_DLI_WRK      = GT_DLI_WRK
           IV_COMMIT       = gv_commit
           IS_BILL_DEFAULT = GS_BILL_DEFAULT
      IMPORTING
           EV_CRP_GUID     = GV_CRP_GUID
           EV_NO_AUTHORITY = GV_NO_AUTHORITY.
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
*       ........
*---------------------------------------------------------------------
FORM AUTHORITY_CHECK USING UV_ACTION_TYPE   TYPE ACTIV_AUTH
                           UV_BILL_ORG      TYPE BEA_BILL_ORG
                           UV_BILL_TYPE     TYPE BEA_BILL_TYPE
                     CHANGING UV_RC         TYPE SY-SUBRC.

 CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
     EXPORTING
         IV_BILL_ORG            = UV_BILL_ORG
         IV_BILL_TYPE           = UV_BILL_TYPE
         IV_APPL                = GC_APPL
         IV_ACTVT               = UV_ACTION_TYPE
         IV_CHECK_DLI           = GC_TRUE
         IV_CHECK_BDH           = GC_FALSE
     EXCEPTIONS
         NO_AUTH                = 1.
  UV_RC = SY-SUBRC.
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
