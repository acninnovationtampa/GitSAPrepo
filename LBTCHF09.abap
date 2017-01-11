***INCLUDE LBTCHF09 .

************************************************************************
* Hilfsroutinen des Funktionsbausteins BP_CHECK_REPORT_VALUES          *
************************************************************************

*---------------------------------------------------------------------*
*      FORM RAISE_CHKRP_EXCEPTION                                     *
*---------------------------------------------------------------------*
* Ausloesen einer Exception und Schreiben eines Syslogeintrages falls *
* der Funktionsbaustein BP_CHECK_REPORT_VALUES im Nichtdialogfall un- *
* gueltige Report- bzw. Variantenwerte entdeckt.                      *
* Falls der Parameter DATA ungleich SPACE ist enthält er Daten, die   *
* in den Syslogeintrag eingestreut werden koennen.                    *
*---------------------------------------------------------------------*

FORM RAISE_CHKRP_EXCEPTION USING EXCEPTION DATA.

  data: i_authcknam TYPE btcauthnam,
        i_report    type sy-repid.
*
* Kopfeintrag schreiben
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD INVALID_REPORT_VALUES_DETECTED.
*
* exceptionspezifischen Eintrag schreiben und Exception ausloesen
*
  CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
       ID 'KEY'  FIELD EXCEPTION
       ID 'DATA' FIELD DATA.

   CASE EXCEPTION.
     WHEN REPORT_NAME_MISSING.
          MESSAGE E079 RAISING REPORT_NAME_MISSING.
     WHEN INVALID_REPORT_NAME.
          MESSAGE E074 WITH data RAISING INVALID_REPORT_NAME.
     WHEN INVALID_VARIANT_NAME_ID.
          MESSAGE E075 WITH data RAISING INVALID_VARIANT_NAME.
     WHEN NO_PLAN_AUTHORITY.
          SPLIT data AT '&' INTO i_authcknam i_report.
          MESSAGE E107 WITH i_authcknam i_report RAISING NO_PLAN_AUTHORITY.
     WHEN NO_VARIANTS_DEFINED_ID.
          MESSAGE E078 WITH data RAISING NO_VARIANTS_DEFINED.
     WHEN REPORT_CAN_NOT_BE_SCHEDULED.
          MESSAGE E077 WITH data RAISING REPORT_CAN_NOT_BE_SCHEDULED.
     WHEN REPORT_HAS_NO_VARIANTS_ID.
          MESSAGE E078 WITH data RAISING REPORT_HAS_NO_VARIANTS.
     WHEN VARIANT_CHECK_HAS_FAILED.
          MESSAGE E080 RAISING VARIANT_CHECK_HAS_FAILED.
     WHEN VARIANT_NAME_MISSING_ID.
          MESSAGE E528 RAISING VARIANT_NAME_MISSING.
     WHEN INVALID_DIALOG_TYPE.
          MESSAGE E536 RAISING INVALID_DIALOG_TYPE.
     WHEN INVALID_CHECK_TYPE.
          MESSAGE E536 RAISING INVALID_CHECK_TYPE.
     WHEN SYNTAX_ERROR.
          MESSAGE E376 WITH data RAISING VARIANT_CHECK_HAS_FAILED.
     WHEN GENERATION_ERROR.
          MESSAGE E375 WITH data RAISING VARIANT_CHECK_HAS_FAILED.
     WHEN CATALOG_READ_ERROR.
          MESSAGE E076 WITH data RAISING VARIANT_CHECK_HAS_FAILED.
     WHEN OTHERS.
*
*      hier sitzen wir etwas in der Klemme: eine dieser Routine unbe-
*      kannte Exception innerhalb der Startterminpruefung soll ausge-
*      loest werden. Aus Verlegenheit wird INVALID_STEP_TYP ausge-
*      loest und die unbekannte Exception im Syslog vermerkt.
*
          CALL 'C_WRITE_SYSLOG_ENTRY' ID 'TYP' FIELD ' '
                ID 'KEY'  FIELD UNKNOWN_CHKRP_EXCEPTION
                ID 'DATA' FIELD EXCEPTION.
          MESSAGE E074 WITH data RAISING INVALID_REPORT_NAME.
  ENDCASE.

ENDFORM. " RAISE_CHKRP_EXCEPTION
