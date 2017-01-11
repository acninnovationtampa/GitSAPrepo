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
* Include           BETX_ICBODL_DRZ                                  *
*--------------------------------------------------------------------*
*-----------------------------------------------------------------*
*       FORM DERIVE_INTERCOMPANY
*-----------------------------------------------------------------*
* Derive duelist item from the data sent by the source application
*-----------------------------------------------------------------*
FORM ICBODL_DRZ_DERIVE_INTERCOMPANY
  USING
    US_DLI_INT      TYPE /1BEA/S_CRMB_DLI_INT
    US_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK
    UT_CONDITION       TYPE BEAT_PRC_COM
    UT_PARTNER       TYPE BEAT_PAR_COM
    UT_TEXTLINE       TYPE COMT_TEXT_TEXTDATA_T
  CHANGING
    CT_DLI_WRK      TYPE /1BEA/T_CRMB_DLI_WRK
    CT_RETURN       TYPE BEAT_RETURN.

  DATA:
    LT_RETURN        TYPE BEAT_RETURN,
    LV_EQUAL         TYPE BEA_BOOLEAN,
    LV_STOP          TYPE BEA_BOOLEAN,
    LV_LEVEL         TYPE BEA_IC_LEVEL,
    LV_BILL_ORG      TYPE BEA_BILL_ORG,
    LS_DLI_PV        TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_REF_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK       TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_COM       TYPE /1BEA/S_CRMB_DLI_COM,
    LS_DLI_INT       TYPE /1BEA/S_CRMB_DLI_INT,
    LS_SALES_AREA_IB TYPE ofit_sales_area_ib,
    LT_CONDITION      TYPE BEAT_PRC_COM,
    LT_PARTNER      TYPE BEAT_PAR_COM,
    LT_TEXTLINE      TYPE COMT_TEXT_TEXTDATA_T,
    LS_ITC         TYPE BEAS_ITC_WRK,
    LV_RETURNCODE  TYPE SYSUBRC.

* Predecessor verion (PV) contains the version of the previous
* step or the version of the original entry for the first step
  LS_DLI_PV = US_DLI_WRK.
  LV_STOP = GC_FALSE.

*     take over public data in order to GET billed and open data
      MOVE-CORRESPONDING US_DLI_INT TO LS_DLI_COM.
      MOVE-CORRESPONDING LS_DLI_COM TO LS_DLI_INT.
      LS_DLI_INT-DERIV_CATEGORY = GC_DERIV_ORGDATA.
    IF US_DLI_WRK-INCOMP_ID <> GC_INCOMP_ENQ.
      PERFORM GET
        CHANGING
          LS_DLI_INT
          LT_DLI_WRK
          LT_RETURN.
    ENDIF.
*--------------------------------------------------------------------*
* BEGIN OF ACTUAL DERIVATION LOGIC
*--------------------------------------------------------------------*
*   intercompany process active and complete intercompany item given?
    IF ( US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_ORDER_IC OR
         US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
         US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP ) AND
         US_DLI_WRK-INDICATOR_IC   = GC_DERIV_IC_YES        AND
         US_DLI_WRK-BILL_STATUS    = GC_BILLSTAT_TODO       AND
         ( LS_DLI_PV-INCOMP_ID     = GC_INCOMP_OK OR
           LS_DLI_PV-INCOMP_ID     = GC_INCOMP_ENQ ).
      PERFORM ITC_DERIVE
        USING
          US_DLI_WRK
          '1SAP_ITC_IC'
          'ITEM_CATEGORY_IC'
        CHANGING
          LS_ITC
          LT_RETURN
          LV_RETURNCODE.
      PERFORM ICBODL_BOZ_BILL_ORG_DERIVE
        USING
          US_DLI_WRK
          LS_ITC
        CHANGING
          LV_BILL_ORG
          LT_RETURN
          LV_RETURNCODE.
*       Determin SalesOrg from customizing OFIC_CMPCD_IB
        PERFORM ICBODL_BOZ_SALES_AREA_DERIVE
          USING
            LV_BILL_ORG
          CHANGING
            LS_SALES_AREA_IB
            LV_RETURNCODE.
        IF LS_SALES_AREA_IB IS NOT INITIAL AND LV_RETURNCODE = 0.
          LS_DLI_INT-SALES_ORG   = LS_SALES_AREA_IB-sales_org_ib.
          LS_DLI_INT-DIS_CHANNEL = LS_SALES_AREA_IB-dis_channel_ib.
          LS_DLI_INT-DIVISION    = LS_SALES_AREA_IB-division_ib.

*         Determine reference currency from sales organization
          PERFORM ICBODL_DETERMINE_REF_CURRENCY
            USING
              LS_DLI_INT-SALES_ORG
            CHANGING
              LS_DLI_INT-REF_CURRENCY.
        ENDIF.

*       set protected attributes
        LS_DLI_INT-INCOMP_ID        = LS_DLI_PV-INCOMP_ID.
        LS_DLI_INT-ITEM_CATEGORY    = LS_ITC-ITEM_CATEGORY.
        LS_DLI_INT-BILL_CATEGORY    = GC_BILL_CAT_INT.
        LS_DLI_INT-DERIV_CATEGORY   = GC_DERIV_ORGDATA.
        LS_DLI_INT-BILL_RELEVANCE_C = US_DLI_WRK-BILL_RELEVANCE.
        LS_DLI_INT-CREDIT_DEBIT_C   = US_DLI_WRK-CREDIT_DEBIT.
        LS_DLI_INT-INDICATOR_IC_C   = GC_TRUE.
        MOVE LV_BILL_ORG TO LS_DLI_INT-BILL_ORG_C.
        LT_CONDITION = UT_CONDITION.
        LT_PARTNER = UT_PARTNER.
        LT_TEXTLINE = UT_TEXTLINE.
*       Determine Partner
        CLEAR:
          LS_DLI_INT-SOLD_TO_PARTY,
          LS_DLI_INT-PAYER_C,
          LT_PARTNER.
        PERFORM PARODL_DTZ_PARTNER_DETERMINE
          USING
            LS_DLI_PV
            LS_ITC
          CHANGING
            LT_PARTNER
            LT_RETURN
            LV_RETURNCODE.
        IF US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
           US_DLI_WRK-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP.
          PERFORM GET_REF_DLI
            USING
              US_DLI_WRK
            CHANGING
              LS_REF_DLI_WRK
              LT_RETURN
              LV_RETURNCODE.
          PERFORM DRVODL_PIP_PREP_INT_FORM_PRE
            USING
              LS_REF_DLI_WRK
            CHANGING
              LS_DLI_INT.
          PERFORM PRCODL_MRG_CONDITION_MERGE
            USING
              LS_REF_DLI_WRK
            CHANGING
              LT_CONDITION.
        ENDIF.
    ELSE.
      CLEAR:
        LS_DLI_INT,
        LS_DLI_PV.
    ENDIF.
*--------------------------------------------------------------------*
* BEGIN OF REJECT HANDLING FOR DERIVATION
*--------------------------------------------------------------------*
    LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
                   WHERE BILL_STATUS = GC_BILLSTAT_DONE.
      IF LS_DLI_INT-INDICATOR_IC_C = GC_TRUE.
*       incomplete due to missing cancelation?
        LV_EQUAL = GC_TRUE.
        PERFORM ICBODL_BOZ_ORG_DATA_COMPARE
          USING
            LS_DLI_WRK
            LV_BILL_ORG
          CHANGING
            LV_EQUAL
            LT_RETURN
            LV_RETURNCODE.
        IF LV_EQUAL = GC_FALSE.
          LS_DLI_WRK-INCOMP_ID = GC_INCOMP_CANCEL.
          LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
          MODIFY LT_DLI_WRK FROM LS_DLI_WRK.
        ENDIF.
      ELSE.
*       incomplete due to missing IC-Billing --> request rejection
        LS_DLI_WRK-INCOMP_ID = GC_INCOMP_REJECT.
        MESSAGE E262(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                          INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
          EXPORTING
            IV_CONTAINER   = 'DLI'
            IS_DLI_WRK     = LS_DLI_WRK
            IT_RETURN      = LT_RETURN
          IMPORTING
            ET_RETURN      = LT_RETURN.
        LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
        CALL FUNCTION '/1BEA/CRMB_DL_O_ADD_TO_BUFFER'
          EXPORTING
           IS_DLI_WRK = LS_DLI_WRK.
        DELETE LT_DLI_WRK.
      ENDIF.
    ENDLOOP.
*--------------------------------------------------------------------*
* END OF REJECT HANDLING FOR DERIVATION
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* BEGIN OF CREATE AND UPDATE HANDLING FOR DERIVATION
*--------------------------------------------------------------------*
    CALL FUNCTION '/1BEA/CRMB_DL_O_CREATE'
      EXPORTING
        IS_DLI_INT      = LS_DLI_INT
        IT_DLI_WRK      = LT_DLI_WRK
        IT_CONDITION       = LT_CONDITION
        IT_PARTNER       = LT_PARTNER
        IT_TEXTLINE       = LT_TEXTLINE
      IMPORTING
        ES_DLI_WRK      = LS_DLI_PV
        ET_RETURN       = CT_RETURN.
*--------------------------------------------------------------------*
* END OF CREATE AND UPDATE HANDLING FOR DERIVATION
*--------------------------------------------------------------------*
*   collect valid billed entries for rejection process
    INSERT LINES OF LT_DLI_WRK INTO TABLE CT_DLI_WRK.
* final handling of error messages
  PERFORM AL_CREATE
    CHANGING
      LS_DLI_PV
      LT_RETURN.
  INSERT LINES OF LT_RETURN INTO TABLE CT_RETURN.
ENDFORM.                    "ICBODL_DRZ_DERIVE_INTERCOMPANY


FORM ICBODL_DETERMINE_REF_CURRENCY
     USING    UV_SALES_ORG    TYPE CRMT_SALES_ORG
     CHANGING CV_REF_CURRENCY TYPE CRMT_REF_CURRENCY.

  types:
*       Buffered table for sales org
        BEGIN OF crmt_buffer_1,
          sales_org    TYPE crmt_sales_org,
          ref_currency TYPE crmt_ref_currency,
        END OF crmt_buffer_1,
        crmt_buffer_1_tab TYPE SORTED TABLE OF crmt_buffer_1
          WITH UNIQUE KEY sales_org.

  data:  lt_hrtb_attrib  type hrtb_attrib,
         lv_om_attrib    type om_attrib,
         lt_attributes   type hrtb_attvalrt,
         ls_attributes   type omattvalrt,
 	       ls_buffer       type crmt_buffer_1.
  constants:
 	       lc_currency     type om_attrib  value 'CURRENCY',
 	       lc_orgman_sales type om_attrscn value 'SALE'.

  statics:
 	       st_buffer 	     type crmt_buffer_1_tab.

  check: not uv_sales_org is initial.

  read table st_buffer into ls_buffer
    with table key sales_org = uv_sales_org.

  if sy-subrc ne 0.
    lv_om_attrib = lc_currency.
    insert lv_om_attrib into table lt_hrtb_attrib.

    call method cl_crm_orgman_interface=>read_attributes_single
      exporting
        scenario          = lc_orgman_sales
        otype             = uv_sales_org(2)
        objid             = uv_sales_org+2(12)
        attributes        = lt_hrtb_attrib
      importing
        values            = lt_attributes
      exceptions
        internal_error    = 1
        invalid_object    = 2
        invalid_scenario  = 3
        invalid_attribute = 4
        no_authority      = 5
        others            = 6.

    if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.

*   Read the reference currency of the own organization
    read table lt_attributes with key attrib = 'CURRENCY'
              into ls_attributes.
    ls_buffer-sales_org    = uv_sales_org.
    ls_buffer-ref_currency = ls_attributes-low.
    insert ls_buffer into table st_buffer.
  endif.

  IF NOT ls_buffer-ref_currency IS INITIAL.
    cv_ref_currency = ls_buffer-ref_currency.
  ENDIF.

ENDFORM.                      " ICBODL_DETERMINE_REF_CURRENCY
