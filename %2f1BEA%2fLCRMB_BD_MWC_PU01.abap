FUNCTION /1BEA/CRMB_BD_MWC_P_POST.
*"--------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_MESSAGE) TYPE  /1CRMG0/BEABILLDOCCRMB
*"     VALUE(IS_MESSAGE_D) TYPE  /1CRMG0/BEABILLDLVCRMB
*"     VALUE(IS_BDOC) TYPE  /1BEA/BS_CRMB_BD
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
  CONSTANTS:
    LC_BDOC_TYPE   TYPE SMOG_GNAME    VALUE 'BEABILLDOCCRMB',
    LC_DOWNL_OBJ   TYPE SMO_OBJNAM    VALUE 'BEABILLDOCCRMB',
    LC_BDOC_TYPE_D TYPE SMOG_GNAME    VALUE 'BEABILLDLVCRMB',
    LC_DOWNL_OBJ_D TYPE SMO_OBJNAM    VALUE 'BEABILLDLVCRMB'.
  DATA:
    LS_BDOC        TYPE /1BEA/BS_CRMB_BD,
    LV_TRANS_MSG   TYPE /1CRMG0/BEABILLDOCCRMB,
    LV_TRANS_MSG_D TYPE /1CRMG0/BEABILLDLVCRMB,
    LS_BDOC_HEAD   TYPE SMW3_FHD,
    LS_OPTION      TYPE SMW3FOPT.

*---------------------------------------------------------------------
* CALLING MIDDLEWARE-FLOW
*---------------------------------------------------------------------

 LV_TRANS_MSG   = IS_MESSAGE.
 LV_TRANS_MSG_D = IS_MESSAGE_D.
 LS_BDOC        = IS_BDOC.

  CALL METHOD CL_SMW_MFLOW=>PROCESS_OUTBOUND
    EXPORTING
      BDOC_TYPE            = LC_BDOC_TYPE
      DOWNLOAD_OBJECT_NAME = LC_DOWNL_OBJ
      IN_UPDATETASK        = SPACE
      __SYNCHMODE          = 'X'     "GC_TRUE
    IMPORTING
      HEADER               = LS_BDOC_HEAD
    CHANGING
      MESSAGE              = LV_TRANS_MSG
      MESSAGE_EXT          = LS_BDOC
    EXCEPTIONS
      TECHNICAL_ERROR      = 0
      OTHERS               = 0.
  CLEAR LS_BDOC_HEAD.
  CALL METHOD CL_SMW_MFLOW=>PROCESS_OUTBOUND
    EXPORTING
      BDOC_TYPE            = LC_BDOC_TYPE_D
      DOWNLOAD_OBJECT_NAME = LC_DOWNL_OBJ_D
      IN_UPDATETASK        = SPACE
      __SYNCHMODE          = 'X'      "GC_TRUE
    IMPORTING
      HEADER               = LS_BDOC_HEAD
    CHANGING
      MESSAGE              = LV_TRANS_MSG_D
      MESSAGE_EXT          = LS_BDOC
    EXCEPTIONS
      TECHNICAL_ERROR      = 0
      OTHERS               = 0.
* validation flow - send message to source applications
  CLEAR LS_BDOC_HEAD.
  CALL METHOD CL_SMW_MFLOW=>SET_HEADER_FIELDS
    EXPORTING
      IN_BDOC_TYPE   = LC_BDOC_TYPE
    IMPORTING
      OUT_HEADER     = LS_BDOC_HEAD.
 CALL METHOD CL_SMW_MFLOW=>PERS_VALIDATE
   EXPORTING
     BDOC_HEADER     = LS_BDOC_HEAD
     OPTIONS         = LS_OPTION
     DO_LUWHANDLING  = SPACE
   CHANGING
     MESSAGE         = LV_TRANS_MSG
     MESSAGE_EXT     = LS_BDOC
   EXCEPTIONS
     TECHNICAL_ERROR = 0
     OTHERS          = 0.

ENDFUNCTION.
