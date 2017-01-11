***INCLUDE LSSELFXX.

* Baut Feldbeschreibung f�r Tabellen-Popup auf
FORM BUILD_FIDESC_VERSION.
*
  DESCRIBE TABLE FIDESC_VERSION LINES SY-TFILL.
  IF SY-TFILL = 0.
    MOVE 'TRDIR-VERSION'         TO FIDESC_VERSION-FIELDNAME.
    MOVE SPACE                   TO FIDESC_VERSION-COL_HEAD.
    MOVE 1                       TO FIDESC_VERSION-FIELDNUM.
    MOVE 'X'                     TO FIDESC_VERSION-DISPLAY.
    MOVE 'X'                     TO FIDESC_VERSION-KEY_FIELD.
    APPEND FIDESC_VERSION.
    MOVE 'TRDIR-VERSION'         TO FIDESC_VERSION-FIELDNAME.
    MOVE 'Selection Screen Version'(101)
                                 TO FIDESC_VERSION-COL_HEAD.    "#EC *
    MOVE 2                       TO FIDESC_VERSION-FIELDNUM.
    MOVE 'X'                     TO FIDESC_VERSION-DISPLAY.
    MOVE SPACE                   TO FIDESC_VERSION-KEY_FIELD.
    APPEND FIDESC_VERSION.
  ENDIF.
*
ENDFORM.                                  " BUILD_FIDESC_VERSION.


* Baut Popup-Tabelle mit Versionen f�r RS_VALUES_BOX auf.
* P_SUBRC: 0: O.K.
*          4: Keine Versionen
*          8: P_SAPDB nicht da
*         12: P_SAPDB nicht generierbar
FORM BUILD_POPUP_VERSIONS USING    P_SAPDB LIKE TRDIR-NAME
                          CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA: BEGIN OF L_SSCR OCCURS 50.
          INCLUDE STRUCTURE RSSCR.
  DATA: END   OF L_SSCR.

  DATA: BEGIN OF L_TEXTPOOL OCCURS 50.
          INCLUDE STRUCTURE TEXTPOOL.
  DATA: END   OF L_TEXTPOOL.

  DATA: BEGIN OF L_TEXTKEY,
          ID  LIKE TEXTPOOL-ID VALUE 'I',
          KEY LIKE TEXTPOOL-KEY,
        END   OF L_TEXTKEY.

  DATA L_FIRST_VERSION VALUE 'X'.
  DATA L_READ_TPOOL_SUBRC LIKE SY-SUBRC.

  REFRESH POPUP_VERSIONS.

  SELECT SINGLE * FROM TRDIR WHERE NAME = P_SAPDB.
  IF SY-SUBRC NE 0.
    P_SUBRC = 8.
    EXIT.
  ENDIF.

  LOAD REPORT P_SAPDB PART 'SSCR' INTO L_SSCR.
  P_SUBRC = SY-SUBRC.
  IF P_SUBRC NE 0.
    GENERATE REPORT P_SAPDB.
    P_SUBRC = SY-SUBRC.
    IF P_SUBRC NE 0.
      GENERATE REPORT P_SAPDB WITHOUT SELECTION-SCREEN.
      P_SUBRC = SY-SUBRC.
      IF P_SUBRC EQ 0.
        LOAD REPORT P_SAPDB PART 'SSCR' INTO L_SSCR.
        P_SUBRC = SY-SUBRC.
      ENDIF.
    ELSE.
      LOAD REPORT P_SAPDB PART 'SSCR' INTO L_SSCR.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF P_SUBRC NE 0.
    P_SUBRC = 12.
    EXIT.
  ENDIF.

  LOOP AT L_SSCR WHERE KIND = 'V'.
    IF L_FIRST_VERSION NE SPACE.
      L_FIRST_VERSION = SPACE.
      READ TEXTPOOL P_SAPDB INTO L_TEXTPOOL LANGUAGE SY-LANGU.
      L_READ_TPOOL_SUBRC = SY-SUBRC.
      IF L_READ_TPOOL_SUBRC = 0.
        LOOP AT L_TEXTPOOL.
          IF L_TEXTPOOL-ID NE 'I'.
            DELETE L_TEXTPOOL.
          ENDIF.
        ENDLOOP.
        SORT L_TEXTPOOL BY KEY.
      ENDIF.
    ENDIF.
    MOVE: L_SSCR-NAME+2(3) TO POPUP_VERSIONS-VERSION,
          L_SSCR-NAME+5(3) TO L_TEXTKEY-KEY.
    IF L_READ_TPOOL_SUBRC = 0.
      READ TABLE L_TEXTPOOL WITH KEY L_TEXTKEY BINARY SEARCH.
      IF SY-SUBRC = 0.
        MOVE L_TEXTPOOL-ENTRY TO POPUP_VERSIONS-TEXT.
      ELSE.
        MOVE SPACE TO POPUP_VERSIONS-TEXT.
      ENDIF.
    ELSE.
      MOVE SPACE TO POPUP_VERSIONS-TEXT.
    ENDIF.
    APPEND POPUP_VERSIONS.
  ENDLOOP.

  DESCRIBE TABLE POPUP_VERSIONS LINES SY-TFILL.
  IF SY-TFILL > 0.
    P_SUBRC = 0.
  ELSE.
    P_SUBRC = 4.
  ENDIF.

ENDFORM.

FORM CHECK_LOAD USING    P_PROGRAM LIKE SY-REPID
                CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_HEAD LIKE RHEAD OCCURS 1.

  LOAD REPORT P_PROGRAM PART 'HEAD' INTO L_HEAD.
  P_SUBRC = SY-SUBRC.
  IF P_SUBRC NE 0.
    GENERATE REPORT P_PROGRAM.
    P_SUBRC = SY-SUBRC.
    IF P_SUBRC NE 0.
      GENERATE REPORT P_PROGRAM WITHOUT SELECTION-SCREEN.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.

FORM LOAD_SSCR TABLES   P_SSCR STRUCTURE RSSCR
               USING    P_REPORT LIKE RSVAR-REPORT
               CHANGING P_SUBRC  LIKE SY-SUBRC.

  LOAD REPORT P_REPORT PART 'SSCR' INTO P_SSCR.
  IF SY-SUBRC NE 0.
    GENERATE REPORT P_REPORT.
    IF SY-SUBRC NE 0.
      P_SUBRC = SY-SUBRC.
      EXIT.
    ELSE.
      LOAD REPORT P_REPORT PART 'SSCR' INTO P_SSCR.
    ENDIF.
  ENDIF.
  P_SUBRC = SY-SUBRC.

* Sortiert und entfernt Hexnull-Zeile
  PERFORM SHAPE_SSCR(RSDBRUNT) TABLES P_SSCR.

ENDFORM.                               " LOAD_SSCR

***********
* callback f�r ALV Grid in RS_INT_SELSCREEN_VERSION_F4
***********
form CALLBACK_ALV_UCOMM USING r_ucomm LIKE sy-ucomm        "#EC *
                              rs_selfield TYPE slis_selfield.
*  if r_ucomm = 'ENTER' or r_ucomm = 'PICK'.
   check rs_selfield-tabindex ne 0.
   read table popup_versions index rs_selfield-tabindex.
   if sy-subrc = 0.
     clear rs_selfield-refresh .
   endif.

endform.