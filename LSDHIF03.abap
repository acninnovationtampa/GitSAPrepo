*----------------------------------------------------------------------*
***INCLUDE LSDHIF03 .
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM GET_FIELDS_OF_VALUE_TAB                                  *
*---------------------------------------------------------------------*
*       Beschreibung einer intern definierten Tabelle in Form
*       einer DFIES-Tabelle gewinnen.
*---------------------------------------------------------------------*
*  -->  VALUE_TAB                                                     *
*  -->  FIELD_TAB                                                     *
*  -->  RETFIELD                                                      *
*---------------------------------------------------------------------*
FORM get_fields_of_value_tab
     TABLES value_tab
            field_tab STRUCTURE dfies
     CHANGING retfield LIKE dfies-fieldname.
  DATA hlp(61).
  DATA offset LIKE dfies-offset.
  DATA dfies_zwi LIKE dfies.
  DATA dtelinfo_wa TYPE dtelinfo.
  DATA: tabname LIKE dd03p-tabname, lfieldname LIKE dfies-lfieldname.
  FIELD-SYMBOLS: <f>.
  DATA: i LIKE sy-index.
  DATA: n(4) TYPE n.

  DESCRIBE FIELD value_tab HELP-ID hlp.
  DO.
    i = sy-index.
    ASSIGN COMPONENT i OF STRUCTURE value_tab TO <f>.
    IF sy-subrc <> 0 . EXIT. ENDIF.
    DESCRIBE FIELD <f> HELP-ID hlp.
    SPLIT hlp AT '-' INTO tabname lfieldname.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              tabname        = tabname
              lfieldname     = lfieldname
              all_types      = 'X'
         IMPORTING
*             X030L_WA       =
*             DDOBJTYPE      =
              dfies_wa       = dfies_zwi
*        TABLES
*             DFIES_TAB      = DFIES_ZWI
         EXCEPTIONS
              not_found      = 1
              internal_error = 2
              OTHERS         = 3.
    CHECK sy-subrc = 0.
    DESCRIBE DISTANCE BETWEEN value_tab AND <f>
             INTO dfies_zwi-offset IN BYTE MODE.
    CLEAR dfies_zwi-tabname.
    dfies_zwi-position = i.
    n = i.
    CONCATENATE 'F' n INTO dfies_zwi-fieldname.
    dfies_zwi-mask+2(1) = 'X'.         "Rollname für F1-Hilfe verantw.
*   Das Flag F4-Available muß jetzt aber aus dem DTEL kommen.
    CLEAR: dfies_zwi-f4availabl, dtelinfo_wa.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname     = dfies_zwi-rollname
        all_types   = 'X'
      IMPORTING
        dtelinfo_wa = dtelinfo_wa
      EXCEPTIONS
        OTHERS      = 0.
    dfies_zwi-f4availabl = dtelinfo_wa-f4availabl.
    APPEND dfies_zwi TO field_tab.
  ENDDO.
  ASSIGN COMPONENT retfield OF STRUCTURE value_tab TO <f>.
  DESCRIBE DISTANCE BETWEEN value_tab AND <f>
           INTO offset IN BYTE MODE.
  READ TABLE field_tab WITH KEY offset = offset.
  CHECK sy-subrc = 0.
  retfield = field_tab-fieldname.
ENDFORM.                               " GET_FIELDS_OF_VALUE_TAB
*---------------------------------------------------------------------*
*       FORM SET_HELP_INFO_FROM_FOCUS                                 *
*---------------------------------------------------------------------*
*       Die Info, zu dem Feld, das bei F4 den Focus hatte, in die
*       HELP_INFO übertragen. Mit dieser Info ist das ActiveX in
*       der Lage, das Feld eindeutig zu identifizieren.
*---------------------------------------------------------------------*
*  -->  HELP_INFO                                                     *
*---------------------------------------------------------------------*
FORM set_help_info_from_focus CHANGING help_info STRUCTURE help_info.
  DATA: BEGIN OF focus,
            subprog LIKE help_info-dynpprog,
            subnum LIKE help_info-dynpro,
            mainprog LIKE help_info-dynpprog,
            mainnum LIKE help_info-dynpro,
            fieldname LIKE help_info-dynprofld,
            offs TYPE i,               "Cursor innerhalb des Feldes
            line TYPE i,               "Steploop
        END OF focus.
* Der Call funktioniert nicht bei der Standard-Hilfe,
* sondern nur zu PAI und POV.
  CALL 'DY_GET_FOCUS'
        ID 'SSCREENNAM' FIELD focus-subprog
        ID 'SSCREENNBR' FIELD focus-subnum
        ID 'MSCREENNAM' FIELD focus-mainprog
        ID 'MSCREENNBR' FIELD focus-mainnum
        ID 'FIELDNAME' FIELD focus-fieldname
        ID 'FIELDOFFS' FIELD focus-offs
        ID 'LINE' FIELD focus-line.
*   Die mitgegebene Info ist leider bei Subscreens nicht ausreichend.
*   Deshalb wird hier noch mal die Information zu dem Feld gelesen,
*   das zur Zeit den Focus hat. Wenn erkannt wird, daß das Feld auf
*   einem Subscreen liegt, wird die Information zu dem Subscreen-Feld
*   genommen.
  IF ( focus-subprog <> focus-mainprog OR
       focus-subnum <> focus-mainnum ).
*     Das Dynprofeld, liegt in einem Subscreen.
    help_info-sy_dyn = 'U'.
    help_info-msgv1 = focus-mainprog.  "So ist es nun mal vereinbart
    help_info-msgv2 = focus-mainnum.
    help_info-dynpprog = focus-subprog.
    help_info-dynpro = focus-subnum.
  ELSE.
    help_info-dynpprog = focus-mainprog.
    help_info-dynpro = focus-mainnum.
  ENDIF.
  help_info-stepl = focus-line.
  help_info-dynprofld = focus-fieldname.
ENDFORM.                    "SET_HELP_INFO_FROM_FOCUS
*---------------------------------------------------------------------*
*       FORM check_custtab_available                                  *
*---------------------------------------------------------------------*
*       In CALLCONTROL-CUSTTAB die Prüftabelle zum Feld
*       HELP_INFO-TABNAME/FIELDNAME eintragen, falls es
*       dazu eine Customizing-Transaktion gibt.
*---------------------------------------------------------------------*
*  -->  help_info                                                     *
*  -->  callcontrol                                                   *
*---------------------------------------------------------------------*
FORM check_custtab_available
     CHANGING help_info TYPE help_info
              callcontrol TYPE ddshf4ctrl.
  DATA dfies_wa TYPE dfies.
  DATA lfieldname TYPE dfies-lfieldname.
  DATA irc(1) TYPE c.                  "Achtung: nicht like SY-SUBRC

  CHECK help_info-fieldname <> space AND
        help_info-tabname <> space.
  lfieldname = help_info-fieldname.

  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      tabname    = help_info-tabname
      lfieldname = lfieldname
    IMPORTING
      dfies_wa   = dfies_wa
    EXCEPTIONS
      OTHERS     = 2.
  CHECK sy-subrc = 0 AND dfies_wa-checktable <> space.
  help_info-checktable = dfies_wa-checktable.
  CALL FUNCTION 'F4_GET_OBJECT_INFORMATION'
    EXPORTING
      checktable = help_info-checktable
    IMPORTING
      returncode = irc
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc = 0 AND irc <> space.
    callcontrol-custtab = help_info-checktable.
  ENDIF.
ENDFORM.                    "check_custtab_available

*---------------------------------------------------------------------*
*       FORM flatten_fielddescr                                       *
*---------------------------------------------------------------------*
* Strings und Rawstrings in CHAR-Felder umwandeln.
* OUTPUTLEN wird so übernommen, wie sie in FIELDDESCR
* steht.
* Das Feld wird aber für Optimierung der Spaltenbreite im
* Anzeigebaustein markiert.
*
* Der OFFSET der nachfolgenden Felder muß entsprechend angepaßt werden.
*
* Returncode ist <> 0, wenn mindestens ein Feld umgewandelt wurde.
*---------------------------------------------------------------------*
*  -->  SHLP                                                          *
*---------------------------------------------------------------------*
FORM flatten_fielddescr
     CHANGING shlp TYPE shlp_descr
              rc TYPE sy-subrc.
  DATA offset_shift TYPE dfies-offset.
  DATA offset_min TYPE dfies-offset.
  FIELD-SYMBOLS: <dfies> TYPE dfies.

  CLEAR rc.
  SORT shlp-fielddescr BY offset.
  LOOP AT shlp-fielddescr ASSIGNING <dfies>.
    IF offset_shift > 0.
      ADD offset_shift TO <dfies>-offset.
      offset_min = <dfies>-offset.
      PERFORM get_next_aligned_offset(saplsdf4)
              USING offset_min
                    <dfies>-datatype
              CHANGING <dfies>-offset.
      offset_shift = offset_shift + <dfies>-offset - offset_min.
    ENDIF.
    IF <dfies>-inttype = 'g'.
      <dfies>-outputlen = 132.
      <dfies>-inttype = 'C'.
      <dfies>-mask+7(1) = 'O'. "Dargestellte Breite vom Inhalt abhängig
      rc = 4.
    ELSEIF <dfies>-inttype = 'y'.
*     RAW-String wird ebenfalls auf Character abgebildet, weil
*     andernfalls mit HEX 00 aufgefüllt werden würde.
*      <dfies>-inttype = 'X'.
      <dfies>-outputlen = 132.
      <dfies>-inttype = 'C'.
      <dfies>-mask+7(1) = 'O'. "Dargestellte Breite vom Inhalt abhängig
      rc = 4.
    ELSE.
      CONTINUE.
    ENDIF.
*    offset_shift = offset_shift + <dfies>-outputlen - <dfies>-intlen.
*    <dfies>-intlen = <dfies>-outputlen.
*    PERFORM unicode_char2byte(saplsdsd) CHANGING <dfies>-intlen.
*    PERFORM unicode_char2byte(saplsdsd) CHANGING <dfies>-offset.
     data old_intlen type i.
     old_intlen = <dfies>-intlen.
    <dfies>-intlen = <dfies>-outputlen.
     PERFORM unicode_char2byte(saplsdsd) CHANGING <dfies>-intlen.
     offset_shift = offset_shift + <dfies>-intlen - old_intlen.
  ENDLOOP.
ENDFORM.                    "flatten_fielddescr
