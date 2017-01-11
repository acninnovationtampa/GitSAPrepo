***INCLUDE RSDBCOM2 .
* Gemeinsame Datenstrukturen (und Equates) von RSSYSTDB und RSDBRUNT.

* Daten für Dynprosource

DATA: BEGIN OF T OCCURS 50,                    " Ablauflogik
        LINE(72),
      END OF T.

DATA BEGIN OF F OCCURS 30.                     " Feldbeschreibung TM51
   INCLUDE STRUCTURE D021S.
DATA END OF F.

DATA BEGIN OF M OCCURS 30.                     " Matchcode-Sub-Ids TM51
  INCLUDE STRUCTURE D023S.
DATA END OF M.


*-----------------------------------------------------------------*
* Gibt Auskunft über den Bildaufbau                               *
DATA: BEGIN OF SCREEN_INFO,
        PREFIX(11)      VALUE 'SEL_SCREEN',
        DYNNR LIKE SY-DYNNR,
        MIDFIX(6) VALUE ' INFO:',
        VERSION(2)      TYPE N VALUE '17',
        LINES(6)        TYPE N,
        HASH(31)        TYPE N,
      END   OF SCREEN_INFO.

* Feldname für Dummyfeld: enthält laufzeitrelevante
*                         Informationen über das Bild
  DATA: BEGIN OF SCR_RUNT_INFO,
          PREFIX(2) VALUE '%_',
          VERSION(2) TYPE N,
* SELOPTS: N: keine SELECT-OPTIONS auf Bild
*          S: nur kurze
*          L: nur lange
*          B: beide Sorten
          SELOPTS(1),
          DYNSEL,
          TYPE,
          HASH(10),
          UNUSED(13),
        END OF SCR_RUNT_INFO.
* Equate für aktuelle Versionsnummer
  constants VERSION(2) TYPE N VALUE '17'.

* Equates für die Bits in SSCR-FLAG1 bzw. FLAG2
CONSTANTS: SSCR_F1_DBSE    TYPE X VALUE '80',   " Datenbankspezifisch
           SSCR_F1_OBLI    TYPE X VALUE '40',   " OBLIGATORY
           SSCR_F1_NODI    TYPE X VALUE '20',   " NO-DISPLAY
           SSCR_F1_LOWC    TYPE X VALUE '10',   " LOWER CASE
           SSCR_F1_CBOX    TYPE X VALUE '08',   " AS CHECKBOX
           SSCR_F1_NOIN    TYPE X VALUE '08',   " NO INTERVALS
           SSCR_F1_NOEX    TYPE X VALUE '04',   " NO-EXTENSION
           SSCR_F1_IXST    TYPE X VALUE '04',   " AS INDEX STRUCTURE
           SSCR_F1_RADI    TYPE X VALUE '02',   " RADIOBUTTON
           SSCR_F1_REDB    TYPE X VALUE '02',   " AS DATABASE SELECTION
           SSCR_F1_SUBS    TYPE X VALUE '02',   " SUBSCREENBEREICH
           SSCR_F1_PARM    TYPE X VALUE '01',   " Parameter
*
           SSCR_F2_VRLO    TYPE X VALUE '80',   " VALUE-REQUEST FOR LOW
           SSCR_F2_VRHI    TYPE X VALUE '40',   " VALUE-REQUEST FOR HIGH
           SSCR_F2_VCHK    TYPE X VALUE '40',   " VALUE CHECK
           SSCR_F2_HRLO    TYPE X VALUE '20',   " HELP-REQUEST FOR LOW
           SSCR_F2_HRHI    TYPE X VALUE '10',   " HELP-REQUEST FOR HIGH
           SSCR_F2_LIBO    TYPE X VALUE '10',   " AS LISTBOX
           SSCR_F2_HR      TYPE X VALUE '08',   " HELP-REQUEST FOR both
           SSCR_F2_DYN     TYPE X VALUE '04',   " Dynamisches Bezugsfeld
           SSCR_F2_REFR    TYPE X VALUE '02',   " Nur Referenz
           SSCR_F2_SIGN    TYPE X VALUE '01'.   " DDIC: Vorzeichen

CONSTANTS: BIT_SSCR_F1_DBSE    TYPE I VALUE 1,
           BIT_SSCR_F1_OBLI    TYPE I VALUE 2,
           BIT_SSCR_F1_NODI    TYPE I VALUE 3,
           BIT_SSCR_F1_LOWC    TYPE I VALUE 4,
           BIT_SSCR_F1_CBOX    TYPE I VALUE 5,
           BIT_SSCR_F1_NOIN    TYPE I VALUE 5,
           BIT_SSCR_F1_NOEX    TYPE I VALUE 6,
           BIT_SSCR_F1_IXST    TYPE I VALUE 6,
           BIT_SSCR_F1_RADI    TYPE I VALUE 7,
           BIT_SSCR_F1_REDB    TYPE I VALUE 7,
           BIT_SSCR_F1_SUBS    TYPE I VALUE 7,
           BIT_SSCR_F1_PARM    TYPE I VALUE 8,
*
           BIT_SSCR_F2_VRLO    TYPE I VALUE 1,
           BIT_SSCR_F2_VRHI    TYPE I VALUE 2,
           BIT_SSCR_F2_VCHK    TYPE I VALUE 2,
           BIT_SSCR_F2_HRLO    TYPE I VALUE 3,
           BIT_SSCR_F2_HRHI    TYPE I VALUE 4,
           BIT_SSCR_F2_HR      TYPE I VALUE 5,
           BIT_SSCR_F2_DYN     TYPE I VALUE 6,
           BIT_SSCR_F2_REFR    TYPE I VALUE 7,
           BIT_SSCR_F2_SIGN    TYPE I VALUE 8.




* Konstanten für Selektionsbilder
* Maximale Länge für SELECT-OPTIONS auf dem Screen

CONSTANTS MAX_LENG_SELOPT TYPE I VALUE 18.

CONSTANTS MAX_LENG_SELOPT_LONG  TYPE I VALUE 18. "  wider SB - gfb

CONSTANTS MAX_ILENG_SELOPT TYPE I VALUE 255.     " ... und insgesamt
* Maximale Länge für PARAMETERS auf dem Screen
CONSTANTS MAX_LENG_PARAM  TYPE I VALUE 45.
CONSTANTS MAX_LENG_PARAM_LONG  TYPE I VALUE 45. "  wider SB - gfb


CONSTANTS MAX_ILENG_PARAM  TYPE I VALUE 255.    " ... und insgesamt

*Equates für VARID-FLAG1
CONSTANTS: VARID_F1_NOIMP TYPE X VALUE '10'.
CONSTANTS: VARID_F1_IMP TYPE X VALUE 'EF'.
CONSTANTS: VARID_F1_ALLSCREENS TYPE X VALUE '20'.
CONSTANTS: VARID_F1_NOT_ALL_SCREENS TYPE X VALUE '20'.
CONSTANTS: VARID_F1_SCREENS TYPE X VALUE 'DF'.
CONSTANTS: VARI_F1_NOSPAGPA TYPE X VALUE '40'.
CONSTANTS: VARI_F1_SPAGPA TYPE X VALUE 'BF'.
CONSTANTS: VARI_F1_NOINT  TYPE X VALUE '80'.
CONSTANTS: VARI_F1_OBLI   TYPE X VALUE '01'.
CONSTANTS: VARI_F1_INT TYPE X VALUE '7F'.
CONSTANTS: VARI_F1_NO_OBLI TYPE X VALUE 'FE'.
