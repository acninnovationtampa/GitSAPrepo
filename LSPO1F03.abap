*----------------------------------------------------------------------*
***INCLUDE LSPO1F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  append_quickinfo_to_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IV_QUICKINFO_BUTTON_1  text
*      <--P_BUTTON_1  text
*----------------------------------------------------------------------*
FORM append_quickinfo_to_button                             "*048i+
     USING    iv_quickinfo TYPE text132
     CHANGING cv_button.

  data lv_quickinfo type string.                            "1150700 >>
  data lv_len       type i.

* check the length of the quickinfo
* strlen( button ) + strlen( quickinfo ) = max. 43
  lv_len       = 43 - strlen( cv_button ).
  lv_quickinfo = iv_quickinfo(lv_len).                      "1150700 <<

* Dieser Teil wurde aus dem Funktionsbaustein ICON_CREATE
* kopiert, weil es noch keinen Reuse-Baustein für das
* Einfügen von Quickinfos in eine Drucktaste ohne Ikone gibt.
  CONCATENATE '@\Q' lv_quickinfo '@|' cv_button INTO cv_button.
  TRANSLATE cv_button USING '| '.

ENDFORM.                    " append_quickinfo_to_button    "*048i-
