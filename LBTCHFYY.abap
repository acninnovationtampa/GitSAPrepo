*----------------------------------------------------------------------*
***INCLUDE LBTCHFYY .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_STATUS_SM37C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN_P  text
*      -->P_STATUS_SET  text
*----------------------------------------------------------------------*
form determine_status_sm37c using select_values structure btcselectp
                                  status_set structure status_set.

  clear status_set.

  if select_values-prelim   eq 'X'.
    status_set-scheduled_flag = 'P'.
  endif.
  if select_values-schedul  eq 'X'.
    status_set-released_flag = 'S'.
  endif.
  if select_values-ready    eq 'X'.
    status_set-ready_flag = 'Y'.
  endif.
  if select_values-running  eq 'X'.
    status_set-active_flag = 'R'.
  endif.
  if select_values-finished  eq 'X'.
    status_set-finished_flag = 'F'.
  endif.
  if select_values-aborted  eq 'X'.
    status_set-cancelled_flag = 'A'.
  endif.

endform.                               " DETERMINE_STATUS_SM37C


*&---------------------------------------------------------------------*
*&      Form  CHECK_VALID_DATE_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BTCH3071_FROM_DATE  text
*      -->P_BTCH3071_TO_DATE  text
*      -->P_BTCH3071_FROM_TIME  text
*      -->P_BTCH3071_TO_TIME  text
*----------------------------------------------------------------------*
form check_valid_date_time using  from_date like sy-datum
                                  to_date   like sy-datum
                                  from_time like sy-uzeit
                                  to_time   like sy-uzeit.

*  if from_date eq no_date.
*    from_date = initial_from_date.
*  endif.
*  if from_time eq no_time.
*    from_time = initial_from_time.
*  endif.
*  if to_date eq no_date or to_date eq '00000000'.
*    to_date = initial_to_date.
*  endif.
*  if to_time eq no_time or to_date eq '000000'.
*    to_time = initial_to_time.
*  endif.

  if (
       to_date < from_date
     )
     or
     (
       to_date eq from_date
       and
       to_time < from_time
     ).
    message e296.
  endif.

endform.                               " CHECK_VALID_DATE_TIME

*-----------------------------------------------------------------------
* form for the progress bar indicator
*-----------------------------------------------------------------------
form indicate_progress_for_part using value(progress_string)
                                                     like done_text
                                      value(total_parts)     type i
                                      value(progress_part)   type i.
  if ( total_parts <> 0 ).
    done_part = 100 / total_parts.
    done_part = done_part * progress_part.
    done_text = progress_string.
  else.
    done_part = 100.
    done_text = text-661.
  endif.

  if ( sy-batch = ' ' ).
    call function 'SAPGUI_PROGRESS_INDICATOR'
         exporting
              percentage = done_part
              text       = done_text
         exceptions
              others     = 0.
  endif.
endform.                               " form indicate_progress_for_part

*&---------------------------------------------------------------------*
*&      Form  handle_under_score_EXTPROG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SELECT_VALUES_EXTPROG  text
*----------------------------------------------------------------------*
form handle_under_score_extprog using string1 like tbtcp-xpgprog.
  data: string_len type i.
  data: new_string(256) value space,   " double the space to avoid
                                       " length overflow
        delimiter(2) value '!_',      " '!' is the escape character used
                                       " later.
        last_one(1).                   " last character in the string
  data: begin of itab occurs 10,
          jobname like tbtco-jobname,
        end of itab.

  split string1 at '_' into table itab.
* if there is an '_' at the end of the string, append an empty line
* at the end of the internal table.  -- just for the special cases
  string_len = strlen( string1 ) - 1.  " consider the offset
  move string1+string_len(1) to last_one.
  if last_one eq '_'.
    append space to itab.
  endif.
  loop at itab.
    if sy-tabix eq 1.
      move itab-jobname to new_string.
      continue.
    endif.
    concatenate new_string itab-jobname
                into new_string separated by delimiter.
  endloop.
* translate the original string.
  string_len = strlen( new_string ).
  if string_len > 128.                 " some jerk being really mean
    move new_string+0(127) to string1. " fix a wild card at the end
    concatenate string1 '%' into string1.
  else.
    move new_string to string1.
  endif.


endform.                               " handle_under_score_EXTPROG
*&---------------------------------------------------------------------*
*&      Form  handle_under_score_EXTCMD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SELECT_VALUES_EXTCMD  text
*----------------------------------------------------------------------*
form handle_under_score_extcmd using string1 like tbtcp-extcmd.
  data: string_len type i.
  data: new_string(36) value space,    " double the space to avoid
                                       " length overflow
        delimiter(2) value '!_',      " '!' is the escape character used
                                       " later.
        last_one(1).                   " last character in the string
  data: begin of itab occurs 10,
          jobname like tbtco-jobname,
        end of itab.

  split string1 at '_' into table itab.
* if there is an '_' at the end of the string, append an empty line
* at the end of the internal table.  -- just for the special cases
  string_len = strlen( string1 ) - 1.  " consider the offset
  move string1+string_len(1) to last_one.
  if last_one eq '_'.
    append space to itab.
  endif.
  loop at itab.
    if sy-tabix eq 1.
      move itab-jobname to new_string.
      continue.
    endif.
    concatenate new_string itab-jobname
                into new_string separated by delimiter.
  endloop.
* translate the original string.
  string_len = strlen( new_string ).
  if string_len > 18.                  " some jerk being really mean
    move new_string+0(17) to string1.  " fix a wild card at the end
    concatenate string1 '%' into string1.
  else.
    move new_string to string1.
  endif.


endform.                               " handle_under_score_EXTCMD
