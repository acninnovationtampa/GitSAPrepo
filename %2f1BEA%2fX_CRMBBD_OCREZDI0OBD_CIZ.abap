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
 FORM DI_ADD_CORR_ITEMS
   USING
     US_BTY_WRK     TYPE BEAS_BTY_WRK
     US_ITC_WRK     TYPE BEAS_ITC_WRK
     US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
     US_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK
   CHANGING
     CT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK
     CS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK
     CT_BDI_TC_WRK  TYPE /1BEA/T_CRMB_BDI_WRK
     CV_RETURNCODE  TYPE SYSUBRC.

   FIELD-SYMBOLS:
     <BDI>          TYPE /1BEA/S_CRMB_BDI_WRK.

   DATA:
     LT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK,
     LT_BDI_TC_WRK  TYPE /1BEA/T_CRMB_BDI_WRK.

   CALL FUNCTION '/1BEA/CRMB_BD_O_CIT_CREATE'
     EXPORTING
       IS_DLI               = US_DLI_WRK
       IS_BDI               = US_BDI_WRK
       IS_ITC               = US_ITC_WRK
     IMPORTING
       ET_BDI               = LT_BDI_WRK
       ET_BDI_TC            = LT_BDI_TC_WRK
     EXCEPTIONS
       REJECT               = 1
       OTHERS               = 2.
   IF SY-SUBRC NE 0.
     CV_RETURNCODE = 1.
     RETURN.
   ENDIF.
   LOOP AT LT_BDI_WRK ASSIGNING <BDI>.
     PERFORM BDI_PROCESS
       USING
         US_BTY_WRK
         US_DLI_WRK
         GC_FALSE
       CHANGING
         <BDI>
         CS_BDH_WRK.
     APPEND <BDI> TO CT_BDI_WRK.
   ENDLOOP.
   LOOP AT LT_BDI_TC_WRK ASSIGNING <BDI>.
     <BDI>-IS_REVERSED = GC_IS_REVED_BY_CORR.
     <BDI>-UPD_TYPE    = GC_UPDATE.
   ENDLOOP.

   CT_BDI_TC_WRK = LT_BDI_TC_WRK.


 ENDFORM.
