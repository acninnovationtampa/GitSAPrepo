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
  IF US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORIGIN OR
     US_DLI_WRK-DERIV_CATEGORY = gc_deriv_retrobill OR
     US_DLI_WRK-DERIV_CATEGORY = GC_DERIV_CONDITION.
    PERFORM PAROBD_I2Z_BDI_PARSET_MERGE
      USING
        US_ITC_WRK
        US_DLI_WRK
        LS_REF_DLI_WRK
        UV_TABIX_DLI
      CHANGING
        LS_BDI_WRK
        CV_RETURNCODE.
  ELSE.
*   take Intercompany Partner for delivery related process from derived item
    PERFORM PAROBD_I1Z_BDI_PARTNERSET_FILL
      USING
        US_ITC_WRK
        US_DLI_WRK
        UV_TABIX_DLI
      CHANGING
        LS_BDI_WRK
        CV_RETURNCODE.
  ENDIF.
  CHECK CV_RETURNCODE IS INITIAL.
