FUNCTION /1BEA/CRMB_BD_PAR_O_HD_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
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
*---------------------------------------------------------------------
* END INITIAZITATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PROCESS
*---------------------------------------------------------------------
  CALL FUNCTION 'COM_PARTNER_REMOVE_SET_OW'
       EXPORTING
            IV_PARTNERSET_GUID = IS_BDH-PARSET_GUID
       EXCEPTIONS
            ERROR_OCCURRED     = 1
            OTHERS             = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E004(BEA_PAR) INTO GV_DUMMY.
    PERFORM msg_add using space space space space CHANGING ET_RETURN.
    PERFORM MSG_BD_PAR_O_2_RETURN    CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END PROCESS
*---------------------------------------------------------------------
ENDFUNCTION.
