*----------------------------------------------------------------------*
***INCLUDE LSDHIF02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  Run_entitytab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHLP_TAB  text
*      -->P_RECORD_TAB  text
*      -->P_DOMNAME  text
*      -->P_TABNAME  text
*      <--P_SHLP  text
*      <--P_CALLCONTROL  text
*----------------------------------------------------------------------*
FORM Run_entitytab TABLES shlp_tab TYPE SHLP_DESCT
                          record_tab STRUCTURE SEAHLPRES
                   USING domname LIKE DD01V-DOMNAME
                         VALUE(tabname) LIKE DD03P-TABNAME
                   CHANGING shlp TYPE SHLP_DESCR
                            callcontrol STRUCTURE DDSHF4CTRL.

     DATA: value LIKE DDSHIFACE-VALUE,
           DD01V_wa LIKE DD01V,
           fieldname LIKE DFIES-FIELDNAME,
           shlp_int TYPE SHLP_DESCR,
           interface_wa LIKE DDSHIFACE.

     IF tabname IS INITIAL.
        CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
             EXPORTING
                  PARAMETER         = par%tabname
             IMPORTING
                  VALUE             = value
             TABLES
                  SHLP_TAB          = SHLP_TAB
                  RECORD_TAB        = RECORD_TAB
*                 SELOPT_TAB        =
*                 RESULTS_TAB       =
             CHANGING
                  SHLP              = SHLP
                  CALLCONTROL       = CALLCONTROL
             EXCEPTIONS
                  PARAMETER_UNKNOWN = 1.
        IF SY-SUBRC = 0.
           tabname = value.
        ENDIF.
     ENDIF.
     IF tabname CN '-'.
        CALL FUNCTION 'DDIF_DOMA_GET'
             EXPORTING
                  NAME          = DOMNAME
             IMPORTING
                  DD01V_WA      = DD01V_wa
             EXCEPTIONS
                  OTHERS        = 2.
     ENDIF.
     IF DD01V_wa-ENTITYTAB IS INITIAL OR
        ( tabname <> '&' AND DD01V_wa-ENTITYTAB <> tabname ).
        MESSAGE S804(DH) RAISING NO_F4_HLP.
*   Keine Eingabehilfe verfügbar
     ENDIF.
     shlp_int-intdescr-selmethod = shlp_int-shlpname
                                 = DD01V_wa-ENTITYTAB.
     shlp_int-shlptype = 'ET'.
     callcontrol-attachkind = 'A'.
     shlp_int-intdescr-selmtype = 'T'.
     SELECT SINGLE FIELDNAME INTO fieldname FROM DD03K
            WHERE TABNAME = DD01V_wa-ENTITYTAB AND DOMNAME = DOMNAME.
     IF SY-SUBRC <> 0.
        MESSAGE S804(DH) RAISING NO_F4_HLP.
*   Keine Eingabehilfe verfügbar
     ENDIF.
     PERFORM GET_INTERFACE_CH(SAPLSDSD)
             USING DD01V_wa-ENTITYTAB fieldname
             CHANGING shlp_int.
     READ TABLE shlp-interface INTO interface_wa
          WITH KEY SHLPFIELD = par%value.
     interface_wa-SHLPFIELD = fieldname.
     CLEAR: interface_wa-TOPSHLPNAM, interface_wa-TOPSHLPFLD.
     LOOP AT shlp_int-interface TRANSPORTING NO FIELDS
          WHERE SHLPFIELD = fieldname.
          MODIFY shlp_int-interface FROM interface_wa.
          EXIT.
     ENDLOOP.
     PERFORM GET_CHECKTABLE_HELP(SAPLSDSD) CHANGING shlp_int.
     LOOP AT shlp_int-interface INTO interface_wa
          WHERE NOT F4FIELD IS INITIAL.
          fieldname = interface_wa-SHLPFIELD.
          EXIT.
     ENDLOOP.
     IF shlp_int-shlptype = 'ET'.
        shlp_int-shlptype = 'CT'.
     ENDIF.
     PERFORM Run_constructed_shlp_for_value
             TABLES RECORD_TAB
             USING fieldname shlp_int
             CHANGING CALLCONTROL SHLP.
ENDFORM.                    " Run_entitytab


*&---------------------------------------------------------------------*
*&      Form  New_offsets
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SHLP_HLP  text                                             *
*----------------------------------------------------------------------*
FORM New_offsets CHANGING shlp TYPE SHLP_DESCR.

     DATA: dummy TYPE DDBOOL_D,
           rc LIKE SY-SUBRC.

     PERFORM Domainfo_to_dfies(SAPLSDIF) TABLES shlp-fielddescr
                                         CHANGING rc.
     PERFORM Complete_fielddescr(SAPLSDF4)
             USING ' '
             CHANGING shlp-fielddescr dummy.
ENDFORM.                    " New_offsets


*&---------------------------------------------------------------------*
*&      Form  Callback_subshlp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SHLP_HLP  text                                             *
*----------------------------------------------------------------------*
FORM Callback_subshlp TABLES Record_tab STRUCTURE SEAHLPRES
                      CHANGING shlp TYPE shlp_descr
                               callcontrol LIKE DDSHF4CTRL.

DATA interface_wa LIKE DDSHIFACE.

callcontrol-RETALLFLDS = 'X'.
callcontrol-PVALUES = callcontrol-PERSONALIZ = 'D'.
interface_wa-VALUE = %shlpname.
MODIFY shlp-interface FROM interface_wa TRANSPORTING VALUE
       WHERE SHLPFIELD = 'SHLPNAME'.
ENDFORM.                    " Callback_subshlp


*&---------------------------------------------------------------------*
*&      Form  Run_constructed_shlp_for_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RECORD_TAB  text
*      -->P_SHLP_INT  text
*      <--P_SHLP  text
*----------------------------------------------------------------------*
FORM Run_constructed_shlp_for_value
     TABLES record_tab STRUCTURE SEAHLPRES
     USING shlpfield TYPE DD04L-SHLPFIELD
           shlp_int TYPE SHLP_DESCR
     CHANGING callcontrol STRUCTURE DDSHF4CTRL
              shlp TYPE SHLP_DESCR.

     DATA: fields_out_tab LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
           ocxinterface LIKE DDSHOCXINT,
           rc TYPE SY-SUBRC,
           key TYPE SY-TABIX.

     FIELD-SYMBOLS: <dfies> TYPE DFIES,
                    <value>.

     PERFORM Read_key(SAPLSDSD) USING shlp CHANGING key.
     IF key <> 0.
        PERFORM Get_data(RADBTNA1) USING key 'SAPLSDSD_OCXINTERFACE'
                                   CHANGING ocxinterface rc.
     ENDIF.
     CLEAR CALLCONTROL-STEP.
     PERFORM F4PROZ(SAPLSDSD)
             TABLES fields_out_tab USING shlp_int
             CHANGING CALLCONTROL ocxinterface rc.
     CHECK rc = 0.
     IF key <> 0.
        PERFORM put_data(radbtna1)
                USING key 'SAPLSDSD_OCXINTERFACE' ocxinterface
                CHANGING rc.
     ENDIF.
     PERFORM Convert_result_in2ex(SAPLSDH4)
             TABLES RECORD_TAB SHLP-fielddescr
             USING par%value.
     READ TABLE shlp-fielddescr ASSIGNING <dfies>
          WITH KEY FIELDNAME = par%value.
     Assign_par RECORD_TAB <dfies> <value>.
     LOOP AT fields_out_tab WHERE FIELDNAME = shlpfield.
          <value> = fields_out_tab-FIELDVAL.
          APPEND RECORD_TAB.
     ENDLOOP.
     PERFORM Convert_result_ex2in(SAPLSDH4)
             TABLES RECORD_TAB SHLP-fielddescr
             USING ' '.
ENDFORM.                    " Run_constructed_shlp_for_value
