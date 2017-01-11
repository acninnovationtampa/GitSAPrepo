*&---------------------------------------------------------------------*
*&  Include           BEA_CLASS_F1_CON
*&---------------------------------------------------------------------*

* Please, sort alphabetically by the TYPE!

CONSTANTS:
  gc_cond_split_false    TYPE bea_condition_split VALUE ' '            , "#EC *
  gc_cond_split_true     TYPE bea_condition_split VALUE 'A'            , "#EC *
  gc_cond_split_drv      TYPE bea_condition_split VALUE 'B'            , "#EC *
  gc_cond_split_ref_a    TYPE bea_condition_split VALUE 'C'            , "#EC *
  gc_cond_split_ref_b    TYPE bea_condition_split VALUE 'D'            , "#EC *
  gc_deriv_origin        TYPE bea_deriv_category  VALUE ' '            , "#EC *
  gc_deriv_orgdata       TYPE bea_deriv_category  VALUE 'A'            , "#EC *
  gc_deriv_periods       TYPE bea_deriv_category  VALUE 'B'            , "#EC *
  gc_deriv_partner       TYPE bea_deriv_category  VALUE 'C'            , "#EC *
  gc_deriv_condition     TYPE bea_deriv_category  VALUE 'D'            , "#EC *
  gc_deriv_retrobill     TYPE bea_deriv_category  VALUE 'E'            , "#EC *
  gc_deriv_leanbilling   TYPE bea_deriv_category  VALUE 'G'            , "#EC *
  gc_icv_status_not_rel	 TYPE bea_icv_status      VALUE ' '            , "#EC *
  gc_icv_status_blocked  TYPE bea_icv_status      VALUE 'A'            , "#EC *
  gc_icv_status_todo     TYPE bea_icv_status      VALUE 'B'            , "#EC *
  gc_icv_status_in_work  TYPE bea_icv_status      VALUE 'C'            , "#EC *
  gc_icv_status_done     TYPE bea_icv_status      VALUE 'D'            , "#EC *
  gc_icv_status_error    TYPE bea_icv_status      VALUE 'E'            , "#EC *
  gc_icv_status_canceled TYPE bea_icv_status      VALUE 'F'            , "#EC *
  gc_deriv_ic_no         TYPE bea_indicator_ic    VALUE ' '            , "#EC *
  gc_deriv_ic_yes        TYPE bea_indicator_ic    VALUE 'X'            , "#EC *
  gc_deriv_ic_ref_yes    TYPE bea_indicator_ic    VALUE 'Y'            , "#EC *
  gc_src_reject          TYPE bea_reject          VALUE 'C'            , "#EC *
  gc_src_delete          TYPE bea_reject          VALUE 'D'            , "#EC *
  gc_src_reject_open     TYPE bea_reject          VALUE 'E'            , "#EC *
  gc_taxable             TYPE bea_taxable         VALUE ' '            , "#EC *
  gc_nontaxable          TYPE bea_taxable         VALUE 'A'            , "#EC *
  gc_output_tax          TYPE bea_tax_direction   VALUE '01'           , "#EC *
  gc_input_tax           TYPE bea_tax_direction   VALUE '02'           , "#EC *
  gc_undefined_tax       TYPE bea_tax_direction   VALUE ' '            , "#EC *
  gc_dlhstat_default     TYPE c                   VALUE ' '            , "#EC *
  gc_dlhstat_blocked     TYPE c                   VALUE 'A'            , "#EC *
  gc_dlhstat_open        TYPE c                   VALUE 'B'            . "#EC *
