FUNCTION /1BEA/CRMB_DL_O_GETDETAIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_DLI_GUID) TYPE  BEA_DLI_GUID
*"  EXPORTING
*"     REFERENCE(ES_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
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
* Time  : 13:53:10
*
*======================================================================

 CONSTANTS:
   LC_TABNAME TYPE SYMSGV VALUE '/1BEA/CRMB_DLI'.
 data: lv_dli_guid type bea_dli_guid.

  lv_dli_guid = iv_dli_guid.
  CLEAR ES_DLI.
* first, look up entry in buffer
  READ TABLE GT_DLI_WRK INTO ES_DLI
       WITH KEY DLI_GUID = lV_DLI_GUID BINARY SEARCH.
  IF SY-SUBRC <> 0.
*   entry not found in buffer => search for entry in database
    SELECT SINGLE * FROM /1BEA/CRMB_DLI
      INTO CORRESPONDING FIELDS OF ES_DLI
      WHERE DLI_GUID = lV_DLI_GUID.
    IF SY-SUBRC <> 0.
      MESSAGE E104(BEA) WITH IV_DLI_GUID LC_TABNAME RAISING NOTFOUND.
    ENDIF.
  ENDIF.

ENDFUNCTION.
