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
*---------------------------------------------------------------------
*       FORM BDH_PARTNERSET_FILL
*---------------------------------------------------------------------
FORM PAROBD_H1Z_BDH_PARTNERSET_FILL
  USING
    US_DLI_WRK   TYPE /1BEA/S_CRMB_DLI_WRK
    US_BTY_WRK   TYPE BEAS_BTY_WRK
    UV_TABIX_DLI TYPE SYTABIX
  CHANGING
    CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
    CV_RETURN_CODE TYPE SYSUBRC.
  DATA:
    LT_RETURN TYPE BEAT_RETURN.
  CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_HD_CREATE'
         EXPORTING
             IS_DLI    = US_DLI_WRK
             IS_BTY    = US_BTY_WRK
             IS_BDH    = CS_BDH_WRK
         IMPORTING
             ES_BDH    = CS_BDH_WRK
             ET_RETURN = LT_RETURN
         EXCEPTIONS
             REJECT     = 1
             INCOMPLETE = 2
             OTHERS     = 3.
  IF SY-SUBRC <> 0.
    CV_RETURN_CODE = SY-SUBRC.
    MESSAGE E014(BEA_PAR) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                          INTO GV_DUMMY.
    CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
      EXPORTING
        IV_OBJECT      = 'DL'
        IV_CONTAINER   = 'DLI'
        IS_DLI_WRK     = US_DLI_WRK
        IT_RETURN      = LT_RETURN.
  ENDIF.
ENDFORM.                    "bdh_partnerset_fill
