***INCLUDE LBTCHF10 .

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_EDITOR                   *
************************************************************************

*---------------------------------------------------------------------*
*      FORM SAVE_JOB_STEPLIST                                         *
*---------------------------------------------------------------------*
* Erstellen einer Kopie der Stepliste, die an den Funktionsbaustein   *
* BP_JOB_EDITOR uebergeben wurde.                                     *
*---------------------------------------------------------------------*

FORM save_job_steplist.

  CLEAR job_steplist_copy.
  REFRESH job_steplist_copy.

  LOOP AT job_steplist.
    job_steplist_copy = job_steplist.
    APPEND job_steplist_copy.
  ENDLOOP.

ENDFORM. " SAVE_JOB_STEPLIST

*---------------------------------------------------------------------*
*      FORM RESTORE_OLD_JOB_STEPLIST                                  *
*---------------------------------------------------------------------*
* Stepliste, so wie sie an den Funktionsbaustein BP_JOB_EDITOR ueber- *
* geben wurde, restaurieren                                           *
*---------------------------------------------------------------------*

FORM restore_old_job_steplist.

  CLEAR job_steplist.
  REFRESH job_steplist.

  LOOP AT job_steplist_copy.
    job_steplist = job_steplist_copy.
    APPEND job_steplist.
  ENDLOOP.

ENDFORM. " RESTORE_OLD_JOB_STEPLIST

*---------------------------------------------------------------------*
*      FORM FILL_1140_WITH_INPUT_DATA                                 *
*---------------------------------------------------------------------*
* Das Dynpro 1140 (Anzeigen / Editieren von Jobwerten) wird mit den   *
* entsprechenden, an den Fubst. BP_JOB_EDITOR uebergebenen, Jobdaten  *
* gefuellt.                                                           *
*---------------------------------------------------------------------*
FORM fill_1140_with_input_data.
  DATA lv_is_intercepted TYPE boolean.

  MOVE-CORRESPONDING job_head_input TO btch1140.

  CASE job_head_input-status.
    WHEN btc_running.
      btch1140-statustxt = text-077.
    WHEN btc_ready.
      btch1140-statustxt = text-078.
    WHEN btc_scheduled.
      PERFORM check_job_is_intercepted
         USING
            job_head_input-jobname
            job_head_input-jobcount
         CHANGING
            lv_is_intercepted.
      IF lv_is_intercepted = abap_true.
        btch1140-statustxt = text-360.
      ELSE.
        btch1140-statustxt = text-079.
      ENDIF.
    WHEN btc_released.
      btch1140-statustxt = text-080.
    WHEN btc_aborted.
      btch1140-statustxt = text-081.
    WHEN btc_finished.
      btch1140-statustxt = text-082.
    WHEN btc_put_active.
      btch1140-statustxt = text-748.
    WHEN OTHERS.
      btch1140-statustxt = text-083.
  ENDCASE.

ENDFORM. " FILL_1140_WITH_INPUT_DATA.

*---------------------------------------------------------------------*
*      FORM RAISE_JOBHEAD_EXCEPTION                                   *
*---------------------------------------------------------------------*
* Ausloesen einer Exception und Schreiben eines Syslogeintrages, falls*
* der Funktionsbaustein BP_JOB_EDITOR ungueltige Jobdaten entdeckt.   *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden.                            *
*---------------------------------------------------------------------*

FORM raise_jobhead_exception USING exception data.
*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD invalid_job_values_detected
       ID 'DATA' FIELD job_head_input-jobname.
*
* exceptionspezifischen Eintrag schreiben und Exception ausloesen
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD exception
       ID 'DATA' FIELD data.

  CASE exception.
    WHEN eventcnt_generation_error_id.
      RAISE eventcnt_generation_error.
    WHEN invalid_dialog_type.
      RAISE invalid_dialog_type.
    WHEN invalid_jobclass.
      RAISE invalid_jobclass.
    WHEN invalid_jobstatus.
      RAISE invalid_jobstatus.
    WHEN invalid_opcode.
      RAISE invalid_opcode.
*    WHEN INVALID_STARTDATE.
*      " wird hier nicht behandelt. Nur der Vollständigkeit halber
    WHEN invalid_stepdata.
      RAISE invalid_stepdata.
    WHEN jobcount_generation_error_id.
      RAISE jobcount_generation_error.
    WHEN jobname_missing.
      RAISE jobname_missing.
    WHEN job_not_modifiable_anymore.
      RAISE job_not_modifiable_anymore.
    WHEN no_stepdata_given.
      RAISE no_stepdata_given.
    WHEN tgt_host_chk_has_failed_id.
      RAISE tgt_host_chk_has_failed.
    WHEN no_batch_on_target_host_id.
      RAISE no_batch_on_target_host.
    WHEN no_free_batch_wp_id.
      RAISE no_free_batch_wp.
    WHEN no_batch_wp_for_jobclass_id.
      RAISE no_batch_wp_for_jobclass.
    WHEN no_startdate_no_release.
      RAISE no_startdate_no_release.
    WHEN no_batch_server_found_id.
      RAISE no_batch_server_found.
    WHEN no_release_privilege_given.
      RAISE no_release_privilege_given.
    WHEN target_host_not_defined_id.
      RAISE target_host_not_defined.
    WHEN no_plan_privilege_given_id.
      RAISE no_plan_privilege_given.
    WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb der Jobdatenpruefung soll ausgeloest
*      werden. Aus Verlegenheit wird jobname_missing ausgeloest und die
*      die unbekannte Exception im Syslog vermerkt.
*
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_job_exception
            ID 'DATA' FIELD exception.
      RAISE report_name_missing.
  ENDCASE.
ENDFORM. " RAISE_JOBHEAD_EXCEPTION

*---------------------------------------------------------------------*
*      FORM FILL_1140_JOB_DATA                                        *
*---------------------------------------------------------------------*
* Jobwerte aus Struktur vom Typ TBTCJOB in Dynpro 1140 "schaufeln"    *
*---------------------------------------------------------------------*

FORM fill_1140_job_data.

  DATA: recipient_object LIKE swotobjid,
        tgt_grp_name TYPE bpsrvgrp,
        tmp_grp TYPE REF TO cl_bp_server_group.

  swc_container container.

  CLEAR btch1140.
  btch1140-jobname   = job_head_input-jobname.
  btch1140-jobcount  = job_head_input-jobcount.
  IF job_head_input-jobclass EQ space.
    btch1140-jobclass  = 'C'.
  ELSE.
    btch1140-jobclass  = job_head_input-jobclass.
  ENDIF.

  IF job_head_input-tgtsrvgrp IS INITIAL.
    IF job_head_input-execserver IS NOT INITIAL.
      btch1140-execserver = job_head_input-execserver.
    ELSE.
      IF ( job_head_input-status = btc_scheduled OR
       job_head_input-status = btc_released OR
       job_head_input-status = btc_ready ) AND
       job_editor_opcode = btc_show_job.
        CALL METHOD cl_bp_group_factory=>make_group_by_name
          EXPORTING
            i_name          = sap_default_srvgrp
            i_only_existing = cl_bp_const=>true
          RECEIVING
            o_grp_instance  = tmp_grp.
        IF tmp_grp IS NOT INITIAL.
          CONCATENATE '<' sap_default_srvgrp '>' INTO btch1140-execserver.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM map_id_to_name USING job_head_input-tgtsrvgrp tgt_grp_name.
    IF NOT tgt_grp_name IS INITIAL.
      btch1140-tgtsrvgrp = job_head_input-tgtsrvgrp.
      CONCATENATE '<' tgt_grp_name '>' INTO btch1140-execserver.
    ELSE.
      CONCATENATE '<' text-821 '>' INTO btch1140-execserver. " note 1546435
    ENDIF.
  ENDIF.

* note 1137537
  IF job_head_input-authckman IS INITIAL
  AND ( job_editor_opcode = btc_create_job OR job_editor_opcode = btc_edit_job ).
    SELECT SINGLE authckman FROM tbtco INTO job_head_input-authckman
    WHERE jobname = job_head_input-jobname AND jobcount = job_head_input-jobcount.
    IF sy-subrc <> 0.
      job_head_input-authckman = sy-mandt.
    ENDIF.
  ENDIF.

* start of note 773686
  IF EDIT_MODUS <> 'CREA'.
    IF NOT btch1140aux-recipient IS INITIAL.
      swc_free_object btch1140aux-recipient.
      CLEAR btch1140aux-recipient.
    ENDIF.
    IF job_head_input-authckman = sy-mandt OR
    job_head_input-authckman IS INITIAL.
      btch1140-reclogsys  = job_head_input-reclogsys.
      btch1140-recobjtype = job_head_input-recobjtype.
      btch1140-recobjkey  = job_head_input-recobjkey.
      btch1140-recdescrib = job_head_input-recdescrib.
      IF NOT job_head_input-recobjkey IS INITIAL.
        recipient_object-logsys  = job_head_input-reclogsys.
        recipient_object-objtype = job_head_input-recobjtype.
        recipient_object-objkey  = job_head_input-recobjkey.
        recipient_object-DESCRIBE = job_head_input-recdescrib.
        swc_object_from_persistent recipient_object btch1140aux-recipient.
        IF sy-subrc = 0.
          IF sy-ucomm = 'JCPY' OR edit_modus = 'JDRP'.      "note 1921763
            swc_call_method btch1140aux-recipient 'Copy' container.
            swc_free_object btch1140aux-recipient.
            swc_get_element container result btch1140aux-recipient.
          ENDIF.
        ELSE.
          IF sy-msgid IS NOT INITIAL.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ELSE.
            MESSAGE s546.
          ENDIF.
          swc_free_object btch1140aux-recipient.
        ENDIF.
      ENDIF.
    ELSE.
      IF NOT job_head_input-recobjkey IS INITIAL AND sy-ucomm = 'JCPY'.
        CLEAR job_head_input-reclogsys.
        CLEAR job_head_input-recobjtype.
        CLEAR job_head_input-recobjkey.
        CLEAR job_head_input-recdescrib.
        IF job_editor_opcode = btc_create_job AND
        recipient_modified = true.
          CALL 'WriteTrace'
          ID 'CALL' FIELD 'BP_JOB_EDITOR'
          ID 'PAR1' FIELD
          'Job client different from current client.'        "#EC NOTEXT
          ID 'PAR2' FIELD
          'Recipient object will not be copied.'.            "#EC NOTEXT
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* end of note 773686

  DATA lv_is_intercepted TYPE boolean.

  CASE job_head_input-status.
    WHEN btc_running.
      btch1140-statustxt = text-077.
    WHEN btc_ready.
      btch1140-statustxt = text-078.
    WHEN btc_scheduled.
      PERFORM check_job_is_intercepted
                USING
                   job_head_input-jobname
                   job_head_input-jobcount
                CHANGING
                   lv_is_intercepted.
      IF lv_is_intercepted = abap_true.
        btch1140-statustxt = text-360.
      ELSE.
        btch1140-statustxt = text-079.
      ENDIF.
    WHEN btc_released.
      btch1140-statustxt = text-080.
    WHEN btc_aborted.
      btch1140-statustxt = text-081.
    WHEN btc_finished.
      btch1140-statustxt = text-082.
    WHEN btc_put_active.
      btch1140-statustxt = text-748.
    WHEN OTHERS.
      btch1140-statustxt = text-083.
  ENDCASE.

ENDFORM. " FILL_1140_JOB_DATA

*---------------------------------------------------------------------*
*      FORM FILL_1140_STDT_DATA                                       *
*---------------------------------------------------------------------*
* Startterminwerte aus Struktur vom Typ TBTCSTRT in Dynpro 1140       *
* "schaufeln" ( Fubst. BP_JOB_EDITOR )                                *
*---------------------------------------------------------------------*

FORM fill_1140_stdt_data.

  DATA: btcprd_row      TYPE i VALUE 1,
        dttm_header_pos TYPE i VALUE 20,
        dttm_date_pos   TYPE i VALUE 18,
        dttm_time_pos   TYPE i VALUE 32.

  CLEAR btch1140-stdttext1.
  CLEAR btch1140-stdttext2.
  CLEAR btch1140-stdttext3.
  CLEAR btch1140-btcprd1.
  CLEAR btch1140-btcprd2.
  CLEAR btch1140-btcprd3.
  CLEAR btch1140-btcprd4.
  CLEAR btch1140-btcprd5.

* fill new display structure
  MOVE-CORRESPONDING job_stdt_input TO btch114x.
  btch114x-dynpro = c_def1140. "general text dynpro

*
*  Starttermintyp Datum / Uhrzeit
*
  IF job_stdt_input-startdttyp EQ btc_stdt_datetime.
    DESCRIBE FIELD text-152 LENGTH len IN CHARACTER MODE.
    WRITE text-152 TO btch1140-stdttext1+dttm_header_pos(len).
    btch1140-stdttext2 = text-153.
    WRITE job_stdt_input-sdlstrtdt TO
               btch1140-stdttext2+dttm_date_pos(10) DD/MM/YYYY.
    WRITE job_stdt_input-sdlstrttm TO
          btch1140-stdttext2+dttm_time_pos(8).
    IF NOT ( job_stdt_input-laststrtdt IS INITIAL ) AND
       job_stdt_input-laststrtdt NE no_date.
      btch1140-stdttext3 = text-154.
      WRITE job_stdt_input-laststrtdt TO
        btch1140-stdttext3+dttm_date_pos(10) DD/MM/YYYY.
      WRITE job_stdt_input-laststrttm TO
        btch1140-stdttext3+dttm_time_pos(8).
    ENDIF.
    btch114x-dynpro = c_time1140.
*
*  Starttermintyp Vorgaengerjob
*
  ELSEIF job_stdt_input-startdttyp EQ btc_stdt_afterjob.
    btch1140-stdttext1 = text-151.
    btch1140-stdttext2 = text-019.
    DESCRIBE FIELD text-019 LENGTH offset IN CHARACTER MODE.
    offset = offset + 1.
    DESCRIBE FIELD job_stdt_input-predjob LENGTH len
                                                 IN CHARACTER MODE.
    WRITE job_stdt_input-predjob TO btch1140-stdttext2+offset(len).
    btch114x-dynpro = c_job1140.
*
*  Starttermintyp 'nach Event' / 'bei Betriebsart'
*
  ELSEIF job_stdt_input-startdttyp EQ btc_stdt_event.
    btch1140-stdttext1 = text-151.
    IF job_stdt_input-eventid EQ oms_eventid.  " bei Betriebsart
      btch1140-stdttext2 = text-271.
      DESCRIBE FIELD text-271 LENGTH offset IN CHARACTER MODE.
      offset = offset + 1.
      DESCRIBE FIELD spfba-baname LENGTH len IN CHARACTER MODE.
      WRITE job_stdt_input-eventparm TO
                                     btch1140-stdttext2+offset(len).
      btch114x-opmode = job_stdt_input-eventparm.
      btch114x-dynpro = c_bart1140.
    ELSE.                                       " nach Event
      btch1140-stdttext2 = text-116.
      DESCRIBE FIELD text-116 LENGTH offset IN CHARACTER MODE.
      offset = offset + 1.
      DESCRIBE FIELD job_stdt_input-eventid LENGTH len
                                     IN CHARACTER MODE .
      WRITE job_stdt_input-eventid TO btch1140-stdttext2+offset(len).
      btch114x-dynpro = c_event1140.
    ENDIF.
*
*  Starttermintyp 'Sofort'
*
  ELSEIF job_stdt_input-startdttyp EQ btc_stdt_immediate.
    btch1140-stdttext1 = text-002.
    btch114x-dynpro = c_sofort1140.
    btch114x-immed = 'X'.
*
*  Starttermintyp 'an Arbeitstag'
*
  ELSEIF job_stdt_input-startdttyp EQ btc_stdt_onworkday.
    btch1140-stdttext1 = text-281.
    offset = strlen( btch1140-stdttext1 ) + 1.
    WRITE job_stdt_input-wdayno TO btch1140-stdttext1+offset(2).
    offset = strlen( btch1140-stdttext1 ) + 1.

    IF job_stdt_input-wdaycdir EQ btc_beginning_of_month.
      len = strlen( text-282 ).
      WRITE text-282 TO btch1140-stdttext1+offset(len).
    ELSE.
      len = strlen( text-283 ).
      WRITE text-283 TO btch1140-stdttext1+offset(len).
    ENDIF.

    WRITE '(' TO btch1140-stdttext2+0(1).
    WRITE job_stdt_input-sdlstrtdt TO
               btch1140-stdttext2+2(10) DD/MM/YYYY.
    offset = strlen( btch1140-stdttext2 ).
    WRITE ',' TO btch1140-stdttext2+offset(1).
    offset = strlen( btch1140-stdttext2 ) + 1.
    WRITE job_stdt_input-sdlstrttm TO btch1140-stdttext2+offset(8).
    offset = strlen( btch1140-stdttext2 ) + 1.
    WRITE ')' TO btch1140-stdttext2+offset(1).
    btch114x-dynpro = c_wcal1140.
  ENDIF.
*
*  Periodenwerte anzeigen
*
  IF job_stdt_input-periodic EQ 'X'.
    sum = job_stdt_input-prdmins  +
          job_stdt_input-prdhours +
          job_stdt_input-prddays  +
          job_stdt_input-prdweeks +
          job_stdt_input-prdmonths.
    IF sum NE 0. " zeitperiodisch
      IF sum EQ 1.
*
*           Einzelwert anzeigen ( minütlich, stündlich, täglich, ...)
*
        IF job_stdt_input-prdmins NE 0.
          btch1140-btcprd1 = text-031.     " minütlich
        ELSEIF job_stdt_input-prdhours NE 0.
          btch1140-btcprd1 = text-032.     " stündlich
        ELSEIF job_stdt_input-prddays NE 0.
          btch1140-btcprd1 = text-033.     " täglich
        ELSEIF job_stdt_input-prdweeks NE 0.
          btch1140-btcprd1 = text-034.     " wöchentlich
        ELSE.
          btch1140-btcprd1 = text-035.     " monatlich
        ENDIF.
      ELSE.
*
*        Periodenwerte explizit anzeigen ( Minute, Stunde, Tage, ... )
*
        IF job_stdt_input-prdmins NE 0.
          PERFORM write_1140_prd_text USING job_stdt_input-prdmins
                                            btcprd_row
                                            text-021.
        ENDIF.

        IF job_stdt_input-prdhours NE 0.
          PERFORM write_1140_prd_text USING job_stdt_input-prdhours
                                            btcprd_row
                                            text-023.
        ENDIF.

        IF job_stdt_input-prddays NE 0.
          PERFORM write_1140_prd_text USING job_stdt_input-prddays
                                            btcprd_row
                                            text-025.
        ENDIF.

        IF job_stdt_input-prdweeks NE 0.
          PERFORM write_1140_prd_text USING job_stdt_input-prdweeks
                                            btcprd_row
                                            text-027.
        ENDIF.

        IF job_stdt_input-prdmonths NE 0.
          PERFORM write_1140_prd_text USING
                                      job_stdt_input-prdmonths
                                      btcprd_row
                                      text-029.
        ENDIF.
      ENDIF.
    ELSE.
      btch1140-btcprd1 = text-117.  " eventperiodisch
    ENDIF.
  ELSE.
    CLEAR btch1140-btcprd1. " nicht periodisch
  ENDIF.

ENDFORM. " FILL_1140_STDT_DATA

*---------------------------------------------------------------------*
*      FORM WRITE_1140_PRD_TEXT                                       *
*---------------------------------------------------------------------*
* Explizite Periodenwertangaben im Dynpro 1140 als Texte anzeigen.    *
* Hauptaufgabe dieser Routine ist, neben dem textlichen Darstellen    *
* einer Periode, die naechste freie Zeile (BTCPRD1 ... BTCPRD5) zu    *
* ermitteln, in die der Text einzustreuen ist (PRD_FIELD_NR wird fort-*
* geschrieben von dieser Routine)                                     *
*---------------------------------------------------------------------*
FORM write_1140_prd_text USING prd_value prd_field_nr text.

  DATA: period_text(50).

  IF text EQ text-025. " Tagewert ist 3-stellig
    WRITE prd_value TO period_text+0(3) NO-ZERO.
  ELSE.                " restlichen Werte sind 2-stellig
    WRITE prd_value TO period_text+1(2) NO-ZERO.
  ENDIF.
  DESCRIBE FIELD text LENGTH len IN CHARACTER MODE.
  WRITE text TO period_text+4(len).  " Text ankleben

  CASE prd_field_nr.                " Dynprofeld fuellen
    WHEN 1.
      btch1140-btcprd1 = period_text.
    WHEN 2.
      CLEAR btch1140-btcprd2.
      btch1140-btcprd2 = period_text.
    WHEN 3.
      btch1140-btcprd3 = period_text.
    WHEN 4.
      btch1140-btcprd4 = period_text.
    WHEN 5.
      btch1140-btcprd5 = period_text.
  ENDCASE.

  IF prd_field_nr < 5.
    prd_field_nr = prd_field_nr + 1.
  ENDIF.

ENDFORM. " WRITE_1140_PRD_TEXT

*---------------------------------------------------------------------*
*      FORM PROCESS_STARTDATE                                         *
*---------------------------------------------------------------------*
* Startterminanzeige- bzw. eingabe aufrufen                           *
*---------------------------------------------------------------------*

FORM process_startdate.

  DATA: opcode LIKE btch0000-int4,
        stdt_modify_type_1140 LIKE stdt_modify_type.

  IF job_editor_opcode EQ btc_show_job.
    opcode = btc_show_startdate.
  ELSE.
    opcode = btc_edit_startdate.
  ENDIF.

  CALL FUNCTION 'BP_START_DATE_EDITOR'
    EXPORTING
      stdt_dialog      = btc_yes
      stdt_opcode      = opcode
      stdt_input       = job_stdt_input
    IMPORTING
      stdt_output      = job_stdt_input
      stdt_modify_type = stdt_modify_type_1140
    EXCEPTIONS
      OTHERS           = 99.

  IF ( sy-subrc EQ 0                          )   AND
     ( job_editor_opcode EQ btc_create_job OR
       job_editor_opcode EQ btc_edit_job      )   AND
       stdt_modify_type_1140 EQ btc_stdt_modified.

    IF job_editor_modify_type <= btc_job_modified.
      job_editor_modify_type = btc_job_modified.
    ENDIF.
    PERFORM fill_1140_stdt_data.
  ENDIF.

ENDFORM. " PROCESS_STARTDATE.

*---------------------------------------------------------------------*
*      FORM PROCESS_STEPS                                             *
*---------------------------------------------------------------------*
* Steps bearbeiten                                                    *
*---------------------------------------------------------------------*

FORM process_steps.

  DATA: opcode LIKE btch0000-int4,
        step_modify_type_1140 LIKE steplist_modify_type.

  IF job_editor_opcode EQ btc_show_job.
    opcode = btc_show_steplist.
  ELSE.
    opcode = btc_edit_steplist.
  ENDIF.

*  CALL FUNCTION 'BP_STEPLIST_EDITOR'
  CALL FUNCTION 'BP_STEPLIST_EDITOR'
    EXPORTING
      steplist_dialog      = btc_yes
      steplist_opcode      = opcode
      i_jobname            = btch1140-jobname
      i_jobcount           = btch1140-jobcount
    IMPORTING
      steplist_modify_type = step_modify_type_1140
    TABLES
      steplist             = job_steplist
    EXCEPTIONS
      OTHERS               = 99.

  IF ( sy-subrc EQ 0                          ) AND
     ( job_editor_opcode EQ btc_create_job OR
       job_editor_opcode EQ btc_edit_job      ).
    CASE step_modify_type_1140.
      WHEN btc_stpl_unchanged.
        " nix zu tun
      WHEN btc_stpl_updated.
        IF job_editor_modify_type < btc_job_new_step_count.
          job_editor_modify_type = btc_job_steps_updated.
        ENDIF.
      WHEN btc_stpl_new_count.
        job_editor_modify_type = btc_job_new_step_count.
    ENDCASE.

  ENDIF.

ENDFORM. " PROCESS_STEPS.

*---------------------------------------------------------------------*
*      FORM SHOW_JOB_PREDECESSORS                                     *
*---------------------------------------------------------------------*
* Vorgängerjob(s) anzeigen                                            *
* Achtung !                                                           *
* Um rekursive Aufrufe des Jobeditors zu ermöglichen, müssen die      *
* aktuellen Dynprodaten auf einen "Stack" gelegt werden und am Ende   *
* der Routine restauriert werden. Das gleiche gilt für Selektions-    *
* parameter die der Fubst. BP_JOBLIST_PROCESSOR zum Auffrischen der   *
* angezeigten Jobliste braucht.                                       *
*---------------------------------------------------------------------*

FORM show_job_predecessors.

  DATA BEGIN OF predecessor OCCURS 1.
          INCLUDE STRUCTURE tbtcjob.
  DATA END OF predecessor.
  DATA: sel_crit LIKE btcselect OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'BP_JOB_GET_PREDECESSORS'
    EXPORTING
      jobname               = job_head_input-jobname
      jobcount              = job_head_input-jobcount
    TABLES
      pred_joblist          = predecessor
    EXCEPTIONS
      job_not_exists        = 1
      no_predecessors_found = 2
      OTHERS                = 99.

  CASE sy-subrc.
    WHEN 0.
      " Vorgänger gefunden
    WHEN 1.
      MESSAGE e127 WITH job_head_input-jobname.
    WHEN OTHERS.
      MESSAGE e176 WITH job_head_input-jobname.
  ENDCASE.

  READ TABLE predecessor INDEX 1.

  disp_own_job_advanced_flag = 'X'.
  CLEAR sel_crit.
  REFRESH sel_crit.
  sel_crit-jobname  = predecessor-jobname.
  sel_crit-jobcount = predecessor-jobcount.
  sel_crit-username = predecessor-sdluname.
  sel_crit-from_date = '00000000'.
  sel_crit-from_time = '000000'.
  sel_crit-to_date   = '31129999'.
  sel_crit-to_time   = '240000'.
  sel_crit-eventid   = '*'.
  sel_crit-prelim    = 'X'.
  sel_crit-schedul   = 'X'.
  sel_crit-ready     = 'X'.
  sel_crit-running   = 'X'.
  sel_crit-finished  = 'X'.
  sel_crit-aborted   = 'X'.
  APPEND sel_crit.

  PERFORM show_selection USING sel_crit.

ENDFORM. " SHOW_JOB_PREDECESSORS.

*---------------------------------------------------------------------*
*      FORM SHOW_JOB_SUCCESSORS                                       *
*---------------------------------------------------------------------*
* Nachfolgejob(s) anzeigen                                            *
* Achtung !                                                           *
* Um rekursive Aufrufe des Jobeditors zu ermöglichen, müssen die      *
* aktuellen Dynprodaten auf einen "Stack" gelegt werden und am Ende   *
* der Routine restauriert werden. Das gleiche gilt für die Selektions-*
* parameter die der Fubst. BP_JOBLIST_PROCESSOR zum Auffrischen der   *
* angezeigten Jobliste braucht.                                       *
*---------------------------------------------------------------------*

FORM show_job_successors.

  DATA: sel_crit LIKE btcselect OCCURS 0 WITH HEADER LINE.
  DATA BEGIN OF successors OCCURS 10.
          INCLUDE STRUCTURE tbtcjob.
  DATA END OF successors.

  CALL FUNCTION 'BP_JOB_GET_SUCCESSORS'
    EXPORTING
      jobname             = job_head_input-jobname
      jobcount            = job_head_input-jobcount
    TABLES
      succ_joblist        = successors
    EXCEPTIONS
      job_not_exists      = 1
      no_successors_found = 2
      OTHERS              = 99.

  CASE sy-subrc.
    WHEN 0.
      " Nachfolger gefunden
    WHEN 1.
      MESSAGE e127 WITH job_head_input-jobname.
    WHEN 2.
      MESSAGE e177 WITH job_head_input-jobname.
  ENDCASE.

  READ TABLE successors INDEX 1.

  disp_own_job_advanced_flag = 'X'.
  CLEAR sel_crit.
  REFRESH sel_crit.
  sel_crit-jobname = '*'.
  sel_crit-username = '*'.
  sel_crit-from_date = '00000000'.
  sel_crit-from_time = '      '.
  sel_crit-to_date = '00000000'.
  sel_crit-to_time = '      '.
  sel_crit-eventid   = btc_eventid_eoj.
  sel_crit-eventparm = successors-eventparm.
  sel_crit-prelim    = 'X'.
  sel_crit-schedul   = 'X'.
  sel_crit-ready     = 'X'.
  sel_crit-running   = 'X'.
  sel_crit-finished  = 'X'.
  sel_crit-aborted   = 'X'.
  APPEND sel_crit.

  PERFORM show_selection USING sel_crit.

ENDFORM. " SHOW_JOB_SUCCESSORS.

*---------------------------------------------------------------------*
*      CHECK_INPUT_1140                                               *
*---------------------------------------------------------------------*
* Überprüfen der Jobwerte die im Rahmen des Funktionsbausteins        *
* BP_JOB_EDITOR auf dem Dynpro 1140 eingegeben wurden.                *
* Vorsichtshalber, weil wir hier nicht wissen, ob die Starttermin-    *
* und Stepdaten ok sind, prüfen wir diese ebenfalls.                  *
* Diese Funktion prüft auch Jobdaten im Nichtdialogfall ("so tun,     *
* als seien Jobdaten auf dem Dynpro 1140 eingegeben worden")          *
* Die geprüften Werte werden anschliessend in die globale Struktur    *
* JOB_HEAD_INPUT gestellt, mit welcher BP_JOB_EDITOR dann weiter-     *
* arbeitet.                                                           *
*---------------------------------------------------------------------*

FORM check_input_1140.

  DATA: num_of_steps TYPE i VALUE 0,
        step_count   LIKE btch0000-int4 VALUE 0,
        rc           TYPE i VALUE 0,
        step_count_text(4),
        opcode                 LIKE  stdt_opcode,
        target_server          LIKE  tbtcjob-execserver,
        target_host            LIKE  tbtcjob-btcsystem,
        step_modify_type       LIKE  steplist_modify_type,
        startdate_modify_type  LIKE  stdt_modify_type,
        startdate_given        LIKE  btc_yes,
        change(4)        TYPE  c VALUE '< > ',
        target_group     TYPE  bpsrvgrp,
        tmp_grp          TYPE  REF TO cl_bp_server_group,
        grp_server_list  TYPE TABLE OF bpsrvline,
        one_resource     TYPE msname2,"one possible srv for the job
        one_rsrc_short   TYPE btcsrvname.
  .
*
* zuerst die Daten auf dem Dynpro verproben/testen:
*        - Jobname
*        - Jobklasse
*        - Spoollistenempfänger (Recipient)
*        - Zielservernamen
*
* Jobname
*=========
  IF btch1140-jobname EQ space.
    IF job_editor_dialog EQ btc_yes.
      MESSAGE e093.
    ELSE.
      CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
        EXPORTING
          i_msgid     = 'BT'
          i_msgno     = '093'.
      PERFORM raise_jobhead_exception USING jobname_missing space.
    ENDIF.
  ELSE.
    job_head_input-jobname = btch1140-jobname.

    IF job_head_input-jobname NE job_head_output-jobname AND
       job_editor_modify_type < btc_job_modified.
      job_editor_modify_type = btc_job_modified.
    ENDIF.
  ENDIF.

* Jobclass
*=========

  IF btch1140-jobclass NE btc_jobclass_a AND
     btch1140-jobclass NE btc_jobclass_b AND
     btch1140-jobclass NE btc_jobclass_c.
    IF job_editor_dialog EQ btc_yes.
      MESSAGE e095.
    ELSE.
      CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
        EXPORTING
          i_msgid     = 'BT'
          i_msgno     = '095'.
      PERFORM raise_jobhead_exception USING invalid_jobclass
                                            btch1140-jobclass.
    ENDIF.
  ELSE.
    job_head_input-jobclass = btch1140-jobclass.

    IF job_head_input-jobclass NE job_head_output-jobclass AND
       job_editor_modify_type < btc_job_modified.
      job_editor_modify_type = btc_job_modified.
    ENDIF.
  ENDIF.

* recipient
*==========

* Nun auch die persistente Objektreferenz des Empfängerobjekts
* für die Spoollisten sichern.

  IF recipient_modified = true.
    job_head_input-reclogsys  = btch1140-reclogsys.
    job_head_input-recobjtype = btch1140-recobjtype.
    job_head_input-recobjkey  = btch1140-recobjkey.
    job_head_input-recdescrib = btch1140-recdescrib.
  ENDIF.
* als modifizierten Job kenntlich machen - sonst wird nix gespeichert
  IF recipient_modified EQ true AND
     job_editor_modify_type < btc_job_modified.
    job_editor_modify_type = btc_job_modified.
  ENDIF.

*
* jetzt die Starttermindaten pruefen. Beachte: Angabe von Starttermin-
* daten ist nicht zwingend ! Sind Starttermindaten vorhanden, so muß
* überprüft werden, ob der User Freigabeberechtigung hat. Wenn ja, dann
* wird der Status des Jobs auf 'freigegeben' gesetzt, ansonsten bleibt
* er auf 'eingeplant'.
*
  CALL FUNCTION 'BP_START_DATE_EDITOR'
    EXPORTING
      stdt_dialog                    = btc_no
      stdt_input                     = job_stdt_input
    IMPORTING
      stdt_output                    = job_stdt_input
    EXCEPTIONS
      no_startdate_given             = 1
      predecessor_jobname_not_unique = 2
      OTHERS                         = 99.
  IF sy-subrc EQ 0.
    startdate_given = btc_yes.  " Starttermindaten sind ok
  ELSEIF sy-subrc EQ 1.          " Job in Status 'eingeplant' versetzen
    startdate_given = btc_no.
  ELSEIF sy-subrc EQ 2.                " Dieser "Fehler" kann im Dialog-
    IF job_editor_dialog EQ btc_yes.  " fall übersehen werden, da der
      startdate_given = btc_yes.     " User schon einen Job ausge-
    ELSE.                             " wählt hat
      RAISE invalid_startdate.       " Syslogeintrag schon gemacht
    ENDIF.
  ELSE.                  " fehlerhafte Starttermindaten
    IF job_editor_dialog EQ btc_yes.
      MESSAGE s096.
      CALL FUNCTION 'BP_START_DATE_EDITOR'
        EXPORTING
          stdt_dialog      = btc_yes
          stdt_opcode      = btc_edit_startdate
          stdt_input       = job_stdt_input
        IMPORTING
          stdt_output      = job_stdt_input
          stdt_modify_type = startdate_modify_type
        EXCEPTIONS
          OTHERS           = 99.
      IF sy-subrc EQ 0 AND
         startdate_modify_type EQ btc_stdt_modified AND
         job_editor_modify_type < btc_job_modified.
        job_editor_modify_type = btc_job_modified.
      ENDIF.
      PERFORM fill_1140_stdt_data.
      LEAVE SCREEN. " Dynpro 1140 nochmal prozessieren
    ELSE.
      RAISE invalid_startdate.  " kein Syslogeintrag hier, weil das
    ENDIF.                       " schon der Fubst. macht
  ENDIF.
* Zielserverangabe und Starttermine
*==================================
*
* Falls ein Starttermin oder eine Zielrechnerangabe vorliegen, Ziel-
* rechnername verproben bzw. ermitteln
* - falls Name angegeben wurde:
*   - prüfen, ob Zielserver abhängig vom Starttermintyp batchfähig ist
*

  IF NOT btch1140-execserver IS INITIAL.
    target_group = btch1140-execserver.
    IF target_group(1) = '<'.
* this may be a server group
      TRANSLATE target_group USING change.
      CONDENSE target_group NO-GAPS.
      CALL METHOD cl_bp_group_factory=>make_group_by_name
        EXPORTING
          i_name          = target_group
          i_only_existing = 'X'
        RECEIVING
          o_grp_instance  = tmp_grp.
      IF NOT tmp_grp IS INITIAL.
* really a server group
        job_head_input-tgtsrvgrp = tmp_grp->get_id( ).
        btch1140-tgtsrvgrp = job_head_input-tgtsrvgrp.
        CLEAR job_head_input-execserver.

        CALL METHOD tmp_grp->get_list
          RECEIVING
            o_list = grp_server_list.

        IF grp_server_list IS INITIAL.
          IF job_editor_dialog = btc_yes.

            IF job_stdt_input-startdttyp = btc_stdt_immediate.
              MESSAGE e664 WITH target_group.
            ELSE.
              MESSAGE w664 WITH target_group.
            ENDIF.

          ENDIF.
        ELSE.
          PERFORM find_resource_in_srv_group USING
                                               grp_server_list
                                               job_head_input-jobclass
                                               job_stdt_input
                                               one_resource.
          IF one_resource IS INITIAL AND
             job_editor_dialog = btc_yes.
            CLEAR job_stdt_input-instname.

            IF job_stdt_input-startdttyp = btc_stdt_immediate.
              MESSAGE e664 WITH target_group.
            ELSE.
              MESSAGE w664 WITH target_group.
            ENDIF.

          ENDIF.
        ENDIF.
      ELSE.
* incorrect name of the server group.
        CLEAR job_head_input-execserver.
        CLEAR job_head_input-tgtsrvgrp.

        IF job_editor_dialog EQ btc_yes.
          MESSAGE e662 WITH target_group.
        ELSE.
          xbp_msgpar1 = target_group.
          CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
            EXPORTING
              i_msgid     = 'BT'
              i_msgno     = '093'
              I_MSG1      = xbp_msgpar1.
          CLEAR xbp_msgpar1.
          PERFORM raise_jobhead_exception USING
                                no_batch_on_target_host_id
                                space.
        ENDIF.
      ENDIF.
    ELSE.
* a server
      job_head_input-execserver = btch1140-execserver.
      CLEAR job_head_input-tgtsrvgrp.  "d023157  note 695257
    ENDIF.
  ELSE.
* no target
    CLEAR job_head_input-execserver.
    CLEAR job_head_input-tgtsrvgrp.   "d023157  note 695257
    job_stdt_input-imstrtpos = true.
  ENDIF. "execserver field is set

  IF ( job_head_input-execserver NE job_head_output-execserver OR
       job_head_input-tgtsrvgrp NE job_head_output-tgtsrvgrp  ) AND
     job_editor_modify_type < btc_job_modified.
    job_editor_modify_type = btc_job_modified.
  ENDIF.

  job_head_input-btcsysreax = space.
  job_head_input-btcsystem  = space.  "ajk: should be set later
  job_head_input-reaxserver = space.  "kfarrell:  reaxserver should not
  "be copied to new job

  IF NOT job_head_input-execserver IS INITIAL.
* not a server group but a server
    CLEAR job_stdt_input-instname.
    target_server = job_head_input-execserver.

    PERFORM check_server_for_job_exec USING target_server
                                            target_host
                                            job_stdt_input
                                            job_head_input-jobclass
                                            rc.
    CASE rc.
      WHEN 0.
      WHEN tgt_host_chk_has_failed.
        IF job_editor_dialog EQ btc_yes.
          MESSAGE e503.
        ELSE.
        call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '503'.
          PERFORM raise_jobhead_exception USING
                                tgt_host_chk_has_failed_id
                                space.
        ENDIF.

      WHEN no_batch_on_target_host.
* d023157   25.11.2008
* only in case of immediate start we write an error message.
* otherwise we write a warning.
        IF job_editor_dialog EQ btc_yes.
          IF job_stdt_input-startdttyp = btc_stdt_immediate.
            MESSAGE e515 WITH job_head_input-execserver.
          ELSE.
            MESSAGE w515 WITH job_head_input-execserver.
          ENDIF.

        ELSE.
          xbp_msgpar1 = job_head_input-execserver.

          call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '515'
                     i_msg1      = xbp_msgpar1
                       .
          clear xbp_msgpar1.
          PERFORM raise_jobhead_exception USING
                                no_batch_on_target_host_id
                                job_head_input-execserver.
        ENDIF.


      WHEN no_free_batch_wp_now.
      WHEN no_batch_wp_for_jobclass.
        " kann nur vorkommen bei Jobklasse B oder C, wenn auf dem Ziel-
        " rechner nur Jobklasse A verarbeitet werden kann
        IF job_editor_dialog EQ btc_yes.
          MESSAGE e256 WITH job_head_input-execserver.
        ELSE.
          PERFORM raise_jobhead_exception USING
                                no_batch_wp_for_jobclass_id
                                job_head_input-execserver.
        ENDIF.
      WHEN target_host_not_defined.
        IF job_editor_dialog EQ btc_yes.
          MESSAGE e123 WITH job_head_input-execserver.
        ELSE.
          PERFORM raise_jobhead_exception USING
                                target_host_not_defined_id
                                job_head_input-btcsystem.
        ENDIF.
      WHEN no_batch_server_found.
    ENDCASE.
  ENDIF.

*
* prüfen, ob mindestens 1 Step vorhanden ist
*
  DESCRIBE TABLE job_steplist LINES num_of_steps.
  IF num_of_steps < 1.  " Fehler: Job ohne Steps gibt's nicht !
    IF job_editor_dialog EQ btc_yes.
      MESSAGE s097.
      CALL FUNCTION 'BP_STEPLIST_EDITOR'
        EXPORTING
          steplist_opcode      = btc_edit_steplist
          steplist_dialog      = btc_yes
        IMPORTING
          steplist_modify_type = step_modify_type
        TABLES
          steplist             = job_steplist
        EXCEPTIONS
          OTHERS               = 99.
      IF sy-subrc EQ 0.
        IF step_modify_type EQ btc_stpl_unchanged.
          LEAVE SCREEN.  " Anwender bricht absichtlich ab
        ELSE.
          job_editor_modify_type = btc_job_new_step_count.
          DESCRIBE TABLE job_steplist LINES num_of_steps.
        ENDIF.
      ELSE.
        LEAVE SCREEN.  " Oops !
      ENDIF.
    ELSE.  " kein Dialog
      call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
             exporting
                   i_msgid     = 'BT'
                   i_msgno     = '097'.
      PERFORM raise_jobhead_exception USING no_stepdata_given
                                            job_head_input-jobname.
    ENDIF.
  ENDIF.
*
* jetzt alle Steps in der Stepliste prüfen
*
  step_count = 1.
  WHILE step_count <= num_of_steps.
    CALL FUNCTION 'BP_STEPLIST_EDITOR'
      EXPORTING
        steplist_dialog = btc_no
        step_to_verify  = step_count
      TABLES
        steplist        = job_steplist
      EXCEPTIONS
        OTHERS          = 99.
    IF sy-subrc EQ 0.
      step_count = step_count + 1.  " alles ok, nächsten Step prüfen
    ELSE.  " Step enthält fehlerhafte Daten
      IF job_editor_dialog EQ btc_yes.
        MESSAGE s098 WITH step_count.
        steplist_row_to_move = step_count. " Stepzeile hervorheben
        CALL FUNCTION 'BP_STEPLIST_EDITOR' " Stepliste editieren
                 EXPORTING steplist_opcode = btc_edit_steplist
                           steplist_dialog = btc_yes
                 IMPORTING steplist_modify_type = step_modify_type
                 TABLES    steplist        = job_steplist
                 EXCEPTIONS OTHERS         = 99.
        IF sy-subrc EQ 0.
          IF step_modify_type EQ btc_stpl_unchanged.
            LEAVE SCREEN.    " User bricht Verarbeitung ab !
          ELSE.
            job_editor_modify_type = btc_job_new_step_count.
            DESCRIBE TABLE job_steplist LINES num_of_steps.
            step_count = step_count + 1.  " nächsten Step prüfen
          ENDIF.
        ELSE.
          " User hat nix eingegeben -> Prüfung und Eingabe wiederh.
        ENDIF.
      ELSE.  " kein Dialog
        step_count_text = step_count.
        call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '098'.
        PERFORM raise_jobhead_exception USING invalid_stepdata
                                              step_count_text.
      ENDIF.
    ENDIF.
  ENDWHILE.
*
* Veränderungsdaten abhängig vom Verarbeitungsmodus fortschreiben.
* Im Fall, daß ein Job neu angelegt wird, wird auch noch ein
* Jobcount generiert.
*
  GET TIME.

  IF job_editor_opcode EQ btc_create_job OR
     job_editor_opcode EQ btc_edit_job.
    job_head_input-stepcount  = num_of_steps.    " sowohl im Dialog-
    job_head_input-lastchdate = sy-datum.        " als auch im Nicht-
    job_head_input-lastchtime = sy-uzeit.        " dialogfall
    job_head_input-lastchname = sy-uname.
  ENDIF.

  IF job_editor_opcode EQ btc_create_job.         " wird sowohl im
    job_head_input-sdldate   = sy-datum.         " Dialog- als auch
    job_head_input-sdltime   = sy-uzeit.         " im Nichtdialofall
    job_head_input-sdluname  = sy-uname.         " durchlaufen
    job_head_input-authckman = sy-mandt.
    job_head_input-intreport = newstep_flag.
    job_head_input-prednum   = 0.
    job_head_input-succnum   = 0.
    job_head_input-strtdate  = no_date.
    job_head_input-strttime  = no_time.
    job_head_input-enddate   = no_date.
    job_head_input-endtime   = no_time.
    job_head_input-joblog    = space.
    job_head_input-wpnumber  = 0.
    job_head_input-wpprocid  = 0.

*    PERFORM gen_jobcount USING btch1140-jobname
*                               job_head_input-jobcount
*                               rc.
*    IF rc NE 0.
*      IF job_editor_dialog EQ btc_yes.
*        MESSAGE e100 WITH btch1140-jobname.
*      ENDIF.
*      RAISE jobcount_generation_error.  " Syslog wurde schon
*    ENDIF.                               " geschrieben
  ENDIF.
*
* Freigabeinformationen in Jobkopfdaten fortschreiben
*
  IF job_editor_opcode EQ btc_create_job OR
     job_editor_opcode EQ btc_edit_job.

    IF release_privilege_given EQ btc_yes.       " auch im Nichtdialog-
      IF startdate_given EQ btc_yes.            " fall durchlaufen
        job_head_input-status   = btc_released.
        job_head_input-reldate  = sy-datum.
        job_head_input-reltime  = sy-uzeit.
        job_head_input-reluname = sy-uname.
        IF job_stdt_input-startdttyp EQ btc_stdt_immediate.
          job_stdt_input-sdlstrtdt = sy-datum.
          job_stdt_input-sdlstrttm = sy-uzeit.
        ENDIF.
      ELSE.
        job_head_input-status   = btc_scheduled.
        job_head_input-reldate  = no_date.
        job_head_input-reltime  = no_time.
        job_head_input-reluname = space.
      ENDIF.
    ELSE. " es liegt keine Freigabeberechtigung vor
      job_head_input-status    = btc_scheduled.
      job_head_input-reldate   = no_date.
      job_head_input-reltime   = no_time.
      job_head_input-reluname  = space.
      IF job_stdt_input-startdttyp EQ btc_stdt_immediate.
        IF job_editor_dialog EQ btc_yes.
          MESSAGE e108.
        ELSE.
        call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '108'.
          PERFORM raise_jobhead_exception USING
                                no_release_privilege_given
                                space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM store_stdt_in_jobhead USING job_head_input
                                      job_stdt_input
                                      job_editor_dialog
                                      rc.
  IF rc NE 0.
    PERFORM raise_jobhead_exception USING
                                    eventcnt_generation_error_id
                                    job_head_input-eventid.
  ENDIF.
*
* sollen im dialoglosen Fall die Jobdaten lediglich geprüft werden,
* so muß auch noch der Jobstatus geprüft werden (bei CREATE bzw. EDIT
* wird der Jobstatus weiter oben gesetzt und muß deshalb hier nicht
* mehr geprüft werden). Zusätzlich muß geprüft werden, ob Starttermin-
* daten vorliegen, falls der Job nicht mehr im Zustand 'eingeplant' ist.
*
  IF job_editor_dialog EQ btc_no AND
     job_editor_opcode EQ btc_check_only.
    IF job_head_input-status NE btc_running    AND
       job_head_input-status NE btc_ready      AND
       job_head_input-status NE btc_scheduled  AND
       job_head_input-status NE btc_released   AND
       job_head_input-status NE btc_aborted    AND
       job_head_input-status NE btc_finished.

      xbp_msgpar1 = job_head_input-jobname.
      call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              exporting
                    i_msgid     = 'BT'
                    i_msgno     = '141'
                    i_msg1      = xbp_msgpar1
                      .
      clear xbp_msgpar1.
      PERFORM raise_jobhead_exception USING
                            invalid_jobstatus
                            job_head_input-status.
    ENDIF.

    IF job_head_input-status NE btc_scheduled AND
       startdate_given EQ btc_no.
      PERFORM raise_jobhead_exception USING
                            no_startdate_no_release
                            job_head_input-jobname.
    ENDIF.
  ENDIF.
*
* Spezialfall: ein Job wird dialoglos oder im Dialog ohne Modifikation
* der Inputdaten erzeugt. Dann wird der Modifytyp "künstlich" gesetzt.
*
  IF job_editor_opcode EQ btc_create_job AND
     job_editor_modify_type EQ btc_job_not_modified.
    job_editor_modify_type = btc_job_new_step_count.
  ENDIF.

ENDFORM. " CHECK_INPUT_1140.

*---------------------------------------------------------------------*
*      FORM VERIFY_JOB_EDITOR_ABORT                                   *
*---------------------------------------------------------------------*
* Diese Routine prüft, ob beim Verlassen des Jobeditors über PF3 /    *
* Pf12 / PF15 Daten verloren gehen würden. Wenn ja, wird der Benutzer *
* mittels eines PopUps darauf hingewiesen.                            *
*---------------------------------------------------------------------*
FORM verify_job_editor_abort.

  IF sy-datar EQ 'X' OR
     job_editor_modify_type NE btc_job_not_modified.
    jobdata_modified = true.
  ENDIF.

  IF jobdata_modified EQ true.
*
*    es wurden EventId-Daten eingegeben bzw. verändert -> Sicher-
*    heitsabfrage an den Benutzer schicken
*
    PERFORM verify_user_abort USING text-138.
  ELSE.
    SET SCREEN 0.  " es wurden keine Daten verändert -> Dynpro 1140
    LEAVE SCREEN.  " verlassen
  ENDIF.

ENDFORM. " VERIFY_JOB_EDITOR_ABORT.
*&---------------------------------------------------------------------*
*&      Form  FILL_1140_step_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_1140_step_data TABLES in_steplist STRUCTURE tbtcstep.

  CLEAR btch1140-steptext.

  DESCRIBE TABLE in_steplist LINES step_list_entries.
  IF step_list_entries NE 0.
    WRITE step_list_entries LEFT-JUSTIFIED TO btch1140-steptext.
    CONCATENATE btch1140-steptext text-734 INTO btch1140-steptext SEPARATED BY space .
  ENDIF.

ENDFORM.                    " FILL_1140_STEP_DATA

*&---------------------------------------------------------------------*
*&      Form REORG_JOBS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

FORM reorg_jobs.

  AUTHORITY-CHECK OBJECT 'S_BTCH_ADM'
           ID 'BTCADMIN' FIELD btc_yes.

  IF sy-subrc <> 0.
    MESSAGE s791.
    EXIT.
  ENDIF.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text       = text-822.

  PERFORM cleanup_reorg_jobs.

  CLEAR btch1141.
  CALL SCREEN 1141.


ENDFORM.                    "reorg_jobs

*&---------------------------------------------------------------------*
*&      Form  SWITCH_SYSTEM_AND_CLIENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM switch_system_and_client.
  DATA: msg(80).

  DATA: next_ta        TYPE sytcode,  "where to go afterwards
        first_ta       TYPE sytcode,  "where we go first
        next_clt       TYPE symandt,  "what client afterwards
        goto_clt       TYPE symandt,  "what client to go to
        dest_sys       TYPE rfcdest,  "what system to call
        final_dest     TYPE rfcdest,  "proposal for the log destination
        is_remote_dest TYPE char1,    "indicating: this is really remote
        ground         TYPE i.        "level counter f. recursive calls

  DATA: my_role        TYPE csmobjnm, "am I a central system or not
*      MY_SYS         type CSMBK_OBJ, "SPfeiffer 28112000
        my_sys         TYPE csmbk_ob2,
        my_sys_name    TYPE csmobjnm,
        my_facts       TYPE csmbk OCCURS 10.



* 1) determine whether you are the level ground zero
* therefore we need to know whether we are central ccms
* if we are not the central ccms we get out of here just with
* the next destination.
  ground = 0.           " assume we are ground zero ??

* SPfeiffer changes 28112000
  my_sys_name = sy-sysid.
  CALL FUNCTION 'SCSM_RG_SYSTEM_ROLE_GET'
   EXPORTING
     system_name                     = my_sys_name
*   LICENSE_NUMBER                  = CSM_DUMMYVALUE
*   SYSTEM_GUID                     =
   IMPORTING
     system_entry                    = my_sys
     system_role                     = my_role
* TABLES
*   SYSTEM_DATA                     =
   EXCEPTIONS
     no_csm_role_assigned            = 1
     system_not_found                = 2
     repository_not_yet_filled       = 3
     not_authorized                  = 4
     OTHERS                          = 5
            .
*CALL FUNCTION 'SCSMBK_SYSTEM_ROLE_GET'
* IMPORTING
*   SYSTEM_ENTRY                    = MY_SYS
*   SYSTEM_ROLE                     = MY_ROLE
*  TABLES
*   SYSTEM_DATA                     = MY_FACTS
* EXCEPTIONS
*   REPOSITORY_NOT_YET_FILLED       = 1
*   OTHERS                          = 2
  .
  IF sy-subrc > 1.
    MESSAGE s645(bt) WITH 'could not use repository'.
  ENDIF.
* End SPfeiffer changes 28112000

  IF my_role = csm_central_system.
    btch4900-not_centrl = false.
  ELSE.
    btch4900-not_centrl = true.
  ENDIF.

* 2) determine where to go and go there
* the following is just a test for the destination
* most likely this requires to map a logical name to a trusted
* RFC destination
* 2.1) ask the repository whats available (missing)

* 2.2) ask the user where he wants to go
*      fills btch4900, combo box contents comes from Repository
  CALL SCREEN 4900 STARTING AT 2 2
                   ENDING AT   90 10.

  IF btch4900-keep_going = space.
    EXIT.
  ELSE.
    first_ta = btch4900-nxttrans.
  ENDIF.

* 2.3) map it to a destination
  IF btch4900-nxtsystem <> sy-sysid. "in remote system switch client
    dest_sys = btch4900-nxtsystem.
    goto_clt = btch4900-nxtclient.
    is_remote_dest = true.
  ELSE.                               "in local system go client
    dest_sys = btch4900-nxtcltdest.
    goto_clt = space.
    is_remote_dest = false.
  ENDIF.

* 2.3) make the call
  CLEAR msg.
  CALL FUNCTION 'BP_SWITCH_CLIENT' DESTINATION dest_sys
    EXPORTING
      transaction           = first_ta
      final_dest            = final_dest
      final_client          = goto_clt
      is_remote_dest        = is_remote_dest
    IMPORTING
      next_transaction      = next_ta
      next_client           = next_clt
    EXCEPTIONS
      invalid_parameters    = 1
      logon_failed          = 2
      problem_detected      = 3
      system_failure        = 4  MESSAGE msg
      communication_failure = 5  MESSAGE msg
      OTHERS                = 99.

  IF sy-subrc <> 0.
    IF sy-subrc = 1 OR sy-subrc = 2 OR sy-subrc = 3.
      MESSAGE s645(bt) WITH 'switch client went wrong'.
    ELSEIF NOT msg IS INITIAL.
      SHIFT msg LEFT DELETING LEADING space.
      MESSAGE s645(bt) WITH msg.
    ENDIF.
  ENDIF.

* 3) determine where to go next


ENDFORM.                    "switch_system_and_client

*&---------------------------------------------------------------------*
*&      Form  READ_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_status CHANGING p_changed.

  DATA: linecnt  TYPE i.

  DATA: cnt TYPE i.
  DATA: last_finished TYPE i. " Merker
  DATA: last_aborted  TYPE i. " Merker

  DATA: wa_info_tab  LIKE rjsta1.
  DATA: wa_info_tab2 LIKE rjsta2.

  CLEAR   info_tab.
  REFRESH info_tab.

  CLEAR   info_tab2.
  REFRESH info_tab2.

  DESCRIBE TABLE jobtab LINES linecnt.

  IF linecnt = 0 OR p_changed IS NOT INITIAL.
    SELECT * FROM reorgjobs INTO CORRESPONDING FIELDS OF TABLE jobtab
                            ORDER BY component jobname ASCENDING.
    CLEAR p_changed.
  ENDIF.

  LOOP AT jobtab.
    last_finished = 0.
    last_aborted  = 0.

    SELECT * FROM tbtco WHERE jobname = jobtab-jobname
                          AND ( status = btc_finished OR
                                status = btc_aborted OR
                                status = btc_released OR
                                status = btc_ready    OR
                                status = btc_running OR
                                status = btc_put_active )
                          ORDER BY jobname ASCENDING
                          status strtdate DESCENDING
                                 strttime DESCENDING.

      IF tbtco-status = btc_finished AND last_finished = 1.
        CONTINUE.
      ENDIF.

      IF tbtco-status = btc_aborted AND last_aborted = 1.
        CONTINUE.
      ENDIF.


      IF tbtco-status = btc_finished AND last_finished = 0.
        last_finished = 1.
      ENDIF.

      IF tbtco-status = btc_aborted AND last_aborted = 0.
        last_aborted = last_aborted + 1.
      ENDIF.


      CLEAR wa_info_tab.

      MOVE-CORRESPONDING tbtco TO wa_info_tab.

* check status of job

      CASE tbtco-status.
        WHEN btc_finished. WRITE text-756 TO wa_info_tab-status.
        WHEN btc_aborted.  WRITE text-773 TO wa_info_tab-status.
        WHEN btc_running.  WRITE text-757 TO wa_info_tab-status.
        WHEN btc_released. WRITE text-758 TO wa_info_tab-status.
        WHEN btc_ready.    WRITE text-759 TO wa_info_tab-status.
        WHEN btc_put_active. WRITE text-748 TO wa_info_tab-status.
      ENDCASE.

* check period of job

      IF tbtco-periodic = 'X' AND
                       ( tbtco-status = btc_running  OR
                         tbtco-status = btc_released OR
                         tbtco-status = btc_finished OR
                         tbtco-status = btc_aborted  OR
                         tbtco-status = btc_ready    OR
                         tbtco-status = btc_put_active ).

        IF tbtco-prdmonths = '1' OR tbtco-prdmonths = '01' .
          WRITE text-754 TO wa_info_tab-period.
        ELSEIF
           tbtco-prdweeks  = '1' OR tbtco-prdweeks  = '01' .
          WRITE text-753 TO wa_info_tab-period.
        ELSEIF
           tbtco-prddays   = '1' OR tbtco-prddays   = '01' .
          WRITE text-752 TO wa_info_tab-period.
        ELSEIF
           tbtco-prdhours  = '1' OR tbtco-prdhours  = '01' .
          WRITE text-763 TO wa_info_tab-period.
        ELSE.
          WRITE text-755 TO wa_info_tab-period..
        ENDIF.

      ENDIF.

* read name of variant
      SELECT SINGLE * FROM tbtcp WHERE jobcount = tbtco-jobcount
                                   AND jobname  = tbtco-jobname.
      IF sy-subrc = 0.
        IF NOT tbtcp-variant IS INITIAL.
          wa_info_tab-varname = tbtcp-variant.
        ENDIF.
      ENDIF.


      MOVE jobtab-jobinfo   TO wa_info_tab-jobinfo.
      MOVE jobtab-progname  TO wa_info_tab-progname.
      MOVE jobtab-component TO wa_info_tab-component.
      APPEND wa_info_tab TO info_tab.
      .
      MOVE-CORRESPONDING wa_info_tab TO wa_info_tab2.
      MOVE tbtco-jobcount TO wa_info_tab2-jobcount.
      APPEND wa_info_tab2 TO info_tab2.

    ENDSELECT.

  ENDLOOP.


ENDFORM.                    " READ_STATUS

*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_JOBS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM schedule_jobs.

  DATA: jc LIKE tbtco-jobcount.
  DATA: variant LIKE btch1141-varname.
  DATA: flag TYPE c.

  DATA: strtimmed LIKE  btch0000-char1 VALUE space,
        prdhours  LIKE tbtco-prdhours  VALUE 0,
        prdmonths LIKE tbtco-prdmonths VALUE 0,
        prdweeks  LIKE tbtco-prdweeks  VALUE 0,
        prddays   LIKE tbtco-prddays   VALUE 0,
        sdlstrtdt LIKE tbtco-sdlstrtdt,
        sdlstrttm LIKE tbtco-sdlstrttm.

  CHECK okcode = 'SAVE'.

  sdlstrtdt = no_date.
  sdlstrttm = no_time.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = btch1141-jobname
    IMPORTING
      jobcount = jc
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc NE 0.
    MESSAGE a117 WITH btch1141-jobname.
  ENDIF.

  IF btch1141-varname IS INITIAL.
    variant = space.
  ELSE.
    variant = btch1141-varname.
  ENDIF.

  IF btch1141-authcknam IS INITIAL.
    btch1141-authcknam = sy-uname.
  ENDIF.

  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      authcknam = btch1141-authcknam
      jobcount  = jc
      jobname   = btch1141-jobname
      report    = btch1141-progname
      variant   = variant
    EXCEPTIONS
      OTHERS    = 1.

  IF sy-subrc <> 0.
    PERFORM delete_rec_job USING btch1141-jobname jc.
    MESSAGE a117 WITH btch1141-jobname.
  ENDIF.


* start immediately
  IF NOT b_imme IS INITIAL.
    strtimmed = 'X'.
  ELSE.
    sdlstrtdt = btch1141-sdldate.
    sdlstrttm = btch1141-sdltime.
  ENDIF.

  IF NOT b_period_hourly IS INITIAL.
    prdhours = 1.
  ENDIF.

  IF NOT b_period_daily IS INITIAL.
    prddays = 1.
  ENDIF.

  IF NOT b_period_weekly IS INITIAL.
    prdweeks = 1.
  ENDIF.

  IF NOT b_period_monthly IS INITIAL.
    prdmonths = 1.
  ENDIF.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount         = jc
      jobname          = btch1141-jobname
      strtimmed        = strtimmed
      prdhours         = prdhours
      prdmonths        = prdmonths
      prdweeks         = prdweeks
      prddays          = prddays
      sdlstrtdt        = sdlstrtdt
      sdlstrttm        = sdlstrttm
      targetserver     = btch1141-execserver
    IMPORTING
      job_was_released = flag
    EXCEPTIONS
      OTHERS           = 1.

  IF sy-subrc <> 0.
    PERFORM delete_rec_job USING btch1141-jobname jc.
    MESSAGE a117 WITH btch1141-jobname.
  ELSE.
    MESSAGE s277 WITH btch1141-jobname.
  ENDIF.

ENDFORM.                    " SCHEDULE_JOBS

*&---------------------------------------------------------------------*
*&      Form  DELETE_REOJOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*----------------------------------------------------------------------*
FORM delete_reojob TABLES p_et_index_rows STRUCTURE lvc_s_row.


  DATA: ls_selected_line LIKE lvc_s_row,
        lf_row_index TYPE lvc_index.
  DATA: wa_info_tab2 LIKE rjsta2.

  LOOP AT p_et_index_rows INTO ls_selected_line.
    lf_row_index = ls_selected_line-index.

    READ TABLE info_tab2 INDEX lf_row_index INTO wa_info_tab2.
    IF sy-subrc = 0.
      CALL FUNCTION 'BP_JOB_DELETE'
        EXPORTING
          jobcount               = wa_info_tab2-jobcount
          jobname                = wa_info_tab2-jobname
          forcedmode             = 'X'
          commitmode             = 'X'
        EXCEPTIONS
          job_is_already_running = 1
          OTHERS                 = 2.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE i128 WITH wa_info_tab2-jobname..
        WHEN 2.
          MESSAGE i136 WITH wa_info_tab2-jobname.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DELETE_REOJOB

*&---------------------------------------------------------------------*
*&      Form  READ_COMPONENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_components.

  DATA: linecnt TYPE i.
  DATA: nodetab LIKE snodetext OCCURS 0 WITH HEADER LINE.

*  TABLES: df14l, df14t.  "***
  DATA: wa_df14l TYPE df14l, wa_df14t TYPE df14t.

  DESCRIBE TABLE comptab LINES linecnt.

* check. if table comptab has been filled defore
  IF linecnt NE 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'RS_COMPONENT_VIEW'
    EXPORTING
      language    = sy-langu
*     OBJECT_TYPE = OBJECT_TYPE
*     REFRESH     = REFRESH
    TABLES
      nodetab     = nodetab.

  LOOP AT nodetab.
    CHECK nodetab-tlevel = '02'.
    MOVE nodetab-name TO comptab-component.
    MOVE nodetab-text TO comptab-comptext.
    APPEND comptab.
  ENDLOOP.

* special treatment for component WP
* it might be installed on the system, although
* it is not in the result list of rs_component_view

  SELECT SINGLE * FROM df14l INTO wa_df14l WHERE ps_posid = 'WP'.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

* WP is installed

  READ TABLE comptab WITH KEY component = 'WP'.
  IF sy-subrc = 0.
    EXIT.   " WP already in comptab
  ENDIF.

* WP is not listed in comptab yet.
* get component text

  CLEAR comptab.
  SELECT SINGLE * FROM df14t INTO wa_df14t WHERE fctr_id = wa_df14l-fctr_id
                               AND langu   = sy-langu.

  IF sy-subrc = 0.
    comptab-comptext = wa_df14t-name.
  ENDIF.

  comptab-component = 'WP'.

  APPEND comptab.

ENDFORM.                    " READ_COMPONENTS

*&---------------------------------------------------------------------*
*&      Form  EXISTS_JOB_ALREADY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exists_job_already USING ret TYPE i.

  ret = 0.

  SELECT * FROM tbtcp WHERE progname = btch1141-progname.
    SELECT SINGLE * FROM tbtco WHERE jobname  = tbtcp-jobname
                                 AND jobcount = tbtcp-jobcount.
    IF sy-subrc = 0.
      IF tbtco-status = btc_released OR tbtco-status = btc_ready
                                     OR tbtco-status = btc_running.
        ret = 1.
        EXIT.
      ENDIF.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " EXISTS_JOB_ALREADY

*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM schedule_all .

  DATA: lt_fields   TYPE TABLE OF sval,
        l_field     TYPE sval,
        l_rc,
        l_authcknam TYPE btcauthnam.

  l_authcknam = sy-uname.

  IF batch_user_assign_privilege = btc_yes.
    l_field-fieldname = 'AUTHCKNAM'.
    l_field-tabname   = 'BTCH1141'.
    l_field-value     = l_authcknam.
    l_field-fieldtext = 'Step user'(825).
    APPEND l_field TO lt_fields.
    CLEAR l_field.

    WHILE l_field-value IS INITIAL.
      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          no_value_check  = 'X'
          popup_title     = 'Specify a step user ID for the reorg jobs'(824)
        IMPORTING
          returncode      = l_rc
        TABLES
          fields          = lt_fields
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE e626.
      ELSEIF l_rc IS NOT INITIAL.
        MESSAGE s682(db).
        SET SCREEN 1141.
        LEAVE SCREEN.
      ENDIF.
      READ TABLE lt_fields INDEX 1 INTO l_field.
    ENDWHILE.

    l_authcknam = l_field-value.

    PERFORM check_reorg_authcknam USING l_authcknam.

  ENDIF.

  LOOP AT jobtab WHERE defperiod NE ' '.
    PERFORM schedule_job_2 USING jobtab l_authcknam.
  ENDLOOP.

  MESSAGE s543.

ENDFORM.                    " SCHEDULE_ALL

*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_JOB_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REORGJOBS  text
*----------------------------------------------------------------------*
FORM schedule_job_2 USING rec STRUCTURE reorgjobs
                          p_authcknam TYPE btcauthnam.

  DATA: jc LIKE tbtco-jobcount.
  DATA: variant LIKE btch1141-varname.
  DATA: flag TYPE c.

  DATA: strtimmed LIKE  btch0000-char1 VALUE space,
        prdhours  LIKE tbtco-prdhours  VALUE 0,
        prdmonths LIKE tbtco-prdmonths VALUE 0,
        prdweeks  LIKE tbtco-prdweeks  VALUE 0,
        prddays   LIKE tbtco-prddays   VALUE 0,
        sdlstrtdt LIKE tbtco-sdlstrtdt,
        sdlstrttm LIKE tbtco-sdlstrttm.

  DATA: i_authcknam TYPE btcauthnam.


  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = rec-jobname
    IMPORTING
      jobcount = jc
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc NE 0.
    MESSAGE a117 WITH rec-jobname.
  ENDIF.

  IF rec-defvariant IS INITIAL.
    variant = space.
  ELSE.
    variant = rec-defvariant.
  ENDIF.

  IF p_authcknam IS INITIAL.
    i_authcknam = sy-uname.
  ELSE.
    i_authcknam = p_authcknam.
  ENDIF.

  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      authcknam = i_authcknam
      jobcount  = jc
      jobname   = rec-jobname
      report    = rec-progname
      variant   = variant
    EXCEPTIONS
      OTHERS    = 1.

  IF sy-subrc <> 0.
    PERFORM delete_rec_job USING rec-jobname jc.
    MESSAGE a117 WITH rec-jobname.
  ENDIF.



* set period and start time

* jobs from a 7.10, 7.11 or 7.30 upgrade
  IF rec-defperiod = 'I'.
    rec-defperiod = 'H'.
  ENDIF.

  CASE rec-defperiod.
    WHEN 'M'.
      prdmonths = 1.
      sdlstrtdt = sy-datum + 1.
      sdlstrttm = '010000'.
    WHEN 'W'.
      prdweeks = 1.
      sdlstrtdt = sy-datum + 1.
      sdlstrttm = '000100'.
    WHEN 'D'.
      prddays = 1.
      sdlstrtdt = sy-datum + 1.
      sdlstrttm = '003000'.
    WHEN 'H'.
      prdhours = 1.
      sdlstrtdt = sy-datum.
      sdlstrttm = sy-uzeit + 240.
    WHEN OTHERS.
      PERFORM delete_rec_job USING rec-jobname jc.
      MESSAGE a117 WITH rec-jobname.
  ENDCASE.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount         = jc
      jobname          = rec-jobname
*     STRTIMMED        = STRTIMMED
      prdhours         = prdhours
      prdmonths        = prdmonths
      prdweeks         = prdweeks
      prddays          = prddays
      sdlstrtdt        = sdlstrtdt
      sdlstrttm        = sdlstrttm
*     TARGETSERVER     = rec-execserver
    IMPORTING
      job_was_released = flag
    EXCEPTIONS
      OTHERS           = 1.

  IF sy-subrc <> 0.
    PERFORM delete_rec_job USING rec-jobname jc.
    MESSAGE a117 WITH rec-jobname.
  ENDIF.

ENDFORM.                    " SCHEDULE_JOB_2

*&---------------------------------------------------------------------*
*&      Form  EXISTS_JOB_ALREADY2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RET  text
*      -->P_JOBTAB_PROGNAME  text
*----------------------------------------------------------------------*
FORM exists_job_already2 CHANGING p_changed.
*                        USING ret TYPE i.

*  ret = 0.

  LOOP AT jobtab.

    SELECT * FROM tbtcp WHERE progname = jobtab-progname.
      SELECT SINGLE * FROM tbtco WHERE jobname  = tbtcp-jobname
                                   AND jobcount = tbtcp-jobcount.
      IF sy-subrc = 0.
        IF tbtco-status = btc_released OR tbtco-status = btc_ready
                                       OR tbtco-status = btc_running.
          DELETE TABLE jobtab.
          p_changed = 'X'.
          CONTINUE.
*          ret = 1.
*          EXIT.
        ENDIF.
      ENDIF.
    ENDSELECT.

  ENDLOOP.

ENDFORM.                    " EXISTS_JOB_ALREADY2

*&---------------------------------------------------------------------*
*&      Form  fill_1260_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_1260_data .
  CLEAR btch1260.

  CASE job_stdt_input-prdbehav.
    WHEN btc_process_always.
      btch1260-always = 'X'.
    WHEN btc_dont_process_on_holiday.
      btch1260-notonholid = 'X'.
    WHEN btc_process_before_holiday.
      btch1260-before = 'X'.
    WHEN btc_process_after_holiday.
      btch1260-after  = 'X'.
    WHEN OTHERS. " 'Alte Jobs' ohne Periodenverhalten
      btch1260-always = 'X'.
  ENDCASE.

  IF btch1260-always EQ space.   " prüfen, ob Feld 'nur an Arbeits-
    btch1260-with_limit = 'X'.  " tagen 'anzuknipsen' ist
  ENDIF.

  btch1260-calendarid = job_stdt_input-calendarid.
ENDFORM.                    " fill_1260_data

*&--------------------------------------------------------------------*
*&      Form  show_selection
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->SEL_CRIT   text
*---------------------------------------------------------------------*
FORM show_selection USING sel_crit TYPE btcselect.

** Added bz C5035006 on 30.10.2001
** Back up actions for the output_joblist table and jobsel_param_in

  DATA: bac_index TYPE i.

* Creating an internal table with lines of type backup_struct.
* This table will serve as a storage of backup copies of incoming
* tables output_joblist and jobsel_param_in.
  TYPES: BEGIN OF backup_struct,
    bac_table_job_list LIKE output_joblist OCCURS 0,
    bac_table_sel_crit LIKE jobsel_param_in,
    bac_table_sel_crit_out LIKE jobsel_param_out,
    bac_job_head_input LIKE job_head_input,
    bac_btch1140 LIKE btch1140,
  END OF backup_struct.
  DATA: bac_table_struct TYPE TABLE OF backup_struct.
  DATA: var_backup_struct TYPE backup_struct.

  CLEAR var_backup_struct.

* Copiyng the output_joblist, jobsel_param_in, jobsel_param_out,
* job_head_input and BTCH1140 into a temporary variable.
  IF NOT output_joblist IS INITIAL.
    LOOP AT output_joblist.
      APPEND output_joblist TO var_backup_struct-bac_table_job_list.
    ENDLOOP.
  ENDIF.
  MOVE jobsel_param_in TO var_backup_struct-bac_table_sel_crit.
  MOVE jobsel_param_out TO var_backup_struct-bac_table_sel_crit_out.
  MOVE job_head_input TO var_backup_struct-bac_job_head_input.
  MOVE btch1140 TO var_backup_struct-bac_btch1140.
  CLEAR btch1140.

* The value of the bac_index variable is the depth of calls.
  bac_index = bac_index + 1.

* The incoming values just copied are moved to the internal table.
  APPEND var_backup_struct TO bac_table_struct.

* End of backup actions

  CALL FUNCTION 'BP_OWN_JOB_MAINTENANCE'
    EXPORTING
      jobselect_dialog        = btc_no
      jobsel_param_input      = sel_crit
    EXCEPTIONS
      unknown_selection_error = 1
      OTHERS                  = 2.

* Restore actions

  CLEAR disp_own_job_advanced_flag.
  CLEAR output_joblist.
  REFRESH output_joblist.

* The currrent values of jobs and selection are restored from the
* internal table.
  READ TABLE bac_table_struct INDEX bac_index
    INTO var_backup_struct.

  DELETE bac_table_struct INDEX bac_index.
  bac_index = bac_index - 1.

* Current values are copied to the outer variables.
  IF NOT var_backup_struct-bac_table_job_list IS INITIAL.
    LOOP AT var_backup_struct-bac_table_job_list
       INTO output_joblist.
      APPEND output_joblist.
    ENDLOOP.
  ENDIF.
  MOVE var_backup_struct-bac_table_sel_crit TO jobsel_param_in.
  MOVE var_backup_struct-bac_job_head_input TO job_head_input.
  MOVE var_backup_struct-bac_btch1140 TO btch1140.

*     set the old values also to jobsel_param_out
*     this is necessary for the refresh sm sm37
  MOVE var_backup_struct-bac_table_sel_crit_out TO jobsel_param_out.

* End of restore actions

  IF sy-subrc <> 0.
    MESSAGE e645 WITH text-742 sy-subrc.
  ENDIF.

ENDFORM.                    "show_selection

*&---------------------------------------------------------------------*
*&      Form  swc_call
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3459   text
*----------------------------------------------------------------------*
FORM swc_call USING method.

  swc_container container.

  swc_call_method btch1140aux-recipient method container.
  IF sy-subrc = 0.
    IF method = 'Edit'.
      recipient_modified = true.   " 'save' was pressed
    ENDIF.
  ELSE.
    IF sy-msgid IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      MESSAGE s546.
    ENDIF.
    EXIT.
  ENDIF.

ENDFORM.                    " swc_call
*&---------------------------------------------------------------------*
*&      Form  CLEANUP_REORG_JOBS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cleanup_reorg_jobs .

  DATA: reorg_jobname TYPE tbtcjob-jobname.
  DATA: reorg_progname TYPE reorgjobs-progname.
  DATA: reorg_jobinfo TYPE jobinfo.
  DATA: del TYPE btcchar1.
  DATA: wa_reorgjobs TYPE reorgjobs.
  DATA: modjobs TYPE TABLE OF btch1180.
  DATA: lines TYPE i.
  DATA: old_reorgjob TYPE reorgjobs.
  DATA: ins_flag TYPE btcchar1.
  DATA: mod_flag TYPE btcchar1.

**********'SAP_REORG_UPDATERECORDS'**********
  reorg_jobname  = 'SAP_REORG_UPDATERECORDS'.
  reorg_progname = 'RSM13002'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    del = 'X'.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

**********'SAP_WP_CACHE_RELOAD_FULL'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_jobname  = 'SAP_WP_CACHE_RELOAD_FULL'.
  reorg_progname = 'RWP_RUNTIME_CACHE_RELOAD'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    CLEAR del.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

**********'SAP_REORG_JOBS'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSBTCDEL'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  MOVE-CORRESPONDING wa_reorgjobs TO old_reorgjob.
  IF sy-subrc = 0.
    DO 2 TIMES.
      SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = 'RSBTCDEL2'.
      IF sy-subrc <> 0.
        wa_reorgjobs-progname = 'RSBTCDEL2'.
        PERFORM check_variant_exists USING wa_reorgjobs-progname
        CHANGING wa_reorgjobs-defvariant.
        IF wa_reorgjobs-defvariant IS INITIAL.
          PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
          CHANGING wa_reorgjobs-defvariant.
        ENDIF.
        IF wa_reorgjobs-defvariant IS NOT INITIAL.
          INSERT reorgjobs FROM wa_reorgjobs.
          APPEND wa_reorgjobs-jobname TO modjobs.
        ENDIF.
      ENDIF.
    ENDDO.
    IF sy-subrc = 0.
      PERFORM delete_reorgjob USING old_reorgjob-jobname old_reorgjob-progname del.
      APPEND old_reorgjob-jobname TO modjobs.
    ENDIF.
  ENDIF.

  reorg_progname = 'RSBTCDEL2'.
  reorg_jobinfo = 'DELETE OLD JOBS'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname
  AND jobinfo <> reorg_jobinfo.
  IF sy-subrc = 0.
    PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
    APPEND wa_reorgjobs-jobname TO modjobs.
  ENDIF.


**********'SAP_REORG_PRIPARAMS'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSBTCPRIDEL'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc <> 0.
    ins_flag = 'X'.
    wa_reorgjobs-progname = reorg_progname.
    wa_reorgjobs-jobname = 'SAP_REORG_PRIPARAMS'.
    wa_reorgjobs-jobinfo = 'DELETE OLD PRINT PARAMETERS'.
    wa_reorgjobs-jobvariant = 'X'.
    wa_reorgjobs-component = 'BC'.
    wa_reorgjobs-defvariant = 'SAP&001'.
    wa_reorgjobs-defperiod = 'M'.
  ENDIF.
  PERFORM check_variant_exists USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
  IF wa_reorgjobs-defvariant IS INITIAL.
    PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                           CHANGING wa_reorgjobs-defvariant.
    IF wa_reorgjobs-defvariant IS NOT INITIAL.
      IF ins_flag IS INITIAL.
        mod_flag = 'X'.
      ENDIF.
    ELSE.
      IF ins_flag IS NOT INITIAL.
        CLEAR ins_flag.
      ENDIF.
    ENDIF.
  ENDIF.
  IF ins_flag IS NOT INITIAL.
    INSERT reorgjobs FROM wa_reorgjobs.
  ELSEIF mod_flag IS NOT INITIAL.
    UPDATE reorgjobs FROM wa_reorgjobs.
  ENDIF.
  IF ins_flag IS NOT INITIAL OR mod_flag IS NOT INITIAL.
    APPEND wa_reorgjobs-jobname TO modjobs.
  ENDIF.

**********'SAP_SPOOL_CONSISTENCY_CHECK'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSPO1043'.
  reorg_jobinfo = 'SPOOL/TEMSE CONSISTENCY CHECK'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc <> 0.
    ins_flag = 'X'.
    wa_reorgjobs-progname = reorg_progname.
    wa_reorgjobs-jobname = 'SAP_SPOOL_CONSISTENCY_CHECK'.
    wa_reorgjobs-jobinfo = reorg_jobinfo.
    wa_reorgjobs-jobvariant = 'X'.
    wa_reorgjobs-component = 'BC'.
    wa_reorgjobs-defvariant = 'SAP&001'.
    wa_reorgjobs-defperiod = 'D'.
  ENDIF.
  PERFORM check_variant_exists USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
  IF wa_reorgjobs-defvariant IS INITIAL.
    PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                           CHANGING wa_reorgjobs-defvariant.
    IF wa_reorgjobs-defvariant IS NOT INITIAL.
      IF ins_flag IS INITIAL.
        mod_flag = 'X'.
      ENDIF.
    ELSE.
      IF ins_flag IS NOT INITIAL.
        CLEAR ins_flag.
      ENDIF.
    ENDIF.
  ENDIF.
  IF wa_reorgjobs-jobinfo <> reorg_jobinfo.
    PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
    mod_flag = 'X'.
  ENDIF.
  IF ins_flag IS NOT INITIAL.
    INSERT reorgjobs FROM wa_reorgjobs.
  ELSEIF mod_flag IS NOT INITIAL.
    UPDATE reorgjobs FROM wa_reorgjobs.
  ENDIF.
  IF ins_flag IS NOT INITIAL OR mod_flag IS NOT INITIAL.
    APPEND wa_reorgjobs-jobname TO modjobs.
  ENDIF.

**********'SAP_REORG_ORPHANED_JOBLOGS'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSTS0024'.
  PERFORM check_report_exists CHANGING reorg_progname.
  IF reorg_progname IS NOT INITIAL.
    SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
    IF sy-subrc <> 0.
      ins_flag = 'X'.
      wa_reorgjobs-progname = reorg_progname.
      wa_reorgjobs-jobname = 'SAP_REORG_ORPHANED_JOBLOGS'.
      wa_reorgjobs-jobinfo = 'DELETE ORPHANED JOB LOGS'.
      wa_reorgjobs-jobvariant = 'X'.
      wa_reorgjobs-component = 'BC'.
      wa_reorgjobs-defperiod = 'W'.
      wa_reorgjobs-defvariant = 'SAP&001'.
    ENDIF.
    PERFORM check_variant_exists USING wa_reorgjobs-progname
                                 CHANGING wa_reorgjobs-defvariant.
    IF wa_reorgjobs-defvariant IS INITIAL.
      PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                             CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS NOT INITIAL.
        IF ins_flag IS INITIAL.
          mod_flag = 'X'.
        ENDIF.
      ELSE.
        IF ins_flag IS NOT INITIAL.
          CLEAR ins_flag.
        ENDIF.
      ENDIF.
    ENDIF.
    IF ins_flag IS NOT INITIAL.
      INSERT reorgjobs FROM wa_reorgjobs.
    ELSEIF mod_flag IS NOT INITIAL.
      UPDATE reorgjobs FROM wa_reorgjobs.
    ENDIF.
    IF ins_flag IS NOT INITIAL OR mod_flag IS NOT INITIAL.
      APPEND wa_reorgjobs-jobname TO modjobs.
    ENDIF.
  ENDIF.

**********'SAP_CHECK_ACTIVE_JOBS'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'BTCAUX07'.
  reorg_jobinfo = 'CHECK ACTIVE JOBS'.
  PERFORM check_report_exists CHANGING reorg_progname.
  IF reorg_progname IS NOT INITIAL.
    SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
    IF sy-subrc <> 0.
      wa_reorgjobs-progname = reorg_progname.
      wa_reorgjobs-jobname = 'SAP_CHECK_ACTIVE_JOBS'.
      wa_reorgjobs-jobinfo = reorg_jobinfo.
      wa_reorgjobs-jobvariant = 'X'.
      wa_reorgjobs-component = 'BC'.
      wa_reorgjobs-defvariant = 'SAP&001'.
      wa_reorgjobs-defperiod = 'H'.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                   CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
      ENDIF.
      IF wa_reorgjobs-defvariant IS NOT INITIAL.
        INSERT reorgjobs FROM wa_reorgjobs.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ELSE.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                   CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
        IF wa_reorgjobs-defvariant IS NOT INITIAL.
          UPDATE reorgjobs FROM wa_reorgjobs.
          APPEND wa_reorgjobs-jobname TO modjobs.
        ENDIF.
      ENDIF.
      IF wa_reorgjobs-jobinfo <> reorg_jobinfo.
        PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ENDIF.
  ENDIF.

**********'SAP_REORG_ORPHANED_TEMSE_FILES'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSTS0043'.
  reorg_jobinfo = 'DELETE ORPHANED TEMSE FILES'.
  PERFORM check_report_exists CHANGING reorg_progname.
  IF reorg_progname IS NOT INITIAL.
    SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
    IF sy-subrc <> 0.
      wa_reorgjobs-progname = reorg_progname.
      wa_reorgjobs-jobname = 'SAP_REORG_ORPHANED_TEMSE_FILES'.
      wa_reorgjobs-jobinfo = reorg_jobinfo.
      wa_reorgjobs-jobvariant = 'X'.
      wa_reorgjobs-component = 'BC'.
      wa_reorgjobs-defvariant = 'SAP&001'.
      wa_reorgjobs-defperiod = 'W'.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                   CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
      ENDIF.
      IF wa_reorgjobs-defvariant IS NOT INITIAL.
        INSERT reorgjobs FROM wa_reorgjobs.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ELSE.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                    CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
        IF wa_reorgjobs-defvariant IS NOT INITIAL.
          UPDATE reorgjobs FROM wa_reorgjobs.
          APPEND wa_reorgjobs-jobname TO modjobs.
        ENDIF.
      ENDIF.
      IF wa_reorgjobs-jobinfo <> reorg_jobinfo.
        PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ENDIF.
  ENDIF.

**********'SAP_DELETE_ORPHANED_IVARIS'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'BTC_DELETE_ORPHANED_IVARIS'.
  reorg_jobinfo = 'DELETE ORPHANED TEMP. VARIANTS'.
  PERFORM check_report_exists CHANGING reorg_progname.
  IF reorg_progname IS NOT INITIAL.
    SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
    IF sy-subrc <> 0.
      wa_reorgjobs-progname = reorg_progname.
      wa_reorgjobs-jobname = 'SAP_DELETE_ORPHANED_IVARIS'.
      wa_reorgjobs-jobinfo = reorg_jobinfo.
      wa_reorgjobs-jobvariant = 'X'.
      wa_reorgjobs-component = 'BC'.
      wa_reorgjobs-defvariant = 'SAP&001'.
      wa_reorgjobs-defperiod = 'W'.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                   CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
      ENDIF.
      IF wa_reorgjobs-defvariant IS NOT INITIAL.
        INSERT reorgjobs FROM wa_reorgjobs.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ELSE.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                    CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
        IF wa_reorgjobs-defvariant IS NOT INITIAL.
          UPDATE reorgjobs FROM wa_reorgjobs.
          APPEND wa_reorgjobs-jobname TO modjobs.
        ENDIF.
      ENDIF.
      IF wa_reorgjobs-jobinfo <> reorg_jobinfo.
        PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ENDIF.
  ENDIF.

**********'SAP_ESF_REPOSITORY_LOADGEN'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_jobname  = 'SAP_ESF_REPOSITORY_LOADGEN'.
  reorg_progname = 'RS_ESF_REPOSITORY_LOADGEN'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    CLEAR del.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

**********'SAP_SSF_CERTEXPIRE'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_jobname  = 'SAP_SSF_CERTEXPIRE'.
  reorg_progname = 'SSF_ALERT_CERTEXPIRE'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    del = 'X'.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

***********SAP_SOA_TABLE_SWITCH***********
  CLEAR: wa_reorgjobs, mod_flag.
  reorg_jobname  = 'SAP_SOA_TABLE_SWITCH'.
  reorg_progname = 'RSXMB_TABLE_SWITCH'.
  reorg_jobinfo = 'DELETE BY TABLE SWITCH'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    IF wa_reorgjobs-defperiod <> 'D'.
      wa_reorgjobs-defperiod = 'D'.
      UPDATE reorgjobs FROM wa_reorgjobs.
      IF sy-subrc = 0.
        mod_flag = 'X'.
      ENDIF.
    ENDIF.
    IF wa_reorgjobs-jobinfo <> reorg_jobinfo.
      PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
      mod_flag = 'X'.
    ENDIF.
    IF mod_flag IS NOT INITIAL.
      COMMIT WORK.
      APPEND reorg_jobname TO modjobs.
    ENDIF.
  ENDIF.


***********SAP_SOA_ARCHIVE_PLAN*************
  CLEAR: wa_reorgjobs.
  reorg_jobname  = 'SAP_SOA_ARCHIVE_PLAN'.
  reorg_progname = 'RSXMB_ARCHIVE_PLAN'.
  reorg_jobinfo = 'ACHIVE MESSAGES'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname
  AND jobinfo <>  reorg_jobinfo.
  IF sy-subrc = 0.
    PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
    APPEND reorg_jobname TO modjobs.
  ENDIF.


***********SAP_SOA_DELETE_HISTORY*************
  CLEAR: wa_reorgjobs.
  reorg_jobname  = 'SAP_SOA_DELETE_HISTORY'.
  reorg_progname = 'RSXMB_DELETE_HISTORY'.
  reorg_jobinfo = 'DELETE HISTORY ENTRIES'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname
  AND jobinfo <>  reorg_jobinfo.
  IF sy-subrc = 0.
    PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

***********SAP_SOA_DELETE_MESSAGES*************
  CLEAR: wa_reorgjobs.
  reorg_jobname  = 'SAP_SOA_DELETE_MESSAGES'.
  reorg_progname = 'RSXMB_DELETE_MESSAGES'.
  reorg_jobinfo = 'DELETE MESSAGES'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname
  AND jobinfo <>  reorg_jobinfo.
  IF sy-subrc = 0.
    PERFORM modify_reorg_jobinfo USING reorg_progname reorg_jobinfo.
    APPEND reorg_jobname TO modjobs.
  ENDIF.


**********SLCA_LCK_SYNCHOWNERS*******************
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_jobname  = 'SLCA_LCK_SYNCHOWNERS'.
  reorg_progname = 'SLCA_LCK_SYNCHOWNERS'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    del = 'X'.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.


***********SAP_ADS_SPOOL_CONSISTENCY_CHECK************
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSPO1042'.
  reorg_jobinfo = 'CHECK ADS SPOOL CONSISTENCY'.
  PERFORM check_report_exists CHANGING reorg_progname.
  IF reorg_progname IS NOT INITIAL.
    SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
    IF sy-subrc <> 0.
      wa_reorgjobs-progname = reorg_progname.
      wa_reorgjobs-jobname = 'SAP_ADS_SPOOL_CONSISTENCY_CHECK'.
      wa_reorgjobs-jobinfo = reorg_jobinfo.
      wa_reorgjobs-jobvariant = 'X'.
      wa_reorgjobs-component = 'BC'.
      wa_reorgjobs-defvariant = 'SAP&001'.
      wa_reorgjobs-defperiod = 'D'.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                   CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
      ENDIF.
      IF wa_reorgjobs-defvariant IS NOT INITIAL.
        INSERT reorgjobs FROM wa_reorgjobs.
        APPEND wa_reorgjobs-jobname TO modjobs.
      ENDIF.
    ELSE.
      PERFORM check_variant_exists USING wa_reorgjobs-progname
                                    CHANGING wa_reorgjobs-defvariant.
      IF wa_reorgjobs-defvariant IS INITIAL.
        PERFORM create_reorgjob_variant USING wa_reorgjobs-progname
                               CHANGING wa_reorgjobs-defvariant.
        IF wa_reorgjobs-defvariant IS NOT INITIAL.
          UPDATE reorgjobs FROM wa_reorgjobs.
          APPEND wa_reorgjobs-jobname TO modjobs.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

***********SAP_BTC_TABLE_CONSISTENCY_CHECK************
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_progname = 'RSBTCCNS'.
  reorg_jobinfo = 'CHECK BATCH TABLE CONSISTENCY'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc <> 0.
    wa_reorgjobs-progname = reorg_progname.
    wa_reorgjobs-jobname = 'SAP_BTC_TABLE_CONSISTENCY_CHECK'.
    wa_reorgjobs-jobinfo = reorg_jobinfo.
    wa_reorgjobs-jobvariant = 'X'.
    wa_reorgjobs-COMPONENT = 'BC'.
    wa_reorgjobs-defvariant = 'SAP&AUTOREPYES'.
    wa_reorgjobs-defperiod = 'D'.
    INSERT reorgjobs FROM wa_reorgjobs.
    APPEND wa_reorgjobs-jobname TO modjobs.
  ENDIF.

**********'SAP_ABAP_CHANNELS_MANAGEMENT'**********
  CLEAR: wa_reorgjobs, ins_flag, mod_flag.
  reorg_jobname  = 'SAP_ABAP_CHANNELS_MANAGEMENT'.
  reorg_progname = 'RS_AC_TOOLS_SCHEDULER'.
  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjobs WHERE progname = reorg_progname.
  IF sy-subrc = 0.
    CLEAR del.
    PERFORM delete_reorgjob USING reorg_jobname reorg_progname del.
    APPEND reorg_jobname TO modjobs.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM modjobs.
  DESCRIBE TABLE modjobs LINES lines.
  IF lines > 0.
    COMMIT WORK.
    IF sy-tcode = 'SM36'.
      CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
        EXPORTING
          i_title              = text-823
          i_allow_no_selection = 'X'
          i_tabname            = '1'
          i_structure_name     = 'BTCH1180'
        TABLES
          t_outtab             = modjobs
        EXCEPTIONS
          program_error        = 1
          OTHERS               = 2.
    ENDIF.
  ENDIF.

ENDFORM.                    " CLEANUP_REORG_JOBS
*&---------------------------------------------------------------------*
*&      Form  DELETE_REORGJOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REORG_JOBNAME  text
*      -->P_REORG_PROGNAME  text
*----------------------------------------------------------------------*
FORM delete_reorgjob  USING    r_jobname
                               r_progname
                               r_del.

  DATA: r_jobs TYPE TABLE OF tbtcs.
  DATA: lr_job TYPE tbtcs.
  DATA: i_progname TYPE tbtcp-progname.

  DELETE FROM reorgjobs WHERE jobname  = r_jobname
                          AND progname = r_progname.

  IF r_del IS NOT INITIAL.

    SELECT * FROM tbtcs INTO TABLE r_jobs WHERE jobname = r_jobname.

    IF sy-subrc = 0.
      LOOP AT r_jobs INTO lr_job.
        CLEAR i_progname.
        SELECT SINGLE progname FROM tbtcp INTO i_progname
                               WHERE jobname = lr_job-jobname
                               AND jobcount = lr_job-jobcount.

        IF i_progname = r_progname.
          CALL FUNCTION 'BP_JOB_DELETE'
            EXPORTING
              jobcount                 = lr_job-jobcount
              jobname                  = lr_job-jobname
*             FORCEDMODE               = ' '
*             COMMITMODE               = 'X'
            EXCEPTIONS
              cant_delete_event_entry  = 1
              cant_delete_job          = 2
              cant_delete_joblog       = 3
              cant_delete_steps        = 4
              cant_delete_time_entry   = 5
              cant_derelease_successor = 6
              cant_enq_predecessor     = 7
              cant_enq_successor       = 8
              cant_enq_tbtco_entry     = 9
              cant_update_predecessor  = 10
              cant_update_successor    = 11
              commit_failed            = 12
              jobcount_missing         = 13
              jobname_missing          = 14
              job_does_not_exist       = 15
              job_is_already_running   = 16
              no_delete_authority      = 17
              OTHERS                   = 18.
        ENDIF.

      ENDLOOP.

      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " DELETE_REORGJOB
*&---------------------------------------------------------------------*
*&      Form  MODIFY_REORG_JOBINFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REORG_JOBNAME  text
*      -->P_REORG_JOBINFO  text
*----------------------------------------------------------------------*
FORM modify_reorg_jobinfo  USING    p_reorg_progname
                                    p_reorg_jobinfo.

  DATA: wa_reorgjob TYPE reorgjobs.

  SELECT SINGLE * FROM reorgjobs INTO wa_reorgjob WHERE progname =
   p_reorg_progname AND jobinfo <> p_reorg_jobinfo.
  IF sy-subrc = 0.
    wa_reorgjob-jobinfo = p_reorg_jobinfo.
    UPDATE reorgjobs FROM wa_reorgjob.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " MODIFY_REORG_JOBINFO
*&---------------------------------------------------------------------*
*&      Form  CHECK_VARIANT_EXISTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_REORGJOBS_PROGNAME  text
*      <--P_WA_REORGJOBS_DEFVARIANT  text
*----------------------------------------------------------------------*
FORM check_variant_exists  USING    p_progname
                           CHANGING p_variant.

  DATA: v_rc TYPE sy-subrc.

  CALL FUNCTION 'RS_VARIANT_EXISTS'
    EXPORTING
      report              = p_progname
      variant             = p_variant
    IMPORTING
      r_c                 = v_rc
    EXCEPTIONS
      not_authorized      = 1
      no_report           = 2
      report_not_existent = 3
      report_not_supplied = 4
      OTHERS              = 5.
  IF v_rc <> 0.
    CLEAR p_variant.
  ENDIF.

ENDFORM.                    " CHECK_VARIANT_EXISTS
*&---------------------------------------------------------------------*
*&      Form  CREATE_REORGJOB_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_REORGJOBS_PROGNAME  text
*      <--P_WA_REORGJOBS_DEFVARIANT  text
*----------------------------------------------------------------------*
FORM create_reorgjob_variant  USING    p_progname
                              CHANGING p_variant.

  DATA: lt_varicont TYPE TABLE OF rsparams.
  DATA: ls_varicont TYPE rsparams.
  DATA: lt_varitext TYPE TABLE OF varit.
  DATA: ls_varitext TYPE varit.
  DATA: ls_desc TYPE varid.
  DATA: lt_fieldinfo TYPE TABLE OF rsel_info.
  DATA: ls_fieldname TYPE rsdynpar.
  DATA: lt_fieldname TYPE TABLE OF rsdynpar.
  DATA: remainder TYPE string.
  DATA: t_job TYPE btcjob.
  DATA: t_count TYPE btcjobcnt.
  DATA: t_variant TYPE btcvariant.
  DATA: index TYPE sy-tabix.

  CLEAR: ls_varicont, ls_varitext, ls_desc, ls_fieldname.
  REFRESH: lt_varicont, lt_varitext, lt_fieldname.

  CALL FUNCTION 'PRGN_CHECK_SYSTEM_TYPE'
    EXCEPTIONS
      sap_system = 1
      OTHERS     = 2.
  IF sy-subrc = 0.
    p_variant = 'CUS&001'.
    PERFORM check_variant_exists  USING    p_progname
                               CHANGING p_variant.
    IF p_variant IS INITIAL.
      p_variant = 'CUS&001'.
      GET TIME.
      ls_desc-mandt        = sy-mandt.
      ls_desc-report       = p_progname.
      ls_desc-variant      = p_variant.
      ls_desc-flag1        = space.
      ls_desc-flag2        = space.
      ls_desc-transport    = space.
      ls_desc-environmnt   = 'A'.     "Variant for batch and online
      ls_desc-protected    = space.
      ls_desc-secu         = space.
      ls_desc-version      = '1'.
      ls_desc-ename        = sy-uname.
      ls_desc-edat         = sy-datum.
      ls_desc-etime        = sy-uzeit.
      ls_desc-aename       = sy-uname.
      ls_desc-aedat        = sy-datum.
      ls_desc-aetime       = sy-uzeit.
      ls_desc-mlangu       = 'E'.

*.fill VARIT structure - variant texts
      ls_varitext-mandt      = sy-mandt.
      ls_varitext-langu      = sy-langu.
      ls_varitext-report     = p_progname.
      ls_varitext-variant    = p_variant.
      CASE p_progname.
        WHEN 'RSTS0024'.
          ls_varitext-vtext      = 'Default Variant'.       "#EC NOTEXT
        WHEN 'RSTS0043'.
          ls_varitext-vtext      = 'All Clients'.           "#EC NOTEXT
        WHEN 'BTC_DELETE_ORPHANED_IVARIS'.
          ls_varitext-vtext = 'Delete Orphaned Temp. Variants'. "#EC NOTEXT
        WHEN 'BTCAUX07'.
          ls_varitext-vtext = 'Check Active Jobs'.          "#EC NOTEXT
        WHEN 'RSBTCDEL2'.
          ls_varitext-vtext = 'Default: 14 days'.           "#EC NOTEXT
        WHEN 'RSPO1042'.
          ls_varitext-vtext =  'Delete inconsistencies after 8 days'.   "#EC NOTEXT
      ENDCASE.
      APPEND ls_varitext TO lt_varitext.

      IF p_progname <> 'RSBTCDEL2'.
        CALL FUNCTION 'RS_REPORTSELECTSCREEN_INFO'
          EXPORTING
            report              = p_progname
*           DEFAULT_VALUES      = 'X'
          TABLES
            field_info          = lt_fieldinfo
*           DEF_VALUES          =
            field_names         = lt_fieldname
          EXCEPTIONS
            no_selections       = 1
            report_not_existent = 2
            subroutine_pool     = 3
            OTHERS              = 4.
        IF sy-subrc <> 0.
          CLEAR p_variant.
        ELSE.

          LOOP AT lt_fieldname INTO ls_fieldname.
            ls_varicont-selname = ls_fieldname-param.
            ls_varicont-kind = 'P'.
            ls_varicont-sign = 'I'.
            ls_varicont-option = 'EQ'.
            CASE p_progname.
              WHEN 'BTCAUX07'.
                IF ls_fieldname-param = 'MIN_AGE'.
                  ls_varicont-low = 60.
                ELSEIF ls_fieldname-param = 'ACTIVE'.
                  ls_varicont-low = 'X'.
                ELSEIF ls_fieldname-param = 'READY'.
                  ls_varicont-low = space.
                ENDIF.
              WHEN 'RSTS0024'.
                IF ls_fieldname-param = 'LISTONLY'.
                  ls_varicont-low = space.
                ELSEIF ls_fieldname-param = 'CHECK'.
                  ls_varicont-low = space.
                ELSEIF ls_fieldname-param = 'DELETE'.
                  ls_varicont-low = 'X'.
                ELSEIF ls_fieldname-param = 'LIMIT'.
                  ls_varicont-low = '20000'.
                ENDIF.
              WHEN 'RSTS0043'.
                IF ls_fieldname-param = 'CLIENT'.
                  ls_varicont-low = '*'.
                ELSEIF ls_fieldname-param = 'IDI'.
                  ls_varicont-low = '*'.
                ELSEIF ls_fieldname-param = 'LOCAT'.
                  ls_varicont-low = 'G'.
                ELSEIF ls_fieldname-param = 'DELFLAG'.
                  ls_varicont-low = 'X'.
                ENDIF.
              WHEN 'BTC_DELETE_ORPHANED_IVARIS'.
                IF ls_fieldname-param CS '-'.
                  SPLIT ls_fieldname-param AT '-' INTO ls_varicont-selname remainder.
                ELSE.
                  ls_varicont-selname = ls_fieldname-param.
                ENDIF.
                IF ls_varicont-selname = 'S_REP'.
                  ls_varicont-kind = 'S'.
*    ls_varicont-sign = 'I'.
*    ls_varicont-option = 'EQ'.
*    ls_varicont-low = space.
                ELSEIF ls_varicont-selname = 'S_VAR'.
                  ls_varicont-kind = 'S'.
*    ls_varicont-sign = 'I'.
*    ls_varicont-option = 'EQ'.
*    ls_varicont-low = space.
                ELSEIF ls_varicont-selname = 'DELETE'.
                  ls_varicont-kind = 'P'.
                  ls_varicont-sign = 'I'.
                  ls_varicont-option = 'EQ'.
                  ls_varicont-low = 'X'.
                ENDIF.
              WHEN 'RSPO1042'.
                IF ls_fieldname-param = 'KEEPDAYS'.
                  ls_varicont-low = '08'.
                ELSEIF ls_fieldname-param = 'SIMONLY'.
                  ls_varicont-low = space.
                ENDIF.
            ENDCASE.
            APPEND ls_varicont TO lt_varicont.
            CLEAR: ls_varicont, remainder.
          ENDLOOP.
        ENDIF.
      ELSE.
        t_job = 'TO_BE_DELETED'.                            "#EC NOTEXT
        CALL FUNCTION 'JOB_OPEN'               " create dummy job with temp variant
          EXPORTING
            jobname                = t_job
         IMPORTING
           jobcount               = t_count
         EXCEPTIONS
           OTHERS                 = 99.
        IF sy-subrc <> 0.
          CLEAR p_variant.
          EXIT.
        ENDIF.
        SUBMIT (p_progname) VIA JOB t_job NUMBER t_count
        WITH testrun = space
        AND RETURN.
        IF sy-subrc <> 0.
          CLEAR p_variant.
          EXIT.
        ENDIF.
        SELECT SINGLE variant FROM tbtcp INTO t_variant WHERE
          jobname = t_job AND jobcount = t_count AND
          stepcount = 1.
        IF sy-subrc <> 0.
          CLEAR p_variant.
          EXIT.
        ENDIF.
        CALL FUNCTION 'RS_VARIANT_VALUES_TECH_DATA'
          EXPORTING
            report                     = p_progname
            variant                    = t_variant
*   SEL_TEXT                   = ' '
*   MOVE_OR_WRITE              = 'W'
*   SORTED                     = ' '
*   EXECUTE_DIRECT             =
* IMPORTING
*   TECHN_DATA                 =
          TABLES
            variant_values             = lt_varicont
*   VARIANT_TEXT               =
         EXCEPTIONS
           variant_non_existent       = 1
           variant_obsolete           = 2
           OTHERS                     = 3
                  .
        IF sy-subrc <> 0.
          CLEAR p_variant.
          EXIT.
        ENDIF.
        PERFORM delete_rec_job USING t_job t_count.

        READ TABLE lt_varicont INTO ls_varicont WITH KEY selname = 'PORTION'.
        IF sy-subrc = 0.
          index = sy-tabix.
          REPLACE ALL OCCURRENCES OF ',' IN ls_varicont-low WITH '.'.
          MODIFY lt_varicont FROM ls_varicont INDEX index.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'RS_CREATE_VARIANT'
        EXPORTING
          curr_report               = p_progname
          curr_variant              = p_variant
          vari_desc                 = ls_desc
        TABLES
          vari_contents             = lt_varicont
          vari_text                 = lt_varitext
*         VSCREENS                  =
        EXCEPTIONS
          illegal_report_or_variant = 1
          illegal_variantname       = 2
          not_authorized            = 3
          not_executed              = 4
          report_not_existent       = 5
          report_not_supplied       = 6
          variant_exists            = 7
          variant_locked            = 8
          OTHERS                    = 9.
      IF sy-subrc <> 0.
        CLEAR p_variant.
      ENDIF.
*      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " CREATE_REORGJOB_VARIANT
*&---------------------------------------------------------------------*
*&      Form  DELETE_REC_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REC_JOBNAME  text
*      -->P_JC  text
*----------------------------------------------------------------------*
FORM delete_rec_job  USING    p_rec_jobname
                              p_jc.

  CALL FUNCTION 'BP_JOB_DELETE'
    EXPORTING
      jobcount = p_jc
      jobname  = p_rec_jobname
    EXCEPTIONS
      OTHERS   = 99.

ENDFORM.                    " DELETE_REC_JOB
*&---------------------------------------------------------------------*
*&      Form  CHECK_REPORT_EXISTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_REORG_PROGNAME  text
*----------------------------------------------------------------------*
FORM check_report_exists  CHANGING p_progname.

  CALL FUNCTION 'RPY_EXISTENCE_CHECK_PROG'
   EXPORTING
     name              = p_progname
*   LIMU_KEY          =
* TABLES
*   PROGDIR_TAB       =
   EXCEPTIONS
     not_exist         = 1
     OTHERS            = 2
            .
  IF sy-subrc <> 0.
    CLEAR p_progname.
  ENDIF.

ENDFORM.                    " CHECK_REPORT_EXISTS
*&---------------------------------------------------------------------*
*&      Form  CHECK_REORG_AUTHCKNAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_reorg_authcknam using p_authcknam type btcauthnam.

  data: auth_rc type sy-subrc.

  PERFORM auth_check_nam USING p_authcknam auth_rc.

  CASE auth_rc.
    WHEN 0.
      " Einplanung des angegebenen benutzernamens ist ok

    WHEN no_user_assign_privilege.
         MESSAGE e102 WITH p_authcknam.

    WHEN invalid_username.
        MESSAGE e071 WITH p_authcknam.

    WHEN bad_user_type.
        MESSAGE e103 WITH p_authcknam.
  ENDCASE.

ENDFORM.
