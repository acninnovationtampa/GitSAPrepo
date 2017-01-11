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
    IF NOT US_DLI_WRK-PARENT_ITEMNO IS INITIAL.
      PERFORM PITOBD_RNZ_PARENT_ITEM_FILL
        USING
          US_DLI_WRK
        CHANGING
          CS_BDI_WRK.
    ENDIF.
