FUNCTION /1BEA/CRMB_BD_O_ADD_TO_BUFFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK OPTIONAL
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK OPTIONAL
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
* Time  : 13:52:50
*
*======================================================================
*====================================================================
* Definitionsteil
*====================================================================
DATA :
  LV_TABIX         TYPE SYTABIX,
  LV_SUBRC         TYPE SYSUBRC,
  LV_UPD_TYPE_OLD  TYPE UPDATE_TYPE,
  LS_BDH           TYPE /1BEA/S_CRMB_BDH_WRK,
  LS_BDI_NEW       TYPE /1BEA/S_CRMB_BDI_WRK,
  LS_BDI           TYPE /1BEA/S_CRMB_BDI_WRK.
*==================================================================
* Implementierungsteil
*==================================================================
* Only data with non-initial UPD_TYPE will be processed.
* process IS_BDH
IF NOT IS_BDH IS INITIAL AND
   NOT IS_BDH-UPD_TYPE IS INITIAL.
  READ TABLE GT_BDH_WRK INTO LS_BDH
    WITH KEY HEADNO_EXT = IS_BDH-HEADNO_EXT
    BINARY SEARCH
    TRANSPORTING UPD_TYPE.
  LV_TABIX = SY-TABIX.
  LV_SUBRC = SY-SUBRC.
  CASE LV_SUBRC.
    WHEN 0.
* handle old and new UPD_TYPE
      LV_UPD_TYPE_OLD = LS_BDH-UPD_TYPE.
      LS_BDH = IS_BDH.
      IF LV_UPD_TYPE_OLD = IS_BDH-UPD_TYPE.
* new data is accepted 'as is'.
      ELSEIF LV_UPD_TYPE_OLD = GC_INSERT.
        IF IS_BDH-UPD_TYPE = GC_UPDATE.
* INSERT new data instead of old values
          LS_BDH-UPD_TYPE = GC_INSERT.
        ELSEIF IS_BDH-UPD_TYPE = GC_DELETE.
* remove record from buffer
          CLEAR LS_BDH-UPD_TYPE.
        ENDIF.
      ELSEIF LV_UPD_TYPE_OLD = GC_UPDATE.
        IF IS_BDH-UPD_TYPE = GC_INSERT.
* UPDATE with new data instead of old values
          LS_BDH-UPD_TYPE = GC_UPDATE.
        ELSEIF IS_BDH-UPD_TYPE = GC_DELETE.
* DELETE from database
          LS_BDH-UPD_TYPE = GC_DELETE.
        ENDIF.
      ELSEIF LV_UPD_TYPE_OLD = GC_DELETE.
* UPDATE with new data
        LS_BDH-UPD_TYPE = GC_UPDATE.
      ELSE.        "LV_UPD_TYPE_OLD IS INITIAL.
      ENDIF.
      IF NOT LS_BDH-UPD_TYPE IS INITIAL.
        MODIFY GT_BDH_WRK FROM LS_BDH INDEX LV_TABIX.
      ELSE.
        DELETE GT_BDH_WRK INDEX LV_TABIX.
      ENDIF.
    WHEN 4.
      INSERT IS_BDH INTO GT_BDH_WRK INDEX LV_TABIX.
    WHEN 8.
      APPEND IS_BDH TO GT_BDH_WRK.
  ENDCASE.
ENDIF.

* process IT_BDI
LOOP AT IT_BDI INTO LS_BDI_NEW
  WHERE NOT UPD_TYPE IS INITIAL.
* GT_BDI_WRK is kept sorted by heads and external item numbers
  READ TABLE GT_BDI_WRK INTO LS_BDI
       WITH KEY BDH_GUID   = LS_BDI_NEW-BDH_GUID
                ITEMNO_EXT = LS_BDI_NEW-ITEMNO_EXT
    BINARY SEARCH
    TRANSPORTING UPD_TYPE.
  LV_TABIX = SY-TABIX.
  LV_SUBRC = SY-SUBRC.
  CASE LV_SUBRC.
    WHEN 0.
* handle old and new UPD_TYPE
      CLEAR LV_UPD_TYPE_OLD.
      LV_UPD_TYPE_OLD = LS_BDI-UPD_TYPE.
      LS_BDI = LS_BDI_NEW.
      IF LV_UPD_TYPE_OLD = LS_BDI_NEW-UPD_TYPE.
* new data is accepted 'as is'.
      ELSEIF LV_UPD_TYPE_OLD = GC_INSERT.
        IF LS_BDI_NEW-UPD_TYPE = GC_UPDATE.
* INSERT new data instead of old values
          LS_BDI-UPD_TYPE = GC_INSERT.
        ELSEIF LS_BDI_NEW-UPD_TYPE = GC_DELETE.
* remove record from buffer
          CLEAR LS_BDI-UPD_TYPE.
        ENDIF.
      ELSEIF LV_UPD_TYPE_OLD = GC_UPDATE.
        IF LS_BDI_NEW-UPD_TYPE = GC_INSERT.
* UPDATE with new data instead of old values
          LS_BDI-UPD_TYPE = GC_UPDATE.
        ELSEIF LS_BDI_NEW-UPD_TYPE = GC_DELETE.
* DELETE from database
          LS_BDI-UPD_TYPE = GC_DELETE.
        ENDIF.
      ELSEIF LV_UPD_TYPE_OLD = GC_DELETE.
* UPDATE with new data
        LS_BDI-UPD_TYPE = GC_UPDATE.
      ELSE.        "LV_UPD_TYPE_OLD IS INITIAL.
      ENDIF.
      IF NOT LS_BDI-UPD_TYPE IS INITIAL.
        MODIFY GT_BDI_WRK FROM LS_BDI INDEX LV_TABIX.
      ELSE.
        DELETE GT_BDI_WRK INDEX LV_TABIX.
      ENDIF.
    WHEN 4.
      INSERT LS_BDI_NEW INTO GT_BDI_WRK INDEX LV_TABIX.
    WHEN 8.
      APPEND LS_BDI_NEW TO GT_BDI_WRK.
  ENDCASE.
ENDLOOP.


ENDFUNCTION.
