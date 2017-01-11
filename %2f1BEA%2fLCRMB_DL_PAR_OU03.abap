FUNCTION /1BEA/CRMB_DL_PAR_O_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IT_PAR_COM) TYPE  BEAT_PAR_COM
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_MSG_VAR        TYPE BEAS_MESSAGE_VAR,
    LT_RETURN         TYPE BEAT_RETURN,
    LS_PAR_COM        TYPE BEAS_PAR_COM,
    LS_PAR_WRK        TYPE COMT_PARTNER_WRK,
    LS_PAR_CTRL       TYPE COMT_PARTNER_CONTROL,
    LT_IFN_C          TYPE COMT_PARTNER_INPUT_FIELD_N_TAB,
    LRT_FIELDNAME     TYPE BEART_PAR_COM_FIELDNAME,
    LV_DLI_PAR_PROC   TYPE COMT_PARTNER_DETERM_PROC,
    LS_DETERM_PROC    TYPE CRMC_PARTNER_PDP,
    LT_DETERM_PROC    TYPE COMT_PARTNER_PDP_TAB,
    LS_PAR_FCT        TYPE CRMC_PARTNER_FCT,
    LT_PAR_FCT        TYPE COMT_PARTNER_CRMC_FCT_TAB,
    LV_SUBRC          TYPE SYSUBRC,
    LV_STRUC          TYPE TABNAME,
    LV_ADDR           TYPE BEA_BOOLEAN.
  STATICS:
    LT_IFN_E          TYPE BEAT_PAR_FIELD_NAMES,
    LT_IFN_A          TYPE BEAT_PAR_FIELD_NAMES.
  CONSTANTS:
    LC_STRUC_EXT     TYPE TABNAME VALUE 'COMT_PARTNER_EXT'.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN INITIALIZATION
*---------------------------------------------------------------------
  BREAK-POINT ID BEA_PAR.
  PERFORM INIT_DLI_PAR_O.
  ES_DLI = IS_DLI.
  CLEAR ES_DLI-PARSET_GUID.
*---------------------------------------------------------------------
* END INITIALIZATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
*   Fill up CONTROL-Structure for Partnerprocessing
  CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_GET_CTRL'
       EXPORTING
            IS_DLI      = IS_DLI
            IS_ITC      = IS_ITC
       IMPORTING
            ES_PAR_CTRL = LS_PAR_CTRL.
*   continue with process ?
*     read partner determination proc
  IF NOT LS_PAR_CTRL-DETERM_PROC IS INITIAL.
    LV_DLI_PAR_PROC = LS_PAR_CTRL-DETERM_PROC.
    CALL FUNCTION 'COM_PARTNER_DETERM_PROC_GET_CB'
       EXPORTING
         IV_DETERM_PROC                   = LV_DLI_PAR_PROC
       IMPORTING
         ET_DETERM_PROC                   = LT_DETERM_PROC
       EXCEPTIONS
         DETERM_PROC_DOES_NOT_EXIST       = 1
         OTHERS                           = 2.
     IF SY-SUBRC <> 0.
       MESSAGE E006(BEA_PAR) INTO GV_DUMMY.
       PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                    CHANGING ET_RETURN.
       PERFORM MSG_DLI_PAR_O_2_RETURN CHANGING ET_RETURN.
       MESSAGE E001(BEA_PAR) RAISING REJECT.
     ENDIF.
    LOOP AT LT_DETERM_PROC INTO LS_DETERM_PROC.
      CALL FUNCTION 'COM_PARTNER_GET_FUNCTIONS'
        EXPORTING
          IV_PARTNER_FCT        = LS_DETERM_PROC-PARTNER_FCT
        IMPORTING
          ES_PARTNER_FCT        = LS_PAR_FCT
        EXCEPTIONS
          PARTNER_FCT_NOT_FOUND = 1
          OTHERS                = 2.
      IF SY-SUBRC = 0.
        INSERT LS_PAR_FCT INTO TABLE LT_PAR_FCT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF NOT LT_PAR_FCT IS INITIAL AND
     IT_PAR_COM IS INITIAL.
    LS_MSG_VAR-MSGV1 = GC_P_DLI_ITEMNO.
    LS_MSG_VAR-MSGV2 = GC_P_DLI_HEADNO.
    CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = IS_DLI
        IS_MSG_VAR     = LS_MSG_VAR
      IMPORTING
        ES_MSG_VAR     = LS_MSG_VAR.
    MESSAGE E012(BEA_PAR) WITH LS_MSG_VAR-MSGV1 LS_MSG_VAR-MSGV2 RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
*   which input fields of the external fields are filled
  PERFORM FILL_INPUT_FIELDS    USING LC_STRUC_EXT
                            CHANGING LT_IFN_E ET_RETURN.
  LOOP AT IT_PAR_COM INTO LS_PAR_COM.
    IF NOT IS_ITC IS INITIAL AND
       LS_PAR_CTRL-DETERM_PROC IS INITIAL.
      CONTINUE.
    ENDIF.
    PERFORM INIT_PAR_COM_REF CHANGING LS_PAR_COM.
*     relevant entry for billing duelist ?
    IF NOT LS_PAR_CTRL-DETERM_PROC IS INITIAL.
      PERFORM CHECK_AND_MAP_FCT USING LT_PAR_FCT
                             CHANGING LS_PAR_COM LV_SUBRC.
    ELSE.
      CLEAR LV_SUBRC.
    ENDIF.
    IF LV_SUBRC <> 0.
      CONTINUE.
    ENDIF.
    CLEAR: LT_IFN_C,
           LT_IFN_A,
           LV_ADDR,
           LRT_FIELDNAME,
           LS_PAR_WRK.
    IF LS_PAR_COM-ADDR_ORIGIN = GC_DOC_ADR OR
       LS_PAR_COM-ADDR_ORIGIN = GC_REF_ADR.
      PERFORM DOC_ADDRESS_FILL
        CHANGING
          LV_ADDR LV_STRUC LRT_FIELDNAME LS_PAR_COM.
    ENDIF.
    IF LV_ADDR                = GC_TRUE AND
       LS_PAR_COM-ADDR_ORIGIN = GC_DOC_ADR.
*        inputs for the address fields are done --> document address
      PERFORM FILL_INPUT_FIELDS USING LV_STRUC
                             CHANGING LT_IFN_A ET_RETURN.
      PERFORM EXCLUDE_FIELDS  CHANGING LRT_FIELDNAME.
    ENDIF.
    PERFORM MERGE_IFN_E_A_TO_C USING LT_IFN_A LT_IFN_E
                            CHANGING LT_IFN_C.
    IF NOT LRT_FIELDNAME IS INITIAL.
      DELETE LT_IFN_C WHERE FIELDNAME IN LRT_FIELDNAME.              "#EC CI_SORTSEQ
    ENDIF.
*     Process of creating and check a single partner
    CALL FUNCTION 'COM_PARTNER_MAINTAIN_SINGLE_OW'
      EXPORTING
        IV_PARTNERSET_GUID               = ES_DLI-PARSET_GUID
        IS_PARTNER_COM                   = LS_PAR_COM                "#EC ENHOK
        IS_PARTNER_CONTROL               = LS_PAR_CTRL
      IMPORTING
        EV_CREATED_PARTNERSET_GUID       = ES_DLI-PARSET_GUID
        ES_PARTNER_WRK                   = LS_PAR_WRK
      CHANGING
        CT_INPUT_FIELD_NAMES             = LT_IFN_C
*       CT_PARTNER_ATTRIBUTES_COM        =
      EXCEPTIONS
        ERROR_OCCURRED                   = 1
        OTHERS                           = 2.
    IF SY-SUBRC <> 0.
      MESSAGE E002(BEA_PAR) WITH IS_ITC-DLI_PAR_PROC INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                   CHANGING ET_RETURN.
      PERFORM MSG_DLI_PAR_O_2_RETURN   CHANGING ET_RETURN.
      MESSAGE E001(BEA_PAR) RAISING REJECT.
    ELSE.
      IF LV_ADDR = GC_TRUE.
        PERFORM DOC_ADDRESS_BUFFER
          USING
            LS_PAR_WRK
            LS_PAR_COM.
      ENDIF.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN POST PROCESSING
*---------------------------------------------------------------------
*   derive dependent information from partneset
  IF NOT IS_DLI-PARSET_GUID IS INITIAL.
    CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DERIVE'
         EXPORTING
              IS_DLI = IS_DLI
              IS_ITC = IS_ITC
         IMPORTING
              ES_DLI = ES_DLI
         EXCEPTIONS
              REJECT = 1
              OTHERS = 2.
    IF SY-SUBRC <> 0.
      MESSAGE E003(BEA_PAR) WITH IS_DLI-PARSET_GUID INTO GV_DUMMY.
      PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING LT_RETURN.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
* END POST PROCESSING
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN ERROR RETURNING
*---------------------------------------------------------------------
  PERFORM MSG_DLI_PAR_O_2_RETURN CHANGING LT_RETURN.
  IF NOT LT_RETURN IS INITIAL.
    INSERT LINES OF LT_RETURN INTO TABLE ET_RETURN.
    LOOP AT LT_RETURN TRANSPORTING NO FIELDS
          WHERE TYPE = GC_EMESSAGE
             OR TYPE = GC_AMESSAGE.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC = 0.
      MESSAGE E009(BEA_PAR) WITH IS_ITC-DLI_PAR_PROC RAISING REJECT.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
* END ERROR RETURNING
*---------------------------------------------------------------------
ENDFUNCTION.
*---------------------------------------------------------------------
*       FORM fill_input_fields
*---------------------------------------------------------------------
FORM FILL_INPUT_FIELDS
  USING    IV_STRUC_NAME   TYPE TABNAME
  CHANGING CT_INPUT_FIELDS TYPE BEAT_PAR_FIELD_NAMES
           CT_RETURN       TYPE BEAT_RETURN.
  DATA: LS_INPUT_FIELDS TYPE COMT_INPUT_FIELD_NAMES,
        LT_FIELDS       TYPE TABLE OF X031L,
        LS_FIELDS       TYPE X031L.
*  already filled ?
  CHECK CT_INPUT_FIELDS IS INITIAL.
  CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
            TABNAME       = IV_STRUC_NAME
       TABLES
            X031L_TAB     = LT_FIELDS
       EXCEPTIONS
            NOT_FOUND     = 1
            OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING CT_RETURN.
    PERFORM MSG_DLI_PAR_O_2_RETURN   CHANGING CT_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.

  SORT LT_FIELDS BY FIELDNAME.
  LOOP AT LT_FIELDS INTO LS_FIELDS.
    CLEAR LS_INPUT_FIELDS.
    LS_INPUT_FIELDS-FIELDNAME = LS_FIELDS-FIELDNAME.
    LS_INPUT_FIELDS-CHANGEABLE = GC_TRUE.
    APPEND LS_INPUT_FIELDS TO CT_INPUT_FIELDS.     "#EC ENHOK
  ENDLOOP.
    LS_INPUT_FIELDS-FIELDNAME = 'KIND_OF_ENTRY'.
    LS_INPUT_FIELDS-CHANGEABLE = GC_TRUE.
    APPEND LS_INPUT_FIELDS TO CT_INPUT_FIELDS.     "#EC ENHOK
ENDFORM.
*---------------------------------------------------------------------
*      FORM INIT_PAR_COM_REF
*---------------------------------------------------------------------
 FORM INIT_PAR_COM_REF
   CHANGING
     CS_PAR_COM      TYPE BEAS_PAR_COM.
 CLEAR:
   CS_PAR_COM-REF_PARTNER_HANDLE,
   CS_PAR_COM-REF_PARTNER_FCT,
   CS_PAR_COM-REF_PARTNER_NO,
   CS_PAR_COM-REF_NO_TYPE,
   CS_PAR_COM-REF_DISPLAY_TYPE.
 CLEAR CS_PAR_COM-RELATION_PARTNER.
 ENDFORM.                    "INIT_PAR_COM_REF
*---------------------------------------------------------------------
*      FORM CHECK_AND_MAP_FCT
*---------------------------------------------------------------------
 FORM CHECK_AND_MAP_FCT
   USING
     UT_PAR_FCT      TYPE COMT_PARTNER_CRMC_FCT_TAB
   CHANGING
     CS_PAR_COM      TYPE BEAS_PAR_COM
     CV_SUBRC        TYPE SYSUBRC.
   DATA:
     LS_PAR_FCT        TYPE CRMC_PARTNER_FCT,
     LS_PAR_COM        TYPE CRMC_PARTNER_FCT.

   READ TABLE UT_PAR_FCT WITH TABLE KEY
         PARTNER_FCT = CS_PAR_COM-PARTNER_FCT
         TRANSPORTING NO FIELDS.
   CV_SUBRC = SY-SUBRC.
   CHECK SY-SUBRC <> 0.

   CALL FUNCTION 'COM_PARTNER_GET_FUNCTIONS'
     EXPORTING
       IV_PARTNER_FCT        = CS_PAR_COM-PARTNER_FCT
     IMPORTING
       ES_PARTNER_FCT        = LS_PAR_COM
     EXCEPTIONS
       PARTNER_FCT_NOT_FOUND = 0
       OTHERS                = 0.
   READ TABLE UT_PAR_FCT INTO LS_PAR_FCT
     WITH KEY PARTNER_PFT = LS_PAR_COM-PARTNER_PFT.
   CV_SUBRC = SY-SUBRC.
   IF CV_SUBRC = 0.
     IF CS_PAR_COM-PARTNER_FCT <> LS_PAR_FCT-PARTNER_FCT.
       CS_PAR_COM-PARTNER_FCT = LS_PAR_FCT-PARTNER_FCT.
     ENDIF.
   ENDIF.
 ENDFORM.                    "CHECK_AND_MAP_FCT
*---------------------------------------------------------------------
*      FORM DOC_ADDRESS_FILL
*---------------------------------------------------------------------
 FORM DOC_ADDRESS_FILL
   CHANGING
     CV_ADDR         TYPE BEA_BOOLEAN
     CV_STRUC        TYPE TABNAME
     CRT_FIELDNAME   TYPE BEART_PAR_COM_FIELDNAME
     CS_PAR_COM      TYPE BEAS_PAR_COM.
 CONSTANTS:
   LC_ADDR_TYPE_ORG TYPE AD_ADRTYPE VALUE '1',
   LC_ADDR_TYPE_PER TYPE AD_ADRTYPE VALUE '2',
   LC_ADDR_TYPE_ANS TYPE AD_ADRTYPE VALUE '3',
   LC_STRUC_ORG     TYPE TABNAME VALUE 'BAPIADDR1',
   LC_STRUC_PER     TYPE TABNAME VALUE 'BAPIADDR2',
   LC_STRUC_ANS     TYPE TABNAME VALUE 'BAPIADDR3'.
 DATA:
   LRS_FIELDNAME TYPE BEARS_PAR_COM_FIELDNAME,
   LS_DOC_ADDR       TYPE GSY_DOC_ADDR.

   CLEAR CV_STRUC.
   CV_ADDR = GC_FALSE.
   CS_PAR_COM-ADDR_ORIGIN = GC_DOC_ADR.
   LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
   LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
   LRS_FIELDNAME-LOW     = 'STD_BP_ADDRESS'.
   APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
   READ TABLE GT_DOC_ADDR INTO LS_DOC_ADDR WITH KEY
              SRC_ADDR_NR = CS_PAR_COM-ADDR_NO.
   IF SY-SUBRC = 0.
     CS_PAR_COM-ADDR_NR = CS_PAR_COM-ADDR_NO = LS_DOC_ADDR-ADDR_NR.
     CS_PAR_COM-ADDR_NP = CS_PAR_COM-PERS_NO = LS_DOC_ADDR-ADDR_NP.
     CS_PAR_COM-ADDR_TYPE = LS_DOC_ADDR-ADDR_TYPE.
     RETURN.
   ENDIF.
   CASE CS_PAR_COM-ADDR_TYPE.
     WHEN LC_ADDR_TYPE_ORG.
       CV_STRUC = LC_STRUC_ORG.
       CV_ADDR  = GC_TRUE.
     WHEN LC_ADDR_TYPE_PER.
       CV_STRUC = LC_STRUC_PER.
       CV_ADDR  = GC_TRUE.
     WHEN LC_ADDR_TYPE_ANS.
       CV_STRUC = LC_STRUC_ANS.
       CV_ADDR  = GC_TRUE.
     WHEN OTHERS.
   ENDCASE.
 ENDFORM.                    "DOC_ADDRESS_FILL
*---------------------------------------------------------------------
*      FORM DOC_ADDRESS_BUFFER
*---------------------------------------------------------------------
 FORM DOC_ADDRESS_BUFFER
   USING
     US_PAR_WRK      TYPE COMT_PARTNER_WRK
     US_PAR_COM      TYPE BEAS_PAR_COM.
 DATA:
   LS_DOC_ADDR       TYPE GSY_DOC_ADDR.

   READ TABLE GT_DOC_ADDR INTO LS_DOC_ADDR WITH KEY
              SRC_ADDR_NR = US_PAR_COM-ADDR_NR.
   IF SY-SUBRC <> 0.
     LS_DOC_ADDR-SRC_ADDR_NR = US_PAR_COM-ADDR_NR.
     LS_DOC_ADDR-ADDR_NR     = US_PAR_WRK-ADDR_NR.
     LS_DOC_ADDR-ADDR_NP     = US_PAR_WRK-ADDR_NP.
     LS_DOC_ADDR-ADDR_TYPE   = US_PAR_WRK-ADDR_TYPE.
     INSERT LS_DOC_ADDR INTO TABLE GT_DOC_ADDR.
   ENDIF.
 ENDFORM.                    "DOC_ADDRESS_BUFFER
*---------------------------------------------------------------------
*        FORM EXCLUDE_FIELDS
*---------------------------------------------------------------------
FORM EXCLUDE_FIELDS
  CHANGING CRT_FIELDNAME   TYPE BEART_PAR_COM_FIELDNAME.
  DATA:
    LRS_FIELDNAME TYPE BEARS_PAR_COM_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_NR'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_NP'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_NO'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'PERS_NO'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_NP'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_ORIGIN'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
  LRS_FIELDNAME-SIGN    = GC_SIGN_INCLUDE.
  LRS_FIELDNAME-OPTION  = GC_RANGEOPTION_EQ.
  LRS_FIELDNAME-LOW     = 'ADDR_TYPE'.
  APPEND LRS_FIELDNAME TO CRT_FIELDNAME.
ENDFORM.
*--------------------------------------------------------------------
*      Form  merge_ifn_e_a_to_c
*--------------------------------------------------------------------
FORM MERGE_IFN_E_A_TO_C
  USING    IT_IFN_A TYPE BEAT_PAR_FIELD_NAMES
           IT_IFN_E TYPE BEAT_PAR_FIELD_NAMES
  CHANGING ET_IFN_C TYPE COMT_PARTNER_INPUT_FIELD_N_TAB.

  DATA: LT_IFN_I  TYPE BEAT_PAR_FIELD_NAMES.

  APPEND LINES OF IT_IFN_A TO LT_IFN_I.
  APPEND LINES OF IT_IFN_E TO LT_IFN_I.
  SORT LT_IFN_I.
  ET_IFN_C = LT_IFN_I.
ENDFORM.                    " merge_ifn_e_a_to_c
*--------------------------------------------------------------------
*      Form  INIT_DLI_PAR_O
*--------------------------------------------------------------------
FORM INIT_DLI_PAR_O.
  CALL FUNCTION 'BEA_PAR_O_INIT'.
ENDFORM.                    " INIT_DLI_PAR_O
*--------------------------------------------------------------------
*      Form  MSG_DLI_PAR_O_2_RETURN
*--------------------------------------------------------------------
FORM MSG_DLI_PAR_O_2_RETURN
  CHANGING CT_RETURN TYPE BEAT_RETURN.
*   get errors from com_partner functionality
  CALL FUNCTION 'BEA_PAR_O_MSG_GETLIST'
       EXPORTING
            IT_RETURN = CT_RETURN
       IMPORTING
            ET_RETURN = CT_RETURN.
ENDFORM.                    " MSG_DLI_PAR_O_2_RETURN
