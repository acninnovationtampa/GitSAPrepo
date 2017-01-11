FUNCTION /1BEA/CRMB_BD_U_HD_SHOWLIST.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IV_MODE) TYPE  BEA_BD_UIMODE DEFAULT 'A'
*"     REFERENCE(IS_VARIANT) TYPE  DISVARIANT OPTIONAL
*"  EXPORTING
*"     VALUE(EV_DATA_SAVED) TYPE  BEA_BOOLEAN
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
* Time  : 13:53:01
*
*======================================================================
*--------------------------------------------------------------------
* Data Declaration
*--------------------------------------------------------------------
 DATA:
   LV_LINES            TYPE I,
   LS_BDH              TYPE /1BEA/S_CRMB_BDH_WRK,
   lv_mode             type bea_bd_uimode,
   lv_tabix            type sy-tabix,
   lv_auth_error       type bea_boolean.
 FIELD-SYMBOLS:
   <bdh_wrk>           TYPE /1BEA/S_CRMB_BDH_WRK.
*********************************************************************
* Implementation
*********************************************************************
  GV_MODE            = IV_MODE.
  IF GV_MODE  = GC_BD_TRANSFER.
    GV_AL_MODE       = GC_AL_DSP_N.
  ELSE.
    GV_AL_MODE       = GC_AL_DSP_X.
  ENDIF.
*--------------------------------------------------------------------
* Authorization-Check
*--------------------------------------------------------------------
  GT_BDH             = IT_BDH.
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
      LV_AUTH_ERROR = GC_TRUE.
    ENDIF.
  ENDLOOP.
  IF LV_AUTH_ERROR = GC_TRUE.
    MESSAGE I136(BEA).
    IF GT_BDH IS INITIAL.
      EXIT.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------
* Special Logic in case there is only one invoice (and NOT Transfer)
*--------------------------------------------------------------------
  DESCRIBE TABLE GT_BDH LINES LV_LINES.
  IF LV_LINES = 1 AND
     GV_MODE <> GC_BD_TRANSFER.
     MESSAGE s153(bea).
*  Go directly to billing document view
     IF IV_MODE = GC_BD_BILL.
        lV_MODE = GC_BD_BILL_SGL.
     else.
        lv_mode = iv_mode.
     ENDIF.
     READ TABLE GT_BDH INTO LS_BDH INDEX 1. " is the only one
     CALL FUNCTION '/1BEA/CRMB_BD_U_HD_SHOWDETAIL'
       EXPORTING
         IS_BDH           = LS_BDH
         IT_BDI           = IT_BDI
         IV_MODE          = lV_MODE
         IV_AL_MODE       = GV_AL_MODE
       IMPORTING
         EV_DATA_SAVED    = EV_DATA_SAVED.
  ELSE.
     MESSAGE s154(bea) WITH lv_lines.
*--------------------------------------------------------------------
* Prepare CALL dynpro
*--------------------------------------------------------------------
*....................................................................
* Transfer importing parameters to global data
*....................................................................
     GT_BDI             = IT_BDI.
     GS_VARIANT         = IS_VARIANT.
*....................................................................
* Handle dialog billing / cancelling
*....................................................................
     IF    GV_MODE = GC_BD_BILL
        OR GV_MODE = gc_bd_dial_canc.
           GV_DATA_CHANGED = GC_TRUE.
     ENDIF.
*....................................................................
* Clear control data if necessary
*....................................................................
     IF ev_data_saved IS REQUESTED.
        CLEAR gv_data_saved.
     ENDIF.
*....................................................................
* Data Manager: in case that we PROCESS data
*....................................................................
     IF gv_mode = gc_bd_process.
        PERFORM list_data_manager_insert.
     ENDIF.
*....................................................................
* Prepare creating a new instance of a ALV Grid
*....................................................................
     gv_new_alv = gc_true.
*....................................................................
* CALL dynpro
*....................................................................
     CALL SCREEN 0200.
*....................................................................
* Transfer global data to exporting parameters
*....................................................................
     EV_DATA_SAVED = GV_DATA_SAVED.
   ENDIF.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* FORMS
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*      FORM  SET_STATUS_200
*********************************************************************
FORM SET_STATUS_200.
*--------------------------------------------------------------------
* Status
*--------------------------------------------------------------------
 IF GV_DATA_CHANGED = GC_TRUE.
   SET PF-STATUS 'BD_HEADER_LIST'
                 OF PROGRAM GC_PROG_STAT_TITLE.
 ELSE.
   SET PF-STATUS 'BD_HEADER_LIST'
                 OF PROGRAM GC_PROG_STAT_TITLE
                 EXCLUDING GC_SAVE.
 ENDIF.
*--------------------------------------------------------------------
* Title
*--------------------------------------------------------------------
 IF gv_mode = gc_bd_disp.
   SET TITLEBAR 'BD_HEADER_LIST_DISP'
                OF PROGRAM GC_PROG_STAT_TITLE.
 ELSEIF gv_mode = gc_bd_transfer.
   SET TITLEBAR 'BD_HEADER_TRANSFER'
                OF PROGRAM GC_PROG_STAT_TITLE.
 ELSEIF gv_mode = gc_bd_dial_canc.
   SET TITLEBAR 'BD_HEADER_LIST_CANC'
                OF PROGRAM GC_PROG_STAT_TITLE.
 ELSE.
   SET TITLEBAR 'BD_HEADER_LIST'
                OF PROGRAM GC_PROG_STAT_TITLE.
 ENDIF.
ENDFORM.
*********************************************************************
*      FORM  HEADER_SHOWLIST
*********************************************************************
FORM HEADER_SHOWLIST.
*....................................................................
* Declaration
*....................................................................
 CONSTANTS LC_CONTROL    TYPE SCRFNAME VALUE 'CUSTOM_BDH'.
 DATA     lo_alv_bdh TYPE REF TO cl_gui_alv_grid.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Create a Customer Container
*--------------------------------------------------------------------
   IF GO_CUSTOM_BDH IS INITIAL.
      CREATE OBJECT GO_CUSTOM_BDH
        EXPORTING
          CONTAINER_NAME = LC_CONTROL
        EXCEPTIONS
          OTHERS         = 1.
      IF SY-SUBRC <> 0.
        MESSAGE e165(BEA).
      ENDIF.
   ENDIF.
*--------------------------------------------------------------------
* Eventually create custom container and ALV Grid Instance
*--------------------------------------------------------------------
   IF NOT gv_new_alv IS INITIAL.
     CLEAR gv_new_alv.
     PERFORM bdh_alv_manager_insert.
   ENDIF.
*--------------------------------------------------------------------
* Read the correct ALV Instance
*--------------------------------------------------------------------
   PERFORM bdh_alv_manager_read CHANGING lo_alv_bdh.
*--------------------------------------------------------------------
* Call Function Module displaying the list of headers
*--------------------------------------------------------------------
    CALL FUNCTION '/1BEA/CRMB_BD_U_SHOW_BDH'
      EXPORTING
        IT_BDH             = GT_BDH
        IT_BDI             = GT_BDI
        IO_ALV_GRID        = lO_ALV_BDH
        IV_MODE            = GV_MODE
        IV_AL_MODE         = GV_AL_MODE.
ENDFORM.                    " HEADER_SHOWLIST
*********************************************************************
*       FORM  USER_COMMAND_0200
*********************************************************************
FORM USER_COMMAND_200.
*....................................................................
* Local Data Declaration
*....................................................................
  DATA:
   lv_okcode     TYPE syucomm.
*====================================================================
* Implementation
*====================================================================
  lv_okcode = gv_okcode.
  CLEAR gv_okcode.
  CASE lV_OKCODE.
*--------------------------------------------------------------------
* BACK
*--------------------------------------------------------------------
    WHEN GC_BACK.
      IF GV_MODE = gc_bd_bill OR
         GV_MODE = gc_bd_dial_canc OR
         GV_DATA_CHANGED IS NOT INITIAL.
        PERFORM POPUP_AND_SAVE_200.
      ENDIF.
      PERFORM FREE_CONTROLS_200.
      LEAVE TO SCREEN 0.
*--------------------------------------------------------------------
* SAVE
*--------------------------------------------------------------------
    WHEN GC_SAVE.
*....................................................................
* Final Processing: ADD and SAVE
*....................................................................
      CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
        EXPORTING
          IV_PROCESS_MODE        = GC_PROC_ADD
          IV_COMMIT_FLAG         = GC_COMMIT_ASYNC.
      GV_DATA_SAVED = GC_TRUE.
      CLEAR GV_DATA_CHANGED.
      PERFORM FREE_CONTROLS_200.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.
*********************************************************************
*     FORM  POPUP_AND_SAVE_200
*********************************************************************
 FORM POPUP_AND_SAVE_200.
*....................................................................
* Local Data Declaration
*....................................................................
 CONSTANTS: LC_YES    TYPE C VALUE 'J'.
 DATA:      LV_ANSWER TYPE C.
*--------------------------------------------------------------------
* Implementation
*--------------------------------------------------------------------
   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
     EXPORTING
       DEFAULTOPTION  = LC_YES
       TEXTLINE1      = TEXT-P02
       TEXTLINE2      = TEXT-P03
       TITEL          = TEXT-P01
       CANCEL_DISPLAY = SPACE
     IMPORTING
       ANSWER         = LV_ANSWER.
   IF LV_ANSWER = LC_YES.
*....................................................................
* Final Processing: ADD and SAVE
*....................................................................
     CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
       EXPORTING
         IV_PROCESS_MODE        = GC_PROC_ADD
         IV_COMMIT_FLAG         = GC_COMMIT_ASYNC.
     GV_DATA_SAVED = GC_TRUE.
     CLEAR GV_DATA_CHANGED.
   ELSE.
*....................................................................
* REFRESH
*....................................................................
     CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
     CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
     CLEAR GV_DATA_CHANGED.
   ENDIF.
ENDFORM.                    " POPUP_AND_SAVE_200
*********************************************************************
*       FORM  USER_COMMAND_AT_EXIT_200
*********************************************************************
FORM USER_COMMAND_AT_EXIT_200.
*....................................................................
* Declaration
*....................................................................
   DATA: lv_okcode TYPE syucomm.
*--------------------------------------------------------------------
* Data saved? and Cleaning Jobs
*--------------------------------------------------------------------
   IF GV_DATA_CHANGED = GC_TRUE OR
      GV_MODE = gc_bd_dial_canc.
     PERFORM POPUP_AND_SAVE_200.
   ENDIF.
   PERFORM FREE_CONTROLS_200.
*--------------------------------------------------------------------
* Leave Screen
*--------------------------------------------------------------------
   lv_okcode = gv_okcode.
   CLEAR gv_okcode.
   CASE lV_OKCODE.
     WHEN GC_CANC.
       LEAVE TO SCREEN 0.
     WHEN GC_EXIT.
       LEAVE TO SCREEN 0.
   ENDCASE.
ENDFORM.                 " USER_COMMAND_AT_EXIT_200
*********************************************************************
*      FORM  FREE_CONTROLS_200
*********************************************************************
FORM FREE_CONTROLS_200.
*....................................................................
* Declaration
*....................................................................
  DATA: lv_last_alv TYPE bea_boolean.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Free the ALV instance and delete it from the manager
*--------------------------------------------------------------------
  CLEAR lv_last_alv.
  PERFORM bdh_alv_manager_delete CHANGING lv_last_alv.
*--------------------------------------------------------------------
* Free eventually the custom container
*--------------------------------------------------------------------
  IF     NOT GO_CUSTOM_BDH IS INITIAL
     AND NOT lv_last_alv IS INITIAL.
     CALL METHOD GO_CUSTOM_BDH->FREE.
     FREE GO_CUSTOM_BDH.
  ENDIF.
ENDFORM.                    " FREE_CONTROLS_200
*********************************************************************
*      FORM  bdh_alv_manager_insert
*********************************************************************
FORM bdh_alv_manager_insert.
*....................................................................
* Declaration
*....................................................................
  DATA: lo_bdh_alv     TYPE REF TO cl_gui_alv_grid,
        lo_bdh_alv_old TYPE REF TO cl_gui_alv_grid.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Create a new ALV instance
*--------------------------------------------------------------------
  CREATE OBJECT lo_bdh_alv
     EXPORTING
       I_PARENT = GO_CUSTOM_BDH
     EXCEPTIONS
       OTHERS         = 1.
  IF SY-SUBRC <> 0.
    MESSAGE e165(BEA).
  ENDIF.
*--------------------------------------------------------------------
* Look if old one exists; if yes -> Set Invisible
*--------------------------------------------------------------------
  READ TABLE gt_bdh_alv_manager INDEX 1 INTO lo_bdh_alv_old.
  IF sy-subrc = 0.
     CALL METHOD lo_bdh_alv_old->set_visible
       EXPORTING
         visible           = cl_gui_alv_grid=>visible_false
       EXCEPTIONS
         cntl_error        = 1
         cntl_system_error = 2
         OTHERS            = 3.
     IF sy-subrc <> 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     ENDIF.
  ENDIF.
*--------------------------------------------------------------------
* Insert the new instance in the manager table
*--------------------------------------------------------------------
  INSERT lo_bdh_alv INTO gt_bdh_alv_manager INDEX 1.
ENDFORM.                    " bdh_alv_manager_insert
*********************************************************************
*      FORM  bdh_alv_manager_read
*********************************************************************
FORM bdh_alv_manager_read
     CHANGING co_bdh_alv TYPE REF TO cl_gui_alv_grid.
*--------------------------------------------------------------------
* Read the instance that is on top of the stack
*--------------------------------------------------------------------
  CLEAR co_bdh_alv.
  READ TABLE gt_bdh_alv_manager INDEX 1 INTO co_bdh_alv.
  IF sy-subrc NE 0.
    MESSAGE e166(bea).
  ENDIF.
*--------------------------------------------------------------------
* Set this new instance on VISIBLE
*--------------------------------------------------------------------
  CALL METHOD co_bdh_alv->set_visible
    EXPORTING
      visible           = cl_gui_alv_grid=>visible_TRUE
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " bdh_alv_manager_read
*********************************************************************
*      FORM  bdh_alv_manager_delete
*********************************************************************
FORM bdh_alv_manager_delete CHANGING cv_last_alv TYPE bea_boolean.
*....................................................................
* Declaration
*....................................................................
  DATA: lo_alv_bdh TYPE REF TO cl_gui_alv_grid,
        lv_lines   TYPE i.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Read the instance that is to be deleted
*--------------------------------------------------------------------
  READ TABLE gt_bdh_alv_manager INDEX 1 INTO lo_alv_bdh.
  IF sy-subrc NE 0.
    MESSAGE e166(bea).
  ENDIF.
*--------------------------------------------------------------------
* Delete the instance that is on top of the stack
*--------------------------------------------------------------------
  DELETE gt_bdh_alv_manager INDEX 1.
  IF sy-subrc NE 0.
    MESSAGE e166(bea).
  ENDIF.
*--------------------------------------------------------------------
* Free this instance
*--------------------------------------------------------------------
   CALL METHOD lO_ALV_BDH->FREE.
   FREE lO_ALV_BDH.
*--------------------------------------------------------------------
* Any ALV instance left?
*--------------------------------------------------------------------
   DESCRIBE TABLE gt_bdh_alv_manager LINES lv_lines.
   IF lv_lines = 0.
     cv_last_alv = gc_true.
   ENDIF.
ENDFORM.                    " bdh_alv_manager_delete
*********************************************************************
*      FORM  list_data_manager_insert
*********************************************************************
FORM list_data_manager_insert.

   CLEAR: gt_bdh_list_manage, gt_bdi_list_manage.
   gt_bdh_list_manage = gt_bdh.
   gt_bdi_list_manage = gt_bdi.

ENDFORM.                    "list_data_manager_insert
*********************************************************************
*      FORM  list_data_manager_read
*********************************************************************
FORM list_data_manager_read.

   CLEAR: gt_bdh, gt_bdi.
   gt_bdh = gt_bdh_list_manage.
   gt_bdi = gt_bdi_list_manage.

ENDFORM.                    "list_data_manager_read
*********************************************************************
*      FORM  list_data_manager_modify_bdh
*********************************************************************
FORM list_data_manager_modify_bdh
     USING us_bdh TYPE /1BEA/s_CRMB_BDH_wrk.
   DATA: lv_tabix TYPE sytabix.
   READ TABLE gt_bdh_list_manage WITH KEY bdh_guid = us_bdh-bdh_guid
                 TRANSPORTING NO FIELDS.
   lv_tabix = sy-tabix.
   IF sy-subrc = 0.
      MODIFY gt_bdh_list_manage FROM us_bdh INDEX lv_tabix.
   ENDIF.
ENDFORM.                    "list_data_manager_modify_bdh
*********************************************************************
*      FORM  list_data_manager_modify_bdi
*********************************************************************
FORM list_data_manager_modify_bdi
     USING us_bdi TYPE /1BEA/s_CRMB_BDI_wrk.
   DATA: lv_tabix TYPE sytabix.
   READ TABLE gt_bdi_list_manage WITH KEY bdi_guid = us_bdi-bdi_guid
                 TRANSPORTING NO FIELDS.
   lv_tabix = sy-tabix.
   IF sy-subrc = 0.
      MODIFY     gt_bdi_list_manage FROM us_bdi INDEX lv_tabix.
   ENDIF.
ENDFORM.                    "list_data_manager_modify_bdi
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* MODULES
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*====================================================================
*      MODULE  STATUS_200  OUTPUT
*====================================================================
MODULE STATUS_200 OUTPUT.

  IF gv_mode = gc_bd_process.
     PERFORM list_data_manager_read.
  ENDIF.
  PERFORM SET_STATUS_200.

ENDMODULE.                 " STATUS_200  OUTPUT

*====================================================================
*       MODULE HEADER_SHOWLIST OUTPUT
*====================================================================
MODULE HEADER_SHOWLIST OUTPUT.

  PERFORM HEADER_SHOWLIST.

ENDMODULE.                 " HEADER_SHOWLIST  OUTPUT
*====================================================================
*       MODULE  USER_COMMAND_0200  INPUT
*====================================================================
MODULE USER_COMMAND_200 INPUT.

  perform USER_COMMAND_200.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*====================================================================
*       MODULE  USER_COMMAND_AT_EXIT_200  INPUT
*====================================================================
MODULE USER_COMMAND_AT_EXIT_200 INPUT.

  perform USER_COMMAND_AT_EXIT_200.

ENDMODULE.                 " USER_COMMAND_AT_EXIT_200  INPUT
