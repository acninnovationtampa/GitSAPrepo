FUNCTION-POOL bea_basics.                   "MESSAGE-ID ..
*
* Types
TYPES:
  BEGIN OF gsy_values_shpl,
    bname TYPE bea_maint_user,
  END   OF gsy_values_shpl,
  gty_values_shpl TYPE STANDARD TABLE OF gsy_values_shpl.
*
* Constants
CONSTANTS:
  gc_comma                      TYPE  c          VALUE ',',
  gc_space                      TYPE  c          VALUE space,
  gc_asterisk                   TYPE  c          VALUE '*',
  gc_option_bt                  TYPE  bapioption VALUE 'BT',
  gc_option_cp                  TYPE  bapioption VALUE 'CP',
  gc_option_eq                  TYPE  bapioption VALUE 'EQ',
  gc_sign_i                     TYPE  bapisign   VALUE 'I',
  gc_search_digits(2)           TYPE  c          VALUE '* ',
  gc_func_f4_select_from_shlp   TYPE  funcname
                                VALUE 'F4_SELECT_FROM_SEARCH_HELP',
  gc_func_f4_select_search_help TYPE  funcname
                                VALUE 'F4_SELECT_SEARCH_HELP'.
*
* For BEA external modificators
INCLUDE BEF_BASICS_CON.

CONSTANTS:
  gc_appl(4)         TYPE c          VALUE 'APPL',
  gc_feature(7)      TYPE c          VALUE 'FEATURE',
  gc_obj(3)          TYPE c          VALUE 'OBJ',
  gc_container(9)    TYPE c          VALUE 'CONTAINER',
  gc_pobj(4)         TYPE c          VALUE 'POBJ'     ,
  gc_sobj(4)         TYPE c          VALUE 'SOBJ'     ,
  gc_rcont(5)        TYPE c          VALUE 'RCONT'    ,
  gc_ccont1(6)       TYPE c          VALUE 'CCONT1'   ,
  gc_attribute(9)    TYPE c          VALUE 'ATTRIBUTE'.

*&---------------------------------------------------------------------*
*&       Class LCL_LEADING_ZERO_TEST
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_leading_zero_test DEFINITION FOR TESTING. "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    METHODS:
      test_convert_num_range FOR TESTING.

ENDCLASS.               "LCL_LEADING_ZERO_TEST
