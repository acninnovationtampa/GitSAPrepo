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
   LS_DI0ODL_CHK_OV      TYPE /1BEA/S_CRMB_DLI_WRK.

 LOOP AT UT_DLI_WRK INTO LS_DI0ODL_CHK_OV
      WHERE BILL_STATUS EQ GC_BILLSTAT_DONE.
   IF (
      NOT LS_DI0ODL_CHK_OV-LOGSYS IS INITIAL
     OR NOT LS_DI0ODL_CHK_OV-OBJTYPE IS INITIAL
     OR NOT LS_DI0ODL_CHK_OV-SRC_HEADNO IS INITIAL
     OR NOT LS_DI0ODL_CHK_OV-SRC_ITEMNO IS INITIAL
       ) AND (
      LS_DI0ODL_CHK_OV-LOGSYS NE LS_DLI_WRK-LOGSYS
     OR LS_DI0ODL_CHK_OV-OBJTYPE NE LS_DLI_WRK-OBJTYPE
     OR LS_DI0ODL_CHK_OV-SRC_HEADNO NE LS_DLI_WRK-SRC_HEADNO
     OR LS_DI0ODL_CHK_OV-SRC_ITEMNO NE LS_DLI_WRK-SRC_ITEMNO
       ).
     MESSAGE E242(BEA)
             WITH GC_P_DLI_ITEMNO GC_P_DLI_HEADNO
             INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
       EXPORTING
         IV_CONTAINER   = 'DLI'
         IS_DLI_WRK     = LS_DLI_WRK
         IT_RETURN      = CT_RETURN
       IMPORTING
         ET_RETURN      = CT_RETURN.
     LV_RETURNCODE = 1.
     IF LS_DLI_WRK-INCOMP_ID IS INITIAL.
       LS_DLI_WRK-INCOMP_ID = GC_INCOMP_ERROR.
     ENDIF.
     EXIT.
   ENDIF.
 ENDLOOP.
