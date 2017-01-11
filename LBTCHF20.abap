***INCLUDE LBTCHF20 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_COPY                    *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM READ_SOURCEJOB_DATA                                       *
*---------------------------------------------------------------------*
* Die Daten des zu kopierenden Jobs aus der Datenbank lese            *
*---------------------------------------------------------------------*
FORM READ_SOURCEJOB_DATA TABLES  SRC_STEPLIST STRUCTURE TBTCSTEP
                          USING  SRC_JOBNAME
                                 SRC_JOBCOUNT
                                 dialog
                          CHANGING src_jobhead STRUCTURE tbtcjob
                                   p_mess TYPE string
                                   rc.

  DATA: l_subrc TYPE sy-subrc.

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname      = src_jobname
      job_read_jobcount     = src_jobcount
      job_read_opcode       = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead      = src_jobhead
    TABLES
      job_read_steplist     = src_steplist
    EXCEPTIONS
      job_doesnt_exist      = 1
      job_doesnt_have_steps = 2
      OTHERS                = 99.
  l_subrc = sy-subrc.
  IF l_subrc <> 0 AND dialog <> btc_yes.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO p_mess.
  ENDIF.
  CASE l_subrc.
    WHEN 0.
      " Lesen der Jobdaten war erfolgreich
    WHEN 1.
      IF DIALOG EQ BTC_YES.
         MESSAGE S127 WITH SRC_JOBNAME.
      ELSE.
        PERFORM WRITE_JOB_COPY_SYSLOG USING JOBENTRY_DOESNT_EXIST
                                            SRC_JOBNAME.
      ENDIF.
      RC = 1.
      EXIT.
    WHEN 2.
      IF DIALOG EQ BTC_YES.
         MESSAGE S139 WITH SRC_JOBNAME.
      ENDIF.
      PERFORM WRITE_JOB_COPY_SYSLOG USING NO_STEPS_FOUND_IN_DB
                                          SRC_JOBNAME.
      RC = 1.
      EXIT.
    WHEN OTHERS.
      IF DIALOG EQ BTC_YES.
         MESSAGE S155 WITH SRC_JOBNAME.
      ENDIF.
      PERFORM WRITE_JOB_COPY_SYSLOG USING UNKNOWN_JOB_READ_ERROR
                                          SRC_JOBNAME.
      RC = 1.
      EXIT.
    ENDCASE.

    RC = 0.

ENDFORM. " READ_SOURCEJOB_DATA

*---------------------------------------------------------------------*
*      FORM ASK_USER_FOR_JOBNAME                                      *
*---------------------------------------------------------------------*
* Benutzer nach dem Namen des kopierten Jobs Fragen                   *
*---------------------------------------------------------------------*

FORM ASK_USER_FOR_JOBNAME USING JOBNAME RC.

   BTCH1180-JOBNAME = NAME_OF_JOB_TO_COPY.

   CALL SCREEN 1180 STARTING AT 15 10
                    ENDING   AT 66 12.

   IF OKCODE EQ 'CAN' OR
           OKCODE EQ 'ECAN'.  " Benutzer will Kopieren abbrechen
      RC = 1.
      EXIT.
   ELSE.
      JOBNAME = BTCH1180-JOBNAME.
   ENDIF.

   RC = 0.

ENDFORM. " ASK_USER_FOR_JOBNAME USING JOBNAME RC.

*---------------------------------------------------------------------*
*      FORM CREATE_COPIED_JOB                                         *
*---------------------------------------------------------------------*
* Jobkopie erzeugen (neuen Job erzeugen)                              *
*---------------------------------------------------------------------*

FORM CREATE_COPIED_JOB TABLES SRC_STEPLIST
                       USING  dialog
                       CHANGING src_jobhead STRUCTURE tbtcjob
                                p_mess TYPE string
                              RC.

  DATA: org_comm TYPE sy-ucomm.
  DATA: c_rc TYPE sy-subrc.

  org_comm = sy-ucomm.
  sy-ucomm = 'JCPY'.

  CALL FUNCTION 'BP_JOB_CREATE'
    EXPORTING
      job_cr_dialog   = btc_no
      job_cr_head_inp = src_jobhead
    IMPORTING
      job_cr_head_out = src_jobhead
    TABLES
      job_cr_steplist = src_steplist
    EXCEPTIONS
      OTHERS          = 99.

  c_rc = sy-subrc.
  sy-ucomm = org_comm.

  IF c_RC NE 0.
    IF DIALOG EQ BTC_YES.                     " im Nichtdialogfall
      MESSAGE s149 WITH src_jobhead-jobname. " schreibt BP_JOB_CREATE Syslogs
    ELSE.
      MESSAGE s149 WITH src_jobhead-jobname INTO p_mess.
    ENDIF.
    RC = 1.
    EXIT.
  ENDIF.

  RC = 0.

ENDFORM. " CREATE_COPIED_JOB

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_COPY_SYSLOG                                     *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM WRITE_JOB_COPY_SYSLOG USING SYSLOGID DATA.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD JOB_COPY_PROBLEM_DETECTED.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD SYSLOGID
        ID 'DATA' FIELD DATA.

ENDFORM. " WRITE_JOB_COPY_SYSLOG USING SYSLOGID DATA.
