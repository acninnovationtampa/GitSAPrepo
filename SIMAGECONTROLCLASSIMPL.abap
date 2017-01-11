*----------------------------------------------------------------------*
*   INCLUDE SIMAGECONTROLCLASSIMPL                                     *
*----------------------------------------------------------------------*
TYPE-POOLS CNDP.
TYPE-POOLS SFES.                       "h.h

************************************************************************
* EVENT MAP TABLE
* This table is used to map an event of an activeX control to
* the object. The object can then raise an ABAP event.
* When an Object of the class C_IMAGE_CONTROL is created
* (CREATE_CONTROL) a row is inserted. If the object is deleted
* (DELETE_CONTROL) the row is removed.
* If an event occurs the SHELLID of the control is used for the
* search in the table. If an entry is found, the CONTROL_REF in the
* row is used to call a method which raises the event in the object.
************************************************************************
types: begin of ole_control_map,
             shell_id type cntl_handle-shellid,
             control_ref type ref to c_image_control,
       end of ole_control_map.
data ole_control_map_table type table of ole_control_map.
data ole_control_map_wa type ole_control_map.

************************************************************************
* CALLBACK on_control_event
************************************************************************
* Callback form for all of the registered events.
callback on_control_event.
* This callback is called inside the 'CONTROL_DISPATCH' function.
* In the control_map_table it is searched the control with the
* shell-id that is passed to the callback.
* If the control is found, the method raise_event of the control
* is called.
loop at ole_control_map_table into ole_control_map_wa.
  if evt_shellid = ole_control_map_wa-shell_id.
    call method ole_control_map_wa-control_ref->raise_event
         exporting evt_eventid = evt_eventid.
  endif.
endloop.
endcallback.


************************************************************************
* CLASS   c_image_control
* IMPLEMENTATION
************************************************************************
CLASS C_image_control implementation.

************************************************************************
* CLASS   c_image_control
* METHOD  set_window_property
************************************************************************
  method set_window_property.
*        importing propid type i
*                  value type i.

    call function 'CONTROL_SET_WINDOW_PROPERTY'
      EXPORTING H_CONTROL = M_H_CONTROL
                propid    = propid
                VALUE     = VALUE
      EXCEPTIONS OTHERS = 0.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  get_window_property
************************************************************************
  method get_window_property.
*        importing propid type i
*        returning value type i.

    call function 'CONTROL_GET_WINDOW_PROPERTY'
      EXPORTING H_CONTROL = M_H_CONTROL
                propid    = propid
      IMPORTING RETURN     = VALUE
      EXCEPTIONS OTHERS = 0.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  create_control
************************************************************************
  method create_control.
*        importing dynnr like sy-dynnr
*                  repid like sy-repid
*                  style TYPE i OPTIONAL
*                  container TYPE c OPTIONAL.

    DATA: RETURN,
          GUITYPE TYPE I.

    GUITYPE = 0.
    CALL FUNCTION 'GUI_HAS_OBJECTS'
         EXPORTING
              OBJECT_MODEL = SFES_OBJ_ACTIVEX
         IMPORTING
              RETURN       = RETURN
         EXCEPTIONS
              OTHERS       = 0.
    IF RETURN = 'X'.
      GUITYPE = 1.
    ENDIF.
    IF GUITYPE = 0.
      CALL FUNCTION 'GUI_HAS_OBJECTS'
           EXPORTING
                OBJECT_MODEL = SFES_OBJ_JAVABEANS
           IMPORTING
                RETURN       = RETURN
           EXCEPTIONS
                OTHERS       = 0.
      IF RETURN = 'X'.
        GUITYPE = 2.
      ENDIF.
    ENDIF.

* Fill the m_prog_id member. If a base class exsits the member should be
* filled in the constructor or in an 'INIT' method. The create_control
* method then uses this member to create the control.
* See 'call function 'CONTROL_CREATE'' below.

    CASE GUITYPE.
      WHEN 1.
        M_PROG_ID = 'SAPGUI.ImageCtrl.1'.
      WHEN 2.
        M_PROG_ID = 'com.sap.components.controls.sapImage.SapImage'.
    ENDCASE.

* Initialize the control framework. The case that this function is
* called multiple times (when more than one control is created) is
* handled inside the function.
    CALL FUNCTION 'CONTROL_INIT'
         EXCEPTIONS
              OTHERS = 0.

* Set the window styles of the control.
* For more information on the styles see WIN32 SDK
    DATA STYLE_LOCAL TYPE I.
    STYLE_LOCAL = STYLE + WS_VISIBLE + WS_CHILD.

* Create the control
    call function 'CONTROL_CREATE'
         exporting owner_repid   = repid
                   CLSID         = M_PROG_ID
                   SHELLSTYLE    = STYLE_LOCAL
                   PARENTID      = DYNPRO_DEFAULT
                   version_check = 'X'
                   try           = 'X'
         CHANGING  H_CONTROL = M_H_CONTROL
         EXCEPTIONS OTHERS = 0.

* Attach the control to the screen
    call function 'CONTROL_LINK'
         EXPORTING H_CONTROL = M_H_CONTROL
                   repid     = repid
                   dynnr     = dynnr
                   CONTAINER = CONTAINER.

    ole_control_map_wa-shell_id = m_h_control-shellid.
    ole_control_map_wa-control_ref = me.
    append ole_control_map_wa to ole_control_map_table.

  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  destroy_control
************************************************************************
  method destroy_control.
* Delete control from EVENT MAP TABLE
    loop at ole_control_map_table into ole_control_map_wa.
      if m_h_control-shellid = ole_control_map_wa-shell_id.
        delete ole_control_map_table index sy-tabix.
        exit.
      endif.
    endloop.

* Delete activeX control
    call function 'CONTROL_DESTROY'
         CHANGING H_CONTROL = M_H_CONTROL
      EXCEPTIONS OTHERS = 0.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  load_image_from_url
************************************************************************
  METHOD LOAD_IMAGE_FROM_URL.
*        importing url type c
*        returning bool_result_value_0_or_1 type c.

    CALL FUNCTION 'CONTROL_CALL_METHOD'
         EXPORTING
              H_CONTROL = M_H_CONTROL
              METHOD    = 'loadImageFromURL'
              P_COUNT   = 1
              P1        = URL
         IMPORTING
              RETURN    = BOOL_RESULT_VALUE_0_OR_1
         EXCEPTIONS
              OTHERS    = 0.

  ENDMETHOD.

************************************************************************
* CLASS   c_image_control
* METHOD  clear_image
************************************************************************
  METHOD CLEAR_IMAGE.

    CALL FUNCTION 'CONTROL_CALL_METHOD'
         EXPORTING
              H_CONTROL = M_H_CONTROL
              METHOD    = 'clearImage'
              P_COUNT   = 0
         EXCEPTIONS
              OTHERS    = 0.

  ENDMETHOD.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event
************************************************************************
  method register_event.
*        importing evt_id type i.

* Register the callback form.
* The given data (event-id, form, h_control) is inserted into
* into an internal table. If an event occurs the table is used
* in the function 'CONTROL_DISPATCH' the determine which callback form
* is called.
    call function 'CONTROL_REGISTER_EVT_CB'
         exporting event = evt_id
                   callback_form = 'ON_CONTROL_EVENT'
         CHANGING  H_CONTROL = M_H_CONTROL
      EXCEPTIONS OTHERS = 0.

* Tell the framework to send the event to the backend. Without
* this call the previous call would be useless, because the event
* would not reach the backend
    call function 'CONTROL_REGISTER_EVENT'
         EXPORTING H_CONTROL = M_H_CONTROL
                   EVENT     = EVT_ID
      EXCEPTIONS OTHERS = 0.

  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event_click
************************************************************************
  method register_event_click.
    call method register_event exporting evt_id = event_click.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event_dblclick
************************************************************************
  method register_event_dblclick.
    CALL METHOD REGISTER_EVENT EXPORTING EVT_ID = EVENT_DOUBLE_CLICK.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event_context_menu
************************************************************************
  method register_event_context_menu.
    call method register_event exporting evt_id = 1.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event_image_click
************************************************************************
  METHOD REGISTER_EVENT_IMAGE_CLICK.
    CALL METHOD REGISTER_EVENT EXPORTING EVT_ID = 2.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  register_event_image_dblclick
************************************************************************
  METHOD REGISTER_EVENT_IMAGE_DBLCLICK.
    CALL METHOD REGISTER_EVENT EXPORTING EVT_ID = 3.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  set_display_mode
************************************************************************
  method set_display_mode.
*        importing display_mode type i.

    call function 'CONTROL_SET_PROPERTY'
      EXPORTING H_CONTROL = M_H_CONTROL
                PROPERTY = 'displayMode'
                VALUE = DISPLAY_MODE
      EXCEPTIONS OTHERS = 0.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  get_display_mode
************************************************************************
  method get_display_mode.
*        returning display_mode type i.

    call function 'CONTROL_GET_PROPERTY'
      EXPORTING H_CONTROL = M_H_CONTROL
                PROPERTY = 'displayMode'
      CHANGING RETURN = DISPLAY_MODE
      EXCEPTIONS OTHERS = 0.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  raise_event
************************************************************************
  method raise_event.
*        importing evt_eventid type i.

    DATA MOUSE_POS_X TYPE I.
    DATA MOUSE_POS_Y TYPE I.

    case evt_eventid.
      when event_click.
        raise event click.

      when EVENT_DOUBLE_CLICK.
        raise event dblclick.

      when 1.
* Get the parameters of the event
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 0
             CHANGING  RETURN = MOUSE_POS_X
      EXCEPTIONS OTHERS = 0.
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 1
             CHANGING  RETURN = MOUSE_POS_Y
      EXCEPTIONS OTHERS = 0.
* Raise the ABAP event
        raise event context_menu
                    exporting mouse_pos_x = mouse_pos_x
                              mouse_pos_y = mouse_pos_y.

      WHEN 2.
* Get the parameters of the event
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 0
             CHANGING  RETURN = MOUSE_POS_X
                   EXCEPTIONS OTHERS = 0.
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 1
             CHANGING  RETURN = MOUSE_POS_Y
                   EXCEPTIONS OTHERS = 0.
* Raise the ABAP event
        RAISE EVENT IMAGE_CLICK
                    exporting mouse_pos_x = mouse_pos_x
                              mouse_pos_y = mouse_pos_y.

      WHEN 3.
* Get the parameters of the event
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 0
             CHANGING  RETURN = MOUSE_POS_X
                   EXCEPTIONS OTHERS = 0.
        call function 'CONTROL_GET_EVENT_PARAM'
             EXPORTING H_CONTROL         = M_H_CONTROL
                       param_id          = 1
             CHANGING  RETURN = MOUSE_POS_Y
                   EXCEPTIONS OTHERS = 0.
* Raise the ABAP event
        RAISE EVENT IMAGE_DBLCLICK
                    exporting mouse_pos_x = mouse_pos_x
                              mouse_pos_y = mouse_pos_y.

    endcase.
  endmethod.

************************************************************************
* CLASS   c_image_control
* METHOD  get_handle
************************************************************************
  METHOD GET_HANDLE.
*        returning handle type cntl_handle.
    HANDLE = M_H_CONTROL.
  ENDMETHOD.

************************************************************************
* CLASS   c_image_control
* METHOD  set_handle
************************************************************************
  METHOD SET_HANDLE.
*        importing handle type cntl_handle.
    M_H_CONTROL = HANDLE.
  ENDMETHOD.

endclass.
