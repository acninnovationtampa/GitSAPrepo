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
* action profile determination
  DATA:
   LT_PPF_PROCS    TYPE BEAT_PPF_PROCS,
   LS_PPF_PROCS    TYPE BEAS_PPF_PROCS.

* start determination of action profiles
  CALL FUNCTION '/1BEA/CRMB_BD_PPF_O_PROCS_DET'
   EXPORTING
     IS_BDH       = IS_BDH
     IS_BTY       = IS_BTY
   IMPORTING
     ET_PPF_PROCS = LT_PPF_PROCS
     ET_RETURN    = ET_RETURN.

  LOOP AT LT_PPF_PROCS INTO LS_PPF_PROCS.

* create context
    CREATE OBJECT LO_CONTEXT.

* set context attributes
     LO_CONTEXT->APPLCTN = GC_PPFAPPL.
     LO_CONTEXT->NAME    = LS_PPF_PROCS.
     LO_CONTEXT->APPL    = LO_APPL_OBJECT.
     LO_CONTEXT->PARTNER = LO_PARTNER_COLL.

    LS_CONTEXT = LO_CONTEXT.
    APPEND LS_CONTEXT TO LT_CONTEXT.

  ENDLOOP.
