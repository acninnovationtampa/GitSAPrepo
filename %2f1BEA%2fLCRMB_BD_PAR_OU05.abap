FUNCTION /1BEA/CRMB_BD_PAR_O_GET_MULTI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
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
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LT_PARSETS_GET TYPE COMT_PARTNERSET_GUID_TAB,
    LT_PARSETS     TYPE BEAT_PARSET_GUID,
    LS_DLI         TYPE /1BEA/S_CRMB_DLI_WRK,
    LV_DUMMY.                                          "#EC NEEDED
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*   read current Partnerset from DB
  LOOP AT IT_DLI INTO LS_DLI.
    INSERT LS_DLI-PARSET_GUID INTO TABLE LT_PARSETS.
  ENDLOOP.
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
  IF NOT LT_PARSETS IS INITIAL.
    LT_PARSETS_GET = LT_PARSETS.
    CALL FUNCTION 'COM_PARTNER_GET_MULTI_OW'
      EXPORTING
        IT_PARTNERSET_GUIDS        = LT_PARSETS_GET
      EXCEPTIONS
        PARTNERSET_NOT_FOUND       = 1
        PARTNER_NOT_FOUND          = 2
        ERROR_MESSAGE              = 3
        OTHERS                     = 4.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO LV_DUMMY.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
ENDFUNCTION.
