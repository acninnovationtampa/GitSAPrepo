FUNCTION /SAPCND/CNF_ANALYSIS_FLD .
*"--------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IR_ANALYSIS) TYPE REF TO /SAPCND/CL_DET_ANALYSIS_OW
*"     REFERENCE(IS_MESSAGE) TYPE  /SAPCND/DET_ANALYSIS_MESSAGE
*"     VALUE(IV_PRESTEP) TYPE  /SAPCND/BOOLEAN
*"     VALUE(IV_HEADER) TYPE  /SAPCND/BOOLEAN
*"     REFERENCE(IT_PROTO_FLD) TYPE  /SAPCND/DET_ANALYSIS_FLD_T
*"--------------------------------------------------------------------

  statics lw_proto_fld type /sapcnd/det_analysis_fld.
  data    ls_message type  /sapcnd/det_analysis_message.

  ls_message = is_message.

  ls_message-msgno = '010'.                                 "#EC NOTEXT
  ls_message-type = /sapcnd/cl_det_analysis_ow=>type_fieldinfo.
  loop at it_proto_fld into lw_proto_fld.
    if lw_proto_fld-fstst ca ctcus_nosel or lw_proto_fld-fstst eq ctcus_key_no_search.
     ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_determined.
    else.
      if iv_prestep eq ctcus_true and
         iv_header  eq ctcus_false.
        if lw_proto_fld-fstst eq ctcus_hier_access.
          ls_message-subtype =
              /sapcnd/cl_det_analysis_ow=>subtype_hier_prestep.
        else.
         ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_prestep.
       endif.
        else.
          if lw_proto_fld-fstst eq ctcus_hier_access.
            ls_message-subtype =
                /sapcnd/cl_det_analysis_ow=>subtype_hier_compl.
          else.
           ls_message-subtype = /sapcnd/cl_det_analysis_ow=>subtype_compl.
         endif.
          endif.
        endif.
        ls_message-priority  = sy-tabix.
        move-corresponding lw_proto_fld to ls_message-fieldinfo.
        if lw_proto_fld-initial eq ctcus_true.
          ls_message-contents = icon_message_warning_small.
        endif.
        call method ir_analysis->add_message( ls_message ).
      endloop.

    endfunction.
