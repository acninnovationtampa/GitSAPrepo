*--- REX
CONSTANTS:
  gc_ttyp_sales_vol      TYPE bea_reb_ttyp_r1 VALUE ' ',    "#EC NEEDED
  gc_ttyp_part_sett      TYPE bea_reb_ttyp_r1 VALUE 'A',    "#EC NEEDED
  gc_ttyp_fina_sett      TYPE bea_reb_ttyp_r1 VALUE 'B',    "#EC NEEDED
  gc_ttyp_manu_accru     TYPE bea_reb_ttyp_r1 VALUE 'C',    "#EC NEEDED
  gc_ttyp_correction     TYPE bea_reb_ttyp_r1 VALUE 'D',    "#EC NEEDED
  gc_ttyp_consum_ent     TYPE bea_reb_ttyp_r1 VALUE 'E',    "#EC NEEDED
  gc_ttyp_recalcu        TYPE bea_reb_ttyp_r1 VALUE 'F',    "#EC NEEDED
  gc_ttyp_closure        TYPE bea_reb_ttyp_r1 VALUE 'H',    "#EC NEEDED
  gc_ttyp_closure_sett   TYPE bea_reb_ttyp_r1 VALUE 'I',    "#EC NEEDED
  gc_ttyp_closure_trans  TYPE bea_reb_ttyp_r1 VALUE 'J',    "#EC NEEDED
  gc_ttyp_transfer       TYPE bea_reb_ttyp_r1 VALUE 'K'.    "#EC NEEDED

CONSTANTS:
  BEGIN OF gc_rexh_status,
    not_relevant         TYPE bea_rexh_status VALUE ' ',    "#EC NEEDED
    partially_relevant   TYPE bea_rexh_status VALUE 'A',    "#EC NEEDED
    fully_relevant       TYPE bea_rexh_status VALUE 'B',    "#EC NEEDED
    completely_processed TYPE bea_rexh_status VALUE 'C',    "#EC NEEDED
  END OF gc_rexh_status.

*--- RDL
* Rebate transaction type values
CONSTANTS:
  gc_sal_vol     VALUE ' ',         "#EC NEEDED collecting sales volume
  gc_par_pay     VALUE 'A',              "#EC NEEDED partial settlement
  gc_fin_pay     VALUE 'B',                "#EC NEEDED final settlement
  gc_man_acc     VALUE 'C',                        "#EC NEEDED accruals
  gc_corr        VALUE 'D',    "#EC NEEDED correction (base,scale base)
  gc_ent_con     VALUE 'E',               "#EC NEEDED consuming rebates
  gc_retro       VALUE 'F',                   "#EC NEEDED Recalculation
  gc_nullify     VALUE 'H',                   "#EC NEEDED Nullification
  gc_manpay      VALUE 'I',               "#EC NEEDED manual settlement
  gc_cvrd        VALUE 'G',        "#EC NEEDED cvrd marketing check run
  gc_rollclose   VALUE 'J',             "#EC NEEDED roll over + closure
  gc_rollover    VALUE 'K'.                      " #EC NEEDED Roll over

* Release status of RDLH entries/agreement
CONSTANTS:
  gc_rel_open            TYPE bea_rdlh_rel_status VALUE 'A', "#EC NEEDED Open (Released for settlement)
  gc_rel_released        TYPE bea_rdlh_rel_status VALUE 'B', "#EC NEEDED Released for final settlement
  gc_rel_blocked         TYPE bea_rdlh_rel_status VALUE 'C', "#EC NEEDED Blocked  for settlement
  gc_rel_delete          TYPE bea_rdlh_rel_status VALUE 'D', "#EC NEEDED Marked for deletion
                                                             "Close after condition deletion
  gc_rel_error           TYPE bea_rdlh_rel_status VALUE 'E', "#EC NEEDED Blocked error in the agreement
  gc_rel_close           TYPE bea_rdlh_rel_status VALUE 'F', "#EC NEEDED Close without recall
  gc_rel_close_rc        TYPE bea_rdlh_rel_status VALUE 'G'. "#EC NEEDED Close with recall

* Settlement status of RDLH entries/agreement
CONSTANTS:
  gc_sett_open           TYPE bea_rdlh_sett_status VALUE 'A', "#EC NEEDED
  gc_sett_settled        TYPE bea_rdlh_sett_status VALUE 'B', "#EC NEEDED
  gc_sett_finaset        TYPE bea_rdlh_sett_status VALUE 'C', "#EC NEEDED
  gc_sett_deleted        TYPE bea_rdlh_sett_status VALUE 'D'. "#EC NEEDED

* Process Status of RDLH entries
CONSTANTS:
  gc_not_relevant        TYPE bea_rdlh_status VALUE ' ',    "#EC NEEDED
  gc_not_processed       TYPE bea_rdlh_status VALUE 'A',    "#EC NEEDED
  gc_part_processed      TYPE bea_rdlh_status VALUE 'B',    "#EC NEEDED
  gc_full_processed      TYPE bea_rdlh_status VALUE 'C',    "#EC NEEDED
  gc_err_processed       TYPE bea_rdlh_status VALUE 'D'.    "#EC NEEDED


* Error ID of RDLH entries
CONSTANTS:
  gc_rdlh_errid_ok       TYPE bea_rdl_error_id VALUE ' ',   "#EC NEEDED
  gc_rdlh_errid_error    TYPE bea_rdl_error_id VALUE 'A', "#EC NEEDED Error
  gc_rdlh_errid_enq      TYPE bea_rdl_error_id VALUE 'B', "#EC NEEDED Locked
  gc_rdlh_errid_fs       TYPE bea_rdl_error_id VALUE 'C', "#EC NEEDED Already final settled
  gc_rdlh_errid_noa      TYPE bea_rdl_error_id VALUE 'D'. "#EC NEEDED Missing Authority

* Settle Status of RDLP
CONSTANTS:
  gc_rdlp_open           TYPE bea_rdlp_sett_status VALUE ' ', "#EC NEEDED Open
  gc_rdlp_settled        TYPE bea_rdlp_sett_status VALUE 'A', "#EC NEEDED closed by settlement
  gc_rdlp_nullified      TYPE bea_rdlp_sett_status VALUE 'B', "#EC NEEDED closed by nullification
  gc_rdlp_forward        TYPE bea_rdlp_sett_status VALUE 'C', "#EC NEEDED closed by roll over
  gc_rdlp_reopen         TYPE bea_rdlp_sett_status VALUE 'D', "#EC NEEDED reopened due to cancellation
  gc_rdlp_paid           TYPE bea_rdlp_sett_status VALUE 'E'. "#EC NEEDED Payment exit (dynamically set)


*--- RPD
CONSTANTS:
  gc_settlement_partial      TYPE bea_settle_category VALUE 'A', "#EC NEEDED
  gc_settlement_final        TYPE bea_settle_category VALUE 'B', "#EC NEEDED
  gc_settlement_accrual      TYPE bea_settle_category VALUE 'C', "#EC NEEDED
  gc_settlement_correct      TYPE bea_settle_category VALUE 'D', "#EC NEEDED
  gc_settlement_nullify      TYPE bea_settle_category VALUE 'H', "#EC NEEDED
  gc_settlement_manpay       TYPE bea_settle_category VALUE 'I', "#EC NEEDED
  gc_settlement_closuretrans TYPE bea_settle_category VALUE 'J', "#EC NEEDED
  gc_settlement_transfer     TYPE bea_settle_category VALUE 'K'. "#EC NEEDED


*---------------
CONSTANTS:
  gc_ppfappl_r1          TYPE ppfdappl         VALUE 'REBATE', "#EC NEEDED
  gc_bor_ragr            TYPE oj_name          VALUE 'BUS2000215', "#EC NEEDED
  gc_p_pre_partner       TYPE symsgv           VALUE '%PARTNER%'. "#EC NEEDED

CONSTANTS:
  gc_logsys_masked       TYPE bea_logsys        VALUE '<*>', "#EC NEEDED
  gc_objtype_masked      TYPE bea_ag_objtype_fv VALUE '<*>', "#EC NEEDED
  gc_type_id_masked      TYPE bea_ag_type_id    VALUE '<*>', "#EC NEEDED
  gc_objtype_billing     TYPE bea_objtype VALUE 'BUS20810', "#EC NEEDED
  gc_objtype_rebate      TYPE bea_objtype VALUE 'BUS20830', "#EC NEEDED
  gc_objtype_1o_rbag_i   TYPE bea_objtype VALUE 'BUS2000190', "#EC NEEDED
  gc_objtype_tpm         TYPE bea_objtype VALUE 'BUS2010030', "#EC NEEDED
  gc_objtype_tpm_elem    TYPE bea_objtype VALUE 'BUS2010032', "#EC NEEDED
  gc_objtype_cvc         TYPE bea_objtype VALUE '/SPL/BUS60', "#EC NEEDED
  gc_objtype_fbc         TYPE bea_objtype VALUE '/SPL/BUS70', "#EC NEEDED
  gc_prog_stat_title_r1  TYPE syrepid  VALUE  'SAPLBEA_SCREEN_CENTER_R1'. "#EC NEEDED

*---------------
CONSTANTS:
  gc_proc_cntrl_rebate   TYPE bea_proc_cntrl VALUE 'A',     "#EC NEEDED
  gc_proc_cntrl_entitle  TYPE bea_proc_cntrl VALUE 'B',     "#EC NEEDED
  gc_proc_cntrl_cvrd     TYPE bea_proc_cntrl VALUE 'C',     "#EC NEEDED
  gc_proc_cntrl_foc      TYPE bea_proc_cntrl VALUE 'D'.     "#EC NEEDED
CONSTANTS:
  gc_foc_caltype_001     TYPE reb_foc_cal_type VALUE '001', "#EC NEEDED
  gc_foc_caltype_002     TYPE reb_foc_cal_type VALUE '002', "#EC NEEDED
  gc_foc_caltype_003     TYPE reb_foc_cal_type VALUE '003'. "#EC NEEDED
