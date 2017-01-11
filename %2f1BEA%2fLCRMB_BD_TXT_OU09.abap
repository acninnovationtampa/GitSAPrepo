FUNCTION /1BEA/CRMB_BD_TXT_O_IT_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK OPTIONAL
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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

* EXPLAIN:
* Practically all the work of text determination can be done
* generically, independent of the current text object.
* Therefore, this function contains only a few preparatory steps.
* Checks, error handling and the proper text determination mostly
* take place in TXT_O_FIND; errors from TXT_O_FIND are passed
* directly to the caller of BD_TXT_O_IT_CREATE.


*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
     LV_TXTPROC      TYPE  COMT_TEXT_DET_PROCEDURE,
     LV_OBJID        TYPE  SYMSGV,
     LV_RC           TYPE  SYSUBRC,
     LT_RETURN       TYPE  BEAT_RETURN,
     LT_FV_COM_CUST  TYPE  COMT_TEXT_FIELD_VALUE_TAB.

*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
* fill export parameters (will not be changed by this function)
  IF ES_BDI IS REQUESTED.
    ES_BDI = IS_BDI.
  ENDIF.

  IF is_itc-bdi_txt_proc IS INITIAL.
* no text determination for this bill type (no error)
    EXIT.
  ELSE.
    lv_txtproc = is_itc-bdi_txt_proc.
  ENDIF.

*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
   IF NOT gv_mapping_exit IS INITIAL.
     CALL BADI gv_mapping_exit->in_map_item
       EXPORTING
         is_bdi         = is_bdi
         iv_tdobject    = gc_bdi_txtobj
         iv_txtproc     = lv_txtproc
       IMPORTING
         et_fv_com_cust = lt_fv_com_cust
         et_return      = lt_return
       EXCEPTIONS
         reject         = 1
         OTHERS         = 2.

     IF sy-subrc NE 0.
       APPEND LINES OF lt_return TO et_return.
       MESSAGE e101(bea_txt) RAISING reject.
     ENDIF.
   ENDIF.
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_TXT_O_FIND'
       EXPORTING
            IS_STRUC              = IS_BDI
            IV_TDOBJECT           = GC_BDI_TXTOBJ
            IV_TXTPROC            = LV_TXTPROC
            IV_TYPENAME           = GC_TYPENAME_BDI_WRK
            IV_NO_DELTA_INIT_PROC = GC_TRUE
            IT_FV_COM_CUST        = LT_FV_COM_CUST
       IMPORTING
            ET_RETURN             = ET_RETURN
       EXCEPTIONS
            REJECT                = 1
            INCOMPLETE            = 2
            OTHERS                = 1.

  IF SY-SUBRC <> 0.
    LV_RC = SY-SUBRC.
    WRITE IS_BDI-BDI_GUID TO LV_OBJID.
    CASE LV_RC.
      WHEN 0.
* everything OK
      WHEN 2.
        MESSAGE E061(BEA_TXT) WITH LV_OBJID
                RAISING incomplete.
      WHEN OTHERS.
        MESSAGE E057(BEA_TXT) WITH LV_OBJID
                RAISING reject.
    ENDCASE.
  ENDIF.

* (exceptions are passed directly to the caller, without further
* action by BD_TXT_O_IT_CREATE)

*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------

ENDFUNCTION.
