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
* Special Treatment for the field PRODUCT
 DATA:
    lv_prdudl_prp_product      TYPE COMT_PRODUCT_GUID,
    lv_prdudl_prp_product_id   TYPE COMT_PRODUCT_ID.

lv_fieldname = 'PRODUCT_DESCR'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
lv_tabix = sy-tabix.

   IF NOT is_dli-PRODUCT IS INITIAL.
   lv_prdudl_prp_product = is_dli-PRODUCT.
   CALL FUNCTION 'COM_PRODUCT_ID_GET'
     EXPORTING
       IV_PRODUCT_GUID       = LV_prdudl_prp_PRODUCT
     IMPORTING
       EV_PRODUCT_ID         = LV_prdudl_prp_PRODUCT_ID
     EXCEPTIONS
       NOT_FOUND             = 0
       WRONG_CALL            = 0
       OTHERS                = 0.
     CALL FUNCTION 'CONVERSION_EXIT_PRID1_OUTPUT'
       EXPORTING
         INPUT         = lv_prdudl_prp_product_id
      IMPORTING
         OUTPUT        = lv_prdudl_prp_product_id.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname           = 'COMM_PRODUCT'
          lfieldname        = 'PRODUCT_ID'
          langu             = sy-langu
        IMPORTING
          dfies_wa          = ls_dfies
        EXCEPTIONS
          NOT_FOUND       = 1
          INTERNAL_ERROR  = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN.
      ELSE.
        ls_text-tabname = ls_dfies-tabname.
        ls_text-element = ls_dfies-fieldname.
        ls_text-text1 = ls_dfies-scrtext_l.
        ls_text-text2 = lv_prdudl_prp_product_id.
        ls_text-type = space.
        INSERT ls_text INTO lt_text index lv_tabix.
      ENDIF.
   ENDIF.
endif.
