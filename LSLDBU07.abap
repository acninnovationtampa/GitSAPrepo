FUNCTION SELECT_OPTIONS_RESTRICT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(PROGRAM) LIKE  SY-REPID OPTIONAL
*"             REFERENCE(RESTRICTION) TYPE  SSCR_RESTRICT
*"             REFERENCE(DB) LIKE  RSSCR-DB DEFAULT SPACE
*"       EXCEPTIONS
*"              TOO_LATE
*"              REPEATED
*"              SELOPT_WITHOUT_OPTIONS
*"              SELOPT_WITHOUT_SIGNS
*"              INVALID_SIGN
*"              EMPTY_OPTION_LIST
*"              INVALID_KIND
*"              REPEATED_KIND_A
*"----------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_SELOPT LIKE RSSCR-NAME.

  IF PROGRAM IS INITIAL.
    IF DB = SPACE.
      PROGRAM = SY-CPROG.
    ELSE.
      PROGRAM = SY-LDBPG.
    ENDIF.
  ENDIF.

  PERFORM FILL_RESTRICT(RSDBRUNT) USING    PROGRAM
                                           RESTRICTION DB SPACE
                                  CHANGING L_SUBRC L_SELOPT.

  CASE L_SUBRC.
    WHEN 0.
*   WHEN 1.
*     RAISE NOT_DURING_SUBMIT.
    WHEN 2.
      RAISE TOO_LATE.
*   WHEN 3.
*     RAISE DB_CALL_AFTER_REPORT_CALL.
    WHEN 4.
      RAISE REPEATED.
    WHEN 5.
      RAISE REPEATED.
    WHEN 6.
      RAISE EMPTY_OPTION_LIST.
    WHEN 7.
      MESSAGE A032 WITH L_SELOPT RAISING SELOPT_WITHOUT_OPTIONS.
    WHEN 8.
      RAISE INVALID_SIGN.
    WHEN 9.
      MESSAGE A033 WITH L_SELOPT RAISING SELOPT_WITHOUT_SIGNS.
    WHEN 10.
      RAISE INVALID_KIND.
*   WHEN 11.
*     MESSAGE A034 RAISING REPORT_CALL_AFTER_DB_ERROR.
    WHEN 12.
      RAISE REPEATED_KIND_A.
  ENDCASE.

ENDFUNCTION.
