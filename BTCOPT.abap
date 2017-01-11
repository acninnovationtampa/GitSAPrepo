*&---------------------------------------------------------------------*
*&  Include           BTCOPT
*&---------------------------------------------------------------------*

CONSTANTS: btc_opt_weak_immstart TYPE btcoptions-btcoption  "note 564391
           VALUE 'WEAK_IMMSTART'.

CONSTANTS: btc_opt_weak_evtstart TYPE btcoptions-btcoption  "note 564391
           VALUE 'WEAK_EVTSTART'.

CONSTANTS: btc_opt_wizard_auth TYPE btcoptions-btcoption  "note 568963
           VALUE 'WIZARD_AUTH'.

CONSTANTS: btc_opt_logcomm_authcheck TYPE btcoptions-btcoption "n 854060
           VALUE 'LOGCOMM_AUTHCHECK'.

CONSTANTS: btc_opt_extprog_authcheck TYPE btcoptions-btcoption "n 859104
           VALUE 'EXTPROG_AUTHCHECK'.

CONSTANTS: btc_opt_var_nodisplay TYPE btcoptions-btcoption  "n 1363273
           VALUE 'VAR_NODISPLAY'.

CONSTANTS: btc_opt_smx_own_client TYPE btcoptions-btcoption "n 1458243
           VALUE 'SMX_OWN_CLIENT'.

CONSTANTS: sxbp_opt_error_handling TYPE btcoptions-btcoption "n 1515739
           VALUE 'XBP_2_ERROR_HANDLING'.
* macros
DEFINE get_option.

  clear &2.
  refresh &2.
  clear &3.

  call function 'BTC_OPTION_GET'
    exporting
      name               = &1
*   IMPVALUE1          =
*   IMPVALUE2          =
* IMPORTING
*   COUNT              =
   tables
     options            = &2
   exceptions
     invalid_name       = 1
     others             = 2
            .

  read table &2 index 1 into &3.

END-OF-DEFINITION.
