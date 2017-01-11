TYPE-POOL SLCTR .

***********************************************************************
*   Object                                                            *
***********************************************************************

* Constants for the object type
CONSTANTS:
  SLCTR_VIEW_TYPE         LIKE OBJH-OBJECTTYPE  VALUE 'V',
  SLCTR_TABLE_TYPE        LIKE OBJH-OBJECTTYPE  VALUE 'S',
  SLCTR_CLUSTER_TYPE      LIKE OBJH-OBJECTTYPE  VALUE 'C',
  SLCTR_VCL_OLD_TYPE      LIKE OBJH-OBJECTTYPE  VALUE 'K',
  SLCTR_LOGO_TYPE         LIKE OBJH-OBJECTTYPE  VALUE 'L',
  SLCTR_TXN_TYPE          LIKE OBJH-OBJECTTYPE  VALUE 'T',
  SLCTR_DUMMY_TYPE        LIKE OBJH-OBJECTTYPE  VALUE 'D',
  SLCTR_TABU_TYPE         LIKE OBJH-OBJECTTYPE  VALUE 'U'.

TYPES:
  BEGIN OF SLCTR_OBJECT,
    OBJECTNAME            LIKE OBJH-OBJECTNAME,
    OBJECTTYPE            LIKE OBJH-OBJECTTYPE,
  END OF SLCTR_OBJECT,
  SLCTR_OBJECTS           TYPE SLCTR_OBJECT     OCCURS 0,

  BEGIN OF SLCTR_OBJECT_TABLE,
    OBJECT                TYPE SLCTR_OBJECT,
    TABNAME               LIKE OBJS-TABNAME,
    VIEWNAME              LIKE OBJS-TABNAME,
  END OF SLCTR_OBJECT_TABLE,
  SLCTR_OBJECT_TABLES     TYPE SLCTR_OBJECT_TABLE OCCURS 0,

  BEGIN OF SLCTR_OBJECT_DESCR,
    OBJECT                TYPE SLCTR_OBJECT,
    FIRST_E071            LIKE SY-TABIX,
    LAST_E071             LIKE SY-TABIX,
    FIRST_E071K           LIKE SY-TABIX,
    LAST_E071K            LIKE SY-TABIX,
    CLIDEP                LIKE OBJH-CLIDEP,
    OBJCATEG              LIKE OBJH-OBJCATEG,
    IMPORTABLE            LIKE OBJH-IMPORTABLE,
    SIZE                  TYPE I,
    LEVEL                 TYPE I,
    CYCLE                 TYPE I,
    STATUS                TYPE I,
    ERROR                 TYPE C,
  END OF SLCTR_OBJECT_DESCR,
  SLCTR_OBJECT_DESCRS     TYPE SLCTR_OBJECT_DESCR OCCURS 0,

  BEGIN OF SLCTR_OBJTAB_DESCR,
    OBJTAB                TYPE SLCTR_OBJECT_TABLE,
    CLUSTER_ELEM          TYPE SLCTR_OBJECT,
    VIEWGRANT             LIKE OBJS-VIEWGRANT,
    DDIC                  LIKE OBJS-DDIC,
    PRIM_TABLE            LIKE OBJS-PRIM_TABLE,
  END OF SLCTR_OBJTAB_DESCR,
  SLCTR_OBJTAB_DESCRS     TYPE SLCTR_OBJTAB_DESCR OCCURS 0.

***********************************************************************
*   Import                                                            *
***********************************************************************

* Kind of logical import
TYPES:
  SLCTR_IMPORT_KIND      TYPE C.

CONSTANTS:
  SLCTR_IMP_TRANSPORT    TYPE SLCTR_IMPORT_KIND VALUE 'T',
  SLCTR_IMP_CLIENT       TYPE SLCTR_IMPORT_KIND VALUE 'C',
  SLCTR_IMP_REMOTE       TYPE SLCTR_IMPORT_KIND VALUE 'R'.

* Constants for import return codes
CONSTANTS:
  SLCTR_RC_OK            LIKE SY-SUBRC VALUE  0,
  SLCTR_RC_WARNING       LIKE SY-SUBRC VALUE  4,
  SLCTR_RC_ERROR         LIKE SY-SUBRC VALUE  8,
  SLCTR_RC_CANCELLED     LIKE SY-SUBRC VALUE 10,
  SLCTR_RC_FATAL         LIKE SY-SUBRC VALUE 12,
  SLCTR_RC_ABORT         LIKE SY-SUBRC VALUE 16.

* Constants for import action
CONSTANTS:
  SLCTR_IMP_INSERTED     LIKE CT003-IMP_ACTION  VALUE 'I',
  SLCTR_IMP_UPDATED      LIKE CT003-IMP_ACTION  VALUE 'U',
  SLCTR_IMP_DELETED      LIKE CT003-IMP_ACTION  VALUE 'D',
  SLCTR_IMP_UNCHANGED    LIKE CT003-IMP_ACTION  VALUE 'N',
  SLCTR_IMP_ERROR        LIKE CT003-IMP_ACTION  VALUE 'E'.

TYPES:
  BEGIN OF SLCTR_IMPORT_RESULT,
    ERRORS               TYPE I,
    INSERTED             TYPE I,
    UPDATED              TYPE I,
    DELETED              TYPE I,
    UNCHANGED            TYPE I,
  END OF SLCTR_IMPORT_RESULT,

  BEGIN OF SLCTR_IMPORT_FLAGS,
    ACTION               TYPE C,
    ERROR                TYPE C,
  END OF SLCTR_IMPORT_FLAGS,

  BEGIN OF SLCTR_TABLE_KEY,
    OBJTAB               TYPE SLCTR_OBJECT_TABLE,
    TABKEY               LIKE E071K-TABKEY,
    KEYLEN               TYPE I,
    GENKEYLEN            TYPE I,
    OBJ_NAME             LIKE TADIR-OBJ_NAME,
    INDEX                LIKE SY-TABIX,
    IMPORT               TYPE SLCTR_IMPORT_RESULT,
  END OF SLCTR_TABLE_KEY,
  SLCTR_TABLES_KEYS      TYPE SLCTR_TABLE_KEY OCCURS 0.

***********************************************************************
*   Data handle                                                      *
***********************************************************************

* Data handle for logical import
TYPES:
  BEGIN OF SLCTR_HANDLE,
    KIND                TYPE SLCTR_IMPORT_KIND,
    SYSTEM              LIKE SY-SYSID,
    CLIENT              LIKE T000-MANDT,
    RFCDEST             LIKE RFCDES-RFCDEST,
  END OF SLCTR_HANDLE.
