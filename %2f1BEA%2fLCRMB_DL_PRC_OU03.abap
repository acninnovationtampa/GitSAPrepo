FUNCTION /1BEA/CRMB_DL_PRC_O_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
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
  DATA:
    LV_PD_HANDLE  TYPE PRCT_HANDLE,
    LV_SESSION_ID TYPE BEA_PRC_SESSION_ID,
    LT_SESSION_ID TYPE BEAT_PRC_SESSION_ID.
  IF NOT IS_DLI-PRC_SESSION_ID IS INITIAL.
    CALL FUNCTION 'BEA_PRC_O_HNDL_GET'
      EXPORTING
        IV_SESSION_ID         = IS_DLI-PRC_SESSION_ID
      IMPORTING
        EV_PRICING_HANDLE     = LV_PD_HANDLE
      EXCEPTIONS
        SESSION_NOT_FOUND     = 1
        OTHERS                = 2.
    IF SY-SUBRC NE 0.
      RETURN.
    ENDIF.
  ELSE.
    IF NOT IS_DLI-PRIDOC_GUID IS INITIAL.
      CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_OPEN'
        EXPORTING
          IS_DLI              = IS_DLI
          IS_ITC              = IS_ITC
          IV_WRITE_MODE       = GC_PRC_PD_READWRIT
        IMPORTING
          EV_SESSION_ID       = LV_SESSION_ID
          EV_PD_HANDLE        = LV_PD_HANDLE
        EXCEPTIONS
          REJECT              = 1
          OTHERS              = 2.
      IF SY-SUBRC NE 0.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'PRC_PD_DELETE'
    EXPORTING
      IV_PD_HANDLE          = LV_PD_HANDLE
      IV_SAVE_IMPLICIT      = GC_SAVE_IMPLICITLY
    EXCEPTIONS
      OTHERS                = 0.
  IF NOT LV_SESSION_ID IS INITIAL.
     APPEND LV_SESSION_ID TO LT_SESSION_ID.
     CALL FUNCTION 'BEA_PRC_O_PD_CLOSE'
       EXPORTING
         IT_SESSION_ID = LT_SESSION_ID.
  ENDIF.
ENDFUNCTION.
