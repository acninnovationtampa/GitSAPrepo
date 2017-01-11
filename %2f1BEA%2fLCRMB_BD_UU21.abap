FUNCTION /1BEA/CRMB_BD_U_DETAIL_BDH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
*********************************************************************
* Declaration
*********************************************************************
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
*********************************************************************
* Implementation
*********************************************************************
*====================================================================
* Get Info about fields of the DDIC-Structure /1BEA/S_CRMB_BDH
*====================================================================
 lv_tabname = '/1BEA/S_CRMB_BDH'.
 CALL FUNCTION 'DDIF_FIELDINFO_GET'
   EXPORTING
     tabname           = lv_tabname
     langu             = sy-langu
   TABLES
     dfies_tab         = lt_dfies
   EXCEPTIONS
       NOT_FOUND       = 1
       INTERNAL_ERROR  = 2
       OTHERS          = 3.
 IF sy-subrc <> 0.
   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 ENDIF.
*====================================================================
* Build Table lt_text, that will be displayed
*====================================================================
 CLEAR lt_text.
*--------------------------------------------------------------------
* Relevant data for Transfer to Accounting
*--------------------------------------------------------------------
   ls_text-text1    = text-DH3.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
*....................................................................
* Transfer-Status
*....................................................................
   lv_fieldname = 'TRANSFER_STATUS'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Terms of Payment
*....................................................................
   lv_fieldname = 'TERMS_OF_PAYMENT'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Reference Number
*....................................................................
   lv_fieldname = 'REFERENCE_NO'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*--------------------------------------------------------------------
* Pricing data
*--------------------------------------------------------------------
   ls_text-text1    = text-DH2.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
*....................................................................
* Tax Value
*....................................................................
   lv_fieldname = 'TAX_VALUE'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Currency of the Document
*....................................................................
   lv_fieldname = 'DOC_CURRENCY'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Reference Currency
*....................................................................
   lv_fieldname = 'REF_CURRENCY'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Pricing Procedure
*....................................................................
   lv_fieldname = 'PRIC_PROC'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Exchange rate type
*....................................................................
   lv_fieldname = 'EXCHANGE_TYPE'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.

*--------------------------------------------------------------------
* Additional data
*--------------------------------------------------------------------
   ls_text-text1    = text-DH4.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
*....................................................................
* Cancel Flag
*....................................................................
   lv_fieldname = 'CANCEL_FLAG'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Collective Run Guid
*....................................................................
   lv_fieldname = 'CRP_GUID'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Split Criteria
*....................................................................
   lv_fieldname = 'SPLIT_CRITERIA'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*--------------------------------------------------------------------
* Administration data
*--------------------------------------------------------------------
   ls_text-text1    = text-DH1.
   ls_text-text2    = ''.
   ls_text-type = 'U'.
   APPEND ls_text TO lt_text.
*....................................................................
* Date of Maintenance
*....................................................................
   lv_fieldname = 'MAINT_DATE'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* Time of Maintenance
*....................................................................
   lv_fieldname = 'MAINT_TIME'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*....................................................................
* User that maintained the document
*....................................................................
   lv_fieldname = 'MAINT_USER'.
   READ TABLE lt_dfies INTO ls_dfies
              WITH KEY tabname   = lv_tabname
                       fieldname = lv_fieldname.
   PERFORM get_text_bdh USING   ls_dfies
                                is_bdh
                       CHANGING lt_text.
*--------------------------------------------------------------------
* Document data (i.e. all the other fields!)
*--------------------------------------------------------------------
 CLEAR LT_TEXT_HLP.
 ls_text-text1    = text-DH5.
 ls_text-text2    = ''.
 ls_text-type = 'U'.
 LOOP AT LT_DFIES INTO LS_DFIES.
*....................................................................
* Filter fields, that shall not be displayed (CLIENT)
* or that have a special logic (CRP_GUID)
*....................................................................
   IF LS_DFIES-FIELDNAME = 'CLIENT'        OR
      LS_DFIES-FIELDNAME = 'CRP_GUID'.
     CONTINUE.
   ENDIF.
   READ TABLE LT_TEXT WITH KEY ELEMENT = LS_DFIES-FIELDNAME
        TRANSPORTING NO FIELDS.
   IF NOT SY-SUBRC IS INITIAL.
     PERFORM get_text_bdh USING   ls_dfies
                                  is_bdh
                         CHANGING lt_text_hlp.
   ENDIF.
 ENDLOOP.
 IF NOT LT_TEXT_HLP IS INITIAL.
   INSERT LINES OF LT_TEXT_HLP INTO LT_TEXT INDEX 1.
   INSERT LS_TEXT INTO LT_TEXT INDEX 1.
 ENDIF.

* Event BD_UHDT0
  INCLUDE %2f1BEA%2fX_CRMBBD_UHDT0PRCUBD_HGR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UHDT0ACCUBD_HGR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UHDT0MWCUBD_HGR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UHDT0TXTUBD_HGR.
*====================================================================
* Set DATA for dynamic documents
*====================================================================
  IF NOT IT_FIELDS_EXCL IS INITIAL.
    LOOP AT IT_FIELDS_EXCL INTO LV_FIELDNAME.
      READ TABLE LT_TEXT WITH KEY ELEMENT = LV_FIELDNAME
                         TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        DELETE LT_TEXT INDEX SY-TABIX.
      ENDIF.
    ENDLOOP.
    delete lt_text where element is initial.
  ENDIF.

  CALL FUNCTION 'BEA_OBJ_U_DYN_DOC_TEXT'
     EXPORTING
       it_text                   = lt_text
       IV_NO_OF_COLUMNS          = 1
       IV_BACKGROUND_COLOR       = cl_dd_document=>col_textarea.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Form Routines
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*      Form  get_text_bdh
*********************************************************************
FORM get_text_bdh
  USING
    us_dfies     TYPE dfies
    us_bdh       TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING
    ct_text      TYPE beat_html_text.
*....................................................................
* Declaration
*....................................................................
  DATA:
    ls_dfies        TYPE dfies,
    lt_dfies        TYPE beft_dfies,
    lt_fixed_values TYPE DDFIXVALUES,
    ls_fixed_values TYPE DDFIXVALUE,
    ls_text         TYPE beas_html_text,
    lv_text         TYPE char64,
    lv_text_ref     TYPE char64,
    lv_description  TYPE BEA_DESCRIPTION,
    lv_crp_guid     TYPE BEA_CRP_GUID,
    ls_crp          TYPE BEAS_CRP,
    lv_date         TYPE d,
    lv_time         TYPE t.
  FIELD-SYMBOLS:
    <value>         TYPE ANY,
    <value_ref>     TYPE ANY.
*====================================================================
* Implementation
*====================================================================
  IF US_DFIES-FIELDNAME = 'BILL_CATEGORY'.
    ls_text-tabname = us_dfies-tabname.
    ls_text-element = us_dfies-fieldname.
    ls_text-text1   = us_dfies-scrtext_l.
    ls_text-type = space.
    CALL FUNCTION 'BEA_BCA_O_GET_DESCRIPTION'
      EXPORTING
        IV_APPL                = GC_APPL
        IV_BILL_CATEGORY       = US_BDH-BILL_CATEGORY
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
*--------------------------------------------------------------------
* Special Handling for the Collective Run
*--------------------------------------------------------------------
 IF us_dfies-fieldname = 'CRP_GUID'.
     lv_crp_guid = us_bdh-crp_guid.
     CALL FUNCTION 'BEA_CRP_O_GETDETAIL'
       EXPORTING
         IV_APPL                = gc_appl
         IV_CRP_GUID            = lv_crp_guid
       IMPORTING
         ES_CRP                 = ls_crp
       EXCEPTIONS
         OTHERS                 = 0.
     IF NOT LS_CRP IS INITIAL.
       CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
           tabname           = 'BEAS_CRP'
           fieldname         = 'CR_NUMBER'
           langu             = sy-langu
         TABLES
           dfies_tab         = lt_dfies
         EXCEPTIONS
           NOT_FOUND       = 1
           INTERNAL_ERROR  = 2
           OTHERS          = 3.
       IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       ENDIF.
       READ TABLE LT_DFIES INTO LS_DFIES INDEX 1.
       ls_text-tabname = 'BEAS_CRP'.
       ls_text-element = ls_dfies-fieldname.
       ls_text-text1 = ls_dfies-scrtext_l.
       ls_text-text2 = ls_crp-cr_number.
       ls_text-type = space.
       APPEND ls_text TO ct_text.
    ENDIF.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------
* Standard Handling
*--------------------------------------------------------------------
    ls_text-tabname = us_dfies-tabname.
    ls_text-element = us_dfies-fieldname.
    ls_text-text1   = us_dfies-scrtext_l.
    ASSIGN COMPONENT us_dfies-fieldname OF
           STRUCTURE us_bdh TO <value>.
    IF NOT US_DFIES-VALEXI IS INITIAL.
*....................................................................
* Field having an underlying domain with fixed values
*....................................................................
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
*....................................................................
* Field is an amount or a quantity
*....................................................................
      ASSIGN COMPONENT us_dfies-reffield OF
             STRUCTURE us_bdh TO <value_ref>.
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
*....................................................................
* Date field -> Conversion necessary
*....................................................................
       MOVE <value> TO lv_date.
       WRITE lv_date to ls_text-text2.
    ELSEIF us_dfies-DATATYPE = 'TIMS'.
*....................................................................
* Time field -> Conversion necessary
*....................................................................
       MOVE <value> TO lv_time.
       WRITE lv_time to ls_text-text2.
    ELSEIF ( us_dfies-domname = 'SYSUUID' OR
             us_dfies-domname = 'SYSUUID_C' ).
*....................................................................
* Never display GUIDs!
*....................................................................
       RETURN. "from form
    ELSE.
    if us_dfies-convexit = 'ALPHA'.
      call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input         = ls_text-text2
        importing
          output        = ls_text-text2.
    endif.
      WRITE <value> TO ls_text-text2.
    ENDIF.
    ls_text-type = space.
    APPEND ls_text TO ct_text.

ENDFORM.                    " get_text_bdh
