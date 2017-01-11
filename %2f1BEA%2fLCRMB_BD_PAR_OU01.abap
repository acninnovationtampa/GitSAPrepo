FUNCTION /1BEA/CRMB_BD_PAR_O_COMPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH_NEW) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(EV_EQUAL) TYPE  BEA_BOOLEAN
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
  IF NOT IS_BDH_NEW-PARSET_GUID IS INITIAL OR
     NOT IS_BDH-PARSET_GUID     IS INITIAL.
*   ckeck, if partnersets are equal
    CALL FUNCTION 'COM_PARTNER_COMPARE_SETS'
         EXPORTING
              IV_PARTNERSET_GUID_A = IS_BDH_NEW-PARSET_GUID
              IV_PARTNERSET_GUID_B = IS_BDH-PARSET_GUID
         IMPORTING
              EV_SETS_ARE_EQUAL    = EV_EQUAL
         EXCEPTIONS
              SET_NOT_FOUND        = 1
              OTHERS               = 2.
    IF SY-SUBRC <> 0.
      EV_EQUAL = GC_FALSE.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
*
ENDFUNCTION.
