FUNCTION /1BEA/CRMB_BD_TXT_O_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_BDH) TYPE  /1BEA/T_CRMB_BDH_WRK
*"     REFERENCE(IT_BDI) TYPE  /1BEA/T_CRMB_BDI_WRK
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
  DATA:
    LS_BDH     TYPE /1BEA/S_CRMB_BDH_WRK,
    LT_BDH     TYPE /1BEA/T_CRMB_BDH_WRK,
    LS_BDI     TYPE /1BEA/S_CRMB_BDI_WRK,
    LT_BDI     TYPE /1BEA/T_CRMB_BDI_WRK.

  LOOP AT IT_BDH INTO LS_BDH
    WHERE NOT UPD_TYPE IS INITIAL.

    INSERT LS_BDH INTO TABLE LT_BDH.
  ENDLOOP.

  LOOP AT IT_BDI INTO LS_BDI
    WHERE NOT UPD_TYPE IS INITIAL.

    INSERT LS_BDI INTO TABLE LT_BDI.
  ENDLOOP.

* SAVE texts for BD heads
  CALL FUNCTION 'BEA_TXT_O_SAVE'
       EXPORTING
            IT_STRUC    = LT_BDH
            IV_TDOBJECT = GC_BDH_TXTOBJ
            IV_TYPENAME = GC_TYPENAME_BDH_WRK
            IV_APPL     = GC_APPL
       EXCEPTIONS
            ERROR       = 0
            OTHERS      = 0.
* do not react on errors from SAVE

* SAVE texts for BD items
  CALL FUNCTION 'BEA_TXT_O_SAVE'
       EXPORTING
            IT_STRUC    = LT_BDI
            IV_TDOBJECT = GC_BDI_TXTOBJ
            IV_TYPENAME = GC_TYPENAME_BDI_WRK
            IV_APPL     = GC_APPL
       EXCEPTIONS
            ERROR       = 0
            OTHERS      = 0.
* do not react on errors from SAVE

ENDFUNCTION.
