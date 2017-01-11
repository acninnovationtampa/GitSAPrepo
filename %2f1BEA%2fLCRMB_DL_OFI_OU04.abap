FUNCTION /1BEA/CRMB_DL_OFI_O_IC_CHECK.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
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
  CONSTANTS:
    LC_01          TYPE BEA_IC_LEVEL VALUE '01'.
  DATA:
    LV_BILL_ORG_D  TYPE BEA_BILL_ORG,
    LV_COMPANY_S   TYPE OFIT_BUKRS,
    LV_COMPANY_D   TYPE OFIT_BUKRS.
*--------------------------------------------------------------------*
*  BEGIN INITIALIZATION
*--------------------------------------------------------------------*
  ES_DLI = IS_DLI.
  ES_DLI-INDICATOR_IC = GC_FALSE.
*--------------------------------------------------------------------*
*  END INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*  BEGIN SERVICE CALL
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
        ES_DLI-INDICATOR_IC = GC_TRUE.
      ELSE.
*       Application log for derivation requested?
        IF GV_DRV_LOG = GC_TRUE.
          MESSAGE W150(BEA) INTO GV_DUMMY.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = ES_DLI
              IT_RETURN      = ET_RETURN
            IMPORTING
              ET_RETURN      = ET_RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
*   Application log for derivation requested?
    IF GV_DRV_LOG = GC_TRUE AND ES_DLI-INDICATOR_IC = GC_FALSE.
      MESSAGE W152(BEA) INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = ES_DLI
          IT_RETURN      = ET_RETURN
        IMPORTING
          ET_RETURN      = ET_RETURN.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
* END SERVICE CALL
*--------------------------------------------------------------------*
ENDFUNCTION.
*--------------------------------------------------------------------*
*       Form BILL_ORG_FILL
*--------------------------------------------------------------------*
* Logic:
*      Determine the Billing Organization for the Vendor
*          (Logic exists solely for comptability reasons from
*           earlier releases)
*      If no assigned Billing org. found for the Vendor
*        Determine Billing Organization for the TPOP Plant
*--------------------------------------------------------------------*
FORM BILL_ORG_FILL
  USING
    US_DLI         TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CV_BILL_ORG    TYPE BEA_BILL_ORG
    CT_RETURN      TYPE BEAT_RETURN.

  DATA:
    LS_OFI_COM     TYPE OFIC_BILLORG_SRV,
    LV_VENDOR_ID   TYPE BU_PARTNER,
    LS_KEYS        TYPE CRMT_OFI_FIELD_VALUE,
    LT_KEYS        TYPE CRMT_OFI_FIELD_VALUE_T,
    LS_RESULT      TYPE CRMT_OFI_FIELD_VALUE,
    LT_RESULT      TYPE CRMT_OFI_FIELD_VALUE_T,
    LV_SCENARIO    TYPE CRMT_OFI_BS_IDENTIFICATION.
  CONSTANTS:
    LC_SALES      TYPE CRMT_OFI_BS_IDENTIFICATION VALUE 'CRM_SALES'.

  IF NOT US_DLI-VENDOR IS INITIAL.
    CLEAR: LT_KEYS,
           LT_RESULT.
    call function 'COM_PARTNER_CONVERT_GUID_TO_NO'
      exporting
         iv_partner_guid    = US_DLI-VENDOR
      importing
         ev_partner         = lv_vendor_id
      exceptions
         partner_does_not_exist       = 1
         others                       = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING CT_RETURN.
      RETURN.
    endif.
    LV_SCENARIO   = LC_SALES.
    LS_KEYS-FIELD = GC_OFI_FIELDNAMES-VENDOR.
    LS_KEYS-VALUE = LV_VENDOR_ID.
    APPEND LS_KEYS TO LT_KEYS.
*   fill result
    LS_RESULT = GC_OFI_FIELDNAMES-BILLING_ORG_DELIVERY.
    APPEND LS_RESULT TO LT_RESULT.
*   call orgfinder
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
        CV_BILL_ORG = LS_RESULT-VALUE.
      ENDIF.
    ELSE.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.                    " BILL_ORG_FILL
