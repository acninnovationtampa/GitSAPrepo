FUNCTION /1BEA/CRMB_DL_O_GETCOUNT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IRT_BDI_GUID) TYPE  BEART_BDI_GUID OPTIONAL
*"     REFERENCE(IRT_BILL_BLOCK) TYPE  BEART_BILL_BLOCK OPTIONAL
*"     REFERENCE(IRT_BILL_CATEGORY) TYPE  BEART_BILL_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_BILL_DATE) TYPE  BEART_BILL_DATE OPTIONAL
*"     REFERENCE(IRT_BILL_ORG) TYPE  BEART_BILL_ORG OPTIONAL
*"     REFERENCE(IRT_BILL_RELEVANCE) TYPE  BEART_BILL_RELEVANCE
*"         OPTIONAL
*"     REFERENCE(IRT_BILL_STATUS) TYPE  BEART_BILL_STATUS OPTIONAL
*"     REFERENCE(IRT_BILL_TYPE) TYPE  BEART_BILL_TYPE OPTIONAL
*"     REFERENCE(IRT_CREDIT_DEBIT) TYPE  BEART_CREDIT_DEBIT OPTIONAL
*"     REFERENCE(IRT_DERIV_CATEGORY) TYPE
*"                             /1BEA/RT_CRMB_DERIV_CATEGORY OPTIONAL
*"     REFERENCE(IRT_DLI_GUID) TYPE  BEART_DLI_GUID OPTIONAL
*"     REFERENCE(IRT_INCOMP_ID) TYPE  BEART_INCOMP_ID OPTIONAL
*"     REFERENCE(IRT_INVCR_DATE) TYPE  /1BEA/RT_CRMB_INVCR_DATE
*"         OPTIONAL
*"     REFERENCE(IRT_ITEM_CATEGORY) TYPE  BEART_ITEM_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_ITEM_TYPE) TYPE  BEART_ITEM_TYPE OPTIONAL
*"     REFERENCE(IRT_LOGSYS) TYPE  /1BEA/RT_CRMB_LOGSYS OPTIONAL
*"     REFERENCE(IRT_MAINT_DATE) TYPE  BEART_MAINT_DATE OPTIONAL
*"     REFERENCE(IRT_MAINT_TIME) TYPE  BEART_MAINT_TIME OPTIONAL
*"     REFERENCE(IRT_MAINT_USER) TYPE  BEART_MAINT_USER OPTIONAL
*"     REFERENCE(IRT_OBJTYPE) TYPE  /1BEA/RT_CRMB_OBJTYPE OPTIONAL
*"     REFERENCE(IRT_PAYER) TYPE  BEART_PAYER OPTIONAL
*"     REFERENCE(IRT_P_LOGSYS) TYPE  /1BEA/RT_CRMB_P_LOGSYS OPTIONAL
*"     REFERENCE(IRT_P_OBJTYPE) TYPE  /1BEA/RT_CRMB_P_OBJTYPE
*"         OPTIONAL
*"     REFERENCE(IRT_P_SRC_HEADNO) TYPE  /1BEA/RT_CRMB_P_SRC_HEADNO
*"         OPTIONAL
*"     REFERENCE(IRT_SOLD_TO_PARTY) TYPE  /1BEA/RT_CRMB_SOLD_TO_PARTY
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_DATE) TYPE  /1BEA/RT_CRMB_SRC_DATE OPTIONAL
*"     REFERENCE(IRT_SRC_GUID) TYPE  /1BEA/RT_CRMB_SRC_GUID OPTIONAL
*"     REFERENCE(IRT_SRC_HEADNO) TYPE  /1BEA/RT_CRMB_SRC_HEADNO
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_ITEMNO) TYPE  /1BEA/RT_CRMB_SRC_ITEMNO
*"         OPTIONAL
*"     REFERENCE(IRT_SRC_USER) TYPE  /1BEA/RT_CRMB_SRC_USER OPTIONAL
*"     REFERENCE(IRT_SRVDOC_SOURCE) TYPE  BEART_SRVDOC_SOURCE
*"         OPTIONAL
*"     REFERENCE(IRT_TERMS_OF_PAYMENT) TYPE  BEART_TERMS_OF_PAYMENT
*"         OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_NR_OF_ENTRIES) TYPE  BEA_NR_OF_ENTRIES
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
  SELECT COUNT( * ) FROM /1BEA/CRMB_DLI
           INTO EV_NR_OF_ENTRIES
           WHERE
               BDI_GUID IN IRT_BDI_GUID
              AND BILL_BLOCK IN IRT_BILL_BLOCK
              AND BILL_CATEGORY IN IRT_BILL_CATEGORY
              AND BILL_DATE IN IRT_BILL_DATE
              AND BILL_ORG IN IRT_BILL_ORG
              AND BILL_RELEVANCE IN IRT_BILL_RELEVANCE
              AND BILL_STATUS IN IRT_BILL_STATUS
              AND BILL_TYPE IN IRT_BILL_TYPE
              AND CREDIT_DEBIT IN IRT_CREDIT_DEBIT
              AND DERIV_CATEGORY IN IRT_DERIV_CATEGORY
              AND DLI_GUID IN IRT_DLI_GUID
              AND INCOMP_ID IN IRT_INCOMP_ID
              AND INVCR_DATE IN IRT_INVCR_DATE
              AND ITEM_CATEGORY IN IRT_ITEM_CATEGORY
              AND ITEM_TYPE IN IRT_ITEM_TYPE
              AND LOGSYS IN IRT_LOGSYS
              AND MAINT_DATE IN IRT_MAINT_DATE
              AND MAINT_TIME IN IRT_MAINT_TIME
              AND MAINT_USER IN IRT_MAINT_USER
              AND OBJTYPE IN IRT_OBJTYPE
              AND PAYER IN IRT_PAYER
              AND P_LOGSYS IN IRT_P_LOGSYS
              AND P_OBJTYPE IN IRT_P_OBJTYPE
              AND P_SRC_HEADNO IN IRT_P_SRC_HEADNO
              AND SOLD_TO_PARTY IN IRT_SOLD_TO_PARTY
              AND SRC_DATE IN IRT_SRC_DATE
              AND SRC_GUID IN IRT_SRC_GUID
              AND SRC_HEADNO IN IRT_SRC_HEADNO
              AND SRC_ITEMNO IN IRT_SRC_ITEMNO
              AND SRC_USER IN IRT_SRC_USER
              AND SRVDOC_SOURCE IN IRT_SRVDOC_SOURCE
              AND TERMS_OF_PAYMENT IN IRT_TERMS_OF_PAYMENT.
ENDFUNCTION.