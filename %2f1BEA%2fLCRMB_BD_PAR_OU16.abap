FUNCTION /1BEA/CRMB_BD_PAR_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
* Time  : 13:53:02
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LT_PARSETS_SAVE TYPE COMT_PARTNERSET_GUID_TAB,
    LT_PARSETS      TYPE BEAT_PARSET_GUID,
    LS_BDH          TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDI          TYPE /1BEA/S_CRMB_BDI_WRK.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*   Insert current Head-Partnerset to DB
  LOOP AT IT_BDH INTO LS_BDH
     WHERE NOT UPD_TYPE IS INITIAL.
    INSERT LS_BDH-PARSET_GUID INTO TABLE LT_PARSETS.
  ENDLOOP.
*   Insert current Item-Partnersets to DB
  LOOP AT IT_BDI INTO LS_BDI
     WHERE NOT UPD_TYPE IS INITIAL.
    INSERT LS_BDI-PARSET_GUID INTO TABLE LT_PARSETS.
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
