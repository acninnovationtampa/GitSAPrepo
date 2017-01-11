FUNCTION RS_TRDIR_SELECT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(TRDIR_NAME) LIKE  TRDIR-NAME
*"       EXPORTING
*"             VALUE(TRDIR_ROW) LIKE  TRDIR STRUCTURE  TRDIR
*"       EXCEPTIONS
*"              INTERNAL_ERROR
*"              PARAMETER_ERROR
*"              NOT_FOUND
*"----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Data base operations (SELECT, MODIFY, ...) with buffer management
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Changed:  11.12.97
* Created:  08.12.97         Manfred Schneider
* Changes:  08.12.97  MS001  Manfred Schneider
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Descriptions:
*    MS001  Function module created
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Purpose:
*    See function module documentation
*-----------------------------------------------------------------------

* Initialize export parameter
  CLEAR TRDIR_ROW.

* Check import parameter
  IF TRDIR_NAME = SPACE.
    MESSAGE S550 WITH
      'TRDIR_NAME' 'RS_TRDIR_SELECT'   "#EC NOTEXT
      RAISING PARAMETER_ERROR.
    EXIT.                              " E X I T
  ENDIF.

* Get buffer from ABAP memory
  CLEAR TRDIR_HASH.
  IMPORT TRDIR_HASH FROM MEMORY ID MEMORY_ID.
  IF SY-SUBRC <> 0.
    " first call; no table in ABAP memory; TRDIR_HASH is now empty
  ENDIF.

* Try to find entry in buffer; if ok: return TRDIR entry
  READ TABLE TRDIR_HASH INTO TRDIR_ROW
    WITH KEY NAME = TRDIR_NAME.
* If not found: select from database
  IF SY-SUBRC <> 0.
    SELECT SINGLE * FROM TRDIR INTO TRDIR_ROW
      WHERE NAME = TRDIR_NAME.
* If not found in database: raise exception
    IF SY-SUBRC <> 0.
      MESSAGE S551 WITH TRDIR_NAME 'TRDIR'                   "#EC NOTEXT
        RAISING NOT_FOUND.
      EXIT.                            " E X I T
    ENDIF.
* If found in database: insert in table, save in buffer
* and return TRDIR entry
    INSERT TRDIR_ROW INTO TABLE TRDIR_HASH.
    IF SY-SUBRC <> 0.
      MESSAGE S552 WITH
        'Insert Into Table TRDIR_HASH' 'RS_TRDIR_SELECT'     "#EC NOTEXT
        RAISING INTERNAL_ERROR.
      EXIT.                            " E X I T
    ENDIF.
    EXPORT TRDIR_HASH TO MEMORY ID MEMORY_ID.
    IF SY-SUBRC <> 0.
      MESSAGE S552 WITH
        'Export To Memory' 'RS_TRDIR_SELECT'                 "#EC NOTEXT
        RAISING INTERNAL_ERROR.
      EXIT.                            " E X I T
    ENDIF.
  ENDIF.

ENDFUNCTION.
