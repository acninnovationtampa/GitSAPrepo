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
*------------------------------------------------------------------
*  Include           BETX_PRCOBD_TBC
*------------------------------------------------------------------
 data:
   lv_date_from        type d,
   lv_time_from        type t,
   lv_date_to          type d,
   lv_time_to          type t.
  convert time stamp is_bdi_wrk-base_time_from
          time zone  is_bdi_wrk-base_timezone
          into date  lv_date_from
          time       lv_time_from.
  convert time stamp is_bdi_wrk-base_time_to
          time zone  is_bdi_wrk-base_timezone
          into date  lv_date_to
          time       lv_time_to.
*       check whether to subtract one second of the settlement period
*       so that pricing knows there is no extra day
  if lv_time_from = lv_time_to.
    if lv_time_to = '000000'.
      lv_date_to = lv_date_to - 1.
      lv_time_to = '235959'.
    else.
      lv_time_to = lv_time_to - 1.
    endif.
  endif.
* now convert date and time into timestamp but keep the timezone
  convert date  lv_date_to
          time  lv_time_to
          into time stamp ls_prc_item-base_time_to
          time zone is_bdi_wrk-base_timezone.
