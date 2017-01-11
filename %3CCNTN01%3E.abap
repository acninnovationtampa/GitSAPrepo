************************************************************************
* BITTE NEUES INCLUDE CNTN01_SWC benutzen!!!
************************************************************************
* Dieses Include führt bei der Nutzung innerhalb eines CLASS-POOLS zu
* einer Vielzahl von Warnungen. Um dieses zu vermeiden, bitte das oben
* genannte Include in den lokalen Implementierungsteil einer gloabeln
* Klasse inkludieren.
************************************************************************

*************************** Macros *************************************
* Types
TYPES:
  swc_object LIKE obj_record.

* DATA Container
DEFINE swc_container.
data begin of &1 occurs 0.
  include structure swcont.
data end of &1.
END-OF-DEFINITION.

*************************** Data Declaration ***************************
DATA BEGIN OF swo_%return.
  INCLUDE STRUCTURE swotreturn.
DATA END OF swo_%return.
DATA swo_%objid LIKE swotobjid.
DATA swo_%verb LIKE swotlv-verb.
swc_container swo_%container.

************************* Error Handling   *****************************
* set system error codes from structure SWOTRETURN
* P1    Returncode of structure SWOTRETURN
DEFINE swc_%sys_error_set.
  if &1-code ne 0.
    sy-msgid = &1-workarea.
    sy-msgno = &1-message.
    sy-msgty = 'E'.
    sy-msgv1 = &1-variable1.
    sy-msgv2 = &1-variable2.
    sy-msgv3 = &1-variable3.
    sy-msgv4 = &1-variable4.
  endif.
  sy-subrc = &1-code.
END-OF-DEFINITION.

************************* Container Macros *****************************
*** for documentation see Online Documentation: Workflow Container
* Create Container
DEFINE swc_create_container.
  clear &1.
  refresh &1.
END-OF-DEFINITION.

* Release Container
DEFINE swc_release_container.
  clear &1.
  refresh &1.
END-OF-DEFINITION.

* Clear Container
DEFINE swc_clear_container.
  refresh &1.
  clear &1.
END-OF-DEFINITION.

* Container Create Element
DEFINE swc_create_element.
  call function 'SWC_ELEMENT_CREATE'
       exporting
            element   = &2
       tables
            container = &1
       exceptions already_exists = 4
                  others = 1.
END-OF-DEFINITION.

* Container Set Element
DEFINE swc_set_element.
  call function 'SWC_ELEMENT_SET'
       exporting
            element       = &2
            field         = &3
       tables
            container     = &1
       exceptions others = 1.
END-OF-DEFINITION.

* Container Set Table
DEFINE swc_set_table.
  call function 'SWC_TABLE_SET'
       exporting
            element       = &2
       tables
            container     = &1
            table         = &3
       exceptions others = 1.
END-OF-DEFINITION.

* Container Get Element
DEFINE swc_get_element.
  call function 'SWC_ELEMENT_GET'
       exporting
            element       = &2
       importing
            field         = &3
       tables
            container     = &1
       exceptions not_found = 8
                  is_null   = 4
                  others = 1.
END-OF-DEFINITION.

* Container Get Table
DEFINE swc_get_table.
  call function 'SWC_TABLE_GET'
       exporting
            element       = &2
       tables
            container     = &1
            table         = &3
       exceptions not_found = 8
                  is_null   = 4
                  others = 1.
END-OF-DEFINITION.

* Container Löschen Element
DEFINE swc_delete_element.
  call function 'SWC_ELEMENT_DELETE'
       exporting
            element   = &2
       tables
            container = &1
       exceptions others = 1.
END-OF-DEFINITION.

* Kopieren Container1/Element1 -> Container2/Element2
* Parameters:  P1  Quellcontainer
*              P2  Quellelement
*              P3  Zielcontainer
*              P4  Zielelement
DEFINE swc_copy_element.
  call function 'SWC_ELEMENT_COPY'
       exporting
            source_element   = &2
            target_element   = &4
       tables
            source_container = &1
            target_container = &3
       exceptions
            not_found        = 1
            is_null          = 2
            others           = 3.
END-OF-DEFINITION.


*************** Container Object Macros ********************************
* Create Object Reference
* Parameters: P1   Object Reference to be created,  Output
*             P2   Type of the Object, Input
*             P3   Key of the Object, Input
DEFINE swc_create_object.
  swo_%objid-objtype = &2.
  swo_%objid-objkey = &3.
  &1-header = 'OBJH'.
  &1-type   = 'SWO '.
  call function 'SWO_CREATE'
       exporting
            objtype = swo_%objid-objtype
            objkey  = swo_%objid-objkey
       importing
            object  = &1-handle
            return  = swo_%return.
  if swo_%return-code ne 0.
    &1-handle = 0.
  endif.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.

* Create Object Reference
* Parameters: P1   Object Reference to be created,  Output
*             P2   Type of the Object, Input
*             P3   Key of the Object, Input
*             P4   Object Location (logical system), Input
DEFINE swc_create_remote_object.
  swo_%objid-objtype = &2.
  swo_%objid-objkey  = &3.
  swo_%objid-logsys  = &4.
  &1-header          = 'OBJH'.
  &1-type            = 'SWO '.
  call function 'SWO_CREATE'
       exporting
            objtype        = swo_%objid-objtype
            objkey         = swo_%objid-objkey
            logical_system = swo_%objid-logsys
       importing
            object         = &1-handle
            return         = swo_%return.
  if swo_%return-code ne 0.
    &1-handle = 0.
  endif.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.

* Create Object Reference via Dialog RFC destination if available
* Parameters: P1   Object Reference to be created,  Output
*             P2   Type of the Object, Input
*             P3   Key of the Object, Input
*             P4   Object Location (logical system), Input
DEFINE swc_create_remote_dialg_object.
  swo_%objid-objtype = &2.
  swo_%objid-objkey  = &3.
  swo_%objid-logsys  = &4.
  &1-header          = 'OBJH'.
  &1-type            = 'SWO '.
  call function 'SWO_CREATE'
       exporting
            objtype        = swo_%objid-objtype
            objkey         = swo_%objid-objkey
            logical_system = swo_%objid-logsys
            USE_DIALOG_RFC = 'X'
       importing
            object         = &1-handle
            return         = swo_%return.
  if swo_%return-code ne 0.
    &1-handle = 0.
  endif.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.


* Free Object Reference
* Parameters: P1   Object Reference to be freed,  Input
DEFINE swc_free_object.
  call function 'SWO_FREE'
       exporting
            object  = &1-handle
       importing
            return  = swo_%return.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.

* Get Object Type
* Parameters: P1   Object Reference , Input
*             P2   Name of the Objecttype, Output
DEFINE swc_get_object_type.
  call function 'SWO_OBJECT_ID_GET'
       exporting
            object  = &1-handle
       importing
            return  = swo_%return
            objid   = swo_%objid.
  swc_%sys_error_set swo_%return.
  &2 = swo_%objid-objtype.
END-OF-DEFINITION.

* Get Object Key
* Parameters: P1   Object Reference,  Input
*             P2   Object Key, Output
DEFINE swc_get_object_key.
  call function 'SWO_OBJECT_ID_GET'
       exporting
            object  = &1-handle
       importing
            return  = swo_%return
            objid   = swo_%objid.
  swc_%sys_error_set swo_%return.
  &2 = swo_%objid-objkey.
END-OF-DEFINITION.

* Get Property
* Parameters: P1   Object Reference,  Input
*             P2   Attribute Name, Input
*             P3   Value of the attribute, Output
DEFINE swc_get_property.
  swc_create_container swo_%container.
  call function 'SWO_INVOKE'
       exporting
            access     = 'G'
            object     = &1-handle
            verb       = &2
            persistent = ' '
       importing
            return     = swo_%return
            verb       = swo_%verb
       tables
            container  = swo_%container.
  swc_%sys_error_set swo_%return.
  if sy-subrc = 0.
    swc_get_element swo_%container swo_%verb &3.
  endif.
END-OF-DEFINITION.

* Get Table Property
* Parameters: P1   Object Reference,  Input
*             P2   Table Attribute Name, Input
*             P3   Value of the table attribute, Output
DEFINE swc_get_table_property.
  swc_create_container swo_%container.
  call function 'SWO_INVOKE'
       exporting
            access     = 'G'
            object     = &1-handle
            verb       = &2
            persistent = ' '
       importing
            return     = swo_%return
            verb       = swo_%verb
       tables
            container  = swo_%container.
  swc_%sys_error_set swo_%return.
  if sy-subrc = 0.
    swc_get_table swo_%container swo_%verb &3.
  endif.
END-OF-DEFINITION.

* Invoke Method
* Parameters: P1   Object Reference,  Input
*             P2   Method Name, Input
*             P3   Container with Import and Export parameters, In/Out
DEFINE swc_call_method.
  call function 'SWO_INVOKE'
       exporting
            access     = 'C'
            object     = &1-handle
            verb       = &2
            persistent = ' '
       importing
            return     = swo_%return
       tables
            container  = &3.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.

* Invoke Method asynchronously
* Parameters: P1   Object Reference,  Input
*             P2   Method Name, Input
*             P3   Container with Import and Export parameters, In/Out
DEFINE swc_call_method_async.
  call function 'SWO_INVOKE'
       exporting
            access     = 'C'
            object     = &1-handle
            verb       = &2
            persistent = ' '
            synchron   = ' '
            no_arfc    = 'X'
       importing
            return     = swo_%return
       tables
            container  = &3.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.

* Refresh Object Properties
* Parameters: P1   Object Reference,  Input
DEFINE swc_refresh_object.
  call function 'SWO_OBJECT_REFRESH'
       exporting
            object       = &1
       exceptions
            error_create = 02.
END-OF-DEFINITION.
***************** Events ***********************************************
* Raise Event
* Parameters: P1   Objectreference, Input
*             P2   Event Name, Input
*             P3   Event container with export parameters, Input
DEFINE swc_raise_event.
  if &1-handle > 0.
    swc_create_container swo_%container.
    loop at &3.
      swo_%container = &3.
      append swo_%container.
    endloop.
*   Make container a persistent
    call function 'SWC_CONT_PERSISTENT_CONVERT'
       exporting
            from_persistent = ' '
            to_persistent   = 'X'
       importing
            return          = swo_%return
       tables
            container       = swo_%container
       exceptions
            others          = 1.
    if swo_%return-code = 0.
*     Raise event
      swc_get_object_type &1 swo_%objid-objtype.
      swc_get_object_key &1 swo_%objid-objkey.
      call function 'SWE_EVENT_CREATE'
         exporting
              objtype              = swo_%objid-objtype
              objkey               = swo_%objid-objkey
              event                = &2
         tables
              event_container      = swo_%container
         exceptions
              objtype_not_found    = 1
              others               = 2.
    else.
      swc_%sys_error_set swo_%return.
    endif.
  else.
    sy-subrc = 4.
  endif.
END-OF-DEFINITION.

************ Converting containers *************************************
* Convert persistent container to runtime format
* Parameters: P1   Container, In/Out
*             P2   from persistent,  In
*             P3   to persistent,    In
DEFINE swc_container_convert.
  call function 'SWC_CONT_PERSISTENT_CONVERT'
     exporting
          from_persistent = &2
          to_persistent   = &3
     importing
          return          = swo_%return
     tables
          container       = &1
     exceptions
          others          = 1.
  swc_%sys_error_set swo_%return.
END-OF-DEFINITION.
* Convert persistent container to runtime format
* Parameters: P1   Container, In/Out
DEFINE swc_container_to_runtime.
  swc_container_convert &1 'X' ' '.
END-OF-DEFINITION.
* Make container persistent
* Parameters: P1   Container, In/Out
DEFINE swc_container_to_persistent.
  swc_container_convert &1 ' ' 'X'.
END-OF-DEFINITION.

* Convert handle to persistent object reference
* Parameters:   P1   object handle,   In
*               P2   persistent object reference (SWOTOBJID),   Out
DEFINE swc_object_to_persistent.
  call function 'SWO_OBJECT_ID_GET'
       exporting
            object  = &1-handle
       importing
            return  = swo_%return
            objid   = swo_%objid.
  swc_%sys_error_set swo_%return.
  &2 = swo_%objid.
END-OF-DEFINITION.

* Convert persistent object reference to runtime handle
* Parameters:   P1   persistent object reference (SWOTOBJID),   Out
*               P2   object handle,   In
DEFINE swc_object_from_persistent.
  swc_create_object &2 &1-objtype &1-objkey.
END-OF-DEFINITION.

* Compress container
* Parameters:   P   container,     Changing
DEFINE swc_container_compress.
  call function 'SWC_CONT_COMPRESS'
    tables
      container       = &1.
END-OF-DEFINITION.
