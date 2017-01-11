function /sapcnd/get_global_parameter .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PARAM_NAME) TYPE  /SAPCND/PARAM_NAME
*"     VALUE(I_CLIENT) TYPE  SYMANDT DEFAULT SY-MANDT
*"  EXPORTING
*"     VALUE(E_PARAM_VALUE) TYPE  /SAPCND/PARAM_VALUE
*"  EXCEPTIONS
*"      EXC_PARAM_NOT_FOUND
*"----------------------------------------------------------------------

  statics: xconfig   type hashed table of /sapcnd/config
                          with unique key param_name,
           xconfigcc type hashed table of /sapcnd/configcc
                          with unique key client param_name,
           xclient   type hashed table of symandt
                          with unique key table_line.

  data: wa_xconfig   type /sapcnd/config,
        wa_xconfigcc type /sapcnd/configcc.

* hard coded timezone master data DB
  if i_param_name = 'TIMEZONE_MASTER_DATA_DB'.
    e_param_value = ctcus_timezone_utc.
    exit.
  endif.

* cache the client independent config parameters
  if xconfig[] is initial.
    select * from /sapcnd/config into table xconfig.
  endif.

* cache the client dependent config parameters
  read table xclient with table key table_line = i_client
             transporting no fields.
  if sy-subrc <> 0.

*   client is not yet in cache
*   fill client-dependent setting client specified from database
    select * from /sapcnd/configcc client specified
             into table xconfigcc
             where client = i_client.

*   fill client cache
    insert i_client into table xclient.
  endif.

* check for the client-dependent setting first from cache table
  read table xconfigcc into wa_xconfigcc
                       with table key
                            client = i_client
                            param_name = i_param_name.
  if sy-subrc = 0.
    e_param_value = wa_xconfigcc-param_value.
  else.

*   there's no client dependent entry
*   ok, check for a client independent one
    read table xconfig into wa_xconfig
                       with table key param_name = i_param_name.
    if sy-subrc = 0.
      e_param_value = wa_xconfig-param_value.
    else.
      raise exc_param_not_found.
    endif.
  endif.

endfunction.
