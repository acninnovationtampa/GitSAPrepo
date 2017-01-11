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
FORM PARODL_DLZ_PARTNER_DELETE
  USING
    US_ITC       TYPE BEAS_ITC_WRK
  CHANGING
    CS_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK.

  STATICS:
    SS_DLI_HID TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID,
    ST_DLI_DOC TYPE /1BEA/T_CRMB_DLI_WRK.
  DATA:
    LS_DLI_HID TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID,
    LS_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK.

  IF CS_DLI_WRK-DERIV_CATEGORY <> GC_DERIV_LEANBILLING AND
     CS_DLI_WRK-DERIV_CATEGORY <> GC_DERIV_CONDITION.
    MOVE-CORRESPONDING CS_DLI_WRK TO LS_DLI_HID.
    IF LS_DLI_HID <> SS_DLI_HID.
      SS_DLI_HID = LS_DLI_HID.
      ST_DLI_DOC = GT_DLI_DOC.
    ENDIF.
    IF NOT ST_DLI_DOC IS INITIAL.
      LS_DLI_WRK = CS_DLI_WRK.
      CLEAR LS_DLI_WRK-PARSET_GUID.
      MODIFY ST_DLI_DOC FROM LS_DLI_WRK
             TRANSPORTING PARSET_GUID
             WHERE DLI_GUID = CS_DLI_WRK-DLI_GUID.
      READ TABLE ST_DLI_DOC WITH KEY
           PARSET_GUID = CS_DLI_WRK-PARSET_GUID
           TRANSPORTING NO FIELDS.
      IF SY-SUBRC <> 0.
        CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DELETE'
          EXPORTING
            IS_DLI = CS_DLI_WRK
            IS_ITC = US_ITC.                "#EC ENHOK
      ENDIF.
      CLEAR CS_DLI_WRK-PARSET_GUID.
    ENDIF.
  ENDIF.
ENDFORM.
