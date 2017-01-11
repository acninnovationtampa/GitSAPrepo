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
*---------------------------------------------------------------------
* Complete split for service partner
*---------------------------------------------------------------------
    IF LS_SPLIT-SPLIT_REASON = GC_PARTNER.
      IF NOT LS_SPLIT-PARTNER_FCT IS INITIAL.
        CALL FUNCTION 'COM_PARTNER_GET_DESCRIPTION_CB'
          EXPORTING
            IV_PARTNER_FCT = LS_SPLIT-PARTNER_FCT
            IV_SPRAS       = SY-LANGU
          IMPORTING
            EV_DESCRIPTION = LS_SPLIT-PARTNER_FCT_T.
      ELSE.
        LS_SPLIT-PARTNER_FCT   = GC_PARTNER.
        LS_SPLIT-PARTNER_FCT_T = TEXT-001.
      ENDIF.
    ENDIF.
