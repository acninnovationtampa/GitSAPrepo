***INCLUDE CRM_BILLING_CON .

CONSTANTS: BEGIN OF gc_billing_relevance,
             not_billing_rel    TYPE crmt_billing_relevant VALUE ' ',
             external           TYPE crmt_billing_relevant VALUE 'A',
             contract           TYPE crmt_billing_relevant VALUE 'B',
             delivered_qty      TYPE crmt_billing_relevant VALUE 'C',
             confirmation       TYPE crmt_billing_relevant VALUE 'D',
             order              TYPE crmt_billing_relevant VALUE 'E',
             delivery           TYPE crmt_billing_relevant VALUE 'F',
             deliv_no_zero_qty  TYPE crmt_billing_relevant VALUE 'G',
             value_based        TYPE crmt_billing_relevant VALUE 'I',
             ubb_pre_bill       TYPE crmt_billing_relevant VALUE 'V',
             ubb_pre_bill_pool  TYPE crmt_billing_relevant VALUE 'W',
             billing_rel(9)     TYPE c                VALUE 'BCDEFGIVW',
             billing_after_shipping(4) TYPE c         VALUE 'ACFG',
*            'A' is an assumption for sales orders
             order_related(6)    TYPE c                VALUE 'BDEIVW',
             delivery_related(3) TYPE c                VALUE 'CFG',
           END OF gc_billing_relevance.


CONSTANTS:
  BEGIN OF gc_billing_date_kind,
        period_date TYPE timenaeven VALUE 'PERIOD_DATE',
        settl_from  TYPE timenaeven VALUE 'SETTL_FROM',
        settl_to    TYPE timenaeven VALUE 'SETTL_TO',
        bill_date   TYPE timenaeven VALUE 'BILL_DATE',
        value_date  TYPE timenaeven VALUE 'VALUE_DATE',
        invcr_date  TYPE timenaeven VALUE 'INVCR_DATE',
  END OF gc_billing_date_kind.


CONSTANTS:
  BEGIN OF gc_billing_status,
        open                 TYPE crmt_distributed VALUE 'A',
        partial_billed       TYPE crmt_distributed VALUE 'B',
        complete_billed      TYPE crmt_distributed VALUE 'C',
        not_relevant         TYPE crmt_distributed VALUE 'D',
  END OF gc_billing_status.


CONSTANTS:
  BEGIN OF gc_billing_calctype,
        no_calctype          TYPE crmt_billing_calctype VALUE ' ',
        milestone            TYPE crmt_billing_calctype VALUE 'A',
  END OF gc_billing_calctype.

CONSTANTS:
  BEGIN OF gc_billing_external_scenario,
        no_scenario          TYPE crmt_external_bill_scenario VALUE ' ',
        fica_oneoff          TYPE crmt_external_bill_scenario VALUE 'A',
        fica_dsm_incentive   TYPE crmt_external_bill_scenario VALUE 'B',
  END OF gc_billing_external_scenario.

CONSTANTS:
    gc_billing_sepa_obj_type TYPE swo_objtyp VALUE 'BUS1006' .

CONSTANTS:
     BEGIN OF  gc_sepa_status,
       entered          TYPE sepa_status VALUE '0',
       active           TYPE sepa_status VALUE '1',
       tobeconfirmed    TYPE sepa_status VALUE '2',
       locked           TYPE sepa_status VALUE '3',
       canceled         TYPE sepa_status VALUE '4',
       obsolete         TYPE sepa_status VALUE '5',
       completed        TYPE sepa_status VALUE '6',
     END  OF gc_sepa_status .
