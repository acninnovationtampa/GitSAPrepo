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
 CONSTANTS:
   LC_ADDR_TYPE_ORG  TYPE AD_ADRTYPE VALUE '1',
   LC_ADDR_TYPE_PER  TYPE AD_ADRTYPE VALUE '2',
   LC_ADDR_TYPE_CON  TYPE AD_ADRTYPE VALUE '3'.

 CONSTANTS: LC_PRCOBD_CDT_CASH_DISC_ATTR TYPE PRCT_ATTR_NAME
              VALUE 'CASH_DISC',
            LC_PRCOBD_CDT_TAXBAS_ATTR TYPE PRCT_ATTR_NAME
              VALUE 'TAX_X_TAXBAS_NET',
            LC_PRCOBD_CDT_DISBAS_ATTR TYPE PRCT_ATTR_NAME
              VALUE 'TAX_X_DISBAS_NET',
            LC_PRCOBD_CDT_CTY_FRO_ATTR TYPE PRCT_ATTR_NAME
              VALUE 'TAX_X_EU_CTY_FRO'.
 DATA:
   LV_ADDR_NR        TYPE AD_ADDRNUM,
   LV_ADDR_NP        TYPE AD_PERSNUM,
   LV_ADDR_TYPE      TYPE AD_ADRTYPE,
   LS_BAPIADDR1      TYPE BAPIADDR1,
   LS_BAPIADDR2      TYPE BAPIADDR2,
   LS_BAPIADDR3      TYPE BAPIADDR3,
   LV_COUNTRY        TYPE LAND1.
 DATA:
   LS_PRCOBD_CDT_ATTR_NAME_VALUE TYPE PRCT_ATTR_NAME_VALUE,
   LV_PRCOBD_CDT_CASH_DISCOUNT   TYPE CRMT_CASH_DISC.

 STATICS:
   LV_BILL_ORG_BUF   TYPE BEA_BILL_ORG,
   LS_T005_BUF       TYPE T005.

* Check if Cash Discount is requested.
   READ TABLE GT_ALL_ATTR_NAMES TRANSPORTING NO FIELDS
     WITH KEY TABLE_LINE = LC_PRCOBD_CDT_CASH_DISC_ATTR
     BINARY SEARCH.
   IF SY-SUBRC = 0.
     CLEAR LV_PRCOBD_CDT_CASH_DISCOUNT.
     CALL FUNCTION 'CRM_TAX_CASH_DISC_FILL'
       EXPORTING
         IV_PRODUCT_GUID = IS_BDI_WRK-PRODUCT
         IV_SALES_ORG    = IS_BDI_WRK-SALES_ORG
         IV_DISTR_CHAN   = IS_BDI_WRK-DIS_CHANNEL
       IMPORTING
         EV_CASH_DISC    = LV_PRCOBD_CDT_CASH_DISCOUNT.
     IF LV_PRCOBD_CDT_CASH_DISCOUNT IS NOT INITIAL.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_NAME  = LC_PRCOBD_CDT_CASH_DISC_ATTR.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_VALUE = LV_PRCOBD_CDT_CASH_DISCOUNT.
       PERFORM FILL_ITEM_NAME_VALUE_TAB USING LS_PRCOBD_CDT_ATTR_NAME_VALUE
                                              GC_TRUE
                                        CHANGING LS_PRC_ITEM.
     ENDIF.

     IF LV_BILL_ORG_BUF NE IS_BDH_WRK-BILL_ORG.
       LV_BILL_ORG_BUF = IS_BDH_WRK-BILL_ORG.

       CALL FUNCTION 'COM_PARTNER_ADDRESS_DETERMINE'
         EXPORTING
           IV_PARTNER                 = LV_BILL_ORG_BUF
         IMPORTING
           EV_ADDR_NR                 = LV_ADDR_NR
           EV_ADDR_NP                 = LV_ADDR_NP
           EV_ADDR_TYPE               = LV_ADDR_TYPE
         EXCEPTIONS
           PARTNER_NOT_DEFINED        = 1
           PARTNER_DOES_NOT_EXIST     = 2
           REL_PARTNER_DOES_NOT_EXIST = 3
           NO_ADDRESS_FOUND           = 4
           OTHERS                     = 5.

       IF SY-SUBRC EQ 0.
         CALL FUNCTION 'COM_PARTNER_ADDRESS_GET_COMPL'
           EXPORTING
             IV_ADDR_NR     = LV_ADDR_NR
             IV_ADDR_NP     = LV_ADDR_NP
             IV_ADDR_TYPE   = LV_ADDR_TYPE
           IMPORTING
             ES_BAPIADDR1   = LS_BAPIADDR1
             ES_BAPIADDR2   = LS_BAPIADDR2
             ES_BAPIADDR3   = LS_BAPIADDR3
           EXCEPTIONS
             ERROR_OCCURRED = 1
             OTHERS         = 2.

         IF SY-SUBRC EQ 0.
           CASE LV_ADDR_TYPE.
             WHEN LC_ADDR_TYPE_ORG.
               LV_COUNTRY = LS_BAPIADDR1-COUNTRY.
             WHEN LC_ADDR_TYPE_PER.
               LV_COUNTRY = LS_BAPIADDR2-COUNTRY.
             WHEN LC_ADDR_TYPE_CON.
               LV_COUNTRY = LS_BAPIADDR3-COUNTRY.
           ENDCASE.
         ENDIF.
       ENDIF.

       IF LS_T005_BUF-LAND1 NE LV_COUNTRY.
         CLEAR LS_T005_BUF.
         SELECT SINGLE * FROM T005 INTO LS_T005_BUF
           WHERE LAND1 = LV_COUNTRY.
       ENDIF.
     ENDIF.
   ENDIF.

   READ TABLE GT_ALL_ATTR_NAMES TRANSPORTING NO FIELDS
     WITH KEY TABLE_LINE = LC_PRCOBD_CDT_TAXBAS_ATTR
     BINARY SEARCH.
   IF SY-SUBRC = 0.
     IF LS_T005_BUF-XMWSN IS NOT INITIAL.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_NAME  = LC_PRCOBD_CDT_TAXBAS_ATTR.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_VALUE = LS_T005_BUF-XMWSN.
       PERFORM FILL_ITEM_NAME_VALUE_TAB USING LS_PRCOBD_CDT_ATTR_NAME_VALUE
                                              GC_TRUE
                                        CHANGING LS_PRC_ITEM.
     ENDIF.
   ENDIF.

   READ TABLE GT_ALL_ATTR_NAMES TRANSPORTING NO FIELDS
     WITH KEY TABLE_LINE = LC_PRCOBD_CDT_DISBAS_ATTR
     BINARY SEARCH.
   IF SY-SUBRC = 0.
     IF LS_T005_BUF-XMWSN IS NOT INITIAL.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_NAME = LC_PRCOBD_CDT_DISBAS_ATTR.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_VALUE = LS_T005_BUF-XSKFN.
       PERFORM FILL_ITEM_NAME_VALUE_TAB USING LS_PRCOBD_CDT_ATTR_NAME_VALUE
                                              GC_TRUE
                                        CHANGING LS_PRC_ITEM.
     ENDIF.
   ENDIF.

   READ TABLE GT_ALL_ATTR_NAMES TRANSPORTING NO FIELDS
     WITH KEY TABLE_LINE = LC_PRCOBD_CDT_CTY_FRO_ATTR
     BINARY SEARCH.
   IF SY-SUBRC = 0.
     IF LS_T005_BUF-XMWSN IS NOT INITIAL.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_NAME = LC_PRCOBD_CDT_CTY_FRO_ATTR.
       LS_PRCOBD_CDT_ATTR_NAME_VALUE-ATTR_VALUE = LS_T005_BUF-XEGLD.
       PERFORM FILL_ITEM_NAME_VALUE_TAB USING LS_PRCOBD_CDT_ATTR_NAME_VALUE
                                              GC_TRUE
                                        CHANGING LS_PRC_ITEM.
     ENDIF.
   ENDIF.
