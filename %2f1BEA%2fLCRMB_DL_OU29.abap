FUNCTION /1BEA/CRMB_DL_O_BUILD_DOCVIEW.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(IV_HEAD_DL) TYPE  BEA_BOOLEAN OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BAPIMAXROW
*"         DEFAULT                    0
*"  EXPORTING
*"     REFERENCE(ET_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"     REFERENCE(ET_DLH) TYPE  /1BEA/T_CRMB_DLI_WRK
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
* It is required that no value or amount fields
* form the source doc header as no special
* treatment (= summing up) is implemented

  CONSTANTS:
    LC_HEAD            TYPE C VALUE 'A',
    LC_ITEM            TYPE C VALUE 'B'.
  DATA:
    LV_LINENO          TYPE I,
    LV_NEW_HEAD        TYPE BEA_BOOLEAN,
    LS_DLI_HEADKEY     TYPE /1BEA/US_CRMB_DL_DLI_SRCDLHD,
    LS_DLI_HEADKEY_OLD TYPE /1BEA/US_CRMB_DL_DLI_SRCDLHD.
  DATA:
    LS_DLI_ITEMKEY     TYPE /1BEA/US_CRMB_DL_DLI_SRC_IID,
    LS_DLI_ITEMKEY_OLD TYPE /1BEA/US_CRMB_DL_DLI_SRC_IID,
    LS_DLH             TYPE /1BEA/US_CRMB_DL_DLI_DLH,
    LS_DL_HEAD         TYPE /1BEA/US_CRMB_DL_DLI_DLH,
    LS_DLI             TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI             TYPE /1BEA/T_CRMB_DLI_WRK,
    LS_DLI_HEAD        TYPE /1BEA/S_CRMB_DLI_WRK.

  DATA: LV_TABIX TYPE SYTABIX,
        LV_TABIX_OLD TYPE SYTABIX.

  CLEAR:
    ET_DLH.

  LT_DLI = IT_DLI.

  SORT LT_DLI BY
                 SRC_HEADNO
                 OBJTYPE
                 BILL_CATEGORY
                 DERIV_CATEGORY
                 LOGSYS
                 SRC_ITEMNO
                 BILL_DATE
                 MAINT_DATE DESCENDING
                 MAINT_TIME DESCENDING.

  LV_TABIX_OLD = 1.
  LOOP AT LT_DLI INTO LS_DLI.
    LV_NEW_HEAD = GC_FALSE.
    MOVE-CORRESPONDING LS_DLI TO LS_DLI_HEADKEY.
* If new source document, insert previous header into output table
    IF NOT LS_DLI_HEADKEY = LS_DLI_HEADKEY_OLD.
      LS_DLI_HEADKEY_OLD = LS_DLI_HEADKEY.
      LV_NEW_HEAD = GC_TRUE.
    ENDIF.
    IF LV_NEW_HEAD = GC_TRUE.
      IF NOT LS_DLI_HEAD IS INITIAL.
        LS_DLI_HEAD-DLI_UITYPE = LC_HEAD.
        IF IV_HEAD_DL IS INITIAL.
          INSERT LS_DLI_HEAD INTO ET_DLI INDEX LV_TABIX_OLD.
          LV_TABIX_OLD = LV_TABIX + 2.
        ELSE.
          APPEND LS_DLI_HEAD TO ET_DLH.
* Check Search Threshold (PCUI!)
          LV_LINENO = LV_LINENO + 1.
          IF IV_HEAD_DL = GC_TRUE  AND
            IV_MAXROWS IS SUPPLIED AND
            LV_LINENO = IV_MAXROWS.
            LV_TABIX = LV_TABIX + 1.
            DELETE LT_DLI FROM LV_TABIX.
            ET_DLI = LT_DLI.
            RETURN.
          ENDIF.
        ENDIF.
        CLEAR LS_DLI_HEAD.
      ENDIF.
      MOVE-CORRESPONDING LS_DLI TO LS_DLH.
      MOVE-CORRESPONDING LS_DLH TO LS_DLI_HEAD.
      LS_DL_HEAD-DERIV_CATEGORY = LS_DLI-DERIV_CATEGORY.
      LS_DL_HEAD-LOGSYS = LS_DLI-LOGSYS.
      LS_DL_HEAD-OBJTYPE = LS_DLI-OBJTYPE.
      LS_DL_HEAD-SRC_HEADNO = LS_DLI-SRC_HEADNO.
      LS_DL_HEAD-BILL_DATE = LS_DLI-BILL_DATE.
      LS_DL_HEAD-BILL_ORG = LS_DLI-BILL_ORG.
      LS_DL_HEAD-BILL_TYPE = LS_DLI-BILL_TYPE.
      LS_DL_HEAD-PAYER = LS_DLI-PAYER.
      LS_DL_HEAD-SRC_PROCESS_TYPE = LS_DLI-SRC_PROCESS_TYPE.
      LS_DL_HEAD-BILL_BLOCK = LS_DLI-BILL_BLOCK.
      LS_DL_HEAD-SOLD_TO_PARTY = LS_DLI-SOLD_TO_PARTY.
    ENDIF.
    MOVE-CORRESPONDING LS_DLI TO LS_DLI_ITEMKEY.
* If new item, compare to previous ones: Clear header field(s) if
* distinct values in one source document exist
    IF NOT LS_DLI_ITEMKEY = LS_DLI_ITEMKEY_OLD.
      LS_DLI-DLI_UITYPE = LC_ITEM.
       IF NOT LS_DLI-DERIV_CATEGORY = LS_DL_HEAD-DERIV_CATEGORY.
         CLEAR LS_DLI_HEAD-DERIV_CATEGORY.
       ENDIF.
       IF NOT LS_DLI-LOGSYS = LS_DL_HEAD-LOGSYS.
         CLEAR LS_DLI_HEAD-LOGSYS.
       ENDIF.
       IF NOT LS_DLI-OBJTYPE = LS_DL_HEAD-OBJTYPE.
         CLEAR LS_DLI_HEAD-OBJTYPE.
       ENDIF.
       IF NOT LS_DLI-SRC_HEADNO = LS_DL_HEAD-SRC_HEADNO.
         CLEAR LS_DLI_HEAD-SRC_HEADNO.
       ENDIF.
       IF NOT LS_DLI-BILL_DATE = LS_DL_HEAD-BILL_DATE.
         CLEAR LS_DLI_HEAD-BILL_DATE.
       ENDIF.
       IF NOT LS_DLI-BILL_ORG = LS_DL_HEAD-BILL_ORG.
         CLEAR LS_DLI_HEAD-BILL_ORG.
       ENDIF.
       IF NOT LS_DLI-BILL_TYPE = LS_DL_HEAD-BILL_TYPE.
         CLEAR LS_DLI_HEAD-BILL_TYPE.
       ENDIF.
       IF NOT LS_DLI-PAYER = LS_DL_HEAD-PAYER.
         CLEAR LS_DLI_HEAD-PAYER.
       ENDIF.
       IF NOT LS_DLI-SRC_PROCESS_TYPE = LS_DL_HEAD-SRC_PROCESS_TYPE.
         CLEAR LS_DLI_HEAD-SRC_PROCESS_TYPE.
       ENDIF.
       IF NOT LS_DLI-BILL_BLOCK = LS_DL_HEAD-BILL_BLOCK.
         CLEAR LS_DLI_HEAD-BILL_BLOCK.
       ENDIF.
       IF NOT LS_DLI-SOLD_TO_PARTY = LS_DL_HEAD-SOLD_TO_PARTY.
         CLEAR LS_DLI_HEAD-SOLD_TO_PARTY.
       ENDIF.
    ENDIF.
    IF IV_HEAD_DL IS INITIAL.
      APPEND LS_DLI TO ET_DLI.
    ENDIF.
    LV_TABIX = SY-TABIX.
  ENDLOOP.

  LS_DLI_HEAD-DLI_UITYPE = LC_HEAD.
  IF IV_HEAD_DL IS INITIAL.
    INSERT LS_DLI_HEAD INTO ET_DLI INDEX LV_TABIX_OLD.
  ELSE.
    APPEND LS_DLI_HEAD TO ET_DLH.
    ET_DLI = LT_DLI.
  ENDIF.

ENDFUNCTION.
