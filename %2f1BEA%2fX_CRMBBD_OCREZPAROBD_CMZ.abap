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
*       FORM BD_PARTNERSET_COMPRESS
*---------------------------------------------------------------------
  FORM PAROBD_CMZ_BD_PARSET_COMPRESS
    CHANGING
      CT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK.
    DATA:
      LT_BDI_WRK     TYPE /1BEA/T_CRMB_BDI_WRK,
      LS_BDI_WRK_H   TYPE /1BEA/S_CRMB_BDI_WRK,
      LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK.

    READ TABLE CT_BDI_WRK INTO LS_BDI_WRK_H INDEX 1.
    IF SY-SUBRC EQ 0.
      READ TABLE GT_BDI_WRK
         WITH KEY BDH_GUID = LS_BDI_WRK_H-BDH_GUID
         BINARY SEARCH TRANSPORTING NO FIELDS.
      LOOP AT GT_BDI_WRK INTO LS_BDI_WRK FROM SY-TABIX.
        IF LS_BDI_WRK-BDH_GUID = LS_BDI_WRK_H-BDH_GUID.
          APPEND LS_BDI_WRK TO LT_BDI_WRK.
        ELSE.
          EXIT. "from LOOP
        ENDIF.
      ENDLOOP.
      IF NOT LT_BDI_WRK IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_BD_PAR_O_COMPRESS'
           EXPORTING
             IT_BDI            = CT_BDI_WRK
             IT_BDI_PART       = LT_BDI_WRK
           IMPORTING
             ET_BDI            = CT_BDI_WRK
           EXCEPTIONS
             REJECT            = 0
             OTHERS            = 0.
      ENDIF.
    ENDIF.
  ENDFORM.
