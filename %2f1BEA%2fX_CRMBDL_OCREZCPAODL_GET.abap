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
*      Form  PARTNER_GET:
*
*      Read Billing Set of Payer
*--------------------------------------------------------------------*
FORM CPAODL_GET_PARTNER_GET
  USING
    US_DLI_WRK        TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_BUPA_FRG0030   TYPE CRMT_BUS_SET0030
    CV_RETURNCODE     TYPE SY-SUBRC.

  CONSTANTS:
    LC_BUS_SALES_COM   TYPE STRUKNAME VALUE 'CRMT_BUS_SALES_COM'.
  DATA:
    LV_PARTNER_GUID    TYPE BU_PARTNER_GUID,
    LS_SALES_AREA      TYPE CRMT_BUS_SALES_AREA.

  IF US_DLI_WRK-PAYER_GUID IS INITIAL.
    CALL FUNCTION 'COM_PARTNER_CONVERT_GUID_TO_NO'
      EXPORTING
        IV_PARTNER                   = US_DLI_WRK-PAYER
      IMPORTING
        EV_PARTNER_GUID              = LV_PARTNER_GUID
      EXCEPTIONS
        PARTNER_DOES_NOT_EXIST       = 1
        OTHERS                       = 2.
    IF NOT SY-SUBRC IS INITIAL.
      CV_RETURNCODE = 4.
    ENDIF.
  ELSE.
    LV_PARTNER_GUID = US_DLI_WRK-PAYER_GUID.
  ENDIF.

  IF NOT LV_PARTNER_GUID IS INITIAL.
   LS_SALES_AREA-SALES_ORG = US_DLI_WRK-SALES_ORG.
   LS_SALES_AREA-CHANNEL = US_DLI_WRK-DIS_CHANNEL.
   LS_SALES_AREA-DIVISION = US_DLI_WRK-DIVISION.
    CALL FUNCTION 'CRM_BUPA_FRG0030_READ'
      EXPORTING
        iv_partner_guid        = LV_PARTNER_GUID
        iv_com_structure_name  = LC_BUS_SALES_COM
        is_com_structure       = LS_SALES_AREA
      IMPORTING
        ES_DATA                = CS_BUPA_FRG0030
      EXCEPTIONS
        NO_VALID_RECORD_FOUND         = 1
        KEY_STRUCTURE_NOT_SUPPORTED   = 2
      OTHERS                        = 3.
    IF SY-SUBRC <> 0.
      CV_RETURNCODE = 4.
    ENDIF.
  ENDIF.

ENDFORM.                    " CPAODL_GET_PARTNER_GET
