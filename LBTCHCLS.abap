*----------------------------------------------------------------------*
*   INCLUDE LBTCHCLS
*   Class for user selection favorites                                 *
*----------------------------------------------------------------------*
*    Class BP_JOBSEL_FAVORITE_ITEM definition
*----------------------------------------------------------------------*
class bp_jobsel_favorite_item definition.
  public section.
*
* constructor
*
    methods constructor
              importing in_name       type btcjob
                        in_properties type btcselectp.

    methods get_item_name
              exporting name type btcjob.
    methods set_item_name
              importing name type btcjob.
*              exceptions duplicate_name type i.

    methods get_item_properties
              exporting properties type btcselectp.
    methods set_item_properties
              importing properties type btcselectp.

    methods get_item_creator
              exporting creator like sy-uname.
    methods set_item_creator.

    methods get_item_create_date
              exporting create_date like sy-datum.
    methods set_item_create_date.

    methods get_item_create_time
              exporting create_time like sy-uzeit.
    methods set_item_create_time.

  protected section.
    data: item_name(32)    type c value space,
          item_creator     like sy-uname,
          item_create_date like sy-datum,
          item_create_time like sy-uzeit,
          item_properties  type btcselectp.

endclass.

*----------------------------------------------------------------------*
*    Class BP_JOBSEL_FAVORITE_CONTAINER definition
*----------------------------------------------------------------------*
class bp_jobsel_favorite_container definition.
  public section.
*
* constructor
*
    methods constructor.

*
* load my favorite list from DB
*
    methods load_favorite_list_from_db.

*
* check existence of item in favorite list
*
    methods check_existence_in_list
            importing in_name type btcjob
            returning value(return_code) type i.

*
* insert user favorite job selection variant into the user-specific
* container
*
    methods add_item
            importing in_item type ref to bp_jobsel_favorite_item
            exceptions item_exists_already.

*
* remove user favorite job selection variant from the user-specific
* container
*
    methods remove_item
            importing in_name       type btcjob
            exceptions item_not_exist.

*
* validate the favorite job selection variant to be inserted against
* the container
*
    methods validate_item
            importing in_item type ref to bp_jobsel_favorite_item
            returning value(rcode)  type i.

*
* update DB according to the changes made and confirmed
*
    methods update_db
            exceptions update_failed.

*
* retrieve selection variant from the user-specific container using
* item name
*
    methods get_item_by_name
            importing in_name  type btcjob
            exporting out_item type ref to bp_jobsel_favorite_item
            exceptions item_not_found.

*
* retrieve selection variant from the user-specific container using
* index of the list
*
    methods get_item_by_index
            importing in_index type i
            exporting out_item type ref to bp_jobsel_favorite_item
            exceptions index_not_in_range.

  protected section.
    data: my_favorite_list type table of ref to bp_jobsel_favorite_item,
          total_favorite   type i.

endclass.

*----------------------------------------------------------------------*
*    Class BP_JOBSEL_FAVORITE_ITEM implementation
*----------------------------------------------------------------------*
class bp_jobsel_favorite_item implementation.
*
* constructor
*
  method constructor.
*        importing in_name       type btcjob
*                  in_properties type btcselectp.

* setting initial values to attributes
    call method me->set_item_name
                exporting name = in_name.
    call method me->set_item_properties
                exporting properties = in_properties.
    call method me->set_item_creator.
    call method me->set_item_create_date.
    call method me->set_item_create_time.

  endmethod.

  method get_item_name.
*        exporting name type btcjob
    name = item_name.
  endmethod.
  method set_item_name.
*        importing name type btcjob
    item_name = name.
  endmethod.

  method get_item_properties.
*        exporting properties type btcselectp
    move item_properties to properties.
  endmethod.
  method set_item_properties.
*        importing properties type btcselectp
    move properties to item_properties.
  endmethod.

  method get_item_creator.
*        exporting creator like sy-uname
    creator = item_creator.
  endmethod.
  method set_item_creator.
*        importing creator like sy-uname
    if item_name eq '_DEFAULT'.
      item_creator = 'SAP*'.
    else.
      item_creator = sy-uname.
    endif.
  endmethod.

  method get_item_create_date.
*        exporting create_date like sy-datum
    create_date = item_create_date.
  endmethod.
  method set_item_create_date.
*        importing create_date like sy-datum
    item_create_date = sy-datum.
  endmethod.

  method get_item_create_time.
*        exporting create_time like sy-uzeit
    create_time = item_create_time.
  endmethod.
  method set_item_create_time.
*        importing create_time like sy-uzeit
    item_create_time = sy-uzeit.
  endmethod.

endclass.

*---------------------------------------------------------------------*
*       CLASS bp_jobsel_favorite_container IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
class bp_jobsel_favorite_container implementation.

  method constructor.
*   load my favorite list from DB
    call method me->load_favorite_list_from_db.
    describe table my_favorite_list lines total_favorite.
  endmethod.

  method load_favorite_list_from_db.
    data: wa_favsels        type favsels,
          new_item          type ref to bp_jobsel_favorite_item,
          new_properties    type btcselectp,
          new_select_daily  type btcselectp,
          len               type i value 0.

    select * from favsels into wa_favsels.
      if wa_favsels-creator eq sy-uname or
         wa_favsels-favname eq '_DEFAULT'.
        move-corresponding wa_favsels to new_properties.
        create object new_item
               exporting in_name       = wa_favsels-favname
                         in_properties = new_properties.
        append new_item to my_favorite_list.
      endif.
    endselect.
* If the first time calling this transaction while the table
* FAVSELS is empty, create the _DEFAULT entry to start
    describe table my_favorite_list lines len.
    if len eq 0. " table is empty
      " create a default entry with default properties
      new_select_daily-jobname  = '*'.
      new_select_daily-username = '*'.
      new_select_daily-selfav   = '_DEFAULT'.
      new_select_daily-from_date = sy-datum.
      new_select_daily-from_time = '000000'.
      new_select_daily-to_date   = sy-datum.
      new_select_daily-to_time   = '240000'.
      new_select_daily-prelim    = 'X'.
      new_select_daily-schedul  = 'X'.
      new_select_daily-ready    = 'X'.
      new_select_daily-running  = 'X'.
      new_select_daily-finished = 'X'.
      new_select_daily-aborted  = 'X'.
      new_select_daily-dontcare = 'X'.
      create object new_item
             exporting in_name       = '_DEFAULT'
                       in_properties = new_select_daily.
      call method me->add_item
             exporting in_item = new_item.
      call method me->update_db.
    endif.

  endmethod.

  method check_existence_in_list.
*        importing in_name type btcjob
*        returning value(return_code) type i.
    data: temp_item type ref to bp_jobsel_favorite_item,
          temp_name type btcjob.

    return_code = 0.
    loop at my_favorite_list into temp_item.
      call method temp_item->get_item_name
           importing name = temp_name.
      if temp_name eq in_name.
        return_code = 1.
        exit.
      endif.
    endloop.

  endmethod.

  method add_item.
*        importing in_item type ref to bp_jobsel_favorite_item.

* validate the newly created item.
    data: return_code type i value 0,
          user_answer type c,
          temp_name   type btcjob.

    call method me->validate_item
         exporting in_item = in_item
         receiving rcode   = return_code.

    if return_code eq 0.
*     append new item to the item list
      append in_item to my_favorite_list.
      total_favorite = total_favorite + 1.
    else.
*     validation fails due to duplicate name
*     prompt for overwrite
      call function 'POPUP_TO_CONFIRM_STEP'      "#EC FB_OLDED
           exporting
                defaultoption = 'N'
                textline1     = text-750
                titel         = text-751
           importing
                answer        = user_answer
           exceptions
                others        = 99.
      if sy-subrc eq 0.
        case user_answer.
          when 'J'.                    " overwrite
            call method in_item->get_item_name
                 importing name    = temp_name.
            call method me->remove_item
                 exporting in_name = temp_name.
            append in_item to my_favorite_list.
          when 'N'.
            leave screen.
          when 'A'.
            leave screen.
        endcase.
      endif.
    endif.

  endmethod.

  method remove_item.
*        importing in_name       type btcjob.
    data: temp_item type ref to bp_jobsel_favorite_item.
    data: temp_item_name type btcjob.

* remove item with the input name from the list
    loop at my_favorite_list into temp_item.
      call method temp_item->get_item_name
                  importing name = temp_item_name.
      if in_name eq temp_item_name.
        delete my_favorite_list.
        total_favorite = total_favorite - 1.
        exit.
      endif.
    endloop.

  endmethod.

  method update_db.
    data: update_item  type favsels,
          temp_item    type ref to bp_jobsel_favorite_item,
          temp_prop    type btcselectp,
          temp_name    type btcjob,
          temp_creator like sy-uname,
          temp_date    like sy-datum,
          temp_time    like sy-uzeit.

    data: temp_db_item type favsels,
          db_list_count type i,
          r_code type i.

* using object services to avoid commit work in the logic
    data: update_problem(1) type c,
          update_transaction  type ref to if_os_transaction,
          transaction_manager type ref to if_os_transaction_manager.

    call method cl_os_system=>get_transaction_manager
         receiving
           result = transaction_manager.

    if sy-subrc <> 0.
* exceptions
      raise update_failed.
    endif.

    call method transaction_manager->create_transaction
         receiving
           result = update_transaction.

    call method update_transaction->start.

* starting updating DB
    loop at my_favorite_list into temp_item.
      call method temp_item->get_item_name
                  importing name        = temp_name.
      call method temp_item->get_item_creator
                  importing creator     = temp_creator.
      call method temp_item->get_item_create_date
                  importing create_date = temp_date.
      call method temp_item->get_item_create_time
                  importing create_time = temp_time.
      call method temp_item->get_item_properties
                  importing properties  = temp_prop.

*     modify DB accordingly
      clear update_item.
      update_item-favname  = temp_name.
      update_item-creator  = temp_creator.
      update_item-creadate = temp_date.
      update_item-creatime = temp_time.
      move-corresponding temp_prop to update_item.
      modify favsels from update_item.
      if sy-subrc <> 0.
        update_problem = 'X'.
      endif.
    endloop.

*   clean up the DB with latest favorite list if necessary
    select count(*) from favsels into db_list_count
           where creator = sy-uname or
                 favname = '_DEFAULT'.

*   DB needs to be cleaned up
    if db_list_count > total_favorite.
      select * from favsels into temp_db_item
             where creator = sy-uname.
        call method me->check_existence_in_list
             exporting in_name     = temp_db_item-favname
             receiving return_code = r_code.
        if r_code eq 1.                " exists, do nothing
        else.                          " not exist, delete it from DB
          delete favsels from temp_db_item.
        endif.
      endselect.
    endif.

*   do the actual update in DB
*    commit work.
*   check if the update is successful
    if update_problem <> space.
                                       " if not, roll back.
      call method update_transaction->undo.
    else.
      call method update_transaction->end.
    endif.

  endmethod.

  method get_item_by_name.
*        importing in_name  type btcjob
*        exporting out_item type ref to bp_jobsel_favorite_item.
    data: temp_name type btcjob.

    clear out_item.
    loop at my_favorite_list into out_item.
      call method out_item->get_item_name
           importing name = temp_name.
      if in_name = temp_name.
        exit.
      endif.
    endloop.

  endmethod.

  method get_item_by_index.
*        importing in_index type i
*        exporting out_item type ref to bp_jobsel_favorite_item.

    read table my_favorite_list into out_item index in_index.

* exceptions

  endmethod.

  method validate_item.
*        importing in_item type ref to bp_jobsel_favorite_item
*        returning value(rcode)  type i.

    data: temp_name1 type btcjob,
          temp_name2 type btcjob,
          temp_item type ref to bp_jobsel_favorite_item,
          temp_prop type btcselectp,
          temp_rcode type i value 0.

*   get the name of the input item
    call method in_item->get_item_name
                importing name = temp_name2.
*   check whether the name is valid
    loop at my_favorite_list into temp_item.
      call method temp_item->get_item_name
                  importing name = temp_name1.

*     duplicate name
      if temp_name2 = temp_name1.
        temp_rcode = 1.
        exit.
      endif.
    endloop.

    rcode = temp_rcode.

  endmethod.

endclass.
