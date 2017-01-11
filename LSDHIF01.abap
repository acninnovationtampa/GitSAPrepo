*----------------------------------------------------------------------*
*   INCLUDE LSDHIF01                                                   *
*----------------------------------------------------------------------*

* Vorbereitet für 3.0-Version

* Brückenfunktionen zwischen den alten extern aufrufbaren
* F4-Bausteinen SHL2 und SHL3 und der neuen Hilfe.

* 1. Feldbeschreibung generieren.
FORM help_value_2_fielddescr
     TABLES fields_tab STRUCTURE help_value
            headings TYPE f4typ_heading_tab
            dfies_tab STRUCTURE dfies
            fprop_tab STRUCTURE ddshfprop.
  DATA dfies_zwi LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA fnames LIKE dfies-fieldname OCCURS 0.
  DATA offset TYPE i.

  CLEAR: dfies_tab[], fprop_tab[], fprop_tab.
  LOOP AT fields_tab.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = fields_tab-tabname
        fieldname      = fields_tab-fieldname
      TABLES
        dfies_tab      = dfies_zwi
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0. EXIT. ENDIF.
    READ TABLE dfies_zwi INDEX 1.
    READ TABLE headings
         WITH KEY tabname = fields_tab-tabname
                  fieldname = fields_tab-fieldname.
    IF sy-subrc = 0.
      dfies_zwi-reptext = headings-head_text.
      dfies_zwi-headlen = strlen( headings-head_text ).
      CLEAR: dfies_zwi-scrtext_s, dfies_zwi-scrtext_m,
             dfies_zwi-scrtext_l.
      CLEAR: dfies_zwi-scrlen1, dfies_zwi-scrlen2,
             dfies_zwi-scrlen3.
      MODIFY dfies_zwi INDEX 1.
    ENDIF.
    dfies_zwi-offset = offset.
    IF dfies_zwi-outputlen < dfies_zwi-intlen.
      ADD dfies_zwi-intlen TO offset.
    ELSE.
      ADD dfies_zwi-outputlen TO offset.
    ENDIF.
*   Bei Suchhilfen müssen die Feldnamen eindeutig sein.
    READ TABLE fnames WITH KEY dfies_zwi-fieldname
               TRANSPORTING NO FIELDS
               BINARY SEARCH.
    WHILE sy-subrc = 0.
      CONCATENATE '*' dfies_zwi-fieldname INTO dfies_zwi-fieldname.
      READ TABLE fnames WITH KEY dfies_zwi-fieldname
                 TRANSPORTING NO FIELDS
                 BINARY SEARCH.
    ENDWHILE.
    INSERT dfies_zwi-fieldname INTO fnames INDEX sy-tabix.
    APPEND dfies_zwi TO dfies_tab.
    fprop_tab-fieldname = dfies_zwi-fieldname.
    ADD 1 TO fprop_tab-shlplispos.
    ADD 1 TO fprop_tab-shlpselpos.
    CLEAR fprop_tab-shlpoutput.
    IF fields_tab-selectflag = 'X'.
      fprop_tab-shlpoutput = 'X'.
    ENDIF.
    APPEND fprop_tab.
  ENDLOOP.
ENDFORM.                               "HELP_VALUE_2_FIELDDESCR

*---------------------------------------------------------------------*
*       FORM VALUETAB_2_RECORDTAB                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE_TAB                                                     *
*  -->  DFIES_TAB                                                     *
*  -->  RECORD_TAB                                                    *
*---------------------------------------------------------------------*
FORM valuetab_2_recordtab
     TABLES value_tab
            dfies_tab STRUCTURE dfies  "Nur Felder von der Liste
            record_tab STRUCTURE seahlpres.
  FIELD-SYMBOLS: <f>,
                 <record> TYPE x,
                 <val> TYPE x.
  DATA len LIKE dfies-outputlen.
  DATA: fldcount TYPE i,
        reccount TYPE i,
        rest TYPE i,
        i_val TYPE i,
        i_rec TYPE i.
  DATA offset LIKE dfies-offset.
  DATA maxlen LIKE dfies-intlen.
  DATA maxintlen LIKE dfies-intlen.

  CLEAR: record_tab[], record_tab.
* VALUE_TAB enthält die Inhalte pro Zelle zeilenweise.
* Aus Performance-Gründen wird aber spaltenweise in RECORD_TAB
* übertragen.
* Zunächst mal eine leere RECORD_TAB generieren.
  DESCRIBE TABLE value_tab LINES i_val.
  DESCRIBE TABLE dfies_tab LINES fldcount.
  CHECK fldcount <> 0.
  reccount = i_val DIV fldcount.
  rest = i_val MOD fldcount.
  IF rest <> 0.
    ADD 1 TO reccount.
  ENDIF.
  DO reccount TIMES.
    APPEND record_tab.
  ENDDO.
* Jetzt in dieser Record_Tab spaltenweise modifizieren
  CLEAR offset.
  LOOP AT dfies_tab.
    i_val = sy-tabix.
    i_rec = 1. "Die RECORD_TAB beginnt immer wieder von vorne
    dfies_tab-offset = offset.
    ASSIGN record_tab-string TO <record> CASTING.
    ASSIGN <record>+dfies_tab-offset(*) TO <f>.
    ASSIGN value_tab TO <val> CASTING.
    CLEAR maxlen.
    DO.
      READ TABLE value_tab INDEX i_val.
      IF sy-subrc <> 0. EXIT. ENDIF.
      ADD fldcount TO i_val.
      READ TABLE record_tab INDEX i_rec.
      <f> = <val>.

      len = strlen( value_tab ).
      IF len > maxlen.
        maxlen = len.
      ENDIF.
      MODIFY record_tab INDEX i_rec.
      ADD 1 TO i_rec.
    ENDDO.
*   Wenn das Datum bereits extern eingegeben wurde, muß das hier
*   berücksichtigt werden. (Die alten Bausteinen nahmen das nicht
*   so genau)
    IF dfies_tab-datatype = 'DATS' AND maxlen > 8.
      dfies_tab-inttype = 'C'. dfies_tab-datatype = 'CHAR'.
    ENDIF.
    IF dfies_tab-outputlen > maxlen.
      maxlen = dfies_tab-outputlen.
    ENDIF.
    maxintlen = maxlen.
    PERFORM unicode_char2byte(saplsdsd) CHANGING maxintlen.
    IF dfies_tab-intlen > maxintlen.
      maxintlen = dfies_tab-intlen.
    ENDIF.
*   In den alten Bausteinen war es erlaubt, längere Texte mitzugeben,
*   als der Datentyp eigentlich verkraftet.
*   Das funktioniert aber nur bei Character-artigen Typen.
    IF dfies_tab-inttype = 'C'.
      dfies_tab-outputlen = maxlen.
      dfies_tab-intlen = maxintlen.
    ENDIF.
    MODIFY dfies_tab.
    ADD maxintlen TO offset.
  ENDLOOP.                             " AT DFIES_TAB
ENDFORM.                    "VALUETAB_2_RECORDTAB
*---------------------------------------------------------------------*
*       FORM VALUESTRUC_2_FIELDDESCR                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUESTRUC                                                    *
*  -->  DFIES_TAB                                                     *
*  -->  FPROP_TAB                                                     *
*---------------------------------------------------------------------*
FORM valuestruc_2_fielddescr
     TABLES valuestruc STRUCTURE shstruc
            dfies_tab STRUCTURE dfies
            fprop_tab STRUCTURE ddshfprop.

  DATA offset LIKE dfies-offset.
  DATA fnames LIKE dfies-fieldname OCCURS 0.
* Tabelle der Felder, die im DDIC ein Konvertierungsexit haben.
  DATA dfies_conv LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA dfies_conv2 LIKE dfies OCCURS 0.
* Leider stehen die Konvertierungsexits und das LOWERCASE-Flag
* nicht in der VALUESTRUC und
* müssen deshalb hier nachglesen werden.
  LOOP AT valuestruc.
*   Der Baustein liest tabellenweise. Deshalb pro Tabellenname nur
*   einmal aufrufen.
    READ TABLE dfies_conv
         WITH KEY tabname = valuestruc-tabname BINARY SEARCH.
    IF sy-subrc <> 0.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = valuestruc-tabname
        TABLES
          dfies_tab = dfies_conv2
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      APPEND LINES OF dfies_conv2 TO dfies_conv.
      SORT dfies_conv BY tabname.
    ENDIF.
  ENDLOOP.
  DELETE dfies_conv WHERE convexit = space AND lowercase = space.
  CLEAR: dfies_tab[], dfies_tab, fprop_tab[], fprop_tab.
  LOOP AT valuestruc.
    MOVE-CORRESPONDING valuestruc TO dfies_tab.
    dfies_tab-outputlen = valuestruc-fieldlen.
    dfies_tab-intlen = valuestruc-fieldlen.  "Kann sich noch ändern
    dfies_tab-reptext = valuestruc-keyword.
    dfies_tab-headlen = strlen( dfies_tab-reptext ).
    dfies_tab-scrlen1 = strlen( dfies_tab-scrtext_s ).
    dfies_tab-scrlen2 = strlen( dfies_tab-scrtext_m ).
    dfies_tab-scrlen3 = strlen( dfies_tab-scrtext_l ).
    dfies_tab-datatype = valuestruc-fieldtype.
    dfies_tab-offset = offset.
    ADD dfies_tab-outputlen TO offset.
    ADD 1 TO dfies_tab-position.
    CALL FUNCTION 'DD_DDTYPE_TO_ABAPTYPE'
         EXPORTING
              ddlen         = dfies_tab-outputlen
              ddtype        = dfies_tab-datatype
         IMPORTING
*              ABCODE        =
              ablen         = dfies_tab-intlen
              abtype        = dfies_tab-inttype
         EXCEPTIONS
              OTHERS        = 0.
*   Das Konvertierungsexit und das Lowercase-Flag
*   ist leider nicht in STRUC_TAB enthalten
*   und muß aus dem DDIC nachgelesen werden.
    CLEAR: dfies_tab-convexit, dfies_tab-lowercase.
    READ TABLE dfies_conv
         WITH KEY tabname = valuestruc-tabname
                  fieldname = valuestruc-fieldname BINARY SEARCH.
    IF sy-subrc = 0.
      dfies_tab-convexit = dfies_conv-convexit.
      dfies_tab-lowercase = dfies_conv-lowercase.
    ELSEIF dfies_tab-datatype = 'LANG'.
      dfies_tab-convexit = 'ISOLA'.
    ENDIF.
*   Bei Suchhilfen müssen die Feldnamen eindeutig sein.
    READ TABLE fnames WITH KEY dfies_tab-fieldname
               TRANSPORTING NO FIELDS
               BINARY SEARCH.
    WHILE sy-subrc = 0.
      CONCATENATE '*' dfies_tab-fieldname INTO dfies_tab-fieldname.
      READ TABLE fnames WITH KEY dfies_tab-fieldname
                 TRANSPORTING NO FIELDS
                 BINARY SEARCH.
    ENDWHILE.
    INSERT dfies_tab-fieldname INTO fnames INDEX sy-tabix.
    APPEND dfies_tab.
    fprop_tab-fieldname = dfies_tab-fieldname.
    ADD 1 TO fprop_tab-shlplispos.
    ADD 1 TO fprop_tab-shlpselpos.
    CLEAR fprop_tab-shlpoutput.
    IF valuestruc-selectflag <> space.
      fprop_tab-shlpoutput = 'X'.
    ENDIF.
    APPEND fprop_tab.
  ENDLOOP.
ENDFORM.                    "VALUESTRUC_2_FIELDDESCR
*---------------------------------------------------------------------*
*       FORM SHVALUE_2_RECORDTAB                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SHVALUE                                                       *
*  -->  DFIES_TAB                                                     *
*  -->  RECORD_TAB                                                    *
*---------------------------------------------------------------------*
FORM shvalue_2_recordtab
     TABLES shvalue STRUCTURE shvalue
            dfies_tab STRUCTURE dfies  "Nur Felder von der Liste
            record_tab STRUCTURE seahlpres.
  FIELD-SYMBOLS: <f>.
  DATA len LIKE dfies-outputlen.
  DATA: pos TYPE i,
        line TYPE i.

  CLEAR: record_tab[], record_tab.
* Aus Performance-Gründen wird spaltenweise in RECORD_TAB
* übertragen.
  SORT shvalue BY pos line.
  pos = -1.
  LOOP AT shvalue.
    IF shvalue-pos <> pos.             "Nächste Spalte
      pos = shvalue-pos.
      READ TABLE dfies_tab INDEX pos.
      CHECK sy-subrc = 0.
      len = dfies_tab-outputlen.
      IF dfies_tab-outputlen < dfies_tab-intlen.
        len = dfies_tab-intlen.
      ENDIF.
      ASSIGN record_tab+dfies_tab-offset(len) TO <f>.
    ENDIF.
    READ TABLE record_tab INDEX shvalue-line.
*   Wenn es die Zeile noch nicht gibt, einfügen.
    WHILE sy-subrc <> 0.
      CLEAR record_tab.
      APPEND record_tab.
      READ TABLE record_tab INDEX shvalue-line.
    ENDWHILE.
    <f> = shvalue-low_value.
    MODIFY record_tab INDEX shvalue-line.
  ENDLOOP.
* In SHVALUE sind die Werte in externer Darstellung enthalten. Das
* muß sich jetzt auch in der DFIES_TAB niederschlagen.
  LOOP AT dfies_tab.
    dfies_tab-mask+1(1) = 'E'.
    MODIFY dfies_tab.
  ENDLOOP.
ENDFORM.                    "SHVALUE_2_RECORDTAB

*---------------------------------------------------------------------*
*       FORM RESULT_2_VALUETAB                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SELECT_VALUES                                                 *
*  -->  RESULT_TAB                                                    *
*  -->  SHLP                                                          *
*  -->  SELECT_INDEX                                                  *
*  -->  SELECT_VALUE                                                  *
*---------------------------------------------------------------------*
FORM result_2_valuetab
     TABLES select_values STRUCTURE help_vtab
            result_tab STRUCTURE seahlpres
     CHANGING shlp TYPE shlp_descr
              select_index LIKE sy-tabix
              select_value.
  FIELD-SYMBOLS: <f>.
  DATA dfies_wa LIKE dfies.

  CLEAR: select_values[], select_values, select_value, select_index.
  CHECK NOT result_tab[] IS INITIAL.
  READ TABLE result_tab INDEX 1.
  IF shlp-shlptype = 'CA' OR shlp-shlptype = 'CL'.
    select_index = 1.
  ELSE.
* Der Index des ausgewählten Wertes verbirgt sich hinter dem
* Parameter _INDEX
    READ TABLE shlp-fielddescr INTO dfies_wa
         WITH KEY fieldname = '_INDEX'.
    ASSIGN result_tab+dfies_wa-offset(dfies_wa-intlen) TO <f>.
    select_index = <f>.
  ENDIF.
* Die RESULT_WA feldweise in die Tabelle SELECT_VALUES übertragen
* Das soll dann im externen Format passieren
  PERFORM convert_result_in2ex(saplsdh4)
          TABLES result_tab shlp-fielddescr
          USING space.                 "Alle Felder
  READ TABLE result_tab INDEX 1.
* Reihenfolge der Trefferliste einhalten:
  SORT shlp-fielddescr BY offset.
  LOOP AT shlp-fielddescr INTO dfies_wa.
*   RESULT_TAB sollte externe Darstellung haben
    ASSIGN result_tab+dfies_wa-offset(dfies_wa-outputlen)
           TO <f>.
    select_values-tabname = dfies_wa-tabname.
    select_values-fieldname = dfies_wa-fieldname.
    select_values-value = <f>.
    APPEND select_values.
    READ TABLE shlp-fieldprop TRANSPORTING NO FIELDS
               WITH KEY fieldname = dfies_wa-fieldname
               shlpoutput = 'X'.
    IF sy-subrc = 0.
      select_value = <f>.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "RESULT_2_VALUETAB
*---------------------------------------------------------------------*
*       FORM FIELDSOUT_2_VALUETAB                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SELECT_VALUES                                                 *
*  -->  FIELDS_OUT_TAB                                                *
*  -->  SHLP                                                          *
*  -->  SELECT_INDEX                                                  *
*  -->  SELECT_VALUE                                                  *
*---------------------------------------------------------------------*
FORM fieldsout_2_valuetab
     TABLES select_values STRUCTURE help_vtab
            fields_out_tab STRUCTURE ddshretval
     CHANGING shlp TYPE shlp_descr
              select_index LIKE sy-tabix
              select_value.
  FIELD-SYMBOLS: <f>.
  DATA dfies_wa LIKE dfies.

  CLEAR: select_values[], select_values, select_value, select_index.
  CHECK NOT fields_out_tab[] IS INITIAL.
  IF shlp-shlptype = 'CA' OR shlp-shlptype = 'CL'.
    select_index = 1.
  ELSE.
* Der Index des ausgewählten Wertes verbirgt sich hinter dem
* Parameter _INDEX
    READ TABLE fields_out_tab WITH KEY fieldname = '_INDEX'.
    IF sy-subrc = 0.
      select_index = fields_out_tab-fieldval.
    ENDIF.
  ENDIF.
* Die FIELDS_OUT_TAB in SELECT_VALUES umkopieren. FIELDS_OUT_TAB hat
* bereits externes Format.
* Reihenfolge der Trefferliste einhalten:
  SORT shlp-fielddescr BY offset.
  LOOP AT shlp-fielddescr INTO dfies_wa
    WHERE fieldname <> '_INDEX'.
    READ TABLE fields_out_tab WITH KEY fieldname = dfies_wa-fieldname.
    IF sy-subrc = 0.
      select_values-tabname = dfies_wa-tabname.
      select_values-fieldname = dfies_wa-fieldname.
      select_values-value = fields_out_tab-fieldval.
      APPEND select_values.
      READ TABLE shlp-fieldprop TRANSPORTING NO FIELDS
                 WITH KEY fieldname = dfies_wa-fieldname
                 shlpoutput = 'X'.
      IF sy-subrc = 0.
        select_value = fields_out_tab-fieldval.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "FIELDSOUT_2_VALUETAB

*---------------------------------------------------------------------*
*       FORM CHECKTAB_2_SHLP                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TABNAME                                                       *
*  -->  FIELDNAME                                                     *
*  -->  SHLP                                                          *
*---------------------------------------------------------------------*
FORM checktab_2_shlp
     USING tabname LIKE help_info-tabname
           fieldname LIKE help_info-fieldname
     CHANGING shlp TYPE shlp_descr.
  DATA dfies_wa LIKE dfies.
  DATA fieldprop_wa LIKE ddshfprop.

  CLEAR shlp.
  shlp-shlpname = tabname.
  shlp-shlptype = 'SH'.
  shlp-intdescr-selmtype = 'T'.
  shlp-intdescr-selmethod = tabname.
  shlp-intdescr-dialoginfo = 'X'.
  shlp-intdescr-issimple = 'X'.
  shlp-intdescr-selmexit =  'F4UT_OPTIMIZE_COLWIDTH'.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = tabname
    TABLES
      dfies_tab      = shlp-fielddescr
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT shlp-fielddescr INTO dfies_wa.
    fieldprop_wa-fieldname = dfies_wa-fieldname.
    CLEAR fieldprop_wa-shlpoutput.
    IF dfies_wa-fieldname = fieldname.
      fieldprop_wa-shlpoutput = 'X'.
    ENDIF.
    ADD 1 TO fieldprop_wa-shlplispos.
    ADD 1 TO fieldprop_wa-shlpselpos.
    APPEND fieldprop_wa TO shlp-fieldprop.
  ENDLOOP.
ENDFORM.                    "CHECKTAB_2_SHLP
*---------------------------------------------------------------------*
*       FORM ADD_INDEX_FIELD                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RECORD_TAB                                                    *
*  -->  SHLP                                                          *
*---------------------------------------------------------------------*
FORM add_index_field
     TABLES record_tab STRUCTURE seahlpres
     CHANGING shlp TYPE shlp_descr.
  DATA dfies_wa LIKE dfies.
  DATA dfies_prev LIKE dfies. "Vorhergehendes Feld
  DATA fieldprop_wa LIKE ddshfprop.
  DATA i TYPE i.
  DATA min_offset TYPE dfies-offset.
  DATA index(6) TYPE n.                "Länge 6 reicht hoffentlich
  FIELD-SYMBOLS <f> TYPE n.
  FIELD-SYMBOLS <record> TYPE x.

  LOOP AT shlp-fielddescr INTO dfies_prev.
    dfies_prev-position = sy-tabix.
    MODIFY shlp-fielddescr FROM dfies_prev.
  ENDLOOP.
  SORT shlp-fielddescr BY offset.
* DFIES-Eintrag für das Index-Feld zusammenbasteln.
  DESCRIBE TABLE shlp-fielddescr LINES i.
  READ TABLE shlp-fielddescr INTO dfies_prev INDEX i.
  dfies_wa-fieldname = '_INDEX'.
  dfies_wa-datatype = 'NUMC'.
  dfies_wa-inttype = 'N'.
  dfies_wa-position = dfies_prev-position + 1.
  DESCRIBE FIELD index LENGTH dfies_wa-intlen IN BYTE MODE.
  DESCRIBE FIELD index LENGTH dfies_wa-outputlen IN CHARACTER MODE.
* Offset ergibt sich aus der Länge des vorhergehenden Feldes
  dfies_wa-offset = dfies_prev-offset.
  IF dfies_prev-intlen > dfies_prev-outputlen.
    ADD dfies_prev-intlen TO dfies_wa-offset.
  ELSE.
    ADD dfies_prev-outputlen TO dfies_wa-offset.
  ENDIF.
  min_offset = dfies_wa-offset.
  PERFORM get_next_aligned_offset(saplsdf4) USING min_offset
            dfies_wa-datatype CHANGING dfies_wa-offset.
  APPEND dfies_wa TO shlp-fielddescr.
  fieldprop_wa-fieldname = dfies_wa-fieldname.
  fieldprop_wa-shlpoutput = 'X'.
  APPEND fieldprop_wa TO shlp-fieldprop.
  ASSIGN record_tab TO <record> CASTING.
  ASSIGN <record>+dfies_wa-offset(dfies_wa-intlen) TO <f> CASTING.
  LOOP AT record_tab.
    ADD 1 TO index.
    <f> = index.
    MODIFY record_tab.
  ENDLOOP.
ENDFORM.                               " ADD_INDEX_FIELD
*---------------------------------------------------------------------*
*       FORM MCSELOPT_2_SHLPSELOPT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  MCSELOPT_TAB                                                  *
*  -->  SHLP                                                          *
*---------------------------------------------------------------------*
FORM mcselopt_2_shlpselopt
    TABLES mcselopt_tab STRUCTURE mcselopt
    CHANGING shlp TYPE shlp_descr.
  DATA dfies_wa LIKE dfies.
  DATA selopt_wa LIKE ddshselopt.
  DATA i LIKE sy-tabix.

  LOOP AT shlp-fielddescr INTO dfies_wa.
    i = sy-tabix.
    LOOP AT mcselopt_tab WHERE position = i.
      CHECK mcselopt_tab-low <> '*' OR mcselopt_tab-option <> 'CP'.
      MOVE-CORRESPONDING mcselopt_tab TO selopt_wa.
      selopt_wa-shlpfield = dfies_wa-fieldname.
      selopt_wa-shlpname = dfies_wa-tabname.
      APPEND selopt_wa TO shlp-selopt.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "MCSELOPT_2_SHLPSELOPT

*---------------------------------------------------------------------*
*       FORM COLUMN_2_RECORDTAB                                       *
*---------------------------------------------------------------------*
*       Gleiche Funktion wie VALUE_TAB to RECORD_TAB. Es wird aber
*       von externer Darstellung ausgegangen und abschließen wird
*       nach interner Binärdarstellung konvertiert.
*---------------------------------------------------------------------*
*  -->  VALUE_TAB                                                     *
*  -->  DFIES_TAB                                                     *
*  -->  RECORD_TAB                                                    *
*---------------------------------------------------------------------*
FORM column_2_recordtab
     TABLES value_tab
            dfies_tab STRUCTURE dfies  "Nur Felder von der Liste
            record_tab STRUCTURE seahlpres.
  FIELD-SYMBOLS: <f>,
                 <record> TYPE x,
                 <val> TYPE x.
  DATA len LIKE dfies-outputlen.
  DATA: fldcount TYPE i,
        reccount TYPE i,
        rest TYPE i,
        i_val TYPE i,
        i_rec TYPE i.

  CLEAR: record_tab[], record_tab.
* Den Offset (bei leerer Record_tab) auf externe Darstellung umsetzen.
  PERFORM convert_result_in2ex(saplsdh4)
          TABLES record_tab
                 dfies_tab
          USING space.                 "Alle Felder.
* VALUE_TAB enthält die Inhalte pro Zelle zeilenweise.
* Aus Performance-Gründen wird aber spaltenweise in RECORD_TAB
* übertragen.
* Zunächst mal eine leere RECORD_TAB generieren.
  DESCRIBE TABLE value_tab LINES i_val.
  DESCRIBE TABLE dfies_tab LINES fldcount.
  CHECK fldcount <> 0.
  reccount = i_val DIV fldcount.
  rest = i_val MOD fldcount.
  IF rest <> 0.
    ADD 1 TO reccount.
  ENDIF.
  DO reccount TIMES.
    APPEND record_tab.
  ENDDO.
* Jetzt in dieser Record_Tab spaltenweise modifizieren
  LOOP AT dfies_tab.
    len = dfies_tab-outputlen.
    PERFORM unicode_char2byte(saplsdsd) CHANGING len.
    i_val = sy-tabix.
    i_rec = 1. "Die RECORD_TAB beginnt immer wieder von vorne
    ASSIGN record_tab-string TO <record> CASTING.
    ASSIGN <record>+dfies_tab-offset(len) TO <f>.
    ASSIGN value_tab TO <val> CASTING.
    DO.
      READ TABLE value_tab INDEX i_val. "#EC CI_NOORDER
      IF sy-subrc <> 0. EXIT. ENDIF.
      ADD fldcount TO i_val.
      READ TABLE record_tab INDEX i_rec.
      <f> = <val>.
      MODIFY record_tab INDEX i_rec.
      ADD 1 TO i_rec.
    ENDDO.
  ENDLOOP.
  PERFORM convert_result_ex2in(saplsdh4)
          TABLES record_tab
                 dfies_tab
          USING space.                 "Alle Felder.
ENDFORM.                    "COLUMN_2_RECORDTAB

*&--------------------------------------------------------------------*
*&      Form  GET_TITLE_FROM_DDIC
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->TABNAME    text
*      -->FIELDNAME  text
*      -->WINDOW_TITLtext
*---------------------------------------------------------------------*
FORM get_title_from_ddic
    USING tabname LIKE help_info-tabname
          fieldname LIKE help_info-fieldname
    CHANGING window_title.
  DATA dfies_wa LIKE dfies.
  DATA lfieldname LIKE dfies-lfieldname.

  CHECK tabname <> space.
  lfieldname = fieldname.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname    = tabname
      lfieldname = lfieldname
    IMPORTING
      dfies_wa   = dfies_wa
    EXCEPTIONS
      OTHERS     = 3.
  CHECK sy-subrc = 0.
  window_title = dfies_wa-scrtext_l.
  CHECK window_title = space.
  window_title = dfies_wa-scrtext_m.
  CHECK window_title = space.
  window_title = dfies_wa-scrtext_s.
ENDFORM.                    "GET_TITLE_FROM_DDIC
