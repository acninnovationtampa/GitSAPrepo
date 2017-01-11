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
*     reset net value for value based billing item
 IF ls_dli_wrk-bill_relevance = gc_bill_rel_value.
   ls_dli_wrk-net_value = ls_dli_wrk_old-net_value.
 ENDIF.
