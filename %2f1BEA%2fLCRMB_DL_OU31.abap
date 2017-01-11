FUNCTION /1BEA/CRMB_DL_O_COLL_RUN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IS_BILL_DEFAULT) TYPE  BEAS_BILL_DEFAULT
*"     REFERENCE(IV_COMMIT) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"  EXPORTING
*"     REFERENCE(EV_CRP_GUID) TYPE  BEA_CRP_GUID
*"     REFERENCE(EV_LOGHNDL) TYPE  BALLOGHNDL
*"     REFERENCE(EV_NO_AUTHORITY) TYPE  BEA_BOOLEAN
*"     REFERENCE(ET_DLI_ERROR) TYPE  BEAT_DLI_GUID
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
* Definitionsteil
*====================================================================
*--------------------------------------------------------------------
* Definition lokaler Variablen
*--------------------------------------------------------------------
  DATA:
    LT_DLI_WRK_BD_CREATE TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_WRK           TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_PACK_HLP      TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK           TYPE /1BEA/T_CRMB_DLI_WRK,
    LV_COUNTER           TYPE SYTABIX,
    LV_RETURNCODE        TYPE SYSUBRC,
    LT_RETURN            TYPE BEAT_RETURN.
  DATA: LS_DLI_HEADKEY     TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID.
  DATA: LS_DLI_HEADKEY_OLD TYPE /1BEA/US_CRMB_DL_DLI_SRC_HID.
  FIELD-SYMBOLS:
    <FS_DLI_WRK> TYPE /1BEA/S_CRMB_DLI_WRK.
*==================================================================
* Implementierungsteil
*==================================================================
  EV_NO_AUTHORITY = GC_FALSE.
  PERFORM AUTHORITY_CHECK_ALL
    USING
      GC_ACTV_MASSDATA
    CHANGING
      LT_RETURN
      LV_RETURNCODE.
  IF NOT LV_RETURNCODE IS INITIAL.
    IF ET_RETURN IS REQUESTED.
      APPEND LINES OF LT_RETURN TO ET_RETURN.
    ENDIF.
    EV_NO_AUTHORITY = GC_TRUE.
    RETURN.
  ENDIF.
  CLEAR LV_COUNTER.
  LT_DLI_WRK = IT_DLI_WRK.
  LOOP AT LT_DLI_WRK ASSIGNING <FS_DLI_WRK>.
    IF NOT IS_BILL_DEFAULT-BILL_DATE IS INITIAL.
      <FS_DLI_WRK>-BILL_DATE_D = IS_BILL_DEFAULT-BILL_DATE.
    ELSE.
      <FS_DLI_WRK>-BILL_DATE_D = LS_DLI_WRK-BILL_DATE.
    ENDIF.
    IF NOT IS_BILL_DEFAULT-BILL_TYPE IS INITIAL.
      <FS_DLI_WRK>-BILL_TYPE_D = IS_BILL_DEFAULT-BILL_TYPE.
    ELSE.
      <FS_DLI_WRK>-BILL_TYPE_D = LS_DLI_WRK-BILL_TYPE.
    ENDIF.
  ENDLOOP.

  SORT LT_DLI_WRK BY
      SOLD_TO_PARTY
      BILL_ORG
      BILL_TYPE_D
      LOGSYS
      OBJTYPE
      SRC_HEADNO
      CLIENT.
* customer specific influencing of package building
  LOOP AT LT_DLI_WRK ASSIGNING <FS_DLI_WRK>.
*   manage package criteria of collective run processing
    IF
        <FS_DLI_WRK>-SOLD_TO_PARTY <> LS_DLI_PACK_HLP-SOLD_TO_PARTY
       OR <FS_DLI_WRK>-BILL_ORG <> LS_DLI_PACK_HLP-BILL_ORG
       OR <FS_DLI_WRK>-BILL_TYPE_D <> LS_DLI_PACK_HLP-BILL_TYPE_D.
      LS_DLI_PACK_HLP-SOLD_TO_PARTY = <FS_DLI_WRK>-SOLD_TO_PARTY.
      LS_DLI_PACK_HLP-BILL_ORG = <FS_DLI_WRK>-BILL_ORG.
      LS_DLI_PACK_HLP-BILL_TYPE_D = <FS_DLI_WRK>-BILL_TYPE_D.
      IF NOT LT_DLI_WRK_BD_CREATE[] IS INITIAL.
        PERFORM BILL_CREATE
           USING
             LT_DLI_WRK_BD_CREATE
             IS_BILL_DEFAULT
             IV_COMMIT
             IV_PROCESS_MODE
           CHANGING
             EV_CRP_GUID
             EV_LOGHNDL
             ET_DLI_ERROR
             ET_RETURN.
        CLEAR LV_COUNTER.
        CLEAR LT_DLI_WRK_BD_CREATE.
      ENDIF.
    ENDIF.
*   manage threashold value of collective run processing
    MOVE-CORRESPONDING <FS_DLI_WRK> TO LS_DLI_HEADKEY.
    IF NOT LS_DLI_HEADKEY = LS_DLI_HEADKEY_OLD.
      LS_DLI_HEADKEY_OLD = LS_DLI_HEADKEY.
      ADD 1 TO LV_COUNTER.
    ENDIF.
    IF LV_COUNTER > GV_MAX_DOCUMENTS.
      PERFORM BILL_CREATE
          USING
            LT_DLI_WRK_BD_CREATE
            IS_BILL_DEFAULT
            IV_COMMIT
            IV_PROCESS_MODE
          CHANGING
            EV_CRP_GUID
            EV_LOGHNDL
            ET_DLI_ERROR
            ET_RETURN.
      LV_COUNTER = 1.
      CLEAR LT_DLI_WRK_BD_CREATE.
    ENDIF.
    INSERT <FS_DLI_WRK> INTO TABLE LT_DLI_WRK_BD_CREATE.
  ENDLOOP.
  IF NOT LT_DLI_WRK_BD_CREATE IS INITIAL.
    PERFORM BILL_CREATE
      USING
        LT_DLI_WRK_BD_CREATE
        IS_BILL_DEFAULT
        IV_COMMIT
        IV_PROCESS_MODE
      CHANGING
        EV_CRP_GUID
        EV_LOGHNDL
        ET_DLI_ERROR
        ET_RETURN.
    CLEAR LV_COUNTER.
    CLEAR LT_DLI_WRK_BD_CREATE.
  ENDIF.
ENDFUNCTION.

*---------------------------------------------------------------------
*       FORM bill_create
*---------------------------------------------------------------------
  FORM BILL_CREATE
       USING
         UT_DLI_WRK_BD_CREATE TYPE /1BEA/T_CRMB_DLI_WRK
         US_BILL_DEFAULT      TYPE BEAS_BILL_DEFAULT
         UV_COMMIT_FLAG       TYPE BEF_COMMIT
         UV_PROCESS_MODE      TYPE BEA_PROCESS_MODE
       CHANGING
         CV_CRP_GUID          TYPE BEA_CRP_GUID
         cv_loghndl           type balloghndl
         CT_DLI_ERROR         TYPE BEAT_DLI_GUID
         ct_return            type beat_return.
data: lt_return type beat_return,
      ls_crp    type beas_crp.
*-----------------------------------------------------------------------
* Handle Collective Run and APPLication Log
*-----------------------------------------------------------------------
PERFORM get_crp CHANGING ls_crp
                              ct_return.
PERFORM get_loghndl  using    ls_crp
                     changing cv_loghndl
                              ct_return.
************************************************************************
* Create Bills
************************************************************************
CALL FUNCTION '/1BEA/CRMB_BD_O_CREATE'
 EXPORTING
   it_dli_wrk      = ut_dli_wrk_bd_create
   is_crp          = ls_crp
   iv_loghndl      = cv_loghndl
   is_bill_default = us_bill_default
   iv_process_mode = uv_process_mode
   iv_commit_flag  = uv_commit_flag
 IMPORTING
   es_crp          = ls_crp
   ev_loghndl      = cv_loghndl
   et_return       = lt_return.
CV_CRP_GUID = ls_crp-guid.
IF not lt_return is initial.
 PERFORM errors_at_bill USING ut_dli_wrk_bd_create
                              lt_return
                        CHANGING ct_return
                                 ct_dli_error.
ENDIF.
  ENDFORM.                    "bill_create
*---------------------------------------------------------------------*
*      Form  get_crp
*---------------------------------------------------------------------*
FORM get_crp  CHANGING cs_crp    TYPE beas_crp
                            ct_return TYPE beat_return.
 CONSTANTS: lc_crp_type_bill TYPE bea_crp_type VALUE 'A'.
*-----------------------------------------------------------------------
* Get the currently processed
*-----------------------------------------------------------------------
 CLEAR cs_crp.
 CALL FUNCTION 'BEA_CRP_O_GET'
   IMPORTING
     es_crp = cs_crp.
*-----------------------------------------------------------------------
* If there is none, open one
*-----------------------------------------------------------------------
 IF cs_crp is initial.
   CALL FUNCTION 'BEA_CRP_O_CREATE'
     EXPORTING
       iv_APPL            = gc_APPL
       iv_type            = lc_crp_type_bill
     IMPORTING
       es_crp             = cs_crp
     EXCEPTIONS
       crp_already_exists = 1
       nr_error           = 2
       OTHERS             = 3.
   IF sy-subrc ne 0.
     MESSAGE ID sy-msgid TYPE sy-msgTY NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
             INTO gv_dummy.
     PERFORM msg_add USING space space space space
                     CHANGING ct_return.
     IF NOT sy-batch IS INITIAL.
       MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     ENDIF.
     RETURN. "from form
   ENDIF.
 ELSE.
*-----------------------------------------------------------------------
* If there is one, check the type!
*-----------------------------------------------------------------------
   IF NOT cs_crp-type = lc_crp_type_bill.
* Wrong type -> REFRESH and CREATE
     CALL FUNCTION 'BEA_CRP_O_REFRESH'.
     clear cs_crp.
     CALL FUNCTION 'BEA_CRP_O_CREATE'
       EXPORTING
         iv_APPL            = gc_APPL
         iv_type            = lc_crp_type_bill
       IMPORTING
         es_crp             = cs_crp
       EXCEPTIONS
         crp_already_exists = 1
         nr_error           = 2
         OTHERS             = 3.
     IF sy-subrc ne 0.
       MESSAGE ID sy-msgid TYPE sy-msgTY NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               INTO gv_dummy.
       PERFORM msg_add USING space space space space
                       CHANGING ct_return.
       IF NOT sy-batch IS INITIAL.
         MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       ENDIF.
       RETURN. "from form
     ENDIF.
   ENDIF.
 ENDIF.
ENDFORM.                    " get_crp
*---------------------------------------------------------------------*
*      Form  get_loghndl
*---------------------------------------------------------------------*
FORM get_loghndl using    us_crp     type beas_crp
                 CHANGING cv_loghndl TYPE balloghndl
                          ct_return  TYPE beat_return.
DATA: lv_loghndl TYPE balloghndl.
CALL FUNCTION 'BEA_AL_O_GETBUFFER'
 IMPORTING
   ev_loghndl = lv_loghndl.
IF not lv_loghndl is initial.
 cv_loghndl = lv_loghndl.
ELSE.
 CALL FUNCTION 'BEA_AL_O_CREATE'
   EXPORTING
     iv_APPL            = gc_APPL
     iv_crp_guid        = us_crp-guid
   IMPORTING
     ev_loghndl         = lv_loghndl
   EXCEPTIONS
     log_already_exists = 1
     log_not_created    = 2
     OTHERS             = 3.
 IF sy-subrc <> 0.
   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
           INTO gv_dummy.
   PERFORM msg_add USING space space space space
                   CHANGING ct_return.
   RETURN. "from form
 ELSE.
   cv_loghndl = lv_loghndl.
 ENDIF.
ENDIF.
ENDFORM.                    "get_loghndl
*---------------------------------------------------------------------
*      Form  errors_at_bill
*---------------------------------------------------------------------
FORM errors_at_bill
    USING    ut_dli_wrk_bd_create TYPE /1bea/t_CRMB_DLI_wrk
             ut_return            TYPE beat_return
    CHANGING ct_return            TYPE beat_return
             ct_dli_error         TYPE beat_dli_guid.
 DATA: ls_return TYPE beas_return,
       ls_dli    TYPE /1bea/s_CRMB_DLI_wrk.
*---------------------------------------------------------------------
* Messages
*---------------------------------------------------------------------
 APPEND LINES OF ut_return TO ct_return.
*---------------------------------------------------------------------
* Error DLIs
*---------------------------------------------------------------------
 LOOP AT ut_return INTO ls_return WHERE not row is initial.
   READ TABLE ut_dli_wrk_bd_create INTO ls_dli INDEX ls_return-row.
   APPEND ls_dli-dli_guid TO ct_dli_error.
 ENDLOOP.
* new Errorhandling on GUID's
 LOOP AT ut_return INTO ls_return WHERE container = 'DLI'.
   APPEND ls_return-object_guid TO ct_dli_error.
 ENDLOOP.
ENDFORM.                    " errors_at_bill
*-----------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_ALL                                  *
*-----------------------------------------------------------------*
FORM AUTHORITY_CHECK_ALL
  USING
    UV_ACTIVITY    TYPE ACTIV_AUTH
  CHANGING
    CT_RETURN      TYPE BEAT_RETURN
    CV_RETURNCODE  TYPE SYSUBRC.
  CALL FUNCTION 'BEA_AUT_O_CHECK_ALL'
    EXPORTING
      IV_BILL_TYPE           = SPACE
      IV_BILL_ORG            = SPACE
      IV_APPL                = GC_APPL
      IV_ACTVT               = UV_ACTIVITY
      IV_CHECK_DLI           = GC_TRUE
      IV_CHECK_BDH           = GC_FALSE
    EXCEPTIONS
      NO_AUTH                = 1
      OTHERS                 = 2.
  IF SY-SUBRC <> 0.
    CV_RETURNCODE = SY-SUBRC.
    CASE UV_ACTIVITY.
      WHEN GC_ACTV_MASSDATA.
        message e501(bea) into gv_dummy.
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
    ENDCASE.
      PERFORM MSG_ADD
        USING    SPACE SPACE SPACE SPACE
        CHANGING CT_RETURN.
  ENDIF.
ENDFORM.
