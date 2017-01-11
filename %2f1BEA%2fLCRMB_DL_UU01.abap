FUNCTION /1BEA/CRMB_DL_U_CAPTION_DLI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IO_GUI_CONTAINER) TYPE REF TO CL_GUI_CONTAINER
*"     REFERENCE(IO_DD_DOCUMENT) TYPE REF TO CL_DD_DOCUMENT
*"     REFERENCE(IV_REUSE_DD_DOCUMENT) TYPE  BEA_BOOLEAN OPTIONAL
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
  DATA: lt_fields       TYPE ttfieldname,
        lv_fieldname    TYPE DFIES-LFIELDNAME,
        lt_text         TYPE beat_html_text,
        ls_text         TYPE beas_html_text,
        ls_dfies        TYPE dfies,
        lt_dfies        TYPE beft_dfies,
        lv_itc          TYPE BEA_ITEM_CATEGORY,
        lv_bty          TYPE BEA_BILL_TYPE,
        lv_description  TYPE BEA_DESCRIPTION.

  FIELD-SYMBOLS: <value> TYPE ANY.

* Set reference fields shown in a caption/header display:
  LV_FIELDNAME = 'LOGSYS'.
  APPEND LV_FIELDNAME TO LT_FIELDS.
  LV_FIELDNAME = 'OBJTYPE'.
  APPEND LV_FIELDNAME TO LT_FIELDS.
  LV_FIELDNAME = 'SRC_HEADNO'.
  APPEND LV_FIELDNAME TO LT_FIELDS.
  LV_FIELDNAME = 'SRC_ITEMNO'.
  APPEND LV_FIELDNAME TO LT_FIELDS.
  lv_fieldname = 'ITEM_CATEGORY'.
  APPEND lv_fieldname TO lt_fields.
  lv_fieldname = 'BILL_TYPE'.
  APPEND lv_fieldname TO lt_fields.

* Build the text-table
  LOOP AT lt_fields INTO lv_fieldname.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname    = '/1BEA/S_CRMB_DLI_WRK'
        lfieldname = lv_fieldname
        langu      = sy-langu
      IMPORTING
        dfies_wa   = ls_dfies
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    APPEND ls_dfies TO lt_dfies.
  ENDLOOP.
  LOOP AT lt_dfies INTO ls_dfies.
    ls_text-tabname = ls_dfies-tabname.
    ls_text-element = ls_dfies-fieldname.
    ls_text-text1 = ls_dfies-scrtext_l.
* Handle value tables (for fix part)
 IF ls_dfies-fieldname = 'ITEM_CATEGORY'.
   lv_itc = is_dli-item_category.
   CALL FUNCTION 'BEA_ITC_O_GET_DESCRIPTION'
     EXPORTING
       IV_APPL                = gc_appl
       IV_ITC                 = lv_itc
     IMPORTING
       EV_DESCRIPTION         = lv_description
     EXCEPTIONS
       OBJECT_NOT_FOUND       = 1
       OTHERS                 = 2.
    IF sy-subrc <> 0.
      ls_text-text2 = lv_itc.
    ELSE.
      CONCATENATE '(' lv_itc ')' into ls_text-text2.
      CONCATENATE lv_description ls_text-text2
                 into ls_text-text2
                 separated by space.
    ENDIF.
  ELSEIF ls_dfies-fieldname = 'BILL_TYPE'.
    lv_bty = is_dli-bill_type.
    CALL FUNCTION 'BEA_BTY_O_GET_DESCRIPTION'
      EXPORTING
        IV_APPL                = gc_appl
        IV_BTY                 = lv_bty
      IMPORTING
        EV_DESCRIPTION         = lv_description
     EXCEPTIONS
       OBJECT_NOT_FOUND       = 1
       OTHERS                 = 2.
    IF sy-subrc <> 0.
      ls_text-text2 = lv_bty.
    ELSE.
      CONCATENATE '(' lv_bty ')' into ls_text-text2.
      CONCATENATE lv_description ls_text-text2
                  into ls_text-text2
                  separated by space.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT ls_dfies-fieldname OF
           STRUCTURE is_dli TO <value>.
    MOVE <value> TO ls_text-text2.
    IF ls_dfies-fieldname = 'LOGSYS'.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
         EXPORTING
           INPUT         = ls_text-text2
         IMPORTING
           OUTPUT        = ls_text-text2.
    ENDIF.
    IF ls_dfies-fieldname = 'OBJTYPE'.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
         EXPORTING
           INPUT         = ls_text-text2
         IMPORTING
           OUTPUT        = ls_text-text2.
    ENDIF.
    IF ls_dfies-fieldname = 'SRC_HEADNO'.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
         EXPORTING
           INPUT         = ls_text-text2
         IMPORTING
           OUTPUT        = ls_text-text2.
    ENDIF.
    IF ls_dfies-fieldname = 'SRC_ITEMNO'.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
         EXPORTING
           INPUT         = ls_text-text2
         IMPORTING
           OUTPUT        = ls_text-text2.
    ENDIF.
   ENDIF.
   APPEND ls_text TO lt_text.
  ENDLOOP.

* Call generic function with dynamic document display:
  CALL FUNCTION 'BEA_OBJ_U_DYN_DOC_TABLE'
    EXPORTING
      it_text              = lt_text
      io_gui_container     = io_gui_container
      IO_DD_DOC            = IO_DD_DOCUMENT
      IV_BACKGROUND_COLOR  = gc_background_color
      IV_REUSE_DOC         = IV_REUSE_DD_DOCUMENT.

ENDFUNCTION.
