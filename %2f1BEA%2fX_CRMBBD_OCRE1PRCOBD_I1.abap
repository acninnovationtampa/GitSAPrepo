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
    IF NOT US_DLI_WRK-PRIDOC_GUID IS INITIAL.
      CS_BDI_WRK-PRV_PRIDOC_GUID = US_DLI_WRK-PRIDOC_GUID.
      CS_BDI_WRK-PRV_ITEM_GUID   = US_DLI_WRK-DLI_GUID.
      IF NOT US_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
        IF US_DLI_WRK-SRC_PRC_GUID IS INITIAL.
          MOVE US_DLI_WRK-SRC_GUID TO CS_BDI_WRK-PRV_ITEM_GUID.
        ELSE.
          MOVE US_DLI_WRK-SRC_PRC_GUID TO CS_BDI_WRK-PRV_ITEM_GUID.
        ENDIF.
      ENDIF.
    ELSE.
      IF NOT US_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
        CS_BDI_WRK-PRC_COPY_CONTROL = GC_PRC_NOCOPY.
      ENDIF.
    ENDIF.
    CS_BDI_WRK-REF_QUANTITY = US_DLI_WRK-QUANTITY.
    CS_BDI_WRK-REF_QTY_UNIT = US_DLI_WRK-QTY_UNIT.
