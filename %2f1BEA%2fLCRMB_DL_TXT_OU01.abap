FUNCTION /1BEA/CRMB_DL_TXT_O_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IS_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
 data:
    ls_msg_var     TYPE  beas_message_var.


* The target object will not be changed by text processing
  IF es_dli_new IS REQUESTED.
    es_dli_new = is_dli_new.
  ENDIF.

  CALL FUNCTION 'BEA_TXT_O_COPY'
       EXPORTING
            is_struc_from = is_dli
            is_struc_to   = is_dli_new
            iv_tdobject   = gc_dli_txtobj
            iv_typename   = gc_typename_dli_wrk
       IMPORTING
            et_return     = et_return
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
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
    MESSAGE E059(BEA_TXT) WITH ls_msg_var-msgv1 ls_msg_var-msgv2
            RAISING REJECT.
  ENDIF.

ENDFUNCTION.
