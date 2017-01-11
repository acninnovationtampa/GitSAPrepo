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
  CONSTANTS: LC_CRTOBD_LSG_TTE_LOGSYS TYPE PRCT_ATTR_NAME
             VALUE 'TTE_LOGSYS'.
  DATA: LS_CRTOBD_LSG_ATTR_NAME_VALUE TYPE PRCT_ATTR_NAME_VALUE,
        LV_OWN_LOGSYS                 TYPE TBDLS-LOGSYS.

    READ TABLE GT_ALL_ATTR_NAMES TRANSPORTING NO FIELDS
      WITH KEY TABLE_LINE = LC_CRTOBD_LSG_TTE_LOGSYS
      BINARY SEARCH.
    IF SY-SUBRC = 0.
      CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
        IMPORTING
          OWN_LOGICAL_SYSTEM = LV_OWN_LOGSYS
        EXCEPTIONS
          OTHERS             = 0.
      LS_CRTOBD_LSG_ATTR_NAME_VALUE-ATTR_NAME  = LC_CRTOBD_LSG_TTE_LOGSYS.
      LS_CRTOBD_LSG_ATTR_NAME_VALUE-ATTR_VALUE = LV_OWN_LOGSYS.
      PERFORM FILL_ITEM_NAME_VALUE_TAB USING LS_CRTOBD_LSG_ATTR_NAME_VALUE
                                             GC_TRUE
                                       CHANGING LS_PRC_ITEM.
    ENDIF.
