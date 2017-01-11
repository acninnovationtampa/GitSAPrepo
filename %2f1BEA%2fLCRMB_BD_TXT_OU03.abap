FUNCTION /1BEA/CRMB_BD_TXT_O_HD_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BTY) TYPE  BEAS_BTY_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
* directly to the caller of BD_TXT_O_HD_CREATE.


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

* fill export parameters (will not be changed by this function)
  IF ES_BDH IS REQUESTED.
    ES_BDH = IS_BDH.
  ENDIF.

*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  IF IS_BTY-BDH_TXT_PROC IS INITIAL.
* no text determination for billing document header (no error)
    EXIT.
  ELSE.
    LV_TXTPROC = IS_BTY-BDH_TXT_PROC.
  ENDIF.

*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------


*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
   IF NOT gv_mapping_exit IS INITIAL.
     CALL BADI gv_mapping_exit->in_map_head
       EXPORTING
         is_bdh         = is_bdh
         iv_tdobject    = gc_bdh_txtobj
         iv_txtproc     = lv_txtproc
       IMPORTING
         et_fv_com_cust = lt_fv_com_cust
         et_return      = lt_return
       EXCEPTIONS
         reject         = 1
         OTHERS         = 2.

     IF sy-subrc NE 0.
       APPEND LINES OF lt_return TO et_return.
       MESSAGE e100(bea_txt) RAISING reject.
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
            IS_STRUC              = IS_BDH
            IV_TDOBJECT           = GC_BDH_TXTOBJ
            IV_TYPENAME           = GC_TYPENAME_BDH_WRK
            IV_TXTPROC            = LV_TXTPROC
            IV_NO_DELTA_INIT_PROC = GC_TRUE
            IT_FV_COM_CUST        = LT_FV_COM_CUST
       IMPORTING
            ET_RETURN             = ET_RETURN
       EXCEPTIONS
            REJECT                = 1
            INCOMPLETE            = 2
            OTHERS                = 3.

  IF SY-SUBRC <> 0.
    LV_RC = SY-SUBRC.
    WRITE IS_BDH-BDH_GUID TO LV_OBJID.
    CASE LV_RC.
      WHEN 0.
* everything OK
      WHEN 2.
        MESSAGE E052(BEA_TXT) WITH LV_OBJID
                RAISING incomplete.
      WHEN OTHERS.
        MESSAGE E058(BEA_TXT) WITH LV_OBJID
                RAISING reject.
    ENDCASE.
  ENDIF.

* (exceptions are passed directly to the caller, without further
* action by BD_TXT_O_HD_CREATE)
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
