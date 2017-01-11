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
 FORM PRCODL_CRZ_PRC_FILL_BY_CRE
   USING
     US_DLI_INT         TYPE /1BEA/S_CRMB_DLI_INT
     UT_CONDITION       TYPE BEAT_PRC_COM
     US_ITC             TYPE BEAS_ITC_WRK
     UV_BILLED_QUANTITY TYPE BEA_QUANTITY
   CHANGING
     CS_DLI_WRK         TYPE /1BEA/S_CRMB_DLI_WRK
     CT_RETURN          TYPE BEAT_RETURN.

 DATA:
   LV_CONDITION_SPLIT TYPE BEA_BOOLEAN,
   LS_ITC             TYPE BEAS_ITC_WRK.
 DATA:
   LV_ORBWPDQ    TYPE BEA_BOOLEAN.
 STATICS:
   LV_OWN_LOGSYS TYPE LOGSYS.
 LS_ITC = US_ITC.
 IF LV_OWN_LOGSYS IS INITIAL.
   CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
     IMPORTING
       OWN_LOGICAL_SYSTEM                   = LV_OWN_LOGSYS.
 ENDIF.
 IF
    CS_DLI_WRK-P_LOGSYS IS INITIAL AND
    CS_DLI_WRK-P_OBJTYPE IS INITIAL AND
    CS_DLI_WRK-P_SRC_HEADNO IS INITIAL AND
    CS_DLI_WRK-P_SRC_ITEMNO IS INITIAL
    .
    IF US_DLI_INT-REF_QTY_UNIT = CS_DLI_WRK-QTY_UNIT.
      IF ABS( US_DLI_INT-REF_QUANTITY ) NE ABS( CS_DLI_WRK-QUANTITY ).
        LV_ORBWPDQ = GC_TRUE.
      ENDIF.
    ENDIF.
 ENDIF.
 IF LV_OWN_LOGSYS EQ CS_DLI_WRK-LOGSYS.
   IF CS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_ORIGIN.
     IF UV_BILLED_QUANTITY IS INITIAL AND
        LV_ORBWPDQ         = GC_FALSE AND
        LV_CONDITION_SPLIT = GC_FALSE AND
        NOT US_DLI_INT-SRC_PRIDOC_GUID IS INITIAL.
       CS_DLI_WRK-SRVDOC_SOURCE = 'A'.
       MOVE US_DLI_INT-SRC_PRIDOC_GUID TO CS_DLI_WRK-PRIDOC_GUID.
       RETURN.
     ELSE.
       IF NOT US_DLI_INT-SRC_PRIDOC_GUID IS INITIAL.
         CALL FUNCTION 'BEA_PRC_O_GET_PROC'
           EXPORTING
             IV_PRIDOC_GUID = US_DLI_INT-SRC_PRIDOC_GUID
           IMPORTING
             EV_PRIC_PROC   = LS_ITC-DLI_PRC_PROC.
       ENDIF.
       CLEAR CS_DLI_WRK-SRVDOC_SOURCE.
     ENDIF.
   ENDIF.
 ENDIF.
 IF CS_DLI_WRK-DERIV_CATEGORY = gc_deriv_leanbilling.
   CS_DLI_WRK-SRVDOC_SOURCE = 'A'.
*  Service Contracts: Reference is taken over during derivation
*  Financial Service: Pricing will be created during billing process
   RETURN.
 ENDIF.
 PERFORM PRICING_FILL
   USING
     US_DLI_INT
     UT_CONDITION
     LS_ITC
   CHANGING
     CS_DLI_WRK
     CT_RETURN.
 ENDFORM.

*--------------------------------------------------------------------*
*      Form  Pricing_Fill
*--------------------------------------------------------------------*
 FORM PRICING_FILL
   USING
     US_DLI_INT    TYPE /1BEA/S_CRMB_DLI_INT
     UT_CONDITION  TYPE BEAT_PRC_COM
     US_ITC        TYPE BEAS_ITC_WRK
   CHANGING
     CS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
     CT_RETURN     TYPE BEAT_RETURN.

   DATA:
     LS_REF_QUANTITY    TYPE BEAS_REF_QUANTITY,
     LV_EXT_COND_SUPPLY TYPE BEA_BOOLEAN.


   LS_REF_QUANTITY-REF_QUANTITY = US_DLI_INT-REF_QUANTITY.
   LS_REF_QUANTITY-REF_QTY_UNIT = US_DLI_INT-REF_QTY_UNIT.

   CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_CREATE'
     EXPORTING
       IS_DLI             = CS_DLI_WRK
       IS_ITC             = US_ITC
       IT_COND_COM        = UT_CONDITION
       IS_REF_QUANTITY    = LS_REF_QUANTITY
     IMPORTING
       ES_DLI      = CS_DLI_WRK
       ET_RETURN   = CT_RETURN
     EXCEPTIONS
       REJECT      = 1
       OTHERS      = 2.
   IF SY-SUBRC <> 0.
     CS_DLI_WRK-INCOMP_ID = GC_INCOMP_FATAL.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
     CALL FUNCTION '/1BEA/CRMB_DL_O_MESSAGE_ADD'
       EXPORTING
         IV_CONTAINER   = 'DLI'
         IS_DLI_WRK     = CS_DLI_WRK
         IT_RETURN      = CT_RETURN
       IMPORTING
         ET_RETURN      = CT_RETURN.
   ENDIF.
 ENDFORM.
