FUNCTION /1BEA/CRMB_BD_O_ADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PROCESS_MODE) TYPE  BEA_PROCESS_MODE DEFAULT 'B'
*"     REFERENCE(IV_COMMIT_FLAG) TYPE  BEF_COMMIT OPTIONAL
*"     REFERENCE(IV_NO_PPF) TYPE  BEA_BOOLEAN OPTIONAL
*"     REFERENCE(IV_DL_WITH_SERVICES) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_WITH_DOCFLOW) TYPE  BEA_BOOLEAN DEFAULT 'X'
*"     REFERENCE(IV_DLI_NO_SAVE) TYPE  BEA_BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"     REFERENCE(ET_SUCCESS) TYPE  BEAT_RETURN
*"     REFERENCE(ET_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(ET_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
* Time  : 13:52:50
*
*======================================================================

  CHECK NOT IV_PROCESS_MODE = GC_PROC_NOADD.

*====================================================================
* Call the SAVE-Method
*====================================================================
* test again and again
  IF IV_PROCESS_MODE = GC_PROC_ADD.
    IF ET_BDH IS SUPPLIED OR
       ET_BDI IS SUPPLIED.
      CALL FUNCTION '/1BEA/CRMB_BD_O_SAVE'
        EXPORTING
          IV_COMMIT_FLAG      = IV_COMMIT_FLAG
          IV_NO_PPF           = IV_NO_PPF
          IV_DL_WITH_SERVICES = IV_DL_WITH_SERVICES
          IV_WITH_DOCFLOW     = IV_WITH_DOCFLOW
          IV_DLI_NO_SAVE      = IV_DLI_NO_SAVE
          IT_RETURN           = ET_RETURN
        IMPORTING
          ET_BDH              = ET_BDH
          ET_BDI              = ET_BDI.
    ELSE.
      CALL FUNCTION '/1BEA/CRMB_BD_O_SAVE'
        EXPORTING
          IV_COMMIT_FLAG      = IV_COMMIT_FLAG
          IV_NO_PPF           = IV_NO_PPF
          IV_DL_WITH_SERVICES = IV_DL_WITH_SERVICES
          IV_WITH_DOCFLOW     = IV_WITH_DOCFLOW
          IV_DLI_NO_SAVE      = IV_DLI_NO_SAVE
          IT_RETURN           = ET_RETURN.
    ENDIF.
  ENDIF.

ENDFUNCTION.
