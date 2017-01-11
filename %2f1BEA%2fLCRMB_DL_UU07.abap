FUNCTION /1BEA/CRMB_DL_U_SHOWDETAIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_FCODE) TYPE  UI_FUNC OPTIONAL
*"     REFERENCE(IV_TABIX) TYPE  SYTABIX DEFAULT 1
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
 GT_DLI_DET       = IT_DLI.
 GV_TABIX         = IV_TABIX.

  CLEAR GS_SRV_PREPARED.

  gv_detail_tab1            = text-det.
  gv_detail_tab2            = text-par.
  gv_detail_tab3            = text-prc.
  gv_detail_tab4            = text-txt.
  gv_detail_tab9            = text-mkt.
*--------------------------------------------------------------------
* Which DLI to display?
*--------------------------------------------------------------------
  READ TABLE gt_dli_det INDEX GV_TABIX into gs_dli.
*--------------------------------------------------------------------
* Evaluate FCODE input
*--------------------------------------------------------------------
 IF IV_FCODE IS INITIAL.
   GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB1.
 ELSE.
   PERFORM eval_ptab_110 USING iv_fcode.
 ENDIF.

  CALL SCREEN 0110.

ENDFUNCTION.

*--------------------------------------------------------------------*
*      Form  SET_AND_FILL_HEADER_TAB
*--------------------------------------------------------------------*
*      text
*--------------------------------------------------------------------*
* -->  p1        text
* <--  p2        text
*--------------------------------------------------------------------*
form SET_AND_FILL_HEADER_TAB .

  DATA:
    LV_HEIGHT      TYPE I,
    LV_REUSE_DOC   TYPE BEA_BOOLEAN VALUE gc_true,
    ls_dli_dsp    TYPE /1bea/s_CRMB_DLI_dsp.

    READ TABLE gt_dli_det INDEX GV_TABIX into gs_dli.

**********************************************************************
* Detail
**********************************************************************
  IF GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB1.
       CLEAR GS_DETAIL-SUBSCREEN.  " dummy due to "event"
* Detail in dynpro (CRMB only)
       GS_DETAIL-PROG = '/1BEA/SAPLCRMB_DL_U'.
       GS_DETAIL-SUBSCREEN = '0616'.
       IF GS_SRV_PREPARED-DETAIL IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_DL_U_INT2EXT'
           EXPORTING
             is_dli     = GS_DLI
           IMPORTING
             es_dli_dsp = ls_dli_dsp.
         MOVE-CORRESPONDING ls_dli_dsp to /1BEA/S_CRMB_DLI_DSP.
         GS_SRV_PREPARED-DETAIL = GC_TRUE.
       ENDIF.
     IF GS_DETAIL-SUBSCREEN IS INITIAL.

    IF go_docking IS INITIAL.
      CALL METHOD CL_PERS_ADMIN=>GET_DATA
        EXPORTING
          P_PERS_KEY          = 'BEA_DLI_DETAIL'
          P_UNAME             = SY-UNAME
        IMPORTING
          P_PERS_DATA         = lv_height
        EXCEPTIONS
          OTHERS              = 0.
      IF LV_HEIGHT IS INITIAL.
        LV_HEIGHT = 60.   "default value
      ENDIF.
      CREATE OBJECT go_docking
                    EXPORTING
                              side      = go_docking->dock_at_top
                              extension = lv_height.
      CREATE OBJECT go_doc_cap_det
         EXPORTING background_color = gc_background_color.
      LV_REUSE_DOC = gc_false.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_DL_U_CAPTION_DLI'
      EXPORTING
        is_dli               = gs_dli
        io_gui_container     = go_docking
        IO_DD_DOCUMENT       = go_doc_cap_det
        IV_REUSE_DD_DOCUMENT = LV_REUSE_DOC.

      GS_DETAIL-PROG = 'SAPLBEA_OBJ_U'.
      GS_DETAIL-SUBSCREEN = '0100'.

      IF GS_SRV_PREPARED-DETAIL IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_DL_U_DETAIL_DLI'
          EXPORTING
            IS_DLI            = gs_dli.
        GS_SRV_PREPARED-DETAIL = GC_TRUE.
      ENDIF.

     ENDIF.
  ENDIF.

* Event for calling subscreens in other tabs
* Event DL_USD0
  INCLUDE %2f1BEA%2fX_CRMBDL_USD0_PARUDL_TAB.
  INCLUDE %2f1BEA%2fX_CRMBDL_USD0_PRCUDL_TAB.
  INCLUDE %2f1BEA%2fX_CRMBDL_USD0_TXTUDL_TAB.

  DETAIL-ACTIVETAB = GS_DETAIL-PRESSED_TAB.

ENDFORM.                    " SET_AND_FILL_HEADER_TAB
*********************************************************************
*      Form  FREE_CONTROLS_110
*********************************************************************
FORM FREE_CONTROLS_110 .
*--------------------------------------------------------------------
* Free of general stuff
*--------------------------------------------------------------------
  IF NOT GO_DOCKING IS INITIAL.
    CALL METHOD GO_DOCKING->GET_HEIGHT
      IMPORTING
        HEIGHT = gV_HEIGHT
      EXCEPTIONS
        OTHERS = 0.
    CALL METHOD CL_PERS_ADMIN=>SET_DATA
      EXPORTING
        P_PERS_KEY  = 'BEA_DLI_DETAIL'
        P_UNAME     = SY-UNAME
        P_PERS_DATA = gV_HEIGHT
      EXCEPTIONS
        OTHERS      = 0.
    CALL METHOD GO_DOCKING->FREE.
    FREE GO_DOCKING.
  ENDIF.
* Event for further initializing screens and data
* Event DL_USD1
  INCLUDE %2f1BEA%2fX_CRMBDL_USD1_PRCUDL_INI.
  INCLUDE %2f1BEA%2fX_CRMBDL_USD1_TXTUDL_INI.
ENDFORM.                    " FREE_CONTROLS_110
*--------------------------------------------------------------------*
*      Form  USER_COMMAND_110
*--------------------------------------------------------------------*
*      text
*--------------------------------------------------------------------*
FORM USER_COMMAND_110.

 DATA: LV_OKCODE TYPE SYUCOMM.

   LV_OKCODE = GV_OKCODE110.
   CLEAR GV_OKCODE110.
   CASE LV_OKCODE.
    WHEN 'BACK'.
      PERFORM FREE_CONTROLS_110.
      LEAVE TO SCREEN 0.
    WHEN GC_PREV.
      GV_TABIX = GV_TABIX - 1.
      CLEAR GS_SRV_PREPARED.
    WHEN GC_NEXT.
      GV_TABIX = GV_TABIX + 1.
      CLEAR GS_SRV_PREPARED.
  ENDCASE.

* Event for further processing (refresh etc.)
* Event DL_USD2
  INCLUDE %2f1BEA%2fX_CRMBDL_USD2_PRCUDL_RFR.

ENDFORM.                    " USER_COMMAND_110

*--------------------------------------------------------------------*
*      Form  USER_COMMAND_AT_EXIT_110
*--------------------------------------------------------------------*
*      text
*--------------------------------------------------------------------*
FORM USER_COMMAND_AT_EXIT_110.

  DATA: LV_OKCODE TYPE SYUCOMM.

  LV_OKCODE = GV_OKCODE110.
  CLEAR GV_OKCODE110.
  CASE LV_OKCODE.
    WHEN 'CANC'.
      PERFORM FREE_CONTROLS_110.
      LEAVE TO SCREEN 0.
      CLEAR GV_OKCODE110.
    WHEN 'EXIT'.
      PERFORM FREE_CONTROLS_110.
      LEAVE TO SCREEN 0.
      CLEAR GV_OKCODE110.
  ENDCASE.

ENDFORM.                    " USER_COMMAND_AT_EXIT_110

*--------------------------------------------------------------------*
*      Form  STATUS_110
*--------------------------------------------------------------------*
*      text
*--------------------------------------------------------------------*
* -->  p1        text
* <--  p2        text
*--------------------------------------------------------------------*
FORM status_110 .

 DATA:
   LT_FCODE       TYPE TABLE OF SYUCOMM,
   LV_LINES       TYPE I.

   clear lt_fcode[].
   DESCRIBE TABLE GT_DLI_DET LINES lv_Lines.
   IF GV_TABIX = 1.
     APPEND GC_PREV TO lt_fcode.
   ENDIF.
   IF GV_TABIX = LV_LINES.
     APPEND GC_NEXT TO lt_fcode.
   ENDIF.
  SET PF-STATUS 'DL_ITEM_DETAIL' OF PROGRAM GC_PROG_STAT_TITLE
      EXCLUDING lt_fcode.
  SET TITLEBAR 'DL_ITEM_DETAIL' OF PROGRAM GC_PROG_STAT_TITLE.

* disable all but detail tab (must be activated in subscription)
    LOOP AT SCREEN.
      screen-active = 0.
      IF screen-name = 'GV_DETAIL_TAB1'.
        screen-active = 1.
      ENDIF.
* Event for calling subscreens in other tabs
* Event DL_USD3
  INCLUDE %2f1BEA%2fX_CRMBDL_USD3_PARUDL_STA.
  INCLUDE %2f1BEA%2fX_CRMBDL_USD3_PRCUDL_STA.
  INCLUDE %2f1BEA%2fX_CRMBDL_USD3_TXTUDL_STA.
      MODIFY SCREEN.
    ENDLOOP.

ENDFORM.                    " STATUS_110
*********************************************************************
*     FORM  eval_ptab_110
*********************************************************************
FORM eval_ptab_110 USING uv_fcode TYPE UI_FUNC.
*....................................................................
* Declaration
*....................................................................
 DATA: ls_itc TYPE beas_itc_wrk.
*====================================================================
* Implementation
*====================================================================
 GS_DETAIL-OLD_TAB = GS_DETAIL-PRESSED_TAB.
 CLEAR GS_DETAIL-PRESSED_TAB.
 IF uv_fcode is initial or uv_fcode = 'DETAIL'.
   GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB1. "Detail is default
 ENDIF.
 IF    uv_fcode = 'PAR'
    OR uv_fcode = 'PRC'
    OR uv_fcode = 'TXT'.
   CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
     EXPORTING
       iv_appl                = gc_appl
       iv_itc                 = gs_dli-ITEM_CATEGORY
     IMPORTING
       ES_ITC_WRK             = ls_itc
     EXCEPTIONS
       object_not_found = 1
       OTHERS           = 2.
   IF sy-subrc <> 0.
     GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   CASE uV_FCODE.
     WHEN 'PAR'.
         GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB2.
     WHEN 'PRC'.
       IF ls_itc-DLI_PRC_PROC IS NOT INITIAL OR
       ls_itc-DLI_PRICING_TYPE IS NOT INITIAL.
         GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB3.
       ELSE.
         GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
         MESSAGE W807(bea) WITH gs_dli-ITEM_CATEGORY text-prc.
       ENDIF.
     WHEN 'TXT'.
       IF NOT ls_itc-dlI_TXT_PROC IS INITIAL.
         GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB4.
       ELSE.
         GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
         MESSAGE W808(bea) WITH gs_dli-ITEM_CATEGORY text-txt.
       ENDIF.
     ENDCASE.
 ENDIF.
 IF GS_DETAIL-PRESSED_TAB IS INITIAL.
   GS_DETAIL-PRESSED_TAB = UV_FCODE.
 ENDIF.
ENDFORM.                    " eval_ptab_110
*********************************************************************
*     FORM  detail_active_tab_get
*********************************************************************
FORM detail_active_tab_get.
*....................................................................
* Declaration
*....................................................................
  DATA: lv_fcode TYPE ui_func.
*====================================================================
* Implementation
*====================================================================
   CASE GV_OKCODE110.
     WHEN GC_DETAIL-TAB1.
       lv_fcode = 'DETAIL'.
     WHEN GC_DETAIL-TAB2.
       lv_fcode = 'PAR'.
     WHEN GC_DETAIL-TAB3.
       lv_fcode = 'PRC'.
     WHEN GC_DETAIL-TAB4.
       lv_fcode = 'TXT'.
     WHEN GC_DETAIL-TAB5.
       lv_fcode = GC_DETAIL-TAB5.
     WHEN GC_DETAIL-TAB6.
       lv_fcode = GC_DETAIL-TAB6.
     WHEN GC_DETAIL-TAB7.
       lv_fcode = GC_DETAIL-TAB7.
   ENDCASE.
   IF NOT lv_fcode IS INITIAL.
     PERFORM eval_ptab_110 USING lv_fcode.
   ENDIF.
ENDFORM. " detail_active_tab_get.
*---------------------------------------------------------------------
*       Module  STATUS_110  OUTPUT
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------
MODULE STATUS_110 OUTPUT.
  PERFORM status_110.
ENDMODULE.                 " STATUS_110  OUTPUT

*---------------------------------------------------------------------
*      Module  detail_active_tab_set  OUTPUT
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------
MODULE DETAIL_ACTIVE_TAB_SET OUTPUT.
  perform SET_AND_FILL_HEADER_TAB.
ENDMODULE.                " DETAIL_ACTIVE_TAB_SET OUTPUT.

*********************************************************************
*      Module  detail_active_tab_get  INPUT
*********************************************************************
MODULE DETAIL_ACTIVE_TAB_GET INPUT.

  PERFORM detail_active_tab_get.

ENDMODULE.                 " detail_active_tab_get  INPUT

*---------------------------------------------------------------------
*      Module  user_command_110  INPUT
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------
MODULE USER_COMMAND_110 INPUT.

  PERFORM USER_COMMAND_110.

ENDMODULE.                 " user_command_110  INPUT

*---------------------------------------------------------------------
*      Module  user_command_at_exit_110  INPUT
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------
MODULE USER_COMMAND_AT_EXIT_110 INPUT.

  PERFORM USER_COMMAND_AT_EXIT_110.

ENDMODULE.                 " user_command_at_exit_110  INPUT
