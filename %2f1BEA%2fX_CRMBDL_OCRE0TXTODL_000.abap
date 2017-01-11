*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================
   DATA:
     LV_TXTODL_000_TABIX    TYPE SYTABIX,
     LS_TXTODL_000_TEXT     TYPE COMT_TEXT_TEXTDATA,
     LS_TXTODL_000_TLINE    TYPE BEAS_TXT_LINE_COM,
     LS_TXTODL_000_TEXTHEAD TYPE BEAS_DLI_TXT_HEAD_COM,
     LS_TXTODL_000_TEXTLINE TYPE BEAS_DLI_TXT_LINE_COM.
   CLEAR CT_TEXTLINE.
   LOOP AT UT_TEXTHEAD INTO LS_TXTODL_000_TEXTHEAD
        WHERE PARENTRECNO = CV_TABIX_DLI.
     CLEAR LS_TXTODL_000_TEXT.
     MOVE-CORRESPONDING LS_TXTODL_000_TEXTHEAD TO LS_TXTODL_000_TEXT-STXH.
     LV_TXTODL_000_TABIX = SY-TABIX.
     LOOP AT UT_TEXTLINE INTO LS_TXTODL_000_TEXTLINE
          WHERE PARENTRECNO = LV_TXTODL_000_TABIX.
       MOVE-CORRESPONDING LS_TXTODL_000_TEXTLINE TO LS_TXTODL_000_TLINE.
       APPEND LS_TXTODL_000_TLINE TO LS_TXTODL_000_TEXT-LINES.
     ENDLOOP.
     APPEND LS_TXTODL_000_TEXT TO CT_TEXTLINE.
   ENDLOOP.
