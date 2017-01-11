FUNCTION /1BEA/CRMB_BD_U_IT_SHOWDETAIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IV_MODE) TYPE  BEA_BD_UIMODE DEFAULT 'A'
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
* Time  : 13:53:01
*
*======================================================================
*********************************************************************
* Processing Logic
*********************************************************************
* The Processing Logic relies on the fact, that the caller gives over
* ALL items of one bill document
*--------------------------------------------------------------------
* Transfer of the input to global variables
*--------------------------------------------------------------------
 gs_bdh        = is_bdh.
 gt_bdi_to_bdh = IT_BDI.
 GV_MODE       = IV_MODE.

* IT_BDI could be unsorted when delivered from ALV (Doubleclick / User Command 'DETAIL'
 READ TABLE gt_bdi_to_bdh INDEX iv_tabix INTO gs_bdi.
 sort gt_bdi_to_bdh by itemno_ext.
 READ TABLE gt_bdi_to_bdh
   with key bdi_guid = gs_bdi-bdi_guid
   transporting no fields.
 if sy-subrc = 0.
   gv_item_focus = sy-tabix.
 endif.
*--------------------------------------------------------------------
* Reset PRC Session if opened in READONLY-Mode
*--------------------------------------------------------------------
 IF gv_prc_session_id IS NOT INITIAL.
   DATA: lv_write_mode type c.
   call function 'BEA_PRC_O_HNDL_GET'
     exporting
       iv_session_id     = gv_prc_session_id
     importing
       ev_write_mode     = lv_write_mode
     exceptions
       others            = 0.
   IF lv_write_mode = gc_prc_pd_readonly.
     PERFORM CLOSE_HD_PRC_CONTROL.
   ENDIF.
 ENDIF.
*--------------------------------------------------------------------
* Reset some global variables
*--------------------------------------------------------------------
 PERFORM Free_ui.
 CLEAR GS_SRV_PREPARED.
 CLEAR gs_tab.
*--------------------------------------------------------------------
* Fill the text fields for the tabstrips
*--------------------------------------------------------------------
 GV_DETAIL_TAB0            = TEXT-GNL.
 GV_DETAIL_TAB1            = TEXT-ITO.
 GV_DETAIL_TAB2            = TEXT-PAR.
 GV_DETAIL_TAB3            = TEXT-PRC.
 GV_DETAIL_TAB4            = TEXT-TXT.
 GV_DETAIL_TAB9            = TEXT-STS.
 GV_DETAIL_TAB10           = TEXT-DFW.
*--------------------------------------------------------------------
* Which BDI to display?
*--------------------------------------------------------------------
 READ TABLE gt_bdi_to_bdh INDEX gv_item_focus INTO gs_bdi.
 IF NOT sy-subrc IS INITIAL.
   MESSAGE e164(bea).
 ENDIF.
*--------------------------------------------------------------------
* Evaluate FCODE input
*--------------------------------------------------------------------
 IF IV_FCODE IS INITIAL.
   GS_TAB-PRESSED_TAB = GC_TAB-TAB0.
 ELSE.
   PERFORM eval_ptab_220 USING iv_fcode.
 ENDIF.
*--------------------------------------------------------------------
* Call Screen
*--------------------------------------------------------------------
 SET SCREEN 0420.
ENDFUNCTION.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Form Routines
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*     Form  STATUS_220
*********************************************************************
FORM STATUS_220.
*....................................................................
* Declaration
*....................................................................
   DATA: LT_FCODE_exl   TYPE SYUCOMM_T,
         lv_cancel      TYPE bea_boolean,
         LV_LINES       TYPE I,
         lv_headno_ext  type bea_headno_ext,
         lv_description TYPE BEA_DESCRIPTION,
         lv_chngbl_srv  TYPE bea_boolean,
         lv_item_id     TYPE vrm_id,
         lV_ALOG        TYPE smp_dyntxt.
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
* Titlebar
*--------------------------------------------------------------------
*....................................................................
* Prepare Title
*....................................................................
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
     SET TITLEBAR 'BD_ITEM_DETAIL' OF PROGRAM GC_PROG_STAT_TITLE
                    with lv_description lv_headno_ext.
   ELSE.
     SET TITLEBAR 'BD_ITEM_DETAIL_UPD' OF PROGRAM GC_PROG_STAT_TITLE
                   with lv_description lv_headno_ext.
   ENDIF.
*--------------------------------------------------------------------
* Menu Status
*--------------------------------------------------------------------
   CLEAR lt_fcode_exl.
*....................................................................
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
      APPEND GC_APPLLOG TO lt_fcode_exl.
      APPEND gc_transfer  TO lt_fcode_exl.
      APPEND gc_fcode_toggle TO lt_fcode_exl.
    WHEN OTHERS. "mode DISPLAY and TRANSFER
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
* Eliminate non active Tabs
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
* Event for calling subscreens in other tabs
      MODIFY SCREEN.
    ENDLOOP.
ENDFORM.                    " STATUS_220
*********************************************************************
*     FORM  SET_AND_FILL_ITEM_TAB
*********************************************************************
FORM SET_AND_FILL_ITEM_TAB.
*....................................................................
* Declaration
*....................................................................
  DATA: LV_REUSE_DOC  TYPE BEA_BOOLEAN VALUE gc_true,
        lv_height     TYPE i,
        ls_bdi_dsp    TYPE /1bea/s_CRMB_BDI_dsp,
        ls_bdi        TYPE /1bea/s_CRMB_BDI_wrk,
        lt_bdi        TYPE /1bea/t_CRMB_BDI_wrk,
        LT_DOCFLOW    TYPE BEAT_DFL_OUT,
        lv_mode       TYPE bea_bd_uimode.
  DATA: LV_PRC_ITEM_NO    TYPE PRCT_ITEM_NO,
        LV_PRC_WRITE_MODE TYPE c,
        lv_allowed        TYPE bea_boolean.
*====================================================================
* Upper Part of the Screen
*====================================================================
*--------------------------------------------------------------------
* Which BDI to display?
*--------------------------------------------------------------------
  READ TABLE gt_bdi_to_bdh INDEX gv_item_focus INTO gs_bdi.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e164(bea).
  ENDIF.
*====================================================================
* Detail and SRVs
*====================================================================
*--------------------------------------------------------------------
* General
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB0.
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0225'.
       IF GS_SRV_PREPARED-GENERAL IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_U_IT_INT2EXT'
           EXPORTING
             is_bdi     = GS_BDI
           IMPORTING
             es_bdi_dsp = ls_bdi_dsp.
         MOVE-CORRESPONDING ls_bdi_dsp to BEAS_BDI_TAB_GENERAL.
         GS_SRV_PREPARED-GENERAL = GC_TRUE.
       ENDIF.
     ENDIF.
*--------------------------------------------------------------------
* Details of the bill item
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB1.
       CLEAR GS_TAB-SUBSCREEN.  " dummy because of "event"
* Detail in dynpro (CRMB only)
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0226'.
       IF GS_SRV_PREPARED-DETAIL IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_U_IT_INT2EXT'
           EXPORTING
             is_bdi     = GS_BDI
           IMPORTING
             es_bdi_dsp = ls_bdi_dsp.
         MOVE-CORRESPONDING ls_bdi_dsp to /1BEA/S_CRMB_BDI_DSP.
         GS_SRV_PREPARED-DETAIL = GC_TRUE.
       ENDIF.
      IF GS_TAB-SUBSCREEN IS INITIAL.
       GS_TAB-PROG = 'SAPLBEA_OBJ_U'.
       GS_TAB-SUBSCREEN = '0100'.
       IF GS_SRV_PREPARED-DETAIL IS INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_U_DETAIL_BDI'
           EXPORTING
             IS_BDI = GS_BDI.
         GS_SRV_PREPARED-DETAIL = GC_TRUE.
       ENDIF.
     ENDIF.
   ENDIF.
*--------------------------------------------------------------------
* Status
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB9.
       GS_TAB-PROG = '/1BEA/SAPLCRMB_BD_U'.
       GS_TAB-SUBSCREEN = '0229'.
       IF GS_SRV_PREPARED-STATUS IS INITIAL.
         MOVE-CORRESPONDING gs_bdi to BEAS_BDI_TAB_STATUS.
         GS_SRV_PREPARED-STATUS = GC_TRUE.
       ENDIF.
     ENDIF.
*--------------------------------------------------------------------
* DocFlow
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB10.
       GS_TAB-PROG = 'SAPLBEA_OBJ_U'.
       GS_TAB-SUBSCREEN = '0301'.
       IF GS_SRV_PREPARED-DOCFLOW IS INITIAL.
         clear lt_docflow.
         CALL FUNCTION '/1BEA/CRMB_DL_O_DOCFL_BDI_GET'
           EXPORTING
             is_bdi           = GS_BDI
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
               IV_LEVEL      = GC_DFL_ITEM
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
         IF    ( GS_BDI-ITEM_CATEGORY <> GS_ITC_WRK-ITEM_CATEGORY )
            OR ( GS_ITC_WRK IS INITIAL ).
           CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
             EXPORTING
               IV_APPL                = GC_APPL
               IV_ITC                 = GS_BDI-ITEM_CATEGORY
             IMPORTING
               ES_ITC_WRK             = GS_ITC_WRK
             EXCEPTIONS
               OBJECT_NOT_FOUND       = 1
               OTHERS                 = 2.
           IF SY-SUBRC <> 0.
             GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
             MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             RETURN. "from form
           ENDIF.
       ENDIF.
       CALL FUNCTION 'BEA_PAR_U_DISPLAY'
          EXPORTING
            IV_PARSET_GUID             = gs_bdi-parset_guid
            IV_PAR_PROCEDURE           = GS_ITC_WRK-BDI_PAR_PROC
            IV_OBJTYPE                 = GC_BOR_BDI
          EXCEPTIONS
            REJECT                     = 1
            OTHERS                     = 2.
       IF SY-SUBRC <> 0.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         RETURN. "from form
       ENDIF.
       GS_SRV_PREPARED-PAR = GC_TRUE.
    ENDIF.
    GS_TAB-PROG = 'SAPLCOM_PARTNER_UI2'.
    GS_TAB-SUBSCREEN = '2000'.
  ENDIF.
     DATA: LV_PRC_NO_EDIT   TYPE BEA_PRC_EDIT_MODE,
           LS_PRC_ITEM      TYPE PRCT_ITEM_COM_VAR.
*--------------------------------------------------------------------
* Pricing
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB3.
        IF GS_SRV_PREPARED-PRC IS INITIAL.
           LV_PRC_ITEM_NO = GS_BDI-BDI_GUID.
*....................................................................
* Document already on the database -> OPEN a session
*....................................................................
           IF NOT (    gv_mode = gc_bd_bill
                    OR gv_mode = gc_bd_bill_sgl ) .
              PERFORM price_change_allowed CHANGING lv_allowed.
              IF    ( NOT GV_MAINT_MODE IS INITIAL )
                AND ( lv_allowed = gc_true ) .
                 LV_PRC_WRITE_MODE = gc_prc_pd_readwrit.
              ELSE.
                 LV_PRC_WRITE_MODE = gc_prc_pd_readonly.
              ENDIF.
              IF GV_PRC_SESSION_ID IS INITIAL.
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
                    MESSAGE ID SY-MSGID TYPE sy-msgty NUMBER SY-MSGNO
                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                    RETURN. "from form
                 ELSE.
                    IF LV_PRC_WRITE_MODE = gc_prc_pd_readwrit.
                      gs_bdh-PRC_SESSION_ID = GV_PRC_SESSION_ID.
                    ENDIF.
                 ENDIF.
              ENDIF.
*....................................................................
* Otherwise, take the session, that is already open (in WRITE_MODE!)
*....................................................................
           ELSE.
             IF     ( NOT gs_bdh-PRC_SESSION_ID IS INITIAL )
                AND (    GS_BDH-TRANSFER_STATUS = GC_TRANSFER_TODO
                      OR GS_BDH-TRANSFER_STATUS = GC_TRANSFER_NO_UI
                      OR GS_BDH-TRANSFER_STATUS = GC_TRANSFER_BLOCK ).
                GV_PRC_SESSION_ID = gs_bdh-PRC_SESSION_ID.
             ELSE.
                MESSAGE e164(bea).
             ENDIF.
           ENDIF.
           IF GS_BDI-REVERSAL    EQ GC_REVERSAL_CORREC  OR
              GS_BDI-REVERSAL    EQ GC_REVERSAL_CANCEL  OR
              GS_BDI-IS_REVERSED EQ GC_IS_REVED_BY_CANC OR
              GS_BDI-IS_REVERSED EQ GC_IS_REVED_BY_CORR.
             LV_PRC_NO_EDIT = GC_TRUE.
           ENDIF.
* Event BD_UISD2
  INCLUDE %2f1BEA%2fX_CRMBBD_UISD2CMLOBD_IS2.
           CALL FUNCTION 'BEA_PRC_U_SET_PD'
              EXPORTING
                IV_PRC_SESSION_ID = GV_PRC_SESSION_ID
                IV_PD_ITEM_NO     = LV_PRC_ITEM_NO
                IV_NO_EDIT        = LV_PRC_NO_EDIT.
           GS_SRV_PREPARED-PRC = GC_TRUE.
        ENDIF.
        GS_TAB-PROG = 'SAPLBEA_PRC_U'.
        GS_TAB-SUBSCREEN = '1000'.
      ENDIF.
*--------------------------------------------------------------------
* Texte
*--------------------------------------------------------------------
     IF GS_TAB-PRESSED_TAB = GC_TAB-TAB4.
        IF GS_SRV_PREPARED-TXT IS INITIAL.
          IF GV_MAINT_MODE IS INITIAL.
*....................................................................
* Display mode
*....................................................................
            CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_READ'
              EXPORTING
                IS_BDI     = GS_BDI
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
            CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_PROVID'
              EXPORTING
                IS_BDI     = GS_BDI
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
*....................................................................
* Update mode -> REFRESH buffer and READ
*....................................................................
            IF gv_mode = gc_bd_process.
              CLEAR lt_bdi.
              APPEND gs_bdi TO lt_bdi.
              CALL FUNCTION 'BEA_TXT_O_REFRESH'
                EXPORTING
                  it_struc    = lt_bdi
                  iv_tdobject = gc_bdi_txtobj
                  iv_typename = gc_typename_bdi_wrk
                  iv_appl     = gc_appl
                EXCEPTIONS
                  error       = 0
                  OTHERS      = 0.
            ENDIF.
            CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_READ'
              EXPORTING
                IS_BDI     = GS_BDI
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
        IF NOT GV_MAINT_MODE IS INITIAL.
           CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_PROVID'
             EXPORTING
               IS_BDI     = GS_BDI
               IV_MODE    = GC_MODE-UPDATE
             EXCEPTIONS
               ERROR      = 1
               INCOMPLETE = 2
               OTHERS     = 3.
           IF SY-SUBRC <> 0.
              GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
              MESSAGE ID SY-MSGID TYPE GC_SMESSAGE NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              RETURN. "from form
           ENDIF.
        ENDIF.
        GS_TAB-PROG = 'SAPLCOM_TEXT_MAINTENANCE'.
        GS_TAB-SUBSCREEN = '2100'.
     ENDIF.
* Event for calling subscreens in other tabs

  DETAIL-ACTIVETAB   = GS_TAB-PRESSED_TAB.
  GV_PRESSED_TAB_ITM = GS_TAB-PRESSED_TAB.

ENDFORM.                    " SET_AND_FILL_ITEM_TAB

*********************************************************************
*       Form  PUT_ITEM_TEXT_DATA
*********************************************************************
FORM PUT_ITEM_TEXT_DATA.
*....................................................................
* Declaration
*....................................................................
  DATA: LV_TEXT_CHANGED TYPE BEA_BOOLEAN,
        Ls_BDI          TYPE /1BEA/s_CRMB_BDI_WRK,
        LT_BDI_MANAGE TYPE /1BEA/T_CRMB_BDI_WRK.
*====================================================================
* Implementation
*====================================================================
        CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_IT_PUT'
          EXPORTING
            IS_BDI          = GS_BDI
            IV_MODE         = GC_MODE-UPDATE
          IMPORTING
            ES_BDI          = GS_BDI
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
          LT_BDI_MANAGE = gt_bdi_to_bdh.
          LOOP AT lt_bdi_manage INTO ls_bdi where
                      bdh_guid = gs_bdh-bdh_guid.
            ls_bdi-upd_type  = gc_update.
            IF ls_bdi-BDI_GUID = GS_BDI-BDI_GUID.
              ls_bdi-text_error = GS_BDI-text_error.
              ls_bdi-net_value = GS_BDI-net_value.
              ls_bdi-tax_value = GS_BDI-tax_value.
              ls_bdi-gross_value = GS_BDI-gross_value.
            ENDIF.
            MODIFY lt_bdi_manage FROM ls_bdi
                   TRANSPORTING upd_type text_error net_value tax_value gross_value.
          ENDLOOP.
          CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
             EXPORTING
                IS_BDH  = GS_BDH
                it_bdi  = lt_bdi_manage.
          MODIFY gt_bdi_manage FROM gs_bdi TRANSPORTING text_error
                               WHERE bdi_guid = gs_bdi-bdi_guid.
          CLEAR GS_BDH-UPD_TYPE.
          LOOP AT gt_bdi_to_bdh INTO ls_bdi.
            CLEAR ls_bdi-upd_type.
            MODIFY gt_bdi_to_bdh FROM ls_bdi TRANSPORTING upd_type.
          ENDLOOP.
          GV_DATA_CHANGED = GC_TRUE.
        ENDIF.
ENDFORM.                    " PUT_ITEM_TEXT_DATA
*********************************************************************
*       Form  CLOSE_IT_PRC_CONTROL
*********************************************************************
 FORM CLOSE_IT_PRC_CONTROL.
  DATA: LT_PRC_SESSION_ID TYPE BEAT_PRC_SESSION_ID.
     IF      NOT GV_PRC_SESSION_ID IS INITIAL.
       IF NOT (    gv_mode = gc_bd_bill
                OR gv_mode = gc_bd_bill_sgl ) .
         REFRESH LT_PRC_SESSION_ID.
         APPEND GV_PRC_SESSION_ID TO LT_PRC_SESSION_ID.
         CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
            EXPORTING
               IT_SESSION_ID = LT_PRC_SESSION_ID.
       ENDIF.
       CLEAR GV_PRC_SESSION_ID.
     ENDIF.
     CALL FUNCTION 'BEA_PRC_U_FREE'.
 ENDFORM.                    " CLOSE_IT_PRC_CONTROL
*********************************************************************
*       Form  CHECK_PRC_CHANGED
*********************************************************************
 FORM CHECK_PRC_CHANGED.
*....................................................................
* Declaration
*....................................................................
   DATA: LV_PRC_CHANGED TYPE C,
         LS_BDI         TYPE /1BEA/S_CRMB_BDI_WRK.
*====================================================================
* Implementation
*====================================================================
   CALL FUNCTION 'BEA_PRC_U_HAS_CHANGED'
     IMPORTING
       EV_HAS_CHANGED       = LV_PRC_CHANGED.
   IF NOT LV_PRC_CHANGED IS INITIAL.
     GV_DATA_CHANGED = LV_PRC_CHANGED.
     CLEAR GS_BDH-TAX_VALUE.
     CLEAR GS_BDH-NET_VALUE.
     CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_CHANGE'
        EXPORTING
          IS_BDH           = GS_BDH
          IT_BDI           = gt_bdi_to_bdh
        IMPORTING
          ES_BDH           = GS_BDH
          ET_BDI           = gt_bdi_to_bdh
        EXCEPTIONS
          INCOMPLETE       = 1
          OTHERS           = 2.
     IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        RETURN.
     ENDIF.
     GS_BDH-UPD_TYPE = GC_UPDATE.
     LOOP AT gt_bdi_to_bdh INTO ls_bdi.
       ADD LS_BDI-TAX_VALUE TO GS_BDH-TAX_VALUE.
       ADD LS_BDI-NET_VALUE TO GS_BDH-NET_VALUE.
       ls_bdi-upd_type  = gc_update.
       MODIFY gt_bdi_to_bdh FROM ls_bdi
         TRANSPORTING upd_type tax_value net_value.
     ENDLOOP.
     CALL FUNCTION '/1BEA/CRMB_BD_O_ADD_TO_BUFFER'
        EXPORTING
          IS_BDH  = GS_BDH
          it_bdi  = gt_bdi_to_bdh.
     CLEAR GS_BDH-UPD_TYPE.
     LOOP AT gt_bdi_to_bdh INTO ls_bdi.
        CLEAR ls_bdi-upd_type.
        MODIFY gt_bdi_to_bdh FROM ls_bdi TRANSPORTING upd_type.
     ENDLOOP.
     GV_DATA_CHANGED = GC_TRUE.
     CLEAR GS_SRV_PREPARED-DETAIL.  "Update amounts in detail screen
     CLEAR GS_SRV_PREPARED-GENERAL. "Update in general tab
     PERFORM SET_HEADER_TITLE.      "Update Header Title
     CALL FUNCTION 'TTE_4_DOCUMENT_BUFF_REFRESH'
       EXPORTING
         I_DOCUMENT_ID     = GS_BDH-BDH_GUID
         IV_REMOVE_TTE_DOC = ''.
   ENDIF.
 ENDFORM.                    " CHECK_PRC_CHANGED
*********************************************************************
*      FORM  FREE_CONTROLS_220
*********************************************************************
FORM FREE_CONTROLS_220.
*--------------------------------------------------------------------
* Destroy docking container
*--------------------------------------------------------------------
   IF NOT GO_DOCKING IS INITIAL.
      CALL METHOD go_docking->get_height
         IMPORTING
           height = gv_height_bdi
         EXCEPTIONS
           OTHERS = 0.
      CALL METHOD cl_pers_admin=>set_data
         EXPORTING
           p_pers_key  = 'BEA_BDI_DETAIL'
           p_uname     = sy-uname
           p_pers_data = gv_height_bdi
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
      PERFORM CLOSE_IT_PRC_CONTROL.
   ENDIF.
*--------------------------------------------------------------------
* Reset Text Layer of Text Processing
*--------------------------------------------------------------------
   IF NOT GS_SRV_PREPARED-txt IS INITIAL.
     CALL FUNCTION 'BEA_TXT_O_RESET_UI'
       EXPORTING
         it_struc    = gt_bdi_to_bdh
         iv_tdobject = gc_bdi_txtobj
         iv_typename = gc_typename_bdi_wrk
      EXCEPTIONS
         error       = 0
         OTHERS      = 0.
   ENDIF.
   clear gv_pressed_tab_hdr.
   clear gv_pressed_tab_itm.
ENDFORM.                    " FREE_CONTROLS_220
*********************************************************************
*     FORM  POPUP_AND_SAVE_220
*********************************************************************
 FORM POPUP_AND_SAVE_220.
*....................................................................
* Declaration
*....................................................................
 CONSTANTS: LC_YES TYPE C VALUE 'J'.
 DATA: LV_ANSWER(1) TYPE C.
*====================================================================
* Implementation
*====================================================================
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
     PERFORM save_220.
     MESSAGE S610(BEA).
   ELSE.
     CLEAR GV_DATA_CHANGED.
     CALL FUNCTION '/1BEA/CRMB_BD_O_REFRESH'.
     CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
   ENDIF.
ENDFORM.                    " POPUP_AND_SAVE_220
*********************************************************************
*     FORM  CHECK_AUTHORITY_220
*********************************************************************
FORM CHECK_AUTHORITY_220.

  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
      IV_BILL_TYPE           = gs_bdh-BILL_TYPE
      IV_BILL_ORG            = gs_bdh-BILL_ORG
      IV_APPL                = gc_appl
      IV_ACTVT               = GC_ACTV_SUPPLEMENT "for SRV-data
      IV_CHECK_DLI           = GC_FALSE
      IV_CHECK_BDH           = GC_TRUE
    EXCEPTIONS
      NO_AUTH                = 1.
  IF SY-SUBRC <> 0.
    IF gs_bdh-BILL_ORG IS INITIAL.
      MESSAGE E309(BEA) WITH gs_bdh-BILL_TYPE.
    ELSE.
      MESSAGE E310(BEA)
              WITH gs_bdh-BILL_TYPE gs_bdh-BILL_ORG.
    ENDIF.
    RETURN.
  ENDIF.
ENDFORM.                    "CHECK_AUTHORITY_220
*********************************************************************
*     Form  user_command_220
*********************************************************************
FORM user_command_220.
*....................................................................
* Declaration
*....................................................................
 DATA:
   LV_OKCODE   TYPE SYUCOMM,
   lt_bdh      TYPE /1BEA/T_CRMB_BDH_WRK.
*====================================================================
* Implementation
*====================================================================
   LV_OKCODE = GV_OKCODE.
   CLEAR GV_OKCODE.
   CASE LV_OKCODE.
*--------------------------------------------------------------------
* Toggle
*--------------------------------------------------------------------
     WHEN GC_TOGGLE.
       IF GV_MAINT_MODE IS INITIAL.
         PERFORM toggle_to_change_220.
       ELSE.
         IF     GV_DATA_CHANGED = GC_TRUE
            AND gv_mode = gc_bd_process.
           PERFORM POPUP_AND_SAVE_220.
           PERFORM GET_LATEST_DATA.
         ENDIF.
         PERFORM dequeue_210.  "dequeue billing document header
         CLEAR GV_MAINT_MODE.
         CLEAR: GS_SRV_PREPARED-txt, GS_SRV_PREPARED-prc.
         PERFORM CLOSE_IT_PRC_CONTROL.
       ENDIF.
*....................................................................
* REFRESH
*....................................................................
     WHEN GC_REFRESH.
       PERFORM GET_LATEST_DATA.
*--------------------------------------------------------------------
* Back
*--------------------------------------------------------------------
     WHEN GC_BACK.
       IF     GV_MODE         = GC_BD_BILL_SGL
          AND GV_DATA_CHANGED = GC_TRUE.
         PERFORM POPUP_AND_SAVE_220.
       ENDIF.
       IF     GV_DATA_CHANGED = GC_TRUE
          AND gv_maint_mode   = gc_true
          AND gv_mode = gc_bd_process.
         PERFORM POPUP_AND_SAVE_220.
       ELSEIF GV_DATA_CHANGED = GC_TRUE
          AND gv_maint_mode   = gc_true.
         PERFORM update_from_it_detail.
       ENDIF.
       IF     gv_mode = gc_bd_process
         AND gv_maint_mode   = gc_true.
          PERFORM dequeue_210.  "dequeue billing document header
       ENDIF.
       perform FREE_CONTROLS_220.
       CLEAR gv_okcode.
       LEAVE TO SCREEN 0.
*--------------------------------------------------------------------
* CANCEL (Dialog Cancel!)
*--------------------------------------------------------------------
    WHEN gc_fcode_cancel.
      perform get_alog_msg.
      IF     GV_DATA_CHANGED = GC_TRUE
         AND GV_MAINT_MODE   = GC_TRUE.
        PERFORM POPUP_AND_SAVE_220.
        CHECK GV_DATA_CHANGED = GC_FALSE. "if user declines to save changes
      ENDIF.
      PERFORM cancel_in_show.
      PERFORM INITIALIZE_GLOBALS.
*--------------------------------------------------------------------
* ALOG   Display Application LOG
*--------------------------------------------------------------------
    WHEN GC_APPLLOG.
      perform display_alog_msg.
*--------------------------------------------------------------------
* Save
*--------------------------------------------------------------------
    WHEN GC_SAVE.
      IF GV_DATA_CHANGED = GC_TRUE.
        PERFORM save_220.
        CLEAR gs_srv_prepared-txt.
        CLEAR gs_srv_prepared-prc.
        CLEAR gv_prc_session_id.
        CLEAR gv_maint_mode.
        PERFORM dequeue_210.  "dequeue billing document header
        perform FREE_CONTROLS_220.
        clear gv_data_changed.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S609(BEA).
      ENDIF.
    WHEN GC_ITEM_COLLAPSE.
      CLEAR gv_okcode.
      perform set_header_screen.
    WHEN GC_HEADER_COLLAPSE.
      CLEAR gv_okcode.
      perform set_header_screen.
    WHEN GC_ITEM_GET.
      READ TABLE gt_bdi_to_bdh
        WITH KEY bdi_guid = gv_item_title transporting no fields.
      IF sy-subrc = 0.
        gv_item_focus = sy-tabix.
      ENDIF.
      PERFORM free_ui.
      CLEAR GS_SRV_PREPARED.
*--------------------------------------------------------------------
* Previous Item
*--------------------------------------------------------------------
    WHEN GC_ITEM_PREV.
      gv_item_focus = gv_item_focus - 1.
      PERFORM free_ui.
      CLEAR GS_SRV_PREPARED.
*--------------------------------------------------------------------
* Next Item
*--------------------------------------------------------------------
    WHEN GC_ITEM_NEXT.
      gv_item_focus = gv_item_focus + 1.
      PERFORM free_ui.
      CLEAR GS_SRV_PREPARED.
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
          PERFORM dequeue_210.  "dequeue billing document header
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
endform.                    " user_command_220
*********************************************************************
*     Form  user_command_at_exit_220
*********************************************************************
form user_command_at_exit_220.
*....................................................................
* Declaration
*....................................................................
 DATA: LV_OKCODE TYPE SYUCOMM.
*====================================================================
* Implementation
*====================================================================
   LV_OKCODE = GV_OKCODE.
   CLEAR GV_OKCODE.
   CASE LV_OKCODE.
     WHEN gc_canc OR gc_exit.
       IF     GV_DATA_CHANGED = GC_TRUE
          AND gv_maint_mode   = gc_true
          AND  ( gv_mode      = gc_bd_process or
                 gv_mode      = gc_bd_bill_sgl ).
         PERFORM POPUP_AND_SAVE_220.
       ELSEIF GV_DATA_CHANGED = GC_TRUE
          AND gv_maint_mode   = gc_true.
         PERFORM update_from_it_detail.
       ENDIF.
       PERFORM dequeue_210.  "dequeue billing document header
       perform FREE_CONTROLS_220.
       LEAVE TO SCREEN 0.
   ENDCASE.
endform.                    " user_command_at_exit_220
*********************************************************************
*     Form  detail_active_tab_get_220
*********************************************************************
Form  detail_active_tab_get_220.
*....................................................................
* Declaration
*....................................................................
  DATA: lv_fcode TYPE ui_func.
*====================================================================
* Implementation
*====================================================================
   CASE GV_OKCODE.
     WHEN GC_TAB-TAB0.
       lv_fcode = GC_TAB-TAB0.
     WHEN GC_TAB-TAB1.
       lv_fcode = gc_detail.
     WHEN GC_TAB-TAB2.
       lv_fcode = GC_par.
     WHEN GC_TAB-TAB3.
       lv_fcode = GC_prc.
     WHEN GC_TAB-TAB4.
       lv_fcode = GC_txt.
     WHEN GC_TAB-TAB5.
       lv_fcode = GC_TAB-TAB5.
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
   ENDCASE.
   IF NOT lv_fcode IS INITIAL.
     PERFORM eval_ptab_220 USING lv_fcode.
   ENDIF.
endform.                    " detail_active_tab_get_220
*********************************************************************
*     FORM  check_changes_220
*********************************************************************
FORM check_changes_220.
*--------------------------------------------------------------------
* Changes in Texts?
*--------------------------------------------------------------------
  IF     ( NOT gv_maint_mode IS INITIAL )
     AND ( GS_TAB-PRESSED_TAB = GC_TAB-TAB4 )  "SRV = Texte
     AND ( NOT gs_srv_prepared-txt IS INITIAL ) .
   PERFORM PUT_ITEM_TEXT_DATA.
  ENDIF.
*--------------------------------------------------------------------
* Change in Conditions?
*--------------------------------------------------------------------
  IF     ( NOT gv_maint_mode IS INITIAL )
     AND ( GS_TAB-PRESSED_TAB = GC_TAB-TAB3 )  "SRV = Prc
     AND ( NOT gs_srv_prepared-prc IS INITIAL ) .
      PERFORM CHECK_PRC_CHANGED.
   ENDIF.
ENDFORM.                    " check_changes_220
*********************************************************************
*     FORM  toggle_to_change_220
*********************************************************************
FORM toggle_to_change_220.
*....................................................................
* Declaration
*....................................................................
  CONSTANTS: lc_prc_not_chang_transfer TYPE c VALUE 'Y'.
  DATA: lt_bdh        TYPE /1bea/t_CRMB_BDH_wrk,
        lt_bdi_old    TYPE /1bea/t_CRMB_BDI_wrk,
        lt_bdi_new    TYPE /1bea/t_CRMB_BDI_wrk,
        ls_bdi        TYPE /1bea/s_CRMB_BDI_wrk,
        ls_bdi_h      TYPE /1bea/s_CRMB_BDI_wrk,
        lrs_bdh_guid  TYPE bears_bdh_guid,
        lrt_bdh_guid  TYPE beart_bdh_guid,
        lv_prc_change TYPE c,
        lv_allowed    TYPE bea_boolean,
        lv_txt_change TYPE bea_boolean,
        lv_srvs       TYPE i,
        lv_msgv       TYPE symsgv.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Check Authority
*--------------------------------------------------------------------
  PERFORM CHECK_AUTHORITY_220.
*--------------------------------------------------------------------
* Enqueue the Billing Document
*--------------------------------------------------------------------
  CALL FUNCTION 'ENQUEUE_E_BEA_BD'
     EXPORTING
        CLIENT         = SY-MANDT
        BDH_GUID       = GS_BDH-BDH_GUID
        APPL           = GC_APPL
     EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    RETURN.
  ENDIF.
*--------------------------------------------------------------------
* Get latest data (if data changed by other user in the meantime)
*--------------------------------------------------------------------
  lrs_bdh_guid-sign   = gc_include.
  lrs_bdh_guid-option = gc_equal.
  lrs_bdh_guid-low    = gs_bdh-bdh_guid.
  APPEND lrs_bdh_guid TO lrt_bdh_guid.
  lt_bdi_old = gt_bdi_to_bdh.
  CLEAR: gt_bdi_to_bdh, gs_bdh.
  CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
     EXPORTING
       irt_bdh_bdh_guid = lrt_bdh_guid
     IMPORTING
       et_bdh           = lt_bdh
       et_bdi           = lt_bdi_new.
  READ TABLE lt_bdh INTO gs_bdh INDEX 1.
*....................................................................
* Put Items in the right order in the global table
*....................................................................
  LOOP AT lt_bdi_old INTO ls_bdi.
    READ TABLE lt_bdi_new WITH KEY bdi_guid = ls_bdi-bdi_guid
                          INTO ls_bdi_h.
    APPEND ls_bdi_h TO gt_bdi_to_bdh.
  ENDLOOP.
*--------------------------------------------------------------------
* Check if Prices can still be changed
*--------------------------------------------------------------------
  PERFORM price_change_allowed CHANGING lv_allowed.
  IF lv_allowed = gc_true.
    lv_prc_change = gc_true.
    ADD 1 TO lv_srvs.
    lv_msgv = text-prc.
  ELSE.
    lv_prc_change = lc_prc_not_chang_transfer.
  ENDIF.
*--------------------------------------------------------------------
* Check if Textes can still be changed
*--------------------------------------------------------------------
    lv_txt_change = gc_true.
    IF NOT lv_srvs IS INITIAL.
      CONCATENATE lv_msgv text-and text-txt INTO lv_msgv
                  SEPARATED BY space.
    ELSE.
      lv_msgv = text-txt.
    ENDIF.
    ADD 1 TO lv_srvs.
*--------------------------------------------------------------------
* Set the global variables in order to have the "change" situation
*--------------------------------------------------------------------
  IF lv_txt_change = gc_true.
    CLEAR gs_srv_prepared-txt.
  ENDIF.
  IF lv_prc_change = gc_true.
    CLEAR gs_srv_prepared-prc.
    PERFORM CLOSE_IT_PRC_CONTROL.
  ENDIF.
  gv_maint_mode = gc_true.
*--------------------------------------------------------------------
* Message
*--------------------------------------------------------------------
  IF NOT lv_prc_change = lc_prc_not_chang_transfer.
    IF lv_srvs LE 1.
      MESSAGE s157(bea) WITH lv_msgv.
    ELSE.
      MESSAGE s156(bea) WITH lv_msgv.
    ENDIF.
  ELSE.
      MESSAGE s161(bea).
  ENDIF.
ENDFORM.                    " toggle_to_change_220
*********************************************************************
*     FORM  save_220
*********************************************************************
FORM save_220.
  PERFORM check_change_of_valuta_date.
  CALL FUNCTION '/1BEA/CRMB_BD_O_ADD'
     EXPORTING
       IV_PROCESS_MODE        = GC_PROC_ADD
       IV_COMMIT_FLAG         = GC_COMMIT_SYNC.
  CLEAR GV_DATA_CHANGED.
  GV_DATA_SAVED = GC_TRUE.
  PERFORM update_from_it_detail.
ENDFORM.                    " save_220
*********************************************************************
*     FORM  update_from_it_detail
*********************************************************************
FORM update_from_it_detail.
*....................................................................
* Declaration
*....................................................................
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Inform SHOW_BDH about changes
*--------------------------------------------------------------------
  IF NOT gv_action_in_show = gc_dialog_cancel_in_show.
     gv_action_in_show = gc_data_change_in_show.
  ENDIF.
*--------------------------------------------------------------------
* Update data manager from Function Module SHOW
*--------------------------------------------------------------------
  PERFORM data_manager_modify USING gs_bdh gt_bdi_to_bdh.
*--------------------------------------------------------------------
* Update Tables from the function modules SHOW_BDH / HD_SHOWLIST
*--------------------------------------------------------------------
  PERFORM modify_global_data_from_caller
          USING gs_bdh gt_bdi_to_bdh 'IT_DETAIL'.
ENDFORM.                    " update_from_it_detail
*********************************************************************
*     FORM  Free_ui
*********************************************************************
FORM Free_ui.
*....................................................................
* Declaration
*....................................................................
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* Free Text Screen
*--------------------------------------------------------------------
  IF NOT gs_srv_prepared-txt IS INITIAL.
    CALL FUNCTION 'BEA_TXT_O_RESET_UI'
      EXPORTING
        it_struc    = gt_bdi_to_bdh
        iv_tdobject = gc_bdi_txtobj
        iv_typename = gc_typename_bdi_wrk
      EXCEPTIONS
        error       = 0
        OTHERS      = 0.
  ENDIF.
*--------------------------------------------------------------------
* Free Pricing Screen
*--------------------------------------------------------------------
  IF NOT gs_srv_prepared-prc IS INITIAL.
    CALL FUNCTION 'BEA_PRC_U_FREE'.
  ENDIF.
ENDFORM.                    " Free_ui
*********************************************************************
*     FORM  eval_ptab_220
*********************************************************************
FORM eval_ptab_220 USING uv_fcode TYPE UI_FUNC.
*....................................................................
* Declaration
*....................................................................
 DATA: ls_itc TYPE beas_itc_wrk,
       ls_bty TYPE beas_bty_wrk.
*====================================================================
* Implementation
*====================================================================
 GS_TAB-OLD_TAB = GS_TAB-PRESSED_TAB.
 CLEAR GS_TAB-PRESSED_TAB.
 IF uv_fcode is initial or uv_fcode = GC_DETAIL.
   GS_TAB-PRESSED_TAB = GC_TAB-TAB1. "Detail is default
 ENDIF.
 IF    uv_fcode = GC_PAR
    OR uv_fcode = GC_PRC
    OR uv_fcode = GC_TXT.
*--------------------------------------------------------------------
* In all Cases, the Item Category must be known -> Read it
*--------------------------------------------------------------------
   CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
     EXPORTING
       iv_appl                = gc_appl
       iv_itc                 = gs_bdi-ITEM_CATEGORY
     IMPORTING
       ES_ITC_WRK             = ls_itc
     EXCEPTIONS
       object_not_found = 1
       OTHERS           = 2.
   IF sy-subrc <> 0.
     GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   CASE UV_FCODE.
*--------------------------------------------------------------------
* Tabstrip Partner: Is there a Partner Determination Procedure?
*--------------------------------------------------------------------
     WHEN GC_PAR.
       IF NOT ls_itc-BDI_PAR_PROC IS INITIAL.
         GS_TAB-PRESSED_TAB = GC_TAB-TAB2.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w804(bea) WITH gs_bdi-ITEM_CATEGORY text-par.
       ENDIF.
*--------------------------------------------------------------------
* Tabstrip Conditions:
*--------------------------------------------------------------------
     WHEN GC_PRC.
*....................................................................
* Is there a Pricing Procedure?
*....................................................................
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
       IF ls_bty-PRIC_PROC IS NOT INITIAL OR
          ls_bty-PRC_PPDEFAULT IS NOT INITIAL.
*....................................................................
* Is the item relevant for pricing?
*....................................................................
         IF gs_bdi-pricing_status = gc_prc_stat_notrel.
           GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
           MESSAGE w809(bea).
         ELSE.
           GS_TAB-PRESSED_TAB = GC_TAB-TAB3.
         ENDIF.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w801(bea) WITH gs_bdh-bill_type text-prc.
       ENDIF.
*--------------------------------------------------------------------
* Tabstrip Texts: Is there a Text Determination Procedure?
*--------------------------------------------------------------------
     WHEN GC_TXT.
       IF NOT ls_itc-BDI_TXT_PROC IS INITIAL.
         GS_TAB-PRESSED_TAB = GC_TAB-TAB4.
       ELSE.
         GS_TAB-PRESSED_TAB = GS_TAB-OLD_TAB.
         MESSAGE w805(bea) WITH gs_bdi-ITEM_CATEGORY text-txt.
       ENDIF.
       WHEN OTHERS.
     ENDCASE.
 ENDIF.
 IF GS_TAB-PRESSED_TAB IS INITIAL.
   GS_TAB-PRESSED_TAB = UV_FCODE.
 ENDIF.
ENDFORM.                    " eval_ptab_220
*********************************************************************
*     FORM  price_change_allowed
*********************************************************************
FORM price_change_allowed CHANGING cv_allowed TYPE bea_boolean.
*....................................................................
* Declaration
*....................................................................
*====================================================================
* Implementation
*====================================================================
  CLEAR cv_allowed.
*--------------------------------------------------------------------
* Check Transfer_Status and Check if Cancel-Invoice
*--------------------------------------------------------------------
  IF     (    gs_bdh-transfer_status = gc_transfer_todo
           OR gs_bdh-transfer_status = gc_transfer_block )
     AND ( gs_bdh-cancel_flag IS INITIAL ).
*....................................................................
* Check if cancelled Invoice
*....................................................................
    READ TABLE gt_bdi_to_bdh WITH KEY
               is_reversed = gc_is_reved_by_canc
               TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      cv_allowed = gc_true.
    ENDIF.
  ENDIF.
ENDFORM.                    " price_change_allowed
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* Modules
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*********************************************************************
*       Module  STATUS_220  OUTPUT
*********************************************************************
 MODULE STATUS_220 OUTPUT.

   perform status_220.

 ENDMODULE.                 " STATUS_220  OUTPUT
*********************************************************************
*      Module  detail_active_tab_set_220  OUTPUT
*********************************************************************
 MODULE DETAIL_ACTIVE_TAB_SET_220 OUTPUT.

   PERFORM SET_AND_FILL_ITEM_TAB.

 ENDMODULE.                " DETAIL_ACTIVE_TAB_SET_220 OUTPUT.
*********************************************************************
*      Module  detail_active_tab_get_220  INPUT
*********************************************************************
 MODULE DETAIL_ACTIVE_TAB_GET_220 INPUT.

   PERFORM check_changes_220.

   PERFORM detail_active_tab_get_220.

 ENDMODULE.                 " detail_active_tab_get_220  INPUT
*********************************************************************
*      Module  user_command_220  INPUT
*********************************************************************
 MODULE USER_COMMAND_220 INPUT.

   perform user_command_220.

 ENDMODULE.                 " user_command_220  INPUT
*********************************************************************
*      Module  user_command_at_exit_220  INPUT
*********************************************************************
 MODULE USER_COMMAND_AT_EXIT_220 INPUT.

   PERFORM check_changes_220.

   PERFORM USER_COMMAND_AT_EXIT_220.

 ENDMODULE.                 " user_command_at_exit_110  INPUT
