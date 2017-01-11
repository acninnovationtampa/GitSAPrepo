*----------------------------------------------------------------------*
*   INCLUDE COM_TEXT_CON                                               *
*----------------------------------------------------------------------*

CONSTANTS:
   gc_no_guid TYPE crmt_object_guid   VALUE IS INITIAL.

CONSTANTS: BEGIN OF GC_MODE,
             UPDATE  VALUE 'B',
             INSERT  VALUE 'A',
             DELETE  VALUE 'D',
             DISPLAY VALUE 'C',
             ARCHIVE VALUE 'E',
           END OF GC_MODE.       "#EC NEEDED

CONSTANTS: BEGIN OF GC_FUNCTION,
             UPDATE TYPE TDFUNCTION VALUE 'U',
             INSERT TYPE TDFUNCTION VALUE 'I',
             DELETE TYPE TDFUNCTION VALUE 'D',
           END OF GC_FUNCTION.

CONSTANTS: GC_CHARX(1) TYPE C VALUE 'X',
           GC_UNDEFINED(1) TYPE C VALUE '-',  "#EC NEEDED
           gc_asterisk value '*'.
* allowed ways of changing a text: The value correspond the allowed
* values of the domain COM_TEXT_CHANGEABLE
constants:
  begin of gc_changeable,
     all           type c value ' ',
     only_add      type c value 'A',
     add_with_name type c value 'B',
     only_display  type c value 'C',
     no_display     type c value 'N',
     protocol      type c value 'P',
     history       type c value 'R',
  end of gc_changeable.
* allowed ways of accessing a text. The values correspond to the
* allowed values of the domain COMT_TEXT_REFWAY
constants:
  begin of gc_refway,
    undefined    type c value ' ',
    copy         type c value 'A',
    reference    type c value 'B',
    dyn_read     type c value 'C',
  end of gc_refway.

* Message type
constants:  begin of gc_msgtype,
              dump      type   symsgty   value 'X',
              abort     type   symsgty   value 'A',
              error     type   symsgty   value 'E',
              warning   type   symsgty   value 'W',
              info      type   symsgty   value 'I',
              success   type   symsgty   value 'S',
            end of gc_msgtype.    "#EC NEEDED
* Memory id
types gty_memory_id type c length 60.
constants: gc_prot_ids type gty_memory_id value 'COM_TEXT_MAINTENANCE_PROTIDS',
           gc_no_commit_flag type gty_memory_id value 'COM_TEXT_MAINTENANCE_NO_COMMIT_FLAG'.

constants: begin of gc_authorization,
                 edit type n length 2 value '02',
                 display type n length 2 value '03',
             end of gc_authorization.    "#EC NEEDED

* text objects
CONSTANTS:
  BEGIN OF gc_tdobject,
     billing_header   TYPE comt_text_textobject VALUE 'BEA_BDH',
     billing_item     TYPE comt_text_textobject VALUE 'BEA_BDI',
     duelist_item     TYPE comt_text_textobject VALUE 'BEA_DLI',
     activity_journal TYPE comt_text_textobject VALUE 'CRM_ACTJRN',
     order_header     TYPE comt_text_textobject VALUE 'CRM_ORDERH',
     order_item       TYPE comt_text_textobject VALUE 'CRM_ORDERI',
     order_partner    TYPE comt_text_textobject VALUE 'CRM_ORDPTH',
     prodcat_area     TYPE comt_text_textobject VALUE 'PCAT_CTY',
     prodcat_item     TYPE comt_text_textobject VALUE 'PCAT_ITM',
     business_partner TYPE comt_text_textobject VALUE 'BUT000',
  END OF gc_tdobject.                                    "#EC NEEDED

* text-object kind
CONSTANTS:
BEGIN OF gc_tdobj_kind,
    header TYPE crmt_object_kind value 'A',
    item   TYPE crmt_object_kind value 'B',
  END OF gc_tdobj_kind.                                  "#EC NEEDED
