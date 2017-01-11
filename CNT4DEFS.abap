*----------------------------------------------------------------------*
*   INCLUDE CNT4DEFS                                                   *
*----------------------------------------------------------------------*

CONSTANTS:
*** item class
           TREEV_ITEM_CLASS_TEXT TYPE I VALUE 2,
           TREEV_ITEM_CLASS_CHECKBOX TYPE I VALUE 3,
           TREEV_ITEM_CLASS_BUTTON TYPE I VALUE 4,
           TREEV_ITEM_CLASS_LINK TYPE I VALUE 5,
*** Events
           TREEV_EVENTID_EXPAND_NC TYPE I VALUE 18,
           TREEV_EVENTID_ITEM_DBL_CLK TYPE I VALUE 22,
           TREEV_EVENTID_NODE_DBL_CLK TYPE I VALUE 25,
           TREEV_EVENTID_NODE_CONTEXT_MEN TYPE I VALUE 36,
           TREEV_EVENTID_ITEM_CONTEXT_MEN TYPE I VALUE 26,
           TREEV_EVENTID_HEADER_CLICK TYPE I VALUE 28,
           TREEV_EVENTID_BUTTON_CLICK TYPE I VALUE 29,
           TREEV_EVENTID_LINK_CLICK TYPE I VALUE 35,
           TREEV_EVENTID_CHECKBOX_CHANGE TYPE I VALUE 33,
           TREEV_EVENTID_SEL_CHANGE TYPE I VALUE 21,
****************** do not use
           TREEV_EVENTID_CONTEXT_MENU TYPE I VALUE 26,
****************** use treev_eventid_item_context_men !
*** Alignment
           TREEV_ALIGN_LEFT TYPE I VALUE 0,
           TREEV_ALIGN_CENTER TYPE I VALUE 1,
           TREEV_ALIGN_RIGHT TYPE I VALUE 2,
           TREEV_ALIGN_AUTO TYPE I VALUE 3,
*** mode
           TREEV_MODE_SIMPLE TYPE I VALUE 0,
           TREEV_MODE_LIST TYPE I VALUE 1,
           TREEV_MODE_COLUMNS TYPE I VALUE 2,
*** node relationships
           TREEV_RELAT_FIRST_CHILD TYPE I VALUE 4,
           TREEV_RELAT_LAST_CHILD TYPE I VALUE 6,
           TREEV_RELAT_PREV_SIBLING TYPE I VALUE 3,
           TREEV_RELAT_NEXT_SIBLING TYPE I VALUE 2,
           TREEV_RELAT_FIRST_SIBLING TYPE I VALUE 5,
           TREEV_RELAT_LAST_SIBLING TYPE I VALUE 1,
*** node_selection_mode
           TREEV_NODE_SEL_MODE_SINGLE TYPE I VALUE 0,
           TREEV_NODE_SEL_MODE_MULTIPLE TYPE I VALUE 1,
*** header types
           TREEV_HEADER_FIXED TYPE I VALUE 0,
           TREEV_HEADER_VARIABLE TYPE I VALUE 1,
           TREEV_HEADER_AUTO TYPE I VALUE 2,
*** node and item styles
           TREEV_STYLE_INHERITED TYPE I VALUE 0,
           TREEV_STYLE_DEFAULT TYPE I VALUE 1,
           TREEV_STYLE_INTENSIFIED TYPE I VALUE 2,
           TREEV_STYLE_INACTIVE TYPE I VALUE 3,
           TREEV_STYLE_INTENSIFD_CRITICAL TYPE I VALUE 4,
           TREEV_STYLE_EMPHASIZED_NEGATIV TYPE I VALUE 5,
           TREEV_STYLE_EMPHASIZED_POSITIV TYPE I VALUE 6,
           TREEV_STYLE_EMPHASIZED TYPE I VALUE 7,
*** scroll commands
           TREEV_SCROLL_UP_LINE TYPE I VALUE 1,
           TREEV_SCROLL_DOWN_LINE TYPE I VALUE 2,
           TREEV_SCROLL_UP_PAGE TYPE I VALUE 3,
           TREEV_SCROLL_DOWN_PAGE TYPE I VALUE 4,
           TREEV_SCROLL_HOME TYPE I VALUE 5,
           TREEV_SCROLL_END TYPE I VALUE 6,
*** fonts
           TREEV_FONT_DEFAULT TYPE I VALUE 0,
           TREEV_FONT_FIXED TYPE I VALUE 1,
           TREEV_FONT_PROP TYPE I VALUE 2.