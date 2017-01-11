TYPE-POOL SYDB0 .

* ------------ Selection screens at runtime -------------------------- *

* Type N representation of reduced SSCR-NUMB
TYPES SYDB0_SSCR_NUMB(3) TYPE N.
TYPES: BEGIN OF SYDB0_OPTI_OFF,
         NUMB TYPE SYDB0_SSCR_NUMB,
       END   OF SYDB0_OPTI_OFF.
TYPES SYDB0_OPTI_OFF_T TYPE SYDB0_OPTI_OFF OCCURS 0.
TYPES: BEGIN OF SYDB0_SELNOIN,
        NUMB TYPE SYDB0_SSCR_NUMB,
        LOW,
        HIGH,
        VPUSH,
      END OF SYDB0_SELNOIN.
TYPES: SYDB0_SELNOIN_T TYPE SYDB0_SELNOIN OCCURS 0.
* Structure: Table of relevant Parameters
TYPES: BEGIN OF SYDB0_PARAMS,
         NAME LIKE RSSCR-NAME,            " Name des Parameters
         NUMB  TYPE SYDB0_SSCR_NUMB,      " SSCR-NUMB
         SSCR LIKE RSSCR,                 " SSCR
         TEXT LIKE RSPARINT-TEXT,         " Text
         VUV,                             " Variant User Variable
       END   OF SYDB0_PARAMS.
* Optionen in Hex-Format
TYPES: SYDB0_XOPTIONS(2) TYPE X.

* Structure: Table of relevant Select-Options
TYPES:  BEGIN OF SYDB0_SELOPTS,
          NAME(8),                         " Name der SELECT-OPTION
          NUMB TYPE SYDB0_SSCR_NUMB,       " SSCR-NUMB
          SSCRIX LIKE SY-TABIX,            " Index in %_SSCR
          SSCR LIKE RSSCR,                 " SSCR
          TEXT LIKE RSSELINT-TEXT,         " Text
          VUV,                             " Variant User Variable
          DISPLAYED_LINE LIKE SY-TABIX,    " Nummer der Zeile auf Bild
          SCREEN_LOW  LIKE SCREEN,         " SCREEN von selopt-LOW
          SCREEN_HIGH LIKE SCREEN,         " SCREEN von selopt-HIGH
          SG_MAIN LIKE RSRESTRICT-SIGN, " Vorzeichen: ' ', 'I', 'E', 'N'
          SG_ADDY LIKE RSRESTRICT-SIGN, " Vorzeichen: ' ', 'I', 'E', 'N'
          X_MAIN_OPTIONS TYPE SYDB0_XOPTIONS,
          X_ADDY_OPTIONS TYPE SYDB0_XOPTIONS,
          JUST_INTERVALS,                    " nur Intervalle erlaubt
          JUST_PATTERNS,                     " nur Muster erlaubt
          JUST_INT_OR_PATT,                  " nur Int. oder Muster erl.
          NOINT_CHECK,                       " Keine Intervallprüfung
        END   OF SYDB0_SELOPTS.

* Index table via number
TYPES: BEGIN OF SYDB0_SELNUM,
         NUMB TYPE SYDB0_SSCR_NUMB,       " %_SSCR-NUMB
         SELTABIX LIKE SY-TABIX,          " Index in SELOPTS
         CONVERT LIKE RSCONVERT,
         REFFIELD LIKE RSSCR-DBFIELD,
         INITIALIZED,
       END   OF SYDB0_SELNUM.

* Block number
TYPES SYDB0_BLOCKNUM(7).
* Contents of blocks
TYPES: BEGIN OF SYDB0_BLOCKS,
        BLOCKNUM TYPE SYDB0_BLOCKNUM,
        NAME(20),                      " maximale Länge
        PARENT TYPE SYDB0_BLOCKNUM,
        SELOPTS LIKE RSSCR-NAME OCCURS 10,
        INIT,                          " Wird bei Blockeinstieg gesetzt
                                       " Für END_OF_BLOCK-Handling
        ORGNUM(7) TYPE N,              " Referenz: Nummer Originalblock
      END   OF SYDB0_BLOCKS.
* Contents of blocks (simple version for RESTRICT)
TYPES: BEGIN OF SYDB0_SIMPLE_BLOCKS,
        NAME(20),                      " maximale Länge
        SELOPTS LIKE RSSCR-NAME OCCURS 10,
      END   OF SYDB0_SIMPLE_BLOCKS.

TYPES SYDB0_SELOPTS_T TYPE SYDB0_SELOPTS OCCURS 20.
TYPES SYDB0_SELNUM_T TYPE SYDB0_SELNUM OCCURS 20.
TYPES SYDB0_PARAMS_T TYPE SYDB0_PARAMS OCCURS 20.
TYPES SYDB0_BLOCKS_T TYPE SYDB0_BLOCKS OCCURS 20.
TYPES SYDB0_SIMPLE_BLOCKS_T TYPE SYDB0_SIMPLE_BLOCKS OCCURS 20.
TYPES SYDB0_RSSELID_T LIKE RSSELID OCCURS 10.

* Description of picked field
TYPES: BEGIN OF SYDB0_PICK,
         FIELD LIKE RSSCR-NAME,
         NUMB TYPE SYDB0_SSCR_NUMB,
       END   OF SYDB0_PICK.
TYPES: BEGIN OF SYDB0_TABS,
         FCODE LIKE SY-UCOMM,
         NAME(20),
         DYNNR LIKE SY-DYNNR,
         PROGRAM TYPE SY-REPID,
       END OF SYDB0_TABS.
TYPES: SYDB0_TABS_T TYPE SYDB0_TABS OCCURS 0.
*Description of blocks in tabstrip
TYPES: BEGIN OF SYDB0_TABBLOCK,
         NAME TYPE SYDB0_TABS-NAME,
       END OF SYDB0_TABBLOCK.
TYPES: SYDB0_TABBLOCK_T TYPE SYDB0_TABBLOCK OCCURS 0.
TYPES: BEGIN OF SYDB0_TAB_2_SCREEN,
        NAME TYPE SYDB0_TABS-NAME,
        PROG TYPE SY-REPID,
        DYNNR LIKE SY-DYNNR,
      END OF SYDB0_TAB_2_SCREEN.
TYPES: SYDB0_TAB_2_SCREEN_T TYPE SYDB0_TAB_2_SCREEN OCCURS 0.
* Selection_text_modify
types: begin of sydb0_modtext,
         index like sy-index,
         name  like rsscr-name,
         text  type rsseltext,
       end of sydb0_modtext.
* Description of one screen
TYPES: BEGIN OF SYDB0_SCREEN,
         PROGRAM LIKE SY-REPID,
         DYNNR   LIKE SY-DYNNR,
         TYPE,
         TITLETYPE,                    " T: TEXT-xxx, F: Feld
         TITLE LIKE SY-TITLE,          " Inhalt oder Feldname
         FUNC_KEYS(5),                 " Anwendundungsdrucktasten
         RESTRICT_FLAG,                " Restrict-Info gesetzt?
                              " ' ': kein Aufruf
                              " 'X': Aufruf mit Auswirkung für Bild
                              " 'N': Aufruf ohne Auswirkung für Bild
         ANY_VARIANTS,                 " Any variants for this screen?
         ANY_VUVS,                     " User variables?
         ANY_INACTIVES,                " Geschützte Objekte ?
         ANY_INVISIBLES,               " Unsichtbare Objekte ?
         dyns_sub,                     " Free selections subscreen?
         SELOPTS TYPE SYDB0_SELOPTS_T,
         SELNUM  TYPE SYDB0_SELNUM_T,
         PARAMS  TYPE SYDB0_PARAMS_T,
         BLOCKS  TYPE SYDB0_BLOCKS_T,
         INACTIVE TYPE SYDB0_RSSELID_T,
         INVISIBLE TYPE SYDB0_RSSELID_T,
         NOINTERVALS TYPE SYDB0_RSSELID_T, "bis Feld ausgeblendet
         OBLIGATORY TYPE SYDB0_RSSELID_T, "Mußeingabefeld
         TABS       TYPE SYDB0_TABS_T,
         TABBLOCKS TYPE SYDB0_TABBLOCK_T,
         modtext type sydb0_modtext occurs 0,
       END   OF SYDB0_SCREEN.

* Descriptions of all screens
TYPES SYDB0_SCREEN_T TYPE SYDB0_SCREEN OCCURS 5.

* Description of one stack entry
TYPES: BEGIN OF SYDB0_SCR_STACK_LINE,
         PROGRAM LIKE SY-REPID,
         DYNNR   LIKE SY-DYNNR,
         MODE,       " S: SUBMIT, C: CALL, T: Transaktion/Dialogbaustein
                     " J: Subscreen
         POPUP,                        " AS POPUP?
         STATUS LIKE SY-PFKEY,         " GUI-Status
         GUI_PROG LIKE SY-REPID,       " Programm des GUI-Status
         STATUS_FB LIKE RS38L-NAME,    " FB zum Setzen des GUI-Status
         STATUS_SET,                   " Eigener Status gesetzt
         EXCL LIKE RSEXFCODE OCCURS 5, " EXCLUDE-Tabelle
         USR_EXCL LIKE RSEXFCODE OCCURS 5, " EXCLUDE-Tabelle der Anwend.
         PICK TYPE SYDB0_PICK,         " picked field
         UCOMM LIKE SY-UCOMM,          " OK-Code
         spec_ucomm,                   " Feldspezifischer Ucomm?
         ALL_SELECTIONS,                " Invisibles sichtbar?
         PREV_SLSET LIKE SY-SLSET,      " Vorheriges SY-SLSET
         parentscreen type sydb0_screen,
         SELOPTS_INSIDE,                 " Sel-Opts in Subscreen
         invisibles_inside,              " Invisibles in Subscreen
         OPTI_PUSH_OFF TYPE SYDB0_OPTI_OFF_T,
         SELOPT_NO_INPUT TYPE SYDB0_SELNOIN_T,
         LAST_SUBSCREEN_PROGRAM TYPE SY-REPID,
         LAST_SUBSCREEN_DYNNR TYPE SY-DYNNR,
         RESET_UCOMM LIKE SY-UCOMM,
         FIELD_FOUND,                     "gefunden in Frame
         TAB_2_SCREEN TYPE SYDB0_TAB_2_SCREEN_T,
         ancestors type i,
       END   OF SYDB0_SCR_STACK_LINE.

* Screen stack
TYPES SYDB0_SCR_STACK TYPE SYDB0_SCR_STACK_LINE OCCURS 5.

* Program description
* Screen specific variants
TYPES: BEGIN OF SYDB0_VSCR,
         PROGRAM  LIKE SY-CPROG,
         DYNNR    LIKE SY-DYNNR,
         VARIANT  LIKE SY-SLSET,
         VARI     LIKE RVARI OCCURS 20,
         VARIVDAT LIKE RSVARIVDAT OCCURS 2,
       END   OF SYDB0_VSCR.
TYPES SYDB0_VSCR_T TYPE SYDB0_VSCR OCCURS 3.

* Objects with dynamic reference
TYPES: BEGIN OF SYDB0_DYNREF,
         NAME LIKE RSSCR-NAME,
         KIND LIKE RSSCR-KIND,
         FIELDNAME LIKE RSSCR-DBFIELD,
         REFFIELD  LIKE RSSCR-DBFIELD,
         DB        LIKE RSSCR-DB,
         CONVERT   LIKE RSCONVERT,
         CURR_REF  LIKE RSSCR-DBFIELD,
         F4        TYPE DFIES-F4AVAILABL,
         SELTEXT   LIKE DD04V-SCRTEXT_L,
       END   OF SYDB0_DYNREF.
* Description of one program
TYPES: BEGIN OF SYDB0_PROG,
          PROGRAM LIKE SY-REPID,
          LDBPG   LIKE SY-LDBPG,         " Datenbankprogramm
          AFTER_FIRST_PBO,               " Erstes PBO vorbei
          RESTRICT_SET,                  " Einmal Restriktionen gesetzt
          TITLE   LIKE SY-TITLE,         " Standardtitel
          ANY_VARIANTS,
          VARIANT LIKE SY-SLSET,         " Variante
          SUBMODE(2),
          STATUS_SUBMODE(2),
          DYNSEL,
          SSCR LIKE RSSCR OCCURS 50,
          VARI LIKE RVARI OCCURS 20,
          VARIVDAT LIKE RSVARIVDAT OCCURS 2,
          VSCR TYPE SYDB0_VSCR_T,
       END   OF SYDB0_PROG.
* Table of all programs
TYPES: SYDB0_PROG_T TYPE SYDB0_PROG OCCURS 3.
