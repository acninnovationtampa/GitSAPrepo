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
  IF GS_DETAIL-PRESSED_TAB = GC_DETAIL-TAB4.
      IF GS_SRV_PREPARED-TXT IS INITIAL.
        CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_READ'
          EXPORTING
            is_dli     = gs_dli
            IV_MODE    = GC_MODE-DISPLAY
          EXCEPTIONS
            error      = 1
            incomplete = 2
            OTHERS     = 3.
         IF sy-subrc <> 0.
           GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
           RETURN.
         ENDIF.
         CALL FUNCTION '/1BEA/CRMB_DL_TXT_O_PROVIDE'
           EXPORTING
             is_dli     = gs_dli
             IV_MODE    = GC_MODE-DISPLAY
           EXCEPTIONS
             error      = 1
             incomplete = 2
             OTHERS     = 3.
         IF sy-subrc <> 0.
           GS_DETAIL-PRESSED_TAB = GS_DETAIL-OLD_TAB.
           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
           RETURN.
         ENDIF.
         GS_SRV_PREPARED-TXT = GC_TRUE.
       ENDIF.
      GS_DETAIL-PROG = 'SAPLCOM_TEXT_MAINTENANCE'.
      GS_DETAIL-SUBSCREEN = '2100'.
  ENDIF.
