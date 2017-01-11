FUNCTION REUSE_ALV_VARIANT_SELECT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DIALOG) DEFAULT 'X'
*"     VALUE(I_USER_SPECIFIC) DEFAULT ' '
*"     VALUE(I_DEFAULT) DEFAULT 'X'
*"     VALUE(I_TABNAME_HEADER) TYPE  SLIS_TABNAME OPTIONAL
*"     VALUE(I_TABNAME_ITEM) TYPE  SLIS_TABNAME OPTIONAL
*"     VALUE(IT_DEFAULT_FIELDCAT) TYPE  SLIS_T_FIELDCAT_ALV
*"     VALUE(I_LAYOUT) TYPE  SLIS_LAYOUT_ALV
*"     VALUE(I_BYPASSING_BUFFER) TYPE  CHAR01 OPTIONAL
*"     VALUE(I_BUFFER_ACTIVE) OPTIONAL
*"  EXPORTING
*"     VALUE(E_EXIT)
*"     VALUE(ET_FIELDCAT) TYPE  SLIS_T_FIELDCAT_ALV
*"     VALUE(ET_SORT) TYPE  SLIS_T_SORTINFO_ALV
*"     VALUE(ET_FILTER) TYPE  SLIS_T_FILTER_ALV
*"     VALUE(ES_LAYOUT) TYPE  SLIS_LAYOUT_ALV
*"  CHANGING
*"     VALUE(CS_VARIANT) LIKE  DISVARIANT STRUCTURE  DISVARIANT
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      FC_NOT_COMPLETE
*"      NOT_FOUND
*"      PROGRAM_ERROR
*"----------------------------------------------------------------------
  DATA: LS_LAYOUT_LIT   TYPE KKBLO_LAYOUT.
  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
  DATA: LT_DEFAULT_FIELDCAT_LIT TYPE KKBLO_T_FIELDCAT.
  DATA: LT_FIELDCAT_LIT TYPE KKBLO_T_FIELDCAT.
  DATA: LT_SORTINFO_LIT TYPE KKBLO_T_SORTINFO.
  DATA: LT_FILTER_LIT TYPE KKBLO_T_FILTER.
  DATA: L_TABNAME_HEADER TYPE KKBLO_TABNAME.
  data: ls_ltdxkey type ltdxkey.

  data:
        l_import type char01,
        l_export type char01,
        l_delete type char01,
        l_buffer_active type char01.

  l_buffer_active = i_buffer_active.
  call function 'ALV_CHECK_BUFFER'
       exporting
            i_buffer_type      = 'A'
            i_buffer_active    = l_buffer_active
            i_bypassing_buffer = i_bypassing_buffer
            i_refresh_buffer   = ' '
       importing
            e_import           = l_import
            e_export           = l_export
            e_delete           = l_delete.

*
* Falls Tabname in Fieldcat vorgegeben, nimm diesen, sonst '1' und nur
* bei einfachen Listen und wenn tabname_header initial.
  IF I_TABNAME_ITEM IS INITIAL.
    IF I_TABNAME_HEADER IS INITIAL.
      L_TABNAME_HEADER = GC_TABNAME.
      LOOP AT IT_DEFAULT_FIELDCAT INTO LS_FIELDCAT
                                           WHERE NOT TABNAME IS INITIAL.
        L_TABNAME_HEADER = LS_FIELDCAT-TABNAME.
        EXIT.
      ENDLOOP.
    ELSE.
      L_TABNAME_HEADER = I_TABNAME_HEADER.
    ENDIF.
  ELSE.
    L_TABNAME_HEADER = I_TABNAME_HEADER.
  ENDIF.

  move-corresponding cs_variant to ls_ltdxkey.
  if not l_delete is initial.
    call function 'ALV_DELETE_BUFFER'
         exporting
              is_ltdxkey = ls_ltdxkey
              i_type     = 'S'
              i_langu    = sy-langu
         exceptions
              no_delete  = 0
              not_found  = 0
              others     = 0.
  endif.

*  if i_buffer_active = 'X' and
  if ( ( not l_import is initial ) and
     ( not cs_variant-variant is initial ) and
     ( i_dialog is initial or i_dialog = 'N' ) ).
    call function 'ALV_IMPORT_FROM_BUFFER_SLIS'
         exporting
              is_ltdxkey            = ls_ltdxkey
*             I_LANGU               = SY-LANGU
         IMPORTING
              ET_FIELDCAT_SLIS      = et_fieldcat
*             E_FIELDCAT_SLIS_STATE =
              ET_SORT_SLIS          = et_sort
*             E_SORT_SLIS_STATE     =
              ET_FILTER_SLIS        = et_filter
              ES_LAYOUT_SLIS        = es_layout
         EXCEPTIONS
              NO_IMPORT             = 1
              OTHERS                = 2
              .
    if sy-subrc =  0.
      exit.
    endif.

  endif.
  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
       EXPORTING
            IT_FIELDCAT = IT_DEFAULT_FIELDCAT
            IS_LAYOUT   = I_LAYOUT
       IMPORTING
            ES_LAYOUT   = LS_LAYOUT_LIT
            ET_FIELDCAT = LT_DEFAULT_FIELDCAT_LIT.
*
  CALL FUNCTION 'LT_VARIANT_LOAD'
       EXPORTING
*           I_TOOL              = 'LT'
            I_TABNAME           = L_TABNAME_HEADER
            I_TABNAME_SLAVE     = I_TABNAME_ITEM
            I_DIALOG            = I_DIALOG
            I_USER_SPECIFIC     = I_USER_SPECIFIC
            I_DEFAULT           = I_DEFAULT
       IMPORTING
            E_EXIT              = E_EXIT
            ET_FIELDCAT         = LT_FIELDCAT_LIT
            ET_SORT             = LT_SORTINFO_LIT
            ET_FILTER           = LT_FILTER_LIT
       CHANGING
            CS_LAYOUT           = LS_LAYOUT_LIT
            CT_DEFAULT_FIELDCAT = LT_DEFAULT_FIELDCAT_LIT
            CS_VARIANT          = CS_VARIANT
       EXCEPTIONS
            WRONG_INPUT         = 1
            FC_NOT_COMPLETE     = 2
            NOT_FOUND           = 3
            OTHERS              = 4.
  CASE SY-SUBRC.
    WHEN 0.
      CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA_BACK'
           EXPORTING
                IT_FIELDCAT = LT_FIELDCAT_LIT
                IT_SORT     = LT_SORTINFO_LIT
                IT_FILTER   = LT_FILTER_LIT
                IS_LAYOUT   = LS_LAYOUT_LIT
           IMPORTING
                ES_LAYOUT   = ES_LAYOUT
                ET_FIELDCAT = ET_FIELDCAT
                ET_SORT     = ET_SORT
                ET_FILTER   = ET_FILTER.

*      if i_buffer_active = 'X'.
      if not l_export is initial.
        call function 'ALV_EXPORT_TO_BUFFER_SLIS'
             exporting
                  is_ltdxkey            = ls_ltdxkey
*                 I_LANGU               = SY-LANGU
                  it_fieldcat_slis      = et_fieldcat
*                 I_FIELDCAT_SLIS_STATE =
                  IT_SORT_SLIS          = et_sort
*                 I_SORT_SLIS_STATE     =
                  IT_FILTER_SLIS        = et_filter
                  IS_LAYOUT_SLIS        = es_layout
             EXCEPTIONS
                  NO_KEY                = 0
                  NO_EXPORT             = 0
                  OTHERS                = 0.
*        if sy-subrc ne 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        endif.
      endif.
    WHEN 1.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      RAISING WRONG_INPUT.
    WHEN 2.
      RAISE FC_NOT_COMPLETE.
    WHEN 3.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      RAISING NOT_FOUND.
    WHEN OTHERS.
      MESSAGE E534(0K) RAISING PROGRAM_ERROR.
  ENDCASE.
ENDFUNCTION.
