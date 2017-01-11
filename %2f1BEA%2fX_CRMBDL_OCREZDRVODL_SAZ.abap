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
*       FORM DRVODL_CS_CREATE_STATUS_1O
*-----------------------------------------------------------------*
* Derive duelist item from the data sent by the source application
*-----------------------------------------------------------------*
FORM DRVODL_SAVE_STATUS_1O.

  CONSTANTS:
    LC_QNAME_PREFIX    TYPE TRFCQNAM VALUE 'BEADLS1OIBSB'.
  DATA:
    LV_RETURNCODE      TYPE SY-SUBRC,
    LV_NOSEND          TYPE CHAR1,
    LV_QNAME           TYPE TRFCQNAM,
    LS_STATUS_1O       TYPE CRMT_ORDER_QTY_TO_BILL,
    LT_STATUS_1O_SYNC  TYPE CRMT_ORDER_QTY_TO_BILL_T,
    LT_STATUS_1O_ASYNC TYPE CRMT_ORDER_QTY_TO_BILL_T,
    LS_UPD_STATUS_1O   TYPE GSY_UPD_STATUS_1O.

  LOOP AT GT_UPD_STATUS_1O INTO LS_UPD_STATUS_1O
       WHERE QUANTITY <> 0.
    MOVE-CORRESPONDING LS_UPD_STATUS_1O TO LS_STATUS_1O.
    CASE LS_UPD_STATUS_1O-BILL_RELEVANCE.
      WHEN GC_BILL_REL_ORDER    OR GC_BILL_REL_ORDER_IC.
        INSERT LS_STATUS_1O INTO TABLE LT_STATUS_1O_SYNC.
      WHEN GC_BILL_REL_DELIVERY OR GC_BILL_REL_DELIV_IC
                                OR GC_BILL_REL_DLV_TPOP.
        IF LV_QNAME IS INITIAL.
          CONCATENATE LC_QNAME_PREFIX LS_UPD_STATUS_1O-SRC_HEADNO INTO LV_QNAME.
        ENDIF.
        INSERT LS_STATUS_1O INTO TABLE LT_STATUS_1O_ASYNC.
    ENDCASE.
  ENDLOOP.

  IF NOT LT_STATUS_1O_SYNC IS INITIAL.
    CALL FUNCTION 'CRM_ORDER_BEA_DL_UPDA_CUMUL_I'
      EXPORTING
        IT_QTY_TO_BILL       = LT_STATUS_1O_SYNC
      EXCEPTIONS
        FAILED               = 0
        OTHERS               = 0.
  ENDIF.
  IF NOT LT_STATUS_1O_ASYNC IS INITIAL.
*   Set qname for qRFC
    CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
      EXPORTING
        QNAME              = LV_QNAME
        NOSEND             = LV_NOSEND
      EXCEPTIONS
        INVALID_QUEUE_NAME = 0
        OTHERS             = 0.
    CALL FUNCTION 'CRM_ORDER_BEA_DL_UPDA_CUMUL_I'
      IN BACKGROUND TASK
      EXPORTING
        IT_QTY_TO_BILL       = LT_STATUS_1O_ASYNC
      EXCEPTIONS
        FAILED               = 0
        OTHERS               = 0.
  ENDIF.

ENDFORM.                    "DRVODL_CS_CREATE_STATUS_1O
