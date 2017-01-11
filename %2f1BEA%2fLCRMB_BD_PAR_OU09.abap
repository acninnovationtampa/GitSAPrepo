FUNCTION /1BEA/CRMB_BD_PAR_O_HD_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
    LRT_PFT    TYPE BEART_PAR_PFT,
    LRS_PFT    TYPE BEARS_PAR_PFT,
    LT_PAR     TYPE BEAT_PAR_WRK,
    LS_PAR_RET TYPE BEAS_PAR_WRK.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
  ES_BDH = IS_BDH.
*---------------------------------------------------------------------
* BEGIN SERVICE
*---------------------------------------------------------------------
* which partner-functiontyp shall be mapped
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0003'.
  APPEND lrs_pft TO lrt_pft.
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0004'.
  APPEND lrs_pft TO lrt_pft.
  IF NOT LRT_PFT IS INITIAL.
    CALL FUNCTION 'BEA_PAR_O_GET'
      EXPORTING
        IV_PARSET_GUID          = IS_BDH-PARSET_GUID
        IV_RESPECT_NUMBER       = GC_TRUE
        IV_ADDR_GET             = GC_FALSE
      IMPORTING
        ET_PAR                  = LT_PAR
      EXCEPTIONS
        REJECT                  = 1
        OTHERS                  = 2.
    IF SY-SUBRC = 0.
*       mapping of partner-masterdata to es_bdh
      LOOP AT LT_PAR INTO LS_PAR_RET
           WHERE GUID        = IS_BDH-PARSET_GUID
             AND PARTNER_PFT IN LRT_PFT
             AND MAINPARTNER = GC_TRUE.
        IF LS_PAR_RET-PARTNER_PFT = '0003'.
          IF ES_BDH-BILL_TO_GUID IS INITIAL.
            MOVE LS_PAR_RET-PARTNER_NO TO ES_BDH-BILL_TO_GUID.
          ENDIF.
        ENDIF.
        IF LS_PAR_RET-PARTNER_PFT = '0004'.
          IF ES_BDH-PAYER_GUID IS INITIAL.
            MOVE LS_PAR_RET-PARTNER_NO TO ES_BDH-PAYER_GUID.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE
*---------------------------------------------------------------------
ENDFUNCTION.
