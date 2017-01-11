FUNCTION-POOL bea_al_o.
************************************************************************
* Constants
************************************************************************
INCLUDE SBAL_CONSTANTS.
INCLUDE BEA_BASICS.
CONSTANTS: gc_alobject_bea       TYPE balobj_d    VALUE 'BEA',
           gc_alsubobject_crp    TYPE balsubobj   VALUE 'CRP',
           gc_alsubobject_no_crp TYPE balsubobj   VALUE 'NO_CRP',
           gc_alsubobject_dli    TYPE balsubobj   VALUE 'DLI'.
*-----------------------------------------------------------------------
* Real global variables
*-----------------------------------------------------------------------
DATA: gv_loghndl   TYPE balloghndl,
      gs_loghdr    TYPE bal_s_log.
data: gt_return    type beat_return.
data: gv_appl      TYPE fieldname.
