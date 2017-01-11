type-pool ctcus.

* fieldnames
constants:

  ctcus_client               type fieldname value 'CLIENT',
  ctcus_cnd_alv_celltab      type fieldname value 'CND_ALV_CELLTAB',
  ctcus_cond_group_id        type fieldname value 'COND_GROUP_ID',
  ctcus_created_by           type fieldname value 'CREATED_BY',
  ctcus_created_on           type fieldname value 'CREATED_ON',
  ctcus_date_from            type fieldname value 'DATE_FROM',
  ctcus_date_to              type fieldname value 'DATE_TO',
  ctcus_dbaction_supp        type fieldname value 'DBACTION_SUPP',
  ctcus_dbaction_tabl        type fieldname value 'DBACTION_TABL',
  ctcus_application          type fieldname value 'KAPPL',
  ctcus_supp_condition_id    type fieldname value 'KOPOS',
  ctcus_cond_table_id        type fieldname value 'KOTABNR',
  ctcus_cond_type            type fieldname value 'KSCHL',
  ctcus_cond_type_supp       type fieldname value 'KSCHL_SUPP',
  ctcus_usage                type fieldname value 'KVEWE',
  ctcus_scale_base_type_supp type fieldname value 'KZBZG',
  ctcus_maint_status         type fieldname value 'MAINT_STATUS',
  ctcus_maint_stat           type fieldname value 'MAINT_STAT',
  ctcus_ui_color_line        type fieldname value 'MNT_UI_COLOR_LINE',
  ctcus_exists_at_db         type fieldname
                             value 'MNT_OW_EXISTS_AT_DB',
  ctcus_maint_mode_on_select type fieldname
                             value 'MNT_OW_MAINT_MODE_ON_SELECT',
  ctcus_error_by_cond_rec    type fieldname
                             value 'MNT_OW_ERROR_BY_COND_REC',
  ctcus_error_by_relation    type fieldname
                             value 'MNT_OW_ERROR_BY_RELATION',
  ctcus_result               type fieldname
                             value 'MNT_OW_RESULT',
  ctcus_is_archived          type fieldname
                             value '/SAPCND/MNT_IS_ARCHIVED',
  ctcus_cond_rec_status      type fieldname
                             value 'MNT_UI_COND_REC_STATUS',
  ctcus_cond_type_line       type fieldname
                             value 'MNT_UI_IS_COND_TYPE_LINE',
  ctcus_is_initial_line      type fieldname
                             value 'MNT_UI_IS_INITIAL_LINE',
  ctcus_is_deleted_icon      type fieldname
                             value 'MNT_UI_IS_DELETED_ICON',
  ctcus_scale_exist          type fieldname
                             value 'MNT_UI_SCALE_EXIST',
  ctcus_object_id            type fieldname value 'OBJECT_ID',
  ctcus_release_status       type fieldname value 'RELEASE_STATUS',
  ctcus_release_stat         type fieldname value 'RELEASE_STAT',
  ctcus_scale_dim            type fieldname value 'SCALE_DIM',
  ctcus_scale_type_supp      type fieldname value 'STFKZ',
  ctcus_supp_exist           type fieldname value 'SUPP_EXIST',
  ctcus_timestamp_from       type fieldname value 'TIMESTAMP_FROM',
  ctcus_timestamp_to         type fieldname value 'TIMESTAMP_TO',
  ctcus_time_from            type fieldname value 'TIME_FROM',
  ctcus_time_to              type fieldname value 'TIME_TO',
  ctcus_time_zone            type fieldname value 'TIME_ZONE',
  ctcus_varnumh              type fieldname value 'VARNUMH',
  ctcus_dim_id               type fieldname value 'DIM_ID',
  ctcus_dbaction             type fieldname value 'DBACTION',
  ctcus_scale_id             type fieldname value 'SCALE_ID',
  ctcus_scale_line_id        type fieldname value 'SCALE_LINE_ID',
  ctcus_eval_type            type fieldname value 'EVAL_TYPE',
  ctcus_scale_type           type fieldname value 'SCALE_TYPE',
  ctcus_scale_base_type      type fieldname value 'SCALE_BASE_TYPE',
  ctcus_line_fcat            type fieldname value 'MNT_IL_LINE_FCAT',
  ctcus_def_timestamp        type fieldname value
                                  'DET_DEFAULT_TIMESTAMP'.
* rollnames
constants:
  ctcus_roll_usage           type rollname  value '/SAPCND/USAGE',
  ctcus_roll_application     type rollname  value '/SAPCND/APPLICATION',
  ctcus_roll_cond_table_id   type rollname  value
                                              '/SAPCND/COND_TABLE_ID',
  ctcus_roll_cond_type       type rollname  value '/SAPCND/COND_TYPE',
  ctcus_roll_supp_exist      type rollname  value '/SAPCND/DIMENSION_ID'
.
* fieldnames of /SAPCND/T688C
constants:
  ctcus_attribute_type       type fieldname value 'ATTRIBUTE_TYPE',
  ctcus_is_external          type fieldname value 'IS_EXTERNAL',
  ctcus_fieldname            type fieldname value 'FIELDNAME'.

* parameters names that reflect global settings
constants:
  ctcus_procstage_correction     type /sapcnd/processing_stage
                                 value 'B',
  ctcus_procstage_generation     type /sapcnd/processing_stage
                                 value 'C',
  ctcus_procstage_general_msgs   type /sapcnd/processing_stage
                                 value 'D',
  ctcus_procstage_gen_access     type /sapcnd/processing_stage
                                 value 'F',
  ctcus_fieldname_vakey          type /sapcnd/param_name
                                 value 'FIELDNAME_VAKEY',
  ctcus_fieldname_vadat          type /sapcnd/param_name
                                 value 'FIELDNAME_VADAT',
  ctcus_fieldname_scale_value    type /sapcnd/param_name
                                 value 'FIELDNAME_SCALE_VALUE',
  ctcus_fieldname_scale_line_id  type /sapcnd/param_name
                                 value 'FIELDNAME_SCALE_LINE_ID',
  ctcus_fieldname_scale_unit     type /sapcnd/param_name
                                 value 'FIELDNAME_SCALE_UNIT',
  ctcus_fieldname_scale_currency type /sapcnd/param_name
                                 value 'FIELDNAME_SCALE_CURRENCY',
  ctcus_fieldname_scale_amount   type /sapcnd/param_name
                                 value 'FIELDNAME_SCALE_AMOUNT',
  ctcus_fieldname_evaluation     type /sapcnd/param_name
                                 value 'FIELDNAME_EVALUATION',
  ctcus_fieldname_eval_type      type /sapcnd/param_name
                                 value 'FIELDNAME_EVAL_TYPE',
  ctcus_template_tabl            type /sapcnd/param_name
                                 value 'STR_TEMPLATE_TABL',
  ctcus_template_tabl_key        type /sapcnd/param_name
                                 value 'STR_TEMPLATE_TABL_KEY',
  ctcus_template_supp            type /sapcnd/param_name
                                 value 'STR_TEMPLATE_SUPP',
  ctcus_template_supp_key        type /sapcnd/param_name
                                 value 'STR_TEMPLATE_SUPP_KEY',
  ctcus_template_scale_dim       type /sapcnd/param_name
                                 value 'TEMPLATE_SCALE_DIM',
  ctcus_template_scale_val       type /sapcnd/param_name
                                 value 'TEMPLATE_SCALE_VAL',
  ctcus_template_scale_lin       type /sapcnd/param_name
                                 value 'TEMPLATE_SCALE_LIN',
  ctcus_template_scale_def       type /sapcnd/param_name
                                 value 'TEMPLATE_SCALE_DEF',
  ctcus_template_scale_evl       type /sapcnd/param_name
                                 value 'TEMPLATE_SCALE_EVL',
  ctcus_sec_condition_tabl_index type /sapcnd/param_name
                                 value 'SEC_CONDITION_TABL_INDEX',
  ctcus_gesta_tabl_generated     type /sapcnd/param_name
                                 value 'GESTA_TABL_GENERATED',
  ctcus_gesta_secindx_generated  type /sapcnd/param_name
                                 value 'GESTA_SECINDX_GENERATED',
  ctcus_gesta_tabl_activated     type /sapcnd/param_name
                                 value 'GESTA_TABL_ACTIVATED',
  ctcus_gesta_acsview_generated  type /sapcnd/param_name
                                 value 'GESTA_ACSVIEW_GENERATED',
  ctcus_gesta_report_generated   type /sapcnd/param_name
                                 value 'GESTA_REPORT_GENERATED',
  ctcus_gesta_dynpro_generated   type /sapcnd/param_name
                                 value 'GESTA_DYNPRO_GENERATED',
  ctcus_gesta_highest            type /sapcnd/param_name
                                 value 'GESTA_HIGHEST',
  ctcus_global_prefix_bdoc       type /sapcnd/param_name
                                 value 'GLOBAL_PREFIX_BDOC',
  ctcus_global_prefix            type /sapcnd/param_name
                                 value 'GLOBAL_PREFIX',
  ctcus_emulate_old_data_model   type /sapcnd/param_name
                                 value 'EMULATE_OLD_DATA_MODEL',
  ctcus_xpra_regen_everything    type /sapcnd/param_name
                                 value 'VERSION_XPRA_REGEN_EVERYTHING',
  ctcus_max_dim_xpra_executed    type /sapcnd/param_name
                                 value 'MAX_DIM_XPRA_EXECUTED',
  ctcus_version_guid_meta_object type /sapcnd/param_name
                                 value 'VERSION_GUID_META_OBJECT',
  ctcus_delete_ctaf_tadir        type /sapcnd/param_name
                                 value 'DELETE_CTAF_TADIR',
  ctcus_clean_up_cache           type /sapcnd/param_name
                                 value 'CLEAN_UP_CACHE',
  ctcus_regen_std_table          type /sapcnd/param_name
                                 value 'REGEN_STD_TABLE',

* values
ctcus_true            type /sapcnd/boolean value 'X',
ctcus_false           type /sapcnd/boolean value ' ',
ctcus_data_origin_r3  type /sapcnd/data_origin value 'A',
ctcus_data_origin_crm type /sapcnd/data_origin value 'B',
ctcus_quote           type c                   value '''',
ctcus_and             type txline              value 'AND',
ctcus_or              type txline              value 'OR',

* names for possible is_virtual-values

* use logical combinations with these values with extreme care
* avoid e.g. the following coding:
* if ls_t681ff-is_virtual = ctcus_virt_external_internal
* or ls_t681ff-is_virtual = ctcus_virt_pure_external

* for logical combinations, use multi-valued constants below
* use e.g. the following coding:
* if ls_t681ff-is_virtual = ctcus_virt_ext_not_ui

* when introducing a new is_virtual constant, the multi-valued constants
* and potentially all places where single value constants
* are still used, have to be adapted
ctcus_virt_pure_internal     type /sapcnd/t681ff_s-is_virtual value 'A',
ctcus_virt_pure_external     type /sapcnd/t681ff_s-is_virtual value 'B',
ctcus_virt_external_internal type /sapcnd/t681ff_s-is_virtual value 'C',
ctcus_virt_pure_access       type /sapcnd/t681ff_s-is_virtual value 'D',
ctcus_virt_ext_int_not_ui    type /sapcnd/t681ff_s-is_virtual value 'E',
ctcus_virt_ext_int_not_ui_db type /sapcnd/t681ff_s-is_virtual value 'F',
ctcus_virt_pure_int_not_db   type /sapcnd/t681ff_s-is_virtual value 'G',
ctcus_virt_ext_int_not_db    type /sapcnd/t681ff_s-is_virtual value 'H',

* all external fields
ctcus_virt_ext(5)        type c value 'BCEFH',

* all external fields in UI
ctcus_virt_ext_ui(3)     type c value 'BCH',

* all internal fields
ctcus_virt_int(7)        type c value 'ACDEFGH',

* all db-fields
ctcus_virt_db(3)         type c value 'ACE',

* all int AND ext fields
ctcus_virt_int_or_ext(4) type c value 'CEFH',

* all fields that have dependencies, or are dependent
ctcus_virt_int_dep(6)    type c value 'ACEFGH',

* attribute types
ctcus_attr_appl  type /sapcnd/attribute_type value 'A',
ctcus_attr_usage type /sapcnd/attribute_type value 'B',
ctcus_attr_cond  type /sapcnd/attribute_type value 'C',

* used for selection constants
ctcus_free_selection  type /sapcnd/used_for_selection value 'A',
ctcus_single_value    type /sapcnd/used_for_selection value 'B',
ctcus_value_operator  type /sapcnd/used_for_selection value 'C',
ctcus_no_selection    type /sapcnd/used_for_selection value 'D',
ctcus_ddic_selection  type /sapcnd/used_for_selection value 'E',

ctcus_selection_all(5) type c value 'ABCDE',

* abap memory constants
ctcus_mem_dd04v            type char30
                           value '/SAPCND/DD04V',

* gen results
ctcus_genresult_success type sysubrc value 0,
ctcus_genresult_warning type sysubrc value 4,
ctcus_genresult_error   type sysubrc value 8,

* results
ctcus_result_success type sysubrc value 0,
ctcus_result_warning type sysubrc value 4,
ctcus_result_error   type sysubrc value 8,

* read status
ctcus_object_state_active   type ddobjstate value 'A',
ctcus_object_state_inactive type ddobjstate value ' ',

* generated objects info
ctcus_gen_obj_info_all          type /sapcnd/gen_object_info value ' ',
ctcus_gen_obj_info_badi         type /sapcnd/gen_object_info value '1',
ctcus_gen_obj_info_cli_indep    type /sapcnd/gen_object_info value '2',
ctcus_gen_obj_info_none         type /sapcnd/gen_object_info value '3',

* generation status on the fly
ctcus_gen_status_fly_success type /sapcnd/gen_status_on_the_fly value '2',
ctcus_gen_status_fly_fail    type /sapcnd/gen_status_on_the_fly value '1',
ctcus_gen_status_fly_unknown type /sapcnd/gen_status_on_the_fly value ' ',

* object validity
ctcus_validity_activated type as4local value 'A',
ctcus_validity_inactive  type as4local value ' ',

* field visibility
ctcus_field_vis_always      type /sapcnd/field_visibility value ' ',
ctcus_field_vis_not_initial type /sapcnd/field_visibility value 'A',
ctcus_field_vis_never       type /sapcnd/field_visibility value 'B',
ctcus_field_vis_no_out      type /sapcnd/field_visibility value 'C',

** Namespaces for transport (condition tables)
ctcus_sap_namespace           type c        value 'A',
ctcus_customer_namespace      type c        value 'Z',

** Condition record transport flags
ctcus_trnflag_a               type /sapcnd/cond_rec_trnflag value 'A',
ctcus_trnflag_z               type /sapcnd/cond_rec_trnflag value 'Z',

** Prefixes for table numbers (condition tables)
ctcus_customer_table_prefix   type char3    value 'CUS',
ctcus_sap_table_prefix        type char3    value 'SAP',

*  System id SAP
ctcus_sysid_sap               type sysysid  value 'SAP',

* Dummy trkorr used in after import step
ctcus_dummy_request          type /sapcnd/trn_request value '___DUMMY_',

ctcus_condref_yes             type /sapcnd/cond_group_id
                              value '4DFAE50228082341AB708AE484AF8683',
ctcus_param_default_devclass  type /sapcnd/param_name
                              value 'DEF_DEVCLASS_FOR_R3_OBJECTS',

* program ID, objects, and objfunc in e071
ctcus_pgmid_r3tr              type pgmid      value 'R3TR',
ctcus_pgmid_limu              type pgmid      value 'LIMU',
ctcus_table                   type trobjtype  value 'TABL',
ctcus_devclass_local          type devclass   value '$TMP',
ctcus_otype_tdat              type trobjtype  value 'TDAT',
ctcus_otype_cdat              type trobjtype  value 'CDAT',
ctcus_otype_vdat              type trobjtype  value 'VDAT',
ctcus_otype_tabu              type trobjtype  value 'TABU',
ctcus_objfunc_key             type c          value 'K',
ctcus_otype_adir              type trobjtype  value 'ADIR',


* logical transport objects: objects in e071
ctcus_object_cond_table       type trobjtype value 'CTCT',
ctcus_object_maint_context    type trobjtype value 'CTMC',
ctcus_object_ref_type         type trobjtype value 'CTRF',
ctcus_object_dd_pattern       type trobjtype value 'CTDD',
ctcus_object_application      type trobjtype value 'CTAP',
ctcus_object_usage            type trobjtype value 'CTUS',
ctcus_object_usg_fl           type trobjtype value 'CTUF',
ctcus_object_scale_base       type trobjtype value 'CTSB',
ctcus_object_task_sign        type trobjtype value 'CTTK',
ctcus_object_task_def         type trobjtype value 'CTTS',
ctcus_object_appl_field       type trobjtype value 'CTAF',
ctcus_object_fieldname        type trobjtype value 'CTFF',
ctcus_object_data_element     type trobjtype value 'CTFD',
ctcus_object_field_relation   type trobjtype value 'CTFR',
ctcus_object_dtel_dependency  type trobjtype value 'CTFP',


* object names in e071
ctcus_oname_condr             type sobj_name
                              value '/SAPCND/CONDITION_RECORDS',
ctcus_condrecs                type tabname  value '/SAPCND/CONDRECS',
ctcus_maint_group             type sobj_name value '/SAPCND/VC_GROUP',
ctcus_config_view             type sobj_name value '/SAPCND/V_CONFIG',
ctcus_configcc_view           type sobj_name value '/SAPCND/V_CFGCC',


* bal objects and bal subobjects
ctcus_bal_object              type bal_s_log-object
                              value 'COND_TECHNIQUE',
ctcus_bal_subobj_transport    type bal_s_log-subobject
                              value 'TRANSPORT', "transport of records!!
ctcus_bal_subobj_group        type bal_s_log-subobject
                              value 'GROUP_GEN',
ctcus_bal_subobj_outdated     type bal_s_log-subobject
                              value 'OUTDATED_OBJECTS',
ctcus_bal_subobj_task         type bal_s_log-subobject
                              value 'TASK',
ctcus_bal_subobj_usage        type bal_s_log-subobject
                              value 'USAGE',
ctcus_bal_subobj_ct           type bal_s_log-subobject
                              value 'CT',
ctcus_bal_subobj_cond_table   type bal_s_log-subobject
                              value 'COND_TABLE',
ctcus_bal_subobj_field_cat    type bal_s_log-subobject
                              value 'FIELD_CATALOGUE',
ctcus_bal_subobj_regen_appl   type bal_s_log-subobject
                              value 'REGEN_APPL',
ctcus_bal_subobj_application  type bal_s_log-subobject
                              value 'APPLICATION',
ctcus_bal_subobj_masterdata   type bal_s_log-subobject
                              value 'MASTERDATA_CREATE',

* type of the sub communication structures
ctcus_sub_com_head            type /sapcnd/comm_sub_str_type value 'H',
ctcus_sub_com_item            type /sapcnd/comm_sub_str_type value 'I',
ctcus_sub_com_mixed           type /sapcnd/comm_sub_str_type value 'M',
ctcus_sub_com_initial         type /sapcnd/comm_sub_str_type
                                   value ' ',              "all fields

* Engine types
ctcus_engine_type_abap        type /sapcnd/det_engine_type   value 'A',
ctcus_engine_type_java        type /sapcnd/det_engine_type   value 'B',

* standard time zone UTC
ctcus_timezone_utc            type tznzone value 'UTC',

* access types
ctcus_fixed_key               type /sapcnd/access_field_type value ' ',
ctcus_key_no_search           type /sapcnd/access_field_type value 'b',
ctcus_hier_access             type /sapcnd/access_field_type value 'A',
ctcus_free_key                type /sapcnd/access_field_type value 'B',
ctcus_vadat                   type /sapcnd/access_field_type value 'C',
ctcus_access_type_free        type char2 value 'AC',
ctcus_access_type_bound       type char2 value ' B',
ctcus_nosel                   type char2 value 'BC',
ctcus_standard_access_types   type char3 value ' bA',

* implementation types
ctcus_maint_badi              type /sapcnd/maint_impl_type value ' ',
ctcus_maint_generic           type /sapcnd/maint_impl_type value '1',
ctcus_maint_attr_generic      type /sapcnd/maint_impl_type value '2',
ctcus_maint_int_generic       type /sapcnd/maint_impl_type value '6',

* userexit types
ctcus_ue_requirement          type /sapcnd/userexit_type value 'REQ',

* runtime scaling
ctcus_runtime_scaling         type i value 1000.
