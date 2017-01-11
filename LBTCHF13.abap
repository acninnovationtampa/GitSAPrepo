***INCLUDE LBTCHF13 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_MODIFY                  *
***********************************************************************

*---------------------------------------------------------------------*
*      FORM CHECK_MODE_PARAMETERS                                     *
*---------------------------------------------------------------------*
* Prüfen der Inputparameter DIALOG und OPCODE die die Arbeitsweise    *
* des Funktionsbausteins steueren.                                    *
*---------------------------------------------------------------------*

FORM check_mode_parameters USING dialog opcode rc.

  DATA: opcode_text(4).

  CASE dialog.
    WHEN btc_yes.
      " ok
    WHEN btc_no.
      " ok
    WHEN OTHERS.
      PERFORM write_job_modify_syslog USING invalid_dialog_type space dialog.
      rc = 1.
      EXIT.
  ENDCASE.

  CASE opcode.
    WHEN btc_modify_whole_job.
      " ok.
    WHEN btc_release_job.
      " ok.
    WHEN btc_derelease_job.
      " ok.
    WHEN btc_close_job.
      " ok.
    WHEN OTHERS.
      opcode_text = opcode.
      PERFORM write_job_modify_syslog USING invalid_opcode
                                            space
                                            opcode_text.
      rc = 2.
      EXIT.
  ENDCASE.

  rc = 0.

ENDFORM. " CHECK_MODE_PARAMETERS USING DIALOG OPCODE RC.

*---------------------------------------------------------------------*
*      FORM READ_OLD_JOBDATA                                          *
*---------------------------------------------------------------------*
* Daten des zu modifzierenden Jobs aus der Datenbank lesen            *
*---------------------------------------------------------------------*

FORM read_old_jobdata TABLES old_steplist STRUCTURE tbtcstep
                      USING jobname
                            jobcount
                            read_mode
                            old_jobhead STRUCTURE tbtcjob
                            dialog
                            rc.

  DATA: mod_jobinfo(43).

  CONCATENATE jobname jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname      = jobname
      job_read_jobcount     = jobcount
      job_read_opcode       = read_mode
    IMPORTING
      job_read_jobhead      = old_jobhead
    TABLES
      job_read_steplist     = old_steplist
    EXCEPTIONS
      job_doesnt_exist      = 1
      job_doesnt_have_steps = 2
      OTHERS                = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen der Jobdaten war erfolgreich
    WHEN 1.
      IF dialog EQ btc_yes.
        MESSAGE s127 WITH jobname.
      ELSE.
        PERFORM write_job_modify_syslog USING jobentry_doesnt_exist
                                              space
                                              mod_jobinfo.
      ENDIF.
      rc = 1.
      EXIT.
    WHEN 2.
      IF dialog EQ btc_yes.
        MESSAGE s139 WITH jobname.
      ENDIF.
      PERFORM write_job_modify_syslog USING no_steps_found_in_db
                                            space
                                            mod_jobinfo.
      rc = 1.
      EXIT.

    WHEN OTHERS.
      IF dialog EQ btc_yes.
        MESSAGE s139 WITH jobname.
      ENDIF.
      PERFORM write_job_modify_syslog USING unknown_job_read_error
                                            space
                                            mod_jobinfo.
      rc = 1.
      EXIT.
  ENDCASE.

  rc = 0.

ENDFORM. " READ_OLD_JOBDATA

*---------------------------------------------------------------------*
*      FORM CHECK_JOB_MODIFY_PRIVILEGE                                *
*---------------------------------------------------------------------*
* Prüfen, ob ein Benutzer berechtigt ist, Jobdaten zu modifzieren     *
* Berechtigung liegt vor, wenn:                                       *
*                                                                     *
*  - der Job muß im im Status 'eingeplant' oder 'freigeben' sein      *
*  - der zu ändernde Job von dem Benutzer, der ihn ändern will,       *
*    angelegt worden ist ("eigenen Job ändern") oder                  *
*  - der Benutzer, der den Job ändern will, Batchadministratorbe-     *
*    rechtigung hat                                                   *
*  - im dialogfreien Fall muß bei 'MODIFY_WHOLE_JOB' noch zusätzlich  *
*    der neue gewünschte Status auf Gültigkeit geprüft werden         *
*  - 'Job freigeben' bzw. eine Operation im Dialog ausführen ist      *
*    nicht erlaubt, wenn die Jobdefinition noch nicht abgeschlossen   *
*    worden ist (kann Auftreten bei JOB_OPEN ohne anschliessendes     *
*    JOB_SUBMIT)                                                      *
*                                                                     *
* Diese Routine verlässt sich darauf, daß der Rufer den entsprechenden*
* Job bereits gesperrt hat.                                           *
*                                                                     *
*---------------------------------------------------------------------*

FORM check_job_modify_privilege USING old_jobhead STRUCTURE tbtcjob
                                      new_jobhead STRUCTURE tbtcjob
                                      opcode
                                      dialog
                                      rc.

  DATA: mod_jobinfo(43).

  CONCATENATE old_jobhead-jobname old_jobhead-jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  IF old_jobhead-status NE btc_scheduled AND
     old_jobhead-status NE btc_released AND
     old_jobhead-status NE btc_put_active.
    IF dialog EQ btc_yes.
      MESSAGE s141 WITH old_jobhead-jobname.
    ELSE.
      PERFORM write_job_modify_syslog USING
                                      job_not_modifiable_anymore
*                                          OLD_JOBHEAD-JOBNAME.
                                      space
                                      mod_jobinfo.
    ENDIF.
    rc = modification_not_possible.
    EXIT.
  ENDIF.

  PERFORM check_operation_privilege USING old_jobhead-sdluname rc.

  IF rc NE 0.
    IF dialog EQ btc_yes.
      MESSAGE s140.
    ELSE.
      PERFORM write_job_modify_syslog USING no_job_modify_privilege
*                                             OLD_JOBHEAD-JOBNAME.
                                            space
                                            mod_jobinfo.
    ENDIF.
    rc = no_modif_privilege_given.
    EXIT.
  ENDIF.

  IF dialog EQ btc_no                    AND
     opcode EQ btc_modify_whole_job      AND
     new_jobhead-status NE btc_scheduled AND
     new_jobhead-status NE btc_released.
    PERFORM write_job_modify_syslog USING invalid_jobstatus
                                          mod_jobinfo
                                          new_jobhead-status.
    rc = invalid_new_jobstatus.
    EXIT.
  ENDIF.

  IF old_jobhead-newflag EQ 'O'.
    IF opcode EQ btc_release_job.
      IF dialog EQ btc_yes.
        MESSAGE s181 WITH old_jobhead-jobname.
      ELSE.
        PERFORM write_job_modify_syslog USING
                                        jobdefinition_pending
                                        space
*                                           OLD_JOBHEAD-JOBNAME.
                                        mod_jobinfo.
      ENDIF.
      rc = cant_release_job.
      EXIT.
    ENDIF.

    IF dialog EQ btc_yes.
      MESSAGE s182 WITH old_jobhead-jobname.
      rc = modification_not_possible.
      EXIT.
    ENDIF.
  ENDIF.

  rc = 0.

ENDFORM. " CHECK_MODIFY_PRIVILEGE.

*---------------------------------------------------------------------*
*      FORM SET_JOBSTATUS_IN_DB                                       *
*---------------------------------------------------------------------*
* Speichern eines Jobstatus für einen bestimmten Job in der Daten-    *
* bank mit sofortigem COMMIT, damit die neue Statusinformation        *
* schnellstmöglich in der DB steht.                                   *
*                                                                     *
* Diese Routine verlässt sich darauf, daß der Rufer den entsprechenden*
* Job bereits gesperrt hat.                                           *
*                                                                     *
*---------------------------------------------------------------------*

FORM set_jobstatus_in_db USING jobhead STRUCTURE tbtcjob
                               status
                               dialog
                               rc.

  DATA: mod_jobinfo(43).

  CONCATENATE jobhead-jobname jobhead-jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  CLEAR tbtco.
  MOVE-CORRESPONDING jobhead TO tbtco.
  CLEAR tbtco-jobgroup.  " evtl. vorhandene 'IMMEDIATE'-Info in Job-
  tbtco-status = status. " kopfdaten darf nicht in DB

  UPDATE tbtco.

  IF sy-subrc EQ 0.
    COMMIT WORK.
  ELSE.
    IF dialog EQ btc_yes.
      MESSAGE s144 WITH jobhead-jobname.
    ENDIF.
    PERFORM write_job_modify_syslog USING tbtco_update_db_error
*                                           JOBHEAD-JOBNAME.
                                          space
                                          mod_jobinfo.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM. " SET_JOBSTATUS_IN_DB

*---------------------------------------------------------------------*
*      FORM RELEASE_MODIFIED_JOB                                      *
*---------------------------------------------------------------------*
* Modifizierten Job in der Datenbank freigeben                        *
*                                                                     *
* Diese Routine verlässt sich darauf, daß der Rufer die entsprechenden*
* Starttermindaten bereits gesperrt hat.                              *
*                                                                     *
* Achtung ! COMMIT bzw. ROLLBACK ist vom Rufer auszuführen            *
*                                                                     *
*---------------------------------------------------------------------*
FORM release_modified_job USING new_jobhead STRUCTURE tbtcjob
                                new_stdt    STRUCTURE tbtcstrt
                                old_jobhead STRUCTURE tbtcjob
                                old_stdt    STRUCTURE tbtcstrt
                                old_status
                                dialog
                                rc.
*
*  falls Job vor Modifikation freigegeben war -> alte Freigabedaten
*  aus Datenbank löschen
*
  IF old_status EQ btc_released.
    PERFORM reset_release_info_in_db USING old_jobhead
                                           old_stdt
                                           dialog
                                           rc.
    IF rc NE 0.
      EXIT.
    ENDIF.
  ENDIF.
*
*  neue Freigabedaten (Starttermindaten) in Datenbank speichern
*
  PERFORM insert_release_info_in_db USING new_jobhead
                                          new_stdt
                                          dialog
                                          rc.
  IF rc NE 0.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM. " RELEASE_MODIFIED_JOB

*---------------------------------------------------------------------*
*      FORM UPDATE_MODIFIED_JOBDATA                                   *
*---------------------------------------------------------------------*
* Modifizierte Jobdaten (Jobkopf + evtl. Stepdaten) abhängig vom      *
* Modifikationstyp in der Datenbank updaten:                          *
*                                                                     *
*  Modifikationstyp = BTC_JOB_STEPS_UPDATED:                          *
*  Die Stepwerte in der Datenbank werden lediglich upgedatet          *
*                                                                     *
*  Modifikationstyp = BTC_JOB_NEW_STEPCOUNT:                          *
*  Die alten Stepwerte werden verworfen und durch neue komplett       *
*  ersetzt.                                                           *
*                                                                     *
*  Modifikationstyp = BTC_JOB_MODIFIED:                               *
*  Lediglich die Jobkopfdaten müssen upgedatet werden                 *
*                                                                     *
* Diese Routine verlässt sich darauf, daß der Rufer den entsprechenden*
* Job bereits gesperrt hat.                                           *
*                                                                     *
* Achtung ! COMMIT bzw. ROLLBACK ist vom Rufer auszuführen            *
*                                                                     *
*---------------------------------------------------------------------*
FORM update_modified_jobdata TABLES mod_steplist STRUCTURE tbtcstep
                             USING  mod_jobhead  STRUCTURE tbtcjob
                                    new_stdt     STRUCTURE tbtcstrt
                                    new_status
                                    old_stdt     STRUCTURE tbtcstrt
                                    modify_type
                                    dialog
                                    rc.

*
* neuen Status und Anzahl neuer Steps im Jobkopf speichern
* (bei Sofortstart wurde Status schon von Routine INSERT_RELEASE_INFO
* im Jobkopf gesetzt)
*

  DATA: mod_jobinfo(43).

  CONCATENATE mod_jobhead-jobname mod_jobhead-jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  IF new_stdt-startdttyp NE btc_stdt_immediate.
    mod_jobhead-status = new_status.
  ENDIF.

  DESCRIBE TABLE mod_steplist LINES mod_jobhead-stepcount.
*
* falls alter Starttermin 'nach Vorgängerjob' war und neuer Starttermin
* != altem Vorgänger, dann Nachfolgezähler des alten Vorgängerjobs
* um 1 dekrementieren. Neuer Vorgängerzähler = 0
*
  IF old_stdt-startdttyp EQ btc_stdt_afterjob AND
     ( new_stdt-predjob    NE old_stdt-predjob    OR
       new_stdt-predjobcnt NE old_stdt-predjobcnt    ).
    PERFORM enq_predecessor_job USING old_stdt-predjob
                                      old_stdt-predjobcnt
                                      dialog
                                      rc.
    IF rc NE 0.
      rc = 1.
      EXIT.
    ENDIF.

    PERFORM update_num_of_succjobs USING old_stdt-predjob
                                         old_stdt-predjobcnt
                                         decrement
                                         dialog
                                         rc.
    IF rc NE 0.
      PERFORM deq_predecessor_job USING old_stdt-predjob
                                        old_stdt-predjobcnt
                                        dialog
                                        rc.
      rc = 1.
      EXIT.
    ENDIF.

    mod_jobhead-prednum = 0.

    PERFORM deq_predecessor_job USING old_stdt-predjob
                                      old_stdt-predjobcnt
                                      dialog
                                      rc.
  ENDIF.
*
*  falls neuer Starttermin = 'nach Vorgängerjob' und neuer Vorgängerjob
*  != altem Vorgängerjob -> Nachfolgezähler des neuen Vorgängerjobs
*  um 1 inkrementieren. Neuer Vorgängerzähler = 1
*
  IF new_stdt-startdttyp EQ btc_stdt_afterjob  AND
     ( new_stdt-predjob    NE old_stdt-predjob OR
       new_stdt-predjobcnt NE old_stdt-predjobcnt    ).
    PERFORM enq_predecessor_job USING new_stdt-predjob
                                      new_stdt-predjobcnt
                                      dialog
                                      rc.
    IF rc NE 0.
      PERFORM deq_predecessor_job USING new_stdt-predjob
                                        new_stdt-predjobcnt
                                        dialog
                                        rc.
      rc = 1.
      EXIT.
    ENDIF.

    PERFORM update_num_of_succjobs USING new_stdt-predjob
                                         new_stdt-predjobcnt
                                         increment
                                         dialog
                                         rc.
    IF rc NE 0.
      PERFORM deq_predecessor_job USING new_stdt-predjob
                                        new_stdt-predjobcnt
                                        dialog
                                        rc.
      rc = 1.
      EXIT.
    ENDIF.

    mod_jobhead-prednum = 1.

    PERFORM deq_predecessor_job USING new_stdt-predjob
                                      new_stdt-predjobcnt
                                      dialog
                                      rc.
  ENDIF.
*
*  Steps updaten falls notwendig
*
  IF modify_type EQ btc_job_steps_updated.
    PERFORM update_steplist_in_db TABLES mod_steplist
                                  USING  mod_jobhead
                                         dialog
                                         rc.
    IF rc NE 0.
      rc = 1.
      EXIT.
    ENDIF.
  ENDIF.

  IF modify_type EQ btc_job_new_step_count.

    CLEAR ppktab.
    REFRESH ppktab.
    SELECT * FROM tbtcp INTO CORRESPONDING FIELDS OF TABLE ppktab
                      WHERE jobname  = mod_jobhead-jobname
                        AND jobcount = mod_jobhead-jobcount.

    IF sy-subrc = 0.
      SORT ppktab BY stepcount ASCENDING.
    ENDIF.

* 4.7.2011  d023157   note 1606290
* In two cases we delete the existing steps
* 1. if the call does NOT come from JOB_SUBMIT
* 2. if the only step so far is the dummy step (RSBTCPT3)

      data: only_dummy_step type c value 'N'.

      if sy-dbcnt = 1.
         read table ppktab index 1.
         if ( ppktab-progname = 'RSBTCPT3' and MOD_JOBHEAD-STEPCOUNT = 1 ).
            only_dummy_step = btc_yes.
         endif.
      endif.

      if ( call_from_submit ne btc_yes or only_dummy_step = btc_yes ).

         DELETE FROM TBTCP WHERE JOBNAME  = MOD_JOBHEAD-JOBNAME
                             AND JOBCOUNT = MOD_JOBHEAD-JOBCOUNT.
         IF SY-SUBRC NE 0.
            PERFORM WRITE_JOB_MODIFY_SYSLOG USING TBTCP_DELETE_DB_ERROR
*                                                 MOD_JOBHEAD-JOBNAME.
                                              space
                                              mod_jobinfo.
            RC = 1.
            EXIT.
         ENDIF.
      endif.


    PERFORM store_new_steplist_in_db_sub TABLES mod_steplist
                                                ppktab
                                     USING  mod_jobhead
                                            dialog
                                            rc.

    call_from_submit = btc_no.

    IF rc NE 0.
      rc = 1.
      EXIT.
    ENDIF.
  ENDIF.
*
*  evtl. Periodenkennzeichen "anmachen"
*
  IF new_stdt-periodic EQ 'X'.
    mod_jobhead-periodic = 'X'.
  ENDIF.
*
*  falls es sich um einen Job handelt der über die Fubst. JOB_OPEN,
*  JOB_SUBMIT und JOB_CLOSE definiert wurde, dann bei Freigabe den
*  Job als abgeschlossen kennzeichnen
*
  IF mod_jobhead-newflag EQ 'S'
     AND
     (
       new_status EQ btc_released
       OR
       new_status EQ btc_ready
     ).
    mod_jobhead-newflag = 'C'.
  ENDIF.

* only store complete recipient reference
  IF mod_jobhead-recobjkey IS INITIAL.
    CLEAR mod_jobhead-reclogsys.
    CLEAR mod_jobhead-recobjtype.
    CLEAR mod_jobhead-recdescrib.
  ENDIF.
*
* Veränderungsdaten im Jobkopf fortschreiben
*
  GET TIME.

  mod_jobhead-lastchdate = sy-datum.
  mod_jobhead-lastchtime = sy-uzeit.
  mod_jobhead-lastchname = sy-uname.

  IF mod_jobhead-status EQ btc_released OR
     mod_jobhead-status EQ btc_ready.
    mod_jobhead-reldate  = sy-datum.
    mod_jobhead-reltime  = sy-uzeit.
    mod_jobhead-reluname = sy-uname.
  ELSE.
    mod_jobhead-reldate  = no_date.
    mod_jobhead-reltime  = no_time.
    mod_jobhead-reluname = space.
  ENDIF.

  CLEAR tbtco.
  MOVE-CORRESPONDING mod_jobhead TO tbtco.
  CLEAR tbtco-jobgroup. " evtl. vorhandene 'IMMEDIATE'-Info in Job-
  UPDATE tbtco.         " kopfdaten darf nicht in DB

  IF sy-subrc NE 0.
    IF dialog EQ btc_yes.
      MESSAGE s117 WITH mod_jobhead-jobname.
    ENDIF.
    PERFORM write_job_modify_syslog USING tbtco_update_db_error
*                                           MOD_JOBHEAD-JOBNAME.
                                          space
                                          mod_jobinfo.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM. " UPDATE_MODIFIED_JOBDATA

*---------------------------------------------------------------------*
*      FORM WRITE_JOB_MODIFY_SYSLOG                                   *
*---------------------------------------------------------------------*
* Schreiben eines Syslogeintrags, falls der Funktionsbaustein         *
* schwerwiegende Fehler entdeckt.                                     *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM write_job_modify_syslog USING syslogid p_jobinfo data.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD job_modify_problem_detcted
       ID 'DATA' FIELD p_jobinfo.
*
* syslogspezifischen Eintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
        ID 'KEY'  FIELD syslogid
        ID 'DATA' FIELD data.

ENDFORM. " WRITE_JOB_MODIFY_SYSLOG USING SYSLOGID DATA.
