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
*-----------------------------------------------------------------*
*     FORM PRCODL_ELZ_ERL_GET_TXT_DATA
*-----------------------------------------------------------------*
FORM TXTODL_ELZ_ERL_GET_TXT_DATA
  USING    UV_PARENTRECNO TYPE SYTABIX
  CHANGING CS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
           CT_TEXTHEAD    TYPE BEAT_DLI_TXT_HEAD_COM
           CT_TEXTLINE    TYPE BEAT_DLI_TXT_LINE_COM.

  DATA :
    LS_TEXTHEAD TYPE BEAS_DLI_TXT_HEAD_COM,
    LS_TEXTLINE TYPE BEAS_DLI_TXT_LINE_COM,
    LT_TEXT     TYPE COMT_TEXT_TEXTDATA_T,
    LS_LINES    TYPE TLINE,
    LS_TEXT     TYPE COMT_TEXT_TEXTDATA.

  CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_GET'
    EXPORTING
      IS_DLI           = CS_DLI_WRK
    IMPORTING
      ET_TEXT          = LT_TEXT.
  LOOP AT LT_TEXT INTO LS_TEXT.
    MOVE-CORRESPONDING LS_TEXT-STXH TO LS_TEXTHEAD.
    LS_TEXTHEAD-PARENTRECNO = UV_PARENTRECNO.
    APPEND LS_TEXTHEAD TO CT_TEXTHEAD.
    LOOP AT LS_TEXT-LINES INTO LS_LINES.
      MOVE-CORRESPONDING LS_LINES TO LS_TEXTLINE.
      LS_TEXTLINE-PARENTRECNO = UV_PARENTRECNO.
      APPEND LS_TEXTLINE TO CT_TEXTLINE.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*-----------------------------------------------------------------*
*     FORM PRCODL_ELZ_ERL_GET_TXT_DRV
*-----------------------------------------------------------------*
FORM TXTODL_ELZ_ERL_GET_TXT_DRV
  CHANGING CS_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
           CT_TEXTLINE    TYPE COMT_TEXT_TEXTDATA_T.

  CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_GET'
    EXPORTING
      IS_DLI           = CS_DLI_WRK
    IMPORTING
      ET_TEXT          = CT_TEXTLINE.
ENDFORM.
