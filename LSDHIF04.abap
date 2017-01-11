*----------------------------------------------------------------------*
***INCLUDE LSDHIF04 .
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  Make_helpinfo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CHECKTABLE  text
*      -->P_RETFIELD  text
*      -->P_DISPLAY  text
*      -->P_DYNP_USE  text
*      -->P_DFIES_TAB  text
*      <--P_HELP_INFOS  text
*----------------------------------------------------------------------*
FORM Make_helpinfo TABLES dynpfld_mapping STRUCTURE DSELC
                          dynpfields STRUCTURE DYNPREAD
                   USING checktable TYPE DD03P-CHECKTABLE
                         retfield TYPE DFIES-FIELDNAME
                         value TYPE HELP_INFO-FLDVALUE
                         display TYPE DDBOOL_D
                         dynp_use TYPE DDBOOL_D
                         dfies_tab TYPE DDFIELDS
                   CHANGING help_infos TYPE HELP_INFO.

FIELD-SYMBOLS <dynpread> TYPE DYNPREAD.

CLEAR help_infos.
REFRESH dynpfields.

*- OLR: Comboboxen funktionieren vielleicht doch
  data event(3).
  call 'DY_GET_DYNPRO_EVENT' id 'EVENT' field event.
  if ( sy-subrc = 0 and event = 'OUT' ) or
       dynp_use IS INITIAL.
* IF dynp_use IS INITIAL.
   IF display = 'X'.
      help_infos-SHOW = 'X'.
   ENDIF.
   CONCATENATE '?-' retfield INTO help_infos-DYNPROFLD.
   help_infos-FLDVALUE = value.
ELSE.
     PERFORM Set_help_info_from_focus CHANGING help_infos.
     PERFORM DYNP_VALUES_READ(SAPLSDSD) TABLES dynpfields
                                        USING help_infos.
     READ TABLE dynpfields ASSIGNING <dynpread>
          WITH KEY FIELDNAME = help_infos-DYNPROFLD
               STEPL = help_infos-STEPL.
     IF SY-SUBRC <> 0.
        RAISE ILLEGAL_CALL.
     ENDIF.
     help_infos-FLDVALUE = <dynpread>-FIELDVALUE.
     IF display <> 'F' AND <dynpread>-FIELDINP IS INITIAL.
        help_infos-SHOW = 'X'.
     ENDIF.
ENDIF.
help_infos-CALL = 'T'.
help_infos-SELECTART = 'A'.
help_infos-CHECKTABLE = checktable.
help_infos-CHECKFIELD = retfield.
ENDFORM.                    " Make_helpinfo


*&---------------------------------------------------------------------*
*&      Form  Make_dynpselect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNPFLD_MAPPING  text
*      -->P_DYNPFIELDS  text
*      -->P_DYNPSELECT  text
*      -->P_DFIES_TAB  text
*      -->P_DYNP_USE  text
*----------------------------------------------------------------------*
FORM Make_dynpselect TABLES dynpfld_mapping STRUCTURE DSELC
                            dynpfields STRUCTURE DYNPREAD
                            dynpselect STRUCTURE DSELC
                     USING retfield TYPE DFIES-FIELDNAME
                           dfies_tab TYPE DDFIELDS
                           dynp_use TYPE DDBOOL_D
                           help_infos TYPE HELP_INFO.

     DATA: dfies_wa TYPE DFIES,
           rc TYPE SY-SUBRC,
           found TYPE DDBOOL_D.

     FIELD-SYMBOLS <mapping> TYPE DSELC.

     REFRESH dynpselect.
     IF dynp_use IS INITIAL.
        dynpfields-STEPL = help_infos-STEPL.
     ENDIF.
     dynpselect-FLDNAME = RETFIELD.
     dynpselect-DYFLDNAME = help_infos-DYNPROFLD.
     CLEAR dynpselect-FLDINH.
     APPEND dynpselect.
     IF dynp_use IS INITIAL.
        dynpfields-FIELDNAME = help_infos-DYNPROFLD.
        dynpfields-FIELDVALUE = help_infos-FLDVALUE.
        CLEAR dynpfields-STEPL.
        IF help_infos-SHOW IS INITIAL.
           dynpfields-FIELDINP = 'X'.
        ELSE.
             CLEAR dynpfields-FIELDINP.
        ENDIF.
        APPEND dynpfields.
     ENDIF.
     LOOP AT dfies_tab INTO dfies_wa WHERE FIELDNAME <> RETFIELD.
          READ TABLE dynpfld_mapping
               WITH KEY FLDNAME = dfies_wa-FIELDNAME
               ASSIGNING <mapping>.
          CHECK SY-SUBRC = 0.
          CLEAR dynpselect.
          IF <mapping>-DYFLDNAME IS INITIAL.
             APPEND <mapping> TO dynpselect.
          ELSE.
               dynpselect-FLDNAME = dfies_wa-FIELDNAME.
               IF dynp_use IS INITIAL.
                  CONCATENATE '?-' dfies_wa-FIELDNAME
                              INTO dynpselect-DYFLDNAME.
                  dynpfields-FIELDNAME = dynpselect-DYFLDNAME.
                  CLEAR dynpfields-FIELDVALUE.
                  dynpfields-FIELDVALUE = dynpselect-FLDINH
                                        = <mapping>-FLDINH.
                  PERFORM Conversion_in2ex(SAPLSDH4)
                          USING dfies_wa ' '
                          CHANGING dynpfields-FIELDVALUE.
                  APPEND dynpfields.
               ELSE.
                    dynpselect-DYFLDNAME = <mapping>-DYFLDNAME.
                    PERFORM Get_value_from_dynp
                            TABLES dynpfields
                            USING help_infos <mapping>-DYFLDNAME
                                  dfies_wa
                            CHANGING dynpselect-FLDINH found.
                    CHECK NOT found IS INITIAL.
               ENDIF.
               APPEND dynpselect.
          ENDIF.
     ENDLOOP.
ENDFORM.                    " Make_dynpselect


*&---------------------------------------------------------------------*
*&      Form  Get_value_from_dynp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNPFIELDS  text
*      -->P_HELP_INFOS  text
*      -->P_<MAPPING>_DYFLDNAME  text
*      <--P_DYNPSELECT_FLDINH  text
*----------------------------------------------------------------------*
FORM Get_value_from_dynp TABLES dynpfields STRUCTURE DYNPREAD
                         USING help_infos TYPE HELP_INFO
                               dyfldname TYPE DSELC-DYFLDNAME
                               dfies_wa TYPE DFIES
                         CHANGING fldinh TYPE DSELC-FLDINH
                                  found TYPE DDBOOL_D.

     DATA: rc TYPE SY-SUBRC,
           BEGIN OF mp_field,
                 paranthopen(1),
                 progname LIKE sy-repid,
                 paranthclose(1),
                 fieldname LIKE help_info-dynprofld,
           END OF mp_field.

     FIELD-SYMBOLS <mp_field>.

     found = 'X'.
     CLEAR fldinh.
     READ TABLE dynpfields WITH KEY FIELDNAME = dyfldname
                                    STEPL = help_infos-STEPL
          TRANSPORTING FIELDVALUE.
     IF SY-SUBRC <> 0 AND help_infos-STEPL <> 0.
        READ TABLE dynpfields WITH KEY FIELDNAME = dyfldname
                                       STEPL = 0
             TRANSPORTING FIELDVALUE.
     ENDIF.
     IF SY-SUBRC = 0.
        fldinh = dynpfields-FIELDVALUE.
        PERFORM CONVERSION_EX2IN(SAPLSDH4) USING dfies_wa ' '
                                           CHANGING fldinh rc.
     ELSE.
          CONCATENATE '(' help_infos-DYNPPROG ')' dyfldname
                      INTO mp_field.
          ASSIGN (mp_field) TO <mp_field>.
          IF SY-SUBRC = 0.
             PERFORM Move_save(RADBTNA1) USING <mp_field>
                                         CHANGING fldinh rc.
             IF rc = 0.
                CLEAR dynpfields.
                dynpfields-FIELDNAME = dyfldname.
                dynpfields-FIELDVALUE = fldinh.
                PERFORM CONVERSION_IN2EX(SAPLSDH4)
                        USING dfies_wa ' '
                        CHANGING dynpfields-FIELDVALUE.
                APPEND dynpfields.
             ELSE.
                  CLEAR found.
             ENDIF.
          ELSE.
               CLEAR found.
          ENDIF.
     ENDIF.
ENDFORM.                    " Get_value_from_dynp


*&---------------------------------------------------------------------*
*&      Form  Make_callcontrol
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNP_USE  text
*      -->P_HELP_INFOS  text
*      <--P_CALLCONTROL  text
*----------------------------------------------------------------------*
FORM Make_callcontrol USING multiple_choice TYPE DDBOOL_D
                            dynp_use TYPE DDBOOL_D
                            help_infos TYPE HELP_INFO
                      CHANGING callcontrol TYPE DDSHF4CTRL.

     IF help_infos-SHOW IS INITIAL.
        CLEAR callcontrol-DISPONLY.
     ELSE.
          callcontrol-DISPONLY = 'X'.
     ENDIF.
     IF multiple_choice IS INITIAL.
        CLEAR callcontrol-MULTISEL.
     ELSE.
          callcontrol-MULTISEL = 'X'.
     ENDIF.
ENDFORM.                    " Make_callcontrol


*&---------------------------------------------------------------------*
*&      Form  Make_ocxinterface
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CALLCONTROL  text
*      <--P_OCXINTERFACE  text
*----------------------------------------------------------------------*
FORM Make_ocxinterface USING callcontrol TYPE DDSHF4CTRL
                             dynp_use TYPE DDBOOL_D
                       CHANGING ocxinterface TYPE DDSHOCXINT.

     IF dynp_use IS INITIAL.
        ocxinterface-MODAL = 'X'.
     ELSE.
          CLEAR ocxinterface-MODAL.
     ENDIF.
ENDFORM.                    " Make_ocxinterface


*&---------------------------------------------------------------------*
*&      Form  Correct_interface
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNPFLD_MAPPING  text
*      -->P_DFIES_TAB  text
*      -->P_DYNP_USE  text
*      <--P_SHLP_TOP  text
*----------------------------------------------------------------------*
FORM Correct_interface TABLES dynpflds_mapping STRUCTURE DSELC
                       USING dfies_tab TYPE DDFIELDS
                             dynp_use TYPE DDBOOL_D
                       CHANGING shlp_top TYPE SHLP_DESCR.

     FIELD-SYMBOLS: <mapping> TYPE DSELC,
                    <interface> TYPE DDSHIFACE.

     LOOP AT dynpflds_mapping ASSIGNING <mapping>
          WHERE NOT DYFLDNAME IS INITIAL.
          READ TABLE shlp_top-interface
               WITH KEY SHLPFIELD = <mapping>-FLDNAME
               ASSIGNING <interface>.
          CHECK SY-SUBRC = 0.
          CLEAR <interface>-DISPFIELD.
     ENDLOOP.
ENDFORM.                    " Correct_interface


*&---------------------------------------------------------------------*
*&      Form  Dynp_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHLP_TOP_INTERFACE  text
*      -->P_DYNPFIELDS  text
*      -->P_RETURN_TAB  text
*      -->P_HELP_INFOS  text
*----------------------------------------------------------------------*
FORM Dynp_update TABLES interface STRUCTURE DDSHIFACE
                        dynpfields STRUCTURE DYNPREAD
                        return_tab STRUCTURE DDSHRETVAL
                 USING help_infos TYPE HELP_INFO.

     DATA: selection(1) TYPE C,
           select_value TYPE HELP_INFO-FLDVALUE.

     PERFORM MAP_SHFIELDS_TO_DYNPFIELDS(SAPLSDSD)
             TABLES interface dynpfields return_tab
             USING help_infos
             CHANGING selection select_value.
     CALL FUNCTION 'DYNP_VALUES_UPDATE'
          EXPORTING
               DYNAME               = help_infos-DYNPPROG
               DYNUMB               = help_infos-DYNPRO
          TABLES
               DYNPFIELDS           = dynpfields
          EXCEPTIONS
               OTHERS               = 8.               .
ENDFORM.                    " Dynp_update

FORM Save_Shlptype using shlp type shlp_descr.
data: saved_shlptype like line of saved_shlptypes.

  read table saved_shlptypes transporting no fields
                             with table key shlpname = shlp-shlpname.
  if sy-subrc ne 0.
    saved_shlptype-shlpname = shlp-shlpname.
    saved_shlptype-shlptype = shlp-shlptype.
    insert saved_shlptype into table saved_shlptypes.
  endif.
endform.
