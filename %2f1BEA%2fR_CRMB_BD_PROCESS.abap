REPORT /1BEA/R_CRMB_BD_PROCESS .
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
INCLUDE BEA_BASICS.

TABLES:
        /1BEA/CRMB_BDH,
        /1BEA/CRMB_BDI.
CONSTANTS:
  GC_APPL             TYPE BEF_APPL      VALUE 'CRMB'.
DATA:
  GV_APPL             TYPE BEF_APPL,
  GS_VARIANT          LIKE DISVARIANT,
  GV_OK_CODE          TYPE SYUCOMM.
DATA:   GT_EXTAB       TYPE SLIS_T_EXTAB WITH HEADER LINE.
DATA:   LT_BDH         TYPE /1BEA/T_CRMB_BDH_WRK.
DATA:   LT_BDI         TYPE /1BEA/T_CRMB_BDI_WRK.
DATA:   LS_BDI         TYPE /1BEA/S_CRMB_BDI_WRK.

PARAMETERS: P_CRP         TYPE BEART_CRP_GUID NO-DISPLAY.
PARAMETERS: P_BDH         TYPE BEART_BDH_GUID NO-DISPLAY.
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
PARAMETERS: P_MAXROW     TYPE BEA_NR_OF_ENTRIES DEFAULT 100.
SELECTION-SCREEN END OF BLOCK ROW.
*-------------------------------------------------------------
* Event : INITIALIZATION
*---------------------------------------------------------------------
INITIALIZATION.
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
*.....................................................................
* Definition of the Subsreens for the Tabstrips
*.....................................................................
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
       EXPORTING
            P_STATUS  = 'SELBD'
            P_PROGRAM = 'SAPLBEFB_SCREEN_CENTER'
       TABLES
            P_EXCLUDE = GT_EXTAB
       EXCEPTIONS
            OTHERS    = 0.

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
      WHEN 'SPAL'.
        PERFORM ALV_VARIANT_SELECT.
    ENDCASE.
*---------------------------------------------------------------------
* Event : AT SELECTION-SCREEN ON EXIT-COMMAND
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON EXIT-COMMAND.

START-OF-SELECTION.
*---------------------------------------------------------------------
* Event : START-OF-SELECTION
* --------------------------------------------------------------------
    PERFORM DOCUMENTS_SELECT.
    IF LT_BDH IS INITIAL.
      MESSAGE S130(BEA).
      EXIT.
    ENDIF.
*---------------------------------------------------------------------
* Event : END-OF-SELECTION
*---------------------------------------------------------------------
    PERFORM AUTHORITY_CHECK USING GC_ACTV_display.
    PERFORM DOCUMENTS_DISPLAY.

*---------------------------------------------------------------------
*       FORM documents_select
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM DOCUMENTS_SELECT.

DATA:
  LV_NR_OF_ENTRIES     TYPE BEA_NR_OF_ENTRIES,
  LV_RS_NR_OF_ENTRIES  TYPE BEA_NR_OF_ENTRIES,
  lv_no_dialog         type bea_boolean,
  lv_lines             TYPE i,
  LT_BDH_HLP           TYPE /1BEA/T_CRMB_BDH_WRK,
  LS_BDH               TYPE /1BEA/S_CRMB_BDH_WRK,
  LRS_BDH_GUID         TYPE BEARS_BDH_GUID,
  LRT_BDH_GUID         TYPE BEART_BDH_GUID.

  LRT_BDH_GUID = P_BDH.

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
    GV_DUMMY
    TO MEMORY ID 'SEL_CRIT_BD'.

IF SY-BATCH IS INITIAL.
  CALL FUNCTION '/1BEA/CRMB_BD_O_BDGETCOUNT'
    EXPORTING
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
         EV_NR_OF_ENTRIES  = LV_RS_NR_OF_ENTRIES
         ev_no_dialog      = lv_no_dialog.
  IF LV_RS_NR_OF_ENTRIES = 0.
    EXIT.
  ENDIF.
  lv_no_dialog = gc_true.
  CALL FUNCTION '/1BEA/CRMB_BD_O_BDGETLIST'
    EXPORTING
      IV_MAXROWS = LV_RS_NR_OF_ENTRIES
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
    IRT_BDH_CRP_GUID = P_CRP
    IRT_BDH_BDH_GUID = LRT_BDH_GUID
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
ENDFORM.

*********************************************************************
*       FORM documents_display
*********************************************************************
FORM DOCUMENTS_DISPLAY.
*--------------------------------------------------------------------
* Display Bill Documents
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
       EXPORTING
            IT_BDH                   = LT_BDH
            IT_BDI                   = LT_BDI
            IV_MODE                  = GC_BD_PROCESS
            IS_VARIANT               = GS_VARIANT.
ENDFORM.
*---------------------------------------------------------------------
*       FORM authority_check
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM AUTHORITY_CHECK USING LV_ACTION_TYPE.

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
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
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
    GS_VARIANT-REPORT = LV_REPORT.
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
*--------------------------------------------------------------------*
*     Form  f4_bill_type
*--------------------------------------------------------------------*
*     Value help for bill type
*--------------------------------------------------------------------*
FORM f4_bill_type CHANGING p_fieldval TYPE bea_bill_type.

  CONSTANTS:
    lc_param_appl(11)     TYPE c         VALUE 'APPLICATION',
    lc_bill_type(9)       TYPE c         VALUE 'BILL_TYPE',
    lc_shlp_name          TYPE shlpname  VALUE 'BEAC_BTY',
    lc_shlp_type          TYPE ddshlptyp VALUE 'SH'.

  DATA:
  ls_shlp           TYPE shlp_descr,
  ls_return_values  TYPE ddshretval,
  lt_return_values  TYPE TABLE OF ddshretval,
  ls_shlp_interface TYPE ddshiface,
  lt_shlp_interface TYPE ddshifaces.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = lc_shlp_name
      shlptype = lc_shlp_type
    IMPORTING
      shlp     = ls_shlp.

  ls_shlp_interface-value     = gc_appl.
  MODIFY ls_shlp-interface FROM ls_shlp_interface TRANSPORTING value
         WHERE shlpfield = lc_param_appl.

  ls_shlp_interface-valfield = gc_true.
  MODIFY ls_shlp-interface FROM ls_shlp_interface
         TRANSPORTING valfield
         WHERE shlpfield = lc_bill_type.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_return_values.

 READ TABLE lt_return_values INTO ls_return_values
       WITH KEY fieldname  = lc_bill_type.

  p_fieldval = ls_return_values-fieldval.

ENDFORM.                    " f4_bill_type
*--------------------------------------------------------------------*
*     Form  f4_item_categroy
*--------------------------------------------------------------------*
*     Value help for item category
*--------------------------------------------------------------------*
FORM f4_item_category CHANGING p_fieldval TYPE bea_item_category.

  CONSTANTS:
    lc_param_appl(11)     TYPE c         VALUE 'APPLICATION',
    lc_item_categrory(13) TYPE c         VALUE 'ITEM_CATEGORY',
    lc_shlp_name          TYPE shlpname  VALUE 'BEA_ITEM_CATEGORY',
    lc_shlp_type          TYPE ddshlptyp VALUE 'SH'.

  DATA:
    ls_shlp           TYPE shlp_descr,
    ls_return_values  TYPE ddshretval,
    lt_return_values  TYPE TABLE OF ddshretval,
    ls_shlp_interface TYPE ddshiface,
    lt_shlp_interface TYPE ddshifaces.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = lc_shlp_name
      shlptype = lc_shlp_type
    IMPORTING
      shlp     = ls_shlp.

  ls_shlp_interface-value     = gc_appl.
  MODIFY ls_shlp-interface FROM ls_shlp_interface TRANSPORTING value
         WHERE shlpfield = lc_param_appl.

  ls_shlp_interface-valfield = gc_true.
  MODIFY ls_shlp-interface FROM ls_shlp_interface
       TRANSPORTING valfield
       WHERE shlpfield = lc_item_categrory.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_return_values.

  READ TABLE lt_return_values INTO ls_return_values
       WITH KEY fieldname  = lc_item_categrory.

  p_fieldval = ls_return_values-fieldval.

ENDFORM.                    " f4_item_category
