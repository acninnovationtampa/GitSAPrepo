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
   IF LS_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
     CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_DELETE'
       EXPORTING
          IS_DLI = LS_DLI_WRK
          IS_ITC = US_ITC.                 "#EC ENHOK
     CLEAR LS_DLI_WRK-PRIDOC_GUID.
  ENDIF.
