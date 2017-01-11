*--------------------------------------------------------------------
* Refresh CRM Transactions if billing documents are intialized only;
* In case a rejection or deletion is triggered from the order, the
* refresh must not happen, because otherwise the status update of
* the order in FM CRM_UPLEAD_BEA_FILL will fail.
*--------------------------------------------------------------------
   IF IV_DLI_NO_SAVE IS INITIAL.
     CALL FUNCTION 'BEA_CSA_O_REFRESH'.
   ENDIF.
