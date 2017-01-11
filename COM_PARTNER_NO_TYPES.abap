*----------------------------------------------------------------------*
*   INCLUDE COM_PARTNER_NO_TYPES                                       *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_PARTNER_NO_TYPE,
             BUSINESS_PARTNER_GUID(2) VALUE SPACE,
             BUSINESS_PARTNER_NO(2)   VALUE 'BP',
             CENTRAL_PERSON(2)        VALUE 'CP',
             USER(2)                  VALUE 'US',
             EMPLOYEE(2)              VALUE 'P ',
             ORG_UNIT(2)              VALUE 'O ',
             HIERARCHY_TREE(2)        VALUE 'HT',
             HIERARCHY_TREE_GUID(2)   VALUE 'HG',
             TEAM(2)                  VALUE 'T ',
             EXTERNAL_PARTNER(2)      VALUE 'EX',
             HIERARCHY_NODE(2)        VALUE 'HN',
             HIERARCHY_NODE_GUID(2)   VALUE 'NG'.
CONSTANTS: END OF GC_PARTNER_NO_TYPE.
