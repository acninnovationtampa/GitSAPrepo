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
* IF BILLING WITH REFERENCE THEN DOC FLOW ENTRY IS DELIVERY
  IF IS_DLI-BILL_RELEVANCE = gc_bill_rel_delivery OR
     IS_DLI-BILL_RELEVANCE = gc_bill_rel_deliv_ic OR
     IS_DLI-BILL_RELEVANCE = gc_bill_rel_dlv_tpop.
    IF NOT IS_DLI-P_SRC_HEADNO IS INITIAL.
      LS_DFL-DFL_PRE_KIND       = 'D'.
    ELSE.
      LS_DFL-DFL_PRE_KIND       = 'O'.
    ENDIF.
* IF BILLING WITHOUT REFERENCE THEN DOC FLOW ENTRY IS ORDER"
  ELSE.
    LS_DFL-DFL_PRE_KIND       = 'O'.
  ENDIF.
  LS_DFL-LOGSYS     = IS_DLI-LOGSYS.
  LS_DFL-OBJTYPE    = IS_DLI-OBJTYPE.
  LS_DFL-SRC_HEADNO = IS_DLI-SRC_HEADNO.
  LS_DFL-SRC_ITEMNO = IS_DLI-SRC_ITEMNO.
