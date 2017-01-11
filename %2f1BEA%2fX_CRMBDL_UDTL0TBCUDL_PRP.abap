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
* Conversion of timestamp into date/time
* (convert with respect to given base timezone)

DATA:
  lv_tbcudl_prp_date         TYPE d,
  lv_tbcudl_prp_time         TYPE t,
  lv_tbcudl_prp_date_hlp(12) TYPE c,
  lv_tbcudl_prp_time_hlp(12) TYPE c.

lv_fieldname = 'BASE_TIME_FROM'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
  lv_tabix = sy-tabix.
  CONVERT TIME STAMP is_dli-base_time_from
          TIME ZONE  is_dli-base_timezone
          INTO DATE lv_tbcudl_prp_date TIME lv_tbcudl_prp_time.
  WRITE lv_tbcudl_prp_date to lv_tbcudl_prp_date_hlp.
  WRITE lv_tbcudl_prp_time to lv_tbcudl_prp_time_hlp.
  CONCATENATE lv_tbcudl_prp_date_hlp lv_tbcudl_prp_time_hlp
              into ls_text-text2 SEPARATED BY SPACE.
  MODIFY lt_text FROM ls_text index lv_tabix.
endif.

lv_fieldname = 'BASE_TIME_TO'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
  lv_tabix = sy-tabix.
  CONVERT TIME STAMP is_dli-base_time_to
          TIME ZONE is_dli-base_timezone
          INTO DATE lv_tbcudl_prp_date TIME lv_tbcudl_prp_time.
  WRITE lv_tbcudl_prp_date to lv_tbcudl_prp_date_hlp.
  WRITE lv_tbcudl_prp_time to lv_tbcudl_prp_time_hlp.
  CONCATENATE lv_tbcudl_prp_date_hlp lv_tbcudl_prp_time_hlp
              into ls_text-text2 SEPARATED BY SPACE.
  MODIFY lt_text FROM ls_text index lv_tabix.
endif.
