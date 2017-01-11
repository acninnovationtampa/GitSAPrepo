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
  DATA:
    LV_QUANTITY      TYPE COMT_QUANTITY,
    LV_QTY_UNIT      TYPE COMT_UNIT,
    LV_QTY_UNIT_OV   TYPE COMT_UNIT,
    LV_BASE_UNIT     TYPE COMT_UNIT,
    LV_FACTOR        TYPE F.

  DATA:
    LV_PRODUCT  TYPE COMT_PRODUCT_GUID,
    LS_MSG_VAR  TYPE BEAS_MESSAGE_VAR,
    LS_PRDODL_QTA_ITC TYPE BEAS_ITC_WRK.

IF cs_dli-bill_relevance NE gc_bill_rel_value.

* do not proceed if product is not the same
  IF US_DLI_OV-PRODUCT <> CS_DLI-PRODUCT.
    LS_MSG_VAR-MSGV1 = GC_P_DLI_ITEMNO.
    LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = CS_DLI
        IS_MSG_VAR     = LS_MSG_VAR
      IMPORTING
        ES_MSG_VAR     = LS_MSG_VAR.
    MESSAGE E207(BEA) WITH LS_MSG_VAR-MSGV1 LS_MSG_VAR-MSGV2
                           US_DLI_OV-DLI_GUID CS_DLI-DLI_GUID
                      INTO GV_DUMMY.
    CV_RETURNCODE = 1.
    RETURN. "from FORM
  ELSE.
    LV_PRODUCT = CS_DLI-PRODUCT.
  ENDIF.

  LV_QTY_UNIT_OV = US_DLI_OV-QTY_UNIT.
  LV_QTY_UNIT  = CS_DLI-QTY_UNIT.
  LV_QUANTITY  = CS_DLI-QUANTITY.

  IF LV_QTY_UNIT_OV <> LV_QTY_UNIT.
    CV_RETURNCODE = 1.
    MESSAGE E208(BEA) INTO GV_DUMMY.
* perform unit conversion
    CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
         EXPORTING
           IV_PRODUCT_GUID            = LV_PRODUCT
           IV_INPUT                   = LV_QUANTITY
           IV_UNIT                    = LV_QTY_UNIT
           IV_BASE_UNIT               = LV_BASE_UNIT
           IV_FLAG_UNIT               = GC_TRUE
           IV_PRWB                    = GC_TRUE
         IMPORTING
           EV_BASE_UNIT               = LV_BASE_UNIT
           EV_OUTPUT                  = LV_QUANTITY
         EXCEPTIONS
           WRONG_CALL                 = 1
           NO_UNITS_FOUND             = 1
           BASE_UNIT_NOT_FOUND        = 1
           IV_UNIT_NOT_FOUND          = 1
           CONVERSION_NOT_FOUND       = 1
           OVERFLOW                   = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CV_RETURNCODE = SY-SUBRC.
      RETURN. "from FORM
    ELSE.
      CLEAR CV_RETURNCODE.
    ENDIF.
    IF CV_RETURNCODE <> 0.
      RETURN. "from FORM
    ENDIF.

    CALL FUNCTION 'COM_PRODUCT_UNIT_CONVERSION'
         EXPORTING
           IV_PRODUCT_GUID            = LV_PRODUCT
           IV_INPUT                   = LV_QUANTITY
           IV_UNIT                    = LV_QTY_UNIT_OV
           IV_BASE_UNIT               = LV_BASE_UNIT
         IMPORTING
           EV_OUTPUT                  = LV_QUANTITY
         EXCEPTIONS
           WRONG_CALL                 = 1
           NO_UNITS_FOUND             = 1
           BASE_UNIT_NOT_FOUND        = 1
           IV_UNIT_NOT_FOUND          = 1
           CONVERSION_NOT_FOUND       = 1
           OVERFLOW                   = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CV_RETURNCODE = SY-SUBRC.
      RETURN. "from FORM
    ENDIF.
  ENDIF. "IF LV_QTY_UNIT_OV <> LV_QTY_UNIT
* update new version with open version (including quantity)
  CS_DLI = US_DLI_OV.

  IF CS_DLI-QUANTITY NE 0.
    LV_FACTOR = 1 + ABS( LV_QUANTITY ) / ABS( CS_DLI-QUANTITY ).
    CS_DLI-NET_WEIGHT = CS_DLI-NET_WEIGHT * LV_FACTOR.
    CS_DLI-GROSS_WEIGHT = CS_DLI-GROSS_WEIGHT * LV_FACTOR.
  ENDIF.

  CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DERIVE'
    EXPORTING
      IS_DLI          = CS_DLI
      IS_ITC          = US_ITC
    IMPORTING
      ES_DLI          = CS_DLI
    EXCEPTIONS
      REJECT          = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO GV_DUMMY.
    CV_RETURNCODE = SY-SUBRC.
    RETURN. "from FORM
  ENDIF.
  LS_PRDODL_QTA_ITC = US_ITC.
  IF NOT CS_DLI-PRIDOC_GUID IS INITIAL.
    CALL FUNCTION 'BEA_PRC_O_GET_PROC'
      EXPORTING
        IV_PRIDOC_GUID = CS_DLI-PRIDOC_GUID
      IMPORTING
        EV_PRIC_PROC   = LS_PRDODL_QTA_ITC-DLI_PRC_PROC.
  ENDIF.

  CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_QTY_ADD'
       EXPORTING
         IS_DLI            = CS_DLI
         IS_ITC            = LS_PRDODL_QTA_ITC
         IV_QUANTITY       = LV_QUANTITY
       IMPORTING
         ES_DLI            = CS_DLI
       EXCEPTIONS
         REJECT            = 1
         OTHERS            = 2.
  IF SY-SUBRC <> 0.
    IF NOT CS_DLI-INCOMP_ID = GC_INCOMP_FATAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO GV_DUMMY.
      CV_RETURNCODE = SY-SUBRC.
      RETURN. "from FORM
    ENDIF.
  ENDIF.

  ADD LV_QUANTITY TO CS_DLI-QUANTITY.
* remove bill block resulting from negative quantity,
* if new quantity is positive
  IF CS_DLI-BILL_BLOCK   = GC_BILLBLOCK_QC AND
     CS_DLI-QUANTITY  > 0.
    CLEAR CS_DLI-BILL_BLOCK.
  ENDIF.
  IF CS_DLI-BILL_BLOCK IS INITIAL.
    CS_DLI-BILL_BLOCK = US_ITC-BILL_BLOCK.
  ENDIF.
ENDIF.
