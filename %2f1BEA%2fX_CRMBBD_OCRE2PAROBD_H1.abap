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
  PERFORM PAROBD_H1Z_BDH_PARTNERSET_FILL
    USING
      US_DLI_WRK
      US_BTY_WRK
      UV_TABIX_DLI
    CHANGING
      LS_BDH_WRK
      CV_RETURNCODE.
  CHECK CV_RETURNCODE IS INITIAL.
