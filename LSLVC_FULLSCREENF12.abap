*----------------------------------------------------------------------*
***INCLUDE LSLVC_FULLSCREENF12 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  salv_at_reuse_display
*&---------------------------------------------------------------------*
form salv_at_reuse_display.
  data: boolean type sap_bool.

  if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_runtime.
    data: lt_fcat type if_salv_veri_types=>g_ty_t_slis_fcat.
    data: lt_sort type if_salv_veri_types=>g_ty_t_slis_sort.
    data: lt_filt type if_salv_veri_types=>g_ty_t_slis_filt.
    field-symbols: <string> type string.

    boolean = cl_salv_veri_run=>is_point_in_time_xy(
                    x = CL_SALV_VERI_RUN=>X_REUSE_ALV_GRID_DISPLAY
                    y = CL_SALV_VERI_RUN=>Y_ALV_FULLSCREEN ).
    if boolean eq if_salv_c_bool_sap=>true.
      data: lt_ref type IF_SALV_VERI_TYPES=>G_TYPE_T_DATAREF.
      data: ls_ref type IF_SALV_VERI_TYPES=>G_TYPE_S_DATAREF.
      lt_fcat[] = it_fieldcat[].
      get reference of lt_fcat into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_SLIS_FIELDCATALOG.
      append ls_ref to lt_ref.
      lt_sort[] = it_sort[].
      get reference of lt_sort into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_SLIS_SORT.
      append ls_ref to lt_ref.
      lt_filt[] = it_filter[].
      get reference of lt_filt into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_SLIS_FILTER.
      append ls_ref to lt_ref.
      create data ls_ref-ref type string.
      assign ls_ref-ref->* to <string>.
      call transformation id source xcontent = is_layout
                                    result xml <string>.
      cl_salv_veri_run=>clean_xml( changing serial = <string> ).
      ls_ref-ref_type = if_salv_c_veri_dataref_type=>c_slis_layout.
      append ls_ref to lt_ref.
      cl_salv_veri_run=>save(
        t_ref           = lt_ref
        point_in_time_x = cl_salv_veri_run=>x_reuse_alv_grid_display
        point_in_time_y = cl_salv_veri_run=>y_alv_fullscreen ).
      set screen 0.
      leave screen.
    endif.
  endif.

endform.                    " salv_at

*&---------------------------------------------------------------------*
*&      Form  salv_at_reuse_display_lvc
*&---------------------------------------------------------------------*
form salv_at_reuse_display_lvc.
  data: boolean type sap_bool.

  if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_runtime.
    data: lt_fcat type if_salv_veri_types=>g_ty_t_lvc_fcat.
    data: lt_sort type if_salv_veri_types=>g_ty_t_lvc_sort.
    data: lt_filt type if_salv_veri_types=>g_ty_t_lvc_filt.
    field-symbols: <string> type string.

    boolean = cl_salv_veri_run=>is_point_in_time_xy(
                    x = CL_SALV_VERI_RUN=>X_REUSE_ALV_GRID_DISPLAY
                    y = CL_SALV_VERI_RUN=>Y_ALV_FULLSCREEN_LVC ).
    if boolean eq if_salv_c_bool_sap=>true.
      data: lt_ref type IF_SALV_VERI_TYPES=>G_TYPE_T_DATAREF.
      data: ls_ref type IF_SALV_VERI_TYPES=>G_TYPE_S_DATAREF.
      lt_fcat[] = it_fieldcat_lvc[].
      get reference of lt_fcat into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FIELDCATALOG.
      append ls_ref to lt_ref.
      lt_sort[] = it_sort_lvc[].
      get reference of lt_sort into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_SORT.
      append ls_ref to lt_ref.
      lt_filt[] = it_filter_lvc[].
      get reference of lt_filt into ls_ref-ref.
      ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FILTER.
      append ls_ref to lt_ref.
      create data ls_ref-ref type string.
      assign ls_ref-ref->* to <string>.
      call transformation id source xcontent = is_layout_lvc
                                    result xml <string>.
      cl_salv_veri_run=>clean_xml( changing serial = <string> ).
      ls_ref-ref_type = if_salv_c_veri_dataref_type=>c_lvc_layout.
      append ls_ref to lt_ref.
      cl_salv_veri_run=>save(
        t_ref           = lt_ref
        point_in_time_x = cl_salv_veri_run=>x_reuse_alv_grid_display
        point_in_time_y = cl_salv_veri_run=>y_alv_fullscreen_lvc ).
      set screen 0.
      leave screen.
    endif.
  endif.

endform.                    " salv_at

*&---------------------------------------------------------------------*
*&      Form  salv_at_reuse_display
*&---------------------------------------------------------------------*
form salv_at_99_2_stack.

  field-symbols: <lvc_sort> type lvc_t_sort.
  field-symbols: <lvc_fieldcatalog> type lvc_t_fcat.
  field-symbols: <lvc_filter> type lvc_t_filt.
  field-symbols: <lvc_layout> type lvc_s_layo.
  data : ls_fieldcatalog type lvc_s_fcat.
  data : ls_sort type lvc_s_sort.
  data : ls_filter type lvc_s_filt.
  data : l_data type char12.

  data: boolean type sap_bool.

  data:
    lr_data     type ref to data,
    lt_run      type if_salv_veri_types=>g_type_t_submit,
    ls_run      type if_salv_veri_types=>g_type_s_submit,
    lt_veri_key type if_salv_veri_types_db=>t_type_veri_key,
    ls_veri_key type if_salv_veri_types_db=>s_type_veri_key.

  data: lt_ref type IF_SALV_VERI_TYPES=>G_TYPE_T_DATAREF.
  data: ls_ref type IF_SALV_VERI_TYPES=>G_TYPE_S_DATAREF.

  if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_runtime.
    lt_run = cl_salv_veri_run=>get_t_run( ).
    read table lt_run into ls_run index 1.
    if sy-subrc eq 0.
      if ls_run-point_in_time_x eq CL_SALV_VERI_RUN=>X_DESIGNTIME
      and ls_run-point_in_time_x eq CL_SALV_VERI_RUN=>Y_ALV_FULLSCREEN.
        get reference of gt_grid-t_lvc_fieldcat into ls_ref-ref.
        ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FIELDCATALOG.
        append ls_ref to lt_ref.
        get reference of gt_grid-t_lvc_sort into ls_ref-ref.
        ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_SORT.
        append ls_ref to lt_ref.
        get reference of gt_grid-t_lvc_filter into ls_ref-ref.
        ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FILTER.
        append ls_ref to lt_ref.
        lt_run = cl_salv_veri_run=>get_t_run( ).
        read table lt_run into ls_run index 1.
        if sy-subrc eq 0.
          ls_run-ident1 = IF_SALV_C_VERI_DATAREF_TYPE=>c_selset.
          loop at lt_ref into ls_ref.
            call method cl_salv_veri_db=>save
              exporting
                name              = ls_run-name
                point_in_time_x   = ls_run-point_in_time_x
                point_in_time_y   = ls_run-point_in_time_y
                veri_type         = if_salv_c_veri_type=>c_master_data
                IDENT1            = ls_run-ident1
                IDENT2            = ls_run-ident2
                ref_type          = ls_ref-ref_type
              changing
                ref               = ls_ref-ref.
          endloop.
        endif.
      endif.
    endif.
    if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_runtime.
* select items
      lt_run = cl_salv_veri_run=>get_t_run( ).
      read table lt_run into ls_run index 1.
      if sy-subrc eq 0.
        split ls_run-name at '-' into ls_run-name l_data.
        ls_veri_key-veri_type = if_salv_c_veri_type=>c_master_data.
        ls_veri_key-name      = ls_run-name.
        ls_run-ident1 = IF_SALV_C_VERI_DATAREF_TYPE=>c_selset.
        ls_veri_key-id1       = ls_run-ident1.
        ls_veri_key-id2       = ls_run-ident2.
        ls_veri_key-id3       = cl_salv_veri_run=>X_designtime.
        ls_veri_key-id4       = cl_salv_veri_run=>Y_ALV_FULLSCREEN.
        clear ls_veri_key-data_type.
        try.
          call method cl_salv_veri_db=>read_veri_key
            exporting
              veri_type = ls_veri_key-veri_type
              name      = ls_veri_key-name
              id1       = ls_veri_key-id1
              id2       = ls_veri_key-id2
              id3       = ls_veri_key-id3
              id4       = ls_veri_key-id4
              data_type = ls_veri_key-data_type
            receiving
              value     = lt_veri_key.
          catch cx_salv_not_found.
        endtry.
      endif.
      loop at lt_veri_key into ls_veri_key.
        clear lr_data.
        ls_run-name  = ls_veri_key-name.
        ls_run-ident1 = ls_veri_key-id1.
        ls_run-ident2 = ls_veri_key-id2.
        ls_run-point_in_time_x = ls_veri_key-id3.
        ls_run-point_in_time_y = ls_veri_key-id4.
        ls_run-ref_type = ls_veri_key-data_type.
        ls_run-veri_type = ls_veri_key-veri_type.
        try.
          cl_salv_veri_db=>read(
            exporting
              name            = ls_run-name  "actual name
              point_in_time_x = ls_run-point_in_time_x
              point_in_time_y = ls_run-point_in_time_y
              veri_type       = ls_run-veri_type
              ident1          = ls_run-ident1
              ident2          = ls_run-ident2
              ref_type        = ls_run-ref_type
            changing
              ref             = lr_data ).
          catch cx_salv_msg.
          catch cx_salv_not_found.
        endtry.
        case ls_run-ref_type.
          when IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FIELDCATALOG.
            assign lr_data->* to <lvc_fieldcatalog>.
            refresh gt_grid-t_lvc_fieldcat[].
            loop at <lvc_fieldcatalog> into ls_fieldcatalog.
              append ls_fieldcatalog to gt_grid-t_lvc_fieldcat.
            endloop.
          when IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_SORT.
            assign lr_data->* to <lvc_sort>.
            refresh gt_grid-t_lvc_sort[].
            loop at <lvc_sort> into ls_sort.
              append ls_sort to gt_grid-t_lvc_sort.
            endloop.
          when IF_SALV_C_VERI_DATAREF_TYPE=>C_LVC_FILTER.
            assign lr_data->* to <lvc_filter>.
            refresh gt_grid-t_lvc_filter[].
            loop at <lvc_filter> into ls_filter.
              append ls_filter to gt_grid-t_lvc_filter.
            endloop.
          when if_sALV_C_VERI_DATAREF_TYPE=>C_LVC_LAYOUT.
            assign lr_data->* to <lvc_layout>.
            clear gt_grid-s_lvc_layout.
            move-corresponding <lvc_layout> to gt_grid-s_lvc_layout.
        endcase.
      endloop.
    endif.
  endif.

endform.                    " salv_at
*&---------------------------------------------------------------------*
*&      Form  salv_at_reuse_display
*&---------------------------------------------------------------------*
form salv_at_functions using r_pfstatus type sypfkey
                             r_report   type syrepid
                             rt_extab type kkblo_t_extab.  "#EC CALLED

  data: ls_status type if_salv_veri_types=>g_type_s_status.
  data: boolean type sap_bool.

  if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_runtime
  or cl_salv_veri_run=>on eq cl_salv_veri_run=>c_abapunit.
    boolean = cl_salv_veri_run=>is_point_in_time_xy(
                    x = CL_SALV_VERI_RUN=>X_functions
                    y = CL_SALV_VERI_RUN=>Y_ALV_FULLSCREEN ).
    if boolean eq if_salv_c_bool_sap=>true.
      call function 'RS_CUA_GET_STATUS_FUNCTIONS'
        exporting
          program           = r_report
          status            = r_pfstatus
        tables
          function_list     = ls_status-status[]
        exceptions
          menu_not_found    = 1
          program_not_found = 2
          status_not_found  = 3
          others            = 4.

      if sy-subrc eq 0.
        ls_status-name     = r_pfstatus.
        ls_status-report   = r_report.
        ls_status-extab[]  = rt_extab[].
        if cl_salv_veri_run=>on eq cl_salv_veri_run=>c_abapunit.
          cl_salv_caller_services=>s_status = ls_status.
        else.
          data: lt_ref type IF_SALV_VERI_TYPES=>G_TYPE_T_DATAREF.
          data: ls_ref type IF_SALV_VERI_TYPES=>G_TYPE_S_DATAREF.

          get reference of ls_status into ls_ref-ref.
          ls_ref-ref_type = IF_SALV_C_VERI_DATAREF_TYPE=>C_PFSTATUS.
          append ls_ref to lt_ref.
          cl_salv_veri_run=>save(
            t_ref           = lt_ref
            point_in_time_x = cl_salv_veri_run=>x_functions
            point_in_time_y = cl_salv_veri_run=>y_alv_fullscreen ).
        endif.
      endif.
      set screen 0.
      leave screen.
    endif.
  endif.

endform.                    " salv_at
