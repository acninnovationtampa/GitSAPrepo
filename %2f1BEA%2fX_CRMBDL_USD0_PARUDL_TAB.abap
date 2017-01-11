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
* treat tab click
  IF GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB2.
      IF GS_SRV_PREPARED-PAR IS INITIAL.
        IF ( GS_DLI-ITEM_CATEGORY <> GS_ITC_WRK-ITEM_CATEGORY ) OR
           ( GS_ITC_WRK IS INITIAL ).
          CALL FUNCTION 'BEA_ITC_O_GETDETAIL'
            EXPORTING
              IV_APPL                = GC_APPL
              IV_ITC                 = GS_DLI-ITEM_CATEGORY
            IMPORTING
              ES_ITC_WRK             = GS_ITC_WRK
            EXCEPTIONS
              OBJECT_NOT_FOUND       = 1
              OTHERS                 = 2.
           IF SY-SUBRC <> 0.
             GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             RETURN.
           ENDIF.
         ENDIF.
         CALL FUNCTION 'BEA_PAR_U_DISPLAY'
           EXPORTING
             IV_PARSET_GUID             = gs_dli-parset_guid
             IV_PAR_PROCEDURE           = GS_ITC_WRK-DLI_PAR_PROC
             IV_OBJTYPE                 = GC_BOR_DLI
           EXCEPTIONS
             REJECT                     = 1
             OTHERS                     = 2.
         IF SY-SUBRC <> 0.
           GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           RETURN.
         ENDIF.
         GS_SRV_PREPARED-PAR = GC_TRUE.
       ENDIF.
      GS_DETAIL-PROG = 'SAPLCOM_PARTNER_UI2'.
      GS_DETAIL-SUBSCREEN = '2000'.
   ENDIF.
