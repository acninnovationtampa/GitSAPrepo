FUNCTION /1BEA/CRMB_BD_PPF_O_DETERMINE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BTY) TYPE  BEAS_BTY_WRK
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      PARTNER_ERROR
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

*   application reference
    LO_APPL_OBJECT    TYPE REF TO CL_BEA_PPF,

*   context reference
    LO_CONTEXT        TYPE REF TO CL_BEA_CONTEXT_PPF,
    LS_CONTEXT        TYPE REF TO CL_BEA_CONTEXT_PPF,
    LT_CONTEXT        TYPE BEAT_PPF_CONTEXT,

*   partner reference
    LO_PARTNER        TYPE REF TO CL_BEA_PARTNER_PPF,
*   partner collection reference
    LO_PARTNER_COLL   TYPE REF TO CL_PARTNER_COLL_PPF,

*   PPF-manager reference
    LO_MANAGER        TYPE REF TO CL_MANAGER_PPF,

*   partner table for head of billing document
    LT_PARTNER        TYPE BEAT_PAR_WRK,
*   partner workarea for head of billing document
    LS_PARTNER        TYPE BEAS_PAR_WRK,

*   application key of billing document
    LV_APPLKEY        TYPE PPFDAPPKEY,

*   flag for determination protocol
    LV_NO_DETLOG      TYPE BEA_BOOLEAN
                      VALUE GC_TRUE.

* DEFINITION PART ----------------------------------------------------

  CLASS CA_BEA_PPF DEFINITION LOAD.

* IMPLEMENTATION PART ------------------------------------------------

  CL_MANAGER_PPF=>LOCALE_UPDATE = GC_PPF_UPDATE_TASK.

* get manager instance
  LO_MANAGER = CL_MANAGER_PPF=>GET_INSTANCE( ).

* set key fields of application
  IF IS_BDH-UPD_TYPE = GC_INSERT.

      LO_APPL_OBJECT =
        CA_BEA_PPF=>AGENT->CREATE_PERSISTENT( IS_BDH-BDH_GUID ).

      LO_APPL_OBJECT->SET_BEA_NAME( IS_BTY-APPLICATION ).

  ELSE.
    TRY.

        LO_APPL_OBJECT =
          CA_BEA_PPF=>AGENT->GET_PERSISTENT( IS_BDH-BDH_GUID ).

      CATCH CX_OS_OBJECT_NOT_FOUND.

        LO_APPL_OBJECT =
          CA_BEA_PPF=>AGENT->CREATE_PERSISTENT( IS_BDH-BDH_GUID ).

        LO_APPL_OBJECT->SET_BEA_NAME( IS_BTY-APPLICATION ).

    ENDTRY.

  ENDIF.

* create partner collection
  CREATE OBJECT LO_PARTNER_COLL.

* begin of partner processing
* get partnerset
  CALL FUNCTION 'BEA_PAR_O_GET'
    EXPORTING
      IV_PARSET_GUID = IS_BDH-PARSET_GUID
    IMPORTING
      ET_PAR         = LT_PARTNER
    EXCEPTIONS
      REJECT         = 1
      OTHERS         = 2.

  IF SY-SUBRC <> 0.

*   fill et_return
    MESSAGE ID     SY-MSGID
            TYPE   SY-MSGTY
            NUMBER SY-MSGNO
            WITH   SY-MSGV1 SY-MSGV2
                   SY-MSGV3 SY-MSGV4
            INTO   GV_DUMMY.

    PERFORM msg_add using space space space space CHANGING ET_RETURN.

*   raise partner_error
    MESSAGE ID      SY-MSGID
            TYPE    SY-MSGTY
            NUMBER  SY-MSGNO
            WITH    SY-MSGV1 SY-MSGV2
                    SY-MSGV3 SY-MSGV4
            RAISING PARTNER_ERROR.

  ENDIF.

* loop:     read partner from partner set,
*           create partner object and
*           add to partner collection
  LOOP AT LT_PARTNER INTO LS_PARTNER.

*   create a partner object
    CREATE OBJECT LO_PARTNER
       EXPORTING
          IP_PARTNER_ROLE   = LS_PARTNER-PARTNER_FCT
          IP_PARTNER_NO     = LS_PARTNER-PARTNER_NO
          IP_PARTNER_TEXT   = ''
          IP_ZAV_ADDRESSNO  = LS_PARTNER-ADDR_NR
          IP_ZAV_PERSNO     = LS_PARTNER-ADDR_NP
          IP_ZAV_ADDR_TYPE  = LS_PARTNER-ADDR_TYPE.

*   add partner object to partner collection
    CALL METHOD LO_PARTNER_COLL->ADD_ELEMENT( LO_PARTNER ).

  ENDLOOP.
* end of partner processing

* create context
  IF IS_BTY-PPF_PROC IS NOT INITIAL.
    CREATE OBJECT LO_CONTEXT.

* set context attributes
    LO_CONTEXT->APPLCTN = gc_ppfappl.
    LO_CONTEXT->NAME    = IS_BTY-PPF_PROC.
    LO_CONTEXT->APPL    = LO_APPL_OBJECT.
    LO_CONTEXT->PARTNER = LO_PARTNER_COLL.


    LS_CONTEXT = LO_CONTEXT.
    APPEND LS_CONTEXT TO LT_CONTEXT.
  ENDIF.

* Enrich context data before start of action determination
* Event _PPF_C01
  INCLUDE %2f1BEA%2fX_CRMB_PPF_C01PPFAPD_E01.

* set application key for output in the actionlist
  CALL FUNCTION 'BEA_PPF_O_GET_APPLKEY'
    EXPORTING
      iv_application       = is_bty-application
      iv_headno_ext        = is_bdh-headno_ext
    IMPORTING
      ev_applkey           = lv_applkey.

 LOOP AT LT_CONTEXT INTO LS_CONTEXT.

* start action determination in PPF
   CALL METHOD LO_MANAGER->DETERMINE
     EXPORTING
       IO_CONTEXT   = LS_CONTEXT
       IP_NO_DETLOG = LV_NO_DETLOG.

   CALL METHOD LO_MANAGER->SET_APPLKEY
     EXPORTING
       IP_APPLKEY = LV_APPLKEY
       IO_CONTEXT = LS_CONTEXT.

   PERFORM ADD_CONTEXT_TO_BUFFER USING IS_BDH-BDH_GUID
                                       LS_CONTEXT.

 ENDLOOP.


ENDFUNCTION.
*
*
*---------------------------------------------------------------------
* Form ADD_CONTEXT_TO_BUFFER
*---------------------------------------------------------------------
FORM ADD_CONTEXT_TO_BUFFER USING LV_BDH_GUID
                                 TYPE  BEA_BDH_GUID
                                 LV_CONTEXT
                                 TYPE REF TO CL_BEA_CONTEXT_PPF.
*
 DATA:
   LS_PPF_CONTEXT   TYPE GS_PPF_CONTEXT.


 LS_PPF_CONTEXT-BDH_GUID = LV_BDH_GUID.
 LS_PPF_CONTEXT-CONTEXT  = LV_CONTEXT.
 IF NOT GT_PPF_CONTEXT IS INITIAL.
   READ TABLE GT_PPF_CONTEXT WITH KEY  BDH_GUID = LV_BDH_GUID
                             CONTEXT = LV_CONTEXT
                             TRANSPORTING NO FIELDS.
   IF NOT SY-SUBRC IS INITIAL.
      INSERT LS_PPF_CONTEXT  INTO      GT_PPF_CONTEXT
                           INDEX     SY-TABIX.
   ENDIF.
  ELSE.
    APPEND LS_PPF_CONTEXT TO GT_PPF_CONTEXT.
  ENDIF.
ENDFORM.
