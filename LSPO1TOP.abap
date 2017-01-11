FUNCTION-POOL spo1 MESSAGE-ID s4.
TABLES: spop.

DATA: absmaxlen            TYPE i VALUE 70,                 "B20K058946
      absminlen            TYPE i VALUE 35,                 "B20K058946
      dynpoffset           TYPE i VALUE 10,                 "B20K058946
      textlen              TYPE i.                          "B20K058946

DATA: ok_code(4)           TYPE c,
      ok_code_save(4)      TYPE c,
      option1              LIKE spop-option1,
      option2              LIKE spop-option2,
      option(1)            TYPE c,
      antwort(1)           TYPE c,
      userdefined_f1_id    LIKE dokhl-object,               "B20K052439
      cancel_option(1)     TYPE c.                          "B20K052439


CONSTANTS textlaenge TYPE i VALUE 75.                       "B20K052439
CONSTANTS separate_line(77) TYPE c  VALUE
'----------------------------------------------------------------------'
.
CONSTANTS: c_no_icon(7) TYPE c VALUE 'NO_ICON'.             "*016i

DATA: button_1(152)           TYPE c,            "B20K052439"*048u
      button_2(152)           TYPE c,            "B20K052439"*048u
      button_3(60)            TYPE c,                       "B20K052439
      button_4(60)            TYPE c,                       "B20K052439
      icon_button_3(60)       TYPE c,                       "B20K052439
      icon_button_4(60)       TYPE c,                       "B20K052439
      icon_popup_type(60)     TYPE c,                       "B20K062151
      cursorfield(30)         TYPE c,                       "B20K052439
      dummy_field(10)         TYPE c,                       "B20K052439
      display_more(10)        TYPE c,                       "B20K052439
      textlength              TYPE i,                       "B20K052439
      dynpro_nummer           TYPE i,                       "B20K052439
      diagnosetext(400)       TYPE c,                       "B20K052439
      fragetext(400)          TYPE c,                       "B20K052439
      dummytext(400)          TYPE c,                       "B20K052439
      resttext(400)           TYPE c,                       "B20K052439
      zeile(textlaenge)       TYPE c,                       "B20K052439
      start_spalte            LIKE sy-cucol,                "B20K052439
      start_zeile             LIKE sy-curow,                "B20K052439
      end_spalte              LIKE sy-cucol,                "B20K052439
      end_zeile               LIKE sy-curow,                "B20K052439
      delta_zeile             LIKE sy-curow.                "B20K052439
* interne Tabelle für Aufnahme des formatierten Fragetextes
DATA: BEGIN OF text_tab1 OCCURS 3,                          "B20K052439
         textzeile LIKE zeile,                              "B20K052439
      END OF text_tab1,                                     "B20K052439
      text_tab1_index         LIKE sy-index,                "B20K052439
      tab_len1                TYPE i.                       "B20K052439

* interne Tabelle für Aufnahme des formatierten Diagnosetextes
DATA: BEGIN OF text_tab2 OCCURS 20,                         "B20K052439
         textzeile  LIKE zeile,                             "B20K052439
         textformat LIKE tline-tdformat,                    "B20K052439
      END OF text_tab2,                                     "B20K052439
      text_tab2_index          LIKE sy-index,               "B20K052439
      tab_len2                 TYPE i.                      "B20K052439

* globale Variablen für Cursorverwaltung beim Step-Loop
DATA:
*    max_dynp_len TYPE i VALUE '20',                        "974439  >>
    max_dynp_len TYPE i VALUE '24',                         "974439  <<
    dynp_loops   TYPE i,
    last_page    TYPE i.

* interne Tabelle für Textzeilen, die ausgegeben werden sollen

DATA: BEGIN OF textlines OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF textlines.

DATA: BEGIN OF textzeilen OCCURS 5,                         "B20K057791
        zeile(40) TYPE c,                                   "B20K057791
      END OF textzeilen.                                    "B20K057791
DATA: textzeilen_index TYPE i.                              "B20K057791

* Längere Titelzeile für POPUP_TO_CONFIRM
DATA: title(60) TYPE c.                                     "B20K071317

* Parametertabelle für POPUP_TO_CONFIRM                     "*029i
* (l_* weil es die Tabelle vorher schon gab...)             "*029i
DATA: l_parameter LIKE spar OCCURS 0 WITH HEADER LINE.      "*029i

DATA html_control TYPE REF TO cl_gui_html_viewer.           "974439  >>
DATA my_container TYPE REF TO cl_gui_custom_container.
DATA ui_flag TYPE i.
DATA GUI_STYLES TYPE SWL_STYLES.
DATA html_line(65535) type c.
DATA html_table Like table of html_line.
DATA l_url type CNHT_URL.
DATA fontsize type string.
DATA fontname type string.
DATA font type string.
DATA body type string.
DATA back_color type i.
DATA back_color_x(3) type x.
DATA back_color_string type string.
DATA bgcolor type string.
DATA l_height type i.
DATA l_width type i.
DATA delta type i.
DATA wa_text_tab1 LIKE LINE OF text_tab1.
DATA wa_text_tab2 LIKE LINE OF text_tab2.
DATA text_line2 type string.
DATA my_container2 TYPE REF TO cl_gui_custom_container.
DATA html_table2 Like table of html_line.
DATA html_control2 TYPE REF TO cl_gui_html_viewer.
DATA l_url2 type CNHT_URL.
DATA l_string type string.
DATA text_line type string.                                "974439  <<

*************************** Konstanten *******************************
* Kennzeichen der Dialogtextbausteine
DATA: docu_id_dialog_text  LIKE dokhl-id  VALUE 'DT'.

* angefaßt am 12.3.1997 B20K059957

* angefaßt am 12.1.1997:
DATA: BEGIN OF exclude OCCURS 10,
        func LIKE rsnewleng-fcode,
      END OF exclude.
*DATA  sy-curow.
