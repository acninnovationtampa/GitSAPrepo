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
*      Form  INTERCOMPANY_CHECK
*--------------------------------------------------------------------*
FORM ICBODL_CHZ_INTERCOMPANY_CHECK
  USING
    US_DLI          TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI          TYPE /1BEA/S_CRMB_DLI_WRK
    CT_RETURN       TYPE BEAT_RETURN
    CV_RETURNCODE   TYPE SY-SUBRC.
  DATA:
    LS_ITC    TYPE BEAS_ITC_WRK.

  IF US_DLI-DERIV_CATEGORY = GC_DERIV_ORIGIN AND
     US_DLI-BILL_RELEVANCE <> gc_bill_rel_value.
    BREAK-POINT ID BEA_DRV.
    IF GV_DRV_LOG = GC_TRUE.
*     Application log for derivation
      MESSAGE W181(BEA) INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = CS_DLI
          IT_RETURN      = CT_RETURN
        IMPORTING
          ET_RETURN      = CT_RETURN.
    ENDIF.
    IF US_DLI-INDICATOR_IC = gc_deriv_ic_no.
      IF US_DLI-BILL_RELEVANCE = gc_bill_rel_order_ic OR
         US_DLI-BILL_RELEVANCE = gc_bill_rel_deliv_ic OR
         US_DLI-BILL_RELEVANCE = gc_bill_rel_dlv_tpop.
        PERFORM ITC_DERIVE
          USING
            US_DLI
            '1SAP_ITC_IC'
            'ITEM_CATEGORY_IC'
          CHANGING
            LS_ITC
            CT_RETURN
            CV_RETURNCODE.
        IF NOT LS_ITC IS INITIAL.
          CALL FUNCTION '/1BEA/CRMB_DL_OFI_O_IC_CHECK'
            EXPORTING
              IS_DLI          = US_DLI
              IS_ITC          = LS_ITC
            IMPORTING
              ES_DLI          = CS_DLI
              ET_RETURN       = CT_RETURN
            EXCEPTIONS
              REJECT          = 1
              OTHERS          = 2.
          IF SY-SUBRC <> 0.
            CV_RETURNCODE = SY-SUBRC.
            RETURN.
          ENDIF.
        ENDIF.
      ELSE.
        IF GV_DRV_LOG = GC_TRUE.
          MESSAGE W146(BEA) WITH US_DLI-BILL_RELEVANCE INTO GV_DUMMY.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = US_DLI
              IT_RETURN      = CT_RETURN
            IMPORTING
              ET_RETURN      = CT_RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " INTERCOMPANY_CHECK
