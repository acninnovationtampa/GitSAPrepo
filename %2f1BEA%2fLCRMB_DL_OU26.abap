FUNCTION /1BEA/CRMB_DL_O_ADD_TO_BUFFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI_WRK) TYPE  /1BEA/S_CRMB_DLI_WRK OPTIONAL
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
DATA:
  LV_TABIX         TYPE SYTABIX,
  LV_RC            TYPE SYSUBRC,
  LS_DLI_WRK       TYPE /1BEA/S_CRMB_DLI_WRK,
  LV_UPD_TYPE_OLD  TYPE UPDATE_TYPE.

 IF NOT IS_DLI_WRK-UPD_TYPE IS INITIAL.
   READ TABLE GT_DLI_WRK INTO LS_DLI_WRK
        WITH KEY DLI_GUID = IS_DLI_WRK-DLI_GUID
        BINARY SEARCH
        TRANSPORTING UPD_TYPE.
   LV_RC = SY-SUBRC.
   LV_TABIX = SY-TABIX.
   CASE LV_RC.
     WHEN 0.
* handle old and new UPD_TYPE
       LV_UPD_TYPE_OLD = LS_DLI_WRK-UPD_TYPE.
       LS_DLI_WRK = IS_DLI_WRK.
       IF LV_UPD_TYPE_OLD = IS_DLI_WRK-UPD_TYPE.
* new data is accepted 'as is'.
       ELSEIF LV_UPD_TYPE_OLD = GC_INSERT.
         IF IS_DLI_WRK-UPD_TYPE = GC_UPDATE.
* INSERT new data instead of old values
           LS_DLI_WRK-UPD_TYPE = GC_INSERT.
         ELSEIF IS_DLI_WRK-UPD_TYPE = GC_DELETE.
* remove record from buffer
           CLEAR LS_DLI_WRK-UPD_TYPE.
         ENDIF.
       ELSEIF LV_UPD_TYPE_OLD = GC_UPDATE.
         IF IS_DLI_WRK-UPD_TYPE = GC_INSERT.
* UPDATE with new data instead of old values
           LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
         ELSEIF IS_DLI_WRK-UPD_TYPE = GC_DELETE.
* DELETE from database
           LS_DLI_WRK-UPD_TYPE = GC_DELETE.
         ENDIF.
       ELSEIF LV_UPD_TYPE_OLD = GC_DELETE.
* UPDATE with new data
         LS_DLI_WRK-UPD_TYPE = GC_UPDATE.
       ELSE.        "i.e. LV_UPD_TYPE_OLD IS INITIAL.
       ENDIF.
       IF NOT LS_DLI_WRK-UPD_TYPE IS INITIAL.
         MODIFY GT_DLI_WRK FROM LS_DLI_WRK INDEX LV_TABIX.
       ELSE.
         DELETE GT_DLI_WRK INDEX LV_TABIX.
       ENDIF.
     WHEN 4.
       INSERT IS_DLI_WRK INTO GT_DLI_WRK INDEX LV_TABIX.
     WHEN 8.
       APPEND IS_DLI_WRK TO GT_DLI_WRK.
   ENDCASE.
  ENDIF.


ENDFUNCTION.
