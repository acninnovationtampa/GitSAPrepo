FUNCTION /1BEA/CRMB_BD_PAR_O_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
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
  ES_BDI = IS_BDI.
*---------------------------------------------------------------------
* BEGIN SERVICE
*---------------------------------------------------------------------
* which partner-functiontyp shall be mapped
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0001'.
  APPEND lrs_pft TO lrt_pft.
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0012'.
  APPEND lrs_pft TO lrt_pft.
  IF NOT LRT_PFT IS INITIAL.
    CALL FUNCTION 'BEA_PAR_O_GET'
      EXPORTING
        IV_PARSET_GUID          = IS_BDI-PARSET_GUID
        IV_RESPECT_NUMBER       = GC_TRUE
        IV_ADDR_GET             = GC_TRUE
      IMPORTING
        ET_PAR                  = LT_PAR
      EXCEPTIONS
        REJECT                  = 1
        OTHERS                  = 2.
    IF SY-SUBRC = 0.
*       mapping of partner-masterdata to es_bdi
      LOOP AT LT_PAR INTO LS_PAR_RET
           WHERE GUID        = IS_BDI-PARSET_GUID
             AND PARTNER_PFT IN LRT_PFT
             AND MAINPARTNER = GC_TRUE.
        IF LS_PAR_RET-PARTNER_PFT = '0001'.
          IF ES_BDI-SOLD_TO_GUID IS INITIAL.
            MOVE LS_PAR_RET-PARTNER_NO TO ES_BDI-SOLD_TO_GUID.
          ENDIF.
        ENDIF.
        IF LS_PAR_RET-PARTNER_PFT = '0012'.
          MOVE LS_PAR_RET-PARTNER_NO TO ES_BDI-VENDOR.
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
