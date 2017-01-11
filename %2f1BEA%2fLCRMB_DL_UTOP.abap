FUNCTION-POOL /1BEA/CRMB_DL_U.              "MESSAGE-ID ..
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:02
*
*======================================================================

INCLUDE %3CICON%3E.
INCLUDE BEA_BASICS.

tables: /1bea/s_CRMB_DLI_dsp.

CONSTANTS: GC_APPL           TYPE BEF_APPL    VALUE 'CRMB',
           gc_select_all     TYPE ui_func     VALUE 'SELECT_ALL',
           gc_deselect_all   TYPE ui_func     VALUE 'DESELECT_ALL',
           gc_bill_single    TYPE ui_func     VALUE 'BILL_SGL',
           gc_bill_multiple  TYPE ui_func     VALUE 'BILL_MLT',
           gc_bill_dialog    TYPE ui_func     VALUE 'BILL_DIAG',
           gc_prev           TYPE syucomm     VALUE 'PREV',
           gc_next           TYPE syucomm     VALUE 'NEXT',
           gc_det            type ui_func     value 'DETAIL',
           gc_coll_run       type ui_func     value 'COLL_RUN',
           gc_appl_log       type ui_func     value 'APPL_LOG',
           gc_release        type ui_func     value 'RELEASE',
           gc_errorlist      type ui_func     value 'ERRORLIST',
           gc_simulate       type ui_func     value 'SIMULATE',
           gc_refresh        type ui_func     value 'REFRESH',
           gc_cancel_incomp  type ui_func     value 'CANCEL_INCOMP',
           gc_reject         type ui_func     value 'REJECT',
           gc_reject_DL04    type ui_func     value 'REJECT_DL04',
           gc_iat_transfer   TYPE ui_func     value 'IAT_TRANSFER',
           gc_dfl_src_doc    type ui_func     value 'DFL_SRC_DOC',
           gc_dfl_bill_doc   type ui_func     value 'DFL_BILL_DOC',
           GC_TYPENAME_DLI_WRK  TYPE   DDOBJNAME
                              VALUE  '/1BEA/S_CRMB_DLI_WRK',
           GC_EXIT_DFL_DATA  type exit_def
                              value 'BEA_DOCFLOW_DATA'.

* Define global data for display of due list (via ALV Tree)
CLASS cl_gui_alv_tree    DEFINITION LOAD.
CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw         DEFINITION LOAD.

DATA: go_custom_container TYPE REF TO cl_gui_custom_container,
      go_alv_tree         TYPE REF TO cl_gui_alv_tree,
      go_toolbar          TYPE REF TO cl_gui_toolbar.

DATA: gv_ok_code      TYPE syucomm.

DATA: gt_dli             TYPE /1bea/t_CRMB_DLI_WRK,
      gt_dli_det         TYPE /1bea/t_CRMB_DLI_WRK,
      gt_dummy           TYPE /1bea/t_CRMB_DLI_WRK,
      GS_DLI             TYPE /1BEA/S_CRMB_DLI_WRK,
      gs_bill_default    TYPE BEAS_BILL_DEFAULT,
      gv_tabix           TYPE SYTABIX.
DATA: gs_variant         TYPE disvariant,
      gv_mode            type bea_dl_uimode,
      gt_excluded_fcodes TYPE ui_functions,
      GT_TOOLBAR         TYPE TTB_BUTTON.

* data for tree handling:
data: gt_active_nodes   TYPE lvc_t_nkey.

data: gv_crp_guid TYPE  BEA_CRP_GUID,
      gt_return   TYPE  beat_return.

* Data for detail tabstrip
CONSTANTS: BEGIN OF GC_DETAIL,
             TAB1 LIKE SY-UCOMM VALUE 'DETAIL_FC1',
             TAB2 LIKE SY-UCOMM VALUE 'DETAIL_FC2',
             TAB3 LIKE SY-UCOMM VALUE 'DETAIL_FC3',
             TAB4 LIKE SY-UCOMM VALUE 'DETAIL_FC4',
             TAB5 LIKE SY-UCOMM VALUE 'DETAIL_FC5',
             TAB6 LIKE SY-UCOMM VALUE 'DETAIL_FC6',
             TAB7 LIKE SY-UCOMM VALUE 'DETAIL_FC7',
             TAB9 LIKE SY-UCOMM VALUE 'DETAIL_FC9',
           END OF GC_DETAIL.

CONTROLS:  DETAIL TYPE TABSTRIP.
DATA:      BEGIN OF GS_DETAIL,
             SUBSCREEN   LIKE SY-DYNNR,
             PROG        LIKE SY-REPID,
             PRESSED_TAB LIKE SY-UCOMM VALUE GC_DETAIL-TAB1,
             OLD_TAB LIKE SY-UCOMM,
           END OF GS_DETAIL.
DATA: GV_DETAIL_TAB1(20) TYPE C,
      GV_DETAIL_TAB2(20) TYPE C,
      GV_DETAIL_TAB3(20) TYPE C,
      GV_DETAIL_TAB4(20) TYPE C,
      GV_DETAIL_TAB5(20) TYPE C,
      GV_DETAIL_TAB6(20) TYPE C,
      GV_DETAIL_TAB7(20) TYPE C,
      GV_DETAIL_TAB9(20) TYPE C.
DATA: GV_OKCODE110 TYPE SYUCOMM.

DATA: BEGIN OF GS_SRV_PREPARED,
        DETAIL TYPE BEA_BOOLEAN,
        PAR    TYPE BEA_BOOLEAN,
        PRC    TYPE BEA_BOOLEAN,
        TXT    TYPE BEA_BOOLEAN,
        MKT    TYPE BEA_BOOLEAN,
      END OF GS_SRV_PREPARED.

data: gs_itc_wrk type beas_itc_wrk.

DATA: go_docking             TYPE REF TO cl_gui_docking_container,
      go_doc_cap_det         TYPE REF TO cl_dd_document.
DATA: gv_height TYPE i.

DATA: GO_DFL_DATA          TYPE REF TO IF_EX_BEA_DOCFLOW_DATA.
* Event DL_UTOP
  INCLUDE %2f1BEA%2fX_CRMBDL_UTOP_0INC_F1CON.
  INCLUDE %2f1BEA%2fX_CRMBDL_UTOP_PRCUDL_TOP.
  INCLUDE %2f1BEA%2fX_CRMBDL_UTOP_TXTUDL_TOP.

*=====================================================================
* Define global classes (for ALV Tree)
*=====================================================================
CLASS lcl_tree_event_handler DEFINITION.

  PUBLIC SECTION.

     class-methods handle_node_ctmenu_request
       for event node_context_menu_request of cl_gui_alv_tree
         importing node_key
                   menu.
     class-methods handle_node_ctmenu_selected
       for event node_context_menu_selected of cl_gui_alv_tree
         importing node_key
                   fcode.

    class-methods handle_node_double_click
      for event node_double_click of cl_gui_alv_tree
      importing node_key.

     class-methods handle_header_ctmenu_request
       for event header_context_menu_request of cl_gui_alv_tree
         importing fieldname
                   menu.
     class-methods handle_header_ctmenu_select
       for event header_context_menu_select of cl_gui_alv_tree
         importing fieldname
                   fcode.

     class-methods handle_expand_nc
       for event expand_nc of cl_gui_alv_tree
         importing node_key.

    METHODS: on_function_selected
               FOR EVENT function_selected OF cl_gui_toolbar
                 IMPORTING fcode.

ENDCLASS.

*=====================================================================
* Define global object for event handling
*=====================================================================
DATA: go_event_handler TYPE REF TO lcl_tree_event_handler.
