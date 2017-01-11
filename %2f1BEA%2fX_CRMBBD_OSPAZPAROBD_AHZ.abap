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
*       Form  ANALYZE_HEAD_PARTNER
*---------------------------------------------------------------------
FORM PAROBD_AHZ_ANALYZE_HEAD_PAR
  USING    IV_PARSET_GUID_L TYPE BEA_PARSET_GUID
           IV_PARSET_GUID_R TYPE BEA_PARSET_GUID
  CHANGING CT_SPLIT         TYPE BEAT_SPLALY.

  DATA:
    LV_EQUAL        TYPE BEA_BOOLEAN,
    LT_SPLIT        TYPE BEAT_SPLALY,
    LT_FIELDS       TYPE DD03TTYP,
    LS_FIELDS       LIKE DD03P,
    LS_SPLIT        TYPE BEAS_SPLALY,
    LV_TABIX_L      TYPE SY-TABIX,
    LV_TABIX_R      TYPE SY-TABIX,
    LT_PAR_L        TYPE BEAT_PAR_WRK,
    LS_PAR_L        TYPE BEAS_PAR_WRK,
    LT_PAR_R        TYPE BEAT_PAR_WRK,
    LS_PAR_R        TYPE BEAS_PAR_WRK.
  FIELD-SYMBOLS:
    <VALUE1>,
    <VALUE2>.

  CALL FUNCTION 'BEA_PAR_O_GET'
       EXPORTING
            IV_PARSET_GUID    = IV_PARSET_GUID_L
            IV_RESPECT_NUMBER = GC_TRUE
       IMPORTING
            ET_PAR            = LT_PAR_L
       EXCEPTIONS
            REJECT            = 0
            OTHERS            = 0.

  CALL FUNCTION 'BEA_PAR_O_GET'
       EXPORTING
            IV_PARSET_GUID    = IV_PARSET_GUID_R
            IV_RESPECT_NUMBER = GC_TRUE
       IMPORTING
            ET_PAR            = LT_PAR_R
       EXCEPTIONS
            REJECT            = 0
            OTHERS            = 0.

  LOOP AT LT_PAR_L INTO LS_PAR_L.
    LV_TABIX_L = SY-TABIX.
    READ TABLE LT_PAR_R INTO LS_PAR_R
         WITH KEY GUID         = IV_PARSET_GUID_R
                  PARTNER_FCT  = LS_PAR_L-PARTNER_FCT
                  MAINPARTNER  = LS_PAR_L-MAINPARTNER.
    IF SY-SUBRC = 0.
      LV_TABIX_R = SY-TABIX.
      CLEAR LS_PAR_L-PARTNER_GUID.
      CLEAR LS_PAR_R-PARTNER_GUID.
      CLEAR LS_PAR_L-GUID.
      CLEAR LS_PAR_R-GUID.
      CLEAR LS_PAR_L-KIND_OF_ENTRY.
      CLEAR LS_PAR_R-KIND_OF_ENTRY.
      clear LS_PAR_L-attribute_values-partner_guid.
      clear LS_PAR_R-attribute_values-partner_guid.
      IF LS_PAR_L = LS_PAR_R.
*         partners are equal
        DELETE LT_PAR_L INDEX LV_TABIX_L.
        DELETE LT_PAR_R INDEX LV_TABIX_R.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_PAR_R INTO LS_PAR_R.
    LV_TABIX_R = SY-TABIX.
    READ TABLE LT_PAR_L INTO LS_PAR_L
         WITH KEY GUID         = IV_PARSET_GUID_L
                  PARTNER_FCT  = LS_PAR_R-PARTNER_FCT
                  MAINPARTNER  = LS_PAR_R-MAINPARTNER.
    IF SY-SUBRC = 0.
      LV_TABIX_L = SY-TABIX.
      CLEAR LS_PAR_L-PARTNER_GUID.
      CLEAR LS_PAR_R-PARTNER_GUID.
      CLEAR LS_PAR_L-GUID.
      CLEAR LS_PAR_R-GUID.
      CLEAR LS_PAR_L-KIND_OF_ENTRY.
      CLEAR LS_PAR_R-KIND_OF_ENTRY.
      clear LS_PAR_L-attribute_values-partner_guid.
      clear LS_PAR_R-attribute_values-partner_guid.
      IF LS_PAR_R = LS_PAR_L.
*         partners are equal
        DELETE LT_PAR_L INDEX LV_TABIX_L.
        DELETE LT_PAR_R INDEX LV_TABIX_R.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
          NAME          = 'BEAS_PAR_WRK'
     TABLES
          DD03P_TAB     = LT_FIELDS
     EXCEPTIONS
          ILLEGAL_INPUT = 0
          OTHERS        = 0.

  LOOP AT LT_PAR_R INTO LS_PAR_R.
    LV_TABIX_R = SY-TABIX.
    READ TABLE LT_PAR_L INTO LS_PAR_L
         WITH KEY GUID         = IV_PARSET_GUID_L
                  PARTNER_FCT  = LS_PAR_R-PARTNER_FCT
                  MAINPARTNER  = LS_PAR_R-MAINPARTNER.
    IF SY-SUBRC = 0.
      LV_TABIX_L = SY-TABIX.

      LOOP AT LT_FIELDS INTO LS_FIELDS.
        CASE LS_FIELDS-FIELDNAME.
          WHEN 'EXTERNAL_PARTNER_NUMBER'
            OR 'PARTNER_PFT'
            OR 'PFT_SUBTYPE'
            OR 'ADDR_NR'
            OR 'ADDR_NP'.
            ASSIGN COMPONENT LS_FIELDS-FIELDNAME
              OF STRUCTURE LS_PAR_L TO <VALUE1>.
            CHECK SY-SUBRC = 0.
            ASSIGN COMPONENT LS_FIELDS-FIELDNAME
              OF STRUCTURE LS_PAR_R TO <VALUE2>.
            CHECK SY-SUBRC = 0.
            IF <VALUE1> <> <VALUE2>.
              LS_SPLIT-SPLIT_REASON = GC_PARTNER.
              LS_SPLIT-PARTNER_FCT  = LS_PAR_R-PARTNER_FCT.
              LS_SPLIT-FIELDNAME    = LS_FIELDS-FIELDNAME.
              LS_SPLIT-ROLLNAME     = LS_FIELDS-ROLLNAME.
              LS_SPLIT-VALUE_L      = <VALUE1>.
              LS_SPLIT-VALUE_R      = <VALUE2>.
              APPEND LS_SPLIT TO LT_SPLIT.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

      DELETE LT_PAR_L INDEX LV_TABIX_L.

    ELSE.
      CLEAR LS_SPLIT.
      LS_SPLIT-SPLIT_REASON = GC_PARTNER.
      LS_SPLIT-PARTNER_FCT  = LS_PAR_R-PARTNER_FCT.
      LS_SPLIT-VALUE_R      = LS_PAR_R-EXTERNAL_PARTNER_NUMBER.
      LS_SPLIT-FIELDNAME    = 'EXTERNAL_PARTNER_NUMBER'.
      LS_SPLIT-ROLLNAME     = 'COMT_PARTNER_NUMBER'.
      APPEND LS_SPLIT TO LT_SPLIT.
    ENDIF.

    DELETE LT_PAR_R INDEX LV_TABIX_R.

  ENDLOOP.

  LOOP AT LT_PAR_L INTO LS_PAR_L.
    CLEAR LS_SPLIT.
    LS_SPLIT-SPLIT_REASON = GC_PARTNER.
    LS_SPLIT-PARTNER_FCT  = LS_PAR_L-PARTNER_FCT.
    LS_SPLIT-VALUE_L      = LS_PAR_L-EXTERNAL_PARTNER_NUMBER.
    LS_SPLIT-FIELDNAME    = 'EXTERNAL_PARTNER_NUMBER'.
    LS_SPLIT-ROLLNAME     = 'COMT_PARTNER_NUMBER'.
    APPEND LS_SPLIT TO LT_SPLIT.
  ENDLOOP.
  IF LT_SPLIT IS INITIAL.
*   ckeck, if partnersets are really equal
    LV_EQUAL = GC_TRUE.
    CALL FUNCTION 'COM_PARTNER_COMPARE_SETS'
         EXPORTING
              IV_PARTNERSET_GUID_A = IV_PARSET_GUID_L
              IV_PARTNERSET_GUID_B = IV_PARSET_GUID_R
         IMPORTING
              EV_SETS_ARE_EQUAL    = LV_EQUAL
         EXCEPTIONS
              SET_NOT_FOUND        = 0
              OTHERS               = 0.
    IF LV_EQUAL = GC_FALSE.
      CLEAR LS_SPLIT.
      LS_SPLIT-SPLIT_REASON = GC_PARTNER.
      APPEND LS_SPLIT TO LT_SPLIT.
    ENDIF.
  ENDIF.
  INSERT LINES OF LT_SPLIT INTO TABLE CT_SPLIT.
ENDFORM.                    " ANALYZE_HEAD_PARTNER
