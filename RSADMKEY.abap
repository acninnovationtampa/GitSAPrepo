***INCLUDE RSADMKEY .

************************************************************************
* Definitionen der ADM-Opcodes
*
* entsprecende C-Definitionen in adxxkey.h
************************************************************************
DATA: AD_GENERAL        TYPE I VALUE  0. "#EC NEEDED "generelle Infos
DATA: AD_GENERAL2       TYPE I VALUE 17. "#EC NEEDED "erw. generelle Infos
DATA: AD_PROFILE        TYPE I VALUE  1. "#EC NEEDED "Profile-Parameter lesen
DATA: AD_WPSTAT         TYPE I VALUE  2. "#EC NEEDED "Workprozess-Status wie SM50
DATA: AD_QUEUE          TYPE I VALUE  3. "#EC NEEDED "Dispatcher-Queue-Füllstand
DATA: AD_STARTSTOP      TYPE I VALUE  4. "#EC NEEDED "Workprozesse umschalten
DATA: AD_WPCONF         TYPE I VALUE  5. "#EC NEEDED "Workprozesse-Rekonfiguration
DATA: AD_WPCONF2        TYPE I VALUE 16. "#EC NEEDED "erw. Workprozesse-Rekonfiguration
DATA: AD_USRLST         TYPE I VALUE  6. "#EC NEEDED "Benutzerliste wie SM04
DATA: AD_WPKILL         TYPE I VALUE  7. "#EC NEEDED "Beenden Workprozess
DATA: AD_TIMEINFO       TYPE I VALUE  8. "#EC NEEDED "Zeit eines Appl.Servers

*** Opcodes für Alert-Processing ***************************************
DATA: AD_ALRT_GET_STATE TYPE I VALUE 10. "#EC NEEDED "Alert-Status abholen
DATA: AD_ALRT_OPERATION TYPE I VALUE 11. "#EC NEEDED "Operationen (Quit, usw.)
DATA: AD_ALRT_SET_PARAM TYPE I VALUE 12. "#EC NEEDED "Alert-Schwellwerte setzen

DATA: AD_RZL            TYPE I VALUE 20. "#EC NEEDED "reserviert für RZ-Leitstand
DATA: AD_RZL_STRG       TYPE I VALUE 21. "#EC NEEDED "Zugriff auf lokalen Speicher

*** Opcodes für Extended Memory ****************************************
DATA: AD_EM             TYPE I VALUE 25. "#EC NEEDED "Extended Memory
DATA: AD_ES             TYPE I VALUE 26. "#EC NEEDED "Extended Segments

************************************************************************
* Konstanten fuer den Aufruf von TH_SEND_ADM_MESS
************************************************************************
DATA: TH_ADM_LEVEL_WP TYPE I VALUE 1. "#EC NEEDED " ADM-Message fuer Workprozess
DATA: TH_ADM_LEVEL_DP TYPE I VALUE 2. "#EC NEEDED " ADM-Message fuer Dispatcher
DATA: TH_ADM_LEVEL_MS TYPE I VALUE 3. "#EC NEEDED " ADM-Message fuer Message-Server
DATA: TH_ADM_ANSWER_WAIT_YES TYPE I VALUE 1. "#EC NEEDED " auf Antwort warten
DATA: TH_ADM_ANSWER_WAIT_NO  TYPE I VALUE 0. "#EC NEEDED " nicht auf Antwort warten
DATA: TH_ADM_TRACE_ON  TYPE I VALUE 1. "#EC NEEDED " Trace einschalten
DATA: TH_ADM_TRACE_OFF TYPE I VALUE 0. "#EC NEEDED " Trace ausschalten
DATA: TH_ADM_SRVTYPES_NONE TYPE MSTYPES VALUE 0. "#EC NEEDED


************************************************************************
* Definitionen der ADM-Kommunikations-Strukturen
*
* entsprechende C-Definitionen in adxxkey.h u.a.
************************************************************************

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_GENERAL
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_GENERAL_REC, "#EC NEEDED
     WP_NO_DIA(3),
     WP_NO_VB(3),
     WP_NO_ENQ(3),
     WP_NO_BTC(3),
     WP_NO_SPO(3),
     INSTANCE(13),
     END OF AD_GENERAL_REC.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_GENERAL2
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_GENERAL2_REC, "#EC NEEDED
     WP_NO_DIA(3),
     WP_NO_VB(3),
     WP_NO_ENQ(3),
     WP_NO_BTC(3),
     WP_NO_SPO(3),
     INSTANCE(13),
     USER_NO(3),
     WP_NO_VB2(3),
     WP_NO_RESTRICTED(3),
     WP_MAX_NO(3),
     WP_CONFIGURABLE_NO(3),
     END OF AD_GENERAL2_REC.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_WPSTAT
*-----------------------------------------------------------------------

DATA: CLASS_A_WP_IDENT(20) VALUE 'BTC_CLASS_A_WP'. "#EC NEEDED

*** defines laut dpxxtool.h ********************************************
DATA: AD_WPSTAT_STAT_FREE     TYPE I  VALUE 1.  "#EC NEEDED " Status FREE
DATA: AD_WPSTAT_STAT_WAIT     TYPE I  VALUE 2.  "#EC NEEDED " Status WAIT
DATA: AD_WPSTAT_STAT_RUN      TYPE I  VALUE 4.  "#EC NEEDED " Status RUN
DATA: AD_WPSTAT_STAT_HOLD     TYPE I  VALUE 8.  "#EC NEEDED " Status HOLD
DATA: AD_WPSTAT_STAT_KILLED   TYPE I  VALUE 16. "#EC NEEDED " Status KILLED

DATA: BEGIN OF RAW_AD_WPSTAT_REC,"#EC NEEDED
     WP(3),
     RQTYP(4),
     PID(11),
     STAT(5),
     WAIT_FOR(3),
     RESTART(3),
     NO_OF_DEATHS(5),
     SEM(5),
     RUNTIME(11),
     REPORT(8),
     MANDT(3),
     BNAME(12),
     ACTION(3),
     TAB_NAME(10),
     END OF RAW_AD_WPSTAT_REC.

DATA: CLASS_A_BTC_WP TYPE I."#EC NEEDED

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_STARTSTOP
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_STARTSTOP_REC,"#EC NEEDED
      TYPE(3),
      NAME     TYPE MSNAME,
      SAPSYSNR TYPE SRZL_SYSNO,
      HOSTNAME(64),
      END OF AD_STARTSTOP_REC.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_USRLST
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_USRLST_REC,"#EC NEEDED
     MANDT(3),
     BNAME(12),
     TERMINAL(12),
     TCOD(4),
     REPORT(8),
     DIATIME(11),
     AMODES(3),
     IMODES(3),
     type(11),
     rfc_type(3),
     END OF AD_USRLST_REC.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_WPKILL
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_WPKILL_REC,"#EC NEEDED
     WP(11),
     KILLTYPE(1),
     MANDT(3),
     BNAME(12),
     END OF AD_WPKILL_REC.

*-----------------------------------------------------------------------
* ZUGEH. KONSTANTEN
*-----------------------------------------------------------------------
DATA: AD_WPKILL_HARD(1) VALUE 'H'."#EC NEEDED
DATA: AD_WPKILL_SOFT(1) VALUE 'S'."#EC NEEDED

*-----------------------------------------------------------------------
* STRUKTUR FUER AD_TIMEINFO
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_TIMEINFO_REC,"#EC NEEDED
     UTC(11),
     LOCTIMESTR(14),
     USEC(6),
     TIMEZONE(11),
     END OF AD_TIMEINFO_REC.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_RZL
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_RZL_COM,"#EC NEEDED
     OPCODE(1) TYPE X,
     BUFFER(99),
     END OF AD_RZL_COM.

*-----------------------------------------------------------------------
* STRUKTUR FUER OPCODE AD_QUEUE
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_QUEUE_REC,"#EC NEEDED
      RQTYP(4),
      NOW(11),
      HIGH(11),
      MAXI(11),
      WRITES(11),
      READS(11),
      END OF AD_QUEUE_REC.

*-----------------------------------------------------------------------
* Definitionen fuer Opcodes von AD_RZL, siehe saprzl.h
* ABAP API
*-----------------------------------------------------------------------
DATA: RZL_OP_RESERVED_1    TYPE I VALUE 1.  "#EC NEEDED " reserved
DATA: RZL_OP_RD_FILE       TYPE I VALUE 2.  "#EC NEEDED " read file request
DATA: RZL_OP_KILL_INSTANCE TYPE I VALUE 8.  "#EC NEEDED " depricated
DATA: RZL_OP_UNAME         TYPE I VALUE 9.  "#EC NEEDED " uname, Os-Type + Hostname
DATA: RZL_OP_RESERVED_2    TYPE I VALUE 11. "#EC NEEDED " reserved
DATA: RZL_OP_GET_PFSTART   TYPE I VALUE 12. "#EC NEEDED " get start-profile-name
DATA: RZL_OP_GET_STARTTIME TYPE I VALUE 13. "#EC NEEDED " get start-time
DATA: RZL_OP_RD_DIR        TYPE I VALUE 14. "#EC NEEDED " read directory




* Depricated: No longer handled by C level as of Rel 6.10 - Start
DATA: RZL_OP_LINE_1        TYPE I VALUE 4.  "#EC NEEDED " send first line
DATA: RZL_OP_LINE          TYPE I VALUE 5.  "#EC NEEDED " send further lines
DATA: RZL_OP_AP_FILE       TYPE I VALUE 6.  "#EC NEEDED " append lines to file
DATA: RZL_OP_WR_FILE       TYPE I VALUE 7.  "#EC NEEDED " write lines to file
* No longer handled by C level - End

*-----------------------------------------------------------------------
* Definitionen fuer AD Opcodes von AD_RZL, siehe saprzl.c
*-----------------------------------------------------------------------
DATA: RZL_OP_UNAME_U       TYPE C VALUE 'D'.  "#EC NEEDED " uname, Os-Type + Hostname
DATA: RZL_OP_GET_PFSTART_U TYPE C VALUE 'F'.  "#EC NEEDED " get start-profile-name
DATA: RZL_OP_GET_STARTTIME_U TYPE C VALUE 'G'."#EC NEEDED " get start-time

*-----------------------------------------------------------------------
* Depricated/Disabled because of Security
*-----------------------------------------------------------------------
DATA: RZL_OP_RD_FILE_U     type C value 'A'.  "#EC NEEDED " depricated: read file request
DATA: RZL_OP_RD_FILE_DATA  TYPE C VALUE 'B'.  "#EC NEEDED " depricated: read file response
DATA: RZL_OP_KILL_INSTANCE_U TYPE C VALUE 'C'."#EC NEEDED " depricated: kill instance
DATA: RZL_OP_FILE_STAT     TYPE C VALUE 'E'.  "#EC NEEDED " depricated: never implemented
DATA: RZL_OP_RD_DIR_U      TYPE C VALUE 'H'.  "#EC NEEDED " depricated: read directory
DATA: RZL_OP_RD_DIR_DATA   TYPE C VALUE 'I'.  "#EC NEEDED " depricated: read dir response
DATA: RZL_OP_RD_DIR_SUM    TYPE C VALUE 'J'.  "#EC NEEDED " depricated: read dir summary
DATA: RZL_OP_SYS_CMD       TYPE C VALUE 'K'.  "#EC NEEDED " decpricated
DATA: RZL_OP_SYS_CMD_DATA  TYPE C VALUE 'L'.  "#EC NEEDED " decpricated
DATA: RZL_OP_KILL_APSERVER TYPE C VALUE 'M'.  "#EC NEEDED " depricated

*-----------------------------------------------------------------------
* Strukturen der Opcodes innerhalb von AD_RZL
*-----------------------------------------------------------------------
DATA: BEGIN OF RZL_TR_LINE,  "#EC NEEDED  "Transfer-format for
     OPCODE(1),       " RZL_LINE_1, RZL_LINE, RZL_KILL_INSTANCE,
     TEXT(99),               " RZL_UNAME,  RZL_GET_PFSTART
     END OF RZL_TR_LINE.     "

DATA: BEGIN OF RZL_TR_LINE_DATA, "#EC NEEDED "Transfer-format for RZL_SYS_CMD,
     OPCODE(1),              " RZL_SYS_CMD_DATA,
     OFFSET(5),              "
     LEN(5),                 "
     TEXT(89),               "
     END OF RZL_TR_LINE_DATA."

DATA: BEGIN OF RZL_TR_FILE,  "#EC NEEDED "Transfer-format for RZL_RD_FILE
     OPCODE(1),              " RZL_AP_FILE, RZL_WR_FILE
     FROMLINE(5),           " start read at line {0..}
     TOLINE(5),             " stop read at line {excluding}
     NAME(89),              " file name
     END OF RZL_TR_FILE.

DATA: BEGIN OF RZL_TR_FILE_DATA, "#EC NEEDED "response-format for RZL_RD_FILE
     OPCODE(1),             " RZL_AP_FILE, RZL_WR_FILE
     OFFSET(5),             " offset if fragment in line
     LEN(5),                " length of line fragment
     LINENR(5),             " nr of line in file {0..}
     TEXT(84),               " line or line fragment
     END OF RZL_TR_FILE_DATA.

*-----------------------------------------------------------------------
* Strukturen der Opcodes innerhalb von AD_EM
*-----------------------------------------------------------------------
DATA: BEGIN OF AD_EM_T,      "#EC NEEDED "Transfer-format for ES, EM
     OPCODE(3),              " OpCode, see esxxadx.h, emxxadx.h
     ADSPACE(96),            " OpCode dependent space. Renamed from SPACE to ADSPACE. According to
                             " where-used search the component name SPACE was unused. cg 02.07.2013
     END OF AD_EM_T.         "

DATA: EM_AD_OP_USAGE TYPE I VALUE 1. "#EC NEEDED  "get EM usage
DATA: BEGIN OF EM_TR_STR_USAGE,      "#EC NEEDED "transfer format
     OPCODE(3),              " OpCode
     BLOCKSIZEKB(4)     TYPE X,
     SLOTSEXISTING(4)   TYPE X,
     SLOTSUSED(4)       TYPE X,
     SLOTSALLOCATED(4)  TYPE X,
     SLOTSATTACHED(4)   TYPE X,
     HEAPUSEDSUM(4)     TYPE X,
     PRIVWPNO(4)        TYPE X,
     EMSLOTSUSED(4)     TYPE X,
     EMSLOTSUSEDPEAK(4) TYPE X,
     EMSLOTSTOTAL(4)    TYPE X,
     HEAPUSEDSUMKB(4)   TYPE X,
     HEAPUSEDSUMPEAKKB(4) TYPE X,
     WPDIARESTART(4)    TYPE X,
     WPNONDIARESTART(4) TYPE X,
     END OF EM_TR_STR_USAGE.

DATA: EM_AD_OP_CNTXT     TYPE I VALUE 2.  "#EC NEEDED "get EM context slots
DATA: EM_AD_OP_ACT_CNTXT TYPE I VALUE 3.  "#EC NEEDED "get EM active context slots
DATA: BEGIN OF EM_TR_STR_CNTXT,      "#EC NEEDED "transfer format
     OPCODE(3),                    "  3 Size
     HANDLE(4)             TYPE X, "  7
     KEY(16),                      " 23 Size
     INFO(16),                     " 29 Size
     ATTACHED              TYPE X, " 30 Size
     WPID                  TYPE X, " 31 Size
     ACTIMODE              TYPE X, " 32 Size
     MEMSUMKB(4)           TYPE X, " 36 Size
     PRIVSUMKB(4)          TYPE X, " 40 Size
     PRIVTIME(6),                  " 46 Size
     TCODE(4),                     " 50 Size
     USEDKB(4)             TYPE X, " 54 Size
     MAXKB(4)              TYPE X, " 58 Size
     MAXDIAKB(4)           TYPE X, " 62 Size
     USEDSTACKEDMODESKB(4) TYPE X, " 66 Size
     USEDGLOBALKB(4)       TYPE X, " 70 Size
     USEDHYPERKB(4)        TYPE X, " 74 Size
     ESMEMORYFREEMB(4)     TYPE X, " 78 Size
     END OF EM_TR_STR_CNTXT.

*-----------------------------------------------------------------------
* Strukturen der Opcodes innerhalb von AD_ES
*-----------------------------------------------------------------------
DATA: ES_AD_OP_USAGE TYPE I VALUE 1.  "#EC NEEDED "get ES usage
DATA: BEGIN OF ES_TR_STR_USAGE,      "#EC NEEDED "transfer format
     OPCODE(3),              " OpCode
     BLOCKSIZEKB(4)     TYPE X,
     SLOTSEXISTING(4)   TYPE X,
     SLOTSUSED(4)       TYPE X,
     SLOTSALLOCATED(4)  TYPE X,
     SLOTSATTACHED(4)   TYPE X,
     END OF ES_TR_STR_USAGE.

DATA: ES_AD_OP_CNTXT     TYPE I VALUE 2. "#EC NEEDED  "get ES context slots
DATA: BEGIN OF ES_TR_STR_CNTXT,      "#EC NEEDED "transfer format
     OPCODE(3),              " OpCode
     STARTINDEX(4)       TYPE X,
     ACTIVESTATESONLY(1) TYPE X,
     HANDLE(4)           TYPE X,
     USERNAME(20),
     STATE(1)            TYPE X,
     LASTATTACHCLIENT(1) TYPE X,
     SIZEMB(4)           TYPE X,
     CNTOPALLOC(4)       TYPE X,
     TIMOPALLOC(4)       TYPE X,
     TIMOPFREE(4)        TYPE X,
     CNTOPATTACH(4)      TYPE X,
     TIMOPATTACH(4)      TYPE X,
     TIMOPDETACH(4)      TYPE X,
     END OF ES_TR_STR_CNTXT.

DATA: ES_AD_OP_SETUP          TYPE I VALUE 3. "#EC NEEDED "get/set ES controls
DATA: ES_ADM_SETUP_DISCLAIM   TYPE I VALUE 1. "#EC NEEDED "set disclaim
DATA: ES_ADM_SETUP_STATISTICS TYPE I VALUE 2. "#EC NEEDED "set statistics level

DATA: BEGIN OF ES_TR_STR_SETUP,   "#EC NEEDED    "transfer format
     OPCODE(3),              " OpCode
     SETUPOP(4)         TYPE X," Setup Operation Code
     MAGIC(4)           TYPE X,"
     SIZE(4)            TYPE X,"
     VERSION(4)         TYPE X,"
     STATISTICSLEVEL(4) TYPE X," Statistics Level 0,1,2
     STATPRTCOLTIME(4)  TYPE X,"
     STATPRTCOLCYCLE(4) TYPE X,"
     DISCLAIMATFREE(4)  TYPE X," Disclaim  0=off, 1=each, n=each n-th
     DISCLAIMCOUNT(4)   TYPE X,"
     ACTIVECLIENTS(4)   TYPE X,"
     HIGHESTCLIENT(4)   TYPE X,"
     INITIALSIZEMB(4)   TYPE X,"
     MAXSIZEMB(4)       TYPE X,"
     ADDRESSSPACEMB(4)  TYPE X,"
     END OF ES_TR_STR_SETUP.
