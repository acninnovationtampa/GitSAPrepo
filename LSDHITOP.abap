FUNCTION-POOL SDHI.                         "MESSAGE-ID ..
INCLUDE RADSHMAC.
TYPE-POOLS F4TYP.  "Br�cke zu alten F4-Bausteinen
TABLES: DDSHDEFSH.  "Tabelle der Default-Suchhilfen


DATA %SHLPNAME LIKE DD30V-SHLPNAME.    " f�r �bergabe an Callback-Form
                                       " von F4TOOL_SUBSHLP_BY_HOTKEY
CONSTANTS: par%domname LIKE DDSHFPROP-FIELDNAME VALUE 'DOMNAME',
           par%value LIKE DDSHFPROP-FIELDNAME VALUE 'VALUE',
           par%text LIKE DDSHFPROP-FIELDNAME VALUE 'TEXT',
           PAR%ROLLNAME LIKE DDSHFPROP-FIELDNAME VALUE 'ROLLNAME',
           PAR%TABNAME LIKE DDSHFPROP-FIELDNAME VALUE 'TABNAME'.

TYPES:: begin of t1,
          shlpname type shlp_descr-shlpname,
          shlptype type shlp_descr-shlptype,
        end of t1.
DATA:   saved_shlptypes type sorted table of t1 with unique key shlpname.
