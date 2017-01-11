FUNCTION /1BEA/CRMB_BD_PAR_O_REFRESH.
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
  LT_PARSETS_REFRESH TYPE COMT_PARTNERSET_GUID_TAB,
  LT_PARSETS         TYPE BEAT_PARSET_GUID,
  LS_BDH             TYPE /1BEA/S_CRMB_BDH_WRK,
  LS_BDI             TYPE /1BEA/S_CRMB_BDI_WRK.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
*   Refresh current Head-Partnerset
  LOOP AT IT_BDH INTO LS_BDH.
    INSERT LS_BDH-PARSET_GUID INTO TABLE LT_PARSETS.
  ENDLOOP.
*   Refresh current Item-Partnersets
  LOOP AT IT_BDI INTO LS_BDI.
    INSERT LS_BDI-PARSET_GUID INTO TABLE LT_PARSETS.
  ENDLOOP.
  IF NOT LT_PARSETS IS INITIAL.
    LT_PARSETS_REFRESH = LT_PARSETS.
    CALL FUNCTION 'COM_PARTNER_INIT_OW'
      EXPORTING
        IT_PARTNERSETS_TO_INIT       = LT_PARSETS_REFRESH
        IV_INIT_DB_BUFFER            = GC_TRUE.
  ENDIF.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
