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
*--------------------------------------------------------------------*
*     FORM bdh_pricing
*--------------------------------------------------------------------*
*     Pricing per document (add items and update)
*--------------------------------------------------------------------*
FORM PRCOBD_B1Z_BDH_PRICING
  CHANGING
    CS_BDH_WRK TYPE /1BEA/S_CRMB_BDH_WRK.
  DATA:
    LT_RETURN  TYPE BEAT_RETURN,
    LT_BDI_WRK TYPE /1BEA/T_CRMB_BDI_WRK,
    LS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK,
    LV_EXT_LOG TYPE BEA_BOOLEAN.
  CLEAR LT_RETURN.
  CLEAR CS_BDH_WRK-TAX_VALUE.
  CLEAR CS_BDH_WRK-NET_VALUE.
  READ TABLE GT_BDI_WRK
    WITH KEY BDH_GUID = CS_BDH_WRK-BDH_GUID
    BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_BDI_WRK INTO LS_BDI_WRK FROM SY-TABIX.
      IF LS_BDI_WRK-BDH_GUID = CS_BDH_WRK-BDH_GUID.
*        CLEAR LS_BDI_WRK-NET_VALUE.
*        CLEAR LS_BDI_WRK-TAX_VALUE.
*        CLEAR LS_BDI_WRK-GROSS_VALUE.
        IF LS_BDI_WRK-IS_REVERSED EQ GC_IS_REVED_BY_CORR.
          LS_BDI_WRK-IS_REVERSED = GC_IS_REVED_NO_FIX.
        ENDIF.
        APPEND LS_BDI_WRK TO LT_BDI_WRK.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF GS_CRP IS INITIAL.
    LV_EXT_LOG = GC_TRUE.
  ENDIF.
  CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_IT_CREATE'
      EXPORTING
         IS_BDH           = CS_BDH_WRK
         IT_BDI           = LT_BDI_WRK
         IV_EXTENDED_LOG  = LV_EXT_LOG
     IMPORTING
         ES_BDH           = CS_BDH_WRK
         ET_BDI           = LT_BDI_WRK
         ET_RETURN        = LT_RETURN
     EXCEPTIONS
         INCOMPLETE       = 1
         OTHERS           = 2.
  IF SY-SUBRC NE 0 OR LT_RETURN is not initial.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'BD'
        IV_CONTAINER   = 'BDH'
        IS_BDH         = CS_BDH_WRK
        IT_RETURN      = LT_RETURN.
  ENDIF.
  LOOP AT LT_BDI_WRK INTO LS_BDI_WRK.
    READ TABLE GT_BDI_WRK
       WITH KEY BDH_GUID   = LS_BDI_WRK-BDH_GUID
                ITEMNO_EXT = LS_BDI_WRK-ITEMNO_EXT
      TRANSPORTING NO FIELDS BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      ADD LS_BDI_WRK-NET_VALUE TO CS_BDH_WRK-NET_VALUE.
      ADD LS_BDI_WRK-TAX_VALUE TO CS_BDH_WRK-TAX_VALUE.
      IF LS_BDI_WRK-IS_REVERSED EQ GC_IS_REVED_NO_FIX.
        LS_BDI_WRK-IS_REVERSED = GC_IS_REVED_BY_CORR.
      ENDIF.
      MODIFY GT_BDI_WRK FROM LS_BDI_WRK INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "bdh_pricing
