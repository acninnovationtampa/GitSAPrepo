*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================

**************************************************************
* FORM corr_bill_cancel_check
*
* Cancellation check for differential billing:
* An item subject to differential billing may only be cancelled
* if it is the last BDI in its difference group.
* Dependent items (correction and clearing items) must not
* be cancelled if the check for their parent item fails.
*
**************************************************************
FORM corr_bill_cancel_check
  USING
    IS_BDH          TYPE /1BEA/S_CRMB_BDH_WRK
    IT_BDI          TYPE /1BEA/T_CRMB_BDI_WRK
  CHANGING
    CV_CANCEL_TYPE  TYPE CHAR1
    ct_bd_guids_loc TYPE beat_bd_guids
    cv_returncode   TYPE sysubrc.   "#EC NEEDED

  DATA:
   lv_cancel_type  TYPE char1,
   ls_bd_guids     TYPE beas_bd_guids,
   lt_bd_guids     TYPE beat_bd_guids,
   ls_bdi_wrk      TYPE /1bea/s_CRMB_BDI_wrk,
   ls_bdi_child    TYPE /1bea/s_CRMB_BDI_wrk,
   ls_bdi_succ     TYPE /1bea/s_CRMB_BDI_wrk,
   ls_bdh_succ     TYPE /1bea/s_CRMB_BDH_wrk.

  BREAK-POINT ID BEA_DIFFINV.

  lv_cancel_type = cv_cancel_type.
  IF cv_cancel_type = gc_cancel_partial.
    lt_bd_guids = ct_bd_guids_loc.
  ELSE.
*   prepare for negative check result, i.e. for
*   partial cancellation: fill lt_bd_guids
    LOOP AT it_bdi INTO ls_bdi_wrk.
      MOVE-CORRESPONDING ls_bdi_wrk TO ls_bd_guids.
      APPEND ls_bd_guids TO lt_bd_guids.
    ENDLOOP.
  ENDIF.


  LOOP AT it_bdi INTO ls_bdi_wrk
    WHERE reversal    IS INITIAL
      AND is_reversed = gc_is_reved_by_corr.

    CLEAR:
      ls_bdh_succ,
      ls_bdi_succ.
    IF cv_cancel_type = gc_cancel_partial.
      READ TABLE lt_bd_guids WITH KEY
        bdh_guid = is_bdh-bdh_guid
        bdi_guid = ls_bdi_wrk-bdi_guid
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.
    PERFORM corr_bill_getdisucc
      USING
        is_bdh
        ls_bdi_wrk
      CHANGING
        ls_bdh_succ
        ls_bdi_succ.

    IF NOT ls_bdi_succ IS INITIAL.
*   This BDI has a successor and must not be cancelled
*   -> delete BDI and dependent items from
*   ct_bd_guids_loc and set cancel_type = 'partial'
      MESSAGE e401(crm_ipm_bea)
        WITH is_bdh-headno_ext ls_bdi_wrk-itemno_ext
             ls_bdh_succ-headno_ext ls_bdi_succ-itemno_ext
        INTO gv_dummy.
      CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
        EXPORTING
           iv_object    = 'BD'
          iv_container = 'BDI'
          is_bdi       = ls_bdi_wrk.

*     handle all dependent items, regardless of the
*     type of relation to the parent
      LOOP AT it_bdi INTO ls_bdi_child
        WHERE parent_itemno   = ls_bdi_wrk-itemno_ext.
        DELETE lt_bd_guids
          WHERE bdi_guid = ls_bdi_child-bdi_guid.
        MESSAGE e402(crm_ipm_bea)
                WITH is_bdh-headno_ext ls_bdi_child-itemno_ext
                     ls_bdi_child-parent_itemno
                INTO gv_dummy.
        CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
          EXPORTING
            iv_object    = 'BD'
            iv_container = 'BDI'
            is_bdi       = ls_bdi_child.
      ENDLOOP.
      DELETE lt_bd_guids
        WHERE bdi_guid = ls_bdi_wrk-bdi_guid.
      lv_cancel_type = gc_cancel_partial.
    ENDIF. "IF NOT ls_bdi_succ IS INITIAL

  ENDLOOP. "AT it_bdi INTO ls_bdi_wrk

  IF lv_cancel_type = gc_cancel_partial.
*   return the IDs of the BDIs for which
*   cancellation is OK as far as differential billing
*   is concerned
    ct_bd_guids_loc = lt_bd_guids.
  ENDIF.
  cv_cancel_type = lv_cancel_type.

ENDFORM.

*************************************************************
* FORM corr_bill_getdisucc
*
* Get successor for BDI with differential invoicing
*
*************************************************************
FORM corr_bill_getdisucc
    USING
      is_bdh           TYPE /1BEA/S_CRMB_BDH_WRK
      is_bdi           TYPE /1BEA/S_CRMB_BDI_WRK
    CHANGING
      cs_bdh_succ      TYPE /1BEA/S_CRMB_BDH_WRK
      cs_bdi_succ      TYPE /1BEA/S_CRMB_BDI_WRK.

  DATA:
    lrs_bdh_cancel_flag TYPE bears_cancel_flag,
    lrt_bdh_cancel_flag TYPE beart_cancel_flag,
    lrs_bdh_bill_category TYPE bears_bill_category,
    lrt_bdh_bill_category TYPE beart_bill_category,
    lrs_bdi_logsys      TYPE /1BEA/RS_CRMB_LOGSYS,
    lrt_bdi_logsys      TYPE /1BEA/RT_CRMB_LOGSYS,
    lrs_bdi_objtype     TYPE /1BEA/RS_CRMB_OBJTYPE,
    lrt_bdi_objtype     TYPE /1BEA/RT_CRMB_OBJTYPE,
    lrs_bdi_src_headno  TYPE /1BEA/RS_CRMB_SRC_HEADNO,
    lrt_bdi_src_headno  TYPE /1BEA/RT_CRMB_SRC_HEADNO,
    lrs_bdi_src_itemno  TYPE /1BEA/RS_CRMB_SRC_ITEMNO,
    lrt_bdi_src_itemno  TYPE /1BEA/RT_CRMB_SRC_ITEMNO,
    ls_bdi_wrk          TYPE /1BEA/S_CRMB_BDI_WRK,
    lt_bdi_wrk          TYPE /1BEA/T_CRMB_BDI_WRK,
    lt_bdh_wrk          TYPE /1BEA/T_CRMB_BDH_WRK.

  CLEAR: cs_bdi_succ,
         cs_bdh_succ.

* Check: BDI is not a cancellation or correction item
  CHECK is_bdi-reversal IS INITIAL.

* Check: BDI has ever been reversed and not yet cancelled
* (Cancellation of the successor does NOT reset
* the IS_REVERSED flag in the predecessor)
  CHECK is_bdi-is_reversed = gc_is_reved_by_corr.

   lrs_bdh_cancel_flag-sign      = gc_include.
   lrs_bdh_cancel_flag-option    = gc_equal.
   APPEND lrs_bdh_cancel_flag TO lrt_bdh_cancel_flag.

   lrs_bdh_bill_category-sign    = gc_include.
   lrs_bdh_bill_category-option  = gc_equal.
   lrs_bdh_bill_category-low     = is_bdh-bill_category.
   APPEND lrs_bdh_bill_category TO lrt_bdh_bill_category.

   lrs_bdi_logsys-sign           = gc_include.
   lrs_bdi_logsys-option         = gc_equal.
   lrs_bdi_logsys-low            = is_bdi-logsys.
   APPEND lrs_bdi_logsys to lrt_bdi_logsys.

   lrs_bdi_objtype-sign          = gc_include.
   lrs_bdi_objtype-option        = gc_equal.
   lrs_bdi_objtype-low           = is_bdi-objtype.
   APPEND lrs_bdi_objtype to lrt_bdi_objtype.

   lrs_bdi_src_headno-sign       = gc_include.
   lrs_bdi_src_headno-option     = gc_equal.
   lrs_bdi_src_headno-low        = is_bdi-src_headno.
   APPEND lrs_bdi_src_headno to lrt_bdi_src_headno.

   lrs_bdi_src_itemno-sign       = gc_include.
   lrs_bdi_src_itemno-option     = gc_equal.
   lrs_bdi_src_itemno-low        = is_bdi-src_itemno.
   APPEND lrs_bdi_src_itemno to lrt_bdi_src_itemno.

* Select potential successors from database
  CALL FUNCTION '/1BEA/CRMB_BD_O_GETLIST'
    EXPORTING
      IRT_BDH_BILL_CATEGORY = lrt_bdh_bill_category
      IRT_BDH_CANCEL_FLAG   = lrt_bdh_cancel_flag
      IRT_BDI_LOGSYS        = lrt_bdi_logsys
      IRT_BDI_OBJTYPE       = lrt_bdi_objtype
      IRT_BDI_SRC_HEADNO    = lrt_bdi_src_headno
      IRT_BDI_SRC_ITEMNO    = lrt_bdi_src_itemno
    IMPORTING
      ET_BDI                = lt_bdi_wrk
      ET_BDH                = lt_bdh_wrk.

* Check correction items referring to the same BRI
  READ TABLE lt_bdi_wrk INTO ls_bdi_wrk
    WITH KEY
      logsys       = is_bdi-logsys
      objtype      = is_bdi-objtype
      src_headno   = is_bdi-src_headno
      src_itemno   = is_bdi-src_itemno
      reversal     = gc_reversal_correc
      is_reversed  = space. "not cancelled

* If there is no correction item, or if all
* correction items have been cancelled,
* then is_bdi has no valid successor

  IF sy-subrc = 0.
* Return parent_item of the relevant correction item
    READ TABLE lt_bdi_wrk INTO cs_bdi_succ
      WITH KEY
        bdh_guid   = ls_bdi_wrk-bdh_guid
        itemno_ext = ls_bdi_wrk-parent_itemno.
    IF NOT cs_bdi_succ IS INITIAL.
      READ TABLE lt_bdh_wrk INTO cs_bdh_succ
        WITH KEY
          bdh_guid = cs_bdi_succ-bdh_guid.
    ENDIF.
  ENDIF.

ENDFORM.
