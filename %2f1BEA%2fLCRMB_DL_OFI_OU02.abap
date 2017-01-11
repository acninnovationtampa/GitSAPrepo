FUNCTION /1BEA/CRMB_DL_OFI_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IT_PAR_COM) TYPE  BEAT_PAR_COM
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
  DATA:
    LS_CND_COM   TYPE BEAS_CND_ACS_TOTL,
    LS_OFI_COM   TYPE OFIC_BILLORG_SRV,
    LS_KEYS      TYPE CRMT_OFI_FIELD_VALUE,
    LT_KEYS      TYPE CRMT_OFI_FIELD_VALUE_T,
    LS_RESULT    TYPE CRMT_OFI_FIELD_VALUE,
    LT_RESULT    TYPE CRMT_OFI_FIELD_VALUE_T,
    LV_SCENARIO  TYPE CRMT_OFI_BS_IDENTIFICATION.
  CONSTANTS:
    LC_BSC_SLS   TYPE BEA_BUSINESS_SCENARIO VALUE 'A',
    LC_BSC_SRV   TYPE BEA_BUSINESS_SCENARIO VALUE 'B',
    LC_BSC_FIN   TYPE BEA_BUSINESS_SCENARIO VALUE 'C',
    LC_BSC_GRM   TYPE BEA_BUSINESS_SCENARIO VALUE 'D',
    LC_SALES     TYPE CRMT_OFI_BS_IDENTIFICATION VALUE 'CRM_SALES',
    LC_SERVICE   TYPE CRMT_OFI_BS_IDENTIFICATION VALUE 'CRMSRV'.
*--------------------------------------------------------------------*
* BEGIN INITIALIZATION
*--------------------------------------------------------------------*
  ES_DLI = IS_DLI.
  CLEAR ES_DLI-BILL_ORG.
*--------------------------------------------------------------------*
* END INITIALIZATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* BEGIN PRESTEP
*--------------------------------------------------------------------*
  DATA:
    LV_PAR_GUID  TYPE BU_PARTNER_GUID,
    LS_PAR_COM TYPE BEAS_PAR_COM,
    LS_PAR_FCT TYPE COMT_PARTNER_FCT.
  CONSTANTS:
    LC_SUBTYPE TYPE COMT_PARTNER_SUBTYPE VALUE 'CRM'.
  STATICS:
    LT_PAR_FCT TYPE COMT_PARTNER_FCT_TAB.
  IF LT_PAR_FCT IS INITIAL.
    CALL FUNCTION 'COM_PARTNER_TYPE_TO_FUNCTION'
      EXPORTING
        IV_PARTNER_PFT      = GC_PARTNER_PFT-BILLING_UNIT
        IV_PARTNER_SUBTYPE  = LC_SUBTYPE
      IMPORTING
        ET_PARTNER_FCT      = LT_PAR_FCT.
  ENDIF.
  LOOP AT LT_PAR_FCT INTO LS_PAR_FCT.
    READ TABLE IT_PAR_COM INTO LS_PAR_COM
         WITH KEY PARTNER_FCT = LS_PAR_FCT
                  MAINPARTNER = GC_TRUE.
    IF SY-SUBRC = 0.
      CASE LS_PAR_COM-NO_TYPE.
        WHEN GC_PARTNER_NO_TYPE-BUSINESS_PARTNER_GUID.
          LV_PAR_GUID = LS_PAR_COM-PARTNER_NO.
          CALL FUNCTION 'COM_PARTNER_CONVERT_GUID_TO_NO'
            EXPORTING
              IV_PARTNER_GUID              = LV_PAR_GUID
            IMPORTING
              EV_PARTNER                   = ES_DLI-BILL_ORG
            EXCEPTIONS
              PARTNER_DOES_NOT_EXIST       = 1
              OTHERS                       = 2.
          IF SY-SUBRC = 0.
            EXIT.
          ENDIF.
        WHEN GC_PARTNER_NO_TYPE-BUSINESS_PARTNER_NO.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT         = LS_PAR_COM-PARTNER_NO
            IMPORTING
              OUTPUT        = ES_DLI-BILL_ORG.
          EXIT.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ENDLOOP.
*--------------------------------------------------------------------*
* END PRESTEP
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* BEGIN CALL ORGFINDER
*--------------------------------------------------------------------*
IF ES_DLI-BILL_ORG IS INITIAL.
  MOVE-CORRESPONDING IS_DLI TO LS_CND_COM.
  MOVE IS_DLI-BILL_DATE TO LS_CND_COM-ACCESS_DATE.
  MOVE IS_DLI-SALES_ORG TO LS_OFI_COM-SALES_ORG.
  MOVE IS_DLI-SERVICE_ORG TO LS_OFI_COM-SERVICE_ORG.
*   fill keys depending from business-scenario
  CASE IS_DLI-BUSINESSSCENARIO.
    WHEN LC_BSC_SLS OR LC_BSC_FIN.
      LV_SCENARIO   = LC_SALES.
      LS_KEYS-FIELD = GC_OFI_FIELDNAMES-SALES_ORG.
      LS_KEYS-VALUE = LS_OFI_COM-SALES_ORG.
      APPEND LS_KEYS TO LT_KEYS.
    WHEN LC_BSC_SRV OR LC_BSC_GRM.
      LV_SCENARIO   = LC_SERVICE.
      LS_KEYS-FIELD = GC_OFI_FIELDNAMES-SERVICE_ORG.
      LS_KEYS-VALUE = LS_OFI_COM-SERVICE_ORG.
      APPEND LS_KEYS TO LT_KEYS.
      LS_KEYS-FIELD = GC_OFI_FIELDNAMES-SALES_ORG.
      LS_KEYS-VALUE = LS_OFI_COM-SALES_ORG.
      APPEND LS_KEYS TO LT_KEYS.
    WHEN OTHERS.
      MESSAGE E109(BEA) WITH IS_DLI-BUSINESSSCENARIO
              RAISING REJECT.
  ENDCASE.
*   fill result
  LS_RESULT = GC_OFI_FIELDNAMES-BILLING_ORG.
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
        ES_DLI-BILL_ORG = LS_RESULT-VALUE.
      ENDIF.
    ELSE.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING ET_RETURN.
    ENDIF.
    IF ES_DLI-BILL_ORG IS INITIAL.
      MESSAGE E110(BEA) WITH IS_DLI-BUSINESSSCENARIO
              RAISING REJECT.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
* END CALL ORGFINDER
*--------------------------------------------------------------------*
ENDFUNCTION.
