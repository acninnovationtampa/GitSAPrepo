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
   DATA:
     LS_PARODL_000_PARTNER TYPE BEAS_DLI_PAR_COM,
     LS_PARODL_000_PAR_COM TYPE BEAS_PAR_COM.
   CLEAR CT_PARTNER.
   LOOP AT UT_PARTNER INTO LS_PARODL_000_PARTNER
        WHERE PARENTRECNO = CV_TABIX_DLI.
     CLEAR LS_PARODL_000_PAR_COM.
     MOVE-CORRESPONDING LS_PARODL_000_PARTNER TO LS_PARODL_000_PAR_COM.
     APPEND LS_PARODL_000_PAR_COM TO CT_PARTNER.
   ENDLOOP.
