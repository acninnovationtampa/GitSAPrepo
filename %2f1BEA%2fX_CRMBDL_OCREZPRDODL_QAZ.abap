*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================
*-----------------------------------------------------------------*
*     FORM PRDODL_QAZ_QUANTITY_GET
*-----------------------------------------------------------------*
*  Compute quantity for the current duelist item from the
*  cumulated quantity given by the source application and the quantity
*  billed so far.
*-----------------------------------------------------------------*
FORM PRDODL_QAZ_QUANTITY_ADAPT
  USING
    US_DLI_INT         TYPE /1BEA/S_CRMB_DLI_INT
    UT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK
  CHANGING
    CS_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK
    CS_BILLED_QUANTITY TYPE BEA_QUANTITY
    CV_BUFFER_ADD      TYPE BEA_BOOLEAN
    CT_RETURN          TYPE BEAT_RETURN
    CV_RETURNCODE      TYPE SYSUBRC.

  DATA:
    LS_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_OV          TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_BILLED_QUANTITY TYPE COMT_QUANTITY,
    LV_BILLED_ITEM     TYPE BEA_BOOLEAN,
    LV_OUTPUT_NEW      TYPE COMT_QUANTITY,
    LV_OUTPUT_OLD      TYPE COMT_QUANTITY,
    LV_INPUT           TYPE COMT_QUANTITY,
    LV_UNIT_OLD        TYPE COMT_UNIT,
    LV_UNIT_NEW        TYPE COMT_UNIT,
    LV_BASE_UNIT       TYPE COMT_UNIT,
    LV_PRODUCT         TYPE COMT_PRODUCT_GUID,
    LV_MINUS(1),
    LV_FACTOR          TYPE F,
    LV_INVALID_QTY_UNIT_CHANGE TYPE C,
    LV_QTY_UNIT_CHANGE TYPE C.

    CHECK CS_DLI_WRK-SRC_REJECT IS INITIAL.
    CV_BUFFER_ADD = GC_TRUE.
    IF US_DLI_INT-SRC_ACTIVITY = GC_SRC_ACTIVITY_DL04.
*     no quantity adaption for incomplete entries with typ A
      LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
        WHERE BILL_STATUS =  GC_BILLSTAT_TODO
          AND INCOMP_ID   <> GC_INCOMP_OK.
        INSERT LS_DLI_WRK INTO TABLE LT_DLI_OV.
      ENDLOOP.
      SORT LT_DLI_OV BY INCOMP_ID DESCENDING.
      READ TABLE LT_DLI_OV INDEX 1 INTO LS_DLI_WRK.
      IF LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
        RETURN.
      ENDIF.
    ENDIF.
    LV_UNIT_NEW = CS_DLI_WRK-QTY_UNIT.
    LV_OUTPUT_NEW = CS_DLI_WRK-QUANTITY.
    LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
      WHERE BILL_STATUS =  GC_BILLSTAT_DONE AND
            QTY_UNIT    <> LV_UNIT_NEW.
      LV_QTY_UNIT_CHANGE = GC_TRUE.
      IF LV_UNIT_NEW IS INITIAL.
        LV_INVALID_QTY_UNIT_CHANGE = GC_TRUE.
        EXIT.
      ENDIF.
      IF LS_DLI_WRK-QTY_UNIT IS INITIAL.
        LV_INVALID_QTY_UNIT_CHANGE = GC_TRUE.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT LV_INVALID_QTY_UNIT_CHANGE IS INITIAL.
      MESSAGE E105(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = CS_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
      CV_RETURNCODE = 1.
      RETURN. "from FORM
    ENDIF.
    IF LV_QTY_UNIT_CHANGE IS INITIAL.
      LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
        WHERE BILL_STATUS = GC_BILLSTAT_DONE.
        ADD LS_DLI_WRK-QUANTITY TO LV_BILLED_QUANTITY.
      ENDLOOP.
      IF SY-SUBRC = 0.
        LV_BILLED_ITEM = GC_TRUE.
      ENDIF.
      SUBTRACT LV_BILLED_QUANTITY FROM LV_OUTPUT_NEW.
    ELSE.
      LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
        WHERE BILL_STATUS = GC_BILLSTAT_DONE.
        LV_INPUT = LS_DLI_WRK-QUANTITY.
        LV_UNIT_OLD  = LS_DLI_WRK-QTY_UNIT.
        IF LS_DLI_WRK-PRODUCT <> CS_DLI_WRK-PRODUCT.
          MESSAGE E207(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                               LS_DLI_WRK-DLI_GUID CS_DLI_WRK-DLI_GUID
                            INTO GV_DUMMY.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = CS_DLI_WRK
              IT_RETURN      = CT_RETURN
            IMPORTING
              ET_RETURN      = CT_RETURN.
          CV_RETURNCODE = 1.
          RETURN. "from FORM
        ELSE.
          LV_PRODUCT = CS_DLI_WRK-PRODUCT.
        ENDIF.
        CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
             EXPORTING
               IV_PRODUCT_GUID        = LV_PRODUCT
               IV_INPUT               = LV_INPUT
               IV_UNIT                = LV_UNIT_OLD
               IV_BASE_UNIT           = LV_BASE_UNIT
               IV_FLAG_UNIT           = 'X'
               IV_PRWB                = 'X'
             IMPORTING
               EV_BASE_UNIT         = LV_BASE_UNIT
               EV_OUTPUT            = LV_OUTPUT_OLD
             EXCEPTIONS
               WRONG_CALL             = 1
               NO_UNITS_FOUND         = 1
               BASE_UNIT_NOT_FOUND    = 1
               IV_UNIT_NOT_FOUND      = 1
               CONVERSION_NOT_FOUND   = 1
               OVERFLOW               = 1.
        IF SY-SUBRC <> 0.
          CV_RETURNCODE = SY-SUBRC.
          message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into gv_dummy.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = CS_DLI_WRK
              IT_RETURN      = CT_RETURN
            IMPORTING
              ET_RETURN      = CT_RETURN.
          RETURN. "from FORM
        ENDIF.
        ADD LV_OUTPUT_OLD TO LV_BILLED_QUANTITY.
      ENDLOOP. "LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
      IF SY-SUBRC = 0.
        LV_BILLED_ITEM = GC_TRUE.
      ENDIF.
      LV_OUTPUT_NEW = CS_DLI_WRK-QUANTITY.
      IF LV_BILLED_QUANTITY <> 0.
        LV_INPUT = CS_DLI_WRK-QUANTITY.
        CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
          EXPORTING
            IV_PRODUCT_GUID      = LV_PRODUCT
            IV_INPUT             = LV_INPUT
            IV_UNIT              = LV_UNIT_NEW
            IV_BASE_UNIT         = LV_BASE_UNIT
            IV_FLAG_UNIT         = 'X'
            IV_PRWB              = 'X'
          IMPORTING
            EV_BASE_UNIT         = LV_BASE_UNIT
            EV_OUTPUT            = LV_OUTPUT_NEW
          EXCEPTIONS
            WRONG_CALL           = 1
            NO_UNITS_FOUND       = 1
            BASE_UNIT_NOT_FOUND  = 1
            IV_UNIT_NOT_FOUND    = 1
            CONVERSION_NOT_FOUND = 1
            OVERFLOW             = 1.
        IF SY-SUBRC <> 0.
          CV_RETURNCODE = SY-SUBRC.
          message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into gv_dummy.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = CS_DLI_WRK
              IT_RETURN      = CT_RETURN
            IMPORTING
              ET_RETURN      = CT_RETURN.
          RETURN. "from FORM
        ENDIF.
        SUBTRACT LV_BILLED_QUANTITY FROM LV_OUTPUT_NEW.
        LV_INPUT = LV_OUTPUT_NEW.
        IF LV_INPUT LT 0.
          LV_MINUS = 'X'.
          LV_INPUT = LV_INPUT * ( -1 ).
        ENDIF.
        CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
             EXPORTING
               IV_PRODUCT_GUID        = LV_PRODUCT
               IV_INPUT               = LV_INPUT
               IV_UNIT                = LV_UNIT_NEW
               IV_BASE_UNIT           = LV_BASE_UNIT
             IMPORTING
               EV_BASE_UNIT           = LV_BASE_UNIT
               EV_OUTPUT              = LV_OUTPUT_NEW
             EXCEPTIONS
               WRONG_CALL             = 1
               NO_UNITS_FOUND         = 1
               BASE_UNIT_NOT_FOUND    = 1
               IV_UNIT_NOT_FOUND      = 1
               CONVERSION_NOT_FOUND   = 1
               OVERFLOW               = 1.
        IF SY-SUBRC <> 0.
          CV_RETURNCODE = SY-SUBRC.
          message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into gv_dummy.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = CS_DLI_WRK
              IT_RETURN      = CT_RETURN
            IMPORTING
              ET_RETURN      = CT_RETURN.
          RETURN. "from FORM
        ENDIF.
        IF NOT LV_MINUS IS INITIAL.
          LV_OUTPUT_NEW = LV_OUTPUT_NEW * ( -1 ).
        ENDIF.
      ENDIF.
    ENDIF.
    IF CS_DLI_WRK-QUANTITY NE 0.
      LV_FACTOR = ABS( LV_OUTPUT_NEW ) / ABS( CS_DLI_WRK-QUANTITY ).
      CS_DLI_WRK-NET_WEIGHT = CS_DLI_WRK-NET_WEIGHT * LV_FACTOR.
      CS_DLI_WRK-GROSS_WEIGHT = CS_DLI_WRK-GROSS_WEIGHT * LV_FACTOR.
    ENDIF.
    IF NOT LV_BILLED_QUANTITY IS INITIAL.
      IF LV_OUTPUT_NEW IS INITIAL.
        CV_BUFFER_ADD = GC_FALSE.
      ENDIF.
    ELSE.  " allow for zero quantity billed item transferred again
      IF CS_DLI_WRK-QUANTITY = 0        AND
         LV_OUTPUT_NEW       IS INITIAL AND
         LV_BILLED_ITEM      = GC_TRUE.
        CV_BUFFER_ADD = GC_FALSE.
      ENDIF.
    ENDIF.
    CS_DLI_WRK-QUANTITY = LV_OUTPUT_NEW.
    CS_BILLED_QUANTITY  = LV_BILLED_QUANTITY.
    IF US_DLI_INT-QUANTITY > 0.
      IF CS_DLI_WRK-QUANTITY < 0 AND
         CS_DLI_WRK-BILL_BLOCK <> GC_BILLBLOCK_EXTERN.
        CS_DLI_WRK-BILL_BLOCK = GC_BILLBLOCK_QC.
      ENDIF.
    ENDIF.
  ENDFORM.
*-----------------------------------------------------------------*
*     FORM PRDODL_QAZ_QUANTITY_GET
*-----------------------------------------------------------------*
FORM PRDODL_QAZ_QUANTITY_GET
  USING
    UT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK
    UV_QTY_UNIT        TYPE COMT_UNIT
  CHANGING
    CV_BILLED_QUANTITY TYPE COMT_QUANTITY
    CV_NET_WEIGHT      TYPE CRMT_NET_WEIGHT
    CV_GROSS_WEIGHT    TYPE CRMT_GROSS_WEIGHT
    CT_RETURN          TYPE BEAT_RETURN
    CV_RETURNCODE      TYPE SYSUBRC.

  DATA:
    LS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_OUTPUT_OLD  TYPE COMT_QUANTITY,
    lv_INPUT       type comt_quantity,
    LV_UNIT_OLD    TYPE COMT_UNIT,
    LV_UNIT_NEW    TYPE COMT_UNIT,
    lv_base_unit   type comt_unit,
    lv_product     TYPE COMT_PRODUCT_GUID,
    LV_MINUS       TYPE CHAR1.

  CLEAR CV_RETURNCODE.
  LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
    WHERE BILL_STATUS = GC_BILLSTAT_DONE.
    LV_INPUT = LS_DLI_WRK-QUANTITY.
    LV_UNIT_OLD = LS_DLI_WRK-QTY_UNIT.
    LV_PRODUCT = LS_DLI_WRK-PRODUCT.
    CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
         EXPORTING
           IV_PRODUCT_GUID        = LV_PRODUCT
           IV_INPUT               = LV_INPUT
           IV_UNIT                = LV_UNIT_OLD
           IV_BASE_UNIT           = LV_BASE_UNIT
           IV_FLAG_UNIT           = GC_TRUE
           IV_PRWB                = GC_TRUE
         IMPORTING
           EV_BASE_UNIT           = LV_BASE_UNIT
           EV_OUTPUT              = LV_OUTPUT_OLD
         EXCEPTIONS
           WRONG_CALL             = 1
           NO_UNITS_FOUND         = 2
           BASE_UNIT_NOT_FOUND    = 3
           IV_UNIT_NOT_FOUND      = 4
           CONVERSION_NOT_FOUND   = 5
           OVERFLOW               = 6.
    IF SY-SUBRC <> 0.
      CV_RETURNCODE = SY-SUBRC.
      message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into gv_dummy.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = LS_DLI_WRK
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
      RETURN. "from FORM
    ENDIF.
    ADD LV_OUTPUT_OLD TO CV_BILLED_QUANTITY.
    ADD LS_DLI_WRK-NET_WEIGHT TO CV_NET_WEIGHT.
    ADD LS_DLI_WRK-GROSS_WEIGHT TO CV_GROSS_WEIGHT.
  ENDLOOP.
  IF CV_BILLED_QUANTITY <> 0.
    LV_INPUT = CV_BILLED_QUANTITY.
    IF LV_INPUT < 0.
      LV_MINUS = GC_TRUE.
      LV_INPUT = LV_INPUT * ( -1 ).
    ENDIF.
    LV_UNIT_NEW = UV_QTY_UNIT.
    CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
      EXPORTING
        IV_PRODUCT_GUID      = LV_PRODUCT
        IV_INPUT             = LV_INPUT
        IV_UNIT              = LV_UNIT_NEW
        IV_BASE_UNIT         = LV_BASE_UNIT
        IV_FLAG_UNIT         = GC_TRUE
        IV_PRWB              = GC_TRUE
      IMPORTING
        EV_BASE_UNIT         = LV_BASE_UNIT
        EV_OUTPUT            = CV_BILLED_QUANTITY
      EXCEPTIONS
        WRONG_CALL           = 1
        NO_UNITS_FOUND       = 1
        BASE_UNIT_NOT_FOUND  = 1
        IV_UNIT_NOT_FOUND    = 1
        CONVERSION_NOT_FOUND = 1
        OVERFLOW             = 1.
    IF SY-SUBRC = 0.
      IF LV_MINUS = GC_TRUE.
        CV_BILLED_QUANTITY = CV_BILLED_QUANTITY * ( -1 ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.              "PRDODL_QAZ_FORM QUANTITY_GET

*-----------------------------------------------------------------*
*     FORM PRDODL_QAZ_QUANTITY_GET
*-----------------------------------------------------------------*
*  Compute net value for the current duelist item from the
*  cumulated net value given by the source application and the net value
*  billed so far.
*-----------------------------------------------------------------*
FORM PRDODL_NET_VALUE_ADAPT
  USING
    US_DLI_INT         TYPE /1BEA/S_CRMB_DLI_INT
    UT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK
  CHANGING
    CS_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK
    CV_BUFFER_ADD      TYPE BEA_BOOLEAN
    CT_RETURN          TYPE BEAT_RETURN
    CV_RETURNCODE      TYPE SYSUBRC.

  DATA:
    LS_DLI_WRK                 TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_INVALID_CURRENCY_CHANGE TYPE C,
    LV_BILLED_NET_VALUE        TYPE CRMT_NET_VALUE,
    LV_NEW_NET_VALUE           TYPE CRMT_NET_VALUE,
    LV_BILLED_ITEM             TYPE C.

    CHECK CS_DLI_WRK-SRC_REJECT IS INITIAL OR
          CS_DLI_WRK-SRC_REJECT = GC_SRC_REJECT_OPEN.
    CV_BUFFER_ADD = GC_TRUE.
    LV_NEW_NET_VALUE = CS_DLI_WRK-NET_VALUE.
    LOOP AT UT_DLI_WRK INTO LS_DLI_WRK
      WHERE BILL_STATUS = GC_BILLSTAT_DONE.
      LV_BILLED_ITEM = GC_TRUE.
      IF LS_DLI_WRK-DOC_CURRENCY = CS_DLI_WRK-DOC_CURRENCY.
        ADD LS_DLI_WRK-NET_VALUE TO LV_BILLED_NET_VALUE.
      ELSE.
*do the currency conversion here
*currently, the currency conversion rule is not available, so we first mark it as incomplete now
      ENDIF.
    ENDLOOP.
    SUBTRACT LV_BILLED_NET_VALUE FROM LV_NEW_NET_VALUE.
    IF LV_BILLED_NET_VALUE IS NOT INITIAL.
      IF LV_NEW_NET_VALUE IS INITIAL.
        CV_BUFFER_ADD = GC_FALSE.
      ENDIF.
    ELSE.
      IF CS_DLI_WRK-NET_VALUE = 0 AND
         LV_NEW_NET_VALUE IS INITIAL AND
         LV_BILLED_ITEM = GC_TRUE.
        CV_BUFFER_ADD = GC_FALSE.
      ENDIF.
    ENDIF.
    CS_DLI_WRK-NET_VALUE = LV_NEW_NET_VALUE.
ENDFORM.    "PRDODL_NET_VALUE_ADAPT
