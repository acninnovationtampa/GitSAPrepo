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
 IF IS_DLI-BILL_RELEVANCE = GC_BILL_REL_DELIVERY OR
    IS_DLI-BILL_RELEVANCE = GC_BILL_REL_DELIV_IC OR
    IS_DLI-BILL_RELEVANCE = GC_BILL_REL_DLV_TPOP.

    LRS_LOGSYS-SIGN   = GC_INCLUDE.
    LRS_LOGSYS-OPTION = GC_EQUAL.
    LRS_LOGSYS-LOW    = IS_DLI-P_LOGSYS.
    APPEND LRS_LOGSYS TO LRT_LOGSYS.
    LRS_OBJTYPE-SIGN   = GC_INCLUDE.
    LRS_OBJTYPE-OPTION = GC_EQUAL.
    LRS_OBJTYPE-LOW    = IS_DLI-P_OBJTYPE.
    APPEND LRS_OBJTYPE TO LRT_OBJTYPE.
    LRS_SRC_HEADNO-SIGN   = GC_INCLUDE.
    LRS_SRC_HEADNO-OPTION = GC_EQUAL.
    LRS_SRC_HEADNO-LOW    = IS_DLI-P_SRC_HEADNO.
    APPEND LRS_SRC_HEADNO TO LRT_SRC_HEADNO.
    LRS_SRC_ITEMNO-SIGN   = GC_INCLUDE.
    LRS_SRC_ITEMNO-OPTION = GC_EQUAL.
    LRS_SRC_ITEMNO-LOW    = IS_DLI-P_SRC_ITEMNO.
    APPEND LRS_SRC_ITEMNO TO LRT_SRC_ITEMNO.

*   GET DUE LIST ITEM OF THE ORIGINATING ORDER
    CALL FUNCTION '/1BEA/CRMB_DL_O_GETLIST'
      EXPORTING
        IRT_LOGSYS     = LRT_LOGSYS
        IRT_OBJTYPE     = LRT_OBJTYPE
        IRT_SRC_HEADNO     = LRT_SRC_HEADNO
        IRT_SRC_ITEMNO     = LRT_SRC_ITEMNO
      IMPORTING
        ET_DLI         = CT_DLI
        ES_RETURN      = LS_RETURN.

   IF LS_RETURN IS INITIAL.

     READ TABLE CT_DLI INTO LS_DLI
       WITH KEY
         LOGSYS = IS_DLI-P_LOGSYS
         OBJTYPE = IS_DLI-P_OBJTYPE
         SRC_HEADNO = IS_DLI-P_SRC_HEADNO
         SRC_ITEMNO = IS_DLI-P_SRC_ITEMNO.

     LS_DFL-LOGSYS             = LS_DLI-LOGSYS.
     LS_DFL-OBJTYPE            = LS_DLI-OBJTYPE.
     LS_DFL-SRC_HEADNO         = LS_DLI-SRC_HEADNO.
     LS_DFL-SRC_ITEMNO         = LS_DLI-SRC_ITEMNO.
     LS_DFL-SRC_PROCESS_TYPE   = LS_DLI-SRC_PROCESS_TYPE.
     LS_DFL-MAINT_DATE         = LS_DLI-SRC_DATE.
     LS_DFL-DFL_PRE_KIND       = 'O'.
     LS_DFL-BILL_RELEVANCE     = LS_DLI-BILL_RELEVANCE.
     IF GO_DFL_DATA IS INITIAL.
       CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
         EXPORTING
           EXIT_NAME              = GC_EXIT_DFL_DATA
           NULL_INSTANCE_ACCEPTED = ' '
        CHANGING
           INSTANCE               = GO_DFL_DATA
        EXCEPTIONS
           OTHERS = 1.
        LV_SUBRC = SY-SUBRC.
      ENDIF.
      IF LV_SUBRC = 0.
        CALL FUNCTION 'BEA_OBJ_O_GET_SCENARIO'
          EXPORTING
            IV_OBJTYPE        = LS_DFL-OBJTYPE
          IMPORTING
            EV_SCENARIO       = LV_FLT_VAL.
        IF NOT LV_FLT_VAL IS INITIAL.
          CALL METHOD GO_DFL_DATA->DATA_GET
            EXPORTING
              FLT_VAL           = LV_FLT_VAL
              IS_DFL            = LS_DFL
              IV_LEVEL          = IV_LEV
            IMPORTING
              ES_DFL            = LS_DFL.
         ENDIF.
       ENDIF.
      INSERT LS_DFL INTO TABLE CT_DFL.
      clear LS_DFL.
   ENDIF.
 ENDIF.
