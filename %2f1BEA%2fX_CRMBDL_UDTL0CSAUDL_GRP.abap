*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:02
*
*======================================================================
data: lv_csaudlgrp_text_str     type string.
lv_fieldname = 'SRC_BILL_BLOCK'.

read table lt_text with key tabname = space
                            element = space
                            text1   = text-di2
                   transporting no fields.
lv_tabix_hlp = sy-tabix + 1.
loop at lt_text into ls_text from lv_tabix_hlp.
  lv_tabix = sy-tabix.
  if ls_text-element is initial.
    lv_tabix = lv_tabix - 1.
    exit.
  endif.
endloop.

read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
lv_tabix_hlp = sy-tabix.

if lv_tabix_hlp ge lv_tabix.
  lv_tabix_hlp = lv_tabix_hlp + 1.
endif.

if not is_dli-src_bill_block is initial.
  call function 'DDUT_TEXT_FOR_VALUE'
    exporting
      tabname           = 'CRMC_BUPA_CBBL'
      fieldname         = 'REASON'
      value             = is_dli-src_bill_block
      value_is_external = gc_true
    importing
      text              = lv_csaudlgrp_text_str.
  if not lv_csaudlgrp_text_str is initial.
    ls_text-text2 = lv_csaudlgrp_text_str.
  else.
    ls_text-text2 = text-ybr.
  endif.
else.
  ls_text-text2 = text-nbr.
endif.

insert ls_text into lt_text index lv_tabix.
delete lt_text index lv_tabix_hlp.
endif.
