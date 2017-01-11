FUNCTION bea_crp_o_getlist.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IRT_APPL) TYPE  BEFRT_APPL OPTIONAL
*"     REFERENCE(IRT_CRP_GUID) TYPE  BEART_CRP_GUID OPTIONAL
*"     REFERENCE(IRT_TYPE) TYPE  BEART_CRP_TYPE OPTIONAL
*"     REFERENCE(IRT_NUMBER) TYPE  BEART_CRP_NUMBER OPTIONAL
*"     REFERENCE(IRT_ERRORS) TYPE  BEART_CRP_ERRORS OPTIONAL
*"     REFERENCE(IRT_DOCUMENTS) TYPE  BEART_CRP_DOCUMENTS OPTIONAL
*"     REFERENCE(IRT_DATE) TYPE  BEART_MAINT_DATE OPTIONAL
*"     REFERENCE(IRT_TIME) TYPE  BEART_MAINT_TIME OPTIONAL
*"     REFERENCE(IRT_USER) TYPE  BEART_MAINT_USER OPTIONAL
*"     REFERENCE(IV_MAXROWS) TYPE  BAPIMAXROW OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_CRP) TYPE  BEAT_CRP
*"----------------------------------------------------------------------


  SELECT * FROM bead_crp
           UP TO iv_maxrows ROWS
           INTO TABLE et_crp
           WHERE appl       IN irt_appl
             AND guid       IN irt_crp_guid
             AND type       IN irt_type
             AND cr_number  IN irt_number
             AND errors     IN irt_errors
             AND documents  IN irt_documents
             AND maint_date IN irt_date
             AND maint_time IN irt_time
             AND maint_user IN irt_user.

ENDFUNCTION.
