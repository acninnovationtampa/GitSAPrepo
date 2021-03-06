FUNCTION /1BEA/CRMB_BD_O_BDHGETLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IRT_ARCHIVABLE) TYPE  BEART_ARCHIVABLE OPTIONAL
*"     REFERENCE(IRT_BDH_GUID) TYPE  BEART_BDH_GUID OPTIONAL
*"     REFERENCE(IRT_BILL_CATEGORY) TYPE  BEART_BILL_CATEGORY
*"         OPTIONAL
*"     REFERENCE(IRT_BILL_DATE) TYPE  BEART_BILL_DATE OPTIONAL
*"     REFERENCE(IRT_BILL_ORG) TYPE  BEART_BILL_ORG OPTIONAL
*"     REFERENCE(IRT_BILL_TYPE) TYPE  BEART_BILL_TYPE OPTIONAL
*"     REFERENCE(IRT_CANCEL_FLAG) TYPE  BEART_CANCEL_FLAG OPTIONAL
*"     REFERENCE(IRT_CRP_GUID) TYPE  BEART_CRP_GUID OPTIONAL
*"     REFERENCE(IRT_DOC_CURRENCY) TYPE  BEART_DOC_CURRENCY OPTIONAL
*"     REFERENCE(IRT_HEADNO_EXT) TYPE  BEART_HEADNO_EXT OPTIONAL
*"     REFERENCE(IRT_LOGSYS) TYPE  BEART_LOGSYS OPTIONAL
*"     REFERENCE(IRT_MAINT_DATE) TYPE  BEART_MAINT_DATE OPTIONAL
*"     REFERENCE(IRT_MAINT_TIME) TYPE  BEART_MAINT_TIME OPTIONAL
*"     REFERENCE(IRT_MAINT_USER) TYPE  BEART_MAINT_USER OPTIONAL
*"     REFERENCE(IRT_NET_VALUE) TYPE  BEART_NET_VALUE OPTIONAL
*"     REFERENCE(IRT_OBJTYPE) TYPE  BEART_OBJTYPE OPTIONAL
*"     REFERENCE(IRT_PAYER) TYPE  BEART_PAYER OPTIONAL
*"     REFERENCE(IRT_PRIC_PROC) TYPE  BEART_PRIC_PROC OPTIONAL
*"     REFERENCE(IRT_REFERENCE_NO) TYPE  BEART_REFERENCE_NO OPTIONAL
*"     REFERENCE(IRT_REF_CURRENCY) TYPE  BEART_REF_CURRENCY OPTIONAL
*"     REFERENCE(IRT_SPLIT_CRITERIA) TYPE  BEART_SPLIT_CRITERIA
*"         OPTIONAL
*"     REFERENCE(IRT_TAX_VALUE) TYPE  BEART_TAX_VALUE OPTIONAL
*"     REFERENCE(IRT_TERMS_OF_PAYMENT) TYPE  BEART_TERMS_OF_PAYMENT
*"         OPTIONAL
*"     REFERENCE(IRT_TRANSFER_DATE) TYPE  BEART_TRANSFER_DATE
*"         OPTIONAL
*"     REFERENCE(IRT_TRANSFER_ERROR) TYPE
*"                             /1BEA/RT_CRMB_TRANSFER_ERROR OPTIONAL
*"     REFERENCE(IRT_TRANSFER_STATUS) TYPE  BEART_TRANSFER_STATUS
*"         OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BAPIMAXROW
*"         DEFAULT                    0
*"  EXPORTING
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
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
* Time  : 13:52:50
*
*======================================================================
  CLEAR ET_BDH.

  SELECT * FROM /1BEA/CRMB_BDH
           INTO CORRESPONDING FIELDS OF TABLE ET_BDH
           UP TO IV_MAXROWS ROWS
         WHERE
                  ARCHIVABLE IN IRT_ARCHIVABLE
                 AND BDH_GUID IN IRT_BDH_GUID
                 AND BILL_CATEGORY IN IRT_BILL_CATEGORY
                 AND BILL_DATE IN IRT_BILL_DATE
                 AND BILL_ORG IN IRT_BILL_ORG
                 AND BILL_TYPE IN IRT_BILL_TYPE
                 AND CANCEL_FLAG IN IRT_CANCEL_FLAG
                 AND CRP_GUID IN IRT_CRP_GUID
                 AND DOC_CURRENCY IN IRT_DOC_CURRENCY
                 AND HEADNO_EXT IN IRT_HEADNO_EXT
                 AND LOGSYS IN IRT_LOGSYS
                 AND MAINT_DATE IN IRT_MAINT_DATE
                 AND MAINT_TIME IN IRT_MAINT_TIME
                 AND MAINT_USER IN IRT_MAINT_USER
                 AND NET_VALUE IN IRT_NET_VALUE
                 AND OBJTYPE IN IRT_OBJTYPE
                 AND PAYER IN IRT_PAYER
                 AND PRIC_PROC IN IRT_PRIC_PROC
                 AND REFERENCE_NO IN IRT_REFERENCE_NO
                 AND REF_CURRENCY IN IRT_REF_CURRENCY
                 AND SPLIT_CRITERIA IN IRT_SPLIT_CRITERIA
                 AND TAX_VALUE IN IRT_TAX_VALUE
                 AND TERMS_OF_PAYMENT IN IRT_TERMS_OF_PAYMENT
                 AND TRANSFER_DATE IN IRT_TRANSFER_DATE
                 AND TRANSFER_ERROR IN IRT_TRANSFER_ERROR
                 AND TRANSFER_STATUS IN IRT_TRANSFER_STATUS.

ENDFUNCTION.
