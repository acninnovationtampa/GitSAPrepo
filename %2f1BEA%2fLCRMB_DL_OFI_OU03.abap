FUNCTION /1BEA/CRMB_DL_OFI_O_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(EV_BILL_ORG) TYPE  BEA_BILL_ORG
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
* Time  : 13:53:10
*
*======================================================================
  DATA:
    LV_BILL_ORG_D  TYPE BEA_BILL_ORG,
    LV_COMPANY_S   TYPE OFIT_BUKRS,
    LV_COMPANY_D   TYPE OFIT_BUKRS.
*--------------------------------------------------------------------*
* BEGIN INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* END INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* BEGIN SERVICE CALL
*--------------------------------------------------------------------*
    PERFORM BILL_ORG_FILL
      USING
        IS_DLI
      CHANGING
        LV_BILL_ORG_D
        ET_RETURN.
  IF NOT LV_BILL_ORG_D IS INITIAL.
    PERFORM COMPANY_CODE_FILL
      USING
        LV_BILL_ORG_D
      CHANGING
        LV_COMPANY_D
        ET_RETURN.
    PERFORM COMPANY_CODE_FILL
      USING
        IS_DLI-BILL_ORG
      CHANGING
        LV_COMPANY_S
        ET_RETURN.
    IF NOT LV_COMPANY_S IS INITIAL AND
       NOT LV_COMPANY_D IS INITIAL.
      IF LV_COMPANY_S <> LV_COMPANY_D.
        EV_BILL_ORG = LV_BILL_ORG_D.
      ENDIF.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
* END SERVICE CALL
*--------------------------------------------------------------------*
ENDFUNCTION.
*--------------------------------------------------------------------*
*       Form BILL_ORG_CND_FILL
*--------------------------------------------------------------------*
FORM BILL_ORG_CND_FILL
  USING
    US_DLI         TYPE /1BEA/S_CRMB_DLI_WRK
    UV_IC_LEVEL    TYPE BEA_IC_LEVEL
  CHANGING
    CV_BILL_ORG    TYPE BEA_BILL_ORG
    CT_RETURN      TYPE BEAT_RETURN.

ENDFORM.                    " BILL_ORG_CND_FILL
