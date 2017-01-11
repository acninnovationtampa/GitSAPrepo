FUNCTION-POOL bea_crp_o.               "MESSAGE-ID ..

INCLUDE BEA_BASICS.

CONSTANTS:
  gc_nr_beacrp      TYPE nrobj VALUE 'BEACOLLRUN',
  gc_nr_interval_01 TYPE nrnr  VALUE '01'.

DATA: gs_crp TYPE beas_crp.
