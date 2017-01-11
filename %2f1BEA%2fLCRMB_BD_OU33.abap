FUNCTION /1BEA/CRMB_BD_O_BDHGETDTL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BDH_GUID) TYPE  BEA_BDH_GUID
*"  EXPORTING
*"     REFERENCE(ES_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
   LC_TABNAME TYPE SYMSGV VALUE '/1BEA/CRMB_BDH'
   .

  CLEAR ES_BDH.

* read BD head for the given key

* first, look up entry in buffer
  READ TABLE GT_BDH_WRK INTO ES_BDH
       WITH KEY BDH_GUID = IV_BDH_GUID.

  IF SY-SUBRC <> 0.
* entry not found in buffer
* => search for entry in database
    SELECT SINGLE * FROM /1BEA/CRMB_BDH
      INTO CORRESPONDING FIELDS OF ES_BDH
      WHERE BDH_GUID = IV_BDH_GUID.
    IF SY-SUBRC <> 0.
      MESSAGE E104(BEA) WITH IV_BDH_GUID LC_TABNAME RAISING NOTFOUND.
    ENDIF.
  ENDIF.


ENDFUNCTION.
