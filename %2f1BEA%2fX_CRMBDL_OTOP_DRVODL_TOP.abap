*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:53:10
*
*======================================================================

  TYPES: BEGIN OF GSY_UPD_STATUS_1O,
    BILL_RELEVANCE TYPE BEA_BILL_RELEVANCE,
    SRC_HEADNO     TYPE BEA_SRC_HEADNO.
    INCLUDE STRUCTURE CRMT_ORDER_QTY_TO_BILL.
  TYPES END OF GSY_UPD_STATUS_1O.
  DATA:
    GT_UPD_STATUS_1O TYPE STANDARD TABLE OF GSY_UPD_STATUS_1O.
