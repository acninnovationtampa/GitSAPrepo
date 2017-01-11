TYPE-POOL trwbo .

TYPES: trwbo_charflag(1) TYPE c.

*----------------------------------------------------------------------*
* Table and structure types corresponding to our database tables
*----------------------------------------------------------------------*
TYPES: trwbo_s_e070        LIKE e070    .
TYPES: trwbo_s_e070use     LIKE e070use .
TYPES: trwbo_s_e07t        LIKE e07t    .
TYPES: trwbo_s_e070a       LIKE e070a   .
TYPES: trwbo_s_e070c       LIKE e070c   .
TYPES: trwbo_s_e070m       LIKE e070m   .
TYPES: trwbo_s_e071        LIKE e071    .
TYPES: trwbo_s_e071k       LIKE e071k   .
TYPES: trwbo_s_e071kf      LIKE e071kf  .
TYPES: trwbo_s_lock        LIKE strlocktab.
TYPES: trwbo_s_ko200       TYPE ko200.

TYPES: trwbo_t_e070        TYPE trwbo_s_e070         OCCURS   0.
TYPES: trwbo_t_e070use     TYPE trwbo_s_e070use      OCCURS   0.
TYPES: trwbo_t_e07t        TYPE trwbo_s_e07t         OCCURS   0.
TYPES: trwbo_t_e070a       TYPE trattributes.
TYPES: trwbo_t_e070c       TYPE trwbo_s_e070c        OCCURS   0.
TYPES: trwbo_t_e070m       TYPE trwbo_s_e070m        OCCURS   0.
TYPES: trwbo_t_e071        TYPE trwbo_s_e071         OCCURS   0.
TYPES: trwbo_t_e071k       TYPE trwbo_s_e071k        OCCURS   0.
TYPES: trwbo_t_e071kf      TYPE trwbo_s_e071kf       OCCURS   0.
TYPES: trwbo_t_locktab     TYPE trwbo_s_lock         OCCURS   0.
TYPES: trwbo_t_ko200       TYPE STANDARD TABLE OF trwbo_s_ko200.

* string key.
TYPES: trwbo_s_e071k_str   TYPE e071k_str.
TYPES: trwbo_t_e071k_str   TYPE TABLE OF trwbo_s_e071k_str.
*----------------------------------------------------------------------*
* Context of a request (header only and with objects and keys)
*----------------------------------------------------------------------*
TYPES: BEGIN OF trwbo_request_header.
INCLUDE   STRUCTURE e070.
TYPES:    as4text        LIKE e07t-as4text,
          as4text_filled TYPE trwbo_charflag,
          client         LIKE e070c-client,
          tarclient      LIKE e070c-tarclient,
          clients_filled TYPE trwbo_charflag,
          tardevcl       LIKE e070m-tardevcl,
          devclass       LIKE e070m-devclass,
          tarlayer       LIKE e070m-tarlayer,
          e070m_filled   TYPE trwbo_charflag,
       END OF   trwbo_request_header.
TYPES: trwbo_request_headers TYPE trwbo_request_header  OCCURS 0.

TYPES: BEGIN OF trwbo_request,
          h                 TYPE trwbo_request_header,
          objects           TYPE trwbo_t_e071,
          keys              TYPE trwbo_t_e071k,
          keys_str          TYPE e071k_strtyp,
          objects_filled    TYPE trwbo_charflag,
          attributes        TYPE trwbo_t_e070a,
          attributes_filled TYPE trwbo_charflag,
       END OF   trwbo_request.

TYPES: trwbo_requests        TYPE trwbo_request         OCCURS 0.

*----------------------------------------------------------------------*
* Types for the (public) interface of STRH (TR_PRESENT_REQUESTS_xxx)
*----------------------------------------------------------------------*
TYPES:                        trwbo_calling_organizer TYPE c.
CONSTANTS: trwbo_wbo     TYPE trwbo_calling_organizer VALUE 'W',
           trwbo_cust    TYPE trwbo_calling_organizer VALUE 'C',
           trwbo_cto     TYPE trwbo_calling_organizer VALUE 'A',
           trwbo_trans   TYPE trwbo_calling_organizer VALUE 'T',
           trwbo_piece   TYPE trwbo_calling_organizer VALUE 'F',
           trwbo_clients TYPE trwbo_calling_organizer VALUE '1',
           trwbo_deliver TYPE trwbo_calling_organizer VALUE '2',
           trwbo_display TYPE trwbo_calling_organizer VALUE 'D',
           trwbo_img     TYPE trwbo_calling_organizer VALUE 'I'.


TYPES: BEGIN OF trwbo_selection,
          trkorrpattern LIKE e070-trkorr,
          stdrequest    TYPE trwbo_charflag,
          client        LIKE e070c-client,
          tarsystem     LIKE e070-tarsystem,
          categ_syst    TYPE trwbo_charflag,  "obsolete!
          categ_cust    TYPE trwbo_charflag,  "obsolete!
          reqfunctions  LIKE trpari-w_longstat,
          reqstatus     LIKE trpari-w_longstat,
          taskfunctions LIKE trpari-w_longstat,
          taskstatus    LIKE trpari-w_longstat,
          suppress_req_selection      TYPE c,
          connect_req_task_conditions TYPE c,
          singletasks   TYPE trwbo_charflag,
          freetasks_f   LIKE trpari-w_longstat,
          freetasks_s   LIKE trpari-w_longstat,
          fromdate      LIKE e070-as4date,
          todate        LIKE e070-as4date,
          attribute     LIKE e070a-attribute,
          reference     LIKE e070a-reference,
       END OF  trwbo_selection.

TYPES: trwbo_selections TYPE trwbo_selection OCCURS 0.

TYPES: BEGIN OF trwbo_new_req_props,
          trfunctions LIKE trpari-w_longstat,
          taskfunc    LIKE e070-trfunction,
          client      LIKE e070c-client,
          tarsystem   LIKE e070-tarsystem,
          attribute   LIKE e070a-attribute,
          reference   LIKE e070a-reference,
       END OF   trwbo_new_req_props.

TYPES: trwbo_title           LIKE  sy-title.

TYPES: BEGIN OF trwbo_user,
         user    LIKE e070-as4user,
       END OF trwbo_user.

TYPES: trwbo_users   TYPE trwbo_user OCCURS 0.
