**INCLUDE LBTCHF36 .

************************************************************************
*   Hilfsroutinen der Funktionsbausteine BP_ADD_JOB_STEP und           *
*   BP_INSERT_JOB_STEP                                                 *
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  modify_job_step
*&---------------------------------------------------------------------*
* This form routine initializes some step values and returns print and *
* archive parameters.                                                  *
*----------------------------------------------------------------------*

FORM modify_job_step USING  wa_job_step
                            step STRUCTURE bpjobstep
                            allpripar STRUCTURE bapipripar
                            allarcpar STRUCTURE bapiarcpar
                            new_print_parameters STRUCTURE pri_params
                            new_arc_parameters STRUCTURE arc_params
                            pripars_failed.

  IF step-typ = btc_abap.

    IF step-authcknam EQ space OR
       step-authcknam IS INITIAL.
      step-authcknam = sy-uname.
    ENDIF.

    IF step-language EQ space OR
       step-language IS INITIAL.
      step-language = sy-langu.
    ENDIF.

    step-status = btc_scheduled.
    CLEAR step-listident.

    DATA: report_name LIKE sy-repid.
    WRITE step-program TO report_name.

    PERFORM init_print_parameters USING allpripar
                                        allarcpar
                                        step-authcknam
                                        report_name.

    CLEAR new_print_parameters.
    CLEAR new_arc_parameters.
    CLEAR pripars_failed.

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        archive_id             = allarcpar-archiv_id
        archive_info           = allarcpar-info
        archive_mode           = allpripar-armod
        archive_text           = allarcpar-arctext
        ar_object              = allarcpar-ar_object
        archive_report         = allarcpar-report
        authority              = allpripar-prber
        copies                 = allpripar-prcop
        cover_page             = allpripar-prbig
        data_set               = allpripar-prdsn
        department             = allpripar-prabt
        destination            = allpripar-pdest
        expiration             = allpripar-pexpi
        immediately            = allpripar-primm
        layout                 = allpripar-paart
        line_count             = allpripar-linct
        line_size              = allpripar-linsz
        list_name              = allpripar-plist
        list_text              = allpripar-prtxt
        mode                   = 'BATCH'
        new_list_id            = allpripar-prnew
        no_dialog              = 'X'
*        in_archive_parameters        = allarcpar
*        in_parameters                = allpripar
        report                 = report_name
        receiver               = allpripar-prrec
        release                = allpripar-prrel
        sap_cover_page         = allpripar-prsap
        host_cover_page        = allpripar-prunx
        priority               = allpripar-priot
        sap_object             = allarcpar-sap_object
        type                   = allpripar-ptype
        user                   = step-authcknam
      IMPORTING
        out_archive_parameters = new_arc_parameters
        out_parameters         = new_print_parameters
      EXCEPTIONS
        archive_info_not_found = 1
        invalid_print_params   = 2
        invalid_archive_params = 3
        OTHERS                 = 4.

    IF sy-subrc <> 0.
      pripars_failed = 'X'.
      EXIT.   " return to caller to raise exception
    ENDIF.

    MOVE-CORRESPONDING step TO wa_job_step.
    MOVE-CORRESPONDING new_arc_parameters TO wa_job_step.
    MOVE-CORRESPONDING new_print_parameters TO wa_job_step.
  ELSE.                         " no ABAP step
    MOVE-CORRESPONDING step TO wa_job_step.
  ENDIF.

ENDFORM.                    " modify_job_step
