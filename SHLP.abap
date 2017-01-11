TYPE-POOL SHLP .
* Detailed documentation for this type definition is available
* as parameters docu of the functions in function group SDHI
* (e.g. F4IF_DISPLAY_VALUES)

TYPES: SHLP_INTDESCR_T TYPE SHLP_INTDS,
       SHLP_DESCR_T TYPE SHLP_DESCR,
       SHLP_DESCR_TAB_T TYPE SHLP_DESCT.

TYPES: begin of SHLP_CURS,
         with_cursor(1) type c,
         c type cursor,
       end of shlp_curs.

TYPES: BEGIN OF shlp_range_t,
         sign LIKE ddshselopt-sign,
         option LIKE ddshselopt-option,
         low LIKE ddshselopt-low,
         high LIKE ddshselopt-high,
       END OF shlp_range_t.

TYPES: BEGIN OF shlp_selfld_line,
        keyword LIKE helpval-keyword,
*       In Button steht die Ikone für die Selektionsoption (EQ, CP etc)
*       Bei SPACE, wird die Ikone nicht angezeigt.
        button LIKE rsselint-opti_push,
        low LIKE  helpval-value,
*       In MORE steht die Ikone für Mehrfachauswahl.
*       Bei SPACE, wird die Ikone nicht angezeigt.
        more LIKE icons-text,
        dfies LIKE dfies,
        disprange TYPE c, "Erster Eintrag aus RANGE_TAB wird angezeigt
        range_tab TYPE shlp_range_t OCCURS 0,
        sign LIKE ddshselopt-sign,
        option LIKE ddshselopt-option,
      END OF shlp_selfld_line.
