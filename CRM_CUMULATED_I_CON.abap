*----------------------------------------------------------------------*
*   INCLUDE CRM_CUMULATED_I_CON                                        *
*----------------------------------------------------------------------*
*   constant declarations for cumulated_i
*----------------------------------------------------------------------*

CONSTANTS: BEGIN OF gc_cum_type,
             cont_successor      TYPE crmt_cum_type VALUE '01',
             goods_issue         TYPE crmt_cum_type VALUE '02',
             quote_successor     TYPE crmt_cum_type VALUE '03',
             invoice             TYPE crmt_cum_type VALUE '04',
             delivery            TYPE crmt_cum_type VALUE '05',
             ipm_pp              TYPE crmt_cum_type VALUE '06',
             ipm_itd             TYPE crmt_cum_type VALUE '07',
             ipm_explo_frequ_std TYPE crmt_cum_type VALUE '11',
             ipm_explo_frequ_add TYPE crmt_cum_type VALUE '12',
             cont_successor_sync TYPE crmt_cum_type VALUE '13',
             vendor_invoice      TYPE crmt_cum_type VALUE '20',
             internal_to_bill    TYPE crmt_cum_type VALUE '30',
             internal_billed     TYPE crmt_cum_type VALUE '31',
             accommod_to_bill    TYPE crmt_cum_type VALUE '32',
             accommod_billed     TYPE crmt_cum_type VALUE '33',
             tcd_delivery        TYPE crmt_cum_type VALUE '34',
             grm_upd_claim       TYPE crmt_cum_type VALUE '60',
             grm_upd_bri         TYPE crmt_cum_type VALUE '61',
             cla_csr             TYPE crmt_cum_type value '70',
             cla_dc              TYPE crmt_cum_type value '71',
             cla_cb              TYPE crmt_cum_type value '72',
             cla_wo              TYPE crmt_cum_type value '73',
             cla_cop             TYPE crmt_cum_type value '74',
             cla_csd             TYPE crmt_cum_type value '75',
             settlement          TYPE crmt_cum_type value '76',
             cla_ccr             TYPE crmt_cum_type value '77',
             cla_csd_tax_diff    TYPE crmt_cum_type value '78',
             inspected_quantity  TYPE crmt_cum_type value '90',
           END OF gc_cum_type.

CONSTANTS: BEGIN OF gc_cum_type_temp,
             ipm_pp           TYPE crmt_cum_type VALUE '08'   ,
               ref_to_ipm_pp  TYPE crmt_cum_type VALUE    '06',
             ipm_itd          TYPE crmt_cum_type VALUE '09'   ,
               ref_to_ipm_itd TYPE crmt_cum_type VALUE    '06',
             cont_successor   TYPE crmt_cum_type VALUE '10'   ,
               ref_to_cont_s  TYPE crmt_cum_type VALUE    '01',
           END OF gc_cum_type_temp.

CONSTANTS: BEGIN OF gc_cum_rule,
             order_quan                   TYPE crmt_cum_rule VALUE '01',
             order_value                  TYPE crmt_cum_rule VALUE '02',
             quantity                     TYPE crmt_cum_rule VALUE '03',
             value                        TYPE crmt_cum_rule VALUE '04',
             grm_rel_value                TYPE crmt_cum_rule VALUE '60',
             grm_clr_value                TYPE crmt_cum_rule VALUE '61',
             grm_hbk_value                TYPE crmt_cum_rule VALUE '62',
             cla_claimed_amount           TYPE crmt_cum_rule VALUE '70',
             cla_validated_amount         TYPE crmt_cum_rule VALUE '71',
             cla_settled_amount           TYPE crmt_cum_rule VALUE '72',
             cla_cpp_item_consumed_amount TYPE crmt_cum_rule VALUE '73',
             cla_requested_amount         TYPE crmt_cum_rule VALUE '74',
             cla_rejected_amount          TYPE crmt_cum_rule VALUE '75',
             cla_released_exp_amount      TYPE crmt_cum_rule VALUE '76',
             cpp_remaining_amount         TYPE crmt_cum_rule VALUE '80',
             cla_chargeback_amount        TYPE crmt_cum_rule VALUE '86', "do not use anymore
             cla_fndbased_cb_amount       TYPE crmt_cum_rule VALUE '86',
             cla_prjbased_cb_amount       TYPE crmt_cum_rule VALUE '8E',
             cla_writeoff_amount          TYPE crmt_cum_rule VALUE '87',
             cla_carriedover_amount       TYPE crmt_cum_rule VALUE '88', "do not use anymore
             cla_cop_from_csd_amount      TYPE crmt_cum_rule VALUE '88',
             cla_cop_from_ccb_amount      TYPE crmt_cum_rule VALUE '8D',
             cla_unresolved_amount        TYPE crmt_cum_rule VALUE '89',
             cla_unresolved_tax_amount    TYPE crmt_cum_rule VALUE '8W', "CRM 7.0 EhP1 Claims Taxation
             cla_unassigned_amount        TYPE crmt_cum_rule VALUE '8U',
             cla_unassigned_tax_amount    TYPE crmt_cum_rule VALUE '8V', "CRM 7.0 EhP1 Claims Taxation
             cla_released_net_amount      TYPE crmt_cum_rule VALUE '8X', "CRM 7.0 EhP1 Claims Taxation
             cla_released_tax_amount      TYPE crmt_cum_rule VALUE '8Y', "CRM 7.0 EhP1 Claims Taxation
             cla_collectible_amount       TYPE crmt_cum_rule VALUE '8A',
             cla_uncollectible_amount     TYPE crmt_cum_rule VALUE '8B',
             cla_recovered_amount         TYPE crmt_cum_rule VALUE '8C',
             cla_original_amount          TYPE crmt_cum_rule VALUE '90',
             cla_disputed_amount          TYPE crmt_cum_rule VALUE '91',
             cla_paid_amount              TYPE crmt_cum_rule VALUE '92',
             cla_credited_amount          TYPE crmt_cum_rule VALUE '93',
             cla_manually_cleared_amount  TYPE crmt_cum_rule VALUE '94',
             cla_autom_written_off_amount TYPE crmt_cum_rule VALUE '95',
             cla_delta_paid_amount        TYPE crmt_cum_rule VALUE '96',
             cla_delta_credited_amount    TYPE crmt_cum_rule VALUE '97',
             cla_delta_man_cleared_amount TYPE crmt_cum_rule VALUE '98',
             cla_delta_written_off_amount TYPE crmt_cum_rule VALUE '99',
             cla_delta_original_amount    TYPE crmt_cum_rule VALUE '9B', "CRM 7.0 EhP1 Claims Taxation
             cla_cleared_amount           TYPE crmt_cum_rule VALUE '9A',
             cla_cal_net_tax              TYPE crmt_cum_rule VALUE '22',
             cla_cal_tax_tax              TYPE crmt_cum_rule VALUE '23',
             cla_cal_gross_tax            TYPE crmt_cum_rule VALUE '24',

           END OF gc_cum_rule.

CONSTANTS: gc_cum_type_ipm_use(17) TYPE c VALUE '06,07,08,09,11,12'.
