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
    IF LV_BUFFER_ADD = GC_TRUE.
      PERFORM PRCODL_CRZ_PRC_FILL_BY_CRE
        USING
          US_DLI_INT
          UT_CONDITION
          CS_ITC
          LV_BILLED_QUANTITY
        CHANGING
          LS_DLI_WRK
          CT_RETURN.
    ENDIF.
