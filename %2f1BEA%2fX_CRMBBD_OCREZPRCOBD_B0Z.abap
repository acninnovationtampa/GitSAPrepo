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
FORM PRCOBD_B0Z_BDH_PRIC_PROC_DET
  USING
    US_DLI_WRK TYPE /1BEA/S_CRMB_DLI_WRK
    US_BTY_WRK TYPE BEAS_BTY_WRK
  CHANGING
    CS_BDH_WRK TYPE /1BEA/S_CRMB_BDH_WRK.

 IF NOT US_BTY_WRK-PRC_PPDEFAULT IS INITIAL.
   IF NOT US_DLI_WRK-PRIDOC_GUID IS INITIAL.
     CALL FUNCTION 'BEA_PRC_O_GET_PROC'
       EXPORTING
         IV_PRIDOC_GUID      = US_DLI_WRK-PRIDOC_GUID
         IV_ALSO_FROM_BUFFER = GC_PRC_TRUE
       IMPORTING
         EV_PRIC_PROC        = CS_BDH_WRK-PRIC_PROC.
   ENDIF.
 ENDIF.
ENDFORM.
