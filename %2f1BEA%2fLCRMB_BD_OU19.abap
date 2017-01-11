FUNCTION /1BEA/CRMB_BD_O_SPLIT_ANALYZE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH_WRK_L) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BDH_WRK_R) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(ET_SPLIT) TYPE  BEAT_SPLALY
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
* Time  : 13:52:50
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LT_SPLIT     TYPE BEAT_SPLALY.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* ANALYZE HEADER
*---------------------------------------------------------------------
  PERFORM ANALYZE_BILL_DOCUMENTS
    USING    IS_BDH_WRK_L
             IS_BDH_WRK_R
    CHANGING LT_SPLIT.

*--------------------------------------------------------------------
* Add analyze header for service
*--------------------------------------------------------------------
* Event BD_OSPA0
  INCLUDE %2f1BEA%2fX_CRMBBD_OSPA0PAROBD_AH.

*---------------------------------------------------------------------
* COMPLETE RESULT
*---------------------------------------------------------------------
  PERFORM COMPLETE_SPLIT
    CHANGING LT_SPLIT.
  ET_SPLIT = LT_SPLIT.

  IF ET_SPLIT IS INITIAL.
    MESSAGE S167(BEA) WITH
       IS_BDH_WRK_L-HEADNO_EXT IS_BDH_WRK_R-HEADNO_EXT.
  ENDIF.

ENDFUNCTION.

*---------------------------------------------------------------------
*       Form  ANALYZE_BILL_DOCUMENTS
*---------------------------------------------------------------------
FORM ANALYZE_BILL_DOCUMENTS
  USING    IS_BDH_L TYPE /1BEA/S_CRMB_BDH_WRK
           IS_BDH_R TYPE /1BEA/S_CRMB_BDH_WRK
  CHANGING CT_SPLIT TYPE BEAT_SPLALY.
  DATA:
    LT_FIELDS       TYPE DD03TTYP,
    LS_FIELDS       LIKE DD03P,
    LS_SPLIT        TYPE BEAS_SPLALY,
    LS_BDH_CMP_L    TYPE /1BEA/S_CRMB_BDH_CMP,
    LS_BDH_CMP_R    TYPE /1BEA/S_CRMB_BDH_CMP.
  FIELD-SYMBOLS:
    <VALUE1>,
    <VALUE2>.
  CONSTANTS:
    LC_BDH_CMP TYPE DDOBJNAME VALUE '/1BEA/S_CRMB_BDH_CMP'.
*
  MOVE-CORRESPONDING IS_BDH_L TO LS_BDH_CMP_L.
  MOVE-CORRESPONDING IS_BDH_R TO LS_BDH_CMP_R.
* assign same values To Components Excluded from Comparison (CEC)
  LS_BDH_CMP_L-NET_VALUE = LS_BDH_CMP_R-NET_VALUE.
  LS_BDH_CMP_L-TAX_VALUE = LS_BDH_CMP_R-TAX_VALUE.

  CALL FUNCTION 'DDIF_TABL_GET'
       EXPORTING
            NAME          = LC_BDH_CMP
       TABLES
            DD03P_TAB     = LT_FIELDS
       EXCEPTIONS
            ILLEGAL_INPUT = 0
            OTHERS        = 0.

  DELETE LT_FIELDS WHERE NOT PRECFIELD IS INITIAL.
  SY-SUBRC = 0.

  WHILE SY-SUBRC = 0.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE LS_BDH_CMP_L TO <VALUE1>.
    CHECK SY-SUBRC = 0.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE LS_BDH_CMP_R TO <VALUE2>.
    IF <VALUE1> <> <VALUE2>.
      READ TABLE LT_FIELDS INDEX SY-INDEX INTO LS_FIELDS.
      CHECK SY-SUBRC = 0.
      CLEAR LS_SPLIT.
      CASE LS_FIELDS-FIELDNAME.
        WHEN 'CRP_GUID'.
          PERFORM CONVERT_GUID_TO_EXTERN
            USING    LS_FIELDS-FIELDNAME
                     <VALUE1>
                     <VALUE2>
            CHANGING LS_SPLIT-ROLLNAME
                     LS_SPLIT-VALUE_L
                     LS_SPLIT-VALUE_R.
        WHEN OTHERS.
          WRITE <VALUE1> TO LS_SPLIT-VALUE_L.
          WRITE <VALUE2> TO LS_SPLIT-VALUE_R.
          LS_SPLIT-ROLLNAME = LS_FIELDS-ROLLNAME.
      ENDCASE.
      LS_SPLIT-SPLIT_REASON = GC_HEAD.
      LS_SPLIT-FIELDNAME    = LS_FIELDS-FIELDNAME.
      APPEND LS_SPLIT TO CT_SPLIT.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " ANALYZE_BILL_DOCUMENTS

*---------------------------------------------------------------------
*      Form  CONVERT_GUID_TO_EXTERN
*---------------------------------------------------------------------
FORM CONVERT_GUID_TO_EXTERN
  USING    IV_FIELDNAME TYPE FIELDNAME
           IV_GUID_L    TYPE BEA_CRP_GUID
           IV_GUID_R    TYPE BEA_CRP_GUID
  CHANGING CV_ROLLNAME  TYPE ROLLNAME
           CV_VALUE_L   TYPE ANY
           CV_VALUE_R   TYPE ANY.
  DATA:
    LS_CRP    TYPE BEAS_CRP.
  CASE IV_FIELDNAME.
    WHEN 'CRP_GUID'.
      IF NOT IV_GUID_L IS INITIAL.
        CALL FUNCTION 'BEA_CRP_O_GETDETAIL'
          EXPORTING
            IV_APPL                = GC_APPL
            IV_CRP_GUID            = IV_GUID_L
          IMPORTING
            ES_CRP                 = LS_CRP
          EXCEPTIONS
            OBJECT_NOT_FOUND       = 1
            OTHERS                 = 2.
        IF SY-SUBRC = 0.
          CV_VALUE_L = LS_CRP-CR_NUMBER.
        ENDIF.
      ENDIF.
      IF NOT IV_GUID_R IS INITIAL.
        CLEAR LS_CRP.
        CALL FUNCTION 'BEA_CRP_O_GETDETAIL'
          EXPORTING
            IV_APPL                = GC_APPL
            IV_CRP_GUID            = IV_GUID_R
          IMPORTING
            ES_CRP                 = LS_CRP
          EXCEPTIONS
            OBJECT_NOT_FOUND       = 1
            OTHERS                 = 2.
        IF SY-SUBRC = 0.
          CV_VALUE_R = LS_CRP-CR_NUMBER.
        ENDIF.
      ENDIF.
      CV_ROLLNAME = 'BEA_CRP_NUMBER'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "CONVERT_GUID_TO_EXTERN

*---------------------------------------------------------------------
*       Form  COMPLETE_SPLIT
*---------------------------------------------------------------------
FORM COMPLETE_SPLIT
  CHANGING CT_SPLIT TYPE BEAT_SPLALY.
  DATA:
    LS_SPLIT     TYPE BEAS_SPLALY,
    LS_DTEL      TYPE DD04V.

  LOOP AT CT_SPLIT INTO LS_SPLIT.
    CALL FUNCTION 'DDIF_DTEL_GET'
         EXPORTING
              NAME          = LS_SPLIT-ROLLNAME
              LANGU         = SY-LANGU
         IMPORTING
              DD04V_WA      = LS_DTEL
         EXCEPTIONS
              ILLEGAL_INPUT = 0
              OTHERS        = 0.

    LS_SPLIT-SPLALY_FIELD_T = LS_DTEL-SCRTEXT_L.

*--------------------------------------------------------------------
* Event for complete Split
*--------------------------------------------------------------------
* Event BD_OSPA1
    INCLUDE %2f1BEA%2fX_CRMBBD_OSPA1PAROBD_EHS.

    MODIFY CT_SPLIT FROM LS_SPLIT.
  ENDLOOP.

ENDFORM.                    " COMPLETE_SPLIT

*--------------------------------------------------------------------
* Add formroutines
*--------------------------------------------------------------------
* Event BD_OSPAZ
  INCLUDE %2f1BEA%2fX_CRMBBD_OSPAZPAROBD_AHZ.

