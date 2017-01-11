FUNCTION /1BEA/CRMB_BD_U_SHOW_BDH.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IO_ALV_GRID) TYPE REF TO CL_GUI_ALV_GRID OPTIONAL
*"     REFERENCE(IV_MODE) TYPE  BEA_BD_UIMODE DEFAULT 'A'
*"     REFERENCE(IS_VARIANT) TYPE  DISVARIANT OPTIONAL
*"     REFERENCE(IV_WITH_HEADER) TYPE  BEA_BOOLEAN DEFAULT SPACE
*"     REFERENCE(IV_AL_MODE) TYPE  BEA_AL_MODE DEFAULT 'A'
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
* Time  : 13:53:00
*
*======================================================================
*=====================================================================
* Define local data
*=====================================================================
  DATA: LS_LAYOUT   TYPE LVC_S_LAYO,
        LS_VARIANT  TYPE DISVARIANT,
        LT_EXCLUDE  TYPE UI_FUNCTIONS,
        ls_exclude  TYPE ui_func,
        LT_FIELDCAT TYPE LVC_T_FCAT,
        ls_fieldcat TYPE LVC_s_FCAT.
*=====================================================================
* Build ALV output table from data provided
*=====================================================================
  GT_BDH  = IT_BDH.
  GT_BDI  = IT_BDI.
  GV_MODE = IV_MODE.
  GV_AL_MODE = IV_AL_MODE.
  IF gv_mode = gc_bd_dial_canc.
     PERFORM fill_outtab_bdh_dialcanc.
  ELSEIF gv_mode = gc_bd_transfer.
     PERFORM fill_outtab_bdh_transfer.
  ELSE.
     PERFORM fill_outtab_bdh.
  ENDIF.
*=====================================================================
* If not done outside, create the ALV Grid
*=====================================================================
    IF IO_ALV_GRID IS INITIAL.
      CREATE OBJECT GO_ALV_BDH
         EXPORTING I_PARENT = CL_GUI_CONTAINER=>SCREEN0.
    ELSE.
      GO_ALV_BDH = IO_ALV_GRID.
    ENDIF.
*=====================================================================
* Exclude some irrelevant standard buttons from ALV toolbar
*=====================================================================
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_MINIMUM.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_MAXIMUM.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SUBTOT.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_VIEWS.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO LT_EXCLUDE.
*=====================================================================
* Set layout parameters title, optimum width,
* selected mode: multiple-rows
*=====================================================================
  IF NOT IV_WITH_HEADER IS INITIAL.
    LS_LAYOUT-GRID_TITLE = TEXT-T01.
    LS_LAYOUT-SMALLTITLE = GC_TRUE.
  ENDIF.
  LS_LAYOUT-CWIDTH_OPT = GC_TRUE.
  LS_LAYOUT-SEL_MODE   = GC_SEL_MULTIPLE.
  ls_layout-info_fname = 'LINECOLOR'.
  LS_LAYOUT-DETAILINIT = GC_TRUE.
*=====================================================================
* If input-parameter is_variant is initial, set minimum variant
* parameters
*=====================================================================
  IF NOT IS_VARIANT IS INITIAL.
    LS_VARIANT = IS_VARIANT.
  ELSE.
      IF NOT gv_mode = gc_bd_dial_canc.
         LS_VARIANT-REPORT = SY-REPID.
         LS_VARIANT-HANDLE = 'BDH'.
      ELSE.
         LS_VARIANT-REPORT = SY-REPID.
         LS_VARIANT-HANDLE = 'CANC'.
      ENDIF.
  ENDIF.
*=====================================================================
* Build the fieldcat according to DDIC structure
*=====================================================================
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
            I_STRUCTURE_NAME     = '/1BEA/S_CRMB_BDH'
*             I_BYPASSING_BUFFER = GC_TRUE
       CHANGING
            CT_FIELDCAT        = LT_FIELDCAT.
*....................................................................
* ICON-Field
*....................................................................
   CLEAR ls_fieldcat.
   ls_fieldcat-fieldname = 'ICONS'.
   ls_fieldcat-icon      = 'X'.
   ls_fieldcat-coltext = text-ics.
   ls_fieldcat-tooltip = text-ico.
   ls_fieldcat-seltext = text-ico.
   ls_fieldcat-datatype    = 'CHAR'.
   ls_fieldcat-outputlen    = 4.
   APPEND ls_fieldcat to lt_fieldcat.
*=====================================================================
* Call ALV grid
*=====================================================================
  CALL METHOD GO_ALV_BDH->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = LS_VARIANT
      I_SAVE               = gc_variant_all
      IS_LAYOUT            = LS_LAYOUT
      IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = LT_FIELDCAT
      IT_OUTTAB            = GT_OUTTAB_BDH.
*=====================================================================
* Set event handler for the ALV Grid
*=====================================================================
  SET HANDLER LCL_EVENT_HANDLER_BDH=>HANDLE_USER_COMMAND
              FOR GO_ALV_BDH.
  SET HANDLER LCL_EVENT_HANDLER_BDH=>HANDLE_TOOLBAR
              FOR GO_ALV_BDH.
  SET HANDLER LCL_EVENT_HANDLER_BDH=>HANDLE_CONTEXT_MENU
              FOR GO_ALV_BDH.
  SET HANDLER LCL_EVENT_HANDLER_BDH=>HANDLE_DOUBLE_CLICK
              FOR GO_ALV_BDH.
*=====================================================================
* Set toolbar for ALV grid
*=====================================================================
  CALL METHOD GO_ALV_BDH->SET_TOOLBAR_INTERACTIVE.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*       CLASS lcl_event_handler_bdh IMPLEMENTATION
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  CLASS LCL_EVENT_HANDLER_BDH IMPLEMENTATION.
**********************************************************************
* method handle_toolbar
**********************************************************************
    METHOD HANDLE_TOOLBAR.
*.....................................................................
* Data Declaration
*.....................................................................
      DATA: LS_TOOLBAR        TYPE STB_BUTTON,
            lv_function       type ui_func,
            lT_FCODES_EXCLUDE TYPE ui_functions.
*=====================================================================
* Add Elements to the Toolbar
*=====================================================================
      CLEAR GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Separator
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*---------------------------------------------------------------------
* Buttons
*---------------------------------------------------------------------
*.....................................................................
* Refresh
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_REFRESH.
      LS_TOOLBAR-ICON      = ICON_REFRESH.
      LS_TOOLBAR-QUICKINFO = TEXT-RSH.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Document View
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_DOC.
      LS_TOOLBAR-ICON      = ICON_CONTENT_OBJECT.
      IF GV_MODE = GC_BD_DISP.
        LS_TOOLBAR-QUICKINFO = TEXT-B02.
      ELSE.
        LS_TOOLBAR-QUICKINFO = TEXT-B01.
      ENDIF.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Separator
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Split Analyze
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_ANALYZE.
      LS_TOOLBAR-ICON      = ICON_COMPARE.
      LS_TOOLBAR-QUICKINFO = TEXT-SPL.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Docflow
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_DOCFL.
      LS_TOOLBAR-ICON      = ICON_TE_RECEIPTS.
      LS_TOOLBAR-QUICKINFO = TEXT-DFL.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.

*.....................................................................
* PPF activities (PPF_OVW)
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_PPF_OVW.
      LS_TOOLBAR-ICON      = ICON_MESSAGE.
      LS_TOOLBAR-QUICKINFO = TEXT-PRN.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Separator
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Transfer
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_TRANSFER.
      LS_TOOLBAR-ICON      = ICON_RELEASE.
      LS_TOOLBAR-QUICKINFO = TEXT-RLS.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Dialog Cancel
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_DIALOG_CANCEL.
      LS_TOOLBAR-ICON      = ICON_STORNO.
      LS_TOOLBAR-QUICKINFO = TEXT-CAN.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Separator
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*.....................................................................
* Protocoll - Errors in Billing (Application Log)
*             + Errors in Transfer to Accounting
*.....................................................................
      LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_BUTTON.
      LS_TOOLBAR-FUNCTION  = GC_APPLLOG.
      LS_TOOLBAR-ICON      = ICON_ERROR_PROTOCOL.
      LS_TOOLBAR-QUICKINFO = TEXT-PRO.
      APPEND LS_TOOLBAR TO GT_TOOLBAR_BDH.
      CLEAR LS_TOOLBAR.
*=====================================================================
* Exclude buttons according to the gv_mode
*=====================================================================
      IF NOT GV_MODE = GC_BD_TRANSFER.
        LV_FUNCTION = GC_TRANSFER.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
        LV_FUNCTION = GC_ACC_ERR.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
        LV_FUNCTION = GC_ACC_SIMULATE.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
        LV_FUNCTION = GC_ACC_DOC.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
      ENDIF.
      IF    gv_mode = gc_bd_bill
         OR gv_mode = gc_bd_dial_canc.
        LV_FUNCTION = gc_docfl.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
        LV_FUNCTION = gc_ppf_ovw.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
      endif.
      if not (    gv_mode = gc_bd_process
               or gv_mode = gc_bd_transfer ).
        LV_FUNCTION = gc_refresh.
        APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
      endif.
      if not gv_mode = gc_bd_process.
         LV_FUNCTION = gc_dialog_cancel.
         APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
      endif.
      if not (    gv_mode = gc_bd_process
               OR gv_mode = gc_bd_bill
               OR gv_mode = gc_bd_dial_canc
               OR gv_mode = gc_bd_transfer ) .
         LV_FUNCTION = GC_APPLLOG.
         APPEND LV_FUNCTION TO lT_FCODES_EXCLUDE.
      endif.
      LOOP AT lT_FCODES_EXCLUDE INTO LV_FUNCTION.
        DELETE GT_TOOLBAR_BDH WHERE FUNCTION = LV_FUNCTION.
      ENDLOOP.
*=====================================================================
* Dynamic Expand/Collapse toolbar functions
*=====================================================================
* Add expand/collaps function to toolbar
      CLEAR ls_toolbar.
      MOVE 0 TO ls_toolbar-butn_type.
      MOVE gc_toolbar_collexp TO ls_toolbar-function.
      if gv_tb_is_collapsed_bdh = gc_false.
        MOVE icon_collapse TO ls_toolbar-icon.
        MOVE TEXT-TBC TO ls_toolbar-quickinfo.
      else.
* Exclude Functions
        delete e_object->mt_toolbar
          where function = cl_gui_alv_grid=>MC_FC_SORT_ASC   OR
                function = cl_gui_alv_grid=>MC_FC_SORT_DSC   OR
                function = cl_gui_alv_grid=>MC_FC_FIND       OR
                function = cl_gui_alv_grid=>MC_FC_FIND_MORE  OR
                function = cl_gui_alv_grid=>MC_MB_FILTER     OR
                function = cl_gui_alv_grid=>MC_FC_SUM        OR
                function = cl_gui_alv_grid=>MC_FC_PRINT_BACK OR
                function = cl_gui_alv_grid=>MC_MB_EXPORT     OR
                function = cl_gui_alv_grid=>MC_MB_VARIANT    OR
                function = cl_gui_alv_grid=>MC_FC_INFO.
     MOVE icon_expand TO ls_toolbar-icon.
     MOVE TEXT-TBE TO ls_toolbar-quickinfo.
   endif.
   MOVE SPACE TO ls_toolbar-disabled.
   APPEND ls_toolbar TO GT_TOOLBAR_BDH.

*=====================================================================
* Fill output
*=====================================================================
      APPEND LINES OF GT_TOOLBAR_BDH TO E_OBJECT->MT_TOOLBAR.
  ENDMETHOD.                           " handle_toolbar
**********************************************************************
* METHOD handle_context_menu.
**********************************************************************
    METHOD HANDLE_CONTEXT_MENU.
*.....................................................................
* Data Declaration
*.....................................................................
      DATA: LS_TOOLBAR  TYPE STB_BUTTON,
            LV_TEXT     TYPE GUI_TEXT.
*---------------------------------------------------------------------
* Implementation
*---------------------------------------------------------------------
*.....................................................................
* Seperator
*.....................................................................
      CALL METHOD E_OBJECT->ADD_SEPARATOR.
*.....................................................................
* Add elements of toolbar (not Split Analyze, that needs two invoices)
*.....................................................................
      LOOP AT GT_TOOLBAR_BDH INTO LS_TOOLBAR
                             WHERE NOT function = gc_analyze.
        IF NOT LS_TOOLBAR-FUNCTION IS INITIAL.
          LV_TEXT = LS_TOOLBAR-QUICKINFO.
          CALL METHOD E_OBJECT->ADD_FUNCTION
            EXPORTING
              FCODE = LS_TOOLBAR-FUNCTION
              TEXT  = LV_TEXT.
        ENDIF.
      ENDLOOP.
    ENDMETHOD.                           "handle_contex_menu
**********************************************************************
* method handle_user_command
**********************************************************************
    METHOD HANDLE_USER_COMMAND.
*---------------------------------------------------------------------
* Declaration Part
*---------------------------------------------------------------------
      CONSTANTS:
        lc_fcode_dummy       TYPE syucomm VALUE 'DUMMY'.
      DATA:
        LT_ROW_NO             TYPE LVC_T_ROID,
        LS_ROW_NO             TYPE LVC_S_ROID,
        LV_LINES              TYPE I,
        LS_BDH                TYPE /1BEA/S_CRMB_BDH_WRK,
        LT_BDH                TYPE /1BEA/T_CRMB_BDH_WRK,
        LT_BDH_to_cancel      TYPE /1BEA/T_CRMB_BDH_WRK,
        LT_BDI                TYPE /1BEA/T_CRMB_BDI_WRK,
        LT_BDI_TO_BDH         TYPE /1BEA/T_CRMB_BDI_WRK,
        LT_DOCFLOW            TYPE BEAT_DFL_OUT,
        LS_BDH_L              TYPE /1BEA/S_CRMB_BDH_WRK,
        LS_BDH_R              TYPE /1BEA/S_CRMB_BDH_WRK,
        LT_SPLIT              TYPE BEAT_SPLALY,
        LS_RETURN             TYPE BEAS_RETURN,
        LT_RETURN             TYPE beat_return,
        LT_RETURN2            TYPE beat_return,
        lt_bd_guids           type BEAT_BD_GUIDS,
        lv_exit               type bea_boolean,
        lv_loghndl            type balloghndl,
        lv_newlog             type bea_boolean,
        lv_data_saved         type bea_boolean,
        lv_current_alv        TYPE REF TO cl_gui_alv_grid,
        lv_return             TYPE bea_boolean,
        LV_TITLE              TYPE BALTITLE,
        lv_action_in_show(10) TYPE c,
        lv_mode               TYPE bea_bd_uimode,
        lv_func_module        TYPE funcname,
        lv_tabix              TYPE sy-tabix.
     FIELD-SYMBOLS:
        <bdh_wrk>             TYPE /1BEA/S_CRMB_BDH_WRK.

*=====================================================================
* Implementation Part
*=====================================================================
*---------------------------------------------------------------------
* Evaluate Selection
*---------------------------------------------------------------------
*.....................................................................
* Get selected rows
*.....................................................................
      CALL METHOD GO_ALV_BDH->GET_SELECTED_ROWS
        IMPORTING
          ET_ROW_NO = LT_ROW_NO.
*....................................................................
* Delete irrelevant selection, e.g. summary line
*....................................................................
      DELETE LT_ROW_NO WHERE ROW_ID IS INITIAL.
*.....................................................................
* Determine the number of selected rows
*.....................................................................
      DESCRIBE TABLE LT_ROW_NO LINES LV_LINES.
*---------------------------------------------------------------------
* Check number of selected BDHs against user command.
*---------------------------------------------------------------------
*
*     Exactly 1 line must have been selected
      IF     E_UCOMM = GC_DOC     OR
             E_UCOMM = GC_DOCFL   OR
             E_UCOMM = GC_ACC_DOC.
        IF LV_LINES <> 1.
          MESSAGE S158(BEA).
          EXIT.
        ENDIF.
*
*     Exactly 2 lines must have been selected
      ELSEIF E_UCOMM = GC_ANALYZE.
        IF LV_LINES <> 2.
          MESSAGE S163(BEA).
          EXIT.
        ENDIF.
*
*     At least 1 line must have been selected
      ELSEIF E_UCOMM = GC_TRANSFER      OR
             E_UCOMM = GC_FCODE_CANCEL  OR
             E_UCOMM = GC_DIALOG_CANCEL OR
             E_UCOMM = GC_ACC_SIMULATE  OR
             E_UCOMM = GC_PPF_OVW.
        IF NOT LV_LINES > 0.
          MESSAGE S160(BEA).
          EXIT.
        ENDIF.
*
      ENDIF.
*.....................................................................
* Determine the selected BDHs
*.....................................................................
      CLEAR: LS_BDH,
             LT_BDH.
      LOOP AT LT_ROW_NO INTO LS_ROW_NO.
        READ TABLE GT_OUTTAB_BDH INDEX LS_ROW_NO-ROW_ID INTO LS_BDH.
        APPEND LS_BDH TO LT_BDH.
      ENDLOOP.
      IF LV_LINES = 1.
*       Supplying BDH structure for user-commands, which need exactly
*       one selected entry
        READ TABLE LT_BDH INTO LS_BDH INDEX 1.
      ENDIF.
*
**********************************************************************
* Treat button click
**********************************************************************
      CASE E_UCOMM.
*====================================================================
* Document view
*====================================================================
        WHEN GC_DOC.
          PERFORM get_bdi_to_bdh USING    ls_bdh
                                 CHANGING lt_bdi_to_bdh.
          lv_action_in_show = gv_action_in_show.
          CLEAR gv_action_in_show.
          lv_current_alv = go_alv_bdh.
          CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWDETAIL'
            EXPORTING
              IS_BDH        = LS_BDH
              IT_BDI        = LT_BDI_TO_BDH
              IV_MODE       = GV_MODE
              IV_AL_MODE    = GV_AL_MODE.
          go_alv_bdh = lv_current_alv.
          IF gv_action_in_show = gc_dialog_cancel_in_show.
             CALL METHOD cl_gui_cfw=>set_new_ok_code
                    EXPORTING new_code = lc_fcode_dummy.
          ELSEIF gv_action_in_show = gc_data_change_in_show.
             PERFORM set_for_new_display USING lt_row_no.
          ENDIF.
          gv_action_in_show = lv_action_in_show.
*====================================================================
* Document Flow
*====================================================================
        WHEN GC_DOCFL.
           CLEAR lt_docflow.
           CALL FUNCTION '/1BEA/CRMB_DL_O_DOCFL_BDH_GET'
             EXPORTING
               is_bdh          = LS_BDH
            IMPORTING
               ET_DOCFLOW      = LT_DOCFLOW
            EXCEPTIONS
              REJECT           = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            MESSAGE ID SY-MSGID TYPE gc_imessage NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            RETURN. "from method
          ELSE.
            lv_mode = gv_mode.
            CALL FUNCTION 'BEA_OBJ_U_DFL_SHOW'
              EXPORTING
                it_docflow  = LT_DOCFLOW
                IV_FB_NAME  = gc_fb_name
                IV_LEVEL    = GC_DFL_HEAD.
            gv_mode = lv_mode.
          ENDIF.
*=====================================================================
* Split analysis
*=====================================================================
        WHEN GC_ANALYZE.
          READ TABLE LT_BDH INDEX 1 INTO LS_BDH_L.
          READ TABLE LT_BDH INDEX 2 INTO LS_BDH_R.
          CALL FUNCTION '/1BEA/CRMB_BD_O_SPLIT_ANALYZE'
            EXPORTING
              IS_BDH_WRK_L = LS_BDH_L
              IS_BDH_WRK_R = LS_BDH_R
            IMPORTING
              ET_SPLIT     = LT_SPLIT.
          lv_mode = gv_mode.
          CALL FUNCTION 'BEA_OBJ_U_DOC_SPLIT_ANALYZE'
            EXPORTING
              IV_HEADNO_L   = LS_BDH_L-HEADNO_EXT
              IV_HEADNO_R   = LS_BDH_R-HEADNO_EXT
              IT_SPLIT      = LT_SPLIT.
          gv_mode = lv_mode.
*====================================================================
* Transfer to accounting
*====================================================================
        WHEN GC_TRANSFER.
          CLEAR lv_return.
            PERFORM check_for_transfer USING lt_bdh
                                       CHANGING lv_return.
            lv_func_module = '/1BEA/CRMB_BD_O_TRANSFER'.
          IF NOT lv_return IS INITIAL.
            RETURN.
          ENDIF.
          CLEAR gt_return.
          CALL FUNCTION lv_func_module
            EXPORTING
              IT_BDH         = LT_BDH
              IV_COMMIT_FLAG = GC_COMMIT_ASYNC
            IMPORTING
              ET_RETURN      = gT_RETURN.
          IF NOT gT_RETURN IS INITIAL.
            MESSAGE s132(bea).
          ENDIF.
            PERFORM update_after_transfer USING lt_bdh
                                                gt_return.
          PERFORM set_for_new_display USING lt_row_no.
*===================================================================
* Cancel the document(s) in a DIALOG mode
*===================================================================
     WHEN gc_dialog_cancel.
       LT_BDH_to_cancel = lt_bdh.
*-------------------------------------------------------------------
* Prepare the CALL CANCEL
*-------------------------------------------------------------------
       PERFORM prepare_for_cancel USING    LT_BDH_to_cancel
                                  CHANGING lt_bd_guids
                                           lv_exit.
       IF NOT lv_exit IS INITIAL.
          EXIT. "from method
       ENDIF.
*--------------------------------------------------------------------
* CALL the CANCEL function module
*--------------------------------------------------------------------
      CLEAR gt_return.
      CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
        EXPORTING
          it_bd_guids       = lt_bd_guids
          iv_cause          = gc_reversal_cancel
          iv_process_mode   = gc_proc_noadd
        IMPORTING
          et_return         = gt_return.
      CALL FUNCTION 'BEA_AL_O_REFMSGS'.
      IF NOT gt_return IS INITIAL.
         CALL FUNCTION 'BEA_AL_O_ADDMSGS'
            EXPORTING
               it_return       = gt_return.
         MESSAGE s132(bea).
      ENDIF.
*--------------------------------------------------------------------
* Get the buffer from the O-Layer for display
*--------------------------------------------------------------------
      CLEAR lt_bdh.
      CLEAR lt_bdi.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BUFFER_GET'
         IMPORTING
            ET_BDH_WRK               = LT_BDH
            ET_BDI_WRK               = LT_BDI.
      IF NOT LT_BDH IS INITIAL.
        CLEAR lv_data_saved.
*--------------------------------------------------------------------
* Display the cancelled and the newly created Cancel-Invoices
* (the latter are not yet saved)
*--------------------------------------------------------------------
        lv_current_alv = go_alv_bdh.
        lv_mode = gv_mode.
        CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWLIST'
           EXPORTING
              IT_BDH                   = LT_BDH
              IT_BDI                   = LT_BDI
              IV_MODE                  = GC_BD_dial_canc
           IMPORTING
              EV_DATA_SAVED            = LV_DATA_SAVED.
        go_alv_bdh = lv_current_alv.
*....................................................................
* Reset global variable gv_mode
*....................................................................
        gv_mode = lv_mode.
        IF NOT lv_data_saved IS INITIAL.
*--------------------------------------------------------------------
* Evaluate results
*--------------------------------------------------------------------
           PERFORM update_after_dialog_cancel USING LT_BDH_to_cancel
                                                    lt_bdh
                                                    lt_bdi.
        ENDIF.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
                    EXPORTING new_code = lc_fcode_dummy.
      ELSE.
         CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
      ENDIF.
*====================================================================
* Show the Protocol - Errors in Billing (Application Log)
*                   + Errors in Transfer to Accounting
*====================================================================
   when GC_APPLLOG.
*....................................................................
* Errors in Billing - Determine the messages to be displayed
*....................................................................
     CLEAR lt_return.
     IF    gv_mode = gc_bd_bill
        OR gv_mode = gc_bd_dial_canc.
       CALL FUNCTION 'BEA_AL_O_GETMSGS'
         IMPORTING
           et_return = lt_return.
     ELSEIF    gv_mode = gc_bd_process
            OR gv_mode = gc_bd_transfer.
       lt_return = gt_return.
     ENDIF.
*....................................................................
* Errors in Transfer - Determine the messages to be displayed
*....................................................................
     IF GV_MODE = GC_BD_PROCESS  OR
        GV_MODE = GC_BD_TRANSFER OR
        GV_MODE = GC_BD_DISP.
       DESCRIBE TABLE LT_BDH LINES LV_LINES.
       CLEAR LT_RETURN2.
       LOOP AT LT_BDH INTO LS_BDH.
         PERFORM DETERMINE_TRANSFER_ERRORS
                         USING    LS_BDH
                                  LV_LINES
                                  GC_SRV_ACC
                         CHANGING LT_RETURN2.
       ENDLOOP.
       IF NOT LT_RETURN2 IS INITIAL.
*        Errors in Transfer are available
         IF NOT LT_RETURN IS INITIAL.
*          Errors in Billing are available
           IF LV_LINES = 1.
*            Only 1 invoice selected -> Inserting of a separator message
             READ TABLE LT_BDH INTO LS_BDH INDEX 1.
             MESSAGE W767(BEA) WITH LS_BDH-HEADNO_EXT
                               INTO GV_DUMMY.
             PERFORM MSG_ADD USING    SPACE SPACE SPACE SPACE
                             CHANGING LT_RETURN.
           ENDIF.
         ENDIF.
         APPEND LINES OF LT_RETURN2 TO LT_RETURN.
       ENDIF.
     ENDIF.
     IF lt_return IS INITIAL.
       MESSAGE s199(bea).
     ELSE.
*....................................................................
* Display them
*....................................................................
       DESCRIBE TABLE LT_RETURN LINES LV_LINES.
       IF LV_LINES = 1.
*        Only 1 message!
         READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
         MESSAGE ID     LS_RETURN-ID
                 TYPE   GC_SMESSAGE
                 NUMBER LS_RETURN-NUMBER
                 WITH   LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                        LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4.
       ELSE.
*        More than 1 message!
         CLEAR lv_loghndl.
         CALL FUNCTION 'BEA_AL_O_GETBUFFER'
           IMPORTING
             ev_loghndl = lv_loghndl.
         IF lv_loghndl is initial.
           lv_newlog = gc_true.
           CALL FUNCTION 'BEA_AL_O_CREATE'
             EXPORTING
               iv_appl            = gc_appl
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
         CLEAR LV_TITLE.
         IF GV_MODE = GC_BD_TRANSFER.
           MESSAGE I754(BEA) INTO LV_TITLE.
         ENDIF.
         lv_mode = gv_mode.
         CALL FUNCTION 'BEA_AL_U_SHOW'
           EXPORTING
             iv_appl        = gc_appl
             iv_loghndl     = lv_loghndl
             it_return      = lt_return
             iv_title       = lv_title
             iv_mode        = gv_al_mode
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
         gv_mode = lv_mode.
         IF NOT lv_newlog IS INITIAL.
           CALL FUNCTION 'BEA_AL_O_REFRESH'.
         ENDIF.
       ENDIF.
     ENDIF.
*====================================================================
* Jump to PPF activities
*====================================================================
   when GC_PPF_OVW.
*....................................................................
* Start PPF activity overview in same window
*....................................................................
       lv_mode = gv_mode.
       CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_PREVIEW'
         EXPORTING
           IT_BDH = LT_BDH.
       gv_mode = lv_mode.
*====================================================================
* Refresh display
*====================================================================
        WHEN GC_REFRESH.
          DATA:
            LRT_BDH_HEADNO_EXT TYPE RANGE OF /1BEA/CRMB_BDH-HEADNO_EXT,
            LRT_BDH_PAYER TYPE RANGE OF /1BEA/CRMB_BDH-PAYER,
            LRT_BDH_BILL_DATE TYPE RANGE OF /1BEA/CRMB_BDH-BILL_DATE,
            LRT_BDH_BILL_TYPE TYPE RANGE OF /1BEA/CRMB_BDH-BILL_TYPE,
            LRT_BDH_BILL_CATEGORY TYPE RANGE OF /1BEA/CRMB_BDH-BILL_CATEGORY,
            LRT_BDH_BILL_ORG TYPE RANGE OF /1BEA/CRMB_BDH-BILL_ORG,
            LRT_BDH_MAINT_USER TYPE RANGE OF /1BEA/CRMB_BDH-MAINT_USER,
            LRT_BDH_MAINT_DATE TYPE RANGE OF /1BEA/CRMB_BDH-MAINT_DATE,
            LRT_BDI_SRC_PROCESS_TYPE TYPE RANGE OF /1BEA/CRMB_BDI-SRC_PROCESS_TYPE,
            LRT_BDI_SRC_ITEM_TYPE TYPE RANGE OF /1BEA/CRMB_BDI-SRC_ITEM_TYPE,
            LRT_BDI_SRC_HEADNO TYPE RANGE OF /1BEA/CRMB_BDI-SRC_HEADNO,
            LRT_BDI_SRC_ITEMNO TYPE RANGE OF /1BEA/CRMB_BDI-SRC_ITEMNO,
            LRT_BDI_SALES_ORG TYPE RANGE OF /1BEA/CRMB_BDI-SALES_ORG,
            LRT_BDI_DIS_CHANNEL TYPE RANGE OF /1BEA/CRMB_BDI-DIS_CHANNEL,
            LRT_BDI_SERVICE_ORG TYPE RANGE OF /1BEA/CRMB_BDI-SERVICE_ORG,
            LRT_BDI_ITEMNO_EXT TYPE RANGE OF /1BEA/CRMB_BDI-ITEMNO_EXT,
            LRT_BDI_PRODUCT_DESCR TYPE RANGE OF /1BEA/CRMB_BDI-PRODUCT_DESCR,
            LRT_BDH_GUID        TYPE BEART_BDH_GUID,
            LRT_TRANSFER_STATUS TYPE BEART_TRANSFER_STATUS.

          IMPORT
            LRT_BDH_HEADNO_EXT   = LRT_BDH_HEADNO_EXT
            LRT_BDH_PAYER   = LRT_BDH_PAYER
            LRT_BDH_BILL_DATE   = LRT_BDH_BILL_DATE
            LRT_BDH_BILL_TYPE   = LRT_BDH_BILL_TYPE
            LRT_BDH_BILL_CATEGORY   = LRT_BDH_BILL_CATEGORY
            LRT_BDH_BILL_ORG   = LRT_BDH_BILL_ORG
            LRT_BDH_MAINT_USER   = LRT_BDH_MAINT_USER
            LRT_BDH_MAINT_DATE   = LRT_BDH_MAINT_DATE
            LRT_BDI_SRC_PROCESS_TYPE   = LRT_BDI_SRC_PROCESS_TYPE
            LRT_BDI_SRC_ITEM_TYPE   = LRT_BDI_SRC_ITEM_TYPE
            LRT_BDI_SRC_HEADNO   = LRT_BDI_SRC_HEADNO
            LRT_BDI_SRC_ITEMNO   = LRT_BDI_SRC_ITEMNO
            LRT_BDI_SALES_ORG   = LRT_BDI_SALES_ORG
            LRT_BDI_DIS_CHANNEL   = LRT_BDI_DIS_CHANNEL
            LRT_BDI_SERVICE_ORG   = LRT_BDI_SERVICE_ORG
            LRT_BDI_ITEMNO_EXT   = LRT_BDI_ITEMNO_EXT
            LRT_BDI_PRODUCT_DESCR   = LRT_BDI_PRODUCT_DESCR
            LRT_BDH_GUID        = LRT_BDH_GUID
            LRT_TRANSFER_STATUS = LRT_TRANSFER_STATUS
            FROM MEMORY ID 'SEL_CRIT_BD'.
          CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
            EXPORTING
              IRT_BDH_BDH_GUID        = LRT_BDH_GUID
              IRT_BDH_TRANSFER_STATUS = LRT_TRANSFER_STATUS
              IRT_BDH_HEADNO_EXT = LRT_BDH_HEADNO_EXT[]
              IRT_BDH_PAYER = LRT_BDH_PAYER[]
              IRT_BDH_BILL_DATE = LRT_BDH_BILL_DATE[]
              IRT_BDH_BILL_TYPE = LRT_BDH_BILL_TYPE[]
              IRT_BDH_BILL_CATEGORY = LRT_BDH_BILL_CATEGORY[]
              IRT_BDH_BILL_ORG = LRT_BDH_BILL_ORG[]
              IRT_BDH_MAINT_USER = LRT_BDH_MAINT_USER[]
              IRT_BDH_MAINT_DATE = LRT_BDH_MAINT_DATE[]
              IRT_BDI_SRC_PROCESS_TYPE = LRT_BDI_SRC_PROCESS_TYPE[]
              IRT_BDI_SRC_ITEM_TYPE = LRT_BDI_SRC_ITEM_TYPE[]
              IRT_BDI_SRC_HEADNO = LRT_BDI_SRC_HEADNO[]
              IRT_BDI_SRC_ITEMNO = LRT_BDI_SRC_ITEMNO[]
              IRT_BDI_SALES_ORG = LRT_BDI_SALES_ORG[]
              IRT_BDI_DIS_CHANNEL = LRT_BDI_DIS_CHANNEL[]
              IRT_BDI_SERVICE_ORG = LRT_BDI_SERVICE_ORG[]
              IRT_BDI_ITEMNO_EXT = LRT_BDI_ITEMNO_EXT[]
              IRT_BDI_PRODUCT_DESCR = LRT_BDI_PRODUCT_DESCR[]
            IMPORTING
              ET_BDH      = GT_BDH
              ET_BDI      = GT_BDI.
        LOOP AT GT_BDH ASSIGNING <bdh_wrk>.
          lv_tabix = sy-tabix.
          CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
            EXPORTING
              IV_BILL_TYPE           = <BDH_WRK>-BILL_TYPE
              IV_BILL_ORG            = <BDH_WRK>-BILL_ORG
              IV_ACTVT               = GC_ACTV_DISPLAY
              IV_APPL                = GC_APPL
              IV_CHECK_DLI           = GC_FALSE
              IV_CHECK_BDH           = GC_TRUE
            EXCEPTIONS
              NO_AUTH                = 1.
            IF SY-SUBRC NE 0.
              DELETE GT_BDH INDEX LV_TABIX.
            ENDIF.
          ENDLOOP.

          IF gv_mode = gc_bd_dial_canc.
            PERFORM fill_outtab_bdh_dialcanc.
          ELSEIF gv_mode = gc_bd_transfer.
            PERFORM fill_outtab_bdh_transfer.
          ELSE.
            PERFORM fill_outtab_bdh.
          ENDIF.
          CALL METHOD go_alv_bdh->refresh_table_display.
*====================================================================
* Collapse/Expand Toolbar-Functions
*====================================================================
        WHEN gc_toolbar_collexp.
          if gv_tb_is_collapsed_bdh = gc_true.
            gv_tb_is_collapsed_bdh = gc_false.
          else.
            gv_tb_is_collapsed_bdh = gc_true.
          endif.
*    raise toolbar-event
          CALL METHOD go_alv_bdh->set_toolbar_interactive.
*====================================================================
* All others
*====================================================================
        WHEN OTHERS.
          CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
            EXPORTING
              NEW_CODE = E_UCOMM.
      ENDCASE.

    ENDMETHOD.                           "handle_user_command

*********************************************************************
* method handle_double_click = GC_DOC (document view)
*********************************************************************
   METHOD HANDLE_DOUBLE_CLICK.
*....................................................................
* Declaration
*....................................................................
      CONSTANTS:
            lc_fcode_dummy TYPE syucomm VALUE 'DUMMY'.
      DATA: LS_BDH         TYPE /1BEA/S_CRMB_BDH_WRK,
            LT_BDI_TO_BDH  TYPE /1BEA/T_CRMB_BDI_WRK,
            lv_current_alv TYPE REF TO cl_gui_alv_grid,
            lt_row_no      TYPE lvc_t_roid,
            lv_action_in_show(10) TYPE c.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* get selected row (double clicked)
*--------------------------------------------------------------------
      READ TABLE GT_OUTTAB_BDH INDEX E_ROW-INDEX INTO LS_BDH.
      IF SY-SUBRC <> 0.
        MESSAGE I155(BEA).
      ELSE.
        PERFORM get_bdi_to_bdh USING    ls_bdh
                               CHANGING lt_bdi_to_bdh.
          lv_action_in_show = gv_action_in_show.
          CLEAR gv_action_in_show.
          CLEAR gv_first_display.
          lv_current_alv = go_alv_bdh.
          CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWDETAIL'
            EXPORTING
              IS_BDH        = LS_BDH
              IT_BDI        = LT_BDI_TO_BDH
              IV_MODE       = GV_MODE.
          go_alv_bdh = lv_current_alv.
          IF gv_action_in_show = gc_dialog_cancel_in_show.
             CALL METHOD cl_gui_cfw=>set_new_ok_code
                    EXPORTING new_code = lc_fcode_dummy.
          ELSEIF gv_action_in_show = gc_data_change_in_show.
             PERFORM set_for_new_display USING lt_row_no.
          ENDIF.
          gv_action_in_show = lv_action_in_show.
     ENDIF.
  ENDMETHOD.                           "handle_double_click
ENDCLASS.                    "LCL_EVENT_HANDLER_BDH IMPLEMENTATION
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Form Routinen
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
**********************************************************************
*    Form  get_bdi_to_bdh
**********************************************************************
FORM get_bdi_to_bdh
    USING    us_bdh        TYPE /1BEA/S_CRMB_BDH_WRK
    CHANGING ct_bdi_to_bdh TYPE /1bea/t_CRMB_BDI_wrk.
 DATA: ls_bdi TYPE /1bea/s_CRMB_BDI_wrk.
 CLEAR ct_bdi_to_bdh.
 LOOP AT gt_bdi INTO ls_bdi WHERE bdh_guid = us_bdh-bdh_guid.
   APPEND ls_bdi TO ct_bdi_to_bdh.
 ENDLOOP.
 if sy-subrc NE 0.
    message e169(bea) with uS_BDH-headno_ext.
 endif.
ENDFORM.                    " get_bdi_to_bdh
*********************************************************************
*      Form  fill_outtab_bdh
*********************************************************************
FORM fill_outtab_bdh.
*....................................................................
* Data Declaration
*....................................................................
 DATA: ls_outtab TYPE gsy_outtab_bdh,
       ls_bdi    TYPE /1BEA/S_CRMB_BDI_wrk,
       ls_bdh    TYPE /1BEA/S_CRMB_BDH_wrk.
*====================================================================
* Implementation
*====================================================================
 CLEAR gt_outtab_bdh.
 LOOP AT gt_bdh INTO ls_bdh.
    CLEAR ls_outtab.
    MOVE-CORRESPONDING ls_bdh TO ls_outtab.
    IF    ls_outtab-cancel_flag = gc_cancel
       OR ls_outtab-cancel_flag = gc_partial_cancel.
* It is a Cancel-Invoice -> ICON_STORNO
       CONCATENATE '@BA\Q' text-sto '@' INTO ls_outtab-icons.
    ELSEIF ls_outtab-upd_type = gc_error_dial_cancel.
* There was an error at Dialog Cancel -> ICON_LED_RED
       CONCATENATE '@5C\Q' text-err '@' INTO ls_outtab-icons.
       CLEAR ls_bdh-upd_type.
       MODIFY gt_bdh FROM ls_bdh.
    ELSE.
     LOOP AT gt_bdi INTO ls_bdi
                   WHERE bdh_guid    =  ls_outtab-bdh_guid
                     AND ( is_reversed = gc_is_not_reversed OR
                           is_reversed = gc_is_reved_by_corr ).
       EXIT.
     ENDLOOP.
     IF sy-subrc <> 0.
* It is a cancelled invoice -> ICON_CANCEL
        CONCATENATE '@0W\Q' text-cac '@' INTO ls_outtab-icons.
     ELSE.
* Nothing special -> ICON_DOCUMENT
        CONCATENATE '@AR\Q' text-DO2 '@' INTO ls_outtab-icons.
     ENDIF.
   ENDIF.
   APPEND ls_outtab TO gt_outtab_bdh.
 ENDLOOP.
ENDFORM.                    "fill_outtab_bdh
*********************************************************************
*      Form  fill_outtab_bdh_dialcanc
*********************************************************************
FORM fill_outtab_bdh_dialcanc.
*....................................................................
* Data Declaration
*....................................................................
 DATA: ls_outtab       TYPE gsy_outtab_bdh,
       ls_bdh_canc     TYPE /1BEA/S_CRMB_BDH_wrk,
       ls_bdh          TYPE /1BEA/S_CRMB_BDH_wrk,
       lv_linecolor(4) TYPE c VALUE 'C300'.
*====================================================================
* Implementation
*====================================================================
 CLEAR gt_outtab_bdh.
*--------------------------------------------------------------------
* Loop at all Cancel Documents
*--------------------------------------------------------------------
 LOOP AT gt_bdh INTO ls_bdh_canc
         WHERE cancel_flag = gc_cancel
            OR cancel_flag = gc_partial_cancel.
*....................................................................
* Care about color -> Zebra
*....................................................................
    IF lv_linecolor+1(1) = '3'.
       lv_linecolor+1(1) = '2'.
    ELSE.
       lv_linecolor+1(1) = '3'.
    ENDIF.
*....................................................................
* Look for the cancelled document
*....................................................................
    READ TABLE gt_bdh INTO ls_bdh
               WITH KEY bdh_guid = ls_bdh_canc-CANC_BDH_GUID.
    IF sy-subrc NE 0.
       MESSAGE e164(bea).
    ENDIF.
    CLEAR ls_outtab.
    MOVE-CORRESPONDING ls_bdh TO ls_outtab.
* It is a cancelled invoice -> ICON_CANCEL
    CONCATENATE '@0W\Q' text-cac '@' INTO ls_outtab-icons.
    ls_outtab-linecolor = lv_linecolor.
    APPEND ls_outtab TO gt_outtab_bdh.
*....................................................................
* The Cancel Document
*....................................................................
    CLEAR ls_outtab.
    MOVE-CORRESPONDING ls_bdh_canc TO ls_outtab.
* It is a Cancel-Invoice -> ICON_STORNO
    CONCATENATE '@BA\Q' text-sto '@' INTO ls_outtab-icons.
    ls_outtab-linecolor = lv_linecolor.
    APPEND ls_outtab TO gt_outtab_bdh.
 ENDLOOP.
ENDFORM.                    "fill_outtab_bdh_dialcanc
*********************************************************************
*      FORM  update_after_dialog_cancel
*********************************************************************
FORM update_after_dialog_cancel
    USING ut_bdh_to_cancel TYPE /1BEA/T_CRMB_BDH_wrk
          ut_bdh           TYPE /1BEA/T_CRMB_BDH_wrk
          ut_bdi           TYPE /1BEA/T_CRMB_BDI_wrk.
*....................................................................
* Declaration
*....................................................................
 DATA: ls_bdh           TYPE /1BEA/S_CRMB_BDH_wrk,
       ls_bdh_to_cancel TYPE /1BEA/S_CRMB_BDH_wrk,
       ls_bdi           TYPE /1BEA/S_CRMB_BDI_wrk.
*====================================================================
* Implementation
*====================================================================
 LOOP AT ut_bdh_to_cancel INTO ls_bdh_to_cancel.
*--------------------------------------------------------------------
* Check if cancellation was succesfull
*--------------------------------------------------------------------
   READ TABLE ut_bdh INTO ls_bdh
              WITH KEY bdh_guid = ls_bdh_to_cancel-bdh_guid.
   IF sy-subrc = 0.
*--------------------------------------------------------------------
* CANCEL succesfull -> Update list_data_manager BDH and BDI
*--------------------------------------------------------------------
        PERFORM list_data_manager_modify_bdh USING ls_bdh.
        LOOP AT ut_bdi INTO ls_bdi WHERE bdh_guid = ls_bdh-bdh_guid.
           PERFORM list_data_manager_modify_bdi USING ls_bdi.
        ENDLOOP.
   ELSE.
*--------------------------------------------------------------------
* Error in CANCEL -> Update list_data_manager BDH only for ICON
*--------------------------------------------------------------------
       ls_bdh-upd_type = gc_error_dial_cancel.
       PERFORM list_data_manager_modify_bdh USING ls_bdh.
   ENDIF.
 ENDLOOP.
ENDFORM.                    " update_after_dialog_cancel
**********************************************************************
*      Form  set_for_new_display
**********************************************************************
FORM set_for_new_display USING ut_row_no TYPE lvc_t_roid.
*....................................................................
* Declaration
*....................................................................
 DATA: ls_stable TYPE lvc_s_stbl.
*====================================================================
* Implementation
*====================================================================
 ls_stable-row = gc_true.
 ls_stable-col = gc_true.
 CALL METHOD go_alv_bdh->refresh_table_display
   EXPORTING
     is_stable = ls_stable.
 IF sy-subrc <> 0.
   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 ENDIF.
 IF NOT ut_row_no IS INITIAL.
   CALL METHOD go_alv_bdh->set_selected_rows
     EXPORTING
       it_row_no = ut_row_no.
 ENDIF.
ENDFORM.                    " set_for_new_display
***********************************************************************
*      Form  prepare_for_cancel
***********************************************************************
       FORM prepare_for_cancel
            USING    ut_bdh      TYPE /1bea/t_CRMB_BDH_wrk
            CHANGING ct_bd_guids TYPE beat_bd_guids
                     cv_exit     TYPE bea_boolean.
*.....................................................................
* Data Declaration
*.....................................................................
         DATA: ls_bd_guids   TYPE beas_bd_guids,
               ls_bdh        TYPE /1bea/s_CRMB_BDH_wrk,
               ls_outtab_bdh type gsy_outtab_bdh.
*=====================================================================
* Implementation
*=====================================================================
*---------------------------------------------------------------------
* Authority Check
*---------------------------------------------------------------------
         PERFORM overall_auth_check_cancel.
*---------------------------------------------------------------------
* Check the invoices to be cancelled and build up the input for CANCEL
*---------------------------------------------------------------------
         CLEAR ct_bd_guids.
         LOOP AT ut_bdh INTO ls_bdh.
*....................................................................
* Check if not Cancel-Invoice:
*....................................................................
           IF ls_bdh-cancel_flag = gc_reversal_cancel.
             MESSAGE s200(bea).
             cv_exit = gc_true.
             EXIT. "from loop
           ENDIF.
*....................................................................
* Check if not Cancelled-Invoice:
*....................................................................
           READ TABLE gt_outtab_bdh WITH KEY bdh_guid = ls_bdh-bdh_guid
                                    INTO ls_outtab_bdh.
           IF ls_outtab_bdh-icons CS '@0W'. "ICON_CANCEL
             MESSAGE s200(bea).
             cv_exit = gc_true.
             EXIT. "from loop
           ENDIF.
*....................................................................
* Check if not signed as "archivable":
*....................................................................
           IF ls_bdh-archivable = gc_true.
             MESSAGE s239(bea) WITH ls_bdh-headno_ext.
             cv_exit = gc_true.
             EXIT. "from loop
           ENDIF.
           Clear ls_bd_guids.
           ls_bd_guids-bdh_guid = ls_bdh-bdh_guid.
           APPEND ls_bd_guids TO ct_bd_guids.
         ENDLOOP.
         IF NOT cv_exit IS INITIAL.
           EXIT. "from form
         ENDIF.
  ENDFORM.                    " prepare_for_cancel
***********************************************************************
*      Form  overall_auth_check_cancel
***********************************************************************
FORM overall_auth_check_cancel.
*----------------------------------------------------------------------
* At least one bill_type / bill_org, where the user is authorized ?
*----------------------------------------------------------------------
   CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
      iv_bill_type           = space
      iv_bill_org            = space
      iv_appl                = gc_appl
      iv_actvt               = gc_actv_cancel
      iv_check_dli           = gc_false
      iv_check_bdh           = gc_true
    EXCEPTIONS
      no_auth                = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " overall_auth_check_cancel
***********************************************************************
*      Form  update_after_transfer
***********************************************************************
FORM update_after_transfer
     USING ut_bdh    TYPE /1bea/t_CRMB_BDH_WRK
           ut_return TYPE beat_return.
*....................................................................
* Declaration
*....................................................................
  DATA: ls_bdh        TYPE /1bea/s_CRMB_BDH_WRK,
        ls_outtab_bdh TYPE gsy_outtab_bdh,
        lv_tabix      TYPE sytabix.
*====================================================================
* Implementation
*====================================================================
  LOOP AT ut_bdh INTO ls_bdh.
*--------------------------------------------------------------------
* Check if anything went wrong
*--------------------------------------------------------------------
    READ TABLE ut_return WITH KEY OBJECT_GUID = ls_bdh-bdh_guid
                         TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*....................................................................
* Update the global table of BDHs
*....................................................................
      READ TABLE gt_bdh WITH KEY bdh_guid = ls_bdh-bdh_guid
                        TRANSPORTING NO FIELDS.
      lv_tabix = sy-tabix.
      IF sy-subrc NE 0.
        MESSAGE e164(bea).
      ENDIF.
      ls_bdh-transfer_status = gc_transfer_in_work.
      CLEAR ls_bdh-transfer_error.
      CLEAR ls_bdh-mwc_error.
      MODIFY gt_bdh FROM ls_bdh INDEX lv_tabix
                    TRANSPORTING transfer_status
                                 transfer_error
                                 mwc_error
                                 .
*....................................................................
* Update the table that is displayed
*....................................................................
      READ TABLE gt_outtab_bdh WITH KEY bdh_guid = ls_bdh-bdh_guid
                               INTO ls_outtab_bdh.
      lv_tabix = sy-tabix.
      IF sy-subrc NE 0.
        MESSAGE e164(bea).
      ENDIF.
      ls_outtab_bdh-transfer_status = gc_transfer_in_work.
* Release succesfull -> ICON_LED_YELLOW
      CLEAR ls_outtab_bdh-icons.
      CONCATENATE '@5D\Q' text-rel '@' INTO ls_outtab_bdh-icons.
      CLEAR ls_outtab_bdh-transfer_error.
      CLEAR ls_outtab_bdh-mwc_error.
      MODIFY gt_outtab_bdh FROM ls_outtab_bdh INDEX lv_tabix
                           TRANSPORTING transfer_status icons
                                 transfer_error
                                 mwc_error
                                .
    ELSE. " release went wrong
*....................................................................
* Update the table that is displayed on ERROR
*....................................................................
      READ TABLE gt_outtab_bdh WITH KEY bdh_guid = ls_bdh-bdh_guid
                               INTO ls_outtab_bdh.
      lv_tabix = sy-tabix.
      IF sy-subrc NE 0.
        MESSAGE e164(bea).
      ENDIF.
* Release went wrong -> ICON_LED_RED
      CLEAR ls_outtab_bdh-icons.
      CONCATENATE '@5C\Q' text-ere '@' INTO ls_outtab_bdh-icons.
      MODIFY gt_outtab_bdh FROM ls_outtab_bdh INDEX lv_tabix
                           TRANSPORTING icons.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " update_after_transfer
*********************************************************************
*      Form  check_for_transfer
*********************************************************************
FORM check_for_transfer
     USING    ut_bdh    TYPE /1bea/t_CRMB_BDH_WRK
     CHANGING cv_return TYPE bea_boolean.
*....................................................................
* Declaration
*....................................................................
  DATA: ls_bdh TYPE /1bea/s_CRMB_BDH_WRK.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* At least one bill_type / bill_org, where the user is authorized ?
*--------------------------------------------------------------------
   LOOP AT ut_bdh INTO ls_bdh
           WHERE NOT (    transfer_status = gc_transfer_todo
                       OR transfer_status = gc_transfer_block ) .
     MESSAGE s162(bea) WITH ls_bdh-headno_ext.
     cv_return = gc_true.
     RETURN.
   ENDLOOP.
ENDFORM.                    " check_for_transfer
*********************************************************************
*      Form  fill_outtab_transfer
*********************************************************************
FORM fill_outtab_bdh_transfer.
*....................................................................
* Data Declaration
*....................................................................
 DATA: ls_outtab TYPE gsy_outtab_bdh,
       ls_bdh    TYPE /1BEA/S_CRMB_BDH_wrk.
*====================================================================
* Implementation
*====================================================================
 CLEAR gt_outtab_bdh.
 LOOP AT gt_bdh INTO ls_bdh.
    CLEAR ls_outtab.
    MOVE-CORRESPONDING ls_bdh TO ls_outtab.
    IF    ls_outtab-transfer_status = gc_transfer_block.
* It is a blocked Invoice -> ICON_LOCKED
       CONCATENATE '@06\Q' text-blo '@' INTO ls_outtab-icons.
    ELSEIF NOT ls_outtab-transfer_error IS INITIAL.
* Überleitungsfehler -> icon_red_light
       CONCATENATE '@0A\Q' text-ter '@' INTO ls_outtab-icons.
    ELSEIF NOT ls_outtab-mwc_error IS INITIAL.
* Überleitungsfehler -> icon_red_light
       CONCATENATE '@0A\Q' text-ter '@' INTO ls_outtab-icons.
    ELSE.
* Nothing special -> ICON_DOCUMENT
        CONCATENATE '@AR\Q' text-DO2 '@' INTO ls_outtab-icons.
   ENDIF.
   APPEND ls_outtab TO gt_outtab_bdh.
 ENDLOOP.
ENDFORM.                    "fill_outtab_bdh_transfer
*********************************************************************
*  FORM  DETERMINE_TRANSFER_ERRORS
*********************************************************************
*  -->  US_BDH                 Selected document header
*  -->  UV_SRV                 Calling service
*  <--  CT_RETURN              Determined transfer errors
*********************************************************************
FORM DETERMINE_TRANSFER_ERRORS
       USING    US_BDH                TYPE /1BEA/S_CRMB_BDH_WRK
                UV_LINES              TYPE I
                UV_SRV                TYPE BEF_SERVICE
       CHANGING CT_RETURN             TYPE BEAT_RETURN.
*
  DATA:
    LV_TABNAME       TYPE DDOBJNAME,
    LV_TEXT1         TYPE STRING,
    LV_TEXT2         TYPE STRING,
    LV_ITEM_ERROR    TYPE BEA_BOOLEAN,
    LRS_SEL_OPTION   TYPE SMO8SODATE,
    LRT_SEL_OPTION   TYPE SMO8SODATT,
    LV_ERR_KEY       TYPE SMOG_PKERR,
    LS_BDOC_HEADER   TYPE SMW3_FHD,
    LT_BDOC_HEADER   TYPE SMW3_FHDT,
    LS_ERROR_SEGM    TYPE SMOG_MERR,
    LV_HEADNO_EXT    TYPE BEA_HEADNO_EXT,
    LV_LINES         TYPE I,
    LV_SRV           TYPE BEF_SERVICE,
    LV_DDICTYPE      TYPE SMW3_DDIC1.
  STATICS:
    SS_BDOC_HEADER   TYPE SMW3_FHD,
    ST_ERROR_SEGM    TYPE SMW_ERRTAB,
    SR_BDOC_BODY     TYPE REF TO DATA.
  CONSTANTS:
    LC_BDOC_TYPE_STA TYPE SMOG_GNAME VALUE 'BEABILLSTACRMB'.

  FIELD-SYMBOLS <FV_SRV>             TYPE BEF_SERVICE.
  FIELD-SYMBOLS <FS_BDOC_BODY_STA>   TYPE ANY.
  FIELD-SYMBOLS <FS_BDOC_HEADER_STA> TYPE ANY.
  FIELD-SYMBOLS <FT_BDOC_HEADER_STA> TYPE TABLE.
*--------------------------------------------------------------------
* Initialization
*--------------------------------------------------------------------
  LV_TABNAME = '/1BEA/S_CRMB_BDH_WRK'.
*--------------------------------------------------------------------
* Processing selected BDH
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* Checking if preconditions are true
*--------------------------------------------------------------------

  CHECK US_BDH-MWC_ERROR IS INITIAL.
  CHECK US_BDH-PRICING_ERROR IS INITIAL.
    CHECK US_BDH-TRANSFER_STATUS = GC_TRANSFER_TODO
          AND US_BDH-TRANSFER_ERROR IS NOT INITIAL.
*--------------------------------------------------------------------
* Determining BDOC and Reading Error-Segments in Middleware
*--------------------------------------------------------------------
  LV_ERR_KEY            = US_BDH-BDH_GUID.
  LRS_SEL_OPTION-SIGN   = GC_INCLUDE.
  LRS_SEL_OPTION-OPTION = GC_GREATER_EQUAL.
  LRS_SEL_OPTION-LOW    = US_BDH-MAINT_DATE.
  APPEND LRS_SEL_OPTION TO LRT_SEL_OPTION.
* Determine BDoc
  CALL METHOD CL_SMW_BDOCSTORE=>GET_INBOUNDBDOCHEADER_BYERRKEY
    EXPORTING
      BDOC_TYPE           = LC_BDOC_TYPE_STA
      ERR_KEY             = LV_ERR_KEY
      DATE_SELECT_OPTIONS = LRT_SEL_OPTION
    IMPORTING
      BDOC_HEADERS        = LT_BDOC_HEADER.
  DESCRIBE TABLE LT_BDOC_HEADER LINES LV_LINES.
  IF LV_LINES IS INITIAL.
*   No BDoc determined
    MESSAGE E762(BEA) WITH US_BDH-HEADNO_EXT
                      INTO GV_DUMMY.
    LV_ITEM_ERROR = GC_TRUE.
  ELSE.
*   BDocs determined
    LOOP AT LT_BDOC_HEADER INTO LS_BDOC_HEADER.
      IF LS_BDOC_HEADER-BDOC_ID <> SS_BDOC_HEADER-BDOC_ID.
*       Create data type which is compatible to the current BDoc type.
        LV_DDICTYPE = LS_BDOC_HEADER-DDIC1.
        IF LV_DDICTYPE IS NOT INITIAL.
          CATCH SYSTEM-EXCEPTIONS CREATE_DATA_UNKNOWN_TYPE = 4.
            CREATE DATA SR_BDOC_BODY TYPE (LV_DDICTYPE).
          ENDCATCH.
          IF SY-SUBRC = 0.
            ASSIGN SR_BDOC_BODY->* TO <FS_BDOC_BODY_STA>.
            IF SY-SUBRC = 0.
*             Reading error segments and body of selected BDoc.
              CALL METHOD CL_SMW_BDOCSTORE=>GET_BDOC
                EXPORTING
                  BDOC_ID           = LS_BDOC_HEADER-BDOC_ID
                  GET_BODY          = GC_TRUE
                  GET_ERRORS        = GC_TRUE
                IMPORTING
                  BDOC_HEADER       = SS_BDOC_HEADER
                  BDOC_BODY         = <FS_BDOC_BODY_STA>
                  BDOC_ERRORS       = ST_ERROR_SEGM
                EXCEPTIONS
                  INVALID_BDOC_ID   = 1
                  INCONSISTENT_BODY = 2
                  FAILED            = 3
                  OTHERS            = 4.
              IF NOT SY-SUBRC IS INITIAL.
                MESSAGE ID   SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                        INTO GV_DUMMY.
                LV_ITEM_ERROR = GC_TRUE.
*               Something went wrong during the read of the mBDoc. We leave the loop without any further try.
                EXIT.
              ENDIF.
*           Assignment was not successeful, something is wrong. We set the error flag and leave
*           the loop without any further try.
            ELSE.
              MESSAGE E762(BEA) WITH US_BDH-HEADNO_EXT
                                INTO GV_DUMMY.
              LV_ITEM_ERROR = GC_TRUE.
              EXIT.
            ENDIF.
*         For the current mBDoc body structure (LV_DDICTYPE) no data type could be created, something
*         is wrong. We set the error flag and leave the loop without any further try.
          ELSE.
            MESSAGE E762(BEA) WITH US_BDH-HEADNO_EXT
                              INTO GV_DUMMY.
            LV_ITEM_ERROR = GC_TRUE.
            EXIT.
          ENDIF.
*       For the current mBDoc no body structure (LV_DDICTYPE) is available, something is wrong.
*       We set the error flag and leave the loop without any further try.
        ELSE.
          MESSAGE E762(BEA) WITH US_BDH-HEADNO_EXT
                            INTO GV_DUMMY.
          LV_ITEM_ERROR = GC_TRUE.
          EXIT.
        ENDIF.
      ELSE.
        ASSIGN SR_BDOC_BODY->* TO <FS_BDOC_BODY_STA>.
      ENDIF.
      ASSIGN COMPONENT 'BEA_BDOC_HEADER_STA' OF STRUCTURE <FS_BDOC_BODY_STA> TO <FT_BDOC_HEADER_STA>.
      IF <FT_BDOC_HEADER_STA> IS ASSIGNED.
        IF <FT_BDOC_HEADER_STA> IS NOT INITIAL.
          READ TABLE <FT_BDOC_HEADER_STA> ASSIGNING <FS_BDOC_HEADER_STA> INDEX 1.
          ASSIGN COMPONENT 'SRV' OF STRUCTURE <FS_BDOC_HEADER_STA> TO <FV_SRV>.
          IF ( <FV_SRV> IS ASSIGNED ) AND ( <FV_SRV> IS NOT INITIAL ).
            LV_SRV = <FV_SRV>.
*         Currently the mBDoc BEABILLSTACRMB is used during the processing of the 'ACC' respectively
*         the 'ICV' service; furthermore the component SRV of the mBDoc segment BEA_BDOC_HEADER_STA
*         is only set if the mBDoc is created during the processing of the 'ICV' service -> if no
*         component value can be retrieved we are in the 'ACC' scenario.
          ELSE.
            LV_SRV = GC_SRV_ACC.
          ENDIF.
        ENDIF.
*     The retrieved table structure doesn#t fit to the current mBDoc body structure (LV_DDICTYPE),
*     something is wrong. We set the error flag and leave the loop without any further try.
      ELSE.
        MESSAGE E762(BEA) WITH US_BDH-HEADNO_EXT
                          INTO GV_DUMMY.
        LV_ITEM_ERROR = GC_TRUE.
        EXIT.
      ENDIF.
*     We have found an mBDoc which has been created during processing of the same service which
*     currently is calling this form -> we can leave the loop and evaluate the error segments.
      IF LV_SRV = UV_SRV.
        EXIT.
      ENDIF.
*     We use later on the variable to decide if we have to show something or not.
      CLEAR LV_SRV.
    ENDLOOP.
  ENDIF.
  IF NOT LV_ITEM_ERROR IS INITIAL.
    PERFORM MSG_ADD USING    GC_BDH US_BDH-BDH_GUID SPACE SPACE
                    CHANGING CT_RETURN.
    EXIT.
  ENDIF.
  CHECK LV_SRV IS NOT INITIAL.
*--------------------------------------------------------------------
* Transporting Error-Segments for BDH into Return Table
*--------------------------------------------------------------------
  CLEAR LV_HEADNO_EXT.
  LOOP AT ST_ERROR_SEGM INTO  LS_ERROR_SEGM
                        WHERE ERR_KEY = US_BDH-BDH_GUID.
    IF UV_LINES <> 1. "More than 1 item selected
      IF US_BDH-HEADNO_EXT <> LV_HEADNO_EXT.
*       Header line for BDH
        MESSAGE W767(BEA) WITH US_BDH-HEADNO_EXT
                          INTO GV_DUMMY.
        PERFORM MSG_ADD USING    GC_BDH US_BDH-BDH_GUID SPACE SPACE
                        CHANGING CT_RETURN.
        LV_HEADNO_EXT = US_BDH-HEADNO_EXT.
      ENDIF.
    ENDIF.
    PERFORM APPEND_ERROR_SEGM_TO_RETURN
                   USING    LS_ERROR_SEGM
                            GC_BDH
                            US_BDH-BDH_GUID
                   CHANGING CT_RETURN.
  ENDLOOP.
  IF NOT SY-SUBRC IS INITIAL.
*   No error segments for BDH found in selected BDoc
    MESSAGE E764(BEA) WITH US_BDH-HEADNO_EXT
                           US_BDH-BDH_GUID
                      INTO GV_DUMMY.
    LV_ITEM_ERROR = GC_TRUE.
    PERFORM MSG_ADD USING    GC_BDH US_BDH-BDH_GUID SPACE SPACE
                    CHANGING CT_RETURN.
  ENDIF.
*
ENDFORM.                    "DETERMINE_TRANSFER_ERRORS
*********************************************************************
*  FORM  APPEND_ERROR_SEGM_TO_RETURN
*********************************************************************
*  -->  US_ERROR_SEGM     Error Segment
*  -->  UV_OBJECT_TYPE    Object type of BE object
*  -->  UV_OBJECT_GUID    Object GUID
*  <--  CT_RETURN         Return table with messages
*********************************************************************
FORM APPEND_ERROR_SEGM_TO_RETURN
            USING    US_ERROR_SEGM   TYPE SMOG_MERR
                     UV_OBJECT_TYPE  TYPE BEA_OBJECT_TYPE
                     UV_OBJECT_GUID  TYPE ANY
            CHANGING CT_RETURN       TYPE BEAT_RETURN.
*
  DATA:
    LV_MSGVAR1       TYPE SYMSGV,
    LV_MSGVAR2       TYPE SYMSGV,
    LV_MSGVAR3       TYPE SYMSGV,
    LV_MSGVAR4       TYPE SYMSGV,
    LV_MSGNR         TYPE MSGNR,
    LV_MESSAGE       TYPE BAPI_MSG.
*
  CONSTANTS:
    LC_BRACKET_OPEN  TYPE C VALUE '(',
    LC_BRACKET_CLOSE TYPE C VALUE ')',
    LC_SLASH         TYPE C VALUE '/'.

*--------------------------------------------------------------------
* Checking, if error message is defined in system (table T100)
*--------------------------------------------------------------------
  LV_MSGNR = US_ERROR_SEGM-NUMBER.
  CALL FUNCTION 'SWF_T100_DB_EXISTENCE_CHECK'
    EXPORTING
      ARBGB             = US_ERROR_SEGM-ID
      MSGNR             = LV_MSGNR
    EXCEPTIONS
      OBJECT_NOT_EXISTS = 1
      OTHERS            = 2.
  IF SY-SUBRC IS INITIAL.
*--------------------------------------------------------------------
*   Message exists => processing message
*--------------------------------------------------------------------
    MESSAGE ID     US_ERROR_SEGM-ID
            TYPE   US_ERROR_SEGM-TYPE
            NUMBER US_ERROR_SEGM-NUMBER
            WITH   US_ERROR_SEGM-MESSAGE_V1 US_ERROR_SEGM-MESSAGE_V2
                   US_ERROR_SEGM-MESSAGE_V3 US_ERROR_SEGM-MESSAGE_V4
            INTO   GV_DUMMY.
  ELSE.
*--------------------------------------------------------------------
*   No Message exists => only use message text
*--------------------------------------------------------------------
*   Concatenating message ID and message number to message text
    CONCATENATE US_ERROR_SEGM-MESSAGE
                LC_BRACKET_OPEN
                TEXT-MID
                US_ERROR_SEGM-ID
                LC_SLASH
                TEXT-MNR
                US_ERROR_SEGM-NUMBER
                LC_BRACKET_CLOSE
                INTO LV_MESSAGE
                SEPARATED BY SPACE.
*
    CALL FUNCTION 'BEFB_MESSAGE_TEXT_SPLIT'
      EXPORTING
        IV_TEXT    = LV_MESSAGE
      IMPORTING
        EV_MSGVAR1 = LV_MSGVAR1
        EV_MSGVAR2 = LV_MSGVAR2
        EV_MSGVAR3 = LV_MSGVAR3
        EV_MSGVAR4 = LV_MSGVAR4.
*
    MESSAGE ID     'BEA'
            TYPE   US_ERROR_SEGM-TYPE
            NUMBER '766'
            WITH   LV_MSGVAR1
                   LV_MSGVAR2
                   LV_MSGVAR3
                   LV_MSGVAR4
            INTO   GV_DUMMY.
*
  ENDIF.
*--------------------------------------------------------------------
* Add message to retrun table
*--------------------------------------------------------------------
  PERFORM MSG_ADD USING    UV_OBJECT_TYPE UV_OBJECT_GUID
                           SPACE SPACE
                  CHANGING CT_RETURN.
*
ENDFORM.                    "APPEND_ERROR_SEGM_TO_RETURN
