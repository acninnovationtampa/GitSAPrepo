***INCLUDE <WIZARD> .
*"**********************************************************************
*" makros for the wizard-subscreens
*"**********************************************************************
*- wizard data get
DEFINE swf_data_get.
  call function 'SWF_WIZARD_DIALOG_DATA_GET'
    importing
      data   = &1
    exceptions
      others = 0.
END-OF-DEFINITION.

*- wizard data get
DEFINE swf_data_set.
  call function 'SWF_WIZARD_DIALOG_DATA_SET'
    exporting
      data   = &1
    exceptions
      others = 0.
END-OF-DEFINITION.

*- wizard table get
DEFINE swf_table_get.
  call function 'SWF_WIZARD_DIALOG_DATA_GET'
    tables
      table  = &1
    exceptions
      others = 0.
END-OF-DEFINITION.

*- wizard table set
DEFINE swf_table_set.
  call function 'SWF_WIZARD_DIALOG_DATA_SET'
    tables
      table  = &1
    exceptions
      others = 0.
END-OF-DEFINITION.

*- wizard container get
DEFINE swf_container_get.
  call function 'SWF_WIZARD_DIALOG_DATA_GET'
    tables
      container = &1
    exceptions
      others    = 0.
END-OF-DEFINITION.

*- wizard container set
DEFINE swf_container_set.
  call function 'SWF_WIZARD_DIALOG_DATA_SET'
    tables
      container = &1
    exceptions
      others    = 0.
END-OF-DEFINITION.

*- get wizard ok_code
DEFINE swf_okcode_get.
  call function 'SWF_WIZARD_DIALOG_OKCODE_GET'
    importing
      act_okcode = &1
    exceptions
      others     = 0.
END-OF-DEFINITION.

*- set wizard ok_code
DEFINE swf_okcode_set.
  call function 'SWF_WIZARD_DIALOG_OKCODE_SET'
    exporting
      act_okcode = &1
    exceptions
      others     = 0.
END-OF-DEFINITION.

*- refresh wizard dialog
DEFINE swf_refresh.
  call function 'SWF_WIZARD_DIALOG_REFRESH'
    exceptions
      others = 0.
  exit.
END-OF-DEFINITION.

*- set header of the individual input/output-screens
DEFINE swf_header_set.
  call function 'SWF_WIZARD_DIALOG_MODIFY'
    exporting
      headline = &1
    exceptions
      others   = 0.
END-OF-DEFINITION.

*"**********************************************************************
*" makros for the for-routines (control wizard-process)
*"**********************************************************************
*- evaluate return-code of swf_wizard_call
DEFINE swf_evaluate.
  case sy-subrc.
    when 1.
      &1 = wizard_command_cancel.
      exit.
    when 2.
      &1 = wizard_command_back.
      exit.
    when 0.
      &1 = wizard_command_continue.
  endcase.
END-OF-DEFINITION.

*- exclude step from being processed
DEFINE swf_exclude.
  call function 'SWF_WIZARD_PROCESS_MODIFY'
    exporting
      step_form    = &1
      step_program = &2
      command      = 'D'.
END-OF-DEFINITION.

*- include step to be processed
DEFINE swf_include.
  call function 'SWF_WIZARD_PROCESS_MODIFY'
    exporting
      step_form    = &1
      step_program = &2
      command      = 'A'.
END-OF-DEFINITION.

*- include all steps
DEFINE swf_include_all.
  call function 'SWF_WIZARD_PROCESS_MODIFY'
    exporting
      command = 'C'.
END-OF-DEFINITION.

*- goto specified screen
DEFINE swf_goto.
  call function 'SWF_WIZARD_PROCESS_MODIFY'
    exporting
      step_form    = &1
      step_program = &2
      command      = 'J'.
END-OF-DEFINITION.

*- get the loop index out of a step
DEFINE swf_loop_index_get.
  call function 'SWF_WIZARD_PROCESS_READ'
    exporting
      step_form    = &1
      step_program = &2
    importing
      out_index    = &3.
END-OF-DEFINITION.

*"**********************************************************************
*" constants
*"**********************************************************************
*- constants (boolean)
CONSTANTS: wizard_true                    LIKE sy-input VALUE 'X',
           wizard_false                   LIKE sy-input VALUE space.
*- constants (ok_codes)
CONSTANTS: wizard_command_cancel   TYPE syucomm VALUE 'ABBR',
           wizard_command_end      TYPE syucomm VALUE 'ENDE',
           wizard_command_refresh  TYPE syucomm VALUE 'REFR',
           wizard_command_pick     TYPE syucomm VALUE 'PICK',
           wizard_command_back     TYPE syucomm VALUE '<<  ',
           wizard_command_continue TYPE syucomm VALUE '>>  '.

*- constants (screen types)
CONSTANTS: wizard_screen_start  LIKE swf_wizard-screen_typ VALUE 'STRT',
           wizard_screen_end    LIKE swf_wizard-screen_typ VALUE 'END ',
           wizard_screen_report LIKE swf_wizard-screen_typ VALUE 'REPO',
           wizard_screen_text   LIKE swf_wizard-screen_typ VALUE 'TEXT',
           wizard_screen_normal LIKE swf_wizard-screen_typ VALUE space,
           wizard_screen_entry  LIKE swf_wizard-screen_typ VALUE 'INPT'.
