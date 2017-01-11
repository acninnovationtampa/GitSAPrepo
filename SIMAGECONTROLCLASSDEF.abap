*----------------------------------------------------------------------*
*   INCLUDE SIMAGECONTROLCLASSDEF                                      *
*----------------------------------------------------------------------*

INCLUDE %3CCTLDEF%3E.                      " useful constants

************************************************************************
* Constans for property display_mode
************************************************************************
CONSTANTS: DISPLAY_MODE_NORMAL            TYPE I VALUE 0.
CONSTANTS: DISPLAY_MODE_STRETCH           TYPE I VALUE 1.
CONSTANTS: DISPLAY_MODE_FIT               TYPE I VALUE 2.
CONSTANTS: DISPLAY_MODE_NORMAL_CENTER     TYPE I VALUE 3.
CONSTANTS: DISPLAY_MODE_FIT_CENTER        TYPE I VALUE 4.

************************************************************************
* CLASS    c_image_control
* DEFINITION
************************************************************************
class c_image_control definition.
  public section.

* Methods needed in every activeX control. These methods should be
* placed in a base class for axtiveX controls when inheritance is
* available.
* START_OF_BASE_CLASS_METHODS

* Control creation / destruction
    methods create_control
            importing dynnr like sy-dynnr
                      REPID LIKE SY-REPID
                      STYLE TYPE I OPTIONAL
                      CONTAINER TYPE C OPTIONAL.

    methods destroy_control.

* Control positioning / standard properties
    methods set_window_property
            importing propid type i
                      value type i.
    methods get_window_property
            importing propid type i
            RETURNING VALUE(VALUE) TYPE I.

* Getting or setting th control handle for low level access
    METHODS GET_HANDLE
            RETURNING VALUE(HANDLE) TYPE CNTL_HANDLE.
    METHODS SET_HANDLE
            IMPORTING HANDLE TYPE CNTL_HANDLE.

* General event registration
    methods register_event importing evt_id type i.

* Event raising method. Called by callback form (on_control_event)
* This method should never be called by the user of the class.
* Due to design restrictions this method has to be public nevertheless.
* This method must be made available to the OO control framework.
* This may be done by defining a base class and passing a reference to
* the object to the framework. Another possible way is to define an
* interface with the raise_event method and pass a reference to that
* interface to the framework
    methods raise_event
            importing evt_eventid type i.

* END_OF_BASE_CLASS_METHODS


* Control methods / properties
    methods load_image_from_url
            importing url type c
            RETURNING VALUE(BOOL_RESULT_VALUE_0_OR_1) TYPE I.

    METHODS CLEAR_IMAGE.

    methods set_display_mode
            importing display_mode type i.
    methods get_display_mode
            RETURNING VALUE(DISPLAY_MODE) TYPE I.

* Event registration
    methods register_event_click.
    methods register_event_dblclick.
    methods register_event_context_menu.
    METHODS REGISTER_EVENT_IMAGE_CLICK.
    METHODS REGISTER_EVENT_IMAGE_DBLCLICK.

* ABAP events
    events click.
    events dblclick.
    events context_menu
           exporting value(mouse_pos_x) type i
                     value(mouse_pos_y) type i.
    EVENTS IMAGE_CLICK
           exporting value(mouse_pos_x) type i
                     value(mouse_pos_y) type i.
    EVENTS IMAGE_DBLCLICK
           exporting value(mouse_pos_x) type i
                     value(mouse_pos_y) type i.

* Protected data
  protected section.
* This data is protected, because it should be defined in a base class
* for activeX controls.
* The m_prog_id member is needed to provide an generic creation
* method that is implemented in the base class. The m_prog_id must
* be filled in the constructor (or 'INIT' method) of the derived class.
* Then the create_control method of the base class can create a control
* using the m_prog_id member.
    data m_h_control    type cntl_handle.
    data m_prog_id(255) type c.
endclass.
