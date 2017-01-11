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
*-----------------------------------------------------------------*
*     FORM PRCODL_ELZ_ERL_GET_PRC_DATA
*-----------------------------------------------------------------*
FORM PRCODL_ELZ_ERL_GET_PRC_DATA
  USING
    UV_PARENTRECNO TYPE SYTABIX
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_COM     TYPE /1BEA/S_CRMB_DLI_COM
    CT_CONDITION   TYPE BEAT_DLI_PRC_COM.

  DATA:
    LS_COND           TYPE PRCD_COND,
    LT_COND           TYPE PRCT_COND_DU_TAB,
    LS_CONDITION      TYPE BEAS_DLI_PRC_COM.

  PERFORM PRCODL_ELZ_ERL_GET_CONDITION
    USING
      US_DLI_WRK
    CHANGING
      LT_COND.
  READ TABLE LT_COND INTO LS_COND INDEX 1.
  IF SY-SUBRC EQ 0 AND NOT US_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
    CS_DLI_COM-SRC_PRIDOC_GUID = LS_COND-KNUMV.
  ENDIF.
  LOOP AT LT_COND INTO LS_COND.
    MOVE-CORRESPONDING LS_COND TO LS_CONDITION.
    LS_CONDITION-PARENTRECNO = UV_PARENTRECNO.
    APPEND LS_CONDITION TO CT_CONDITION.
  ENDLOOP.
ENDFORM.
*-----------------------------------------------------------------*
*     FORM PRCODL_ELZ_ERL_GET_PRC_DRV
*-----------------------------------------------------------------*
FORM PRCODL_ELZ_ERL_GET_PRC_DRV
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_DLI_INT     TYPE /1BEA/S_CRMB_DLI_INT
    CT_CONDITION   TYPE BEAT_PRC_COM.

  DATA:
    LS_CONDITION      TYPE BEAS_PRC_COM,
    LS_COND           TYPE PRCD_COND,
    LT_COND           TYPE PRCT_COND_DU_TAB.

  PERFORM PRCODL_ELZ_ERL_GET_CONDITION
    USING
      US_DLI_WRK
    CHANGING
      LT_COND.

  READ TABLE LT_COND INTO LS_COND INDEX 1.
  IF SY-SUBRC EQ 0 AND NOT US_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
    CS_DLI_INT-SRC_PRIDOC_GUID = LS_COND-KNUMV.
  ENDIF.
  LOOP AT LT_COND INTO LS_COND.
    MOVE-CORRESPONDING LS_COND TO LS_CONDITION.
    APPEND LS_CONDITION TO CT_CONDITION.
  ENDLOOP.
ENDFORM.
*-----------------------------------------------------------------*
*     FORM PRDODL_ELZ_ERL_GET_CONDITION
*-----------------------------------------------------------------*
FORM PRCODL_ELZ_ERL_GET_CONDITION
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_COND        TYPE PRCT_COND_DU_TAB.

  DATA:
    LV_ITEM_NO        TYPE PRCT_ITEM_NO,
    LRS_ITEM_NO       TYPE PRCT_ITEM_NO_RS,
    LRT_ITEM_NO       TYPE PRCT_ITEM_NO_RT,
    LT_CONDITION_GUID TYPE PRCT_PRIDOC_GUID_T.

  LV_ITEM_NO = US_DLI_WRK-DLI_GUID.
  IF NOT US_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
    IF US_DLI_WRK-SRC_PRC_GUID IS INITIAL.
      LV_ITEM_NO = US_DLI_WRK-SRC_GUID.
    ELSE.
      LV_ITEM_NO = US_DLI_WRK-SRC_PRC_GUID.
    ENDIF.
  ENDIF.
  CLEAR LT_CONDITION_GUID.
  APPEND US_DLI_WRK-PRIDOC_GUID TO LT_CONDITION_GUID.
  CLEAR LRS_ITEM_NO.
  CLEAR LRT_ITEM_NO.
  LRS_ITEM_NO-SIGN   = GC_INCLUDE.
  LRS_ITEM_NO-OPTION = GC_EQUAL.
  LRS_ITEM_NO-LOW    = LV_ITEM_NO.
  APPEND LRS_ITEM_NO TO LRT_ITEM_NO.
  CALL FUNCTION 'PRC_PRIDOC_SELECT_MULTI_DB'
    EXPORTING
      IT_PRIDOC_GUID = LT_CONDITION_GUID
      IRT_ITEM_NO    = LRT_ITEM_NO
    IMPORTING
      ET_COND        = CT_COND.
ENDFORM.