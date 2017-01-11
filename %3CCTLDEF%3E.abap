***INCLUDE <CTLDEF>.
TYPE-POOLS: CNTL.
* TYPE-POOLS: CNDP. "// dataprovider rh
* control styles........................................................
CONSTANTS: WS_VISIBLE         TYPE I VALUE 268435456. " general.........
CONSTANTS: WS_BORDER          TYPE I VALUE 8388608.
CONSTANTS: WS_VSCROLL         TYPE I VALUE 2097152.
CONSTANTS: WS_HSCROLL         TYPE I VALUE 1048576.
CONSTANTS: WS_GROUP           TYPE I VALUE 131072.
CONSTANTS: WS_TABSTOP         TYPE I VALUE 65536.
CONSTANTS: WS_CLIPSIBLINGS    TYPE I VALUE 67108864.
CONSTANTS: WS_CLIPCHILDREN    TYPE I VALUE 33554432.
CONSTANTS: WS_DLGFRAME        TYPE I VALUE 4194304.
CONSTANTS: WS_THICKFRAME      TYPE I VALUE 262144.
CONSTANTS: WS_DISABLED        TYPE I VALUE 134217728.
CONSTANTS: WS_CHILD           TYPE I VALUE 1073741824.
* CONSTANTS: WS_CAPTION         TYPE I VALUE 12582912.
CONSTANTS: WS_SYSMENU         TYPE I VALUE 524288.
CONSTANTS: WS_MINIMIZEBOX     TYPE I VALUE 131072.
CONSTANTS: WS_MAXIMIZEBOX     TYPE I VALUE 65536.
CONSTANTS: WS_MINIMIZE        TYPE I VALUE 536870912.
CONSTANTS: WS_MAXIMIZE        TYPE I VALUE 268435456.

CONSTANTS: BS_PUSHBUTTON      TYPE I VALUE 0.      " for buttons.....
CONSTANTS: BS_CHECKBOX        TYPE I VALUE 2.
CONSTANTS: BS_AUTOCHECKBOX    TYPE I VALUE 3.
CONSTANTS: BS_RADIOBUTTON     TYPE I VALUE 4.
CONSTANTS: BS_AUTORADIOBUTTON TYPE I VALUE 9.
CONSTANTS: BS_GROUPBOX        TYPE I VALUE 7.
CONSTANTS: BS_LEFTTEXT        TYPE I VALUE 32.
CONSTANTS: BS_DEFPUSHBUTTON   TYPE I VALUE 1.
CONSTANTS: BS_LEFT            TYPE I VALUE 256.   " >= WIN95 begin..
CONSTANTS: BS_RIGHT           TYPE I VALUE 512.
CONSTANTS: BS_CENTER          TYPE I VALUE 768.
CONSTANTS: BS_TOP             TYPE I VALUE 1024.
CONSTANTS: BS_BOTTOM          TYPE I VALUE 2048.
CONSTANTS: BS_VCENTER         TYPE I VALUE 3072.
CONSTANTS: BS_PUSHLIKE        TYPE I VALUE 4096.
CONSTANTS: BS_MULTILINE       TYPE I VALUE 8192.  " >= WIN95 end....

CONSTANTS: ES_LEFT            TYPE I VALUE 0.   " for edit fields.
CONSTANTS: ES_CENTER          TYPE I VALUE 1.
CONSTANTS: ES_RIGHT           TYPE I VALUE 2.
CONSTANTS: ES_MULTILINE       TYPE I VALUE 4.
CONSTANTS: ES_UPPERCASE       TYPE I VALUE 8.
CONSTANTS: ES_LOWERCASE       TYPE I VALUE 16.
CONSTANTS: ES_PASSWORD        TYPE I VALUE 32.
CONSTANTS: ES_AUTOVSCROLL     TYPE I VALUE 64.
CONSTANTS: ES_AUTOHSCROLL     TYPE I VALUE 128.
CONSTANTS: ES_READONLY        TYPE I VALUE 2048.
CONSTANTS: ES_WANTRETURN      TYPE I VALUE 4096.

CONSTANTS: LBS_SORT           TYPE I VALUE 2.         " for listboxes...
CONSTANTS: LBS_MULTICOLUMN    TYPE I VALUE 512.
CONSTANTS: LBS_NOINTEGRAL     TYPE I VALUE 256.

CONSTANTS: CBS_SIMPLE         TYPE I VALUE 1.         " for comboboxes..
CONSTANTS: CBS_DROPDOWN       TYPE I VALUE 2.
CONSTANTS: CBS_DROPDOWNLIST   TYPE I VALUE 3.
CONSTANTS: CBS_AUTOHSCROLL    TYPE I VALUE 64.
CONSTANTS: CBS_SORT           TYPE I VALUE 256.
CONSTANTS: CBS_NOINTEGRAL     TYPE I VALUE 1024.

CONSTANTS: SS_LEFT            TYPE I VALUE 0.         " for statics.....
CONSTANTS: SS_CENTER          TYPE I VALUE 1.
CONSTANTS: SS_RIGHT           TYPE I VALUE 2.
CONSTANTS: SS_ICON            TYPE I VALUE 3.
CONSTANTS: SS_BLACKFRAME      TYPE I VALUE 7.
CONSTANTS: SS_GREYFRAME       TYPE I VALUE 8.
CONSTANTS: SS_BLACKRECT       TYPE I VALUE 4.
CONSTANTS: SS_GREYRECT        TYPE I VALUE 5.
CONSTANTS: SS_WHITERECT       TYPE I VALUE 6.
CONSTANTS: SS_SIMPLE          TYPE I VALUE 11.
CONSTANTS: SS_SUNKEN          TYPE I VALUE 4096.      " >= WIN95........

CONSTANTS: MF_SEPARATOR       TYPE I VALUE 2048.      " for menus.......
CONSTANTS: MF_ENABLED         TYPE I VALUE 0.
CONSTANTS: MF_GRAYED          TYPE I VALUE 1.
CONSTANTS: MF_DISABLED        TYPE I VALUE 2.
CONSTANTS: MF_UNCHECKED       TYPE I VALUE 0.
CONSTANTS: MF_CHECKED         TYPE I VALUE 8.
CONSTANTS: MF_UNHILITE        TYPE I VALUE 0.
CONSTANTS: MF_HILITE          TYPE I VALUE 128.
CONSTANTS: MF_POPUP           TYPE I VALUE 16.

CONSTANTS: TVS_HASBUTTONS     TYPE I VALUE 1.         " tree............
CONSTANTS: TVS_HASLINES       TYPE I VALUE 2.
CONSTANTS: TVS_LINESATROOT    TYPE I VALUE 4.
CONSTANTS: TVS_EDITLABELS     TYPE I VALUE 6.

CONSTANTS: TVI_ROOT           TYPE I VALUE 1.         " node inserts....
CONSTANTS: TVI_FIRST          TYPE I VALUE 1.
CONSTANTS: TVI_LAST           TYPE I VALUE 2.

* properties............................................................

CONSTANTS: PROP_ALIGN           TYPE I VALUE 10.
CONSTANTS: PROP_AUTOSIZE        TYPE I VALUE 20.
CONSTANTS: PROP_BACKCOLOR       TYPE I VALUE 30.
CONSTANTS: PROP_BACKMODE        TYPE I VALUE 40.
CONSTANTS: PROP_BACKSTYLE       TYPE I VALUE 50.
CONSTANTS: PROP_CAPTION         TYPE I VALUE 60.
CONSTANTS: PROP_CHECKED         TYPE I VALUE 70.
CONSTANTS: PROP_CURSOR          TYPE I VALUE 80.
CONSTANTS: PROP_ENABLED         TYPE I VALUE 90.
CONSTANTS: PROP_FONT            TYPE I VALUE 100.
CONSTANTS: PROP_FORECOLOR       TYPE I VALUE 110.
CONSTANTS: PROP_HEIGHT          TYPE I VALUE 120.
CONSTANTS: PROP_HELPID          TYPE I VALUE 130.
CONSTANTS: PROP_HELPFILE        TYPE I VALUE 140.
CONSTANTS: PROP_ICON            TYPE I VALUE 150.
CONSTANTS: PROP_INTERVAL        TYPE I VALUE 160.
CONSTANTS: PROP_LEFT            TYPE I VALUE 170.
CONSTANTS: PROP_MAX             TYPE I VALUE 180.
CONSTANTS: PROP_MAXLENGTH       TYPE I VALUE 190.
CONSTANTS: PROP_MIN             TYPE I VALUE 200.
CONSTANTS: PROP_MODE            TYPE I VALUE 210.
CONSTANTS: PROP_PICTURE         TYPE I VALUE 220.
CONSTANTS: PROP_TABINDEX        TYPE I VALUE 230.
CONSTANTS: PROP_TABSTOP         TYPE I VALUE 240.
CONSTANTS: PROP_TICKFREQUENCY   TYPE I VALUE 250.
CONSTANTS: PROP_TICKSTYLE       TYPE I VALUE 260.
CONSTANTS: PROP_TOP             TYPE I VALUE 270.
CONSTANTS: PROP_VALUE           TYPE I VALUE 280.
CONSTANTS: PROP_VISIBLE         TYPE I VALUE 290.
CONSTANTS: PROP_WIDTH           TYPE I VALUE 300.
CONSTANTS: PROP_BITMAP          TYPE I VALUE 310.
CONSTANTS: PROP_BITMAP_STYLE    TYPE I VALUE 320.
CONSTANTS: PROP_TEXT            TYPE I VALUE 330.
CONSTANTS: PROP_SOUND           TYPE I VALUE 340.
CONSTANTS: PROP_INDEX           TYPE I VALUE 350.
CONSTANTS: PROP_STRING          TYPE I VALUE 360.
CONSTANTS: PROP_ITEM            TYPE I VALUE 370.
CONSTANTS: PROP_FONT_SIZE       TYPE I VALUE 380.
CONSTANTS: PROP_FONT_BOLD       TYPE I VALUE 390.
CONSTANTS: PROP_FONT_ITALIC     TYPE I VALUE 400.
CONSTANTS: PROP_METRIC          TYPE I VALUE 410.
CONSTANTS: PROP_GRID_STEP       TYPE I VALUE 420.
CONSTANTS: PROP_VSCROLL_RANGE   TYPE I VALUE 430.
CONSTANTS: PROP_HSCROLL_RANGE   TYPE I VALUE 440.
CONSTANTS: PROP_GRID_HANDLE     TYPE I VALUE 450.
CONSTANTS: PROP_ADJUST_DESIGN   TYPE I VALUE 460.
CONSTANTS: PROP_DOCK_AT         TYPE I VALUE 470.
CONSTANTS: PROP_CONTEXT_MENU TYPE I VALUE 490.

* docking_at types......................................................

CONSTANTS: DOCK_AT_LEFT         TYPE I VALUE 1.
CONSTANTS: DOCK_AT_TOP          TYPE I VALUE 2.
CONSTANTS: DOCK_AT_BOTTOM       TYPE I VALUE 4.
CONSTANTS: DOCK_AT_RIGHT        TYPE I VALUE 8.

* metric types..........................................................

CONSTANTS: METRIC_DEFAULT       TYPE I VALUE 0.
CONSTANTS: METRIC_PIXEL         TYPE I VALUE 1.
CONSTANTS: METRIC_MM            TYPE I VALUE 2.

* standard event identifiers for custom controls........................

CONSTANTS: EVENT_CLICK              TYPE I VALUE -600.
CONSTANTS: EVENT_DOUBLE_CLICK       TYPE I VALUE -601.
constants: event_keydown            type i value -602.
constants: event_keypress           type i value -603.
constants: event_keyup              type i value -604.
constants: event_mousedown          type i value -605.
constants: event_mousemove          type i value -606.
constants: event_mouseup            type i value -607.
constants: event_error              type i value -608.
constants: event_readystatechange   type i value -609.


* standard event identifiers for shell controls (useful in design mode).

CONSTANTS: SHELL_DOUBLE_CLICK   TYPE I VALUE 3.
CONSTANTS: SHELL_CLICK          TYPE I VALUE 5.
CONSTANTS: SHELL_CLOSE          TYPE I VALUE 8.
CONSTANTS: SHELL_MENU_CLICK     TYPE I VALUE 10.
CONSTANTS: SHELL_MOVE           TYPE I VALUE 11.
CONSTANTS: SHELL_SIZE           TYPE I VALUE 12.
CONSTANTS: SHELL_CM_REQUEST     TYPE I VALUE 13.
CONSTANTS: SHELL_CM_CLICK       TYPE I VALUE 14.

* property values.......................................................

CONSTANTS: PV_ENABLED           TYPE I VALUE 1.
CONSTANTS: PV_DISABLED          TYPE I VALUE 0.
CONSTANTS: PV_VISIBLE           TYPE I VALUE 1.
CONSTANTS: PV_INVISIBLE         TYPE I VALUE 0.
CONSTANTS: PV_CHECKED           TYPE I VALUE 1.
CONSTANTS: PV_UNCHECKED         TYPE I VALUE 0.
CONSTANTS: PV_MODE_DESIGN       TYPE I VALUE 1.
CONSTANTS: PV_MODE_RUN          TYPE I VALUE 0.

* font types............................................................

CONSTANTS: FONT_TYPE_SERIF      TYPE I VALUE 1.
CONSTANTS: FONT_TYPE_COURIER    TYPE I VALUE 2.
CONSTANTS: FONT_TYPE_ROMAN      TYPE I VALUE 3.
CONSTANTS: FONT_TYPE_ARIAL      TYPE I VALUE 4.

CONSTANTS: FONT_TYPE_SYSTEM_PROP  TYPE I VALUE 1000.
CONSTANTS: FONT_TYPE_SYSTEM_FIXED TYPE I VALUE 1001.

* font sizes............................................................

CONSTANTS: FONT_SIZE_SMALL      TYPE I VALUE 0.
CONSTANTS: FONT_SIZE_REGULAR    TYPE I VALUE 1.
CONSTANTS: FONT_SIZE_LARGE      TYPE I VALUE 2.
CONSTANTS: FONT_SIZE_HUGE       TYPE I VALUE 3.

* font normal, bold, italic.............................................

CONSTANTS: FONT_NORMAL          TYPE I VALUE 0.
CONSTANTS: FONT_BOLD            TYPE I VALUE 1.
CONSTANTS: FONT_ITALIC          TYPE I VALUE 1.
CONSTANTS: FONT_SET             TYPE I VALUE 1.

* bitmap attributes.....................................................

CONSTANTS: BITMAP_TRANSPARENT   TYPE I VALUE 1.
CONSTANTS: BITMAP_STRETCH       TYPE I VALUE 2.
CONSTANTS: BITMAP_VISIBLE       TYPE I VALUE 4.
CONSTANTS: BITMAP_BACKGROUND    TYPE I VALUE 8.

* predefined window identifiers.........................................

constants: dynpro_default       type i value -1.
CONSTANTS: MAIN_WINDOW          TYPE I VALUE 0.
CONSTANTS: DYNPRO_0             TYPE I VALUE 10.
CONSTANTS: DYNPRO_1             TYPE I VALUE 11.
CONSTANTS: DYNPRO_2             TYPE I VALUE 12.
CONSTANTS: DYNPRO_3             TYPE I VALUE 13.
CONSTANTS: DYNPRO_4             TYPE I VALUE 14.
CONSTANTS: DYNPRO_5             TYPE I VALUE 15.
CONSTANTS: DYNPRO_6             TYPE I VALUE 16.
CONSTANTS: DYNPRO_7             TYPE I VALUE 17.
CONSTANTS: DYNPRO_8             TYPE I VALUE 18.
CONSTANTS: DYNPRO_9             TYPE I VALUE 19.
CONSTANTS: TOP_WINDOW           TYPE I VALUE 33.
CONSTANTS: DESKTOP_WINDOW       TYPE I VALUE 99.


* dialog defines........................................................

constants: DLG_STYLE_DESKTOP    type i value 0.
constants: DLG_STYLE_MDI        type i value 1.

* useful defines........................................................

CONSTANTS: CNTL_TRUE  TYPE I VALUE 1,
      CNTL_FALSE type i value 0.

* alignment style.......................................................

CONSTANTS: ALIGN_AT_LEFT           TYPE I VALUE 1.
CONSTANTS: ALIGN_AT_RIGHT          TYPE I VALUE 2.
CONSTANTS: ALIGN_AT_TOP            TYPE I VALUE 4.
CONSTANTS: ALIGN_AT_BOTTOM         TYPE I VALUE 8.
CONSTANTS: ALIGN_CENTERED          TYPE I VALUE 16.
CONSTANTS: SET_AT_TOP              TYPE I VALUE 32.
CONSTANTS: SET_AT_BOTTOM           TYPE I VALUE 64.
CONSTANTS: SET_AT_LEFT             TYPE I VALUE 128.
CONSTANTS: SET_AT_RIGHT
                                   TYPE I VALUE 256.
CONSTANTS: SET_CENTERED            TYPE I VALUE 512.

*---------------------------------------------------------------------*
* Callback..............................................................
*---------------------------------------------------------------------*

define callback.
form &1 using    evt_shellid    type i
                 evt_eventid    type i
                 evt_is_shellevent type c
                 evt_cargo      type c
                 callback_test  type c
        changing callback_found type c.

  callback_found = 'X'.
  if not callback_test is initial.
*   dummy for slin
    if evt_cargo eq evt_is_shellevent. endif.
    if evt_eventid eq evt_shellid. endif.
    exit.
  endif.
end-of-definition.

define callbackex.
form &1 using    evt_cntl       type cntl_handle
                 evt_eventid    type i
                 evt_is_shellevent type c
                 evt_cargo      type c
                 callback_test  type c
        changing callback_found type c.

  callback_found = 'X'.
  if not callback_test is initial.
*   dummy for slin
    if evt_cargo eq evt_is_shellevent. endif.
    exit.
  endif.
end-of-definition.
define endcallback.
endform.
end-of-definition.
