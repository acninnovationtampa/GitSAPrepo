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
*       FORM DRVODL_CREATE_STATUS_1O
*-----------------------------------------------------------------*
* Derive duelist item from the data sent by the source application
*-----------------------------------------------------------------*
FORM DRVODL_CREATE_STATUS_1O
  USING
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_RETURN       TYPE BEAT_RETURN.

  DATA:
    LV_RETURNCODE    TYPE SY-SUBRC,
    LS_REF_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_UPD_STATUS_1O TYPE GSY_UPD_STATUS_1O.

  IF ( US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA OR
       US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_PARTNER ) AND
       US_DLI_WRK-INCOMP_ID      = GC_INCOMP_OK.
    LS_UPD_STATUS_1O-BILL_RELEVANCE = US_DLI_WRK-BILL_RELEVANCE.
    IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA.
      LS_UPD_STATUS_1O-INT_BILL_CAT = '1'.
    ELSEIF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_PARTNER.
      LS_UPD_STATUS_1O-INT_BILL_CAT = '2'.
    ENDIF.
    LS_UPD_STATUS_1O-ITEM_GUID      = US_DLI_WRK-SRC_GUID.
*   In the delivery related scenario retrieve the order item
    IF US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIVERY OR
       US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
       US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP.
      PERFORM GET_REF_DLI
        USING    US_DLI_WRK
        CHANGING LS_REF_DLI_WRK
                 CT_RETURN
                 LV_RETURNCODE.
      IF LV_RETURNCODE IS INITIAL.
        LS_UPD_STATUS_1O-SRC_HEADNO = LS_REF_DLI_WRK-SRC_HEADNO.
        LS_UPD_STATUS_1O-ITEM_GUID = LS_REF_DLI_WRK-SRC_GUID.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.
    LS_UPD_STATUS_1O-QUANTITY       = US_DLI_WRK-QUANTITY.
    IF US_DLI_WRK-UPD_TYPE = GC_DELETE.
      MULTIPLY LS_UPD_STATUS_1O-QUANTITY BY -1.
    ENDIF.
    LS_UPD_STATUS_1O-QTY_UNIT       = US_DLI_WRK-QTY_UNIT.
    COLLECT LS_UPD_STATUS_1O INTO GT_UPD_STATUS_1O.
  ENDIF.

ENDFORM.                    "DRVODL_CREATE_STATUS_1O
