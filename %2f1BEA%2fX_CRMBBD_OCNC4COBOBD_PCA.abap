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
 PERFORM corr_bill_cancel_check
   USING
     cs_bdh
     ct_bdi
   CHANGING
     cv_cancel_type
     ct_bd_guids_loc
     cv_returncode.