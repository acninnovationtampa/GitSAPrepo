*&---------------------------------------------------------------------*
*&  Include           BEA_ACC_CON                                      *
*&---------------------------------------------------------------------*
CONSTANTS:
  gc_acc_obj_type_bebd    TYPE awtyp                    VALUE 'BEBD'         ,
  gc_acc_obj_type_berd    TYPE awtyp                    VALUE 'BERD'         ,
  gc_acc_obj_type_bere    TYPE awtyp                    VALUE 'BERE'         ,
  gc_acc_paystat_unknown  TYPE bea_acc_payment_status   VALUE space          ,
  gc_acc_paystat_open     TYPE bea_acc_payment_status   VALUE 'A'            ,
  gc_acc_paystat_part     TYPE bea_acc_payment_status   VALUE 'B'            ,
  gc_acc_paystat_cleared  TYPE bea_acc_payment_status   VALUE 'C'            ,
  gc_acc_paystat_nothing  TYPE bea_acc_payment_status   VALUE 'D'            ,
  gc_trans_err_no         TYPE bea_transfer_error       VALUE ' '            ,
  gc_trans_err_else       TYPE bea_transfer_error       VALUE 'A'            ,
  gc_trans_err_orgunit    TYPE bea_transfer_error       VALUE 'B'            ,
  gc_trans_err_acctdet    TYPE bea_transfer_error       VALUE 'C'            ,
  gc_trans_err_acctkey    TYPE bea_transfer_error       VALUE 'D'            ,
  gc_trans_err_taxsign    TYPE bea_transfer_error       VALUE 'E'            ,
  gc_trans_err_paycard    TYPE bea_transfer_error       VALUE 'F'            ,
  gc_trans_err_oltp       TYPE bea_transfer_error       VALUE 'G'            ,
  gc_trans_err_doctype    TYPE bea_transfer_error       VALUE 'H'            ,
  gc_trans_err_locksrcdoc TYPE bea_transfer_error       VALUE 'I'            ,
  gc_trans_errors_pyp(2)  TYPE c                        VALUE 'FI'           ,
  gc_map_context_acc      TYPE bea_acc_map_context      VALUE ' '            ,
  gc_map_context_mmiv     TYPE bea_acc_map_context      VALUE 'A'            ,
  gc_map_context_fiap     TYPE bea_acc_map_context      VALUE 'B'            ,
  gc_map_context_cla      TYPE bea_acc_map_context      VALUE 'C'            ,
  gc_cla_inv_pp           TYPE acc_cla_control          VALUE 'A'            , "#EC *
  gc_acc_bus_act_rfbu     TYPE glvor                    VALUE 'RFBU'         ,
  gc_acc_bus_act_sd00     TYPE glvor                    VALUE 'SD00'         ,
  gc_acc_bus_act_rmrp     TYPE glvor                    VALUE 'RMRP'         .

CONSTANTS: BEGIN OF gc_nbe_scenarios,
             sales     TYPE acc_bus_scenario VALUE 'A',
             service   TYPE acc_bus_scenario VALUE 'B',
             financing TYPE acc_bus_scenario VALUE 'C',
             grantor   TYPE acc_bus_scenario VALUE 'D',
             funds     TYPE acc_bus_scenario VALUE 'E',
           END OF gc_nbe_scenarios.
