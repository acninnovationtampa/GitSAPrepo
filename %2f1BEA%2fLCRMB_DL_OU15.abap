FUNCTION /1BEA/CRMB_DL_O_REOPEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IV_CAUSE) TYPE  BEA_CANCEL_REASON DEFAULT 'A'
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      ERROR
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
* Welche Felder des alten DLIs werden in den neuen übernommen?
* Die Vorschlagsfakturaart und der Positionstyp sowie sämtlcihe
* Felder des freien Teils
*....................................................................
* Declaration Part
*....................................................................
  CONSTANTS:
    LC_FUNCNAME   TYPE FUNCNAME VALUE '/1BEA/CRMB_DL_O_REOPEN'.
  DATA:
    LS_ITC        TYPE BEAS_ITC_WRK,
    LT_DLI        TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI        TYPE /1BEA/S_CRMB_DLI_WRK,
    LS_DLI_OV     TYPE /1BEA/S_CRMB_DLI_WRK,
    LRS_DERIV_CATEGORY TYPE /1BEA/RS_CRMB_DERIV_CATEGORY,
    LRT_DERIV_CATEGORY TYPE /1BEA/RT_CRMB_DERIV_CATEGORY,
    LRS_LOGSYS TYPE /1BEA/RS_CRMB_LOGSYS,
    LRT_LOGSYS TYPE /1BEA/RT_CRMB_LOGSYS,
    LRS_OBJTYPE TYPE /1BEA/RS_CRMB_OBJTYPE,
    LRT_OBJTYPE TYPE /1BEA/RT_CRMB_OBJTYPE,
    LRS_SRC_HEADNO TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    LRT_SRC_HEADNO TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    LRS_SRC_ITEMNO TYPE /1BEA/RS_CRMB_SRC_ITEMNO,
    LRT_SRC_ITEMNO TYPE /1BEA/RT_CRMB_SRC_ITEMNO,
    LV_RETURNCODE TYPE SYSUBRC.
*====================================================================
* Implementation
*====================================================================
*--------------------------------------------------------------------
* check import parameters
*--------------------------------------------------------------------
  IF IV_CAUSE <> GC_CAUSE_CANCEL AND
     IV_CAUSE <> GC_CAUSE_REJECT.
    MESSAGE E001(BEA) WITH LC_FUNCNAME RAISING WRONG_INPUT.
  ENDIF.
*--------------------------------------------------------------------
* Put input in local variable
*--------------------------------------------------------------------
  LS_DLI = IS_DLI.
*--------------------------------------------------------------------
* If the cause for CANCEL is not REJECT -> Look for Open Version
*--------------------------------------------------------------------
  CLEAR LS_DLI_OV.
  IF NOT iv_cause = GC_CAUSE_REJECT.
     CLEAR: LRS_DERIV_CATEGORY, LRT_DERIV_CATEGORY.
     LRS_DERIV_CATEGORY-SIGN   = GC_INCLUDE.
     LRS_DERIV_CATEGORY-OPTION = GC_EQUAL.
     LRS_DERIV_CATEGORY-LOW    = LS_DLI-DERIV_CATEGORY.
     APPEND LRS_DERIV_CATEGORY TO LRT_DERIV_CATEGORY.
     CLEAR: LRS_LOGSYS, LRT_LOGSYS.
     LRS_LOGSYS-SIGN   = GC_INCLUDE.
     LRS_LOGSYS-OPTION = GC_EQUAL.
     LRS_LOGSYS-LOW    = LS_DLI-LOGSYS.
     APPEND LRS_LOGSYS TO LRT_LOGSYS.
     CLEAR: LRS_OBJTYPE, LRT_OBJTYPE.
     LRS_OBJTYPE-SIGN   = GC_INCLUDE.
     LRS_OBJTYPE-OPTION = GC_EQUAL.
     LRS_OBJTYPE-LOW    = LS_DLI-OBJTYPE.
     APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
     CLEAR: LRS_SRC_HEADNO, LRT_SRC_HEADNO.
     LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
     LRS_SRC_HEADNO-OPTION = GC_EQUAL.
     LRS_SRC_HEADNO-LOW    = LS_DLI-SRC_HEADNO.
     APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
     CLEAR: LRS_SRC_ITEMNO, LRT_SRC_ITEMNO.
     LRS_SRC_ITEMNO-SIGN   = GC_INCLUDE.
     LRS_SRC_ITEMNO-OPTION = GC_EQUAL.
     LRS_SRC_ITEMNO-LOW    = LS_DLI-SRC_ITEMNO.
     APPEND LRS_SRC_ITEMNO TO LRT_SRC_ITEMNO.
     CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
          EXPORTING
            IV_SORTREL        = GC_SORT_BY_EXTERNAL_REF
            IRT_DERIV_CATEGORY    = LRT_DERIV_CATEGORY
            IRT_LOGSYS    = LRT_LOGSYS
            IRT_OBJTYPE    = LRT_OBJTYPE
            IRT_SRC_HEADNO    = LRT_SRC_HEADNO
            IRT_SRC_ITEMNO    = LRT_SRC_ITEMNO
          IMPORTING
            ET_DLI          = LT_DLI.
     CALL FUNCTION '/1BEA/CRMB_DL_O_GET_CHANGEABL'
          EXPORTING
            IT_DLI          = LT_DLI
          IMPORTING
            ES_DLI_OV       = LS_DLI_OV.
  ENDIF.
*--------------------------------------------------------------------
* get customizing for item category
*--------------------------------------------------------------------
  CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
    EXPORTING
      IV_APPL          = GC_APPL
      IV_ITC           = LS_DLI-ITEM_CATEGORY
    IMPORTING
      ES_ITC_WRK       = LS_ITC
    EXCEPTIONS
      OBJECT_NOT_FOUND = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            RAISING ERROR.
  ENDIF.
*====================================================================
* Reopen (copy) or Update existing open FV
*====================================================================
*--------------------------------------------------------------------
* If no open version exists, create new duelist item
*--------------------------------------------------------------------
  IF LS_DLI_OV IS INITIAL OR
     LS_DLI_OV-INCOMP_ID = 'B'.
    PERFORM REOPEN
      USING
        IV_CAUSE
        LS_ITC
      CHANGING
        LS_DLI
        LV_RETURNCODE.
  ELSEIF NOT LS_DLI_OV-INCOMP_ID IS INITIAL AND
         NOT LS_DLI_OV-SRC_REJECT IS INITIAL.
*    CONTINUE.
  ELSE.
*--------------------------------------------------------------------
* Otherwise, update from IS_DLI to latest version
*--------------------------------------------------------------------
    PERFORM REOPEN_BY_UPD
      USING
        LS_DLI_OV
        LS_ITC
      CHANGING
        LS_DLI
        LV_RETURNCODE.
  ENDIF. "IF LS_DLI_LV IS INITIAL
*--------------------------------------------------------------------
* End Processing
*--------------------------------------------------------------------
  IF LV_RETURNCODE IS INITIAL.

    IF LS_DLI-BILL_RELEVANCE EQ GC_BILL_REL_UN_DEF.
      LS_DLI-BILL_RELEVANCE = GC_BILL_REL_ORDER.
      IF
       NOT LS_DLI-P_LOGSYS IS INITIAL AND
       NOT LS_DLI-P_OBJTYPE IS INITIAL AND
       NOT LS_DLI-P_SRC_HEADNO IS INITIAL AND
       NOT LS_DLI-P_SRC_ITEMNO IS INITIAL.
        LS_DLI-BILL_RELEVANCE = GC_BILL_REL_DELIVERY.
      ENDIF.
    ENDIF.
    ES_DLI = LS_DLI.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            RAISING ERROR.
  ENDIF.
ENDFUNCTION.

* -------------------------------------------------------------
* Create new duelist item from billed item
* -------------------------------------------------------------
FORM REOPEN
     USING
       UV_CAUSE      TYPE BEA_REVERSAL
       US_ITC        TYPE BEAS_ITC_WRK
     CHANGING
       CS_DLI        TYPE /1BEA/S_CRMB_DLI_WRK
       CV_RETURNCODE TYPE SYSUBRC.

  DATA:
    LS_DLI_OLD    TYPE /1BEA/S_CRMB_DLI_WRK.

* keep status quo for purposes of copying
  LS_DLI_OLD = CS_DLI.

  CLEAR CS_DLI-BDI_GUID.
  CS_DLI-MAINT_USER  = SY-UNAME.
  CS_DLI-MAINT_DATE  = SY-DATLO.
  CS_DLI-MAINT_TIME  = SY-TIMLO.
  CS_DLI-UPD_TYPE    = GC_INSERT.

  IF UV_CAUSE = GC_REVERSAL_CANCEL.
    CS_DLI-BILL_STATUS = GC_BILLSTAT_TODO.
    IF  CS_DLI-INCOMP_ID = GC_INCOMP_CANCEL.
      CLEAR CS_DLI-INCOMP_ID.
    ENDIF.
  ELSE. "i.e. UV_CAUSE = GC_REVERSAL_REJECT
    CS_DLI-SRC_REJECT  = GC_SRC_DELETE.
    CS_DLI-BILL_STATUS = GC_BILLSTAT_REJECT.
  ENDIF.

  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      EV_GUID_16 = CS_DLI-DLI_GUID.

* Event DL_OREO1
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO1PARODL_COP.
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO1PRCODL_COP.
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO1TXTODL_COP.
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO1ICBODL_RO.
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO1DRBODL_COP.

ENDFORM. "REOPEN

* -------------------------------------------------------------
* Update existing open due list item
* -------------------------------------------------------------
FORM REOPEN_BY_UPD
     USING
       US_DLI_OV     TYPE /1BEA/S_CRMB_DLI_WRK
       US_ITC        TYPE BEAS_ITC_WRK
     CHANGING
       CS_DLI        TYPE /1BEA/S_CRMB_DLI_WRK
       CV_RETURNCODE TYPE SYSUBRC.


* Event DL_OREO2
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO2PRDODL_QTA.
  INCLUDE %2f1BEA%2fX_CRMBDL_OREO2ICBODL_RO.

  CS_DLI-UPD_TYPE = GC_UPDATE.

ENDFORM.  "REOPEN_BY_UPD

