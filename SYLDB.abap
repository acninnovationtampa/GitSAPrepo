TYPE-POOL SYLDB .

* -------------------------------------------------------------------- *
* Types for logical databases                                          *
* -------------------------------------------------------------------- *

* PARAMETERS ... AS SEARCH PATTERN ----------------------------------- *

TYPE-POOLS RSDS.

TYPES SYLDB_TRANGE TYPE RSDS_TRANGE.

TYPES: BEGIN OF SYLDB_SP,
         HOTKEY LIKE SPPARAMS-HOTKEY,
         STRING LIKE SPPARAMS-STRING,
         TRANGE TYPE SYLDB_TRANGE,
       END   OF SYLDB_SP.
