*-------------------------------------------------------------------
***INCLUDE LSPO1F01 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  GET_HELP      B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_help.

  IF userdefined_f1_id NE space.
*   CALL FUNCTION 'POPUP_DISPLAY_TEXT'                      "*029d
    CALL FUNCTION 'POPUP_DISPLAY_TEXT_WITH_PARAMS'          "*029i
         EXPORTING
*             LANGUAGE       = SY-LANGU
              popup_title    = title
*             START_COLUMN   = 10
*             START_ROW      = 3
              text_object    = userdefined_f1_id
              help_modal     = space
*        IMPORTING
*             CANCELLED      =
         TABLES                                             "*029i
              PARAMETERS     = l_parameter                  "*029i
         EXCEPTIONS
              text_not_found = 1
              OTHERS         = 2.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE i130.
      WHEN 2.
        MESSAGE i130.
    ENDCASE.
  ELSE.
    MESSAGE i130.
  ENDIF.

ENDFORM.                               " GET_HELP

*&---------------------------------------------------------------------*
*&      Form  FORMAT_TEXT    B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_FRAGE  text                                           *
*----------------------------------------------------------------------*
FORM format_text TABLES text_tab STRUCTURE text_tab1
                 USING    p_text_frage.
  REFRESH text_tab.
  MOVE p_text_frage TO resttext.
  WHILE resttext NE space.
    CLEAR zeile.
    CALL FUNCTION 'TEXT_SPLIT'
      EXPORTING
        length = textlength
        text   = resttext
      IMPORTING
        line   = zeile
        rest   = resttext
      EXCEPTIONS
        OTHERS = 1.
    CASE sy-subrc.
      WHEN 0.
        MOVE zeile TO text_tab-textzeile.
        APPEND text_tab.
      WHEN OTHERS.
        CLEAR resttext.
    ENDCASE.
  ENDWHILE.
ENDFORM.                               " FORMAT_TEXT

*&---------------------------------------------------------------------*
*&      Form  APPEND_ICON_TO_BUTTON    B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUTTON_1  text                                             *
*      -->P_ICON_BUTTON_1  text                                        *
*----------------------------------------------------------------------*
FORM append_icon_to_button
     USING    p_icon_button_1
              iv_quickinfo_button_1 TYPE text132            "*048i
     CHANGING p_button_1.

  data lv_quickinfo        type string.                     "1150700 >>
  data lv_len              type i.
  data lv_button_with_icon type string.

* check the length of the quickinfo
* strlen( button ) + strlen( icon ) + strlen( quickinfo ) = max. 43
  lv_len       = 43 - 2 - strlen( p_button_1 ).
  lv_quickinfo = iv_quickinfo_button_1(lv_len).             "1150700 <<

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = p_icon_button_1
      text                  = p_button_1
      info                  = lv_quickinfo                  "*048i
      add_stdinf            = ''
    IMPORTING
      RESULT                = lv_button_with_icon
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  CASE sy-subrc.
    WHEN 0.
      p_button_1 = lv_button_with_icon.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                               " APPEND_ICON_TO_BUTTON

*&---------------------------------------------------------------------*
*&      Form  CALCULATE_SCREEN_SIZE      B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calculate_screen_size USING    textlength
                                    start_spalte
                                    start_zeile
                           CHANGING tab_len1
                                    tab_len2
                                    end_spalte
                                    end_zeile
                                    dynpro_nummer.
* Tabellenparameter
  DESCRIBE TABLE text_tab1  LINES tab_len1.
  DESCRIBE TABLE text_tab2  LINES tab_len2.
* Dynprogröße berechnen
  data lv_old_version type boolean. "1667082
  perform display_old_version using lv_old_version.
  IF lv_old_version = 'X'.                                 "1007150 >>
    end_spalte   = start_spalte +  textlength + 15.
    max_dynp_len = 20.
    IF tab_len2 EQ '0'.
      delta_zeile = tab_len1 + 1.
      dynpro_nummer = 500.
    ELSE.
      delta_zeile = tab_len2 + 4.
      dynpro_nummer = 600.
    ENDIF.
    IF delta_zeile GT max_dynp_len.
      delta_zeile = max_dynp_len.
      dynpro_nummer = 700.
    ENDIF.
    end_zeile = start_zeile + delta_zeile.
  ELSE.
    end_spalte   = start_spalte +  textlength + 15.
    IF tab_len2 EQ '0'.
      delta_zeile = tab_len1 + 2.
      IF tab_len1 = 1.
        ADD 1 to delta_zeile.
      ENDIF.
      dynpro_nummer = 500.
    ELSE.
      If tab_len1 > 2.
        delta_zeile = tab_len2 + tab_len1 + 3.
      ELSE.
        delta_zeile = tab_len2 + 5.
      ENDIF.
      dynpro_nummer = 600.
    ENDIF.
    IF delta_zeile GT max_dynp_len.
      delta_zeile = max_dynp_len - 8 + tab_len1.
      IF tab_len1 = 1.
        ADD 1 to delta_zeile.
      ENDIF.
      IF textlength = 48.
        add 12 to end_spalte."1604520
      ELSE.
        add 3 to end_spalte. "1604520
      ENDIF.
      dynpro_nummer = 700.
    ENDIF.
    end_zeile = start_zeile + delta_zeile.
    "Check if mainly double byte characters will be        "1604520 >>
    "displayed. If yes, make the popup wider to avoid
    "additional line breaks in the html control.
    data lv_threshold type i.
    data lv_strlen    type i.
    data lv_numofchar type i.

    lv_strlen    = strlen( fragetext ).
    lv_numofchar = numofchar( fragetext ).

    lv_threshold = ( lv_numofchar / 2 ) + lv_numofchar.
    if lv_threshold < lv_strlen and dynpro_nummer <> 700.
      end_spalte = end_spalte + 10.
    endif.                                                 "1604520 <<
  ENDIF.                                                   "1007150 <<

ENDFORM.                               " CALCULATE_SCREEN_SIZE

*&---------------------------------------------------------------------*
*&      Form  MOVE_DOCU_TO_ITAB     B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXTLINES  text                                            *
*      -->P_TEXT_TAB2  text                                            *
*----------------------------------------------------------------------*
FORM move_docu_to_itab TABLES   p_textlines STRUCTURE textlines
                                p_text_tab  STRUCTURE text_tab2.

  DATA: length            TYPE i,
        text_length       TYPE i,
        offset            TYPE i VALUE '0',
        aufz_sign(2)      TYPE c VALUE 'o ',
        count             TYPE i,      "only used for MB processing
        offset_flag(1)    TYPE c VALUE space,
        format_header(10) TYPE c VALUE 'U1U2U3U4U5',
        lv_first_loop     type boolean value 'X'. "2052999

  CONSTANTS: offset_aufzaehlung TYPE i VALUE 2.

  CLEAR:     resttext, diagnosetext.

  IF p_textlines[] IS INITIAL.
    CLEAR p_text_tab.
    REFRESH p_text_tab.
  ELSE.
    LOOP AT p_textlines.
      IF resttext NE space.
        CASE p_textlines-tdformat.

* Wenn Überschrift, Aufzählung oder Absatzformatierung,
* dann neue Zeile beginnen
* sonst Zeilen miteinander verbinden
* Formatierungszeichen merken
          WHEN '* ' OR 'AS'.
            PERFORM write_to_text_tab USING resttext offset aufz_sign
                                      CHANGING p_text_tab-textzeile.
            APPEND p_text_tab.
            MOVE p_textlines-tdline TO resttext.
            offset_flag = space.
            offset = 0.
          WHEN 'U1' OR 'U2' OR 'U3' OR 'U4' OR 'U5'.
            PERFORM write_to_text_tab USING resttext offset aufz_sign
                                      CHANGING p_text_tab-textzeile.
            APPEND p_text_tab.
*           Vor Überschrift Leerzeile einfügen
            CLEAR p_text_tab.
            APPEND p_text_tab.
            MOVE p_textlines-tdline TO resttext.
            offset_flag = space.
            offset = 0.
          WHEN 'B1'.
            PERFORM write_to_text_tab USING resttext offset aufz_sign
                                      CHANGING p_text_tab-textzeile.
            APPEND p_text_tab.
*           Aufzählung mit 'o ' beginnen
            CONCATENATE aufz_sign p_textlines-tdline INTO resttext
                                                  SEPARATED BY space.
            offset_flag = 'X'.
            offset = offset_aufzaehlung.
          WHEN space.
            IF sy-langu CA '123JM'.    "for MB processing
              CONCATENATE resttext p_textlines-tdline INTO resttext.
            ELSE.                      "for SB processing
              CONCATENATE resttext p_textlines-tdline INTO resttext
                                                  SEPARATED BY space.
            ENDIF.
          WHEN OTHERS.
            offset_flag = space.
            offset = 0.
            CONCATENATE resttext p_textlines-tdline INTO resttext
                                                   SEPARATED BY space.
        ENDCASE.
*     Wenn kein Rest vorhanden, neue Zeile anfangen
*     und Formatierung merken
      ELSE.
        CASE p_textlines-tdformat.
          WHEN 'B1'.
            offset_flag = 'X'.
            offset = offset_aufzaehlung.
            CONCATENATE aufz_sign p_textlines-tdline INTO resttext
                                                  SEPARATED BY space.
          when 'U1' OR 'U2' OR 'U3' OR 'U4' OR 'U5'. "2052999
            if lv_first_loop is initial.
*             Vor Überschrift Leerzeile einfügen
              clear p_text_tab.
              append p_text_tab.
            endif.
            offset_flag = space.
            offset = 0.
            MOVE p_textlines-tdline TO resttext.
          WHEN OTHERS.
            offset_flag = space.
            offset = 0.
            MOVE p_textlines-tdline TO resttext.
        ENDCASE.
      ENDIF.

*     Zeilenumbruch vorbereiten
      IF offset_flag = space.
        text_length = textlength.
      ELSE.
        IF sy-langu CA '123JM' AND count = 0.      "for MB processing
          text_length = textlength.
          count = count + 1.
        ELSE.                          "for SB processing
          text_length = textlength - offset_aufzaehlung.
        ENDIF.
      ENDIF.
*     length = STRLEN( resttext ).                          "*012d
      length = cl_abap_list_utilities=>dynamic_output_length( resttext )."*012i

*     Solange der übergebene Doku-Text zu lang ist, kleinschneiden und
*     häppchenweise in interne Tabelle schreiben
      WHILE length > text_length.
        CALL FUNCTION 'TEXT_SPLIT'
          EXPORTING
            length       = text_length
            text         = resttext
            as_character = 'X'                              "*012i
          IMPORTING
            line         = zeile
            rest         = resttext
          EXCEPTIONS
            OTHERS       = 1.
        CASE sy-subrc.
          WHEN 0.
            CLEAR p_text_tab.
            PERFORM write_to_text_tab USING zeile offset aufz_sign
                                      CHANGING p_text_tab-textzeile.
*           Formatierungszeichen für Überschrift übergeben
            IF format_header CS p_textlines-tdformat.
              WRITE p_textlines-tdformat TO p_text_tab-textformat.
            ENDIF.
            APPEND p_text_tab.
          WHEN OTHERS.
            CLEAR resttext.
        ENDCASE.
        length = STRLEN( resttext ).
      ENDWHILE.

*     Wenn Reststück zu einer Überschrift gehört, als ganzes in
*     eine Zeile schreiben
      CASE p_textlines-tdformat.
        WHEN 'U1' OR 'U2' OR 'U3' OR 'U4' OR 'U5'.
          MOVE resttext TO p_text_tab-textzeile.
          MOVE p_textlines-tdformat TO p_text_tab-textformat.
          APPEND p_text_tab.
          CLEAR resttext.
          CLEAR p_text_tab.
      ENDCASE.
      clear lv_first_loop.
    ENDLOOP.

* den allerletzten Rest in interne Tabelle schreiben
    IF resttext NE space.
*      move resttext to p_text_tab-textzeile.
      MOVE resttext TO zeile.
      PERFORM write_to_text_tab USING zeile offset aufz_sign
                                CHANGING p_text_tab-textzeile.
      APPEND p_text_tab.
    ENDIF.

  ENDIF.
ENDFORM.                               " MOVE_DOCU_TO_ITAB



*&---------------------------------------------------------------------*
*&      Form  INSERT_PARAMS        B20K052439
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXTLINES  text                                            *
*      -->P_PARAMETER  text                                            *
*----------------------------------------------------------------------*
FORM insert_params TABLES   p_textlines STRUCTURE textlines
                            p_parameter STRUCTURE spar.

*015d+
*  data: help_string          type c value '&',
*        help_string1(12)     type c,
*        replace_done_flag(1) type c,
*015d-
  DATA:                                                     "*015i
          field_length         TYPE i,
          length               TYPE i,
          line                 LIKE tline-tdline.           "*015i
*015d+
*        begin_par            type i,
*        end_par              type i,
*        len_par              type i,
*        line                 like tline-tdline,
*        tab_key(10)          type c.
*
*  field-symbols: <str1> type c,
*                 <str2> type c,
*                 <str3> type c.
*015d-

  DESCRIBE FIELD p_textlines-tdline LENGTH field_length
                                    IN CHARACTER MODE.

  LOOP AT p_textlines.
* Prüfen, ob Platzhalter vorhanden
*    IF p_textlines-tdline CP '*&*&*'.                      "*015d
    MOVE p_textlines-tdline TO diagnosetext.
*015d+
*      move diagnosetext to resttext.
*      while resttext cs help_string.
*        clear replace_done_flag.
*        begin_par = sy-fdpos + 1.
*        clear dummytext.
*        move resttext+begin_par to dummytext.
*        if dummytext ns help_string.
*          exit.
*        else.
*          end_par = sy-fdpos.
*          len_par = end_par + 1.
**         Name des Platzhalter ermitteln
*          assign dummytext(end_par) to <str1>.
*          tab_key = dummytext(end_par).
*
**         nach Parameter in interner Tabelle suchen
*          read table p_parameter with key param = tab_key
*                                 binary search.
*          if sy-subrc = 0.
*            shift p_parameter-value left deleting leading space.
*            concatenate help_string <str1> help_string
*                                                into help_string1.
*            length = strlen( p_parameter-value ).
*            if length gt 0.
*              assign p_parameter-value(length) to <str2>.
*              length = strlen( help_string1 ).
*              assign help_string1(length) to <str3>.
*              replace <str3> with <str2> into diagnosetext.
*            else.
*              length = strlen( help_string1 ).
*              assign help_string1(length) to <str3>.
*              replace <str3> with space into diagnosetext.
*            endif.
*            if sy-subrc = 0.
*              clear resttext.
*              move dummytext+len_par to resttext.
*              replace_done_flag = 'X'.
**               exit.
*            endif.
*          endif.
*
*          if replace_done_flag eq space.
*            clear resttext.
*            move dummytext to resttext.
*          endif.
*
*        endif.
*      endwhile.
*015d-
*015i+
    PERFORM replace_parameters TABLES   p_parameter
                               CHANGING diagnosetext.
*015i-
*     Alle Parameter eingefügt

*     Nun muß noch geänderte Textzeile zurückgeschrieben werden
*     Wenn der Text durch Einfügen der Parameter zu lang geworden sein
*     sollte, muß er noch klein geschnitten werden.
    length = STRLEN( diagnosetext ).
    WHILE length > field_length.
      CALL FUNCTION 'TEXT_SPLIT'
        EXPORTING
          length = field_length
          text   = diagnosetext
        IMPORTING
          line   = line
          rest   = diagnosetext
        EXCEPTIONS
          OTHERS = 1.
      CASE sy-subrc.
        WHEN 0.
          MOVE line TO p_textlines-tdline.
          insert p_textlines.
          CLEAR p_textlines-tdformat.
        WHEN OTHERS.
          CLEAR diagnosetext.
      ENDCASE.
      length = STRLEN( diagnosetext ).
    ENDWHILE.
    MOVE diagnosetext TO p_textlines-tdline.
    MODIFY p_textlines.
* ENDIF.                                                    "*015d
  ENDLOOP.
ENDFORM.                               " INSERT_PARAMS

*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_TEXT_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZEILE  text                                                *
*      -->P_OFFSET  text                                               *
*      -->P_AUFZ_SIGN  text                                            *
*      <--P_P_TEXT_TAB-TEXTZEILE  text                                 *
*----------------------------------------------------------------------*
FORM write_to_text_tab USING    p_zeile
                                p_offset
                                p_string
                       CHANGING p_text-textzeile.

  DATA: help_string(2) TYPE c.

  CLEAR p_text-textzeile.
  MOVE p_zeile TO help_string.
  IF help_string = p_string.
    WRITE p_zeile TO p_text-textzeile.
  ELSE.
    CLEAR p_text-textzeile.
    WRITE p_zeile TO p_text-textzeile+p_offset.
  ENDIF.
ENDFORM.                               " WRITE_TO_TEXT_TAB
*&---------------------------------------------------------------------*
*&      Form  PAGING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE_SAVE  text                                         *
*      <--P_TEXT_TAB2_INDEX  text                                      *
*----------------------------------------------------------------------*
FORM paging USING    p_ok_code
                     p_text_lines
                     p_page_lines
            CHANGING p_tab_index.
  DATA: last_page TYPE i.
  last_page = p_text_lines - p_page_lines + 1.
  IF last_page LT 1.
    last_page = 1.
  ENDIF.

  CASE p_ok_code.
    WHEN 'P--'.
      p_tab_index = 1.
    WHEN 'P-'.
      p_tab_index = p_tab_index - p_page_lines.
      IF p_tab_index LT 1.
        p_tab_index = 1.
      ENDIF.
    WHEN 'P+'.
      p_tab_index = p_tab_index + p_page_lines.
      IF p_tab_index GT last_page.
        p_tab_index = last_page.
      ENDIF.
    WHEN 'P++'.
      p_tab_index = last_page.
  ENDCASE.
ENDFORM.                               " PAGING

*&---------------------------------------------------------------------*
*&      Form  SET_CURSOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OPTION  text                                               *
*----------------------------------------------------------------------*
FORM set_cursor USING    p_option.
  IF p_option = '1'.
    SET CURSOR FIELD 'BUTTON_1'.
  ELSE.
    SET CURSOR FIELD 'BUTTON_2'.
  ENDIF.
ENDFORM.                               " SETCURSOR

* B20K058946
*&---------------------------------------------------------------------*
*&      Form  CHECK_SPOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_DYNPLEN  text                                              *
*      <--P_SPOP  text                                                 *
*----------------------------------------------------------------------*
FORM check_spop CHANGING p_dynplen
                         p_textlen
                         p_spop LIKE spop.
  DATA: len     TYPE i,
        maxlen  TYPE i,
        pos     TYPE i.

  DATA: limiter(4) TYPE c VALUE '*;;*'.

* doppelte Semikolon als Textbegrenzer eliminieren
  IF p_spop-textline1 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-textline1(pos) TO p_spop-textline1.
    ENDIF.
  ENDIF.
  IF p_spop-textline2 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-textline2(pos) TO p_spop-textline2.
    ENDIF.
  ENDIF.
  IF p_spop-textline3 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-textline3(pos) TO p_spop-textline3.
    ENDIF.
  ENDIF.
  IF p_spop-diagnose CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-diagnose(pos) TO p_spop-diagnose.
    ENDIF.
  ENDIF.
  IF p_spop-diagnose1 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-diagnose1(pos) TO p_spop-diagnose1.
    ENDIF.
  ENDIF.
  IF p_spop-diagnose2 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-diagnose2(pos) TO p_spop-diagnose2.
    ENDIF.
  ENDIF.
  IF p_spop-diagnose3 CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-diagnose3(pos) TO p_spop-diagnose3.
    ENDIF.
  ENDIF.
  IF p_spop-titel CP limiter.
    pos = sy-fdpos.
    IF pos GT 0.
      MOVE p_spop-titel(pos) TO p_spop-titel.
    ENDIF.
  ENDIF.

* Maximale Textlänge bestimmen
* MAXLEN = STRLEN( P_SPOP-TEXTLINE1 ).                      "*012d
  maxlen = cl_abap_list_utilities=>dynamic_output_length( p_spop-textline1 )."*012i
* len = STRLEN( p_spop-textline2 ).                         "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-textline2 )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
* len = STRLEN( p_spop-textline3 ).                         "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-textline3 )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
* len = STRLEN( p_spop-diagnose ).                          "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-diagnose )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
* len = STRLEN( p_spop-diagnose1 ).                         "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-diagnose1 )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
* len = STRLEN( p_spop-diagnose2 ).                         "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-diagnose2 )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
* len = STRLEN( p_spop-diagnose3 ).                         "*012d
  len = cl_abap_list_utilities=>dynamic_output_length( p_spop-diagnose3 )."*012i
  IF len GT maxlen.
    maxlen = len.
  ENDIF.
  IF maxlen GT absmaxlen.
    maxlen = absmaxlen.
  ELSEIF maxlen LE absminlen.
    maxlen = absminlen.
  ENDIF.
  p_textlen = maxlen.
  p_dynplen = maxlen + dynpoffset.



ENDFORM.                    "check_spop

*&---------------------------------------------------------------------*
*&      Form  TYPE_OF_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ICON_POPUP_TYPE  text                                      *
*----------------------------------------------------------------------*
FORM type_of_popup CHANGING p_icon_popup_type.

  DATA:  popup_icon(40)    TYPE c,
         icon_pattern(14)  TYPE c VALUE 'ICON_MESSAGE_*',
         icon_question(21) TYPE c VALUE 'ICON_MESSAGE_QUESTION'.
  DATA:  lv_bool TYPE abap_bool.                            "*062i

  STATICS: sv_add_tooltip LIKE icon-internal,               "*062i
           sv_tooltip_need_determined TYPE xfeld.           "*062i

** WE have to check if for Accessibility reasons a tooltip   "*062i+ 065u+
** is needed for the icon.
*  IF sv_tooltip_need_determined IS INITIAL.
*
*    CLEAR sv_add_tooltip.
*
*    CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
*      IMPORTING
*        accessibility     = lv_bool
*      EXCEPTIONS
*        its_not_available = 1
*        OTHERS            = 2.
*    IF sy-subrc = 0.
*      IF NOT lv_bool IS INITIAL.
** We need the toltip.
*        sv_add_tooltip = 'X'.
*      ENDIF.
*    ELSE.
** In this case we assume the tooltip is not needed.
*    ENDIF.
*
*    sv_tooltip_need_determined = 'X'.
*  ENDIF.                                                    "*062i- 065u-

*016i+
* Eventuell wird gar keine Ikone gewünscht.
  IF p_icon_popup_type = c_no_icon.
    CLEAR p_icon_popup_type.
    EXIT.
  ENDIF.
*016i-

* Nur bestimmte Ikonen zulässig
  IF NOT p_icon_popup_type CP icon_pattern.
    MOVE icon_question TO p_icon_popup_type.
  ENDIF.

* Darstellung der Ikone besorgen
  CALL FUNCTION 'ICON_CREATE'
       EXPORTING
            name                  = p_icon_popup_type
      add_stdinf                  = 'X'                        "*062u 065u
       IMPORTING
            RESULT                = popup_icon
       EXCEPTIONS                                        "#EC *
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

  CASE sy-subrc.
    WHEN 0.
      MOVE popup_icon TO p_icon_popup_type.
    WHEN OTHERS.
      CALL FUNCTION 'ICON_CREATE'
           EXPORTING
                name                  = icon_question
                text                  = space
*         INFO                  = ' '
                add_stdinf            = 'X'
           IMPORTING
                RESULT                = p_icon_popup_type
           EXCEPTIONS                                   "#EC *
                icon_not_found        = 1
                outputfield_too_short = 2
                OTHERS                = 3.

  ENDCASE.


ENDFORM.                               " TYPE_OF_POPUP
*&---------------------------------------------------------------------*
*&      Form  FREE_CONTROL
*&---------------------------------------------------------------------*
form FREE_CONTROL.                                           "1223251 >>
  CLEAR l_url.
  REFRESH html_table.
  IF html_control is not initial.
    CALL METHOD html_control->free.
    FREE html_control.
  ENDIF.
  IF html_control2 is not initial.
    CALL METHOD html_control2->free.
    FREE html_control2.
  ENDIF.
  IF my_container is not initial.
    CALL METHOD my_container->free.
    FREE my_container.
  ENDIF.
  IF my_container2 is not initial.
    CALL METHOD my_container2->free.
    FREE my_container2.
  ENDIF.
endform.                    " FREE_CONTROL                   "1223251 <<
*&---------------------------------------------------------------------*
*&      Form  INSTANTIATE_CONTROL
*&---------------------------------------------------------------------*
form INSTANTIATE_CONTROL.
  if my_container is initial.
    create object my_container
        exporting
            container_name = 'HTML_CONTROL_CON'
        exceptions
            others = 1.
    if sy-subrc <> 0.
        raise cntl_error.
    endif.
  endif.
  if html_control is initial.
    ui_flag = cl_gui_html_viewer=>uiflag_noiemenu   +
              cl_gui_html_viewer=>uiflag_no3dborder +
              cl_gui_html_viewer=>uiflag_use_sapgui_charset.
    create object html_control
      exporting
        parent             = my_container
        uiflag             = ui_flag
      exceptions
        cntl_error         = 1
        cntl_install_error = 2
        dp_install_error   = 3
        dp_error           = 4
        others             = 5.
    if sy-subrc ne 0.
      raise cntl_error.
    endif.
  endif.
endform.                    " INSTANTIATE_CONTROL
*&---------------------------------------------------------------------*
*&      Form  INSTANTIATE_CONTROLS
*&---------------------------------------------------------------------*
form INSTANTIATE_CONTROLS.
  perform instantiate_control.
  if my_container2 is initial.
    create object my_container2
        exporting
            container_name = 'HTML_CONTROL_CON2'
        exceptions
            others = 1.
    if sy-subrc <> 0.
        raise cntl_error.
    endif.
  endif.
  if html_control2 is initial.
    ui_flag = cl_gui_html_viewer=>uiflag_noiemenu   +
              cl_gui_html_viewer=>uiflag_no3dborder +
              cl_gui_html_viewer=>uiflag_use_sapgui_charset.
    create object html_control2
      exporting
        parent             = my_container2
        uiflag             = ui_flag
      exceptions
        cntl_error         = 1
        cntl_install_error = 2
        dp_install_error   = 3
        dp_error           = 4
        others             = 5.
    if sy-subrc ne 0.
      raise cntl_error.
    endif.
  endif.
endform.                    " INSTANTIATE_CONTROLS
*&---------------------------------------------------------------------*
*&      Form  SHOW_HTML
*&---------------------------------------------------------------------*
form SHOW_HTML.
* in ACC mode the focus should be set on the html control (note 1383282)
  data lv_acc type abap_bool.
  call function 'GET_ACCESSIBILITY_MODE'
    importing
      accessibility = lv_acc.
  if lv_acc = abap_true.
    cl_gui_html_viewer=>set_focus( html_control ).
  endif.
  html_control->load_data(
    importing
      assigned_url         = l_url
    changing
      data_table           = html_table
    exceptions
      dp_invalid_parameter = 1
      dp_error_general     = 2
      cntl_error           = 3
      others               = 4 ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  html_control->show_url(
    exporting
      url                    = l_url
    exceptions
      cntl_error             = 1
      cnht_error_not_allowed = 2
      cnht_error_parameter   = 3
      dp_error_general       = 4
      others                 = 5 ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
endform.                    " SHOW_HTML
*&---------------------------------------------------------------------*
*&      Form  SHOW_HTMLS
*&---------------------------------------------------------------------*
form SHOW_HTMLS .
  perform show_html.
  html_control2->load_data(
    importing
      assigned_url         = l_url2
    changing
      data_table           = html_table2
    exceptions
      dp_invalid_parameter = 1
      dp_error_general     = 2
      cntl_error           = 3
      others               = 4 ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  html_control2->show_url(
    exporting
      url                    = l_url2
    exceptions
      cntl_error             = 1
      cnht_error_not_allowed = 2
      cnht_error_parameter   = 3
      dp_error_general       = 4
      others                 = 5 ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
endform.                    " SHOW_HTMLS
*&---------------------------------------------------------------------*
*&      Form  BUILD_HTML
*&---------------------------------------------------------------------*
form BUILD_HTML.
  refresh html_table.
  refresh html_table2.

  "get font name                                           "1594548 >>
  cl_gui_resources=>get_fontname( importing fontname = fontname
                                  exceptions others  = 1 ).
  if sy-subrc <> 0.
    fontname = 'ARIAL'. "fallback
  else.
    concatenate fontname ', ARIAL' into fontname.
  endif.
  "get font size
  data lv_size type i.
  cl_gui_resources=>get_fontsize( importing fontsize = lv_size
                                  exceptions others  = 1 ).
  if sy-subrc <> 0.
    fontsize = '9pt'. "fallback
  else.
    fontsize = trunc( lv_size / 10000 ).
    condense fontsize.
    concatenate fontsize 'pt' into fontsize.
  endif.
  "get background color
  cl_gui_resources=>get_background_color( exporting  id     = 36
                                                     state  = 0
                                          importing  color  = back_color
                                          exceptions others = 1 ).
  if sy-subrc <> 0.
    bgcolor = '#FFFFFF'. "fallback
  else.
  back_color_x      = back_color.
  back_color_string = back_color_x.
  concatenate '#' back_color_string+4(2)
                  back_color_string+2(2)
                  back_color_string+0(2) into bgcolor.
  endif.                                                   "1594548 <<
  "build html
  append '<html><head></head>' to html_table.
  concatenate '<body bgcolor="' bgcolor '" scroll="auto">' into body.
  append body to html_table.
  concatenate '<span style="line-height:1.75em; font-size:' fontsize '; font-family:' fontname '">' into font.
  append font to html_table.
  case sy-dynnr.
    when 502.
      loop at text_tab1 into wa_text_tab1.
        l_string = wa_text_tab1.
        perform mark_special_characters changing l_string..
        if text_line is initial.
          move l_string TO text_line.
        else.
          concatenate text_line '<br>' l_string into text_line.
        endif.
      endloop.
    when 602.
      perform build_html_for_diagnose_object.
      loop at text_tab1 into wa_text_tab1.
        l_string = wa_text_tab1.
        perform mark_special_characters changing l_string.
        if sy-tabix = 1.
          concatenate text_line '<br><br>' l_string into text_line.
        else.
          concatenate text_line '<br>' l_string into text_line.
        endif.
      endloop.
    when 702.
      perform build_html_for_diagnose_object.
      " build second html control with text_question
      append '<html><head></head>' to html_table2.
      concatenate '<body bgcolor="' bgcolor '" scroll="no">' into body.
      append body to html_table2.
      concatenate '<span style="line-height:1.75em; font-size:' fontsize '; font-family:' fontname '">' into font.
      append font to html_table2.
      loop at text_tab1 into wa_text_tab1.
        l_string = wa_text_tab1.
        perform mark_special_characters changing l_string.
        if sy-tabix = 1.
          move l_string to text_line2.
        else.
          concatenate text_line2 '<br>' l_string into text_line2.
        endif.
      endloop.
      append text_line2 to html_table2.
      append '</span></body></html>' to html_table2.
      clear text_line2.
  endcase.
  append text_line to html_table.
  append '</span></body></html>' to html_table.
  clear text_line.
endform.                    " BUILD_HTML
*&---------------------------------------------------------------------*
*&      Form  BUILD_HTML_FOR_DIAGNOSE_OBJECT
*&---------------------------------------------------------------------*
form BUILD_HTML_FOR_DIAGNOSE_OBJECT .
  loop at text_tab2 into wa_text_tab2.
    l_string = wa_text_tab2-textzeile.
    perform mark_special_characters changing l_string.
    if text_line is initial.
       if wa_text_tab2-textformat ca 'U'.
         concatenate '<font color=blue><em>' l_string '</em></font>' into text_line.
       else.
         move l_string to text_line.
       endif.
    else.
      if wa_text_tab2-textformat ca 'U'.
        concatenate text_line '<br>' '<font color=blue><em>' l_string '</em></font>' into text_line.
      else.
        concatenate text_line '<br>' l_string into text_line.
      endif.
    endif.
  endloop.
endform.                    " BUILD_HTML_FOR_DIAGNOSE_OBJECT
*&---------------------------------------------------------------------*
*&      Form  MARK_SPECIAL_CHARACTERS
*&---------------------------------------------------------------------*
form MARK_SPECIAL_CHARACTERS  changing p_string.
  " remove ITF character format
  replace all occurrences of regex '<Z[12GHKUV]>' in p_string with ``.
  replace all occurrences of '</>' in p_string with ``.
  replace all occurrences of '<(>' in p_string with ``.
  replace all occurrences of '<)>' in p_string with ``.
  " replace html own characters
  replace all occurrences of '&' in p_string with '&amp;'.
  replace all occurrences of '<' in p_string with '&lt;'.
  replace all occurrences of '>' in p_string with '&gt;'.
  replace all occurrences of '"' in p_string with '&quot;'.
endform.                    " MARK_SPECIAL_CHARACTERS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_OLD_VERSION  Note 1667082
*&---------------------------------------------------------------------*
form DISPLAY_OLD_VERSION using p_oldversion type boolean.
*   In case of SY-BINPT='X' use a subscreen with textlines.
*   Batch Input is not able to process controls (note 311440).
*   Otherwise use the new accessibile subscreen with html control.
*   This change on old dynpros (500,600,700) is necessary to
*   use already existing eCATT and batchinput records furthermore.
*
*   If SY-BATCH='X' call dynpro with textlines because in batch
*   isn't it possible to create container for html control
*
*   If the popup will be called in a BSP application, in former times
*   nothing happens, the popup was processed successfully. Now with
*   the html control a dump occurs during instantiation of control

  data lv_rfc_cf_is_gui_on type boolean.

  call function 'RFC_CF_IS_GUI_ON'
    importing on = lv_rfc_cf_is_gui_on.

  if sy-binpt            = 'X' or
     sy-batch            = 'X' or
     lv_rfc_cf_is_gui_on = 'N'.
    p_oldversion = 'X'.
  else.
    clear p_oldversion.
  endif.

endform.                    " DISPLAY_OLD_VERSION
