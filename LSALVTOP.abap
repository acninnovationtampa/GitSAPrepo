function-pool salv.                         "MESSAGE-ID ..

type-pools: slis,
            kkblo.
tables: euinfo.

class cl_gui_alv_grid definition load.

constants: gc_tabname type slis_tabname value '1',
           gc_max_columns type i value 99.  "Y6BK098821 und Y6DK097472


data: g_repid like sy-repid.

include LSALVD01.             " global objects for BLOCK_LIST_DISPLAY
