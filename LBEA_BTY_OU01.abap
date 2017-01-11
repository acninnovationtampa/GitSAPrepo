FUNCTION BEA_BTY_O_GETDETAIL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_APPL) TYPE  BEF_APPL
*"     VALUE(IV_BTY) TYPE  BEA_BILL_TYPE
*"  EXPORTING
*"     REFERENCE(ES_BTY_WRK) TYPE  BEAS_BTY_WRK
*"  EXCEPTIONS
*"      OBJECT_NOT_FOUND
*"----------------------------------------------------------------------
************************************************************************
* Define local data
************************************************************************
  IF NOT GS_BTY-BILL_TYPE EQ IV_BTY
     OR  GS_BTY-BILL_TYPE IS INITIAL.
    SELECT SINGLE * FROM  BEAC_BTY
                    INTO CORRESPONDING FIELDS OF GS_BTY
                      WHERE APPLICATION = IV_APPL
                        AND BILL_TYPE = IV_BTY.
    IF SY-SUBRC <> 0.
      CLEAR GS_BTY.
      MESSAGE E403(BEA) WITH IV_BTY IV_APPL RAISING OBJECT_NOT_FOUND.
    ENDIF.
  ENDIF.
  MOVE-CORRESPONDING GS_BTY TO ES_BTY_WRK.
ENDFUNCTION.
