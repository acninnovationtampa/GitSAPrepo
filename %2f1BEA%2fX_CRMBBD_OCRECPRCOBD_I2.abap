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
      CS_BDI_WRK-SUC_PRIDOC_GUID = US_DLI_WRK-PRIDOC_GUID.
      CS_BDI_WRK-SUC_ITEM_GUID   = US_DLI_WRK-DLI_GUID.
    ENDIF.
    CS_BDI_WRK-PRICING_DATE = US_DLI_WRK-PRICING_DATE.
    CS_BDI_WRK-RENDERED_DATE = US_DLI_WRK-RENDERED_DATE.
