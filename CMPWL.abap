TYPE-POOL cmpwl.

TYPES: cmpwl_const2_type(2) TYPE c.

TYPES: BEGIN OF cmpwl_s_address_type,
         pointer_local LIKE addr1_sel-addrnumber,
         pointer_remote LIKE addr1_sel-addrnumber,
         handle_local LIKE addr1_sel-addrhandle,
         compare_result TYPE c,
         index LIKE sy-tabix,
         namtab_index like sy-tabix,
       END OF cmpwl_s_address_type.
TYPES: cmpwl_t_address_type TYPE cmpwl_s_address_type OCCURS 0.


TYPES: BEGIN OF cmpwl_s_cmpwl_type.
        INCLUDE STRUCTURE cmpwl.
TYPES:   mark_adj TYPE c,
         mark_cmp TYPE c,
         mark_imp TYPE c.
TYPES: END OF cmpwl_s_cmpwl_type.
TYPES: cmpwl_t_cmpwl_type TYPE cmpwl_s_cmpwl_type OCCURS 0.

TYPES: cmpwl_s_cmpwlh_type LIKE cmpwlh.
TYPES: cmpwl_t_cmpwlh_type TYPE cmpwl_s_cmpwlh_type OCCURS 0.

TYPES: cmpwl_s_cmpwlimp_type LIKE cmpwlimp.
TYPES: cmpwl_t_cmpwlimp_type TYPE cmpwl_s_cmpwlimp_type OCCURS 0.

TYPES: cmpwl_s_cmpwlk_type LIKE cmpwlk.
TYPES: cmpwl_t_cmpwlk_type TYPE cmpwl_s_cmpwlk_type OCCURS 0.

TYPES: BEGIN OF cmpwl_s_msg_type,
         msgid LIKE sy-msgid,
         msgty LIKE sy-msgty,
         msgno LIKE sy-msgno,
         msgv1 LIKE sy-msgv1,
         msgv2 LIKE sy-msgv2,
         msgv3 LIKE sy-msgv3,
         msgv4 LIKE sy-msgv4,
       END OF cmpwl_s_msg_type.

TYPES: BEGIN OF cmpwl_system_info_type,
         rfc_dest LIKE rfcdes-rfcdest,
         code_page_local LIKE tcp00-cpcodepage,
         code_page_remote LIKE tcp00-cpcodepage,
         endian_check_number_local LIKE tcp00-cpcodepage,
         endian_check_number_remote LIKE tcp00-cpcodepage,
         langu_local LIKE sy-langu,
         langu_remote LIKE sy-langu,
         system_name_local LIKE sy-sysid,
         system_name_remote LIKE sy-sysid,
         sap_release_local LIKE sy-saprl,
         sap_release_remote LIKE sy-saprl,
         client_local LIKE sy-mandt,
         client_remote LIKE sy-mandt,
         t000_local LIKE t000_rfc,
         t000_remote LIKE t000_rfc,
         user_name_local LIKE sy-uname,
         user_name_remote LIKE sy-uname,
       END OF cmpwl_system_info_type.

TYPES: BEGIN OF cmpwl_s_except_type.
        INCLUDE STRUCTURE cmpwlec.
TYPES:   mark TYPE c.
TYPES:   delete TYPE c.
TYPES:   index LIKE sy-tabix.
TYPES: END OF cmpwl_s_except_type.
TYPES: cmpwl_t_except_type TYPE cmpwl_s_except_type OCCURS 0.

TYPES: BEGIN OF cmpwl_s_except_sap_type.
        INCLUDE STRUCTURE cmpwle.
TYPES:  mark TYPE c.
TYPES: END OF cmpwl_s_except_sap_type.
TYPES: cmpwl_t_except_sap_type TYPE cmpwl_s_except_sap_type OCCURS 0.

************************************************************************
* state of work list                                                   *
************************************************************************
CONSTANTS:
  cmpwl_state_creating_header      LIKE cmpwlh-state VALUE 'H',
  cmpwl_state_scheduled_for_crt    LIKE cmpwlh-state VALUE 'b',
  cmpwl_state_creating             LIKE cmpwlh-state VALUE 'B',
  cmpwl_state_crt_terminated       LIKE cmpwlh-state VALUE 'W',
  cmpwl_state_open                 LIKE cmpwlh-state VALUE 'O',
  cmpwl_state_scheduled_for_cmp    LIKE cmpwlh-state VALUE 'c',
  cmpwl_state_comparing            LIKE cmpwlh-state VALUE 'C',
  cmpwl_state_cmp_terminated       LIKE cmpwlh-state VALUE 'X',
  cmpwl_state_scheduled_for_imp    LIKE cmpwlh-state VALUE 'i',
  cmpwl_state_importing            LIKE cmpwlh-state VALUE 'I',
  cmpwl_state_imp_terminated       LIKE cmpwlh-state VALUE 'Y',
  cmpwl_state_adjusting            LIKE cmpwlh-state VALUE 'A',
  cmpwl_state_adj_terminated       LIKE cmpwlh-state VALUE 'Z',
  cmpwl_state_closed               LIKE cmpwlh-state VALUE 'L'.

************************************************************************
* kind of work list                                                    *
************************************************************************
CONSTANTS:
  cmpwl_kind_transport_request    LIKE cmpwlh-kind VALUE 'R',
  cmpwl_kind_parts_list           LIKE cmpwlh-kind VALUE 'L',
  cmpwl_kind_cust_template        LIKE cmpwlh-kind VALUE 'T',
  cmpwl_kind_app_comp             LIKE cmpwlh-kind VALUE 'A',
  cmpwl_kind_project_img          LIKE cmpwlh-kind VALUE 'P',
  cmpwl_kind_project_img_mark     LIKE cmpwlh-kind VALUE 'Q',
  cmpwl_kind_project_img_view     LIKE cmpwlh-kind VALUE 'V',
  cmpwl_kind_project_img_views    LIKE cmpwlh-kind VALUE 'W',
  cmpwl_kind_enterprise_img       LIKE cmpwlh-kind VALUE 'E',
  cmpwl_kind_enterprise_img_mark  LIKE cmpwlh-kind VALUE 'F',
  cmpwl_kind_reference_img        LIKE cmpwlh-kind VALUE 'I',
  cmpwl_kind_ale_group            LIKE cmpwlh-kind VALUE 'G',
  cmpwl_kind_manual_selection     LIKE cmpwlh-kind VALUE 'M'.

************************************************************************
* import status                                                        *
************************************************************************
CONSTANTS:
  cmpwl_imp_not_importable       LIKE cmpwl-impstatus VALUE 'X',
  cmpwl_imp_not_selected_for_imp LIKE cmpwl-impstatus VALUE 'N',
  cmpwl_imp_selected_for_import  LIKE cmpwl-impstatus VALUE 'S',
  cmpwl_imp_executing_import     LIKE cmpwl-impstatus VALUE 'E',
  cmpwl_imp_imported_ok          LIKE cmpwl-impstatus VALUE 'O',
  cmpwl_imp_imported_failure     LIKE cmpwl-impstatus VALUE 'F',
  cmpwl_imp_terminated           LIKE cmpwl-impstatus VALUE 'A'.
************************************************************************
* adjust status                                                        *
************************************************************************
CONSTANTS:
  cmpwl_adj_init      LIKE cmpwl-adjstatus VALUE 'I',
  cmpwl_adj_open      LIKE cmpwl-adjstatus VALUE 'O',
  cmpwl_adj_closed    LIKE cmpwl-adjstatus VALUE 'L'.

************************************************************************
* compare status       (=rscmptp1)                                     *
************************************************************************
CONSTANTS:
  cmpwl_cmp_terminated               LIKE cmpwl-cmpstatus VALUE 'XX',
  cmpwl_cmp_initial                  LIKE cmpwl-cmpstatus VALUE '00',
  cmpwl_cmp_not_found_local          LIKE cmpwl-cmpstatus VALUE '01',
  cmpwl_cmp_no_fields_local          LIKE cmpwl-cmpstatus VALUE '02',
  cmpwl_cmp_not_active_local         LIKE cmpwl-cmpstatus VALUE '03',
  cmpwl_cmp_no_tvdir_entry_local     LIKE cmpwl-cmpstatus VALUE '04',
  cmpwl_cmp_view_too_wide_local      LIKE cmpwl-cmpstatus VALUE '05',
  cmpwl_cmp_no_auth_local            LIKE cmpwl-cmpstatus VALUE '06',
  cmpwl_cmp_auth_s_tabu_cli_loc      LIKE cmpwl-cmpstatus VALUE '42',
  cmpwl_cmp_auth_s_tabu_dis_loc      LIKE cmpwl-cmpstatus VALUE '43',

  cmpwl_cmp_no_vmaint_tool_local     LIKE cmpwl-cmpstatus VALUE '07',
  cmpwl_cmp_read_error_local         LIKE cmpwl-cmpstatus VALUE '08',
  cmpwl_cmp_compress_error_local     LIKE cmpwl-cmpstatus VALUE '09',
  cmpwl_cmp_decompress_error_loc     LIKE cmpwl-cmpstatus VALUE '10',
  cmpwl_cmp_not_found_remote         LIKE cmpwl-cmpstatus VALUE '11',
  cmpwl_cmp_no_fields_remote         LIKE cmpwl-cmpstatus VALUE '12',
  cmpwl_cmp_not_active_remote        LIKE cmpwl-cmpstatus VALUE '13',
  cmpwl_cmp_no_tvdir_entr_remote     LIKE cmpwl-cmpstatus VALUE '14',
  cmpwl_cmp_view_too_wide_remote     LIKE cmpwl-cmpstatus VALUE '15',
  cmpwl_cmp_no_auth_remote           LIKE cmpwl-cmpstatus VALUE '16',
  cmpwl_cmp_auth_s_tab_cli_remot     LIKE cmpwl-cmpstatus VALUE '45',
  cmpwl_cmp_auth_s_tab_dis_remot     LIKE cmpwl-cmpstatus VALUE '46',

  cmpwl_cmp_no_vmaint_tool_remot     LIKE cmpwl-cmpstatus VALUE '17',
  cmpwl_cmp_read_error_remote        LIKE cmpwl-cmpstatus VALUE '18',
  cmpwl_cmp_compress_error_remot     LIKE cmpwl-cmpstatus VALUE '19',
  cmpwl_cmp_decompr_error_remote     LIKE cmpwl-cmpstatus VALUE '20',
  cmpwl_cmp_comm_failure             LIKE cmpwl-cmpstatus VALUE '21',
  cmpwl_cmp_system_failure           LIKE cmpwl-cmpstatus VALUE '22',
  cmpwl_cmp_keys_must_be_cmpared     LIKE cmpwl-cmpstatus VALUE '23',
  cmpwl_cmp_key_struct_not_conv      LIKE cmpwl-cmpstatus VALUE '24',
  cmpwl_cmp_field_struc_not_conv     LIKE cmpwl-cmpstatus VALUE '25',
  cmpwl_cmp_rfc_dest_not_found       LIKE cmpwl-cmpstatus VALUE '26',
  cmpwl_cmp_canceled                 LIKE cmpwl-cmpstatus VALUE '27',
  cmpwl_cmp_different_langu          LIKE cmpwl-cmpstatus VALUE '28',
  cmpwl_cmp_cliindep_same_system     LIKE cmpwl-cmpstatus VALUE '29',
  cmpwl_cmp_no_sm30_view             LIKE cmpwl-cmpstatus VALUE '40',
  cmpwl_cmp_systab                   LIKE cmpwl-cmpstatus VALUE '41',
  cmpwl_cmp_restricted_equal         LIKE cmpwl-cmpstatus VALUE 'S',
  cmpwl_cmp_restricted_equal_pro     LIKE cmpwl-cmpstatus VALUE 'Q',
  cmpwl_cmp_equal                    LIKE cmpwl-cmpstatus VALUE 'E',
  cmpwl_cmp_non_equal                LIKE cmpwl-cmpstatus VALUE 'N',
  cmpwl_cmp_non_equal_prop           LIKE cmpwl-cmpstatus VALUE 'P',
  cmpwl_cmp_restricted_equal_sd      LIKE cmpwl-cmpstatus VALUE 'SS',
  cmpwl_cmp_equal_sd                 LIKE cmpwl-cmpstatus VALUE 'SE',
  cmpwl_cmp_non_equal_sd             LIKE cmpwl-cmpstatus VALUE 'SN',
  cmpwl_cmp_non_equal_prop_sd        LIKE cmpwl-cmpstatus VALUE 'SP',
  cmpwl_cmp_excepted                 LIKE cmpwl-cmpstatus VALUE '47',
  cmpwl_cmp_no_transl_cmp            LIKE cmpwl-cmpstatus VALUE '48',
  cmpwl_cmp_no_compare               LIKE cmpwl-cmpstatus VALUE '49',
  cmpwl_cmp_no_e071k_entry           LIKE cmpwl-cmpstatus VALUE '50',
  cmpwl_cmp_selected_for_cmp         LIKE cmpwl-cmpstatus VALUE 'XS',
  cmpwl_cmp_executing_comparison     LIKE cmpwl-cmpstatus VALUE 'XE',
  cmpwl_cmp_not_selected_for_cmp     LIKE cmpwl-cmpstatus VALUE 'XN'.

************************************************************************
* return codes   (=rscmptp1)                                           *
************************************************************************
CONSTANTS:
  cmpwl_rc_okay                      TYPE cmpwl_const2_type VALUE '00',
  cmpwl_rc_internal_error            TYPE cmpwl_const2_type VALUE '63',
  cmpwl_rc_foreign_lock              TYPE cmpwl_const2_type VALUE '64',
  cmpwl_rc_lock_error                TYPE cmpwl_const2_type VALUE '65',
  cmpwl_rc_wrong_logon_client        TYPE cmpwl_const2_type VALUE '66'.

************************************************************************
* compare level                                                        *
************************************************************************
CONSTANTS:
  cmpwl_cl_object                LIKE cmpwl-cmplevel VALUE 'O',
  cmpwl_cl_table                 LIKE cmpwl-cmplevel VALUE 'T',
  cmpwl_cl_subobject             LIKE cmpwl-cmplevel VALUE 'V',
  cmpwl_cl_no_compare            LIKE cmpwl-cmplevel VALUE 'N',
  cmpwl_cl_table_merged          LIKE cmpwl-cmplevel VALUE 'M',
  cmpwl_cl_not_specified         LIKE cmpwl-cmplevel VALUE 'X'.

************************************************************************
* comparable                                                           *
************************************************************************
CONSTANTS:
  cmpwl_comparable               LIKE cmpwl-comparable VALUE 'X',
  cmpwl_not_comparable           LIKE cmpwl-comparable VALUE ' '.

************************************************************************
* compare exceptions                                                   *
************************************************************************
CONSTANTS:
  cmpwl_except_no_compare        LIKE cmpwle-exptkind VALUE 'N',
  cmpwl_except_no_field_compare  LIKE cmpwle-exptkind VALUE 'F',
  cmpwl_except_table_compare     LIKE cmpwle-exptkind VALUE 'T'.

************************************************************************
* compare/import actions                                               *
************************************************************************
CONSTANTS:
  cmpwl_object_compare           TYPE c VALUE 'C',
  cmpwl_mass_compare             TYPE c VALUE 'M',
  cmpwl_interactive_transfer     TYPE c VALUE 'I',
  cmpwl_automatic_transfer       TYPE c VALUE 'A'.

************************************************************************
* address adjustment                                                   *
************************************************************************
CONSTANTS:
  cmpwl_addr_adjusted LIKE addr1_sel-addrnumber VALUE '@ADJUSTED@'.
