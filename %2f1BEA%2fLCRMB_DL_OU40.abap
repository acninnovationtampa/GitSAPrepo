FUNCTION /1BEA/CRMB_DL_O_DLI_INV_SORT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
*"  EXPORTING
*"     REFERENCE(ET_DLI) TYPE  /1BEA/T_CRMB_DLI_WRK
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
 FIELD-SYMBOLS:
   <DLI>         TYPE /1BEA/S_CRMB_DLI_WRK.
 DATA:
   LT_DLI_WRK    TYPE /1BEA/T_CRMB_DLI_WRK.

 LT_DLI_WRK = IT_DLI.
 CLEAR ET_DLI.

 SORT LT_DLI_WRK BY
      DERIV_CATEGORY
      LOGSYS
      OBJTYPE
      SRC_HEADNO
      SRC_ITEMNO
      MAINT_DATE
      MAINT_TIME.

 LOOP AT LT_DLI_WRK ASSIGNING <DLI> WHERE
      NOT LOGSYS IS INITIAL AND
      NOT OBJTYPE IS INITIAL AND
      NOT SRC_HEADNO IS INITIAL AND
      NOT SRC_ITEMNO IS INITIAL.
   APPEND <DLI> TO ET_DLI.
 ENDLOOP.
 DELETE LT_DLI_WRK WHERE
      NOT LOGSYS IS INITIAL AND
      NOT OBJTYPE IS INITIAL AND
      NOT SRC_HEADNO IS INITIAL AND
      NOT SRC_ITEMNO IS INITIAL.

 SORT LT_DLI_WRK BY
    DERIV_CATEGORY
    LOGSYS
    OBJTYPE
    SRC_HEADNO
    SRC_ITEMNO.

 APPEND LINES OF LT_DLI_WRK TO ET_DLI.

ENDFUNCTION.
