FUNCTION /1BEA/CRMB_BD_MWC_O_VALIDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_BDOC_HEADER) TYPE  SMW3_FHD
*"     VALUE(IS_MESSAGE) TYPE  /1CRMG0/BEABILLDOCCRMB
*"     VALUE(IS_MESSAGE_EXT) TYPE  /1BEA/BS_CRMB_BD
*"  EXCEPTIONS
*"      TECHNICAL_ERROR
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
   LS_OPTION     TYPE SMW3FOPT.

 CALL METHOD CL_SMW_MFLOW=>PERS_VALIDATE
   EXPORTING
     BDOC_HEADER     = IS_BDOC_HEADER
     OPTIONS         = LS_OPTION
   CHANGING
     MESSAGE         = IS_MESSAGE
     MESSAGE_EXT     = IS_MESSAGE_EXT
   EXCEPTIONS
     TECHNICAL_ERROR = 1
     OTHERS          = 2.

 IF SY-SUBRC NE 0.
   RAISE TECHNICAL_ERROR.
 ENDIF.

ENDFUNCTION.
