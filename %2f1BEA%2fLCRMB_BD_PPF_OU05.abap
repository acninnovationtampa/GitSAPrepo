FUNCTION /1BEA/CRMB_BD_PPF_O_PREVIEW.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"--------------------------------------------------------------------
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


CONSTANTS:
      lc_selname1 TYPE RSSCR_NAME VALUE 'S_APPL',
      lc_selname2 TYPE RSSCR_NAME VALUE 'S_APPKEY',
      lc_selname3 TYPE RSSCR_NAME VALUE 'P_COUNT',
      lc_selname4 TYPE RSSCR_NAME VALUE 'P_DPTC'.

DATA: ls_bdh      TYPE /1bea/s_CRMB_BDH_wrk,
      lt_seltab   TYPE TABLE OF rsparams,
      ls_seltab   TYPE rsparams,
      lv_applkey  TYPE ppfdappkey.



  ls_seltab-selname = lc_selname1.
  ls_seltab-kind    = gc_selkind_selopt.
  ls_seltab-sign    = gc_sign_include.
  ls_seltab-option  = gc_rangeoption_eq.
  ls_seltab-low     = gc_ppfappl.
  APPEND ls_seltab TO lt_seltab.

  LOOP AT it_bdh INTO ls_bdh.


    CALL FUNCTION 'BEA_PPF_O_GET_APPLKEY'
      EXPORTING
        iv_application = 'CRMB'
        iv_headno_ext  = ls_bdh-headno_ext
      IMPORTING
        ev_applkey     = lv_applkey.

    ls_seltab-selname = lc_selname2.
    ls_seltab-kind    = gc_selkind_selopt.
    ls_seltab-sign    = gc_sign_include.
    ls_seltab-option  = gc_rangeoption_eq.
    ls_seltab-low     = lv_applkey.
    APPEND ls_seltab TO lt_seltab.

  ENDLOOP.

  ls_seltab-selname = lc_selname3.
  ls_seltab-kind    = gc_selkind_param.
  ls_seltab-sign    = gc_sign_include.
  ls_seltab-option  = gc_rangeoption_eq.
  ls_seltab-low     = space.
  APPEND ls_seltab TO lt_seltab.

  ls_seltab-selname = lc_selname4.
  ls_seltab-kind    = gc_selkind_param.
  ls_seltab-sign    = gc_sign_include.
  ls_seltab-option  = gc_rangeoption_eq.
  ls_seltab-low     = space.
  APPEND ls_seltab TO lt_seltab.

  SUBMIT rsppfprocess WITH SELECTION-TABLE lt_seltab
                      AND RETURN.

ENDFUNCTION.
