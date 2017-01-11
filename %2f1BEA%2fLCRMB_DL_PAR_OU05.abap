FUNCTION /1BEA/CRMB_DL_PAR_O_DERIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
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
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LRT_PFT    TYPE BEART_PAR_PFT,
    LRS_PFT    TYPE BEARS_PAR_PFT,
    LT_PAR     TYPE BEAT_PAR_WRK,
    LS_PAR_RET TYPE BEAS_PAR_WRK,
    LV_PAYER   TYPE BEA_PAYER,
    LV_SOLD_TO TYPE BEA_SOLD_TO.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
  ES_DLI = IS_DLI.
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
  lrs_pft-low = '0002'.
  APPEND lrs_pft TO lrt_pft.
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0003'.
  APPEND lrs_pft TO lrt_pft.
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0004'.
  APPEND lrs_pft TO lrt_pft.
  lrs_pft-sign    = gc_sign_include.
  lrs_pft-option  = gc_rangeoption_eq.
  lrs_pft-low = '0012'.
  APPEND lrs_pft TO lrt_pft.
  IF NOT LRT_PFT IS INITIAL.
    CALL FUNCTION 'BEA_PAR_O_GET'
      EXPORTING
        IV_PARSET_GUID          = IS_DLI-PARSET_GUID
        IV_RESPECT_NUMBER       = GC_TRUE
        IV_ADDR_GET             = GC_TRUE
      IMPORTING
        ET_PAR                  = LT_PAR
      EXCEPTIONS
        REJECT                  = 1
        OTHERS                  = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING REJECT.
    ENDIF.
*     mapping of partner-masterdata to es_dli
    LOOP AT LT_PAR INTO LS_PAR_RET
         WHERE GUID        = IS_DLI-PARSET_GUID
           AND PARTNER_PFT IN LRT_PFT
           AND MAINPARTNER = GC_TRUE.
      IF LS_PAR_RET-PARTNER_PFT = '0001'.
        IF ES_DLI-SOLD_TO_PARTY IS INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT         = LS_PAR_RET-EXTERNAL_PARTNER_NUMBER
          IMPORTING
            OUTPUT        = ES_DLI-SOLD_TO_PARTY.
        ENDIF.
        IF ES_DLI-SOLD_TO_GUID IS INITIAL.
          MOVE LS_PAR_RET-PARTNER_NO TO ES_DLI-SOLD_TO_GUID.
        ENDIF.
      ENDIF.
      IF LS_PAR_RET-PARTNER_PFT = '0002'.
        IF ES_DLI-TAX_DEST_COUNTRY IS INITIAL.
          MOVE LS_PAR_RET-COUNTRY TO ES_DLI-TAX_DEST_COUNTRY.
        ENDIF.
      ENDIF.
      IF LS_PAR_RET-PARTNER_PFT = '0003'.
        IF ES_DLI-BILL_TO_GUID IS INITIAL.
          MOVE LS_PAR_RET-PARTNER_NO TO ES_DLI-BILL_TO_GUID.
        ENDIF.
      ENDIF.
      IF LS_PAR_RET-PARTNER_PFT = '0004'.
        IF ES_DLI-PAYER_GUID IS INITIAL.
          MOVE LS_PAR_RET-PARTNER_NO TO ES_DLI-PAYER_GUID.
        ENDIF.
        IF ES_DLI-PAYER IS INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT         = LS_PAR_RET-EXTERNAL_PARTNER_NUMBER
          IMPORTING
            OUTPUT        = ES_DLI-PAYER.
        ENDIF.
      ENDIF.
      IF LS_PAR_RET-PARTNER_PFT = '0012'.
        MOVE LS_PAR_RET-PARTNER_NO TO ES_DLI-VENDOR.
      ENDIF.
    ENDLOOP.
  ENDIF.
*---------------------------------------------------------------------
* END SEVICE
*---------------------------------------------------------------------
ENDFUNCTION.
