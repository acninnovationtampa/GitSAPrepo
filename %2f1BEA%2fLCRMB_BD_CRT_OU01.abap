FUNCTION /1BEA/CRMB_BD_CRT_O_DOC_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(ES_TAXDOC) TYPE  BEAS_PRC_TTE_O_DOCUMENT
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
* Time  : 13:53:02
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LV_PD_HANDLE           TYPE PRCT_HANDLE,
    LS_HANDLE              TYPE TTEPDT_SAVE_HANDLE_ST,
    LR_TTEDOC              TYPE REF TO CL_TTE_DOCUMENT_EXT,
    LS_HEAD_DATA           TYPE PRCT_HEAD_DATA,
    LT_HEADER              TYPE TTEPDT_HEADER_COM_TT,
    LS_HEADER              TYPE TTEPDT_HEADER_COM_ST,
    LS_O_HEADER            TYPE TTEPDT_OHEADER_COM_ST,
    LT_ITEM                TYPE TTEPDT_ITEM_COM_TT,
    LT_TAXEVENT            TYPE TTEPDT_TAXEVENT_COM_TT,
    LT_TAXEL               TYPE TTEPDT_TAXEL_COM_TT,
    LT_TAXVALUE            TYPE TTEPDT_TAXVALUE_COM_TT,
    LT_CURRCONV            TYPE TTEPDT_CURRCONV_COM_TT,
    LT_TRACE               TYPE TTEPDT_TRACE_COM_TT.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN CHECK INTERFACE
*---------------------------------------------------------------------
  IF IS_BDH-PRC_SESSION_ID IS INITIAL.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END CHECK INTERFACE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
  CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
    EXPORTING
      IV_SESSION_ID     = IS_BDH-PRC_SESSION_ID
    IMPORTING
      EV_PRICING_HANDLE = LV_PD_HANDLE
    EXCEPTIONS
      SESSION_NOT_FOUND = 1.
  IF SY-SUBRC <> 0.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E006(BEA_PRC) INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E006(BEA_PRC) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  CALL FUNCTION 'PRC_PD_HEAD_READ'
    EXPORTING
      IV_PD_HANDLE         = LV_PD_HANDLE
     IMPORTING
       ES_HEAD_DATA        = LS_HEAD_DATA
     EXCEPTIONS
       NON_EXISTING_HANDLE = 1
       OTHERS              = 2.
  IF SY-SUBRC <> 0.
    IF ET_RETURN IS REQUESTED.
      MESSAGE E110(BEA_PRC) INTO GV_DUMMY.
      PERFORM msg_add using space space space space CHANGING ET_RETURN.
    ENDIF.
    MESSAGE E110(BEA_PRC) RAISING REJECT.
  ENDIF.
  IF NOT LS_HEAD_DATA-TTE_REQUIRED IS INITIAL.
    PERFORM FILL_TTE_HANDLE
        using
          IS_BDH
          LS_HEAD_DATA
        changing
          LS_HANDLE.
    CREATE OBJECT LR_TTEDOC.
    CALL FUNCTION 'TTE_4_DOCUMENT_GET_PERS'
      EXPORTING
        I_HANDLE                  = LS_HANDLE
        I_READ_FROM_TTE           = LS_HEAD_DATA-EDIT_MODE
        IR_TTEDOC                 = LR_TTEDOC
      EXCEPTIONS
        COMMUNICATION_FAILURE     = 1
        NO_TTE_DOCUMENT           = 2
        SYSTEM_FAILURE            = 3
        IMPORT_ERROR              = 4
        OTHERS                    = 5.
    IF SY-SUBRC <> 0.
      IF ET_RETURN IS REQUESTED.
        MESSAGE E112(BEA_PRC) INTO GV_DUMMY.
        PERFORM msg_add using space space space space CHANGING ET_RETURN.
      ENDIF.
      MESSAGE E112(BEA_PRC) RAISING REJECT.
    ELSE.
      call method lr_ttedoc->get_input_document
        importing
          IT_HEADER_TAB             = LT_HEADER
          IT_ITEM_TAB               = LT_ITEM
          IT_TRANPROP_TAB           = ES_TAXDOC-I_TRANPROP
          IT_ORGUNIT_TAB            = ES_TAXDOC-I_ORGUNIT
          IT_ITEMPART_TAB           = ES_TAXDOC-I_ITEMPART
          IT_PRICEL_TAB             = ES_TAXDOC-I_PRICEL
          IT_TAXDATE_TAB            = ES_TAXDOC-I_TAXDATE
          IT_TAXEVENT_TAB           = LT_TAXEVENT
          IT_TAXEL_TAB              = LT_TAXEL
          IT_TAXVALUE_TAB           = LT_TAXVALUE
          IT_PRODUCT_TAB            = ES_TAXDOC-I_PRODUCT
          IT_PRTAXCL_TAB            = ES_TAXDOC-I_PRTAXCL
          IT_PRPROP_TAB             = ES_TAXDOC-I_PRPROP
          IT_PARTNER_TAB            = ES_TAXDOC-I_PARTNER
          IT_PATAXCL_TAB            = ES_TAXDOC-I_PATAXCL
          IT_PAPROP_TAB             = ES_TAXDOC-I_PAPROP
          IT_PATAXNUM_TAB           = ES_TAXDOC-I_PATAXNUM
          IT_CURRCONV_TAB           = LT_CURRCONV.
      call method lr_ttedoc->get_output_document
        importing
          OT_HEADER_TAB             = ES_TAXDOC-O_HEADER
          OT_ITEM_TAB               = ES_TAXDOC-O_ITEM
          OT_TAXEVENT_TAB           = ES_TAXDOC-O_TAXEVENT
          OT_TAXEL_TAB              = ES_TAXDOC-O_TAXEL
          OT_TAXVALUE_TAB           = ES_TAXDOC-O_TAXVALUE
          OT_CURRCONV_TAB           = ES_TAXDOC-O_CURRCONV
          OT_TRACE_TAB              = LT_TRACE
          OT_TEXT_TAB               = ES_TAXDOC-O_TEXT
          OT_EXEMPT_TAB             = ES_TAXDOC-O_EXEMPT
          OT_USITEM_TAB             = ES_TAXDOC-O_USITEM.
      CLEAR LS_O_HEADER.
      READ TABLE ES_TAXDOC-O_HEADER INTO LS_O_HEADER INDEX 1.
      IF LS_O_HEADER-RETURNCODE > 2.
        IF ET_RETURN IS REQUESTED.
          MESSAGE E114(BEA_PRC) INTO GV_DUMMY.
          PERFORM msg_add using space space space space CHANGING ET_RETURN.
        ENDIF.
        MESSAGE E114(BEA_PRC) RAISING REJECT.
      ENDIF.
    ENDIF.
  ENDIF.
  ES_TAXDOC-PRIDOC_GUID = IS_BDH-PRIDOC_GUID.
  ES_TAXDOC-HEADNO_EXT  = IS_BDH-HEADNO_EXT.
  READ TABLE LT_HEADER INTO LS_HEADER INDEX 1.
  IF SY-SUBRC EQ 0.
    ES_TAXDOC-LANGUAGE = LS_HEADER-LANGUAGE.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
