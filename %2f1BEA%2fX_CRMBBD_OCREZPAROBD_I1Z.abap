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
*       FORM BDI_PARTNERSET_FILL
*---------------------------------------------------------------------
  FORM PAROBD_I1Z_BDI_PARTNERSET_FILL
    USING
      US_ITC_WRK     TYPE BEAS_ITC_WRK
      US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
      UV_TABIX_DLI   TYPE SYTABIX
    CHANGING
      CS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK
      CV_RETURN_CODE TYPE SYSUBRC.
    DATA :
      LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK,
      LT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK,
      LT_RETURN      TYPE BEAT_RETURN.
* partner processing ------------------------------
* STEP 1: create a partner set for the item
    CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_IT_CREATE'
         EXPORTING
            IS_DLI     = US_DLI_WRK
            IS_BDI     = CS_BDI_WRK
            IS_ITC     = US_ITC_WRK
         IMPORTING
            ES_BDI     = CS_BDI_WRK
            ET_RETURN  = LT_RETURN
         EXCEPTIONS
            REJECT     = 1
            OTHERS     = 2.
    IF SY-SUBRC <> 0.
      CV_RETURN_CODE = SY-SUBRC.
      MESSAGE E015(BEA_PAR) WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
                            INTO GV_DUMMY.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'DL'
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK
          IT_RETURN      = LT_RETURN.
      RETURN. "from FORM
    ENDIF.

* end of partner processing ------------------------------
  ENDFORM.                    "BDI_PARTNERSET_FILL
