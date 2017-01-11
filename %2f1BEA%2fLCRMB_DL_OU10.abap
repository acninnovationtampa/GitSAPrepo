FUNCTION /1BEA/CRMB_DL_O_PROCESS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_COM
*"     REFERENCE(IT_CONDITION) TYPE  BEAT_DLI_PRC_COM OPTIONAL
*"     REFERENCE(IT_PARTNER) TYPE  BEAT_DLI_PAR_COM OPTIONAL
*"     REFERENCE(IT_TEXTHEAD) TYPE  BEAT_DLI_TXT_HEAD_COM OPTIONAL
*"     REFERENCE(IT_TEXTLINE) TYPE  BEAT_DLI_TXT_LINE_COM OPTIONAL
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"  EXPORTING
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
*====================================================================
* Definition part
*====================================================================
*--------------------------------------------------------------------
* Definition of local data
*--------------------------------------------------------------------
  DATA:
    LS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK       TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_DRV       TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_ITC           TYPE BEAS_ITC_WRK,
    LV_TABIX_DLI     TYPE SYTABIX,
    LS_DLI_COM       TYPE /1BEA/S_CRMB_DLI_COM,
    LS_DLI_INT       TYPE /1BEA/S_CRMB_DLI_INT,
    LT_CONDITION        TYPE BEAT_PRC_COM,
    LT_PARTNER        TYPE BEAT_PAR_COM,
    LT_TEXTLINE        TYPE COMT_TEXT_TEXTDATA_T,
    LT_DLI_CANCEL    TYPE BEAT_DLI_CANCEL,
    LT_RETURN        TYPE BEAT_RETURN,
    LT_RETURN_AL     TYPE BEAT_RETURN.
*==================================================================
* Implementation part
*==================================================================
*--------------------------------------------------------------------
* Initial processing
*--------------------------------------------------------------------
  BREAK-POINT ID BEA_DL.
  PERFORM INITIALIZE
    USING
      IV_PROCESS_MODE.
  LOOP AT IT_DLI INTO LS_DLI_COM.
    LV_TABIX_DLI = SY-TABIX.
    CLEAR:
      LT_RETURN,
      LT_RETURN_AL,
      LS_ITC,
      LS_DLI_INT,
      LT_DLI_DRV,
      LT_DLI_WRK.
    PERFORM PREPARE_SERVICES
      USING
        LS_DLI_COM
        IT_CONDITION
        IT_PARTNER
        IT_TEXTHEAD
        IT_TEXTLINE
      CHANGING
        LT_CONDITION
        LT_PARTNER
        LT_TEXTLINE
        LV_TABIX_DLI.
    PERFORM PREPARE_CREATE
      USING
        LS_DLI_COM
      CHANGING
        LS_DLI_INT
        LT_PARTNER
        LS_ITC
        LT_RETURN.
    PERFORM GET
      CHANGING
        LS_DLI_INT
        LT_DLI_WRK
        LT_RETURN.
    CALL FUNCTION '/1BEA/CRMB_DL_O_CREATE'
      EXPORTING
           IS_DLI_INT      = LS_DLI_INT
           IT_DLI_WRK      = LT_DLI_WRK
           IT_CONDITION       = LT_CONDITION
           IT_PARTNER       = LT_PARTNER
           IT_TEXTLINE       = LT_TEXTLINE
           IT_RETURN       = LT_RETURN
      IMPORTING
           ES_DLI_WRK      = LS_DLI_WRK
           ET_RETURN       = LT_RETURN_AL.

    CALL FUNCTION '/1BEA/CRMB_DL_O_DERIVE'
      EXPORTING
           IS_DLI_INT      = LS_DLI_INT
           IS_DLI_WRK      = LS_DLI_WRK
           IT_DLI_WRK      = LT_DLI_WRK
           IT_CONDITION       = LT_CONDITION
           IT_PARTNER       = LT_PARTNER
           IT_TEXTLINE       = LT_TEXTLINE
      IMPORTING
           ET_DLI_WRK      = LT_DLI_DRV
           ET_RETURN       = LT_RETURN_AL.
    INSERT LINES OF LT_DLI_DRV INTO TABLE LT_DLI_WRK.
    CLEAR LT_RETURN.
    PERFORM PREPARE_REJECT
      USING
        LS_DLI_COM
        LS_DLI_WRK
        LS_ITC
        LT_DLI_WRK
        LV_TABIX_DLI
      CHANGING
        LT_DLI_CANCEL
        LT_RETURN.
*   final handling of error messages
    PERFORM AL_CREATE
      CHANGING
        LS_DLI_WRK
        LT_RETURN.
    INSERT LINES OF LT_RETURN INTO TABLE LT_RETURN_AL.
    PERFORM ROW_UPD_AND_APP_TO_BEATRETURN
      USING
        GC_BAPI_PAR_DLI LV_TABIX_DLI LT_RETURN_AL LS_DLI_WRK
      CHANGING
        ET_RETURN.
  ENDLOOP.
*--------------------------------------------------------------------
* Final processing
*--------------------------------------------------------------------
* Cancel Invoice
  IF NOT LT_DLI_CANCEL IS INITIAL.
    CLEAR LT_RETURN.
    PERFORM BD_REJECT
      USING
        LT_DLI_CANCEL
        IV_PROCESS_MODE
      CHANGING
        LT_RETURN.
    APPEND LINES OF LT_RETURN TO ET_RETURN.
  ENDIF.

* Event DL_OPRO0
    INCLUDE %2f1BEA%2fX_CRMBDL_OPRO0DRBODL_PRO.

  IF IV_PROCESS_MODE = GC_PROC_ADD.
    CALL FUNCTION '/1BEA/CRMB_DL_O_SAVE'
      EXPORTING
        IV_COMMIT_FLAG = IV_COMMIT_FLAG.
  ENDIF.
  IF IV_PROCESS_MODE = GC_PROC_TEST.
    CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
  ENDIF.
ENDFUNCTION.
*-----------------------------------------------------------------*
*     FORM Initialize
*-----------------------------------------------------------------*
*     Refresh buffer depending on process mode
*-----------------------------------------------------------------*
FORM INITIALIZE
  USING
    UV_PROCESS_MODE TYPE BEA_PROCESS_MODE.
  IF NOT UV_PROCESS_MODE = GC_PROC_NOADD.
    CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'.
  ENDIF.
ENDFORM.                    "initialize
*-----------------------------------------------------------------*
*     FORM Item_Category_Derive
*-----------------------------------------------------------------*
*     Derive item category from data provided by the
*     source application
*-----------------------------------------------------------------*
FORM ITEM_CATEGORY_DERIVE
  USING
    US_DLI_COM       TYPE /1BEA/S_CRMB_DLI_COM
  CHANGING
    CV_ITEM_CATEGORY TYPE BEA_ITEM_CATEGORY
    CT_RETURN        TYPE BEAT_RETURN
    CV_RETURNCODE    TYPE SYSUBRC.

  DATA:
    LS_ITC_WRK          TYPE  BEAS_ITC_WRK,
    LS_DLI_WRK          TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_SRC_PROCESS_TYPE TYPE BEA_SRC_PROCESS_TYPE,
    LV_SRC_ITEM_CAT     TYPE BEA_SRC_ITEM_CATEGORY.

  MOVE-CORRESPONDING US_DLI_COM TO LS_DLI_WRK.


  CV_ITEM_CATEGORY = LS_DLI_WRK-ITEM_CATEGORY.
  IF CV_ITEM_CATEGORY IS INITIAL.
    LV_SRC_PROCESS_TYPE = LS_DLI_WRK-SRC_PROCESS_TYPE.
    LV_SRC_ITEM_CAT     = LS_DLI_WRK-SRC_ITEM_TYPE.
    CALL FUNCTION 'BEA_ITC_DET_O_DERIVE'
      EXPORTING
        IV_APPLICATION       = GC_APPL
        IV_SRC_PROCESS_TYPE  = LV_SRC_PROCESS_TYPE
        IV_SRC_ITEM_CAT      = LV_SRC_ITEM_CAT
      IMPORTING
        EV_ITEM_CATEGORY     = CV_ITEM_CATEGORY.
  ENDIF.
  IF CV_ITEM_CATEGORY IS INITIAL.
    MESSAGE E551(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                      INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
    CV_RETURNCODE = 1.
    RETURN.
  ENDIF.
ENDFORM.                    "item_category_derive
*-----------------------------------------------------------------*
*       FORM GET
*-----------------------------------------------------------------*
*       Find all previous changeable duelist items
*       belonging to the same source object
*       and call ENQUEUE
*-----------------------------------------------------------------*
FORM GET
  CHANGING
    CS_DLI_INT        TYPE /1BEA/S_CRMB_DLI_INT
    CT_DLI_WRK        TYPE /1BEA/T_CRMB_DLI_WRK
    CT_RETURN         TYPE BEAT_RETURN.

  STATICS:
    LV_UPD_DRV      TYPE BEA_BOOLEAN,
    LV_ENQUEUED     TYPE BEA_BOOLEAN,
    LS_DLI_HEAD     TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID,
    LS_RETURN       TYPE BEAS_RETURN.
  DATA:
    LV_SORTREL      TYPE  BEA_SORTREL,
    LT_DLI_WRK      TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_WRK      TYPE /1BEA/S_CRMB_DLI_WRK,
    LRS_LOGSYS    TYPE /1BEA/RS_CRMB_LOGSYS,
    LRT_LOGSYS    TYPE /1BEA/RT_CRMB_LOGSYS,
    LRS_OBJTYPE    TYPE /1BEA/RS_CRMB_OBJTYPE,
    LRT_OBJTYPE    TYPE /1BEA/RT_CRMB_OBJTYPE,
    LRS_SRC_HEADNO    TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    LRT_SRC_HEADNO    TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    LV_READ_BY_INT_ID TYPE BEA_BOOLEAN.

  CHECK: CS_DLI_INT-SRC_ACTIVITY <> GC_SRC_ACTIVITY_INSERT.
  CLEAR SY-SUBRC.
  CLEAR LS_DLI_HEAD.
  MOVE-CORRESPONDING CS_DLI_INT TO LS_DLI_HEAD.
  IF LS_DLI_HEAD <> GS_SRC_HID.
    GS_SRC_HID = LS_DLI_HEAD.
    CLEAR:
      LV_ENQUEUED,
      LV_UPD_DRV,
      GT_DLI_DOC,
      LS_RETURN.
    LS_DLI_WRK-LOGSYS = CS_DLI_INT-LOGSYS.
    LS_DLI_WRK-OBJTYPE = CS_DLI_INT-OBJTYPE.
    LS_DLI_WRK-SRC_HEADNO = CS_DLI_INT-SRC_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_ENQUEUE'
      EXPORTING
        IS_DLI_WRK = LS_DLI_WRK
      IMPORTING
        ES_RETURN  = LS_RETURN.
    IF LS_RETURN IS INITIAL.
      LV_SORTREL = GC_SORT_BY_EXTERNAL_REF.
      IF CS_DLI_INT-BILL_RELEVANCE_C = GC_BILL_REL_LEAN OR
         CS_DLI_INT-BILL_RELEVANCE_C = GC_BILL_REL_BILLREQ_I.
        LV_SORTREL = GC_SORT_BY_EXT_GUID_REF.
      ENDIF.
      LRS_LOGSYS-SIGN   = GC_INCLUDE.
      LRS_LOGSYS-OPTION = GC_EQUAL.
      LRS_LOGSYS-LOW    = CS_DLI_INT-LOGSYS.
      APPEND LRS_LOGSYS TO LRT_LOGSYS.
      LRS_OBJTYPE-SIGN   = GC_INCLUDE.
      LRS_OBJTYPE-OPTION = GC_EQUAL.
      LRS_OBJTYPE-LOW    = CS_DLI_INT-OBJTYPE.
      APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
      LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
      LRS_SRC_HEADNO-OPTION = GC_EQUAL.
      LRS_SRC_HEADNO-LOW    = CS_DLI_INT-SRC_HEADNO.
      APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
      CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
        EXPORTING
          IV_SORTREL     = LV_SORTREL
          IRT_LOGSYS = LRT_LOGSYS
          IRT_OBJTYPE = LRT_OBJTYPE
          IRT_SRC_HEADNO = LRT_SRC_HEADNO
      IMPORTING
          ET_DLI         = GT_DLI_DOC.
    ELSE.
      LV_ENQUEUED = GC_TRUE.
    ENDIF.
  ENDIF.
  IF NOT LV_ENQUEUED IS INITIAL.
    CS_DLI_INT-INCOMP_ID = GC_INCOMP_ENQ.
    LS_DLI_WRK-LOGSYS = CS_DLI_INT-LOGSYS.
    LS_DLI_WRK-OBJTYPE = CS_DLI_INT-OBJTYPE.
    LS_DLI_WRK-SRC_HEADNO = CS_DLI_INT-SRC_HEADNO.
    LS_DLI_WRK-SRC_ITEMNO = CS_DLI_INT-SRC_ITEMNO.
    MESSAGE ID LS_RETURN-ID TYPE LS_RETURN-TYPE
            NUMBER LS_RETURN-NUMBER
            WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2
                 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
            INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = LS_DLI_WRK
        IT_RETURN      = CT_RETURN
      IMPORTING
        ET_RETURN      = CT_RETURN.
    RETURN. "from form
  ENDIF.

* Event DL_OCRE5
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE5DRVODL_GET.
    INCLUDE %2f1BEA%2fX_CRMBDL_OCRE5SRFODL_GET.

  IF LV_READ_BY_INT_ID IS INITIAL.
    LOOP AT GT_DLI_DOC INTO LS_DLI_WRK WHERE
               DERIV_CATEGORY = CS_DLI_INT-DERIV_CATEGORY AND
               LOGSYS = CS_DLI_INT-LOGSYS AND
               OBJTYPE = CS_DLI_INT-OBJTYPE AND
               SRC_HEADNO = CS_DLI_INT-SRC_HEADNO AND
               SRC_ITEMNO = CS_DLI_INT-SRC_ITEMNO.
      INSERT LS_DLI_WRK INTO TABLE LT_DLI_WRK.
    ENDLOOP.
  ENDIF.
  CALL FUNCTION '/1BEA/CRMB_DL_O_GET_CHANGEABL'
       EXPORTING
         IT_DLI               = LT_DLI_WRK
       IMPORTING
         ET_DLI_WRK           = CT_DLI_WRK.
ENDFORM. "Form GET
*-----------------------------------------------------------------*
*       FORM PREPARE_CREATE
*-----------------------------------------------------------------*
*       Create new duelist item from the data sent by the
*       source application
*-----------------------------------------------------------------*
FORM PREPARE_CREATE
  USING
    US_DLI_COM    TYPE /1BEA/S_CRMB_DLI_COM
  CHANGING
    CS_DLI_INT    TYPE /1BEA/S_CRMB_DLI_INT
    CT_PARTNER    TYPE BEAT_PAR_COM
    CS_ITC        TYPE BEAS_ITC_WRK
    CT_RETURN     TYPE BEAT_RETURN.

  DATA:
    LV_RETURNCODE       TYPE SYSUBRC.

  PERFORM ITEM_CATEGORY_DERIVE
    USING
      US_DLI_COM
    CHANGING
      CS_DLI_INT-ITEM_CATEGORY
      CT_RETURN
      LV_RETURNCODE.
  MOVE-CORRESPONDING US_DLI_COM TO CS_DLI_INT.

  IF NOT LV_RETURNCODE IS INITIAL.
    CS_DLI_INT-INCOMP_ID = GC_INCOMP_ERROR.
  ENDIF.

ENDFORM.                    "prepare_create
*-----------------------------------------------------------------*
*       FORM PREPARE_REJECT
*-----------------------------------------------------------------*
*       Update billed duelist items whose invoice might still
*       be cancelled. Then, after a cancellation of the invoice,
*       the new invoice will be created from the updated data, i.e.
*       with the most recent data sent from the source application.
*-----------------------------------------------------------------*
FORM PREPARE_REJECT
    USING
      US_DLI_COM       TYPE /1BEA/S_CRMB_DLI_COM
      US_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK
      US_ITC           TYPE BEAS_ITC_WRK
      UT_DLI           TYPE /1BEA/T_CRMB_DLI_WRK
      UV_TABIX_DLI     TYPE SY-TABIX
    CHANGING
      CT_DLI_CANCEL    TYPE BEAT_DLI_CANCEL
      CT_RETURN        TYPE BEAT_RETURN.
  DATA:
    LRS_BDH_GUID        TYPE BEARS_BDH_GUID,
    LRT_BDH_GUID        TYPE BEART_BDH_GUID,
    LRS_SRC_GUID        TYPE BEARS_BDI_GUID,
    LRT_SRC_GUID        TYPE BEART_BDI_GUID,
    LRS_ITEM_TYPE       TYPE BEARS_ITEM_TYPE,
    LRT_ITEM_TYPE       TYPE BEART_ITEM_TYPE,
    LS_DLI_WRK          TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_CANCEL       TYPE BEAS_DLI_CANCEL,
    LS_BDI              TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI              TYPE /1BEA/T_CRMB_BDI_WRK.

  CHECK NOT US_DLI_COM-SRC_REJECT IS INITIAL.
  CHECK US_DLI_COM-SRC_REJECT NE GC_SRC_REJECT_OPEN.
  LOOP AT UT_DLI INTO LS_DLI_WRK
                 WHERE BILL_STATUS = GC_BILLSTAT_DONE.
*....................................................................
* Read the Invoice Item and prepare the CANCEL
*....................................................................
    CLEAR LS_BDI.
    CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETDTL'
      EXPORTING
        IV_BDI_GUID       = LS_DLI_WRK-BDI_GUID
      IMPORTING
        ES_BDI            = LS_BDI.
    IF LS_BDI IS INITIAL.
      MESSAGE E229(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                        INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
        EXPORTING
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = LS_DLI_WRK
          IT_RETURN      = CT_RETURN
          IV_TABIX       = UV_TABIX_DLI
        IMPORTING
          ET_RETURN      = CT_RETURN.
      LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
    ENDIF.
    CLEAR LS_DLI_CANCEL.
    LS_DLI_CANCEL-BD_GUIDS-BDH_GUID  = LS_BDI-BDH_GUID.
    LS_DLI_CANCEL-BD_GUIDS-BDI_GUID  = LS_DLI_WRK-BDI_GUID.
    LS_DLI_CANCEL-DLI_GUID           = US_DLI_WRK-DLI_GUID.
    LS_DLI_CANCEL-BILL_STATUS        = US_DLI_WRK-BILL_STATUS.
    LS_DLI_CANCEL-TABIX_DLI          = UV_TABIX_DLI.
    APPEND LS_DLI_CANCEL TO CT_DLI_CANCEL.
*   special handling for structure items
    IF LS_BDI-ITEM_TYPE = GC_ITEM_TYPE_STRUCT.
      LRS_BDH_GUID-SIGN   = GC_INCLUDE.
      LRS_BDH_GUID-OPTION = GC_EQUAL.
      LRS_BDH_GUID-LOW    = LS_BDI-BDH_GUID.
      APPEND LRS_BDH_GUID TO LRT_BDH_GUID.
      LRS_SRC_GUID-SIGN   = GC_INCLUDE.
      LRS_SRC_GUID-OPTION = GC_EQUAL.
      LRS_SRC_GUID-LOW    = LS_BDI-SRC_GUID.
      APPEND LRS_SRC_GUID TO LRT_SRC_GUID.
      LRS_ITEM_TYPE-SIGN   = GC_EXCLUDE.
      LRS_ITEM_TYPE-OPTION = GC_EQUAL.
      LRS_ITEM_TYPE-LOW    = GC_ITEM_TYPE_STRUCT.
      APPEND LRS_ITEM_TYPE TO LRT_ITEM_TYPE.
      CALL FUNCTION '/1BEA/CRMB_BD_O_BDIGETLIST'
        EXPORTING
          IRT_BDH_GUID      = LRT_BDH_GUID
          IRT_SRC_GUID      = LRT_SRC_GUID
          IRT_ITEM_TYPE     = LRT_ITEM_TYPE
        IMPORTING
          ET_BDI            = LT_BDI.
      READ TABLE LT_BDI INTO LS_BDI INDEX 1.
      IF SY-SUBRC IS INITIAL.
        CLEAR LS_DLI_CANCEL.
        LS_DLI_CANCEL-BD_GUIDS-BDH_GUID  = LS_BDI-BDH_GUID.
        LS_DLI_CANCEL-BD_GUIDS-BDI_GUID  = LS_BDI-BDI_GUID.
        LS_DLI_CANCEL-DLI_GUID           = US_DLI_WRK-DLI_GUID.
        LS_DLI_CANCEL-BILL_STATUS        = US_DLI_WRK-BILL_STATUS.
        LS_DLI_CANCEL-TABIX_DLI          = UV_TABIX_DLI.
        APPEND LS_DLI_CANCEL TO CT_DLI_CANCEL.
      ELSE.
        MESSAGE E259(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                          INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
          EXPORTING
            IV_CONTAINER   = 'DLI'
            IS_DLI_WRK     = LS_DLI_WRK
            IT_RETURN      = CT_RETURN
            IV_TABIX       = UV_TABIX_DLI
          IMPORTING
            ET_RETURN      = CT_RETURN.
        LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "prepare_reject
*--------------------------------------------------------------------*
*      Form  PREPARE_SERVICES
*--------------------------------------------------------------------*
 FORM PREPARE_SERVICES
   USING
      US_DLI_COM   TYPE /1BEA/S_CRMB_DLI_COM
      UT_CONDITION    TYPE BEAT_DLI_PRC_COM
      UT_PARTNER    TYPE BEAT_DLI_PAR_COM
      UT_TEXTHEAD    TYPE BEAT_DLI_TXT_HEAD_COM
      UT_TEXTLINE    TYPE BEAT_DLI_TXT_LINE_COM
   CHANGING
     CT_CONDITION     TYPE BEAT_PRC_COM
     CT_PARTNER     TYPE BEAT_PAR_COM
     CT_TEXTLINE     TYPE COMT_TEXT_TEXTDATA_T
     CV_TABIX_DLI  TYPE SYTABIX.

* Event DL_OCRE0
  INCLUDE %2f1BEA%2fX_CRMBDL_OCRE0PARODL_000.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCRE0PRCODL_000.
  INCLUDE %2f1BEA%2fX_CRMBDL_OCRE0TXTODL_000.

 ENDFORM.              "PREPARE_SERVICES
*-----------------------------------------------------------------*
*       FORM BD_REJECT
*-----------------------------------------------------------------*
FORM BD_REJECT
  USING
    UT_DLI_CANCEL   TYPE BEAT_DLI_CANCEL
    UV_PROCESS_MODE TYPE BEA_PROCESS_MODE
  CHANGING
    CT_RETURN       TYPE BEAT_RETURN.

  DATA:
    LS_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK         TYPE /1BEA/T_CRMB_DLI_WRK,
    LT_DLI_WRK_UPD     TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_CANCEL      TYPE BEAS_DLI_CANCEL,
    LT_DLI_CANCEL_UPD  TYPE BEAT_DLI_CANCEL,
    LS_BD_GUIDS        TYPE BEAS_BD_GUIDS,
    LT_BD_GUIDS        TYPE BEAT_BD_GUIDS,
    LS_RETURN          TYPE BEAS_RETURN,
    LT_RETURN          TYPE BEAT_RETURN,
    LT_RETURN_CANCEL   TYPE BEAT_RETURN.

  CLEAR LT_RETURN_CANCEL.
  LOOP AT UT_DLI_CANCEL INTO LS_DLI_CANCEL.
    MOVE LS_DLI_CANCEL-BD_GUIDS TO LS_BD_GUIDS.
    APPEND LS_BD_GUIDS TO LT_BD_GUIDS.
  ENDLOOP.

  CALL FUNCTION '/1BEA/CRMB_BD_O_CANCEL'
    EXPORTING
      IT_BD_GUIDS         = LT_BD_GUIDS
      IV_CAUSE            = GC_CAUSE_REJ_NEW
      IV_PROCESS_MODE     = UV_PROCESS_MODE
      IV_COMMIT_FLAG      = GC_NOCOMMIT
    IMPORTING
      ET_RETURN           = LT_RETURN_CANCEL.

  IF NOT LT_RETURN_CANCEL IS INITIAL.  " error in cancel -> find DLI
    LOOP AT LT_RETURN_CANCEL INTO LS_RETURN.
      CASE LS_RETURN-CONTAINER.
        WHEN 'BDH'.
          READ TABLE LT_DLI_CANCEL_UPD
               WITH KEY BD_GUIDS-BDH_GUID = LS_RETURN-OBJECT_GUID
               TRANSPORTING NO FIELDS.
          IF NOT SY-SUBRC = 0.
            LOOP AT UT_DLI_CANCEL INTO LS_DLI_CANCEL
                 WHERE BD_GUIDS-BDH_GUID = LS_RETURN-OBJECT_GUID.
              APPEND LS_DLI_CANCEL TO LT_DLI_CANCEL_UPD.
            ENDLOOP.
          ENDIF.
        WHEN 'BDI'.
          READ TABLE LT_DLI_CANCEL_UPD
               WITH KEY BD_GUIDS-BDI_GUID = LS_RETURN-OBJECT_GUID
               TRANSPORTING NO FIELDS.
          IF NOT SY-SUBRC = 0.
            LOOP AT UT_DLI_CANCEL INTO LS_DLI_CANCEL
                 WHERE BD_GUIDS-BDI_GUID = LS_RETURN-OBJECT_GUID.
              APPEND LS_DLI_CANCEL TO LT_DLI_CANCEL_UPD.
            ENDLOOP.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    LT_DLI_WRK = GT_DLI_WRK.
    LOOP AT LT_DLI_CANCEL_UPD INTO LS_DLI_CANCEL.
      READ TABLE LT_DLI_WRK_UPD
                            WITH KEY DLI_GUID = LS_DLI_CANCEL-DLI_GUID
                            TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC = 0.
        LOOP AT LT_DLI_WRK INTO LS_DLI_WRK
                           WHERE DLI_GUID = LS_DLI_CANCEL-DLI_GUID.
          APPEND LS_DLI_WRK TO LT_DLI_WRK_UPD.
          MESSAGE E561(BEA) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                            INTO GV_DUMMY.
          CLEAR LT_RETURN.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = LS_DLI_WRK
              IT_RETURN      = LT_RETURN
              IV_TABIX       = LS_DLI_CANCEL-TABIX_DLI
            IMPORTING
              ET_RETURN      = LT_RETURN.
          PERFORM AL_CREATE
            CHANGING
              LS_DLI_WRK
              LT_RETURN.
          APPEND LINES OF LT_RETURN TO CT_RETURN.
          CLEAR LT_RETURN.

* transfer the BD cancellation error message into DL message container
* so that the error message from BD cancellation could be displayed with the incomplete due list item
          CLEAR ls_return.
          READ TABLE lt_return_cancel WITH KEY OBJECT_GUID = ls_dli_cancel-bd_guids-bdh_guid
            INTO ls_return.
          IF sy-subrc <> 0.
*             error is not coming from bdh, but bdi
            READ TABLE lt_return_cancel WITH KEY object_guid = ls_dli_cancel-bd_guids-bdi_guid
              INTO ls_return.
            CHECK sy-subrc = 0 AND ls_return IS NOT INITIAL.
*             skip the rest if error message couldn't be found in lt_return_cancel
          ENDIF.
          MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
                  WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
                  INTO gv_dummy.
          CLEAR LT_RETURN.
          CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
            EXPORTING
              IV_CONTAINER   = 'DLI'
              IS_DLI_WRK     = LS_DLI_WRK
              IT_RETURN      = LT_RETURN
              IV_TABIX       = LS_DLI_CANCEL-TABIX_DLI
            IMPORTING
              ET_RETURN      = LT_RETURN.
          PERFORM AL_CREATE
            CHANGING
              LS_DLI_WRK
              LT_RETURN.
          APPEND LINES OF LT_RETURN TO CT_RETURN.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
      CALL FUNCTION '/1BEA/CRMB_DL_O_BUFFER_MODIFY'
        EXPORTING
          IT_DLI_WRK     = LT_DLI_WRK_UPD
          IV_BILL_STATUS = GC_BILLSTAT_TODO
          IV_INCOMP_ID   = GC_INCOMP_ERROR.

  ENDIF.

ENDFORM.                              "BD_REJECT

* Event DL_OPROZ
    INCLUDE %2f1BEA%2fX_CRMBDL_OPROZDRBODL_PRZ.
