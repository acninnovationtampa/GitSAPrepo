FUNCTION /1BEA/CRMB_BD_PAR_O_IT_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IS_BDI_NEW) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDI_NEW) TYPE  /1BEA/S_CRMB_BDI_WRK
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
* Time  : 13:53:02
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN INITIAZITATION
*---------------------------------------------------------------------
  PERFORM INIT_BD_PAR_O.
  ES_BDI_NEW = IS_BDI_NEW.
  CLEAR ES_BDI_NEW-PARSET_GUID.
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
*   copy partnerset from old to new
  CALL FUNCTION 'COM_PARTNER_COPY_SET_OW'
    EXPORTING
      IV_PARTNERSET_GUID               = IS_BDI-PARSET_GUID
*     IS_PARTNER_CONTROL               =
    IMPORTING
      EV_CREATED_PARTNERSET_GUID       = ES_BDI_NEW-PARSET_GUID
    EXCEPTIONS
      PARTNERSET_NOT_FOUND             = 1
      ERROR_OCCURRED                   = 2
      OTHERS                           = 3.
  IF SY-SUBRC <> 0.
    CLEAR ES_BDI_NEW-PARSET_GUID.
    MESSAGE E007(BEA_PAR) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
    PERFORM MSG_BD_PAR_O_2_RETURN   CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*   derive information for pricing and taxes
  CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_DERIVE'
    EXPORTING
      IS_BDI = ES_BDI_NEW
    IMPORTING
      ES_BDI = ES_BDI_NEW.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
