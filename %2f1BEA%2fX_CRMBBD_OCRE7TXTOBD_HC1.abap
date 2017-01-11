*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================
    IF LV_EQUAL = GC_FALSE. "no matching head has been found
*       find texts for the billing document head
      CALL FUNCTION '/1BEA/CRMB_BD_TXT_O_HD_CREATE'
           EXPORTING
             IS_BDH     = CS_BDH_WRK
             IS_BTY     = US_BTY_WRK
*          IMPORTING
*            ES_BDH     = CS_BDH_WRK
           EXCEPTIONS
             REJECT     = 1
             INCOMPLETE = 1
             OTHERS     = 1.
      IF SY-SUBRC <> 0.
        CS_BDH_WRK-TEXT_ERROR = GC_TRUE.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GV_DUMMY.
        CALL FUNCTION '/1BEA/CRMB_BD_O_MESSAGE_ADD'
          EXPORTING
            IV_OBJECT      = 'BD'
            IV_CONTAINER   = 'BDH'
            IS_BDH         = CS_BDH_WRK.
      ENDIF.
    ENDIF.
