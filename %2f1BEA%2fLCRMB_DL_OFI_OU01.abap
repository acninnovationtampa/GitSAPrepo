FUNCTION /1BEA/CRMB_DL_OFI_O_COMPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IV_BILL_ORG) TYPE  BEA_BILL_ORG
*"  EXPORTING
*"     REFERENCE(EV_EQUAL) TYPE  BEA_BOOLEAN
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
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
    LS_MSG_VAR    TYPE BEAS_MESSAGE_VAR,
    LV_COMPANY_N  TYPE OFIT_BUKRS,
    LV_COMPANY_O  TYPE OFIT_BUKRS.
*--------------------------------------------------------------------*
*  BEGIN INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*  END INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*  BEGIN SERVICE CALL
*--------------------------------------------------------------------*
  PERFORM COMPANY_CODE_FILL
    USING
      IS_DLI-BILL_ORG
    CHANGING
      LV_COMPANY_O
      ET_RETURN.
  PERFORM COMPANY_CODE_FILL
    USING
      IV_BILL_ORG
    CHANGING
      LV_COMPANY_N
      ET_RETURN.
  IF LV_COMPANY_O <> LV_COMPANY_N.
    EV_EQUAL = GC_FALSE.
    LS_MSG_VAR-MSGV1 = GC_P_DLI_ITEMNO.
    LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = IS_DLI
        IS_MSG_VAR     = LS_MSG_VAR
      IMPORTING
        ES_MSG_VAR     = LS_MSG_VAR.
    MESSAGE E261(BEA) WITH LS_MSG_VAR-MSGV1 LS_MSG_VAR-MSGV2
                      INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                 CHANGING ET_RETURN.
  ENDIF.
*--------------------------------------------------------------------*
*   END CALL ORGFINDER
* -------------------------------------------------------------------*
ENDFUNCTION.
*--------------------------------------------------------------------*
*       Form COMPANY_CODE_FILL
*--------------------------------------------------------------------*
FORM COMPANY_CODE_FILL
  USING
    UV_BILL_ORG    TYPE BEA_BILL_ORG
  CHANGING
    CV_COMPANY     TYPE OFIT_BUKRS
    CT_RETURN      TYPE BEAT_RETURN.

  DATA:
    LS_KEYS        TYPE CRMT_OFI_FIELD_VALUE,
    LT_KEYS        TYPE CRMT_OFI_FIELD_VALUE_T,
    LS_RESULT      TYPE CRMT_OFI_FIELD_VALUE,
    LT_RESULT      TYPE CRMT_OFI_FIELD_VALUE_T,
    LV_SCENARIO    TYPE CRMT_OFI_BS_IDENTIFICATION.
  CONSTANTS:
    LC_SALES       TYPE CRMT_OFI_BS_IDENTIFICATION VALUE 'CRM_SALES'.
*--------------------------------------------------------------------*
* BEGIN SERVICE CALL
*--------------------------------------------------------------------*
  MOVE UV_BILL_ORG TO LS_KEYS-VALUE.
  LV_SCENARIO   = LC_SALES.
  LS_KEYS-FIELD = GC_OFI_FIELDNAMES-BILLING_ORG.
  APPEND LS_KEYS TO LT_KEYS.
*   fill result
  LS_RESULT = GC_OFI_FIELDNAMES-COMPANY_CODE.
  APPEND LS_RESULT TO LT_RESULT.
*     call orgfinder
  CALL FUNCTION 'CRM_SIMPLE_OFI_API'
    EXPORTING
      IT_KEYS                     = LT_KEYS
      IV_SCENARIO                 = LV_SCENARIO
    CHANGING
      CT_RESULT                   = LT_RESULT
    EXCEPTIONS
      NOTHING_FOUND               = 1
      OFICUSTOMIZING_INCONSISTENT = 2
      RESULT_NOT_SPECIFIED        = 3
      OTHERS                      = 4.
  IF SY-SUBRC = 0.
    READ TABLE LT_RESULT INTO LS_RESULT INDEX 1.
    IF SY-SUBRC = 0.
      CV_COMPANY = LS_RESULT-VALUE.
    ENDIF.
  ELSE.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*--------------------------------------------------------------------*
* END SERVICE CALL
*--------------------------------------------------------------------*
ENDFORM.                    " COMPANY_CODE_FILL
