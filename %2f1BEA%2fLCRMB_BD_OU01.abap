FUNCTION /1BEA/CRMB_BD_O_COLL_RUN_CANC.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_CRP_GUID) TYPE  BEART_CRP_GUID
*"     VALUE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT DEFAULT 'A'
*"     VALUE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
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
* Time  : 13:52:50
*
*======================================================================
 DATA: lv_returncode TYPE sysubrc,
       lt_return     TYPE beat_return,
       lv_crp_guid   TYPE bears_crp_guid,
       lrs_crp_guid  TYPE bears_crp_guid,
       lrt_crp_guid  TYPE beart_crp_guid,
       lt_bdh_wrk    TYPE /1BEA/T_CRMB_BDH_WRK,
       ls_bdh_hlp    TYPE /1BEA/S_CRMB_BDH_WRK,
       lv_count      TYPE i,
       lt_bd_guid    TYPE beat_bd_guids,
       ls_bd_guids   TYPE beas_bd_guids,
       ls_crp        TYPE beas_crp,
       ls_crp_old    TYPE beas_crp,
       lv_loghndl    TYPE balloghndl.


 FIELD-SYMBOLS:
         <ls_bdh_wrk>  TYPE /1bea/s_CRMB_BDH_wrk.

***********************************************************************

 PERFORM AUTH_CHECK_ALL
   USING
     gc_actv_massdata
   CHANGING
     lt_return
     lv_returncode.

 IF NOT lv_returncode IS INITIAL.
   IF et_return IS REQUESTED.
     APPEND LINES OF lt_return TO et_return.
   ENDIF.
   RETURN.
 ENDIF.


 LOOP AT it_crp_guid INTO lv_crp_guid.

   CLEAR: lt_bd_guid, ls_bdh_hlp.

   CALL FUNCTION 'BEA_CRP_O_GETDETAIL'
     EXPORTING
       iv_appl          = 'CRMB'
       iv_crp_guid      = lv_crp_guid-low
     IMPORTING
       es_crp           = ls_crp_old
     EXCEPTIONS
       object_not_found = 1
       OTHERS           = 2.

   CHECK sy-subrc IS INITIAL.

*   Get new CRP

   PERFORM get_new_crp
     CHANGING
       ls_crp
       lt_return.

   PERFORM get_log_hndl
     USING
       ls_crp
     CHANGING
       lv_loghndl
       lt_return.

   lt_bdh_wrk = it_bdh.

   CHECK lt_bdh_wrk IS NOT INITIAL.

   SORT lt_bdh_wrk BY
       bill_type
       bill_org.

   LOOP AT lt_bdh_wrk ASSIGNING <ls_bdh_wrk>
     where crp_guid = lv_crp_guid-low.
     IF ls_bdh_hlp IS NOT INITIAL AND (
        <ls_bdh_wrk>-bill_type <> ls_bdh_hlp-bill_type OR
        <ls_bdh_wrk>-bill_org <> ls_bdh_hlp-bill_org ) OR
        lv_count = GV_MAX_COL_CAN.
       IF lt_bd_guid IS NOT INITIAL.
         CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
           EXPORTING
             it_bd_guids          = lt_bd_guid
            is_crp                = ls_crp
            iv_loghndl            = lv_loghndl
            iv_cause              = gc_cause_cancel
            iv_process_mode       = iv_process_mode
            iv_commit_flag        = iv_commit_flag
                   .
         CLEAR: lv_count,
              lt_bd_guid.
         ls_bd_guids-bdh_guid = <ls_bdh_wrk>-bdh_guid.
         INSERT ls_bd_guids INTO TABLE lt_bd_guid.
         ADD 1 TO lv_count.
       ENDIF.
     ELSE.
       ls_bd_guids-bdh_guid = <ls_bdh_wrk>-bdh_guid.
       INSERT ls_bd_guids INTO TABLE lt_bd_guid.
       ADD 1 TO lv_count.
     ENDIF.

     ls_bdh_hlp = <ls_bdh_wrk>.
   ENDLOOP.

   IF sy-subrc = 0.
     READ TABLE lt_bd_guid WITH KEY <ls_bdh_wrk>-bdh_guid
       TRANSPORTING NO FIELDS.
     if sy-subrc <> 0.
       ls_bd_guids-bdh_guid = <ls_bdh_wrk>-bdh_guid.
       INSERT ls_bd_guids INTO TABLE lt_bd_guid.
       ADD 1 TO lv_count.
     ENDIF.
   ENDIF.

   IF lt_bd_guid IS NOT INITIAL.
     CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
       EXPORTING
         it_bd_guids           = lt_bd_guid
        is_crp                 = ls_crp
        iv_loghndl             = lv_loghndl
         iv_cause              = gc_cause_cancel
         iv_process_mode       = iv_process_mode
         iv_commit_flag        = iv_commit_flag
*        IMPORTING
*          ES_CRP                =
*          EV_LOGHNDL            =
*          ET_RETURN             =
               .
   ENDIF.
 ENDLOOP.
ENDFUNCTION.
*---------------------------------------------------------------------*
*      FORM  GET_NEW_CRP
*---------------------------------------------------------------------*
FORM get_new_crp CHANGING cs_crp    TYPE beas_crp
                     ct_return TYPE beat_return.

 CONSTANTS: lc_crp_type_canc TYPE bea_crp_type VALUE 'B'.
*-----------------------------------------------------------------------
* Get the currently processed
*-----------------------------------------------------------------------
 CLEAR cs_crp.
 CALL FUNCTION 'BEA_CRP_O_GET'
   IMPORTING
     es_crp = cs_crp.
*-----------------------------------------------------------------------
* If there is none, open one
*-----------------------------------------------------------------------
 IF cs_crp IS INITIAL.
   CALL FUNCTION 'BEA_CRP_O_CREATE'
     EXPORTING
       iv_appl            = gc_appl
       iv_type            = lc_crp_type_canc
     IMPORTING
       es_crp             = cs_crp
     EXCEPTIONS
       crp_already_exists = 1
       nr_error           = 2
       OTHERS             = 3.

   IF sy-subrc NE 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
       INTO gv_dummy.
     PERFORM message_add USING space space space space
       CHANGING ct_return.

     IF NOT sy-batch IS INITIAL.
       MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     ENDIF.
     RETURN. "from form
   ENDIF.
 ELSE.
*-----------------------------------------------------------------------
* If there is one, check the type!
*-----------------------------------------------------------------------
   IF NOT cs_crp-type = lc_crp_type_canc.
* Wrong type -> REFRESH and CREATE
     CALL FUNCTION 'BEA_CRP_O_REFRESH'.
     CLEAR cs_crp.
     CALL FUNCTION 'BEA_CRP_O_CREATE'
       EXPORTING
         iv_appl            = gc_appl
         iv_type            = lc_crp_type_canc
       IMPORTING
         es_crp             = cs_crp
       EXCEPTIONS
         crp_already_exists = 1
         nr_error           = 2
         OTHERS             = 3.

     IF sy-subrc NE 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         INTO gv_dummy.
       PERFORM message_add USING space space space space
         CHANGING ct_return.
       IF NOT sy-batch IS INITIAL.
         MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       ENDIF.
       RETURN. "from form
     ENDIF.
   ENDIF.
 ENDIF.
ENDFORM. " get_new_crp
*---------------------------------------------------------------------*
*      FORM  GET_LOG_HNDL
*---------------------------------------------------------------------*
FORM get_log_hndl USING    us_crp     TYPE beas_crp
                CHANGING cv_loghndl TYPE balloghndl
                         ct_return  TYPE beat_return.
  DATA: lv_loghndl TYPE balloghndl.
  CALL FUNCTION 'BEA_AL_O_GETBUFFER'
    IMPORTING
      ev_loghndl = lv_loghndl.

  IF NOT lv_loghndl IS INITIAL.
    cv_loghndl = lv_loghndl.
  ELSE.
    CALL FUNCTION 'BEA_AL_O_CREATE'
      EXPORTING
        iv_appl            = gc_appl
        iv_crp_guid        = us_crp-guid
      IMPORTING
        ev_loghndl         = lv_loghndl
      EXCEPTIONS
        log_already_exists = 1
        log_not_created    = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO gv_dummy.
      PERFORM message_add USING space space space space
        CHANGING ct_return.
      RETURN. "from form
    ELSE.
      cv_loghndl = lv_loghndl.
    ENDIF.
  ENDIF.
ENDFORM.  "get_log_hndl
*-----------------------------------------------------------------*
*       FORM AUTH_CHECK_ALL                                  *
*-----------------------------------------------------------------*
 FORM auth_check_all
  USING
    uv_activity    TYPE activ_auth
  CHANGING
    ct_return      TYPE beat_return
    cv_returncode  TYPE sysubrc.
   CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
     EXPORTING
       iv_bill_type = space
       iv_bill_org  = space
       iv_appl      = gc_appl
       iv_actvt     = uv_activity
       iv_check_dli = gc_true
       iv_check_bdh = gc_false
     EXCEPTIONS
       no_auth      = 1
       OTHERS       = 2.
   IF sy-subrc <> 0.
     cv_returncode = sy-subrc.
     CASE uv_activity.
       WHEN gc_actv_massdata.
         MESSAGE e501(bea) INTO gv_dummy.
       WHEN OTHERS.
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_dummy.
     ENDCASE.
     PERFORM message_add
       USING    space space space space
       CHANGING ct_return.
   ENDIF.
 ENDFORM.                    "AUTH_CHECK_ALL
*---------------------------------------------------------------------*
*     Form  MESSAGE_ADD
*---------------------------------------------------------------------*
 FORM message_add USING uv_object_type TYPE bea_object_type
                        uv_object_guid TYPE any
                        uv_param       TYPE bapi_param
                        uv_row         TYPE bapi_line
                  CHANGING ct_return TYPE beat_return.

   DATA: ls_return      TYPE bapiret2,
         ls_bearet      TYPE beas_return.

   CALL FUNCTION 'BALW_BAPIRETURN_GET2'
     EXPORTING
       type      = sy-msgty
       cl        = sy-msgid
       number    = sy-msgno
       par1      = sy-msgv1
       par2      = sy-msgv2
       par3      = sy-msgv3
       par4      = sy-msgv4
       parameter = uv_param
       row       = uv_row
     IMPORTING
       return    = ls_return.

   MOVE-CORRESPONDING ls_return TO ls_bearet.
   ls_bearet-object_type = uv_object_type.
   ls_bearet-object_guid = uv_object_guid.
   APPEND ls_bearet TO ct_return.

 ENDFORM.                    "message_add

