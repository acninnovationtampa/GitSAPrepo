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
* Conversion of timestamp into date/time (convert with respect
* to UTC as given base timezone already considered)

CONSTANTS:
  lc_tbcubd_ipr_timezone     type sy-zonlo value 'UTC'.
DATA:
  lv_tbcubd_ipr_date         TYPE d,
  lv_tbcubd_ipr_time         TYPE t,
  lv_tbcubd_ipr_date_hlp(12) TYPE c,
  lv_tbcubd_ipr_time_hlp(12) TYPE c.

lv_fieldname = 'BASE_TIME_FROM'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
  lv_tabix = sy-tabix.
  CONVERT TIME STAMP is_bdi-base_time_from
          TIME ZONE lc_tbcubd_ipr_timezone
          INTO DATE lv_tbcubd_ipr_date TIME lv_tbcubd_ipr_time.
  WRITE lv_tbcubd_ipr_date to lv_tbcubd_ipr_date_hlp.
  WRITE lv_tbcubd_ipr_time to lv_tbcubd_ipr_time_hlp.
  CONCATENATE lv_tbcubd_ipr_date_hlp lv_tbcubd_ipr_time_hlp
              into ls_text-text2 SEPARATED BY SPACE.
  MODIFY lt_text FROM ls_text index lv_tabix.
endif.

lv_fieldname = 'BASE_TIME_TO'.
read table lt_text into ls_text with key tabname = lv_tabname
                                         element = lv_fieldname.
if sy-subrc is initial.
  lv_tabix = sy-tabix.
  CONVERT TIME STAMP is_bdi-base_time_to
          TIME ZONE lc_tbcubd_ipr_timezone
          INTO DATE lv_tbcubd_ipr_date TIME lv_tbcubd_ipr_time.
  WRITE lv_tbcubd_ipr_date to lv_tbcubd_ipr_date_hlp.
  WRITE lv_tbcubd_ipr_time to lv_tbcubd_ipr_time_hlp.
  CONCATENATE lv_tbcubd_ipr_date_hlp lv_tbcubd_ipr_time_hlp
              into ls_text-text2 SEPARATED BY SPACE.
  MODIFY lt_text FROM ls_text index lv_tabix.
endif.
