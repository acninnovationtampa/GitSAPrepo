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
*-------------------------------------------------------------------
*     FORM PARENT_ITEM_FILL
*-------------------------------------------------------------------
FORM PITOBD_RNZ_PARENT_ITEM_FILL
  USING
    US_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK.
  DATA:
    LS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK,
    LT_DLI_WRK TYPE /1BEA/T_CRMB_DLI_WRK.

* parent item already specified by correction process
  CHECK CS_BDI_WRK-REVERSAL <> GC_REVERSAL_CORREC.
  CHECK CS_BDI_WRK-ITEM_TYPE <> GC_ITEM_TYPE_STRUCT AND
        CS_BDI_WRK-ITEM_TYPE <> GC_ITEM_TYPE_ACCRUAL.
  CLEAR CS_BDI_WRK-PARENT_ITEMNO.
  CALL FUNCTION '/1BEA/CRMB_DL_O_BUFFER_GET'
    IMPORTING
      ET_DLI_WRK = LT_DLI_WRK.
  READ TABLE LT_DLI_WRK INTO LS_DLI_WRK WITH KEY
                       LOGSYS     = US_DLI_WRK-LOGSYS
                       OBJTYPE    = US_DLI_WRK-OBJTYPE
                       SRC_HEADNO = US_DLI_WRK-SRC_HEADNO
                       SRC_ITEMNO = US_DLI_WRK-PARENT_ITEMNO.
  IF SY-SUBRC = 0.
    READ TABLE GT_BDI_WRK INTO LS_BDI_WRK WITH KEY
                ROOT_DLITEM_GUID = LS_DLI_WRK-DLI_GUID.
    IF SY-SUBRC = 0.
      CS_BDI_WRK-PARENT_ITEMNO    = LS_BDI_WRK-ITEMNO_EXT.
      CS_BDI_WRK-PARENT_ITEM_GUID = LS_BDI_WRK-BDI_GUID.
    ENDIF.
  ENDIF.
ENDFORM.                    "parent_item_fill
