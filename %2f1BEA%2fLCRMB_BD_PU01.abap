FUNCTION /1BEA/CRMB_BD_P_POST.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_BDH_WRK) TYPE  /1BEA/T_CRMB_BDH_WRK OPTIONAL
*"     VALUE(IT_BDI_WRK) TYPE  /1BEA/T_CRMB_BDI_WRK OPTIONAL
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
 DATA:
   LT_BDH_INS TYPE /1BEA/T_CRMB_BDH,
   LT_BDH_UPD TYPE /1BEA/T_CRMB_BDH,
   LT_BDH_DEL TYPE /1BEA/T_CRMB_BDH,
   LS_BDH_WRK TYPE /1BEA/S_CRMB_BDH_WRK,
   LS_BDH     TYPE /1BEA/S_CRMB_BDH,
   LT_BDI_INS TYPE /1BEA/T_CRMB_BDI,
   LT_BDI_UPD TYPE /1BEA/T_CRMB_BDI,
   LT_BDI_DEL TYPE /1BEA/T_CRMB_BDI,
   LS_BDI_WRK TYPE /1BEA/S_CRMB_BDI_WRK,
   LS_BDI     TYPE /1BEA/S_CRMB_BDI.

 LOOP AT IT_BDH_WRK INTO LS_BDH_WRK
                     WHERE NOT UPD_TYPE IS INITIAL.
   MOVE-CORRESPONDING LS_BDH_WRK TO LS_BDH.
   CASE LS_BDH_WRK-UPD_TYPE.
     WHEN GC_UPDATE.
       APPEND LS_BDH TO LT_BDH_UPD.
     WHEN GC_INSERT.
       APPEND LS_BDH TO LT_BDH_INS.
     WHEN GC_DELETE.
       APPEND LS_BDH TO LT_BDH_DEL.
   ENDCASE.
 ENDLOOP.
 LOOP AT IT_BDI_WRK INTO LS_BDI_WRK
                     WHERE NOT UPD_TYPE IS INITIAL.
   MOVE-CORRESPONDING LS_BDI_WRK TO LS_BDI.
   CASE LS_BDI_WRK-UPD_TYPE.
     WHEN GC_UPDATE.
       APPEND LS_BDI TO LT_BDI_UPD.
     WHEN GC_INSERT.
       APPEND LS_BDI TO LT_BDI_INS.
     WHEN GC_DELETE.
       APPEND LS_BDI TO LT_BDI_DEL.
   ENDCASE.
 ENDLOOP.

 UPDATE /1BEA/CRMB_BDH FROM TABLE LT_BDH_UPD.
 IF SY-SUBRC <> 0.
   MESSAGE A100(BEA) WITH '/1BEA/CRMB_BDH' sy-subrc.
 ENDIF.

 INSERT /1BEA/CRMB_BDH FROM TABLE LT_BDH_INS.
 IF SY-SUBRC <> 0.
   MESSAGE A101(BEA) WITH '/1BEA/CRMB_BDH' sy-subrc.
 ENDIF.

 DELETE /1BEA/CRMB_BDH FROM TABLE LT_BDH_DEL.
 IF SY-SUBRC <> 0.
   MESSAGE A102(BEA) WITH '/1BEA/CRMB_BDH' sy-subrc.
 ENDIF.
 UPDATE /1BEA/CRMB_BDI FROM TABLE LT_BDI_UPD.
 IF SY-SUBRC <> 0.
   MESSAGE A100(BEA) WITH '/1BEA/CRMB_BDI' sy-subrc.
 ENDIF.

 INSERT /1BEA/CRMB_BDI FROM TABLE LT_BDI_INS.
 IF SY-SUBRC <> 0.
   MESSAGE A101(BEA) WITH '/1BEA/CRMB_BDI' sy-subrc.
 ENDIF.

 DELETE /1BEA/CRMB_BDI FROM TABLE LT_BDI_DEL.
 IF SY-SUBRC <> 0.
   MESSAGE A102(BEA) WITH '/1BEA/CRMB_BDI' sy-subrc.
 ENDIF.

ENDFUNCTION.
