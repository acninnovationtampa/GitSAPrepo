*----------------------------------------------------------------------*
*   INCLUDE CRM_OBJECT_TYPES_CON                                       *
*----------------------------------------------------------------------*
CONSTANTS:
  BEGIN OF gc_object_type,
*   // Root object for all transactions
    transaction                TYPE crmt_swo_objtyp_process VALUE 'BUS20001',
*   // Transactions
    ic_email                   TYPE crmt_swo_objtyp_process VALUE 'CRMICMAIL',
    ic_email_sofm              TYPE crmt_swo_objtyp_process VALUE 'SOFM',
    knowledge_article          TYPE crmt_swo_objtyp_process VALUE 'BUS2000106',
    activity                   TYPE crmt_swo_objtyp_process VALUE 'BUS2000110',
    outline_agr                TYPE crmt_swo_objtyp_process VALUE 'BUS2000107',
    task                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000125',
    businessactivity           TYPE crmt_swo_objtyp_process VALUE 'BUS2000126',
    opportunity                TYPE crmt_swo_objtyp_process VALUE 'BUS2000111',
    contract_service           TYPE crmt_swo_objtyp_process VALUE 'BUS2000112',
    contract_purchas           TYPE crmt_swo_objtyp_process VALUE 'BUS2000113',
    contract_sales             TYPE crmt_swo_objtyp_process VALUE 'BUS2000121',
    contract_finance           TYPE crmt_swo_objtyp_process VALUE 'BUS2000114',
    fs_main_contract           TYPE crmt_swo_objtyp_process VALUE 'BUS2000308',
    fs_object_contract         TYPE crmt_swo_objtyp_process VALUE 'BUS2000307',
    sales                      TYPE crmt_swo_objtyp_process VALUE 'BUS2000115',
    service                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000116',
    srv_confirm                TYPE crmt_swo_objtyp_process VALUE 'BUS2000117',
    purch_sched_agr            TYPE crmt_swo_objtyp_process VALUE 'BUS2000118',
    complaint                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000120',
    lean                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000249',
    lead                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000108',
    sur                        TYPE crmt_swo_objtyp_process VALUE 'BUS2000210',
    psl                        TYPE crmt_swo_objtyp_process VALUE 'BUS2000210',
    rebate_agr                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000215',
    incident                   TYPE crmt_swo_objtyp_process VALUE 'BUS2000223',
    incident_management        TYPE crmt_swo_objtyp_process VALUE 'BUS2000223',
    problem                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000224',
    problem_management         TYPE crmt_swo_objtyp_process VALUE 'BUS2000224',
    billreq                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000240',
    text                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000128',
    maintenance_plan           TYPE crmt_swo_objtyp_process VALUE 'BUS2000245',
    warranty_claim             TYPE crmt_swo_objtyp_process VALUE 'BUS2000255',
    claim_submission_document  TYPE crmt_swo_objtyp_process VALUE 'BUS2000310',
    claim_settlement_request   TYPE crmt_swo_objtyp_process VALUE 'BUS2000311',
    prepayment_request         TYPE crmt_swo_objtyp_process VALUE 'BUS2000312',
    budget_reservation         TYPE crmt_swo_objtyp_process VALUE 'BUS2000313',
    chargeback                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000320',
*   Grantor Management
    grantor_application        TYPE crmt_swo_objtyp_process VALUE 'BUS2000270',
    grantor_agreement          TYPE crmt_swo_objtyp_process VALUE 'BUS2000271',
    grantor_claim              TYPE crmt_swo_objtyp_process VALUE 'BUS2000272',
    grantor_program            TYPE crmt_swo_objtyp_process VALUE 'BUS2100010',
    grantor_earmarkfund        TYPE crmt_swo_objtyp_process VALUE 'FMRE',
*   Social Services
    social_application         TYPE crmt_swo_objtyp_process VALUE 'BUS2000280',
    social_serviceplan         TYPE crmt_swo_objtyp_process VALUE 'BUS2000281',
    deduction_plan             TYPE crmt_swo_objtyp_process VALUE 'BUS2000290',
*   Public Sector
    decision_basis             TYPE crmt_swo_objtyp_process VALUE 'BUS2000292',
*   Provider Order and Provider Contract
    provider_order             TYPE crmt_swo_objtyp_process VALUE 'BUS2000265',
    provider_contract          TYPE crmt_swo_objtyp_process VALUE 'BUS2000266',
*   Provider Master Agreement
    provider_master_agreement  TYPE crmt_swo_objtyp_process VALUE 'BUS2000267',
*   Funds Management
    fund_plan                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000400',
    fund_usage                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000425',
    fund_usage_item            TYPE crmt_swo_objtyp_process VALUE 'BUS2000426',
    fund                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000401',
    budget_posting             TYPE crmt_swo_objtyp_process VALUE 'BUS2000402',

*   CRM Case Management
    case_management            TYPE crmt_swo_objtyp_process VALUE 'BUS20900',

*   change in module status_data_provide too - the object type.
*   // External objects
    campaign                   TYPE crmt_swo_objtyp_process VALUE 'BUS2010020',
    campaign_element           TYPE crmt_swo_objtyp_process VALUE 'BUS2010022',
    trade_promo                TYPE crmt_swo_objtyp_process VALUE 'BUS2010030',
    trade_promo_elem           TYPE crmt_swo_objtyp_process VALUE 'BUS2010032',
    mdf_program                TYPE crmt_swo_objtyp_process VALUE 'BUS2010050',
    spec_program               TYPE crmt_swo_objtyp_process VALUE 'BUS2010060',
    initiative                 TYPE crmt_swo_objtyp_process VALUE 'BUS2010070',
    initiative_elem            TYPE crmt_swo_objtyp_process VALUE 'BUS2010072',
    agreement                  TYPE crmt_swo_objtyp_process VALUE 'BUS2010080',
    keytiming                  TYPE crmt_swo_objtyp_process VALUE 'BUS2010120',

    business_partner           TYPE crmt_swo_objtyp_process VALUE 'BUS1006',
    solution                   TYPE crmt_swo_objtyp_process VALUE 'BUS117501',
*   Billing Engine
    invoice                    TYPE crmt_swo_objtyp_process VALUE 'BUS20810',
*   Rebate Engine
    settledoc                  TYPE crmt_swo_objtyp_process VALUE 'BUS20830',
*   Telco
    ist_order_head             TYPE crmt_swo_objtyp_process VALUE 'BUS2000265',
    ist_contract_head          TYPE crmt_swo_objtyp_process VALUE 'BUS2000266',
*   ETC
    tc_contract                TYPE crmt_swo_objtyp_process VALUE 'BUS2000246',
*   Utilities
    util_pod                   TYPE crmt_swo_objtyp_process VALUE 'PREMISE1',
    util_order                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000247',
    util_package               TYPE crmt_swo_objtyp_process VALUE 'BUS2000248',
    util_contract              TYPE crmt_swo_objtyp_process VALUE 'BUS2000249',
    util_prod_det              TYPE crmt_swo_objtyp_process VALUE 'BUS2000348',
    util_checkr                TYPE crmt_swo_objtyp_process VALUE 'UTILCHECKR',
    util_checki                TYPE crmt_swo_objtyp_process VALUE 'UTILCHECKI',
*   UBB
    contract_pool              TYPE crmt_swo_objtyp_process VALUE 'BUS2000250',
*
    project                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000220',
*   Intellectual Property Mngmt.
    ipm_contract_s             TYPE crmt_swo_objtyp_process VALUE 'BUS2000230',
    ipm_contract_p             TYPE crmt_swo_objtyp_process VALUE 'BUS2000231',
    ipm_confirm                TYPE crmt_swo_objtyp_process VALUE 'BUS2000232',

*   Utilities DSM - Demand Side Management.
    dsm_application            TYPE crmt_swo_objtyp_process VALUE 'BUS2000410',
    dsm_agreement              TYPE crmt_swo_objtyp_process VALUE 'BUS2000411',
    dsm_program                TYPE crmt_swo_objtyp_process VALUE 'BUS2100400',

*   cProject
    cproject                   TYPE crmt_swo_objtyp_process VALUE 'BUS2172',
    cproject_phase             TYPE crmt_swo_objtyp_process VALUE 'BUS2173',
    iobject                    TYPE crmt_swo_objtyp_process VALUE 'BUS1278',
    targetgroup                TYPE crmt_swo_objtyp_process VALUE 'BUS1185',
    bus_agreement              TYPE crmt_swo_objtyp_process VALUE 'BUS1006130',
    interaction_object         TYPE crmt_swo_objtyp_process VALUE 'BUS20004',
    tour                       TYPE crmt_swo_objtyp_process VALUE 'BUS20510',
    po                         TYPE crmt_swo_objtyp_process VALUE 'BUS2201',
    po_item                    TYPE crmt_swo_objtyp_process VALUE 'BUS2201001',
    incom_inv                  TYPE crmt_swo_objtyp_process VALUE 'BUS2205',
    incom_inv_item             TYPE crmt_swo_objtyp_process VALUE 'BUS2205001',
    dispute_case               TYPE crmt_swo_objtyp_process VALUE 'BUS2022',
    account_plan               TYPE crmt_swo_objtyp_process VALUE 'BUS20110',
    external_incident          TYPE crmt_swo_objtyp_process VALUE 'EXTINCIDT',
    gift_certificate           TYPE crmt_swo_objtyp_process VALUE 'BUS200600',
*   Chargeback Recovery
    chargeback_recovery        TYPE crmt_swo_objtyp_process VALUE 'BUS2000330',
*   Loyalty Management
*   // Loyalty Root
    loyalty                    TYPE crmt_swo_objtyp_process VALUE 'BUS80001',
    loy_membership             TYPE crmt_swo_objtyp_process VALUE 'BUS8000102',
    loy_partnership            TYPE crmt_swo_objtyp_process VALUE 'BUS8000106',

    sd_rebate_agreement        TYPE crmt_swo_objtyp_process VALUE 'BUS3031',
    fi_accounting_document     TYPE crmt_swo_objtyp_process VALUE 'BKPF',
    fi_accounting_line_item    TYPE crmt_swo_objtyp_process VALUE 'BSEG',
    erp_quotation              TYPE crmt_swo_objtyp_process VALUE 'BUS2031',
    erp_order                  TYPE crmt_swo_objtyp_process VALUE 'BUS2032',
    erp_contract               TYPE crmt_swo_objtyp_process VALUE 'BUS2034',
    erp_delivery              TYPE crmt_swo_objtyp_process VALUE 'LIKP',
    erp_invoice               TYPE crmt_swo_objtyp_process VALUE 'VBRK',
    erp_cs_order              TYPE crmt_swo_objtyp_process VALUE 'BUS2088',
    scm_apo_vmi_sto            TYPE crmt_swo_objtyp_process VALUE 'BUS10502',
    pos_transaction            TYPE crmt_swo_objtyp_process VALUE 'POSTRN',
*   Composite transaction
    comp_transaction           TYPE crmt_swo_objtyp_process VALUE 'BUS2000100',
    hybris_mkt_campaign       TYPE crmt_swo_objtyp_process VALUE 'CUAN_INI',
    hybris_mkt_campaign_vers  TYPE crmt_swo_objtyp_process VALUE 'CUAN_INIV',
  END OF gc_object_type,

  BEGIN OF gc_object_type_item,
    text                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000128',
    opportunity                TYPE crmt_swo_objtyp_process VALUE 'BUS2000130',
    sales                      TYPE crmt_swo_objtyp_process VALUE 'BUS2000131',
    outl_agr_sales             TYPE crmt_swo_objtyp_process VALUE 'BUS2000152',
    cust_contract              TYPE crmt_swo_objtyp_process VALUE 'BUS2000135',
    pur_contract               TYPE crmt_swo_objtyp_process VALUE 'BUS2000136',
    srv_contract               TYPE crmt_swo_objtyp_process VALUE 'BUS2000137',
    fin_contract               TYPE crmt_swo_objtyp_process VALUE 'BUS2000138',
    pur_sched_agrm             TYPE crmt_swo_objtyp_process VALUE 'BUS2000139',
    srv_agreement              TYPE crmt_swo_objtyp_process VALUE 'BUS2000157',
    service                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000140',
    srv_confirm_m              TYPE crmt_swo_objtyp_process VALUE 'BUS2000142',
    srv_confirm_p              TYPE crmt_swo_objtyp_process VALUE 'BUS2000143',
    srv_confirm_e              TYPE crmt_swo_objtyp_process VALUE 'BUS2000158',
    srv_confirm_t              TYPE crmt_swo_objtyp_process VALUE 'BUS2000154',
    inspection                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000144',
    service_m                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000146',
    service_e                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000159',
    service_t                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000153',
    util_contract              TYPE crmt_swo_objtyp_process VALUE 'BUS2000147',
    util_contract_l            TYPE crmt_swo_objtyp_process VALUE 'BUS2000149',
    util_package_item          TYPE crmt_swo_objtyp_process VALUE 'BUS2000196',
    util_prod_det_item         TYPE crmt_swo_objtyp_process VALUE 'BUS2000349',
    srv_plan_item              TYPE crmt_swo_objtyp_process VALUE 'BUS2000148',
    invoice_req                TYPE crmt_swo_objtyp_process VALUE 'BUS2000163',
    credit_req                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000162',
    debit_req                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000167',
    credit_cor_req             TYPE crmt_swo_objtyp_process VALUE 'BUS2000169',
    debit_cor_req              TYPE crmt_swo_objtyp_process VALUE 'BUS2000168',
    credit_plan_req            TYPE crmt_swo_objtyp_process VALUE 'BUS2000166',
    object                     TYPE crmt_swo_objtyp_process VALUE 'BUS2000170',
    complaint                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000160',
    return                     TYPE crmt_swo_objtyp_process VALUE 'BUS2000161',
    substdeliv                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000165',
    lead                       TYPE crmt_swo_objtyp_process VALUE 'BUS2000129',
    ret_delivery               TYPE crmt_swo_objtyp_process VALUE 'BUS2000164',
    scrapping                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000185',
    loaner                     TYPE crmt_swo_objtyp_process VALUE 'BUS2000186',
    loaner_return              TYPE crmt_swo_objtyp_process VALUE 'BUS2000187',
    sur_confirm                TYPE crmt_swo_objtyp_process VALUE 'BUS2000178',
    rev_alloc                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000188',
    rebate_item                TYPE crmt_swo_objtyp_process VALUE 'BUS2000190',
    claim_item                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000191',
    tc_contract_item           TYPE crmt_swo_objtyp_process VALUE 'BUS2000195',
    checklist_item             TYPE crmt_swo_objtyp_process VALUE 'BUS2000199',
    prov_order_itm             TYPE crmt_swo_objtyp_process VALUE 'BUS2000155',
    prov_contract_itm          TYPE crmt_swo_objtyp_process VALUE 'BUS2000156',
*   Provider Master Agreement Item
    prov_master_agreement_item TYPE crmt_swo_objtyp_process VALUE 'BUS2000183',
    claim_submission_document  TYPE crmt_swo_objtyp_process VALUE 'BUS2000314',
    claim_settlement_request   TYPE crmt_swo_objtyp_process VALUE 'BUS2000315',
    claim_settl_req_fund_assgn TYPE crmt_swo_objtyp_process VALUE 'BUS2000318',
    claim_tax_item             TYPE crmt_swo_objtyp_process VALUE 'BUS2000319',
    prepayment_request         TYPE crmt_swo_objtyp_process VALUE 'BUS2000316',
    budget_reservation         TYPE crmt_swo_objtyp_process VALUE 'BUS2000317',
    chargeback                 TYPE crmt_swo_objtyp_process VALUE 'BUS2000321',
*   Chargeback item in the recovery assignment block of the chargeback
    chargeback_rv              TYPE crmt_swo_objtyp_process VALUE 'BUS2000322',
    claim_calc_tax_item        TYPE crmt_swo_objtyp_process VALUE 'BUS2000329',
*   Chargeback Recovery Item of the chargeback recovery document
    chargeback_recovery        TYPE crmt_swo_objtyp_process VALUE 'BUS2000331',
*   Financial Servcies
    product_bundle             TYPE crmt_swo_objtyp_process VALUE 'BUS2000300',
    fs_loan                    TYPE crmt_swo_objtyp_process VALUE 'BUS2000301',
    fs_insurance               TYPE crmt_swo_objtyp_process VALUE 'BUS2000302',
    fs_coll_agree              TYPE crmt_swo_objtyp_process VALUE 'BUS2000303',
    fs_sales                   TYPE crmt_swo_objtyp_process VALUE 'BUS2000304',
    fs_drm_outl                TYPE crmt_swo_objtyp_process VALUE 'BUS2000305',
    fs_cms_collat              TYPE crmt_swo_objtyp_process VALUE 'BUSISB104',
    fs_cms_cag                 TYPE crmt_swo_objtyp_process VALUE 'BUSISB101',
    fs_cml_loan                TYPE crmt_swo_objtyp_process VALUE 'BUS2049',
    fs_invoice_req             TYPE crmt_swo_objtyp_process VALUE 'BUS2000171',
    fs_object_data_item        TYPE crmt_swo_objtyp_process VALUE 'BUS2000306',
*Note1103349
    fs_real_estate             TYPE crmt_swo_objtyp_process VALUE 'BUS2000170',
**    For retail Mortgage Loan
    fs_rel_morgloan            TYPE crmt_swo_objtyp_process VALUE 'BUS2000309',
*   Billing Engine
    invoice                    TYPE crmt_swo_objtyp_process VALUE 'BUS20820',
*   Rebate Engine
    settledoc                  TYPE crmt_swo_objtyp_process VALUE 'BUS20840',
*   Telco
    ist_order_pos              TYPE crmt_swo_objtyp_process VALUE 'BUS2000155',
    ist_contract_pos           TYPE crmt_swo_objtyp_process VALUE 'BUS2000156',
*   Intellectual Property Mngmt.
    ipm_contract_s             TYPE crmt_swo_objtyp_process VALUE 'BUS2000176',
    ipm_contract_p             TYPE crmt_swo_objtyp_process VALUE 'BUS2000175',
    ipm_confirm                TYPE crmt_swo_objtyp_process VALUE 'BUS2000177',
    activity                   TYPE crmt_swo_objtyp_process VALUE 'BUS2000127',
*   UBB
    pool_contract              TYPE crmt_swo_objtyp_process VALUE 'BUS2000251',
    ubb_srv_contract           TYPE crmt_swo_objtyp_process VALUE 'BUS2000252',
    gaid                       TYPE crmt_swo_objtyp_process VALUE 'ALLOC_ID',
*   Grantor Management
    grantor_appl_item          TYPE crmt_swo_objtyp_process VALUE 'BUS2000275',
    grantor_agre_item          TYPE crmt_swo_objtyp_process VALUE 'BUS2000276',
    grantor_claim_item         TYPE crmt_swo_objtyp_process VALUE 'BUS2000277',
*   Social Services
    social_appl_item           TYPE crmt_swo_objtyp_process VALUE 'BUS2000287',
    social_srvp_item           TYPE crmt_swo_objtyp_process VALUE 'BUS2000288',
    preq_item                  TYPE crmt_swo_objtyp_process VALUE 'BUS2000289',
    deduct_plan_item           TYPE crmt_swo_objtyp_process VALUE 'BUS2000291',
*   Public Sector
    decision_basis_item        TYPE crmt_swo_objtyp_process VALUE 'BUS2000293',
    gift_certificate           TYPE crmt_swo_objtyp_process VALUE 'BUS200600',
*   Funds Management
    budget_posting_item        TYPE crmt_swo_objtyp_process VALUE 'BUS2000405',
*   Utilities DSM - Demand Side Management.
    dsm_measure                TYPE crmt_swo_objtyp_process VALUE 'BUS2000415',
    dsm_prg_measure            TYPE crmt_swo_objtyp_process VALUE 'BUS2100415',
    dsm_incentive              TYPE crmt_swo_objtyp_process VALUE 'BUS2000416',
    dsm_prg_incentive          TYPE crmt_swo_objtyp_process VALUE 'BUS2100416',
    dsm_prg_goal_contr         TYPE crmt_swo_objtyp_process VALUE 'BUS2100417',
    dsm_equipment              TYPE crmt_swo_objtyp_process VALUE 'BUS2000417',
*   Composite Transaction item
    comp_transaction_item      TYPE crmt_swo_objtyp_process VALUE 'BUS2000105',
  END OF gc_object_type_item,

* // WF events
  BEGIN OF gc_object_event,
    created                    TYPE swo_event VALUE 'CREATED',
    deleted                    TYPE swo_event VALUE 'DELETED',
  END OF gc_object_event,

* Assigned Application of Business Transaction Category
  BEGIN OF gc_btc_application,
    crm                        TYPE crmt_application VALUE 'CRM', " One Order CRM
    ebp                        TYPE crmt_application VALUE 'EBP', " One Order EBP
  END OF gc_btc_application,

  BEGIN OF gc_relation_type,
    sales                      TYPE  binreltyp  VALUE 'REPL',
    service                    TYPE  binreltyp  VALUE 'SRV1',
    oltp                       TYPE  binreltyp  VALUE 'VORA',
  END OF gc_relation_type,

  BEGIN OF gc_template_types,
     campaign_mobile           TYPE crmt_template_type VALUE 'A',
     doc_flow_h_i_online       TYPE crmt_template_type VALUE 'B',
     doc_flow_h_online         TYPE crmt_template_type VALUE 'C',
     no_doc_flow_online        TYPE crmt_template_type VALUE 'D',
  END OF gc_template_types,

  gc_template_types_online(3)  TYPE c VALUE 'BCD',

* solution configurator relevant product role
  BEGIN OF gc_product_role,
     sales_package             TYPE crmt_product_role  VALUE 'S',
     combined_rate_plan        TYPE crmt_product_role  VALUE 'C',
     rate_plan                 TYPE crmt_product_role  VALUE 'R',
     blank                     TYPE crmt_product_role  VALUE ' ',
  END OF gc_product_role,

* Order type
  BEGIN OF gc_prod_purpose,
     standard                  TYPE crmt_isx_prod_class VALUE ' ',
     master_agreement          TYPE crmt_isx_prod_class VALUE 'A',
     revenue_distribution      TYPE crmt_isx_prod_class VALUE 'B',
    counter_pooling            TYPE crmt_isx_prod_class VALUE 'P',
      END OF gc_prod_purpose,

* sel_type
  BEGIN OF gc_sel_type,
     sales_package             TYPE crmt_provider_product_role VALUE 'S',
     nested_sales_package      TYPE crmt_provider_product_role VALUE 'N',
     combined_rate_plan        TYPE crmt_provider_product_role VALUE 'C',
     main_rate_plan            TYPE crmt_provider_product_role VALUE 'M',
     rate_plan                 TYPE crmt_provider_product_role VALUE 'R',
     sales_item_fee            TYPE crmt_provider_product_role VALUE 'I',
*    sales item / one time fee
  END OF gc_sel_type,

* Order type
  BEGIN OF gc_document_purpose,
     standard                  TYPE crmt_isx_document_purpose VALUE ' ',
     master_agreement          TYPE crmt_isx_document_purpose VALUE 'A',
     revenue_distribution      TYPE crmt_isx_document_purpose VALUE 'B',
     counter_pooling           TYPE crmt_isx_document_purpose VALUE 'P',
  END OF gc_document_purpose,

  gc_rfc_btx_class TYPE crmt_transaction_classificatn VALUE 'A',

  gc_bcq_btx_class TYPE crmt_transaction_classificatn VALUE 'A',
  gc_bsc_btx_class TYPE crmt_transaction_classificatn VALUE 'B'.
