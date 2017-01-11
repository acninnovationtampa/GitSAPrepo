FUNCTION /1BEA/CRMB_BD_PRC_O_IT_MAPOUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BDH_WRK) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(IS_BDI_WRK) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(IS_PRC_I_RET) TYPE  PRCT_ITEM_RET
*"  EXPORTING
*"     REFERENCE(ES_BDH_WRK) TYPE  /1BEA/S_CRMB_BDH_WRK
*"     REFERENCE(ES_BDI_WRK) TYPE  /1BEA/S_CRMB_BDI_WRK
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
    LS_BDH_WRK     TYPE /1BEA/S_CRMB_BDH_WRK,
    LS_BDI_WRK     TYPE /1BEA/S_CRMB_BDI_WRK,
    LS_PRC_I_RET   TYPE PRCT_ITEM_RET,
    LT_RETURN      TYPE BEAT_RETURN.

  LS_BDH_WRK   = IS_BDH_WRK.
  LS_BDI_WRK   = IS_BDI_WRK.
  LS_PRC_I_RET = IS_PRC_I_RET.

  MOVE LS_PRC_I_RET-NETWR TO LS_BDI_WRK-NET_VALUE.
  MOVE LS_PRC_I_RET-BRTWR TO LS_BDI_WRK-GROSS_VALUE.
  MOVE LS_PRC_I_RET-MWSBP TO LS_BDI_WRK-TAX_VALUE.


  IF NOT GV_MAPPING_EXIT IS INITIAL.
    CLEAR LT_RETURN.
    CALL BADI GV_MAPPING_EXIT->OUT_MAP_ITEM
      EXPORTING  IS_PRC_I_RET = LS_PRC_I_RET
      IMPORTING  ET_RETURN    = LT_RETURN
      CHANGING   CS_BDH       = LS_BDH_WRK
                 CS_BDI       = LS_BDI_WRK
      EXCEPTIONS REJECT       = 1.
    IF SY-SUBRC NE 0.
      APPEND LINES OF LT_RETURN TO ET_RETURN.
      MESSAGE E202(BEA_PRC) RAISING REJECT.
    ENDIF.
  ENDIF.

  ES_BDI_WRK = LS_BDI_WRK.
  ES_BDH_WRK = LS_BDH_WRK.

ENDFUNCTION.
