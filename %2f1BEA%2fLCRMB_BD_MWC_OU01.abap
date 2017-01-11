FUNCTION /1BEA/CRMB_BD_MWC_O_1O_UPDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
  CONSTANTS:
    LC_BDOC_TYPE    TYPE SMOG_GNAME    VALUE 'BEABILLDOCCRMB',
    LC_QNAME_PRE    TYPE char14        value 'CSA_BEACRMB_BD'.
  DATA:
    LS_BDOC         TYPE /1BEA/BS_CRMB_BD,
    LT_BDH_WRK      TYPE HASHED TABLE OF /1BEA/S_CRMB_BDH_WRK
                         with unique key bdh_guid,
    LS_BDH          TYPE /1BEA/S_CRMB_BDH,
    LT_BDH          TYPE SORTED TABLE OF /1BEA/S_CRMB_BDH
                         with unique key bdh_guid,
    LT_BDI_WRK      TYPE /1BEA/T_CRMB_BDI_WRK,
*   different sorting for delivery related billing
    LT_BDI_WRK2     TYPE tt_bdi_wrk2,
    LS_BDI          TYPE /1BEA/S_CRMB_BDI,
    LT_BDI          TYPE /1BEA/T_CRMB_BDI,
    LV_TABIX        TYPE SYTABIX,
    LRS_SRC_GUID    TYPE /1BEA/RS_CRMB_SRC_GUID,
    LRT_SRC_GUID    TYPE /1BEA/RT_CRMB_SRC_GUID,
    LS_TRANS_MSG    TYPE /1CRMG0/BEAS_BDOC_HEADER001,
    LS_TRANS_DOC    TYPE /1CRMG0/BEAS_BILLING_DOCUM001,
    LV_TRANS_MSG    TYPE /1CRMG0/BEABILLDOCCRMB,
    LS_BDOC_HEAD    TYPE SMW3_FHD,
    LV_QUEUE_NO     TYPE QFRANINT,
    LV_QUEUE_C      TYPE NUMC10,
    LV_MAX_QUEUES   TYPE QFRANINT,
    LV_NOSEND       TYPE C VALUE IS INITIAL,
    LV_DO_INDEX     TYPE SYINDEX,
    LV_ITEM_COUNT   TYPE I,
    LV_LAST_HEADNO  TYPE BEA_SRC_HEADNO,
    LV_RFC_QNAME    TYPE trfcqnam.

  FIELD-SYMBOLS:
    <FS_BDH>        TYPE /1BEA/S_CRMB_BDH,
    <FS_BDH_WRK>    TYPE /1BEA/S_CRMB_BDH_WRK,
    <FS_BDI_WRK>    TYPE /1BEA/S_CRMB_BDI_WRK,
    <lv_src_headno> TYPE bea_src_headno.

*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
  BREAK-POINT ID BEA_BD.

  CHECK GS_MWC_PARAM-PROCESS_TIME IS INITIAL.

  LRS_SRC_GUID-SIGN   = GC_INCLUDE.
  LRS_SRC_GUID-OPTION = GC_RANGEOPTION_EQ.
*---------------------------------------------------------------------
* BDOC CLASSICAL PART - HEADER SEGMENT
*---------------------------------------------------------------------
  LS_TRANS_MSG-APPL   = GC_APPL.
  LS_TRANS_MSG-OBJ    = GC_OBJ.

  LT_BDI_WRK = IT_BDI.
  LT_BDH_WRK = IT_BDH.
  SORT LT_BDI_WRK BY LOGSYS OBJTYPE SRC_HEADNO.

  DO 2 TIMES.
    IF SY-INDEX = 2.
      LV_DO_INDEX = SY-INDEX.
      PERFORM COMPLETE_P_SRC_HEADNO
        USING
          LRT_SRC_GUID
        CHANGING
          LT_BDI_WRK2.
      LT_BDI_WRK = LT_BDI_WRK2.
      IF LT_BDI_WRK IS INITIAL.
        EXIT.
      ENDIF.
      CLEAR:
        LV_TRANS_MSG,
        LRT_SRC_GUID,
        LS_BDOC,
        LT_BDI,
        LT_BDH,
        LV_ITEM_COUNT.
    ENDIF.
    LOOP AT LT_BDI_WRK ASSIGNING <FS_BDI_WRK>.
      IF LV_DO_INDEX < 2.
        ASSIGN COMPONENT 'SRC_HEADNO' OF STRUCTURE <FS_BDI_WRK> TO <lv_src_headno>.
      ELSE.
        ASSIGN COMPONENT 'P_SRC_HEADNO_D' OF STRUCTURE <FS_BDI_WRK> TO <lv_src_headno>.
      ENDIF.
      CHECK SY-SUBRC = 0.
      READ TABLE LT_BDH_WRK ASSIGNING <FS_BDH_WRK>
                        WITH KEY BDH_GUID = <FS_BDI_WRK>-BDH_GUID.
      CHECK SY-SUBRC = 0.
      CHECK <FS_BDH_WRK>-MWC_ERROR = SPACE.
      CHECK <FS_BDH_WRK>-PRICING_ERROR <> GC_PRC_ERR_F AND
            <FS_BDH_WRK>-PRICING_ERROR <> GC_PRC_ERR_C.

      IF ( <FS_BDI_WRK>-BILL_RELEVANCE = gc_bill_rel_delivery OR
           <FS_BDI_WRK>-BILL_RELEVANCE = gc_bill_rel_deliv_ic OR
           <FS_BDI_WRK>-BILL_RELEVANCE = gc_bill_rel_dlv_tpop OR
           ( <FS_BDI_WRK>-BILL_RELEVANCE IS INITIAL AND
             <FS_BDI_WRK>-OBJTYPE = 'LIKP' ) ) "for compatibility reasons
         AND LV_DO_INDEX <> 2.
*       different handling for deliveries and corresponding Sales Orders
        INSERT <FS_BDI_WRK> INTO TABLE LT_BDI_WRK2.
        IF <FS_BDI_WRK>-P_SRC_HEADNO_D IS INITIAL.
          LRS_SRC_GUID-LOW = <FS_BDI_WRK>-SRC_GUID.
          APPEND LRS_SRC_GUID TO LRT_SRC_GUID.
        ENDIF.
        CONTINUE.
      ENDIF.
*---------------------------------------------------------------------
*       GENERATE BDOC MESSAGE IF THREASHOLD IS REACHED
*---------------------------------------------------------------------
      IF LV_ITEM_COUNT >= GV_MAX_ITEMS.
        IF LV_LAST_HEADNO IS NOT INITIAL AND
           LV_LAST_HEADNO <> <LV_SRC_HEADNO>.
          CALL FUNCTION 'GUID_CREATE'
            IMPORTING
              EV_GUID_16 = LS_TRANS_MSG-GUID.

          LOOP AT LT_BDH ASSIGNING <FS_BDH>.
            CLEAR LS_TRANS_DOC.
*---------------------------------------------------------------------
*           BDOC CLASSICAL PART - DOC SEGMENT
*---------------------------------------------------------------------
            MOVE-CORRESPONDING <FS_BDH> TO LS_TRANS_DOC.
            LS_TRANS_DOC-GUID = LS_TRANS_MSG-GUID.
            INSERT LS_TRANS_DOC INTO TABLE LV_TRANS_MSG-BEA_BILLING_DOCUMENTS.
            INSERT <FS_BDH> INTO TABLE ls_bdoc-document_bdh.
          ENDLOOP.
*---------------------------------------------------------------------
*         BDOC MESSAGE - DOCUMENT HEADER
*---------------------------------------------------------------------
          INSERT LS_TRANS_MSG INTO TABLE LV_TRANS_MSG-BEA_BDOC_HEADER.
          INSERT LINES OF LT_BDI INTO TABLE ls_bdoc-document_bdi.

*       validation flow - send message to source applications
          CLEAR LS_BDOC_HEAD.
          CALL METHOD CL_SMW_MFLOW=>SET_HEADER_FIELDS
            EXPORTING
              IN_BDOC_TYPE   = LC_BDOC_TYPE
            IMPORTING
              OUT_HEADER     = LS_BDOC_HEAD.
*        Set qname for qRFC
          LV_QUEUE_C = LV_LAST_HEADNO.
          CONCATENATE LC_QNAME_PRE LV_QUEUE_C INTO LV_RFC_QNAME.
          CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
            EXPORTING
            qname              = lv_rfc_qname
            nosend             = lv_nosend
          EXCEPTIONS
            invalid_queue_name = 0
            OTHERS             = 0.
          CALL FUNCTION '/1BEA/CRMB_BD_MWC_O_VALIDATE' IN BACKGROUND TASK
            AS SEPARATE UNIT
            EXPORTING
              IS_BDOC_HEADER        = LS_BDOC_HEAD
              IS_MESSAGE            = LV_TRANS_MSG
              IS_MESSAGE_EXT        = LS_BDOC.

          PERFORM COMPLETE_P_SRC_HEADNO
            USING
              LRT_SRC_GUID
            CHANGING
              LT_BDI_WRK2.
          CLEAR:
            LV_TRANS_MSG,
            LS_BDOC,
            LT_BDI,
            LT_BDH,
            LRT_SRC_GUID,
            LV_ITEM_COUNT.
        ENDIF.
      ENDIF.
*     collect billing documents for mBDOC
      READ TABLE LT_BDH WITH KEY BDH_GUID = <FS_BDH_WRK>-BDH_GUID
                TRANSPORTING NO FIELDS.
      IF SY-SUBRC <> 0.
        CLEAR LS_BDH.
        MOVE-CORRESPONDING <FS_BDH_WRK> TO LS_BDH.
        INSERT LS_BDH INTO TABLE LT_BDH.
      ENDIF.
      clear ls_bdi.
      move-corresponding <fs_bdi_wrk> to ls_bdi.
      INSERT LS_BDI INTO TABLE LT_BDI.
*     control group changing
      ADD 1 TO LV_ITEM_COUNT.
      LV_LAST_HEADNO = <LV_SRC_HEADNO>.
    ENDLOOP.

*---------------------------------------------------------------------
* GENERATE LAST BDOC MESSAGE
*---------------------------------------------------------------------
    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        EV_GUID_16 = LS_TRANS_MSG-GUID.

    LOOP AT LT_BDH ASSIGNING <FS_BDH>.
      CLEAR LS_TRANS_DOC.
*---------------------------------------------------------------------
*   BDOC CLASSICAL PART - DOC SEGMENT
*---------------------------------------------------------------------
      MOVE-CORRESPONDING <FS_BDH> TO LS_TRANS_DOC.
      LS_TRANS_DOC-GUID = LS_TRANS_MSG-GUID.
      INSERT LS_TRANS_DOC INTO TABLE LV_TRANS_MSG-BEA_BILLING_DOCUMENTS.
      INSERT <FS_BDH> into table ls_bdoc-document_bdh.
    ENDLOOP.
*---------------------------------------------------------------------
*   BDOC MESSAGE - DOCUMENT HEADER
*---------------------------------------------------------------------
    INSERT LS_TRANS_MSG INTO TABLE LV_TRANS_MSG-BEA_BDOC_HEADER.
    INSERT LINES of lt_bdi INTO TABLE ls_bdoc-document_bdi.
    CHECK NOT LS_BDOC-DOCUMENT_BDH IS INITIAL.
*---------------------------------------------------------------------
* CALLING MIDDLEWARE-VALIDATION-FLOW FOR REMAINING TRANSACTIONS
*---------------------------------------------------------------------
*   validation flow - send message to source applications
    CLEAR LS_BDOC_HEAD.
    CALL METHOD CL_SMW_MFLOW=>SET_HEADER_FIELDS
      EXPORTING
        IN_BDOC_TYPE   = LC_BDOC_TYPE
      IMPORTING
        OUT_HEADER     = LS_BDOC_HEAD.
*   Set qname for qRFC
    LV_QUEUE_C = LV_LAST_HEADNO.
    CONCATENATE LC_QNAME_PRE LV_QUEUE_C INTO LV_RFC_QNAME.
    CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
      EXPORTING
        qname              = lv_rfc_qname
        nosend             = lv_nosend
      EXCEPTIONS
        invalid_queue_name = 0
        OTHERS             = 0.
    CALL FUNCTION '/1BEA/CRMB_BD_MWC_O_VALIDATE' IN BACKGROUND TASK
      AS SEPARATE UNIT
      EXPORTING
        IS_BDOC_HEADER        = LS_BDOC_HEAD
        IS_MESSAGE            = LV_TRANS_MSG
        IS_MESSAGE_EXT        = LS_BDOC.

  ENDDO.
*
ENDFUNCTION.

*---------------------------------------------------------------------
*       FORM COMPLETE_P_SRC_HEADNO
*---------------------------------------------------------------------
FORM COMPLETE_P_SRC_HEADNO
  USING
    IRT_SRC_GUID   TYPE /1BEA/RT_CRMB_SRC_GUID
  CHANGING
    CT_BDI_WRK     TYPE TT_BDI_WRK2.

DATA:
  LV_TABIX          TYPE SYTABIX,
  LV_P_SRC_HEADNO_D TYPE BEA_P_SRC_HEADNO,
  LRS_BILL_STATUS   TYPE BEARS_BILL_STATUS,
  LRT_BILL_STATUS   TYPE BEART_BILL_STATUS,
  LT_DLI_WRK        TYPE /1BEA/T_CRMB_DLI_WRK,
  LT_BDI_WRK        TYPE /1BEA/T_CRMB_BDI_WRK.

FIELD-SYMBOLS:
  <FS_DLI_WRK>     TYPE /1BEA/S_CRMB_DLI_WRK,
  <FS_BDI_WRK>     TYPE /1BEA/S_CRMB_BDI_WRK.

  CHECK NOT IRT_SRC_GUID IS INITIAL.
  LRS_BILL_STATUS-SIGN   = GC_INCLUDE.
  LRS_BILL_STATUS-OPTION = GC_EQUAL.
  LRS_BILL_STATUS-LOW    = GC_BILLSTAT_NO.
  APPEND LRS_BILL_STATUS TO LRT_BILL_STATUS.

  CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
    EXPORTING
      IRT_BILL_STATUS   = LRT_BILL_STATUS
      IRT_SRC_GUID      = IRT_SRC_GUID
    IMPORTING
      ET_DLI            = LT_DLI_WRK.

  READ TABLE CT_BDI_WRK TRANSPORTING NO FIELDS
         WITH KEY P_SRC_HEADNO_D = LV_P_SRC_HEADNO_D
         BINARY SEARCH.
  CHECK SY-SUBRC = 0.
  LV_TABIX = SY-TABIX.
  LT_BDI_WRK[] = CT_BDI_WRK[].
  CLEAR CT_BDI_WRK.
  LOOP AT LT_BDI_WRK ASSIGNING <FS_BDI_WRK>
        FROM  LV_TABIX
        WHERE P_SRC_HEADNO_D IS INITIAL.
    READ TABLE LT_DLI_WRK ASSIGNING <FS_DLI_WRK>
           WITH KEY SRC_GUID = <FS_BDI_WRK>-SRC_GUID.
    IF SY-SUBRC = 0.
      <FS_BDI_WRK>-P_SRC_HEADNO_D = <FS_DLI_WRK>-SRC_HEADNO.
    ENDIF.
  ENDLOOP.
  CT_BDI_WRK[] = LT_BDI_WRK[].

ENDFORM.
