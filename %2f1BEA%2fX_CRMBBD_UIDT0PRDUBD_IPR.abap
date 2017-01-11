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
  DATA: lv_prdubd_ipr_product      TYPE COMT_PRODUCT_GUID,
        lv_prdubd_ipr_product_id   TYPE COMT_PRODUCT_ID.
lv_fieldname = 'PRODUCT_DESCR'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
check sy-subrc is initial.
lv_tabix = sy-tabix.
     lv_prdubd_ipr_product = is_bdi-PRODUCT.
     IF NOT lv_prdubd_ipr_product IS INITIAL.
       CALL FUNCTION 'COM_PRODUCT_ID_GET'
          EXPORTING
            IV_PRODUCT_GUID       = LV_prdubd_ipr_PRODUCT
          IMPORTING
            EV_PRODUCT_ID         = LV_prdubd_ipr_PRODUCT_ID.
       CALL FUNCTION 'CONVERSION_EXIT_PRID1_OUTPUT'
         EXPORTING
           INPUT         = lv_prdubd_ipr_product_id
        IMPORTING
           OUTPUT        = lv_prdubd_ipr_product_id.
       IF NOT LV_prdubd_ipr_PRODUCT_ID IS INITIAL.
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
             RETURN. "from form
          ELSE.
        ls_text-tabname = ls_dfies-tabname.
        ls_text-element = ls_dfies-fieldname.
        ls_text-text1 = ls_dfies-scrtext_l.
        ls_text-text2 = lv_prdubd_ipr_product_id.
        ls_text-type = space.
        INSERT ls_text INTO lt_text index lv_tabix.
          ENDIF.
       ENDIF.
     ENDIF.
