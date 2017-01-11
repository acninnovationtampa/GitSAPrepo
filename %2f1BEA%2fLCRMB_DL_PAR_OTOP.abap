FUNCTION-POOL /1BEA/CRMB_DL_PAR_O.          "MESSAGE-ID ..
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
TYPES:
  BEGIN OF GSY_DOC_ADDR,
        SRC_ADDR_NR TYPE AD_ADDRNUM,
        ADDR_NR     TYPE AD_ADDRNUM,
        ADDR_NP     TYPE AD_PERSNUM,
        ADDR_TYPE   TYPE AD_ADRTYPE,
  END OF GSY_DOC_ADDR.
TYPES:
  GTY_DOC_ADDR TYPE STANDARD TABLE OF GSY_DOC_ADDR.
DATA:
  GT_PARSETS_DEL TYPE BEAT_PARSET_GUID,
  GT_DOC_ADDR    TYPE GTY_DOC_ADDR.

CONSTANTS:
  GC_DOC_ADR TYPE COMT_ADDR_ORIGIN VALUE 'B',
  GC_REF_ADR TYPE COMT_ADDR_ORIGIN VALUE 'C',
  GC_SCOPE    TYPE COMT_PARTNER_PROC_SCOPE VALUE 'A'.

INCLUDE: BEA_PAR_PFT,
         BEA_BASICS.
