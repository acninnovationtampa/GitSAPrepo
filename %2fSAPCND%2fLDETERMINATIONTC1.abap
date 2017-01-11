*----------------------------------------------------------------------*
*   INCLUDE LDETERMINATIONTC1                                          *
*----------------------------------------------------------------------*
* Values for VORRC.                                       Further Access
constants:
  gc_vorrc_not_done    type /sapcnd/det_prestep_code value '1',  "Yes
  gc_vorrc_found_exact type /sapcnd/det_prestep_code value '2',  "No
  gc_vorrc_found       type /sapcnd/det_prestep_code value '3',  "Yes
  gc_vorrc_not_found   type /sapcnd/det_prestep_code value '4'.  "No

* Values for STOP_MODE
constants:
  gc_stop_mode_do_not  type /sapcnd/det_stop_mode    value ' ',
  gc_stop_mode_read    type /sapcnd/det_stop_mode    value '1',
  gc_stop_mode_prestep type /sapcnd/det_stop_mode    value 'A'.

* Values for RETURNCODE
constants:
  gc_found             type /sapcnd/det_access_returncode value '00',
  gc_field_initial     type /sapcnd/det_access_returncode value '01',
  gc_not_found         type /sapcnd/det_access_returncode value '02',
  gc_blocked           type /sapcnd/det_access_returncode value '03'.
