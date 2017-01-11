*----------------------------------------------------------------------*
* KORREKTUREN
*----------------------------------------------------------------------*
* Korrigiert zu Release:   Korrekturkürzel:   Korrekturnummer:   excl:
*      Beschreibung:
*----------------------------------------------------------------------*
* ____                     __________           __________          (_)
*----------------------------------------------------------------------*
TYPE-POOL KKBLO .
TYPE-POOLS: SLIS.

*--- strings
TYPES: KKBLO_TABNAME   TYPE SLIS_TABNAME,
       KKBLO_FIELDNAME TYPE SLIS_FIELDNAME,
       KKBLO_FORMNAME  TYPE SLIS_FORMNAME,
       KKBLO_ENTRY     TYPE SLIS_ENTRY,
       KKBLO_COLDESC   TYPE SLIS_COLDESC.

*--- Structure for exception quickinfo
TYPES: KKBLO_QINFO TYPE ALV_S_QINF.

*--- Structure for exception quickinfo table
TYPES: KKBLO_T_QINFO TYPE KKBLO_QINFO OCCURS 0.

*--- Structure for the excluding table (function codes)
TYPES: KKBLO_EXTAB TYPE SLIS_EXTAB.

*--- excluding table
TYPES: KKBLO_T_EXTAB TYPE KKBLO_EXTAB OCCURS 1.

*--- Structure for reprep-initialization
TYPES: KKBLO_REPREP_ID TYPE SLIS_REPREP_ID.

*--- Structure for reprep-parameters
TYPES: BEGIN OF KKBLO_REPREP,
         CALLBACK_PROGRAM LIKE SY-REPID,
         CALLBACK_REPREP_SEL_MODIFY TYPE KKBLO_FORMNAME,
         REPREP_ID TYPE KKBLO_REPREP_ID,
       END OF KKBLO_REPREP.

*--- Structure for callback_reprep_sel_modify
TYPES: KKBLO_REPREP_COMMUNICATION TYPE SLIS_REPREP_COMMUNICATION.

*--- Structure for colors
TYPES: KKBLO_COLOR TYPE SLIS_COLOR.
TYPES: BEGIN OF KKBLO_COLTYPES.
INCLUDE TYPE SLIS_COLTYPES.
TYPES:  END OF KKBLO_COLTYPES.

*--- Structure for specific color settings
TYPES: BEGIN OF KKBLO_SPECIALCOL.
INCLUDE TYPE SLIS_SPECIALCOL_ALV.
TYPES:  END OF KKBLO_SPECIALCOL.
TYPES: KKBLO_T_SPECIALCOL TYPE KKBLO_SPECIALCOL OCCURS 1.

*--- Structure for scrolling in list
TYPES: BEGIN OF KKBLO_LIST_SCROLL,
         LSIND LIKE SY-LSIND,
         CPAGE LIKE SY-CPAGE,
         STARO LIKE SY-STARO,
         STACO LIKE SY-STACO,
         CUROW LIKE SY-CUROW,
         CUCOL LIKE SY-CUCOL,
         CURSOR_LINE LIKE SY-CUROW,
         CURSOR_OFFSET LIKE SY-CUCOL,
       END OF KKBLO_LIST_SCROLL.

*--- Lineinfo before output
TYPES: KKBLO_LINEINFO TYPE SLIS_LINEINFO.

*--- Marks in list
TYPES: BEGIN OF KKBLO_COLMARK,
         TABNAME TYPE KKBLO_TABNAME,
         FIELDNAME TYPE KKBLO_FIELDNAME,
         COLNO TYPE I,
       END OF KKBLO_COLMARK.
TYPES: KKBLO_T_COLMARK TYPE KKBLO_COLMARK OCCURS 1.

TYPES: BEGIN OF KKBLO_ROWMARK,
         TABNAME TYPE KKBLO_TABNAME,
         TABINDEX LIKE SY-TABIX,
       END OF KKBLO_ROWMARK.
TYPES: KKBLO_T_ROWMARK TYPE KKBLO_ROWMARK OCCURS 1.

types: begin of kkblo_incl_layout1,
         NO_SELINFOS(1) TYPE C,
         ROWNO_CHANGE(1) TYPE C,       " number of rows changeable
         NO_NUMC_SUM(1)  TYPE C,
         ZEBRA_MULTI(1)  TYPE C,
         NO_STATIC_SUBTOT,
         COLORS TYPE KKBLO_COLTYPES,   " description of colors
         SUPPRESS_DYNPRO(1) TYPE C,    " no call screen
         INTERNET_PREPARE(1) TYPE C,   " for processing via internet
         INTERFACE_COMPLETE(1) TYPE C, " just display.
         NO_FILTER_CONFIRM(1) TYPE C,  " filter on cell without confirm.
         DETAIL_ONLY(1) TYPE C,        " show only detail
         DETAIL_EXIT(1) TYPE C,        " ucomm-exit for function 'DETA'
         S_VARIANT LIKE DISVARIANT,    " display variant
         WEBLOOK type LVC_LOOK,
         WEBSTYLE type LVC_STYLE,
         WEBROWS type LVC_WEBROW,
         WEBXWIDTH type INT4,
         WEBXHEIGHT type INT4,
       end   of kkblo_incl_layout1,

       begin of kkblo_incl_layout0,
         ROWS_MAX TYPE I,
         NO_ZEBRA(1)     TYPE C,
         I_AM_POPUP(1) TYPE C,
         NEW_FCODES(1) TYPE C,
         OLD_COLSEL(1) TYPE C,         " 'old' popup for column select.
         MEMORY(1) TYPE C,             " write layout in memory
         COL_OFFSET LIKE SY-CUCOL,     " add col_offset to first column
         ROW_OFFSET LIKE SY-CUROW,     " add row_offset to first row
         KEYCOLS(1) TYPE N,            " number of keycolumns
         BLOCK_MODE(1) TYPE C,         " ALV Block mode
         DEFAULT(1)    TYPE C,
         SAVE(1) TYPE C,
         frontend type lvc_front,
         object_key type bds_typeid,
         doc_id type bds_docid,
         template type bds_filena,
         language type lang,
       end   of kkblo_incl_layout0.

TYPES: BEGIN OF KKBLO_INCL_LAYOUT.
include type kkblo_incl_layout0.
include type kkblo_incl_layout1.
types: END OF KKBLO_INCL_LAYOUT.

*--- Information about the layout of the list
TYPES: BEGIN OF KKBLO_LAYOUT.
        include structure alv_s_layo.
        include structure kkb_s_layo.
        include structure alv_s_prnt.
INCLUDE TYPE SLIS_LAYOUT_ALV1.
INCLUDE TYPE SLIS_PRINT_ALV1.
INCLUDE TYPE KKBLO_INCL_LAYOUT1.
TYPES: END OF KKBLO_LAYOUT.

TYPES: BEGIN OF KKBLO_LPRINT,
         FIRST_COL LIKE SY-CUCOL,      " start column
         FIRST_ROW LIKE SY-CUROW,      " start row
         FIRST_HEADCOL LIKE SY-CUCOL,  " start column for header
         WIDTH TYPE I,                 " width of the list
         ROWS TYPE I,                  " number of lines
         ROWS_SLAVE TYPE I,            " number of lines
         HEADER_LINES TYPE I,          " number of header lines
         SEPARATOR LIKE SY-VLINE,      " character between two columns
         OFFSET_BOX TYPE I,            " offset for checkboxes
         OFFSET_LIGHTS TYPE I,         " offset for exceptions
         OFFSET_FOLDER TYPE I,         " offset for folder
         OFFSET_TOTALS TYPE I,         " offset for totals
       END OF KKBLO_LPRINT.

*--- Structure for key information
TYPES: BEGIN OF KKBLO_KEYINFO,
         MASTER01 TYPE KKBLO_FIELDNAME,
         SLAVE01 TYPE KKBLO_FIELDNAME,
         MASTER02 TYPE KKBLO_FIELDNAME,
         SLAVE02 TYPE KKBLO_FIELDNAME,
         MASTER03 TYPE KKBLO_FIELDNAME,
         SLAVE03 TYPE KKBLO_FIELDNAME,
         MASTER04 TYPE KKBLO_FIELDNAME,
         SLAVE04 TYPE KKBLO_FIELDNAME,
         MASTER05 TYPE KKBLO_FIELDNAME,
         SLAVE05 TYPE KKBLO_FIELDNAME,
       END OF KKBLO_KEYINFO.

*--- information about subtotals and filter
TYPES: BEGIN OF KKBLO_SFINFO,
        INDEX LIKE SY-TABIX,
        INDEX_SLAVE LIKE SY-TABIX,
        SUM(3) TYPE C,
        FILTER(3) TYPE C,
        SUM_OFF(1) TYPE C,
      END OF KKBLO_SFINFO.

TYPES: KKBLO_T_SFINFO TYPE KKBLO_SFINFO OCCURS 1.

TYPES: BEGIN OF KKBLO_GROUPLEVELS.
        include structure alv_s_grpl.
        include structure kkb_s_grpl.
types:  CORRINDEX_MASTER LIKE SY-TABIX,
        CORRINDEX_SLAVE  LIKE SY-TABIX,
        cindex_from  like sy-tabix,
      END OF KKBLO_GROUPLEVELS.

TYPES: KKBLO_T_GROUPLEVELS TYPE KKBLO_GROUPLEVELS OCCURS 1.

*--- Catalogue of the fields (and description of these fields)
TYPES: BEGIN OF KKBLO_FIELDCAT.
        include structure alv_s_fcat.
        include structure kkb_s_fcat.
include TYPE SLIS_FIELDCAT_ALV1.
TYPES:   ROLLNAME_DDIC  LIKE DD03P-ROLLNAME,
         TECH_ROW_POS   LIKE SY-CUCOL, " technical field
         TECH_COL_POS   LIKE SY-CUCOL, " technical field
         TECH_COMPLETE  TYPE C,        " technical flag DO NOT CHANGE!!
       END OF KKBLO_FIELDCAT.

TYPES: KKBLO_T_FIELDCAT TYPE KKBLO_FIELDCAT OCCURS 1.

TYPES: KKBLO_EVENT_EXIT TYPE SLIS_EVENT_EXIT.
TYPES: KKBLO_T_EVENT_EXIT TYPE SLIS_T_EVENT_EXIT.

TYPES: KKBLO_SUBTOT_TEXT TYPE SLIS_SUBTOT_TEXT.

* special groups for column selection
TYPES: BEGIN OF KKBLO_SP_GROUP.
include structure alv_s_sgrp.
include structure kkb_s_sgrp.
types: END OF KKBLO_SP_GROUP.
TYPES: KKBLO_T_SP_GROUP TYPE KKBLO_SP_GROUP OCCURS 1.

* Controlling structure
TYPES: BEGIN OF KKBLO_CONTROL,
         DISPLAY_ONLY(1) TYPE C,
         SAVE(1)   TYPE C,
         DEF_GROUP(4) TYPE C,
         ROWNO_CHANGE(1) TYPE C,
         LISTTYPE(1) TYPE C,           " (H)ier., (S)imple, (M)atrix
         ROWS TYPE I,                  " number of lines
         ROWS_SLAVE TYPE I,            " number of lines (position)
         T_GROUP TYPE KKBLO_T_SP_GROUP," table of groups
         S_VARIANT LIKE DISVARIANT,
*        Display variants
         HEADER_TEXT(20) TYPE C,       " Text for header button
         ITEM_TEXT(20) TYPE C,         " Text for item button
         DEFAULT_ITEM(1) TYPE C,       " Items as default
*
         TOTALS_INACT(1) TYPE C,
         COLPOS_INACT(1) TYPE C,
         ROWPOS_INACT(1) TYPE C,
         LENGTH_INACT(1) TYPE C,
         TOTALS_INVIS(1) TYPE C,
         COLPOS_INVIS(1) TYPE C,
         ROWPOS_INVIS(1) TYPE C,
         LENGTH_INVIS(1) TYPE C,
         OFFSET TYPE I,
         GROUP_CHANGE_EDIT(1) TYPE C,  " Settings by user for new group
*        Sortpopup
         SORT_DEFAULT(1) TYPE C,
         NO_SUBTOTALS(1) TYPE C,       " no subtotals possible
         NO_TOTALLINE(1) TYPE C,       " no totalline
         UNIT_SPLITTING(1) TYPE C,
       END OF KKBLO_CONTROL.

* information cursor position
TYPES:  KKBLO_SELFIELD TYPE SLIS_SELFIELD.

* information for sort and subtotals
TYPES: BEGIN OF KKBLO_SORTINFO.
        include structure alv_s_sort.
        include structure kkb_s_sort.
types: END OF KKBLO_SORTINFO.
TYPES: KKBLO_T_SORTINFO TYPE KKBLO_SORTINFO OCCURS 0.

TYPES: BEGIN OF KKBLO_SORT_EXTEND.
INCLUDE TYPE KKBLO_SORTINFO.
types:  colcount type i,
        end of kkblo_sort_extend.  "Y6BK082363/Y6BK083036
TYPES: KKBLO_T_SORT_EXTEND TYPE KKBLO_SORT_EXTEND OCCURS 0.

TYPES: BEGIN OF KKBLO_SUBTOT_OPTIONS,
         OFFSET TYPE I,
         TOTALS(1) TYPE C,
         TOTALS_ON_LIST(1) TYPE C,
         SUBTOTALS(1) TYPE C,
         SUBTOTALS_ON_LIST(1) TYPE C,
         MAX_LEVEL TYPE I,
         LEN_FOR_TEXT TYPE I,
         ULINE_FROM_LEVEL TYPE I,
         T_LEVELS TYPE KKBLO_T_SORT_EXTEND,
       END OF KKBLO_SUBTOT_OPTIONS.

TYPES: BEGIN OF KKBLO_SORTSHOW,
         FIELDNAME TYPE KKBLO_FIELDNAME,
         TABNAME TYPE KKBLO_FIELDNAME,
         SELTEXT(40) TYPE C,
         UP(50) TYPE C,
         DOWN(50) TYPE C,
         SUBTOT(50) TYPE C,
         UP_PRINT(15) TYPE C,
         DOWN_PRINT(15) TYPE C,
         SUBTOT_PRINT(15) TYPE C,
       END OF KKBLO_SORTSHOW.
TYPES: KKBLO_T_SORTSHOW TYPE KKBLO_SORTSHOW OCCURS 1.

* information for scrolling columns
TYPES: BEGIN OF KKBLO_COLUMNS,
        COLNR LIKE SY-CUCOL,
        ROWNR LIKE SY-CUROW,
        COLINDEX LIKE SY-CUCOL,
        FIELDNAME TYPE KKBLO_FIELDNAME,
        TABNAME TYPE KKBLO_TABNAME,
        KEY(1)   TYPE C,
        LAST(1)   TYPE C,
      END OF KKBLO_COLUMNS.
TYPES: KKBLO_T_COLUMNS TYPE KKBLO_COLUMNS OCCURS 1.


TYPES: BEGIN OF KKBLO_SELOTAB,
        FELDT(40),
        VALUF(80),
        VALUT(80),
        SIGN0(2),
        OPTIO(2),
        STYPE(1),
        LTEXT(50),
      END OF KKBLO_SELOTAB.
TYPES: KKBLO_T_SELOTAB TYPE KKBLO_SELOTAB OCCURS 1.

* filter
TYPES: BEGIN OF KKBLO_FILTER.
        include structure alv_s_filt.
        include structure kkb_s_filt.
INCLUDE TYPE SLIS_FILTER_ALV1.
TYPES: END OF KKBLO_FILTER.

TYPES: KKBLO_T_FILTER TYPE KKBLO_FILTER OCCURS 1.

TYPES: BEGIN OF KKBLO_DETAIL_FILTER,
         FIELDNAME TYPE KKBLO_FIELDNAME,
         TABNAME TYPE KKBLO_TABNAME,
         SELTEXT(40),
         VALUF(80),
         VALUT(80),
         VALUF_PRINT(80),
         VALUT_PRINT(80),
         SIGN0(4),
         SIGN0_PRINT(4),
         SIGN_ICON(4),
         SIGN_ICON_PRINT(4),
         OPTIO(2),
         STYPE(1),
         OUTPUTLEN LIKE DFIES-OUTPUTLEN,
         EXCEPTION(1) TYPE C,
         OR(1) TYPE C,
       END OF KKBLO_DETAIL_FILTER.

TYPES: KKBLO_T_DETAIL_FILTER TYPE KKBLO_DETAIL_FILTER OCCURS 1.

* delete or add an entry in the select-option info
* nur in SLIS ändern!!
TYPES: KKBLO_SELENTRY_HIDE TYPE SLIS_SELENTRY_HIDE_ALV.
TYPES: KKBLO_T_SELENTRY_HIDE TYPE KKBLO_SELENTRY_HIDE OCCURS 1.

TYPES: KKBLO_SEL_HIDE TYPE SLIS_SEL_HIDE_ALV.

* information for selections
* nur in SLIS ändern!!
TYPES: KKBLO_SELDIS1 TYPE SLIS_SELDIS1_ALV.
TYPES: KKBLO_SELDIS TYPE KKBLO_SELDIS1 OCCURS 1.

* Header table for top of page
TYPES: BEGIN OF KKBLO_LISTHEADER.
INCLUDE TYPE SLIS_LISTHEADER.
TYPES: END OF KKBLO_LISTHEADER.
TYPES: KKBLO_T_LISTHEADER TYPE KKBLO_LISTHEADER OCCURS 1.

* Exporting Exit by user
TYPES: KKBLO_EXIT_BY_USER TYPE SLIS_EXIT_BY_USER.

* Detail
TYPES: BEGIN OF KKBLO_DETAIL,
         KEYCHAR(60),
         DATACHAR(132),
         DATACHAR_PRINT(132),
       END OF KKBLO_DETAIL.
TYPES: KKBLO_T_DETAIL TYPE KKBLO_DETAIL OCCURS 1.

TYPES: BEGIN OF KKBLO_COUNTTAB,
         KEYCHAR(60),
         DATACHAR TYPE I,
       END OF KKBLO_COUNTTAB.
TYPES: KKBLO_T_COUNTTAB TYPE KKBLO_COUNTTAB OCCURS 1.

TYPES: BEGIN OF KKBLO_FIELDS,
         FIELDNAME TYPE KKBLO_FIELDNAME,
         TABNAME   TYPE KKBLO_TABNAME,
         SELTEXT   LIKE DD03P-SCRTEXT_L,
         OUTPUTLEN LIKE DD03P-OUTPUTLEN,
         DO_SUM(20) TYPE C,
         DO_SUM_PRINT(15) TYPE C,
       END OF KKBLO_FIELDS.
TYPES: KKBLO_T_FIELDS TYPE KKBLO_FIELDS OCCURS 1.

TYPES: BEGIN OF KKBLO_HEADER,
         EXCEPTION(4) TYPE C,
         FOLDER(4) TYPE C,
         TEXT01 TYPE KKBLO_ENTRY,
         TEXT02 TYPE KKBLO_ENTRY,
         TEXT03 TYPE KKBLO_ENTRY,
         TEXT04 TYPE KKBLO_ENTRY,
         TEXT05 TYPE KKBLO_ENTRY,
         TEXT06 TYPE KKBLO_ENTRY,
         TEXT07 TYPE KKBLO_ENTRY,
         TEXT08 TYPE KKBLO_ENTRY,
         TEXT09 TYPE KKBLO_ENTRY,
         TEXT10 TYPE KKBLO_ENTRY,
         TEXT11 TYPE KKBLO_ENTRY,
         TEXT12 TYPE KKBLO_ENTRY,
         TEXT13 TYPE KKBLO_ENTRY,
         TEXT14 TYPE KKBLO_ENTRY,
         TEXT15 TYPE KKBLO_ENTRY,
         TEXT16 TYPE KKBLO_ENTRY,
         TEXT17 TYPE KKBLO_ENTRY,
         TEXT18 TYPE KKBLO_ENTRY,
         TEXT19 TYPE KKBLO_ENTRY,
         TEXT20 TYPE KKBLO_ENTRY,
         TEXT21 TYPE KKBLO_ENTRY,
         TEXT22 TYPE KKBLO_ENTRY,
         TEXT23 TYPE KKBLO_ENTRY,
         TEXT24 TYPE KKBLO_ENTRY,
         TEXT25 TYPE KKBLO_ENTRY,
         TEXT26 TYPE KKBLO_ENTRY,
         TEXT27 TYPE KKBLO_ENTRY,
         TEXT28 TYPE KKBLO_ENTRY,
         TEXT29 TYPE KKBLO_ENTRY,
         TEXT30 TYPE KKBLO_ENTRY,
         TEXT31 TYPE KKBLO_ENTRY,
         TEXT32 TYPE KKBLO_ENTRY,
         TEXT33 TYPE KKBLO_ENTRY,
         TEXT34 TYPE KKBLO_ENTRY,
         TEXT35 TYPE KKBLO_ENTRY,
         TEXT36 TYPE KKBLO_ENTRY,
         TEXT37 TYPE KKBLO_ENTRY,
         TEXT38 TYPE KKBLO_ENTRY,
         TEXT39 TYPE KKBLO_ENTRY,
         TEXT40 TYPE KKBLO_ENTRY,
         TEXT41 TYPE KKBLO_ENTRY,
         TEXT42 TYPE KKBLO_ENTRY,
         TEXT43 TYPE KKBLO_ENTRY,
         TEXT44 TYPE KKBLO_ENTRY,
         TEXT45 TYPE KKBLO_ENTRY,
         TEXT46 TYPE KKBLO_ENTRY,
         TEXT47 TYPE KKBLO_ENTRY,
         TEXT48 TYPE KKBLO_ENTRY,
         TEXT49 TYPE KKBLO_ENTRY,
         TEXT50 TYPE KKBLO_ENTRY,
         TEXT51 TYPE KKBLO_ENTRY,
         TEXT52 TYPE KKBLO_ENTRY,
         TEXT53 TYPE KKBLO_ENTRY,
         TEXT54 TYPE KKBLO_ENTRY,
         TEXT55 TYPE KKBLO_ENTRY,
         TEXT56 TYPE KKBLO_ENTRY,
         TEXT57 TYPE KKBLO_ENTRY,
         TEXT58 TYPE KKBLO_ENTRY,
         TEXT59 TYPE KKBLO_ENTRY,
         TEXT60 TYPE KKBLO_ENTRY,
         TEXT61 TYPE KKBLO_ENTRY,
         TEXT62 TYPE KKBLO_ENTRY,
         TEXT63 TYPE KKBLO_ENTRY,
         TEXT64 TYPE KKBLO_ENTRY,
         TEXT65 TYPE KKBLO_ENTRY,
         TEXT66 TYPE KKBLO_ENTRY,
         TEXT67 TYPE KKBLO_ENTRY,
         TEXT68 TYPE KKBLO_ENTRY,
         TEXT69 TYPE KKBLO_ENTRY,
         TEXT70 TYPE KKBLO_ENTRY,
         TEXT71 TYPE KKBLO_ENTRY,
         TEXT72 TYPE KKBLO_ENTRY,
         TEXT73 TYPE KKBLO_ENTRY,
         TEXT74 TYPE KKBLO_ENTRY,
         TEXT75 TYPE KKBLO_ENTRY,
         TEXT76 TYPE KKBLO_ENTRY,
         TEXT77 TYPE KKBLO_ENTRY,
         TEXT78 TYPE KKBLO_ENTRY,
         TEXT79 TYPE KKBLO_ENTRY,
         TEXT80 TYPE KKBLO_ENTRY,
         TEXT81 TYPE KKBLO_ENTRY,
         TEXT82 TYPE KKBLO_ENTRY,
         TEXT83 TYPE KKBLO_ENTRY,
         TEXT84 TYPE KKBLO_ENTRY,
         TEXT85 TYPE KKBLO_ENTRY,
         TEXT86 TYPE KKBLO_ENTRY,
         TEXT87 TYPE KKBLO_ENTRY,
         TEXT88 TYPE KKBLO_ENTRY,
         TEXT89 TYPE KKBLO_ENTRY,
         TEXT90 TYPE KKBLO_ENTRY,
         TEXT91 TYPE KKBLO_ENTRY,
         TEXT92 TYPE KKBLO_ENTRY,
         TEXT93 TYPE KKBLO_ENTRY,
         TEXT94 TYPE KKBLO_ENTRY,
         TEXT95 TYPE KKBLO_ENTRY,
         TEXT96 TYPE KKBLO_ENTRY,
         TEXT97 TYPE KKBLO_ENTRY,
         TEXT98 TYPE KKBLO_ENTRY,
         TEXT99 TYPE KKBLO_ENTRY,
       END OF KKBLO_HEADER.
