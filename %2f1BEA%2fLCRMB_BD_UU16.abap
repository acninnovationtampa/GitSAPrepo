FUNCTION /1BEA/CRMB_BD_U_HD_SHOWDETAIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IV_MODE) TYPE  BEA_BD_UIMODE DEFAULT 'A'
*"     REFERENCE(IV_FCODE) TYPE  UI_FUNC OPTIONAL
*"     REFERENCE(IV_AL_MODE) TYPE  BEA_AL_MODE DEFAULT 'A'
*"     REFERENCE(IV_BDI_GUID) TYPE  BEA_BDI_GUID OPTIONAL
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
*********************************************************************
* Processing Logic
*********************************************************************
* The Processing Logic relies on the fact, that the caller gives over
* ALL items of one bill document plus the head whose detail he wants
* to see.
*--------------------------------------------------------------------
* Authority-Check
*--------------------------------------------------------------------
  gs_bdh     = is_bdh.
  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
        IV_BILL_TYPE           = gs_bdh-BILL_TYPE
        IV_BILL_ORG            = gs_bdh-BILL_ORG
        IV_ACTVT               = GC_ACTV_DISPLAY
        IV_APPL                = GC_APPL
        IV_CHECK_DLI           = GC_FALSE
        IV_CHECK_BDH           = GC_TRUE
    EXCEPTIONS
        NO_AUTH                = 1.
  IF SY-SUBRC NE 0.
    MESSAGE S501(BEA).
    EXIT.
  ENDIF.
* Event BD_UHSD3 for Initialization
*--------------------------------------------------------------------
* Transfer of the input data
*--------------------------------------------------------------------
  gt_bdi_to_bdh = it_bdi.
  DELETE gt_bdi_to_bdh WHERE BDH_GUID NE GS_BDH-BDH_GUID.
  gv_mode    = iv_mode.
  IF IV_BDI_GUID IS NOT INITIAL.
    gv_bdi_guid = iv_bdi_guid.
    READ TABLE gt_bdi_to_bdh
      WITH KEY bdi_guid = GV_BDI_GUID transporting no fields.
      IF sy-subrc = 0.
        gv_item_focus = sy-tabix.
      ENDIF.
  ENDIF.
  CLEAR gv_pressed_tab_hdr.

*--------------------------------------------------------------------
* Set maintenance mode
*--------------------------------------------------------------------
   IF    gv_mode = gc_bd_bill_sgl
      OR gv_mode = gc_bd_bill
      OR gv_mode = gc_bd_dial_canc.
     gv_maint_mode = gc_true. "before documents are saved -> CHANGE
   ELSE.
     CLEAR gv_maint_mode. "otherwise: DISPLAY is default
   ENDIF.
* Manage multiple calls
  PERFORM data_manager_insert.

* Handle dialog billing
  IF GV_MODE = GC_BD_BILL_SGL.
     GV_DATA_CHANGED = GC_TRUE.
  ENDIF.

  IF ev_data_saved IS REQUESTED.
     CLEAR gv_data_saved.
  ENDIF.
*--------------------------------------------------------------------
* Clear / Set some global data
*--------------------------------------------------------------------
 REFRESH gt_outtab_bdi.
 perform INITIALIZE_GLOBALS.
 perform get_alog_msg.
*--------------------------------------------------------------------
* Evaluate FCODE -> First tabstrip to display
*--------------------------------------------------------------------
   IF IV_FCODE IS NOT INITIAL.
     PERFORM eval_ptab_210 USING iv_fcode.
   ENDIF.
*--------------------------------------------------------------------
* Call Screen
*--------------------------------------------------------------------
  CALL SCREEN 0410.

  PERFORM data_manager_delete.

* Transfer global data to exporting parameters
  EV_DATA_SAVED = GV_DATA_SAVED.
  CLEAR gv_data_saved.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* FORM Routinen
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*     FORM  INITIALIZE_GLOBALS
 FORM INITIALIZE_GLOBALS.
   perform data_manager_read.
   perform set_header_title.
   perform set_item_title.
   perform set_tab_data.
*....................................................................
 ENDFORM.
*********************************************************************
*     FORM  SET_HEADER_SCREEN
 FORM SET_HEADER_SCREEN.
*....................................................................
   SET SCREEN 0410.
   perform SET_TAB_DATA.
 ENDFORM.
*********************************************************************
*     FORM  SET_TAB_DATA
*********************************************************************
 FORM SET_TAB_DATA.
*....................................................................
   CLEAR gs_srv_prepared.
   CLEAR gs_tab.
*--------------------------------------------------------------------
* Set texts for tabstrip on dynpro
*--------------------------------------------------------------------
   GV_DETAIL_TAB0            = TEXT-GNL.
   GV_DETAIL_TAB1            = TEXT-HDO.
   GV_DETAIL_TAB2            = TEXT-PAR.
   GV_DETAIL_TAB3            = TEXT-PRC.
   GV_DETAIL_TAB4            = TEXT-TXT.
   GV_DETAIL_TAB5            = TEXT-PPF.
   GV_DETAIL_TAB9            = TEXT-STS.
   GV_DETAIL_TAB10           = TEXT-DFW.
   GV_DETAIL_TAB13           = TEXT-DOC.
   IF gv_pressed_tab_hdr IS NOT INITIAL.
     gs_tab-pressed_tab = gv_pressed_tab_hdr.
   ELSE.
     GS_TAB-PRESSED_TAB = GC_TAB-TAB0.
   ENDIF.
 ENDFORM.
*********************************************************************
*     FORM  SET_HEADER_TITLE
*********************************************************************
 FORM SET_HEADER_TITLE.
*....................................................................
* Declaration
*....................................................................
 DATA:
   ls_bdh_dsp  TYPE /1bea/s_CRMB_BDH_dsp,
   lf_netval(20),
   lf_headno_ext(40).
*....................................................................
* Implementation
*....................................................................
 CALL FUNCTION '/1BEA/CRMB_BD_U_HD_INT2EXT'
   EXPORTING
     is_bdh     = gs_bdh
   IMPORTING
     es_bdh_dsp = ls_bdh_dsp.
 MOVE-CORRESPONDING ls_bdh_dsp to BEAS_BDH_TAB_GENERAL.
 MOVE-CORRESPONDING ls_bdh_dsp to /1bea/s_CRMB_BDH_dsp.
* Header Title
 WRITE ls_bdh_dsp-net_value CURRENCY ls_bdh_dsp-doc_currency TO lf_netval.
 WRITE ls_bdh_dsp-headno_ext TO lf_headno_ext no-zero.
 CONCATENATE lf_headno_ext '/' ls_bdh_dsp-payer_name '/'
             lf_netval ls_bdh_dsp-doc_currency INTO gv_header_title
   SEPARATED BY space.
 ENDFORM.
*********************************************************************
*     FORM  SET_ITEM_TITLE
*********************************************************************
 FORM SET_ITEM_TITLE.
*....................................................................
* Declaration
*....................................................................
 DATA:
   ls_bdi      LIKE LINE OF gt_bdi_to_bdh,
   ls_bdi_dsp  TYPE /1bea/s_CRMB_BDI_dsp,
   lf_itemno_alpha(40).
*....................................................................
* Implementation
*....................................................................
* Data for Item Listbox
   REFRESH GT_ITEM_TITLE.
   DESCRIBE TABLE gt_bdi_to_bdh LINES gv_item_max.
   IF GV_ITEM_FOCUS IS INITIAL.
     gv_item_focus = 1.
   ENDIF.
   SORT gt_bdi_to_bdh by itemno_ext.
   LOOP AT gt_bdi_to_bdh INTO ls_bdi.
     CALL FUNCTION '/1BEA/CRMB_BD_U_IT_INT2EXT'
       EXPORTING
         is_bdi     = ls_bdi
       IMPORTING
         es_bdi_dsp = ls_bdi_dsp.

     gt_item_title-key = ls_bdi-bdi_guid.
     write ls_bdi_dsp-itemno_alpha to gt_item_title-text no-zero.
     if ls_bdi_dsp-product_id is not initial.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
           INPUT  = ls_bdi_dsp-product_id
         IMPORTING
           OUTPUT = ls_bdi_dsp-product_id.
     endif.
     CONCATENATE gt_item_title-text '/' ls_bdi_dsp-product_id '/'
                 ls_bdi_dsp-product_descr INTO gt_item_title-text SEPARATED BY space.
     APPEND gt_item_title.
   ENDLOOP.
 ENDFORM.
*********************************************************************
*     FORM  GET_LATEST_DATA
*********************************************************************
 FORM GET_LATEST_DATA.
   DATA:
     lt_bdh       TYPE /1bea/t_CRMB_BDH_wrk,
     lrs_bdh_guid TYPE bears_bdh_guid,
     lrt_bdh_guid TYPE beart_bdh_guid.

   lrs_bdh_guid-sign   = gc_include.
   lrs_bdh_guid-option = gc_equal.
   lrs_bdh_guid-low    = gs_bdh-bdh_guid.
   APPEND lrs_bdh_guid TO lrt_bdh_guid.
   CLEAR: gt_bdi_to_bdh, gs_bdh.
   CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
      EXPORTING
        irt_bdh_bdh_guid = lrt_bdh_guid
      IMPORTING
        et_bdh           = lt_bdh
        et_bdi           = gt_bdi_to_bdh.
   READ TABLE lt_bdh INTO gs_bdh INDEX 1.
   PERFORM get_alog_msg.
   PERFORM set_header_title.
   CLEAR gv_data_changed.
*....................................................................
* Data manager of this function module
*....................................................................
   PERFORM data_manager_modify USING gs_bdh gt_bdi_to_bdh.
*....................................................................
* Eventually Calling modules
*....................................................................
   PERFORM modify_global_data_from_caller
     USING gs_bdh gt_bdi_to_bdh 'IT_DETAIL'.
 ENDFORM.
*********************************************************************
*     FORM  GET_ALOG_MSG
*********************************************************************
 FORM GET_ALOG_MSG.
   FIELD-SYMBOLS:
     <fs_alog_msg> like line of gt_alog_msg.
   DATA:
     LT_RETURN2    TYPE BEAT_RETURN,
     LV_LINES      TYPE I.

   clear gt_alog_msg.
   case gv_mode.
     when gc_bd_bill_sgl or
          gc_bd_bill.
       CALL FUNCTION 'BEA_AL_O_GETMSGS'
         IMPORTING
           et_return = gt_alog_msg.
       IF gv_mode = gc_bd_bill.
* Filter messages to focused billing document
         loop at gt_alog_msg assigning <fs_alog_msg>.
           if <fs_alog_msg>-src_headno <> gs_bdh-headno_ext.
             delete gt_alog_msg.
           endif.
         endloop.
       ENDIF.
   ENDCASE.

*....................................................................
* Errors in Transfer - Determine the messages to be displayed
*....................................................................
   IF GV_MODE = GC_BD_PROCESS  OR
      GV_MODE = GC_BD_TRANSFER OR
      GV_MODE = GC_BD_DISP.
     LV_LINES = 1.
     CLEAR LT_RETURN2.
     PERFORM DETERMINE_TRANSFER_ERRORS
       USING    GS_BDH
                LV_LINES
                GC_SRV_ACC
       CHANGING LT_RETURN2.
     IF NOT LT_RETURN2 IS INITIAL.
*   Errors in Transfer are available
       APPEND LINES OF LT_RETURN2 TO gt_alog_msg.
     ENDIF.
   ENDIF.
 ENDFORM.
*********************************************************************
*     FORM  DISPLAY_ALOG_MSG
*********************************************************************
 FORM DISPLAY_ALOG_MSG.
   DATA:
     lv_loghndl    TYPE balloghndl,
     lv_newlog     TYPE bea_boolean,
     lv_mode       TYPE bea_bd_uimode.

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
   lv_mode = gv_mode.
   CALL FUNCTION 'BEA_AL_U_SHOW'
     EXPORTING
       iv_appl        = gc_appl
       iv_loghndl     = lv_loghndl
       it_return      = gt_alog_msg
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
 ENDFORM.
*********************************************************************
*     FORM  GET_ITEM_TITLE
*********************************************************************
 FORM GET_ITEM_TITLE  USING iv_bdi_focus TYPE syindex.
*....................................................................
* Declaration
*....................................................................
 DATA:
   ls_bdi     TYPE /1bea/s_CRMB_BDI_wrk.
*....................................................................
* Implementation
*....................................................................
   READ TABLE gt_bdi_to_bdh INTO ls_bdi INDEX iv_bdi_focus.
   gv_item_title  = ls_bdi-bdi_guid.
 ENDFORM.
*********************************************************************
*     FORM  SHOW_ITEM_DETAIL
*********************************************************************
 FORM SHOW_ITEM_DETAIL USING iv_bdi_focus TYPE syindex.
     CALL FUNCTION '/1BEA/CRMB_BD_U_IT_SHOWDETAIL'
       EXPORTING
         IS_BDH   = GS_BDH
         IT_BDI   = GT_BDI_TO_BDH
         IV_MODE  = GV_MODE
         IV_FCODE = GV_PRESSED_TAB_ITM
         IV_TABIX = IV_BDI_FOCUS.
 ENDFORM.
*********************************************************************
*     FORM  CHECK_CHANGE_OF_VALUTA_DATE
*********************************************************************
 FORM CHECK_CHANGE_OF_VALUTA_DATE.
*--------------------------------------------------------------------
* Valuta date has changed
*--------------------------------------------------------------------
  DATA:
    LS_BDH        TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDI        TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_MANAGE TYPE /1BEA/T_CRMB_BDI_WRK.

   IF BEAS_BDH_TAB_GENERAL-TRANSFER_DATE <> gs_bdh-transfer_date.
     GS_BDH-transfer_DATE = BEAS_BDH_TAB_GENERAL-TRANSFER_DATE.
     GS_BDH-UPD_TYPE  = GC_UPDATE.
     LT_BDI_MANAGE = gt_bdi_manage.
     LOOP AT lt_bdi_manage INTO ls_bdi where
                     bdh_guid = gs_bdh-bdh_guid.
       ls_bdi-UPD_TYPE  = GC_UPDATE.
       MODIFY lt_bdi_manage FROM ls_bdi.
     ENDLOOP.
     CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
       EXPORTING
         IS_BDH  = GS_BDH
         IT_BDI  = lt_bdi_manage.

     CLEAR GS_BDH-UPD_TYPE.
     LOOP AT gt_bdi_to_bdh INTO ls_bdi.
       CLEAR ls_bdi-UPD_TYPE.
       MODIFY gt_bdi_to_bdh FROM ls_bdi.
     ENDLOOP.
     gv_action_in_show = gc_data_change_in_show.
     PERFORM data_manager_modify
       USING gs_bdh gt_bdi_to_bdh.
     PERFORM modify_global_data_from_caller
       USING gs_bdh gt_bdi_to_bdh 'CHANGE_DATE'.
   ENDIF.
 ENDFORM.
*********************************************************************
*     FORM  SET_STATUS_210
*********************************************************************
 FORM SET_STATUS_210.
*....................................................................
* Declaration
*....................................................................
   DATA: lt_fcode_exl       TYPE syucomm_t,
         lv_chngbl_srv      TYPE bea_boolean,
         lv_cancel          TYPE bea_boolean,
         lv_headno_ext      TYPE bea_headno_ext,
         lv_description     TYPE bea_description,
         lv_item_id         TYPE vrm_id,
         lv_transfer        TYPE smp_dyntxt,
         lV_ALOG            TYPE smp_dyntxt.
*====================================================================
* Implementation
*====================================================================
* Item-Listbox
    PERFORM get_item_title USING gv_item_focus.
    lv_item_id    = 'GV_ITEM_TITLE'.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = lv_item_id
        values = gt_item_title[].
*--------------------------------------------------------------------
* Look if there is a service that supports changes
*--------------------------------------------------------------------
    lv_chngbl_srv = gc_true.
    lv_chngbl_srv = gc_true.
*....................................................................
* Disable TOGGLE, if not.
*....................................................................
    IF lv_chngbl_srv IS INITIAL.
       APPEND gc_fcode_toggle TO lt_fcode_exl.
    ENDIF.
*--------------------------------------------------------------------
* Set Status according to mode(s)
*--------------------------------------------------------------------
  CASE GV_MODE.
    WHEN GC_BD_PROCESS.
      IF gv_maint_mode IS INITIAL.
        APPEND gc_save TO lt_fcode_exl.
      ELSE.
        APPEND gc_refresh TO lt_fcode_exl.
      ENDIF.
      IF NOT gs_bdh-archivable is initial.
        APPEND gc_fcode_toggle  TO lt_fcode_exl.
        APPEND gc_fcode_cancel  TO lt_fcode_exl.
      ELSE.
        PERFORM check_if_cancel CHANGING lv_cancel.
        IF NOT lv_cancel IS INITIAL.
          APPEND gc_fcode_cancel  TO lt_fcode_exl.
        ENDIF.
      ENDIF.
      IF NOT (    gs_bdh-transfer_status = gc_transfer_todo
               OR gs_bdh-transfer_status = gc_transfer_block ).
        APPEND gc_transfer  TO lt_fcode_exl.
      ELSE.
        CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
          EXPORTING
            IV_BILL_TYPE    = GS_BDH-BILL_TYPE
            IV_BILL_ORG     = GS_BDH-BILL_ORG
            IV_APPL         = GC_APPL
            IV_ACTVT        = GC_ACTV_TRANSITION
            IV_CHECK_DLI    = GC_FALSE
            IV_CHECK_BDH    = GC_TRUE
          EXCEPTIONS
            NO_AUTH      = 1
            OTHERS       = 2.
        IF SY-SUBRC <> 0.
          APPEND gc_transfer  TO lt_fcode_exl.
        ENDIF.
      ENDIF.
    WHEN GC_BD_BILL_SGL.
      APPEND gc_refresh TO lt_fcode_exl.
      APPEND gc_fcode_cancel   TO lt_fcode_exl.
      APPEND GC_DOCFL    to lt_fcode_exl.
      APPEND gc_transfer  TO lt_fcode_exl.
      APPEND gc_fcode_toggle TO lt_fcode_exl.
    WHEN GC_BD_BILL OR
         gc_bd_dial_canc.
      APPEND gc_refresh TO lt_fcode_exl.
      APPEND GC_DOCFL   to lt_fcode_exl.
      APPEND GC_SAVE    TO lt_fcode_exl.
      APPEND gc_fcode_cancel  TO lt_fcode_exl.
      APPEND gc_transfer  TO lt_fcode_exl.
      APPEND gc_fcode_toggle TO lt_fcode_exl.
    WHEN OTHERS.  "mode DISPLAY and TRANSFER
      APPEND gc_fcode_toggle  TO lt_fcode_exl.
      APPEND GC_SAVE    TO lt_fcode_exl.
      APPEND gc_fcode_cancel  TO lt_fcode_exl.
      IF NOT gv_mode = gc_bd_transfer.
        APPEND gc_transfer  TO lt_fcode_exl.
      ENDIF.
  ENDCASE.
*--------------------------------------------------------------------
* Set Dynamic Application Log FCode description
*--------------------------------------------------------------------
  describe table gt_alog_msg.
  if sy-tfill = 0.
    lv_alog-text      = text-PRO.
    lv_alog-icon_id   = icon_led_inactive.
    lv_alog-icon_text = text-al0.
    APPEND GC_APPLLOG TO lt_fcode_exl.
  ELSE.
    lv_alog-text      = text-PRO.
    lv_alog-icon_id   = icon_led_red.
    lv_alog-icon_text = text-al1.
  ENDIF.
  CALL FUNCTION 'SET_DYNAMIC_FCODE_DESCRIPTION'
    EXPORTING
      iv_fcode        = GC_APPLLOG
      iv_dynamic_text = lv_alog.

*--------------------------------------------------------------------
* Set GUI Status
*--------------------------------------------------------------------
  SET PF-STATUS 'BD_DOC_DETAIL' OF PROGRAM GC_PROG_STAT_TITLE
    EXCLUDING lt_fcode_exl.
*--------------------------------------------------------------------
* Set Titlebar according to mode(s)
*--------------------------------------------------------------------
   CALL FUNCTION 'BEA_BTY_O_GET_DESCRIPTION'
      EXPORTING
        IV_APPL                = gc_appl
        IV_BTY                 = gs_bdh-bill_type
      IMPORTING
        EV_DESCRIPTION         = lv_description
      EXCEPTIONS
        OBJECT_NOT_FOUND       = 1
        OTHERS                 = 2.
   IF sy-subrc <> 0.
     lv_description = text-do2.
   ENDIF.
   lv_headno_ext = gs_bdh-headno_ext.
   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT         = lv_headno_ext
      IMPORTING
        OUTPUT        = lv_headno_ext.
   IF gv_maint_mode IS INITIAL.
     SET TITLEBAR  'BD_HEADER_DETAIL'
                    OF PROGRAM GC_PROG_STAT_TITLE
                    WITH lv_description lv_headno_ext.
   ELSE.
     SET TITLEBAR  'BD_HEADER_DETAIL_UPD'
                    OF PROGRAM GC_PROG_STAT_TITLE
                    WITH lv_description lv_headno_ext.
   ENDIF.
*--------------------------------------------------------------------
* Disable those SRV-Screens that are not part of CRMB
*--------------------------------------------------------------------
* disable all but detail tab (must be activated in subscription)
    LOOP AT SCREEN.
      screen-active = 0.
      IF screen-name = 'PB_ITEM_NEXT'.
        screen-active = 1.
        IF gv_item_focus >= gv_item_max.
          screen-input = '0'.
        ELSE.
          screen-input = '1'.
        ENDIF.
      ENDIF.
      IF screen-name = 'PB_ITEM_PREV'.
        screen-active = 1.
        IF gv_item_focus = 1.
          screen-input = '0'.
        ELSE.
          screen-input = '1'.
        ENDIF.
      ENDIF.
      IF screen-name = 'PB_HEADER'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'PB_ITEM'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_HEADER_TITLE'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_ITEM_TITLE'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_ITEM_LABEL'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB0'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB1'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB9'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB10'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB2'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB3'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB4'.
        screen-active = 1.
      ENDIF.
      IF screen-name = 'GV_DETAIL_TAB5'.
        screen-active = 1.
      ENDIF.
* Event for calling subscreens in other tabs
*....................................................................
* Always Disable PPF (=Actions)-Screen before Actions were created
*....................................................................
     IF SCREEN-NAME = 'GV_DETAIL_TAB5'
        AND (    gv_mode = gc_bd_bill
              OR gv_mode = gc_bd_bill_sgl
              OR gv_mode = gc_bd_dial_canc ) .
       SCREEN-ACTIVE = 0.
     ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
 ENDFORM.                  " SET_STATUS_210
*********************************************************************
*     FORM  SET_AND_FILL_HEADER_TAB
*********************************************************************
FORM SET_AND_FILL_HEADER_TAB.
*....................................................................
* Data Declaration
*....................................................................
  DATA: LV_REUSE_DOC TYPE BEA_BOOLEAN VALUE gc_true,
        lv_height    TYPE i,
        ls_bdi       TYPE /1bea/s_CRMB_BDI_wrk,
        lt_bdh       TYPE /1bea/t_CRMB_BDH_wrk,
        lv_mode      TYPE bea_bd_uimode,
        LT_DOCFLOW   TYPE BEAT_DFL_OUT.
* For the Subscreen of the PPF:
  CONSTANTS: LC_PPF_MODE_D TYPE C        VALUE 'D',
             LC_PPF_MODE_M TYPE C        VALUE 'M'.
  DATA:      LV_PPF_MODE    TYPE PPFDMODE,
             lo_ppf_manager TYPE REF TO cl_manager_ppf.
* For the Subscreen "Conditions":
  DATA: LV_PRC_ITEM_NO    TYPE PRCT_ITEM_NO,
        LV_PRC_WRITE_MODE TYPE c.
*====================================================================
* Detail / SRV - Data
*====================================================================
*--------------------------------------------------------------------
* General
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB0.
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0215'.
     ENDIF.
*--------------------------------------------------------------------
* Detail
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB1.
       CLEAR GS_TAB-SUBSCREEN.  " dummy because of "event"
* Detail in dynpro (CRMB only)
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0216'.
      IF GS_TAB-SUBSCREEN IS INITIAL.
       GS_TAB-PROG = 'SAPLBEA_OBJ_U'.
       GS_TAB-SUBSCREEN = '0100'.
       IF GS_SRV_PREPARED-DETAIL IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_U_DETAIL_BDH'
           EXPORTING
             IS_BDH = GS_BDH.
         GS_SRV_PREPARED-DETAIL = GC_TRUE.
       ENDIF.
      ENDIF.
     ENDIF.
*--------------------------------------------------------------------
* Status
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB9.
       MOVE-CORRESPONDING gs_bdh to BEAS_BDH_TAB_STATUS.
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0219'.
     ENDIF.
*--------------------------------------------------------------------
* DocFlow
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB10.
       GS_TAB-PROG = 'SAPLBEA_OBJ_U'.
       GS_TAB-SUBSCREEN = '0301'.
       IF GS_SRV_PREPARED-DOCFLOW IS INITIAL.
         clear lt_docflow.
         CALL FUNCTION '/1BEA/CRMB_DL_O_DOCFL_BDH_GET'
           EXPORTING
             is_bdh           = GS_BDH
           IMPORTING
             ET_DOCFLOW       = LT_DOCFLOW
           EXCEPTIONS
             REJECT           = 1
             OTHERS           = 2.
         IF sy-subrc <> 0.
           MESSAGE ID SY-MSGID TYPE gc_imessage NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ELSE.
           lv_mode = gv_mode.
           CALL FUNCTION 'BEA_OBJ_U_DFL_SHOW'
             EXPORTING
               it_docflow    = LT_DOCFLOW
               IV_FB_NAME    = gc_fb_name
               IV_LEVEL      = GC_DFL_HEAD
               IV_no_display = GC_true.
           gv_mode = lv_mode.
           GS_SRV_PREPARED-DOCFLOW = GC_TRUE.
         ENDIF.
       ENDIF.
     ENDIF.
*--------------------------------------------------------------------
* Partner
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB2.
       IF GS_SRV_PREPARED-PAR IS INITIAL.
         IF ( GS_BDH-BILL_TYPE <> GS_BTY-BILL_TYPE ) OR
            ( GS_BTY IS INITIAL ).
           CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
              EXPORTING
                IV_APPL          = GC_APPL
                IV_BTY           = GS_BDH-BILL_TYPE
              IMPORTING
                ES_BTY_WRK       = GS_BTY
              EXCEPTIONS
                OBJECT_NOT_FOUND = 1
                OTHERS           = 2.
           IF SY-SUBRC NE 0.
             GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
             MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             RETURN. "from form
           ENDIF.
         ENDIF.
         CALL FUNCTION 'BEA_PAR_U_DISPLAY'
           EXPORTING
             IV_PARSET_GUID             = gs_bdh-parset_guid
             IV_PAR_PROCEDURE           = GS_BTY-BDH_PAR_PROC
             IV_OBJTYPE                 = GC_BOR_BDH
           EXCEPTIONS
             REJECT                     = 1
             OTHERS                     = 2.
         IF SY-SUBRC <> 0.
           GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
           MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           RETURN.
         ENDIF.
         GS_SRV_PREPARED-PAR = GC_TRUE.
       ENDIF.
       GS_TAB-PROG = 'SAPLCOM_PARTNER_UI2'.
       GS_TAB-SUBSCREEN = '2000'.
     ENDIF.
*--------------------------------------------------------------------
* Pricing
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB3.
       IF GS_SRV_PREPARED-PRC IS INITIAL.
*....................................................................
* Begin of pricing-session
*....................................................................
          IF GV_PRC_SESSION_ID IS INITIAL.
            LV_PRC_WRITE_MODE = gc_prc_pd_readonly.
            CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_HD_DERIVE'
              EXPORTING
                IS_BDH = GS_BDH
              IMPORTING
                ES_BDH = GS_BDH.
            LOOP AT GT_BDI_TO_BDH INTO LS_BDI.
              CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_DERIVE'
                EXPORTING
                  IS_BDI          = LS_BDI
                IMPORTING
                  ES_BDI          = LS_BDI.
              MODIFY GT_BDI_TO_BDH FROM LS_BDI.
            ENDLOOP.
            CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_OPEN'
               EXPORTING
                 IS_BDH              = GS_BDH
                 IT_BDI              = gt_bdi_to_bdh
                 IV_WRITE_MODE       = LV_PRC_WRITE_MODE
               IMPORTING
                 EV_SESSION_ID       = GV_PRC_SESSION_ID
               EXCEPTIONS
                 REJECT              = 1
                 OTHERS              = 2.
            IF SY-SUBRC NE 0.
              GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
              MESSAGE ID SY-MSGID TYPE GC_IMESSAGE NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              RETURN. "from form
            ENDIF.
          ENDIF.
*....................................................................
* Display the Conditions
*....................................................................
          CLEAR lv_prc_item_no.
          CALL FUNCTION 'BEA_PRC_U_SET_PD'
             EXPORTING
               IV_PRC_SESSION_ID = GV_PRC_SESSION_ID
               IV_PD_ITEM_NO     = LV_PRC_ITEM_NO
               IV_NO_EDIT        = GC_TRUE.
          GS_SRV_PREPARED-PRC = GC_TRUE.
       ENDIF.
       GS_TAB-PROG = 'SAPLBEA_PRC_U'.
       GS_TAB-SUBSCREEN = '1000'.
     ENDIF.
*--------------------------------------------------------------------
* Texte
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB4.
*....................................................................
* Prepare Text Subscreen (to be done once)
*....................................................................
       IF GS_SRV_PREPARED-TXT IS INITIAL.
* Display mode
         IF GV_MAINT_MODE IS INITIAL.
           CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_READ'
              EXPORTING
                IS_BDH     = GS_BDH
                IV_MODE    = GC_MODE-DISPLAY
              EXCEPTIONS
                ERROR      = 1
                INCOMPLETE = 2
                OTHERS     = 3.
           IF SY-SUBRC <> 0.
              GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
              MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           ENDIF.
           CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_PROVID'
              EXPORTING
                IS_BDH     = GS_BDH
                IV_MODE    = GC_MODE-DISPLAY
              EXCEPTIONS
                ERROR      = 1
                INCOMPLETE = 2
                OTHERS     = 3.
           IF SY-SUBRC <> 0.
              GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
              MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             RETURN.
           ENDIF.
         ELSE.
* Update mode -> REFRESH buffer and READ
           IF gv_mode = gc_bd_process.
             CLEAR lt_bdh.
             APPEND gs_bdh TO lt_bdh.
             CALL FUNCTION 'BEA_TXT_O_REFRESH'
               EXPORTING
                 it_struc    = lt_bdh
                 iv_tdobject = gc_bdh_txtobj
                 iv_typename = gc_typename_bdh_wrk
                 iv_appl     = gc_appl
               EXCEPTIONS
                 error       = 0
                 OTHERS      = 0.
           ENDIF.
           CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_READ'
              EXPORTING
                IS_BDH     = GS_BDH
                IV_MODE    = GC_MODE-UPDATE
              EXCEPTIONS
                ERROR      = 1
                INCOMPLETE = 2
                OTHERS     = 3.
           IF SY-SUBRC <> 0.
              GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
              MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           ENDIF.
         ENDIF.
         GS_SRV_PREPARED-TXT = GC_TRUE.
       ENDIF.
*....................................................................
* If Update Mode, do things that are to be done at each call
*....................................................................
       IF NOT GV_MAINT_MODE IS INITIAL.
          CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_PROVID'
             EXPORTING
               IS_BDH     = GS_BDH
               IV_MODE    = GC_MODE-UPDATE
             EXCEPTIONS
               ERROR      = 1
               INCOMPLETE = 2
               OTHERS     = 3.
          IF SY-SUBRC <> 0.
             GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
             MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             RETURN.
          ENDIF.
       ENDIF.
       GS_TAB-PROG = 'SAPLCOM_TEXT_MAINTENANCE'.
       GS_TAB-SUBSCREEN = '2110'.
     ENDIF.
*--------------------------------------------------------------------
* PPF
*--------------------------------------------------------------------
  IF GS_TAB-PRESSED_TAB = GC_TAB-TAB5.
    IF GS_SRV_PREPARED-PPF IS INITIAL.
      IF GV_MAINT_MODE IS INITIAL.
        LV_PPF_MODE = LC_PPF_MODE_D.
        lo_ppf_manager = cl_manager_ppf=>get_instance( ).
        lo_ppf_manager->refresh( ).
      ELSE.
        GV_DATA_CHANGED = GC_TRUE.
        LV_PPF_MODE = LC_PPF_MODE_M.
*....................................................................
* Start Tracking Changes
*....................................................................
       CALL FUNCTION 'BEA_PPF_O_TA_START'
         EXCEPTIONS
           ERROR  = 1
           OTHERS = 2.
        IF SY-SUBRC <> 0.
          GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
          MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          RETURN.
        ENDIF.
      ENDIF.
      IF ( GS_BDH-BILL_TYPE <> GS_BTY-BILL_TYPE ) OR
         ( GS_BTY IS INITIAL ).
        CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
           EXPORTING
               IV_APPL          = GC_APPL
               IV_BTY           = GS_BDH-BILL_TYPE
           IMPORTING
               ES_BTY_WRK       = GS_BTY
           EXCEPTIONS
               OBJECT_NOT_FOUND = 1
               OTHERS           = 2.
      IF SY-SUBRC NE 0.
        GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
        MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        RETURN.
      ENDIF.
    ENDIF.
    CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_PREPARE'
      EXPORTING
        IS_BDH                 = GS_BDH
        IS_BTY                 = GS_BTY
        IV_VIEWMODE            = LV_PPF_MODE
        IV_HEADER              = GC_TRUE
        IV_SHOW_INACTIVE       = GC_FALSE.
     GS_SRV_PREPARED-PPF = GC_TRUE.
   ENDIF.
   GS_TAB-PROG = 'SAPLSPPF_VIEW_CRM'.
   GS_TAB-SUBSCREEN = '0100'.
 ENDIF.

   DETAIL_HDR-ACTIVETAB = GS_TAB-PRESSED_TAB.
   GV_PRESSED_TAB_HDR   = GS_TAB-PRESSED_TAB.

 ENDFORM.                    " SET_AND_FILL_HEADER_TAB
*********************************************************************
*       Form  PUT_HEADER_TEXT_DATA
*********************************************************************
 FORM PUT_HEADER_TEXT_DATA.
*....................................................................
* Declaration
*....................................................................
   DATA: LV_TEXT_CHANGED TYPE BEA_BOOLEAN,
         ls_bdi          TYPE /1bea/s_CRMB_BDI_WRK,
         LT_BDI_MANAGE TYPE /1BEA/T_CRMB_BDI_WRK.
*====================================================================
* Implementation
*====================================================================
   CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_PUT'
      EXPORTING
         IS_BDH          = GS_BDH
         IV_MODE         = GC_MODE-UPDATE
      IMPORTING
         ES_BDH          = GS_BDH
         EV_DATA_CHANGED = LV_TEXT_CHANGED
      EXCEPTIONS
         ERROR      = 1
         INCOMPLETE = 2
         OTHERS     = 3.
      IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      IF NOT LV_TEXT_CHANGED IS INITIAL.
        GS_BDH-UPD_TYPE = GC_UPDATE.
        LT_BDI_MANAGE = gt_bdi_manage.
        LOOP AT lt_bdi_manage INTO ls_bdi where
                    bdh_guid = gs_bdh-bdh_guid.
          ls_bdi-upd_type  = gc_update.
          MODIFY lt_bdi_manage FROM ls_bdi TRANSPORTING upd_type.
        ENDLOOP.
        CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
           EXPORTING
             IS_BDH  = GS_BDH
             it_bdi  = lt_bdi_manage.
        MODIFY gt_bdh_manage FROM gs_bdh TRANSPORTING text_error
                            WHERE bdh_guid = gs_bdh-bdh_guid.
        CLEAR GS_BDH-UPD_TYPE.
        LOOP AT gt_bdi_to_bdh INTO ls_bdi.
           CLEAR ls_bdi-upd_type.
           MODIFY gt_bdi_to_bdh FROM ls_bdi TRANSPORTING upd_type.
         ENDLOOP.
         GV_DATA_CHANGED = GC_TRUE.
      ENDIF.
 ENDFORM.                    " PUT_HEADER_TEXT_DATA
*********************************************************************
*       Form  CLOSE_HD_PRC_CONTROL
*********************************************************************
 FORM CLOSE_HD_PRC_CONTROL.
  DATA: LT_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID.
     IF NOT GV_PRC_SESSION_ID IS INITIAL.
       CLEAR LT_PRC_SESSION_ID.
       APPEND GV_PRC_SESSION_ID TO LT_PRC_SESSION_ID.
       CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
            EXPORTING
                 IT_SESSION_ID = LT_PRC_SESSION_ID.
       ENDIF.
     CLEAR GV_PRC_SESSION_ID.
     CALL FUNCTION 'BEA_PRC_U_FREE'.
 ENDFORM.                    " CLOSE_HD_PRC_CONTROL
*********************************************************************
*       Form  CHECK_PPF_CHANGED
*********************************************************************
 FORM CHECK_PPF_CHANGED.
   DATA: LV_PPF_CHANGED TYPE BOOLE_D.
   CALL FUNCTION 'SPPF_VIEW_GET_CHANGED'
      IMPORTING
        PE_CHANGED = LV_PPF_CHANGED.
   IF NOT LV_PPF_CHANGED IS INITIAL.
       GV_DATA_CHANGED = GC_TRUE.
   ENDIF.
 ENDFORM.                    " CHECK_PPF_CHANGED
*********************************************************************
*      FORM  FREE_CONTROLS_210
*********************************************************************
FORM FREE_CONTROLS_210.
*....................................................................
* Declaration
*....................................................................
  DATA: lt_bdh TYPE /1bea/t_CRMB_BDH_wrk.
*====================================================================
* Implementation
*====================================================================
   clear gv_pressed_tab_hdr.
   clear gv_pressed_tab_itm.
   IF NOT GO_ALV_BDI IS INITIAL.
     CALL METHOD GO_ALV_BDI->FREE.
     FREE GO_ALV_BDI.
     REFRESH GT_OUTTAB_BDI.
   ENDIF.
   IF NOT GO_CUSTOM_DOC IS INITIAL.
     CALL METHOD GO_CUSTOM_DOC->FREE.
     FREE GO_CUSTOM_DOC.
   ENDIF.
*--------------------------------------------------------------------
* Destroy docking container
*--------------------------------------------------------------------
   IF NOT GO_DOCKING IS INITIAL.
     CALL METHOD go_docking->get_height
        IMPORTING
           height = gv_height_bdh
        EXCEPTIONS
           OTHERS = 0.
     CALL METHOD cl_pers_admin=>set_data
        EXPORTING
           p_pers_key  = 'BEA_BDH_DETAIL'
           p_uname     = sy-uname
           p_pers_data = gv_height_bdh
        EXCEPTIONS
           OTHERS      = 0.
      CALL METHOD GO_DOCKING->FREE.
      FREE GO_DOCKING.
   ENDIF.
*--------------------------------------------------------------------
* Detail Subscreen
*--------------------------------------------------------------------
   IF NOT GS_SRV_PREPARED-detail IS INITIAL.
      CALL FUNCTION 'BEA_OBJ_U_FREE'.
   ENDIF.
*--------------------------------------------------------------------
* Close Pricing Session
*--------------------------------------------------------------------
   IF NOT GS_SRV_PREPARED-PRC IS INITIAL.
      PERFORM CLOSE_HD_PRC_CONTROL.
   ENDIF.
*--------------------------------------------------------------------
* Close PPF
*--------------------------------------------------------------------
   IF NOT GS_SRV_PREPARED-PPF IS INITIAL.
       CALL FUNCTION 'SPPF_VIEW_END_CRM'.
   ENDIF.
*--------------------------------------------------------------------
* Reset U-Layer of Text Processing
*--------------------------------------------------------------------
   IF NOT GS_SRV_PREPARED-txt IS INITIAL.
     CLEAR lt_bdh.
     APPEND gs_bdh TO lt_bdh.
     CALL FUNCTION 'BEA_TXT_O_RESET_UI'
       EXPORTING
         it_struc    = lt_bdh
         iv_tdobject = gc_bdh_txtobj
         iv_typename = gc_typename_bdh_wrk
      EXCEPTIONS
         error       = 0
         OTHERS      = 0.
   ENDIF.
ENDFORM.                    " FREE_CONTROLS_201
*********************************************************************
*     FORM  POPUP_AND_SAVE_210
*********************************************************************
 FORM POPUP_AND_SAVE_210.
*....................................................................
* Data Declaration
*....................................................................
 CONSTANTS: LC_YES TYPE C VALUE 'J'.
 DATA: LV_ANSWER(1) TYPE C.
*===================================================================
* Implementation
*===================================================================
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
     PERFORM save_210.
     MESSAGE S610(BEA).
   ELSE.
     IF NOT gs_srv_prepared-ppf IS INITIAL.
        CALL FUNCTION 'BEA_PPF_O_TA_UNDO'
          EXCEPTIONS
            ERROR         = 1
            OTHERS        = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
     ENDIF.
     CLEAR gv_data_changed.
     CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
     CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
   ENDIF.
ENDFORM.                    " POPUP_AND_SAVE_210
*********************************************************************
*     FORM  toggle_to_change_210
*********************************************************************
FORM toggle_to_change_210.
*....................................................................
* Declaration
*....................................................................
  DATA: lv_msgv      TYPE symsgv,
        lv_msgv1     TYPE symsgv,
        lv_srvs      TYPE bea_boolean.
*--------------------------------------------------------------------
* Handling when Bill Document is already on the Database
*--------------------------------------------------------------------
  IF gv_mode = gc_bd_process.
*....................................................................
* Check Authority to change
*....................................................................
    CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
      EXPORTING
        IV_BILL_TYPE           = GS_BDH-BILL_TYPE
        IV_BILL_ORG            = GS_BDH-BILL_ORG
        IV_APPL                = gc_appl
        IV_ACTVT               = GC_ACTV_SUPPLEMENT "for SRV-data
        IV_CHECK_DLI           = GC_FALSE
        IV_CHECK_BDH           = GC_TRUE
      EXCEPTIONS
        NO_AUTH                = 1.
    IF SY-SUBRC <> 0.
      IF GS_BDH-BILL_ORG IS INITIAL.
        MESSAGE E309(BEA) WITH GS_BDH-BILL_TYPE.
      ELSE.
        MESSAGE E310(BEA) WITH GS_BDH-BILL_TYPE GS_BDH-BILL_ORG.
      ENDIF.
      RETURN. "from form
    ENDIF.
*....................................................................
* Enqueue the Billing Document
*....................................................................
    CALL FUNCTION 'ENQUEUE_E_BEA_BD'
       EXPORTING
         client         = sy-mandt
         bdh_guid       = gs_bdh-bdh_guid
         appl           = gc_appl
       EXCEPTIONS
         foreign_lock   = 1
         system_failure = 2
         OTHERS         = 3.
    IF sy-subrc <> 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*....................................................................
* Get latest data (if data changed by other user in the meantime)
*....................................................................
    PERFORM GET_LATEST_DATA.
  ENDIF.
*--------------------------------------------------------------------
* Set the global variables in order to have the "change" situation
*--------------------------------------------------------------------
  CLEAR GS_SRV_PREPARED-TXT.
  CLEAR GS_SRV_PREPARED-PPF.
  GV_MAINT_MODE = GC_TRUE.
*--------------------------------------------------------------------
* Message
*--------------------------------------------------------------------
  lv_msgv = text-txt.
  IF lv_msgv IS INITIAL.
    lv_msgv = text-ppf.
  ELSE.
    CONCATENATE lv_msgv text-and text-ppf INTO lv_msgv
                SEPARATED BY SPACE.
    lv_srvs = gc_true.
  ENDIF.
  IF lv_srvs IS INITIAL.
     MESSAGE s157(bea) WITH lv_msgv.
  ELSE.
  ENDIF.
ENDFORM.                    " toggle_to_change_210
*********************************************************************
*     FORM  USER_COMMAND_210
*********************************************************************
FORM USER_COMMAND_210.
*....................................................................
* Declaration
*....................................................................
  DATA:
   LV_OKCODE     TYPE SYUCOMM,
   lt_bdh        TYPE /1BEA/T_CRMB_BDH_WRK.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Handle User Commands
*--------------------------------------------------------------------
   LV_OKCODE = GV_OKCODE.
   CLEAR GV_OKCODE.
   CASE LV_OKCODE.
*....................................................................
* TOGGLE
*....................................................................
     WHEN GC_TOGGLE.
       IF GV_MAINT_MODE IS INITIAL.
         PERFORM toggle_to_change_210.
       ELSE.
         IF     GV_DATA_CHANGED = GC_TRUE
            AND gv_mode = gc_bd_process.
            PERFORM POPUP_AND_SAVE_210.
            PERFORM GET_LATEST_DATA.
         ENDIF.
         IF gv_mode = gc_bd_process.
            PERFORM dequeue_210.
         ENDIF.
         CLEAR GS_SRV_PREPARED-TXT.
         CLEAR GS_SRV_PREPARED-PPF.
         CLEAR GV_MAINT_MODE.
       ENDIF.
*....................................................................
* REFRESH
*....................................................................
     WHEN GC_REFRESH.
       PERFORM GET_LATEST_DATA.
*....................................................................
* BACK
*....................................................................
     WHEN GC_BACK.
       IF     GV_DATA_CHANGED = GC_TRUE
          AND GV_MAINT_MODE   = GC_TRUE
          AND gv_mode = gc_bd_process.
         PERFORM POPUP_AND_SAVE_210.
       ENDIF.
       IF     GV_MODE         = GC_BD_BILL_SGL
          AND GV_DATA_CHANGED = GC_TRUE.
         PERFORM POPUP_AND_SAVE_210.
       ENDIF.
       IF     gv_mode = gc_bd_process
          AND GV_MAINT_MODE   = GC_TRUE.
            PERFORM dequeue_210.
       ENDIF.
       perform FREE_CONTROLS_210.
       CLEAR GV_PRC_SESSION_ID.
       CLEAR GV_OKCODE.
       LEAVE TO SCREEN 0.
     WHEN GC_DUMMY.
       PERFORM INITIALIZE_GLOBALS.
*--------------------------------------------------------------------
* CANCEL (Dialog Cancel!)
*--------------------------------------------------------------------
    WHEN gc_fcode_cancel.
      perform get_alog_msg.
      IF     GV_DATA_CHANGED = GC_TRUE
         AND GV_MAINT_MODE   = GC_TRUE.
        PERFORM POPUP_AND_SAVE_210.
        CHECK GV_DATA_CHANGED = GC_FALSE. "if user declines to save changes
      ENDIF.
      PERFORM cancel_in_show.
      PERFORM INITIALIZE_GLOBALS.
*--------------------------------------------------------------------
* ALOG   Display Application LOG
*--------------------------------------------------------------------
    WHEN GC_APPLLOG.
      perform display_alog_msg.
*....................................................................
* SAVE
*....................................................................
    WHEN GC_SAVE.
      IF GV_DATA_CHANGED = GC_TRUE.
        PERFORM save_210.
        CLEAR GS_SRV_PREPARED-TXT.
        CLEAR GS_SRV_PREPARED-PPF.
        CLEAR GV_PRC_SESSION_ID.
        CLEAR GV_MAINT_MODE.
        PERFORM dequeue_210.
        perform FREE_CONTROLS_210.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S609(BEA).
      ENDIF.
    WHEN GC_ITEM_COLLAPSE.
      PERFORM show_item_detail USING gv_item_focus.
    WHEN GC_HEADER_COLLAPSE.
      PERFORM show_item_detail USING gv_item_focus.
    WHEN GC_ITEM_GET.
      READ TABLE gt_bdi_to_bdh
        WITH KEY bdi_guid = gv_item_title transporting no fields.
      IF sy-subrc = 0.
        gv_item_focus = sy-tabix.
      ENDIF.
      PERFORM show_item_detail USING gv_item_focus.
    WHEN GC_ITEM_PREV.
      gv_item_focus = gv_item_focus - 1.
      PERFORM show_item_detail USING gv_item_focus.
    WHEN GC_ITEM_NEXT.
      gv_item_focus = gv_item_focus + 1.
      PERFORM show_item_detail USING gv_item_focus.
*--------------------------------------------------------------------
* Transfer to accounting
*--------------------------------------------------------------------
        WHEN GC_TRANSFER.
          IF GV_DATA_CHANGED     = GC_TRUE AND
             GV_MAINT_MODE       = GC_TRUE.
            PERFORM POPUP_AND_SAVE_210.
            CHECK GV_DATA_CHANGED = GC_FALSE. "if user declines to save changes
          ENDIF.
          APPEND gs_bdh TO lt_bdh.
          CLEAR gt_return.
            CALL FUNCTION '/1BEA/CRMB_BD_O_TRANSFER'
              EXPORTING
                IT_BDH         = LT_BDH
                IV_COMMIT_FLAG = GC_COMMIT_ASYNC
              IMPORTING
                ET_RETURN      = GT_RETURN.
          if gt_return is initial.
              gs_bdh-transfer_status = gc_transfer_in_work.
              CLEAR gs_bdh-transfer_error.
            CLEAR gs_bdh-mwc_error.
          else.
            append lines of gt_return to gt_alog_msg.
            MESSAGE s132(bea).
          endif.
* Toggle to Display Mode
          IF GV_MAINT_MODE = GC_TRUE.
            IF GV_MODE = GC_BD_PROCESS.
              PERFORM dequeue_210.
            ENDIF.
            CLEAR GS_SRV_PREPARED-TXT.
            CLEAR GS_SRV_PREPARED-PPF.
            CLEAR GV_MAINT_MODE.
          ENDIF.
          gv_action_in_show = gc_data_change_in_show.
*....................................................................
* Data manager of this function module
*....................................................................
      PERFORM data_manager_modify USING gs_bdh gt_bdi_to_bdh.
*....................................................................
* Eventually Calling modules
*....................................................................
      PERFORM modify_global_data_from_caller
              USING gs_bdh gt_bdi_to_bdh 'TRANSFER'.
   ENDCASE.
ENDFORM.                    " USER_COMMAND
*********************************************************************
*     FORM  dequeue_210
*********************************************************************
FORM dequeue_210.
*--------------------------------------------------------------------
* Dequeue the Billing Document
*--------------------------------------------------------------------
     CALL FUNCTION 'DEQUEUE_E_BEA_BD'
       EXPORTING
         client   = sy-mandt
         bdh_guid = gs_bdh-bdh_guid
         appl     = gc_appl.
ENDFORM.                    " dequeue_210
*********************************************************************
*     FORM  SAVE_210
*********************************************************************
FORM SAVE_210.
*--------------------------------------------------------------------
* "SAVE" newly created actions
*--------------------------------------------------------------------
   IF NOT gs_srv_prepared-ppf IS INITIAL.
      CALL FUNCTION 'BEA_PPF_O_TA_END'
        EXCEPTIONS
          error  = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
   ENDIF.
   PERFORM check_change_of_valuta_date.
*--------------------------------------------------------------------
* SAVE BDHs / BDIs
*--------------------------------------------------------------------
   CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
      EXPORTING
        iv_process_mode     = gc_proc_add
        iv_commit_flag      = gc_commit_sync.
   GV_DATA_SAVED = GC_TRUE.
   CLEAR gv_data_changed.
   PERFORM update_from_it_detail.
ENDFORM.                    " SAVE_210
*********************************************************************
*     FORM  check_changes_210
*********************************************************************
FORM check_changes_210.
 IF NOT GV_MAINT_MODE IS INITIAL.
*--------------------------------------------------------------------
* Changes in Texts?
*--------------------------------------------------------------------
  IF     ( GS_TAB-PRESSED_TAB = GC_TAB-TAB4 )  "SRV = Texte
     AND ( NOT gs_srv_prepared-txt IS INITIAL ) .
      PERFORM PUT_HEADER_TEXT_DATA.
  ENDIF.
*--------------------------------------------------------------------
* Change in PPF?
*--------------------------------------------------------------------
  IF     ( GS_TAB-PRESSED_TAB = GC_TAB-TAB5 )  "SRV = PPF
     AND ( NOT gs_srv_prepared-ppf IS INITIAL ) .
      PERFORM CHECK_PPF_CHANGED.
   ENDIF.
* Begin: Value date change
  IF     ( GS_TAB-PRESSED_TAB = GC_TAB-TAB0 )  "SRV = PPF
     OR ( GS_TAB-PRESSED_TAB = GC_TAB-TAB1 ) .
      PERFORM CHECK_CHANGE_OF_VALUTA_DATE.
   ENDIF.

 ENDIF.


ENDFORM.                    " check_changes_210
*********************************************************************
*     FORM  DETAIL_ACTIVE_TAB_GET_210
*********************************************************************
FORM DETAIL_ACTIVE_TAB_GET_210.
*....................................................................
* Declaration
*....................................................................
  DATA: lv_fcode TYPE ui_func.
*====================================================================
* Implementation
*====================================================================
   CASE GV_OKCODE.
     WHEN GC_TAB-TAB0.
       lv_fcode = gc_TAB-TAB0.
     WHEN GC_TAB-TAB1.
       lv_fcode = gc_detail.
     WHEN GC_TAB-TAB2.
       lv_fcode = GC_par.
     WHEN GC_TAB-TAB3.
       lv_fcode = GC_prc.
     WHEN GC_TAB-TAB4.
       lv_fcode = GC_txt.
     WHEN GC_TAB-TAB5.
       lv_fcode = GC_ppf.
     WHEN GC_TAB-TAB6.
       lv_fcode = GC_TAB-TAB6.
     WHEN GC_TAB-TAB7.
       lv_fcode = GC_TAB-TAB7.
     WHEN GC_TAB-TAB8.
       lv_fcode = GC_TAB-TAB8.
     WHEN GC_TAB-TAB9.
       lv_fcode = GC_TAB-TAB9.
     WHEN GC_TAB-TAB10.
       lv_fcode = GC_TAB-TAB10.
     WHEN GC_TAB-TAB13.
       lv_fcode = GC_TAB-TAB13.
   ENDCASE.
   IF NOT lv_fcode IS INITIAL.
     PERFORM eval_ptab_210 USING lv_fcode.
   ENDIF.
ENDFORM.                    " DETAIL_ACTIVE_TAB_GET_210
*********************************************************************
*     FORM  eval_ptab_210
*********************************************************************
FORM eval_ptab_210 USING uv_fcode TYPE UI_FUNC.
*....................................................................
* Declaration
*....................................................................
 DATA: ls_bty TYPE beas_bty_wrk.
*====================================================================
* Implementation
*====================================================================
 GS_TAB-OLD_TAB = GS_TAB-PRESSED_TAB.
 CLEAR GS_TAB-PRESSED_TAB.
 IF uv_fcode is initial.
   GS_TAB-PRESSED_TAB = GC_TAB-TAB0. "General is default
 ENDIF.
 IF uv_fcode = GC_DETAIL.
   GS_TAB-PRESSED_TAB = GC_TAB-TAB1. "Detail
 ENDIF.
 IF    uv_fcode = GC_PAR
    OR uv_fcode = GC_PRC
    OR uv_fcode = GC_TXT
    OR uv_fcode = GC_PPF.
   CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
     EXPORTING
       iv_appl          = gc_appl
       iv_bty           = gs_bdh-bill_type
     IMPORTING
       es_bty_wrk       = ls_bty
     EXCEPTIONS
       object_not_found = 1
       OTHERS           = 2.
   IF sy-subrc <> 0.
     GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   CASE uV_FCODE.
     WHEN GC_PAR.
       IF NOT ls_bty-BDH_PAR_PROC IS INITIAL.
         GS_TAB-PRESSED_TAB = GC_TAB-TAB2.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w800(bea) WITH gs_bdh-bill_type text-par.
       ENDIF.
     WHEN GC_PRC.
       IF ls_bty-PRIC_PROC IS NOT INITIAL OR
          ls_bty-PRC_PPDEFAULT IS NOT INITIAL.
         GS_TAB-PRESSED_TAB = GC_TAB-TAB3.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w801(bea) WITH gs_bdh-bill_type text-prc.
       ENDIF.
     WHEN GC_TXT.
       IF NOT ls_bty-BDH_TXT_PROC IS INITIAL.
         GS_TAB-PRESSED_TAB = GC_TAB-TAB4.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w802(bea) WITH gs_bdh-bill_type text-txt.
       ENDIF.
     WHEN GC_PPF.
       GS_TAB-PRESSED_TAB = GC_TAB-TAB5.
     ENDCASE.
 ENDIF.
 IF GS_TAB-PRESSED_TAB IS INITIAL.
   GS_TAB-PRESSED_TAB = UV_FCODE.
 ENDIF.
ENDFORM.                    " eval_ptab_210

*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Modules
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*       Module  STATUS_210  OUTPUT
*********************************************************************
 MODULE STATUS_210 OUTPUT.

   PERFORM SET_STATUS_210.

 ENDMODULE.                 " STATUS_210  OUTPUT
*********************************************************************
*      Module  detail_active_tab_set_210  OUTPUT
*********************************************************************
 MODULE DETAIL_ACTIVE_TAB_SET_210 OUTPUT.

   PERFORM SET_AND_FILL_HEADER_TAB.

 ENDMODULE.                " DETAIL_ACTIVE_TAB_SET_210 OUTPUT.
*********************************************************************
*      Module  set_screen  OUTPUT
*********************************************************************
 MODULE SET_SCREEN OUTPUT.
   IF GV_BDI_GUID IS NOT INITIAL.
     CLEAR GV_BDI_GUID.
     PERFORM show_item_detail USING gv_item_focus.
     LEAVE SCREEN.
   ENDIF.
 ENDMODULE.                " SET_SCREEN OUTPUT.
*********************************************************************
*      Module  detail_active_tab_get_210  INPUT
*********************************************************************
 MODULE DETAIL_ACTIVE_TAB_GET_210 INPUT.

   PERFORM check_changes_210.

   PERFORM DETAIL_ACTIVE_TAB_GET_210.

 ENDMODULE.                 " detail_active_tab_get_210  INPUT
*********************************************************************
*      Module  user_command_210  INPUT
*********************************************************************
 MODULE USER_COMMAND_210 INPUT.

   PERFORM USER_COMMAND_210.

 ENDMODULE.                 " user_command_210  INPUT
*********************************************************************
*      Module  user_command_at_exit_210  INPUT
*********************************************************************
 MODULE USER_COMMAND_AT_EXIT_210 INPUT.

   PERFORM check_changes_210.

   CASE GV_OKCODE.
     WHEN GC_CANC OR GC_EXIT.
       IF     GV_DATA_CHANGED = GC_TRUE
          AND GV_MAINT_MODE   = GC_TRUE
          AND ( gv_mode       = gc_bd_process or
                gv_mode       = gc_bd_bill_sgl ).
         PERFORM POPUP_AND_SAVE_210.
       ENDIF.
       IF     gv_mode = gc_bd_process
          AND GV_MAINT_MODE   = GC_TRUE.
            PERFORM dequeue_210.
       ENDIF.
       perform FREE_CONTROLS_210.
       IF gv_mode = gc_bd_bill or
          gv_mode =  gc_bd_dial_canc.
         GV_DATA_CHANGED = GC_TRUE.
       ENDIF.
       CLEAR GV_OKCODE.
       LEAVE TO SCREEN 0.
   ENDCASE.

 ENDMODULE.                 " user_command_at_exit_210  INPUT
