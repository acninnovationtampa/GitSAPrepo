*----------------------------------------------------------------------*
*   INCLUDE LSALVD01                                                   *
*----------------------------------------------------------------------*
CONSTANTS:
               GC_MAX_OF_BLOCK_LISTS_PLUS_ONE TYPE I VALUE 30,  "Y7AK077911
               GC_LIST_TYPE_HS VALUE 'H',
               GC_LIST_TYPE_S  VALUE 'S',
               GC_DUMMY VALUE ' '.

DATA:
               G_PAGE TYPE I,
               GS_STATUS TYPE SLIS_STATUS,
               XS_STATUS LIKE GS_STATUS.

DATA:
               BEGIN OF GT_DUMMY OCCURS 0,
                 DUMMY,
               END OF GT_DUMMY.
DATA:
               BEGIN OF GT_OVERVIEW  OCCURS 0,
                 LIST_ID TYPE I,
                 TEXT TYPE SLIS_TEXT40,
               END OF GT_OVERVIEW.
DATA:
*              Table of stacked data
               BEGIN OF GT_STACK  OCCURS 0,
                  LIST_ID                 TYPE I,
                  LIST_TYPE               TYPE C,
                  HEADER_TABNAME          TYPE SLIS_TABNAME,
                  ITEM_TABNAME            TYPE SLIS_TABNAME,
                  CALLBACK_PROGNAME       LIKE SY-REPID,
                  FORM_END_OF_PAGE        TYPE SLIS_FORMNAME,
                  FORM_END_OF_LIST        TYPE SLIS_FORMNAME,
                  FORM_TOP_OF_PAGE        TYPE SLIS_FORMNAME,
                  FORM_TOP_OF_LIST        TYPE SLIS_FORMNAME,
*(DEL)            form_PF_STATUS_SET      TYPE SLIS_FORMNAME,
*(DEL)            form_USER_COMMAND       TYPE SLIS_FORMNAME,
                  FORM_BEFORE_LINE_OUTPUT TYPE SLIS_FORMNAME,
                  FORM_AFTER_LINE_OUTPUT TYPE SLIS_FORMNAME,
                  FORM_LIST_MODIFY   TYPE SLIS_FORMNAME,
                  FORM_FOREIGN_TOP_OF_PAGE TYPE SLIS_FORMNAME,
                  FORM_FOREIGN_END_OF_PAGE TYPE SLIS_FORMNAME,
                  FORM_TOP_OF_COVERPAGE   TYPE SLIS_FORMNAME,
                  FORM_END_OF_COVERPAGE   TYPE SLIS_FORMNAME,
                  FORM_ITEM_DATA_EXPAND   TYPE SLIS_FORMNAME,
                  LAYOUT TYPE KKBLO_LAYOUT,
                  FIELDCAT TYPE KKBLO_T_FIELDCAT,
                  SORT     TYPE KKBLO_T_SORTINFO,
                  FILTER   TYPE KKBLO_T_FILTER,
                  KEYINFO  TYPE KKBLO_KEYINFO,
               END   OF GT_STACK.

FIELD-SYMBOLS:
               <ITEM_TABLE01>  TYPE TABLE,
               <ITEM_TABLE02>  TYPE TABLE,
               <ITEM_TABLE03>  TYPE TABLE,
               <ITEM_TABLE04>  TYPE TABLE,
               <ITEM_TABLE05>  TYPE TABLE,
               <ITEM_TABLE06>  TYPE TABLE,
               <ITEM_TABLE07>  TYPE TABLE,
               <ITEM_TABLE08>  TYPE TABLE,
               <ITEM_TABLE09>  TYPE TABLE,
               <ITEM_TABLE10>  TYPE TABLE,
               <ITEM_TABLE11>  TYPE TABLE,
               <ITEM_TABLE12>  TYPE TABLE,
               <ITEM_TABLE13>  TYPE TABLE,
               <ITEM_TABLE14>  TYPE TABLE,
               <ITEM_TABLE15>  TYPE TABLE,
               <ITEM_TABLE16>  TYPE TABLE,
               <ITEM_TABLE17>  TYPE TABLE,
               <ITEM_TABLE18>  TYPE TABLE,
               <ITEM_TABLE19>  TYPE TABLE,
*<<<Y6BK074974
               <ITEM_TABLE20>  TYPE TABLE,
               <ITEM_TABLE21>  TYPE TABLE,
               <ITEM_TABLE22>  TYPE TABLE,
               <ITEM_TABLE23>  TYPE TABLE,
               <ITEM_TABLE24>  TYPE TABLE,
               <ITEM_TABLE25>  TYPE TABLE,
               <ITEM_TABLE26>  TYPE TABLE,
               <ITEM_TABLE27>  TYPE TABLE,
               <ITEM_TABLE28>  TYPE TABLE,
               <ITEM_TABLE29>  TYPE TABLE,
*>>>Y6BK074974
               <ITEM_TABLE01_WA>,
               <ITEM_TABLE02_WA>,
               <ITEM_TABLE03_WA>,
               <ITEM_TABLE04_WA>,
               <ITEM_TABLE05_WA>,
               <ITEM_TABLE06_WA>,
               <ITEM_TABLE07_WA>,
               <ITEM_TABLE08_WA>,
               <ITEM_TABLE09_WA>,
               <ITEM_TABLE10_WA>,
               <ITEM_TABLE11_WA>,
               <ITEM_TABLE12_WA>,
               <ITEM_TABLE13_WA>,
               <ITEM_TABLE14_WA>,
               <ITEM_TABLE15_WA>,
               <ITEM_TABLE16_WA>,
               <ITEM_TABLE17_WA>,
               <ITEM_TABLE18_WA>,
               <ITEM_TABLE19_WA>,
*<<<Y6BK074974
               <ITEM_TABLE20_WA>,
               <ITEM_TABLE21_WA>,
               <ITEM_TABLE22_WA>,
               <ITEM_TABLE23_WA>,
               <ITEM_TABLE24_WA>,
               <ITEM_TABLE25_WA>,
               <ITEM_TABLE26_WA>,
               <ITEM_TABLE27_WA>,
               <ITEM_TABLE28_WA>,
               <ITEM_TABLE29_WA>,
*>>>Y6BK074974
               <HEADER_TABLE01>  TYPE TABLE,
               <HEADER_TABLE02>  TYPE TABLE,
               <HEADER_TABLE03>  TYPE TABLE,
               <HEADER_TABLE04>  TYPE TABLE,
               <HEADER_TABLE05>  TYPE TABLE,
               <HEADER_TABLE06>  TYPE TABLE,
               <HEADER_TABLE07>  TYPE TABLE,
               <HEADER_TABLE08>  TYPE TABLE,
               <HEADER_TABLE09>  TYPE TABLE,
               <HEADER_TABLE10>  TYPE TABLE,
               <HEADER_TABLE11>  TYPE TABLE,
               <HEADER_TABLE12>  TYPE TABLE,
               <HEADER_TABLE13>  TYPE TABLE,
               <HEADER_TABLE14>  TYPE TABLE,
               <HEADER_TABLE15>  TYPE TABLE,
               <HEADER_TABLE16>  TYPE TABLE,
               <HEADER_TABLE17>  TYPE TABLE,
               <HEADER_TABLE18>  TYPE TABLE,
               <HEADER_TABLE19>  TYPE TABLE,
*<<<Y6BK074974
               <HEADER_TABLE20>  TYPE TABLE,
               <HEADER_TABLE21>  TYPE TABLE,
               <HEADER_TABLE22>  TYPE TABLE,
               <HEADER_TABLE23>  TYPE TABLE,
               <HEADER_TABLE24>  TYPE TABLE,
               <HEADER_TABLE25>  TYPE TABLE,
               <HEADER_TABLE26>  TYPE TABLE,
               <HEADER_TABLE27>  TYPE TABLE,
               <HEADER_TABLE28>  TYPE TABLE,
               <HEADER_TABLE29>  TYPE TABLE,
*>>>Y6BK074974
               <HEADER_TABLE01_WA>,
               <HEADER_TABLE02_WA>,
               <HEADER_TABLE03_WA>,
               <HEADER_TABLE04_WA>,
               <HEADER_TABLE05_WA>,
               <HEADER_TABLE06_WA>,
               <HEADER_TABLE07_WA>,
               <HEADER_TABLE08_WA>,
               <HEADER_TABLE09_WA>,
               <HEADER_TABLE10_WA>,
               <HEADER_TABLE11_WA>,
               <HEADER_TABLE12_WA>,
               <HEADER_TABLE13_WA>,
               <HEADER_TABLE14_WA>,
               <HEADER_TABLE15_WA>,
               <HEADER_TABLE16_WA>,
               <HEADER_TABLE17_WA>,
               <HEADER_TABLE18_WA>,
               <HEADER_TABLE19_WA>,
*<<<Y6BK074974
               <HEADER_TABLE20_WA>,
               <HEADER_TABLE21_WA>,
               <HEADER_TABLE22_WA>,
               <HEADER_TABLE23_WA>,
               <HEADER_TABLE24_WA>,
               <HEADER_TABLE25_WA>,
               <HEADER_TABLE26_WA>,
               <HEADER_TABLE27_WA>,
               <HEADER_TABLE28_WA>,
               <HEADER_TABLE29_WA>.
*>>>Y6BK074974
