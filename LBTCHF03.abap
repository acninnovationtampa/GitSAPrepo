***INCLUDE LBTCHF03 .

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_STARTDATE_EDITOR             *
************************************************************************

*---------------------------------------------------------------------*
*       FORM DTTM_SHOW_ONLY                                           *
*---------------------------------------------------------------------*
* Diese Funktion schaltet die Eingabebereitschaft fuer die Angabe     *
* eines Starttermins aus.                                             *
*---------------------------------------------------------------------*
FORM dttm_show_only.

  LOOP AT SCREEN.
    IF screen-group2 EQ 'PIC'.
      screen-input = off.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.  " DTTM_SHOW_ONLY

*---------------------------------------------------------------------*
*       FORM CHECK_PRED_1010                                          *
*---------------------------------------------------------------------*
*  Prüfe Gültigkeit eines im Rahmen der Starttermineingabe einge-
*  gebenen Vorgängerjobs
*---------------------------------------------------------------------*
FORM check_pred_1010.
*
*   Pruefe, ob Eingabe stattgefunden hat
*
  DATA: lv_status    TYPE btcstatus.
  DATA: predjob_info TYPE btcjobinfo.
  DATA: len TYPE I.
  DATA: ls_predjob TYPE tbtco.


  IF btch1010-predjob EQ space.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e003.
    ELSE.
      PERFORM raise_stdt_exception USING invalid_predecessor_jobname
*                                         btch1010-predjob.
            predjob_info.
    ENDIF.
  ENDIF.
*
*   Pruefe, ob Vorgaenger existiert bzw. als Vorgängerjob zulässig ist
*
  CLEAR pred_tbl.
  REFRESH pred_tbl.

  SELECT * FROM tbtco INTO TABLE pred_tbl
    WHERE jobname = btch1010-predjob
    AND ( status EQ btc_scheduled OR
          status EQ btc_released ).
  IF sy-dbcnt EQ 0.  " Vorgaenger existiert nicht
    IF stdt_dialog EQ btc_yes.
      MESSAGE e004 WITH btch1010-predjob.
    ELSE.
      PERFORM raise_stdt_exception USING
              predjob_doesnt_exist btch1010-predjob.
    ENDIF.
  ELSEIF sy-dbcnt EQ 1. " es existiert genau ein Vorgaenger
    READ TABLE pred_tbl INDEX 1.               "#EC CI_NOORDER
    IF btch1010-predjobcnt IS INITIAL."09.2006 c5035006
      btch1010-predjobcnt = pred_tbl-jobcount.
    ELSE.
      IF btch1010-predjobcnt NE pred_tbl-jobcount
      AND stdt_dialog EQ btc_no.
        PERFORM raise_stdt_exception USING
              invalid_predecessor_jobname btch1010-predjob.
      ELSE.
        btch1010-predjobcnt = pred_tbl-jobcount.
      ENDIF.
    ENDIF.
  ELSE.  " es existieren mehrere Vorgaenger

    IF stdt_dialog EQ btc_yes.               "hgk  11.4.2001
      IF temp_snjob-jc IS INITIAL.          "hgk  23.1.2001
        CLEAR btch1010-predjobcnt.         "hgk  16.1.2001
      ENDIF.
    ENDIF.

    IF btch1010-predjobcnt IS INITIAL. " falls Vorgänger nicht eindeutig
      IF stdt_dialog EQ btc_yes.      " spezifiziert wurde

        CLEAR same_name_jobs.      " hgk  23.1.2001
        REFRESH same_name_jobs.    " hgk  23.1.2001

        LOOP AT pred_tbl.
          MOVE-CORRESPONDING pred_tbl TO same_name_jobs.
          APPEND same_name_jobs.
        ENDLOOP.

        CALL SCREEN 4471 STARTING AT 10 10
        ENDING   AT 70 20.

        btch1010-predjobcnt = temp_snjob-jc.

      ELSE."09.2006 c5035006
        PERFORM raise_stdt_exception USING
              predecessor_jobname_not_unique btch1010-predjob.
      ENDIF.

    ELSE. " falls Vorgänger eindeutig spezifiziert wurde

      CLEAR temp_snjob-jc.  " hgk 23.1.2001
      "09.2006 c5035006
      SELECT SINGLE status FROM tbtco INTO lv_status
      WHERE jobname  = btch1010-predjob
      AND   jobcount = btch1010-predjobcnt.

      IF sy-subrc <> 0.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e450 WITH btch1010-predjob btch1010-predjobcnt.
        ELSE.
         len =  strlen( btch1010-predjob ).
         CONCATENATE btch1010-predjob(len) btch1010-predjobcnt INTO predjob_info
         SEPARATED BY ' \ '.
         PERFORM raise_stdt_exception USING
                invalid_predecessor_jobname predjob_info.
        ENDIF.
      ELSE.
        IF lv_status <> btc_scheduled AND
           lv_status <> btc_released.
          IF stdt_dialog EQ btc_yes.
            MESSAGE e004 WITH btch1010-predjob.
          ELSE.
            PERFORM raise_stdt_exception USING
                  predjob_wrong_status btch1010-predjob.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM. " CHECK_PRED_1010

*---------------------------------------------------------------------*
*       FORM CHECK_DTTM_1010                                          *
*---------------------------------------------------------------------*
* Prüfe Gültigkeit der Startterminangabe Datum / Uhrzeit              *
*---------------------------------------------------------------------*
FORM check_dttm_1010.

  DATA: latest_exec_date_given,
        latest_exec_time_given,
        diff_days TYPE I,
        formatted_dt(10),
        formatted_tm(8),
        log_dt_tm(32).

  DATA: d1 TYPE timestamp.
  CONSTANTS: tolerance_dia TYPE I VALUE   60.      " 1 min
  CONSTANTS: tolerance_nodia TYPE I VALUE 3720.    " 1 h 2 min

  exec_date_given        = space.
  exec_time_given        = space.
  latest_exec_date_given = space.
  latest_exec_time_given = space.
*
*   Pruefe, ob Eingabe stattgefunden hat
*
  IF btch1010-sdlstrtdt NE no_date AND
  NOT ( btch1010-sdlstrtdt IS INITIAL ).
    exec_date_given = 'X'.
  ELSE.
    btch1010-sdlstrtdt = no_date.
  ENDIF.

  IF btch1010-sdlstrttm IS INITIAL.
    IF exec_date_given EQ 'X'.
      exec_time_given = 'X'.
    ELSE.
      btch1010-sdlstrttm = no_time.
    ENDIF.
  ELSE.
    IF btch1010-sdlstrttm NE no_time.
      exec_time_given = 'X'.
    ENDIF.
  ENDIF.

  IF exec_date_given = space OR exec_time_given = space.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e005.
    ELSE.
      PERFORM raise_stdt_exception USING incomplete_startdate space.
    ENDIF.
  ENDIF.
*
*   Pruefe, ob Ausfuehrungstermin in der Vergangenheit liegt
*   ( changed with note 1394208)
  CALL METHOD cl_bp_utilities=>check_starttime
     EXPORTING
         i_sdlstrtdt = btch1010-sdlstrtdt
         i_sdlstrttm = btch1010-sdlstrttm
     RECEIVING
         d1          = d1.

  IF d1 > 0.
    CASE stdt_dialog.
    WHEN btc_yes.
      IF d1 <= tolerance_dia.
        btch1010-sdlstrtdt = sy-datum.
        btch1010-sdlstrttm = sy-uzeit.
    ELSEIF d1 > tolerance_dia.
        MESSAGE e006.
      ENDIF.
    WHEN btc_no.
      IF d1 <= tolerance_nodia.
        btch1010-sdlstrtdt = sy-datum.
        btch1010-sdlstrttm = sy-uzeit.
    ELSEIF d1 > tolerance_nodia.
        WRITE btch1010-sdlstrtdt TO formatted_dt DD/MM/YYYY .
        WRITE btch1010-sdlstrttm TO formatted_tm USING EDIT MASK '__:__:__'.
        CONCATENATE formatted_dt formatted_tm
        INTO log_dt_tm SEPARATED BY space.
        PERFORM raise_stdt_exception USING
              startdate_in_the_past log_dt_tm.
      ENDIF.
    ENDCASE.
  ENDIF.

  IF ( btch1010-laststrtdt NE no_date         AND
    NOT ( btch1010-laststrtdt IS INITIAL )     ).
    latest_exec_date_given = 'X'.
  ELSE.
    btch1010-laststrtdt = no_date.
  ENDIF.
*
* diese Abfrage prüft, ob eine Uhrzeit 00:00:00 als späteste
* Uhrzeit oder als Initialwert zu interpretieren ist. Ist ein
* spätestes Datum angegeben, so wird 00:00:00 als Uhrzeit inter-
* pretiert, ansonsten als Initialwert. Problem: Falls nur die
* Uhrzeit 00:00:00 eingegeben wurde und kein Datum, so fällt
* die Uhrzeit unter den Tisch.
*
  IF btch1010-laststrttm IS INITIAL.
    IF latest_exec_date_given EQ 'X'.
      latest_exec_time_given = 'X'.
    ELSE.
      btch1010-laststrttm = no_time.
    ENDIF.
  ELSE.
    IF btch1010-laststrttm NE no_time.
      latest_exec_time_given = 'X'.
    ENDIF.
  ENDIF.

  IF ( ( latest_exec_date_given EQ 'X' AND
         latest_exec_time_given EQ ' '     ) OR
       ( latest_exec_date_given EQ ' ' AND
         latest_exec_time_given EQ 'X'     )    ).
*
*    unvollständige späteste Startterminangabe
*
    IF stdt_dialog EQ btc_yes.
      MESSAGE e007.
    ELSE.
      PERFORM raise_stdt_exception USING
            incomplete_last_startdate space.
    ENDIF.
  ENDIF.

  IF ( latest_exec_date_given EQ 'X' AND
  latest_exec_time_given EQ 'X'     ).
    IF ( ( btch1010-laststrtdt LT btch1010-sdlstrtdt     ) OR
         ( btch1010-laststrtdt EQ btch1010-sdlstrtdt AND
           btch1010-laststrttm LE btch1010-sdlstrttm     )    ).
*
*       späteste Startterminangabe liegt in der Vergangenheit
*
      IF stdt_dialog EQ btc_yes.
        MESSAGE e008.
      ELSE.
        PERFORM raise_stdt_exception USING
              last_startdate_in_the_past space.
      ENDIF.
    ENDIF.

    diff_days = btch1010-laststrtdt - btch1010-sdlstrtdt.

    IF diff_days > days_per_year.
*
*        Differenz spaetester Starttermin - Starttermin > 1 Jahr
*
      IF stdt_dialog EQ btc_yes.
        MESSAGE e009.
      ELSE.
        PERFORM raise_stdt_exception USING
              startdate_interval_too_large space.
      ENDIF.
    ENDIF.
*
*    Angaben spätester Starttermin ok !
*
  ENDIF.

ENDFORM. " CHECK_DTTM_1010

*---------------------------------------------------------------------*
*       CHECK_EVENT_1010                                              *
*---------------------------------------------------------------------*
* Pruefe Gueltigkeit der Startterminanagabe 'Start nach Event' bzw.   *
* 'bei Betriebsart' ( wird mit Events abgebildet )                    *
*---------------------------------------------------------------------*
FORM check_event_1010.

  DATA: rc TYPE i.

*** for tracing *****************************************

data: tracelevel_btc type i.

perform check_and_set_trace_level_btc
                            using tracelevel_btc
                                  btch1010-eventid.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'CHECK_EVENT_1010'        "#EC NOTEXT
                                          'Event = '                "#EC NOTEXT
                                          btch1010-eventid
                                          ' '.

perform write_string_to_wptrace_btc using tracelevel_btc
                                          'CHECK_EVENT_1010'        "#EC NOTEXT
                                          'Parameter = '            "#EC NOTEXT
                                          btch1010-eventparm
                                          ' '.

*********************************************************

  IF stdt_oms_is_active EQ true.  " Starttermin 'bei Betriebsart'

    PERFORM check_opmodename USING btch1010-opmode rc.

    IF rc EQ 0.
      btch1010-eventid   = oms_eventid.
      btch1010-eventparm = btch1010-opmode.
    ELSE.

      perform err_string_to_wptrace_btc
                           using 'check_event_1010:'                   "#EC NOTEXT
                                 'check_opmodename returned rc ne 0.'  "#EC NOTEXT
                                 'Opmode ='                            "#EC NOTEXT
                                  btch1010-opmode.

      IF stdt_dialog EQ btc_yes.
        MESSAGE e203 WITH btch1010-opmode.
      ELSE.
        PERFORM raise_stdt_exception USING invalid_opmode_name
                                           btch1010-opmode.
      ENDIF.
    ENDIF.

  ELSE.       " Starttermin 'nach Event'

    CALL FUNCTION 'BP_CHECK_EVENTID'
      EXPORTING
        event_id                   = btch1010-eventid
*       EVENT_ID_TYPE              = USER_EVENTID   " wg. Transportgruppe
        event_id_type              = any_eventid_type       " 17.2.94
      EXCEPTIONS
        no_eventid_specified       = 1
        eventid_not_defined_yet    = 2
        invalid_usereventid_prefix = 3
        OTHERS                     = 99.

    CASE sy-subrc.
      WHEN 0.
        " EventId ok
* SAP_END_OF_JOB without parameters is not accepted
        if btch1010-eventid = cl_batch_event=>event_sap_end_of_job.
           if btch1010-eventparm is initial or btch1010-eventparm co ' '.

              perform err_string_to_wptrace_btc
                           using 'check_event_1010:'                   "#EC NOTEXT
                                 'SAP_END_OF_JOB without parameters.'  "#EC NOTEXT
                                 ' '
                                 ' '.

              IF stdt_dialog EQ btc_yes.
                 MESSAGE e645 with 'SAP_END_OF_JOB without parameters not allowed'.
              ELSE.
                 PERFORM raise_stdt_exception USING
                     invalid_eventid btch1010-eventid.
              ENDIF.

           endif.

        endif.

      WHEN 1.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e038.
        ELSE.
          PERFORM raise_stdt_exception USING
                  no_eventid_given space.
        ENDIF.

      WHEN 2.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e042 WITH btch1010-eventid.
        ELSE.
          PERFORM raise_stdt_exception USING
                  invalid_eventid btch1010-eventid.
        ENDIF.

      WHEN 3.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e040.
        ELSE.
          PERFORM raise_stdt_exception USING
                  invalid_eventid btch1010-eventid.
        ENDIF.

      when others.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e645 with 'Event Error'.
        ELSE.
          PERFORM raise_stdt_exception USING
                  invalid_eventid btch1010-eventid.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM. " CHECK_EVENT_1010

*---------------------------------------------------------------------*
*       PRESS_STDT_IMMED_BUTTON                                       *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 das Ankreuzfeld für 'Sofort'       *
* gedrückt und nicht eingabebereit geschaltet wird. Die restlichen    *
* Ankreuzfelder werden deaktiviert.                                   *
*---------------------------------------------------------------------*
FORM press_stdt_immed_button.

  btch1010-immed = 'X'.

  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
ENDFORM. " PRESS_STDT_IMMED_BUTTON

*---------------------------------------------------------------------*
*       ADMIT_STDT_DTTM_INPUT                                         *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 nur die Felder für Angabe         *
* 'Datum / Uhrzeit' aktiv sind. Der Radiobuttons für 'CHECKSTAT'      *
* muß deaktiviert werden.                                             *
*---------------------------------------------------------------------*
FORM admit_stdt_dttm_input.

  PERFORM set_screen_grp_attribut USING 'DAT' 'DTM' space space
                                        invisible off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'DTM' space space
                                        input on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
ENDFORM. " ADMIT_STDT_DTTM_INPUT.

*---------------------------------------------------------------------*
*       ADMIT_STDT_AFTERJOB_INPUT                                      *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 nur die Felder für Angabe         *
* 'nach Vorgängerjob' aktiv sind. Radiobuttons für 'Sofort' und       *
* 'periodisch' deaktivieren.                                          *
*---------------------------------------------------------------------*
FORM admit_stdt_afterjob_input.

  PERFORM set_screen_grp_attribut USING 'DAT' 'JOB' space space
                                        invisible off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'JOB' space space
                                        input on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
ENDFORM. " ADMIT_STDT_AFTERJOB_INPUT.

*---------------------------------------------------------------------*
*       ADMIT_STDT_EVENT_INPUT                                        *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 nur die Felder für Angabe         *
* 'nach Event' bzw. 'bei Betriebsart' aktiv sind. Radiobuttons für    *
* 'Sofort' und 'CHECKSTAT' deaktivieren.                              *
*---------------------------------------------------------------------*
FORM admit_stdt_event_input.

  IF stdt_oms_is_active EQ true.
    PERFORM set_screen_grp_attribut USING 'DAT' 'OMS' space space
                                          invisible off.
    PERFORM set_screen_grp_attribut USING 'DAT' 'OMS' space space
                                          input on.
  ELSE.
    PERFORM set_screen_grp_attribut USING 'DAT' 'EVT' space space
                                          invisible off.
    PERFORM set_screen_grp_attribut USING 'DAT' 'EVT' space space
                                          input on.
  ENDIF.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
ENDFORM. " ADMIT_STDT_EVENT_INPUT.

*---------------------------------------------------------------------*
*       ADMIT_NO_STDT_INPUT                                           *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 kein Radiobutton eingabebereit    *
* ist - die Felder sind defaultmäßig nicht eingabebereit.             *
*---------------------------------------------------------------------*
FORM admit_no_stdt_input.

  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
ENDFORM. " ADMIT_NO_STDT_INPUT.

*---------------------------------------------------------------------*
*       HIDE_STDT_INPUT                                               *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 kein Radiobutton eingabebereit    *
* ist und nicht angezeigt wird                                        *
*---------------------------------------------------------------------*
FORM hide_stdt_input.

  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        invisible on.
ENDFORM. " HIDE_STDT_INPUT

*---------------------------------------------------------------------*
*       SHOW_STDT_IMMEDIATE                                           *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 Starttermin 'Sofort' angezeigt    *
* wird                                                                *
*---------------------------------------------------------------------*
FORM show_stdt_immediate.

  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
ENDFORM. " SHOW_STDT_IMMEDIATE

*---------------------------------------------------------------------*
*       SHOW_STDT_DATETIME                                            *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 Starttermin 'Datum / Uhrzeit'     *
* angezeigt wird                                                      *
*---------------------------------------------------------------------*
FORM show_stdt_dttm.

  PERFORM set_screen_grp_attribut USING 'DAT' 'DTM' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'DTM' space space
                                        invisible off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
ENDFORM. " SHOW_STDT_DTTM

*---------------------------------------------------------------------*
*       SHOW_STDT_AFTERJOB                                            *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 Starttermin 'nach Vorgängerjob'   *
* angezeigt wird                                                      *
*---------------------------------------------------------------------*
FORM show_stdt_afterjob.

  PERFORM set_screen_grp_attribut USING 'DAT' 'JOB' space space
                                        invisible off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        invisible on.
ENDFORM. " SHOW_STDT_AFTERJOB

*---------------------------------------------------------------------*
*       SHOW_STDT_EVENT                                               *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 Starttermin 'nach Event' bzw.     *
* 'bei Betriebsart' angezeigt wird                                    *
*---------------------------------------------------------------------*
FORM show_stdt_event.

  IF stdt_oms_is_active EQ true.
    PERFORM set_screen_grp_attribut USING 'DAT' 'OMS' space space
                                          input off.
    PERFORM set_screen_grp_attribut USING 'DAT' 'OMS' space space
                                          invisible off.
  ELSE.
    PERFORM set_screen_grp_attribut USING 'DAT' 'EVT' space space
                                          input off.
    PERFORM set_screen_grp_attribut USING 'DAT' 'EVT' space space
                                          invisible off.
  ENDIF.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'IMD' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        input off.
  PERFORM set_screen_grp_attribut USING 'DAT' 'CST' space space
                                        invisible on.
  PERFORM set_screen_grp_attribut USING 'DAT' 'PRD' space space
                                        input off.
ENDFORM. " SHOW_STDT_EVENT

*---------------------------------------------------------------------*
*       SHOW_STDT_EVENT                                               *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1060 / 1190 Periodenfelder nicht mehr  *
* eingabebereit sind                                                  *
*---------------------------------------------------------------------*
FORM show_stdt_period.

  PERFORM set_screen_grp_attribut USING 'DAT' space space space
                                        input off.
ENDFORM. " SHOW_STDT_PERIOD

*---------------------------------------------------------------------*
*       SHOW_STDT_PUSHBUTTONS                                         *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1010 die Pusbuttons lediglich ange-    *
* zeigt werden                                                        *
*---------------------------------------------------------------------*
FORM show_stdt_pushbuttons.

  PERFORM set_screen_grp_attribut USING 'DAT' 'PUS' space space
                                        input off.
ENDFORM. " SHOW_STDT_PUSHBUTTONS

*---------------------------------------------------------------------*
*       FORM INIT_1010_START_DATA                                     *
*---------------------------------------------------------------------*
* Initialisierung der Startterminangaben auf dem Dynpro 1010 ab-     ,*
* hängig vom übergebenen Parameter WHICH_DATA                         *
*---------------------------------------------------------------------*
FORM init_1010_start_data USING which_data.

  CASE which_data.
    WHEN everything.
*
*     alle Startterminangaben initialisieren
*
      CLEAR btch1010-immed.

      btch1010-sdlstrtdt  = no_date.
      btch1010-sdlstrttm  = no_time.
      btch1010-laststrtdt = no_date.
      btch1010-laststrttm = no_time.

      CLEAR btch1010-predjob.
      CLEAR btch1010-predjobcnt.
      CLEAR btch1010-checkstat.

      CLEAR btch1010-eventid.
      CLEAR btch1010-eventparm.
      CLEAR btch1010-opmode.

      CLEAR btch1010-periodic.

    WHEN not_immed.
*
*     alle Startterminangaben ausser Sofortausführung initialisieren
*
      btch1010-sdlstrtdt  = no_date.
      btch1010-sdlstrttm  = no_time.
      btch1010-laststrtdt = no_date.
      btch1010-laststrttm = no_time.

      CLEAR btch1010-predjob.
      CLEAR btch1010-predjobcnt.
      CLEAR btch1010-checkstat.

      CLEAR btch1010-eventid.
      CLEAR btch1010-eventparm.
      CLEAR btch1010-opmode.

    WHEN not_datetime.
*
*     alle Startterminangaben ausser Datum / Uhrzeit initialisieren
*
      btch1010-immed = space.

      CLEAR btch1010-predjob.
      CLEAR btch1010-predjobcnt.
      CLEAR btch1010-checkstat.

      CLEAR btch1010-eventid.
      CLEAR btch1010-eventparm.
      CLEAR btch1010-opmode.

    WHEN not_predjob.
*
*     alle Startterminangaben ausser Vorgängerjob initialisieren
*
      btch1010-immed = space.

      btch1010-sdlstrtdt  = no_date.
      btch1010-sdlstrttm  = no_time.
      btch1010-laststrtdt = no_date.
      btch1010-laststrttm = no_time.

      CLEAR btch1010-eventid.
      CLEAR btch1010-eventparm.
      CLEAR btch1010-opmode.

      CLEAR btch1010-periodic.

    WHEN not_eventid.
*
*     alle Startterminangaben ausser EventId / Betriebsart init.
*
      btch1010-immed = space.

      btch1010-sdlstrtdt  = no_date.
      btch1010-sdlstrttm  = no_time.
      btch1010-laststrtdt = no_date.
      btch1010-laststrttm = no_time.

      CLEAR btch1010-predjob.
      CLEAR btch1010-predjobcnt.
      CLEAR btch1010-checkstat.

  ENDCASE.

ENDFORM.  " INIT_1010_START_DATA

*---------------------------------------------------------------------*
*   FORM CHECK_INPUT_1010                                             *
*---------------------------------------------------------------------*
* Starttermindaten auf Dynpro 1010 auf Gültigkeit hin prüfen. Diese   *
* Routine wird sowohl im Dialog- als auch im Nichtdialogfall benutzt. *
*---------------------------------------------------------------------*

FORM check_input_1010.

  IF ( btch1260-calendarid = space OR btch1260-calendarid IS INITIAL )
     AND stdt_dialog EQ btc_yes.   " hgk  12.7.2001
    CLEAR stdt_input-calendarid.
    CLEAR stdt_input-wdayno.
    CLEAR stdt_input-wdaycdir.
    CLEAR stdt_input-prdbehav.
  ENDIF.

  IF btch1010-periodic EQ 'X'.
    stdt_input-periodic = 'X'.
    IF stdt_typ EQ btc_stdt_datetime OR " prüfen, ob Periodenwerte an-
       stdt_typ EQ btc_stdt_immediate.  " gegeben wurden
      sum = stdt_input-prdmins  +
            stdt_input-prdhours +
            stdt_input-prddays  +
            stdt_input-prdweeks +
            stdt_input-prdmonths.
      IF sum EQ 0. " Periodenzeit fehlt
        IF stdt_dialog EQ btc_yes.
          MESSAGE e033.
        ELSE.
          PERFORM raise_stdt_exception USING
                  no_period_data_given space.
        ENDIF.
      ENDIF.
    ELSEIF stdt_typ EQ btc_stdt_afterjob.  " Start nach Vorgängerjob
      IF stdt_dialog EQ btc_yes.           " mit Periode ist nicht
        CLEAR btch1010-periodic.          " zugelassen
        MESSAGE e031.
      ELSE.
        PERFORM raise_stdt_exception USING
                period_and_predjob_no_way space.
      ENDIF.
    ELSEIF stdt_typ EQ btc_stdt_event.     " bei Starttermin = 'nach
      stdt_input-prdmins   = 0.            " Event' werden keine
      stdt_input-prdhours  = 0.            " Zeitangaben benötigt
      stdt_input-prddays   = 0.
      stdt_input-prdweeks  = 0.
      stdt_input-prdmonths = 0.
    ENDIF.
  ELSE.
    stdt_input-periodic  = space.
    stdt_input-prdmins   = 0.
    stdt_input-prdhours  = 0.
    stdt_input-prddays   = 0.
    stdt_input-prdweeks  = 0.
    stdt_input-prdmonths = 0.

  ENDIF.

*  orig_stdt_typ = stdt_typ.

*  DO 2 TIMES.
  CASE stdt_typ.
    WHEN btc_stdt_immediate.
*
*     falls heute kein Arbeitstag ist und der Starttermin auf Grund der
*     Einschränkung 'Starttermin verschieben' in die Zukunft geschoben
*     werden muß, wird der Starttermintyp nach 'Datum/Uhrzeit' gewandelt
*
      PERFORM check_holiday_reaction.
      IF stdt_input-calcorrect EQ 0.
        PERFORM init_1010_start_data USING not_immed.
      ELSE.
        stdt_typ = btc_stdt_datetime.
        PERFORM init_1010_start_data USING not_datetime.
      ENDIF.
    WHEN btc_stdt_datetime.
      PERFORM check_dttm_1010.
*        CHECK stdt_typ EQ orig_stdt_typ.
      PERFORM check_holiday_reaction.
      PERFORM check_dttm_1010.  " Absicht, wegen Sonderfälle !
      PERFORM init_1010_start_data USING not_datetime.
    WHEN btc_stdt_afterjob.
      PERFORM check_pred_1010.
      PERFORM init_1010_start_data USING not_predjob.
    WHEN btc_stdt_event.
      PERFORM check_event_1010.
      PERFORM init_1010_start_data USING not_eventid.
    WHEN OTHERS.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e001.
      ELSE.
        RAISE no_startdate_given. " kein Syslog hier !
      ENDIF.
  ENDCASE.
*    IF stdt_typ EQ orig_stdt_typ.
*      EXIT.
*    ENDIF.
*  ENDDO.


ENDFORM. " CHECK_INPUT_1010.

*---------------------------------------------------------------------*
*   FORM FILL_1010_STDT_DATA                                          *
*---------------------------------------------------------------------*
* Starttermindaten in das Dynpro 1010 "schieben" abhängig vom         *
* gegebenen Starttermintyp                                            *
*---------------------------------------------------------------------*

FORM fill_1010_stdt_data.

  PERFORM init_1010_start_data USING everything.
  stdt_typ = stdt_input-startdttyp.

  IF stdt_typ EQ btc_stdt_immediate.
*
*     Starttermintyp = 'Sofort'
*
    btch1010-immed = 'X'.
  ELSEIF stdt_typ EQ btc_stdt_datetime.
*
*     Starttermintyp = 'Datum / Uhrzeit'
*
* bei Dialog = nein (Starttermindaten sollen lediglich geprüft werden)
* das ursprüngliche Startdatum unter Berücksichtigung der Fabrik-
* kalenderkorrektur berechnen. Da teilweise der Starttermineditor zum
* Prüfen von Daten mehr als ein Mal durchlaufen wird, muß diese Rück-
* rechnung erfolgen, damit die Korrektur nicht 'vergessen' wird. Im
* Dialogfall wird die Fabrikkalenderkorrektur nicht berücksichtigt
* um den Benutzer nicht zu verwirren.
*
    IF stdt_input-sdlstrtdt NE no_date AND
       NOT ( stdt_input-sdlstrtdt IS INITIAL ).
      IF stdt_dialog EQ btc_yes.
        btch1010-sdlstrtdt = stdt_input-sdlstrtdt.
      ELSE.
        btch1010-sdlstrtdt = stdt_input-sdlstrtdt -
                             stdt_input-calcorrect.
      ENDIF.
    ELSE.
      btch1010-sdlstrtdt = no_date.
    ENDIF.

    IF stdt_input-sdlstrttm EQ no_time.
      btch1010-sdlstrttm = no_time.
    ELSE.
      IF stdt_input-sdlstrttm IS INITIAL.
        IF stdt_input-sdlstrtdt NE no_date AND
           NOT ( stdt_input-sdlstrtdt IS INITIAL ).
          btch1010-sdlstrttm = stdt_input-sdlstrttm.
        ELSE.
          btch1010-sdlstrttm = no_time.
        ENDIF.
      ELSE.
        btch1010-sdlstrttm = stdt_input-sdlstrttm.
      ENDIF.
    ENDIF.

    IF stdt_input-laststrtdt NE no_date AND
       NOT ( stdt_input-laststrtdt IS INITIAL ).
      btch1010-laststrtdt = stdt_input-laststrtdt.
    ELSE.
      btch1010-laststrtdt = no_date.
    ENDIF.

    IF stdt_input-laststrttm EQ no_time.
      btch1010-laststrttm = no_time.
    ELSE.
      IF stdt_input-laststrttm IS INITIAL.
        IF stdt_input-laststrtdt NE no_date AND
           NOT ( stdt_input-laststrtdt IS INITIAL ).
          btch1010-laststrttm = stdt_input-laststrttm.
        ELSE.
          btch1010-laststrttm = no_time.
        ENDIF.
      ELSE.
        btch1010-laststrttm = stdt_input-laststrttm.
      ENDIF.
    ENDIF.
  ELSEIF stdt_typ EQ btc_stdt_afterjob.
*
*     Starttermintyp = 'nach Job'
*
    IF NOT ( stdt_input-predjob IS INITIAL ).
      btch1010-predjob = stdt_input-predjob.
    ENDIF.

    IF NOT ( stdt_input-predjobcnt IS INITIAL ).
      btch1010-predjobcnt = stdt_input-predjobcnt.
    ENDIF.

    IF NOT ( stdt_input-checkstat IS INITIAL ).
      btch1010-checkstat = stdt_input-checkstat.
    ENDIF.
  ELSEIF stdt_typ EQ btc_stdt_event.
*
*     Starttermintyp = 'nach Event' / 'bei Betriebsart'
*
    stdt_oms_is_active = false.

    IF NOT ( stdt_input-eventid IS INITIAL ).
      btch1010-eventid = stdt_input-eventid.
      IF stdt_input-eventid EQ oms_eventid.
        btch1010-opmode    = stdt_input-eventparm.
        stdt_oms_is_active = true.
      ENDIF.
    ENDIF.

    IF NOT ( stdt_input-eventparm IS INITIAL ).
      btch1010-eventparm = stdt_input-eventparm.
    ENDIF.
  ENDIF.
*
*  prüfen, ob 'periodisch' gesetzt ist
*
  IF stdt_input-periodic EQ 'X'.
    btch1010-periodic = 'X'.
  ELSE.
    btch1010-periodic = space.
  ENDIF.

** C5035006 note 561575
  btch1260-calendarid = stdt_input-calendarid.

ENDFORM. " FILL_1010_STDT_DATA.

*---------------------------------------------------------------------*
*       FORM SET_CHOICE_1060                                          *
*---------------------------------------------------------------------*
* Entsprechend der vom Anwender ausgewählten Periodenart, wird das    *
* zugehörige Auswahlfeld auf Dynpro 1060 gedrückt                     *
*---------------------------------------------------------------------*
FORM set_choice_1060 USING choice.

  CLEAR btch1060-prd_hourly.
  CLEAR btch1060-prd_daily.
  CLEAR btch1060-prd_weekly.
  CLEAR btch1060-prd_mnthly.
  CLEAR btch1060-prd_explic.

  CASE choice.
    WHEN hourly_period.
      btch1060-prd_hourly = 'X'.
    WHEN daily_period.
      btch1060-prd_daily  = 'X'.
    WHEN weekly_period.
      btch1060-prd_weekly = 'X'.
    WHEN monthly_period.
      btch1060-prd_mnthly = 'X'.
    WHEN OTHERS.
      btch1060-prd_explic = 'X'.
  ENDCASE.

ENDFORM.                    "SET_CHOICE_1060
*---------------------------------------------------------------------*
*       FORM FILL_1060_PERIOD_DATA                                    *
*---------------------------------------------------------------------*
* Entsprechend der Werte in der Hilfsstruktur STDT_INPUT werden
* die Felder des Dynpros 1060 gefüllt.                                *
*---------------------------------------------------------------------*
FORM fill_1060_period_data.
  CLEAR btch1060.
*
*    prüfe, ob eine zeitabhängige Periodenangabe vorliegt
*
  sum = stdt_input-prdmins  +
        stdt_input-prdhours +
        stdt_input-prddays  +
        stdt_input-prdweeks +
        stdt_input-prdmonths.

  IF ( sum > 1                      ) OR
     ( sum EQ 1 AND
       stdt_input-prdmins EQ 1 ).
*
*    es liegt eine explizite Periodenangabe vor: Felder für explizite
*    Periodenwerteingaben füllen.
*
    btch1060-prd_explic = 'X'.
    btch1060-prd_mins   = stdt_input-prdmins.
    btch1060-prd_hours  = stdt_input-prdhours.
    btch1060-prd_days   = stdt_input-prddays.
    btch1060-prd_weeks  = stdt_input-prdweeks.
    btch1060-prd_months = stdt_input-prdmonths.
  ELSE.
*
*    es liegt evtl. eine stündliche, tägliche, woechentliche oder
*    monatliche Periodenangabe vor.
*
    IF stdt_input-prdhours NE 0.
      btch1060-prd_hourly = 'X'.
    ENDIF.

    IF stdt_input-prddays NE 0.
      btch1060-prd_daily = 'X'.
    ENDIF.

    IF stdt_input-prdweeks NE 0.
      btch1060-prd_weekly = 'X'.
    ENDIF.

    IF stdt_input-prdmonths NE 0.
      btch1060-prd_mnthly = 'X'.
    ENDIF.

  ENDIF.

ENDFORM.  " FILL_1060_PERIOD_DATA.

*---------------------------------------------------------------------*
*   FORM SAVE_1060_PERIOD_DATA                                        *
*---------------------------------------------------------------------*
* Periodendaten auf Dynpro 1060 prufen und in die Startterminstruktur *
* vom Typ TBTCSTRT "schieben"                                         *
*---------------------------------------------------------------------*

FORM save_1060_period_data.

  IF btch1060-prd_explic EQ 'X'.
    stdt_input-prdmins   = btch1060-prd_mins.
    stdt_input-prdhours  = btch1060-prd_hours.
    stdt_input-prddays   = btch1060-prd_days.
    stdt_input-prdweeks  = btch1060-prd_weeks.
    stdt_input-prdmonths = btch1060-prd_months.
  ELSE.
    stdt_input-prdmins   = 0.  " Zeitwerte initialisieren
    stdt_input-prdhours  = 0.
    stdt_input-prddays   = 0.
    stdt_input-prdweeks  = 0.
    stdt_input-prdmonths = 0.

    IF btch1060-prd_hourly EQ 'X'.    " untersuchen, welche
      stdt_input-prdhours = 1.   " Periode gewünscht wird
    ELSEIF btch1060-prd_daily EQ 'X'. " und speichern
      stdt_input-prddays  = 1.
    ELSEIF btch1060-prd_weekly EQ 'X'.
      stdt_input-prdweeks = 1.
    ELSEIF btch1060-prd_mnthly EQ 'X'.
      stdt_input-prdmonths = 1.
    ENDIF.

    sum = stdt_input-prdmins  +
          stdt_input-prdhours +
          stdt_input-prddays  +
          stdt_input-prdweeks +
          stdt_input-prdmonths.

    IF sum EQ 0.
      MESSAGE e033.
    ENDIF.
  ENDIF.

ENDFORM. " SAVE_1060_PERIOD_DATA.

*---------------------------------------------------------------------*
*   FORM CHECK_OPMODENAME                                             *
*---------------------------------------------------------------------*
* Prüft einen Betriebsartennamen auf Gültigkeit                       *
*---------------------------------------------------------------------*
FORM check_opmodename USING opmodename rc.

  DATA BEGIN OF p_inst_descr OCCURS 10.
          INCLUDE STRUCTURE spfid.
  DATA END OF p_inst_descr.

  DATA BEGIN OF p_ba_descr OCCURS 10.
          INCLUDE STRUCTURE spfba.
  DATA END OF p_ba_descr.

  DATA: p_ba TYPE spfba.
  DATA: opmode_is_valid LIKE true.

  CALL FUNCTION 'RZL_GET_BA_LIST'       " Beschreibung der definierten
       TABLES     ba_tbl = p_ba_descr     " Betriebsarten lesen
                  id_tbl = p_inst_descr
       EXCEPTIONS OTHERS = 99.

  opmode_is_valid = false.

  LOOP AT p_ba_descr INTO p_ba.
    IF p_ba-baname EQ opmodename.
      opmode_is_valid = true.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF opmode_is_valid EQ true.
    rc = 0.
  ELSE.
    rc = 1.
  ENDIF.

ENDFORM. " CHECK_OPMODENAME

*---------------------------------------------------------------------*
*   FORM FILL_1260_PRDBEHAVIOUR_DATA.                                 *
*---------------------------------------------------------------------*
* Dynpro 1260 mit Periodenverhalten und KalenderId füllen ( aus       *
* Arbeitsbereich STDT_INPUT)                                          *
*---------------------------------------------------------------------*
FORM fill_1260_prdbehaviour_data.

  CLEAR btch1260.

  CASE stdt_input-prdbehav.
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

  btch1260-calendarid = stdt_input-calendarid.

ENDFORM. " FILL_1260_PRDBEHAVIOUR_DATA

*---------------------------------------------------------------------*
*   FORM SAVE_1260_PRDBEHAVIOUR_DATA.                                 *
*---------------------------------------------------------------------*
* Periodenverhalten und KalenderId von Dynpro 1260 in den Arbeits-    *
* bereich STDT_INPUT sichern                                          *
*---------------------------------------------------------------------*
FORM save_1260_prdbehaviour_data.

  DATA: rc TYPE i.

  IF btch1260-with_limit EQ 'X'.
    IF btch1260-always EQ 'X'.
      MESSAGE e636.
*       stdt_input-prdbehav = btc_process_always.
    ELSEIF btch1260-notonholid EQ 'X'.
      stdt_input-prdbehav = btc_dont_process_on_holiday.
    ELSEIF btch1260-before EQ 'X'.
      stdt_input-prdbehav = btc_process_before_holiday.
    ELSEIF btch1260-after EQ 'X'.
      stdt_input-prdbehav = btc_process_after_holiday.
    ENDIF.
  ELSE.
    IF btch1260-notonholid EQ 'X' OR   " Verhalten ohne Einschränkung =
       btch1260-before     EQ 'X' OR   " 'ja' macht keinen Sinn
       btch1260-after      EQ 'X' .
      MESSAGE e265.
    ELSE.
      stdt_input-prdbehav = btc_process_always.
    ENDIF.
  ENDIF.

  IF btch1260-calendarid EQ space.
    IF btch1260-with_limit EQ 'X'.
*       es sind Einschraenkungen gewuenscht, aber kein Fabrikkalender
*       wurde angegeben
      MESSAGE e258.
    ELSE.
*       keine Einschraenkungen angegeben
      stdt_input-prdbehav   = btc_process_always.
      stdt_input-calendarid = space.
    ENDIF.
  ELSE.
    PERFORM check_calendar_id USING btch1260-calendarid rc.
    IF rc EQ 0.
      stdt_input-calendarid = btch1260-calendarid.
    ELSE.
      MESSAGE e259 WITH btch1260-calendarid.
    ENDIF.
  ENDIF.

ENDFORM. " SAVE_1260_PRDBEHAVIOUR_DATA

*---------------------------------------------------------------------*
*   FORM SHOW_PRDBHV                                                  *
*---------------------------------------------------------------------*
* Eingabebereitschaft aller Eingabefelder auf Dynpro 1260 (Perioden-  *
* verhalten) wegnehmen                                                *
*---------------------------------------------------------------------*

FORM show_prdbhv.

  PERFORM set_screen_grp_attribut USING 'DAT' space space space
                                              input off.
  PERFORM set_screen_grp_attribut USING space space space space
                                              input off.

ENDFORM. " SHOW_PRDBHV

*---------------------------------------------------------------------*
*   FORM GET_DEFAULT_CALENDAR_ID                                      *
*---------------------------------------------------------------------*
* Ermitteln der Default-KalenderId aus dem Basis-Customizing          *
*---------------------------------------------------------------------*
* FORM GET_DEFAULT_CALENDAR_ID USING CALENDAR_ID.
*
*  CALENDAR_ID = '01'.
*
*ENDFORM. " GET_DEFAULT_CALENDAR_ID

*---------------------------------------------------------------------*
*   FORM CHECK_CALENDAR_ID                                            *
*---------------------------------------------------------------------*
* Prüfen, ob die angegebenen Kalender-ID gültig ist                   *
* Die Prüfung erfolgt mittels des Fabrikkalenderbausteins             *
* DATE_CONCVERT_TO_FACTORYDATE. Falls die Kalender-ID ungülig ist,    *
* wird RC != 0 gesetzt.                                               *
*---------------------------------------------------------------------*
FORM check_calendar_id USING calendar_id rc.

  GET TIME.

  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                       = sy-datum
      factory_calendar_id        = calendar_id
    EXCEPTIONS
      factory_calendar_not_found = 1
      OTHERS                     = 99.

  IF sy-subrc EQ 1.
    rc = 1.
  ELSE.
    rc = 0.
  ENDIF.

ENDFORM. " CHECK_CALENDAR_ID

*---------------------------------------------------------------------*
*   FORM CHECK_HOLIDAY_REACTION                                       *
*---------------------------------------------------------------------*
* Für ein gegebenes Datum, abhängig von der Kalender-ID und der vom   *
* Benutzer gewünschten Reaktion auf einen Feiertag, das ( evtl. neue )*
* Ausführungsdatum eines Jobs ermitteln                               *
*                                                                     *
* Diese Routine arbeitet auf der Struktur BTCH1010 (Startdatum) und   *
* STDT_INPUT (Fabrikkalender-Id und Periodenverhalten)                *
*---------------------------------------------------------------------*
FORM check_holiday_reaction.

  DATA: date_correct_option  LIKE scal-indicator,
        workingday_indicator LIKE scal-indicator,
        rc TYPE i,
        period_in_mins TYPE p,
        a_week_in_mins TYPE p,
        date_to_check_txt(10),
        new_exec_date        LIKE sy-datum.
*
* KalenderId prüfen (falls angegeben)
*
  IF stdt_input-calendarid NE space.
    PERFORM check_calendar_id USING stdt_input-calendarid rc.
    IF rc NE 0.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e259 WITH stdt_input-calendarid.
      ELSE.
        PERFORM raise_stdt_exception USING
                fcal_id_not_defined_id stdt_input-calendarid.
      ENDIF.
    ENDIF.
  ENDIF.
*
* - Fabrikkalenderkorrekturtage initialisieren
* - falls es keine Einschränkungen gibt: Ausführungsdatum = zu prüfendes
*   Datum (nichts an STDT_INPUT-SDLSTRTDT ändern)
*
  IF stdt_input-prdbehav EQ btc_process_always.
    stdt_input-calcorrect = 0.
    EXIT.
  ENDIF.
*
* falls Periode angegeben wurde gilt: Einschränkung 'Vorziehen'
* ist nur gültig bei Periodenwerten >= 1 Woche um zu verhindern das
* Starttermine in die Vergangenheit gelegt werden
*
  IF stdt_input-prdbehav  EQ btc_process_before_holiday
     AND
     stdt_input-periodic  EQ 'X'
     AND
     stdt_input-prdweeks  EQ 0
     AND
     stdt_input-prdmonths EQ 0.
    a_week_in_mins = 7 * 24 * 60.

    period_in_mins =   stdt_input-prdmins +
                     ( stdt_input-prdhours * 60 ) +
                     ( stdt_input-prddays * 24 * 60 ).

    IF period_in_mins < a_week_in_mins.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e267.
      ELSE.
        PERFORM raise_stdt_exception USING
                period_too_small_for_limit_id space.
      ENDIF.
    ENDIF.
  ENDIF.
*
* bei Starttermin = 'Sofort' das heutige Datum ermitteln
*
  IF stdt_typ EQ btc_stdt_immediate.
    GET TIME.
    btch1010-sdlstrtdt = sy-datum.
    btch1010-sdlstrttm = sy-uzeit.
  ENDIF.

  WRITE btch1010-sdlstrtdt TO date_to_check_txt. " für evtl. Syslogs
*
* ermitteln, ob Ausführungsdatum ein Nichtarbeitstag ist. Wenn ja, dann
* abhängig von HOLIDAY_REACTION neues Ausführungsdatum berechnen
*
  CASE stdt_input-prdbehav.
    WHEN btc_dont_process_on_holiday.
      date_correct_option = '+'.
    WHEN btc_process_before_holiday.
      date_correct_option = '-'.
    WHEN btc_process_after_holiday.
      date_correct_option = '+'.
    WHEN btc_process_always.
      date_correct_option = '+'.
    WHEN OTHERS. " kann nur im Nichtdialogfall vorkommen
      PERFORM raise_stdt_exception USING
              invalid_periodbehaviour_id stdt_input-prdbehav.
  ENDCASE.

  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                       = btch1010-sdlstrtdt
      correct_option             = date_correct_option
      factory_calendar_id        = stdt_input-calendarid
    IMPORTING
      date                       = new_exec_date
      workingday_indicator       = workingday_indicator
    EXCEPTIONS
      date_after_range           = 1
      date_before_range          = 1
      factory_calendar_not_found = 2
      OTHERS                     = 99.

  CASE sy-subrc.
    WHEN 0.
      " Überprüfen bzw. Berechnen des neuen Startdatums ok
    WHEN 1.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e260 WITH btch1010-sdlstrtdt.
      ELSE.
        PERFORM raise_stdt_exception USING
                startdate_out_of_fcal_range_id date_to_check_txt.
      ENDIF.
    WHEN 2.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e259 WITH stdt_input-calendarid.
      ELSE.
        PERFORM raise_stdt_exception USING
                fcal_id_not_defined_id stdt_input-calendarid.
      ENDIF.
    WHEN OTHERS.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e261.
      ELSE.
        PERFORM raise_stdt_exception USING
                unknown_fcal_error_occured_id stdt_input-calendarid.
      ENDIF.
  ENDCASE.
*
* falls zu prüfendes Datum kein Arbeitstag ist:
* - falls Einschränkung = nicht an Feiertag prozessieren -> Fehler
* - falls Einschränkung = vor einem Feiertag prozessieren und
*   letzter Arbeitstag vor dem Feiertag liegt in der Vergangenheit ->
*   Fehler
* - Fabrikkalenderkorrektur berechnen (CALCORRECT-Wert)
*
  IF workingday_indicator EQ space.
    stdt_input-calcorrect = 0.
  ELSE.
    IF stdt_input-prdbehav EQ btc_dont_process_on_holiday.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e262 WITH btch1010-sdlstrtdt.
      ELSE.
        PERFORM raise_stdt_exception USING
                startdate_is_a_holiday_id date_to_check_txt.
      ENDIF.
    ENDIF.
    IF stdt_input-prdbehav EQ btc_process_before_holiday.
      GET TIME.
      IF new_exec_date < sy-datum.
        IF stdt_dialog EQ btc_yes.
          MESSAGE e263 WITH btch1010-sdlstrtdt.
        ELSE.
          PERFORM raise_stdt_exception USING
                  stdt_before_holiday_in_past_id date_to_check_txt.
        ENDIF.
      ENDIF.
    ENDIF.

    stdt_input-calcorrect = new_exec_date - btch1010-sdlstrtdt.

    IF stdt_dialog EQ btc_yes.
      MESSAGE i264 WITH btch1010-sdlstrtdt new_exec_date.
    ENDIF.
  ENDIF.
*
* (neues) Ausführungsdatum in Dynpro 1010 einstreuen
*
  btch1010-sdlstrtdt = new_exec_date.

ENDFORM. " CHECK_HOLIDAY_REACTION

*---------------------------------------------------------------------*
*   FORM FILL_1011_STDT_DATA                                          *
*---------------------------------------------------------------------*
* Starttermindaten 'an Arbeitstag' in das Dynpro 1011 "schieben"      *
*---------------------------------------------------------------------*
FORM fill_1011_stdt_data.

  CLEAR btch1011.

  btch1011-wdayno     = stdt_input-wdayno.
  btch1011-calendarid = stdt_input-calendarid.
  btch1011-sdlstrttm  = stdt_input-sdlstrttm.
  btch1011-prdmonths  = stdt_input-prdmonths.
  btch1011-notbefore  = stdt_input-notbefore.

  IF stdt_dialog EQ btc_yes
     AND
     (
       stdt_input-notbefore IS INITIAL
       OR
       stdt_input-notbefore EQ no_date
     ).
    GET TIME.
    btch1011-notbefore = sy-datum.
  ENDIF.

  IF stdt_input-wdaycdir   EQ btc_beginning_of_month OR
     stdt_input-startdttyp EQ space.
    btch1011-bofmonth = 'X'.
  ELSEIF stdt_input-wdaycdir EQ btc_end_of_month.
    btch1011-eofmonth = 'X'.
  ENDIF.

ENDFORM. " FILL_1011_STDT_DATA

*---------------------------------------------------------------------*
*   CHECK_INPUT_1011                                                  *
*---------------------------------------------------------------------*
* Starttermindaten 'an Arbeitstag' auf Dynpro 1011 verproben.         *
*---------------------------------------------------------------------*
FORM check_input_1011.

  DATA: rc TYPE i,
        syslog_txt(3).

*  IF STDT_TYP EQ BTC_STDT_ONWORKDAY.
  PERFORM check_calendar_id USING btch1011-calendarid rc.

  IF rc NE 0.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e259 WITH btch1011-calendarid.
    ELSE.
      PERFORM raise_stdt_exception USING fcal_id_not_defined_id
                                         btch1011-calendarid.
    ENDIF.
  ENDIF.

  IF btch1011-wdayno IS INITIAL.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e286.
    ELSE.
      PERFORM raise_stdt_exception USING no_workday_nr_given_id
                                         space.
    ENDIF.
  ENDIF.

  IF btch1011-wdayno < 1 OR
     btch1011-wdayno > 31.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e287.
    ELSE.
      syslog_txt = btch1011-wdayno.
      PERFORM raise_stdt_exception USING invalid_workday_nr_id
                                         syslog_txt.
    ENDIF.
  ENDIF.

  IF btch1011-sdlstrttm EQ no_time.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e289.
    ELSE.
      PERFORM raise_stdt_exception USING
                                   workday_starttime_missing_id
                                   space.
    ENDIF.
  ENDIF.

  IF btch1011-bofmonth EQ space AND  " kann nur im Nichtdialogfall
     btch1011-eofmonth EQ space.     " vorkommen
    PERFORM raise_stdt_exception USING invalid_workday_countdir_id
                                       space.
  ENDIF.

  IF btch1011-notbefore IS INITIAL OR
     btch1011-notbefore EQ no_date.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e288.
    ELSE.
      PERFORM raise_stdt_exception USING
                                   notbefore_stdt_missing_id
                                   space.
    ENDIF.
  ENDIF.
*  ELSE. " keine Startterminangabe vorhanden
*     IF STDT_DIALOG EQ BTC_YES.
*        MESSAGE E001.
*     ELSE.
*        RAISE NO_STARTDATE_GIVEN. " kein Syslog hier !
*     ENDIF.
*  ENDIF.

ENDFORM. " CHECK_INPUT_1011.

*---------------------------------------------------------------------*
*   SAVE_1011_STDT_DATA                                               *
*---------------------------------------------------------------------*
* Starttermindaten 'an Arbeitstag' von Dynpro 1011 in Struktur        *
* STDT_INPUT "schieben".                                              *
*---------------------------------------------------------------------*
FORM save_1011_stdt_data.

  FIELD-SYMBOLS: <f>.

  DATA: month             TYPE i,
        year              TYPE i,
        dont_start_before_date LIKE btch1011-notbefore.

  CLEAR stdt_input.

  stdt_input-calendarid = btch1011-calendarid.
  stdt_input-sdlstrttm  = btch1011-sdlstrttm.
  stdt_input-wdayno     = btch1011-wdayno.
  stdt_input-prdmonths  = btch1011-prdmonths.
  stdt_input-notbefore  = btch1011-notbefore.

  IF NOT ( stdt_input-prdmonths IS INITIAL ).
    stdt_input-periodic = 'X'.
  ENDIF.

  IF btch1011-bofmonth EQ 'X'.
    stdt_input-wdaycdir = btc_beginning_of_month.
  ELSE.
    stdt_input-wdaycdir = btc_end_of_month.
  ENDIF.
*
* falls das 'Starte nicht bevor Datum' in der Vergangenheit liegt,
* dann ist das früheste Startdatum heute bzw. morgen. Monat und Jahr
* des 'Starte nicht bevor Datums' ermitteln.
*
  dont_start_before_date = btch1011-notbefore.

  GET TIME.

  IF dont_start_before_date < sy-datum.
    dont_start_before_date = sy-datum.
  ENDIF.

  IF dont_start_before_date EQ sy-datum AND
     btch1011-sdlstrttm <  sy-uzeit.
    dont_start_before_date = dont_start_before_date + 1.
  ENDIF.

  ASSIGN dont_start_before_date+4(2) TO <f>.
  month = <f>.
  ASSIGN dont_start_before_date+0(4) TO <f>.
  year = <f>.
*
* Datum des gewünschten Arbeitstages im Monat des 'Starte nicht bevor
* Datums' berechnen. Falls das Datum in der Vergangenheit liegt, dann
* den gewünschten Arbeitstag des darauffolgenden Monats berechnen
*
  PERFORM calculate_workday_date USING month
                                       year
                                       stdt_input-wdayno
                                       stdt_input-wdaycdir
                                       stdt_input-calendarid
                                       stdt_input-sdlstrtdt.

  IF stdt_input-sdlstrtdt < dont_start_before_date
     OR
     (
       stdt_input-sdlstrtdt EQ sy-datum
       AND
       btch1011-sdlstrttm < sy-uzeit
     ).
    IF month < 12.
      month = month + 1.
    ELSE.
      month = 1.
      year  = year + 1.
    ENDIF.

    PERFORM calculate_workday_date USING month
                                         year
                                         stdt_input-wdayno
                                         stdt_input-wdaycdir
                                         stdt_input-calendarid
                                         stdt_input-sdlstrtdt.
  ENDIF.

ENDFORM. " SAVE_1011_STDT_DATA.

*---------------------------------------------------------------------*
*   CALCULATE_WORKDAY_DATE                                            *
*---------------------------------------------------------------------*
* Berechne das Datum eines n-ten Arbeitstages ( relativ zum Monats-   *
* anfang- bzw. ende ) für einen bestimmten Monat eines bestimmten     *
* Jahres. Diese Routine geht davon aus, daß die Eingangsparameter     *
* bereits auf Sinnfälligkeit verprobt wurden.                         *
*---------------------------------------------------------------------*
FORM calculate_workday_date USING month
                                  year
                                  requested_workday_nr
                                  workday_count_direction
                                  calendarid
                                  date_to_be_calculated.

  DATA: date_correct_option         LIKE scal-indicator,
        factorydate                 LIKE scal-facdate,
        num_of_days_in_month        TYPE i,
        date_to_calculate_txt(10).

  FIELD-SYMBOLS: <f>.
*
* Datum des ersten bzw. lezten Tags des Monats ermitteln in dem der
* Job erstmalig zur Ausführung kommen kann
*
  ASSIGN date_to_be_calculated+4(2) TO <f>.
  <f> = month.
  ASSIGN date_to_be_calculated+0(4) TO <f>.
  <f> = year.
  ASSIGN date_to_be_calculated+6(2) TO <f>.

  IF workday_count_direction EQ btc_beginning_of_month.
    <f> = '01'.
    date_correct_option = '+'.
  ELSE.
    PERFORM days_per_month USING month year num_of_days_in_month.
    <f> = num_of_days_in_month.
    date_correct_option = '-'.
  ENDIF.

  WRITE date_to_be_calculated TO date_to_calculate_txt.
*
* Nr. bzw. Datum des ersten bzw. letzten Arbeitstag des Monats
* berechnen
*
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                       = date_to_be_calculated
      correct_option             = date_correct_option
      factory_calendar_id        = calendarid
    IMPORTING
      factorydate                = factorydate
    EXCEPTIONS
      date_after_range           = 1
      date_before_range          = 1
      factory_calendar_not_found = 2
      OTHERS                     = 99.

  CASE sy-subrc.
    WHEN 0.
      " ok
    WHEN 1.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e260 WITH date_to_be_calculated.
      ELSE.
        PERFORM raise_stdt_exception USING
                startdate_out_of_fcal_range_id date_to_calculate_txt.
      ENDIF.
    WHEN 2.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e259 WITH calendarid.
      ELSE.
        PERFORM raise_stdt_exception USING
                fcal_id_not_defined_id calendarid.
      ENDIF.
    WHEN OTHERS.
      IF stdt_dialog EQ btc_yes.
        MESSAGE e261.
      ELSE.
        PERFORM raise_stdt_exception USING
                unknown_fcal_error_occured_id calendarid.
      ENDIF.
  ENDCASE.
*
* Datum des gewünschten Arbeitstages mit Hilfe des Fabrikkalendertages
* im Monat berechnen
*
  IF workday_count_direction EQ btc_beginning_of_month.
    factorydate = factorydate + requested_workday_nr - 1.
  ELSE.
    factorydate = factorydate - requested_workday_nr + 1.
  ENDIF.

  CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
    EXPORTING
      factorydate         = factorydate
      factory_calendar_id = calendarid
    IMPORTING
      date                = date_to_be_calculated
    EXCEPTIONS
      OTHERS              = 99.

  IF sy-subrc NE 0.
    IF stdt_dialog EQ btc_yes.
      MESSAGE e261.
    ELSE.
      PERFORM raise_stdt_exception USING
              unknown_fcal_error_occured_id calendarid.
    ENDIF.
  ENDIF.

ENDFORM. " CALCULATE_WORKDAY_DATE

*---------------------------------------------------------------------*
*   FORM DAYS_PER_MONTH                                               *
*---------------------------------------------------------------------*
* Diese Funktion berechnet die Anzahl der Tage, die ein vorgegebener  *
* Kalendermonat besitzt. Schaltjahre werden dabei beruecksichtigt.    *
* (übenommen von SAPMSSY2 - Michael Schuster)                         *
*---------------------------------------------------------------------*
FORM days_per_month USING month year num_days.

  DATA:
    daytab(26) VALUE '00312831303130313130313031'.

  DATA:
    i1 TYPE i,
    i2 TYPE i,
    i3 TYPE i.

  FIELD-SYMBOLS <daytab>.

  offset = 2 * month.
  ASSIGN daytab+offset(2) TO <daytab>.
  num_days = <daytab>.

  IF month EQ 2.
*     die Schaltjahrberechnung ist nur fuer den Monat Februar
*     erforderlich

*     Kriterium fuer Schaltjahr
*     - Jahreszahl durch 4 teilbar
*     und
*     - Jahreszahl nicht durch 100 teilbar
*       oder
*       Jahreszahl durch 400 teilbar
    i1 = year MOD 4.
    i2 = year MOD 100.
    i3 = year MOD 400.
    IF i1 EQ 0 AND ( i2 <> 0 OR i3 EQ 0 ).
      num_days = num_days + 1.
    ENDIF.
  ENDIF.

ENDFORM.  " DAYS_PER_MONTH

*---------------------------------------------------------------------*
*       FORM ADMIT_STDT_WDAY_INPUT                                    *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1011 die Felder für Starttermin        *
* 'an Arbeitstag' eingabebereit sind.                                 *
*---------------------------------------------------------------------*
FORM admit_stdt_wday_input.

  PERFORM set_screen_grp_attribut USING 'DAT' 'WDY' space space
                                        input on.

ENDFORM. " ADMIT_STDT_WDAY_INPUT

*---------------------------------------------------------------------*
*       FORM SHOW_STDT_WDAY                                           *
*---------------------------------------------------------------------*
* Dafür sorgen, daß auf Dynpro 1011 die Felder für Starttermin        *
* 'an Arbeitstag' nicht eingabebereit sind                            *
*---------------------------------------------------------------------*
FORM show_stdt_wday.

  PERFORM set_screen_grp_attribut USING 'DAT' 'WDY' space space
                                        input off.

ENDFORM. " SHOW_STDT_WDAY.

*---------------------------------------------------------------------*
*       FORM VERIFY_1010_EDITOR_ABORT                                 *
*---------------------------------------------------------------------*
* Prüfen, ob beim Verlassen des Dynpros 1010 Daten verloren gehen     *
* und ggfs. Abbruch vom Benutzer bestätigen lassen                    *
*---------------------------------------------------------------------*
FORM verify_1010_editor_abort.

  DATA: answer LIKE true.

  IF sy-datar EQ 'X'.             " falls unmittelbar vor Drücken PF12
    startdate_modified = true.   " noch Daten veränder wurden
  ENDIF.

*  IF STARTDATE_MODIFIED            EQ TRUE OR
*     PERIOD_DATA_MODIFIED          EQ TRUE OR
*     EXPLICIT_PERIOD_DATA_MODIFIED EQ TRUE OR
*     PERIOD_BEHAVIOUR_MODIFIED     EQ TRUE.
**
**    es wurden Starttermindaten eingegeben bzw. verändert -> Sicher-
**    heitsabfrage an den Benutzer schicken
**
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING DEFAULTOPTION = 'N'
*                    TEXTLINE1     = TEXT-132
*                    TEXTLINE2     = TEXT-133
*                    TITEL         = TEXT-134
*          IMPORTING ANSWER        = POPUP_ANSWER
*          EXCEPTIONS OTHERS       = 99.
*
*     IF SY-SUBRC EQ 0.
*        IF POPUP_ANSWER EQ 'J'.
*           ANSWER                        = TRUE.
*           STARTDATE_MODIFIED            = FALSE.
*           PERIOD_DATA_MODIFIED          = FALSE.
*           EXPLICIT_PERIOD_DATA_MODIFIED = FALSE.
*           PERIOD_BEHAVIOUR_MODIFIED     = FALSE.
*        ELSE.
*           ANSWER = FALSE.
*        ENDIF.
*     ELSE.
*        MESSAGE E106.
*     ENDIF.
*  ELSE.
*     ANSWER = TRUE.
*  ENDIF.

  answer = true.

  IF answer EQ true.
    CASE okcode.
      WHEN 'MOR1'.
        IF btch1011 IS INITIAL.
          GET TIME.
          btch1011-bofmonth  = 'X'.
          btch1011-notbefore = sy-datum.
        ENDIF.
        SET SCREEN 1011.
        LEAVE SCREEN.
      WHEN 'CAN'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'ECAN'.
        SET SCREEN 0.
        LEAVE SCREEN.
    ENDCASE.
  ELSE.
    LEAVE SCREEN.
  ENDIF.

ENDFORM. " VERIFY_1010_EDITOR_ABORT

*---------------------------------------------------------------------*
*       FORM VERIFY_1011_EDITOR_ABORT                                 *
*---------------------------------------------------------------------*
* Prüfen, ob beim Verlassen des Dynpros 1011 Daten verloren gehen     *
* und ggfs. Abbruch vom Benutzer bestätigen lassen                    *
*---------------------------------------------------------------------*
FORM verify_1011_editor_abort.

  DATA: answer LIKE true.

  IF sy-datar EQ 'X'.
    startdate_modified = true.
  ENDIF.

*  IF STARTDATE_MODIFIED EQ TRUE.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING DEFAULTOPTION = 'N'
*                    TEXTLINE1     = TEXT-132
*                    TEXTLINE2     = TEXT-133
*                    TITEL         = TEXT-134
*          IMPORTING ANSWER        = POPUP_ANSWER
*          EXCEPTIONS OTHERS       = 99.
*
*     IF SY-SUBRC EQ 0.
*        IF POPUP_ANSWER EQ 'J'.
*           ANSWER             = TRUE.
*           STARTDATE_MODIFIED = FALSE.
*        ELSE.
*           ANSWER = FALSE.
*        ENDIF.
*     ELSE.
*        MESSAGE E106.
*     ENDIF.
*  ELSE.
*     ANSWER = TRUE.
*  ENDIF.

  answer = true.

  IF answer EQ true.
    CASE okcode.
      WHEN 'MOR2'.
        SET SCREEN 1010.
        LEAVE SCREEN.
      WHEN 'CAN'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'ECAN'.
        SET SCREEN 0.
        LEAVE SCREEN.
    ENDCASE.
  ELSE.
    LEAVE SCREEN.
  ENDIF.

ENDFORM. " VERIFY_1011_EDITOR_ABORT.

*---------------------------------------------------------------------*
*      FORM RAISE_STDT_EXCEPTION                                      *
*---------------------------------------------------------------------*
* Ausloesen einer Exception und Schreiben eines Syslogeintrages falls *
* der Funktionsbaustein BP_START_DATE_EDITOR im Nichtdialogfall un-   *
* gueltige Starttermindaten entdeckt.                                 *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM raise_stdt_exception USING exception data.

data: job_data type btcjobinfo.

*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD invalid_startdate_detected.

  IF btch1140-jobname IS NOT INITIAL.
    CONCATENATE btch1140-jobname '&' btch1140-jobcount INTO job_data.

    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
    ID 'KEY'  FIELD 'EKD'
    ID 'DATA' FIELD job_data.

  ENDIF.
*
* exceptionspezifischen Eintrag schreiben und Exception ausloesen
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD exception
       ID 'DATA' FIELD data.

  CASE exception.
    WHEN no_startdate_given.
      MESSAGE E001 RAISING no_startdate_given.
    WHEN no_period_data_given.
      MESSAGE E033 RAISING no_period_data_given.
    WHEN invalid_predecessor_jobname.
      MESSAGE E003 RAISING invalid_predecessor_jobname.
    WHEN predjob_wrong_status.
      MESSAGE E004 WITH data RAISING predjob_wrong_status.
    WHEN predjob_doesnt_exist.
      MESSAGE E118 WITH data RAISING predjob_doesnt_exist.
    WHEN predecessor_jobname_not_unique.
      MESSAGE E385 RAISING predecessor_jobname_not_unique.
    WHEN incomplete_startdate.
      MESSAGE E005 RAISING incomplete_startdate.
    WHEN startdate_in_the_past.
      MESSAGE E006 RAISING startdate_in_the_past.
    WHEN incomplete_last_startdate.
      MESSAGE E007 RAISING incomplete_last_startdate.
    WHEN last_startdate_in_the_past.
      MESSAGE E386 RAISING last_startdate_in_the_past.
    WHEN startdate_interval_too_large.
      MESSAGE E009 RAISING startdate_interval_too_large.
    WHEN invalid_eventid.
      MESSAGE E042 WITH data RAISING invalid_eventid.
    WHEN period_and_predjob_no_way.
      MESSAGE E031 RAISING period_and_predjob_no_way.
    WHEN invalid_dialog_type.
      MESSAGE E536 RAISING invalid_dialog_type.
    WHEN invalid_opcode.
      MESSAGE E536 RAISING invalid_opcode.
    WHEN invalid_opmode_name.
      MESSAGE e203 WITH data RAISING invalid_opmode_name.
    WHEN startdate_out_of_fcal_range_id.
      MESSAGE e260 WITH data RAISING startdate_out_of_fcal_range.
    WHEN fcal_id_not_defined_id.
      MESSAGE e259 WITH data RAISING fcal_id_not_defined.
    WHEN unknown_fcal_error_occured_id.
      MESSAGE e261 RAISING unknown_fcal_error_occured.
    WHEN startdate_is_a_holiday_id.
      MESSAGE e262 WITH data RAISING startdate_is_a_holiday.
    WHEN stdt_before_holiday_in_past_id.
      MESSAGE e263 WITH data RAISING stdt_before_holiday_in_past.
    WHEN invalid_periodbehaviour_id.
      MESSAGE e387 WITH data RAISING invalid_periodbehaviour.
    WHEN period_too_small_for_limit_id.
      MESSAGE e267 RAISING period_too_small_for_limit.
    WHEN no_workday_nr_given_id.
      MESSAGE e286 RAISING no_workday_nr_given.
    WHEN invalid_workday_nr_id.
      MESSAGE e287 RAISING invalid_workday_nr.
    WHEN invalid_workday_countdir_id.
      MESSAGE e388 RAISING invalid_workday_countdir.
    WHEN notbefore_stdt_missing_id.
      MESSAGE e288 RAISING notbefore_stdt_missing.
    WHEN workday_starttime_missing_id.
      MESSAGE e289 RAISING workday_starttime_missing.
    WHEN no_eventid_given.
      MESSAGE e038 RAISING no_eventid_given.
    WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb der Startterminpruefung soll ausge-
*      loest werden. Aus Verlegenheit wird NO_STARTDATE_GIVE ausge-
*      loest und die unbekannte Exception im Syslog vermerkt.
*
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_startdate_exception
            ID 'DATA' FIELD exception.
      MESSAGE e666 WITH exception RAISING no_startdate_given.
  ENDCASE.

ENDFORM. " RAISE_STDT_EXCEPTION
