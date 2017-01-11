***INCLUDE LBTCHF19 .

***********************************************************************
* Hilfsroutinen des Funktionsbausteins BP_JOB_SELECT                  *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM INIT_DEFAULT_SELECTION                                   *
*---------------------------------------------------------------------*
* Diese Routine legt die Defaultselektionskriterien fest für den      *
* Fall, daß der Rufer des Bausteines keine Seletktionskriterien       *
* angegeben hat. Diese werden später in das Dynpro 1170 eingestreut.  *
*---------------------------------------------------------------------*
FORM init_default_selection
  USING default_selection STRUCTURE btcselect.

  CLEAR default_selection.

  default_selection-jobname   = '*'.
  default_selection-username  = sy-uname.
  default_selection-from_date = sy-datum.
  default_selection-from_time = no_time.
  default_selection-to_date   = sy-datum.
  default_selection-to_time   = no_time.
  default_selection-prelim    = space.
  default_selection-schedul   = 'X'.
  default_selection-ready     = 'X'.
  default_selection-running   = 'X'.
  default_selection-finished  = 'X'.
  default_selection-aborted   = 'X'.

ENDFORM.                    "init_default_selection

*---------------------------------------------------------------------*
*      FORM RAISE_JOB_SELECT_EXCEPTION                                *
*---------------------------------------------------------------------*
* Ausloesen einer Exception falls der Funktionsbaustein               *
*  BP_JOB_SELECT schwerwiegende Fehler entdeckt.                      *
*---------------------------------------------------------------------*
FORM raise_job_select_exception USING exception data.
*
  CASE exception.
    WHEN jobname_missing.
      RAISE jobname_missing.
    WHEN user_name_missing.
      RAISE username_missing.
    WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb von BP_JOB_SELECT soll ausge-
*      loest werden. Aus Verlegenheit wird JOBNAME_MISSING ausge-
*      loest und die unbekannte Exception im Syslog vermerkt.
*
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_job_select_problem
            ID 'DATA' FIELD exception.
      RAISE jobname_missing.
  ENDCASE.

ENDFORM. " RAISE_JOB_SELECT_EXCEPTION

*&--------------------------------------------------------------------*
*&      Form  concatenate_where
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_WHERE    text
*      -->I_OPERATOR text
*      -->I_PARANTH  text
*---------------------------------------------------------------------*
FORM concatenate_where
  TABLES i_where    STRUCTURE where_line
  USING  i_operator TYPE c
         i_paranth  TYPE c.

  DATA:
    p_new_where      LIKE TABLE OF where_line WITH HEADER LINE,
    p_paranth_set(1) TYPE c,
    p_last_length    TYPE i,
    p_length         TYPE i,
    p_last_tabix     LIKE sy-tabix.

  LOOP AT i_where WHERE LINE <> ''.
    AT FIRST.                          "#EC *
      IF NOT i_paranth IS INITIAL.
        p_paranth_set = 'X'.
        p_new_where-line = '('.
        APPEND p_new_where.
      ENDIF.
    ENDAT.
    p_new_where-line = i_where.
    APPEND p_new_where.
    IF NOT i_operator IS INITIAL.
      p_new_where-line = i_operator.
      APPEND p_new_where.
    ENDIF.
    p_last_tabix = sy-tabix.
  ENDLOOP.

  CLEAR i_where. FREE i_where.
  IF p_last_tabix = 0.
    EXIT.
  ENDIF.

  IF NOT i_operator IS INITIAL.
    DELETE p_new_where INDEX p_last_tabix.
  ENDIF.
  p_last_length = 0.
  IF NOT i_paranth IS INITIAL AND p_paranth_set = 'X'.
    p_new_where-line = ')'.
    APPEND p_new_where.
  ENDIF.

  LOOP AT p_new_where.
    p_length = p_last_length + 1 + STRLEN( p_new_where ).
    IF p_length <= 255.
      IF i_where-line IS INITIAL.
        i_where-line = p_new_where-line.
      ELSE.
        CONCATENATE i_where-line p_new_where-line
          INTO i_where-line SEPARATED BY space.
      ENDIF.
      p_last_length = p_length.
    ELSE.
      IF NOT i_where-line IS INITIAL.
        APPEND i_where.
      ENDIF.
      i_where-line = p_new_where-line.
      p_last_length = STRLEN( p_new_where-line ).
    ENDIF.
  ENDLOOP.

  IF NOT i_where-line IS INITIAL.
    APPEND i_where.
  ENDIF.

ENDFORM.                    "concatenate_where

*&--------------------------------------------------------------------*
*&      Form  convert_field
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_BUFFER   text
*      -->I_NAME     text
*      -->I_MANDATORYtext
*      -->I_ESCAPE   text
*      -->O_WHERE    text
*---------------------------------------------------------------------*
FORM convert_field
  USING i_buffer    TYPE c
        i_name      TYPE c
        i_mandatory TYPE c
        i_escape    TYPE char1
  CHANGING o_where TYPE where_type.

  DATA:
    p_buffer1     TYPE where_type,
    p_buffer2     LIKE p_buffer1,
    p_rc(1)       TYPE c.
  DATA: len TYPE i,
        index TYPE i,
        new_index TYPE i,
        sngl_char.

  p_buffer1 = i_buffer.
  CLEAR o_where.
  IF p_buffer1 IS INITIAL OR i_name IS INITIAL.
    EXIT.
  ENDIF.

  TRANSLATE p_buffer1 USING '*%'.
  IF p_buffer1 CO '% '.
    IF NOT i_mandatory IS INITIAL.
      CONCATENATE i_name '<> ''''' INTO o_where
        SEPARATED BY space.
    ENDIF.
    EXIT.
  ENDIF.

  len = STRLEN( p_buffer1 ).
  index = 0.
  new_index = 0.
  CLEAR p_buffer2.
  DO len TIMES.
    sngl_char = p_buffer1+index.
    IF sngl_char = ''''.
      p_buffer2+new_index(1) = ''''.
      new_index = new_index + 1.
      p_buffer2+new_index(1) = sngl_char.
    ELSEIF sngl_char = ''''.
      p_buffer2+new_index(1) = ''''.
      new_index = new_index + 1.
      p_buffer2+new_index(1) = ''''.
    ELSE.
      p_buffer2+new_index(1) = sngl_char.
    ENDIF.
    index = index + 1.
    new_index = new_index + 1.
  ENDDO.

  p_buffer1 = p_buffer2.
  CLEAR p_buffer2.

  IF NOT i_escape IS INITIAL.
    PERFORM convert_escape
      USING p_buffer1
      CHANGING p_buffer2 p_rc.
  ELSE.
    p_buffer2 = p_buffer1.
  ENDIF.

  CONCATENATE '''' p_buffer2 '''' INTO p_buffer2.
  IF p_buffer2 CA '%' OR NOT i_escape IS INITIAL.
    CONCATENATE i_name 'LIKE' p_buffer2 INTO o_where
      SEPARATED BY space.
  ELSE.
    CONCATENATE i_name '=' p_buffer2 INTO o_where
      SEPARATED BY space.
  ENDIF.

  IF NOT i_escape IS INITIAL AND p_rc = 'X'.
    CONCATENATE o_where 'ESCAPE ''#''' INTO o_where
      SEPARATED BY space.
  ENDIF.

ENDFORM.                    "convert_field

*&--------------------------------------------------------------------*
*&      Form  convert_escape
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_TEXT     text
*      -->O_TEXT     text
*      -->O_RC       text
*---------------------------------------------------------------------*
FORM convert_escape
  USING    i_text TYPE c
  CHANGING o_text TYPE c
           o_rc   TYPE c.

* This routine is a type independent copy of change_jobname_wildcard

  DATA: len TYPE i,
        index TYPE i,
        new_index TYPE i.
  DATA: sngl_char.
  DATA: escape_char VALUE '#'.

  o_rc = 'X'.
  IF NOT i_text CA '_'.
    o_text = i_text.
    CLEAR o_rc.
    EXIT.
  ENDIF.

  len = STRLEN( i_text ).

  index = 0.
  new_index = 0.
  CLEAR o_text.
  DO len TIMES.
    sngl_char = i_text+index.
    IF sngl_char = '_'.
      o_text+new_index(1) = escape_char.
      new_index = new_index + 1.
      o_text+new_index(1) = sngl_char.
    ELSEIF sngl_char = escape_char.
      o_text+new_index(1) = escape_char.
      new_index = new_index + 1.
      o_text+new_index(1) = escape_char.
    ELSE.
      o_text+new_index(1) = sngl_char.
    ENDIF.
    index = index + 1.
    new_index = new_index + 1.
  ENDDO.

ENDFORM.                    "convert_escape

*&--------------------------------------------------------------------*
*&      Form  convert_interval
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_NAME_DATEtext
*      -->I_NAME_TIMEtext
*      -->I_DATE1    text
*      -->I_TIME1    text
*      -->I_DATE2    text
*      -->I_TIME2    text
*      -->O_WHERE    text
*---------------------------------------------------------------------*
FORM convert_interval
  USING i_name_date TYPE c
        i_name_time TYPE c
        i_date1 LIKE sy-datum
        i_time1 LIKE sy-uzeit
        i_date2 LIKE sy-datum
        i_time2 LIKE sy-uzeit
  CHANGING o_where TYPE where_type.

  DATA:
    p_buffer   TYPE where_type,
    p_date(10) TYPE c,
    p_time(8)  TYPE c.

  data: l_time1 type sy-uzeit.
  data: l_time2 type sy-uzeit.

  l_time1 = i_time1.
  l_time2 = i_time2.

  CLEAR o_where.
* Fall 1
  IF ( i_date1 IS INITIAL OR i_date1 CO ' ' ) AND
     ( i_date2 IS INITIAL OR i_date2 CO ' ' ).
    EXIT.
  ENDIF.

* Fall 2
  IF ( i_date1 IS INITIAL OR i_date1 CO ' ' ) AND
     NOT ( i_date2 IS INITIAL OR i_date2 CO ' ' ).
    PERFORM print_ls_eq
        USING i_name_date i_date2 i_name_time l_time2
        CHANGING o_where.
    CONCATENATE '(' o_where 'AND' i_name_date '<> ''        '' )'
      INTO o_where SEPARATED BY space.
  ENDIF.

* Fall 3
  IF NOT ( i_date1 IS INITIAL OR i_date1 CO ' ' ) AND
     ( i_date2 IS INITIAL OR i_date2 CO ' ' ).
    PERFORM print_gr_eq
        USING i_name_date i_date1 i_name_time l_time1
        CHANGING o_where.
    CONCATENATE '(' o_where 'AND' i_name_date '<> ''        '' )'
      INTO o_where SEPARATED BY space.
  ENDIF.

* Fall 4
  IF NOT ( i_date1 IS INITIAL OR i_date1 CO ' ' ) AND
     NOT ( i_date2 IS INITIAL OR i_date2 CO ' ' ).
    IF i_date1 = i_date2.
      CONCATENATE '''' i_date1 '''' INTO p_date.
      CONCATENATE i_name_date '=' p_date INTO o_where
        SEPARATED BY space.
      IF l_time1 = l_time2.
        IF NOT l_time1 CO space AND NOT l_time1 IS INITIAL.
          CONCATENATE '''' l_time1 '''' INTO p_time.
          CONCATENATE o_where 'AND' i_name_time '=' p_time INTO o_where
            SEPARATED BY space.
        ENDIF.
      ELSE.
        IF l_time1 CO ' '.
          CLEAR l_time1.
        ENDIF.
        IF l_time2 CO ' '.
          CLEAR l_time2.
        ENDIF.
        IF NOT l_time1 IS INITIAL.
          CONCATENATE '''' l_time1 '''' INTO p_time.
          CONCATENATE o_where 'AND' i_name_time '>=' p_time
            INTO o_where SEPARATED BY space.
        ENDIF.
        IF NOT l_time2 IS INITIAL.
          CONCATENATE '''' l_time2 '''' INTO p_time.
          CONCATENATE o_where 'AND' i_name_time '<=' p_time
            INTO o_where SEPARATED BY space.
        ENDIF.
      ENDIF.
    ELSE.
      PERFORM print_gr_eq
          USING i_name_date i_date1 i_name_time l_time1
          CHANGING p_buffer.
      CONCATENATE '(' p_buffer 'AND' INTO o_where SEPARATED BY space.
      PERFORM print_ls_eq
          USING i_name_date i_date2 i_name_time l_time2
          CHANGING p_buffer.
      CONCATENATE o_where p_buffer ')' INTO o_where SEPARATED BY space.
    ENDIF.
  ENDIF.

ENDFORM.                    "convert_interval

*&--------------------------------------------------------------------*
*&      Form  execute_bp_job_select
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_WHERE    text
*      -->I_JOBS     text
*      -->I_SEL      text
*---------------------------------------------------------------------*
FORM execute_bp_job_select
  TABLES i_where STRUCTURE where_line
         i_jobs  STRUCTURE tbtcjob
  USING  i_sel   TYPE char2
  CHANGING o_rc  TYPE i.

  DATA:
    p_sel          LIKE i_sel,
    p_where        TYPE TABLE OF where_type WITH HEADER LINE,
    p_num_of_lines TYPE i.

  CLEAR o_rc.
  LOOP AT i_where.
    p_where = i_where-line.
    APPEND p_where.
  ENDLOOP.

* Type of selection
  p_sel = i_sel.
  TRANSLATE p_sel TO UPPER CASE.                         "#EC TRANSLANG
  CASE p_sel.
    WHEN 'AL'.
      SELECT * FROM tbtco
        APPENDING CORRESPONDING FIELDS OF TABLE jobselect_joblist
        WHERE (p_where).

    WHEN 'NG'.
      DESCRIBE TABLE p_where LINES p_num_of_lines.
      IF p_num_of_lines <> 0.
        SELECT * FROM tbtco
          APPENDING CORRESPONDING FIELDS OF TABLE jobselect_joblist
          WHERE (p_where) AND
                ( ( NOT ( EXISTS ( SELECT jobcount FROM tbtccntxt
                          WHERE
                            jobname = tbtco~jobname AND
                            jobcount = tbtco~jobcount AND
                            ctxttype = 'CONFIRMED'
                  ) ) ) OR
                  ( EXISTS ( SELECT jobcount FROM tbtccntxt
                        WHERE
                          jobname = tbtco~jobname AND
                          jobcount = tbtco~jobcount AND
                          ctxttype = 'CONFIRMED' AND
                          NOT ctxtval LIKE '%G%'
                ) ) ).
      ELSE.
        SELECT * FROM tbtco
          APPENDING CORRESPONDING FIELDS OF TABLE jobselect_joblist
          WHERE ( ( NOT ( EXISTS ( SELECT jobcount FROM tbtccntxt
                          WHERE
                            jobname = tbtco~jobname AND
                            jobcount = tbtco~jobcount AND
                            ctxttype = 'CONFIRMED'
                  ) ) ) OR
                  ( EXISTS ( SELECT jobcount FROM tbtccntxt
                        WHERE
                          jobname = tbtco~jobname AND
                          jobcount = tbtco~jobcount AND
                          ctxttype = 'CONFIRMED' AND
                          NOT ctxtval LIKE '%G%'
                ) ) ).
      ENDIF.

    WHEN 'NC'.
      DESCRIBE TABLE p_where LINES p_num_of_lines.
      IF p_num_of_lines <> 0.
        SELECT * FROM tbtco
          APPENDING CORRESPONDING FIELDS OF TABLE jobselect_joblist
          WHERE (p_where) AND
                ( NOT ( EXISTS ( SELECT jobcount FROM tbtccntxt
                        WHERE
                          jobname = tbtco~jobname AND
                          jobcount = tbtco~jobcount AND
                          ctxttype = 'CONFIRMED'
                ) ) ).
      ELSE.
        SELECT * FROM tbtco
          APPENDING CORRESPONDING FIELDS OF TABLE jobselect_joblist
          WHERE ( NOT ( EXISTS ( SELECT jobcount FROM tbtccntxt
                        WHERE
                          jobname = tbtco~jobname AND
                          jobcount = tbtco~jobcount AND
                          ctxttype = 'CONFIRMED'
                ) ) ).
      ENDIF.

    WHEN OTHERS.
      o_rc = err_wrong_selection_par.
  ENDCASE.

ENDFORM.                    "execute_bp_job_select

*&--------------------------------------------------------------------*
*&      Form  create_where
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_WHERE    text
*      -->O_WHERE    text
*      -->I_STATUS   text
*      -->I_INTERVAL1text
*      -->I_INTERVAL2text
*      -->I_EVENT    text
*---------------------------------------------------------------------*
FORM create_where
  TABLES i_where1 STRUCTURE where_line
         i_where2 STRUCTURE where_line
         o_where  STRUCTURE where_line
  USING  i_interval1 TYPE where_type
         i_interval2 TYPE where_type
         i_event     TYPE where_type.

* i_where and i_status and ((i_interval1 and i_interval2) or i_event)

  DATA:
    p_num_of_lines TYPE i,
    p_flag(1)      TYPE c,
    p_temp_where   LIKE TABLE OF where_line WITH HEADER LINE.

  CLEAR o_where. FREE o_where.
  APPEND LINES OF i_where1 TO o_where.
* o_where = i_where and i_status
  PERFORM add_where_lines
    TABLES o_where i_where2 USING 'AND' ''.

  p_temp_where-line = i_interval1. APPEND p_temp_where.
* p_temp_where = (i_interval1 and i_interval2)
  PERFORM add_where_line
    TABLES p_temp_where USING i_interval2 'AND' 'X'.
* p_temp_where = ((i_interval1 and i_interval2) or i_event)
  PERFORM add_where_line
    TABLES p_temp_where USING i_event 'OR' 'X'.
* o_where = o_where and p_temp_where
  PERFORM add_where_lines
    TABLES o_where p_temp_where USING 'AND' ''.

ENDFORM.                    "create_where

*&--------------------------------------------------------------------*
*&      Form  add_where_line
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_WHERE    text
*      -->I_NEW_LINE text
*      -->I_OPERATOR text
*      -->I_PARANTH  text
*---------------------------------------------------------------------*
FORM add_where_line
  TABLES i_where    STRUCTURE where_line
  USING  i_new_line TYPE where_type
         i_operator TYPE c
         i_paranth  TYPE c.

  DATA:
    p_new_where    LIKE TABLE OF where_line WITH HEADER LINE,
    p_num_of_lines TYPE i.

  LOOP AT i_where WHERE LINE <> ''.
    p_new_where-line = i_where-line.
    APPEND p_new_where.
  ENDLOOP.
  FREE i_where.
  APPEND LINES OF p_new_where TO i_where.
  FREE p_new_where.

  DESCRIBE TABLE i_where LINES p_num_of_lines.
  IF p_num_of_lines = 0.
    IF NOT i_new_line IS INITIAL.
      i_where = i_new_line. APPEND i_where.
    ENDIF.
  ELSE.
    IF NOT i_new_line IS INITIAL.
      IF NOT i_operator IS INITIAL.
        i_where-line = i_operator. APPEND i_where.
      ENDIF.
      i_where-line = i_new_line. APPEND i_where.
    ENDIF.
  ENDIF.

  IF NOT i_paranth IS INITIAL.
    p_new_where-line = '('. APPEND p_new_where.
    APPEND LINES OF i_where TO p_new_where.
    p_new_where-line = ')'. APPEND p_new_where.
    DESCRIBE TABLE p_new_where LINES p_num_of_lines.
    IF p_num_of_lines <> 2.
      CLEAR i_where. FREE i_where.
      APPEND LINES OF p_new_where TO i_where.
    ENDIF.
  ENDIF.

ENDFORM.                    "add_where_line

*&--------------------------------------------------------------------*
*&      Form  add_where_lines
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->I_WHERE1   text
*      -->I_WHERE2   text
*      -->I_OPERATOR text
*      -->I_PARANTH  text
*---------------------------------------------------------------------*
FORM add_where_lines
  TABLES i_where1   STRUCTURE where_line
         i_where2   STRUCTURE where_line
  USING  i_operator TYPE c
         i_paranth  TYPE c.

  DATA:
    p_new_where    LIKE TABLE OF where_line WITH HEADER LINE,
    p_num_of_lines TYPE i.

  DESCRIBE TABLE i_where1 LINES p_num_of_lines.
  IF p_num_of_lines = 0.
    APPEND LINES OF i_where2 TO i_where1.
  ELSE.
    DESCRIBE TABLE i_where2 LINES p_num_of_lines.
    IF p_num_of_lines <> 0.
      IF NOT i_operator IS INITIAL.
        i_where1-line = i_operator. APPEND i_where1.
      ENDIF.
      APPEND LINES OF i_where2 TO i_where1.
    ENDIF.
  ENDIF.

  IF NOT i_paranth IS INITIAL.
    p_new_where-line = '('. APPEND p_new_where.
    APPEND LINES OF i_where1 TO p_new_where.
    p_new_where-line = ')'. APPEND p_new_where.
    DESCRIBE TABLE p_new_where LINES p_num_of_lines.
    IF p_num_of_lines <> 2.
      CLEAR i_where1. FREE i_where1.
      APPEND LINES OF p_new_where TO i_where1.
    ENDIF.
  ENDIF.

ENDFORM.                    "add_where_lines
