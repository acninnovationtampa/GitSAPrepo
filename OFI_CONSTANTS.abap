*&---------------------------------------------------------------------*
*&  Include           OFI_CONSTANTS                                    *
*&---------------------------------------------------------------------*

CONSTANTS:

* fieldnames for communication with orgfinder (not all are used)
  BEGIN OF GC_OFI_FIELDNAMES,
    SALES_ORG               TYPE CRMT_OFI_FIELDNAME
                            VALUE 'SALES_ORG',
    SERVICE_ORG             TYPE CRMT_OFI_FIELDNAME
                            VALUE 'SERVICE_ORG',
    SERVICE_TGRP            TYPE CRMT_OFI_FIELDNAME
                            VALUE 'SERVICE_TGRP',
    SERVICE_ORG_RESP        TYPE CRMT_OFI_FIELDNAME
                            VALUE 'SERVICE_ORG_RESP',
    SERVICE_TECH            TYPE CRMT_OFI_FIELDNAME
                            VALUE 'SERVICE_TECH',
    DISTRIBUTION_CHANNEL    TYPE CRMT_OFI_FIELDNAME
                            VALUE 'DIS_CHANNEL',
    DIVISION                TYPE CRMT_OFI_FIELDNAME
                            VALUE 'DIVISION',
    PROD_HIERARCHY          TYPE CRMT_OFI_FIELDNAME
                            VALUE 'PROD_HIER',
    COMPANY_CODE            TYPE CRMT_OFI_FIELDNAME
                            VALUE 'COMP_CODE',
    BUSINESS_AREA           TYPE CRMT_OFI_FIELDNAME
                            VALUE 'BUS_AREA',
    DUNNING_AREA            TYPE CRMT_OFI_FIELDNAME
                            VALUE 'DUNN_AREA',
    PROFIT_CENTER           TYPE CRMT_OFI_FIELDNAME
                            VALUE 'PROFIT_CTR',
    BILLING_ORG             TYPE CRMT_OFI_FIELDNAME
                            VALUE 'BILL_ORG',

*BILLING_ORG_DELIVERY is special for OFI_READ_BILLORG_DELIVERY_SLS
    BILLING_ORG_DELIVERY    TYPE CRMT_OFI_FIELDNAME
                            VALUE 'BILL_ORG_DELIVERY',
    BUSINESSPLACE           TYPE CRMT_OFI_FIELDNAME
                            VALUE 'BUSINESSPLACE',
    CREDIT_CONTROL_AREA     TYPE CRMT_OFI_FIELDNAME
                            VALUE 'C_CTR_AREA',
    VENDOR                  TYPE CRMT_OFI_FIELDNAME
                            VALUE 'VENDOR',
    PLANT                   TYPE CRMT_OFI_FIELDNAME
                            VALUE 'PLANT',
    STORAGE_LOC             TYPE CRMT_OFI_FIELDNAME
                            VALUE 'STORAGE_LOC',
    COST_CENTER             TYPE CRMT_OFI_FIELDNAME
                            VALUE 'COST_CTR',
  END OF GC_OFI_FIELDNAMES,

* scenarios for identification of business process kind
  BEGIN OF GC_OFI_SCENARIOS,
    SALES                   TYPE CRMT_OFI_BS_IDENTIFICATION
                            VALUE 'CRM_SALES',
    SERVICE                 TYPE CRMT_OFI_BS_IDENTIFICATION
                            VALUE 'CRMSRV',
    FINANCING               TYPE CRMT_OFI_BS_IDENTIFICATION
                            VALUE 'CRMFIN',
    GRANTOR                 TYPE CRMT_OFI_BS_IDENTIFICATION
                            VALUE 'GRANTOR',
    FUNDS                   TYPE CRMT_OFI_BS_IDENTIFICATION
                            VALUE 'CRMFM',
  END OF GC_OFI_SCENARIOS,

* others
  gc_ofi_true               value 'X',
  gc_ofi_false              value ' '.
