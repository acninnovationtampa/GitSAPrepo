FUNCTION /1BEA/CRMB_BD_TXT_O_IT_PUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IV_MODE) TYPE  COMT_TEXT_APPL_MODE OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"     REFERENCE(EV_DATA_CHANGED) TYPE  BEA_BOOLEAN
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
    LV_TXTPROC     TYPE  COMT_TEXT_DET_PROCEDURE,
    LS_ITC         TYPE  BEAS_ITC_WRK,
    LV_MODE        TYPE  COMT_TEXT_APPL_MODE,
    LV_OBJID       TYPE  SYMSGV,
    LV_RC          TYPe  SYSUBRC
    .

* EXPLAIN:
* Use generic functions to read texts for a BD item

  ES_BDI = IS_BDI.

* PUT receives the current text data from the text subscreen and
* transfers them to text memory

* read customizing for the item category
  CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
       EXPORTING
            IV_APPL          = GC_APPL
            IV_ITC           = IS_BDI-ITEM_CATEGORY
       IMPORTING
            ES_ITC_WRK       = LS_ITC
       EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            RAISING ERROR.
  ENDIF.

  LV_TXTPROC = LS_ITC-BDI_TXT_PROC.

* EXPLAIN:
* Set default manually, such that global constant can be used
* instead of literal.
  IF IV_MODE IS INITIAL.
    LV_MODE = GC_MODE-DISPLAY.
  ELSE.
    LV_MODE = IV_MODE.
  ENDIF.

  CALL FUNCTION 'BEA_TXT_O_PUT'
       EXPORTING
            IS_STRUC        = IS_BDI
            IV_TDOBJECT     = GC_BDI_TXTOBJ
            IV_TXTPROC      = LV_TXTPROC
            IV_TYPENAME     = GC_TYPENAME_BDI_WRK
            IV_MODE         = LV_MODE
       IMPORTING
            ET_RETURN       = ET_RETURN
            EV_DATA_CHANGED = EV_DATA_CHANGED
       EXCEPTIONS
            ERROR           = 1
            INCOMPLETE      = 2
            OTHERS          = 3.

  IF SY-SUBRC = 0.
* text error may also change due to changes in customizing,
* not only due to manual changes in texts
    ES_BDI-TEXT_ERROR = GC_FALSE.
    IF IS_BDI-TEXT_ERROR <> ES_BDI-TEXT_ERROR.
      EV_DATA_CHANGED = GC_TRUE.
    ENDIF.
  ELSE.
    ES_BDI-TEXT_ERROR = GC_TRUE.
    IF IS_BDI-TEXT_ERROR <> ES_BDI-TEXT_ERROR.
      EV_DATA_CHANGED = GC_TRUE.
    ENDIF.
    LV_RC = SY-SUBRC.
    WRITE IS_BDI-BDI_GUID TO LV_OBJID.
    CASE LV_RC.
      WHEN 2.
        MESSAGE E061(BEA_TXT) WITH LV_OBJID
                RAISING incomplete.
      WHEN OTHERS.
        MESSAGE E057(BEA_TXT) WITH LV_OBJID
                RAISING error.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
