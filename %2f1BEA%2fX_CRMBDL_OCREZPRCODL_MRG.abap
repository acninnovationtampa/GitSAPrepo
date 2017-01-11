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
*--------------------------------------------------------------------*
*      Form  Condition_Merge
*--------------------------------------------------------------------*
FORM PRCODL_MRG_CONDITION_MERGE
  USING
    US_REF_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_CONDITION   TYPE BEAT_PRC_COM.

  DATA:
    LS_CONDITION   TYPE BEAS_PRC_COM,
    LT_PRCD_COND   TYPE PRCT_COND_DU_TAB,
    LS_PRCD_COND   TYPE PRCD_COND,
    LRS_ITEM_NO    TYPE PRCT_ITEM_NO_RS,
    LRT_ITEM_NO    TYPE PRCT_ITEM_NO_RT,
    LT_PRIDOC_GUID TYPE PRCT_PRIDOC_GUID_T.

  IF NOT US_REF_DLI_WRK-PRIDOC_GUID IS INITIAL.
    INSERT US_REF_DLI_WRK-PRIDOC_GUID INTO TABLE LT_PRIDOC_GUID.
    LRS_ITEM_NO-SIGN   = GC_SIGN_INCLUDE.
    LRS_ITEM_NO-OPTION = GC_EQUAL.
    LRS_ITEM_NO-LOW    = US_REF_DLI_WRK-SRC_PRC_GUID.
    APPEND LRS_ITEM_NO TO LRT_ITEM_NO.
    CALL FUNCTION 'PRC_PRIDOC_SELECT_MULTI_DB'
      EXPORTING
        IT_PRIDOC_GUID       = LT_PRIDOC_GUID
        IRT_ITEM_NO          = LRT_ITEM_NO
      IMPORTING
        ET_COND              = LT_PRCD_COND.
    LOOP AT LT_PRCD_COND INTO LS_PRCD_COND.
      CLEAR LS_CONDITION.
      MOVE-CORRESPONDING LS_PRCD_COND TO LS_CONDITION.
      INSERT LS_CONDITION INTO TABLE CT_CONDITION.
    ENDLOOP.
  ENDIF.
ENDFORM.                        "CONDITION_MERGE
