FUNCTION /1BEA/CRMB_DL_PAR_O_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
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
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  INSERT IS_DLI-PARSET_GUID INTO TABLE GT_PARSETS_DEL.
*   read from database to delete
  CALL FUNCTION 'COM_PARTNER_GET'
    EXPORTING
      IV_PARTNERSET_GUID   = IS_DLI-PARSET_GUID
*   IMPORTING
*     ET_PARTNER           =
    EXCEPTIONS
      PARTNERSET_NOT_FOUND = 0
      PARTNER_NOT_FOUND    = 0
      ERROR_MESSAGE        = 0
      OTHERS               = 0.
  CALL FUNCTION 'COM_PARTNER_REMOVE_SET_OW'
       EXPORTING
            IV_PARTNERSET_GUID = IS_DLI-PARSET_GUID
       EXCEPTIONS
            ERROR_MESSAGE      = 0
            ERROR_OCCURRED     = 0
            OTHERS             = 0.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
