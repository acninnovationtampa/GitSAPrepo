*----------------------------------------------------------------------*
***INCLUDE LBTCHF24 .
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*  FORM apply_print_parameters_mask
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_PRINT_PARAMETERS
*  -->  P_PRINT_MASK
*  -->  P_PRINT_PARAMETERS2
*---------------------------------------------------------------------*
FORM apply_print_parameters_mask
  USING
   p_print_parameters TYPE pri_params
   p_print_mask TYPE ppr_mask
  CHANGING
   p_print_parameters2 TYPE pri_params.

  IF NOT p_print_mask IS INITIAL.
    IF p_print_mask-pdest IS INITIAL.
      p_print_parameters2-pdest = p_print_parameters-pdest.
    ENDIF.
    IF p_print_mask-prcop IS INITIAL.
      p_print_parameters2-prcop = p_print_parameters-prcop.
    ENDIF.
    IF p_print_mask-plist IS INITIAL.
      p_print_parameters2-plist = p_print_parameters-plist.
    ENDIF.
    IF p_print_mask-prtxt IS INITIAL.
      p_print_parameters2-prtxt = p_print_parameters-prtxt.
    ENDIF.
    IF p_print_mask-primm IS INITIAL.
      p_print_parameters2-primm = p_print_parameters-primm.
    ENDIF.
    IF p_print_mask-prrel IS INITIAL.
      p_print_parameters2-prrel = p_print_parameters-prrel.
    ENDIF.
    IF p_print_mask-prnew IS INITIAL.
      p_print_parameters2-prnew = p_print_parameters-prnew.
    ENDIF.
    IF p_print_mask-pexpi IS INITIAL.
      p_print_parameters2-pexpi = p_print_parameters-pexpi.
    ENDIF.
    IF p_print_mask-linct IS INITIAL.
      p_print_parameters2-linct = p_print_parameters-linct.
    ENDIF.
    IF p_print_mask-linsz IS INITIAL.
      p_print_parameters2-linsz = p_print_parameters-linsz.
    ENDIF.
    IF p_print_mask-paart IS INITIAL.
      p_print_parameters2-paart = p_print_parameters-paart.
    ENDIF.
    IF p_print_mask-prbig IS INITIAL.
      p_print_parameters2-prbig = p_print_parameters-prbig.
    ENDIF.
    IF p_print_mask-prsap IS INITIAL.
      p_print_parameters2-prsap = p_print_parameters-prsap.
    ENDIF.
    IF p_print_mask-prrec IS INITIAL.
      p_print_parameters2-prrec = p_print_parameters-prrec.
    ENDIF.
    IF p_print_mask-prabt IS INITIAL.
      p_print_parameters2-prabt = p_print_parameters-prabt.
    ENDIF.
    IF p_print_mask-prber IS INITIAL.
      p_print_parameters2-prber = p_print_parameters-prber.
    ENDIF.
    IF p_print_mask-prdsn IS INITIAL.
      p_print_parameters2-prdsn = p_print_parameters-prdsn.
    ENDIF.
    IF p_print_mask-ptype IS INITIAL.
      p_print_parameters2-ptype = p_print_parameters-ptype.
    ENDIF.
    IF p_print_mask-armod IS INITIAL.
      p_print_parameters2-armod = p_print_parameters-armod.
    ENDIF.
    IF p_print_mask-footl IS INITIAL.
      p_print_parameters2-footl = p_print_parameters-footl.
    ENDIF.
    IF p_print_mask-priot IS INITIAL.
      p_print_parameters2-priot = p_print_parameters-priot.
    ENDIF.
    IF p_print_mask-prunx IS INITIAL.
      p_print_parameters2-prunx = p_print_parameters-prunx.
    ENDIF.
  ENDIF.

ENDFORM.                    "apply_print_parameters_mask
*&---------------------------------------------------------------------*
*&      Form  checkarchiveparametersmask
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_archive_parameters  text
*      -->p_archive_mask  text
*      <--P_ARCHIVE_PARAMETERS2  text
*----------------------------------------------------------------------*
FORM apply_archive_parameters_mask
  USING
    p_archive_parameters TYPE arc_params
    p_archive_mask TYPE apr_mask
  CHANGING
    p_archive_parameters2 TYPE arc_params.

  IF NOT p_archive_mask IS INITIAL.
    IF p_archive_mask-sap_object IS INITIAL.
      p_archive_parameters2-sap_object =
      p_archive_parameters-sap_object.
    ENDIF.
    IF p_archive_mask-ar_object IS INITIAL.
      p_archive_parameters2-ar_object =
      p_archive_parameters-ar_object.
    ENDIF.
    IF p_archive_mask-archiv_id IS INITIAL.
      p_archive_parameters2-archiv_id =
      p_archive_parameters-archiv_id.
    ENDIF.
    IF p_archive_mask-doc_type IS INITIAL.
      p_archive_parameters2-doc_type =
      p_archive_parameters-doc_type.
    ENDIF.
    IF p_archive_mask-rpc_host IS INITIAL.
      p_archive_parameters2-rpc_host =
      p_archive_parameters-rpc_host.
    ENDIF.
    IF p_archive_mask-rpc_servic IS INITIAL.
      p_archive_parameters2-rpc_servic =
      p_archive_parameters-rpc_servic.
    ENDIF.
    IF p_archive_mask-interface IS INITIAL.
      p_archive_parameters2-interface =
      p_archive_parameters-interface.
    ENDIF.
    IF p_archive_mask-mandant IS INITIAL.
      p_archive_parameters2-mandant = p_archive_parameters-mandant.
    ENDIF.
    IF p_archive_mask-report IS INITIAL.
      p_archive_parameters2-report = p_archive_parameters-report.
    ENDIF.
    IF p_archive_mask-info IS INITIAL.
      p_archive_parameters2-info = p_archive_parameters-info.
    ENDIF.
    IF p_archive_mask-arctext IS INITIAL.
      p_archive_parameters2-arctext = p_archive_parameters-arctext.
    ENDIF.
    IF p_archive_mask-datum IS INITIAL.
      p_archive_parameters2-datum = p_archive_parameters-datum.
    ENDIF.
    IF p_archive_mask-arcuser IS INITIAL.
      p_archive_parameters2-arcuser = p_archive_parameters-arcuser.
    ENDIF.
    IF p_archive_mask-printer IS INITIAL.
      p_archive_parameters2-printer = p_archive_parameters-printer.
    ENDIF.
    IF p_archive_mask-formular IS INITIAL.
      p_archive_parameters2-formular =
      p_archive_parameters-formular.
    ENDIF.
    IF p_archive_mask-archivpath IS INITIAL.
      p_archive_parameters2-archivpath =
      p_archive_parameters-archivpath.
    ENDIF.
    IF p_archive_mask-protokoll IS INITIAL.
      p_archive_parameters2-protokoll =
      p_archive_parameters-protokoll.
    ENDIF.
    IF p_archive_mask-version IS INITIAL.
      p_archive_parameters2-version = p_archive_parameters-version.
    ENDIF.
  ENDIF.

ENDFORM.                    "apply_archive_parameters_maskask2
