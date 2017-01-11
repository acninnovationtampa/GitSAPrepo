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
* pricing document is created as late as possible
* (expensive RFC)
    DATA:
      LV_PRCOBD_H1_EXT_LOG TYPE BEA_BOOLEAN.
* create empty pricing document
      CLEAR CS_BDH_WRK-TAX_VALUE.
      CLEAR CS_BDH_WRK-NET_VALUE.
      CLEAR LV_PRCOBD_H1_EXT_LOG.
      IF GS_CRP IS INITIAL.
        LV_PRCOBD_H1_EXT_LOG = GC_TRUE.
      ENDIF.
      CLEAR LT_RETURN.
      CALL FUNCTION '/1BEA/CRMB_BD_PRC_O_HD_CREATE'
        EXPORTING
          IS_BDH          = CS_BDH_WRK
          IV_EXTENDED_LOG = LV_PRCOBD_H1_EXT_LOG
        IMPORTING
          ES_BDH          = CS_BDH_WRK
          ET_RETURN       = LT_RETURN
        EXCEPTIONS
          REJECT          = 1.
      IF SY-SUBRC NE 0.
        CV_RETURN_CODE = SY-SUBRC.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
          IV_OBJECT      = 'DL'
          IV_CONTAINER   = 'DLI'
          IS_DLI_WRK     = US_DLI_WRK
          IT_RETURN      = LT_RETURN.
        RETURN. "from FORM
      ENDIF.
