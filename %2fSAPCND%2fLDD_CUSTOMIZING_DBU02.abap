FUNCTION /SAPCND/DD_CUS_DD_T683S_SEL .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_APPLICATION) TYPE  /SAPCND/APPLICATION
*"     REFERENCE(I_DDPAT_TYPE) TYPE  /SAPCND/DDPAT_TYPE
*"     REFERENCE(I_BYPASSING_BUFFER) TYPE  /SAPCND/BOOLEAN OPTIONAL
*"     REFERENCE(I_SET_LOCKS) TYPE  /SAPCND/BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_SELECTION_RESULT) TYPE  /SAPCND/DD_T683S_T
*"  EXCEPTIONS
*"      EXC_LOCKING_FAILED
*"----------------------------------------------------------------------
*  lock the entries if requested
  IF I_SET_LOCKS = 'X'.
    CALL FUNCTION 'ENQUEUE_/SAPCND/E_DD683S'
         EXPORTING
              KAPPL          = I_APPLICATION
         EXCEPTIONS
              FOREIGN_LOCK   = 1
              SYSTEM_FAILURE = 2
              OTHERS         = 3.
    IF SY-SUBRC <> 0.
      RAISE EXC_LOCKING_FAILED.
    ENDIF.
  ENDIF.

* perfrom the select
  IF I_BYPASSING_BUFFER = 'X'.
    SELECT * FROM /SAPCND/DD_T683S BYPASSING BUFFER
                    INTO TABLE E_SELECTION_RESULT
                        WHERE KAPPL      EQ I_APPLICATION
                        AND   DDPAT_TYPE EQ I_DDPAT_TYPE.
  ELSE.

    SELECT * FROM /SAPCND/DD_T683S INTO TABLE E_SELECTION_RESULT
                            WHERE KAPPL      EQ I_APPLICATION
                            AND   DDPAT_TYPE EQ I_DDPAT_TYPE.
  ENDIF.

ENDFUNCTION.
