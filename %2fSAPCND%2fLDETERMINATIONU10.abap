function /sapcnd/cnf_logtab_2_range .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IT_LOGTAB) TYPE  /SAPCND/KEY_VALUE_PAIR_TABLE
*"     VALUE(IV_LOGKEY) TYPE  /SAPCND/LOGICAL_KEY
*"     VALUE(IV_TABLE) TYPE  /SAPCND/COND_TABLE_ID
*"     VALUE(IV_TABLEFIELD) TYPE  /SAPCND/FIELDNAME
*"     VALUE(IV_FIELD) TYPE  /SAPCND/FIELDNAME
*"     VALUE(IV_KZINI) TYPE  /SAPCND/FLAG_INITIAL_ALLOWED
*"     VALUE(IV_FSTST) TYPE  /SAPCND/ACCESS_FIELD_TYPE
*"  EXPORTING
*"     REFERENCE(ET_RANGES) TYPE  RSDS_SELOPT_T
*"  CHANGING
*"     VALUE(CT_PROTO_FLD) TYPE  /SAPCND/DET_ANALYSIS_FLD_T
*"  EXCEPTIONS
*"      FIELD_IS_INITIAL
*"----------------------------------------------------------------------

  statics lv_hinit.
  statics lv_firstini.
  data    lw_proto_fld type /sapcnd/det_analysis_fld.

  lw_proto_fld-table      = iv_table.
  lw_proto_fld-tablefield = iv_tablefield.
  lw_proto_fld-field      = iv_field.
  lw_proto_fld-fstst      = iv_fstst.

  clear gw_ranges.
  gw_ranges-sign = 'I'.
  gw_ranges-option = 'EQ'.

  lv_hinit    = yes.
  lv_firstini = no.

  loop at it_logtab into gw_logtab
    where logical_key = iv_logkey.
    clear lw_proto_fld-contents.
    clear lw_proto_fld-initial.
* field not free, kzini not set
    if iv_fstst ne gc_fstst_free and
       iv_kzini is initial.
      if not gw_logtab-logical_value is initial.
        lv_hinit = no.
        gw_ranges-low = gw_logtab-logical_value.
        append gw_ranges to et_ranges.
        lw_proto_fld-contents = gw_logtab-logical_value.
        append lw_proto_fld to ct_proto_fld.
      else.
        clear lw_proto_fld-contents.
        lw_proto_fld-initial = yes.
        append lw_proto_fld to ct_proto_fld.
        raise field_is_initial.
      endif.
* field not free, kzini set
    elseif iv_fstst ne gc_fstst_free and
           not iv_kzini is initial   and
           lv_firstini eq no.
* only one entry in rangetab
      lv_firstini = yes.
      clear  gw_ranges-low.
      append gw_ranges to et_ranges.
      clear lw_proto_fld-contents.
      clear lw_proto_fld-initial.
      append lw_proto_fld to ct_proto_fld.
* field is free and value not initial
    elseif iv_fstst eq gc_fstst_free and
           not gw_logtab-logical_value is initial.
      lv_hinit = no.
      gw_ranges-low = gw_logtab-logical_value.
      append gw_ranges to et_ranges.
      lw_proto_fld-contents = gw_logtab-logical_value.
      append lw_proto_fld to ct_proto_fld.
    endif.
  endloop.
  if sy-subrc ne 0.
    lw_proto_fld-initial = yes.
    if not iv_kzini is initial or iv_fstst eq gc_fstst_free.
      lv_hinit = no.
      clear  gw_ranges-low.
      append gw_ranges to et_ranges.
      clear lw_proto_fld-initial.
    endif.
    clear lw_proto_fld-contents.
    append lw_proto_fld to ct_proto_fld.
  elseif iv_fstst eq gc_fstst_free and lv_hinit eq yes.
    lv_hinit = no.
    clear  gw_ranges-low.
    append gw_ranges to et_ranges.
    clear lw_proto_fld-contents.
    clear lw_proto_fld-initial.
    append lw_proto_fld to ct_proto_fld.
  endif.

  if lv_hinit eq yes.
    raise field_is_initial.
  endif.

endfunction.
