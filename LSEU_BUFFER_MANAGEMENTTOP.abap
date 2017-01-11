FUNCTION-POOL SEU_BUFFER_MANAGEMENT MESSAGE-ID EU.

*-----------------------------------------------------------------------
* Data base operations (SELECT, MODIFY, ...) with buffer management
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Changed:  08.12.97
* Created:  08.12.97         Manfred Schneider
* Changes:  08.12.97  MS001  Manfred Schneider
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Descriptions:
*    MS001  Include created
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Overview:
*    Global declarations
*-----------------------------------------------------------------------

CONSTANTS: MEMORY_ID(30) VALUE 'RS_TRDIR_BUFFER'.

TABLES: TRDIR.

TYPES: TRDIR_HASH_TYPE TYPE HASHED TABLE OF TRDIR WITH UNIQUE KEY NAME.
DATA:  TRDIR_HASH      TYPE TRDIR_HASH_TYPE.

*---------------------------------------------------------------------*
* Dummy to prevent SLIN warnings                                      *
*---------------------------------------------------------------------*
FORM DUMMY.
  TRDIR = TRDIR.
ENDFORM.
