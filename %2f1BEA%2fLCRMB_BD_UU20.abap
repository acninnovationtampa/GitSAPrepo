FUNCTION /1BEA/CRMB_BD_U_DETAIL_BDI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
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
    lv_tabname      TYPE ddobjname VALUE '/1BEA/S_CRMB_BDI',
    lv_tabix        type sy-tabix,
    lv_tabix_hlp    type sy-tabix.
*********************************************************************
* Implementation
*********************************************************************
*====================================================================
* Get field_info for the DDIC-Structure of the Bill Doc Items
*====================================================================
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
     EXPORTING
       tabname         = lv_tabname
       langu           = sy-langu
     TABLES
       dfies_tab       = lt_dfies
     EXCEPTIONS
       NOT_FOUND       = 1
       INTERNAL_ERROR  = 2
       OTHERS          = 3.
  IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*====================================================================
* Fill Text Table
*====================================================================
  CLEAR lt_text.
*--------------------------------------------------------------------
* Pricing data
*--------------------------------------------------------------------
  ls_text-text1    = text-DH2.
  ls_text-text2    = ''.
  ls_text-type = 'U'.
  APPEND ls_text TO lt_text.
*....................................................................
* Gross Value
*....................................................................
  lv_fieldname = 'GROSS_VALUE'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Tax Value
*....................................................................
  lv_fieldname = 'TAX_VALUE'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Exchange Rate
*....................................................................
  lv_fieldname = 'EXCHANGE_RATE'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Exchange Date
*....................................................................
  lv_fieldname = 'EXCHANGE_DATE'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Currency of the Document
*....................................................................
  lv_fieldname = 'DOC_CURRENCY'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Error in Pricing?
*....................................................................
  lv_fieldname = 'PRICING_STATUS'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Additional data
*....................................................................
  ls_text-text1    = text-DI4.
  ls_text-text2    = ''.
  ls_text-type = 'U'.
  APPEND ls_text TO lt_text.
*....................................................................
* Item cancelled?
*....................................................................
  lv_fieldname = 'IS_REVERSED'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*....................................................................
* Is it an item of a cancel document?
*....................................................................
  lv_fieldname = 'REVERSAL'.
  READ TABLE lt_dfies INTO ls_dfies
             WITH KEY tabname   = lv_tabname
                      fieldname = lv_fieldname.
  PERFORM get_text_bdi USING    ls_dfies
                                is_bdi
                       CHANGING lt_text.
*--------------------------------------------------------------------
* Application data
*--------------------------------------------------------------------
  CLEAR LT_TEXT_HLP.
  ls_text-text1    = text-DH5.
  ls_text-text2    = ''.
  ls_text-type = 'U'.
  LOOP AT LT_DFIES INTO LS_DFIES.
* Filter fields, that shall not be displayed (CLIENT)
* or that have a special logic (CRP_GUID)
*....................................................................
    IF LS_DFIES-FIELDNAME = 'CLIENT'.
     CONTINUE.
    ENDIF.
    READ TABLE LT_TEXT WITH KEY ELEMENT = LS_DFIES-FIELDNAME
         TRANSPORTING NO FIELDS.
    IF NOT SY-SUBRC IS INITIAL.
       PERFORM get_text_bdi USING    ls_dfies
                                     is_bdi
                            CHANGING lt_text_hlp.
    ENDIF.
  ENDLOOP.
  IF NOT LT_TEXT_HLP IS INITIAL.
     INSERT LINES OF LT_TEXT_HLP INTO LT_TEXT INDEX 1.
     INSERT LS_TEXT INTO LT_TEXT INDEX 1.
  ENDIF.

* Event BD_UIDT0
  INCLUDE %2f1BEA%2fX_CRMBBD_UIDT0TXTUBD_IGR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UIDT0PRDUBD_IPR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UIDT0CRTUBD_IPR.
  INCLUDE %2f1BEA%2fX_CRMBBD_UIDT0TBCUBD_IPR.
*====================================================================
* Set DATA and background-style for dynamic document
*====================================================================
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
* Form Routines
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*      Form  get_text_bdi
*********************************************************************
FORM get_text_bdi  USING us_dfies  TYPE dfies
                         us_bdi    TYPE /1BEA/S_CRMB_BDI_WRK
                CHANGING ct_text   TYPE beat_html_text.
*....................................................................
* Declaration
*....................................................................
  DATA:
    ls_dfies        TYPE dfies,
    lt_fixed_values TYPE DDFIXVALUES,
    ls_fixed_values TYPE DDFIXVALUE,
    ls_text         TYPE beas_html_text,
    lv_text         TYPE char64,
    lv_text_ref     TYPE char64,
    lv_date         TYPE d,
    lv_time         TYPE t,
    lv_date_hlp(12) TYPE c,
    lv_time_hlp(12) TYPE c,
    lv_tzone        TYPE TIMEZONE,
    lv_timestamp    TYPE timestampl,
    lv_timestamps   TYPE TIMESTAMP,
    ls_timehlp      TYPE TTZTSTMP.
  field-symbols: <value> type any,
                 <value_ref> TYPE ANY.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Other fields
*--------------------------------------------------------------------
  ls_text-tabname = us_dfies-tabname.
  ls_text-element = us_dfies-fieldname.
  ls_text-text1 = us_dfies-scrtext_l.
  ASSIGN COMPONENT us_dfies-fieldname OF
         STRUCTURE us_bdi TO <value>.
*....................................................................
* Fields with domains with fixed values
*....................................................................
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
*....................................................................
* Quantity and Amount fields
*....................................................................
  ELSEIF not us_dfies-reffield is initial.
    ASSIGN COMPONENT us_dfies-reffield OF
           STRUCTURE us_bdi TO <value_ref>.
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
*....................................................................
* Date fields
*....................................................................
  ELSEIF us_dfies-DATATYPE = 'DATS'.
     MOVE <value> TO lv_date.
     WRITE lv_date to ls_text-text2.
*....................................................................
* Time fields
*....................................................................
  ELSEIF us_dfies-DATATYPE = 'TIMS'.
     MOVE <value> TO lv_time.
     WRITE lv_time to ls_text-text2.
*....................................................................
* Long Timestamp
*....................................................................
 ELSEIF us_dfies-domname = 'TZNTSTMPL'.
   MOVE <value> TO lv_timestamp.
   lv_tzone = sy-zonlo.
   CONVERT TIME STAMP lv_timestamp
     TIME ZONE lv_tzone INTO DATE lv_date TIME lv_time.
   WRITE lv_date to lv_date_hlp.
   WRITE lv_time to lv_time_hlp.
   CONCATENATE lv_date_hlp '/' lv_time_hlp into ls_text-text2
     SEPARATED BY SPACE.
*....................................................................
* Short Timestamp
*....................................................................
 ELSEIF us_dfies-domname = 'TZNTSTMPS'.
   MOVE <value> TO lv_timestamps.
   lv_tzone = sy-zonlo.
   CONVERT TIME STAMP lv_timestamps
     TIME ZONE lv_tzone INTO DATE lv_date TIME lv_time.
   WRITE lv_date to lv_date_hlp.
   WRITE lv_time to lv_time_hlp.
   CONCATENATE lv_date_hlp '/' lv_time_hlp into ls_text-text2
     SEPARATED BY SPACE.
*....................................................................
* Never display any GUIDs!
*....................................................................
 ELSEIF ( us_dfies-domname = 'SYSUUID' OR
          us_dfies-domname = 'SYSUUID_C' ).
     RETURN.
*....................................................................
* OTHERS
*....................................................................
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
*--------------------------------------------------------------------
* Append the information to the text table
*--------------------------------------------------------------------
  ls_text-type = space.
  APPEND ls_text TO ct_text.
ENDFORM.                    " get_text_bdi
