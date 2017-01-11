FUNCTION /1BEA/CRMB_DL_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_WITH_SERVICES) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_WITH_DOCFLOW) TYPE  BEA_BOOLEAN DEFAULT 'X'
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
* Time  : 13:53:10
*
*======================================================================
*====================================================================
* Definitionsteil
*====================================================================

*==================================================================
* Implementierungsteil
*==================================================================
  IF IV_WITH_SERVICES = GC_TRUE.
* save service data (if services are activated)
* Event DL_OSAV0
    INCLUDE %2f1BEA%2fX_CRMBDL_OSAV0PRCODL_SAV.
    INCLUDE %2f1BEA%2fX_CRMBDL_OSAV0PARODL_SAV.
    INCLUDE %2f1BEA%2fX_CRMBDL_OSAV0TXTODL_SAV.
    INCLUDE BETX_DRVODL_SAV.
  ENDIF.   "IF IV_WITH_SERVICES = GC_TRUE.
*--------------------------------------------------------------------
* Save Duelist Data
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_DL_P_POST' IN UPDATE TASK
         EXPORTING
            IT_DLI_WRK = GT_DLI_WRK.
*--------------------------------------------------------------------
* Save Application Log Data
*--------------------------------------------------------------------
  CALL FUNCTION 'BEA_AL_O_SAVE_MULTI'
    EXPORTING
      IT_LOGHNDL           = GT_LOGHNDL
   EXCEPTIONS
     ERROR_AT_SAVE        = 0
     OTHERS               = 0.
  CALL FUNCTION 'BEA_AL_O_DELETE'
    EXPORTING
      IT_BALHDR            = GT_BALHDR_DEL
    EXCEPTIONS
      NO_LOGS              = 0
      OTHERS               = 0.
*--------------------------------------------------------------------
* Save Document Flow Data
*--------------------------------------------------------------------
IF NOT IV_WITH_DOCFLOW IS INITIAL.
  CALL FUNCTION 'BEA_DFL_O_SAVE'.
ENDIF.
*--------------------------------------------------------------------
* Refresh global memory
*--------------------------------------------------------------------
  CALL FUNCTION '/1BEA/CRMB_DL_O_REFRESH'
         EXPORTING
           IV_WITH_SERVICES = IV_WITH_SERVICES
           IV_WITH_DOCFLOW  = IV_WITH_DOCFLOW.
  CASE IV_COMMIT_FLAG.
    WHEN GC_NOCOMMIT.
    WHEN GC_COMMIT_ASYNC.
      COMMIT WORK.
    WHEN GC_COMMIT_SYNC.
      COMMIT WORK AND WAIT.
  ENDCASE.
ENDFUNCTION.
