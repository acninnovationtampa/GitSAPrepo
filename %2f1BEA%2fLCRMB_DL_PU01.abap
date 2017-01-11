FUNCTION /1BEA/CRMB_DL_P_POST.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_DLI_WRK) TYPE  /1BEA/T_CRMB_DLI_WRK
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
   LT_DLI_INS TYPE /1BEA/T_CRMB_DLI,
   LT_DLI_UPD TYPE /1BEA/T_CRMB_DLI,
   LT_DLI_DEL TYPE /1BEA/T_CRMB_DLI,
   LS_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK,
   LS_DLI     TYPE /1BEA/S_CRMB_DLI.

 LOOP AT IT_DLI_WRK INTO LS_DLI_WRK
                     WHERE NOT UPD_TYPE IS INITIAL.
   MOVE-CORRESPONDING LS_DLI_WRK TO LS_DLI.
   CASE LS_DLI_WRK-UPD_TYPE.
     WHEN GC_UPDATE.
       APPEND LS_DLI TO LT_DLI_UPD.
     WHEN GC_INSERT.
       APPEND LS_DLI TO LT_DLI_INS.
     WHEN GC_DELETE.
       APPEND LS_DLI TO LT_DLI_DEL.
   ENDCASE.
 ENDLOOP.

 UPDATE /1BEA/CRMB_DLI FROM TABLE LT_DLI_UPD.
 IF SY-SUBRC <> 0.
   MESSAGE A100(BEA) WITH '/1BEA/CRMB_DLI' sy-subrc.
 ENDIF.

 INSERT /1BEA/CRMB_DLI FROM TABLE LT_DLI_INS.
 IF SY-SUBRC <> 0.
   MESSAGE A101(BEA) WITH '/1BEA/CRMB_DLI' sy-subrc.
 ENDIF.

 DELETE /1BEA/CRMB_DLI FROM TABLE LT_DLI_DEL.
 IF SY-SUBRC <> 0.
   MESSAGE A102(BEA) WITH '/1BEA/CRMB_DLI' sy-subrc.
 ENDIF.

ENDFUNCTION.
