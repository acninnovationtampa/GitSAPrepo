*----------------------------------------------------------------------*
***INCLUDE LSPO1F02 .
*----------------------------------------------------------------------*
*015i+
*&---------------------------------------------------------------------*
*&      Form  replace_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_PARAMETER  text
*      <--P_FRAGETEXT  text
*----------------------------------------------------------------------*
FORM replace_parameters  TABLES   it_parameter STRUCTURE spar
                         CHANGING chv_text.

  DATA: lv_pattern_replace(12) TYPE c.

  LOOP AT it_parameter.

    CONCATENATE '&' it_parameter-param '&' INTO lv_pattern_replace.
    DO.                                                                      "1233077 >>
      FIND lv_pattern_replace in chv_text respecting case.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      REPLACE lv_pattern_replace IN chv_text WITH it_parameter-value.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDDO.                                                                   "1233077 <<
  ENDLOOP. " at it_parameter

ENDFORM.                    " replace_parameters
*015i-
