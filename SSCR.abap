TYPE-POOL SSCR .

* One list of options
TYPES: BEGIN OF SSCR_OPT_LIST,
         NAME    LIKE RSRESTRICT-OPTIONLIST,
         OPTIONS LIKE RSOPTIONS,
       END   OF SSCR_OPT_LIST.

* List of option lists
TYPES: SSCR_OPT_LIST_TAB TYPE SSCR_OPT_LIST OCCURS 5.

* One line of table associating selection screen object with opt. list
TYPES: BEGIN OF SSCR_ASS,
         KIND LIKE RSSCR-KIND,         " A(ll), B(lock), S(elect-Option)
         NAME LIKE RSRESTRICT-OBJECTNAME,  " Blockname, maximal 20
         SG_MAIN LIKE RSRESTRICT-SIGN, " (only) I, SPACE = both
         SG_ADDY LIKE RSRESTRICT-SIGN, " additional SIGN
                                       " on multiple selection screen
         OP_MAIN LIKE RSRESTRICT-OPTIONLIST, " name of option list for
                                       " main selection screen
         OP_ADDY LIKE RSRESTRICT-OPTIONLIST, " name of additional option
                                " list for multiple selection screen
       END   OF SSCR_ASS.
* The association table
TYPES: SSCR_ASS_TAB TYPE SSCR_ASS OCCURS 20.
* The type for SELECT_OPTIONS_RESTRICT (to be extended)
TYPES: BEGIN OF SSCR_RESTRICT,
         OPT_LIST_TAB TYPE SSCR_OPT_LIST_TAB,
         ASS_TAB     TYPE SSCR_ASS_TAB,
       END   OF SSCR_RESTRICT.
* Restrictions for one program
TYPES: BEGIN OF SSCR_RESTRICT_1_PROG,
         PROGRAM LIKE SY-REPID,
         RESTRICT TYPE SSCR_RESTRICT,
       END   OF SSCR_RESTRICT_1_PROG.
* Restrictions for all programs
TYPES:  SSCR_RESTRICT_T TYPE SSCR_RESTRICT_1_PROG OCCURS 5.

* FREE SELECTIONS
* One line of table associating selection screen object with opt. list
TYPES: BEGIN OF SSCR_ASS_DS,
         KIND LIKE RSSCR-KIND,         " A(ll), S(elect-Option)
         TABLENAME LIKE RSDSTABS-PRIM_TAB,
         FIELDNAME LIKE RSDSTABS-PRIM_FNAME,
         SG_MAIN LIKE RSRESTRICT-SIGN, " (only) I, SPACE = both
         SG_ADDY LIKE RSRESTRICT-SIGN, " additional SIGN
                                       " on multiple selection screen
         OP_MAIN LIKE RSRESTRICT-OPTIONLIST, " name of option list for
                                       " main selection screen
         OP_ADDY LIKE RSRESTRICT-OPTIONLIST, " name of additional option
                                " list for multiple selection screen
       END   OF SSCR_ASS_DS.
* The association table
TYPES: SSCR_ASS_DS_TAB TYPE SSCR_ASS_DS OCCURS 20.
* The type for FREE_SELECTIONS_INIT (to be extended)
TYPES: BEGIN OF SSCR_RESTRICT_DS,
         OPT_LIST_TAB TYPE SSCR_OPT_LIST_TAB,
         ASS_TAB      TYPE SSCR_ASS_DS_TAB,
       END   OF SSCR_RESTRICT_DS.

types: begin of sscr_curr_quan,
        tablename like rsdstabs-prim_tab,
        fieldname like rsdstabs-prim_fname,
        reffield  like rsscr-dbfield,
        def_value type sy-waers,
       end of sscr_curr_quan.

types: sscr_curr_quan_t type sscr_curr_quan occurs 0.
