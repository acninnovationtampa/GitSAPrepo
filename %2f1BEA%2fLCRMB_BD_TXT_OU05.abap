FUNCTION /1BEA/CRMB_BD_TXT_O_HD_PROVID.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IV_MODE) TYPE  COMT_TEXT_APPL_MODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      ERROR
*"      INCOMPLETE
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
* Time  : 13:53:02
*
*======================================================================

  DATA:
    LV_OBJID       TYPE  SYMSGV,
    LV_TXTPROC     TYPE  COMT_TEXT_DET_PROCEDURE,
    LV_MODE        TYPE  COMT_TEXT_APPL_MODE,
    LS_BTY         TYPE  BEAS_BTY_WRK
    .

* EXPLAIN:
* Use generic functions to provide texts of a BD head for display
* via standard subscreens of text processing.


* read customizing for the bill type given in the BD head
  CALL FUNCTION 'BEA_BTY_O_GETDETAIL'
       EXPORTING
            IV_APPL          = GC_APPL
            IV_BTY           = IS_BDH-BILL_TYPE
       IMPORTING
            ES_BTY_WRK       = LS_BTY
       EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            RAISING ERROR.
  ENDIF.

  LV_TXTPROC = LS_BTY-BDH_TXT_PROC.

* EXPLAIN:
* Set default manually, such that global constant can be used
* instead of literal.
  IF IV_MODE IS INITIAL.
    LV_MODE = GC_MODE-DISPLAY.
  ELSE.
    LV_MODE = IV_MODE.
  ENDIF.

  CALL FUNCTION 'BEA_TXT_O_PROVIDE'
       EXPORTING
            IS_STRUC    = IS_BDH
            IV_TDOBJECT = GC_BDH_TXTOBJ
            IV_TXTPROC  = LV_TXTPROC
            IV_TYPENAME = GC_TYPENAME_BDH_WRK
            IV_MODE     = LV_MODE
       IMPORTING
            ET_RETURN   = ET_RETURN
       EXCEPTIONS
            ERROR       = 1
            INCOMPLETE  = 2
            OTHERS      = 3.

  CASE SY-SUBRC.
    WHEN 0.
* everything OK
    WHEN 2.
      MESSAGE E052(BEA_TXT) WITH IS_BDH-HEADNO_EXT
              RAISING incomplete.
    WHEN OTHERS.
      MESSAGE E058(BEA_TXT) WITH IS_BDH-HEADNO_EXT
              RAISING error.
  ENDCASE.

ENDFUNCTION.
