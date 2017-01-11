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
  IF GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB3.
      IF GS_SRV_PREPARED-PRC IS INITIAL.
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
            MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            RETURN.
          ENDIF.
        ENDIF.
        CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_DERIVE'
          EXPORTING
            IS_DLI          = GS_DLI
            IS_ITC          = GS_ITC_WRK
          IMPORTING
            ES_DLI          = GS_DLI
          EXCEPTIONS
            REJECT          = 1
            OTHERS          = 2.
        IF SY-SUBRC <> 0.
          GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          RETURN.
        ENDIF.
* Begin of pricing-session
        CALL FUNCTION '/1BEA/CRMB_DL_PRC_O_OPEN'
          EXPORTING
            IS_DLI            = GS_DLI
            IS_ITC            = GS_ITC_WRK
            IV_WRITE_MODE     = GC_FALSE
          IMPORTING
            EV_SESSION_ID     = GV_PRC_SESSION_ID
          EXCEPTIONS
            REJECT              = 1
            OTHERS              = 2.
        IF SY-SUBRC <> 0.
          GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          RETURN.
        ENDIF.
        CALL FUNCTION 'BEA_PRC_U_SET_PD'
          EXPORTING
            IV_PRC_SESSION_ID    = GV_PRC_SESSION_ID
            IV_PD_ITEM_NO        = GS_DLI-DLI_GUID
            IV_NO_EDIT           = 'X'.
        GS_SRV_PREPARED-PRC = GC_TRUE.
      ENDIF.
      GS_DETAIL-PROG = 'SAPLBEA_PRC_U'.
      GS_DETAIL-SUBSCREEN = '1000'.
   ENDIF.
