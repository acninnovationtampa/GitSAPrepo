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
     LS_PRCODL_000_CONDITION TYPE BEAS_DLI_PRC_COM,
     LS_PRCODL_000_PRC_COM   TYPE BEAS_PRC_COM.
   CLEAR CT_CONDITION.
   LOOP AT UT_CONDITION INTO LS_PRCODL_000_CONDITION
        WHERE PARENTRECNO = CV_TABIX_DLI.
     CLEAR LS_PRCODL_000_PRC_COM.
     MOVE-CORRESPONDING LS_PRCODL_000_CONDITION TO LS_PRCODL_000_PRC_COM.
     APPEND LS_PRCODL_000_PRC_COM TO CT_CONDITION.
   ENDLOOP.
