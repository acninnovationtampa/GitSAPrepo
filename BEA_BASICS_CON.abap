*----------------------------------------------------------------------*
*   INCLUDE BEA_BASICS_CON                                             *
*----------------------------------------------------------------------*


************************************************************************
* Please, sort alphabetically by the TYPE!!!!!!!!!!!!!!!


CONSTANTS:
  gc_src_activity_insert TYPE bea_activity      VALUE 'A'            , "#EC *
  gc_src_activity_dl04   TYPE bea_activity      VALUE 'B'            , "#EC *
  gc_appl_memory_id(10)                         VALUE 'BEA_APPL'     , "#EC *
  gc_actv_change       TYPE activ_auth          VALUE '02'           , "#EC *
  gc_actv_create       TYPE activ_auth          VALUE '01'           , "#EC *
  gc_actv_display      TYPE activ_auth          VALUE '03'           , "#EC *
  gc_actv_lock         TYPE activ_auth          VALUE '05'           , "#EC *
  gc_actv_massdata     TYPE activ_auth          VALUE 'A8'           , "#EC *
  gc_actv_create_ext   TYPE activ_auth          VALUE '40'           , "#EC *
  gc_actv_output       TYPE activ_auth          VALUE '35'           , "#EC *
  gc_actv_cancel       TYPE activ_auth          VALUE '85'           , "#EC *
  gc_actv_settle       TYPE activ_auth          VALUE '84'           , "#EC *
  gc_actv_supplement   TYPE activ_auth          VALUE '82'           , "#EC *
  gc_actv_transition   TYPE activ_auth          VALUE 'B4'           , "#EC *
  gc_actv_check        TYPE activ_auth          VALUE '39'           , "#EC *
  gc_actv_unlock       TYPE activ_auth          VALUE '95'           , "#EC *
  gc_actv_reauth       TYPE activ_auth          VALUE 'C6'           , "#EC *
  gc_actv_pay          TYPE activ_auth          VALUE 'A2'           , "#EC *
  gc_actv_accrue       TYPE activ_auth          VALUE 'A1'           , "#EC *
  gc_actv_add_vol      TYPE activ_auth          VALUE 'U4'           , "#EC *
  gc_rangeoption_eq    TYPE bapioption          VALUE 'EQ'           , "#EC *
  gc_rangeoption_bt    TYPE bapioption          VALUE 'BT'           , "#EC *
  gc_equal             TYPE bapioption          VALUE 'EQ'           , "#EC *
  gc_contains_pattern  TYPE bapioption          VALUE 'CP'           , "#EC *
  gc_not_equal         TYPE bapioption          VALUE 'NE'           , "#EC *
  gc_greater_equal     TYPE bapioption          VALUE 'GE'           , "#EC *
  gc_bapi_par_dli      TYPE bapi_param          VALUE 'IT_DLI'       , "#EC *
  gc_bapi_par_rdli     TYPE bapi_param          VALUE 'IT_RDLI'      , "#EC *
  gc_sign_include      TYPE bapisign            VALUE 'I'            , "#EC *
  gc_include           TYPE bapisign            VALUE 'I'            , "#EC *
  gc_exclude           TYPE bapisign            VALUE 'E'            , "#EC *
  gc_asterix           TYPE bapisign            VALUE '*'            , "#EC *
  gc_al_dsp_n          TYPE bea_al_mode         VALUE 'A'            , "#EC *
  gc_al_dsp_x          TYPE bea_al_mode         VALUE 'B'            , "#EC *
  gc_al_dsp_e          TYPE bea_al_mode         VALUE 'C'            , "#EC *
  gc_bdproc_change     TYPE bea_bd_process      VALUE 'A'            , "#EC *
  gc_bdproc_transfer   TYPE bea_bd_process      VALUE 'B'            , "#EC *
  gc_bdproc_cancel     TYPE bea_bd_process      VALUE 'C'            , "#EC *
  gc_bdproc_actions    TYPE bea_bd_process      VALUE 'D'            , "#EC *
  gc_bdproc_orderupd   TYPE bea_bd_process      VALUE 'E'            , "#EC *
  gc_bdproc_bdocs      TYPE bea_bd_process      VALUE 'F'            , "#EC *
  gc_bd_process        TYPE bea_bd_uimode       VALUE 'A'            , "#EC *
  gc_bd_bill           TYPE bea_bd_uimode       VALUE 'B'            , "#EC *
  gc_bd_bill_sgl       TYPE bea_bd_uimode       VALUE 'C'            , "#EC *
  gc_bd_transfer       TYPE bea_bd_uimode       VALUE 'D'            , "#EC *
  gc_bd_disp           TYPE bea_bd_uimode       VALUE 'E'            , "#EC *
  gc_bd_dial_canc      TYPE bea_bd_uimode       VALUE 'F'            , "#EC *
  gc_bd_retrobill      TYPE bea_bd_uimode       VALUE 'G'            , "#EC *
  gc_bd_icv_transfer   TYPE bea_bd_uimode       VALUE 'H'            , "#EC *
  gc_bill_cat_ext        TYPE bea_bill_category   VALUE ' '          , "#EC *
  gc_bill_cat_int        TYPE bea_bill_category   VALUE 'A'          , "#EC *
  gc_bill_cat_accrual    TYPE bea_bill_category   VALUE 'B'          , "#EC *
  gc_bill_cat_proforma   TYPE bea_bill_category   VALUE 'C'          , "#EC *
  gc_bill_cat_prepayment TYPE bea_bill_category   VALUE 'D'          , "#EC *
  gc_bill_cat_clsett_ap  TYPE bea_bill_category   VALUE 'E'          , "#EC *
  gc_bill_cat_clsett_ar  TYPE bea_bill_category   VALUE 'F'          , "#EC *
  gc_bill_cat_payee      TYPE bea_bill_category   VALUE 'G'          , "#EC *
  gc_bill_rel_direct   TYPE bea_bill_relev      VALUE ' '            , "#EC *
  gc_bill_rel_indirect TYPE bea_bill_relev      VALUE 'X'            , "#EC *
  gc_bill_rel_un_def   TYPE bea_bill_relevance  VALUE ' '            , "#EC *
  gc_bill_rel_order    TYPE bea_bill_relevance  VALUE 'A'            , "#EC *
  gc_bill_rel_delivery TYPE bea_bill_relevance  VALUE 'B'            , "#EC *
  gc_bill_rel_order_ic TYPE bea_bill_relevance  VALUE 'C'            , "#EC *
  gc_bill_rel_deliv_ic TYPE bea_bill_relevance  VALUE 'D'            , "#EC *
  gc_bill_rel_value    TYPE bea_bill_relevance  VALUE 'E'            , "#EC *
  gc_bill_rel_dlv_tpop TYPE bea_bill_relevance  VALUE 'F'            , "#EC *
  gc_bill_rel_lean     TYPE bea_bill_relevance  VALUE 'G'            , "#EC *
  gc_bill_rel_billreq_i TYPE bea_bill_relevance VALUE 'H'            , "#EC *
  gc_billstat_no       TYPE bea_bill_status     VALUE ' '            , "#EC *
  gc_billstat_todo     TYPE bea_bill_status     VALUE 'A'            , "#EC *
  gc_billstat_done     TYPE bea_bill_status     VALUE 'B'            , "#EC *
  gc_billstat_reject   TYPE bea_bill_status     VALUE 'C'            , "#EC *
  gc_false             TYPE bea_boolean         VALUE ' '            , "#EC *
  gc_true              TYPE bea_boolean         VALUE 'X'            , "#EC *
  gc_scenario_sales    TYPE bea_business_scenario VALUE 'A'          , "#EC *
  gc_transf_to_bea     TYPE j_vorgang VALUE 'TOBE'                   , "#EC *
  gc_scenario_service  TYPE bea_business_scenario VALUE 'B'          , "#EC *
  gc_scenario_finance  TYPE bea_business_scenario VALUE 'C'          , "#EC *
  gc_cancel            TYPE bea_cancel_flag     VALUE 'A'            , "#EC *
  gc_partial_cancel    TYPE bea_cancel_flag     VALUE 'B'            , "#EC *
  gc_cause_cancel      TYPE bea_cancel_reason   VALUE 'A'            , "#EC *
  gc_cause_rej_new     TYPE bea_cancel_reason   VALUE 'B'            , "#EC *
  gc_cause_reject      TYPE bea_cancel_reason   VALUE 'C'            , "#EC *
  gc_no_correction     TYPE bea_corr_indicat    VALUE ' '            , "#EC *
  gc_sub_to_correction TYPE bea_corr_indicat    VALUE 'A'            , "#EC *
  gc_sub_to_special_correction TYPE bea_corr_indicat VALUE 'B'       , "#EC *
  gc_cc_cumulation     TYPE bea_creation_code   VALUE 'A'            , "#EC *
  gc_credit            TYPE bea_credit_debit    VALUE 'B'            , "#EC *
  gc_debit             TYPE bea_credit_debit    VALUE 'A'            , "#EC *
  gc_crp_nav_to_bd     TYPE bea_crp_mode        VALUE 'A'            , "#EC *
  gc_crp_no_nav_to_bd  TYPE bea_crp_mode        VALUE 'B'            , "#EC *
  gc_crp_type_cancel   TYPE bea_crp_type        VALUE 'B'            , "#EC *
  gc_crp_type_bill     TYPE bea_crp_type        VALUE 'A'            , "#EC *
  gc_dfl_head          TYPE bea_dfl_level       VALUE 'H'            , "#EC *
  gc_dfl_item          TYPE bea_dfl_level       VALUE 'I'            , "#EC *
  gc_dl_type_head      TYPE bea_dl_header_item  VALUE 'H'            , "#EC *
  gc_dl_type_item      TYPE bea_dl_header_item  VALUE 'I'            , "#EC *
  gc_dl_process        TYPE bea_dl_uimode       VALUE 'A'            , "#EC *
  gc_dl_release        TYPE bea_dl_uimode       VALUE 'B'            , "#EC *
  gc_dl_qrel           TYPE bea_dl_uimode       VALUE 'C'            , "#EC *
  gc_dl_errorlist      TYPE bea_dl_uimode       VALUE 'D'            , "#EC *
  gc_dl_reject         TYPE bea_dl_uimode       VALUE 'E'            , "#EC *
  gc_dl_iat_transfer   TYPE bea_dl_uimode       VALUE 'F'            , "#EC *
  gc_dl_reject_dl04    TYPE bea_dl_uimode       VALUE 'G'            , "#EC *
  gc_dl_ui_obj_id      TYPE bea_dli_uitype      VALUE 'A'            , "#EC *
  gc_dl_ui_obj_det     TYPE bea_dli_uitype      VALUE 'B'            , "#EC *
  gc_bd_origin_crmb    TYPE bea_document_origin VALUE ' '            , "#EC *
  gc_bd_origin_exta    TYPE bea_document_origin VALUE 'A'            , "#EC *
  gc_iat_ok            TYPE bea_iat_status      VALUE ' '            , "#EC *
  gc_iat_error         TYPE bea_iat_status      VALUE 'A'            , "#EC *
  gc_incomp_ok         TYPE bea_incomp_id       VALUE ' '            , "#EC *
  gc_incomp_error      TYPE bea_incomp_id       VALUE 'A'            , "#EC *
  gc_incomp_enq        TYPE bea_incomp_id       VALUE 'B'            , "#EC *
  gc_incomp_reject     TYPE bea_incomp_id       VALUE 'C'            , "#EC *
  gc_incomp_cancel     TYPE bea_incomp_id       VALUE 'D'            , "#EC *
  gc_incomp_fatal      TYPE bea_incomp_id       VALUE 'E'            , "#EC *
  gc_is_not_reversed   TYPE bea_is_reversed     VALUE ' '            , "#EC *
  gc_is_reved_by_canc  TYPE bea_is_reversed     VALUE 'A'            , "#EC *
  gc_is_reved_by_corr  TYPE bea_is_reversed     VALUE 'B'            , "#EC *
  gc_is_reved_no_fix   TYPE bea_is_reversed     VALUE 'b'            , "#EC *
  gc_item_type_normal  TYPE bea_item_type       VALUE ' '            , "#EC *
  gc_item_type_value   TYPE bea_item_type       VALUE 'A'            , "#EC *
  gc_item_type_struct  TYPE bea_item_type       VALUE 'B'            , "#EC *
  gc_item_type_accrual TYPE bea_item_type       VALUE 'C'            , "#EC *
  gc_iteminc_10        TYPE bea_iteminc         VALUE '10'           , "#EC *
  gc_bdh               TYPE bea_object_type     VALUE 'A'            , "#EC *
  gc_dli               TYPE bea_object_type     VALUE 'B'            , "#EC *
  gc_bdi               TYPE bea_object_type     VALUE 'C'            , "#EC *
  gc_mkt_subobj_cop    TYPE bea_mkt_subobj      VALUE 'A'            , "#EC *
  gc_mkt_subobj_pp     TYPE bea_mkt_subobj      VALUE 'B'            , "#EC *
  gc_mkt_subobj_ao     TYPE bea_mkt_subobj      VALUE 'C'            , "#EC *
  gc_mkt_subobj_fba    TYPE bea_mkt_subobj      VALUE 'D'            , "#EC *
  gc_mkt_subobj_inv_pp TYPE bea_mkt_subobj      VALUE 'E'            , "#EC *
  gc_par_copy_false    TYPE bea_partner_copy    VALUE ' '            , "#EC *
  gc_par_copy_true     TYPE bea_partner_copy    VALUE 'A'            , "#EC *
  gc_par_copy_drv      TYPE bea_partner_copy    VALUE 'B'            , "#EC *
  gc_partbill_partial  TYPE bea_partbill_stat   VALUE 'A'            , "#EC *
  gc_partbill_total    TYPE bea_partbill_stat   VALUE 'B'            , "#EC *
  gc_partbill_int_active TYPE bea_partbill_control VALUE 'A'         , "#EC *
  gc_partbill_ext_active TYPE bea_partbill_control VALUE 'B'         , "#EC *
  gc_paym_meth_psp     TYPE bea_paym_meth     VALUE 'A'              , "#EC *
  gc_proc_add          TYPE bea_process_mode    VALUE 'B'            , "#EC *
  gc_proc_noadd        TYPE bea_process_mode    VALUE 'A'            , "#EC *
  gc_proc_test         TYPE bea_process_mode    VALUE 'C'            , "#EC *
  gc_proc_test_buff    TYPE bea_process_mode    VALUE 'D'            , "#EC *
  gc_pod_not_relevant  TYPE bea_pod_status      VALUE ' '            , "#EC *
  gc_pod_relevant      TYPE bea_pod_status      VALUE 'A'            , "#EC *
  gc_pod_in_process    TYPE bea_pod_status      VALUE 'B'            , "#EC *
  gc_pod_confirmed     TYPE bea_pod_status      VALUE 'C'            , "#EC *
  gc_reversal_correc   TYPE bea_reversal        VALUE 'B'            , "#EC *
  gc_reversal_cancel   TYPE bea_reversal        VALUE 'A'            , "#EC *
  gc_bea_scenario_crm  TYPE bea_scenario        VALUE 'CRM'          , "#EC *
  gc_bea_scenario_les  TYPE bea_scenario        VALUE 'LES'          , "#EC *
  gc_bea_scenario_ext  TYPE bea_scenario        VALUE 'EXT'          , "#EC *
  gc_src_origin_int    TYPE bea_src_origin      VALUE ' '            , "#EC *
  gc_src_origin_ext    TYPE bea_src_origin      VALUE 'A'            , "#EC *
  gc_no_sortrel           TYPE bea_sortrel      VALUE ' '            , "#EC *
  gc_sort_by_primary_key  TYPE bea_sortrel      VALUE 'A'            , "#EC *
  gc_sort_by_external_ref TYPE bea_sortrel      VALUE 'B'            , "#EC *
  gc_sort_by_references   TYPE bea_sortrel      VALUE 'C'            , "#EC *
  gc_sort_by_internal_ref TYPE bea_sortrel      VALUE 'D'            , "#EC *
  gc_sort_by_ext_guid_ref TYPE bea_sortrel      VALUE 'E'            , "#EC *
  gc_takeover_external  TYPE bea_takeover_mode  VALUE 'A'            , "#EC *
  gc_takeover_internal  TYPE bea_takeover_mode  VALUE 'B'            , "#EC *
  gc_takeover_enhance   TYPE bea_takeover_mode  VALUE 'C'            , "#EC *
  gc_transfer_todo     TYPE bea_transfer_status VALUE ' '            , "#EC *
  gc_transfer_block    TYPE bea_transfer_status VALUE 'A'            , "#EC *
  gc_transfer_in_work  TYPE bea_transfer_status VALUE 'B'            , "#EC *
  gc_transfer_done     TYPE bea_transfer_status VALUE 'C'            , "#EC *
  gc_transfer_cancel   TYPE bea_transfer_status VALUE 'D'            , "#EC *
  gc_transfer_not_rel  TYPE bea_transfer_status VALUE 'E'            , "#EC *
  gc_transfer_no_ui    TYPE bea_transfer_status VALUE 'F'            , "#EC *
  gc_transfer_acc      TYPE bea_transfer_type   VALUE ' '            , "#EC *
  gc_transfer_sdb      TYPE bea_transfer_type   VALUE 'A'            , "#EC *
  gc_transfer_mmiv     TYPE bea_transfer_type   VALUE 'B'            , "#EC *
  gc_transfer_fiiv     TYPE bea_transfer_type   VALUE 'C'            , "#EC *
  gc_commit_async      TYPE bef_commit          VALUE 'A'            , "#EC *
  gc_commit_sync       TYPE bef_commit          VALUE 'B'            , "#EC *
  gc_commit_local      TYPE bef_commit          VALUE 'C'            , "#EC *
  gc_nocommit          TYPE bef_commit          VALUE ' '            , "#EC *
  gc_ppf_backgr_task   TYPE boolean             VALUE 'X'            , "#EC *
  gc_ppf_commit        TYPE boolean             VALUE ' '            , "#EC *
  gc_ppf_update_task   TYPE boolean             VALUE '-'            , "#EC *
  gc_billblock_none    TYPE c                   VALUE ' '            , "#EC *
  gc_billblock_qc      TYPE c                   VALUE 'Q'            , "#EC *
  gc_billblock_intern  TYPE c                   VALUE 'X'            , "#EC *
  gc_billblock_extern  TYPE c                   VALUE 'A'            , "#EC *
  gc_billblock_process TYPE c                   VALUE 'P'            , "#EC *
  gc_numeric(10)       TYPE c                   VALUE '0123456789'   , "#EC *
  gc_variant_all(1)    TYPE c                   VALUE 'A'            , "#EC *
  gc_cancel_full       TYPE char1               VALUE 'A'            , "#EC *
  gc_cancel_partial    TYPE char1               VALUE 'B'            , "#EC *
  gc_cancel_complete   TYPE char1               VALUE 'C'            , "#EC *
  gc_background_picture(9) TYPE c               VALUE 'BE_BANNER'    , "#EC *
  gc_step_disp         TYPE ddshf4step          VALUE 'DISP'         , "#EC *
  gc_step_return       TYPE ddshf4step          VALUE 'RETURN'       , "#EC *
  gc_step_exit         TYPE ddshf4step          VALUE 'EXIT'         , "#EC *
  gc_background_color  TYPE i                   VALUE '15'           , "#EC *
  gc_max_sel_opt       TYPE i                   VALUE '500'          , "#EC *
  gc_gennamespace      TYPE namespace           VALUE '/1BEA/'       , "#EC *
  gc_nrobj_bdh         TYPE nrobj               VALUE 'BEABILLDOC'   , "#EC *
  gc_bor_bkpf          TYPE oj_name             VALUE 'BKPF    '     , "#EC *
  gc_bor_ca_doc        TYPE oj_name             VALUE 'CA_DOC  '     , "#EC *
  gc_bor_vbrk          TYPE oj_name             VALUE 'VBRK    '     , "#EC *
  gc_bor_likp          TYPE oj_name             VALUE 'LIKP    '     , "#EC *
  gc_bor_inb_dlv       TYPE oj_name             VALUE 'BUS2015 '     , "#EC *
  gc_bor_inspection    TYPE oj_name             VALUE '/SPE/INSPE'   , "#EC *
  gc_bor_purchase      TYPE oj_name             VALUE 'BUS2012'      , "#EC *
  gc_bor_dli           TYPE oj_name             VALUE 'BUS20800'     , "#EC *
  gc_bor_bdh           TYPE oj_name             VALUE 'BUS20810'     , "#EC *
  gc_bor_bdi           TYPE oj_name             VALUE 'BUS20820'     , "#EC *
  gc_bor_rdlh          TYPE oj_name             VALUE 'BUS20880'     , "#EC *
  gc_bor_rexh          TYPE oj_name             VALUE 'BUS20870'     , "#EC *
  gc_bor_rpdh          TYPE oj_name             VALUE 'BUS20830'     , "#EC *
  gc_bor_rpdi          TYPE oj_name             VALUE 'BUS20840'     , "#EC *
  gc_crp               TYPE oj_name             VALUE 'CRP'          , "#EC *
  gc_ppfappl           TYPE ppfdappl            VALUE 'BILLING'      , "#EC *
  gc_selkind_param     TYPE rsscr_kind          VALUE 'P'            , "#EC *
  gc_selkind_selopt    TYPE rsscr_kind          VALUE 'S'            , "#EC *
  gc_msg_bapi          TYPE symsgno             VALUE '000'          , "#EC *
  gc_amessage          TYPE symsgty             VALUE 'A'            , "#EC *
  gc_emessage          TYPE symsgty             VALUE 'E'            , "#EC *
  gc_imessage          TYPE symsgty             VALUE 'I'            , "#EC *
  gc_smessage          TYPE symsgty             VALUE 'S'            , "#EC *
  gc_wmessage          TYPE symsgty             VALUE 'W'            , "#EC *
  gc_xmessage          TYPE symsgty             VALUE 'X'            , "#EC *
  gc_p_dli_headno      TYPE symsgv              VALUE '%DLI_H%'      , "#EC *
  gc_p_dli_itemno      TYPE symsgv              VALUE '%DLI_I%'      , "#EC *
  gc_p_dli_p_headno    TYPE symsgv              VALUE '%DLI_PH%'     , "#EC *
  gc_p_dli_p_itemno    TYPE symsgv              VALUE '%DLI_PI%'     , "#EC *
  gc_prog_stat_title   TYPE syrepid   VALUE  'SAPLBEFB_SCREEN_CENTER', "#EC *
  gc_tabix_zero        TYPE sytabix             VALUE '0'            , "#EC *
  gc_fcode_next        TYPE syucomm             VALUE 'NEXT'         , "#EC *
  gc_fcode_prev        TYPE syucomm             VALUE 'PREV'         , "#EC *
  gc_fcode_save        TYPE syucomm             VALUE 'SAVE'         , "#EC *
  gc_fcode_toggle      TYPE syucomm             VALUE 'TOGGLE'       , "#EC *
  gc_fcode_release     TYPE syucomm             VALUE 'RELEASE'      , "#EC *
  gc_fcode_simulate    TYPE syucomm             VALUE 'SIMULATE'     , "#EC *
  gc_fcode_acc_doc     TYPE syucomm             VALUE 'ACC_DOC'      , "#EC *
  gc_docfl             TYPE syucomm             VALUE 'DOCFL'        , "#EC *
  gc_unchanged         TYPE update_type         VALUE ' '            , "#EC *
  gc_update            TYPE update_type         VALUE 'U'            , "#EC *
  gc_insert            TYPE update_type         VALUE 'I'            , "#EC *
  gc_delete            TYPE update_type         VALUE 'D'            , "#EC *
  BEGIN OF gc_objpoolbuf                                             , "#EC *
    active             TYPE char6               VALUE 'ACTIVE'       , "#EC *
    save               TYPE char6               VALUE 'SAVE'         , "#EC *
    reset              TYPE char6               VALUE 'RESET'        , "#EC *
  END OF gc_objpoolbuf                                               , "#EC *
  BEGIN OF gc_bea_product_kind                                       , "#EC *
    old                TYPE bea_product_kind    VALUE space          , "#EC *
    product            TYPE bea_product_kind    VALUE 'A'            , "#EC *
    variant            TYPE bea_product_kind    VALUE 'B'            , "#EC *
    iobject            TYPE bea_product_kind    VALUE 'C'            , "#EC *
    external           TYPE bea_product_kind    VALUE 'D'            , "#EC *
    grid               TYPE bea_product_kind    VALUE 'G'            , "#EC *
    undefined          TYPE bea_product_kind    VALUE 'X'            , "#EC *
  END OF gc_bea_product_kind                                         , "#EC *
  BEGIN OF gc_check_status                                           , "#EC *
    not_rejected       TYPE bea_check_status    VALUE space          , "#EC *
    part_rejected      TYPE bea_check_status    VALUE 'A'            , "#EC *
    full_rejected      TYPE bea_check_status    VALUE 'B'            , "#EC *
   END OF gc_check_status.
