FUNCTION /1BEA/CRMB_DL_TXT_O_PROVIDE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IV_MODE) TYPE  COMT_TEXT_APPL_MODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      ERROR
*"      INCOMPLETE
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

  DATA:
    lv_txtproc     TYPE  comt_text_det_procedure,
    ls_itc         TYPE  beas_itc_wrk,
    lv_mode        TYPE  comt_text_appl_mode,
    lv_subrc       TYPE  sysubrc,
    ls_msg_var     TYPE  beas_message_var,
    ls_msg         TYPE  symsg,
    ls_logmsg      TYPE  symsg
    .

* EXPLAIN:
* Use generic functions to provide texts of a DL item for display
* via standard subscreens of text processing.

* read customizing for the item category given in the DL item
  CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
       EXPORTING
            iv_appl          = gc_appl
            iv_itc           = is_dli-item_category
       IMPORTING
            es_itc_wrk       = ls_itc
       EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error.
  ENDIF.
  lv_txtproc = ls_itc-dli_txt_proc.

* EXPLAIN:
* Set default manually, such that global constant can be used
* instead of literal.
  IF iv_mode IS INITIAL.
    lv_mode = gc_mode-display.
  ELSE.
    lv_mode = iv_mode.
  ENDIF.

  CALL FUNCTION 'BEA_TXT_O_PROVIDE'
       EXPORTING
            is_struc    = is_dli
            iv_tdobject = gc_dli_txtobj
            iv_txtproc  = lv_txtproc
            iv_typename = gc_typename_dli_wrk
            iv_mode     = lv_mode
       IMPORTING
            et_return   = et_return
       EXCEPTIONS
            error       = 1
            incomplete  = 2
            OTHERS      = 3.

  IF SY-SUBRC <> 0.
    lv_subrc = sy-subrc.
    ls_msg_var-msgv1 = gc_p_dli_itemno.
    ls_msg_var-msgv2 = gc_p_dli_headno.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = is_dli
        IS_MSG_VAR     = ls_msg_var
      IMPORTING
        ES_MSG_VAR     = ls_msg_var.

    CASE lv_subrc.
      WHEN 0.
* everything OK
      WHEN 2.
        MESSAGE E060(BEA_TXT) WITH ls_msg_var-msgv1 ls_msg_var-msgv2
                RAISING incomplete.
      WHEN OTHERS.
        MESSAGE E059(BEA_TXT) WITH ls_msg_var-msgv1 ls_msg_var-msgv2
                RAISING error.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
