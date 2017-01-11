FUNCTION /1BEA/CRMB_DL_PAR_O_DETERMINE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_SRC_DLI) TYPE  /1BEA/S_CRMB_DLI_WRK
*"     REFERENCE(IS_ITC) TYPE  BEAS_ITC_WRK
*"  EXPORTING
*"     REFERENCE(ET_PAR_COM) TYPE  BEAT_PAR_COM
*"     REFERENCE(ET_RETURN) TYPE  BEAT_RETURN
*"  EXCEPTIONS
*"      REJECT
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
* Time  : 13:53:10
*
*======================================================================
*---------------------------------------------------------------------
* BEGIN DEFINITION
*---------------------------------------------------------------------
  DATA:
    LV_PARSET_GUID    TYPE COMT_PARTNER_GUID,
    LS_PAR_COM        TYPE BEAS_PAR_COM,
    LS_PAR_CTRL       TYPE COMT_PARTNER_CONTROL,
    LV_DLI_PAR_PROC   TYPE COMT_PARTNER_DETERM_PROC,
    LT_PAR_COM        TYPE COMT_PARTNER_COMT.
  CONSTANTS:
    LC_AGAIN         TYPE COMT_PARTNER_POINT_OF_DETERM VALUE '0'.
*---------------------------------------------------------------------
* END DEFINITION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN INITIALIZATION
*---------------------------------------------------------------------
  PERFORM INIT_DLI_PAR_O.
*---------------------------------------------------------------------
* END INITIALIZATION
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN PREPARE
*---------------------------------------------------------------------
*  Fill up CONTROL-Structure for Partnerprocessing
  CALL FUNCTION '/1BEA/CRMB_DL_PAR_O_GET_CTRL'
       EXPORTING
            IS_DLI      = IS_SRC_DLI
            IS_ITC      = IS_ITC
       IMPORTING
            ES_PAR_CTRL = LS_PAR_CTRL.
*   continue with process ?
  IF LS_PAR_CTRL-DETERM_PROC IS INITIAL.
    MESSAGE E006(BEA_PAR) INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE
                 CHANGING ET_RETURN.
    PERFORM MSG_DLI_PAR_O_2_RETURN   CHANGING ET_RETURN.
    MESSAGE E001(BEA_PAR) RAISING REJECT.
  ENDIF.
*---------------------------------------------------------------------
* END PREPARE
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN SERVICE CALL
*---------------------------------------------------------------------
*  determine new partner
  CALL FUNCTION 'COM_PARTNER_DETERMINATION_OW'
    EXPORTING
      IV_PARTNERSET_GUID                   =  LV_PARSET_GUID
      IV_PREDECESSOR_PARTNERSET_GUID       =  IS_SRC_DLI-PARSET_GUID
      IS_PARTNER_CONTROL                   =  LS_PAR_CTRL
      IV_POINT_OF_DETERMINATION            =  LC_AGAIN
      IS_BP_ACCESS_STRUCTURE               =  IS_SRC_DLI
*     IV_REDETERMINATE                     =  ' '
*     IV_PARTNER_FCT_ONLY                  =  ' '
*     IV_DETERMINE_AGAIN                   =  ' '
    IMPORTING
*     EV_SELECTION_NEEDED                  =
      ET_PARTNER_COM                       =  LT_PAR_COM
*     ET_INPUT_FIELDS                      =
*     ET_ATTRIBUTES_COM                    =
*     ET_SELECTIONS_COM                    =
*     ET_SELECTIONS_FIELDS                 =
*     ET_SELECTIONS_ATTRIBUTES             =
*     EV_SELECTION_GUID                    =
*     EV_NO_DETERMINATION_FOR_PROC         =
*     EV_ALL_PARTNERS_IN_PROC              =
    EXCEPTIONS
      PARAMETER_ERROR                      = 1
      PARTNERSET_NOT_FOUND                 = 2
      PRED_PARTNERSET_NOT_FOU              = 3
      DEADLOCK_IN_DETERM_PROC              = 4
      DETERM_PROC_NOT_FOUND                = 5
      PARTNER_CUSTOMIZING_ERROR            = 6
      NO_DETERMINATION                     = 7
      OTHERS                               = 8.
  IF SY-SUBRC <> 0.
    MESSAGE E003(BEA_PAR) WITH IS_SRC_DLI-PARSET_GUID INTO GV_DUMMY.
    PERFORM MSG_ADD USING SPACE SPACE SPACE SPACE CHANGING ET_RETURN.
  ENDIF.
*---------------------------------------------------------------------
* END SERVICE CALL
*---------------------------------------------------------------------
*---------------------------------------------------------------------
* BEGIN ERROR RETURNING
*---------------------------------------------------------------------
  PERFORM MSG_DLI_PAR_O_2_RETURN CHANGING ET_RETURN.
  IF NOT ET_RETURN IS INITIAL.
    LOOP AT ET_RETURN TRANSPORTING NO FIELDS
          WHERE TYPE = GC_EMESSAGE
             OR TYPE = GC_AMESSAGE.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC = 0.
      MESSAGE E009(BEA_PAR) WITH IS_ITC-DLI_PAR_PROC RAISING REJECT.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------
* END ERROR RETURNING
*---------------------------------------------------------------------
  ET_PAR_COM = LT_PAR_COM.
ENDFUNCTION.
