***INCLUDE LBTCHF07 .

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_STEPLIST_EDITOR              *
************************************************************************

*---------------------------------------------------------------------*
*       FILL_1160_XPG_FLAGS                                           *
*---------------------------------------------------------------------*
* Steueflags für ein externes Programm innerhalb eines Jobsteps aus   *
* der internen Tabelle Steplist in das Dynpro 1160 "schieben".        *
*---------------------------------------------------------------------*

FORM fill_1160_xpg_flags.

  CLEAR btch1160.

  CASE steplist-stdoutcntl.
    WHEN stdout_nomanip.
      btch1160-stdoutnom = 'X'.
      btch1160-stdoutinm = space.
    WHEN stdout_inmemory.
      btch1160-stdoutinm = 'X'.
  ENDCASE.

  CASE steplist-stderrcntl.
    WHEN stderr_nomanip.
      btch1160-stderrnom = 'X'.
      btch1160-stderrinm = space.
    WHEN stderr_inmemory.
      btch1160-stderrinm = 'X'.
  ENDCASE.

  CASE steplist-tracecntl.
    WHEN trace_level0.
      btch1160-trclvl3 = space.
      btch1160-trclvl0 = 'X'.
    WHEN trace_level3.
      btch1160-trclvl3 = 'X'.
      btch1160-trclvl0 = space.
  ENDCASE.

  CASE steplist-termcntl.
    WHEN term_dont_wait.
      btch1160-termdontwt = 'X'.
      btch1160-termbyctlp = space.
    WHEN term_by_cntlpgm.
      btch1160-termbyctlp = 'X'.
  ENDCASE.

ENDFORM. " FILL_1160_XPG_FLAGS.

*---------------------------------------------------------------------*
*       SAVE_1160_XPG_FLAGS                                           *
*---------------------------------------------------------------------*
* Sichern der auf Dynpro 1160 gesetzten Steuerflags in die interne    *
* Tabelle STEPLIST                                                    *
*---------------------------------------------------------------------*

FORM save_1160_xpg_flags.

  IF btch1160-stdoutinm EQ space.
    steplist-stdoutcntl = stdout_nomanip.
  ELSE.
    steplist-stdoutcntl = stdout_inmemory.
  ENDIF.

  IF btch1160-stderrinm EQ space.
    steplist-stderrcntl = stderr_nomanip.
  ELSE.
    steplist-stderrcntl = stderr_inmemory.
  ENDIF.

  IF btch1160-trclvl3 EQ 'X'.
    steplist-tracecntl = trace_level3.
  ELSE.
    steplist-tracecntl = trace_level0.
  ENDIF.

  IF btch1160-termbyctlp EQ 'X'.
    steplist-termcntl = term_by_cntlpgm.
  ELSE.
    steplist-termcntl = term_dont_wait.
  ENDIF.

  steplist-conncntl  = comchannel_release. " Defaultwert
  steplist-stdincntl = stdin_redirect.     " Defaultwert

ENDFORM. " SAVE_1160_XPG_FLAGS.

*---------------------------------------------------------------------*
*       INIT_XPG_FLAGS_IN_STEPENTRY                                   *
*---------------------------------------------------------------------*
* Steuerflags für externes Programm innerhalb eines Steps initiali-   *
* sieren und ins Dynpro 1160 "schieben"                               *
*---------------------------------------------------------------------*

FORM init_xpg_flags_in_stepentry.

  steplist-conncntl   = comchannel_release.
  steplist-stdincntl  = stdin_redirect.
  steplist-stdoutcntl = stdout_inmemory.
  steplist-stderrcntl = stderr_inmemory.
  steplist-tracecntl  = trace_level0.
  steplist-termcntl   = term_by_cntlpgm.

  PERFORM fill_1160_xpg_flags.

ENDFORM. " INIT_XPG_FLAGs_IN_STEPENTRY.

*---------------------------------------------------------------------*
*       CLEAR_XPGFLGS_IN_STEPENTRY                                    *
*---------------------------------------------------------------------*
* Steuerflags für externes Programm innerhalb eines Steps löschen     *
*---------------------------------------------------------------------*

FORM clear_xpgflgs_in_stepentry.

  CLEAR steplist-conncntl.
  CLEAR steplist-stdincntl.
  CLEAR steplist-stdoutcntl.
  CLEAR steplist-stderrcntl.
  CLEAR steplist-tracecntl.
  CLEAR steplist-termcntl.

ENDFORM. " CLEAR_XPGFLGS_IN_STEPENTRY.

*---------------------------------------------------------------------*
*      FORM SET_CHOICE_1120                                           *
*---------------------------------------------------------------------*
*  "Anknipsen" einer Programmanagabe eines Steps auf Dynpro 1120      *
*   (Editieren von Stepwerten)                                        *
*---------------------------------------------------------------------*

FORM set_choice_1120 USING choice.
* so tun, als ob Daten verändert worden sind
  sy-datar = 'X'.                                         "#EC WRITE_OK


  CASE choice.
    WHEN 'BTCH1120-ABAP'.
      btch1120-abap = 'X'.
      btch1120-extpgm = space.
    WHEN 'BTCH1120-EXTPGM'.
      btch1120-extpgm = 'X'.
      btch1120-abap   = space.
    WHEN OTHERS.
      CLEAR sy-datar.                                     "#EC WRITE_OK
  ENDCASE.

  IF sy-datar EQ 'X'.
    stepentry_modified = true.
  ENDIF.

ENDFORM. " SET_CHOICE_1120

*---------------------------------------------------------------------*
*      FORM CHECK_SELECTION_1120                                      *
*---------------------------------------------------------------------*
*  Prüfen der Programmangabenauswahl auf Dynpro 1120 ( Editieren      *
*  von Stepwerten )                                                   *
*---------------------------------------------------------------------*

FORM check_selection_1120.

  num_spec = 0.

  IF btch1120-abap EQ 'X'.
    num_spec = num_spec + 1.
  ENDIF.

  IF btch1120-extcmd = 'X'.
    num_spec = num_spec + 1.
  ENDIF.

  IF btch1120-extpgm EQ 'X'.
    num_spec = num_spec + 1.
  ENDIF.

  IF num_spec EQ 0.
    MESSAGE e066.
  ENDIF.

  IF num_spec > 1.
    MESSAGE e067.
  ENDIF.

ENDFORM. " CHECK_SELECTION_1120

*---------------------------------------------------------------------*
*      FORM CHECK_INPUT_1120                                          *
*---------------------------------------------------------------------*
*  Plausibilitätsprüfung der Inputdaten auf Dynpro 1120 ( Stepwerte ) *
*---------------------------------------------------------------------*
*      - im dialogfreien Fall erst den Steptyp und Stepstatus pruefen
*      - Benutzer, unter dessen Berechtigungen der Step laufen soll,
*        prüfen
*      - bei Programmtyp ABAP bzw. externes Programm müssen die An-
*        gaben auf Vollständigkeit hin überprüft werden. Außer der
*        Gültigkeit des angegebenen Usernamens müssen insbesondere
*        die Report- und Variantenangaben geprüft werden
*

FORM check_input_1120.

  DATA: rc           TYPE i VALUE 0,
        targetsystem LIKE rfcdisplay-rfchost,
        destination  LIKE rfcdes-rfcdest.

  data: subrc(3).
  data: sy_subrc like sy-subrc.

  IF steplist_dialog EQ btc_no.
    CASE steplist-typ.
      WHEN btc_abap.
        " ok
      WHEN btc_xcmd.
        " ok
      WHEN btc_xpg.
        " ok
      WHEN OTHERS.
        PERFORM raise_step_exception USING invalid_step_typ
                                           steplist-typ.
    ENDCASE.

    IF steplist-status NE btc_running   AND
       steplist-status NE btc_ready     AND
       steplist-status NE btc_scheduled AND
       steplist-status NE btc_released  AND
       steplist-status NE btc_aborted   AND
       steplist-status NE btc_finished  AND
       steplist-status NE space. " 'alte' Batchjobs
      PERFORM raise_step_exception USING invalid_step_status
                                         steplist-status.
    ENDIF.
  ENDIF.
*
* Benutzernamen prüfen
*
  IF btch1120-authcknam EQ space.
    IF steplist_dialog EQ btc_yes.
      MESSAGE e069.
    ELSE.
      call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
           exporting
               i_msgid     = 'BT'
               i_msgno     = '069'.
      PERFORM raise_step_exception USING
                                   user_name_missing space.
    ENDIF.
  ENDIF.

  PERFORM auth_check_nam USING btch1120-authcknam rc.

  CASE rc.
    WHEN 0.
      " Einplanung des angegebenen benutzernamens ist ok

    WHEN no_user_assign_privilege.
      IF steplist_dialog EQ btc_yes.
        MESSAGE e102 WITH btch1120-authcknam.
      ELSE.

* store precise error information ********************************
         xbp_msgpar1 = btch1120-authcknam.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '102'
                     i_msg1      = xbp_msgpar1
                       .
         clear xbp_msgpar1.
*****************************************************************

        PERFORM raise_step_exception USING
                                     no_user_assign_privilege_id
                                     btch1120-authcknam.
      ENDIF.

    WHEN invalid_username.
      IF steplist_dialog EQ btc_yes.
        MESSAGE e071 WITH btch1120-authcknam.
      ELSE.

* store precise error information ********************************
         xbp_msgpar1 = btch1120-authcknam.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '71'
                     i_msg1      = xbp_msgpar1
                       .
         clear xbp_msgpar1.
*****************************************************************

        PERFORM raise_step_exception USING invalid_username_id
                                           btch1120-authcknam.
      ENDIF.

    WHEN bad_user_type.
      IF steplist_dialog EQ btc_yes.
        MESSAGE e103 WITH btch1120-authcknam.
      ELSE.

* store precise error information ********************************
         xbp_msgpar1 = btch1120-authcknam.

         call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '103'
                     i_msg1      = xbp_msgpar1
                       .
         clear xbp_msgpar1.
*****************************************************************

        PERFORM raise_step_exception USING bad_user_type_id
                                           btch1120-authcknam.
      ENDIF.
  ENDCASE.
*
* Pruefen der ABAP-Angaben unter Beruecksichtigung des gewählten
* Dialogmodus. Da der Funktionsbaustein BP_CHECK_REPORT_VALUES bei
* fehlerhaften Report- bzw. Variantendaten selbst Syslogs schreibt,
* wird hier nur noch die entsprechende Exception nach oben weiterge-
* reicht.
*
  IF btch1120-abap EQ 'X'.
    IF abap_data_input EQ on OR
       steplist_dialog EQ btc_no.

      CALL FUNCTION 'BP_CHECK_REPORT_VALUES'
           EXPORTING  report_name  = btch1120-abapname
                      variant_name = btch1120-variant
                      check_type   = btc_check_report_and_variant
                      chkrp_dialog = steplist_dialog
           IMPORTING  variant_name = btch1120-variant
           EXCEPTIONS invalid_report_name         =  1
                      invalid_variant_name        =  2
                      no_variants_defined         =  3
                      report_can_not_be_scheduled =  4
                      report_has_no_variants      =  5
                      report_name_missing         =  6
                      variant_check_has_failed    =  7
                      variant_name_missing        =  8
                      variant_selection_aborted   =  9
                      no_plan_authority           = 10
                      OTHERS                      = 99.
      CASE sy-subrc.
        WHEN 0.
          " alles ok
        WHEN 1.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e074 WITH btch1120-abapname.
          ELSE.
            xbp_msgpar1 = btch1120-abapname.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '074'
                i_msg1      = xbp_msgpar1.
            clear xbp_msgpar1.
            RAISE invalid_report_name.
          ENDIF.
        WHEN 2.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e075 WITH btch1120-variant.
          ELSE.
            xbp_msgpar1 = btch1120-variant.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '075'
                i_msg1      = xbp_msgpar1.
            clear xbp_msgpar1.
            RAISE invalid_variant_name.
          ENDIF.
        WHEN 3.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e076 WITH btch1120-abapname.
          ELSE.
            xbp_msgpar1 = btch1120-abapname.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '076'
                i_msg1      = xbp_msgpar1.
            clear xbp_msgpar1.
            RAISE no_variants_defined.
          ENDIF.
        WHEN 4.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e077 WITH btch1120-abapname.
          ELSE.
            xbp_msgpar1 = btch1120-abapname.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '077'
                i_msg1      = xbp_msgpar1.
            clear xbp_msgpar1.
            RAISE report_can_not_be_scheduled.
          ENDIF.
        WHEN 5.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e078 WITH btch1120-abapname.
          ELSE.
            xbp_msgpar1 = btch1120-abapname.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '078'
                i_msg1      = xbp_msgpar1.
            clear xbp_msgpar1.
            RAISE report_has_no_variants.
          ENDIF.
        WHEN 6.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e079.
          ELSE.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '079'.
            RAISE report_name_missing.
          ENDIF.
        WHEN 7.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e080.
          ELSE.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '080'.
            RAISE variant_check_has_failed.
          ENDIF.
        WHEN 8 .                          " kann nur bei Dialog = nein auftauchen. Bei
          IF steplist_dialog EQ btc_no.   " Dialog = ja, wird in Stepliste verzweigt
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '528'.
            RAISE variant_name_missing.
          ENDIF.
        WHEN 9.
          " kann nur im Dialogfall passieren -> PAI verlassen
          IF steplist_dialog EQ btc_yes.
            LEAVE SCREEN.
          ENDIF.
        WHEN 10.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e107 WITH btch1120-authcknam btch1120-abapname.
          ELSE.
            xbp_msgpar1 = btch1120-authcknam.
            xbp_msgpar2 = btch1120-abapname.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '107'
                i_msg1      = xbp_msgpar1
                i_msg2      = xbp_msgpar2.
            clear: xbp_msgpar1, xbp_msgpar2.
            RAISE no_plan_authority.
          ENDIF.
        WHEN OTHERS.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e092 WITH sy-subrc.
          ELSE.
            CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
              EXPORTING
                i_msgid     = 'BT'
                i_msgno     = '092'.
            RAISE variant_check_has_failed.
          ENDIF.
      ENDCASE.
*
*       angegebene Systemsprache prüfen. Falls keine Sprache angegeben
*       wurde, wird nur im Dialog ein Fehler ausgegeben. Im Nicht-
*       dialog wird die Sprache auf aktuelle Systemsprache gesetzt
*       (Aufwärtskompatible Behandlung 'alter Jobs').
*
      IF btch1120-language EQ space.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e275.
        ELSE.
          btch1120-language = sy-langu.
        ENDIF.
      ENDIF.

      CALL 'C_SAPGPARAM'
        ID 'NAME' FIELD parameter_installed_languages
        ID 'VALUE' FIELD installed_languages.

      IF sy-subrc NE 0.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e273.
        ELSE.
          CALL METHOD CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
            EXPORTING
              i_msgid     = 'BT'
              i_msgno     = '273'.
          PERFORM raise_step_exception USING
                                       cant_get_installed_languages
                                       space.
        ENDIF.
      ENDIF.

      IF installed_languages NS btch1120-language.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e274 WITH btch1120-language.
        ELSE.

* store precise error information ********************************
          xbp_msgpar1 = btch1120-language.

          call method CL_BTC_ERROR_CONTROLLER=>FILL_ERROR_INFO
               exporting
                     i_msgid     = 'BT'
                     i_msgno     = '274'
                     i_msg1      = xbp_msgpar1
                       .
          clear xbp_msgpar1.
*****************************************************************

          PERFORM raise_step_exception USING
                                       invalid_system_language
                                       btch1120-language.
        ENDIF.
      ENDIF.
    ELSE.
      LEAVE SCREEN. " ABAP-Inputfeld im PBO-Modul eingabebereit machen
    ENDIF.
  ENDIF.
*
* Angaben fuer externes Kommando testen
*
  IF btch1120-extcmd EQ 'X'.
    IF extcmd_data_input EQ on OR
        steplist_dialog EQ btc_no.

      IF btch1120-extcmdname IS INITIAL.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e326.
        ELSE.
          PERFORM raise_step_exception
           USING name_of_extcmd_missing
                 space.
        ENDIF.
      ENDIF.

      IF btch1120-opsystem IS INITIAL.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e326.
        ELSE.
          PERFORM raise_step_exception
            USING operating_system_missing
                  space.
        ENDIF.
      ENDIF.

      targetsystem = btch1120-xcmdtgtsys.
      destination  = steplist-xpgrfcdest.
      CALL FUNCTION 'SXPG_COMMAND_CHECK'
        EXPORTING
          commandname                = btch1120-extcmdname
          operatingsystem            = btch1120-opsystem
          targetsystem               = targetsystem
          destination                = destination
          additional_parameters      = btch1120-xcmdparams
          ext_user                   = btch1120-authcknam  "note 1177319
        EXCEPTIONS
          command_not_found          = 1
          parameters_too_long        = 2
          security_risk              = 3
          wrong_check_call_interface = 4
          x_error                    = 5
          too_many_parameters        = 6
          parameter_expected         = 7
          illegal_command            = 8
          communication_failure      = 9
          system_failure             = 10
          OTHERS                     = 99.

      sy_subrc = sy-subrc.

      if sy_subrc ne 0.
* store precise error information ********************************
         subrc = sy_subrc.

*    CONCATENATE 'SXPG_COMMAND_CHECK' 'sy-subrc =' subrc
*                         INTO xbp_error_text separated by ' '.

         xbp_msgpar1 = 'SXPG_COMMAND_CHECK'.
         xbp_msgpar2 = subrc.

         CALL METHOD cl_btc_error_controller=>fill_error_info
          EXPORTING
            i_msgid = 'XM'
            i_msgno = msg_error_in_function_1
            i_msg2  = xbp_msgpar1
            i_msg3  = xbp_msgpar2
        .

         clear xbp_msgpar1.
         clear xbp_msgpar2.
         CLEAR xbp_error_text.
******************************************************************
      endif.

      CASE sy_subrc.
        WHEN 1.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e327.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_unknown
                    space.
          ENDIF.
        WHEN 2.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e328.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_params_too_long
                    space.
          ENDIF.
        WHEN 3.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e329.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_security_risk
                    space.
          ENDIF.
        WHEN 4.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e330.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_wrong_check_interface
                    space.
          ENDIF.
        WHEN 5.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e331.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_x_error
                    space.
          ENDIF.
        WHEN 6.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e332.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_too_many_parameters
                    space.
          ENDIF.
        WHEN 7.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e333.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_parameters_expected
                    space.
          ENDIF.
        WHEN 8.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e334.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_illegal_command
                    space.
          ENDIF.
        WHEN 9.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e335.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_communication_failure
                    space.
          ENDIF.
        WHEN 10.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e335.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_system_failure
                    space.
          ENDIF.
        WHEN 99.
          IF steplist_dialog EQ btc_yes.
            MESSAGE e331.
          ELSE.
            PERFORM raise_step_exception
              USING extcmd_x_error
                    space.
          ENDIF.
      ENDCASE.

    ELSE.
      LEAVE SCREEN. " Inputfelder fuer externes Kommando im PBO-Modul
    ENDIF.           " eingabebereit machen
  ENDIF.
*
* Angaben fuer externes Programm testen
*
  IF btch1120-extpgm EQ 'X'.
    IF extpgm_data_input EQ on OR
       steplist_dialog EQ btc_no.

      IF btch1120-xpgname1 IS INITIAL.
        IF steplist_dialog EQ btc_yes.
          MESSAGE e070.
        ELSE.
          PERFORM raise_step_exception USING
                                       name_of_extpgm_missing space.
        ENDIF.
      ENDIF.
    ELSE.
      LEAVE SCREEN. " Inputfelder fuer externes Programm im PBO-Modul
    ENDIF.           " eingabebereit machen
  ENDIF.

ENDFORM. " CHECK_INPUT_1120

*---------------------------------------------------------------------*
*      FORM FILL_1120_STEP_DATA                                       *
*---------------------------------------------------------------------*
*  Stepwerte aus interner Tabelle STEPLIST in das Dynpro 1120
*  "schaufeln".
*---------------------------------------------------------------------*

FORM fill_1120_step_data.

  DATA: t1len TYPE i, "LAENGE DES TARGETFELDES 1
        t2len TYPE i, "LAENGE DES TARGETFELDES 2
        slen  TYPE i. "LAENGE DES SOURCEFELDES

  CLEAR btch1120.
  MOVE-CORRESPONDING steplist TO btch1120.
  btch1120-stepcount = list_row_index.

  IF steplist-typ EQ btc_abap.
    btch1120-abap     = 'X'.
    CONDENSE steplist-program.
    TRANSLATE steplist-program TO UPPER CASE.
    btch1120-abapname = steplist-program.
*      CONDENSE STEPLIST-PARAMETER.
    btch1120-variant  = steplist-parameter.
  ELSEIF steplist-typ EQ btc_xcmd.
    btch1120-extcmd     = 'X'.
    btch1120-extcmdname = steplist-program.
    btch1120-xcmdparams = steplist-parameter.
    btch1120-xcmdtgtsys = steplist-xpgtgtsys.
  ELSEIF steplist-typ EQ btc_xpg.
    btch1120-extpgm = 'X'.
    btch1120-xpgname1 = steplist-program.
    btch1120-xpgparam1  = steplist-parameter.
  ENDIF.
ENDFORM. " FILL_1120_STEP_DATA

*---------------------------------------------------------------------*
*      FORM SAVE_1120_STEP_DATA                                       *
*---------------------------------------------------------------------*
* Stepwerte aus auf Dynpro1120 in interne Tabelle STEPLIST "schaufeln"*
*---------------------------------------------------------------------*

FORM save_1120_step_data.

  DATA: BEGIN OF save_print_params.
          INCLUDE STRUCTURE pri_params.
  DATA: END OF save_print_params.

  DATA: BEGIN OF save_arc_params.
          INCLUDE STRUCTURE arc_params.
  DATA: END OF save_arc_params.

  DATA: restlen TYPE i,
        valid_pri_params TYPE c,
        list_name LIKE pri_params-plist.

  CLEAR steplist.
  MOVE-CORRESPONDING btch1120 TO steplist.

  IF btch1120-abap EQ 'X'.
    steplist-typ       = btc_abap.
    steplist-program   = btch1120-abapname.
    steplist-parameter = btch1120-variant.
    PERFORM clear_xpgflgs_in_stepentry.

    MOVE-CORRESPONDING steplist TO save_print_params.
    MOVE-CORRESPONDING steplist TO save_arc_params.

    IF save_print_params-plist IS INITIAL.
* insertion note 551809, BTCH1120-AUTHCKNAM added.
      PERFORM build_default_plist_name USING btch1120-abapname
                                       list_name btch1120-authcknam.
    ELSE.
      list_name = save_print_params-plist.
    ENDIF.

* note 1113722
    IF save_arc_params-arcuser IS NOT INITIAL
    AND save_arc_params-arcuser <> btch1120-authcknam.
      save_arc_params-arcuser = btch1120-authcknam.
    ENDIF.

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        mode                   = 'BATCH'
        no_dialog              = 'X'
        user                   = btch1120-authcknam
        report                 = btch1120-abapname
        list_name              = list_name
        in_parameters          = save_print_params
        in_archive_parameters  = save_arc_params
      IMPORTING
        out_parameters         = save_print_params
        out_archive_parameters = save_arc_params
        valid                  = valid_pri_params
      EXCEPTIONS
        OTHERS                 = 99.

    IF sy-subrc EQ 0.
      IF valid_pri_params IS INITIAL.
        MESSAGE s864. "Pop-Up can be switched off
      ENDIF.
      MOVE-CORRESPONDING save_print_params TO steplist.
      MOVE-CORRESPONDING save_arc_params   TO steplist.
    ELSE.
      IF steplist_dialog = btc_yes.
        IF sy-msgty <> space.
           MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          MESSAGE e065.
        ENDIF.
      ELSE.
      MESSAGE s065.
        PERFORM raise_step_exception USING
                                   reading_print_params_failed
                                   sy-uname.
      ENDIF.
    ENDIF.
  ELSEIF btch1120-extcmd = 'X'.
    steplist-typ = btc_xcmd.
    steplist-program = btch1120-extcmdname.
    steplist-parameter = btch1120-xcmdparams.
    steplist-xpgtgtsys = btch1120-xcmdtgtsys.

    PERFORM save_1160_xpg_flags.  " Steuerflags sichern
  ELSE.
    steplist-typ = btc_xpg.
    steplist-program = btch1120-xpgname1.
    steplist-parameter = btch1120-xpgparam1.

    PERFORM save_1160_xpg_flags.  " Steuerflags sichern
  ENDIF.
*
* Da nur Steps im Status 'eingplant' angelegt / modifiziert werden
* koennen,wird der entsprechende Status gesetzt. Danach Stepwerte in
* interner Tabelle STEPLIST speichern und den Modifizierungstyp
* der Tabelle STEPLIST setzen. Da die Information, dass sich die
* Anzahl der Steps geaendert hat,hoeher prior ist als die, dass
* bereits bestehende Steps upgedatet wurden, muss dies bei
* EDIT_MODE = 'EDIT' beruecksichtigt werden.
*
  steplist-status = btc_scheduled.

  IF edit_modus EQ 'EDIT'.
    MODIFY steplist INDEX list_row_index.
    IF sy-subrc NE 0.
      MESSAGE e081.
    ENDIF.
    IF steplist_modify_type NE btc_stpl_new_count.
      steplist_modify_type = btc_stpl_updated.
    ENDIF.
  ELSE.       " EDIT_MODE = 'NEW'
    APPEND steplist.
    steplist_modify_type = btc_stpl_new_count.
* fix for 46D -- EDIT_MODE = 'NEW' shows up with correct step number
    next_free_steplist_entry = step_list_entries + 1.

  ENDIF.

ENDFORM. " SAVE_1120_STEP_DATA

*---------------------------------------------------------------------*
*      FORM SAVE_STEPLIST                                             *
*---------------------------------------------------------------------*
* Erstellen einer Kopie der Stepliste, die an den Funktionsbaustein   *
* BP_STEPLIST_EDITOR übergeben wurde.                                 *
*---------------------------------------------------------------------*

FORM save_steplist.

  CLEAR steplist_copy.
  REFRESH steplist_copy.

  LOOP AT steplist.
    steplist_copy = steplist.
    APPEND steplist_copy.
  ENDLOOP.

ENDFORM. " SAVE_STEPLIST

*---------------------------------------------------------------------*
*      FORM RESTORE_OLD_STEPLIST                                  *
*---------------------------------------------------------------------*
* Stepliste, so wie sie an den Funktionsbaustein BP_STEPLIST_EDITOR   *
* übergeben wurde, restaurieren                                       *
*---------------------------------------------------------------------*

FORM restore_old_steplist.

  CLEAR steplist.
  REFRESH steplist.

  LOOP AT steplist_copy.
    steplist = steplist_copy.
    APPEND steplist.
  ENDLOOP.

ENDFORM. " RESTORE_OLD_STEPLIST

*---------------------------------------------------------------------*
*      FORM RAISE_STEP_EXCEPTION                                      *
*---------------------------------------------------------------------*
* Ausloesen einer Exception und Schreiben eines Syslogeintrages falls *
* der Funktionsbaustein BP_STEPLIST_EDITOR im Nichtdialogfall un-   *
* gueltige Stepwerte entdeckt.                                        *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM raise_step_exception USING exception data.

  DATA: step_to_verify_text(4).

*
* Kopfeintrag schreiben
*
  step_to_verify_text = step_to_verify.
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD invalid_step_detected
       ID 'DATA' FIELD step_to_verify_text.
*
* exceptionspezifischen Eintrag schreiben und Exception ausloesen
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD exception
       ID 'DATA' FIELD data.

  CASE exception.
    WHEN invalid_step_typ.
      MESSAGE e292 RAISING invalid_step_typ.
    WHEN invalid_step_status.
      MESSAGE e392 WITH data RAISING invalid_step_status.
    WHEN name_of_extpgm_missing.
      MESSAGE e405 RAISING name_of_extpgm_missing.
    WHEN target_host_name_missing.
      MESSAGE e270 RAISING target_host_name_missing.
    WHEN invalid_dialog_type.
      MESSAGE e536 RAISING invalid_dialog_type.
    WHEN invalid_step_index.
      MESSAGE e373 WITH data RAISING invalid_step_index.
    WHEN error_reading_step_values.
      MESSAGE e510 RAISING error_reading_step_values.
    WHEN invalid_opcode.
      MESSAGE e536 RAISING invalid_opcode.
    WHEN reading_print_params_failed.
      MESSAGE e368 RAISING reading_print_params_failed.
    WHEN user_name_missing.
      MESSAGE e069 RAISING user_name_missing.
    WHEN invalid_username_id.
      MESSAGE e071 WITH data RAISING invalid_user_name.
    WHEN no_user_assign_privilege_id.
      MESSAGE e102 WITH data RAISING no_user_assign_privilege.
    WHEN bad_user_type_id.
      MESSAGE e103 WITH data RAISING bad_user_type.
    WHEN cant_get_installed_languages.
      MESSAGE e273 RAISING cant_get_installed_languages.
    WHEN invalid_system_language.
      MESSAGE e274 WITH data RAISING invalid_system_language.
    WHEN name_of_extcmd_missing.
      MESSAGE e326 RAISING invalid_external_command.
    WHEN operating_system_missing.
      MESSAGE e305 RAISING invalid_external_command.
    WHEN extcmd_unknown.
      MESSAGE e327 RAISING invalid_external_command.
    WHEN extcmd_params_too_long.
      MESSAGE e328 RAISING invalid_external_command.
    WHEN extcmd_security_risk.
      MESSAGE e329 RAISING invalid_external_command.
    WHEN extcmd_wrong_check_interface.
      MESSAGE e330 RAISING invalid_external_command.
    WHEN extcmd_x_error.
      MESSAGE e331 RAISING invalid_external_command.
    WHEN extcmd_too_many_parameters.
      MESSAGE e332 RAISING invalid_external_command.
    WHEN extcmd_parameters_expected.
      MESSAGE e333 RAISING invalid_external_command.
    WHEN extcmd_illegal_command.
      MESSAGE e334 RAISING invalid_external_command.
    WHEN extcmd_communication_failure.
      MESSAGE e335 RAISING invalid_external_command.
    WHEN extcmd_system_failure.
      MESSAGE e335 RAISING invalid_external_command.

    WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb der Startterminpruefung soll ausge-
*      loest werden. Aus Verlegenheit wird INVALID_STEP_TYP ausge-
*      loest und die unbekannte Exception im Syslog vermerkt.
*
      CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
            ID 'KEY'  FIELD unknown_step_exception
            ID 'DATA' FIELD exception.
      MESSAGE e666 WITH exception RAISING invalid_step_typ.
  ENDCASE.

ENDFORM. " RAISE_STEP_EXCEPTION
