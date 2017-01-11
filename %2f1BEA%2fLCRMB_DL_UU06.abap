FUNCTION /1BEA/CRMB_DL_U_SHOW.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IS_BILL_DEFAULT) TYPE  BEAS_BILL_DEFAULT OPTIONAL
*"     REFERENCE(IO_ALV_TREE) TYPE REF TO CL_GUI_ALV_TREE
*"     REFERENCE(IS_VARIANT) TYPE  DISVARIANT OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  BEA_DL_UIMODE DEFAULT 'A'
*"--------------------------------------------------------------------
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================
*====================================================================
* Define local data
*====================================================================
*********************************************************************
* Implementation part
*********************************************************************
* Transfer importing parameters to global data
  GO_ALV_TREE     = IO_ALV_TREE.
  GV_MODE         = IV_MODE.
  GS_BILL_DEFAULT = IS_BILL_DEFAULT.
  IF GT_DLI IS INITIAL.
    GT_DLI = IT_DLI.
  ENDIF.
* Create ALV tree for display of the due list items
  PERFORM CREATE_ALV_TREE USING IS_VARIANT.

* Build the node and item table
  PERFORM BUILD_TREE.

ENDFUNCTION.

*********************************************************************
* Form Routines
*********************************************************************
*--------------------------------------------------------------------*
*     FORM create_alv_tree
*--------------------------------------------------------------------*
*     Create ALV tree for display of due list
*--------------------------------------------------------------------*
FORM CREATE_ALV_TREE USING US_VARIANT TYPE DISVARIANT.
*====================================================================
* Define local data
*====================================================================
  DATA: LS_EVENT                TYPE CNTL_SIMPLE_EVENT,
        LT_EVENTS               TYPE CNTL_SIMPLE_EVENTS,
        LS_HIERARCHY_HEADER     TYPE TREEV_HHDR,
        LT_EXCLUDE              TYPE UI_FUNCTIONS,
        LS_EXCLUDE              TYPE UI_FUNC,
        LT_FIELDCAT             TYPE LVC_T_FCAT,
        LS_VARIANT              TYPE DISVARIANT.
*====================================================================
* Build the fieldcat according to DDIC structure
*====================================================================
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
            I_STRUCTURE_NAME   = '/1BEA/S_CRMB_DLI'
*            i_bypassing_buffer = 'X'
       CHANGING
            CT_FIELDCAT        = LT_FIELDCAT.
*====================================================================
* Set HTML header of ALV Tree
*====================================================================
  LS_HIERARCHY_HEADER-WIDTH   = 12.
*====================================================================
* Exclude some irrelevant standard buttons from ALV toolbar
*====================================================================
  ls_exclude = cl_gui_alv_tree=>mc_fc_graphics.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_tree=>MC_FC_CALCULATE.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_tree=>MC_FC_CALCULATE_AVG.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_tree=>MC_FC_CALCULATE_MAX.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_tree=>MC_FC_CALCULATE_MIN.
  APPEND ls_exclude TO lt_exclude.
*====================================================================
* Call ALV TREE
*====================================================================
  IF NOT US_VARIANT IS INITIAL.
    LS_VARIANT = US_VARIANT.
  ELSE.
    LS_VARIANT-REPORT = SY-REPID.
  ENDIF.
  CALL METHOD GO_ALV_TREE->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
        IS_VARIANT           = LS_VARIANT
        I_SAVE               = GC_VARIANT_ALL
        I_DEFAULT            = GC_TRUE
        IS_HIERARCHY_HEADER  = LS_HIERARCHY_HEADER
        IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
    CHANGING
        IT_OUTTAB            = GT_DUMMY
        IT_FIELDCATALOG      = LT_FIELDCAT.
*====================================================================
* Add tree/application specific internal buttons to ALV
*====================================================================
  PERFORM ADD_TOOLBAR_TO_TREE.
*====================================================================
* Create event handler
*====================================================================
 CALL METHOD GO_ALV_TREE->ADD_KEY_STROKE
   EXPORTING
     I_KEY             = CL_GUI_COLUMN_TREE=>KEY_F4
 EXCEPTIONS
   others            = 0.

  CALL METHOD GO_ALV_TREE->GET_REGISTERED_EVENTS
    IMPORTING
      EVENTS = LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  LS_EVENT-APPL_EVENT = GC_TRUE.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID =
             CL_GUI_COLUMN_TREE=>EVENTID_NODE_CONTEXT_MENU_REQ.
  LS_EVENT-APPL_EVENT = GC_TRUE.
  APPEND LS_EVENT TO LT_EVENTS.
  CALL METHOD GO_ALV_TREE->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS = LT_EVENTS.
  CREATE OBJECT GO_EVENT_HANDLER.
  SET HANDLER GO_EVENT_HANDLER->ON_FUNCTION_SELECTED FOR GO_TOOLBAR.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_NODE_DOUBLE_CLICK
    FOR GO_ALV_TREE.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_NODE_CTMENU_REQUEST
    FOR GO_ALV_TREE.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_NODE_CTMENU_SELECTED
    FOR GO_ALV_TREE.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_HEADER_CTMENU_REQUEST
    FOR GO_ALV_TREE.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_HEADER_CTMENU_SELECT
    FOR GO_ALV_TREE.
  SET HANDLER LCL_TREE_EVENT_HANDLER=>HANDLE_EXPAND_NC
    FOR GO_ALV_TREE.

ENDFORM.
*--------------------------------------------------------------------*
*     FORM build_tree
*--------------------------------------------------------------------*
*     Create ALV tree for display of due list
*--------------------------------------------------------------------*
FORM BUILD_TREE.
*====================================================================
* Define local data
*====================================================================
  CONSTANTS:
        LC_UITYPE_HEAD            TYPE C VALUE 'A',
        LC_UITYPE_ITEM            TYPE C VALUE 'B',
        lc_timezone               type sy-zonlo value 'UTC'.

  DATA: LS_DLI                  TYPE /1BEA/S_CRMB_DLI_WRK,
        LT_DLI                  TYPE /1BEA/T_CRMB_DLI_WRK,
        LV_VALID_DERIV_CAT      TYPE BEA_BOOLEAN,
        LV_NODE_TEXT            TYPE LVC_VALUE,
        LS_NODE_LAYOUT          TYPE LVC_S_LAYN,
        LT_ITEM_LAYOUT          TYPE LVC_T_LAYI,
        LS_ITEM_LAYOUT          TYPE LVC_S_LAYI,
        LV_NODE_KEY_HEAD        TYPE LVC_NKEY,
        LV_NODE_KEY_ITEM        TYPE LVC_NKEY,
        lv_date                 TYPE d,
        lv_time                 TYPE t.
*====================================================================
* Build the node and item table
*====================================================================
  CALL FUNCTION '/1BEA/CRMB_DL_O_BUILD_DOCVIEW'
    EXPORTING
      IT_DLI = GT_DLI
    IMPORTING
      ET_DLI = LT_DLI.
  CLEAR LS_DLI.
  LS_NODE_LAYOUT-N_IMAGE   = 'BNONE'.
  LS_NODE_LAYOUT-EXP_IMAGE = 'BNONE'.
  LOOP AT LT_DLI INTO LS_DLI.
    if not ls_dli-base_timezone is initial.
      if not ls_dli-base_time_from is initial.
        convert time stamp ls_dli-base_time_from
                time zone ls_dli-base_timezone into date lv_date time lv_time.
        convert date lv_date time lv_time into
                time stamp ls_dli-base_time_from time zone lc_timezone.
      endif.
      if not ls_dli-base_time_to is initial.
        convert time stamp ls_dli-base_time_to
                time zone ls_dli-base_timezone into date lv_date time lv_time.
        convert date lv_date time lv_time into
                time stamp ls_dli-base_time_to time zone lc_timezone.
      endif.
    endif.
    IF LS_DLI-DLI_UITYPE = LC_UITYPE_HEAD.
      CLEAR LT_ITEM_LAYOUT.
      LS_ITEM_LAYOUT-FIELDNAME = GO_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
      PERFORM ASSIGN_T_IMAGE
        USING     LS_DLI
        CHANGING  LS_ITEM_LAYOUT.
      APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.
      CALL METHOD GO_ALV_TREE->ADD_NODE
        EXPORTING
              I_RELAT_NODE_KEY = SPACE
              I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
              I_NODE_TEXT      = LV_NODE_TEXT
              IS_OUTTAB_LINE   = LS_DLI
              IS_NODE_LAYOUT   = LS_NODE_LAYOUT
              IT_ITEM_LAYOUT   = LT_ITEM_LAYOUT
           IMPORTING
              E_NEW_NODE_KEY   = LV_NODE_KEY_HEAD.
      APPEND LV_NODE_KEY_HEAD TO GT_ACTIVE_NODES.
    ENDIF.
    IF LS_DLI-DLI_UITYPE = LC_UITYPE_ITEM.
      LV_VALID_DERIV_CAT = GC_FALSE.
      IF LS_DLI-DERIV_CATEGORY = GC_DERIV_ORIGIN OR
         LS_DLI-DERIV_CATEGORY = GC_DERIV_CONDITION OR
         LS_DLI-DERIV_CATEGORY = GC_DERIV_RETROBILL.
        LV_VALID_DERIV_CAT = GC_TRUE.
      ENDIF.
      CLEAR LT_ITEM_LAYOUT.
      PERFORM ASSIGN_T_IMAGE
        USING     LS_DLI
        CHANGING  LS_ITEM_LAYOUT.
      LS_ITEM_LAYOUT-FIELDNAME = GO_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
      APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.
      IF GV_MODE = GC_DL_PROCESS.
        IF LS_DLI-BILL_RELEVANCE = GC_BILL_REL_DELIVERY OR
           LS_DLI-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
           LS_DLI-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP.
          IF LV_VALID_DERIV_CAT = GC_TRUE.
            LS_NODE_LAYOUT-ISFOLDER = 'X'.
            LS_NODE_LAYOUT-EXPANDER = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      CALL METHOD GO_ALV_TREE->ADD_NODE
        EXPORTING
              I_RELAT_NODE_KEY = LV_NODE_KEY_HEAD
              I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
              I_NODE_TEXT      = LV_NODE_TEXT
              IS_OUTTAB_LINE   = LS_DLI
              IS_NODE_LAYOUT   = LS_NODE_LAYOUT
              IT_ITEM_LAYOUT   = LT_ITEM_LAYOUT
           IMPORTING
              E_NEW_NODE_KEY = LV_NODE_KEY_ITEM.
      APPEND LV_NODE_KEY_ITEM TO GT_ACTIVE_NODES.
      CLEAR LS_NODE_LAYOUT-ISFOLDER.
      CLEAR LS_NODE_LAYOUT-EXPANDER.
      CONTINUE.
    ENDIF.
  ENDLOOP.
  CALL METHOD GO_ALV_TREE->UPDATE_CALCULATIONS.
  CALL METHOD GO_ALV_TREE->FRONTEND_UPDATE.
ENDFORM.
*--------------------------------------------------------------------*
*     FORM ASSIGN_T_IMAGE
*--------------------------------------------------------------------*
FORM ASSIGN_T_IMAGE
  USING
    US_DLI          TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    cs_item_layout  type lvc_s_layi.
  CS_ITEM_LAYOUT-T_IMAGE   = ICON_LED_YELLOW.
  CASE GV_MODE.
    WHEN GC_DL_RELEASE.
      IF US_DLI-BILL_BLOCK = GC_BILLBLOCK_EXTERN.
        CS_ITEM_LAYOUT-T_IMAGE   = 'BNONE'.
      ELSEIF US_DLI-BILL_BLOCK = GC_BILLBLOCK_PROCESS.
        CS_ITEM_LAYOUT-T_IMAGE   = ICON_LED_INACTIVE.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*--------------------------------------------------------------------*
*     FORM add_toolbar_to_tree
*--------------------------------------------------------------------*
*     Create ALV tree for display of due list
*--------------------------------------------------------------------*
FORM ADD_TOOLBAR_TO_TREE.
*====================================================================
* Define local data
*====================================================================
  DATA: LS_TOOLBAR  TYPE STB_BUTTON,
        LV_FUNCTION TYPE UI_FUNC.
*====================================================================
* Add tree/application specific internal buttons to ALV
*====================================================================
  CALL METHOD GO_ALV_TREE->GET_TOOLBAR_OBJECT
    IMPORTING
      ER_TOOLBAR = GO_TOOLBAR.
  CHECK NOT GO_TOOLBAR IS INITIAL.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> select all
  LS_TOOLBAR-FUNCTION  = GC_SELECT_ALL.
  LS_TOOLBAR-ICON      = ICON_SELECT_ALL.
  LS_TOOLBAR-QUICKINFO = TEXT-B01.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> deselect all
  LS_TOOLBAR-FUNCTION  = GC_DESELECT_ALL.
  LS_TOOLBAR-ICON      = ICON_DESELECT_ALL.
  LS_TOOLBAR-QUICKINFO = TEXT-B02.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> refresh
  LS_TOOLBAR-FUNCTION  = GC_REFRESH.
  LS_TOOLBAR-ICON      = ICON_REFRESH.
  LS_TOOLBAR-QUICKINFO = TEXT-RSH.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> detail view
  LS_TOOLBAR-FUNCTION  = GC_DET.
  LS_TOOLBAR-ICON      = ICON_DOC_ITEM_DETAIL.
  LS_TOOLBAR-QUICKINFO = TEXT-DTL.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> protocols
  LS_TOOLBAR-FUNCTION  = GC_COLL_RUN.
  LS_TOOLBAR-ICON      = ICON_PROTOCOL.
  LS_TOOLBAR-QUICKINFO = TEXT-CRP.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = GC_APPL_LOG.
  LS_TOOLBAR-ICON      = ICON_ERROR_PROTOCOL.
  LS_TOOLBAR-QUICKINFO = TEXT-LOG.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> billing modes
  LS_TOOLBAR-FUNCTION  = GC_BILL_SINGLE.
  LS_TOOLBAR-ICON      = ICON_DOCUMENT.
  LS_TOOLBAR-QUICKINFO = TEXT-B11.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = GC_BILL_MULTIPLE.
  LS_TOOLBAR-ICON      = ICON_CASHING_UP.
  LS_TOOLBAR-QUICKINFO = TEXT-B12.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR-TEXT.
   LS_TOOLBAR-FUNCTION  = GC_BILL_DIALOG.
   LS_TOOLBAR-ICON      = ICON_CASHING_UP.
   LS_TOOLBAR-TEXT      = TEXT-DLG.
   LS_TOOLBAR-QUICKINFO = TEXT-B13.
   APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> release
  LS_TOOLBAR-FUNCTION  = GC_RELEASE.
  LS_TOOLBAR-ICON      = ICON_RELEASE.
  LS_TOOLBAR-QUICKINFO = TEXT-RLS.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> errorlist
  LS_TOOLBAR-FUNCTION  = GC_ERRORLIST.
  LS_TOOLBAR-ICON      = ICON_COMPLETE.
  LS_TOOLBAR-QUICKINFO = TEXT-ERL.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> errorlist
  LS_TOOLBAR-FUNCTION  = GC_SIMULATE.
  LS_TOOLBAR-ICON      = ICON_SIMULATE.
  LS_TOOLBAR-QUICKINFO = TEXT-SIM.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> reject
  LS_TOOLBAR-FUNCTION  = GC_REJECT.
  LS_TOOLBAR-ICON      = ICON_REJECT.
  LS_TOOLBAR-QUICKINFO = TEXT-REJ.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> iat transfer
  LS_TOOLBAR-FUNCTION  = GC_IAT_TRANSFER.
  LS_TOOLBAR-ICON      = ICON_COMPLETE.
  LS_TOOLBAR-QUICKINFO = TEXT-IAT.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.   "-> reject
  LS_TOOLBAR-FUNCTION  = GC_REJECT_DL04.
  LS_TOOLBAR-ICON      = ICON_REJECT.
  LS_TOOLBAR-QUICKINFO = TEXT-REJ.
  APPEND LS_TOOLBAR TO GT_TOOLBAR.
  IF GV_MODE <> GC_DL_PROCESS.
    LV_FUNCTION = GC_COLL_RUN.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
    LV_FUNCTION = GC_BILL_SINGLE.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
    LV_FUNCTION = GC_BILL_MULTIPLE.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
    LV_FUNCTION = GC_BILL_DIALOG.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT (    GV_MODE = GC_DL_RELEASE
           OR GV_MODE = GC_DL_qREL ) .
    LV_FUNCTION = GC_RELEASE.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT GV_MODE = GC_DL_ERRORLIST.
    LV_FUNCTION = GC_ERRORLIST.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
    LV_FUNCTION = GC_SIMULATE.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT GV_MODE = GC_DL_REJECT.
    LV_FUNCTION = GC_REJECT.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
    LV_FUNCTION = GC_CANCEL_INCOMP.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT GV_MODE = GC_DL_IAT_TRANSFER.
    LV_FUNCTION = GC_IAT_TRANSFER.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT GV_MODE = GC_DL_REJECT_DL04.
    LV_FUNCTION = GC_REJECT_DL04.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
  IF NOT (    GV_MODE = GC_DL_PROCESS
           OR GV_MODE = GC_DL_RELEASE ) .
    LV_FUNCTION = GC_REFRESH.
    APPEND LV_FUNCTION TO GT_EXCLUDED_FCODES.
  ENDIF.
* Event for defining/excluding further toolbar buttons
  LOOP AT GT_EXCLUDED_FCODES INTO LV_FUNCTION.
    DELETE GT_TOOLBAR WHERE FUNCTION = LV_FUNCTION.
  ENDLOOP.
  CALL METHOD GO_TOOLBAR->ADD_BUTTON_GROUP
    EXPORTING
      DATA_TABLE       = GT_TOOLBAR
  EXCEPTIONS
      others           = 1.
  IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------*
*       FORM GET_DLI_TO_PROCESS
*--------------------------------------------------------------------*
* Get the due list items to be processed for the selected nodes
*--------------------------------------------------------------------*
FORM GET_DLI_TO_PROCESS
  using
    uv_function    type ui_func
  CHANGING
    CT_DLI_NODES   TYPE LVC_T_NKEY
    CT_DLI_WRK     TYPE /1BEA/T_CRMB_DLI_WRK
    CV_PROCESSED   TYPE BOOLEAN.
*====================================================================
* Define local data
*====================================================================
  DATA:
    LT_SELECTED_NODES       TYPE LVC_T_NKEY,
    LV_SELECTED_NODE        TYPE LVC_NKEY,
    LRS_TV_IMAGE            TYPE BEARS_TV_IMAGE,
    LRT_TV_IMAGE            TYPE BEART_TV_IMAGE,
    LS_ITEM_LAYOUT          TYPE LVC_S_LAYI,
    LT_ITEM_LAYOUT          TYPE LVC_T_LAYI,
    LV_PARENT_NODE          TYPE LVC_NKEY,
    LS_CHILDREN             TYPE LVC_S_NKEY,
    LT_CHILDREN             TYPE LVC_T_NKEY,
    LV_DLI_NODE             TYPE LVC_NKEY,
    LS_DLI                  TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_LINES                TYPE I.

  case uv_function.
    when gc_bill_multiple OR gc_bill_dialog OR
         gc_errorlist OR gc_simulate or gc_iat_transfer.
      LRS_TV_IMAGE-SIGN   = GC_INCLUDE.
      LRS_TV_IMAGE-OPTION = GC_EQUAL.
      LRS_TV_IMAGE-LOW    = ICON_LED_YELLOW.
      APPEND LRS_TV_IMAGE TO LRT_TV_IMAGE.
    when GC_CANCEL_INCOMP OR GC_REJECT.
      lrs_TV_IMAGE-sign   = gc_include.
      lrs_TV_IMAGE-option = gc_equal.
      LRS_TV_IMAGE-LOW    = ICON_LED_YELLOW.
      append lrs_tv_image to lrt_tv_image.
      LRS_TV_IMAGE-LOW    = ICON_LED_RED.
      append lrs_tv_image to lrt_tv_image.
    when gc_release.
      lrs_TV_IMAGE-sign   = gc_include.
      lrs_TV_IMAGE-option = gc_equal.
      LRS_TV_IMAGE-LOW    = ICON_LED_YELLOW.
      append lrs_tv_image to lrt_tv_image.
      LRS_TV_IMAGE-LOW    = ICON_LED_INACTIVE.
      append lrs_tv_image to lrt_tv_image.
    when gc_dfl_src_doc.
*     only one entry, see below
    when gc_dfl_bill_doc.
      LRS_TV_IMAGE-SIGN   = GC_INCLUDE.
      LRS_TV_IMAGE-OPTION = GC_EQUAL.
      LRS_TV_IMAGE-LOW    = ICON_LED_GREEN.
      APPEND LRS_TV_IMAGE TO LRT_TV_IMAGE.
    when gc_appl_log.
      " all items are allowed
    when OTHERS.
      return.
  endcase.
  IF uv_function = GC_ERRORLIST.
    LRS_TV_IMAGE-LOW    = ICON_CHECKED.
    APPEND LRS_TV_IMAGE TO LRT_TV_IMAGE.
  ENDIF.
*====================================================================
* Build up table of due list items selected for billing
*====================================================================
* Determine which line(s) are selected
  CALL METHOD GO_ALV_TREE->GET_SELECTED_NODES
    CHANGING
      CT_SELECTED_NODES = LT_SELECTED_NODES.
  CALL METHOD cl_gui_cfw=>flush.
  IF LT_SELECTED_NODES IS INITIAL.
    MESSAGE S600(BEA).
    EXIT.
  ENDIF.
  if uv_function = gc_dfl_src_doc.
    describe table lt_selected_nodes lines lv_lines.
    if lv_lines gt 1.
      message s602(bea).
      exit.
    endif.
  endif.
* Get nodes of items to be billed:
* - Get all items if header (= document) is selected
* - Get item data if item is selected
  CLEAR CT_DLI_NODES.
  LOOP AT LT_SELECTED_NODES INTO LV_SELECTED_NODE.
    CALL METHOD GO_ALV_TREE->GET_PARENT
      EXPORTING
        I_NODE_KEY        = LV_SELECTED_NODE
      IMPORTING
        E_PARENT_NODE_KEY = LV_PARENT_NODE.
    IF LV_PARENT_NODE = GO_ALV_TREE->C_VIRTUAL_ROOT_NODE. " head node
      CALL METHOD GO_ALV_TREE->GET_CHILDREN
        EXPORTING
          I_NODE_KEY  = LV_SELECTED_NODE
        IMPORTING
          ET_CHILDREN = LT_CHILDREN.
      LOOP AT LT_CHILDREN INTO LS_CHILDREN.
        insert LS_CHILDREN-NODE_KEY into table ct_dli_nodes.
      ENDLOOP.
    ELSE.  "= item node
*             check if not already included by selected header:
      READ TABLE LT_CHILDREN FROM LV_SELECTED_NODE
                 TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.
        insert LV_SELECTED_NODE into table ct_dli_nodes.
      ENDIF.
    ENDIF.
  ENDLOOP.
* get item data
  loop at ct_dli_nodes into lv_dli_node.
    CLEAR LT_ITEM_LAYOUT.
    CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
      EXPORTING
        I_NODE_KEY     = LV_DLI_NODE
      IMPORTING
        E_OUTTAB_LINE  = LS_DLI
        ET_ITEM_LAYOUT = LT_ITEM_LAYOUT
      EXCEPTIONS
        NODE_NOT_FOUND = 1
        OTHERS         = 2.
    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*     check if processed before in same session
      LOOP AT LT_ITEM_LAYOUT INTO LS_ITEM_LAYOUT
           WHERE T_IMAGE IN LRT_TV_IMAGE.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC = 0.
        INSERT LS_DLI INTO TABLE CT_DLI_WRK.
      ELSE.
* make sure, that ct_dli_wrk is in sync with ct_dli_nodes
        DELETE CT_DLI_NODES.
        CV_PROCESSED = GC_TRUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*--------------------------------------------------------------------*
*     FORM bill_single
*--------------------------------------------------------------------*
* Get the due list items to be processed for the selected nodes
*--------------------------------------------------------------------*
FORM BILL_SINGLE
  CHANGING
    CT_DLI_NODES  TYPE LVC_T_NKEY
    CT_DLI_ERROR  TYPE BEAT_DLI_GUID
    CV_CRP_GUID   TYPE BEA_CRP_GUID
    CV_PROCESSED  TYPE BEA_BOOLEAN
    CT_RETURN     TYPE BEAT_RETURN.
*====================================================================
* Define local data
*====================================================================
  DATA:
    LT_SELECTED_NODES       TYPE LVC_T_NKEY,
    LV_SELECTED_NODE        TYPE LVC_NKEY,
    LT_ITEM_LAYOUT          TYPE LVC_T_LAYI,
    LV_PARENT_NODE          TYPE LVC_NKEY,
    LS_CHILDREN             TYPE LVC_S_NKEY,
    LT_CHILDREN             TYPE LVC_T_NKEY,
    LT_DOC_NODES            TYPE LVC_T_NKEY,
    LV_DOC_NODE             TYPE LVC_NKEY,
    LV_DOC_NODE_HLP         TYPE LVC_NKEY,
    LT_DLI_NODES            TYPE LVC_T_NKEY,
    LS_DLI                  TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI                  TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_ERROR            TYPE BEA_DLI_GUID,
    LT_DLI_ERROR            TYPE BEAT_DLI_GUID,
    LT_BDH                  TYPE /1BEA/T_CRMB_BDH_WRK,
    LS_BDH                  TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_BDI                  TYPE /1BEA/T_CRMB_BDI_WRK,
    LS_RETURN               TYPE BEAS_RETURN,
    LT_RETURN               TYPE BEAT_RETURN,
    LV_DATA_SAVED           TYPE BEA_BOOLEAN.
*====================================================================
* Build up table of due list items selected for billing
*====================================================================
* Determine which line(s) are selected
  CALL METHOD GO_ALV_TREE->GET_SELECTED_NODES
    CHANGING
      CT_SELECTED_NODES = LT_SELECTED_NODES.
  CALL METHOD cl_gui_cfw=>flush.
  IF LT_SELECTED_NODES IS INITIAL. "no nodes selected
    MESSAGE S600(BEA).
    EXIT.
  ENDIF.
* Get all doc nodes to selected nodes:
  CLEAR CT_DLI_NODES.
  LOOP AT LT_SELECTED_NODES INTO LV_SELECTED_NODE.
    CALL METHOD GO_ALV_TREE->GET_PARENT
      EXPORTING
        I_NODE_KEY        = LV_SELECTED_NODE
      IMPORTING
        E_PARENT_NODE_KEY = LV_PARENT_NODE.
    IF LV_PARENT_NODE
            = GO_ALV_TREE->C_VIRTUAL_ROOT_NODE.
      lv_doc_node = LV_SELECTED_NODE." into table lt_doc_nodes.
    ELSE.  "= item node
      lv_doc_node = LV_PARENT_NODE." into table lt_doc_nodes.
    ENDIF.
* Check if the doc_node is already in the table lt_doc_nodes
    READ TABLE lt_doc_nodes FROM lv_doc_node
         TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      INSERT lv_doc_node INTO TABLE lt_doc_nodes.
    ENDIF.
  ENDLOOP.   "at selected nodes
  CLEAR lv_doc_node.
* - Get all items of document selected
  LOOP AT LT_DOC_NODES INTO LV_DOC_NODE.
    CALL METHOD GO_ALV_TREE->GET_CHILDREN
      EXPORTING
        I_NODE_KEY  = LV_DOC_NODE
      IMPORTING
        ET_CHILDREN = LT_CHILDREN.
*      get items and item data
    CLEAR LT_DLI_NODES.
    CLEAR LT_DLI.
    CLEAR LT_DLI_ERROR.
    CLEAR LT_RETURN.
    LOOP AT LT_CHILDREN INTO LS_CHILDREN.
      READ TABLE LT_SELECTED_NODES
           WITH KEY TABLE_LINE = LV_DOC_NODE
           TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.    " parent not selected
        READ TABLE LT_SELECTED_NODES
             WITH KEY TABLE_LINE = LS_CHILDREN-NODE_KEY
             TRANSPORTING NO FIELDS.
        IF NOT SY-SUBRC IS INITIAL.  " child not selected
          CONTINUE.
        ENDIF.
      ENDIF.
      CLEAR LT_ITEM_LAYOUT.
      INSERT LS_CHILDREN-NODE_KEY into table lt_dli_nodes.
      CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
        EXPORTING
          I_NODE_KEY     = LS_CHILDREN-NODE_KEY
        IMPORTING
          E_OUTTAB_LINE  = LS_DLI
          ET_ITEM_LAYOUT = LT_ITEM_LAYOUT
        EXCEPTIONS
          NODE_NOT_FOUND = 1
          OTHERS         = 2.
      IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
*       check if processed before in same session
        READ TABLE LT_ITEM_LAYOUT
                   WITH KEY T_IMAGE = ICON_LED_RED
                   TRANSPORTING NO FIELDS.
        IF SY-SUBRC IS INITIAL.
          CV_PROCESSED = GC_TRUE.
        ELSE.
          READ TABLE LT_ITEM_LAYOUT
                     WITH KEY T_IMAGE = ICON_LED_GREEN
                     TRANSPORTING NO FIELDS.
          IF SY-SUBRC IS INITIAL.
            CV_PROCESSED = GC_TRUE.
          ELSE.
            READ TABLE LT_ITEM_LAYOUT
                       WITH KEY T_IMAGE = SPACE
                       TRANSPORTING NO FIELDS.
            IF SY-SUBRC IS INITIAL.
              CV_PROCESSED = GC_TRUE.
            ELSE.
              APPEND LS_DLI TO LT_DLI.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
* - Try to create billing document
    IF NOT LT_DLI IS INITIAL.
      PERFORM AUTHORITY_CHECK USING    gc_actv_settle
                              CHANGING LT_DLI.
      CALL FUNCTION '/1BEA/CRMB_BD_O_CREATE'
        EXPORTING
          IT_DLI_WRK            = LT_DLI
          IS_BILL_DEFAULT       = GS_BILL_DEFAULT
          IV_PROCESS_MODE       = GC_PROC_NOADD
        IMPORTING
          ET_RETURN             = LT_RETURN.
    ENDIF.
* - Translate return table to error GUIDs
    LOOP AT lt_return INTO ls_return WHERE not row is initial.
      READ TABLE lt_dli INTO ls_dli INDEX ls_return-row.
      APPEND ls_dli-dli_guid TO lt_dli_error.
    ENDLOOP.
* new Errorhandling on GUID's
    LOOP AT lt_return INTO ls_return WHERE container = 'DLI'.
      APPEND ls_return-object_guid TO lt_dli_error.
    ENDLOOP.
    APPEND LINES OF LT_DLI_ERROR TO CT_DLI_ERROR.
* - Get data of created billing document
    CLEAR LT_BDH.
    CLEAR LT_BDI.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BUFFER_GET'
      IMPORTING
        ET_BDH_WRK               = LT_BDH
        ET_BDI_WRK               = LT_BDI.
    IF LT_BDH IS INITIAL.  "document error
      APPEND LINES OF LT_DLI_NODES TO CT_DLI_NODES.
      append lines of lt_return to ct_return.
      CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
      CONTINUE.
    ELSE.
      CALL FUNCTION 'BEA_AL_O_REFMSGS'.
      if not lt_return is initial.
        CALL FUNCTION 'BEA_AL_O_ADDMSGS'
          EXPORTING
            it_return       = lt_return.
        message s132(bea).
      endif.
*     temporary update of transfer status necessary
      LS_BDH-TRANSFER_STATUS = GC_TRANSFER_NO_UI.
      MODIFY LT_BDH FROM LS_BDH TRANSPORTING TRANSFER_STATUS
             WHERE TRANSFER_STATUS = GC_TRANSFER_NOT_REL.
      CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
        EXPORTING
          IT_BDH                   = LT_BDH
          IT_BDI                   = LT_BDI
          IV_MODE                  = GC_BD_BILL
        IMPORTING
          EV_DATA_SAVED            = LV_DATA_SAVED.
      IF NOT LV_DATA_SAVED IS INITIAL.
        APPEND LINES OF LT_DLI_NODES TO CT_DLI_NODES.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF NOT CT_RETURN IS INITIAL.
    MESSAGE S606(BEA).
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------*
*     FORM update_tree
*--------------------------------------------------------------------*
*     Update tree: Set LEDs according to processing status
*--------------------------------------------------------------------*
FORM UPDATE_TREE USING UT_DLI_NODES  TYPE LVC_T_NKEY
                       UT_DLI_ERROR  TYPE BEAT_DLI_GUID
                       uv_function   type ui_func.
*====================================================================
* Define local data
*====================================================================
  DATA:     LV_DLI_NODE              TYPE LVC_NKEY,
            LV_PARENT_NODE           TYPE LVC_NKEY,
            LT_PARENT_NODES          TYPE LVC_T_NKEY,
            LS_CHILDREN              TYPE LVC_S_NKEY,
            LT_CHILDREN              TYPE LVC_T_NKEY,
            LS_ITEM_LAYOUT           TYPE LVC_S_LAYI,
            LT_ITEM_LAYOUT           TYPE LVC_T_LAYI,
            LS_ITEM_LAYOUT_UPD       TYPE LVC_S_LACI,
            LT_ITEM_LAYOUT_UPD       TYPE LVC_T_LACI,
            LT_ITEM_LAYOUT_UPD_ERROR TYPE LVC_T_LACI,
            LT_ITEM_LAYOUT_UPD_OKAY  TYPE LVC_T_LACI,
            LT_ITEM_LAYOUT_UPD_CHECKED  TYPE LVC_T_LACI,
            LS_DLI                   TYPE /1BEA/S_CRMB_DLI_WRK,
            LS_DLI_HEAD              TYPE /1BEA/S_CRMB_DLI_WRK.
*====================================================================
* Update tree (icons and selectibility)
*====================================================================
        CLEAR LT_ITEM_LAYOUT.
        CLEAR LS_ITEM_LAYOUT_UPD.
        LS_ITEM_LAYOUT_UPD-FIELDNAME =
                      GO_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
        LS_ITEM_LAYOUT_UPD-U_T_IMAGE = GC_TRUE.
        LS_ITEM_LAYOUT_UPD-T_IMAGE = ICON_LED_GREEN.
        APPEND LS_ITEM_LAYOUT_UPD TO LT_ITEM_LAYOUT_UPD_OKAY.
        LS_ITEM_LAYOUT_UPD-T_IMAGE = ICON_LED_RED.
        APPEND LS_ITEM_LAYOUT_UPD TO LT_ITEM_LAYOUT_UPD_ERROR.
        LS_ITEM_LAYOUT_UPD-T_IMAGE = ICON_CHECKED.
        APPEND LS_ITEM_LAYOUT_UPD TO LT_ITEM_LAYOUT_UPD_CHECKED.

* Update all selected nodes of due list items
         loop at ut_dli_nodes into lv_dli_node.
           CLEAR: LT_ITEM_LAYOUT, LT_ITEM_LAYOUT_UPD.
           CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
             EXPORTING
               I_NODE_KEY     = LV_DLI_NODE
             IMPORTING
               E_OUTTAB_LINE  = LS_DLI
               ET_ITEM_LAYOUT = LT_ITEM_LAYOUT
             EXCEPTIONS
               NODE_NOT_FOUND = 1
               OTHERS         = 2.
            IF SY-SUBRC <> 0.
              MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ELSE.
              READ TABLE LT_ITEM_LAYOUT INTO LS_ITEM_LAYOUT INDEX 1.
              IF LS_ITEM_LAYOUT-T_IMAGE = SPACE.
                CONTINUE.
              ENDIF.
              IF LS_ITEM_LAYOUT-T_IMAGE = ICON_LED_YELLOW or
                 LS_ITEM_LAYOUT-T_IMAGE = ICON_CHECKED.
                read table UT_DLI_ERROR
                           with key table_line = ls_dli-dli_guid
                           transporting no fields.
                if sy-subrc is initial.
                  LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_ERROR.
                else.
                  IF uv_function <>  GC_SIMULATE.
                    LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_OKAY.
                  ELSE.
                    LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_CHECKED.
                  ENDIF.
                   IF GV_MODE = GC_DL_PROCESS.
                     LS_DLI-BILL_STATUS = GC_BILLSTAT_DONE.
                   ELSEIF    GV_MODE = GC_DL_RELEASE.
                     LS_DLI-BILL_BLOCK = GC_FALSE.
                   ELSEIF gv_mode = GC_DL_qREL.
                     LS_DLI-BILL_BLOCK = GC_FALSE.
                     IF NOT gs_bill_default IS INITIAL.
                       ls_dli-bill_type = gs_bill_default-bill_type.
                     ENDIF.
                   ENDIF.
                endif.
              ENDIF.
              IF LS_ITEM_LAYOUT-T_IMAGE = ICON_LED_RED AND
                 GV_MODE = GC_DL_ERRORLIST.
*                 mark successful reversed or cancelled entries
                read table UT_DLI_ERROR
                           with key table_line = ls_dli-dli_guid
                           transporting no fields.
                if sy-subrc is initial.
                  LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_ERROR.
                else.
                  LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_OKAY.
                endif.
              ENDIF.
              IF LS_ITEM_LAYOUT-T_IMAGE = ICON_LED_INACTIVE AND
                 GV_MODE = GC_DL_RELEASE.
*                 mark successful released entries
                read table UT_DLI_ERROR
                           with key table_line = ls_dli-dli_guid
                           transporting no fields.
                if sy-subrc is initial.
                  LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_ERROR.
                else.
                  LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_OKAY.
                endif.
              ENDIF.
              IF NOT LT_ITEM_LAYOUT_UPD IS INITIAL.
                CALL METHOD GO_ALV_TREE->CHANGE_NODE
                  EXPORTING
                    I_NODE_KEY     = LV_DLI_NODE
                    I_OUTTAB_LINE  = LS_DLI
                    IT_ITEM_LAYOUT = LT_ITEM_LAYOUT_UPD
                  EXCEPTIONS
                    NODE_NOT_FOUND = 1
                    OTHERS         = 2.
                IF SY-SUBRC <> 0.
                  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                ENDIF.
              ENDIF.
            ENDIF.
            CALL METHOD GO_ALV_TREE->GET_PARENT
              EXPORTING
                I_NODE_KEY        = LV_DLI_NODE
              IMPORTING
                E_PARENT_NODE_KEY = LV_PARENT_NODE.
            READ TABLE LT_PARENT_NODES
                       WITH KEY TABLE_LINE = LV_PARENT_NODE
                       TRANSPORTING NO FIELDS.
            IF NOT SY-SUBRC IS INITIAL.
              APPEND LV_PARENT_NODE TO LT_PARENT_NODES.
            ENDIF.
          endloop.
          LOOP AT LT_PARENT_NODES INTO LV_PARENT_NODE.
            CLEAR LT_ITEM_LAYOUT.
            CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
              EXPORTING
                I_NODE_KEY     = LV_PARENT_NODE
              IMPORTING
                E_OUTTAB_LINE  = LS_DLI_HEAD
                ET_ITEM_LAYOUT = LT_ITEM_LAYOUT
              EXCEPTIONS
                NODE_NOT_FOUND = 1
                OTHERS         = 2.
            LOOP AT LT_ITEM_LAYOUT TRANSPORTING NO FIELDS
                       WHERE T_IMAGE = ICON_LED_YELLOW
                          OR T_IMAGE = ICON_LED_INACTIVE
                          OR T_IMAGE = ICON_LED_RED
                          OR T_IMAGE = ICON_CHECKED.
              EXIT.            " = ToDos
            ENDLOOP.
            IF SY-SUBRC IS INITIAL.
              CALL METHOD GO_ALV_TREE->GET_CHILDREN
                EXPORTING
                  I_NODE_KEY  = LV_PARENT_NODE
                IMPORTING
                  ET_CHILDREN = LT_CHILDREN.
              CLEAR LT_ITEM_LAYOUT.
              LOOP AT LT_CHILDREN INTO LS_CHILDREN.
                CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
                  EXPORTING
                    I_NODE_KEY     = LS_CHILDREN-NODE_KEY
                  IMPORTING
                    E_OUTTAB_LINE  = LS_DLI
                    ET_ITEM_LAYOUT = LT_ITEM_LAYOUT
                  EXCEPTIONS
                    NODE_NOT_FOUND = 1
                    OTHERS         = 2.
                 IF SY-SUBRC <> 0.
                   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                 ENDIF.
               ENDLOOP.
               LOOP AT LT_ITEM_LAYOUT TRANSPORTING NO FIELDS
                                      WHERE T_IMAGE = ICON_LED_YELLOW
                                         OR T_IMAGE = ICON_LED_INACTIVE.
                 EXIT.            " = ToDos
               ENDLOOP.
               IF SY-SUBRC IS INITIAL. "to do item(s) exist
                 CONTINUE.
               ELSE.
                 CLEAR LT_ITEM_LAYOUT_UPD.
                 READ TABLE LT_ITEM_LAYOUT
                            WITH KEY T_IMAGE = ICON_LED_RED
                            TRANSPORTING NO FIELDS.
                 IF SY-SUBRC = 0. "error item exists
                   LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_ERROR.
                 ELSE.
                  IF uv_function <>  GC_SIMULATE.
                    LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_OKAY.
                  ELSE.
                    LT_ITEM_LAYOUT_UPD = LT_ITEM_LAYOUT_UPD_CHECKED.
                  ENDIF.
                 ENDIF.
                 CALL METHOD GO_ALV_TREE->CHANGE_NODE
                   EXPORTING
                     I_NODE_KEY     = LV_PARENT_NODE
                     I_OUTTAB_LINE  = LS_DLI_HEAD
                     IT_ITEM_LAYOUT = LT_ITEM_LAYOUT_UPD
                   EXCEPTIONS
                     NODE_NOT_FOUND = 1
                     OTHERS         = 2.
                 IF SY-SUBRC <> 0.
                   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                 ENDIF.
               ENDIF.
             ENDIF.
           ENDLOOP.

        CALL METHOD GO_ALV_TREE->UNSELECT_ALL
          EXCEPTIONS
            OTHERS        = 0.

      CALL METHOD GO_ALV_TREE->FRONTEND_UPDATE.

ENDFORM.
*--------------------------------------------------------------------*
*     FORM get_dli_to_show
*--------------------------------------------------------------------*
* Get all due list items in tree of selected node
*--------------------------------------------------------------------*
FORM GET_DLI_TO_SHOW
  USING
    UV_SELECTED_NODE TYPE LVC_NKEY
  CHANGING
    CT_DLI           TYPE /1BEA/T_CRMB_DLI_WRK
    CV_TABIX         TYPE SYTABIX.
*====================================================================
* Define local data
*====================================================================
  DATA:
    LV_PARENT_NODE   TYPE LVC_NKEY,
    LS_CHILDREN      TYPE LVC_S_NKEY,
    LT_CHILDREN      TYPE LVC_T_NKEY,
    LS_DLI_HLP       TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI           TYPE /1BEA/S_CRMB_DLI_WRK.
*====================================================================
* Get selected node and read item
*====================================================================
* Determine which item lines are belong to the same parent node.
  CALL METHOD GO_ALV_TREE->GET_PARENT
    EXPORTING
      I_NODE_KEY        = UV_SELECTED_NODE
    IMPORTING
      E_PARENT_NODE_KEY = LV_PARENT_NODE.
  IF LV_PARENT_NODE = GO_ALV_TREE->C_VIRTUAL_ROOT_NODE.
    LV_PARENT_NODE = UV_SELECTED_NODE.
  ENDIF.
  CALL METHOD GO_ALV_TREE->GET_CHILDREN
    EXPORTING
      I_NODE_KEY  = LV_PARENT_NODE
    IMPORTING
      ET_CHILDREN = LT_CHILDREN.
  LOOP AT LT_CHILDREN INTO LS_CHILDREN.
    IF LS_CHILDREN-NODE_KEY = UV_SELECTED_NODE.
      CV_TABIX = SY-TABIX.
    ENDIF.
    CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
      EXPORTING
        I_NODE_KEY     = LS_CHILDREN-NODE_KEY
      IMPORTING
        E_OUTTAB_LINE  = LS_DLI
      EXCEPTIONS
        NODE_NOT_FOUND = 1
        OTHERS         = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*     take over actual instead of converted data
      READ TABLE GT_DLI INTO LS_DLI_HLP
           WITH KEY DLI_GUID = LS_DLI-DLI_GUID.
      INSERT LS_DLI_HLP INTO TABLE CT_DLI.
    ENDIF.
  ENDLOOP.
  IF CV_TABIX IS INITIAL. "set default
    CV_TABIX = 1.
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------*
*     FORM read_item_to_node
*--------------------------------------------------------------------*
* Check if item node and read data
*--------------------------------------------------------------------*
FORM READ_ITEM_TO_NODE USING    UV_SELECTED_NODE TYPE LVC_NKEY
                       CHANGING CS_DLI
                                  TYPE /1BEA/S_CRMB_DLI_WRK.
*====================================================================
* Define local data
*====================================================================
      DATA:
            LV_PARENT_NODE          TYPE LVC_NKEY.
*====================================================================
* Check if due list doc "header" and read item
*====================================================================
            CALL METHOD GO_ALV_TREE->GET_PARENT
              EXPORTING
                I_NODE_KEY        = UV_SELECTED_NODE
              IMPORTING
                E_PARENT_NODE_KEY = LV_PARENT_NODE.
            IF LV_PARENT_NODE = GO_ALV_TREE->C_VIRTUAL_ROOT_NODE.
              MESSAGE E601(BEA).
            ELSE.  "selected node is an due list item (and no header)
              CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
                EXPORTING
                  I_NODE_KEY     = UV_SELECTED_NODE
                IMPORTING
                  E_OUTTAB_LINE  = CS_DLI
                EXCEPTIONS
                  NODE_NOT_FOUND = 1
                  OTHERS         = 2.
              IF SY-SUBRC <> 0.
                MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.
            ENDIF.
ENDFORM.
*---------------------------------------------------------------------
*       FORM authority_check
*---------------------------------------------------------------------
*       ........
*---------------------------------------------------------------------
FORM AUTHORITY_CHECK USING    UV_ACTION_TYPE TYPE ACTIV_AUTH
                     CHANGING CT_DLI TYPE /1BEA/T_CRMB_DLI_WRK.

 DATA: LS_DLI       TYPE /1BEA/S_CRMB_DLI_WRK,
       LT_DLI       TYPE /1BEA/T_CRMB_DLI_WRK,
       LV_LINES     TYPE I,
       LV_TABIX     TYPE I,
       LV_LINES_AUT TYPE I.

 LT_DLI = CT_DLI.
 LOOP AT CT_DLI INTO LS_DLI.
   LV_TABIX = SY-TABIX.
   CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
       EXPORTING
           IV_BILL_TYPE           = LS_DLI-BILL_TYPE
           IV_BILL_ORG            = LS_DLI-BILL_ORG
           IV_APPL                = GC_APPL
           IV_ACTVT               = UV_ACTION_TYPE
           IV_CHECK_DLI           = GC_TRUE
           IV_CHECK_BDH           = GC_FALSE
       EXCEPTIONS
           NO_AUTH                = 1.
    IF SY-SUBRC NE 0.
      DELETE CT_DLI INDEX LV_TABIX.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE LT_DLI LINES LV_LINES.
  DESCRIBE TABLE CT_DLI LINES LV_LINES_AUT.
  IF LV_LINES <> LV_LINES_AUT.
    MESSAGE W612(BEA).
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------
*       FORM refresh_display
*---------------------------------------------------------------------
FORM REFRESH_DISPLAY.

 DATA:
   LRT_SRC_HEADNO   TYPE RANGE OF /1BEA/CRMB_DLI-SRC_HEADNO,
   LRT_P_SRC_HEADNO   TYPE RANGE OF /1BEA/CRMB_DLI-P_SRC_HEADNO,
   LRT_SRC_USER   TYPE RANGE OF /1BEA/CRMB_DLI-SRC_USER,
   LRT_SRC_DATE   TYPE RANGE OF /1BEA/CRMB_DLI-SRC_DATE,
   LRT_BILL_ORG   TYPE RANGE OF /1BEA/CRMB_DLI-BILL_ORG,
   LRT_INVCR_DATE   TYPE RANGE OF /1BEA/CRMB_DLI-INVCR_DATE,
   LRT_PAYER   TYPE RANGE OF /1BEA/CRMB_DLI-PAYER,
   LRT_SOLD_TO_PARTY   TYPE RANGE OF /1BEA/CRMB_DLI-SOLD_TO_PARTY,
   LRT_BILL_TYPE   TYPE RANGE OF /1BEA/CRMB_DLI-BILL_TYPE,
   LRT_BILL_CATEGORY   TYPE RANGE OF /1BEA/CRMB_DLI-BILL_CATEGORY,
   LRT_BILL_STATUS TYPE BEART_BILL_STATUS,
   LRT_BILL_BLOCK  TYPE BEART_BILL_BLOCK,
   LRT_INCOMP_ID   TYPE BEART_INCOMP_ID.
 IMPORT
   LRT_SRC_HEADNO   = LRT_SRC_HEADNO
   LRT_P_SRC_HEADNO   = LRT_P_SRC_HEADNO
   LRT_SRC_USER   = LRT_SRC_USER
   LRT_SRC_DATE   = LRT_SRC_DATE
   LRT_BILL_ORG   = LRT_BILL_ORG
   LRT_INVCR_DATE   = LRT_INVCR_DATE
   LRT_PAYER   = LRT_PAYER
   LRT_SOLD_TO_PARTY   = LRT_SOLD_TO_PARTY
   LRT_BILL_TYPE   = LRT_BILL_TYPE
   LRT_BILL_CATEGORY   = LRT_BILL_CATEGORY
   LRT_BILL_STATUS = LRT_BILL_STATUS
   LRT_BILL_BLOCK  = LRT_BILL_BLOCK
   LRT_INCOMP_ID   = LRT_INCOMP_ID
   FROM MEMORY ID 'SEL_CRIT_DL'.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
           IV_SORTREL      = GC_SORT_BY_EXTERNAL_REF
           IRT_INCOMP_ID   = LRT_INCOMP_ID
           IRT_BILL_STATUS = LRT_BILL_STATUS
           IRT_BILL_BLOCK  = LRT_BILL_BLOCK
           IRT_SRC_HEADNO   = LRT_SRC_HEADNO[]
           IRT_P_SRC_HEADNO   = LRT_P_SRC_HEADNO[]
           IRT_SRC_USER   = LRT_SRC_USER[]
           IRT_SRC_DATE   = LRT_SRC_DATE[]
           IRT_BILL_ORG   = LRT_BILL_ORG[]
           IRT_INVCR_DATE   = LRT_INVCR_DATE[]
           IRT_PAYER   = LRT_PAYER[]
           IRT_SOLD_TO_PARTY   = LRT_SOLD_TO_PARTY[]
           IRT_BILL_TYPE   = LRT_BILL_TYPE[]
           IRT_BILL_CATEGORY   = LRT_BILL_CATEGORY[]
       IMPORTING
            ET_DLI      = GT_DLI.

    PERFORM AUTHORITY_CHECK USING GC_ACTV_DISPLAY
                            CHANGING GT_DLI.
* Re-build tree
  CALL METHOD go_alv_tree->delete_all_nodes
    EXCEPTIONS
      FAILED            = 1
      CNTL_SYSTEM_ERROR = 2
      others            = 3.
  IF sy-subrc <> 0.
*   internal error
  ENDIF.
  PERFORM BUILD_TREE.
ENDFORM.
*------------------------------------------------------------------*
*   FORM check_function
*------------------------------------------------------------------*
form check_function
  using
    uv_function   type ui_func
  changing
    cv_permitted  type boolean.

 data:
   lv_function             type ui_func,
   lt_selected_nodes       type lvc_t_nkey,
   lv_selected_node        type lvc_nkey,
   LRS_TV_IMAGE            TYPE BEARS_TV_IMAGE,
   LRT_TV_IMAGE            TYPE BEART_TV_IMAGE,
   LS_ITEM_LAYOUT          TYPE LVC_S_LAYI,
   lt_item_layout          type lvc_t_layi,
   lv_parent_node          type lvc_nkey,
   ls_children             type lvc_s_nkey,
   lt_children             type lvc_t_nkey,
   lv_dli_node             type lvc_nkey,
   ls_dli                  type /1BEA/S_CRMB_DLI_WRK.

  cv_permitted = gc_false.
  lrs_TV_IMAGE-sign   = gc_include.
  lrs_TV_IMAGE-option = gc_equal.
  case uv_function.
    when gc_dfl_bill_doc.
      LRS_TV_IMAGE-LOW    = ICON_LED_GREEN.
      append lrs_tv_image to lrt_tv_image.
    when GC_CANCEL_INCOMP or GC_REJECT.
      LRS_TV_IMAGE-LOW = ICON_LED_YELLOW.
      append lrs_tv_image to lrt_tv_image.
      LRS_TV_IMAGE-LOW = ICON_LED_RED.
      append lrs_tv_image to lrt_tv_image.
    when OTHERS.
      return.
  endcase.
*====================================================================
* Build up table of due list items selected for billing
*====================================================================
* Determine which line(s) are selected
  call method go_alv_tree->get_selected_nodes
    changing
      ct_selected_nodes = lt_selected_nodes.
  call method cl_gui_cfw=>flush.
  if lt_selected_nodes is initial.
    message e600(bea).
    exit.
  endif.
* Get nodes of items to be reject:
* - Get all items if header (= document) is selected
* - Get item data if item is selected
  loop at lt_selected_nodes into lv_selected_node.
    call method go_alv_tree->get_parent
      exporting
        i_node_key        = lv_selected_node
      importing
        e_parent_node_key = lv_parent_node.
    if lv_parent_node = go_alv_tree->c_virtual_root_node. " head node
      call method go_alv_tree->get_children
        exporting
          i_node_key  = lv_selected_node
        importing
          et_children = lt_children.
      loop at lt_children into ls_children.
        call method go_alv_tree->get_outtab_line
          exporting
            i_node_key     = ls_children-node_key
          importing
            e_outtab_line  = ls_dli
            et_item_layout = lt_item_layout
          exceptions
            node_not_found = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        else.
          loop at lt_item_layout into ls_item_layout
               where t_image in lrt_tv_image.
            exit.
          ENDLOOP.
          if sy-subrc is initial.
            case uv_function.
              when GC_REJECT.
                if ls_dli-incomp_id = gc_incomp_reject.
                  cv_permitted = gc_true.
                endif.
              when GC_CANCEL_INCOMP.
                if ls_dli-incomp_id = gc_incomp_cancel.
                  cv_permitted = gc_true.
                endif.
              when others.
                cv_permitted = gc_true.
            endcase.
            if cv_permitted = gc_true.
              exit.
            endif.
          endif.
        endif.
      endloop.
    else.  "= item node
*             check if not already included by selected header:
        call method go_alv_tree->get_outtab_line
          exporting
            i_node_key     = lv_selected_node "lv_dli_node
          importing
            e_outtab_line  = ls_dli
            et_item_layout = lt_item_layout
          exceptions
            node_not_found = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        else.
*         check if processed before in same session
          loop at lt_item_layout into ls_item_layout
               where t_image in lrt_tv_image.
            exit.
          ENDLOOP.
          if sy-subrc is initial.
            case uv_function.
              when GC_REJECT.
                if ls_dli-incomp_id = gc_incomp_reject.
                  cv_permitted = gc_true.
                endif.
              when GC_CANCEL_INCOMP.
                if ls_dli-incomp_id = gc_incomp_cancel.
                  cv_permitted = gc_true.
                endif.
              when others.
                cv_permitted = gc_true.
            endcase.
            if cv_permitted = gc_true.
              exit.
            endif.
          endif.
        endif.
    endif.
    if cv_permitted = gc_true.
      exit.
    endif.
  endloop.
endform.                    "CHECK_FUNCTION
*********************************************************************
* Methods
*********************************************************************

*-------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*-------------------------------------------------------------------*

CLASS LCL_TREE_EVENT_HANDLER IMPLEMENTATION.

  METHOD ON_FUNCTION_SELECTED.
*--------------------------------------------------------------------*
*     Handle toolbar functions
*--------------------------------------------------------------------*
*====================================================================
* Define local data
*====================================================================
    CONSTANTS:
      LC_AL_NO_OBJ        TYPE balsubobj   VALUE 'NO_OBJ'.
    DATA:
      LV_FCODE            TYPE UI_FUNC,
      LT_DLI_NODES        TYPE LVC_T_NKEY,
      LS_DLI_NODES        TYPE LVC_NKEY,
      LT_DLI_NODES_HLP    TYPE LVC_T_NKEY,
      LV_PROCESSED        TYPE BOOLEAN,
      lt_return           type beat_return,
      LV_NO_AUTHORITY     TYPE BEA_BOOLEAN,
      lt_dli_src_iid      TYPE /1bea/ut_CRMB_DL_DLI_SRC_IID,
      ls_dli_src_iid      TYPE /1bea/us_CRMB_DL_DLI_SRC_IID,
      LT_DLI_WRK          TYPE /1BEA/T_CRMB_DLI_WRK,
      LS_DLI              TYPE /1BEA/S_CRMB_DLI_WRK,
      LT_DLI_DET          TYPE /1BEA/T_CRMB_DLI_WRK,
      LT_BDH              TYPE /1BEA/T_CRMB_BDH_WRK,
      LS_BDH              TYPE /1BEA/S_CRMB_BDH_WRK,
      LT_BDI              TYPE /1BEA/T_CRMB_BDI_WRK,
      LS_BDI              TYPE /1BEA/S_CRMB_BDI_WRK,
      LT_DLI_ERROR        TYPE BEAT_DLI_GUID,
      lrs_crp_guid        TYPE bears_crp_guid,
      lrt_crp_guid        TYPE beart_crp_guid,
      lv_newlog           TYPE BEA_BOOLEAN,
      lv_loghndl          TYPE balloghndl,
      LV_TABIX            TYPE SYTABIX,
      LV_DATA_SAVED       TYPE BEA_BOOLEAN,
      LT_SELECTED_NODES   TYPE LVC_T_NKEY,
      LV_SELECTED_NODE    TYPE LVC_NKEY,
      LT_HEADER_NODES     TYPE LVC_T_NKEY,
      LV_LINES            TYPE I,
      lt_crp              TYPE beat_crp,
      LV_AL_MODE          TYPE BEA_AL_MODE,
      LS_DFL_DIS          TYPE BEAS_DFL_DIS,
      LV_FLT_VAL          TYPE BEA_SCENARIO,
      LRT_BDI_GUID        TYPE BEART_BDI_GUID,
      LRS_BDI_GUID        TYPE BEARS_BDI_GUID,
      LRT_BDH_GUID        TYPE BEART_BDH_GUID,
      LRS_BDH_GUID        TYPE BEARS_BDH_GUID,
      ls_return           type beas_return,
      LV_EXTNUMBER        TYPE BALNREXT,
      LV_EXTNUMBER_HLP    TYPE BALNREXT,
      LT_LOGHNDL          TYPE BAL_T_LOGH,
      LS_BALHDR           TYPE BALHDR,
      LT_BALHDR           TYPE BALHDR_T,
      lt_msgh             TYPE bal_t_msgh,
      ls_msgh             TYPE balmsghndl.
*====================================================================
* React on user button clicks in toolbar
*====================================================================
    CLEAR LT_DLI_ERROR.
    LV_FCODE = FCODE.
    CASE LV_FCODE.
*--------------------------------------------------------------------
* BILL_SINGLE
*--------------------------------------------------------------------
      WHEN GC_BILL_SINGLE.
        CLEAR gt_return.
        PERFORM BILL_SINGLE
          CHANGING
            LT_DLI_NODES
            LT_DLI_ERROR
            GV_CRP_GUID
            LV_PROCESSED
            GT_RETURN.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM UPDATE_TREE
          USING
            LT_DLI_NODES
            LT_DLI_ERROR
            LV_FCODE.
*--------------------------------------------------------------------
*   BILL_MULTIPLE
*--------------------------------------------------------------------
      WHEN GC_BILL_MULTIPLE.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_BILL_MULTIPLE
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM AUTHORITY_CHECK USING gc_actv_settle
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          CLEAR gt_return.
          CALL FUNCTION '/1BEA/CRMB_DL_O_COLL_RUN'
            EXPORTING
              IT_DLI_WRK            = LT_DLI_WRK
              IS_BILL_DEFAULT       = GS_BILL_DEFAULT
              IV_PROCESS_MODE       = GC_PROC_ADD
              IV_COMMIT             = GC_COMMIT_ASYNC
            IMPORTING
              EV_CRP_GUID           = GV_CRP_GUID
              EV_NO_AUTHORITY       = LV_NO_AUTHORITY
              ET_RETURN             = GT_RETURN
              ET_DLI_ERROR          = LT_DLI_ERROR.
          IF LV_NO_AUTHORITY = GC_TRUE.
            MESSAGE S501(BEA).
          ELSE.
            PERFORM UPDATE_TREE USING LT_DLI_NODES
                                      LT_DLI_ERROR
                                      LV_FCODE.
            if not gt_return is initial.
               message s132(bea).
            endif.
          ENDIF.
        ENDIF.
*--------------------------------------------------------------------
*   BILL_DIALOG
*--------------------------------------------------------------------
      WHEN GC_BILL_DIALOG.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_BILL_DIALOG
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM AUTHORITY_CHECK USING    gc_actv_settle
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          clear gt_return.
          CALL FUNCTION '/1BEA/CRMB_BD_O_CREATE'
            EXPORTING
              IT_DLI_WRK            = LT_DLI_WRK
              IS_BILL_DEFAULT       = GS_BILL_DEFAULT
              IV_PROCESS_MODE       = GC_PROC_NOADD
            IMPORTING
              ET_RETURN             = GT_RETURN.
          LOOP AT gt_return INTO ls_return WHERE not row is initial.
            READ TABLE lt_dli_wrk INTO ls_dli INDEX ls_return-row.
            APPEND ls_dli-dli_guid TO lt_dli_error.
          ENDLOOP.
          LOOP AT gt_return INTO ls_return WHERE container = 'DLI'.
            APPEND ls_return-object_guid TO lt_dli_error.
          ENDLOOP.
          CLEAR LT_BDH.
          CLEAR LT_BDI.
          CALL FUNCTION '/1BEA/CRMB_BD_O_BUFFER_GET'
            IMPORTING
              ET_BDH_WRK               = LT_BDH
              ET_BDI_WRK               = LT_BDI.
          IF LT_BDH IS INITIAL.
            PERFORM UPDATE_TREE USING LT_DLI_NODES
                                      LT_DLI_ERROR
                                      LV_FCODE.
            CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
            MESSAGE S606(BEA).
          ELSE.
            CALL FUNCTION 'BEA_AL_O_REFMSGS'.
            IF not gt_return is initial.
              CALL FUNCTION 'BEA_AL_O_ADDMSGS'
                EXPORTING
                  it_return       = gt_return.
               message s132(bea).
            ENDIF.
*           temporary update of transfer status necessary
            LS_BDH-TRANSFER_STATUS = GC_TRANSFER_NO_UI.
            MODIFY LT_BDH FROM LS_BDH TRANSPORTING TRANSFER_STATUS
                          WHERE TRANSFER_STATUS = GC_TRANSFER_NOT_REL.
            CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
              EXPORTING
                IT_BDH                   = LT_BDH
                IT_BDI                   = LT_BDI
                IV_MODE                  = GC_BD_BILL
              IMPORTING
                EV_DATA_SAVED            = LV_DATA_SAVED.
            IF NOT LV_DATA_SAVED IS INITIAL.
              PERFORM UPDATE_TREE USING LT_DLI_NODES
                                        LT_DLI_ERROR
                                        LV_FCODE.
            ENDIF.
          ENDIF.
        ENDIF.
*--------------------------------------------------------------------
*   RELEASE
*--------------------------------------------------------------------
      WHEN GC_RELEASE.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_RELEASE
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM AUTHORITY_CHECK USING    gc_actv_unlock
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          clear gt_return.
          CALL FUNCTION '/1BEA/CRMB_DL_O_RELEASE'
            EXPORTING
              IT_DLI_WRK           = LT_DLI_WRK
              IV_COMMIT_FLAG       = GC_COMMIT_ASYNC
              is_bill_default      = gs_bill_default
            IMPORTING
              ET_RETURN            = GT_RETURN.
          LOOP AT gt_return INTO ls_return WHERE not row is initial.
            READ TABLE lt_dli_wrk INTO ls_dli INDEX ls_return-row.
            APPEND ls_dli-dli_guid TO lt_dli_error.
          ENDLOOP.
          PERFORM UPDATE_TREE USING LT_DLI_NODES
                                    LT_DLI_ERROR
                                    LV_FCODE.
        ENDIF.
*--------------------------------------------------------------------
*   ERRORLIST
*--------------------------------------------------------------------
      WHEN GC_ERRORLIST.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_ERRORLIST
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM AUTHORITY_CHECK USING    gc_actv_unlock
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          clear gt_return.
          CALL FUNCTION '/1BEA/CRMB_DL_O_ERRORLIST'
            EXPORTING
              IT_DLI_WRK           = LT_DLI_WRK
              IV_COMMIT_FLAG       = GC_COMMIT_ASYNC
            IMPORTING
              ET_RETURN            = GT_RETURN.
          LOOP AT gt_return INTO ls_return
                  WHERE container = 'DLI'
                    AND      TYPE = GC_EMESSAGE.
            APPEND ls_return-object_guid TO lt_dli_error.
          ENDLOOP.
          PERFORM UPDATE_TREE USING LT_DLI_NODES
                                    LT_DLI_ERROR
                                    LV_FCODE.
          if not gt_return is initial.
            message s132(bea).
          endif.
        ENDIF.
*--------------------------------------------------------------------
*   SIMULATE
*--------------------------------------------------------------------
      WHEN GC_SIMULATE.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_SIMULATE
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
        PERFORM AUTHORITY_CHECK USING    gc_actv_unlock
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          clear gt_return.
          CALL FUNCTION '/1BEA/CRMB_DL_O_ERRORLIST'
            EXPORTING
              IT_DLI_WRK           = LT_DLI_WRK
              IV_COMMIT_FLAG       = GC_NOCOMMIT
              IV_PROCESS_MODE      = GC_PROC_TEST
            IMPORTING
              ET_RETURN            = GT_RETURN.
          LOOP AT gt_return INTO ls_return
                  WHERE container = 'DLI'
                    AND      TYPE = GC_EMESSAGE.
            APPEND ls_return-object_guid TO lt_dli_error.
          ENDLOOP.
          PERFORM UPDATE_TREE USING LT_DLI_NODES
                                    LT_DLI_ERROR
                                    LV_FCODE.
          if not gt_return is initial.
            message s132(bea).
          endif.
        ENDIF.
*--------------------------------------------------------------------
*   CANCEL_INCOMP
*--------------------------------------------------------------------
      WHEN GC_CANCEL_INCOMP.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_CANCEL_INCOMP
          CHANGING LT_DLI_NODES_HLP
                   LT_DLI_DET
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
*           remove entries not being considered
        LOOP AT LT_DLI_DET INTO LS_DLI
             WHERE INCOMP_ID   = GC_INCOMP_CANCEL
               AND BILL_STATUS = GC_BILLSTAT_DONE.
          READ TABLE LT_DLI_NODES_HLP INTO LS_DLI_NODES INDEX SY-TABIX.
          IF SY-SUBRC = 0.
            insert ls_dli_nodes into table lt_dli_nodes.
          ENDIF.
          INSERT LS_DLI INTO TABLE LT_DLI_WRK.
        ENDLOOP.
        PERFORM AUTHORITY_CHECK USING    gc_actv_cancel
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          clear gt_return.
          CALL FUNCTION '/1BEA/CRMB_DL_O_CANCEL_INCOMP'
            EXPORTING
              IT_DLI_WRK           = LT_DLI_WRK
              IV_COMMIT_FLAG       = GC_COMMIT_ASYNC
              IV_PROCESS_MODE      = GC_PROC_ADD
            IMPORTING
              ET_RETURN            = GT_RETURN.
          LOOP AT gt_return INTO ls_return WHERE container = 'DLI'.
            APPEND ls_return-object_guid TO lt_dli_error.
          ENDLOOP.
          PERFORM UPDATE_TREE USING LT_DLI_NODES
                                    LT_DLI_ERROR
                                    LV_FCODE.
          if not gt_return is initial.
            message s132(bea).
          endif.
        ENDIF.
*--------------------------------------------------------------------
*   REJECT
*--------------------------------------------------------------------
      WHEN GC_REJECT.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_REJECT
          CHANGING LT_DLI_NODES_HLP
                   LT_DLI_DET
                   LV_PROCESSED.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S173(BEA).
        ENDIF.
*           remove entries not being considered
        LOOP AT LT_DLI_DET INTO LS_DLI
             WHERE INCOMP_ID = GC_INCOMP_REJECT.
          READ TABLE LT_DLI_NODES_HLP INTO LS_DLI_NODES INDEX SY-TABIX.
          IF SY-SUBRC = 0.
            insert ls_dli_nodes into table lt_dli_nodes.
          ENDIF.
          INSERT LS_DLI INTO TABLE LT_DLI_WRK.
        ENDLOOP.
        PERFORM AUTHORITY_CHECK USING    GC_ACTV_CANCEL
                                CHANGING LT_DLI_WRK.
        IF NOT LT_DLI_WRK IS INITIAL.
          CLEAR GT_RETURN.
          CALL FUNCTION '/1BEA/CRMB_DL_O_REJECT_INCOMP'
            EXPORTING
              IT_DLI_WRK           = LT_DLI_WRK
              IV_COMMIT_FLAG       = GC_NOCOMMIT
              IV_PROCESS_MODE      = GC_PROC_NOADD
            IMPORTING
              ET_RETURN            = GT_RETURN.
          LOOP AT gt_return INTO ls_return WHERE container = 'DLI'.
            APPEND ls_return-object_guid TO lt_dli_error.
          ENDLOOP.
*           Get data of created billing document
          CLEAR LT_BDH.
          CLEAR LT_BDI.
          CALL FUNCTION '/1BEA/CRMB_BD_O_BUFFER_GET'
            IMPORTING
              ET_BDH_WRK               = LT_BDH
              ET_BDI_WRK               = LT_BDI.
          IF LT_BDH IS INITIAL.  "document error
            CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
            PERFORM UPDATE_TREE USING LT_DLI_NODES
                                      LT_DLI_ERROR
                                      LV_FCODE.
          ELSE.
            CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
              EXPORTING
                IT_BDH                   = LT_BDH
                IT_BDI                   = LT_BDI
                IV_MODE                  = GC_BD_DIAL_CANC
              IMPORTING
                EV_DATA_SAVED            = LV_DATA_SAVED.
            IF NOT LV_DATA_SAVED IS INITIAL.
              PERFORM UPDATE_TREE USING LT_DLI_NODES
                                        LT_DLI_ERROR
                                        LV_FCODE.
            ENDIF.
          ENDIF.
          CALL FUNCTION 'BEA_AL_O_REFMSGS'.
          IF NOT GT_RETURN IS INITIAL.
            CALL FUNCTION 'BEA_AL_O_ADDMSGS'
              EXPORTING
                IT_RETURN   =  GT_RETURN.
             MESSAGE S132(BEA).
          ENDIF.
        ENDIF.
*--------------------------------------------------------------------
*   REJECT_DL04
*--------------------------------------------------------------------
        WHEN GC_REJECT_DL04.
         PERFORM GET_DLI_TO_PROCESS
               USING GC_REJECT
            CHANGING LT_DLI_NODES_HLP
                     LT_DLI_DET
                     LV_PROCESSED.
          IF NOT LV_PROCESSED IS INITIAL.
           MESSAGE S173(BEA).
          ENDIF.
          PERFORM AUTHORITY_CHECK USING    gc_actv_cancel
                                  CHANGING LT_DLI_WRK.
          IF NOT LT_DLI_DET IS INITIAL.
            loop at lt_dli_DET into ls_dli
                 where incomp_id = gc_incomp_reject.
              clear ls_dli_src_iid.
              ls_dli_src_iid-LOGSYS = ls_dli-LOGSYS.
              ls_dli_src_iid-OBJTYPE = ls_dli-OBJTYPE.
              ls_dli_src_iid-SRC_HEADNO = ls_dli-SRC_HEADNO.
              ls_dli_src_iid-SRC_ITEMNO = ls_dli-SRC_ITEMNO.
              insert ls_dli_src_iid into table lt_dli_src_iid.
              read table lt_dli_nodes_hlp into ls_dli_nodes INDEX SY-TABIX.
              if sy-subrc = 0.
                insert ls_dli_nodes into table lt_dli_nodes.
              endif.
              INSERT LS_DLI INTO TABLE LT_DLI_WRK.
            endloop.
            clear gt_return.
            CALL FUNCTION '/1BEA/CRMB_DL_O_REJECT'
              EXPORTING
                IT_DLI_SRC_IID       = LT_DLI_SRC_IID
                IV_COMMIT_FLAG       = GC_COMMIT_ASYNC
              IMPORTING
                ET_RETURN            = GT_RETURN.
* - Translate return table to error GUIDs
* new Errorhandling on GUID's
            LOOP AT gt_return INTO ls_return
                 WHERE     CONTAINER   = 'DLI'
                   AND NOT OBJECT_GUID IS INITIAL.
              APPEND ls_return-object_guid TO lt_dli_error.
            ENDLOOP.
* - Translate return table to error GUIDs
            LOOP AT gt_return INTO ls_return WHERE not row is initial.
              READ TABLE lt_dli_wrk INTO ls_dli INDEX ls_return-row.
              APPEND ls_dli-dli_guid TO lt_dli_error.
            ENDLOOP.
            PERFORM UPDATE_TREE USING LT_DLI_NODES
                                      LT_DLI_ERROR
                                      LV_FCODE.
            if not gt_return is initial.
              message s132(bea).
            endif.
          ENDIF.
*--------------------------------------------------------------------
*   DETAIL
*--------------------------------------------------------------------
      WHEN GC_DET.
        clear lt_dli_det.
        CALL METHOD GO_ALV_TREE->GET_SELECTED_NODES
          CHANGING
            CT_SELECTED_NODES = LT_SELECTED_NODES.
        DESCRIBE TABLE LT_SELECTED_NODES LINES LV_LINES.
        IF LV_LINES <> 1.
          MESSAGE s600(BEA).
          EXIT.
        ENDIF.
        READ TABLE LT_SELECTED_NODES INTO LV_SELECTED_NODE INDEX 1.
        PERFORM GET_DLI_TO_SHOW USING    LV_SELECTED_NODE
                                CHANGING LT_DLI_DET
                                         LV_TABIX.
        CALL FUNCTION '/1BEA/CRMB_DL_U_SHOWDETAIL'
          EXPORTING
            IT_DLI   = LT_DLI_DET
            IV_FCODE = LV_FCODE
            IV_TABIX = LV_TABIX.
*--------------------------------------------------------------------
*   COLL_RUN PROTOCOL
*--------------------------------------------------------------------
      WHEN GC_COLL_RUN.
        if gv_crp_guid is initial.
          message s757(bea).
        else.
          CLEAR lrt_crp_guid.
          lrs_crp_guid-sign   = gc_include.
          lrs_crp_guid-option = gc_equal.
          lrs_crp_guid-low    = gv_crp_guid.
          append lrs_crp_guid to lrt_crp_guid.
          CALL FUNCTION 'BEA_CRP_O_GETLIST'
            EXPORTING
              IRT_CRP_GUID        = LrT_CRP_guid
            IMPORTING
              ET_CRP              = lt_crp.
          CALL FUNCTION 'BEA_CRP_U_SHOW'
            EXPORTING
              it_crp             = lt_crp
              IV_MODE            = gc_crp_nav_to_bd.
        endif.
*--------------------------------------------------------------------
*   APPL_LOG
*--------------------------------------------------------------------
      WHEN gc_appl_log.
* Search for persistent application logs
        PERFORM GET_DLI_TO_PROCESS
          USING    GC_APPL_LOG
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        LOOP AT LT_DLI_WRK INTO LS_DLI.
          CLEAR LT_BALHDR.
          CLEAR LV_EXTNUMBER.
          WRITE LS_DLI-LOGSYS TO LV_EXTNUMBER_HLP.
          CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
          WRITE LS_DLI-OBJTYPE TO LV_EXTNUMBER_HLP.
          CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
          WRITE LS_DLI-SRC_HEADNO TO LV_EXTNUMBER_HLP.
          CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
          WRITE LS_DLI-SRC_ITEMNO TO LV_EXTNUMBER_HLP.
          CONCATENATE LV_EXTNUMBER LV_EXTNUMBER_HLP INTO LV_EXTNUMBER.
          CALL FUNCTION 'BEA_AL_O_GETLIST'
            EXPORTING
              IV_APPL              = GC_APPL
              IV_DLI_GUID          = LS_DLI-DLI_GUID
              IV_EXTNUMBER         = LV_EXTNUMBER
            IMPORTING
              ET_BALHDR_T          = LT_BALHDR
            EXCEPTIONS
              LOG_NOT_FOUND        = 1
              INTERNAL_ERROR       = 2
              WRONG_INPUT          = 3
              OTHERS               = 4.
          IF SY-SUBRC <> 0.
*           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          LOOP AT lt_balhdr INTO ls_balhdr.
            INSERT ls_balhdr-log_handle INTO TABLE lt_loghndl.
          ENDLOOP.
        ENDLOOP.
* Transform dynamic messages to application log
        IF NOT GT_RETURN IS INITIAL.
          CLEAR lv_loghndl.
          CALL FUNCTION 'BEA_AL_O_GETBUFFER'
            IMPORTING
             ev_loghndl = lv_loghndl.
          IF lv_loghndl is initial.
            lv_newlog = gc_true.
            CALL FUNCTION 'BEA_AL_O_CREATE'
              EXPORTING
                iv_appl            = gc_appl
                iv_subobject       = LC_AL_NO_OBJ
              IMPORTING
                ev_loghndl         = lv_loghndl
              EXCEPTIONS
                log_already_exists = 1
                log_not_created    = 2
                OTHERS             = 3.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
          IF NOT LV_LOGHNDL IS INITIAL.
            CALL FUNCTION 'BEA_AL_O_MSGS_ADD'
              EXPORTING
                iv_loghndl   = lv_loghndl
                it_return    = gt_return
              IMPORTING
                et_msgh      = lt_msgh
              EXCEPTIONS
                error_at_add = 0
                OTHERS       = 0.
            INSERT LV_LOGHNDL INTO TABLE LT_LOGHNDL.
          ENDIF.
        ENDIF.
        if lt_loghndl is initial.
          message s199(bea).
        ELSE.
          LV_AL_MODE = GC_AL_DSP_N.
          IF GV_MODE = GC_DL_PROCESS.
            LV_AL_MODE = GC_AL_DSP_X.
          ENDIF.
          CALL FUNCTION 'BEA_AL_U_SHOW_MULTI'
            EXPORTING
              IT_LOGHNDL           = LT_LOGHNDL
              IV_MODE              = lv_al_mode
            EXCEPTIONS
              wrong_input    = 1
              no_log         = 2
              internal_error = 3
              no_authority   = 4
              OTHERS         = 5.
          IF sy-subrc <> 0.
             MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          IF not lv_newlog is initial.
             CALL FUNCTION 'BEA_AL_O_REFRESH'.
          ELSE.
            LOOP AT lt_msgh INTO ls_msgh.
              CALL FUNCTION 'BAL_LOG_MSG_DELETE'
                EXPORTING
                  i_s_msg_handle = ls_msgh
                EXCEPTIONS
                  msg_not_found  = 0
                 log_not_found  = 0
                 OTHERS         = 0.
            ENDLOOP.
          ENDIF.
        ENDIF.
*--------------------------------------------------------------------
*   SELECT ALL
*--------------------------------------------------------------------
      WHEN GC_SELECT_ALL.
        CALL METHOD GO_ALV_TREE->GET_CHILDREN
          EXPORTING
            I_NODE_KEY = CL_ALV_TREE_BASE=>C_VIRTUAL_ROOT_NODE
          IMPORTING
            ET_CHILDREN = LT_HEADER_NODES.
        CALL METHOD GO_ALV_TREE->SET_SELECTED_NODES
          EXPORTING
            IT_SELECTED_NODES = LT_HEADER_NODES.
*--------------------------------------------------------------------
*   DESELECT ALL
*--------------------------------------------------------------------
      WHEN GC_DESELECT_ALL.
        CALL METHOD GO_ALV_TREE->UNSELECT_ALL
          EXCEPTIONS
            OTHERS        = 0.
*--------------------------------------------------------------------
*   REFRESH
*--------------------------------------------------------------------
      WHEN GC_REFRESH.
        PERFORM REFRESH_DISPLAY.
*--------------------------------------------------------------------
*   Navigation: DFL_SRC_DOC
*--------------------------------------------------------------------
      WHEN GC_DFL_SRC_DOC.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_DFL_SRC_DOC
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        IF NOT LT_DLI_WRK IS INITIAL.
           IF GO_DFL_DATA IS INITIAL.
             CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
               EXPORTING
                 NULL_INSTANCE_ACCEPTED = ' '
                 EXIT_NAME              = GC_EXIT_DFL_DATA
               CHANGING
                 INSTANCE = GO_DFL_DATA
               EXCEPTIONS
                 OTHERS   = 1.
             IF SY-SUBRC <> 0.
               MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
               RETURN.
             ENDIF.
           ENDIF.
           READ TABLE LT_DLI_WRK INTO LS_DLI INDEX 1.
           MOVE-CORRESPONDING LS_DLI TO LS_DFL_DIS.
           CALL FUNCTION 'BEA_OBJ_O_GET_SCENARIO'
             EXPORTING
               IV_OBJTYPE  = LS_DFL_DIS-OBJTYPE
             IMPORTING
               EV_SCENARIO = LV_FLT_VAL.
           IF NOT LV_FLT_VAL IS INITIAL.
             CALL METHOD GO_DFL_DATA->DISPLAY
               EXPORTING
                 FLT_VAL  = LV_FLT_VAL
                 IS_DFL   = LS_DFL_DIS
               EXCEPTIONS
                 REJECT  = 1
                 OTHERS  = 2.
             IF SY-SUBRC <> 0.
               MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
               RETURN.
             ENDIF.
           ENDIF.
        ENDIF.
*--------------------------------------------------------------------
*   Navigation: DFL_BILL_DOC
*--------------------------------------------------------------------
      WHEN GC_DFL_BILL_DOC.
        PERFORM GET_DLI_TO_PROCESS
             USING GC_DFL_BILL_DOC
          CHANGING LT_DLI_NODES
                   LT_DLI_WRK
                   LV_PROCESSED.
        PERFORM AUTHORITY_CHECK USING    gc_actv_display
                                CHANGING LT_DLI_WRK.
        LOOP AT LT_DLI_WRK INTO LS_DLI.
          CALL FUNCTION '/1BEA/CRMB_DL_O_GETDETAIL'
          EXPORTING
            iv_dli_guid       = LS_DLI-DLI_GUID
          IMPORTING
            ES_DLI            = LS_DLI
          EXCEPTIONS
            NOTFOUND          = 1
            OTHERS            = 2.
          IF SY-SUBRC NE 0 OR LS_DLI-BDI_GUID IS INITIAL.
            LV_PROCESSED = GC_TRUE.
          ELSE.
            LRS_BDI_GUID-SIGN   = GC_INCLUDE.
            LRS_BDI_GUID-OPTION = GC_EQUAL.
            LRS_BDI_GUID-LOW    = LS_DLI-BDI_GUID.
            APPEND LRS_BDI_GUID TO LRT_BDI_GUID.
          ENDIF.
        ENDLOOP.
        IF LRT_BDI_GUID IS INITIAL.
          MESSAGE S144(BEA).
          EXIT.
        ENDIF.
        IF NOT LV_PROCESSED IS INITIAL.
          MESSAGE S143(BEA).
        ENDIF.
        CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
          EXPORTING
            IRT_BDI_GUID            = LRT_BDI_GUID
          IMPORTING
            ET_BDI                  = LT_BDI.
        LOOP AT LT_BDI INTO LS_BDI.
          LRS_BDH_GUID-SIGN   = GC_INCLUDE.
          LRS_BDH_GUID-OPTION = GC_EQUAL.
          LRS_BDH_GUID-LOW    = LS_BDI-BDH_GUID.
          COLLECT LRS_BDH_GUID INTO LRT_BDH_GUID.
        ENDLOOP.
        IF LRT_BDH_GUID IS INITIAL.
          MESSAGE S164(BEA).
          EXIT.
        ENDIF.
        EXPORT LRT_BDH_GUID = LRT_BDH_GUID
               TO MEMORY ID 'SEL_CRIT_BD'.
        CLEAR: LT_BDH, LT_BDI.
        CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
          EXPORTING
            IRT_BDH_BDH_GUID = LRT_BDH_GUID
          IMPORTING
            ET_BDH      = LT_BDH
            ET_BDI      = LT_BDI.
        IF NOT LT_BDH IS INITIAL.
          CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
            EXPORTING
              IT_BDH  = LT_BDH
              IT_BDI  = LT_BDI
              IV_MODE = GC_BD_PROCESS.
        ELSE.
          MESSAGE S130(BEA).
        ENDIF.
*--------------------------------------------------------------------
*   Event for OTHERS.
*--------------------------------------------------------------------
      WHEN OTHERS.   "processing further buttons via event

    ENDCASE.
  ENDMETHOD.                    "ON_FUNCTION_SELECTED

*********************************************************************
* Method Handle Node Double Click
*********************************************************************
  METHOD HANDLE_NODE_DOUBLE_CLICK.
*====================================================================
* Define local data
*====================================================================
    DATA: LV_SELECTED_NODE   TYPE LVC_NKEY,
          LT_DLI_DET         TYPE /1BEA/T_CRMB_DLI_WRK,
          LV_TABIX           TYPE SYTABIX.
*====================================================================
* Show details
*====================================================================
* import node key
    LV_SELECTED_NODE = NODE_KEY.
    clear lt_dli_det.
    PERFORM GET_DLI_TO_SHOW USING    LV_SELECTED_NODE
                            CHANGING LT_DLI_DET
                                     LV_TABIX.
    CALL FUNCTION '/1BEA/CRMB_DL_U_SHOWDETAIL'
      EXPORTING
        IT_DLI   = LT_DLI_DET
        IV_FCODE = GC_DET
        IV_TABIX = LV_TABIX.
  ENDMETHOD.                    "HANDLE_NODE_DOUBLE_CLICK
*********************************************************************
* Method Handle Node Context Menu Request
*********************************************************************
  METHOD HANDLE_NODE_CTMENU_REQUEST.
*====================================================================
* Define local data
*====================================================================
    DATA: LS_TOOLBAR     TYPE STB_BUTTON,
          LV_FUNCTION    TYPE BEA_BOOLEAN,
          LV_TEXT        TYPE GUI_TEXT,
          LV_PARENT_NODE TYPE LVC_NKEY.
*====================================================================
* Add functions to context menu
*====================================================================
    LOOP AT GT_TOOLBAR INTO LS_TOOLBAR.
      IF NOT LS_TOOLBAR-FUNCTION IS INITIAL.
        IF ( LS_TOOLBAR-FUNCTION = GC_DET )  OR
           ( LS_TOOLBAR-FUNCTION = GC_DOCFL ).
          CALL METHOD GO_ALV_TREE->GET_PARENT
            EXPORTING
              I_NODE_KEY        = NODE_KEY
            IMPORTING
              E_PARENT_NODE_KEY = LV_PARENT_NODE.
          IF LV_PARENT_NODE
                  = GO_ALV_TREE->C_VIRTUAL_ROOT_NODE. " head node
            CONTINUE.
          ENDIF.
        ENDIF.
        LV_TEXT = LS_TOOLBAR-QUICKINFO.
        CALL METHOD MENU->ADD_FUNCTION
          EXPORTING
            FCODE = LS_TOOLBAR-FUNCTION
            TEXT  = LV_TEXT.
      ELSE.
        CALL METHOD MENU->ADD_SEPARATOR.
      ENDIF.
    ENDLOOP.

* navigation event ("document flow")
    CALL METHOD MENU->ADD_SEPARATOR.
    LS_TOOLBAR-FUNCTION  = gc_dfl_src_doc.
    LV_TEXT = TEXT-PRE.
    CALL METHOD MENU->ADD_FUNCTION
      EXPORTING
        FCODE = LS_TOOLBAR-FUNCTION
        TEXT  = LV_TEXT.
    perform check_function
      using
        gc_dfl_bill_doc
      changing
        lv_function.
    IF lv_function = gc_true.
      LS_TOOLBAR-FUNCTION  = gc_dfl_bill_doc.
      LV_TEXT = TEXT-SUC.
      CALL METHOD MENU->ADD_FUNCTION
        EXPORTING
          FCODE = LS_TOOLBAR-FUNCTION
          TEXT  = LV_TEXT.
    ENDIF.
* reject and cancellation in case of incomplete entries
    IF GV_MODE = GC_DL_ERRORLIST.
      perform check_function
        using
          gc_reject
        changing
          lv_function.
      IF lv_function = gc_true.
        LS_TOOLBAR-FUNCTION  = GC_REJECT.
        LV_TEXT = TEXT-REJ.
        CALL METHOD MENU->ADD_FUNCTION
          EXPORTING
            FCODE = LS_TOOLBAR-FUNCTION
            TEXT  = LV_TEXT.
      ENDIF.
      lv_function = gc_false.
      perform check_function
        using
          gc_cancel_incomp
        changing
          lv_function.
      IF lv_function = gc_true.
        LS_TOOLBAR-FUNCTION  = GC_CANCEL_INCOMP.
        LV_TEXT = TEXT-CAN.
        CALL METHOD MENU->ADD_FUNCTION
          EXPORTING
            FCODE = LS_TOOLBAR-FUNCTION
            TEXT  = LV_TEXT.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "HANDLE_NODE_CTMENU_REQUEST
* Method Handle Node Context Menu Selected
*********************************************************************
  METHOD HANDLE_NODE_CTMENU_SELECTED.

*====================================================================
* Jump into toolbar button click treatment
*====================================================================

  CALL METHOD GO_EVENT_HANDLER->ON_FUNCTION_SELECTED
    EXPORTING
      FCODE = FCODE.

  ENDMETHOD.                    "HANDLE_NODE_CTMENU_SELECTED
*********************************************************************
* Method Handle Header Context Menu Request
*********************************************************************
  METHOD HANDLE_HEADER_CTMENU_REQUEST.

    CALL METHOD MENU->ADD_FUNCTION
      EXPORTING
        FCODE = 'F4'
        TEXT  = text-cm1.

  ENDMETHOD.                    "HANDLE_HEADER_CTMENU_REQUEST
*********************************************************************
* Method Handle Header Context Menu Select
*********************************************************************
  METHOD HANDLE_HEADER_CTMENU_SELECT.

   CONSTANTS:
     LC_V           TYPE C VALUE 'V',
     LC_F           TYPE C VALUE 'F'.
   DATA:
     LS_HELP_INFO TYPE HELP_INFO,
     LS_DYNPSELECT TYPE STANDARD TABLE OF DSELC,
     LS_DYNPVALUETAB TYPE STANDARD TABLE OF DVAL.

   IF FCODE = 'F4'.
     LS_HELP_INFO-CALL = LC_V.
     LS_HELP_INFO-OBJECT = LC_F.
     LS_HELP_INFO-TABNAME = '/1BEA/CRMB_DLI'.
     LS_HELP_INFO-FIELDNAME = FIELDNAME.

     CALL FUNCTION 'HELP_START'
       EXPORTING
         HELP_INFOS   = LS_HELP_INFO
       TABLES
         DYNPSELECT   = LS_DYNPSELECT
         DYNPVALUETAB = LS_DYNPVALUETAB.
    ENDIF.

  ENDMETHOD.                    "HANDLE_HEADER_CTMENU_SELECT
*********************************************************************
* Method Handle Expand Node Click
*********************************************************************
  METHOD HANDLE_EXPAND_NC.

    DATA:
      LS_DLI TYPE /1BEA/S_CRMB_DLI_WRK,
      LT_DLI TYPE /1BEA/T_CRMB_DLI_WRK,
      LRS_LOGSYS TYPE /1BEA/RS_CRMB_LOGSYS,
      LRT_LOGSYS TYPE /1BEA/RT_CRMB_LOGSYS,
      LRS_OBJTYPE TYPE /1BEA/RS_CRMB_OBJTYPE,
      LRT_OBJTYPE TYPE /1BEA/RT_CRMB_OBJTYPE,
      LRS_SRC_HEADNO TYPE /1BEA/RS_CRMB_SRC_HEADNO,
      LRT_SRC_HEADNO TYPE /1BEA/RT_CRMB_SRC_HEADNO,
      LRS_SRC_ITEMNO TYPE /1BEA/RS_CRMB_SRC_ITEMNO,
      LRT_SRC_ITEMNO TYPE /1BEA/RT_CRMB_SRC_ITEMNO,
      LS_MSG_VAR              TYPE BEAS_MESSAGE_VAR,
      LV_NODE_TEXT            TYPE LVC_VALUE,
      LS_NODE_LAYOUT          TYPE LVC_S_LAYN,
      LT_ITEM_LAYOUT          TYPE LVC_T_LAYI,
      LS_ITEM_LAYOUT          TYPE LVC_S_LAYI.

      CALL METHOD GO_ALV_TREE->GET_OUTTAB_LINE
        EXPORTING
          I_NODE_KEY     = NODE_KEY
        IMPORTING
          E_OUTTAB_LINE  = LS_DLI
        EXCEPTIONS
          NODE_NOT_FOUND = 1
        OTHERS         = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        LRS_LOGSYS-SIGN   = GC_INCLUDE.
        LRS_LOGSYS-OPTION = GC_EQUAL.
        LRS_LOGSYS-LOW    = LS_DLI-P_LOGSYS.
        APPEND LRS_LOGSYS TO LRT_LOGSYS.
        LRS_OBJTYPE-SIGN   = GC_INCLUDE.
        LRS_OBJTYPE-OPTION = GC_EQUAL.
        LRS_OBJTYPE-LOW    = LS_DLI-P_OBJTYPE.
        APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
        LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
        LRS_SRC_HEADNO-OPTION = GC_EQUAL.
        LRS_SRC_HEADNO-LOW    = LS_DLI-P_SRC_HEADNO.
        APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
        LRS_SRC_ITEMNO-SIGN   = GC_INCLUDE.
        LRS_SRC_ITEMNO-OPTION = GC_EQUAL.
        LRS_SRC_ITEMNO-LOW    = LS_DLI-P_SRC_ITEMNO.
        APPEND LRS_SRC_ITEMNO TO LRT_SRC_ITEMNO.
        CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
          EXPORTING
            IRT_LOGSYS = LRT_LOGSYS
            IRT_OBJTYPE = LRT_OBJTYPE
            IRT_SRC_HEADNO = LRT_SRC_HEADNO
            IRT_SRC_ITEMNO = LRT_SRC_ITEMNO
          IMPORTING
            ET_DLI         = LT_DLI.
          CLEAR LS_DLI.
          LOOP AT LT_DLI INTO LS_DLI WHERE
                             BILL_STATUS = GC_BILLSTAT_REJECT.
            DELETE TABLE LT_DLI FROM LS_DLI.
          ENDLOOP.
        IF LT_DLI IS INITIAL.
          LS_MSG_VAR-MSGV1 = GC_P_DLI_HEADNO.
          LS_MSG_VAR-MSGV2 = GC_P_DLI_ITEMNO.
          LS_MSG_VAR-MSGV3 = GC_P_DLI_P_HEADNO.
          LS_MSG_VAR-MSGV4 = GC_P_DLI_P_ITEMNO.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = LS_DLI
              IS_MSG_VAR     = LS_MSG_VAR
            IMPORTING
              ES_MSG_VAR     = LS_MSG_VAR.
           MESSAGE S175(BEA)
                   WITH LS_MSG_VAR-MSGV1 LS_MSG_VAR-MSGV2
                        LS_MSG_VAR-MSGV3 LS_MSG_VAR-MSGV4.
        ELSE.
          CLEAR LS_DLI.
          SORT LT_DLI BY INCOMP_ID.
          LOOP AT LT_DLI INTO LS_DLI.
            CLEAR LS_NODE_LAYOUT.
            LS_NODE_LAYOUT-N_IMAGE   = 'BNONE'.
            IF NOT LS_DLI-INCOMP_ID IS INITIAL OR
                   LS_DLI-BILL_STATUS = GC_BILLSTAT_REJECT.
              LS_NODE_LAYOUT-STYLE = CL_GUI_COLUMN_TREE=>STYLE_INTENSIFD_CRITICAL.
            ENDIF.
            CLEAR LT_ITEM_LAYOUT.
            LS_ITEM_LAYOUT-FIELDNAME = GO_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
            APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.
            CALL METHOD GO_ALV_TREE->ADD_NODE
              EXPORTING
                I_RELAT_NODE_KEY = NODE_KEY
                I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
                I_NODE_TEXT      = LV_NODE_TEXT
                IS_OUTTAB_LINE   = LS_DLI
                IS_NODE_LAYOUT   = LS_NODE_LAYOUT
                IT_ITEM_LAYOUT   = LT_ITEM_LAYOUT.
            INSERT LS_DLI INTO TABLE GT_DLI.
          ENDLOOP.
        ENDIF.
      ENDIF.
  ENDMETHOD.                    "HANDLE_EXPAND_NC

ENDCLASS.   " LCL_EVENT_HANDLER
