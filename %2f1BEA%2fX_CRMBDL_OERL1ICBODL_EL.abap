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
     IF LS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORGDATA.
       PERFORM DRVODL_ELZ_REPLACE_INT_BY_EXT CHANGING LS_DLI_WRK.
       LV_DERIV_CATEGORY = GC_DERIV_ORGDATA.
       CHECK LS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORIGIN.
     ENDIF.
