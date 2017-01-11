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
 FORM PARODL_CRZ_PARTNER_FILL
   USING
     UT_PARTNER    TYPE BEAT_PAR_COM
     US_ITC        TYPE BEAS_ITC_WRK
     US_DLI_NV     TYPE /1BEA/S_CRMB_DLI_WRK
   CHANGING
     CS_DLI_WRK    TYPE /1BEA/S_CRMB_DLI_WRK
     CT_RETURN     TYPE BEAT_RETURN
     CV_RETURNCODE TYPE SYSUBRC.

   DATA:
     LS_DLI_WRK  TYPE /1BEA/S_CRMB_DLI_WRK,
     LT_DLI_PART TYPE /1BEA/T_CRMB_DLI_WRK.

   IF ( CS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_LEANBILLING OR
        CS_DLI_WRK-DERIV_CATEGORY = GC_DERIV_CONDITION ) AND
        CS_DLI_WRK-PARSET_GUID IS NOT INITIAL.
     CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DERIVE'
        EXPORTING
          IS_DLI          = CS_DLI_WRK
          IS_ITC          = US_ITC
        IMPORTING
          ES_DLI          = CS_DLI_WRK
        EXCEPTIONS
          REJECT          = 0
          OTHERS          = 0.
     RETURN.  "Partner will be inherited from main item
   ENDIF.
   CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_CREATE'
     EXPORTING
       IS_DLI     = CS_DLI_WRK
       IT_PAR_COM = UT_PARTNER
       IS_ITC     = US_ITC
     IMPORTING
       ES_DLI     = CS_DLI_WRK
       ET_RETURN  = CT_RETURN
     EXCEPTIONS
       REJECT     = 1
       OTHERS     = 2.
   IF SY-SUBRC <> 0.
     CV_RETURNCODE = SY-SUBRC.
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

   LOOP AT GT_DLI_WRK INTO LS_DLI_WRK WHERE
              DERIV_CATEGORY = CS_DLI_WRK-DERIV_CATEGORY AND
              LOGSYS = CS_DLI_WRK-LOGSYS AND
              OBJTYPE = CS_DLI_WRK-OBJTYPE AND
              SRC_HEADNO = CS_DLI_WRK-SRC_HEADNO
          AND UPD_TYPE  <> GC_DELETE.
     INSERT LS_DLI_WRK INTO TABLE LT_DLI_PART.
   ENDLOOP.
   IF NOT US_DLI_NV IS INITIAL.
     INSERT US_DLI_NV INTO TABLE LT_DLI_PART.
   ENDIF.
   IF NOT LT_DLI_PART IS INITIAL.
     CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_COMPRESS'
       EXPORTING
         IS_DLI      = CS_DLI_WRK
         IT_DLI_PART = LT_DLI_PART
       IMPORTING
         ES_DLI      = CS_DLI_WRK
       EXCEPTIONS
         REJECT      = 0
         OTHERS      = 0.
   ENDIF.
 ENDFORM.
