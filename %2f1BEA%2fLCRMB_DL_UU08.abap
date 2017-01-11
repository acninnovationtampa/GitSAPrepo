FUNCTION /1BEA/CRMB_DL_U_SHOWLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IS_BILL_DEFAULT) TYPE  BEAS_BILL_DEFAULT OPTIONAL
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
  CONSTANTS: lc_numb_of_dlis TYPE i VALUE '500'.

  DATA: LV_LINES TYPE I,
        lv_its   TYPE c,
        lt_dli   TYPE /1bea/t_CRMB_DLI_wrk.

  CHECK NOT IT_DLI IS INITIAL.

  GT_DLI          = IT_DLI.
  GS_BILL_DEFAULT = IS_BILL_DEFAULT.
  GS_VARIANT      = IS_VARIANT.
  GV_MODE         = IV_MODE.

  DESCRIBE TABLE GT_DLI LINES LV_LINES.
  IF LV_LINES = 1.
    MESSAGE S172(BEA).
  ELSEIF lv_lines GT lc_numb_of_dlis.
    CALL FUNCTION 'GUI_IS_ITS'
      IMPORTING
        RETURN        = lv_its.
    IF lv_its IS INITIAL.
      MESSAGE S171(BEA) WITH LV_LINES.
    ELSE.
      APPEND LINES OF gt_dli FROM 1 TO lc_numb_of_dlis TO lt_dli.
      gt_dli = lt_dli.
      MESSAGE s174(bea) WITH lc_numb_of_dlis.
    ENDIF.
  ELSE.
    MESSAGE S171(BEA) WITH LV_LINES.
  ENDIF.

  CALL SCREEN 0100.

ENDFUNCTION.

*---------------------------------------------------------------------
*-      Module  STATUS_0100  OUTPUT
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS 'DL_LIST'       OF PROGRAM gc_prog_stat_title.
  IF GV_MODE = GC_DL_PROCESS.
    SET TITLEBAR  'DL_ITEM_LIST' OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_RELEASE.
    SET TITLEBAR  'DL_RELEASE' OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_qREL.
    SET TITLEBAR  'DL_QRELEASE' OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_ERRORLIST.
    SET TITLEBAR  'DL_ERRORLIST' OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_REJECT.
    SET TITLEBAR  'DL_REJECT'    OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_REJECT_DL04.
    SET TITLEBAR  'DL_REJECT'    OF PROGRAM gc_prog_stat_title.
  ELSEIF GV_MODE = GC_DL_IAT_TRANSFER.
    SET TITLEBAR  'DL_IAT_TRANSFER' OF PROGRAM gc_prog_stat_title.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*-------------------------------------------------------------------*
*       Module  show_due_list  OUTPUT
*-------------------------------------------------------------------*
*       text
*-------------------------------------------------------------------*
MODULE SHOW_DUE_LIST OUTPUT.

perform SHOW_DUE_LIST.

ENDMODULE.                 " show_due_list  OUTPUT

*-------------------------------------------------------------------*
*       Module  USER_COMMAND_0100  INPUT
*-------------------------------------------------------------------*
*       text
*-------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OK_CODE.
    WHEN 'BACK'.
      PERFORM FREE_CONTROLS.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*-------------------------------------------------------------------*
*       Module  exit_command_0100  INPUT
*-------------------------------------------------------------------*
*       text
*-------------------------------------------------------------------*
MODULE EXIT_COMMAND_0100 INPUT.

  PERFORM EXIT_COMMAND_0100.

ENDMODULE.                 " exit_command_0100  INPUT

*---------------------------------------------------------------------
*       Form  free_controls
*---------------------------------------------------------------------
*       text
*---------------------------------------------------------------------

FORM FREE_CONTROLS.

* destroy custom container (detroys contained ALV control, too)
  IF NOT GO_CUSTOM_CONTAINER IS INITIAL.
    CALL METHOD GO_CUSTOM_CONTAINER->FREE.
    FREE GO_CUSTOM_CONTAINER.
    FREE GO_ALV_TREE.
  ENDIF.

ENDFORM.                    " free_controls

********************************************************************
*      Form  show_due_list
********************************************************************
form show_due_list .
*===================================================================
* Define local data
*===================================================================
  CONSTANTS: LC_SCRN_CONTAINER TYPE SCRFNAME VALUE 'DL_ALV_TREE'.
*===================================================================
* Create custom container and ALV grid
*===================================================================

  IF GO_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT GO_CUSTOM_CONTAINER
           EXPORTING CONTAINER_NAME = LC_SCRN_CONTAINER
      EXCEPTIONS
          OTHERS              = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  IF GO_ALV_TREE IS INITIAL.
    CREATE OBJECT GO_ALV_TREE
      EXPORTING
            PARENT = GO_CUSTOM_CONTAINER
            NODE_SELECTION_MODE =
                       CL_GUI_COLUMN_TREE=>NODE_SEL_MODE_MULTIPLE
            ITEM_SELECTION      = SPACE
            NO_HTML_HEADER      = gc_true
      EXCEPTIONS
          OTHERS                = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL FUNCTION '/1BEA/CRMB_DL_U_SHOW'
         EXPORTING
              IT_DLI             = GT_DLI
              IS_BILL_DEFAULT    = GS_BILL_DEFAULT
              IO_ALV_TREE        = GO_ALV_TREE
              IS_VARIANT         = GS_VARIANT
              IV_MODE            = GV_MODE.

  ENDIF.
  CALL METHOD CL_GUI_CFW=>FLUSH.

endform.                    " show_due_list
*------------------------------------------------------------------*
*      Form  exit_command
* -----------------------------------------------------------------*
form EXIT_COMMAND_0100.

  DATA: LV_OK_CODE TYPE SYUCOMM.

  LV_OK_CODE = GV_OK_CODE.
  CLEAR GV_OK_CODE.
  CASE LV_OK_CODE.
    WHEN 'CANC'.
      PERFORM FREE_CONTROLS.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM FREE_CONTROLS.
      LEAVE PROGRAM.
    WHEN OTHERS.
      CALL METHOD CL_GUI_CFW=>DISPATCH.
  ENDCASE.

endform.                     "EXIT_COMMAND_0100
