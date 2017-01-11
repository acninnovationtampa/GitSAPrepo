FUNCTION-POOL /1BEA/CRMB_BD_U.              "MESSAGE-ID ..
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================

tables: /1bea/s_CRMB_BDH_dsp.
tables: /1bea/s_CRMB_BDI_dsp.

TYPE-POOLS vrm.
INCLUDE %3CICON%3E.
INCLUDE BEA_BASICS.
INCLUDE BEA_ACC_CON.

INCLUDE BEA_PRC_CON.
INCLUDE BEA_TXT_CON.
INCLUDE COM_TEXT_CON.
INCLUDE BEA_CLASS_F1_CON.

CLASS cl_gui_cfw DEFINITION LOAD.

TYPE-POOLS: CNTB.

*=====================================================================
* Define global types
*=====================================================================
TYPES:
  BEGIN OF GTY_BDHI,
    HEADNO_EXT   TYPE bea_headno_ext,
    BILL_DATE    TYPE BEA_BILL_DATE,
    PAYER        TYPE BEA_payer,
    bill_org     TYPE bea_bill_org.
    INCLUDE      TYPE /1BEA/s_CRMB_BDI_wrk.
TYPES:
  END OF GTY_BDHI.
*--------------------------------------------------------------------
* Global Types for the ICONS in the ALV Grids
*--------------------------------------------------------------------
*....................................................................
* BDH -> Function Module SHOW_BDH
*....................................................................
TYPES:
 BEGIN OF GSY_OUTTAB_BDH.
     INCLUDE STRUCTURE /1BEA/S_CRMB_BDH_WRK.
 TYPES: icons(40) type c.
 TYPES: linecolor(4) type c.
TYPES: END OF GSY_OUTTAB_BDH.
TYPES GTY_OUTTAB_BDH TYPE STANDARD TABLE OF GSY_OUTTAB_BDH.
*....................................................................
* BDI -> Function Module SHOW_BDI
*....................................................................
TYPES:
 BEGIN OF GSY_OUTTAB_BDI.
     INCLUDE STRUCTURE /1BEA/S_CRMB_BDI_WRK.
 TYPES: icons(40) type c.
TYPES: END OF GSY_OUTTAB_BDI.
TYPES GTY_OUTTAB_BDI TYPE STANDARD TABLE OF GSY_OUTTAB_BDI.
*....................................................................
* BDHI -> Function Module SHOW_BDHI
*....................................................................
TYPES:
 BEGIN OF GSY_OUTTAB_BDHI.
 TYPES: icons(40) type c.
 TYPES: headno_ext type bea_headno_ext,
        BILL_DATE    TYPE BEA_BILL_DATE,
        BILL_TYPE    TYPE BEA_BILL_TYPE,
        PAYER        TYPE BEA_payer,
        bill_org     TYPE bea_bill_org.
     INCLUDE STRUCTURE /1BEA/S_CRMB_BDI_WRK.
TYPES: END OF GSY_OUTTAB_BDHI.
TYPES GTY_OUTTAB_BDHI TYPE STANDARD TABLE OF GSY_OUTTAB_BDHI.
*=====================================================================
* Define global dynpro controls
*=====================================================================
*....................................................................
* For the tabstrips on the Detail-Screens
*....................................................................
CONTROLS:  detail     TYPE TABSTRIP,
           detail_hdr type TABSTRIP.

*=====================================================================
* Define global constants
*=====================================================================
CONSTANTS:
  gc_appl               type bef_appl      value 'CRMB',
  gc_save               type syucomm        value 'SAVE',
  gc_back               type syucomm        value 'BACK',
  gc_exit               type syucomm        value 'EXIT',
  gc_canc               type syucomm        value 'CANC',
  gc_detail             type syucomm        value 'DETAIL',
  gc_change             type syucomm        value 'CHANGE',
  gc_toggle             type syucomm        value 'TOGGLE',
  gc_doc                type syucomm        value 'DOC',
  gc_analyze            type syucomm        value 'ANALYZE',
  gc_transfer           type syucomm        value 'TRANSFER',
  gc_acc_err            type syucomm        value 'ACC_ERR',
  gc_fcode_cancel       type syucomm        value 'CANCEL',
  gc_dialog_cancel      type syucomm        value 'DIALOG_CANCEL',
  GC_APPLLOG            type syucomm        value 'ALOG',
  GC_PPF_OVW            type syucomm        value 'PPF_OVW',
  gc_acc_simulate       type syucomm        value 'ACC_SIMULATATE',
  gc_acc_doc            type syucomm        value 'ACC_DOC',
  gc_retrobill          type syucomm        value 'RETRO_BILL',
  gc_prc                type syucomm        value 'PRC',
  gc_txt                type syucomm        value 'TXT',
  gc_par                type syucomm        value 'PAR',
  gc_ppf                type syucomm        value 'PPF',
  gc_prev               type syucomm        value 'PREV',
  gc_next               type syucomm        value 'NEXT',
  gc_refresh            type syucomm        value 'REFRESH',
  gc_toolbar_collexp    type syucomm        value 'TOOLBAR_COLLEXP',
  gc_item_collapse      type syucomm        value 'FC_ITEM_COLLAPSE',
  gc_header_collapse    type syucomm        value 'FC_HEADER_COLLAPSE',
  gc_item_get           type syucomm        value 'FC_ITEM_GET',
  gc_item_prev          type syucomm        value 'FC_ITEM_PREV',
  gc_item_next          type syucomm        value 'FC_ITEM_NEXT',
  gc_dummy              TYPE syucomm        VALUE 'DUMMY',
  gc_sel_multiple       type c              value 'A',
  gc_error_dial_cancel  TYPE UPDATE_TYPE    VALUE 'E',
  GC_FB_NAME            type RS38L_FNAM     value
                                     '/1BEA/CRMB_DL_U_DISPLAY'.
*
CONSTANTS:
*....................................................................
* Actions in Show
*....................................................................
  gc_dialog_cancel_in_show(10) TYPE c VALUE 'DIAL_CANC',
  gc_data_change_in_show(10)   TYPE c VALUE 'DATA_CHAN',
*....................................................................
* Constants for Text Processing
*....................................................................
    GC_TYPENAME_BDH_WRK TYPE   DDOBJNAME
                            VALUE  '/1BEA/S_CRMB_BDH_WRK',
    GC_TYPENAME_BDI_WRK TYPE   DDOBJNAME
                            VALUE  '/1BEA/S_CRMB_BDI_WRK'.
CONSTANTS:
  BEGIN OF gc_tab,
    tab0  LIKE sy-ucomm VALUE 'DETAIL_FC0',
    tab1  LIKE sy-ucomm VALUE 'DETAIL_FC1',
    tab2  LIKE sy-ucomm VALUE 'DETAIL_FC2',
    tab3  LIKE sy-ucomm VALUE 'DETAIL_FC3',
    tab4  LIKE sy-ucomm VALUE 'DETAIL_FC4',
    tab5  LIKE sy-ucomm VALUE 'DETAIL_FC5',
    tab6  LIKE sy-ucomm VALUE 'DETAIL_FC6',
    tab7  LIKE sy-ucomm VALUE 'DETAIL_FC7',
    tab8  LIKE sy-ucomm VALUE 'DETAIL_FC8',
    tab9  LIKE sy-ucomm VALUE 'DETAIL_FC9',         "Status
    tab10 LIKE sy-ucomm VALUE 'DETAIL_FC10',        "DocFlow
    tab11 LIKE sy-ucomm VALUE 'DETAIL_FC11',        "Marketing
    tab12 LIKE sy-ucomm VALUE 'DETAIL_FC12',        "UBB
    tab13 LIKE sy-ucomm VALUE 'DETAIL_FC13',        "Documents (File Attachments, Signatures)
  END OF gc_tab.

CONSTANTS gc_srv_acc TYPE BEF_SERVICE VALUE 'ACC'.
CONSTANTS gc_srv_icv TYPE BEF_SERVICE VALUE 'ICV'.
CONSTANTS gc_acd_analysis_icv TYPE syucomm VALUE 'ACD_ANALYSIS_ICV'.

*=====================================================================
* Define global data
*=====================================================================

*---------------------------------------------------------------------
* General data for dynpro management:
*---------------------------------------------------------------------
DATA:
  GV_OKCODE               TYPE syucomm,
  GV_MODE                 TYPE BEA_BD_UIMODE,
  GV_AL_MODE              TYPE BEA_AL_MODE,
  GV_MAINT_MODE           TYPE BEA_BOOLEAN,
  GV_DATA_CHANGED         TYPE BEA_BOOLEAN,
  GV_DATA_SAVED           TYPE BEA_BOOLEAN,
  GV_TABIX                TYPE SYTABIX,
  GV_TB_IS_COLLAPSED_BDH  TYPE BEA_BOOLEAN VALUE GC_TRUE,
  GV_TB_IS_COLLAPSED_BDI  TYPE BEA_BOOLEAN VALUE GC_TRUE,
  GT_ALOG_MSG             TYPE BEAT_RETURN,
  gv_height_bdh           TYPE i,
  gv_height_bdi           TYPE i,
  gv_sso_active           TYPE crmt_boolean value '-'.
*---------------------------------------------------------------------
* Data management
*---------------------------------------------------------------------
*.....................................................................
* For the function module SHOW (only one invoice)
*.....................................................................
DATA:
  gt_bdh_manage TYPE /1BEA/t_CRMB_BDH_wrk,
  gt_bdi_manage TYPE /1BEA/t_CRMB_BDI_wrk.
*.....................................................................
* For the function modules HD_SHOWLIST / SHOW_BDH (list of invoices)
*.....................................................................
DATA:
  gt_bdh_list_manage    TYPE /1BEA/t_CRMB_BDH_wrk,
  gt_bdi_list_manage    TYPE /1BEA/t_CRMB_BDI_wrk,
  gv_action_in_show(10) TYPE c,
  gv_first_display      TYPE c.
*---------------------------------------------------------------------
* General data for controls
*---------------------------------------------------------------------
DATA:
  GT_TOOLBAR_BDH TYPE TTB_BUTTON,
  GT_TOOLBAR_BDI TYPE TTB_BUTTON,
  gs_variant     TYPE DISVARIANT.
*---------------------------------------------------------------------
* General application data
*---------------------------------------------------------------------
TABLES:
  BEAS_BDH_TAB_GENERAL,
  BEAS_BDI_TAB_GENERAL,
  BEAS_BDH_TAB_STATUS,
  BEAS_BDI_TAB_STATUS.
DATA:
* All invoices and their items in functions HD_SHOWLIST / SHOW_BDH
  gt_bdh        TYPE /1BEA/t_CRMB_BDH_wrk,
  gt_bdi        TYPE /1BEA/t_CRMB_BDI_wrk,

* Invoice for SHOW_BDI / SHOW / XX_SHOWDETAIL
  gs_bdh          TYPE /1BEA/s_CRMB_BDH_wrk,
  gv_header_title(100),

* Global Items for SHOW / SHOW_BDI / XX_SHOWDETAIL
  gt_bdi_to_bdh TYPE /1BEA/t_CRMB_BDI_wrk,
  gv_bdi_guid   TYPE BEA_BDI_GUID,
  gv_item_focus TYPE SYINDEX,
  gv_item_max   TYPE SYINDEX,
  gv_item_title(32),
  gt_item_title       TYPE vrm_values WITH HEADER LINE,

* Used for IT_SHOWDETAIL: the item that is currently displayed
  gs_bdi        TYPE /1BEA/s_CRMB_BDI_wrk,

  GS_BTY        TYPE BEAS_BTY_WRK,
  gs_itc_wrk    type beas_itc_wrk,
  gt_return     type beat_return.
*---------------------------------------------------------------------
* Data for header list:
*---------------------------------------------------------------------
DATA:
  go_custom_bdh          TYPE REF TO cl_gui_custom_container,
  gt_bdh_alv_manager     TYPE TABLE OF REF TO cl_gui_alv_grid,
  gv_new_alv             TYPE bea_boolean,
  gt_outtab_bdh          TYPE gty_outtab_bdh.
*---------------------------------------------------------------------
* Data for item list:
*---------------------------------------------------------------------
DATA:
  go_alv_bdhi            TYPE REF TO cl_gui_alv_grid,
  gt_bdhi_alv_manager    TYPE TABLE OF REF TO cl_gui_alv_grid,
  go_custom_bdhi         TYPE REF TO cl_gui_custom_container,
  gt_outtab_bdhi         TYPE gty_outtab_bdhi,
  GT_TOOLBAR_BDHI        TYPE TTB_BUTTON.
*---------------------------------------------------------------------
* Data for document view/item list:
*---------------------------------------------------------------------
DATA:
  go_alv_bdh             TYPE REF TO cl_gui_alv_grid,
  go_custom_doc          TYPE REF TO cl_gui_custom_container,
  go_doc_cap_bdh         TYPE REF TO cl_dd_document,
  GO_SPLITTER            TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
  GO_CONTAINER_UPPER     TYPE REF TO CL_GUI_CONTAINER,
  GO_CONTAINER_LOWER     TYPE REF TO CL_GUI_CONTAINER,
  go_alv_bdi             TYPE REF TO cl_gui_alv_grid.
DATA:
  gt_outtab_bdi          TYPE gty_outtab_bdi.
*---------------------------------------------------------------------
* Data for detail tabstrip
*---------------------------------------------------------------------
DATA:
  go_docking               TYPE REF TO cl_gui_docking_container,
  go_doc_cap_det           TYPE REF TO cl_dd_document.
DATA:
  gv_pressed_tab_hdr LIKE sy-ucomm,
  gv_pressed_tab_itm LIKE sy-ucomm,
  BEGIN OF gs_tab,
    subscreen   LIKE sy-dynnr,
    prog        LIKE sy-repid,
    pressed_tab LIKE sy-ucomm VALUE gc_tab-tab1,
    old_tab     LIKE SY-UCOMM,
  END OF gs_tab.
* Variables that are used on the screen:
DATA:
  gv_detail_tab0(20)  TYPE c,
  gv_detail_tab1(20)  TYPE c,
  gv_detail_tab2(20)  TYPE c,
  gv_detail_tab3(20)  TYPE c,
  gv_detail_tab4(20)  TYPE c,
  gv_detail_tab5(20)  TYPE c,
  gv_detail_tab6(20)  TYPE c,
  gv_detail_tab7(20)  TYPE c,
  gv_detail_tab8(20)  TYPE c,
  gv_detail_tab9(20)  TYPE c,
  gv_detail_tab10(20) TYPE c,
  gv_detail_tab11(20) TYPE c,
  gv_detail_tab12(20) TYPE c,
  gv_detail_tab13(20) TYPE c.
DATA:
  BEGIN OF GS_SRV_PREPARED,
    GENERAL TYPE BEA_BOOLEAN,
    DETAIL  TYPE BEA_BOOLEAN,
    PAR     TYPE BEA_BOOLEAN,
    PRC     TYPE BEA_BOOLEAN,
    TXT     TYPE BEA_BOOLEAN,
    PPF     TYPE BEA_BOOLEAN,
    DOCFLOW TYPE BEA_BOOLEAN,
    STATUS  TYPE BEA_BOOLEAN,
    MKT     TYPE BEA_BOOLEAN,
  END OF GS_SRV_PREPARED.

* Event BD_UTOP
  INCLUDE %2f1BEA%2fX_CRMBBD_UTOP_PRCUBD_TOP.
*---------------------------------------------------------------------
*       CLASS lcl_event_handler_bdh DEFINITION
*---------------------------------------------------------------------
*       Event Handler for header list
*---------------------------------------------------------------------
CLASS lcl_event_handler_bdh DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:  handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
                    IMPORTING e_ucomm,

                    handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
                    IMPORTING e_object e_interactive,

                    handle_context_menu
                    FOR EVENT context_menu_request OF cl_gui_alv_grid
                    IMPORTING e_object,

                    handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
                    IMPORTING e_row e_column.
ENDCLASS.
*---------------------------------------------------------------------
*       CLASS lcl_event_handler_bdi DEFINITION
*---------------------------------------------------------------------
*       Event Handler for item list
*---------------------------------------------------------------------
CLASS lcl_event_handler_bdi DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:  handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
                    IMPORTING e_object e_interactive,

                    handle_context_menu
                    FOR EVENT context_menu_request OF cl_gui_alv_grid
                    IMPORTING e_object,

                    handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
                    IMPORTING e_ucomm,

                    handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
                    IMPORTING e_row e_column.
ENDCLASS.
*---------------------------------------------------------------------
*       CLASS lcl_event_handler_bdhi DEFINITION
*---------------------------------------------------------------------
*       Event Handler for item list
*---------------------------------------------------------------------
CLASS lcl_event_handler_bdhi DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:  handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
                    IMPORTING e_object e_interactive,

                    handle_context_menu
                    FOR EVENT context_menu_request OF cl_gui_alv_grid
                    IMPORTING e_object,

                    handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
                    IMPORTING e_ucomm,

                    handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
                    IMPORTING e_row e_column.
ENDCLASS.
