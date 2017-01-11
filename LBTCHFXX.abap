************************************************************************
* Funktionsbausteinübergreifende Hilfsroutinen des Function Pools BTCH *
************************************************************************

*---------------------------------------------------------------------*
* FORM SET_SCREEN_GRP_ATTRIBUT                                        *
*---------------------------------------------------------------------*
* diese Routine schaltet ein Attribut aller zu einer Dynpro-Screen-   *
* group gehoerenden Felder ein bzw. aus.                              *
*                                                                     *
* Input: - Dynprofeldgruppenname                                      *
*        - Attribut: INTENSIFIED                                       *
*                    REQUIRED                                         *
*                    INPUT                                            *
*                    OUTPUT                                           *
*                    INVISIBLE                                        *
*                    ACTIVATE                                         *
*        - Status  : ON / OFF                                         *
*---------------------------------------------------------------------*

FORM set_screen_grp_attribut USING grp1 grp2 grp3 grp4 attribut status.

  LOOP AT SCREEN.
    IF screen-group1 EQ grp1 AND
       screen-group2 EQ grp2 AND
       screen-group3 EQ grp3 AND
       screen-group4 EQ grp4.
      CASE attribut.
        WHEN required.
          screen-required = status.
        WHEN input.
          screen-input = status.
        WHEN output.
          screen-output = status.
        WHEN intensified.
          screen-intensified = status.
        WHEN invisible.
          screen-invisible = status.
          IF status EQ off.
            screen-active = on.
          ELSE.
            screen-active = off.
          ENDIF.
        WHEN activate.
          screen-active = status.
      ENDCASE.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " SET_SCREEN_GRP_ATTRIBUT.

*---------------------------------------------------------------------*
*       FORM BUILD_PREDJOB_EVENT_NAME                                 *
*---------------------------------------------------------------------*
* Aufbau des Namens eines Events über das ein Job angestartet werden  *
* soll. Der Eventname besteht aus 2 Teilen:                           *
*    a. Event-ID (fix)   = 'BTC_END_OF_JOB'                           *
*    b. Event-Paramteter = <JOBNAME><JOBCOUNT>                       *
* Ausserdem wird versucht, einen eindeutigen EVENTCOUNT zur ein-     *
* deutigen Identifizierung des Events im System zu generieren.       *
* Gelingt dies, so wird RC = 0 gesetzt, ansonsten is RC = 1          *
*---------------------------------------------------------------------*

FORM build_predjob_event_name USING pred_job_name
                                    pred_jobcount
                                    evt_id
                                    evt_parameter
                                    evt_count
                                    rc.
*
* Event-Id = BTC_END_OF_JOB setzen
*
  CLEAR evt_id.
  evt_id = btc_eventid_eoj.
*
* Event-Parameter zusammenbauen
*
  CLEAR evt_parameter.

  evt_parameter = pred_job_name.
  DESCRIBE FIELD tbtco-jobname LENGTH offset IN CHARACTER MODE.
  DESCRIBE FIELD pred_jobcount LENGTH len IN CHARACTER MODE .
  WRITE pred_jobcount TO evt_parameter+offset(len).
*
* Eventcount generieren
*

* 14.12.2012    note 1801159    d023157
* we generate the eventcount later in FORM insert_release_info_in_db

*  PERFORM gen_eventcount USING evt_id evt_count rc.
*
*  IF rc NE 0.
*    rc = eventcnt_generation_error.
*    EXIT.
*  ENDIF.

ENDFORM.                               " BUILD_PREDJOB_EVENT_NAME

*---------------------------------------------------------------------*
*       FORM GEN_EVENTCOUNT                                           *
*---------------------------------------------------------------------*
* Generierung eines eindeutigen Jobcounts für eine bestimmte EventId  *
* innerhalb der DB-Tabelle BTCEVTJOB                                  *
*                                                                     *
* Inputparameter: - EVENTID = EventId, für die ein eindeutiger Event- *
*                             count zu generieren ist                 *
* Outputparameter: - EVENTCOUNT : der gefundene, eindeutige Eventcount*
*                  - RC:  RC = 0: Generierung gelungen                *
*                         RC = 1: Generierung misslungen. Es gibt 99  *
*                                 identische Einträge in BTCEVTJOB.   *
*                                 Hier ist was faul.                  *
*                                                                     *
*---------------------------------------------------------------------*

FORM gen_eventcount USING evt_id evt_count rc.

  DATA: ecnt LIKE tbtco-eventcount.

  data: pattern(41).

  data: rand_1  type i.
  data: rand_2  type i.
  data: rc_rand type i.

  data: nr(2)   type n.

  pattern = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.

  GET TIME.
  ecnt = sy-uzeit.


  rc = 1.

* 18.10.2011    d023157   note 1643140
* DO-loop enhanced from 99 to 600 times.

  DO 600 TIMES.

* in case we get problems with generating random numbers,
* we preset the last two characters of the eventcount already

     nr = sy-index mod 100.
     ecnt+6(2) = nr.


     perform get_random_number using rand_1
                                     36
                                     rc_rand.

     if rc_rand = 0.
        rand_1 = rand_1 - 1.
* now rand_1 must be >= 0 and <= 35.
* however, just to be sure
        if rand_1 > 36.
           rand_1 = rand_1 mod 36.
        endif.

        if rand_1 < 0.
           rand_1 = 0 - rand_1.
        endif.

        ecnt+6(1) = pattern+rand_1(1).
     endif.

     perform get_random_number using rand_2
                                     36
                                     rc_rand.

     if rc_rand = 0.
        rand_2 = rand_2 - 1.
* now rand_2 must be >= 0 and <= 35.
* however, just to be sure
        if rand_2 > 35.
           rand_2 = rand_2 mod 36.
        endif.

        if rand_2 < 0.
           rand_2 = 0 - rand_2.
        endif.

        ecnt+7(1) = pattern+rand_2(1).
     endif.


* check, if combination (evt_id, ecnt) already exists
    SELECT SINGLE * FROM btcevtjob
           WHERE eventid    EQ evt_id
             AND eventcount EQ ecnt.                        " (1)

    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CALL FUNCTION 'ENQUEUE_BTCEVTJOB'                       " (2)
         EXPORTING  eventid        = evt_id
                    eventcount     = ecnt
*                    _wait          = 'X'
                    _scope         = '1'
         EXCEPTIONS foreign_lock   = 1
                    system_failure = 2
                    OTHERS         = 99.

    CASE sy-subrc.
      WHEN 0.
* hgk  check again, if combination in btcevtjob exists.
* This is necessary, because it might be possible,
* that in the very short time between the calls (1) and (2)
* above an entry of the same eventid and eventcount has been created
* completely.

        SELECT SINGLE * FROM btcevtjob
               WHERE eventid    EQ evt_id
                 AND eventcount EQ ecnt.                    " (1)

        IF sy-subrc = 0.
          CALL FUNCTION 'DEQUEUE_BTCEVTJOB'
            EXPORTING
              eventid    = evt_id
              eventcount = ecnt.
          CONTINUE.
        ENDIF.

        evt_count = ecnt.
        rc = 0.
        EXIT.

      WHEN 1.  " already locked
        rc = 1.
        CONTINUE.

      WHEN OTHERS.   " bad error
        rc = 1.
        CONTINUE.
    ENDCASE.
  ENDDO.
* c5034979, 4.12.2002

  IF rc NE 0.
*
*    Pech gehabt: Es konnte kein eindeutiger Eventcount generiert werden
*    -> Syslogeintrag
*
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD eventcnt_generation_error_id
          ID 'DATA' FIELD evt_id.
  ENDIF.

ENDFORM.                               " GEN_EVENTCOUNT

*---------------------------------------------------------------------*
*      FORM MOVE_INTTAB_ROW                                           *
*---------------------------------------------------------------------*
*  Verschieben einer Zeile innerhalb einer internen Tabelle.          *
*---------------------------------------------------------------------*
*                                                                     *
*  Parameter:                                                         *
*                                                                     *
*  TAB:    Name der internen Tabelle                                  *
*  SOURCE: Nummer der Zeile, die zu verschieben ist                   *
*  AFTER : Nummer der Zeile, hinter die die Sourcezeile zu positio-   *
*          nieren ist                                                 *
*                                                                     *
*  Returncodes (Parameter RETCODE):                                   *
*                                                                     *
*     OK                                                              *
*     INVALID_SOURCE_ROW                                              *
*     INVALID_AFTER_ROW                                               *
*     INTTAB_READ_ERROR                                               *
*     INTTAB_INSERT_ERROR                                             *
*     INTTAB_DELETE_ERROR                                             *
*                                                                     *
*---------------------------------------------------------------------*
*                                                                     *
* Es muessen 3 Faelle unterschieden werden:                           *
*                                                                     *
*                                                                     *
*    - AFTER == SOURCE : es muss nichts getan werden                  *
*                                                                     *
*    - AFTER > SOURCE :                                               *
*                                                                     *
*         -------                   -------                 -------   *
*         |  a  |                   |  a  |                 |  a  |   *
*         |-----|                   |-----|                 |-----|   *
*  Source |  b  |                   |  b  |                 |  c  |   *
*         |-----|  Read Source      |-----|  Delete Source  |-----|   *
*         |  c  | ----------------> |  c  | --------------> |  d  |   *
*         |-----|  Ins. (After+1)   |-----|                 |-----|   *
*  After  |  d  |                   |  d  |                 |  b  |   *
*         |-----|                   |-----|                 |-----|   *
*         |  e  |                   |  b  |                 |  e  |   *
*         -------                   |-----|                 |-----|   *
*                                   |  e  |                           *
*                                   -------                           *
*                                                                     *
*      (Hinweis: Ein Insert in eine interne Tabelle geschieht immer   *
*                vor dem angegebenen Index)                           *
*                                                                     *
*    - AFTER < SOURCE :                                               *
*                                                                     *
*         -------                   -------                 -------   *
*  After  |  a  |                   |  a  |                 |  a  |   *
*         |-----|                   |-----|                 |-----|   *
*         |  b  |  Read Source      |  d  |                 |  d  |   *
*         |-----|  Insert (After+1) |-----|  Delete         |-----|   *
*         |  c  | ----------------> |  b  | --------------> |  b  |   *
*         |-----|                   |-----|  (Source + 1)   |-----|   *
*  Source |  d  |                   |  c  |                 |  c  |   *
*         |-----|                   |-----|                 |-----|   *
*         |  e  |        (Source+1) |  d  |                 |  e  |   *
*         -------                   |-----|                 |-----|   *
*                                   |  e  |                           *
*                                   -------                           *
*                                                                     *
*---------------------------------------------------------------------*

FORM move_inttab_row TABLES tab USING source after retcode.

  DATA: tab_rows   TYPE i VALUE 0,
        help_index TYPE i VALUE 0.

*
* Anzahl Zeilen der Tabelle bestimmen und die Parameter SOURCE und
* AFTER dagegen verproben.
*
  retcode = ok.

  DESCRIBE TABLE tab LINES tab_rows.

  IF source < 1 OR
     source > tab_rows.
    retcode = invalid_source_row.
    EXIT.
  ENDIF.

  IF after < 1 OR
     after > tab_rows.
    retcode = invalid_after_row.
    EXIT.
  ENDIF.

  IF after EQ source.                  " es gibt nichts zu tun
    EXIT.
  ENDIF.

  READ TABLE tab INDEX source.         " Sourcezeile lesen

  IF sy-subrc NE 0.
    retcode = inttab_read_error.
    EXIT.
  ENDIF.

  IF source < after.
    help_index = after + 1.            " Index fuer Insert errechnen
  ELSE.
    help_index = after.                " Index fuer Insert errechnen
  ENDIF.

  INSERT tab INDEX help_index.         " Sourcezeile hinter Afterzeile
  " "einschieben"
  IF sy-subrc NE 0.
    retcode = inttab_insert_error.
    EXIT.
  ENDIF.

  IF after > source.                   " Index der Sourcezeile errechnen
    help_index = source.
  ELSE.
    help_index = source + 1.
  ENDIF.

  DELETE tab INDEX help_index.         " Sourcezeile loeschen

  IF sy-subrc NE 0.
    retcode = inttab_delete_error.
    EXIT.
  ENDIF.

ENDFORM. " MOVE_INTTAB_ROW                                            a

*---------------------------------------------------------------------*
*      FORM SHORTEN_STRING                                            *
*---------------------------------------------------------------------*
*  "Abschneiden" eines Strings auf eine vorgegebene Länge             *
*---------------------------------------------------------------------*
*                                                                     *
*  Parameter:                                                         *
*                                                                     *
*  STRING       : der zu verkürzende String                           *
*  SHORT_STRING : nimmt den verkürzten String auf                     *
*  CUT_LENGTH   : Länge, auf die STRING zu verkürzen ist              *
*                                                                     *
*  Es sind folgende Fälle zu unterscheiden:                           *
*                                                                     *
*    STRLEN(STRING) <= CUT_LENGTH:                                    *
*        es gibt nichts zu tun, STRING wird einfach nach SHORT_STRING *
*        kopiert                                                      *
*                                                                     *
*    STRLEN(STRING) > CUT_LENGTH:                                     *
*        STRING wird auf (LENGTH - 3) verkuerzt und nach SHORT_STRING *
*        kopiert. Die letzten 3 Stellen von SHORT_STRING werden mit   *
*        '...' gefuellt                                               *
*                                                                     *
*    STRLEN(LENGTH) muß > 3 sein, damit eine Verkürzung mit an-        *
*    schliessendem '...' vorgenommen werden kann                      *
*                                                                     *
*    -----------------------------------------                        *
*    |  STRING          |                    |                        *
*    ----------------------------------------|                        *
*                       |                    |                        *
*    -------------------|               STRING_LENGTH                 *
*    |  SHORT_STRING    |                                             *
*    -------------------|                                             *
*                       |                                             *
*                 CUT_LENGTH                                          *
*                                                                     *
*---------------------------------------------------------------------*

FORM shorten_string USING string short_string value(cut_length).

  DATA: string_length TYPE i,
        short_string_length TYPE i.

  IF cut_length < 0.                   " vorsichtshalber
    EXIT.
  ENDIF.

  DESCRIBE FIELD short_string LENGTH short_string_length
                                        IN CHARACTER MODE.
  IF cut_length > short_string_length. " vorsichtshalber
    cut_length = short_string_length.
  ENDIF.

  CLEAR short_string.

  string_length = strlen( string ).

  IF string_length <= cut_length.
    short_string = string.
  ELSE.
    WRITE string TO short_string+0(cut_length).

    IF cut_length > 3.
      cut_length = cut_length - 3.
      WRITE continue_sign TO short_string+cut_length(3).
    ENDIF.
  ENDIF.

ENDFORM.                               " SHORTEN_STRING

*---------------------------------------------------------------------*
*      FORM EXTRACT_STDT_FROM_JOBHEAD                                 *
*---------------------------------------------------------------------*
* Extrahieren von Starttermindaten aus Jobkopfdaten (JOB_HEAD =       *
* Inputparameter = Struktur vom Typ TBTCJOB) in die Struktur STDT_DATA*
* (Outputparameter = Struktur vom Typ TBTCSTRT)                       *
*---------------------------------------------------------------------*

FORM extract_stdt_from_jobhead USING job_head STRUCTURE tbtcjob
                                     stdt_data STRUCTURE tbtcstrt.
  CLEAR stdt_data.
  stdt_data-sdlstrtdt  = no_date.
  stdt_data-sdlstrttm  = no_time.
  stdt_data-laststrtdt = no_date.
  stdt_data-laststrttm = no_time.

  stdt_data-calendarid = job_head-calendarid.
  stdt_data-prdbehav   = job_head-prdbehav.
  stdt_data-checkstat  = job_head-checkstat.

  IF job_head-jobgroup EQ immediate_flag.
*
*      Starttermintyp = 'Sofort'
*
    stdt_data-startdttyp = btc_stdt_immediate.
  ELSEIF job_head-emergmode EQ btc_stdt_onworkday.
*
*        Starttermintyp = 'an Arbeitstag'
*
    stdt_data-startdttyp = btc_stdt_onworkday.
    stdt_data-wdayno     = job_head-prddays.
    stdt_data-wdaycdir   = job_head-prdmins.
    stdt_data-sdlstrtdt  = job_head-sdlstrtdt.
    stdt_data-sdlstrttm  = job_head-sdlstrttm.
    stdt_data-notbefore  = job_head-laststrtdt.
  ELSEIF job_head-eventid NE space.
    IF job_head-eventid EQ btc_eventid_eoj.
*
*        Starttermintyp = 'Start nach Vorgängerjob'. Im Feld EVENTPARM
*        befindet sich Name und Jobcount des Vorgängerjobs in konkati-
*        nierter Form (<Jobname><Jobcount>). Diese beiden Werte werden
*        aus EVENTPARM extrahiert und in die entsprechenden Starttermin-
*        feldern gespeichert.
*
      stdt_data-startdttyp = btc_stdt_afterjob.

      DESCRIBE FIELD stdt_data-predjob LENGTH len IN CHARACTER MODE.
      WRITE job_head-eventparm TO stdt_data-predjob+0(len).
      offset = len.
      DESCRIBE FIELD stdt_data-predjobcnt LENGTH len IN CHARACTER MODE.
      ASSIGN job_head-eventparm+offset(len) TO <s>.
      ASSIGN stdt_data-predjobcnt+0(len) TO <t>.
      MOVE <s> TO <t>.
    ELSE.
*
*       Starttermintyp = 'Start nach Event'.
*
      stdt_data-startdttyp = btc_stdt_event.
      stdt_data-eventid    = job_head-eventid.
      stdt_data-eventparm  = job_head-eventparm.
    ENDIF.
  ELSEIF NOT ( job_head-sdlstrtdt IS INITIAL ) AND
         job_head-sdlstrtdt NE no_date.
*
*      Starttermintyp = 'Datum / Uhrzeit'
*
    stdt_data-startdttyp = btc_stdt_datetime.
    stdt_data-sdlstrtdt  = job_head-sdlstrtdt.
    stdt_data-sdlstrttm  = job_head-sdlstrttm.
    stdt_data-laststrtdt = job_head-laststrtdt.
    stdt_data-laststrttm = job_head-laststrttm.
  ENDIF.
*
* Periodendaten extrahiern
*
  IF job_head-periodic EQ 'X'.
    stdt_data-periodic = 'X'.

    sum = job_head-prdmins  +
          job_head-prdhours +
          job_head-prddays  +
          job_head-prdweeks +
          job_head-prdmonths.

    IF sum NE 0.                       " zeitperiodisch
      IF stdt_data-startdttyp EQ btc_stdt_onworkday.
*
*          bei Starttermin 'an Arbeitstag' sind nur Monatswerte zulässig
*
        stdt_data-prdmonths = job_head-prdmonths.
      ELSE.
        stdt_data-prdmins   = job_head-prdmins.
        stdt_data-prdhours  = job_head-prdhours.
        stdt_data-prddays   = job_head-prddays.
        stdt_data-prdweeks  = job_head-prdweeks.
        stdt_data-prdmonths = job_head-prdmonths.
      ENDIF.
    ELSE.
      " eventperiodisch
    ENDIF.
  ELSE.
    CLEAR stdt_data-periodic.
  ENDIF.

ENDFORM.                               " EXTRACT_STDT_FROM_JOBHEAD

*---------------------------------------------------------------------*
*      FORM STORE_STDT_IN_JOBHEAD                                     *
*---------------------------------------------------------------------*
* Speichern von Starttermindaten (Inputparameter STDT_DATA) in die    *
* Struktur JOB_HEAD mit Jobkopfdaten                                  *
*---------------------------------------------------------------------*
FORM store_stdt_in_jobhead USING
                           job_head STRUCTURE tbtcjob
                           stdt_data STRUCTURE tbtcstrt
                           dialog
                           rc.
*
* alle startterminrelevanten Daten in den Jobkopfdaten initialisieren
*
  job_head-sdlstrtdt  = no_date.
  job_head-sdlstrttm  = no_time.
  job_head-laststrtdt = no_date.
  job_head-laststrttm = no_time.
  CLEAR job_head-eomcorrect.
  CLEAR job_head-calcorrect.
  CLEAR job_head-prdmins.
  CLEAR job_head-prdhours.
  CLEAR job_head-prddays.
  CLEAR job_head-prdweeks.
  CLEAR job_head-prdmonths.
  CLEAR job_head-periodic.
  CLEAR job_head-eventid.
  CLEAR job_head-eventparm.
  CLEAR job_head-eventcount.
  CLEAR job_head-prednum.
  CLEAR job_head-jobgroup.
  CLEAR job_head-emergmode.
*
* Starttermindaten in Jobkopf speichern
*
  job_head-calendarid = stdt_data-calendarid.
  job_head-prdbehav   = stdt_data-prdbehav.
  job_head-checkstat  = stdt_data-checkstat.

  IF stdt_data-startdttyp EQ btc_stdt_immediate.
    job_head-jobgroup   = immediate_flag.
    job_head-sdlstrtdt  = sy-datum.
    job_head-sdlstrttm  = sy-uzeit.
    job_head-eomcorrect = 0.           " wird von Scheduler gesetzt.
    job_head-calcorrect = stdt_data-calcorrect.
  ELSEIF stdt_data-startdttyp EQ btc_stdt_onworkday.
    job_head-emergmode  = btc_stdt_onworkday.
    job_head-prdmins    = stdt_data-wdaycdir.
    job_head-prddays    = stdt_data-wdayno.
    job_head-sdlstrtdt  = stdt_data-sdlstrtdt.
    job_head-sdlstrttm  = stdt_data-sdlstrttm.
    job_head-laststrtdt = stdt_data-notbefore.
  ELSEIF stdt_data-startdttyp EQ btc_stdt_datetime.
    job_head-sdlstrtdt  = stdt_data-sdlstrtdt.
    job_head-sdlstrttm  = stdt_data-sdlstrttm.
    job_head-laststrtdt = stdt_data-laststrtdt.
    job_head-laststrttm = stdt_data-laststrttm.
    job_head-eomcorrect = 0.           " wird von Scheduler gesetzt.
    job_head-calcorrect = stdt_data-calcorrect.
  ELSEIF stdt_data-startdttyp EQ btc_stdt_afterjob.
    PERFORM build_predjob_event_name USING
                                     stdt_data-predjob
                                     stdt_data-predjobcnt
                                     job_head-eventid
                                     job_head-eventparm
                                     job_head-eventcount
                                     rc.
    IF rc NE 0.
      IF dialog EQ btc_yes.
        MESSAGE s099 WITH stdt_data-predjob.
      ENDIF.
      rc = eventcnt_generation_error.
      EXIT.
    ENDIF.
    job_head-prednum = 1.              " Anzahl Vorgänger setzen
  ELSEIF stdt_data-startdttyp EQ btc_stdt_event.
    job_head-eventid   = stdt_data-eventid.
    job_head-eventparm = stdt_data-eventparm.

* 14.12.2012    note 1801159    d023157
* der Eventcount wird später generiert in FORM insert_release_info_in_db

*    PERFORM gen_eventcount USING job_head-eventid
*                                 job_head-eventcount
*                                 rc.
*    IF rc NE 0.
*      IF dialog EQ btc_yes.
*        MESSAGE s116 WITH job_head-eventid.
*      ENDIF.
*      rc = eventcnt_generation_error.
*      EXIT.
*    ENDIF.


  ENDIF.
*
* Periodendaten speichern.
*
  IF stdt_data-periodic EQ 'X'.
    job_head-periodic = 'X'.

    sum = stdt_data-prdmins  +
          stdt_data-prdhours +
          stdt_data-prddays  +
          stdt_data-prdweeks +
          stdt_data-prdmonths.

    IF sum NE 0.                       " zeitperiodisch
      IF stdt_data-startdttyp EQ btc_stdt_onworkday.
*
*          bei Starttermin 'an Arbeitstag' sind nur Monatswerte zulässig
*
        job_head-prdmonths = stdt_data-prdmonths.
      ELSE.
        job_head-prdmins   = stdt_data-prdmins.
        job_head-prdhours  = stdt_data-prdhours.
        job_head-prddays   = stdt_data-prddays.
        job_head-prdweeks  = stdt_data-prdweeks.
        job_head-prdmonths = stdt_data-prdmonths.
      ENDIF.
    ELSE.
      " eventperiodisch
    ENDIF.
  ELSE.
    job_head-periodic = space.
  ENDIF.

  rc = 0.

ENDFORM.                               " STORE_STDT_IN_JOBHEAD

*---------------------------------------------------------------------*
*       FORM GEN_JOBCOUNT                                             *
*---------------------------------------------------------------------*
* Diese Funktion generiert eine eindeutige Job-Nummer für einen Job.  *
*                                                                     *
* Inputparameter:                                                     *
*    JOBNAME : Name des Jobs, für den ein Jobcount generiert          *
*              werden soll                                            *
*                                                                     *
* Outputparameter:                                                    *
*    JOBCOUNT : generierter Jobcount                                  *
*          RC : Returncode der angibt, ob Jobcountgenerierung erfolg- *
*               reich war. RC = 0 -> Generierung ok, RC = 1 -> Ge-    *
*               nerierung misslungen                                  *
*---------------------------------------------------------------------*
FORM gen_jobcount USING jobname jobcount rc.

  DATA: jcnt LIKE tbtco-jobcount.
** FIXME
** Diese sehr rudimentaere Methode soll durch Nummernkreisvergabe
** ersetzt werden
  GET TIME.
  jcnt = sy-uzeit.
  rc = 1.
  DO 99 TIMES.
    IF sy-index > 9.
      jcnt+6(2) = sy-index.
    ELSE.
      jcnt+6(1) = '0'.
      jcnt+7(1) = sy-index.
    ENDIF.
    SELECT SINGLE * FROM tbtco
           WHERE jobname  = jobname
             AND jobcount = jcnt.
    IF sy-subrc > 0.                   " freie Nummer gefunden
      jobcount = jcnt.
      rc = 0.
      EXIT.
    ENDIF.
  ENDDO.

  IF rc NE 0.
*
*    Pech gehabt: es kann kein eindeutiger Jobcount generiert werden
*    -> Syslogeintrag
*
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD jobcount_generation_error_id
          ID 'DATA' FIELD jobname.
  ENDIF.

ENDFORM.                               " GEN_JOBCOUNT

*---------------------------------------------------------------------*
*       FORM AUTH_CHECK_NAM                                           *
*---------------------------------------------------------------------*
* Diese Funktion prueft den angebenen Batch-Benutzernamen:            *
* - Berechtigung zur Eingabe des Namens                               *
* - Existenz des Namens                                               *
* - Typkennung des Namens ist 'Batch'                                 *
*                                                                     *
* Beachte: Diese Funktion wird auch fuer die dialog-lose Einplanung   *
*          verwendet!                                                 *
*---------------------------------------------------------------------*
FORM auth_check_nam USING username rc.
*
*   Berechtigungspruefung, ob Benutzername fuer Berechtigungspruefung
*   angegeben werden darf
*   keine Pruefung, wenn der Batch-Benutzername mit dem aktuellen
*   Benutzer uebereinstimmt
*
  rc = 0.

  IF username <> sy-uname.
*  check if user exists
    SELECT SINGLE * FROM usr02
           WHERE bname = username.
    IF sy-subrc > 0.
      rc = invalid_username.
      EXIT.
    ENDIF.

    AUTHORITY-CHECK
      OBJECT 'S_BTCH_NAM'
          ID 'BTCUNAME' FIELD username.
    IF sy-subrc > 0.
      rc = no_user_assign_privilege.
      EXIT.
    ENDIF.
*
*       Pruefe Benutzertyp
*
*    IF usr02-ustyp <> c_usertype_dialog  AND
*       usr02-ustyp <> c_usertype_bdc AND    "note 356855
*       usr02-ustyp <> c_usertype_service AND
*       usr02-ustyp <> c_usertype_system AND
*       usr02-ustyp <> c_usertype_batch.
    IF usr02-ustyp = c_usertype_reference.
      rc = bad_user_type.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                               " AUTH_CHECK_NAM

*---------------------------------------------------------------------*
*       FORM VERIFY_USER_ABORT                                        *
*---------------------------------------------------------------------*
* Anwender darauf hinweisen, daß bei seiner Abbruchaktion (PF12)      *
* Daten verloren gehen, sofern er den Abbruch bestätigt. Der in       *
* dieser Routine gerufene Fubst. 'POPUP_TO_CONFIRM_STEP' führt den    *
* Dialog mit dem Anwender durch.                                      *
* Der Parameter TITLE wird im PopUp als Titel angezeigt.              *
*---------------------------------------------------------------------*

FORM verify_user_abort USING title.

  CLEAR dont_erase.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'                   "#EC FB_OLDED
    EXPORTING
      defaultoption = 'N'
      textline1     = text-132
      textline2     = text-133
      titel         = title
    IMPORTING
      answer        = popup_answer
    EXCEPTIONS
      OTHERS        = 99.

  IF sy-subrc EQ 0.
    CASE popup_answer.
      WHEN 'J'.
        SET SCREEN 0.  " Benutzer will wirklich abbrechen
        LEAVE SCREEN.
      WHEN OTHERS.
        dont_erase = 'X'.
    ENDCASE.
  ELSE.
    MESSAGE e106.
  ENDIF.

ENDFORM.                               " VERIFY_USER_ABORT



*---------------------------------------------------------------------*
*       FORM GET_BTC_SYSTEMS                                          *
*---------------------------------------------------------------------*
* Hole Liste aller im System vorhandenen Server die für Batchver-     *
* arbeitung vorgesehen sind.                                          *
*   RC = 0: Liste wurde erfolgreich erstellt                          *
*   RC = 1: Liste aller Batchserver kann nicht vom Messageserver      *
*           gelesen werden                                            *
*   RC = 4: z.Zeit sind keine Batch-Systeme aktiv                     *
*---------------------------------------------------------------------*
FORM get_btc_systems USING rc.

  DATA: BEGIN OF sys_tabl OCCURS 50.
          INCLUDE STRUCTURE msxxlist.
  DATA: END OF sys_tabl.

  DATA:
    batch LIKE msxxlist-msgtypes VALUE 8,
    batch_server_found TYPE i,
    num_lines TYPE i.

  FREE sys_tabl.
*
* Liste aller Batchinstanzen (beim Messageserver) abholen
*
  CALL FUNCTION 'TH_SERVER_LIST'
    EXPORTING
      services = batch
    TABLES
      list     = sys_tabl
    EXCEPTIONS
      OTHERS   = 99.

  IF sy-subrc <> 0.
    rc = tgt_host_chk_has_failed. " Liste kann nicht beschafft werden
    EXIT.
  ENDIF.

  DESCRIBE TABLE sys_tabl LINES num_lines.

  IF num_lines EQ 0.
    rc = no_batch_server_found.        " kein Batchserver vorhanden
    EXIT.
  ENDIF.

  SORT sys_tabl BY name ASCENDING.

  FREE btc_sys_tbl.
  LOOP AT sys_tabl.
    btc_sys_tbl-btcsystem = sys_tabl-host.
    btc_sys_tbl-instname  = sys_tabl-name.
    APPEND btc_sys_tbl.
  ENDLOOP.

  rc = 0.

ENDFORM.                               " GET_BTC_SYSTEMS

*---------------------------------------------------------------------*
*       FORM GET_SERVER_LIST                                          *
*---------------------------------------------------------------------*
* Hole Liste aller am System angeschlossenen Server                   *
*   RC = 1: Liste aller Server kann nicht vom Messageserver beschafft *
*           werden                                                    *
*   RC = 2: derzeit sind dem Messageserver keine Server bekannt       *
*           (darf eigentlich nicht passieren)                         *
*---------------------------------------------------------------------*
FORM get_server_list USING rc.

  DATA: BEGIN OF sys_tabl OCCURS 50.
          INCLUDE STRUCTURE msxxlist.
  DATA: END OF sys_tabl.

  DATA: num_lines TYPE i.

  FREE sys_tabl.

  CALL FUNCTION 'TH_SERVER_LIST'
    TABLES
      list   = sys_tabl
    EXCEPTIONS
      OTHERS = 99.

  IF sy-subrc <> 0.
    rc = cant_get_server_info.  " Liste kann nicht beschafft werden
    EXIT.
  ENDIF.

  DESCRIBE TABLE sys_tabl LINES num_lines.

  IF num_lines EQ 0.
    rc = no_server_found.              " keine Server vorhanden
    EXIT.
  ENDIF.

  SORT sys_tabl BY name ASCENDING.

  FREE btc_sys_tbl.
  LOOP AT sys_tabl.
    btc_sys_tbl-btcsystem = sys_tabl-host.
    btc_sys_tbl-instname  = sys_tabl-name.
    APPEND btc_sys_tbl.
  ENDLOOP.

  rc = 0.

ENDFORM.                               " GET_SERVER_LIST

*---------------------------------------------------------------------*
*       FORM CHECK_TARGET_SERVER                                      *
*---------------------------------------------------------------------*
* Überpruefung des angegebenen Zielrechners auf Gültigkeit abhängig   *
* vom Starttermin eines Jobs (Parameter STARTDATE) und seiner Job-    *
* klasse (Parameter JOBCLASS)                                         *
*                                                                     *
* Starttermintyp = 'Sofort':                                          *
*                                                                     *
* - Zielrechner gegen Rechner, die dem Messageserver bekannt sind,    *
*   verproben und prüfen, ob mindestens 1 Batchworkprozess frei ist   *
*                                                                     *
* Starttermintyp = 'Datum/Uhrzeit' bzw. 'an Arbeitstag'               *
*                                                                     *
* - Betriebsart (BA) ermitteln, die am angegebenen Termin aktiv       *
*   ist und prüfen, ob Zielrechner in dieser BA für Batch konfiguriert*
*   ist und ob die erforderlich Jobklasse prozessiert werden kann.    *
*   Starttermintyp 'an Arbeitstag' wird hier behandelt wie            *
*   'Datum/Uhrzeit'.                                                  *
*                                                                     *
* Starttermintyp = 'bei Betriebsart':                                 *
*                                                                     *
* - prüfen, ob Zielrechner in dieser BA für Batch konfiguriert ist    *
*   und ob die erforderlich Jobklasse prozessiert werden kann         *
*                                                                     *
* alle anderen Starttermintypen ('bei Event', 'nach Vorgängerjob' und *
* 'kein Starttermin gegeben):                                         *
*                                                                     *
* - prüfen, ob Zielrechner in irgendeiner Betriebsart definiert ist   *
*   und ob er die geforderte Jobklasse prozessieren kann. Da wir nicht*
*   wissen, wann der Job abläuft, kann nur diese 'grobe' Prüfung vor- *
*   genommen werden.                                                  *
*                                                                     *
* Achtung !                                                           *
*                                                                     *
* Sollte bei den diversen Prüfungen, z.B. Prüfungen, bei denen BA's   *
* mit ins Spiel kommen, schief gehen, so wird der Zielrechner nur     *
* gegen den Messageserver geprüft (Notbetrieb)                        *
*                                                                     *
*---------------------------------------------------------------------*
FORM check_target_server USING target_hostname
                               target_servername
                               startdate STRUCTURE tbtcstrt
                               jobclass
                               rc.

  DATA: opmode                 LIKE btcomset-modename,
        subrc LIKE sy-subrc.

  DATA BEGIN OF p_inst_descr OCCURS 10.
          INCLUDE STRUCTURE spfid.
  DATA END OF p_inst_descr.

  DATA BEGIN OF p_ba_descr OCCURS 10.
          INCLUDE STRUCTURE spfba.
  DATA END OF p_ba_descr.

  CLEAR rc.
  CLEAR target_hostname.

  IF startdate-startdttyp EQ btc_stdt_immediate.

* d023157     14.1.2005
* bei Sofortstart werden alle Ressourcenprüfungen in
* start_job_immediately durchgeführt. Hier wird nur geprüft,
* ob der Server ein batch-Server ist.

    PERFORM verify_batch_server USING target_hostname
                                     target_servername
                                     rc.



    startdate-imstrtpos = true.      " Sofortstart möglich
    EXIT.

  ELSEIF startdate-startdttyp = btc_stdt_event AND
         startdate-eventid = oms_eventid.
*
*      Starttermintyp = 'bei Betriebsart'
*
    opmode = startdate-eventparm.
*
*   Beschreibung der Betriebsart holen (mit allen Rechnern) und prüfen,
*   ob Zielrechner in dieser BA definiert, batchfähig ist und die ge-
*   forderte Jobklasse bedienen kann
*
    CALL FUNCTION 'RZL_GET_BA_DESCR'
      EXPORTING
        betriebsart_name           = opmode
      IMPORTING
        betriebsart_description    = p_ba_descr
        subrc                      = subrc
      TABLES
        instance_description_table = p_inst_descr
      EXCEPTIONS
        OTHERS                     = 99.

    IF sy-subrc <> 0 OR subrc <> 0.
      PERFORM verify_batch_server USING target_hostname
                                     target_servername
                                     rc.

      EXIT.
    ENDIF.

    PERFORM lookup_server_in_opmode_descr
      TABLES p_inst_descr USING target_servername jobclass rc.

* d023157    25.11.2008
* if in dialogue a job is defined with a non existing target server,
* a warning should be shown.
  ELSE.

    PERFORM verify_batch_server USING target_hostname
                                     target_servername
                                     rc.

  ENDIF.

ENDFORM.                               " CHECK_TARGET_SERVER

*---------------------------------------------------------------------*
*   FORM LOOKUP_SERVER_IN_OPMODE_DESCRIPTION                          *
*---------------------------------------------------------------------*
* Prüfe, ob der gegebene AppServer in einer Betriebsart definiert     *
* und in der Lage ist, einen Batchjob der geforderten Jobklasse       *
* zu prozessieren                                                     *
*---------------------------------------------------------------------*
FORM lookup_server_in_opmode_descr TABLES opmode_descr STRUCTURE spfid
                                   USING
                                         target_servername
                                         jobclass
                                         rc.

  DATA: target_host_has_batch  LIKE true,
        target_host_is_defined LIKE true,
        batch_wps_free         LIKE true,
        non_cls_a_wps          TYPE i VALUE 0.

  DATA: group_server_list TYPE bpsrventry,
        temp_group TYPE REF TO cl_bp_server_group,
        job_input_tmp LIKE job_stdt_input,
        resource TYPE msname2,
        target_group TYPE btch4100-trgtsvr.

  target_group = target_servername.

  IF target_group(1) EQ '<'.
    TRANSLATE target_group USING '< > '.
    CONDENSE target_group.

    CALL METHOD cl_bp_group_factory=>make_group_by_name
      EXPORTING
        i_name          = target_group
        i_only_existing = 'X'
      RECEIVING
        o_grp_instance  = temp_group.

    IF NOT temp_group IS INITIAL.

      CALL METHOD temp_group->get_list
        RECEIVING
          o_list = group_server_list.

      PERFORM find_resource_in_srv_group
       USING
        group_server_list
        btch4100-jobclass
        job_input_tmp
        resource.

      IF resource IS INITIAL.
      ELSE.
        target_group = resource.
      ENDIF.
    ENDIF.
  ENDIF.

  target_host_is_defined = false.
  target_host_has_batch  = false.
  batch_wps_free         = false.

  LOOP AT opmode_descr WHERE apserver EQ target_group.
    target_host_is_defined = true.
    IF opmode_descr-wpnobtc > 0.                          "#EC PORTABLE
      target_host_has_batch = true.
      IF jobclass(1) EQ btc_jobclass_a.
        batch_wps_free = true.
        EXIT.
      ELSE.
        non_cls_a_wps = opmode_descr-wpnobtc - opmode_descr-wpnobtca.
        IF non_cls_a_wps > 0.
          batch_wps_free = true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF target_host_is_defined EQ false.
    rc = target_host_not_defined.
    EXIT.
  ENDIF.

  IF target_host_has_batch EQ false.
    rc = no_batch_on_target_host.
    EXIT.
  ENDIF.

  IF batch_wps_free EQ false.
    rc = no_batch_wp_for_jobclass.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM. " LOOKUP_SERVER_IN_OPMODE_DESCRIPTION

*---------------------------------------------------------------------*
*   FORM FIND_FREE_BATCH_SERVER                                       *
*---------------------------------------------------------------------*
* Diese Funktion versucht, abhängig vom Starttermin und der Jobklasse *
* eines Jobs, einen Server zu finden, auf dem der Job ablaufen kann:  *
*                                                                     *
* Starttermintyp = 'Sofort':                                          *
*                                                                     *
* Über Messageserve Liste aller gerade aktiven Batchserver besorgen.  *
* Um eine möglichst gerechte Verteilung auf die in Frage kommenden    *
* Server vorzunehmen, wird ein Server nach einer "Zufallsfunktion"    *
* ermittelt (Annahme: es gibt n Server):                              *
*                                                                     *
*   Server-Nr. = ((aktuelle Zeit in Sekunden) MOD n ) + 1             *
*                                                                     *
* Starttermintyp = 'Datum/Uhrzeit' bzw. 'an Arbeitstag'               *
*                                                                     *
* - Betriebsart (BA) ermitteln, die am angegebenen Termin aktiv       *
*   ist und prüfen, ob ein Rechner in dieser BA für Batch konfiguriert*
*   ist und ob die erforderlich Jobklasse prozessiert werden kann     *
*                                                                     *
* Starttermintyp = 'bei Betriebsart':                                 *
*                                                                     *
* - prüfen, ob ein Rechner in dieser BA für Batch konfiguriert ist    *
*   und ob die erforderlich Jobklasse prozessiert werden kann         *
*                                                                     *
* alle anderen Starttermintypen ('bei Event', 'nach Vorgängerjob' und *
* 'kein Starttermin gegeben):                                         *
*                                                                     *
* - prüfen, ob ein batchfähiger Rechner in irgendeiner BA definiert   *
*   ist der die geforderte Jobklasse prozessieren kann. Da wir nicht  *
*   wissen, wann der Job abläuft, kann nur diese 'grobe' Prüfung vor- *
*   genommen werden.                                                  *
*                                                                     *
* Achtung !                                                           *
*                                                                     *
* Sollte bei den diversen Prüfungen, z.B. Prüfungen, bei denen BA's   *
* mit ins Spiel kommen, schief gehen, so wird versucht, ein freier    *
* Zielrechner über den Messageserver zu ermitteln.                    *
*                                                                     *
*---------------------------------------------------------------------*
FORM find_free_batch_server USING target_hostname
                                  target_servername
                                  startdate STRUCTURE tbtcstrt
                                  jobclass
                                  rc.
  DATA: BEGIN OF tmp_startdate.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF tmp_startdate.

  DATA: num_of_srv TYPE i,
        opmode LIKE btcomset-modename,
        subrc LIKE sy-subrc,
        num_of_servers TYPE i,
        selected_srv TYPE i.

  DATA BEGIN OF p_inst_descr OCCURS 10.
          INCLUDE STRUCTURE spfid.
  DATA END OF p_inst_descr.

  DATA BEGIN OF p_ba_descr OCCURS 10.
          INCLUDE STRUCTURE spfba.
  DATA END OF p_ba_descr.

  CLEAR rc.
  CLEAR target_servername.
  CLEAR target_hostname.

  IF startdate-startdttyp EQ btc_stdt_immediate.

* d023157     14.1.2005
* bei Sofortstart werden alle Ressourcenprüfungen in
* start_job_immediately durchgeführt.

    startdate-imstrtpos = true.

  ELSEIF startdate-startdttyp = btc_stdt_event AND
         startdate-eventid    = oms_eventid.
*
*      Starttermintyp = 'bei Betriebsart'
*
    opmode = startdate-eventparm.

*
*   Beschreibung der Betriebsart holen (mit allen Rechnern) und prüfen,
*   ob ein Zielrechner in dieser BA definiert, batchfähig ist und die
*   geforderte Jobklasse bedienen kann
*
    CALL FUNCTION 'RZL_GET_BA_DESCR'
      EXPORTING
        betriebsart_name           = opmode
      IMPORTING
        betriebsart_description    = p_ba_descr
        subrc                      = subrc
      TABLES
        instance_description_table = p_inst_descr
      EXCEPTIONS
        OTHERS                     = 99.

    IF sy-subrc <> 0 OR subrc <> 0.
      rc = no_batch_server_found.
      EXIT.
    ENDIF.

    PERFORM find_a_batch_srv_in_opmode TABLES p_inst_descr
                                       USING  target_hostname
                                              target_servername
                                              jobclass
                                              rc.
  ENDIF.

ENDFORM.                               " FIND_FREE_BATCH_SERVER

*---------------------------------------------------------------------*
*   FORM FIND_A_BATCH_SRV_IN_OPMODE                                   *
*---------------------------------------------------------------------*
* Versuche, in der gegebenen Betriebsartentabelle einen batchfähigen  *
* Server zu finden, der die geforderte Jobklasse bearbeiten kann.     *
*---------------------------------------------------------------------*
FORM find_a_batch_srv_in_opmode TABLES opmode_descr STRUCTURE spfid
                                       USING  target_hostname
                                              target_servername
                                              jobclass
                                              rc.
  DATA: batch_server_found LIKE true,
        non_cls_a_wps      TYPE i VALUE 0.

  CLEAR target_hostname.
  CLEAR target_servername.

  batch_server_found = false.

  LOOP AT opmode_descr.
    IF opmode_descr-wpnobtc > 0.                          "#EC PORTABLE
      IF jobclass EQ btc_jobclass_a.
        target_servername  = opmode_descr-apserver.
        target_hostname    = opmode_descr-host.
        batch_server_found = true.
        EXIT.
      ELSE.
        non_cls_a_wps = opmode_descr-wpnobtc - opmode_descr-wpnobtca.
        IF non_cls_a_wps > 0.
          target_servername = opmode_descr-apserver.
          target_hostname   = opmode_descr-host.
          batch_server_found = true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF batch_server_found EQ false.
    rc = no_batch_server_found.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                               " FIND_A_BATCH_SRV_IN_OPMODE

*---------------------------------------------------------------------*
*   FORM CHECK_FOR_FREE_BTC_WP                                        *
*---------------------------------------------------------------------*
* Prüfe, ob auf einem gegebenen SAP-Server mindestens ein freier      *
* Batchworkprozess für die angegebene Jobklasse vorhanden ist.        *
* Falls ja, RC = 0, ansonsten RC != 0                                 *
*---------------------------------------------------------------------*

FORM check_for_free_btc_wp USING srvname jobclass rc.

  DATA: srv_name  LIKE msxxlist-name,
        isrv_type LIKE msxxlist-msgtypes VALUE 0,
        btc_rqtyp(4) VALUE 'BTC ',
        no_of_free_btc_wp  TYPE i VALUE 0,
        no_of_total_btc_wp TYPE i VALUE 0.

  DATA: BEGIN OF req_tbl OCCURS 5.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF req_tbl.

  DATA: BEGIN OF rsp_tbl OCCURS 20.
          INCLUDE STRUCTURE sthcmlist.
  DATA: END OF rsp_tbl.

  DATA: BEGIN OF loc_int_tab OCCURS 10." Tabelle für das Auslesen von
          INCLUDE STRUCTURE salstintg. " 'privaten' Integerweten eines
  DATA: END OF loc_int_tab.            " SAP-Servers

  DATA: BEGIN OF loc_text_tab OCCURS 10. " Tabelle für das Auslesen von
          INCLUDE STRUCTURE salsttext. " 'privaten' Kurztexten eines
  DATA: END OF loc_text_tab.           " SAP-Servers

  DATA: BEGIN OF loc_long_text_tab OCCURS 10. " Tabelle für das Auslesen
          INCLUDE STRUCTURE salstltxt. " von 'privaten' Langtexten
  DATA: END OF loc_long_text_tab.      " eines SAP-Servers

  DATA: BEGIN OF wpstatus_tbl OCCURS 10, " Tabelle, die den Status aller
       wp      TYPE i,                 " Workprozesse eines SAP-Servers
        rqtyp(4),                      " enthält
        stat    TYPE i,
        END OF wpstatus_tbl.

* <c5034976>
  IF srvname(1) EQ '<'.
    TRANSLATE srvname USING '< > '.
    CONDENSE srvname NO-GAPS.
  ENDIF.
* </c5034976>

  srv_name = srvname.

  REFRESH req_tbl.
  REFRESH rsp_tbl.
*
* Request für das Ermitteln der Workprozeßstatus und der reservierten
* Klasse-A-Batchworkprozesse auf dem genannten Server aufbauen
*
  CLEAR req_tbl.
  req_tbl-opcode = ad_wpstat.
  APPEND req_tbl.

  CALL FUNCTION 'RZL_MAKE_STRG_READ_REQ'
    EXPORTING
      name    = class_a_wp_ident
      typ     = 'C'
    TABLES
      req_tbl = req_tbl
    EXCEPTIONS
      OTHERS  = 99.

  IF sy-subrc NE 0.
    rc = tgt_host_chk_has_failed.
    EXIT.
  ENDIF.
*
* Request an Server schicken, Antwort abholen und Workprozeßstatus-
* tabelle aufbauen
*
  CALL FUNCTION 'RZL_EXECUTE_STRG_REQ'
    EXPORTING
      srvname = srvname
    TABLES
      req_tbl = req_tbl
      rsp_tbl = rsp_tbl
    EXCEPTIONS
      OTHERS  = 99.

  IF sy-subrc NE 0.
    rc = tgt_host_chk_has_failed.
    EXIT.
  ENDIF.

  CALL FUNCTION 'RZL_MAKE_STRG_RSP'
    TABLES
      intg_tbl      = loc_int_tab
      text_tbl      = loc_text_tab
      long_text_tbl = loc_long_text_tab
      rsp_tbl       = rsp_tbl
    EXCEPTIONS
      OTHERS        = 99.

  IF sy-subrc NE 0.
    rc = tgt_host_chk_has_failed.
    EXIT.
  ENDIF.

  MOVE space TO loc_text_tab.
  loc_text_tab-name = class_a_wp_ident.
  READ TABLE loc_text_tab.
  IF sy-subrc EQ 0.                    " Anzahl reservierter
    class_a_btc_wp = loc_text_tab-value.  " Klasse-A-Batch-WPs
  ELSE.                                " ermitteln
    class_a_btc_wp = 0.
  ENDIF.

  REFRESH wpstatus_tbl.

  LOOP AT rsp_tbl.
    IF rsp_tbl-opcode EQ ad_wpstat AND rsp_tbl-errno EQ 0.
      raw_ad_wpstat_rec = rsp_tbl-buffer.
      MOVE-CORRESPONDING raw_ad_wpstat_rec TO wpstatus_tbl.
      APPEND wpstatus_tbl.
    ENDIF.
  ENDLOOP.
*
* Anzahl der (freien) Batchworkprozesse ermitteln. Bei Jobklasse un-
* gleich A, sind die reservierten Klasse-A-WPs von der Anzahl der
* freien WPs zu subtrahieren.
*
  LOOP AT wpstatus_tbl.
    IF wpstatus_tbl-rqtyp EQ btc_rqtyp.
      no_of_total_btc_wp = no_of_total_btc_wp + 1.
      IF wpstatus_tbl-stat EQ ad_wpstat_stat_wait.
        no_of_free_btc_wp = no_of_free_btc_wp + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF jobclass EQ btc_jobclass_a.
  ELSE.
    no_of_free_btc_wp = no_of_free_btc_wp - class_a_btc_wp.
  ENDIF.

  IF jobclass NE btc_jobclass_a AND
     no_of_total_btc_wp EQ class_a_btc_wp.
    rc = no_batch_wp_for_jobclass.
    EXIT.
  ENDIF.

  IF no_of_free_btc_wp <= 0.
    rc = no_free_batch_wp_now.
    EXIT.
  ENDIF.

  free_btc_wp = no_of_free_btc_wp.
  total_btc_wp = no_of_total_btc_wp.

  rc = 0.

ENDFORM.                               " CHECK_FOR_FREE_BTC_WP

*---------------------------------------------------------------------*
*   FORM VERIFY_BATCH_HOST                                            *
*---------------------------------------------------------------------*
* Prüfe, ob ein gegebener Rechner im Moment batchfähig ist ( beim     *
* Messageserver nachschauen ) Wenn ja, gib seinen Servernamen an den  *
* den Rufer zurück. Wenn Prüfung erfolgreich durchlaufen wurde, wird  *
* RC = 0, ansonst != 0 gesetzt.                                       *
* Status: veraltet, ersetzt durch verify_batch_server
*---------------------------------------------------------------------*

FORM verify_batch_host USING hostname servername rc.

  DATA: BEGIN OF sys_tabl OCCURS 50.
          INCLUDE STRUCTURE msxxlist.
  DATA: END OF sys_tabl.

  DATA: host_has_batch  LIKE true,
        service_type_batch LIKE msxxlist-msgtypes VALUE 8.

  CLEAR servername.
  FREE sys_tabl.

  CALL FUNCTION 'TH_SERVER_LIST'
    TABLES
      list   = sys_tabl
    EXCEPTIONS
      OTHERS = 99.

  IF sy-subrc <> 0.
    rc = tgt_host_chk_has_failed. " Liste kann nicht beschafft werden
    EXIT.
  ENDIF.

  host_has_batch  = false.

  LOOP AT sys_tabl WHERE host EQ hostname.
    IF sys_tabl-msgtypes O service_type_batch.
      host_has_batch = true.
      servername     = sys_tabl-name.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF host_has_batch EQ false.
    rc = no_batch_on_target_host.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                               " VERIFY_BATCH_HOST

*---------------------------------------------------------------------*
*   FORM VERIFY_BATCH_SERVER                                          *
*---------------------------------------------------------------------*
* Prüfe, ob ein gegebener Server im Moment batchfähig ist ( beim      *
* Messageserver nachschauen ) Wenn ja, gib seinen Hostnamen an den    *
* den Rufer zurück. Wenn Prüfung erfolgreich durchlaufen wurde, wird  *
* RC = 0, ansonst != 0 gesetzt.                                       *
*---------------------------------------------------------------------*

FORM verify_batch_server USING hostname servername rc.

  DATA: BEGIN OF sys_tabl OCCURS 50.
          INCLUDE STRUCTURE msxxlist.
  DATA: END OF sys_tabl.

  DATA: server_has_batch  LIKE true,
        service_type_batch LIKE msxxlist-msgtypes VALUE 8.

  CLEAR hostname.
  FREE sys_tabl.

  CALL FUNCTION 'TH_SERVER_LIST'
    TABLES
      list   = sys_tabl
    EXCEPTIONS
      OTHERS = 99.

  IF sy-subrc <> 0.
    rc = tgt_host_chk_has_failed. " Liste kann nicht beschafft werden
    EXIT.
  ENDIF.

  server_has_batch  = false.

  LOOP AT sys_tabl WHERE name EQ servername.
    IF sys_tabl-msgtypes O service_type_batch.
      server_has_batch = true.
      hostname     = sys_tabl-host.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF server_has_batch EQ false.
    rc = no_batch_on_target_host.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                               " VERIFY_BATCH_SERVER

*---------------------------------------------------------------------*
*      FORM STORE_NEW_STEPLIST_IN_DB                                  *
*---------------------------------------------------------------------*
* Abspeichern der Stepliste eines neuen Jobs in der Datenbank         *
*                                                                     *
* Returncodes:                                                        *
*                                                                     *
*    RC = 0: Speicheroperation gelungen                               *
*    RC = 1: Speicheroperation misslungen                             *
*                                                                     *
* Diese Routine geht davon aus, daß die Steplistwerte bereits auf     *
* Gültigkeit geprüft wurden.                                          *
*                                                                     *
*---------------------------------------------------------------------*

FORM store_new_steplist_in_db TABLES new_steplist STRUCTURE tbtcstep
                              USING  new_job_head STRUCTURE tbtcjob
                                     dialog
                                     rc.
  DATA: step_count TYPE i,
        tmp_key TYPE syprkey.
  DATA: tmp_pri_params LIKE pri_params.

  DATA: BEGIN OF db_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcp.
  DATA: END OF db_steplist.

  DATA: jobinfo_egj(64).      " note 952782

  DATA: p_valid.

*
* Stepliste in DB-Form erstellen (DB-Tabelle TBTCP)
*
  step_count = 1.

  LOOP AT new_steplist.
    CLEAR db_steplist.

    MOVE-CORRESPONDING new_steplist TO db_steplist.

    db_steplist-jobname   = new_job_head-jobname.
    db_steplist-jobcount  = new_job_head-jobcount.
    db_steplist-stepcount = step_count.
    CLEAR db_steplist-listident.       "neu: spoolid= sy-spono= numc10
    db_steplist-xpgpid    = space.
    CLEAR db_steplist-convid.
    db_steplist-status    = btc_scheduled.

    IF new_steplist-typ EQ btc_abap.   " Step führt einen Report aus
      db_steplist-progname = new_steplist-program.
      db_steplist-variant  = new_steplist-parameter.

      "only abap steps may have print parameters associated
      "get a valid key here and store it in db
      IF NOT db_steplist-progname = 'RSBTCPT3'. " note 817602
        MOVE-CORRESPONDING new_steplist TO tmp_pri_params.

* start of note 1137537
        IF db_steplist-authcknam IS INITIAL.
          db_steplist-authcknam = sy-uname.
        ENDIF.

        IF tmp_pri_params EQ space OR tmp_pri_params IS INITIAL.
          CALL FUNCTION 'GET_PRINT_PARAMETERS'
            EXPORTING
              mode                     = 'BATCH'
              no_dialog                = 'X'
              report                   = db_steplist-progname
              user                     = db_steplist-authcknam
            IMPORTING
*             OUT_ARCHIVE_PARAMETERS   =
              out_parameters           = tmp_pri_params
              valid                    = p_valid
*             VALID_FOR_SPOOL_CREATION =
            EXCEPTIONS
              archive_info_not_found   = 1
              invalid_print_params     = 2
              invalid_archive_params   = 3
              OTHERS                   = 4.
          IF sy-subrc <> 0 OR p_valid NE 'X'.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

        ENDIF.
* start of note 1137537

        CALL FUNCTION 'STORE_PRINT_PARAMETERS'
          EXPORTING
            in_parameters = tmp_pri_params
            applikation   = 'B'
            user          = db_steplist-authcknam
            priprog       = db_steplist-progname
          IMPORTING
            key           = tmp_key
          EXCEPTIONS
            error_occured = 1
            OTHERS        = 2.

        IF sy-subrc <> 0.
          "could not get a valid key
          IF dialog EQ btc_yes.
            MESSAGE s299 WITH step_count new_job_head-jobname.
          ENDIF.

          CONCATENATE new_job_head-jobname new_job_head-jobcount INTO
          jobinfo_egj SEPARATED BY '/'.

          CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
             ID 'KEY'  FIELD tbtcp_insert_db_error
             ID 'DATA' FIELD jobinfo_egj.

          rc = 1.
          EXIT.
        ELSE.
          db_steplist-priparkey = tmp_key.
        ENDIF.
      ENDIF.

    ELSEIF new_steplist-typ = btc_xcmd." Step executes external command
      db_steplist-extcmd = new_steplist-program.
      db_steplist-xpgparams = new_steplist-parameter.
      db_steplist-xpgflag = 'X'.
    ELSE. " Step führt ein externes Programm aus
      db_steplist-xpgprog   = new_steplist-program.
      db_steplist-xpgparams = new_steplist-parameter.
      db_steplist-xpgflag   = 'X'.
    ENDIF.

    db_steplist-sdldate  = new_job_head-sdldate.
    db_steplist-sdltime  = new_job_head-sdltime.
    db_steplist-sdluname = new_job_head-sdluname.

    APPEND db_steplist.

    step_count = step_count + 1.
  ENDLOOP.
*
* Stepliste in DB speichern
*
  INSERT tbtcp FROM TABLE db_steplist ACCEPTING DUPLICATE KEYS. "n952782

  IF sy-subrc NE 0.
    IF dialog EQ btc_yes.
      MESSAGE s120 WITH new_job_head-jobname.
    ENDIF.

    CONCATENATE new_job_head-jobname new_job_head-jobcount INTO
    jobinfo_egj SEPARATED BY '/'.

    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtcp_insert_db_error
          ID 'DATA' FIELD jobinfo_egj.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                               " STORE_NEW_STEPLIST_IN_DB

*---------------------------------------------------------------------*
*      FORM UPDATE_STEPLIST_IN_DB                                     *
*---------------------------------------------------------------------*
* Stepliste eines Jobs in der Datenbank updaten                       *
*                                                                     *
* Returncodes:                                                        *
*                                                                     *
*    RC = 0: Speicheroperation gelungen                               *
*    RC = 1: Speicheroperation misslungen                             *
*                                                                     *
* Diese Routine geht davon aus, daß die Steplistwerte bereits auf     *
* Gültigkeit geprüft wurden.                                          *
*                                                                     *
*---------------------------------------------------------------------*

FORM update_steplist_in_db TABLES mod_steplist STRUCTURE tbtcstep
                           USING  mod_jobhead  STRUCTURE tbtcjob
                                  dialog
                                  rc.

  DATA: stepcount LIKE tbtcp-stepcount VALUE 1,
        tmp_key TYPE syprkey,
        tmp_pri_params LIKE pri_params.

  DATA: BEGIN OF db_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcp.
  DATA: END OF db_steplist.

*
* Stepliste in DB-Form erstellen (DB-Tabelle TBTCP)
*
  GET TIME.

  LOOP AT mod_steplist.
    CLEAR db_steplist.

    MOVE-CORRESPONDING mod_steplist TO db_steplist.

    db_steplist-jobname   = mod_jobhead-jobname.
    db_steplist-jobcount  = mod_jobhead-jobcount.
    db_steplist-stepcount = stepcount.

    IF mod_steplist-typ EQ btc_abap.   " Step führt einen Report aus
      db_steplist-progname = mod_steplist-program.
      db_steplist-variant  = mod_steplist-parameter.
      "only abap steps may have print parameters associated
      "get a valid key here and store it in db
      MOVE-CORRESPONDING mod_steplist TO tmp_pri_params.

      CALL FUNCTION 'STORE_PRINT_PARAMETERS'
        EXPORTING
          in_parameters = tmp_pri_params
          applikation   = 'B'
          user          = db_steplist-authcknam
          priprog       = db_steplist-progname
        IMPORTING
          key           = tmp_key
        EXCEPTIONS
          error_occured = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        "could not get a valid key
        IF dialog EQ btc_yes.
          MESSAGE s299 WITH stepcount mod_jobhead-jobname.
        ENDIF.
        CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
           ID 'KEY'  FIELD tbtcp_update_db_error
           ID 'DATA' FIELD mod_jobhead-jobname.
        CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
           ID 'KEY'  FIELD job_count
           ID 'DATA' FIELD mod_jobhead-jobcount.
        rc = 1.
        EXIT.
      ELSE.
        db_steplist-priparkey = tmp_key.
      ENDIF.

    ELSEIF mod_steplist-typ = btc_xcmd." Step executes external command
      db_steplist-extcmd = mod_steplist-program.
      db_steplist-xpgparams = mod_steplist-parameter.
      db_steplist-xpgflag = 'X'.
    ELSE. " Step führt ein externes Programm aus
      db_steplist-xpgprog   = mod_steplist-program.
      db_steplist-xpgparams = mod_steplist-parameter.
      db_steplist-xpgflag   = 'X'.
    ENDIF.

    db_steplist-sdldate  = sy-datum.
    db_steplist-sdltime  = sy-uzeit.
    db_steplist-sdluname = sy-uname.

    APPEND db_steplist.

    stepcount = stepcount + 1.
  ENDLOOP.
*
* Stepliste in DB updaten
*
  UPDATE tbtcp FROM TABLE db_steplist.

  IF sy-subrc NE 0.
    IF dialog EQ btc_yes.
      MESSAGE s120 WITH mod_jobhead-jobname.
    ENDIF.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtcp_update_db_error
          ID 'DATA' FIELD mod_jobhead-jobname.
    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD job_count
          ID 'DATA' FIELD mod_jobhead-jobcount.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                               " UPDATE_STEPLIST_IN_DB

*---------------------------------------------------------------------*
*      FORM INSERT_RELEASE_INFO_IN_DB                                 *
*---------------------------------------------------------------------*
* Fortschreiben der Starttermindaten eines Jobs in den entsprechenden *
* Datenbanktabellen und in den Jobkopfdaten.                          *
*                                                                     *
* Inputparameter:                                                     *
*                                                                     *
* - JOB_HEAD: Kopfdaten des Jobs dessen Freigabeinformationen fortzu- *
*             schreiben sind                                          *
* - STDT    : Starttermindaten des Jobs                               *
* - Dialog  : zeigt an, ob Routine im Dialogbetrieb gerufen wurde     *
*                                                                     *
* Outputparameter:                                                    *
*                                                                     *
*     - RC = 0: Update der Freigabeinformationen gelungen             *
*     - RC = 1: Update der Freigabeinformationen misslungen           *
*                                                                     *
* Folgende Fälle werden abgedeckt:                                    *
*                                                                     *
* - Starttermintyp = 'Sofort' / 'Datum / Uhrzeit' / 'an Arbeitstag'   *
*   - bei 'Sofort': - Jobstatus auf bereit setzen falls der Job       *
*                     wirklich sofort gestartet werden kann           *
*   - Jobdaten in TBTCS eintragen                                     *
*                                                                     *
* - Starttermintyp = 'Vorgänger'                                      *
*   - Anzahl Nachfolger des Vorgängerjobs um 1 inkrementieren         *
*   - Eintrag in Eventsteuertabelle BTCEVTJOB vornehmen der dafür     *
*     sorgt, daß der Job nach dem genannten Vorgängerjob gestartet    *
*     wird.                                                           *
*                                                                     *
* - Starttermintyp = 'Event'                                          *
*  - EventId in Eventsteuertabelle BTCEVTJOB eintragen. Dieser        *
*    sorgt dafür, daß der Job nach dem Eintreffen des spezifizier-    *
*    ten Events gestartet wird.                                       *
*                                                                     *
* Diese Routine verlässt sich darauf, daß:                            *
*                                                                     *
*   - zum Zeitpunkt ihres Aufrufs alle beim Insert beteiligten DB-    *
*     Tabelleneinträge gesperrt sind                                  *
*   - die Jobkopfdaten, die durch diese Routine upgedatet werden, vom *
*     Rufer in der TBTCO gespeichert werden                           *
*   - auf die in dieser Routine vorgenommenen DB-Veränderungen vom    *
*     Rufer entweder ein COMMIT oder ROLLBACK ausgeführt wird         *
*   - der Rufer die logischen Sperren zurücknimmt                     *
*   - der Rufer die Freigabeberechtigung des Benutzers geprüft hat    *
*                                                                     *
*---------------------------------------------------------------------*
FORM insert_release_info_in_db USING job_head STRUCTURE tbtcjob
                                     stdt     STRUCTURE tbtcstrt
                                     dialog
                                     rc.

data: cnt type i.

rc = 0.

* Starttermintyp = 'Sofort' / 'Datum / Uhrzeit' / 'an Arbeitstag':
* Sonderbehandlung bei 'Sofort': kann ein Job nicht unmittelbar auf
* einem Server auf Grund nicht freier Batchworkprozesse angestartet
* werden, so wird er in einen Job mit Starttermin Datum / Uhrzeit um-
* gewandelt (TBTCS-JOBGROUP = SPACE). Kann der Job aber unmittelbar von
* einem Server abgearbeitet werden, so wird TBTCS-JOBGROUP = %_IMMEDIATE
* gesetzt. Dieses Flag wird vom Batchscheduler ausgewertet.
*
  IF stdt-startdttyp EQ btc_stdt_immediate OR
     stdt-startdttyp EQ btc_stdt_datetime  OR
     stdt-startdttyp EQ btc_stdt_onworkday.

***** c5034979 XBP 2.0. Change. Begin. *****
    DELETE FROM tbtcs
      WHERE jobname  = job_head-jobname AND
            jobcount = job_head-jobcount.
***** c5034979 XBP 2.0. Change. End. *****
    CLEAR tbtcs.

    MOVE-CORRESPONDING job_head TO tbtcs.

    GET TIME.

    IF stdt-startdttyp EQ btc_stdt_immediate.
      job_head-sdlstrtdt = sy-datum.
      job_head-sdlstrttm = sy-uzeit.
      tbtcs-sdlstrtdt    = sy-datum.
      tbtcs-sdlstrttm    = sy-uzeit.
      job_head-status    = btc_released.
      IF stdt-imstrtpos EQ true.       " Sofortstart möglich
        tbtcs-jobgroup  = immediate_flag.
      ELSE.
        CLEAR tbtcs-jobgroup.
      ENDIF.
    ELSE.
      CLEAR tbtcs-jobgroup.
    ENDIF.

    INSERT tbtcs.

    IF sy-subrc NE 0.
      IF dialog EQ btc_yes.
        MESSAGE s117 WITH job_head-jobname.
      ENDIF.
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD tbtcs_insert_db_error
            ID 'DATA' FIELD job_head-jobname.
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
             ID 'KEY'  FIELD job_count
             ID 'DATA' FIELD job_head-jobcount.
      rc = 1.
      EXIT.
    ENDIF.

  ELSEIF stdt-startdttyp EQ btc_stdt_afterjob.

* 14.12.2012    note 1801159    d023157
* in any case we need to step into the routine gen_eventcount.
* Only in this routine we have a proper algorithm with
* existence check - enque - existence check

* However, since the job deletion does not enqueue the
* btcevtjob entry, we may - wth a very, very little likelihood
* generate an eventcount, which leads to a failed insert in
* table btcevtjob later on.
* Therefore we try several times. 10 should really be enough.

    do 10 times.
       cnt = cnt + 1.

       PERFORM gen_eventcount USING     " neuen Eventcount
                             btc_eventid_eoj     " generieren
                             job_head-eventcount
                             rc.

       IF rc NE 0.

          if cnt >= 10.
             IF dialog EQ btc_yes.   " Syslogeintrag wurde schon gemacht
                MESSAGE s116 WITH btc_eventid_eoj.
             ENDIF.
             rc = 1.
             EXIT.
          else.
             continue.
          endif.

       ENDIF.

*
*    Den Job als nach dem Vorgängerjob zu startend in Event-
*    steuertabelle BTCEVTJOB eintragen und "scharf" machen
*
       CLEAR btcevtjob.
       btcevtjob-eventid    = btc_eventid_eoj.
       btcevtjob-eventcount = job_head-eventcount.
       btcevtjob-eventparm  = job_head-eventparm.
       btcevtjob-jobname    = job_head-jobname.
       btcevtjob-jobcount   = job_head-jobcount.
       btcevtjob-activated  = btc_event_activated.  " Event scharf machen


       IF stdt-checkstat EQ 'X'.          " Job nur starten,
          btcevtjob-procmode = btc_predjob_checkstat.  " wenn Vorgängerjob
       ENDIF.                             " fehlerfrei

       INSERT btcevtjob.

       IF sy-subrc NE 0.

          if cnt >= 10.

             IF dialog EQ btc_yes.
                MESSAGE s119 WITH stdt-predjob.
             ENDIF.

             CALL FUNCTION 'DEQUEUE_BTCEVTJOB'
                 EXPORTING
                    eventid    = btcevtjob-eventid
                    eventcount = btcevtjob-eventcount.

             CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD btcevtjob_insert_db_error
                ID 'DATA' FIELD stdt-predjob.

             CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD eventid_in_error_info
                ID 'DATA' FIELD btc_eventid_eoj.

             rc = 1.
             EXIT.

          else.
             continue.
          endif.   " if cnt >= 10

       else.

          rc = 0.
          exit.

       ENDIF. " End of 'insert failed' treatment

    enddo.

  ELSEIF stdt-startdttyp EQ btc_stdt_event.

* 14.12.2012    note 1801159    d023157
* in any case we need to step into the routine gen_eventcount.
* Only in this routine we have a proper algorithm with
* existence check - enque - existence check

* However, since the job deletion does not enqueue the
* btcevtjob entry, we may - wth a very, very little likelihood
* generate an eventcount, which leads to a failed insert in
* table btcevtjob later on.
* Therefore we try several times. 10 should really be enough.

    do 10 times.
       cnt = cnt + 1.

       PERFORM gen_eventcount USING     " neuen Eventcount
                             job_head-eventid    " generieren
                             job_head-eventcount
                             rc.

       IF rc NE 0.

          if cnt >= 10.
             IF dialog EQ btc_yes.   " Syslogeintrag wurde schon gemacht
                MESSAGE s116 WITH stdt-eventid.
             ENDIF.
             rc = 1.
             EXIT.
          else.
             continue.
          endif.

       ENDIF.

*
*    Den Job als nach dem Event zu startend in Eventsteuertabelle
*    BTCEVTJOB eintragen und "scharf" machen
*
       CLEAR btcevtjob.
       btcevtjob-eventid    = job_head-eventid.
       btcevtjob-eventcount = job_head-eventcount.
       btcevtjob-eventparm  = job_head-eventparm.
       btcevtjob-jobname    = job_head-jobname.
       btcevtjob-jobcount   = job_head-jobcount.
       btcevtjob-activated  = btc_event_activated. " Event scharf machen

       INSERT btcevtjob.

       IF sy-subrc NE 0.

          if cnt >= 10.

             IF dialog EQ btc_yes.
                MESSAGE s124 WITH job_head-jobname.
             ENDIF.

             CALL FUNCTION 'DEQUEUE_BTCEVTJOB'
                EXPORTING
                   eventid    = btcevtjob-eventid
                   eventcount = btcevtjob-eventcount.

             CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD btcevtjob_insert_db_error
                ID 'DATA' FIELD job_head-jobname.

             CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD job_count
                ID 'DATA' FIELD job_head-jobcount.

             CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD eventid_in_error_info
                ID 'DATA' FIELD job_head-eventid.

             rc = 1.
             EXIT.

          else.
             continue.
          endif.

       else.

          rc = 0.
          exit.

       ENDIF. " End of 'insert failed' treatment

    enddo.

  ENDIF.

ENDFORM.                               " INSERT_RELEASE_INFO_IN_DB

*---------------------------------------------------------------------*
*      FORM RESET_RELEASE_INFO_IN_DB                                  *
*---------------------------------------------------------------------*
* Freigabedaten (Starttermindaten) eines Jobs in der DB löschen       *
*                                                                     *
* Diese Routine verlässt sich darauf, daß der Rufer den entsprechenden*
* Job bereits gesperrt hat.                                           *
*                                                                     *
* Achtung ! COMMIT bzw. ROLLBACK ist vom Rufer auszuführen            *
*                                                                     *
*---------------------------------------------------------------------*

FORM reset_release_info_in_db USING jobhead  STRUCTURE tbtcjob
                                    job_stdt STRUCTURE tbtcstrt
                                    dialog
                                    rc.

  rc = 0.

  IF job_stdt-startdttyp EQ btc_stdt_datetime  OR
     job_stdt-startdttyp EQ btc_stdt_immediate OR
     job_stdt-startdttyp EQ btc_stdt_onworkday.

    PERFORM delete_tbtcs USING jobhead dialog CHANGING rc.

  ELSEIF job_stdt-startdttyp EQ btc_stdt_afterjob OR
         job_stdt-startdttyp EQ btc_stdt_event.

    PERFORM delete_btcevtjob USING jobhead dialog CHANGING rc.

  ENDIF.

ENDFORM.                               " RESET_RELEASE_INFO_IN_DB

*---------------------------------------------------------------------*
*      FORM GET_SRVNAME_FOR_JOB_EXEC                                  *
*---------------------------------------------------------------------*
* Rechner- und Servername für Jobausführung ermitteln abhängig        *
* vom vorgegebenen Zielrechnername und vom Starttermintyp des Jobs:   *
*                                                                     *
* - Ist eine Zielmaschine (TARGET_MACHINE) angegeben, so wird zu-     *
*   nächst geprüft, ob die Zielmaschine in einer Betriebsart definiert*
*   ist (wird erst später aktiviert). Bei Starttermintyp = 'Sofort'   *
*   wird der Instanzname auf dem Zielrechner ermittelt und geprüft,   *
*   ob dort ein Batchworkprozess frei ist.                            *
*                                                                     *
* - Ist keine Zielmaschine angegeben, so wird versucht, abhängig von  *
*   Starttermintyp und Jobklasse, einen freien Batchserver zu finden  *
* Status: ALT (5.2.99), ersetzt durch check_server_for_job_exec       *
*---------------------------------------------------------------------*

FORM get_srvname_for_job_exec USING target_machine
                                    target_servername
                                    startdate STRUCTURE tbtcstrt
                                    jobclass
                                    rc.
  IF target_machine NE space.
    PERFORM check_target_server USING target_machine
                                      target_servername
                                      startdate
                                      jobclass
                                      rc.
    IF rc NE 0.
      EXIT.                            " RC nach oben weitergeben
    ENDIF.
  ELSE.
    PERFORM find_free_batch_server USING target_machine
                                         target_servername
                                         startdate
                                         jobclass
                                         rc.

    IF startdate-startdttyp NE btc_stdt_immediate.
      CLEAR target_machine.
      CLEAR target_servername.
    ENDIF.

    IF rc NE 0.
      EXIT.                            " RC nach oben weitergeben
    ENDIF.
  ENDIF.

  rc = 0.

ENDFORM.                               " GET_SRVNAME_FOR_JOB_EXEC

*---------------------------------------------------------------------*
*      FORM CHECK_SERVER_FOR_JOB_EXEC                                 *
*---------------------------------------------------------------------*
* Given: a executing appserver   TARGET_SERVER                        *
* - try to find out whether the appserver is defined in Opmode for BTC*
* - case start immediate: BTC-WPs available?                          *
* - If no TARGET_SERVER is specified try to find some appserver that  *
*   fits the jobclass and the start date                              *
* returns: RC, TARGET_HOST                                            *
*---------------------------------------------------------------------*

FORM check_server_for_job_exec USING target_server
                                     target_host
                                     startdate STRUCTURE tbtcstrt
                                     jobclass
                                     rc.

  IF target_server NE space.
    PERFORM check_target_server USING  target_host
                                       target_server
                                       startdate
                                       jobclass
                                       rc.
    IF rc NE 0.
      EXIT.                            " RC nach oben weitergeben
    ENDIF.
  ELSE.
    PERFORM find_free_batch_server USING target_host
                                         target_server
                                         startdate
                                         jobclass
                                         rc.

    IF startdate-startdttyp NE btc_stdt_immediate.
      CLEAR target_host.
      CLEAR target_server.
    ENDIF.

    IF rc NE 0.
      EXIT.                            " RC nach oben weitergeben
    ENDIF.
  ENDIF.

  rc = 0.

ENDFORM.                               " CHECK_SERVER_FOR_JOB_EXEC

*---------------------------------------------------------------------*
*      FORM CHECK_OPERATION_PRIVILEGE                                 *
*---------------------------------------------------------------------*
* Diese Routine prüft, ob der Benutzer berechtigt ist, verändernde    *
* Operationen auf Jobs auszuführen. Berechtigung liegt vor, wenn:     *
*                                                                     *
*   - der entsprechende Job vom Benutzer selbst erzeugt worden ist    *
*     oder                                                            *
*   - wenn der Benutzer Batchadminstratorberechtigung hat             *
*                                                                     *
* Wenn die Berechtigung vorliegt, wird RC = 0 ansonsten RC ungleich   *
* 0 gesetzt.                                                          *
*                                                                     *
*---------------------------------------------------------------------*

FORM check_operation_privilege USING job_creator_name rc.

  IF job_creator_name NE sy-uname.
    PERFORM check_batch_admin_privilege.
    IF batch_admin_privilege_given EQ btc_no .
       rc = 1.

       perform check_special_modi_privilege using job_creator_name rc.

       if rc = 1.
          EXIT.
       endif.

    ENDIF.
  ENDIF.

  rc = 0.

ENDFORM.                               " CHECK_OPERATION_PRIVILEGE

*---------------------------------------------------------------------*
*      FORM CHECK_EARLY_WATCH_PRIVILEGE                               *
*---------------------------------------------------------------------*
* Prüfe, ob Benutzer Early-Watch-Berechtigung hat. Diese Routine      *
* setzt die globale Variable EARLY_WATCH_PRIVILEGE_GIVEN              *
*---------------------------------------------------------------------*

FORM check_early_watch_privilege.

  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
     ID 'S_ADMI_FCD' FIELD 'ST0R'.

  IF sy-subrc EQ 0.
    early_watch_privilege_given = btc_yes.
  ELSE.
    early_watch_privilege_given = btc_no.
  ENDIF.

ENDFORM.                               " CHECK_EARLY_WATCH_PRIVILEGE.

*---------------------------------------------------------------------*
*      FORM CHECK_JOB_PLAN_PRIVILEGE                                  *
*---------------------------------------------------------------------*
* Prüfe, ob Benutzer berechtigt ist, Jobs einzuplanen. Wenn er die    *
* Berechtigung hat, wird RC = 0 gesetzt, ansonsten ist RC != 0        *
*---------------------------------------------------------------------*

FORM check_job_plan_privilege USING rc.

*  AUTHORITY-CHECK OBJECT 'S_BTCH_JOB'      wird erst nach 2.1G akti-
*     ID 'JOBGROUP'  FIELD TBTCO-JOBGROUP   viert, weil Anwendung sonst
*     ID 'JOBACTION' FIELD 'PLAN'.          zu viele Probleme bekommt
*
*  IF SY-SUBRC EQ 0.
*     RC = 0.
*  ELSE.
*     RC = 1.
*  ENDIF.

  rc = 0.

ENDFORM.                               " CHECK_JOB_PLAN_PRIVILEGE

*---------------------------------------------------------------------*
*      FORM CHECK_JOB_SHOW_PRIVILEGE                                  *
*---------------------------------------------------------------------*
* Prüfe, ob Benutzer berechtigt ist, den Job anzuzeigen               *
*---------------------------------------------------------------------*

FORM check_job_show_privilege USING rc.

  AUTHORITY-CHECK OBJECT 'S_BTCH_JOB'
     ID 'JOBGROUP'  FIELD tbtco-jobgroup
     ID 'JOBACTION' FIELD 'SHOW'.

  IF sy-subrc EQ 0.
    rc = 0.
  ELSE.
    rc = 1.
  ENDIF.

ENDFORM.                               " CHECK_JOB_SHOW_PRIVILEGE

*---------------------------------------------------------------------*
*      FORM INSERT_JOBLOG_MESSAGE                                     *
*---------------------------------------------------------------------*
* Diese Routine fügt einen Eintrag in das Jobprotokoll eines Jobs ein *
*                                                                     *
* Parameter: - MessageId                                              *
*            - Messagetyp (S, W, A, I, ...)                           *
*                                                                     *
*---------------------------------------------------------------------*

FORM insert_joblog_message USING jobhead STRUCTURE tbtcjob
                                 msg_id msg_type.

  DATA BEGIN OF joblog_msg.
          INCLUDE STRUCTURE btclog_cod.
  DATA END OF joblog_msg.

  DATA: write_failed_data(32),
        logmsg LIKE btctle-logmessage.
*
*   Job-Protokoll Eintrag aufbauen und wegschreiben
*
  joblog_msg-format     = 'F'.
  DESCRIBE FIELD btclog_cod-arbgb LENGTH joblog_msg-arbgbln
                                            IN CHARACTER MODE .
  joblog_msg-arbgb      = 'BT'.
  DESCRIBE FIELD btclog_cod-msgnr LENGTH joblog_msg-msgnrln
                                            IN CHARACTER MODE .
  joblog_msg-msgnr      = msg_id.
  DESCRIBE FIELD btclog_cod-usrmsgtype LENGTH joblog_msg-msgtypln
                                            IN CHARACTER MODE .
  joblog_msg-usrmsgtype = msg_type.
  joblog_msg-exitcode   = '09'.
  joblog_msg-numpar     = 0.
  CLEAR joblog_msg-params.
  logmsg = joblog_msg.

  CALL FUNCTION 'COMMON_LOG_WRITE_S_PLAIN'
    EXPORTING
      logname = jobhead-joblog
      entry   = logmsg
    EXCEPTIONS
      OTHERS  = 99.

  IF sy-subrc NE 0.
* ToDo(msg)
* if syslog adapts long msgids this might be due to change
    write_failed_data+0(3) = msg_id.
    write_failed_data+3(2) = 'BT'.
    CALL 'C_WRITE_SYSLOG_ENTRY'
      ID 'TYP' FIELD ' '
      ID 'KEY' FIELD write_msg_failed
      ID 'DATA' FIELD write_failed_data.
    CALL 'C_WRITE_SYSLOG_ENTRY'
      ID 'TYP' FIELD ' '
      ID 'KEY' FIELD job_name
      ID 'DATA' FIELD jobhead-jobname.
    CALL 'C_WRITE_SYSLOG_ENTRY'
      ID 'TYP' FIELD ' '
      ID 'KEY' FIELD job_count
      ID 'DATA' FIELD jobhead-jobcount.
  ENDIF.

ENDFORM.                               " INSERT_JOBLOG_MESSAGE

*---------------------------------------------------------------------*
*      FORM BUILD_DEFAULT_PLIST_NAME                                  *
*---------------------------------------------------------------------*
* Diese Routine bildet aus einem gegebenen Reportnamen den Default-   *
* wert für den Listennamen im Spool.                                  *
*---------------------------------------------------------------------*

FORM build_default_plist_name USING report_name plist_name user_name.
* insertion note 551809, user_name added

  plist_name = report_name.
  DESCRIBE FIELD plist_name LENGTH len IN CHARACTER MODE .
  offset = strlen( plist_name ).
  IF offset < len.
    WRITE '_' TO plist_name+offset(1).
  ENDIF.
  offset = strlen( plist_name ).
  len    = len - offset.
  IF len >= 3.
    IF user_name EQ space.                      " note 551809
      user_name = sy-uname.                      " note 551809
    ENDIF.                                        " note 551809
    WRITE user_name TO plist_name+offset(3).  " note 551809
  ENDIF.

ENDFORM.                               " BUILD_DEFAULT_PLIST_NAME

*---------------------------------------------------------------------*
*      FORM CHECK_REPORT                                              *
*---------------------------------------------------------------------*
* Einen Report auf folgende Punkte hin untersuchen:                   *
*                                                                     *
*  - auf Existenz                                                     *
*  - auf Einplanbarkeit in Hintergrundjobs                            *
*  - auf Berechtigung des aktiven Benutzers, den Report einzuplanen   *
*                                                                     *
*  Falls Report alle Kriterien erfüllt wird RC = 0, ansonsten         *
*  ein entsprechender Fehlercode an den Rufer zurückgegeben.          *
*                                                                     *
*---------------------------------------------------------------------*

FORM check_report USING report_name rc no_auth_check.

  DATA:
    p_secu TYPE trdir-secu,
    p_subc TYPE trdir-subc.

  CLEAR rc.

  SELECT SINGLE subc secu FROM trdir INTO (p_subc, p_secu)
    WHERE name = report_name.
  IF sy-subrc <> 0.
    rc = report_doesnt_exist.
    EXIT.
  ENDIF.

  IF p_subc <> '1'.
    rc = report_not_to_be_scheduled.
    EXIT.
  ENDIF.

  IF no_auth_check IS NOT INITIAL.   " note 769039
    EXIT.
  ENDIF.

  IF p_secu IS INITIAL.
    EXIT.
  ENDIF.

  IF btch1120-authcknam IS INITIAL.
    MOVE sy-uname TO btch1120-authcknam.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'S_PROGRAM'
    FOR USER btch1120-authcknam
    ID 'P_GROUP'  FIELD p_secu
    ID 'P_ACTION' FIELD 'BTCSUBMIT'.
  IF sy-subrc <> 0.
    rc = no_assign_privilege_for_job.
    EXIT.
  ENDIF.

ENDFORM.                               " CHECK_REPORT.

*---------------------------------------------------------------------*
*       FORM FIELDCAT_INIT                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FIELDCAT_TBL                                                  *
*---------------------------------------------------------------------*
FORM fieldcat_init TABLES fieldcat_tbl TYPE slis_t_fieldcat_alv.

  DATA: jobname_len TYPE i,
        sdluname_len TYPE i,
        statusname_len TYPE i,
        slide_type_status_len TYPE i,
        targserver_len TYPE i,
        reaxserver_len TYPE i,
        lastchname_len TYPE i,
        jobclass_len TYPE i,
        authckman_len TYPE i.


  DESCRIBE FIELD tbtco-jobname LENGTH jobname_len
                                      IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-sdluname LENGTH sdluname_len
                                       IN CHARACTER MODE.

  DESCRIBE FIELD output_joblist-statusname LENGTH statusname_len
                                                  IN CHARACTER MODE.
  DESCRIBE FIELD output_joblist-slide_type_status
           LENGTH slide_type_status_len
                  IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-execserver LENGTH targserver_len
                                         IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-reaxserver LENGTH reaxserver_len
                                         IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-lastchname LENGTH lastchname_len
                                         IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-jobclass LENGTH jobclass_len
                                       IN CHARACTER MODE.
  DESCRIBE FIELD tbtco-authckman LENGTH authckman_len
                                        IN CHARACTER MODE.

  CLEAR fieldcat_tbl.
  REFRESH fieldcat_tbl.

  DATA: p_grid LIKE reuse_alv_type.
  PERFORM get_current_display_function USING p_grid.

  IF p_grid = 'L'.
    fieldcat_tbl-tabname      = 'OUTPUT_JOBLIST'.
    fieldcat_tbl-fieldname    = 'MARKED'.    " hgk  wg. Umstellung auf
    fieldcat_tbl-reptext_ddic = space.       " Grid auskommentiert
    fieldcat_tbl-outputlen    = 1.
    APPEND fieldcat_tbl.
  ENDIF.

  fieldcat_tbl-fieldname     = 'JOBNAME'.
  fieldcat_tbl-reptext_ddic  = text-602.
  fieldcat_tbl-outputlen     = jobname_len.
  fieldcat_tbl-just         = 'L'.
  fieldcat_tbl-key           = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic  = text-721.
  fieldcat_tbl-fieldname     = 'SPOOL_ICON'.
  fieldcat_tbl-icon          = 'X'.
  fieldcat_tbl-fix_column    = 'X'.
  fieldcat_tbl-outputlen     = 5.
  APPEND fieldcat_tbl.

*  19.6.2009  d023157  icon for JSM jobs

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic  = text-820.
  fieldcat_tbl-fieldname     = 'JSM_ICON'.
  fieldcat_tbl-icon          = 'X'.
  fieldcat_tbl-fix_column    = 'X'.
  fieldcat_tbl-outputlen     = 7.
  APPEND fieldcat_tbl.

* end  19.6.2009  d023157 **************

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'SDLUNAME'.
  fieldcat_tbl-reptext_ddic = text-603.
  fieldcat_tbl-outputlen    = sdluname_len.
  fieldcat_tbl-just         = 'L'.
*  fieldcat_tbl-lowercase    = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic = text-604.
  fieldcat_tbl-fieldname    = 'STATUSNAME'.
  fieldcat_tbl-outputlen    = statusname_len.
  fieldcat_tbl-lowercase    = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'STRTDATE'.
  fieldcat_tbl-reptext_ddic = text-605.
* fix for filtering date field - 50
  fieldcat_tbl-datatype     = 'DATS'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'STRTTIME'.
  fieldcat_tbl-reptext_ddic = text-606.
  fieldcat_tbl-datatype     = 'TIMS'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic = text-607.
  fieldcat_tbl-fieldname    = 'DURATION'.
  fieldcat_tbl-just         = 'R'.
  fieldcat_tbl-do_sum       = 'X'.
  fieldcat_tbl-datatype     = 'INT4'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic = text-608.
  fieldcat_tbl-fieldname    = 'DELAYTIME'.
  fieldcat_tbl-just         = 'L'.
  fieldcat_tbl-do_sum       = 'X'.
  fieldcat_tbl-datatype     = 'INT4'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-reptext_ddic = text-631.
  fieldcat_tbl-fieldname    = 'SLIDE_TYPE_STATUS'.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = slide_type_status_len.
  APPEND fieldcat_tbl.

* adding target server from 5.0+
  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'EXECSERVER'.
  fieldcat_tbl-reptext_ddic = text-267.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = targserver_len.
  fieldcat_tbl-lowercase    = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'REAXSERVER'.
  fieldcat_tbl-reptext_ddic = text-609.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = reaxserver_len.
  fieldcat_tbl-lowercase    = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'LASTCHNAME'.
  fieldcat_tbl-reptext_ddic = text-610.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = lastchname_len.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'SDLSTRTDT'.
  fieldcat_tbl-reptext_ddic = text-611.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-datatype     = 'DATS'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'SDLSTRTTM'.
  fieldcat_tbl-reptext_ddic = text-612.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-datatype     = 'TIMS'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'ENDDATE'.
  fieldcat_tbl-reptext_ddic = text-613.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-datatype     = 'DATS'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'ENDTIME'.
  fieldcat_tbl-reptext_ddic = text-614.
  fieldcat_tbl-datatype     = 'TIMS'.
  fieldcat_tbl-no_out       = 'X'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'JOBCLASS'.
  fieldcat_tbl-reptext_ddic = text-615.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = jobclass_len.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'AUTHCKMAN'.
  fieldcat_tbl-reptext_ddic = text-628.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-outputlen    = authckman_len.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'JOBCOUNT'.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-ref_tabname = 'TBTCO'.
  fieldcat_tbl-ref_fieldname = 'JOBCOUNT'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'WPNUMBER'.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-ref_tabname = 'TBTCO'.
  fieldcat_tbl-ref_fieldname = 'WPNUMBER'.
  APPEND fieldcat_tbl.

  CLEAR fieldcat_tbl.
  fieldcat_tbl-fieldname    = 'WPPROCID'.
  fieldcat_tbl-no_out       = 'X'.
  fieldcat_tbl-ref_tabname = 'TBTCO'.
  fieldcat_tbl-ref_fieldname = 'WPPROCID'.
  APPEND fieldcat_tbl.

ENDFORM.                               " FIELDCAT_INIT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build USING layout_tbl TYPE slis_layout_alv.

  DATA: p_grid LIKE reuse_alv_type.
  PERFORM get_current_display_function USING p_grid.

  CLEAR layout_tbl.
  layout_tbl-zebra              = 'X'.
  layout_tbl-detail_popup       = 'X'.
  layout_tbl-detail_titlebar    = text-600.
  layout_tbl-no_vline           = ' '.
  layout_tbl-numc_sum           = 'X'.
  IF p_grid = 'G'.
    layout_tbl-cell_merge         = 'N'.
  ENDIF.
  layout_tbl-totals_text        = text-601.
  layout_tbl-max_linesize       = 500.
  layout_tbl-box_fieldname      = 'MARKED'.
  layout_tbl-box_tabname        = 'OUTPUT_JOBLIST'.
  layout_tbl-coltab_fieldname   = 'COLORIZE_STATUS'.
  layout_tbl-hotspot_fieldname  = 'SPOOL_ICON'.
*  layout_tbl-colwidth_optimize  = 'X'.

ENDFORM.                               " LAYOUT_BUILD

*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
FORM user_command
  USING r_ucomm     LIKE sy-ucomm
        rs_selfield TYPE slis_selfield.

  DATA:
    answer(1)          TYPE c,
    count              TYPE i VALUE 0,
    mark_multi_flag(1) TYPE c VALUE ' ',
    selected_job_name  LIKE tbtco-jobname,
    selected_job_count LIKE tbtco-jobcount,
    index1             TYPE i,
    previous_opcode    TYPE btch0000-int4.

* c5034979, 29.10.2002
  previous_opcode = job_editor_opcode.

  DATA: my_server_name TYPE btcsrvname,
        dest TYPE msxxlist-name,
        rfc_msg(200),
        reaxserver TYPE tbtcjob-reaxserver,
        execserver TYPE tbtcjob-execserver.

  DATA: redirect.
  DATA: ssm_answer.

  DATA: job_ssm_guid TYPE btcctxt.
  DATA: cnt_ssm TYPE i.


* c5034979, 16.01.2003
  DATA: p_grid LIKE reuse_alv_type.
  PERFORM get_current_display_function USING p_grid.
  IF p_grid = 'L'.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
      IMPORTING
        es_list_scroll = jov_list_scroll_info
        et_fieldcat    = prev_fieldcat[]
        et_sort        = prev_sort[]
        et_filter      = prev_filter[]
      EXCEPTIONS
        OTHERS         = 99.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
      IMPORTING
        es_layout      = gs_layout
        es_grid_scroll = jov_grid_scroll_info
        et_fieldcat    = prev_fieldcat[]
        et_sort        = prev_sort[]
        et_filter      = prev_filter[]
      EXCEPTIONS
        OTHERS         = 99.
  ENDIF.
* c5034979, 16.01.2003

  IF sy-subrc NE 0.
    CLEAR jov_list_scroll_info.
    MESSAGE e645 WITH text-746 sy-subrc.
  ENDIF.

  CLEAR marked_itab.
  REFRESH marked_itab.

  LOOP AT output_joblist.
    IF output_joblist-marked = 'X'.
      index1 = sy-tabix.
      count = count + 1.
      MOVE-CORRESPONDING output_joblist TO marked_itab.
      APPEND marked_itab.
    ENDIF.
  ENDLOOP.
  IF count > 1.
    mark_multi_flag = 'X'.
  ENDIF.

  READ TABLE output_joblist INDEX rs_selfield-tabindex.


  DATA: jobsel_param_in_backup LIKE jobsel_param_in,
          wa_marked LIKE marked_itab.

  CASE r_ucomm.
    WHEN 'BKWD' OR 'GOUT' OR 'CNCL'.   "when user wants to exit
      CLEAR jov_list_scroll_info.
      rs_selfield-exit = 'X'.
      refresh_list_flag = ' '.
      exit_signal = 'X'.

* c5035006 06.03.2006
*Job statistic
    WHEN 'JSTA'.
      DATA: wa_joblist TYPE tbtck,
            t_joblist TYPE btc_t_joblist,
            jobstat TYPE REF TO if_bp_job_statistic,
            exception TYPE REF TO cx_bp_job_statistic.

      TRY.
          IF mark_multi_flag = 'X'.
            LOOP AT marked_itab INTO wa_marked.
              wa_joblist-jobname = wa_marked-jobname.
              wa_joblist-jobcount = wa_marked-jobcount.
              APPEND wa_joblist TO t_joblist.
            ENDLOOP.
            CREATE OBJECT jobstat
              TYPE
              cl_bp_joblist_statistic
              EXPORTING
                i_t_joblist = t_joblist.
          ELSE.
            CREATE OBJECT jobstat
              TYPE
              cl_bp_job_statistic
              EXPORTING
                i_jobname  = output_joblist-jobname
                i_jobcount = output_joblist-jobcount.
          ENDIF.

          jobstat->read( ).
          jobstat->show( ).

        CATCH cx_bp_job_statistic INTO exception.
          exception->show_as_infomessage( ).
      ENDTRY.

* c5035006 04.05.2006
*Application log entries
    WHEN 'APLG'.
      DATA:
        l_s_display_profile TYPE bal_s_prof,
        i_s_log_filter TYPE bal_s_lfil,
        t_log_handle TYPE  bal_t_logh.
      DATA:
        t_btc_loghandle TYPE btc_t_loghandle,
        wa_btc_loghandle TYPE btc_s_loghandle.

      IF marked_itab IS INITIAL.
        wa_marked-jobname = output_joblist-jobname.
        wa_marked-jobcount = output_joblist-jobcount.
        APPEND wa_marked TO marked_itab.
      ENDIF.
      LOOP AT marked_itab INTO wa_marked.
        FREE t_btc_loghandle.
        CALL FUNCTION 'BP_GET_APPLICATION_INFO'
          EXPORTING
            jobname             = wa_marked-jobname
            jobcount            = wa_marked-jobcount
          IMPORTING
            t_loghandles        = t_btc_loghandle
          EXCEPTIONS
            job_does_not_exist  = 1
            step_does_not_exist = 2
            nothing_found       = 3
            OTHERS              = 4.
        IF sy-subrc <> 0.
* Handle exceptions later
        ENDIF.
        LOOP AT t_btc_loghandle INTO wa_btc_loghandle.
          INSERT  wa_btc_loghandle-loghandle INTO TABLE t_log_handle.
        ENDLOOP.
      ENDLOOP.
      IF t_log_handle IS INITIAL.
        MESSAGE s460 DISPLAY LIKE 'W'.
*   Keine Applikationsprotokolle wurden in der Datenbank gefunden
        EXIT.
      ENDIF.

      CALL FUNCTION 'BAL_GLB_MEMORY_REFRESH'
        EXCEPTIONS
          not_authorized = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'BAL_DB_LOAD'
        EXPORTING
          i_t_log_handle     = t_log_handle
        EXCEPTIONS
          no_logs_specified  = 1
          log_not_found      = 2
          log_already_loaded = 0
          OTHERS             = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      l_s_display_profile-use_grid = 'X'.
      l_s_display_profile-exp_level = 0.
      l_s_display_profile-disvariant-report = sy-repid.
      l_s_display_profile-disvariant-handle = 'SM37APPLOG'.

* call display function module
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
        EXPORTING
*         i_s_log_filter      = i_s_log_filter
          i_s_display_profile = l_s_display_profile
        EXCEPTIONS
          OTHERS              = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*** end c5035006

    WHEN '&OUP' OR '&ODN'.
      SORT output_joblist ASCENDING BY jobname
                                       sdluname
                                       slide_type_status
                                       sdlstrtdt
                                       sdlstrttm.
      rs_selfield-refresh = 'X'.
      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.

    WHEN '&IC1'.                       "when double click
      IF rs_selfield-tabindex EQ 0.
        MESSAGE e019.
        EXIT.
      ENDIF.

      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF rs_selfield-fieldname = 'SPOOL_ICON'.
        PERFORM show_spoollist_sm37b
          USING output_joblist-jobname output_joblist-jobcount.

*---------------------------------------------------------------------
      ELSEIF ( rs_selfield-fieldname = 'JSM_ICON'
               AND output_joblist-jsm_icon = icon_document ).

* d023157 16.7.2009   in this case show the job documentation
        CALL FUNCTION 'BP_JOB_SOLMAN_SHOW_DOCUMENT'
          EXPORTING
            iv_jobname                     = output_joblist-jobname
            iv_jobcount                    = output_joblist-jobcount
*           IV_JOB_REQ_GUID                =
          EXCEPTIONS
            communication_error            = 1
            solman_destination_missing     = 2
            error_in_connection_to_solman  = 3
            error_starting_browser         = 4
            jobdocid_in_jobcontext_missing = 5
            jobdoc_not_found_in_solman     = 6
            OTHERS                         = 7.

        IF sy-subrc <> 0.

          CASE sy-subrc.

            WHEN 0.
              " alles ok.

            WHEN 1.
              MESSAGE ID sy-msgid TYPE 'W'
                  NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2
                       sy-msgv3 sy-msgv4
                       DISPLAY LIKE 'E'.

            WHEN 2.
              MESSAGE w884 DISPLAY LIKE 'E'.

            WHEN 3.
              MESSAGE ID sy-msgid TYPE 'W'
                  NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2
                  sy-msgv3 sy-msgv4
                  DISPLAY LIKE 'E'.

            WHEN 4.
              MESSAGE w885 DISPLAY LIKE 'E'.

            WHEN 5.
              MESSAGE w886 DISPLAY LIKE 'E'.

            WHEN 6.
              MESSAGE w887 DISPLAY LIKE 'E'.

            WHEN OTHERS.
              MESSAGE w720
                  WITH 'unknown error'
                       'BP_JOB_SOLMAN_SHOW_DOCUMENT'
                        DISPLAY LIKE 'E'.

          ENDCASE.

        ENDIF.
*---------end of elseif ----------------------------------------------

      ELSE.
        PERFORM show_job_sm37b TABLES output_joblist
                                 USING output_joblist-jobname
                                       output_joblist-jobcount.
      ENDIF.


    WHEN 'JPRO'.                       " show job log
      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

      READ TABLE output_joblist INDEX index1.


* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.
      CALL FUNCTION 'BP_JOBLOG_SHOW_SM37B'    "go to job log
          EXPORTING
               client                    = sy-mandt
               jobcount                  = selected_job_count
               jobname                   = selected_job_name
           EXCEPTIONS
                error_reading_jobdata     = 1
                error_reading_joblog_data = 2
                jobcount_missing          = 3
                joblog_does_not_exist     = 4
                joblog_is_empty           = 5
                joblog_show_canceled      = 6
                jobname_missing           = 7
                job_does_not_exist        = 8
                no_joblog_there_yet       = 9
                no_show_privilege_given   = 10
                OTHERS                    = 11.

    WHEN 'REFR'.   " refreshing the list
* d023157  6.8.2003
* special treatment for ADK
* see customer message 590995 / 2003
      IF sy-tcode = 'SARA' OR bp_ext_refresh IS NOT INITIAL.
        CLEAR jov_list_scroll_info.
        rs_selfield-exit = 'X'.
        refresh_list_flag = 'X'.
        exit_signal = 'X'.
      ELSE.
        PERFORM refresh_alv_list USING rs_selfield.
      ENDIF.

    WHEN 'RELE'.                       " release the job
* d023157    16.3.2008
* Solution Manager: If a user matches the criteria.
* he is not allowed to release jobs.
      CLEAR redirect.
      PERFORM check_ssmjob_criteria CHANGING redirect.

      IF mark_multi_flag = 'X'.

        IF redirect = 'Y'.
          MESSAGE i799.
          EXIT.
        ENDIF.

        PERFORM jobtab_contains_solmanjob TABLES marked_itab
                                          USING  ssm_answer.

        IF ssm_answer = 'Y'.
          MESSAGE i883.
          EXIT.
        ENDIF.

        PERFORM release_jobs TABLES sel_joblist
                                    marked_itab.
        MOVE-CORRESPONDING output_joblist TO sel_joblist.

      ELSE.

        IF count = 0 AND rs_selfield-tabindex EQ 0.
          MESSAGE s635.
          EXIT.
        ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
        IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
             ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).

* d023157   17.3.2009
* if only one job has been marked, we can probably release
* this job only in Solman

          IF redirect = 'Y'.
            IF marked_itab-status = 'S'.
              EXIT.
            ENDIF.

            IF marked_itab-status NE 'P'.
              MESSAGE s141 WITH marked_itab-jobname.
              EXIT.
            ENDIF.
          ENDIF.

          PERFORM change_job_in_solman USING marked_itab-jobname
                                             marked_itab-jobcount
                                             redirect.

          IF redirect = 'Y'.
            EXIT.
          ENDIF.
**************************************************************

          selected_job_name = marked_itab-jobname.
          selected_job_count = marked_itab-jobcount.

* when highlight only
        ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
          selected_job_name = output_joblist-jobname.
          selected_job_count = output_joblist-jobcount.

          perform change_job_in_solman using selected_job_name
                                             selected_job_count
                                             redirect.

          if redirect = 'Y'.
             exit.
          endif.

        ENDIF.

        MOVE-CORRESPONDING output_joblist TO sel_joblist.
        jobsel_param_in_backup = jobsel_param_out.
        PERFORM change_job_status_sm37b TABLES sel_joblist
                                        USING btc_release_job
                                        selected_job_name
                                        selected_job_count.

        jobsel_param_in = jobsel_param_in_backup.
        jobsel_param_out = jobsel_param_in.

      ENDIF.
      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'SPOO'.                       " show spool list
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

*C5035006
      PERFORM show_spoollist_universal
              USING
                 selected_job_name
                 selected_job_count
                 'E' .
    WHEN 'STEP'.                       " show step list
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF rs_selfield-tabindex EQ 0 AND count = 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      PERFORM show_steplist_sm37b USING selected_job_name
                                        selected_job_count.

    WHEN 'JABO'.                       " cancel active job

      IF rs_selfield-tabindex EQ 0 AND count EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.
      PERFORM popup_for_cancelation USING answer.
      IF answer = 'J'.
        IF count EQ 0 AND rs_selfield-tabindex NE 0.
          PERFORM abort_job_sm37b USING output_joblist-jobname
                                        output_joblist-jobcount.
        ELSEIF count >= 1.
          LOOP AT marked_itab.
            PERFORM abort_job_sm37b USING marked_itab-jobname
                                          marked_itab-jobcount.
          ENDLOOP.
        ENDIF.
      ENDIF.

      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JCPY'.                       " copy existing job
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      PERFORM copy_job_sm37b TABLES sel_joblist
                             USING selected_job_name
                                   selected_job_count.

      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'DEL'.                        " delete selected jobs
      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.
      PERFORM popup_for_deletion USING answer.
      IF answer = 'J'.
        IF count = 0 AND rs_selfield-tabindex NE 0. " user select
          " by highlight only
* if the status is released (S)
* we check, if the job was created by Solman

          CLEAR ssm_answer.

          PERFORM job_created_by_solman USING
                                         output_joblist-jobname
                                         output_joblist-jobcount
                                 CHANGING
                                         ssm_answer
                                         job_ssm_guid.

* a job, that has been created by SolMan, shall only be deleted
* via SolMan, if the job is the last in its periodicity chain, i.e.
* if deleting the job stops the periodicity chain
          IF ssm_answer = 'Y'.

            PERFORM job_last_in_chain USING
                                     output_joblist-jobname
                                     output_joblist-jobcount
                                     output_joblist-status
                                   CHANGING
                                     ssm_answer.


          ENDIF.

          IF ssm_answer = 'Y'.
            PERFORM delete_job_in_solman
                                  USING output_joblist-jobname
                                        output_joblist-jobcount
                                        job_ssm_guid.

          ELSE.
            PERFORM delete_job_sm37b TABLES output_joblist
                                USING output_joblist-jobname
                                      output_joblist-jobcount.
          ENDIF.

        ELSEIF count >= 1.
* d023157    4.12.2009   first attempt
* if for the current user the JSM scenario is active, we must
* divide the marked jobs into 2 groups:
* 1. Jobs not created via Solman
* 2. Jobs created via Solman
* The jobs of group 2 will be deleted via Solman.
* But in order to avoid too many browser windows, we allow
* not more than 5 Solman jobs.

          LOOP AT marked_itab.

            CLEAR ssm_answer.


            PERFORM job_created_by_solman USING
                                         marked_itab-jobname
                                         marked_itab-jobcount
                                 CHANGING
                                         ssm_answer
                                         job_ssm_guid.

            IF ssm_answer = 'Y'.

              PERFORM job_last_in_chain USING
                                     marked_itab-jobname
                                     marked_itab-jobcount
                                     marked_itab-status
                                   CHANGING
                                     ssm_answer.


            ENDIF.


            IF ssm_answer = 'Y'.
              IF cnt_ssm < 5.
                PERFORM delete_job_in_solman
                                USING marked_itab-jobname
                                      marked_itab-jobcount
                                      job_ssm_guid.

                cnt_ssm = cnt_ssm + 1.
              ENDIF.

            ELSE.

              PERFORM delete_job_sm37b TABLES output_joblist
                                      USING marked_itab-jobname
                                            marked_itab-jobcount.
            ENDIF.

          ENDLOOP.
        ENDIF.

        PERFORM refresh_alv_list USING rs_selfield.

      ELSE.
        EXIT.
      ENDIF.

    WHEN 'EDIT'.                       " modify existing job
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* d023157   16.3.2009 ************************************
* if the user matches the criteria for the Solman scenario,
* he is not allowed to change a job in SM37

*      if marked_itab-status ne 'S' and marked_itab-status ne 'P'.
*         message s141 with marked_itab-jobname.
*         exit.
*      endif.

*      PERFORM change_job_in_solman USING marked_itab-jobname
*                                         marked_itab-jobcount
*                                         redirect.
*
*      IF redirect = 'Y'.
*        EXIT.
*      ENDIF.

***********************************************************


* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      perform change_job_in_solman using selected_job_name
                                         selected_job_count
                                         redirect.

      if redirect = 'Y'.
         exit.
      endif.


      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      jobsel_param_in_backup = jobsel_param_out.
      PERFORM edit_job_sm37b TABLES sel_joblist
                             USING selected_job_name
                                   selected_job_count.

      jobsel_param_in = jobsel_param_in_backup.
      jobsel_param_out = jobsel_param_in.
      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JDBG'.                       " debug job
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      PERFORM debug_job_sm37b TABLES sel_joblist
                              USING selected_job_name
                                    selected_job_count.

      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JMOV'.                       " move job to another app. server
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      perform change_job_in_solman using selected_job_name
                                         selected_job_count
                                         redirect.

      if redirect = 'Y'.
         exit.
      endif.


      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      PERFORM move_job_sm37b TABLES sel_joblist
                             USING selected_job_name
                                   selected_job_count.

      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JGRP'.                       " capture active ABAP step
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      PERFORM debug_active_job_sm37b TABLES sel_joblist
                                     USING selected_job_name
                                           selected_job_count.

    WHEN 'JCHK'.
*********************************************************************
* Status check
*********************************************************************
      IF count = 0 AND rs_selfield-tabindex = 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex <> 0.
        MOVE-CORRESPONDING output_joblist TO marked_itab.
        APPEND marked_itab.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      PERFORM job_check_status_sm37 TABLES marked_itab.
      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JDRP'.                       " Repeat job
      IF mark_multi_flag = 'X'.
        MESSAGE e011.
        EXIT.
      ENDIF.

      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.
      jobsel_param_in_backup = jobsel_param_in.
      PERFORM repeat_job_definition_sm37b TABLES sel_joblist
                                    USING selected_job_name
                                          selected_job_count.

      jobsel_param_in = jobsel_param_in_backup.
      jobsel_param_out = jobsel_param_in.
      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'JDEF'.                       " define job: go to sm36
*** fix for 46C+
*** Check authorization before calling transaction.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = jobdefinition_transaction
        EXCEPTIONS
          ok     = 1
          not_ok = 2
          OTHERS = 3.
      IF sy-subrc <> 1.
        MESSAGE s172(00) WITH jobdefinition_transaction.
        EXIT.
      ENDIF.

      CALL TRANSACTION jobdefinition_transaction.

    WHEN 'JDRL'.    " derelease job - change status back to scheduled
      IF count = 0 AND rs_selfield-tabindex EQ 0.
        MESSAGE s635.
        EXIT.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO sel_joblist.

      IF count EQ 0 AND rs_selfield-tabindex NE 0.
        PERFORM change_job_status_sm37b TABLES sel_joblist
                          USING btc_derelease_job
                                output_joblist-jobname
                                output_joblist-jobcount.
      ELSEIF count >= 1.
* allow multiple selections marked
        LOOP AT marked_itab.
          PERFORM change_job_status_sm37b TABLES sel_joblist
                          USING btc_derelease_job
                                marked_itab-jobname
                                marked_itab-jobcount.
        ENDLOOP.
      ENDIF.

      PERFORM refresh_alv_list USING rs_selfield.

    WHEN 'SM51'.
*** fix for 46C+
*** Check authorization before calling transaction.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = appserverlist_transaction
        EXCEPTIONS
          ok     = 1
          not_ok = 2
          OTHERS = 3.
      IF sy-subrc <> 1.
        MESSAGE s172(00) WITH appserverlist_transaction.
        EXIT.
      ENDIF.

      CALL TRANSACTION appserverlist_transaction.

    WHEN 'SM50'.
*** fix for 46C+
*** Check authorization before calling transaction.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = workproclist_transaction
        EXCEPTIONS
          ok     = 1
          not_ok = 2
          OTHERS = 3.
      IF sy-subrc <> 1.
        MESSAGE s172(00) WITH workproclist_transaction.
        EXIT.
      ENDIF.

      CALL TRANSACTION workproclist_transaction.

    WHEN 'JTRE'.

      DESCRIBE TABLE marked_itab LINES count.
      IF count EQ 0 AND rs_selfield-tabindex NE 0.
        MOVE-CORRESPONDING output_joblist TO marked_itab.
        APPEND marked_itab.
      ELSEIF count NE 0 AND count < 100.
        " ok, follow the checkbox mark
      ELSEIF count > 100.
        MESSAGE e647 WITH count.
      ELSE.                            " didn't select anything.
        MESSAGE e635.
      ENDIF.

      CALL SCREEN 3080 STARTING AT 1 2
                       ENDING AT 45 18.

    WHEN 'WPTF'.

      DATA: wpnumber(10),
            trc_file TYPE sext_types-file,
            status TYPE tbtcjob-status.

      CONSTANTS: trc_file_name(5) VALUE 'dev_w'.

      IF mark_multi_flag = 'X'.
        MESSAGE s011.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
        status = marked_itab-status.
        reaxserver = marked_itab-reaxserver.
        wpnumber = marked_itab-wpnumber.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
        status = output_joblist-status.
        reaxserver = output_joblist-reaxserver.
        wpnumber = output_joblist-wpnumber.
      ENDIF.

      IF selected_job_name IS INITIAL AND selected_job_count IS INITIAL.
        MESSAGE s882.
        EXIT.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
               ID 'S_ADMI_FCD' FIELD 'PADM'.

      IF sy-subrc <> 0.
        MESSAGE s172(00) WITH appserverlist_transaction.
        EXIT.
      ENDIF.

      IF status = 'P' OR status = 'S' OR status = 'Z'.
        MESSAGE s551.
        EXIT.
      ENDIF.

      IF reaxserver NE my_server_name.
        dest = reaxserver.
      ELSE.
        CLEAR dest.
      ENDIF.

      CONDENSE wpnumber.
      CONCATENATE trc_file_name wpnumber INTO trc_file.
      CLEAR rfc_msg.

      CALL FUNCTION '_STRC_DISPLAY_WP_TRACE' DESTINATION dest
        EXPORTING
          file                  = trc_file
        EXCEPTIONS
          communication_failure = 1  MESSAGE rfc_msg
          system_failure        = 2  MESSAGE rfc_msg
          file_not_found        = 3
          OTHERS                = 4.
      IF sy-subrc > 2.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ELSEIF sy-subrc > 0 AND sy-subrc < 3.
        MESSAGE s351 WITH rfc_msg.
        EXIT.
      ENDIF.

    WHEN 'DTMO'.

      DATA: joblog TYPE tbtcjob-joblog,
            client TYPE tbtcjob-authckman.

      IF mark_multi_flag = 'X'.
        MESSAGE s011.
        EXIT.
      ENDIF.

* when the user uses checkbox and highlight at the same time,
* ignore the highlight -- checkbox has higher priority.
      IF ( ( count NE 0 AND rs_selfield-tabindex NE 0 ) OR
           ( count NE 0 AND rs_selfield-tabindex EQ 0 ) ).
        selected_job_name = marked_itab-jobname.
        selected_job_count = marked_itab-jobcount.
        joblog = marked_itab-joblog.
        client = marked_itab-authckman.
* when highlight only
      ELSEIF count EQ 0 AND rs_selfield-tabindex NE 0.
        selected_job_name = output_joblist-jobname.
        selected_job_count = output_joblist-jobcount.
        joblog = output_joblist-joblog.
        client = output_joblist-authckman.
      ENDIF.

      IF selected_job_name IS INITIAL AND selected_job_count IS INITIAL.
        MESSAGE s882.
        EXIT.
      ENDIF.

      IF joblog IS NOT INITIAL.
        IF client = sy-mandt.
          CALL FUNCTION 'RSPO_R_CALL_SP11'
            EXPORTING
              objname = joblog.
        ELSE.
          MESSAGE s552 WITH joblog client.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE s166.
        EXIT.
      ENDIF.

  ENDCASE.

* c5034979, 29.10.2002
  job_editor_opcode = previous_opcode.

  CLEAR r_ucomm.

ENDFORM.                               " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  OUTPUTLIST_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*----------------------------------------------------------------------*
FORM outputlist_build TABLES p_sel_joblist STRUCTURE sel_joblist
                             p_gt_exc STRUCTURE alv_s_qinf.

  DATA: delta_delay_date TYPE i,
        delta_delay_time TYPE i,
        ttl_delay_time TYPE i,
        delta_dura_date TYPE i,
        delta_dura_time TYPE i,
        ttl_dura_time TYPE i.

* flags
* special color
  DATA:
*        colorize_status_row TYPE slis_specialcol_alv,
        red_row TYPE slis_specialcol_alv,
        green_row TYPE slis_specialcol_alv,
        yellow_row TYPE slis_specialcol_alv,
        nocolor_row TYPE slis_specialcol_alv.

* flags for scheduled, start and end date
  DATA : rc_schedule TYPE C,
         rc_start TYPE c,
         rc_end TYPE c.

  DATA: tgt_grp_name TYPE bpsrvgrp.
  DATA: tmp_grp TYPE REF TO cl_bp_server_group.

  DATA: ls_exc TYPE alv_s_qinf.

  TYPES: BEGIN OF t_spoolid ,
    jobname TYPE btcjob,
    jobcount TYPE BTCJOBCNT,
    stepcount TYPE btcstepcnt,
    listident TYPE btclistid,
  END OF t_spoolid.

  TYPES: BEGIN OF t_job,
    jobname TYPE btcjob,
    jobcount TYPE BTCJOBCNT,
    ctxttype TYPE btcctxttyp,
    ctxtval TYPE btcctxt,
  END OF t_job.

  DATA: lt_spoolid TYPE SORTED TABLE OF t_spoolid WITH UNIQUE KEY
        jobname jobcount stepcount listident,
        lt_solmanjobs TYPE SORTED TABLE OF t_job WITH UNIQUE KEY
        jobname jobcount ctxttype ctxtval.

* initialize color rows
  red_row-fieldname = 'STATUSNAME'.
  red_row-color-col = 6.
  red_row-color-int = 1.
  red_row-color-inv = 0.
  red_row-nokeycol  = 'X'.

  green_row-fieldname = 'STATUSNAME'.
  green_row-color-col = 5.
  green_row-color-int = 1.
  green_row-color-inv = 0.
  green_row-nokeycol  = 'X'.

  yellow_row-fieldname = 'STATUSNAME'.
  yellow_row-color-col = 3.
  yellow_row-color-int = 1.
  yellow_row-color-inv = 0.
  yellow_row-nokeycol  = 'X'.

  nocolor_row-fieldname = 'STATUSNAME'.
  nocolor_row-color-col = 2.
  nocolor_row-color-int = 1.
  nocolor_row-color-inv = 0.
  nocolor_row-nokeycol  = 'X'.

  CLEAR ls_exc.
  REFRESH p_gt_exc.
  ls_exc-type = '4'.
  ls_exc-fieldname = 'STATUS'.
  ls_exc-value = green_row-color-col.
  ls_exc-text = text-082.
  APPEND ls_exc TO p_gt_exc.
  CLEAR ls_exc.
  ls_exc-type = '4'.
  ls_exc-fieldname = 'STATUS'.
  ls_exc-value = red_row-color-col.
  ls_exc-text = text-081.
  APPEND ls_exc TO p_gt_exc.
  CLEAR ls_exc.
  ls_exc-type = '4'.
  ls_exc-fieldname = 'STATUS'.
  ls_exc-value = nocolor_row-color-col.
  ls_exc-text = text-080.
  APPEND ls_exc TO p_gt_exc.
  CLEAR ls_exc.
  ls_exc-type = '4'.
  ls_exc-fieldname = 'STATUS'.
  ls_exc-value = yellow_row-color-col .
  ls_exc-text = text-048.
  APPEND ls_exc TO p_gt_exc.

  DATA lv_is_intercepted TYPE boolean.
  REFRESH: output_joblist, event_tbl.

  IF lines( p_sel_joblist ) > 0.
    SELECT jobname jobcount stepcount listident
  FROM tbtcp
  INTO CORRESPONDING FIELDS OF TABLE lt_spoolid
  FOR ALL ENTRIES IN p_sel_joblist
  WHERE jobname = p_sel_joblist-jobname AND
  jobcount = p_sel_joblist-jobcount AND
  listident <> '0000000000'.

    SELECT jobname jobcount ctxttype ctxtval
    FROM tbtccntxt INTO CORRESPONDING FIELDS OF TABLE lt_solmanjobs
  FOR ALL ENTRIES IN p_sel_joblist
  WHERE jobname  = p_sel_joblist-jobname
  AND jobcount = p_sel_joblist-jobcount
  AND ctxttype = 'SOLMAN_REQUEST_ID'.
  ENDIF.

*  CLEAR gs_layout.
  LOOP AT p_sel_joblist.
    CLEAR output_joblist.
    MOVE-CORRESPONDING p_sel_joblist TO output_joblist.
**
** initialize colorize_status
**
    CASE p_sel_joblist-status.
      WHEN 'A'.
        output_joblist-statusname = text-081.
        output_joblist-slide_type_status = 'XXXX<'.
        APPEND red_row TO output_joblist-colorize_status.
      WHEN 'F'.
        output_joblist-statusname = text-082.
        output_joblist-slide_type_status = 'XXXXX'.
        APPEND green_row TO output_joblist-colorize_status.
      WHEN 'S'.
        output_joblist-statusname = text-080.
        output_joblist-slide_type_status = 'XX   '.
        APPEND nocolor_row TO output_joblist-colorize_status.
      WHEN 'R'.
        output_joblist-statusname = text-077.
        output_joblist-slide_type_status = 'XXXX '.
        APPEND nocolor_row TO output_joblist-colorize_status.
      WHEN 'P'.
        PERFORM check_job_is_intercepted
                    USING
                       output_joblist-jobname
                       output_joblist-jobcount
                    CHANGING
                       lv_is_intercepted.
        IF lv_is_intercepted = abap_true.
          output_joblist-statusname = text-360.
          output_joblist-slide_type_status = '?    '.
          APPEND yellow_row TO output_joblist-colorize_status.
        ELSE.
          output_joblist-statusname = text-079.
          output_joblist-slide_type_status = 'X    '.
          APPEND nocolor_row TO output_joblist-colorize_status.
        ENDIF.
      WHEN 'Y'.
        output_joblist-statusname = text-078.
        output_joblist-slide_type_status = 'XXX  '.
        APPEND nocolor_row TO output_joblist-colorize_status.
      WHEN 'Z'.
        output_joblist-statusname = text-748.
        output_joblist-slide_type_status = 'XX?  '.
        APPEND nocolor_row TO output_joblist-colorize_status.
      WHEN OTHERS.
        output_joblist-statusname = text-749.
        output_joblist-slide_type_status = '???  '.
        APPEND nocolor_row TO output_joblist-colorize_status.
    ENDCASE.
* calculate the delay time and the duration of the job.

    ttl_delay_time = 0.
    ttl_dura_time  = 0.

    IF output_joblist-status NE btc_scheduled.
* check date values
      IF  output_joblist-sdlstrttm NE space AND
*          output_joblist-sdlstrttm NE zero_time AND
          output_joblist-sdlstrtdt NE space AND
          output_joblist-sdlstrtdt NE zero_date.
        rc_schedule = 'X'.
      ELSE.
        CLEAR rc_schedule.
      ENDIF.

      IF output_joblist-strttime NE space AND
*         output_joblist-strttime NE zero_time AND
         output_joblist-strtdate NE space AND
         output_joblist-strtdate NE zero_date.
        rc_start = 'X'.
      ELSE.
        CLEAR rc_start.
      ENDIF.

      IF output_joblist-endtime NE space AND
*         output_joblist-endtime NE zero_time AND
         output_joblist-enddate NE space AND
         output_joblist-enddate NE zero_date.
        rc_end = 'X'.
      ELSE.
        CLEAR rc_end.
      ENDIF.

* calculate delay
      IF rc_schedule = 'X'.
        IF rc_start = 'X'.
          PERFORM calculate_time_diff_in_sec
                USING output_joblist-sdlstrtdt
                      output_joblist-sdlstrttm
                      output_joblist-strtdate
                      output_joblist-strttime
                      ttl_delay_time.
        ELSE.
          IF output_joblist-status EQ btc_released OR
             output_joblist-status EQ btc_ready.
            PERFORM calculate_time_diff_in_sec
                  USING output_joblist-sdlstrtdt
                        output_joblist-sdlstrttm
                        sy-datum
                        sy-uzeit
                        ttl_delay_time.
          ENDIF.
        ENDIF.
      ENDIF.

      IF output_joblist-status NE btc_released AND
         output_joblist-status NE btc_ready.

* calculate duration
        IF rc_start = 'X'.
          IF rc_end = 'X'.
            PERFORM calculate_time_diff_in_sec
            USING output_joblist-strtdate
                  output_joblist-strttime
                  output_joblist-enddate
                  output_joblist-endtime
                  ttl_dura_time.
          ELSE.
            IF output_joblist-status EQ btc_running.
              PERFORM calculate_time_diff_in_sec
              USING output_joblist-strtdate
                    output_joblist-strttime
                    sy-datum
                    sy-uzeit
                    ttl_dura_time.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    output_joblist-delaytime = ttl_delay_time.
    output_joblist-duration  = ttl_dura_time.

    IF output_joblist-tgtsrvgrp IS NOT INITIAL.
      PERFORM map_id_to_name USING output_joblist-tgtsrvgrp tgt_grp_name.
      IF NOT tgt_grp_name IS INITIAL.
        CONCATENATE '<' tgt_grp_name '>' INTO output_joblist-execserver.
      ELSE.
        CONCATENATE '<' text-821 '>' INTO output_joblist-execserver. " note 1546435
      ENDIF.
    ELSE.
      IF output_joblist-execserver IS INITIAL.
        IF output_joblist-status = btc_scheduled OR
         output_joblist-status = btc_released OR
         output_joblist-status = btc_ready.
          CALL METHOD cl_bp_group_factory=>make_group_by_name
            EXPORTING
              i_name          = sap_default_srvgrp
              i_only_existing = cl_bp_const=>true
            RECEIVING
              o_grp_instance  = tmp_grp.
          IF tmp_grp IS NOT INITIAL.
            CONCATENATE '<' sap_default_srvgrp '>' INTO output_joblist-execserver.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE lt_spoolid WITH KEY jobname = p_sel_joblist-jobname
    jobcount = p_sel_joblist-jobcount
    TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
        output_joblist-spool_icon = icon_space.
      ELSE.
        output_joblist-spool_icon = icon_history.
    ENDIF.

*   check, if the job was created by Solution Manager *********
*   d023157    19.6.2009
    CLEAR output_joblist-jsm_icon.

    READ TABLE lt_solmanjobs WITH KEY jobname = p_sel_joblist-jobname
    jobcount = p_sel_joblist-jobcount
    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      output_joblist-jsm_icon = icon_document.
    ENDIF.

**** end  d023157    19.6.2009  ********************************

    APPEND output_joblist.

  ENDLOOP.

  PERFORM event_handler USING sy-dynnr.

ENDFORM.                               " OUTPUTLIST_BUILD
*--------------------------------------------------------------*
*       FORM CALCULATE_TIME_DIFF_IN_SEC
*--------------------------------------------------------------*
FORM calculate_time_diff_in_sec USING before_date LIKE sy-datum
                                      before_time LIKE sy-uzeit
                                      now_date    LIKE sy-datum
                                      now_time    LIKE sy-uzeit
                                      time_diff   TYPE i.
  DATA: delta_date TYPE i,
        delta_time TYPE i.

  delta_date = now_date - before_date.
  delta_time = now_time - before_time.

  IF delta_date < 0.                   " irregular situation
    time_diff = 0.
  ELSEIF delta_date > 2000.             " avoid overflow
    time_diff = 0.
  ELSE.
    time_diff = delta_date * 86400 + delta_time.
    IF time_diff < 0.                  " irregular situation
      time_diff = 0.
    ENDIF.
  ENDIF.
ENDFORM.                               " CALCULATE_TIME_DIFF_IN_SEC
*--------------------------------------------------------------*
*       FORM JOB_OVERVIEW_TOP_OF_PAGE
*--------------------------------------------------------------*
FORM job_overview_top_of_page.
  DATA: event_flag(1),
        prog_flag(1).

  DATA: i_accessibility TYPE abap_bool.

  CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
    IMPORTING
      accessibility     = i_accessibility
    EXCEPTIONS
      its_not_available = 1
      OTHERS            = 2.

  IF sy-tcode = 'SMX' OR sy-tcode = 'SMXX' OR
    i_accessibility = abap_true.
    EXIT.
  ENDIF.

  IF btch2170-eventid = ' '.
    event_flag = space.
  ELSE.
    event_flag = 'X'.
  ENDIF.

  IF btch2170-abapname = space.
    prog_flag  = space.
  ELSE.
    prog_flag  = 'X'.
  ENDIF.

  NEW-LINE NO-SCROLLING.
  WRITE: / text-619 INTENSIFIED OFF,
           btch2170-from_date,
           text-620 INTENSIFIED OFF, btch2170-from_time.
  NEW-LINE NO-SCROLLING.
  WRITE: / text-621 INTENSIFIED OFF,
           btch2170-to_date,
           text-620 INTENSIFIED OFF, btch2170-to_time.

  NEW-LINE NO-SCROLLING.
  WRITE: /
           text-622 INTENSIFIED OFF,
           btch2170-jobname.
  NEW-LINE NO-SCROLLING.
  WRITE: /
           text-623 INTENSIFIED OFF,
           btch2170-username.
  SKIP 1.
  NEW-LINE NO-SCROLLING.
  WRITE: /
           btch2170-prelim AS CHECKBOX INPUT OFF,
                               text-079 INTENSIFIED OFF, ' ',
           btch2170-schedul AS CHECKBOX INPUT OFF,
                               text-080 INTENSIFIED OFF, ' ',
           btch2170-ready AS CHECKBOX INPUT OFF,
                               text-078 INTENSIFIED OFF, ' ',
           btch2170-running AS CHECKBOX INPUT OFF,
                               text-077 INTENSIFIED OFF, ' ',
           btch2170-finished AS CHECKBOX INPUT OFF,
                               text-082 INTENSIFIED OFF, ' ',
           btch2170-aborted AS CHECKBOX INPUT OFF,
                               text-081 INTENSIFIED OFF.

  NEW-LINE NO-SCROLLING.
  WRITE: /
           event_flag AS CHECKBOX INPUT OFF,
                             text-626 INTENSIFIED OFF, '  ',
           text-627 INTENSIFIED OFF, btch2170-eventid.
  NEW-LINE NO-SCROLLING.
  WRITE: /
           prog_flag AS CHECKBOX INPUT OFF,
                             text-629 INTENSIFIED OFF, '  ',
           text-630 INTENSIFIED OFF, btch2170-abapname.
  SKIP 1.
ENDFORM.                    "job_overview_top_of_page
*&---------------------------------------------------------------------*
*&      Form  JLOG_LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBLOG_LAYOUT_TBL  text
*----------------------------------------------------------------------*
FORM jlog_layout_build USING layout_tbl TYPE slis_layout_alv.
  CLEAR layout_tbl.
  layout_tbl-zebra = 'X'.
  layout_tbl-colwidth_optimize = 'X'.
  layout_tbl-detail_popup = 'X'.
  layout_tbl-detail_titlebar = text-650.
  layout_tbl-no_vline = ' '.
ENDFORM.                               " JLOG_LAYOUT_BUILD
*&---------------------------------------------------------------------*
*&      Form  JLOG_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBLOG_FIELDCAT_TBL  text
*----------------------------------------------------------------------*
FORM jlog_fieldcat_build USING fieldcat_tbl TYPE slis_t_fieldcat_alv.
  DATA: fieldcat_row TYPE slis_fieldcat_alv.
  DATA: pos TYPE i VALUE 1.

  REFRESH: fieldcat_tbl, event_tbl.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-651.
  fieldcat_row-fieldname = 'ENTERDATE'.
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-652.
  fieldcat_row-fieldname = 'ENTERTIME'.
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-653.
  fieldcat_row-fieldname = 'TEXT'.
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-654.
  fieldcat_row-fieldname = 'MSGID'.
  fieldcat_row-just = 'C'.
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-655.
  fieldcat_row-fieldname = 'MSGNO'.
  fieldcat_row-just = 'C'.
  fieldcat_row-lzero = 'X'.     " note 654233, 2nd correction
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

  CLEAR fieldcat_row.
  fieldcat_row-col_pos   = pos.
  fieldcat_row-seltext_m = text-656.
  fieldcat_row-fieldname = 'MSGTYPE'.
  fieldcat_row-just = 'C'.
  APPEND fieldcat_row TO fieldcat_tbl.
  pos = pos + 1.

*
* Write the top of page information
*
  CLEAR: event_tbl, event_row.
*!!!111
*  event_row-name = slis_ev_top_of_page.
*  event_row-form = 'JOBLOG_TOP_OF_PAGE'.
*  APPEND event_row TO event_tbl.

ENDFORM.                               " JLOG_FIELDCAT_BUILD
*----------------------------------------------------------*
*          FORM JOBLOG_TOP_OF_PAGE
*----------------------------------------------------------*
FORM joblog_top_of_page.
* set left scroll-boundary.
  WRITE: / .
  NEW-LINE NO-SCROLLING.
  WRITE: / text-658 INTENSIFIED OFF,
           joblog_owner_name.
  WRITE: / .
ENDFORM.                               " JOBLOG_TOP_OF_PAGE
*----------------------------------------------------------*
*          FORM JLOG_USER_COMMAND
*----------------------------------------------------------*
FORM jlog_user_command USING r_ucomm LIKE sy-ucomm
                             rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1' OR 'LTXT'.             "when double click
      IF rs_selfield-tabindex = 0.
        MESSAGE s019.
        EXIT.
      ENDIF.

      READ TABLE global_jlg_tbl INDEX rs_selfield-tabindex.
      PERFORM show_joblog_entry_detail USING global_jlg_tbl g_joblog-wpnum.

    WHEN 'REFRESH'.
      PERFORM jlog_refresh CHANGING rs_selfield.

    WHEN 'STOP'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                               " JLOG_USER_COMMAND
*--------------------------------------------------------------*
*       FORM JOB_OVERVIEW_END_OF_LIST
*--------------------------------------------------------------*
FORM job_overview_end_of_list.

  NEW-LINE NO-SCROLLING.
  WRITE: / text-644 INTENSIFIED OFF,
           total_selection_count.
  WRITE: / text-617  INTENSIFIED OFF.

ENDFORM.                    "job_overview_end_of_list
*--------------------------------------------------------------*
*       FORM JOBLOG_END_OF_LIST
*--------------------------------------------------------------*
FORM joblog_end_of_list.
  NEW-LINE NO-SCROLLING.
  WRITE: / text-618 INTENSIFIED OFF.
ENDFORM.                    "joblog_end_of_list
*&---------------------------------------------------------------------*
*&      Form  INIT_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0109   text
*      -->P_0110   text
*----------------------------------------------------------------------*
FORM init_list USING status_callback TYPE slis_formname
                     usercomm_callback TYPE slis_formname.
  DATA: local_repid LIKE sy-repid.
  local_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
    EXPORTING
      i_callback_program       = local_repid
      i_callback_pf_status_set = status_callback
      i_callback_user_command  = usercomm_callback
      it_excluding             = cua_excl_tab
    EXCEPTIONS
      OTHERS                   = 1.

ENDFORM.                               " INIT_LIST
*&---------------------------------------------------------------------*
*&      Form  JOV_PF_STATUS
*&---------------------------------------------------------------------*
FORM jov_pf_status USING fcode_extab TYPE slis_t_extab.

  DATA: BEGIN OF wa_fcode,
            fcode LIKE rsmpe-func,
        END OF wa_fcode.

  SET TITLEBAR 'JOV_TITLE'.
  CASE list_processing_context.
    WHEN btc_joblist_edit.

*      wa_fcode-fcode = 'DEL'.
*      append wa_fcode to fcode_extab.

*  für TA SMX viele Funktionscodes deaktivieren
      IF sy-tcode = 'SMX' OR sy-tcode = 'SMXX'.
        PERFORM exclude_smx USING fcode_extab.
      ENDIF.

* if the JSM scenario is active, exclude 'job repeat'.
* (and some other menu items)
      IF redirect_to_solman = 'Y'.
        IF ( sy-tcode NE 'SMX' AND sy-tcode NE 'SMXX' ).

          wa_fcode-fcode = 'JDRP'.
          APPEND wa_fcode TO fcode_extab.

          wa_fcode-fcode = 'JGRP'.
          APPEND wa_fcode TO fcode_extab.

          wa_fcode-fcode = 'JMOV'.
          APPEND wa_fcode TO fcode_extab.

          wa_fcode-fcode = 'JDRL'.
          APPEND wa_fcode TO fcode_extab.

        ENDIF.
      ENDIF.

      SET PF-STATUS 'JOV_STATUS' EXCLUDING fcode_extab.

    WHEN btc_joblist_show.
      SET PF-STATUS 'JOV_STATUS_SHOW' EXCLUDING fcode_extab.
    WHEN btc_joblist_snap.
      SET PF-STATUS 'JOV_STATUS_SNAP' EXCLUDING fcode_extab.
  ENDCASE.

  IF NOT ( jov_list_scroll_info IS INITIAL ).
    DATA: p_grid LIKE reuse_alv_type.
    PERFORM get_current_display_function USING p_grid.
    IF p_grid = 'L'.
      CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_SET'
        EXPORTING
          is_list_scroll = jov_list_scroll_info
        EXCEPTIONS
          OTHERS         = 99.
    ELSE.
      CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_SET'
        EXPORTING
          is_grid_scroll = jov_grid_scroll_info
        EXCEPTIONS
          OTHERS         = 99.
    ENDIF.

    IF sy-subrc NE 0.
      MESSAGE e645 WITH text-746 sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "jov_pf_status
*&---------------------------------------------------------------------*
*&      Form  SHOW_SPOOLLIST_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OUTPUT_JOBLIST[RS_SELFIELD_TAB  text
*      -->P_OUTPUT_JOBLIST[RS_SELFIELD_TAB  text
*----------------------------------------------------------------------*
FORM show_spoollist_sm37b USING jobname  LIKE tbtcjob-jobname
                                jobcount LIKE tbtcjob-jobcount.
*Redirect C5035006
  PERFORM show_spoollist_universal
              USING
                 jobname
                 jobcount
                 'E' .
ENDFORM.                               " SHOW_SPOOLLIST_SM37B
*&---------------------------------------------------------------------*
*&      Form  SHOW_STEPLIST_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OUTPUT_JOBLIST_JOBNAME  text
*      -->P_OUTPUT_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM show_steplist_sm37b USING jobname LIKE tbtcjob-jobname
                               jobcount LIKE tbtcjob-jobcount.
  DATA: rc TYPE i.

  DATA: BEGIN OF stpl_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF stpl_jobhead.

  DATA: BEGIN OF stpl_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF stpl_steplist.
*
* Jobdaten aus Jobliste und anschliessend aus DB lesen
*

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = stpl_jobhead
    TABLES
      job_read_steplist = stpl_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname_selected.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname_selected.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist, Stepliste des Jobs anzuzueigen
*
  PERFORM check_operation_privilege USING stpl_jobhead-sdluname rc.

  IF rc NE 0.
    PERFORM check_job_show_privilege USING rc.
    IF rc NE 0.
      MESSAGE e248.
    ENDIF.
  ENDIF.

  IF stpl_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname_selected.
  ENDIF.
*
* Stepliste anzeigen
*
  CALL FUNCTION 'BP_STEPLIST_EDITOR'
    EXPORTING
      steplist_dialog = btc_yes
      steplist_opcode = btc_show_steplist
      i_jobname       = jobname
      i_jobcount      = jobcount
    TABLES
      steplist        = stpl_steplist
    EXCEPTIONS
      OTHERS          = 99.


ENDFORM.                               " SHOW_STEPLIST_SM37B
*&---------------------------------------------------------------------*
*&      Form  CHANGE_JOB_STATUS_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->how
*      -->jobname
*      -->jobcount
*----------------------------------------------------------------------*
FORM change_job_status_sm37b TABLES p_sel_joblist STRUCTURE tbtcjob
                             USING how
                                   jobname LIKE tbtcjob-jobname
                                   jobcount LIKE tbtcjob-jobcount.
  DATA: stdt_modify_flag LIKE btch0000-int4.

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF old_steplist OCCURS 0." Dummy
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.

  DATA: BEGIN OF new_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF new_stdt.

  IF block_marking_is_active EQ true.
*
*    prüfen, ob eine "offene" (nicht beendete) Blockmarkierung vorliegt
*
    IF block_starts_at_row NE 0 AND
       block_ends_at_row   EQ 0.
      MESSAGE e163.
    ENDIF.
*
*    falls Jobs freigegeben werden sollen: Starttermin für alle mar-
*    kierten Jobs vom Benutzer erfragen
*
    IF how EQ btc_release_job.
      PERFORM check_authority_to_release
       USING jobname jobcount.

      CALL FUNCTION 'BP_START_DATE_EDITOR'
        EXPORTING
          stdt_dialog      = btc_yes
          stdt_opcode      = btc_edit_startdate
          stdt_input       = new_stdt
        IMPORTING
          stdt_output      = new_stdt
          stdt_modify_type = stdt_modify_flag
        EXCEPTIONS
          OTHERS           = 99.

      IF sy-subrc NE 0 OR
         stdt_modify_flag EQ btc_stdt_not_modified.
        PERFORM init_joblist_block_proc.
        EXIT.
      ENDIF.
    ENDIF.
*
*    jetzt alle markierten Jobs freigeben / zurücknehmen
*
    LOOP AT p_sel_joblist.
      IF p_sel_joblist-newflag EQ 'X'.
        jobname_selected = p_sel_joblist-jobname.

        IF how EQ btc_release_job.
          CALL FUNCTION 'BP_JOB_READ'
            EXPORTING
              job_read_jobname  = jobname
              job_read_jobcount = jobcount
              job_read_opcode   = btc_read_jobhead_only
            IMPORTING
              job_read_jobhead  = old_jobhead
            TABLES
              job_read_steplist = old_steplist
            EXCEPTIONS
              job_doesnt_exist  = 1
              OTHERS            = 99.

          CASE sy-subrc.
            WHEN 0.
              " Lesen hat geklappt
            WHEN 1.
              PERFORM init_joblist_block_proc.
              MESSAGE e127 WITH jobname_selected.
            WHEN OTHERS.
              PERFORM init_joblist_block_proc.
              MESSAGE e155 WITH jobname_selected.
          ENDCASE.
        ENDIF.

        CALL FUNCTION 'BP_JOB_MODIFY'
          EXPORTING
            jobname              = jobname
            jobcount             = jobcount
            dialog               = btc_no
            opcode               = how
            release_stdt         = new_stdt
            release_targetsystem = old_jobhead-btcsystem
          IMPORTING
            modified_jobhead     = p_sel_joblist
          TABLES
            new_steplist         = global_step_tbl  " Dummy
          EXCEPTIONS
            nothing_to_do        = 1
            OTHERS               = 99.

        IF sy-subrc EQ 0.
          MODIFY p_sel_joblist.
          IF sy-subrc NE 0.
            PERFORM init_joblist_block_proc.
            MESSAGE e154.
          ENDIF.
        ELSEIF sy-subrc EQ 1.
          " nichts tun
        ELSE.
          PERFORM init_joblist_block_proc.
          MESSAGE e268 WITH jobname_selected.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM init_joblist_block_proc.
  ELSE.

    IF how EQ btc_release_job.
*
*       Jobkopfdaten lesen um den Zielrechner zu ermitteln
*
      CALL FUNCTION 'BP_JOB_READ'
        EXPORTING
          job_read_jobname  = jobname
          job_read_jobcount = jobcount
          job_read_opcode   = btc_read_jobhead_only
        IMPORTING
          job_read_jobhead  = old_jobhead
        TABLES
          job_read_steplist = old_steplist
        EXCEPTIONS
          job_doesnt_exist  = 1
          OTHERS            = 99.

      CASE sy-subrc.
        WHEN 0.
          " Lesen hat geklappt
        WHEN 1.
          MESSAGE e127 WITH jobname.
        WHEN OTHERS.
          MESSAGE e155 WITH jobname.
      ENDCASE.
    ENDIF.

    PERFORM check_authority_to_release
      USING jobname jobcount.

    CALL FUNCTION 'BP_JOB_MODIFY'
      EXPORTING
        jobname              = jobname
        jobcount             = jobcount
        dialog               = btc_yes
        opcode               = how
        release_targetsystem = old_jobhead-btcsystem
        release_targetserver = old_jobhead-execserver
      IMPORTING
        modified_jobhead     = p_sel_joblist
      TABLES
        new_steplist         = global_step_tbl
      EXCEPTIONS
        nothing_to_do        = 1
        OTHERS               = 99.

  ENDIF.

ENDFORM.                               " CHANGE_JOB_STATUS_SM37B
*&---------------------------------------------------------------------*
*&      Form  ABORT_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OUTPUT_JOBLIST_JOBNAME  text
*      -->P_OUTPUT_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM abort_job_sm37b USING jobname LIKE tbtcjob-jobname
                           jobcount LIKE tbtcjob-jobcount.

  CALL FUNCTION 'BP_JOB_ABORT'
    EXPORTING
      jobname  = jobname
      jobcount = jobcount
    EXCEPTIONS
      OTHERS   = 99.

ENDFORM.                               " ABORT_JOB_SM37B
*&---------------------------------------------------------------------*
*&      Form  COPY_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OUTPUT_JOBLIST_JOBNAME  text
*      -->P_OUTPUT_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM copy_job_sm37b TABLES p_sel_joblist STRUCTURE tbtcjob
                    USING jobname LIKE tbtcjob-jobname
                          jobcount LIKE tbtcjob-jobcount.
  CALL FUNCTION 'BP_JOB_COPY'
    EXPORTING
      dialog            = btc_yes
      source_jobname    = jobname
      source_jobcount   = jobcount
    IMPORTING
      new_jobhead       = p_sel_joblist
    EXCEPTIONS
      job_copy_canceled = 1
      OTHERS            = 99.

  IF sy-subrc EQ 0.
    APPEND p_sel_joblist.
  ENDIF.

ENDFORM.                               " COPY_JOB_SM37B
*&---------------------------------------------------------------------*
*&      Form  DELETE_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_OUTPUT_JOBLIST_JOBNAME  text
*      -->P_OUTPUT_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM delete_job_sm37b TABLES   joblist STRUCTURE output_joblist
          USING    jobname LIKE output_joblist-jobname
                   jobcount LIKE output_joblist-jobcount.
  DATA: rc TYPE i,
        help_text(80).

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF old_steplist OCCURS 0." Dummy
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.

* loop at joblist where marked = 'X'.
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_jobhead_only
    IMPORTING
      job_read_jobhead  = old_jobhead
    TABLES
      job_read_steplist = old_steplist
    EXCEPTIONS
      OTHERS            = 99.

  IF sy-subrc EQ 0.
    IF old_jobhead-succnum > 0.
      PERFORM derelease_successors_sm37b USING old_jobhead-jobname
                                         old_jobhead-jobcount
                                         rc.
      IF rc NE 0.
        EXIT. " Fehlermeldung wird von Routine ausgegeben
      ENDIF.
    ENDIF.

    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        jobname    = old_jobhead-jobname
        jobcount   = old_jobhead-jobcount
        forcedmode = 'X'
      EXCEPTIONS
        OTHERS     = 99.

  ENDIF.

  IF stable_list = btc_joblist_snap.
    LOOP AT joblist.
      IF joblist-jobname = jobname AND joblist-jobcount = jobcount.
        DELETE TABLE joblist.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " DELETE_JOB_SM37B
**&---------------------------------
*&---------------------------------------------------------------------*
*&      Form  JOB_OVERVIEW_ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM job_overview_alv_display.
  DATA: local_repid          LIKE sy-repid,
        dummy_interval_start TYPE p,
        rc                   LIKE sy-subrc,
        color(4)             TYPE c.

  DATA: gt_exc TYPE TABLE OF alv_s_qinf.
  DATA: html_top_of_page TYPE slis_formname.
  DATA: i_accessibility TYPE abap_bool.

  REFRESH output_joblist.
  PERFORM outputlist_build TABLES sel_joblist
                                  gt_exc.

  CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
    IMPORTING
      accessibility     = i_accessibility
    EXCEPTIONS
      its_not_available = 1
      OTHERS            = 2.

  IF i_accessibility = abap_false.
    html_top_of_page = 'JOB_OVERVIEW_TOP_OF_PAGE_NEW'.
  ELSE.
    CLEAR html_top_of_page.
    REFRESH event_tbl.
  ENDIF.

  PERFORM get_fieldcat_for_alv_list USING gt_fieldcat
                                          gt_sort
                                          gt_filter
                                          'OUTPUT_JOBLIST'
                                          dummy_interval_start
                                          rc.
  IF rc NE 0.
    EXIT.
  ENDIF.

  PERFORM layout_build USING gs_layout.

  local_repid = sy-repid.


  PERFORM indicate_progress_for_part
         USING text-649 parts 4.

  IF gt_sort IS INITIAL.
    PERFORM fill_default_sort_table.
  ENDIF.

  DATA: p_grid LIKE reuse_alv_type.
  PERFORM get_current_display_function USING p_grid.

  DATA: joblog_title TYPE lvc_title.
  WRITE text-774 TO joblog_title.

  IF stable_list IS INITIAL
         AND sy-tcode NE 'SMX' AND sy-tcode NE 'SMXX'
         AND i_accessibility = abap_false.

* hgk  18.7.02  wg. int. Meldung  3107512 / 2002
    IF disp_own_job_advanced_flag IS INITIAL. " we are in sm37
*       AND btch2170 IS INITIAL.

      IF p_grid = 'L'.
        CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
          EXPORTING
            i_callback_program          = local_repid
            i_callback_pf_status_set    = g_pf_status
            i_callback_user_command     = g_user_command
*           i_callback_html_top_of_page = 'JOB_OVERVIEW_TOP_OF_PAGE_NEW'
            is_layout                   = gs_layout
            it_fieldcat                 = gt_fieldcat
            it_sort                     = gt_sort
            it_filter                   = gt_filter
            it_events                   = event_tbl
            it_event_exit               = event_exit_tbl[]
            i_save                      = 'A'
            i_default                   = 'X'
          TABLES
            t_outtab                    = output_joblist
          EXCEPTIONS
            program_error               = 1
            OTHERS                      = 2.
      ELSE.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program          = local_repid
            i_callback_pf_status_set    = g_pf_status
            i_callback_user_command     = g_user_command
*           i_grid_title                = joblog_title
            i_callback_html_top_of_page = html_top_of_page
            is_layout                   = gs_layout
            it_fieldcat                 = gt_fieldcat
            it_sort                     = gt_sort
            it_filter                   = gt_filter
            it_events                   = event_tbl
            it_event_exit               = event_exit_tbl[]
            it_except_qinfo             = gt_exc
            i_save                      = 'A'
            i_default                   = 'X'
          TABLES
            t_outtab                    = output_joblist
          EXCEPTIONS
            program_error               = 1
            OTHERS                      = 2.
      ENDIF.

      IF sy-subrc <> 0.
        MESSAGE e641 WITH sy-subrc.
      ENDIF.
    ELSE.
      IF p_grid = 'L'.
        CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
          EXPORTING
            i_callback_program       = local_repid
            i_callback_pf_status_set = g_pf_status
            i_callback_user_command  = g_user_command
            is_layout                = gs_layout
            it_fieldcat              = gt_fieldcat
            it_sort                  = gt_sort
            it_filter                = gt_filter
            it_events                = event_tbl
            it_event_exit            = event_exit_tbl[]
            i_save                   = 'A'
            i_default                = 'X'
          TABLES
            t_outtab                 = output_joblist
          EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
      ELSE.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program       = local_repid
            i_callback_pf_status_set = g_pf_status
            i_callback_user_command  = g_user_command
*           i_grid_title             = joblog_title
            is_layout                = gs_layout
            it_fieldcat              = gt_fieldcat
            it_sort                  = gt_sort
            it_filter                = gt_filter
            it_events                = event_tbl
            it_event_exit            = event_exit_tbl[]
            it_except_qinfo          = gt_exc
            i_save                   = 'A'
            i_default                = 'X'
          TABLES
            t_outtab                 = output_joblist
          EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
      ENDIF.

      IF sy-subrc <> 0.
        MESSAGE e641 WITH sy-subrc.
      ENDIF.
    ENDIF.
  ELSE.
    IF p_grid = 'L'.
      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
        EXPORTING
          i_callback_program       = local_repid
          i_callback_pf_status_set = g_pf_status
          i_callback_user_command  = g_user_command
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat
          it_sort                  = gt_sort
          it_filter                = gt_filter
          it_events                = event_tbl
          it_event_exit            = event_exit_tbl[]
          i_save                   = 'A'
          i_default                = 'X'
        TABLES
          t_outtab                 = output_joblist
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
    ELSE.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = local_repid
          i_callback_pf_status_set = g_pf_status
          i_callback_user_command  = g_user_command
          i_grid_title             = stable_title
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat
          it_sort                  = gt_sort
          it_filter                = gt_filter
          it_events                = event_tbl
          it_event_exit            = event_exit_tbl[]
          it_except_qinfo          = gt_exc
          i_save                   = 'A'
          i_default                = 'X'
        TABLES
          t_outtab                 = output_joblist
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
    ENDIF.
    IF sy-subrc <> 0.
      MESSAGE e641 WITH sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                               " JOB_OVERVIEW_ALV_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EDIT_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SEL_JOBLIST_JOBNAME  text
*      -->P_SEL_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM edit_job_sm37b TABLES joblist STRUCTURE tbtcjob
                    USING jobname LIKE tbtcjob-jobname
                          jobcount LIKE tbtcjob-jobcount.

  PERFORM check_authority_to_release
    USING jobname jobcount.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      jobname          = jobname
      jobcount         = jobcount
      dialog           = btc_yes
      opcode           = btc_modify_whole_job
    IMPORTING
      modified_jobhead = joblist
    TABLES
      new_steplist     = global_step_tbl  " Dummy
    EXCEPTIONS
      OTHERS           = 99.

ENDFORM.                               " EDIT_JOB_SM37B
*&---------------------------------------------------------------------*
*&      Form  MOVE_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SEL_JOBLIST_JOBNAME  text
*      -->P_SEL_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM move_job_sm37b TABLES joblist STRUCTURE tbtcjob
                    USING jobname LIKE tbtcjob-jobname
                          jobcount LIKE tbtcjob-jobcount.
  IF block_marking_is_active EQ true.
*
*    prüfen, ob eine "offene" (nicht beendete) Blockmarkierung vorliegt
*
    IF block_starts_at_row NE 0 AND
       block_ends_at_row   EQ 0.
      MESSAGE e163.
    ENDIF.
*
*    Name des neuen Zielrechners vom Anwender erfragen
*
    CLEAR btch1270.

    CALL SCREEN 1270 STARTING AT 10 5
                     ENDING   AT 65 7.

    IF okcode EQ 'CAN' OR okcode EQ 'ECAN'.
      EXIT.
    ENDIF.
*
*    jetzt alle markierten Jobs 'umziehen' auf neuen Zielrechner
*
    LOOP AT joblist.
      IF joblist-newflag EQ 'X'.
        CALL FUNCTION 'BP_JOB_MOVE'
          EXPORTING
            jobname           = jobname
            jobcount          = jobcount
            dialog            = btc_yes
            new_target_system = btch1270-newtgtsrv
            new_target_group  = btch1270-newtgtgrp
          EXCEPTIONS
            OTHERS            = 99.

        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM init_joblist_block_proc.
  ELSE.
*
*    Name des neuen Zielrechners vom Anwender erfragen, Job umziehen
*
    CLEAR btch1270.

    CALL SCREEN 1270 STARTING AT 10 5
                     ENDING   AT 65 7.

    IF okcode EQ 'CAN' OR okcode EQ 'ECAN'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'BP_JOB_MOVE'
      EXPORTING
        jobname           = jobname
        jobcount          = jobcount
        dialog            = btc_yes
        new_target_system = btch1270-newtgtsrv
        new_target_group  = btch1270-newtgtgrp
      EXCEPTIONS
        OTHERS            = 99.
  ENDIF.


ENDFORM.                               " MOVE_JOB_SM37B
*&---------------------------------------------------------------------*
*&      Form  DEBUG_ACTIVE_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SEL_JOBLIST_JOBNAME  text
*      -->P_SEL_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM debug_active_job_sm37b TABLES joblist STRUCTURE tbtcjob
                            USING jobname LIKE tbtcjob-jobname
                                  jobcount LIKE tbtcjob-jobcount.
  DATA: wp_no LIKE wpinfo-wp_index,
        subrc LIKE sy-subrc,
        rc TYPE i.

  DATA: BEGIN OF act_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF act_jobhead.

  DATA: BEGIN OF act_steplist OCCURS 0." Dummy, wird nur wegen FB-Auf-
          INCLUDE STRUCTURE tbtcstep.  " ruf BP_JOB_READ gebraucht
  DATA: END OF act_steplist.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_jobhead_only
    IMPORTING
      job_read_jobhead  = act_jobhead
    TABLES
      job_read_steplist = act_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist den Job 'einzufangen'
*
  PERFORM check_operation_privilege USING act_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e196.
  ENDIF.
*
* Debuggen ist nur möglich, wenn
*
*  a) der Job aktiv ist
*  b) der Benutzer auf dem Rechner angemeldet ist, auf dem der Job
*     läuft
*
  IF act_jobhead-status NE btc_running.
    MESSAGE e186 WITH jobname.
  ENDIF.

  IF act_jobhead-btcsysreax NE sy-host.
    MESSAGE e187 WITH jobname act_jobhead-btcsysreax.
  ENDIF.

  wp_no = act_jobhead-wpnumber.

  CALL FUNCTION 'TH_DEBUG_WP'
    EXPORTING
      wp_index        = wp_no
    IMPORTING
      subrc        = subrc
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 99.

  CASE sy-subrc.
    WHEN 0.
      " ok, Debuggen hat funktioniert
    WHEN 1.
      MESSAGE e192.
    WHEN OTHERS.
      MESSAGE e188 WITH jobname.
  ENDCASE.

ENDFORM.                               " DEBUG_ACTIVE_JOB_SM37B

*&---------------------------------------------------------------------*
*&      Form  REPEAT_JOB_DEFINITION_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SEL_JOBLIST_JOBNAME  text
*      -->P_SEL_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM repeat_job_definition_sm37b TABLES joblist STRUCTURE tbtcjob
                                 USING jobname LIKE tbtcjob-jobname
                                       jobcount LIKE tbtcjob-jobcount.
  DATA: rc TYPE i VALUE 0,
        stdt_modify_flag LIKE btch0000-int4.

  DATA: BEGIN OF old_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF old_jobhead.

  DATA: BEGIN OF new_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF new_stdt.

  DATA: BEGIN OF old_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF old_steplist.
*
* prüfen, ob Benutzer berechtigt ist, Jobs einzuplanen
*
  PERFORM check_job_plan_privilege USING rc.

  IF rc NE 0.
    MESSAGE e266.
  ENDIF.
*
* Jobdaten aus Datenbank lesen und prüfen, ob Operation zulässig ist
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = old_jobhead
    TABLES
      job_read_steplist = old_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist die Einplanung des Jobs zu wiederh.
*
  PERFORM check_operation_privilege USING old_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e193.
  ENDIF.

  IF old_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname.
  ENDIF.

* 15.8.2013   note 1900810    d023157
* 'Repeat scheduling' (in SM37) of successor does not work any more
* therefore some special coding here. We delete the jobcount of the
* old predecessor. Otherwise it is automatically taken into dynpro
* 1010 (but not displayed), and since the old predecessor has already
* run, repeating scheduling will fail then.
  if sy-batch is initial.
     if old_jobhead-eventid = 'SAP_END_OF_JOB'.
        old_jobhead-eventparm = old_jobhead-eventparm(32).
     endif.
  endif.

*
* Starttermindaten extrahieren, Starttermineditor aufrufen und an-
* schliessend die neuen Starttermindaten in den Jobkopfdaten speichern
*
  PERFORM extract_stdt_from_jobhead USING old_jobhead new_stdt.

  CALL FUNCTION 'BP_START_DATE_EDITOR'
    EXPORTING
      stdt_dialog      = btc_yes
      stdt_opcode      = btc_edit_startdate
      stdt_input       = new_stdt
    IMPORTING
      stdt_output      = new_stdt
      stdt_modify_type = stdt_modify_flag
    EXCEPTIONS
      OTHERS           = 99.

  IF sy-subrc NE 0 OR
     stdt_modify_flag EQ btc_stdt_not_modified.
    EXIT.
  ENDIF.

  PERFORM store_stdt_in_jobhead USING old_jobhead
                                      new_stdt
                                      btc_no
                                      rc.
  IF rc NE 0.
    MESSAGE e158 WITH jobname.
  ENDIF.

* note 773686
  IF old_jobhead-authckman NE sy-mandt.
    MESSAGE i648 WITH old_jobhead-authckman sy-mandt.
  ENDIF.

  IF edit_modus IS INITIAL.    " note 1921763
    edit_modus = sy-ucomm.
  ENDIF.
*
* neuen Job erzeugen
*
  CALL FUNCTION 'BP_JOB_CREATE'
    EXPORTING
      job_cr_dialog   = btc_no
      job_cr_head_inp = old_jobhead
    IMPORTING
      job_cr_head_out = old_jobhead
    TABLES
      job_cr_steplist = old_steplist
    EXCEPTIONS
      OTHERS          = 99.

  IF sy-subrc EQ 0.
    CLEAR joblist.
    joblist = old_jobhead.

    APPEND joblist.

    MESSAGE s156 WITH jobname.
  ELSE.
    MESSAGE e157 WITH jobname.
  ENDIF.

ENDFORM.                               " REPEAT_JOB_DEFINITION_SM37B
*&---------------------------------------------------------------------*
*&      Form  POPUP_FOR_DELETION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ANSWER  text
*----------------------------------------------------------------------*
FORM popup_for_deletion USING answer.
  CLEAR popup_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'                   "#EC FB_OLDED
    EXPORTING
      defaultoption = 'N'
      textline1     = text-704
      textline2     = text-705
      titel         = text-706
    IMPORTING
      answer        = popup_answer
    EXCEPTIONS
      OTHERS        = 1.

  answer = popup_answer.

ENDFORM.                               " POPUP_FOR_DELETION

*&---------------------------------------------------------------------*
*&      Form  POPUP_FOR_CANCELATION
*&---------------------------------------------------------------------*
* WO, 30.08.2004
*----------------------------------------------------------------------*
FORM popup_for_cancelation USING answer.
  CLEAR popup_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'                   "#EC FB_OLDED
    EXPORTING
      defaultoption = 'N'
      textline1     = text-704
      textline2     = text-783
      titel         = text-783
    IMPORTING
      answer        = popup_answer
    EXCEPTIONS
      OTHERS        = 1.

  answer = popup_answer.

ENDFORM.                               " POPUP_FOR_CANCELATION

*&---------------------------------------------------------------------*
*&      Form  SHOW_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SEL_JOBLIST_JOBNAME  text
*      -->P_SEL_JOBLIST_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM show_job_sm37b TABLES joblist STRUCTURE tbtcjob
                    USING jobname LIKE tbtcjob-jobname
                          jobcount LIKE tbtcjob-jobcount.
  DATA: rc TYPE i.

  DATA: BEGIN OF jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF jobhead.

  DATA: BEGIN OF job_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF job_steplist.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = jobhead
    TABLES
      job_read_steplist = job_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname.
  ENDCASE.

  IF jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname.
  ENDIF.
*
* Anzeigeberechtigung prüfen. Anzeigeberechtigung liegt vor, wenn:
*
*  - der Job vom gerade aktive Benutzer erstellt wurde oder
*  - der Benutzer Batchadministratorberechtigung hat oder
*  - der Benutzer generelle Anzeigeberechtigung für Jobs hat
*
  PERFORM check_operation_privilege USING jobhead-sdluname rc.

  IF rc NE 0.
    PERFORM check_job_show_privilege USING rc.
    IF rc NE 0.
      MESSAGE e251 WITH jobhead-jobname.
    ENDIF.
  ENDIF.
*
* Jobdaten anzeigen
*
  CALL FUNCTION 'BP_JOB_EDITOR'
    EXPORTING
      job_editor_dialog = btc_yes
      job_editor_opcode = btc_show_job
      job_head_input    = jobhead
    TABLES
      job_steplist      = job_steplist
    EXCEPTIONS
      OTHERS            = 99.


ENDFORM.                               " SHOW_JOB_SM37B

*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT_FOR_ALV_LIST
*&---------------------------------------------------------------------*
*       check with ALV internal fieldcat and see whether the
*       list has been displayed before and refresh the list
*       according to the current configuration.
*----------------------------------------------------------------------*
FORM get_fieldcat_for_alv_list USING
                       fieldcat    TYPE slis_t_fieldcat_alv
                       sort_crit   TYPE slis_t_sortinfo_alv
                       filter_crit TYPE slis_t_filter_alv
                       tabname  TYPE slis_tabname
                       interval_start TYPE p
                       rc       TYPE i.

  DATA: len                         TYPE i,
        fieldcat_entry              LIKE LINE OF fieldcat,
        prev_fieldcat_entry         LIKE LINE OF fieldcat,
        fieldcat_index              LIKE sy-tabix,
        fieldcat_already_exists     LIKE true,
        alv_internal_fieldcat_index LIKE sy-tabix,
        alv_internal_fieldcat       TYPE kkblo_t_fieldcat,
        alv_internal_fieldcat_entry LIKE LINE OF alv_internal_fieldcat.

  rc = 0.
  REFRESH fieldcat.
  REFRESH sort_crit.
  REFRESH filter_crit.

  sort_crit[]   = prev_sort[].
  filter_crit[] = prev_filter[].

  PERFORM fieldcat_init TABLES fieldcat.

  DESCRIBE TABLE prev_fieldcat LINES len.
  IF len EQ 0.
    EXIT.
  ELSE.
    LOOP AT   prev_fieldcat
         INTO prev_fieldcat_entry.
      READ TABLE fieldcat
           INTO  fieldcat_entry
           WITH KEY fieldname =
                prev_fieldcat_entry-fieldname.
      IF sy-subrc EQ 0.
        fieldcat_index         = sy-tabix.
        fieldcat_entry-col_pos = fieldcat_index.
        fieldcat_entry-row_pos = prev_fieldcat_entry-row_pos.
        fieldcat_entry-no_out  =
                       prev_fieldcat_entry-no_out.
        fieldcat_entry-emphasize =
                       prev_fieldcat_entry-emphasize.
        MODIFY fieldcat
               FROM fieldcat_entry
               INDEX fieldcat_index.
      ELSE.
        rc = 99.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " GET_FIELDCAT_FOR_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_STATUS_Sm37b
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_SCHEDULED_FLAG  text
*      -->P_RELEASED_FLAG  text
*      -->P_READY_FLAG  text
*      -->P_ACTIVE_FLAG  text
*      -->P_FINISHED_FLAG  text
*      -->P_CANCELLED_FLAG  text
*----------------------------------------------------------------------*
FORM determine_status_sm37b USING
                            select_values STRUCTURE btcselect
                            status_set STRUCTURE status_set.

  DATA: BEGIN OF p_status_clause.
  DATA:
    prefix(2) TYPE c,
    clause    LIKE status_set-clause,
  END OF p_status_clause.

  DATA:
    p_status_counter TYPE i.

  CLEAR status_set.

  IF select_values-prelim   EQ 'X'.
    status_set-scheduled_flag = 'P'.
    CONCATENATE p_status_clause ', ''P''' INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.

  IF select_values-schedul  EQ 'X'.
    status_set-released_flag  = 'S'.
    status_set-suspended_flag = 'Z'.   " take upgrade jobs into account
    CONCATENATE p_status_clause ', ''S'', ''Z'''
      INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.
  IF select_values-ready    EQ 'X'.
    status_set-ready_flag = 'Y'.
    CONCATENATE p_status_clause ', ''Y''' INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.
  IF select_values-running  EQ 'X'.
    status_set-active_flag = 'R'.
    CONCATENATE p_status_clause ', ''R''' INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.
  IF select_values-finished  EQ 'X'.
    status_set-finished_flag = 'F'.
    CONCATENATE p_status_clause ', ''F''' INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.
  IF select_values-aborted  EQ 'X'.
    status_set-cancelled_flag = 'A'.
    CONCATENATE p_status_clause ', ''A''' INTO p_status_clause.
    p_status_counter = p_status_counter + 1.
  ENDIF.

  IF p_status_counter = 6.
    EXIT.
  ENDIF.

  status_set-clause = p_status_clause-clause.

  IF NOT status_set-clause IS INITIAL.
    CONCATENATE '(' status_set-clause ')' INTO status_set-clause.
    CONCATENATE 'STATUS IN' status_set-clause INTO status_set-clause
      SEPARATED BY space.
  ENDIF.

ENDFORM.                               " DETERMINE_STATUS_SELECT_TYPE_S
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_TIME_ONLY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_time_only USING
                            select_values STRUCTURE btcselect
                            status_set    STRUCTURE status_set
                            batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  DATA: jobname2(66).
  PERFORM change_jobname_wildcard
    USING select_values-jobname
    CHANGING jobname2.

  IF batch_admin_privilege EQ btc_yes.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR
                    (
                      sdlstrtdt EQ no_date AND
                      eventid   EQ space
                    )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            (
                (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                 )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ELSE.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            authckman EQ sy-mandt
            AND
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR
                    (
                      sdlstrtdt EQ no_date AND
                      eventid   EQ space
                    )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE
            authckman EQ sy-mandt
            AND
            (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ENDIF.
  total_selection_count = sy-dbcnt.
ENDFORM.                               " DO_SELECT_TIME_ONLY
*&---------------------------------------------------------------------*
*&      Form  TRANSLATE_SEL_FIELDS_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_ENDDATE  text
*      -->P_ENDTIME  text
*      -->P_PREDJOB_EVENTID  text
*      -->P_EVT_WILDCARD_FROM_USER  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM translate_sel_fields_sm37b USING
                                select_values STRUCTURE btcselect
                                enddate LIKE tbtco-enddate
                                endtime LIKE tbtco-endtime
                                predjob_eventid
                                evt_wildcard_from_user
                                trigger_flag
                                wild_card_or_not
                                rc.

*
* fix for initialization of esacpe character -- non-printable character
* to switch off escape
* Date: 07/11/2000
* Author: YANGH
* Release: 50
*
  DATA: x1(4) TYPE x VALUE '01',
       init_esc_char TYPE c. " initial_escape_character ->
  " non-printable character for escape off
  FIELD-SYMBOLS: <jd>.
  ASSIGN x1 TO <jd> TYPE 'C'.
  init_esc_char = <jd>.
*
* end of fix
*

*
* Translate the jobname field and username field according to the
* ABAP select statements and catch exceptions.
*

  IF select_values-eventid IS NOT INITIAL.  "note 1629794
    IF select_values-eventparm IS INITIAL.
      select_values-eventparm = '*'.
    ENDIF.
  ENDIF.

  IF select_values-jobname EQ space.
    rc = no_jobname_specified.
    EXIT.
  ELSE.
* differentiate the wild_card or full name here.
    IF ( select_values-jobname CA '*' OR
         select_values-username CA '*' OR
         select_values-abapname CA '*' ).
      wild_card_or_not = 'Y'.
    ELSE.
      wild_card_or_not = 'N'.
    ENDIF.
    TRANSLATE select_values USING '*%'.
  ENDIF.

  IF select_values-username EQ space.
    rc = no_user_specified.
    EXIT.
  ENDIF.

* clean up wild card indicators
  CLEAR abap_wildcard_flag.
  IF select_values-abapname EQ '*'.
    abap_wildcard_flag = 'X'.
  ENDIF.

  IF select_values-abapname EQ space.
    select_values-abapname = '%'.
  ENDIF.

  IF select_values-jobcount EQ space.
    select_values-jobcount = '%'.
  ENDIF.

  IF select_values-jobgroup EQ space.
    select_values-jobgroup = '%'.
  ENDIF.

*
* Differentiate the trigger type.
*
  IF ( select_values-from_date EQ no_date OR
     select_values-from_date EQ '00000000' ) AND
     ( select_values-to_date EQ no_date OR
     select_values-to_date EQ '00000000' ) AND
     select_values-from_time EQ no_time AND
     select_values-to_time   EQ no_time AND
     select_values-eventid   NE space.
    trigger_flag = 'E'.
  ENDIF.
  IF ( select_values-from_date NE no_date AND
     select_values-from_date NE '00000000' ) OR
     ( select_values-to_date   NE no_date AND
     select_values-to_date NE '00000000' ) OR
     select_values-from_time NE no_time OR
     select_values-to_time   NE no_time AND
     select_values-eventid   EQ space.
    trigger_flag = 'T'.
  ENDIF.
  IF ( select_values-from_date EQ no_date OR
     select_values-from_date EQ '00000000' ) AND
     ( select_values-to_date   EQ no_date OR
     select_values-to_date EQ '00000000' ) AND
     select_values-from_time EQ no_time AND
     select_values-to_time   EQ no_time AND
     select_values-eventid   EQ space.
    trigger_flag = 'N'.
  ENDIF.
  IF select_values-eventid   NE space AND
     (
       ( select_values-from_date NE '00000000' AND
         select_values-from_date NE no_date ) OR
       ( select_values-to_date NE '00000000' AND
         select_values-to_date NE no_date ) OR
       select_values-from_time NE no_time OR
       select_values-to_time   NE no_time
     ).
    trigger_flag = 'B'.
  ENDIF.                     " end of differentiate trigger type
*
* Initialize the date / time when necessary.
*
  IF trigger_flag = 'B' OR trigger_flag = 'T'.
    IF select_values-from_date EQ no_date.
      select_values-from_date = initial_from_date.
    ENDIF.

    IF select_values-from_time EQ no_time.
      select_values-from_time = initial_from_time.
    ENDIF.

    IF select_values-to_date EQ no_date OR
       select_values-to_date EQ '00000000'.
      select_values-to_date = initial_to_date.
    ENDIF.

    IF select_values-to_time EQ no_time OR
       select_values-to_time EQ '000000'.
      select_values-to_time = initial_to_time.
    ENDIF.
  ENDIF.                               " end of initializing date/time

*
* Translate the eventid according to ABAP select.
*
  IF trigger_flag = 'B' OR trigger_flag = 'E'.
    TRANSLATE select_values-eventid USING '*%'.
  ENDIF.

ENDFORM.                               " TRANSLATE_SEL_FIELDS_SM37B
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_EVENT_ONLY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_event_only USING  select_values STRUCTURE btcselect
                                 status_set    STRUCTURE status_set
                                 batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  DATA: jobname2(66).
  PERFORM change_jobname_wildcard
    USING select_values-jobname
    CHANGING jobname2.

  IF batch_admin_privilege EQ btc_yes.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  LIKE jobname2 ESCAPE '#'
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   ( eventid NE space AND
            eventid  LIKE select_values-eventid AND
            eventparm LIKE select_values-eventparm
            )
    AND (p_status_clause).
  ELSE.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  LIKE jobname2 ESCAPE '#'
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   ( eventid NE space AND
            eventid  LIKE select_values-eventid AND
            eventparm LIKE select_values-eventparm
            )
    AND   authckman EQ sy-mandt
    AND (p_status_clause).
  ENDIF.
  total_selection_count = sy-dbcnt.
ENDFORM.                               " DO_SELECT_EVENT_ONLY
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATE_TIME_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM check_date_time_validation USING
                                select_values STRUCTURE btcselect
                                rc.
*
* check date and time validation in case user enters them out of
* logic.
*
  IF select_values-from_date > select_values-to_date.
    rc = 1.
    EXIT.
  ENDIF.
  IF select_values-from_date = select_values-to_date AND
     select_values-from_time > select_values-to_time.
    rc = 2.
    EXIT.
  ENDIF.
  IF select_values-from_date < initial_from_date OR
     select_values-to_date   > initial_to_date.
    rc = 3.
    EXIT.
  ENDIF.
  IF select_values-from_date = initial_from_date AND
     select_values-from_time < initial_from_time OR
     select_values-to_date   = initial_to_date   AND
     select_values-to_time   > initial_to_time.
    rc = 4.
    EXIT.
  ENDIF.
  rc = 0.
ENDFORM.                               " CHECK_DATE_TIME_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_GENERAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_general USING select_values STRUCTURE btcselect
                             status_set    STRUCTURE status_set
                             batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  DATA: jobname2(66).
  PERFORM change_jobname_wildcard
    USING select_values-jobname
    CHANGING jobname2.

  DATA: event_flag LIKE tbtco-eventid.
  event_flag = '%'.

  IF batch_admin_privilege EQ btc_yes.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  LIKE jobname2 ESCAPE '#'
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   eventid  LIKE event_flag
    AND (p_status_clause).
  ELSE.
    SELECT * FROM v_op INTO TABLE jobselect_joblist_b
    WHERE jobname  LIKE jobname2 ESCAPE '#'
    AND   sdluname LIKE select_values-username
    AND   jobcount LIKE select_values-jobcount
    AND   jobgroup LIKE select_values-jobgroup
    AND   progname LIKE select_values-abapname
    AND   eventid  LIKE event_flag
    AND authckman EQ sy-mandt
    AND (p_status_clause).
  ENDIF.
  total_selection_count = sy-dbcnt.
ENDFORM.                               " DO_SELECT_GENERAL
*&---------------------------------------------------------------------*
*&      Form  DO_SELECT_TIME_AND_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM do_select_time_and_event USING select_values STRUCTURE btcselect
                                    status_set STRUCTURE status_set
                                    batch_admin_privilege.

  DATA:
    p_status_clause LIKE TABLE OF status_set-clause.
  APPEND status_set-clause TO p_status_clause.

  DATA: jobname2(66).
  PERFORM change_jobname_wildcard
    USING select_values-jobname
    CHANGING jobname2.

  IF batch_admin_privilege EQ btc_yes.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR sdlstrtdt EQ no_date
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND (p_status_clause).
    ENDIF.
  ELSE.
    IF status_set-scheduled_flag NE space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR sdlstrtdt EQ no_date
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND authckman EQ sy-mandt
            AND (p_status_clause).
    ELSEIF status_set-scheduled_flag EQ space.
      SELECT DISTINCT * FROM v_op INTO TABLE jobselect_joblist_b
      WHERE (
                    (
                       ( sdlstrtdt = select_values-from_date
                    AND  sdlstrttm >= select_values-from_time )
                    OR  sdlstrtdt > select_values-from_date
                    )
                    AND
                    (
                       ( sdlstrtdt = select_values-to_date
                    AND sdlstrttm <= select_values-to_time )
                    OR  sdlstrtdt < select_values-to_date
                    )
                    OR ( eventid NE space AND
                         eventid LIKE select_values-eventid )
            )
            AND jobname  LIKE jobname2 ESCAPE '#'
            AND sdluname LIKE select_values-username
            AND jobcount LIKE select_values-jobcount
            AND jobgroup LIKE select_values-jobgroup
            AND progname LIKE select_values-abapname
            AND authckman EQ sy-mandt
            AND (p_status_clause).
    ENDIF.
  ENDIF.
  total_selection_count = sy-dbcnt.
ENDFORM.                               " DO_SELECT_TIME_AND_EVENT
*&---------------------------------------------------------------------*
*&      Form  HANDLE_SELECTED_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBSEL_PARAM_IN  text
*      -->P_STATUS_SET  text
*      -->P_BATCH_ADMIN_PRIVILEGE_GIVEN  text
*----------------------------------------------------------------------*
FORM handle_selected_values.
  DATA: index_count TYPE i VALUE 0,
        prev_jname LIKE tbtco-jobname,
        prev_jcount LIKE tbtco-jobcount.

  DATA: option TYPE btcoptions-btcoption.
  DATA: optionstab TYPE TABLE OF btcoptions.
  DATA: smx_option TYPE btcoptions.

  get_option btc_opt_smx_own_client optionstab smx_option.
*
* move the useful contents into itab sel_joblist
*
  SORT sel_joblist_b.
  LOOP AT sel_joblist_b .
    CLEAR sel_joblist.
    IF ( sy-tcode(3) = 'SMX' OR disp_own_job_advanced_flag = 'X' )
      AND smx_option-btcoption = btc_opt_smx_own_client.     " note 1458243
      IF sel_joblist_b-authckman <> sy-mandt.
        DELETE sel_joblist_b INDEX sy-index.
        CONTINUE.
      ENDIF.
    ENDIF.
* make sure the rows are distinct
    index_count = index_count + 1.
    IF index_count = 1.
      MOVE-CORRESPONDING sel_joblist_b TO sel_joblist.
      APPEND sel_joblist.
      prev_jname  = sel_joblist_b-jobname.
      prev_jcount = sel_joblist_b-jobcount.
    ELSE.
      READ TABLE sel_joblist_b INDEX index_count.
      IF ( sel_joblist_b-jobname  = prev_jname AND
           sel_joblist_b-jobcount = prev_jcount ).
        " do nothing but return to the beginning of the loop.
      ELSE.
        MOVE-CORRESPONDING sel_joblist_b TO sel_joblist.
        APPEND sel_joblist.
        prev_jname  = sel_joblist_b-jobname.
        prev_jcount = sel_joblist_b-jobcount.
      ENDIF.
    ENDIF.

  ENDLOOP.

  PERFORM indicate_progress_for_part
         USING text-648 parts 3.

  PERFORM job_overview_alv_display.

ENDFORM.                               " HANDLE_SELECTED_VALUES
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNPRONR  text
*----------------------------------------------------------------------*
FORM event_handler USING dpno LIKE dynpronr.
  IF dpno = '3000' AND sy-tcode NE 'SMX' AND sy-tcode NE 'SMXX'.
    event_row-name = slis_ev_top_of_page.
    event_row-form = 'JOB_OVERVIEW_TOP_OF_PAGE'.
    APPEND event_row TO event_tbl.

  ELSEIF dpno CP '4000'.
    event_row-name = slis_ev_top_of_page.
    event_row-form = 'JOB_OVERVIEW_TOP_OF_PAGE_C'.
    APPEND event_row TO event_tbl.

  ENDIF.

  REFRESH event_exit_tbl.
  event_exit_row-after = 'X'.
  CLEAR event_exit_row-before.
  event_exit_row-ucomm = '&OUP'.
  APPEND event_exit_row TO event_exit_tbl.
  event_exit_row-ucomm = '&ODN'.
  APPEND event_exit_row TO event_exit_tbl.

ENDFORM.                               " EVENT_HANDLER
*---------------------------------------------------------------------*
*       FORM JOB_OVERVIEW_TOP_OF_PAGE_C                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM job_overview_top_of_page_c.
  DATA: event_flag(1),
        prog_flag(1).

  IF btch3071-eventid = ' ' AND btch3071-jobid = ' '
     AND btch3071-opmodeid = ' '.
    event_flag = space.
  ELSE.
    event_flag = 'X'.
  ENDIF.

  IF btch3077-abapname = space.
    prog_flag  = space.
  ELSE.
    prog_flag  = 'X'.
  ENDIF.

  NEW-LINE NO-SCROLLING.
  WRITE: / text-619 INTENSIFIED OFF,
           btch3071-from_date,
           text-620 INTENSIFIED OFF, btch3071-from_time.
  NEW-LINE NO-SCROLLING.
  WRITE: / text-621 INTENSIFIED OFF,
           btch3071-to_date,
           text-620 INTENSIFIED OFF, btch3071-to_time.

  NEW-LINE NO-SCROLLING.
  WRITE: /
           text-622 INTENSIFIED OFF,
           btch3070-jobname.
  NEW-LINE NO-SCROLLING.
  WRITE: /
           text-623 INTENSIFIED OFF,
           btch3070-username.
  SKIP 1.
  NEW-LINE NO-SCROLLING.
  WRITE: /
           btch3075-prelim AS CHECKBOX INPUT OFF,
                               text-079 INTENSIFIED OFF, ' ',
           btch3075-running AS CHECKBOX INPUT OFF,
                               text-077 INTENSIFIED OFF, ' ',
           btch3075-schedul AS CHECKBOX INPUT OFF,
                               text-080 INTENSIFIED OFF, ' ',
           btch3075-finished AS CHECKBOX INPUT OFF,
                               text-082 INTENSIFIED OFF, ' ',
           btch3075-ready AS CHECKBOX INPUT OFF,
                               text-078 INTENSIFIED OFF, ' ',
           btch3075-aborted AS CHECKBOX INPUT OFF,
                               text-081 INTENSIFIED OFF.

  NEW-LINE NO-SCROLLING.
  WRITE: /
          event_flag AS CHECKBOX INPUT OFF,
                            text-626 INTENSIFIED OFF, '  ',
          text-627 INTENSIFIED OFF, btch3071-eventid.

  NEW-LINE NO-SCROLLING.
  WRITE: / ' ',
          text-641 INTENSIFIED OFF, btch3071-opmodeid,
          text-640 INTENSIFIED OFF, btch3071-jobid.

  NEW-LINE NO-SCROLLING.
  WRITE: /
          prog_flag AS CHECKBOX INPUT OFF,
                          text-629 INTENSIFIED OFF, '  ',
          text-630 INTENSIFIED OFF, btch3077-abapname.
  SKIP 1.

ENDFORM.                    "job_overview_top_of_page_c
*&---------------------------------------------------------------------*
*&      Form  DEBUG_JOB_SM37B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_SELECTED_JOB_NAME  text
*      -->P_SELECTED_JOB_COUNT  text
*----------------------------------------------------------------------*
FORM debug_job_sm37b TABLES joblist STRUCTURE tbtcjob
                     USING  jobname LIKE tbtcjob-jobname
                            jobcount LIKE tbtcjob-jobcount.

  DATA: rc TYPE i,
        switch_btc_dbg_on  TYPE i VALUE 1,
        switch_btc_dbg_off TYPE i VALUE 0,
        debugging_possible LIKE true.

  DATA: BEGIN OF dbg_jobhead.
          INCLUDE STRUCTURE tbtcjob.
  DATA: END OF dbg_jobhead.

  DATA: BEGIN OF dbg_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcstep.
  DATA: END OF dbg_steplist.

  DATA: BEGIN OF packed_print_params.
          INCLUDE STRUCTURE pri_params.
  DATA: END OF packed_print_params.

  DATA: BEGIN OF packed_arc_params.
          INCLUDE STRUCTURE arc_params.
  DATA: END OF packed_arc_params.
*
* Jobdaten aus Datenbank lesen
*
  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobname  = jobname
      job_read_jobcount = jobcount
      job_read_opcode   = btc_read_all_jobdata
    IMPORTING
      job_read_jobhead  = dbg_jobhead
    TABLES
      job_read_steplist = dbg_steplist
    EXCEPTIONS
      job_doesnt_exist  = 1
      OTHERS            = 99.

  CASE sy-subrc.
    WHEN 0.
      " Lesen hat geklappt
    WHEN 1.
      MESSAGE e127 WITH jobname.
    WHEN OTHERS.
      MESSAGE e155 WITH jobname.
  ENDCASE.
*
* prüfen, ob Benutzer berechtigt ist den Job zu debuggen
*
  PERFORM check_operation_privilege USING dbg_jobhead-sdluname rc.

  IF rc NE 0.
    MESSAGE e195.
  ENDIF.

* note 725790
  PERFORM check_system_debugging USING rc.

  IF rc NE 0.
    MESSAGE e192.
  ENDIF.

*
* Debuggen ist nur möglich, wenn
*
*  a) die Jobdefinition abgeschlossen ist
*  b) der Job keine externen Programme enthält
*  c) der Job nicht aktiv ist
*
  IF dbg_jobhead-newflag EQ 'O'.
    MESSAGE e182 WITH jobname.
  ENDIF.

  debugging_possible = true.

  LOOP AT dbg_steplist.
    IF ( dbg_steplist-typ EQ btc_xpg OR
         dbg_steplist-typ EQ btc_xcmd  ).
      debugging_possible = false.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF debugging_possible EQ false.
    MESSAGE e183 WITH jobname.
  ENDIF.

  IF dbg_jobhead-status EQ btc_ready OR
     dbg_jobhead-status EQ btc_running.
    MESSAGE e185 WITH jobname.
  ENDIF.
*
* jetzt die Reports der einzelnen Jobsteps im Debugmodus aufrufen:
*

* save job values for call of GET_JOB_RUNTIME_INFO
  FREE MEMORY ID 'JN'.
  FREE MEMORY ID 'JC'.
  FREE MEMORY ID 'SC'.
  EXPORT jn = jobname TO MEMORY ID 'JN'.
  EXPORT jc = jobcount TO MEMORY ID 'JC'.

  LOOP AT dbg_steplist.
    MOVE-CORRESPONDING dbg_steplist TO packed_print_params.
    MOVE-CORRESPONDING dbg_steplist TO packed_arc_params.

    EXPORT sc = sy-tabix TO MEMORY ID 'SC'.

    CALL 'BatchDebugging' ID 'FLAG' FIELD switch_btc_dbg_on.
    sy-debug = 'Y'.                                       "#EC WRITE_OK

    SUBMIT (dbg_steplist-program)
      TO SAP-SPOOL WITHOUT SPOOL DYNPRO
*      USER dbg_steplist-authcknam
      USING SELECTION-SET dbg_steplist-parameter
      SPOOL PARAMETERS packed_print_params
      ARCHIVE PARAMETERS packed_arc_params
      AND RETURN.

    sy-debug = 'N'.                                       "#EC WRITE_OK
    CALL 'BatchDebugging' ID 'FLAG' FIELD switch_btc_dbg_off.
  ENDLOOP.

  FREE MEMORY ID 'JN'.
  FREE MEMORY ID 'JC'.
  FREE MEMORY ID 'SC'.

ENDFORM.                               " DEBUG_JOB_SM37B
*&---------------------------------------------------------------------*
*&      Form  handle_under_score_jobname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->STRING1 input string
*----------------------------------------------------------------------*
FORM handle_under_score_jobname USING string1 LIKE tbtco-jobname.
  DATA: string_len TYPE i.
  DATA: new_string(64) VALUE space,    " double the new string space
                                       " to avoid length overflow
        delimiter(2) VALUE '!_',      " '!' is the escape character used
                                       " later.
        last_one(1).                   " last character in the string
  DATA: BEGIN OF itab OCCURS 10,
          jobname LIKE tbtco-jobname,
        END OF itab.

  SPLIT string1 AT '_' INTO TABLE itab.
* if there is an '_' at the end of the string, append an empty line
* at the end of the internal table.  -- just for the special cases
  string_len = strlen( string1 ) - 1.  " consider the offset
  MOVE string1+string_len(1) TO last_one.
  IF last_one EQ '_'.
    APPEND space TO itab.
  ENDIF.
  LOOP AT itab.
    IF sy-tabix EQ 1.
      MOVE itab-jobname TO new_string.
      CONTINUE.
    ENDIF.
    CONCATENATE new_string itab-jobname
                INTO new_string SEPARATED BY delimiter.
  ENDLOOP.
* translate the original string.
  string_len = strlen( new_string ).
  IF string_len > 32.                  " some jerk being really mean
    MOVE new_string+0(31) TO string1.  " fix a wild card at the end
    CONCATENATE string1 '%' INTO string1.
  ELSE.
    MOVE new_string TO string1.
  ENDIF.
ENDFORM.                               " handle_under_score_sign_jobname
*&---------------------------------------------------------------------*
*&      Form  handle_under_score_abapname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SELECT_VALUES_PROGNAME  text
*----------------------------------------------------------------------*
FORM handle_under_score_abapname USING string1 LIKE tbtcp-progname.
  DATA: string_len TYPE i.
  DATA: new_string(80) VALUE space,    " double the space to avoid
                                       " length overflow
        delimiter(2) VALUE '!_',      " '!' is the escape character used
                                       " later.
        last_one(1).                   " last character in the string
  DATA: BEGIN OF itab OCCURS 10,
          jobname LIKE tbtco-jobname,
        END OF itab.

  SPLIT string1 AT '_' INTO TABLE itab.
* if there is an '_' at the end of the string, append an empty line
* at the end of the internal table.  -- just for the special cases
  string_len = strlen( string1 ) - 1.  " consider the offset
  MOVE string1+string_len(1) TO last_one.
  IF last_one EQ '_'.
    APPEND space TO itab.
  ENDIF.
  LOOP AT itab.
    IF sy-tabix EQ 1.
      MOVE itab-jobname TO new_string.
      CONTINUE.
    ENDIF.
    CONCATENATE new_string itab-jobname
                INTO new_string SEPARATED BY delimiter.
  ENDLOOP.
* translate the original string.
  string_len = strlen( new_string ).
  IF string_len > 40.                  " some jerk being really mean
    MOVE new_string+0(39) TO string1.  " fix a wild card at the end
    CONCATENATE string1 '%' INTO string1.
  ELSE.
    MOVE new_string TO string1.
  ENDIF.

ENDFORM.                               " handle_under_score_abapname
*&---------------------------------------------------------------------*
*&      Form  HANDLE_UNDER_SCORE_USERNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SELECT_VALUES_USERNAME  text
*----------------------------------------------------------------------*
FORM handle_under_score_username USING string1 LIKE tbtco-sdluname.
  DATA: string_len TYPE i.
  DATA: new_string(24) VALUE space,    " double the space to avoid
                                       " length overflow
        delimiter(2) VALUE '!_',      " '!' is the escape character used
                                       " later.
        last_one(1).                   " last character in the string
  DATA: BEGIN OF itab OCCURS 10,
          jobname LIKE tbtco-jobname,
        END OF itab.

  SPLIT string1 AT '_' INTO TABLE itab.
* if there is an '_' at the end of the string, append an empty line
* at the end of the internal table.  -- just for the special cases
  string_len = strlen( string1 ) - 1.  " consider the offset
  MOVE string1+string_len(1) TO last_one.
  IF last_one EQ '_'.
    APPEND space TO itab.
  ENDIF.
  LOOP AT itab.
    IF sy-tabix EQ 1.
      MOVE itab-jobname TO new_string.
      CONTINUE.
    ENDIF.
    CONCATENATE new_string itab-jobname
                INTO new_string SEPARATED BY delimiter.
  ENDLOOP.
* translate the original string.
  string_len = strlen( new_string ).
  IF string_len > 12.                  " some jerk being really mean
    MOVE new_string+0(11) TO string1.  " fix a wild card at the end
    CONCATENATE string1 '%' INTO string1.
  ELSE.
    MOVE new_string TO string1.
  ENDIF.


ENDFORM.                               " HANDLE_UNDER_SCORE_USERNAME
*-----------------------------------------------------------------------
* callback formroutine for joblog pf status.
*-----------------------------------------------------------------------
FORM jlog_pf_status USING fcode_extab TYPE slis_t_extab.
  SET TITLEBAR 'SJL' WITH joblog_owner_name.
  SET PF-STATUS 'SHJOBLOG' EXCLUDING fcode_extab.
ENDFORM.                    "jlog_pf_status


*&---------------------------------------------------------------------*
*&      Form  find_resource_in_srv_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_GRP_SERVER_LIST  text
*      -->I_NEW_JOBHEAD_JOBCLASS  text
*      -->I_NEW_STDT      text
*      -->O_ONE_RESOURCE  text
*----------------------------------------------------------------------*
FORM find_resource_in_srv_group
                      USING
                        i_grp_server_list TYPE bpsrventry
                        i_new_jobhead_jobclass
                        i_new_stdt
                        o_one_resource.

* positive: o_one_resource set to a servername
* negative: o_one_resource initial

  DATA: rc              LIKE btch0000-int4,
        dummy_machine   LIKE tbtcjob-btcsystem, "not really used
        tmp_server      TYPE bpsrvline,
        tmp_server_name TYPE btcsrvname.

  o_one_resource = space.
  LOOP AT i_grp_server_list INTO tmp_server.
    tmp_server_name = tmp_server-appsrvname.
    PERFORM check_server_for_job_exec USING
                                tmp_server_name
                                dummy_machine
                                i_new_stdt
                                i_new_jobhead_jobclass
                                rc.
    IF rc = 0.
      o_one_resource = tmp_server_name.
      EXIT.
    ENDIF.
  ENDLOOP.

* note: the first server that says yes is taken i.e.
*       no load balancing in case of start immediate
ENDFORM.                    " find_resource_in_srv_group
*&---------------------------------------------------------------------*
*&      Form  check_distinct_after_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_distinct_after_refresh.
  DATA: index_count TYPE i VALUE 0,
        prev_jname LIKE tbtco-jobname,
        prev_jcount LIKE tbtco-jobcount.

  DATA: option TYPE btcoptions-btcoption.
  DATA: optionstab TYPE TABLE OF btcoptions.
  DATA: smx_option TYPE btcoptions.

  get_option btc_opt_smx_own_client optionstab smx_option.
*
* move the useful contents into itab sel_joblist
*
  SORT sel_joblist_b.

  LOOP AT sel_joblist_b .
    CLEAR sel_joblist.

    IF ( sy-tcode(3) = 'SMX' OR disp_own_job_advanced_flag = 'X' )
      AND smx_option-btcoption = btc_opt_smx_own_client.     " note 1458243
      IF sel_joblist_b-authckman <> sy-mandt.
        DELETE sel_joblist_b INDEX sy-index.
        CONTINUE.
      ENDIF.
    ENDIF.
* make sure the rows are distinct
    index_count = index_count + 1.
    IF index_count = 1.
      MOVE-CORRESPONDING sel_joblist_b TO sel_joblist.
      APPEND sel_joblist.
      prev_jname  = sel_joblist_b-jobname.
      prev_jcount = sel_joblist_b-jobcount.
    ELSE.
      READ TABLE sel_joblist_b INDEX index_count.
      IF ( sel_joblist_b-jobname  = prev_jname AND
           sel_joblist_b-jobcount = prev_jcount ).
        " do nothing but return to the beginning of the loop.
      ELSE.
        MOVE-CORRESPONDING sel_joblist_b TO sel_joblist.
        APPEND sel_joblist.
        prev_jname  = sel_joblist_b-jobname.
        prev_jcount = sel_joblist_b-jobcount.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " check_distinct_after_refresh
*&---------------------------------------------------------------------*
*&      Form  fill_default_sort_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_default_sort_table.
  DATA: i TYPE i,
       gt_sort_wa TYPE slis_sortinfo_alv.

  i = 0.
  DO 5 TIMES.
    i = i + 1.
    CASE i.
      WHEN 1.
        gt_sort_wa-spos = '01'.
        gt_sort_wa-fieldname = 'JOBNAME'.
      WHEN 2.
        gt_sort_wa-spos = '02'.
        gt_sort_wa-fieldname = 'SDLUNAME'.
      WHEN 3.
        gt_sort_wa-spos = '03'.
        gt_sort_wa-fieldname = 'SLIDE_TYPE_STATUS'.
      WHEN 4.
        gt_sort_wa-spos = '04'.
        gt_sort_wa-fieldname = 'SDLSTRTDT'.
      WHEN 5.
        gt_sort_wa-spos = '05'.
        gt_sort_wa-fieldname = 'SDLSTRTTM'.
    ENDCASE.
    gt_sort_wa-tabname = 'OUTPUT_JOBLIST'.
    gt_sort_wa-up = 'X'.
    gt_sort_wa-down = space.
    gt_sort_wa-group = space.
    gt_sort_wa-subtot = space.
    gt_sort_wa-comp = space.
    gt_sort_wa-expa = space.
    gt_sort_wa-obligatory = space.
    APPEND gt_sort_wa TO gt_sort.
  ENDDO.
ENDFORM.                    " fill_default_sort_table

*********************************************************

FORM store_new_steplist_in_db_sub TABLES new_steplist STRUCTURE tbtcstep
                                     old_ppktab   STRUCTURE tbtcp
                              USING  new_job_head STRUCTURE tbtcjob
                                     dialog
                                     rc.

  DATA: step_count TYPE i,
          tmp_key TYPE syprkey.
  DATA: tmp_pri_params LIKE pri_params.

  DATA: BEGIN OF db_steplist OCCURS 10.
          INCLUDE STRUCTURE tbtcp.
  DATA: END OF db_steplist.

  data: wa_db_steplist like tbtcp.

* hgk  13.7.2001
  DATA: step_nr TYPE i.
  DATA: stepcount LIKE tbtcp-stepcount.

  DATA: jobinfo_egj(64).    " note 952782

  DESCRIBE TABLE new_steplist LINES step_nr.

*
* Stepliste in DB-Form erstellen (DB-Tabelle TBTCP)
*
  step_count = 1.

  LOOP AT new_steplist.
    CLEAR db_steplist.

    MOVE-CORRESPONDING new_steplist TO db_steplist.

    db_steplist-jobname   = new_job_head-jobname.
    db_steplist-jobcount  = new_job_head-jobcount.
    db_steplist-stepcount = step_count.
    CLEAR db_steplist-listident.       "neu: spoolid= sy-spono= numc10
    db_steplist-xpgpid    = space.
    db_steplist-status    = btc_scheduled.

    db_steplist-sdldate  = new_job_head-sdldate.
    db_steplist-sdltime  = new_job_head-sdltime.
    db_steplist-sdluname = new_job_head-sdluname.

    IF new_steplist-typ EQ btc_abap.   " Step führt einen Report aus
      db_steplist-progname = new_steplist-program.
      db_steplist-variant  = new_steplist-parameter.

      "only abap steps may have print parameters associated
      "get a valid key here and store it in db
      MOVE-CORRESPONDING new_steplist TO tmp_pri_params.


* when the call comes from job_submit, store_print_parameters should
* only be called for the last step in order to avoid, that the
* number of calls increases quadratically to the number of steps
* hgk   13.7.2001
      IF ( call_from_submit EQ btc_yes AND sy-tabix EQ step_nr )
         OR call_from_submit NE btc_yes.

*        call_from_submit = btc_no.

        CALL FUNCTION 'STORE_PRINT_PARAMETERS'
          EXPORTING
            in_parameters = tmp_pri_params
            applikation   = 'B'
            user          = db_steplist-authcknam
            priprog       = db_steplist-progname
          IMPORTING
            key           = tmp_key
          EXCEPTIONS
            error_occured = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          "could not get a valid key
          IF dialog EQ btc_yes.
            MESSAGE s299 WITH step_count new_job_head-jobname.
          ENDIF.

          CONCATENATE new_job_head-jobname new_job_head-jobcount INTO
          jobinfo_egj SEPARATED BY '/'.

          CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtcp_insert_db_error
          ID 'DATA' FIELD jobinfo_egj.

          rc = 1.
          EXIT.
        ELSE.
          db_steplist-priparkey = tmp_key.
        ENDIF.
      ELSE.
*     alten priparkey besorgen
        READ TABLE old_ppktab INDEX step_count.

        IF sy-subrc NE 0.
          IF dialog EQ btc_yes.
            MESSAGE s299 WITH step_count new_job_head-jobname.
          ENDIF.

          CONCATENATE new_job_head-jobname new_job_head-jobcount INTO
          jobinfo_egj SEPARATED BY '/'.

          CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtcp_insert_db_error
          ID 'DATA' FIELD jobinfo_egj.

          rc = 1.
          EXIT.
        ELSE.
          db_steplist-priparkey = old_ppktab-priparkey.
        ENDIF.

      ENDIF.  " hgk   13.7.2001

*    ELSEIF new_steplist-typ = btc_xcmd." Step executes external command
*      db_steplist-extcmd = new_steplist-program.
*      db_steplist-xpgparams = new_steplist-parameter.
*      db_steplist-xpgflag = 'X'.
*    ELSE. " Step führt ein externes Programm aus
*      db_steplist-xpgprog   = new_steplist-program.
*      db_steplist-xpgparams = new_steplist-parameter.
*      db_steplist-xpgflag   = 'X'.

* insert note 736699
    ELSE. " step executes external command or program
      IF new_steplist-typ = btc_xcmd. " Step executes external command
        db_steplist-extcmd = new_steplist-program.
      ELSE.  " step executes external program
        db_steplist-xpgprog   = new_steplist-program.
      ENDIF.
      db_steplist-xpgparams = new_steplist-parameter.
      db_steplist-xpgflag = 'X'.
      IF NOT new_steplist-xpgpid IS INITIAL.
        CLEAR db_steplist-xpgpid.
      ENDIF.
*      IF NOT new_steplist-xpgrfcdest IS INITIAL.
*        CLEAR db_steplist-xpgrfcdest.
*      ENDIF.
      IF NOT new_steplist-conncntl = comchannel_release.
*      AND NOT new_steplist-conncntl = comchannel_hold.
        db_steplist-conncntl = comchannel_release.
      ENDIF.
      IF NOT new_steplist-stdincntl = stdin_nomanip
      AND NOT new_steplist-stdincntl = stdin_close
      AND NOT new_steplist-stdincntl = stdin_redirect.
        db_steplist-stdincntl = stdin_redirect.
      ENDIF.
      IF NOT new_steplist-stdoutcntl = stdout_nomanip
      AND NOT new_steplist-stdoutcntl = stdout_inmemory
      AND NOT new_steplist-stdoutcntl = stdout_close
      AND NOT new_steplist-stdoutcntl = stdout_redirect
      AND NOT new_steplist-stdoutcntl = stdout_trace.
        db_steplist-stdoutcntl = stdout_inmemory.
      ENDIF.
      IF NOT new_steplist-stderrcntl = stderr_nomanip
      AND NOT new_steplist-stderrcntl = stderr_close
      AND NOT new_steplist-stderrcntl = stderr_redirect
      AND NOT new_steplist-stderrcntl = stderr_inmemory.
        db_steplist-stderrcntl = stderr_inmemory.
      ENDIF.
      IF NOT new_steplist-tracecntl = trace_level0
      AND NOT new_steplist-tracecntl = trace_level3.
        db_steplist-tracecntl = trace_level0.
      ENDIF.
      IF NOT new_steplist-termcntl = term_dont_wait
      AND NOT new_steplist-termcntl = term_by_cntlpgm.
*     and not new_steplist-TERMCNTL = TERM_BY_EVENT.
        db_steplist-termcntl = term_by_cntlpgm.
      ENDIF.

    ENDIF.

    APPEND db_steplist.

    step_count = step_count + 1.
  ENDLOOP.
*
* Stepliste in DB speichern
* If we come from job_submit, we need to store only the last step
*

  if call_from_submit = btc_yes.
     DESCRIBE TABLE db_steplist LINES step_nr.

     read table db_steplist index step_nr into wa_db_steplist.

* avoid duplicate keys ?
     insert into tbtcp values wa_db_steplist.

  else.
     INSERT tbtcp FROM TABLE db_steplist ACCEPTING DUPLICATE KEYS. "n952782
  endif.

  IF sy-subrc NE 0.

    IF dialog EQ btc_yes.
      MESSAGE s120 WITH new_job_head-jobname.
    ENDIF.

    CONCATENATE new_job_head-jobname new_job_head-jobcount INTO
    jobinfo_egj SEPARATED BY '/'.

    CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
          ID 'KEY'  FIELD tbtcp_insert_db_error
          ID 'DATA' FIELD jobinfo_egj.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.


ENDFORM.                               " STORE_NEW_STEPLIST_IN_DB_sub
*&---------------------------------------------------------------------*
*&      Form  refresh_alv_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM refresh_alv_list USING rs_selfield TYPE slis_selfield.

* d023157    5.10.2010   we need to do some calculations regarding
* the scroll position after refreshing

  DATA: new_size TYPE i.

  DATA: gt_exc TYPE TABLE OF alv_s_qinf.

  refresh_list_flag = 'X'.
  rs_selfield-refresh = 'X'.
  rs_selfield-tabname = 'OUTPUT_JOBLIST'.

*     list_snap?
  IF stable_list = btc_joblist_snap.
    DATA: wa_sel_joblist TYPE tbtcjob,
          wa_s_job TYPE tbtco.

    REFRESH sel_joblist.
    LOOP AT output_joblist.
      CLEAR wa_s_job.
      SELECT SINGLE * FROM tbtco
      INTO CORRESPONDING FIELDS OF wa_s_job
      WHERE jobname = output_joblist-jobname AND
            jobcount = output_joblist-jobcount.

      IF sy-dbcnt = 0.
        output_joblist-status = 'U'.
      ELSE.
        MOVE-CORRESPONDING wa_s_job TO output_joblist.
      ENDIF.

      MOVE-CORRESPONDING output_joblist TO wa_sel_joblist.
      APPEND wa_sel_joblist TO sel_joblist.
    ENDLOOP.
  ELSE.

    IF display_advanced_flag IS INITIAL.
*     display sm37
      jobsel_param_in = jobsel_param_out.
      TRANSLATE jobsel_param_in USING '%*'.

      CALL FUNCTION 'BP_JOB_SELECT_SM37B'
        EXPORTING
          jobselect_dialog    = btc_no
          jobsel_param_in     = jobsel_param_in
        IMPORTING
          jobsel_param_out    = jobsel_param_out
        TABLES
          jobselect_joblist   = sel_joblist
          jobselect_joblist_b = sel_joblist_b
        EXCEPTIONS
          OTHERS              = 99.

    ELSE.
*     display sm37c
      IF disp_own_job_advanced_flag = 'X'.
        DATA temp_btcselectp LIKE btcselectp.
        MOVE btcselectp TO temp_btcselectp.
        CLEAR btcselectp.
        btcselectp-jobname = '*'.
        btcselectp-username = sy-uname.
      ENDIF.

      CALL FUNCTION 'BP_JOB_SELECT_SM37C'
        EXPORTING
          jobselect_dialog    = btc_no
          jobsel_param_in_p   = btcselectp
        TABLES
          jobselect_joblist   = sel_joblist
          jobselect_joblist_b = sel_joblist_b
        EXCEPTIONS
          OTHERS              = 99.

      IF disp_own_job_advanced_flag = 'X'.
        CLEAR btcselectp.
        MOVE temp_btcselectp TO btcselectp.
      ENDIF.

    ENDIF.

    IF sy-subrc = 99.
      PERFORM write_job_mainten_syslog USING unknown_selection_error
                                                            space.
      EXIT.
    ENDIF.

    PERFORM check_distinct_after_refresh.
  ENDIF.

  REFRESH output_joblist.
  PERFORM outputlist_build TABLES sel_joblist
                                  gt_exc.

  DATA: p_grid LIKE reuse_alv_type.
  PERFORM get_current_display_function USING p_grid.

  DESCRIBE TABLE output_joblist LINES new_size.

  IF p_grid = 'L'.

    IF gs_layout IS INITIAL.   " note 1084226
      CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
        IMPORTING
          es_layout     = gs_layout
        EXCEPTIONS
          no_infos      = 1
          program_error = 2
          OTHERS        = 3.
      CLEAR gs_layout-colwidth_optimize.
    ENDIF.

* read the scroll info

    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
      IMPORTING
        es_list_scroll = jov_list_scroll_info
      EXCEPTIONS
        OTHERS         = 3.

    IF ( sy-subrc = 0 AND jov_list_scroll_info-staro > new_size ).
      jov_list_scroll_info-staro = 1.
      jov_list_scroll_info-cursor_line = 1.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_SET'
      EXPORTING
        is_layout      = gs_layout    " note 1084226
        it_fieldcat    = prev_fieldcat[]
        it_sort        = prev_sort[]
        it_filter      = prev_filter[]
        is_list_scroll = jov_list_scroll_info.

  ELSE.
    IF gs_layout IS INITIAL.  " note 1084226
      CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
        IMPORTING
          es_layout     = gs_layout
        EXCEPTIONS
          no_infos      = 1
          program_error = 2
          OTHERS        = 3.
      CLEAR gs_layout-colwidth_optimize.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_SET'
      EXPORTING
        is_layout      = gs_layout    " note 1084226
        it_fieldcat    = prev_fieldcat[]
        it_sort        = prev_sort[]
        it_filter      = prev_filter[]
        is_grid_scroll = jov_grid_scroll_info.
  ENDIF.

ENDFORM.                    " refresh_alv_list

************************************************************************
* callback form routine JOB_OVERVIEW_TOP_OF_PAGE_NEW
************************************************************************

FORM job_overview_top_of_page_new USING p_do TYPE REF TO cl_dd_document.

  DATA: event_flag(1),
        prog_flag(1).

  DATA text TYPE sdydo_text_element.
  DATA: header LIKE btch2170.

  DATA: i_accessibility TYPE abap_bool.


  CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
    IMPORTING
      accessibility     = i_accessibility
    EXCEPTIONS
      its_not_available = 1
      OTHERS            = 2.

* wg. accessibility von SMX
  IF sy-tcode = 'SMX' OR sy-tcode = 'SMXX' OR
     i_accessibility = abap_true.
    EXIT.
  ENDIF.

  IF display_advanced_flag = 'X'.  " we are in sm37c
    MOVE-CORRESPONDING btcselectp TO header.
  ELSE.                            " we are in sm37
    MOVE-CORRESPONDING btch2170 TO header.
  ENDIF.

  IF header-eventid = ' '.
    event_flag = space.
  ELSE.
    event_flag = 'X'.
  ENDIF.

  IF header-abapname = space.
    prog_flag  = space.
  ELSE.
    prog_flag  = 'X'.
  ENDIF.

  CALL METHOD p_do->new_line.

* 1. line
  text = text-619.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  WRITE header-from_date TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->add_gap
    EXPORTING
      width = 3.
  text = text-620.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  WRITE header-from_time TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

* CALL METHOD p_do->new_line.

* still 1. line  (in old header: 2. line)
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.
  text = text-621.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  WRITE header-to_date TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->add_gap
    EXPORTING
      width = 3.
  text = text-620.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  WRITE header-to_time TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->new_line.

* 3 line
  text = text-622.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  text = header-jobname.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
* CALL METHOD p_do->new_line.

*still 3rd line (in old header: 4. line)
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.
  text = text-623.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 2.

  text = header-username.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->new_line.

* 5. line
  WRITE header-prelim TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-079.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.


  WRITE header-schedul TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-080.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.


  WRITE header-ready TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-078.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.


  WRITE header-running TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-077.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.


  WRITE header-finished TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-082.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.


  WRITE header-aborted TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-081.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.

  CALL METHOD p_do->new_line.

* 6. line

  WRITE event_flag TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-626.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 6.

  text = text-627.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = header-eventid.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->new_line.

* 7 line
  WRITE prog_flag TO text.
  CALL METHOD p_do->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = text-629.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.
  CALL METHOD p_do->add_gap
    EXPORTING
      width = 5.

  text = text-630.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.

  CALL METHOD p_do->add_gap
    EXPORTING
      width = 1.
  text = header-abapname.
  CALL METHOD p_do->add_text
    EXPORTING
      text = text.


ENDFORM.                    "job_overview_top_of_page_new
*&---------------------------------------------------------------------*
*&      Form  JLOG_VARIANT_BUILD
*&---------------------------------------------------------------------*
*      maintain variant for joblog
*---------------------------------------------------------------------*
*      -->GS_LOG_VARItext
*      -->GS_LAYOUT  text
*      -->GT_FIELDCATtext
*      -->LOCAL_REPIDtext
*---------------------------------------------------------------------*
FORM jlog_variant_build
USING
      gs_log_variant LIKE disvariant
      local_repid    LIKE sy-repid.

  CONSTANTS:
  jlog_var_name LIKE disvariant-variant VALUE '/DEF_JLOG',
  jlog_var_comment LIKE disvariant-TEXT VALUE
  'default variant for joblog'.
  DATA:  jlog_sort   TYPE lvc_t_sort,
        jlog_filter TYPE lvc_t_filt,
        jlog_filcat TYPE lvc_t_fcat,
        jlog_layout TYPE lvc_s_layo.

  DATA: lt_ltdx TYPE TABLE OF ltdxkey.
  DATA: ls_ltdx TYPE ltdxkey.
  DATA: variant_deleted TYPE boolean.

*variant
  gs_log_variant-variant = jlog_var_name.
  gs_log_variant-TEXT    = jlog_var_comment.
  gs_log_variant-REPORT  = sy-repid.
*  gs_log_variant-handle = 'JLOG'.
  CLEAR gs_log_variant-handle.

*check existence of variant without handle
  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
  CHANGING
    cs_variant = gs_log_variant
  EXCEPTIONS
    not_found  = 1
    OTHERS     = 2.

  CASE sy-subrc.
  WHEN 0.
    MOVE-CORRESPONDING gs_log_variant TO ls_ltdx.
    APPEND ls_ltdx TO lt_ltdx.
    CALL FUNCTION 'LT_VARIANTS_DELETE'
* EXPORTING
*   I_TOOL              = 'LT'
*   I_TEXT_DELETE       = 'X'
    TABLES
      t_varkey            = lt_ltdx
    EXCEPTIONS
      NOT_FOUND           = 1
      OTHERS              = 2
      .
    IF sy-subrc = 0.
      variant_deleted = abap_true.
    ENDIF.
  WHEN 1.
    variant_deleted = abap_false.
  ENDCASE.

* check existence of variant with handle
  gs_log_variant-handle = 'JLOG'.

  IF variant_deleted <> abap_true.
    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    CHANGING
      cs_variant = gs_log_variant
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  ELSE.
    sy-subrc = 1.
  ENDIF.

  CASE sy-subrc.
  WHEN 1.
*build fildcat for variant
    DATA: ls_fieldcat TYPE alv_s_fcat.
    DATA: pos TYPE I VALUE 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-651.
    ls_fieldcat-fieldname = 'ENTERDATE'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-652.
    ls_fieldcat-fieldname = 'ENTERTIME'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-653.
    ls_fieldcat-fieldname = 'TEXT'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-654.
    ls_fieldcat-fieldname = 'MSGID'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-655.
    ls_fieldcat-fieldname = 'MSGNO'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

    CLEAR ls_fieldcat.
    ls_fieldcat-col_pos   = pos.
    ls_fieldcat-seltext = TEXT-656.
    ls_fieldcat-fieldname = 'MSGTYPE'.
    APPEND ls_fieldcat TO jlog_filcat.
    pos = pos + 1.

*build layout
    jlog_layout-zebra = 'X'.
    jlog_layout-cwidth_opt = 'X'.
    jlog_layout-detailtitl = TEXT-650.
*save
    CALL FUNCTION 'LVC_VARIANT_SAVE'
    EXPORTING
      it_fieldcat     = jlog_filcat
      it_sort         = jlog_sort
      it_filter       = jlog_filter
      is_layout       = jlog_layout
      i_dialog        = space
      i_overwrite     = 'X'
    CHANGING
      cs_variant      = gs_log_variant
    EXCEPTIONS
      wrong_input     = 1
      fc_not_complete = 2
      foreign_lock    = 3
      variant_exists  = 4
      name_reserved   = 5
      program_error   = 6
      OTHERS          = 7.
    IF sy-subrc <> 0.
      MESSAGE s358(rz) WITH 'Starte ASAP'(347) sy-subrc ''.
    ENDIF.
  WHEN 2.
    MESSAGE s358(rz) WITH
    'VARIANT EXISTENCE CHECK error' '' ''.                "#EC NOTEXT
  ENDCASE.

ENDFORM.                    " JLOG_VARIANT_BUILD

***** c5034979 XBP20 *****
*&---------------------------------------------------------------------*
*&      Form  check_authority_to_release
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBNAME  text
*      -->P_JOBCOUNT  text
*----------------------------------------------------------------------*
FORM check_authority_to_release USING l_jobname  LIKE tbtco-jobname
                                      l_jobcount LIKE tbtco-jobcount.

* on attempt to release an intercepted job:
* check if interception is turned on.
* authority check to clearify if the user has authority to do this.
* In case releasing is not allowed, the subroutine exits via
* an error message.
  DATA: interception.
  DATA: wa_tbtco3 LIKE tbtco.
  DATA: wa_tbtccntxt LIKE tbtccntxt.

  CALL FUNCTION 'BP_NEW_FUNC_CHECK'
    EXPORTING
      interception_action = 'r'
    IMPORTING
      interception        = interception
    EXCEPTIONS
      wrong_action        = 1
      no_authority        = 2
      OTHERS              = 3.

  IF sy-subrc = 0 AND NOT interception IS INITIAL.
    SELECT SINGLE * FROM tbtco INTO wa_tbtco3
      WHERE jobname  = l_jobname AND
            jobcount = l_jobcount AND
            status   = btc_scheduled.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM tbtccntxt INTO wa_tbtccntxt
        WHERE jobname  = l_jobname AND
              jobcount = l_jobcount AND
              ctxttype = 'INTERCEPTED'.
      IF sy-subrc = 0.
* check authority for releasing intercepted jobs
        AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
                 ID 'ACTVT' FIELD '01'.
        IF sy-subrc <> 0.
          MESSAGE e646.
*   Sie haben keine Freigabeberechtigung für intercepted Jobs
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_authority_to_release

*---------------------------------------------------------------------*
*       FORM change_jobname_wildcard                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_JOBNAME                                                     *
*  -->  P_NEW_JOBNAME(66)                                             *
*---------------------------------------------------------------------*
FORM change_jobname_wildcard
  USING    p_jobname LIKE tbtco-jobname
  CHANGING p_new_jobname.

  DATA: len TYPE i,
        index TYPE i,
        new_index TYPE i.
  DATA: sngl_char.
  DATA: escape_char VALUE '#'.
  len = strlen( p_jobname ).

  index = 0.
  new_index = 0.
  CLEAR p_new_jobname.
  DO len TIMES.
    sngl_char = p_jobname+index.
    IF sngl_char = '_'.
      p_new_jobname+new_index(1) = escape_char.
      new_index = new_index + 1.
      p_new_jobname+new_index(1) = sngl_char.
    ELSEIF sngl_char = escape_char.
      p_new_jobname+new_index(1) = escape_char.
      new_index = new_index + 1.
      p_new_jobname+new_index(1) = escape_char.
    ELSE.
      p_new_jobname+new_index(1) = sngl_char.
    ENDIF.
    index = index + 1.
    new_index = new_index + 1.
  ENDDO.

ENDFORM.                    "change_jobname_wildcard

*&---------------------------------------------------------------------*
*&      Form  get_current_display_function
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* p_rc = G       GRID
* p_rc = L       LIST
*----------------------------------------------------------------------*
FORM get_current_display_function
    USING p_rc TYPE c.

  DATA: wa_list_switcher LIKE btcoptions.
  DATA: i_accessibility TYPE abap_bool.

  IF tvariant = 'SM37DISP'.
    p_rc = 'G'.
    RETURN.
  ENDIF.

  IF sy-binpt IS NOT INITIAL.
    p_rc = 'L'.
    EXIT.
  ENDIF.

  IF reuse_alv_type = 'L' OR
     reuse_alv_type = 'G'.
    p_rc = reuse_alv_type.
    EXIT.
  ENDIF.

  CALL FUNCTION 'FUNCTION_EXISTS'
    EXPORTING
      funcname           = 'GET_ACCESSIBILITY_MODE'
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.
  IF sy-subrc = 0.
    CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
      IMPORTING
        accessibility     = i_accessibility
      EXCEPTIONS
        its_not_available = 1
        OTHERS            = 2.
    IF sy-subrc = 0.
      IF i_accessibility = abap_true.
        reuse_alv_type = 'G'.
        p_rc = reuse_alv_type.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM btcoptions INTO wa_list_switcher
    WHERE btcoption = 'LIST_GRID_SWITCHER' AND
          value1    = sy-uname.
  IF sy-subrc = 0.
    IF wa_list_switcher-value2 = 'LIST'.
      reuse_alv_type = 'L'.
    ELSEIF wa_list_switcher-value2 = 'GRID'.
      reuse_alv_type = 'G'.
    ELSE.
      SELECT SINGLE * FROM btcoptions INTO wa_list_switcher
        WHERE btcoption = 'LIST_GRID_SWITCHER' AND
              value1 = 'LIST_GRID_SWITCHER'.
      IF sy-subrc = 0.
        reuse_alv_type = 'G'.
      ELSE.
        reuse_alv_type = 'L'.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT SINGLE * FROM btcoptions INTO wa_list_switcher
      WHERE btcoption = 'LIST_GRID_SWITCHER' AND
            value1 = 'LIST_GRID_SWITCHER'.
    IF sy-subrc = 0.
      reuse_alv_type = 'G'.
    ELSE.
      reuse_alv_type = 'L'.
    ENDIF.
  ENDIF.

  p_rc = reuse_alv_type.

ENDFORM.                    "get_current_display_function

*&---------------------------------------------------------------------*
*&      Form  init_print_parameters
*&---------------------------------------------------------------------*
* This function modul initializes empty fields of structures bapipripar*
* and bapiarcpar correctly for GET_PRINT_PARAMETERS                    *
*----------------------------------------------------------------------*

FORM init_print_parameters  USING    pri_params STRUCTURE bapipripar
                                     arc_params STRUCTURE bapiarcpar
                                     sap_user_name
                                     report_name.

  DATA: num_comp(3) TYPE n.

  IF pri_params-primm IS INITIAL OR
     pri_params-primm = space.
    pri_params-primm = c_char_unknown.
* caller must pass '$' if 'do not print immediately' shall be set
  ELSEIF pri_params-primm = c_char_space.
    CLEAR pri_params-primm.
  ENDIF.

  IF pri_params-prrel IS INITIAL OR
     pri_params-prrel = space.
    pri_params-prrel = c_char_unknown.
* caller must pass '$' if 'do not release after print' shall be set
  ELSEIF pri_params-prrel = c_char_space.
    CLEAR pri_params-prrel.
  ENDIF.

  IF pri_params-prnew IS INITIAL OR
     pri_params-prnew = space.
    pri_params-prnew = c_char_unknown.
* caller must pass '$' if 'append spool' shall be set
  ELSEIF pri_params-prnew = c_char_space.
    CLEAR pri_params-prnew.
  ENDIF.

  IF pri_params-prsap IS INITIAL OR
     pri_params-prsap = space.
    pri_params-prsap = c_char_unknown.
* caller must pass '$' if 'no SAP cover page' shall be set
  ELSEIF pri_params-prsap = c_char_space.
    CLEAR pri_params-prsap.
  ENDIF.

  IF pri_params-prunx IS INITIAL OR
     pri_params-prunx = space.
    pri_params-prunx = c_char_unknown.
* caller must pass '$' if 'no host spool cover page' shall be set
  ELSEIF pri_params-prunx = c_char_space.
    CLEAR pri_params-prunx.
  ENDIF.

* catch exception CONVT_NO_NUMBER
  CATCH SYSTEM-EXCEPTIONS conversion_errors  = 4.
    num_comp = pri_params-prcop + 0.
  ENDCATCH.
  IF sy-subrc <> 0 OR pri_params-prcop IS INITIAL OR
    pri_params-prcop = space.
    pri_params-prcop = '1'.                                 " 1 Kopie
  ENDIF.

  IF pri_params-armod IS INITIAL OR
     pri_params-armod = space.
    pri_params-armod = '1'. " Drucken
  ENDIF.

  IF pri_params-prrec IS INITIAL OR
     pri_params-prrec = space.
    pri_params-prrec = sap_user_name.
* caller must pass '$' if SPACE shall be set
  ELSEIF pri_params-prrec = c_char_space.
    CLEAR pri_params-prrec.
  ENDIF.

  IF pri_params-linct IS INITIAL OR
     pri_params-linct = space.
    pri_params-linct = c_int_unknown.
  ENDIF.

  IF pri_params-linsz IS INITIAL OR
     pri_params-linsz = space.
    pri_params-linsz = c_int_unknown.
  ENDIF.

  IF pri_params-pdest IS INITIAL OR
     pri_params-pdest = space.
    pri_params-pdest = c_char_unknown.
  ENDIF.

  IF pri_params-plist IS INITIAL OR
     pri_params-plist = space.
    PERFORM build_default_plist_name
          USING report_name pri_params-plist sap_user_name.
  ENDIF.

  IF pri_params-prtxt IS INITIAL OR
     pri_params-prtxt = space.
    pri_params-prtxt = c_char_unknown.
  ENDIF.

* catch exception CONVT_NO_NUMBER
  CATCH SYSTEM-EXCEPTIONS conversion_errors  = 4.
    num_comp = pri_params-pexpi + 1.
  ENDCATCH.
  IF sy-subrc <> 0 OR pri_params-pexpi IS INITIAL
  OR pri_params-pexpi = space.
    pri_params-pexpi = c_num1_unknown.
  ENDIF.

  IF pri_params-paart IS INITIAL OR
     pri_params-paart = space.
    pri_params-paart = c_char_unknown.
  ENDIF.

  IF pri_params-prbig IS INITIAL OR
     pri_params-prbig = space.
    pri_params-prbig = c_char_unknown.
  ENDIF.

  IF pri_params-prabt IS INITIAL OR
     pri_params-prabt = space.
    pri_params-prabt = c_char_unknown.
* caller must pass '$' if SPACE shall be set
  ELSEIF pri_params-prabt = c_char_space.
    CLEAR pri_params-prabt.
  ENDIF.

  IF pri_params-prber IS INITIAL OR
     pri_params-prber = space.
    pri_params-prber = c_char_unknown.
  ENDIF.

  IF pri_params-prdsn IS INITIAL OR
     pri_params-prdsn = space.
    pri_params-prdsn = c_char_unknown.
  ENDIF.

*  IF pri_params-ptype IS INITIAL OR
*     pri_params-ptype = space.
  pri_params-ptype = c_char_unknown.
*  ENDIF.

  IF pri_params-footl IS INITIAL OR
     pri_params-footl = space.
    pri_params-footl = c_char_unknown.
  ENDIF.

* catch exception CONVT_NO_NUMBER
  CATCH SYSTEM-EXCEPTIONS conversion_errors  = 4.
    num_comp = pri_params-priot + 0.
  ENDCATCH.
  IF sy-subrc <> 0 OR pri_params-priot IS INITIAL OR
    pri_params-priot = space.
    pri_params-priot = c_num1_unknown.
  ENDIF.

  IF arc_params-archiv_id IS INITIAL OR
     arc_params-archiv_id = space.
    arc_params-archiv_id = c_char_unknown.
  ENDIF.

  IF arc_params-info IS INITIAL OR
     arc_params-info = space.
    arc_params-info = c_char_unknown.
  ENDIF.

  IF arc_params-arctext IS INITIAL OR
     arc_params-arctext = space.
    arc_params-arctext = c_char_unknown.
  ENDIF.

  IF arc_params-ar_object IS INITIAL OR
     arc_params-ar_object = space.
    arc_params-ar_object = c_char_unknown.
  ENDIF.

  IF arc_params-report IS INITIAL OR
     arc_params-report = space.
    arc_params-report = c_char_unknown.
  ENDIF.

  IF arc_params-sap_object IS INITIAL OR
     arc_params-sap_object = space.
    arc_params-sap_object = c_char_unknown.
  ENDIF.

ENDFORM.                    " init_print_parameters

*&---------------------------------------------------------------------*
*&      Form  release_jobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_JOBLIST  text
*      -->P_MARKED_ITAB  text
*----------------------------------------------------------------------*
FORM release_jobs TABLES p_sel_joblist STRUCTURE sel_joblist
                         p_marked_itab STRUCTURE marked_itab.

  DATA: stdt_modify_flag LIKE btch0000-int4.

  DATA: BEGIN OF new_stdt.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF new_stdt.

  DATA error_flag TYPE c.
  DATA error_job(50) TYPE c.

  CLEAR error_flag.
  CLEAR error_job.

*get start values for all selected jobs
  CLEAR new_stdt.
  CALL FUNCTION 'BP_START_DATE_EDITOR'
    EXPORTING
      stdt_dialog      = btc_yes
      stdt_opcode      = btc_edit_startdate
      stdt_input       = new_stdt
    IMPORTING
      stdt_output      = new_stdt
      stdt_modify_type = stdt_modify_flag
    EXCEPTIONS
      OTHERS           = 99.

  IF sy-subrc NE 0 OR
     stdt_modify_flag EQ btc_stdt_not_modified.
    EXIT.
  ENDIF.

  SORT p_sel_joblist BY jobname jobcount.
  LOOP AT p_marked_itab.
    READ TABLE p_sel_joblist WITH KEY jobname = p_marked_itab-jobname
                                      jobcount = p_marked_itab-jobcount
                                      BINARY SEARCH.
* read and modify all selected jobs
    SELECT SINGLE * FROM tbtco INTO p_sel_joblist WHERE
        jobname = p_sel_joblist-jobname AND
        jobcount = p_sel_joblist-jobcount.

    IF sy-subrc <> 0.
      error_flag = 'X'.
      CONCATENATE '(' p_sel_joblist-jobcount ')' INTO error_job.
      CONCATENATE p_sel_joblist-jobname error_job INTO error_job
SEPARATED BY space.
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD jobentry_doesnt_exist
            ID 'DATA' FIELD error_job.
      CONTINUE.
    ENDIF.

* only run with status 'scheduled'
    IF p_sel_joblist-status = btc_scheduled.

      CALL FUNCTION 'BP_JOB_MODIFY'
        EXPORTING
          jobname                    = p_sel_joblist-jobname
          jobcount                   = p_sel_joblist-jobcount
          dialog                     = btc_no
          opcode                     = btc_release_job
          release_stdt               = new_stdt
          release_targetserver       = p_sel_joblist-execserver
        IMPORTING
          modified_jobhead           = p_sel_joblist
        TABLES
          new_steplist               = global_step_tbl  " Dummy
        EXCEPTIONS
          nothing_to_do              = 1
          cant_start_job_immediately = 2
          OTHERS                     = 99.

      IF sy-subrc <> 0.
* write syslog - modify error
        error_flag = 'X'.
        CONCATENATE '(' p_sel_joblist-jobcount ')' INTO error_job.
        CONCATENATE p_sel_joblist-jobname error_job INTO error_job
SEPARATED BY space.
        CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
              ID 'KEY'  FIELD cant_modify_job
              ID 'DATA' FIELD error_job.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF error_flag = 'X'.
    MESSAGE e268 WITH error_job.
  ENDIF.

ENDFORM.                    " release_jobs

*&---------------------------------------------------------------------*
*&      Form  check_system_debugging
*&---------------------------------------------------------------------*
*  check if user is authorized to debug jobs
*----------------------------------------------------------------------*
FORM check_system_debugging USING rc.

  DATA: debug_authority.

  CALL FUNCTION 'SYSTEM_DEBUG_AUTHORITY_CHECK'
    EXPORTING
      flag_normal    = 'X'
    IMPORTING
      flag_authority = debug_authority.

  IF NOT debug_authority = 'X'.
    rc = 1.
    EXIT.
  ENDIF.

  rc = 0.

ENDFORM.                    " check_system_debugging

********************************************************************
* d023157     29.4.2004
* wegen accessibility

FORM job_select_smx.

  DATA:    seldates   LIKE btcselect.
  DATA:    lines      TYPE i.
  DATA:    run_cnt    TYPE i.
  DATA:    ab_cnt     TYPE i.
  DATA:    wa_run     LIKE tbtcjob.
  DATA:    wa_ab      LIKE tbtcjob.

  seldates-username = sy-uname.
  seldates-running = 'X'.
  seldates-aborted  = 'X'.
  seldates-jobname  = '*'.

  CLEAR   jobs_smx.
  REFRESH jobs_smx.

  CALL FUNCTION 'BP_JOB_SELECT'
    EXPORTING
      jobselect_dialog          = 'N'
      jobsel_param_in           = seldates
* IMPORTING
*   JOBSEL_PARAM_OUT          =
    TABLES
      jobselect_joblist         = jobs_smx
*   JOBNAME_EXT_SEL           =
*   USERNAME_EXT_SEL          =
* CHANGING
*   ERROR_CODE                =
    EXCEPTIONS
      invalid_dialog_type       = 1
      jobname_missing           = 2
      no_jobs_found             = 3
      selection_canceled        = 4
      username_missing          = 5
      OTHERS                    = 6
            .
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

* sicherheitshalber noch checken, ob Tabelle leer
  DESCRIBE TABLE jobs_smx LINES lines.
  IF lines = 0.

    EXIT.
  ENDIF.

ENDFORM.                    "job_select_smx

*************************************************************

FORM prepare_output_smx.

  DATA: wa_output_smx LIKE output_smx.

  LOOP AT jobs_smx.

    CLEAR wa_output_smx.

    MOVE-CORRESPONDING jobs_smx TO wa_output_smx.

    CASE jobs_smx-status.
      WHEN 'A'.
        wa_output_smx-statusname = text-227.
*        output_list_smx-slide_type_status = 'XXXX<'.
*        APPEND red_row TO output_list_smx-colorize_status.
      WHEN 'F'.
        wa_output_smx-statusname = text-082.
*        output_list_smx-slide_type_status = 'XXXXX'.
*        APPEND green_row TO output_list_smx-colorize_status.
      WHEN 'R'.
        wa_output_smx-statusname = text-077.
*        output_list_smx-slide_type_status = 'XXXX '.
*        APPEND nocolor_row TO output_list_smx-colorize_status.
    ENDCASE.

    APPEND wa_output_smx TO output_list_smx.
  ENDLOOP.

ENDFORM.                    "prepare_output_smx

*********************************************************************

FORM make_field_cat_smx.

  DATA:  waa LIKE lvc_s_fcat.

  waa-fieldname      = 'JOBNAME'.
  waa-ref_table      = 'TBTCJOB'.
  waa-ref_field      = 'JOBNAME'.
  waa-reptext        = text-602.
  waa-outputlen      = 32.
  waa-just           = 'L'.
  waa-key            = 'X'.
  APPEND waa TO field_cat_smx.

  CLEAR waa.
  waa-reptext        = text-604.
  waa-fieldname      = 'STATUSNAME'.
  waa-outputlen      = 9.
  waa-lowercase      = 'X'.
  APPEND waa TO field_cat_smx.

  CLEAR waa.
  waa-fieldname      = 'STRTDATE'.
  waa-ref_table      = 'TBTCJOB'.
  waa-ref_field      = 'STRTDATE'.
  waa-coltext        =  text-295.
  APPEND waa TO field_cat_smx.

  CLEAR waa.
  waa-fieldname      = 'STRTTIME'.
  waa-ref_table      = 'TBTCJOB'.
  waa-ref_field      = 'STRTTIME'.
  waa-coltext        =  text-296.
  APPEND waa TO field_cat_smx.

  CLEAR waa.
  waa-fieldname      = 'ENDDATE'.
  waa-ref_table      = 'TBTCJOB'.
  waa-ref_field      = 'ENDDATE'.
  waa-coltext        =  text-613.
  APPEND waa TO field_cat_smx.

  CLEAR waa.
  waa-fieldname      = 'ENDTIME'.
  waa-ref_table      = 'TBTCJOB'.
  waa-ref_field      = 'ENDTIME'.
  waa-coltext        =  text-614.
  APPEND waa TO field_cat_smx.

ENDFORM.                    "make_field_cat_smx

************************************************************************
* d023157     21.6.2004
*
* Ausschließen bestimmter Funktionscodes für SMX
*

FORM exclude_smx USING fcode_extab TYPE slis_t_extab.

  DATA: BEGIN OF wa_fcode,
              fcode LIKE rsmpe-func,
          END OF wa_fcode.


  wa_fcode-fcode = 'JCHK'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JDRL'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JTRE'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JCPY'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'EDIT'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JDRP'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JMOV'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JGRP'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = '&RNT'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'RELE'.
  APPEND wa_fcode TO fcode_extab.

  IF sy-tcode = 'SMXX'.
    wa_fcode-fcode = 'JABO'.
    APPEND wa_fcode TO fcode_extab.
    wa_fcode-fcode = 'DEL'.
    APPEND wa_fcode TO fcode_extab.
  ENDIF.

* 29.3.2007   d023157
* In SMX bzw. SMXX soll nun auch die Stepliste angezeigt werden.
* Hierfür wurde an die Routine exclude_smx_for_stplst in LBTCHGYY erstellt.
*  wa_fcode-fcode = 'STEP'.
*  APPEND wa_fcode TO fcode_extab.

*  d023157   2.3.2007   SMX shall now be like SMXX
*  IF sy-tcode = 'SMX'.
*    wa_fcode-fcode = 'SPOO'.
*    APPEND wa_fcode TO fcode_extab.
*  ENDIF.

  wa_fcode-fcode = 'JDEF'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'SM51'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'SM50'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'JSTA'.
  APPEND wa_fcode TO fcode_extab.

  wa_fcode-fcode = 'APLG'.
  APPEND wa_fcode TO fcode_extab.

ENDFORM.                    "exclude_smx

**************************************************

*FORM make_field_cat_100.
*
*DATA:  waa LIKE lvc_s_fcat.
*data:  var_len    type i.
*data:  text_len   type i.
*
*DESCRIBE FIELD rsvar-variant LENGTH var_len
*                                     IN CHARACTER MODE.
*
*DESCRIBE FIELD varit-vtext   LENGTH text_len
*                                     IN CHARACTER MODE.
*
*
*CLEAR waa.
*waa-fieldname       = 'VARIANT'.
*waa-ref_table       = 'VARIT'.
*waa-ref_field       = 'VARIANT'.
*waa-outputlen       = var_len.
*waa-just            = 'L'.
*APPEND waa TO field_cat_100.
*
*CLEAR waa.
*waa-fieldname       = 'VTEXT'.
*waa-ref_table       = 'VARIT'.
*waa-ref_field       = 'VTEXT'.
*waa-outputlen       = text_len.
*waa-just            = 'L'.
*APPEND waa TO field_cat_100.
*
*
*endform.
*
**********************************************************
*
*form make_layout_100 using layout TYPE lvc_s_layo.
*
*data: text(60).
*data: text1(25).
*
*write 'Variants for program'(775) to text1.
*concatenate text1 program_name_100 into text separated by ' '.
*
*CLEAR layout.
*
*layout-zebra              = 'X'.
*layout-sel_mode           = 'A'.
*layout-grid_title         = text.
*
*
*endform.
*
*********************************************************
*
*form fill_table_100.
*
*data: wa like varit.
*
** Varianten selektieren
*REFRESH variant_table.
*
*  SELECT * FROM varid CLIENT SPECIFIED
*     WHERE report = program_name_100
*     AND
*     ( mandt = sy-mandt
*       OR
*       mandt = '000' AND ( variant LIKE 'SAP&%' OR variant LIKE
*                           'CUS&%' ) )
*     ORDER BY PRIMARY KEY.
*
*    MOVE varid-variant TO variant_table-variant.
*
*    SELECT SINGLE * FROM varit CLIENT SPECIFIED WHERE
*                             langu      = sy-langu          AND
*                             report     = program_name_100  AND
*                             variant    = varid-variant     AND
*                             mandt      = varid-mandt.
*
*    IF sy-subrc = 0. " <>0 happens if the proper language is not there
*      MOVE varit-vtext TO variant_table-vtext.
*    ELSE.
*      MOVE text-nvd TO variant_table-vtext.
*    ENDIF.
*
*    APPEND variant_table.
*  ENDSELECT.
*
*  DESCRIBE TABLE variant_table LINES var_num.
*
*  IF var_num EQ 0.                     " keine Variante
*    MESSAGE i001(38) WITH text-322.    " gefunden
*    exit.
*  ENDIF.
*
*clear    variant_table_100.
*refresh  variant_table_100.
*
*loop at variant_table.
*   move-corresponding variant_table to wa.
*   append wa to variant_table_100.
*endloop.
*
*
*endform.
*&---------------------------------------------------------------------*
*&      Form  write_trace
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_trace USING  caller
                        trc_v1
                        trc_v2
                        trc_v3
                        trc_v4
                        trc_v5
                        trc_v6
                        trv_v7.

  DATA: error_message(255).
  CONCATENATE trc_v1 trc_v2 trc_v3 trc_v4 trc_v5 trc_v6 trv_v7 INTO
  error_message SEPARATED BY space.
  IF caller IS INITIAL.
    CONCATENATE sy-cprog sy-dynnr INTO caller SEPARATED BY '_'.
  ENDIF.

  CALL 'WriteTrace'
    ID 'CALL' FIELD caller
    ID 'PAR1' FIELD error_message.

ENDFORM.                    " write_trace

*&--------------------------------------------------------------------*
*&      Form  jlog_refresh
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_SELFIELD text
*---------------------------------------------------------------------*
FORM jlog_refresh
    CHANGING p_selfield TYPE slis_selfield.

  DATA:
    p_grid        LIKE reuse_alv_type.

  PERFORM get_current_display_function USING p_grid.
  IF p_grid = 'L'.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
      IMPORTING
        es_list_scroll = jov_list_scroll_info
        et_fieldcat    = prev_fieldcat
        et_sort        = prev_sort[]
        et_filter      = prev_filter[]
      EXCEPTIONS
        OTHERS         = 99.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
      IMPORTING
        es_grid_scroll = jov_grid_scroll_info
        et_fieldcat    = prev_fieldcat[]
        et_sort        = prev_sort[]
        et_filter      = prev_filter[]
      EXCEPTIONS
        OTHERS         = 99.
  ENDIF.

  FREE global_jlg_tbl. CLEAR global_jlg_tbl.
  CALL FUNCTION 'BP_JOBLOG_READ'
    EXPORTING
      jobcount              = g_joblog-jobcount    " note 2095756
      jobname               = g_joblog-jobname     " note 2095756
      joblog                = g_joblog-joblog
      client                = g_joblog-client
    TABLES
      joblogtbl             = global_jlg_tbl
    EXCEPTIONS
      joblog_does_not_exist = 1
      joblog_is_empty       = 2
      job_does_not_exist    = 3
      OTHERS                = 99.
  IF sy-subrc <> 0.
    MESSAGE s167 WITH g_joblog-joblog.
  ENDIF.

  p_selfield-refresh = 'X'.
  p_selfield-tabname = 'GLOBAL_JLG_TBL'.

  IF p_grid = 'L'.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_SET'
      EXPORTING
        it_fieldcat    = prev_fieldcat[]
        it_sort        = prev_sort[]
        it_filter      = prev_filter[]
        is_list_scroll = jov_list_scroll_info.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_SET'
      EXPORTING
        it_fieldcat    = prev_fieldcat[]
        it_sort        = prev_sort[]
        it_filter      = prev_filter[]
        is_grid_scroll = jov_grid_scroll_info.
  ENDIF.

ENDFORM.                    "jlog_refresh
*&---------------------------------------------------------------------*
*&      Form  trace_printparams
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PRIPARAMS  text
*      -->P_ARCPARAMS  text
*----------------------------------------------------------------------*
FORM trace_printparams  USING    step_priparams STRUCTURE pri_params
                                 step_arcparams STRUCTURE arc_params
                                 caller
                                 step_jobname
                                 step_jobcount
                                 step_report.

  DATA: BEGIN OF trace_fields,
  pdest LIKE pri_params-pdest,
  prcop(3),
  primm LIKE pri_params-primm,
  prrel LIKE step_priparams-prrel,
  prnew LIKE step_priparams-prnew,
  pexpi,
  linct(10),
  linsz(10),
  paart LIKE pri_params-paart,
  armod LIKE pri_params-armod,
  prkeyext LIKE pri_params-prkeyext,
  prchk(10),
  END OF trace_fields.

  PERFORM get_trace_level CHANGING trace_level2_on.
  CHECK trace_level2_on = btc_yes.

  MOVE step_priparams-pdest TO trace_fields-pdest.
  MOVE step_priparams-prcop TO trace_fields-prcop.
  MOVE step_priparams-primm TO trace_fields-primm.
  MOVE step_priparams-prrel TO trace_fields-prrel.
  MOVE step_priparams-prnew TO trace_fields-prnew.
  MOVE step_priparams-pexpi TO trace_fields-pexpi.
  MOVE step_priparams-linct TO trace_fields-linct.
  MOVE step_priparams-linsz TO trace_fields-linsz.
  MOVE step_priparams-paart TO trace_fields-paart.
  MOVE step_priparams-armod TO trace_fields-armod.
  MOVE step_priparams-prkeyext TO trace_fields-prkeyext.
  MOVE step_priparams-prchk TO trace_fields-prchk.
  CONDENSE trace_fields-linct.
  CONDENSE trace_fields-linsz.
  CONDENSE trace_fields-prkeyext.
  CONDENSE trace_fields-prchk.

  CALL 'WriteTrace'
  ID 'CALL' FIELD caller
  ID 'PAR1' FIELD step_jobname
  ID 'PAR2' FIELD step_jobcount
  ID 'PAR3' FIELD step_report.
  CALL 'WriteTrace'
    ID 'CALL' FIELD 'print parameters(1)'                   "#EC NOTEXT
    ID 'PAR1' FIELD 'destination:'                          "#EC NOTEXT
    ID 'PAR2' FIELD trace_fields-pdest
    ID 'PAR3' FIELD 'copies:'                               "#EC NOTEXT
    ID 'PAR4' FIELD trace_fields-prcop
    ID 'PAR5' FIELD 'immed.:'                               "#EC NOTEXT
    ID 'PAR6' FIELD trace_fields-primm
    ID 'PAR7' FIELD 'new:'                                  "#EC NOTEXT
    ID 'PAR8' FIELD trace_fields-prnew.
  CALL 'WriteTrace'
    ID 'CALL' FIELD 'print parameters(2)'                   "#EC NOTEXT
    ID 'PAR1' FIELD 'expiration:'                           "#EC NOTEXT
    ID 'PAR2' FIELD trace_fields-pexpi
    ID 'PAR3' FIELD 'rows:'                                 "#EC NOTEXT
    ID 'PAR4' FIELD trace_fields-linsz
    ID 'PAR5' FIELD 'columns:'                              "#EC NOTEXT
    ID 'PAR6' FIELD trace_fields-linct
    ID 'PAR7' FIELD 'format:'                               "#EC NOTEXT
    ID 'PAR8' FIELD trace_fields-paart.
  CALL 'WriteTrace'
    ID 'CALL' FIELD 'print parameters(3)'                   "#EC NOTEXT
    ID 'PAR1' FIELD 'delete:'                               "#EC NOTEXT
     ID 'PAR2' FIELD trace_fields-prrel
    ID 'PAR3' FIELD 'armod:'                                "#EC NOTEXT
     ID 'PAR4' FIELD trace_fields-armod
    ID 'PAR5' FIELD 'prkey:'                                "#EC NOTEXT
     ID 'PAR6' FIELD trace_fields-prkeyext
     ID 'PAR7' FIELD 'checksum:'                            "#EC NOTEXT
     ID 'PAR8' FIELD trace_fields-prchk.

  trace_level2_on = btc_no.

ENDFORM.                    " trace_printparams


*&---------------------------------------------------------------------*
*&      Form  DELETE_TBTCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBHEAD  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM delete_tbtcs USING p_jobhead STRUCTURE tbtcjob dialog
                  CHANGING p_rc.

  DATA: mod_jobinfo(43).
  DATA: del_job TYPE BTCH4470.

  CONCATENATE p_jobhead-jobname p_jobhead-jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  CLEAR tbtcs.
  tbtcs-jobname  = p_jobhead-jobname.
  tbtcs-jobcount = p_jobhead-jobcount.
  DELETE tbtcs.
  IF sy-subrc NE 0.
    SELECT SINGLE jobname jobcount FROM tbtcs INTO (del_job-jn, del_job-jc) WHERE
    jobname = p_jobhead-jobname AND jobcount = p_jobhead-jobcount.
    IF sy-subrc = 0.    " TBTCS entry does exist but cannot be deleted
* store precise error information ********************************
    CONCATENATE tbtcs-jobcount tbtcs-jobname 'DEL_TBTCS'
                                       INTO xbp_error_text.
    .
    CALL METHOD cl_btc_error_controller=>fill_error_info
      EXPORTING
        i_msgid = 'XM'
        i_msgno = msg_cannot_modify_job
        i_text  = xbp_error_text.
    CLEAR xbp_error_text..
******************************************************************

    IF dialog EQ btc_yes.
      MESSAGE s143 WITH 'TBTCS'.
    ENDIF.
    PERFORM write_job_modify_syslog USING tbtcs_delete_db_error
*                                          p_jobhead-jobname.
                                          space
                                          mod_jobinfo.
    p_rc = 1.
    ENDIF.
  ENDIF.

ENDFORM.                    "delete_tbtcs


*&---------------------------------------------------------------------*
*&      Form  delete_btcevtjob
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBHEAD  text
*      -->P_RC       text
*----------------------------------------------------------------------*
FORM delete_btcevtjob USING p_jobhead STRUCTURE tbtcjob DIALOG
CHANGING p_rc.

  DATA: wa_tbtcs TYPE tbtcs.
  DATA: wa_btcevtjob TYPE btcevtjob.
  DATA: mod_jobinfo(43).

  CONCATENATE p_jobhead-jobname p_jobhead-jobcount INTO mod_jobinfo SEPARATED BY ' / '.

  CLEAR btcevtjob.
  btcevtjob-eventid    = p_jobhead-eventid.
  btcevtjob-eventcount = p_jobhead-eventcount.
  DELETE btcevtjob.
  IF sy-subrc NE 0.
    SELECT SINGLE * FROM tbtcs INTO wa_tbtcs WHERE
    jobname = p_jobhead-jobname AND jobcount = p_jobhead-jobcount.
    IF sy-subrc = 0.
      PERFORM delete_tbtcs USING p_jobhead DIALOG CHANGING p_rc.
    ELSE.
      SELECT SINGLE * FROM btcevtjob WHERE eventid = btcevtjob-eventid AND
      eventcount = btcevtjob-eventcount.
      IF sy-subrc = 0.
        p_rc = 1.
        IF DIALOG EQ btc_yes.
          MESSAGE s143 WITH 'BTCEVTJOB'.
        ENDIF.
        PERFORM write_job_modify_syslog USING btcevtjob_delete_db_error
*                                            p_jobhead-jobname.
              space
              mod_jobinfo.
        PERFORM write_job_modify_syslog USING eventid_in_error_info
              mod_jobinfo
              p_jobhead-eventid.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    "delete_btcevtjob
*&---------------------------------------------------------------------*
*&      Form  COMPARE_TIMESTAMPS
*&---------------------------------------------------------------------*
*  In this routine, the spool creation time, which is stored in UTC
*  time, is converted to local server time and compared with the end
*  time of the batch job. If the spool creation time is younger than
*  the job end time, the spool request cannot belong to this particular
*  job.
*----------------------------------------------------------------------*
*      -->P_REQUEST_RQCRETIME  text
*      -->P_WA_TBTCO_ENDDATE  text
*      -->P_WA_TBTCO_ENDTIME  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM compare_timestamps  USING p_request_rqcretime TYPE tsp01-rqcretime
                               p_wa_tbtco_enddate TYPE tbtco-enddate
                               p_wa_tbtco_endtime TYPE tbtco-endtime
                         CHANGING p_rc.

  DATA: spool_timestamp TYPE timestamp.
  DATA: diff TYPE tzntstmpl.
  DATA: tz TYPE timezone.
  DATA: batch_timestamp TYPE timestamp.
  DATA: tolerance TYPE tzntstmpl.

  CLEAR p_rc.
  spool_timestamp = p_request_rqcretime(14).

  CALL FUNCTION 'GET_SYSTEM_TIMEZONE'
    IMPORTING
      timezone            = tz
    EXCEPTIONS
      customizing_missing = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  CONVERT DATE p_wa_tbtco_enddate TIME p_wa_tbtco_endtime INTO TIME
  STAMP batch_timestamp TIME ZONE tz.

  tolerance = 24 * 3600.

  IF sy-subrc = 0.

    CALL METHOD cl_abap_tstmp=>subtract
      EXPORTING
        tstmp1 = spool_timestamp
        tstmp2 = batch_timestamp
      RECEIVING
        r_secs = diff.

    IF diff > tolerance.
      p_rc = 1.
    ENDIF.

  ENDIF.

ENDFORM.                    " COMPARE_TIMESTAMPS

*****************************************************
* d023157   2.3.2009
* create jobs in solution manager instead of SM36
*****************************************************

FORM create_job_in_solman.

* if redirect = Y, the user will be redirected to Solman,
* if redirect ne Y, we have the old behaviour.
  DATA: redirect.

* check criteria here !!!!
  PERFORM check_ssmjob_criteria CHANGING redirect.

  IF redirect = 'Y'.

* begin   23.10.2014   d023157   note 2084690
    data: answer type c.

    clear answer.
    perform ask_user_for_ssmjob using answer '797'.

    if answer ne 'Y'.
       LEAVE.
       SET SCREEN 0.
       LEAVE SCREEN.
    endif.
* end   23.10.2014   d023157   note 2084690

*  MESSAGE i797.

    CALL FUNCTION 'BP_SOLMAN_JOBDEFINITON'
*          EXPORTING
*               IV_JOBNAME             =
*               IV_JOBCOUNT            =
         EXCEPTIONS
             communication_error                 = 1
             solman_destination_missing          = 2
             error_in_connection_to_solman       = 3
             error_starting_browser              = 4
             OTHERS                              = 5
                .
    CASE sy-subrc .

      WHEN 0.
        " alles ok.

      WHEN 1.
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

      WHEN 2.
        MESSAGE w884 DISPLAY LIKE 'E'.

      WHEN 3.
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

      WHEN 4.
        MESSAGE w885 DISPLAY LIKE 'E'.

      WHEN OTHERS.
        MESSAGE w720 WITH 'unknown error' 'BP_SOLMAN_JOBDEFINITON' DISPLAY LIKE 'E'.

    ENDCASE.

    LEAVE.
    SET SCREEN 0.
    LEAVE SCREEN.

  ENDIF.

ENDFORM.                    "create_job_in_solman

*****************************************************
* d023157   10.3.2009
* [create jobs in solution manager instead of SM36]
* Check the calling user against the criteria
*****************************************************

FORM check_ssmjob_criteria CHANGING p_redirect.

  DATA: criteria_profile   TYPE REF TO if_sbti_criteria_profile.
  DATA: criteria_exception TYPE REF TO cx_sbti_exception.

  DATA: match_result       TYPE boolean.  " (X = True )
  DATA: error_text         TYPE string.
  DATA: trace_text(128).
  DATA: trace_level        TYPE btctrclvl.

  DATA: BEGIN OF wa_user,
          mandt LIKE sy-mandt,
          uname LIKE sy-uname,
        END OF wa_user.

  CLEAR wa_user.
  wa_user-mandt = sy-mandt.
  wa_user-uname = sy-uname.

  p_redirect = 'N'.

  TRY.

      CALL METHOD cl_sbti_criteria_manager=>get_instance_active_profile
        EXPORTING
          i_profiletype = if_sbti_criteria_type=>c_ssmjob
        RECEIVING
          r_profile     = criteria_profile.

      CALL METHOD criteria_profile->if_sbti_criteria_checker~criteria_suit
        EXPORTING
          i_data  = wa_user
        RECEIVING
          r_match = match_result.

    CATCH cx_sbti_exception INTO criteria_exception.
      CALL METHOD criteria_exception->get_text
        RECEIVING
          result = error_text.

* In case of an error, write trace entry
*       IF trace_level > btc_trace_level0.
      trace_text = error_text.
      CALL 'WriteTrace'
        ID 'CALL' FIELD 'SSMJOB'
        ID 'PAR1' FIELD '>'
        ID 'PAR2' FIELD trace_text.                         "#EC NOTEXT
*       ENDIF.

  ENDTRY.

  IF match_result = abap_true.
    p_redirect = 'Y'.
  ENDIF.

ENDFORM.                    "check_ssmjob_criteria

*****************************************************
* d023157   16.3.2009
* [change jobs in solution manager instead of SM37]
*
* The job shall be chnaged in Solman (and not in SM37)
* in two cases:
*
* 1. the user matches the criteria
*
* ( OR
*
* 2. the job has been created by Solman )
*
*****************************************************

FORM change_job_in_solman USING p_jobname  TYPE tbtco-jobname
                                p_jobcount TYPE tbtco-jobcount
                                p_redirect TYPE c.

  DATA: subrc(3).
  DATA: cntxttab LIKE tbtcjcntxt OCCURS 0 WITH HEADER LINE.
  DATA: answer.
  DATA: job_ssm_guid TYPE btcctxt.


* first check the user against the criteria,
* unless it has been checked before
  IF p_redirect NE 'Y' AND p_redirect NE 'N'.
    PERFORM check_ssmjob_criteria CHANGING p_redirect.
  ENDIF.

* In any case we have to check, if the job
* has been created by Solman, because we need the GUID,
* if there is one.

  PERFORM job_created_by_solman USING p_jobname
                                         p_jobcount
                                   CHANGING
                                         answer
                                         job_ssm_guid.

  IF answer = 'N'.
    IF p_redirect = 'N'.
      EXIT.
    ENDIF.
  ENDIF.

* 17.6.2009    d023157
* In this case we must not forget to set p_redirect
  IF answer = 'Y'.
    p_redirect = 'Y'.
  ENDIF.

* begin   23.10.2014   d023157   note 2084690
    clear answer.
    perform ask_user_for_ssmjob using answer '797'.

    if answer ne 'Y'.
       exit.
    endif.
* end   23.10.2014   d023157   note 2084690

*  MESSAGE i797.

  CALL FUNCTION 'BP_SOLMAN_JOBDEFINITON'
    EXPORTING
      iv_jobname                    = p_jobname
      iv_jobcount                   = p_jobcount
      iv_job_req_guid               = job_ssm_guid
    EXCEPTIONS
      communication_error           = 1
      solman_destination_missing    = 2
      error_in_connection_to_solman = 3
      error_starting_browser        = 4
      OTHERS                        = 5.

  CASE sy-subrc .

    WHEN 0.
      " alles ok.

    WHEN 1.
      MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

    WHEN 2.
      MESSAGE w884 DISPLAY LIKE 'E'.

    WHEN 3.
      MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

    WHEN 4.
      MESSAGE w885 DISPLAY LIKE 'E'.

    WHEN OTHERS.
      MESSAGE w720 WITH 'unknown error' 'BP_SOLMAN_JOBDEFINITON' DISPLAY LIKE 'E'.

  ENDCASE.

ENDFORM.                    "change_job_in_solman

*****************************************************
* d023157   19.3.2009
*
* This function is needed, if a user marked more than one
* job (in status 'planned') in SM37 and pressed the 'release' button.
* It has to be checked, if among the selected jobs there are jobs,
* which were created by Solution Manager. If yes, the action is
* terminated and a message is displayed.
*
*****************************************************


FORM jobtab_contains_solmanjob TABLES p_marked_itab STRUCTURE output_joblist
                               USING  p_answer TYPE c.

  DATA: guid TYPE btcctxt.

  p_answer = 'N'.

  LOOP AT p_marked_itab .

    PERFORM job_created_by_solman
                            USING p_marked_itab-jobname
                                  p_marked_itab-jobcount
                            CHANGING
                                  p_answer
                                  guid.

    IF p_answer = 'Y'.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "jobtab_contains_solmanjob

*************************************************************
* d023157  19.3.2009
*
* utility function for Solman-scenario.
*************************************************************

FORM job_created_by_solman USING p_jobname  LIKE tbtco-jobname
                                 p_jobcount LIKE tbtco-jobcount
                           CHANGING
                                 p_answer   TYPE c
                                 p_guid     TYPE btcctxt.

  p_answer = 'N'.

  PERFORM get_job_ssm_guid USING p_jobname
                                 p_jobcount
                           CHANGING
                                 p_guid .


  IF NOT p_guid IS INITIAL.
    p_answer = 'Y'.
  ENDIF.

ENDFORM.                    "job_created_by_solman

*************************************************************
* d023157  20.3.2009
*
* utility function for Solman-scenario.
*************************************************************

FORM get_job_ssm_guid USING p_jobname      LIKE tbtco-jobname
                            p_jobcount     LIKE tbtco-jobcount
                      CHANGING
                            p_guid TYPE btcctxt.

  DATA: wa_cntxt LIKE tbtccntxt.

  CLEAR p_guid.

  SELECT SINGLE * FROM tbtccntxt INTO wa_cntxt
                          WHERE jobname  = p_jobname
                            AND jobcount = p_jobcount
                            AND ctxttype = 'SOLMAN_REQUEST_ID'.

  IF sy-dbcnt > 0.
    p_guid = wa_cntxt-ctxtval.
  ENDIF.

ENDFORM.                    "get_job_ssm_guid

**************************************************************
* d023157   4.12.2009
* job deletion via Solman
**************************************************************

FORM delete_job_in_solman USING p_jobname  TYPE tbtco-jobname
                                p_jobcount TYPE tbtco-jobcount
                                p_guid     TYPE btcctxt.


  MESSAGE i798.

  CALL FUNCTION 'BP_SOLMAN_JOBDEFINITON'
    EXPORTING
      iv_jobname                    = p_jobname
      iv_jobcount                   = p_jobcount
      iv_job_req_guid               = p_guid
      iv_job_req_type               = 'DEL'
    EXCEPTIONS
      communication_error           = 1
      solman_destination_missing    = 2
      error_in_connection_to_solman = 3
      error_starting_browser        = 4
      OTHERS                        = 5.

  CASE sy-subrc .

    WHEN 0.
      " alles ok.

    WHEN 1.
      MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

    WHEN 2.
      MESSAGE w884 DISPLAY LIKE 'E'.

    WHEN 3.
      MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

    WHEN 4.
      MESSAGE w885 DISPLAY LIKE 'E'.

    WHEN OTHERS.
      MESSAGE w720 WITH 'unknown error' 'BP_SOLMAN_JOBDEFINITON' DISPLAY LIKE 'E'.

  ENDCASE.

ENDFORM.                    "delete_job_in_solman

***********************************************************
*  d023157    15.12.2009
*  function checks, if this job is the 'last' in the
*  periodicity chain, i.e. if deleting this job
*  stops the periodicity chain.
***********************************************************


FORM job_last_in_chain USING  p_jobname  LIKE tbtco-jobname
                              p_jobcount LIKE tbtco-jobcount
                              p_status   LIKE tbtco-status
                       CHANGING
                              p_answer   TYPE c .


  DATA: wa_cntxt LIKE tbtccntxt.

  CLEAR p_answer.

  IF p_status = btc_released.
    p_answer = 'Y'.
    EXIT.
  ENDIF.

  IF p_status = btc_scheduled.
* if the job is really 'planned', we consider it as last
* one in chain.
* if the job is intercepted, we do not.
    SELECT SINGLE * FROM tbtccntxt INTO wa_cntxt
                      WHERE jobname  = p_jobname
                        AND jobcount = p_jobcount
                        AND ctxttype = 'INTERCEPTED'.

    IF sy-subrc NE 0.
* job is not intercepted
      p_answer = 'Y'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "job_last_in_chain


***************************************************************
*  d023157    21.9.2011    note 1623250

form check_special_modi_privilege using
                                p_user    like tbtcjob-sdluname
                                p_rc      type i.


p_rc = 1.

AUTHORITY-CHECK
    OBJECT 'S_BTCH_JOB'
        ID 'JOBGROUP'  FIELD p_user
        ID 'JOBACTION' FIELD 'MODI'.

if sy-subrc = 0.
   p_rc = 0.
endif.


endform.

***************************************************************

form ask_user_for_ssmjob using p_answer type c
                               msgno    type sy-msgno.

data: text1(90).
data: text2(40).
data: text(135).

message id 'BT' type 'S' number msgno into text1.
message s063(ta) into text2.

concatenate text1 text2 into text separated by ' '.

CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question  = text
      IMPORTING
        answer         = p_answer
      EXCEPTIONS
        OTHERS         = 99.

if p_answer = '1'.
   p_answer = 'Y'.
else.
   p_answer = 'N'.
endif.

endform.
