* Type Pool for DataProvider
TYPE-POOL CNDP.
TYPE-POOLS OLE2.


TYPES CNDP_MEDIUM(40).

CONSTANTS: CNDP_MEDIUM_OBJECT   TYPE CNDP_MEDIUM VALUE 'OBJECT'.
* THESE MEDIA ARE OBSOLETE
* CONSTANTS: CNDP_MEDIUM_FILE     TYPE CNDP_MEDIUM VALUE 'FILE'.
* CONSTANTS: CNDP_MEDIUM_HANDLE   TYPE CNDP_MEDIUM VALUE 'HANDLE'.
CONSTANTS: CNDP_MEDIUM_STREAM   TYPE CNDP_MEDIUM VALUE 'STREAM'.
CONSTANTS: CNDP_MEDIUM_DATA     TYPE CNDP_MEDIUM VALUE 'DATA'.
CONSTANTS: CNDP_MEDIUM_R3TABLE  TYPE CNDP_MEDIUM VALUE 'R3TABLE'.

* Default name space for ABAP internal data
* DO NOT MODIFY, NAMESPACE IS ALSO CODED ON CLIEND SITE
CONSTANTS: CNDP_SAP_URL_NAMESPACE(8)     TYPE C VALUE 'SAPR3://'.
* Pseudo MIME Type for internal tables
* DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
CONSTANTS: CNDP_SAP_TAB_MIMETYPE(11)     TYPE C VALUE  'APPLICATION'.
CONSTANTS: CNDP_SAP_TAB_MIMESUBTYPE(9)   TYPE C VALUE  'X-R3TABLE'.
* Pseudo MIME Type for internal tables presented as rowsets
* DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
CONSTANTS: CNDP_SAP_ROWSET_MIMETYPE(11)   TYPE C VALUE  'APPLICATION'.
CONSTANTS: CNDP_SAP_ROWSET_MIMESUBTYPE(8) TYPE C VALUE 'X-ROWSET'.

CONSTANTS: CNDP_SAP_CTXMNU_MIMETYPE(11)    TYPE C VALUE 'APPLICATION'.
CONSTANTS: CNDP_SAP_CTXMNU_MIMESUBTYPE(12) TYPE C VALUE 'X-SAPCTXMENU'.
* DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
CONSTANTS: CNDP_SAP_DD_MIMETYPE(11)    TYPE C VALUE 'APPLICATION'.
CONSTANTS: CNDP_SAP_DD_MIMESUBTYPE(12) TYPE C VALUE 'X-SAPDDBEHAV'.



CONSTANTS: CNDP_SAP_TAB_UNKNOWN(9)       TYPE C VALUE  'X-UNKNOWN'.

CONSTANTS: CNDP_SAP_TYPE_UNKNOWN(11)     TYPE C VALUE  'APPLICATION'.
CONSTANTS: CNDP_SAP_SUBTYPE_UNKNOWN(9)   TYPE C VALUE  'X-UNKNOWN'.
* Pseudo MIME Type large parameters in Automation Queue
* DO NOT MODIFY, TYPE IS ALSO CODED IN CLIENT SITE
CONSTANTS: CNDP_SAP_LACPARAM_TYPE(11)      TYPE C VALUE  'APPLICATION'.
CONSTANTS: CNDP_SAP_LACPARAM_SUBTYPE(12)   TYPE C VALUE  'X-SAPACLPARA'.
* Lifetimeflag for LocalTable Entries
CONSTANTS: CNDP_LIFETIME_VOLATILE TYPE C VALUE '1'.
CONSTANTS: CNDP_LIFETIME_TRANSACTION TYPE C VALUE 'T'.
* Cannot delete above constant, since it is already in use.
* CONSTANTS: CNDP_LIFETIME_IMODE TYPE C VALUE 'I'.
CONSTANTS: CNDP_LIFETIME_ALL TYPE C VALUE 'X'.

* Structure for UserInfo in DataProvider
TYPES: BEGIN OF CNDP_USER_INFO,
       USER TYPE OLE2_PARAMETER,           " Username am Server
       PASSWORD TYPE OLE2_PARAMETER,       " Password am Server
       PROXY TYPE OLE2_PARAMETER,          " Proxy (incl. Port)
       PROXYUSER TYPE OLE2_PARAMETER,      "User am Proxy
       PROXYPASSWORD TYPE OLE2_PARAMETER,  "Password am Proxy
       SCRAMBLED,                           " Flag ob verschl�sselt
       END OF CNDP_USER_INFO.
* RFC_FIELDS Table Type
TYPES CNDP_FIELDSTAB TYPE STANDARD TABLE OF RFC_FIELDS
                        with default key.
TYPES CNDP_PROPSTAB TYPE standard TABLE OF DPPROPS
                        with default key.



TYPES : BEGIN OF CNDP_TDataChangeField,
           ColIdx type i,
           value type string,
        END OF CNDP_TDataChangeField.
TYPES : CNDP_TDataChangeTab type standard table of
             CNDP_TDataChangeField with default key.

TYPES : cndp_XML_STREAM_LINE(255) TYPE C.
TYPES : cndp_XML_STREAM_TAB_TYPE TYPE STANDARD TABLE OF
             cndp_XML_STREAM_LINE with default key.

* Constants for uopload download errortreatment
* Success codes
CONSTANTS: CNDP_SUCCESS                 TYPE I VALUE 0.
CONSTANTS: CNDP_SUCCESS_FAIL            TYPE I VALUE 1.
* Error codes
CONSTANTS: CNDP_FAIL_UNKNOWN            TYPE I VALUE -1.
CONSTANTS: CNDP_FAIL_NOTFOUND           TYPE I VALUE -2.
CONSTANTS: CNDP_FAIL_ACCESSDENIED       TYPE I VALUE -3.
CONSTANTS: CNDP_FAIL_OUTOFMEM           TYPE I VALUE -4.
CONSTANTS: CNDP_FAIL_OUTOFDISKSPACE     TYPE I VALUE -5.
CONSTANTS: CNDP_FAIL_TIMEOUT            TYPE I VALUE -6.

TYPES : CNDP_ASYNC_KEY(210) TYPE C.
TYPES : CNDP_ASYNC_NAME(30) TYPE C.
TYPES : CNDP_URL(256) TYPE C.


*
CONSTANTS: CNDP_ASYNC_WEB_NAMESPACE TYPE CNDP_ASYNC_NAME
                          VALUE 'WebRepository'.