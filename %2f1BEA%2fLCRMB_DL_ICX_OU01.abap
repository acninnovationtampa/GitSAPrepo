FUNCTION /1BEA/CRMB_DL_ICX_O_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     VALUE(IV_PATTERN) TYPE  /SAPCND/DDPAT
*"     VALUE(IV_DFIELD) TYPE  FIELDNAME
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"--------------------------------------------------------------------
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
*--------------------------------------------------------------------*
* BEGIN DEFINITION
*--------------------------------------------------------------------*
  FIELD-SYMBOLS:
    <F>               TYPE ANY.
  CONSTANTS:
    LC_PATTYPE        TYPE /SAPCND/DDPAT_TYPE  VALUE 'BEA_ITC_DETERMINATION',
    LC_RFIELD         TYPE FIELDNAME           VALUE 'ITEM_CATEGORY',
    LC_APPLICATION    TYPE /SAPCND/APPLICATION VALUE 'BEA'.

  DATA:
    LV_SUBRC          TYPE SYSUBRC,
    LS_ICX_COM        TYPE BEAS_CND_ACS_TOTL,
    LS_RESULT         TYPE /SAPCND/DD_DET_RESULT,
    LT_RESULT         TYPE /SAPCND/DD_DET_RESULT_T,
    LS_FIELDVALUE     TYPE /SAPCND/DET_FIELD_VALUE.
*--------------------------------------------------------------------*
* END DEFINITION
*--------------------------------------------------------------------*
  ES_DLI = IS_DLI.
*--------------------------------------------------------------------*
* BEGIN MAPPING
*--------------------------------------------------------------------*
  MOVE-CORRESPONDING IS_DLI TO LS_ICX_COM.
  MOVE IS_DLI-BILL_DATE TO LS_ICX_COM-ACCESS_DATE.
*--------------------------------------------------------------------*
* END MAPPING
*--------------------------------------------------------------------*
  IF LS_ICX_COM-ACCESS_DATE IS INITIAL.
    MOVE SY-DATLO TO LS_ICX_COM-ACCESS_DATE.
  ENDIF.
  LS_ICX_COM-BEF_APPL = GC_APPL.
* Try to read the data from the function group buffer
  IF IV_PATTERN EQ GS_RESULT_BUFFER-PATTERN AND
     LS_ICX_COM EQ GS_RESULT_BUFFER-ICX_COM.
    LT_RESULT = GS_RESULT_BUFFER-RESULT.
  ELSE.
    LOOP AT GT_RESULT_BUFFER INTO GS_RESULT_BUFFER
      WHERE
        PATTERN EQ IV_PATTERN AND
        ICX_COM EQ LS_ICX_COM.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      LT_RESULT = GS_RESULT_BUFFER-RESULT.
    ELSE.
      LV_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.
* Determine the data if the result was not found in the buffer
  IF NOT LV_SUBRC IS INITIAL.
*--------------------------------------------------------------------*
* BEGIN SERVICE CALL
*--------------------------------------------------------------------*
    CALL FUNCTION '/SAPCND/DD_DETERMINE'
      EXPORTING
        IV_APPLICATION       = LC_APPLICATION
        IV_DDPAT_TYPE        = LC_PATTYPE
        IV_PATTERN           = IV_PATTERN
        IS_COMM_STRUC        = LS_ICX_COM
      IMPORTING
        ET_RESULT            = LT_RESULT.
*--------------------------------------------------------------------*
* END SERVICE CALL
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* BEGIN POST PROCESSING
*--------------------------------------------------------------------*
* Update the buffer
    GS_RESULT_BUFFER-PATTERN = IV_PATTERN.
    GS_RESULT_BUFFER-ICX_COM = LS_ICX_COM.
    GS_RESULT_BUFFER-RESULT  = LT_RESULT. "Could be initial
* Clear the buffer if the size reached the given limit.
* If the buffer gets too big, the loop at the begin of
* this function module would be too slow.
    IF GV_BUFFER_SIZE GE GC_MAX_BUFFER_SIZE. "Currently max. is 10
      CALL FUNCTION '/1BEA/CRMB_DL_ICX_O_REFRESH'.
    ENDIF.
    APPEND GS_RESULT_BUFFER TO GT_RESULT_BUFFER.
    ADD 1 TO GV_BUFFER_SIZE.
  ENDIF.
  ASSIGN COMPONENT LC_RFIELD OF STRUCTURE ES_DLI TO <F>.
  IF SY-SUBRC EQ 0.
    CLEAR <F>.
    READ TABLE LT_RESULT INTO LS_RESULT INDEX 1.
    IF SY-SUBRC EQ 0.
      READ TABLE LS_RESULT-FV_TABLE INTO LS_FIELDVALUE
           WITH KEY FIELD = IV_DFIELD.
      IF SY-SUBRC EQ 0.
        MOVE LS_FIELDVALUE-VALUE TO <F>.
      ENDIF.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
* END POST PROCESSING
*--------------------------------------------------------------------*
ENDFUNCTION.
