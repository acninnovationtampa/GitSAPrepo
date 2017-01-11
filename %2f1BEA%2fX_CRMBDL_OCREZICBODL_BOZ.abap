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
*--------------------------------------------------------------------*
*       Form  ICBODL_BOZ_BILL_ORG_DERIVE
*--------------------------------------------------------------------*
FORM ICBODL_BOZ_BILL_ORG_DERIVE
  USING
    US_DLI        TYPE /1BEA/S_CRMB_DLI_WRK
    US_ITC        TYPE BEAS_ITC_WRK
  CHANGING
    CV_BILL_ORG   TYPE BEA_BILL_ORG
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SY-SUBRC.

  CALL FUNCTION '/1BEA/CRMB_DL_OFI_O_DERIVE'
    EXPORTING
      IS_DLI      = US_DLI
      IS_ITC      = US_ITC
    IMPORTING
      EV_BILL_ORG = CV_BILL_ORG
      ET_RETURN   = CT_RETURN
    EXCEPTIONS
      REJECT      = 1
      OTHERS      = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
  ENDIF.
ENDFORM.                    " BILL_ORG_DERIVE
*--------------------------------------------------------------------*
*       Form ICBODL_BOZ_ORG_DATA_COMPARE
*--------------------------------------------------------------------*
FORM ICBODL_BOZ_ORG_DATA_COMPARE
  USING
    US_DLI        TYPE /1BEA/S_CRMB_DLI_WRK
    UV_BILL_ORG   TYPE BEA_BILL_ORG
  CHANGING
    CV_EQUAL      TYPE BEA_BOOLEAN
    CT_RETURN     TYPE BEAT_RETURN
    CV_RETURNCODE TYPE SY-SUBRC.

  CALL FUNCTION '/1BEA/CRMB_DL_OFI_O_COMPARE'
    EXPORTING
      IS_DLI      = US_DLI
      IV_BILL_ORG = UV_BILL_ORG
    IMPORTING
      EV_EQUAL    = CV_EQUAL
      ET_RETURN   = CT_RETURN
    EXCEPTIONS
      OTHERS      = 0.
ENDFORM.                    " ORG_DATA_COMPARE
*--------------------------------------------------------------------*
*       Form  ICBODL_BOZ_SALES_AREA_DERIVE
*--------------------------------------------------------------------*
FORM ICBODL_BOZ_SALES_AREA_DERIVE
  USING
    UV_BILL_ORG   TYPE BEA_BILL_ORG
  CHANGING
    CS_SALES_AREA_IB TYPE ofit_sales_area_ib
    CV_RETURNCODE    TYPE SY-SUBRC.

  call function 'CRM_OFI_SALES_AREA_IB_READ'
    exporting
      iv_bill_org         = UV_BILL_ORG
    importing
      es_sales_area_ib    = cs_sales_area_ib
    exceptions
      reject              = 1
      others              = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
  ENDIF.
ENDFORM.
