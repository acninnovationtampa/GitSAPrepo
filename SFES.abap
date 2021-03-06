TYPE-POOL SFES .

TYPES:
  SFES_OBJ_TYPE(32) TYPE C.

CONSTANTS:
  SFES_OBJ_ACTIVEX
    TYPE SFES_OBJ_TYPE
    VALUE 'ACTX',
  SFES_OBJ_JAVABEANS
    TYPE SFES_OBJ_TYPE
    VALUE 'JBEAN',
  SFES_OBJ_OLE
    TYPE SFES_OBJ_TYPE
    VALUE 'OLE',
  SFES_OBJ_SAP
    TYPE SFES_OBJ_TYPE
    VALUE 'SAP',
  SFES_OBJ_HTML
    TYPE SFES_OBJ_TYPE
    VALUE 'HTML'.

* Constants for GUI_GET_DESKTOP_INFO
CONSTANTS:
  SFES_INFO_SAPDIR
    TYPE I
    VALUE -1,
  SFES_INFO_SAPSYSDIR
    TYPE I
    VALUE -2,
  SFES_INFO_COMPUTER_NAME
    TYPE I
    VALUE 1,
  SFES_INFO_WINDOWS_DIRECTORY
    TYPE I
    VALUE 2,
  SFES_INFO_SYSTEM_DIRECTORY
    TYPE I
    VALUE 3,
  SFES_INFO_TEMP_DIRECTORY
    TYPE I
    VALUE 4,
  SFES_INFO_USER_NAME
    TYPE I
    VALUE 5,
  SFES_INFO_WINDOWS_PLATFORM
    TYPE I
    VALUE 6,
  SFES_INFO_WINDOWS_BUILDNO
    TYPE I
    VALUE 7,
  SFES_INFO_WINDOWS_VERSION
    TYPE I
    VALUE 8,
  SFES_INFO_PROGRAM_NAME
    TYPE I
    VALUE 9,
  SFES_INFO_PROGRAM_PATH
    TYPE I
    VALUE 10,
  SFES_INFO_CURRENT_DIRECTORY
    TYPE I
    VALUE 11,
  SFES_INFO_DESKTOP_DIRECTORY
    TYPE I
    VALUE 12.
