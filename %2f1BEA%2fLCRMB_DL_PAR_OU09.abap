FUNCTION /1BEA/CRMB_DL_PAR_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ET_DLI_FAULT) TYPE  /1BEA/T_CRMB_DLI_WRK
*"--------------------------------------------------------------------
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
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LS_PARSETS      TYPE BEA_PARSET_GUID,
    LT_PARSETS      TYPE BEAT_PARSET_GUID,
    LT_PARSETS_SAVE TYPE COMT_PARTNERSET_GUID_TAB,
    LS_DLI          TYPE /1BEA/S_CRMB_DLI_WRK.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*   Insert current Partnerset to or from DB
  LOOP AT IT_DLI INTO LS_DLI
       WHERE NOT UPD_TYPE IS INITIAL.
    INSERT LS_DLI-PARSET_GUID INTO TABLE LT_PARSETS.
  ENDLOOP.
*   consider Partnerset for deletion from DB
  LOOP AT GT_PARSETS_DEL INTO LS_PARSETS.
    INSERT LS_PARSETS INTO TABLE LT_PARSETS.
  ENDLOOP.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  IF NOT LT_PARSETS IS INITIAL.
    LT_PARSETS_SAVE = LT_PARSETS.
    CALL FUNCTION 'COM_PARTNER_SAVE_OB'
      EXPORTING
        IT_PARTNERSETS_TO_SAVE       = LT_PARSETS_SAVE
*       IV_SAVE_ALL_OBJECTS          =
        IV_IN_UPDATE_TASK            = GC_TRUE
      EXCEPTIONS
        ERROR_OCCURRED               = 0
        ERROR_MESSAGE                = 0
        OTHERS                       = 0.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
