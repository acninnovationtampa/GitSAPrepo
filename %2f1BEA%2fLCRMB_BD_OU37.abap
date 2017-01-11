FUNCTION /1BEA/CRMB_BD_O_BDIGETDTL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BDI_GUID) TYPE  BEA_BDI_GUID
*"  EXPORTING
*"     REFERENCE(ES_BDI) TYPE  /1BEA/S_CRMB_BDI_WRK
*"  EXCEPTIONS
*"      NOTFOUND
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
* Time  : 13:52:50
*
*======================================================================
 CONSTANTS:
   LC_TABNAME TYPE SYMSGV VALUE '/1BEA/CRMB_BDI'
   .

  CLEAR ES_BDI.

* read BD item for the given key

* first, look up entry in buffer
  READ TABLE GT_BDI_WRK INTO ES_BDI
       WITH KEY BDI_GUID = IV_BDI_GUID.

  IF SY-SUBRC <> 0.
* entry not found in buffer
* => search for entry in database
    SELECT SINGLE * FROM /1BEA/CRMB_BDI
      INTO CORRESPONDING FIELDS OF ES_BDI
      WHERE BDI_GUID = IV_BDI_GUID.
    IF SY-SUBRC <> 0.
      MESSAGE E104(BEA) WITH IV_BDI_GUID LC_TABNAME RAISING NOTFOUND.
    ENDIF.
  ENDIF.
ENDFUNCTION.
