FUNCTION POPUP_TO_CONFIRM_STEP.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DEFAULTOPTION) DEFAULT 'Y'
*"     VALUE(TEXTLINE1)
*"     VALUE(TEXTLINE2) DEFAULT SPACE
*"     VALUE(TITEL)
*"     VALUE(START_COLUMN) LIKE  SY-CUCOL DEFAULT 25
*"     VALUE(START_ROW) LIKE  SY-CUROW DEFAULT 6
*"     VALUE(CANCEL_DISPLAY) DEFAULT 'X'
*"  EXPORTING
*"     VALUE(ANSWER)
*"----------------------------------------------------------------------

  ANSWER = 'N'.

  DATA: DYNPLEN    TYPE I,                                 "B20K058946
        END_COLUMN TYPE I,                                 "B20K058946
        END_ROW    TYPE I.                                 "B20K058946

  CLEAR SPOP.                                              "B20K058946
  CLEAR TEXTLEN.                                           "B20K058946

  CLEAR   EXCLUDE.                                         "B20K079893
  REFRESH EXCLUDE.                                         "B20K079893

  SPOP-TITEL     = TITEL.

  SPOP-TEXTLINE1 = TEXTLINE1.
  SPOP-TEXTLINE2 = TEXTLINE2.

  PERFORM CHECK_SPOP CHANGING DYNPLEN                      "B20K058946
                              TEXTLEN                      "B20K058946
                              SPOP .                       "B20K058946

  END_COLUMN = START_COLUMN + DYNPLEN.                     "B20K058946
  END_ROW    = START_ROW    + 3.                           "B20K058946


  IF DEFAULTOPTION = 'Y' OR DEFAULTOPTION = 'J'.
     OPTION = '1'.
  ELSE.
     OPTION = '2'.
  ENDIF.

  IF CANCEL_DISPLAY = 'X'.                             "B20K052439
    CANCEL_OPTION = 'X'.                               "B20K052439
  ELSE.                                                "B20K052439
    MOVE 'CANC' TO EXCLUDE.                            "B20K079893
    APPEND EXCLUDE.                                    "B20K079893
    CANCEL_OPTION = SPACE.                             "B20K052439
  ENDIF.                                               "B20K052439

*  call screen 100 starting at start_column start_row.       "B20K022194

   CALL SCREEN 100 STARTING AT START_COLUMN START_ROW       "B20K058946
                   ENDING   AT END_COLUMN END_ROW  .        "B20K058946

  ANSWER = ANTWORT.
ENDFUNCTION.
