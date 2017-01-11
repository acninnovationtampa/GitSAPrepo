FUNCTION /SAPCND/CNF_ANALYSIS_REC .
*"--------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IR_ANALYSIS) TYPE REF TO /SAPCND/CL_DET_ANALYSIS_OW
*"     REFERENCE(IS_MESSAGE) TYPE  /SAPCND/DET_ANALYSIS_MESSAGE
*"     VALUE(IV_CONDITION_ID) TYPE  /SAPCND/COND_TABLE_ENTRY_ID
*"     VALUE(IV_OBJECT_ID) TYPE  /SAPCND/OBJECT_ID
*"     VALUE(IV_REJECT) TYPE  /SAPCND/DET_REJECT_INDICATOR
*"     VALUE(IV_TABIX) TYPE  SYTABIX
*"     VALUE(IV_RELEASE_STATUS) TYPE  /SAPCND/RELEASE_STATUS
*"--------------------------------------------------------------------

  check not iv_condition_id is initial.
  data  ls_message type /sapcnd/det_analysis_message.

  ls_message = is_message.

  case iv_reject.
    when /sapcnd/cl_det_analysis_ow=>reject_no.
      ls_message-msgno = '090'.
    when /sapcnd/cl_det_analysis_ow=>reject_relstat.
      ls_message-msgno = '070'.
      ls_message-msgv1 = iv_release_status.
    when /sapcnd/cl_det_analysis_ow=>reject_prio.
      ls_message-msgno = '080'.
  endcase.
  ls_message-type = /sapcnd/cl_det_analysis_ow=>type_message.
  ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_main.
  ls_message-varnumh = iv_condition_id.

  ls_message-priority       = iv_tabix.
  ls_message-release_status = iv_release_status.
  ls_message-rejection      = iv_reject.

  call method ir_analysis->add_message( ls_message ).

endfunction.
