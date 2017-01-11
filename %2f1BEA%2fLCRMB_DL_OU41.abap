FUNCTION /1BEA/CRMB_DL_O_DOCFLOW_MAINT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IV_BILL_STATUS) TYPE  BEA_BILL_STATUS
*"     REFERENCE(IV_BDI_GUID) TYPE  BEA_BDI_GUID
*"  EXPORTING
*"     VALUE(ES_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK
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
  DATA:
    LS_DLI_WRK  TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_TABIX    TYPE SYTABIX,
    LV_IMPL_BR  TYPE BEA_BILL_RELEVANCE.

  LV_IMPL_BR = GC_BILL_REL_ORDER.
  IF
     NOT IS_DLI_WRK-P_LOGSYS IS INITIAL AND
     NOT IS_DLI_WRK-P_OBJTYPE IS INITIAL AND
     NOT IS_DLI_WRK-P_SRC_HEADNO IS INITIAL AND
     NOT IS_DLI_WRK-P_SRC_ITEMNO IS INITIAL.
    LV_IMPL_BR = GC_BILL_REL_DELIVERY.
  ENDIF.
  SORT GT_DLI_WRK BY DLI_GUID.
  READ TABLE GT_DLI_WRK INTO LS_DLI_WRK
                        WITH KEY DLI_GUID = IS_DLI_WRK-DLI_GUID
                        BINARY SEARCH.
  LV_TABIX = SY-TABIX.
  IF SY-SUBRC IS INITIAL.
    LS_DLI_WRK-BDI_GUID    = IV_BDI_GUID.
    LS_DLI_WRK-BILL_STATUS = IV_BILL_STATUS.
    IF LS_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_UN_DEF.
      LS_DLI_WRK-BILL_RELEVANCE = LV_IMPL_BR.
    ENDIF.
    MODIFY GT_DLI_WRK FROM LS_DLI_WRK INDEX LV_TABIX
                      TRANSPORTING BILL_STATUS
                                   BDI_GUID
                                   BILL_RELEVANCE.
  ELSE.
    CASE SY-SUBRC.
      WHEN 4.
        LS_DLI_WRK = IS_DLI_WRK.
        LS_DLI_WRK-BDI_GUID    = IV_BDI_GUID.
        LS_DLI_WRK-BILL_STATUS = IV_BILL_STATUS.
        IF LS_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_UN_DEF.
          LS_DLI_WRK-BILL_RELEVANCE = LV_IMPL_BR.
        ENDIF.
        LS_DLI_WRK-UPD_TYPE    = GC_UPDATE.
        INSERT LS_DLI_WRK INTO GT_DLI_WRK INDEX SY-TABIX.
      WHEN 8.
        LS_DLI_WRK = IS_DLI_WRK.
        LS_DLI_WRK-BDI_GUID    = IV_BDI_GUID.
        LS_DLI_WRK-BILL_STATUS = IV_BILL_STATUS.
        IF LS_DLI_WRK-BILL_RELEVANCE EQ GC_BILL_REL_UN_DEF.
          LS_DLI_WRK-BILL_RELEVANCE = LV_IMPL_BR.
        ENDIF.
        LS_DLI_WRK-UPD_TYPE    = GC_UPDATE.
        APPEND LS_DLI_WRK TO GT_DLI_WRK.
    ENDCASE.
  ENDIF.
  ES_DLI_WRK = LS_DLI_WRK.

ENDFUNCTION.
