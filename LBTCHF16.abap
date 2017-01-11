***********************************************************************
*                                                                     *
* Hilfsroutinen des Fubst. BP_JOB_DELETE                              *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM UNDO_SYSLOG_DELAYED                                      *
*---------------------------------------------------------------------*
* Diese Funktion hebt das verzoegerte Schreiben von Syslog-Meldungen  *
* fuer einen Job wieder auf. Sie wird beim Loeschen eines Jobs        *
* benoetigt, denn wenn der Job geloescht ist, dann ist auch das mit   *
* ihm verknuepfte Problem zumindest fuer diesen Job erledigt.         *
*                                                                     *
*---------------------------------------------------------------------*
FORM undo_syslog_delayed
  USING
   jobname jobcount.

  DATA object_id LIKE btcdelay-object.

  CLEAR object_id.
  object_id+0(32) = jobname.
  object_id+32(8) = jobcount.
  SELECT * FROM btcdelay
           WHERE object = object_id.
    DELETE btcdelay.
  ENDSELECT.

ENDFORM. " UNDO_SYSLOG_DELAYED

*---------------------------------------------------------------------*
*       FORM CHECK_FOR_DELETION_OF_IVARIS                             *
*---------------------------------------------------------------------*
* Diese Funktion prüft, ob der zu löschende Job interne Varianten     *
* benutzt und wenn ja, ob diese internen Varianten gelöscht werden    *
* können. Interne Varianten können gelöscht werden, wenn              *
*                                                                     *
* - der Job periodisch ist und es keinen weiteren Job gibt mit        *
*   gleichem Namen im selben Mandanten wie der zu löschende Job der   *
*   der die gleiche(n) interne Variante(n) enthält.                   *
*                                                                     *
* Anmerkung: Enthält ein Job mehrere interne Varianten, so genügt     *
* es die erste daraufhin zu untersuchen, ob sie noch von anderen      *
* Jobs benutzt wird. Wenn ja, dann darf keine interne Variante ge-    *
* gelöscht werden. Wenn nein, dürfen alle internen Varianten des Jobs *
* gelöscht werden.                                                    *
*---------------------------------------------------------------------*
FORM check_for_deletion_of_ivaris USING del_jobhead STRUCTURE tbtco.

  DATA: BEGIN OF del_job_step_tbl OCCURS 0.
          INCLUDE STRUCTURE tbtcp.
  DATA: END OF del_job_step_tbl.

  DATA: BEGIN OF ivari_step_tbl OCCURS 0.
          INCLUDE STRUCTURE tbtcp.
  DATA: END OF ivari_step_tbl.

  DATA: BEGIN OF int_variant_tbl OCCURS 0.
          INCLUDE STRUCTURE rsrepvar.
  DATA: END OF int_variant_tbl.

  DATA: BEGIN OF tmp_jobhead.
          INCLUDE STRUCTURE tbtco.
  DATA: END OF tmp_jobhead.

  DATA: delete_ivaris  LIKE true,
        job_has_ivaris LIKE true,
        program_name   LIKE tbtcp-progname,
        ivari_name     LIKE tbtcp-variant.
*
* Steptabelle des zu löschenden Jobs lesen und feststellen, ob der Job
* mit internen Varianten arbeitet
*
  SELECT * FROM tbtcp INTO TABLE del_job_step_tbl
           WHERE jobname  EQ del_jobhead-jobname
           AND   jobcount EQ del_jobhead-jobcount.

  job_has_ivaris = false.

  LOOP AT del_job_step_tbl WHERE variant(1) EQ '&'.
    program_name   = del_job_step_tbl-progname.
    ivari_name     = del_job_step_tbl-variant.
    job_has_ivaris = true.
    EXIT.
  ENDLOOP.

  IF job_has_ivaris EQ true.
    delete_ivaris = true.
*
*    selektiere alle Einträge aus der Steptabelle die die Kombination
*    PROGRAM_NAME / IVARI_NAME enthalten ( aus Performancegründen
*    wurde ein entsprechender Index auf die Tabelle TBTCP angelegt ).
*    Prüfe dann, ob es außer dem zu löschenden Job noch andere Jobs
*    im gleichen Mandanten gibt, die die interne Variante benutzt.
*    Wenn ja, dann darf / dürfen die interne(n) Variante(n) nicht
*    gelöscht werden.
*
*     SELECT * FROM TBTCP INTO TABLE IVARI_STEP_TBL
*              WHERE PROGNAME EQ PROGRAM_NAME
*              AND   VARIANT  EQ IVARI_NAME.
*
*     LOOP AT IVARI_STEP_TBL WHERE JOBNAME  NE DEL_JOBHEAD-JOBNAME OR
*                                  JOBCOUNT NE DEL_JOBHEAD-JOBCOUNT.
*       SELECT SINGLE * FROM TBTCO INTO TMP_JOBHEAD
*              WHERE JOBNAME  EQ IVARI_STEP_TBL-JOBNAME
*              AND   JOBCOUNT EQ IVARI_STEP_TBL-JOBCOUNT.
*       IF SY-SUBRC EQ 0.
*          IF TMP_JOBHEAD-AUTHCKMAN EQ DEL_JOBHEAD-AUTHCKMAN.
*             DELETE_IVARIS = FALSE. " Interne Variante wird noch von
*             EXIT.                  " anderem Job verwendet
*          ENDIF.
*       ENDIF.
*     ENDLOOP.

* begin of change WO
    DATA: BEGIN OF target,
            jobname LIKE  tbtco-jobname,
            jobcount LIKE tbtco-jobcount,
          END OF target.

    SELECT SINGLE tstep~jobcount tstep~jobname INTO CORRESPONDING FIELDS OF
    target
          FROM tbtcp AS tstep INNER JOIN tbtco AS tjob
            ON tstep~jobcount = tjob~jobcount AND
               tstep~jobname  = tjob~jobname
          WHERE progname  EQ program_name
                AND variant       EQ ivari_name
                AND NOT
                 (
                  tjob~jobname EQ del_jobhead-jobname
                  AND tjob~jobcount EQ del_jobhead-jobcount
                  )
                AND authckman     EQ del_jobhead-authckman.

    IF sy-subrc GT 0.
      delete_ivaris = true.
    ELSE.
      delete_ivaris = false.
    ENDIF.
* end of change WO
*
*    Gegebenenfalls alle internen Varianten, die vom zu löschenden Job
*    verwendet werden, löschen
*
    IF delete_ivaris EQ true.
      LOOP AT del_job_step_tbl WHERE variant(1) EQ '&'.
        IF sy-saprl < sap_release_30a.
*            call function 'DELETE_JOB_SELECTIONS'
*              exporting report  = del_job_step_tbl-progname
*                        variant = del_job_step_tbl-variant
*                        mandant = del_jobhead-authckman
*              exceptions others = 99.
        ELSE.
          CLEAR int_variant_tbl.
          REFRESH int_variant_tbl.
          int_variant_tbl-report  = del_job_step_tbl-progname.
          int_variant_tbl-variant = del_job_step_tbl-variant.
          APPEND int_variant_tbl.

          CALL FUNCTION 'RS_VARIANT_IDELETE'
            EXPORTING
              mandt       = del_jobhead-authckman
            TABLES
              int_variant = int_variant_tbl
            EXCEPTIONS
              OTHERS      = 99.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM. " CHECK_FOR_DELETION_OF_IVARIS
*&---------------------------------------------------------------------*
*&      Form  get_trace_level
*&---------------------------------------------------------------------*
* check if trace level 2 for component 'batch' is set for the current  *
* work process
*----------------------------------------------------------------------*
FORM get_trace_level CHANGING trace_level2_on.

  DATA: wp_index TYPE wpindex.
  TYPE-POOLS thfb.
  DATA: bp_trc TYPE thfb_trace.

  IF trace_level2_on NE btc_yes.
    CALL FUNCTION 'TH_GET_OWN_WP_NO'
      IMPORTING
        wp_index = wp_index.

    CALL FUNCTION 'TH_GET_WP_TRACE'
      EXPORTING
        wp_id = wp_index
      IMPORTING
        trc   = bp_trc.

    CHECK bp_trc-batch IS NOT INITIAL.

    IF bp_trc-level = 2.
      trace_level2_on = btc_yes.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_trace_level

*&---------------------------------------------------------------------*
*&      Form  TRACE_JOB_DELETION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBNAME  text
*      -->P_JOBCOUNT  text
*      -->P_WA_BTCOPTIONS_VALUE2  text
*----------------------------------------------------------------------*
FORM trace_job_deletion  USING    p_jobname
      p_jobcount
      p_status TYPE btcstatus.

  DATA: wa_btcoptions LIKE btcoptions.
  DATA: callstack TYPE abap_callstack.
  DATA: max_level TYPE i.
  DATA: callstack_line TYPE abap_callstack_line.
  DATA: uname TYPE sy-uname.
  DATA: tcode TYPE sy-tcode.
  DATA: t_jobname TYPE tbtcjob-jobname.
  DATA: blockname(20).
  DATA: opt_cnt TYPE i.
  DATA: options TYPE TABLE OF btcoptions.
  DATA: rest TYPE string.
  DATA: exit_flag TYPE boolean.

  CONSTANTS: option TYPE btcoptions-btcoption VALUE 'BP_JOB_DELETE'.

* note 850885
  IF trace_job_deletion IS INITIAL OR trace_job_deletion = btc_yes.
    CALL FUNCTION 'BTC_OPTION_GET'
      EXPORTING
        name         = option
*       IMPVALUE1    =
*       IMPVALUE2    =
      IMPORTING
        count        = opt_cnt
      TABLES
        options      = options
      EXCEPTIONS
        invalid_name = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      trace_job_deletion = btc_no.
      EXIT.
    ENDIF.

    READ TABLE options WITH KEY  btcoption = option value1 = space TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      max_level = 3.
    ELSE.
      max_level = 100.
    ENDIF.

    IF opt_cnt > 0.
      trace_job_deletion = btc_yes.
    ELSE.
      trace_job_deletion = btc_no.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.

  IF trace_job_deletion = btc_yes.
    LOOP AT options INTO wa_btcoptions.
      IF NOT wa_btcoptions-value1 IS INITIAL.
        IF p_jobname CP wa_btcoptions-value1.
          IF wa_btcoptions-value2(1) = abap_true.
            max_level = 0.
          ELSE.
            max_level = 3.
          ENDIF.
          IF wa_btcoptions-value2+1(1) = btc_released.
            IF p_status <> btc_released AND
               p_status <> btc_scheduled AND
               p_status <> btc_put_active.
              exit_flag = abap_true.
            ENDIF.
          ENDIF.
          EXIT.
        ENDIF.
      ELSE.
        IF wa_btcoptions-value2+1(1) = btc_released.
          IF p_status <> btc_released.
            exit_flag = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF exit_flag = abap_true.
      RETURN.
    ENDIF.

    IF max_level > 3.
      RETURN.
    ENDIF.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level = max_level
      IMPORTING
        callstack = callstack.

    IF max_level IS NOT INITIAL.
      max_level = max_level - 1.
      DELETE callstack FROM 1 TO max_level.
    ENDIF.

    uname = sy-uname.
    tcode = sy-tcode.
    t_jobname = p_jobname.
    CONDENSE: uname, tcode, t_jobname.

    LOOP AT callstack INTO callstack_line.

      blockname = callstack_line-blockname.
      CONDENSE: blockname,
                callstack_line-mainprogram,
                callstack_line-include.

      SPLIT callstack_line-mainprogram AT '=' INTO
      callstack_line-mainprogram rest.

      CALL 'WriteTrace'
        ID 'CALL' FIELD 'BP_JOB_DELETE'                     "#EC NOTEXT
        ID 'PAR1' FIELD uname
        ID 'PAR2' FIELD tcode
        ID 'PAR3' FIELD callstack_line-mainprogram
        ID 'PAR4' FIELD callstack_line-include
        ID 'PAR5' FIELD blockname
        ID 'PAR6' FIELD t_jobname
        ID 'PAR7' FIELD p_jobcount.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " TRACE_JOB_DELETION
