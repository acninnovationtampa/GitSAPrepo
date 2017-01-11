FUNCTION /1BEA/CRMB_DL_TXT_O_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IT_SELKEY) TYPE  BEAT_TXT_SELKEY OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_TEXT) TYPE  COMT_TEXT_TEXTDATA_T
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
    ls_msg         TYPE  symsg,
    lv_subrc       TYPE  sysubrc,
    ls_msg_var     TYPE  beas_message_var
    .



  CALL FUNCTION 'BEA_TXT_O_GET'
       EXPORTING
            is_struc    = is_dli
            iv_tdobject = gc_dli_txtobj
            iv_typename = gc_typename_dli_wrk
            IT_SELKEY   = IT_SELKEY
       IMPORTING
            et_text     = et_text
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
