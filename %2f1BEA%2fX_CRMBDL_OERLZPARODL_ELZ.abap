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
*-----------------------------------------------------------------*
*     FORM PARODL_ELZ_ERL_GET_PAR_DATA
*-----------------------------------------------------------------*
FORM PARODL_ELZ_ERL_GET_PAR_DATA
  USING
    UV_PARENTRECNO TYPE SYTABIX
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_PARTNER     TYPE BEAT_DLI_PAR_COM.

  DATA:
    LT_PARTNERSET_GUIDS     TYPE COMT_PARTNERSET_GUID_TAB,
    LT_PARTNER_INTERNAL_WRK TYPE COMT_PARTNER_WRKT,
    LS_PARTNER_INTERNAL_WRK TYPE COMT_PARTNER_WRK,
    LS_PARTNER              TYPE BEAS_DLI_PAR_COM,
    LS_ADDR1                TYPE BAPIADDR1,
    LS_ADDR2                TYPE BAPIADDR2,
    LS_ADDR3                TYPE BAPIADDR3.

  INSERT US_DLI_WRK-PARSET_GUID INTO TABLE LT_PARTNERSET_GUIDS.
  CALL FUNCTION 'COM_PARTNER_GET_MULTI_OW'
    EXPORTING
      IT_PARTNERSET_GUIDS        = LT_PARTNERSET_GUIDS
    IMPORTING
      ET_PARTNER                 = LT_PARTNER_INTERNAL_WRK
    EXCEPTIONS
        OTHERS                   = 0.
    CLEAR LT_PARTNERSET_GUIDS.
    LOOP AT LT_PARTNER_INTERNAL_WRK INTO LS_PARTNER_INTERNAL_WRK.
      MOVE-CORRESPONDING LS_PARTNER_INTERNAL_WRK TO LS_PARTNER.
* fill address data only for doument adress
      IF LS_PARTNER_INTERNAL_WRK-ADDR_ORIGIN = 'B' OR    " = document address
         LS_PARTNER_INTERNAL_WRK-ADDR_ORIGIN = 'C'.      " = referenced address
        CALL FUNCTION 'COM_PARTNER_ADDRESS_GET_COMPL'
          EXPORTING
            IV_ADDR_NR                  = LS_PARTNER_INTERNAL_WRK-ADDR_NR
            IV_ADDR_NP                  = LS_PARTNER_INTERNAL_WRK-ADDR_NP
            IV_ADDR_TYPE                = LS_PARTNER_INTERNAL_WRK-ADDR_TYPE
            IV_INCLUDE_SLOW_COMM_FIELDS = GC_TRUE
          IMPORTING
            ES_BAPIADDR1                = LS_ADDR1
            ES_BAPIADDR2                = LS_ADDR2
            ES_BAPIADDR3                = LS_ADDR3
          EXCEPTIONS
            OTHERS                      = 1.
        IF SY-SUBRC = 0.
          CASE LS_PARTNER_INTERNAL_WRK-ADDR_TYPE.
            WHEN 1.   " = COMPANY
              MOVE-CORRESPONDING LS_ADDR1 TO LS_PARTNER.
            WHEN 2.   " = PERSON
              MOVE-CORRESPONDING LS_ADDR2 TO LS_PARTNER.
            WHEN 3.   " = CONTACT_PERSON
              MOVE-CORRESPONDING LS_ADDR3 TO LS_PARTNER.
          ENDCASE.
        ENDIF.
      ENDIF.
      LS_PARTNER-PARENTRECNO = UV_PARENTRECNO.
      APPEND LS_PARTNER TO CT_PARTNER.
    ENDLOOP.
ENDFORM.
*-----------------------------------------------------------------*
*     FORM PARODL_ELZ_ERL_GET_PAR_DRV
*-----------------------------------------------------------------*
FORM PARODL_ELZ_ERL_GET_PAR_DRV
  USING
    US_DLI_WRK     TYPE /1BEA/S_CRMB_DLI_WRK
  CHANGING
    CT_PARTNER     TYPE BEAT_PAR_COM.

  DATA:
    LT_PARTNERSET_GUIDS     TYPE COMT_PARTNERSET_GUID_TAB,
    LT_PARTNER_INTERNAL_WRK TYPE COMT_PARTNER_WRKT,
    LS_PARTNER_INTERNAL_WRK TYPE COMT_PARTNER_WRK,
    LS_PARTNER              TYPE BEAS_PAR_COM,
    LS_ADDR1                TYPE BAPIADDR1,
    LS_ADDR2                TYPE BAPIADDR2,
    LS_ADDR3                TYPE BAPIADDR3.

  INSERT US_DLI_WRK-PARSET_GUID INTO TABLE LT_PARTNERSET_GUIDS.
  CALL FUNCTION 'COM_PARTNER_GET_MULTI_OW'
    EXPORTING
      IT_PARTNERSET_GUIDS        = LT_PARTNERSET_GUIDS
    IMPORTING
      ET_PARTNER                 = LT_PARTNER_INTERNAL_WRK
    EXCEPTIONS
        OTHERS                   = 0.
    CLEAR LT_PARTNERSET_GUIDS.
    LOOP AT LT_PARTNER_INTERNAL_WRK INTO LS_PARTNER_INTERNAL_WRK.
      MOVE-CORRESPONDING LS_PARTNER_INTERNAL_WRK TO LS_PARTNER.
* fill address data only for doument adress
      IF LS_PARTNER_INTERNAL_WRK-ADDR_ORIGIN = 'B' OR    " = document address
         LS_PARTNER_INTERNAL_WRK-ADDR_ORIGIN = 'C'.      " = referenced address
        CALL FUNCTION 'COM_PARTNER_ADDRESS_GET_COMPL'
          EXPORTING
            IV_ADDR_NR                  = LS_PARTNER_INTERNAL_WRK-ADDR_NR
            IV_ADDR_NP                  = LS_PARTNER_INTERNAL_WRK-ADDR_NP
            IV_ADDR_TYPE                = LS_PARTNER_INTERNAL_WRK-ADDR_TYPE
            IV_INCLUDE_SLOW_COMM_FIELDS = GC_TRUE
          IMPORTING
            ES_BAPIADDR1                = LS_ADDR1
            ES_BAPIADDR2                = LS_ADDR2
            ES_BAPIADDR3                = LS_ADDR3
          EXCEPTIONS
            OTHERS                      = 1.
        IF SY-SUBRC = 0.
          CASE LS_PARTNER_INTERNAL_WRK-ADDR_TYPE.
            WHEN 1.   " = COMPANY
              MOVE-CORRESPONDING LS_ADDR1 TO LS_PARTNER.
            WHEN 2.   " = PERSON
              MOVE-CORRESPONDING LS_ADDR2 TO LS_PARTNER.
            WHEN 3.   " = CONTACT_PERSON
              MOVE-CORRESPONDING LS_ADDR3 TO LS_PARTNER.
          ENDCASE.
        ENDIF.
      ENDIF.
      INSERT LS_PARTNER INTO TABLE CT_PARTNER.
    ENDLOOP.
ENDFORM.
