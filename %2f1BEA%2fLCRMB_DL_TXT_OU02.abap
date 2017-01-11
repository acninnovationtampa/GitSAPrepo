FUNCTION /1BEA/CRMB_DL_TXT_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IT_TEXT) TYPE  COMT_TEXT_TEXTDATA_T
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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

* EXPLAIN:
* Attach texts from the source system to a BEA duelist item
* 1. Determine new TDNAME for the given item
* 2. Replace TDNAME etc in the given texts with the appropriate values
* 3. (not yet implemented:) map source-TDIDs to BEA-TDIDs
* 4. Transfer texts to text memory (from which they can be SAVEd
*    to the database when saving the duelist item)

*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------

  DATA:
    lv_tdname           TYPE tdobname,
    lt_text             TYPE comt_text_textdata_t,
    ls_text             TYPE comt_text_textdata,
    lt_error            TYPE comt_text_error_t,
    ls_error            TYPE comt_text_error,
    ls_msg              TYPE symsg,
    ls_logmsg           TYPE symsg,
    ls_msg_var          TYPE beas_message_var
    .

*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------


*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
* for the sake of standardised I/O interfaces for all services:
* (text processing does not change any fields in the item)
  IF es_dli IS REQUESTED.
    es_dli = is_dli.
  ENDIF.

* Don't save the text if Text Determination Procedure is not assigned
* to the item category. However if Item Category itself is not determined
* save the text so that once item category is assigned, it can be used if
* text determination procedure is assigned to the item category
  IF is_dli IS INITIAL OR
     it_text IS INITIAL OR
     ( NOT is_itc IS INITIAL AND is_itc-dli_txt_proc IS INITIAL ).
    EXIT.
  ENDIF.

*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------


*---------------------------------------------------------------------
* BEGIN MAPPING
*---------------------------------------------------------------------
* no mapping required

*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------


*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
* Here, the work starts: ----------------------
* 1. Determine the TDNAME for the given duelist item
  CALL FUNCTION 'BEA_TXT_O_FVTABFILL'
       EXPORTING
            is_struc    = is_dli
            iv_tdobject = gc_dli_txtobj
            iv_typename = gc_typename_dli_wrk
       IMPORTING
            ev_tdname   = lv_tdname
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
    MOVE-CORRESPONDING syst TO ls_msg.
    MESSAGE ID ls_msg-msgid TYPE ls_msg-msgty NUMBER ls_msg-msgno
            WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4
            INTO gv_dummy.
    PERFORM msg_add using space space space space CHANGING et_return.

    ls_msg_var-msgv1 = gc_p_dli_itemno.
    ls_msg_var-msgv2 = gc_p_dli_headno.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = is_dli
        IS_MSG_VAR     = ls_msg_var
      IMPORTING
        ES_MSG_VAR     = ls_msg_var.
    MESSAGE e059(bea_TXT) WITH ls_msg_var-msgv1 ls_msg_var-msgv2
            RAISING reject.
  ENDIF.


* 2. Replace TDNAME etc in the given texts with the appropriate values
* 3. (not implemented:) map source-TDIDs to BEA-TDIDs
* NO check of TDIDs against the given text procedure
  lt_text = it_text.
  LOOP AT lt_text INTO ls_text.
    ls_text-stxh-mandt     = sy-mandt.
    ls_text-stxh-tdobject  = gc_dli_txtobj.
    ls_text-stxh-tdname    = lv_tdname.
    ls_text-function       = gc_insert.
* here, we could also map the source TDIDs to their BEA equivalents:
**   ls_text-tdid = ...
    MODIFY lt_text FROM ls_text.
  ENDLOOP.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------

* 4. Transfer texts to text memory
  CALL FUNCTION 'COM_TEXT_SAVE_API'
       IMPORTING
            et_error    = lt_error
       CHANGING
            ct_textdata = lt_text.

  IF NOT lt_error IS INITIAL.
* write errors into return table
* (loss of information cannot be avoided)
    LOOP AT lt_error INTO ls_error.
      MESSAGE ID     ls_error-msgid
              TYPE   ls_error-msgty
              NUMBER ls_error-msgno
        WITH ls_error-msgv1 ls_error-msgv2
             ls_error-msgv3 ls_error-msgv4
        INTO gv_dummy.
      PERFORM msg_add using space space space space CHANGING et_return.
    ENDLOOP.

    ls_msg_var-msgv1 = gc_p_dli_itemno.
    ls_msg_var-msgv2 = gc_p_dli_headno.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = is_dli
        IS_MSG_VAR     = ls_msg_var
      IMPORTING
        ES_MSG_VAR     = ls_msg_var.
    MESSAGE e059(bea_TXT) WITH ls_msg_var-msgv1 ls_msg_var-msgv2
            RAISING reject.
  ENDIF.

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
* no mapping required

*---------------------------------------------------------------------
* END MAPPING
*---------------------------------------------------------------------


ENDFUNCTION.
