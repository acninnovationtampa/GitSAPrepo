*----------------------------------------------------------------------*
*   INCLUDE LBTCHFAV
*   User defined job selection favorite                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SAVE_USER_SELECTION_FAVORITE
*&---------------------------------------------------------------------*
*       Prompting user to save the selection favorite
*----------------------------------------------------------------------*
form save_user_selection_favorite.
  call screen 3090 starting at 10 5
                   ending   at 65 8.
endform.                               " SAVE_USER_SELECTION_FAVORITE

*&---------------------------------------------------------------------*
*&      Form  ADD_FAVSELS_ENTRY
*&---------------------------------------------------------------------*
*       Add a favorite selection item into the favorite list
*----------------------------------------------------------------------*
form add_favsels_entry.
data: begin of fav_prop occurs 0.
        include structure btcselectp.
data: end of fav_prop.

  move-corresponding btch3070 to fav_prop.
  move-corresponding btch3071 to fav_prop.
  move-corresponding btch3072 to fav_prop.
  move-corresponding btch3073 to fav_prop.
  move-corresponding btch3074 to fav_prop.
  move-corresponding btch3075 to fav_prop.
  move-corresponding btch3076 to fav_prop.
  move-corresponding btch3077 to fav_prop.
  append fav_prop.

* create an item first
  create object fav_item
         exporting in_name       = btch3090-favname
                   in_properties = fav_prop.

  call method fav_list->add_item
              exporting in_item = fav_item.

  call method fav_list->update_db.

* show up selected item on the screen
  btch3070-selfav = btch3090-favname.

endform.                               " ADD_FAVSELS_ENTRY
*&---------------------------------------------------------------------*
*&      Form  DELETE_FAVORITE_SELECTION
*&---------------------------------------------------------------------*
*       Remove favorite selection item from the list
*----------------------------------------------------------------------*
*      -->SELFAV  selected item
*----------------------------------------------------------------------*
FORM DELETE_FAVORITE_SELECTION USING SELFAV.
  data: dele_item type ref to bp_jobsel_favorite_item,
        dele_item_name type btcjob.

  if SELFAV ne sys_default_item.
    call method fav_list->get_item_by_name
         exporting in_name  = selfav
         importing out_item = dele_item.

    call method dele_item->get_item_name
         importing name = dele_item_name.

    call method fav_list->remove_item
         exporting in_name = dele_item_name.

    call method fav_list->update_db.
  else.
    message i650.
  endif.

* resume the default selection screen -- have to!!
  call transaction jobmaintenance_transaction_p.

ENDFORM.                    " DELETE_FAVORITE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  REORG_DEFAULT_FAV_LIST
*&---------------------------------------------------------------------*
*       Clean up outdated default items;
*       Create new default items;
*       append new default items to help list
*----------------------------------------------------------------------*
FORM REORG_DEFAULT_FAV_LIST.
  data: new_select_daily  type btcselectp,
        old_select_daily  type btcselectp.
  data: fav_item type ref to BP_JOBSEL_FAVORITE_ITEM,
        new_item type ref to BP_JOBSEL_FAVORITE_ITEM.

* 1. clean up outdated items if necessary.

  call method fav_list->get_item_by_name
       exporting in_name  = '_DEFAULT'
       importing out_item = fav_item.

  call method fav_item->get_item_properties
       importing properties = old_select_daily.

  if old_select_daily-from_date ne sy-datum.  " outdated
    call method fav_list->remove_item
         exporting in_name = '_DEFAULT'.

* 2. create new default item.
    old_select_daily-from_date = sy-datum.
    old_select_daily-to_date   = sy-datum.
    move-corresponding old_select_daily to new_select_daily.

    create object new_item
           exporting in_name       = '_DEFAULT'
                     in_properties = new_select_daily.

    call method fav_list->add_item
         exporting in_item = new_item.

    call method fav_list->update_db.

  endif.

ENDFORM.                    " REORG_DEFAULT_FAV_LIST
