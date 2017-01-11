*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:02
*
*======================================================================
* Special Treatment for the field VENDOR
data:
  lv_vendor_id type bu_partner.

lv_fieldname = 'VENDOR'.
read table lt_text with key tabname = space
                            element = space
                            text1   = text-dh5
                   transporting no fields.
lv_tabix_hlp = sy-tabix + 1.
loop at lt_text into ls_text from lv_tabix_hlp.
  lv_tabix = sy-tabix.
  if ls_text-element is initial.
    exit.
  endif.
endloop.

  if not is_bdi-vendor is initial.
    call function 'COM_PARTNER_CONVERT_GUID_TO_NO'
      exporting
        iv_partner_guid        = is_bdi-vendor
      importing
        ev_partner             = lv_vendor_id
      exceptions
        partner_does_not_exist = 1
        others                 = 2.
    if sy-subrc eq 0.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname           = 'CRMT_VENDOR'
          langu             = sy-langu
          all_types         = 'X'
        IMPORTING
          dfies_wa          = ls_dfies
        EXCEPTIONS
          NOT_FOUND       = 1
          INTERNAL_ERROR  = 2
          OTHERS          = 3.
    IF sy-subrc eq 0.
      ls_text-tabname = ls_dfies-tabname.
      ls_text-element = ls_dfies-fieldname.
      ls_text-text1 = ls_dfies-scrtext_l.
      write lv_vendor_id to ls_text-text2 no-zero.
      ls_text-type = space.
      insert ls_text into lt_text index lv_tabix.
    endif.
  endif.
 endif.
