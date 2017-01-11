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
    LS_PRCODL_UP_ITC TYPE BEAS_ITC_WRK.

    LS_PRCODL_UP_ITC = US_ITC.
    IF LS_DLI_WRK-SRVDOC_SOURCE IS INITIAL.
      IF NOT LS_DLI_WRK-PRIDOC_GUID IS INITIAL.
        CALL FUNCTION 'BEA_PRC_O_GET_PROC'
          EXPORTING
            IV_PRIDOC_GUID = LS_DLI_WRK-PRIDOC_GUID
          IMPORTING
            EV_PRIC_PROC   = LS_PRCODL_UP_ITC-DLI_PRC_PROC.
      ENDIF.
      CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_DELETE'
           EXPORTING
             IS_DLI = LS_DLI_WRK
             IS_ITC = US_ITC.                   "#EC ENHOK
      CLEAR LS_DLI_WRK-PRIDOC_GUID.
      PERFORM PRICING_FILL
        USING
          US_DLI_INT
          UT_CONDITION
          LS_PRCODL_UP_ITC
        CHANGING
          LS_DLI_WRK
          LT_RETURN.
    ENDIF.
