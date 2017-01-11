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
*      Form  DIR_BILLING_CHECK
*--------------------------------------------------------------------*
FORM DRBODL_CHZ_DIR_BILLING_CHECK
  CHANGING
    CS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
    CT_RETURN       TYPE BEAT_RETURN
    CV_RETURNCODE   TYPE SY-SUBRC.

  CONSTANTS:
    LC_BILLDIRECT_INT TYPE BEA_DIRECT_BILLING  VALUE 'A'.
  DATA:
    LS_BUPA_FRG0030   TYPE CRMT_BUS_SET0030,
    LS_REF_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_RETURNCODE     TYPE SY-SUBRC.

  CHECK CS_DLI_WRK-DIRECT_BILLING IS INITIAL.

* Direct Billing Flag in Partner set?

  PERFORM CPAODL_GET_PARTNER_GET
    USING
      CS_DLI_WRK
    CHANGING
      LS_BUPA_FRG0030
      LV_RETURNCODE.
  IF LS_BUPA_FRG0030-DIRECT_INVOICE = GC_TRUE.
    CS_DLI_WRK-DIRECT_BILLING = LC_BILLDIRECT_INT.
  ENDIF.

* For dependent billing (= delivery) check order if no direct result
* by partner was found (= no extra payer in R/3 partner procedure)

  CHECK CS_DLI_WRK-PAYER IS INITIAL.

  IF ( CS_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIVERY OR
       CS_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
       CS_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP ) AND
       CS_DLI_WRK-BILL_STATUS  EQ GC_BILLSTAT_TODO.
    PERFORM GET_REF_DLI
      USING
        CS_DLI_WRK
      CHANGING
        LS_REF_DLI_WRK
        CT_RETURN
        LV_RETURNCODE.
    IF LV_RETURNCODE IS INITIAL AND
       LS_REF_DLI_WRK-DIRECT_BILLING EQ LC_BILLDIRECT_INT.
      CS_DLI_WRK-DIRECT_BILLING = LC_BILLDIRECT_INT.
    ENDIF.
  ENDIF.

ENDFORM.                    " DIR_BILLING_CHECK
