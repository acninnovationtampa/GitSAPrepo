FUNCTION /1BEA/CRMB_DL_U_DETAIL_DLI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IT_FIELDS_EXCL) TYPE  TTFIELDNAME OPTIONAL
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
* Time  : 13:53:02
*
*======================================================================
DATA:
  lt_text         TYPE beat_html_text,
  ls_text         TYPE beas_html_text,
  lt_text_hlp     TYPE beat_html_text,
  lv_fieldname    TYPE fieldname,
  lt_dfies        TYPE beft_dfies,
  ls_dfies        TYPE dfies,
  lv_tabname      TYPE ddobjname,
  lv_tabix        type sy-tabix,
  lv_tabix_hlp    type sy-tabix.

 lv_tabname = '/1BEA/S_CRMB_DLI'.

* get field_info
CALL FUNCTION 'DDIF_FIELDINFO_GET'
  EXPORTING
    tabname      = lv_tabname
    langu        = sy-langu
  TABLES
    dfies_tab    = lt_dfies
  EXCEPTIONS
    NOT_FOUND       = 1
    INTERNAL_ERROR  = 2
    OTHERS          = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

CLEAR lt_text[].

* Application data:
   ls_text-text1    = text-DI2.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
   lv_fieldname = 'BILL_STATUS'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_dli USING   ls_dfies
                                is_dli
                       CHANGING lt_text.
   lv_fieldname = 'BILL_BLOCK'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_dli USING   ls_dfies
                                is_dli
                       CHANGING lt_text.

* Administration data:
   ls_text-text1    = text-DI1.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
   lv_fieldname = 'MAINT_DATE'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_dli USING   ls_dfies
                                is_dli
                       CHANGING lt_text.
   lv_fieldname = 'MAINT_TIME'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_dli USING   ls_dfies
                                is_dli
                       CHANGING lt_text.
   lv_fieldname = 'MAINT_USER'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_dli USING   ls_dfies
                                is_dli
                       CHANGING lt_text.

* Application data:
 CLEAR LT_TEXT_HLP.
 ls_text-text1    = text-DI5.
 ls_text-text2    = ''.
 ls_text-type = 'U'.
 LOOP AT LT_DFIES INTO LS_DFIES.
   IF LS_DFIES-FIELDNAME = 'CLIENT'        OR
      LS_DFIES-FIELDNAME = 'LOGSYS'    OR
      LS_DFIES-FIELDNAME = 'OBJTYPE'    OR
      LS_DFIES-FIELDNAME = 'SRC_HEADNO'    OR
      LS_DFIES-FIELDNAME = 'SRC_ITEMNO'    OR
      LS_DFIES-FIELDNAME = 'BILL_TYPE'     OR
      LS_DFIES-FIELDNAME = 'ITEM_CATEGORY'.
     CONTINUE.
   ENDIF.
   READ TABLE LT_TEXT WITH KEY ELEMENT = LS_DFIES-FIELDNAME
        TRANSPORTING NO FIELDS.
   IF NOT SY-SUBRC IS INITIAL.
     PERFORM get_text_dli USING   ls_dfies
                                  is_dli
                         CHANGING lt_text_hlp.
   ENDIF.
 ENDLOOP.
 IF NOT LT_TEXT_HLP IS INITIAL.
   INSERT LINES OF LT_TEXT_HLP INTO LT_TEXT INDEX 1.
   INSERT LS_TEXT INTO LT_TEXT INDEX 1.
 ENDIF.

* Event for re-grouping of fields or changing texts
* Event DL_UDTL0
  INCLUDE %2f1BEA%2fX_CRMBDL_UDTL0CSAUDL_GRP.
  INCLUDE %2f1BEA%2fX_CRMBDL_UDTL0PRDUDL_PRP.
  INCLUDE %2f1BEA%2fX_CRMBDL_UDTL0CRTUDL_PRP.
  INCLUDE %2f1BEA%2fX_CRMBDL_UDTL0TBCUDL_PRP.

* Set DATA for dynamic documents

  IF NOT IT_FIELDS_EXCL IS INITIAL.
    LOOP AT IT_FIELDS_EXCL INTO LV_FIELDNAME.
      READ TABLE LT_TEXT WITH KEY ELEMENT = LV_FIELDNAME
                         TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        DELETE LT_TEXT INDEX SY-TABIX.
      ENDIF.
    ENDLOOP.
    delete lt_text where tabname is initial and element is initial.
  ENDIF.

CALL FUNCTION 'BEA_OBJ_U_DYN_DOC_TEXT'
  EXPORTING
   it_text                   = lt_text
   IV_NO_OF_COLUMNS          = 1
   IV_BACKGROUND_COLOR       = cl_dd_document=>col_textarea.

ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Form Routinene
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*      Form  get_text_dli
*********************************************************************
FORM get_text_dli
  USING
    us_dfies     TYPE dfies
    us_dli       TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    ct_text      TYPE beat_html_text.
*....................................................................
* Declaration
*....................................................................
 DATA:
    ls_dfies        TYPE dfies,
    lv_description  TYPE BEA_DESCRIPTION,
    lt_fixed_values TYPE DDFIXVALUES,
    ls_fixed_values TYPE DDFIXVALUE,
    ls_text         TYPE beas_html_text,
    lv_text         TYPE char64,
    lv_text_ref     TYPE char64,
    lv_text_str     TYPE string,
    lv_date         TYPE d,
    lv_time         TYPE t,
    lv_date_hlp(12) TYPE c,
    lv_time_hlp(12) TYPE c,
    lv_tzone        TYPE TIMEZONE,
    lv_timestamp    TYPE timestampl,
    lv_timestamps   TYPE TIMESTAMP,
    ls_timehlp      TYPE TTZTSTMP.

 FIELD-SYMBOLS: <value>     TYPE ANY,
                <value_ref> TYPE ANY.

* Special Treatment for the field BILL_BLOCK and BILL_BLOCK = 'Q'
 IF us_dfies-fieldname = 'BILL_BLOCK'  AND
    us_dli-bill_block = gc_billblock_qc.
   ls_text-tabname = us_dfies-tabname.
   ls_text-element = us_dfies-fieldname.
   ls_text-text1   = us_dfies-scrtext_l.
   ls_text-text2 = text-ybb.
   ls_text-type = space.
 ENDIF.

 IF US_DFIES-FIELDNAME = 'BILL_CATEGORY'.
   ls_text-tabname = us_dfies-tabname.
   ls_text-element = us_dfies-fieldname.
   ls_text-text1   = us_dfies-scrtext_l.
   ls_text-type = space.
   CALL FUNCTION 'BEA_BCA_O_GET_DESCRIPTION'
     EXPORTING
       IV_APPL                = GC_APPL
       IV_BILL_CATEGORY       = US_DLI-BILL_CATEGORY
       IV_LANGU               = SY-LANGU
     IMPORTING
       EV_DESCRIPTION         = LV_DESCRIPTION
     EXCEPTIONS
       OBJECT_NOT_FOUND       = 0
       OTHERS                 = 0.
   ls_text-text2 = lv_description.
   APPEND ls_text TO ct_text.
   RETURN.
 ENDIF.

* Automatic conversions (from data type etc.)
 ls_text-tabname = us_dfies-tabname.
 ls_text-element = us_dfies-fieldname.
 ls_text-text1 = us_dfies-scrtext_l.
 ASSIGN COMPONENT us_dfies-fieldname OF
        STRUCTURE us_dli TO <value>.
 IF NOT US_DFIES-VALEXI IS INITIAL.
   CALL FUNCTION 'DDIF_FIELDINFO_GET'
     EXPORTING
       tabname      = us_dfies-rollname
       langu        = sy-langu
       all_types    = gc_true
     TABLES
       fixed_values = lt_fixed_values.
   READ TABLE LT_FIXED_VALUES INTO LS_FIXED_VALUES
              WITH KEY LOW = <VALUE>.
   MOVE LS_FIXED_VALUES-DDTEXT TO ls_text-text2.
 ELSEIF not us_dfies-reffield is initial.
   ASSIGN COMPONENT us_dfies-reffield OF
          STRUCTURE us_dli TO <value_ref>.
   MOVE <value_ref> TO lv_text_ref.
   IF us_dfies-datatype = 'CURR'.
     WRITE <value> CURRENCY <value_ref> TO lv_text.
   ELSEIF us_dfies-datatype = 'QUAN'.
     WRITE <value> UNIT <value_ref> TO lv_text.
   ELSE.
     MOVE <value> TO lv_text.
   ENDIF.
   CONCATENATE lv_text lv_text_ref INTO
   ls_text-text2 SEPARATED BY space.
 ELSEIF us_dfies-DATATYPE = 'DATS'.
   MOVE <value> TO lv_date.
   WRITE lv_date to ls_text-text2.
 ELSEIF us_dfies-DATATYPE = 'TIMS'.
   MOVE <value> TO lv_time.
   WRITE lv_time to ls_text-text2.
 ELSEIF us_dfies-domname = 'TZNTSTMPL'.
   MOVE <value> TO lv_timestamp.
   lv_tzone = sy-zonlo.
   CONVERT TIME STAMP lv_timestamp
     TIME ZONE lv_tzone INTO DATE lv_date TIME lv_time.
   WRITE lv_date to lv_date_hlp.
   WRITE lv_time to lv_time_hlp.
   CONCATENATE lv_date_hlp '/' lv_time_hlp into ls_text-text2
     SEPARATED BY SPACE.
 ELSEIF us_dfies-domname = 'TZNTSTMPS'.  " Short Timestamp
   MOVE <value> TO lv_timestamps.
   lv_tzone = sy-zonlo.
   CONVERT TIME STAMP lv_timestamps
     TIME ZONE lv_tzone INTO DATE lv_date TIME lv_time.
   WRITE lv_date to lv_date_hlp.
   WRITE lv_time to lv_time_hlp.
   CONCATENATE lv_date_hlp '/' lv_time_hlp into ls_text-text2
     SEPARATED BY SPACE.
 ELSEIF ( us_dfies-domname = 'SYSUUID' or us_dfies-domname = 'SYSUUID_C' ).
   RETURN.
 ELSE.
   case us_dfies-convexit.
     when 'ALPHA'.
       call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
         exporting
           input         = <value>
         importing
           output        = ls_text-text2.
     when 'TSTPS'.
       call function 'CONVERSION_EXIT_TSTPS_OUTPUT'
         exporting
           input         = <value>
         importing
           output        = ls_text-text2.
     when others.
       WRITE <value> TO ls_text-text2.
   endcase.
 ENDIF.
 ls_text-type = space.
   APPEND ls_text TO ct_text.

ENDFORM.                    " get_text_dli
