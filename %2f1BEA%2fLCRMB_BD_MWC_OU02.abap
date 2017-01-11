FUNCTION /1BEA/CRMB_BD_MWC_O_FLOW.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
*"     REFERENCE(IT_ADD_CUM_DFL) TYPE  BEAT_CUM_DFL OPTIONAL
*"     VALUE(IV_NO_FLOW) TYPE  BEA_BOOLEAN DEFAULT SPACE
*"     VALUE(IV_NO_PRICING) TYPE  BEA_BOOLEAN DEFAULT SPACE
*"     VALUE(IV_MAX_NO_QUEUES) TYPE  QFRANINT DEFAULT 10
*"  EXPORTING
*"     REFERENCE(ES_BDOC) TYPE  /1BEA/BS_CRMB_BD
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
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
    LC_BDOC_TYPE   TYPE SMOG_GNAME    VALUE 'BEABILLDOCCRMB',
    LC_DOWNL_OBJ   TYPE SMO_OBJNAM    VALUE 'BEABILLDOCCRMB',
    LC_BDOC_TYPE_D TYPE SMOG_GNAME    VALUE 'BEABILLDLVCRMB',
    LC_DOWNL_OBJ_D TYPE SMO_OBJNAM    VALUE 'BEABILLDLVCRMB',
    LC_QNAME_PRE   TYPE char14        value 'CSA_BEACRMB_BD',
    LC_ERROR_PAR   TYPE BEA_MWC_ERROR VALUE 'A',
    LC_ERROR_PRC   TYPE BEA_MWC_ERROR VALUE 'B',
    LC_ERROR_TAX   TYPE BEA_MWC_ERROR VALUE 'C',
    LC_TECHERR     TYPE BEA_MWC_ERROR VALUE 'Y',
    LC_QRFC_IN_UPD TYPE C             VALUE 'X'.
  DATA:
    LS_BDOC        TYPE /1BEA/BS_CRMB_BD,
    LS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDH         TYPE /1BEA/S_CRMB_BDH,
    LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK,
    LS_BDI         TYPE /1BEA/S_CRMB_BDI,
    LT_BDI         TYPE /1BEA/T_CRMB_BDI,
    LS_TRANS_MSG   TYPE /1CRMG0/BEAS_BDOC_HEADER001,
    LS_TRANS_MSG_D TYPE /1CRMG0/BEA_BDOC_HEADER_ST002,
    LS_TRANS_DOC   TYPE /1CRMG0/BEAS_BILLING_DOCUM001,
    LS_TRANS_DOC_D TYPE /1CRMG0/BEA_BILLING_DOCUME002,
    LV_TRANS_MSG   TYPE /1CRMG0/BEABILLDOCCRMB,
    LV_TRANS_MSG_D TYPE /1CRMG0/BEABILLDLVCRMB,
    LS_BDOC_HEAD   TYPE SMW3_FHD,
    LV_SEND_DLV    TYPE BEA_BOOLEAN,
    LV_NOSEND      TYPE C VALUE IS INITIAL,
    LV_ITEMERR     TYPE BEA_MWC_ERROR,
    LV_QUEUE_NO    TYPE QFRANINT,
    LV_QUEUE_C     TYPE NUMC10,
    LV_MAX_ITEMS   TYPE I,
    LV_MAX_QUEUES  TYPE QFRANINT,
    LV_RFC_QNAME   TYPE trfcqnam.
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LT_PAR_WRK    TYPE BEAT_PAR_WRK,
    LT_PAR_WRK_H  TYPE BEAT_PAR2_WRK.
*
  DATA:
    LT_PRC_COM    TYPE BEAT_PRC_COM,
    LT_SESSION_ID TYPE BEAT_PRC_SESSION_ID,
    LS_TAX_DOC    TYPE BEAS_PRC_TTE_O_DOCUMENT.

*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
  BREAK-POINT ID BEA_BD.
  ET_BDH = IT_BDH.

*---------------------------------------------------------------------
* FILLING BDOC STRUCTURES
*---------------------------------------------------------------------

*---------------------------------------------------------------------
* BDOC CLASSICAL PART - HEADER SEGMENT
*---------------------------------------------------------------------
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      EV_GUID_16 = LS_TRANS_MSG-GUID.
  LS_TRANS_MSG_D-GUID = LS_TRANS_MSG-GUID.
  LS_TRANS_MSG-APPL   = GC_APPL.
  LS_TRANS_MSG-OBJ    = GC_OBJ.
  LS_TRANS_MSG_D-APPL = GC_APPL.
  LS_TRANS_MSG_D-OBJ  = GC_OBJ.
  IF GS_MWC_PARAM-MAX_NO_QUEUES GT 0.
    LV_MAX_QUEUES = GS_MWC_PARAM-MAX_NO_QUEUES.
  ELSE.
    LV_MAX_QUEUES = IV_MAX_NO_QUEUES.
  ENDIF.
  CALL FUNCTION 'QF05_RANDOM_INTEGER'
    EXPORTING
      RAN_INT_MAX         = LV_MAX_QUEUES
      RAN_INT_MIN         = 1
    IMPORTING
      RAN_INT             = LV_QUEUE_NO
    EXCEPTIONS
      INVALID_INPUT       = 0.
  UNPACK LV_QUEUE_NO TO LS_TRANS_MSG-QUEUE_NAME.
  LS_TRANS_MSG_D-QUEUE_NAME = LS_TRANS_MSG-QUEUE_NAME.
  APPEND LS_TRANS_MSG   TO LV_TRANS_MSG-BEA_BDOC_HEADER.
  APPEND LS_TRANS_MSG_D TO LV_TRANS_MSG_D-BEA_BDOC_HEADER.

  LOOP AT ET_BDH INTO LS_BDH_WRK.
    IF IV_NO_FLOW IS INITIAL.
      CHECK NOT LS_BDH_WRK-UPD_TYPE IS INITIAL.
    ENDIF.
    CHECK LS_BDH_WRK-PRICING_ERROR <> GC_PRC_ERR_F.
*---------------------------------------------------------------------
* BDOC MESSAGE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
*   INITIALIZATION OF ERROR INDICATORS
*---------------------------------------------------------------------
    CLEAR LS_BDH_WRK-MWC_ERROR.
    IF ls_bdh_wrk-transfer_error NA gc_trans_errors_pyp.
      CLEAR LS_BDH_WRK-TRANSFER_ERROR.
    ENDIF.
    MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR
                                               TRANSFER_ERROR.
    CLEAR: LT_PAR_WRK_H,
           LT_PAR_WRK.
    CALL FUNCTION 'BEA_PAR_O_GET'
      EXPORTING
        IV_PARSET_GUID  = LS_BDH_WRK-PARSET_GUID
        IV_ADDR_GET     = GC_TRUE
      IMPORTING
        ET_PAR          = LT_PAR_WRK
      EXCEPTIONS
        OTHERS          = 1.
    IF SY-SUBRC NE 0.
      LS_BDH_WRK-MWC_ERROR = LC_ERROR_PAR.
      MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
      CONTINUE.
    ENDIF.
    APPEND LINES OF LT_PAR_WRK TO LT_PAR_WRK_H.


    CLEAR LT_BDI_WRK.
    CLEAR LT_BDI.
    CLEAR LV_ITEMERR.
    LOOP AT IT_BDI INTO LS_BDI_WRK
        WHERE BDH_GUID = LS_BDH_WRK-BDH_GUID.
      IF LS_BDI_WRK-BILL_RELEVANCE = gc_bill_rel_delivery OR
         LS_BDI_WRK-BILL_RELEVANCE = gc_bill_rel_deliv_ic OR
         LS_BDI_WRK-BILL_RELEVANCE = gc_bill_rel_dlv_tpop OR
       ( LS_BDI_WRK-BILL_RELEVANCE = GC_BILL_REL_ORDER AND
         ( LS_BDI_WRK-OBJTYPE = GC_BOR_LIKP OR            "STO
           LS_BDI_WRK-OBJTYPE = GC_BOR_INSPECTION ) ) OR  "rSTO
         LS_BDI_WRK-BILL_RELEVANCE IS INITIAL.  "for compatibility reasons
        LV_SEND_DLV = GC_TRUE.
      ENDIF.
      READ TABLE    LT_PAR_WRK_H
           WITH KEY GUID = LS_BDI_WRK-PARSET_GUID
                    TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        CLEAR LT_PAR_WRK.
        CALL FUNCTION 'BEA_PAR_O_GET'
          EXPORTING
            IV_PARSET_GUID  = LS_BDI_WRK-PARSET_GUID
            IV_ADDR_GET     = GC_TRUE
          IMPORTING
            ET_PAR          = LT_PAR_WRK
          EXCEPTIONS
            OTHERS          = 1.
        IF SY-SUBRC NE 0.
          LV_ITEMERR = LC_ERROR_PAR.
          EXIT.
        ELSE.
          APPEND LINES OF LT_PAR_WRK TO LT_PAR_WRK_H.
        ENDIF.
      ENDIF.
      IF LS_BDH_WRK-PRC_SESSION_ID IS INITIAL AND
         IV_NO_PRICING IS INITIAL.
*         derive information for pricing and taxes
        CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_DERIVE'
          EXPORTING
            IS_BDI = LS_BDI_WRK
          IMPORTING
            ES_BDI = LS_BDI_WRK.
      ENDIF.
      APPEND LS_BDI_WRK TO LT_BDI_WRK.
      CLEAR LS_BDI.
      MOVE-CORRESPONDING LS_BDI_WRK TO LS_BDI.
      APPEND LS_BDI TO LT_BDI.
      ADD 1 TO LV_MAX_ITEMS.
    ENDLOOP.
    IF NOT LV_ITEMERR IS INITIAL.
      LS_BDH_WRK-MWC_ERROR = LV_ITEMERR.
      MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
      CONTINUE.
    ENDIF.
    IF LS_BDH_WRK-PRC_SESSION_ID IS INITIAL AND
       IV_NO_PRICING IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_HD_DERIVE'
        EXPORTING
          IS_BDH = LS_BDH_WRK
        IMPORTING
          ES_BDH = LS_BDH_WRK.
    ENDIF.
    IF IV_NO_PRICING IS INITIAL.
      CLEAR LT_PRC_COM.
      CLEAR LT_SESSION_ID.
      CLEAR LS_TAX_DOC.
      IF LS_BDH_WRK-PRC_SESSION_ID IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_OPEN'
          EXPORTING
            IS_BDH              = LS_BDH_WRK
            IT_BDI              = LT_BDI_WRK
            IV_WRITE_MODE       = GC_PRC_PD_READONLY
          IMPORTING
            EV_SESSION_ID       = LS_BDH_WRK-PRC_SESSION_ID
          EXCEPTIONS
            REJECT              = 1
            OTHERS              = 1.
        IF SY-SUBRC NE 0.
          LS_BDH_WRK-MWC_ERROR     = LC_ERROR_PRC.
          MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
          CONTINUE.
        ENDIF.
        APPEND LS_BDH_WRK-PRC_SESSION_ID TO LT_SESSION_ID.
      ENDIF.
      IF NOT LS_BDH_WRK-PRC_SESSION_ID IS INITIAL.
        CALL FUNCTION 'BEA_PRC_O_PDIT_GET'
          EXPORTING
            IV_SESSION_ID    = LS_BDH_WRK-PRC_SESSION_ID
          IMPORTING
            ET_PRC_COM       = LT_PRC_COM
          EXCEPTIONS
            OTHERS           = 1.
        IF SY-SUBRC NE 0.
          LS_BDH_WRK-MWC_ERROR = LC_ERROR_PRC.
          MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
          CONTINUE.
        ENDIF.
        IF NOT LT_PRC_COM IS INITIAL AND
           NOT LS_BDH_WRK-PRIDOC_GUID IS INITIAL.
          CALL FUNCTION '/1BEA/CRMB_BD_CRT_O_DOC_GET'
            EXPORTING
              IS_BDH          = LS_BDH_WRK
            IMPORTING
              ES_TAXDOC       = LS_TAX_DOC
            EXCEPTIONS
              OTHERS          = 1.
          IF SY-SUBRC NE 0.
            LS_BDH_WRK-MWC_ERROR = LC_ERROR_TAX.
            MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
      IF NOT LT_SESSION_ID IS INITIAL.
*       close pricing document
        CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
          EXPORTING
            IT_SESSION_ID = LT_SESSION_ID.
      ENDIF.
    ENDIF.
    APPEND LINES OF LT_BDI TO LS_BDOC-DOCUMENT_BDI.
    APPEND LINES OF LT_PAR_WRK_H TO LS_BDOC-SERVICE_PAR_02.
    IF IV_NO_PRICING IS INITIAL.
      APPEND LINES OF LT_PRC_COM TO LS_BDOC-SERVICE_PRC_02.
      APPEND          LS_TAX_DOC TO LS_BDOC-SERVICE_PRC_TX.
    ENDIF.
*---------------------------------------------------------------------
* BDOC CLASSICAL PART - DOC SEGMENT
*---------------------------------------------------------------------
    CLEAR LS_TRANS_DOC.
    CLEAR LS_TRANS_DOC_D.


    MOVE-CORRESPONDING LS_BDH_WRK TO LS_TRANS_DOC.
    LS_TRANS_DOC-GUID   = LS_TRANS_MSG-GUID.
    APPEND LS_TRANS_DOC   TO LV_TRANS_MSG-BEA_BILLING_DOCUMENTS.
    IF LV_SEND_DLV = GC_TRUE.
      MOVE-CORRESPONDING LS_BDH_WRK TO LS_TRANS_DOC_D.
      LS_TRANS_DOC_D-GUID = LS_TRANS_MSG_D-GUID.
      APPEND LS_TRANS_DOC_D TO LV_TRANS_MSG_D-BEA_BILLING_DOCUMENTS.
    ENDIF.
*---------------------------------------------------------------------
* BDOC MESSAGE - DOCUMENT HEADER
*---------------------------------------------------------------------
    CLEAR LS_BDH.
    MOVE-CORRESPONDING LS_BDH_WRK TO LS_BDH.
    APPEND LS_BDH TO LS_BDOC-DOCUMENT_BDH.

  ENDLOOP.


*
  CHECK NOT LS_BDOC-DOCUMENT_BDH IS INITIAL.
*
*---------------------------------------------------------------------
* EXPORTING BDOC STRUCTURES (IF REQUESTED)
*---------------------------------------------------------------------
  IF ES_BDOC IS REQUESTED.
    ES_BDOC = LS_BDOC.
  ENDIF.

*---------------------------------------------------------------------
* CALLING MIDDLEWARE-FLOW
*---------------------------------------------------------------------
  CHECK IV_NO_FLOW IS INITIAL.

  IF GS_MWC_PARAM-PROCESS_TIME IS INITIAL.
    CALL METHOD CL_SMW_MFLOW=>PROCESS_OUTBOUND
      EXPORTING
        BDOC_TYPE            = LC_BDOC_TYPE
        DOWNLOAD_OBJECT_NAME = LC_DOWNL_OBJ
        IN_UPDATETASK        = LC_QRFC_IN_UPD
      IMPORTING
        HEADER               = LS_BDOC_HEAD
      CHANGING
        MESSAGE              = LV_TRANS_MSG
        MESSAGE_EXT          = LS_BDOC
      EXCEPTIONS
        TECHNICAL_ERROR      = 1
        OTHERS               = 1.
    IF SY-SUBRC NE 0.
      LOOP AT ET_BDH INTO LS_BDH_WRK.
        LS_BDH_WRK-MWC_ERROR = LC_TECHERR.
        MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
      ENDLOOP.
    ENDIF.
    IF LV_SEND_DLV = GC_TRUE.
      CLEAR LS_BDOC_HEAD.
*     outbound flow - LE status update - see above
      CALL METHOD CL_SMW_MFLOW=>PROCESS_OUTBOUND
        EXPORTING
          BDOC_TYPE            = LC_BDOC_TYPE_D
          DOWNLOAD_OBJECT_NAME = LC_DOWNL_OBJ_D
          IN_UPDATETASK        = LC_QRFC_IN_UPD
        IMPORTING
          HEADER               = LS_BDOC_HEAD
        CHANGING
          MESSAGE              = LV_TRANS_MSG_D
          MESSAGE_EXT          = LS_BDOC
        EXCEPTIONS
          TECHNICAL_ERROR      = 1
          OTHERS               = 1.
      IF SY-SUBRC NE 0.
        LOOP AT ET_BDH INTO LS_BDH_WRK.
          LS_BDH_WRK-MWC_ERROR = LC_TECHERR.
          MODIFY ET_BDH FROM LS_BDH_WRK TRANSPORTING MWC_ERROR.
        ENDLOOP.
      ENDIF.
    ENDIF.
    DELETE ET_BDH WHERE UPD_TYPE = gc_unchanged.
    IF LV_MAX_ITEMS > GV_MAX_ITEMS.
      CALL FUNCTION '/1BEA/CRMB_BD_MWC_O_1O_UPDATE'
            EXPORTING
              IT_BDH   = ET_BDH
              IT_BDI   = IT_BDI.
    ELSE.
*     validation flow - initialize useless service data
      CLEAR:
        LS_BDOC-SERVICE_PAR_02,
        LS_BDOC-SERVICE_PRC_02,
        LS_BDOC-SERVICE_PRC_TX,
        LS_BDOC_HEAD.
*     validation flow - send message to source applications
      CALL METHOD CL_SMW_MFLOW=>SET_HEADER_FIELDS
        EXPORTING
          IN_BDOC_TYPE   = LC_BDOC_TYPE
        IMPORTING
          OUT_HEADER     = LS_BDOC_HEAD.
*     Set qname for qRFC
      LV_QUEUE_C = LV_QUEUE_NO.
      CONCATENATE lc_qname_pre LV_QUEUE_C INTO lv_rfc_qname.
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
    ENDIF.
  ELSE.
    CALL FUNCTION '/1BEA/CRMB_BD_MWC_P_POST' IN UPDATE TASK
      EXPORTING
        IS_MESSAGE          = LV_TRANS_MSG
        IS_MESSAGE_D        = LV_TRANS_MSG_D
        IS_BDOC             = LS_BDOC.
  ENDIF.
*
*---------------------------------------------------------------------
* UPDATE OF THE TRANSFER STATUS
*---------------------------------------------------------------------
  LS_BDH_WRK-TRANSFER_STATUS = GC_TRANSFER_IN_WORK.
  MODIFY ET_BDH FROM  LS_BDH_WRK TRANSPORTING TRANSFER_STATUS
                WHERE TRANSFER_STATUS =  GC_TRANSFER_TODO
                  AND PRICING_ERROR   IS INITIAL
                  AND TRANSFER_ERROR  IS INITIAL
                  AND MWC_ERROR       IS INITIAL.

*
ENDFUNCTION.

