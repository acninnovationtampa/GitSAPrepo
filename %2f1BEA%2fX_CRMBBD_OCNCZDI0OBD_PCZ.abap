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
 FORM CANCEL_DI_ITEM_ADD
   USING
     UV_BDH_GUID     TYPE BEA_BDH_GUID
     UT_BDI          TYPE /1BEA/T_CRMB_BDI_WRK
   CHANGING
     CT_BD_GUIDS_LOC TYPE BEAT_BD_GUIDS.

   DATA:
     LS_BDI      TYPE /1BEA/S_CRMB_BDI_WRK,
     LS_BDI_2    TYPE /1BEA/S_CRMB_BDI_WRK,
     LT_STACK    TYPE BEAT_BD_GUIDS,
     LS_STACK    TYPE BEAS_BD_GUIDS,
     LS_BD_GUIDS TYPE BEAS_BD_GUIDS.

   CHECK NOT CT_BD_GUIDS_LOC IS INITIAL.
   LT_STACK = CT_BD_GUIDS_LOC.
   DO.
     READ TABLE LT_STACK INTO LS_STACK INDEX 1.
     IF SY-SUBRC NE 0.
       EXIT.
     ENDIF.
     READ TABLE UT_BDI INTO LS_BDI
       WITH KEY BDI_GUID = LS_STACK-BDI_GUID.
     IF SY-SUBRC NE 0.
       DELETE LT_STACK INDEX 1.
       CONTINUE.
     ELSE.
       DELETE LT_STACK INDEX 1.
     ENDIF.
     IF LS_BDI-REVERSAL NE GC_REVERSAL_CORREC.
       LOOP AT UT_BDI INTO LS_BDI_2
         WHERE PARENT_ITEMNO = LS_BDI-ITEMNO_EXT
           AND REVERSAL      = GC_REVERSAL_CORREC.
         READ TABLE CT_BD_GUIDS_LOC
           WITH KEY BDI_GUID = LS_BDI_2-BDI_GUID
           TRANSPORTING NO FIELDS.
         IF SY-SUBRC NE 0.
           LS_BD_GUIDS-BDI_GUID = LS_BDI_2-BDI_GUID.
           LS_BD_GUIDS-BDH_GUID = UV_BDH_GUID.
           APPEND LS_BD_GUIDS TO CT_BD_GUIDS_LOC.
         ENDIF.
         READ TABLE LT_STACK
           WITH KEY BDI_GUID = LS_BDI_2-BDI_GUID
           TRANSPORTING NO FIELDS.
         IF SY-SUBRC EQ 0.
           DELETE LT_STACK INDEX SY-TABIX.
         ENDIF.
       ENDLOOP.
     ELSE.
       READ TABLE UT_BDI INTO LS_BDI_2
         WITH KEY ITEMNO_EXT = LS_BDI-PARENT_ITEMNO.
       IF SY-SUBRC EQ 0.
         READ TABLE CT_BD_GUIDS_LOC
           WITH KEY BDI_GUID = LS_BDI_2-BDI_GUID
           TRANSPORTING NO FIELDS.
         IF SY-SUBRC NE 0.
           LS_BD_GUIDS-BDI_GUID = LS_BDI_2-BDI_GUID.
           LS_BD_GUIDS-BDH_GUID = UV_BDH_GUID.
           APPEND LS_BD_GUIDS TO CT_BD_GUIDS_LOC.
         ENDIF.
         READ TABLE LT_STACK
           WITH KEY BDI_GUID = LS_BDI_2-BDI_GUID
           TRANSPORTING NO FIELDS.
         IF SY-SUBRC NE 0.
           LS_BD_GUIDS-BDI_GUID = LS_BDI_2-BDI_GUID.
           INSERT LS_BD_GUIDS INTO LT_STACK INDEX 1.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDDO.

 ENDFORM.
