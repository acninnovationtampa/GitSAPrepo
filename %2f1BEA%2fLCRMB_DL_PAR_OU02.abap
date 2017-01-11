FUNCTION /1BEA/CRMB_DL_PAR_O_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"     REFERENCE(IS_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI_NEW) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
* BEGIN INITIAZITATION
*---------------------------------------------------------------------
  PERFORM INIT_DLI_PAR_O.
  ES_DLI_NEW = IS_DLI_NEW.
  CLEAR ES_DLI_NEW-PARSET_GUID.
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
*   copy partnerset from old to new
  CALL FUNCTION 'COM_PARTNER_COPY_SET_OW'
    EXPORTING
      IV_PARTNERSET_GUID               = IS_DLI-PARSET_GUID
*     IS_PARTNER_CONTROL               =
    IMPORTING
      EV_CREATED_PARTNERSET_GUID       = ES_DLI_NEW-PARSET_GUID
    EXCEPTIONS
      PARTNERSET_NOT_FOUND             = 1
      ERROR_OCCURRED                   = 2
      OTHERS                           = 3.
  IF SY-SUBRC <> 0.
    CLEAR ES_DLI_NEW-PARSET_GUID.
    MESSAGE E007(BEA_PAR) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    PERFORM MSG_DLI_PAR_O_2_RETURN   CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
