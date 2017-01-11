FUNCTION /1BEA/CRMB_BD_PPF_O_RENAME.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH) TYPE  /1BEA/S_CRMB_BDH_WRK
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
    LC_APPL           TYPE BEF_APPL VALUE 'CRMB'.
  DATA:

*   PPF-manager reference
    LO_MANAGER        TYPE REF TO CL_MANAGER_PPF,

*   application key of billing document
    LV_APPLKEY        TYPE PPFDAPPKEY.

  FIELD-SYMBOLS:
    <LS_PPF_CONTEXT> TYPE GS_PPF_CONTEXT.

  IF NOT GT_PPF_CONTEXT IS INITIAL.

* get manager instance
    LO_MANAGER = CL_MANAGER_PPF=>GET_INSTANCE( ).

* set application key for output in the actionlist
    CALL FUNCTION 'BEA_PPF_O_GET_APPLKEY'
      EXPORTING
        IV_APPLICATION      = LC_APPL
        IV_HEADNO_EXT       = IS_BDH-HEADNO_EXT
      IMPORTING
        EV_APPLKEY           = LV_APPLKEY.

    READ TABLE GT_PPF_CONTEXT
      WITH KEY BDH_GUID = IS_BDH-BDH_GUID
      BINARY SEARCH
      TRANSPORTING NO FIELDS.
    IF SY-SUBRC = 0.
      LOOP AT GT_PPF_CONTEXT ASSIGNING <LS_PPF_CONTEXT>
        FROM SY-TABIX
        WHERE BDH_GUID = IS_BDH-BDH_GUID.

        CALL METHOD LO_MANAGER->SET_APPLKEY
          EXPORTING
            IP_APPLKEY = LV_APPLKEY
            IO_CONTEXT = <LS_PPF_CONTEXT>-CONTEXT.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFUNCTION.
