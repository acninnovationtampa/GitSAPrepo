function-pool /sapcnd/customizing_sel message-id /sapcnd/customizing.

*-----------------------------------------------------------------------
* Global data definitions are not allowed within this include.
*-----------------------------------------------------------------------

* This file _MAY ONLY_ contain TYPES or CONSTANTS. ANY KIND of DATA
* or TABLES statments are NOT allowed. If you do so, you owe a fine
* diner to everyone.. ;)

type-pools  ctcus.
type-pools  shlp.                      "search helps

* data for F4 for fieldname of relationships in field catalogue
types: begin of ys_field_info,
         s_t681ff type /sapcnd/t681ff,
         scrtext_l type scrtext_l,
       end of ys_field_info.

* table for dynamic where clause
types: gtt_dynsql type standard table of dynamicsql.

constants: gc_and(3)    type c     value 'AND',
           gc_spras_eng type spras value 'E'.
