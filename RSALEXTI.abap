***INCLUDE RSALEXTI

*---------------------------------------------------------------------
* ACHTUNG !! dies ist ein zentraler Include für die
*            Monitoring Infrastruktur und für Alerts
* Der Include enthält allgemeine Definitionen die in allen
* Funktionsgruppen verwendet werden können.
*---------------------------------------------------------------------

* Typen
TYPE-POOLS: CCMSM.
*
* Makros für die Definition eines Callbacks zur Prozessierung von
* Regelknoten einer Monitordefinition ( Version 1 )
*
* Die Parameter der im Makro definierten Formroutinenparameter
* haben folgende Bedeutung:
*
* - PARAMS_TO_EVAL:
*   Diese Regelparameter sind vom Callback zu evaluieren.
*
* - PARAMETERS
*   bereits evaluierte Regelparameter
*
* - DEFAULT_RESULT_NODE_NAME:
*   Defaultname eines Ergebnisknotens. Kann vom Callback ausgewertet
*   und virtuellen Ergebnisknoten als Name zugewiesen werden.
*
* - RESULT_NODES
*   Vom Callback erzeugte Ergebnisknoten
*
* - OPERATION_MODE:
*   Arbeitsmodus eines Callbacks ( Parameter prüfen / Existenz des
*   CAllbacks verifizieren / Regel prozessieren )
*
* - RETURN_CODE:
*   Returncode des Callbacks
*
* - ERROR_INFO:
*   stellt ein Callback ein Fehler fest, dann kann über diesen
*   Parameter eine SAP Fehlernachricht an den Rufer des Callbacks
*   zurückgegeben werden
*
DEFINE CCMS_AL_RULE_CALLBACK_BEGIN_V1.
*---------------------------------------------------------------------*
*       FORM &1                                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAMS_TO_EVAL                                                *
*  -->  PARAMETERS                                                    *
*  -->  RESULT_NODES                                                  *
*  -->  OPERATION_MODE                                                *
*  -->  DEFAULT_RESULT_NODENAME                                       *
*  -->  RETURN_CODE                                                   *
*  -->  ERROR_INFO                                                    *
*---------------------------------------------------------------------*
FORM &1 TABLES PARAMS_TO_EVAL          TYPE CCMSM_RULE_PARAM_TBL
               PARAMETERS              TYPE CCMSM_RULE_PARAM_TBL
               RESULT_NODES            TYPE CCMSM_RULE_CB_RESULT_TBL
        USING  OPERATION_MODE          TYPE ALTYPES-CHAR1
               DEFAULT_RESULT_NODENAME TYPE ALMDRULES-DEFMDNDNAM
               RETURN_CODE             TYPE ALRCTABLE-RC
               ERROR_INFO              TYPE CCMSM_RULE_CB_ERROR_INFO.
*
*    general test and initialization of parameters
*
  RETURN_CODE = AL_RC_OK.

  CLEAR ERROR_INFO.

  IF OPERATION_MODE NE AL_CB_PROCESS_RULE           AND
     OPERATION_MODE NE AL_CB_CHECK_EXISTENCE        AND
     OPERATION_MODE NE AL_CB_CHK_PARMS_ONLY.
*
*         invalid operation mode
*
    RETURN_CODE           = AL_RC_RULE_CB_ERROR.
    ERROR_INFO-ERR_MSG_ID = 'RA'.
    ERROR_INFO-ERR_MSG_NR = 239.
    ERROR_INFO-ERR_PARAM1 = OPERATION_MODE.
    EXIT.
  ENDIF.

  IF OPERATION_MODE EQ AL_CB_CHECK_EXISTENCE.
*
*       Callback proves its existence by having set return code to ok
*
    EXIT.
  ENDIF.

  CLEAR   RESULT_NODES.
  REFRESH RESULT_NODES.

END-OF-DEFINITION.

DEFINE CCMS_AL_RULE_CALLBACK_END_V1.
*
*      if a callback has created virtual template nodes then check
*      whether these virtual nodes have been assigned a set of
*      parameters that were to be evaluated by the callback
*
  LOOP AT RESULT_NODES
    WHERE NODE_TYPE EQ AL_MONITEMPL_NODE_VIRTUAL.

    LOOP AT PARAMS_TO_EVAL.

      READ TABLE RESULT_NODES-PARAMS_TO_PASS_ON
           WITH KEY PAR_NAME = PARAMS_TO_EVAL-PAR_NAME
           TRANSPORTING NO FIELDS.

      IF SY-SUBRC NE 0.
        RETURN_CODE = AL_RC_RULE_CB_ERROR.
        ERROR_INFO-ERR_MSG_ID  = 'RA'.
        ERROR_INFO-ERR_MSG_NR  = 240.
        ERROR_INFO-ERR_PARAM1  = PARAMS_TO_EVAL-PAR_NAME.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF RETURN_CODE NE AL_RC_OK.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.

END-OF-DEFINITION.
*
* macro for calling a callback routine for processing a monitor
* defintion rule ( Version 1 )
*
DEFINE CCMS_AL_EXECUTE_RULE_CB_V1.

  &8 = AL_RC_RULE_CB_ERROR. " Initializie return code
                            " information as if
  CLEAR &9.                 " ABAP callback routine
                            " does not exist. If it
  &9-ERR_MSG_ID = 'RA'.         " exists, then this error
  &9-ERR_MSG_NR = '243'.        " info will be overwritten
  &9-ERR_PARAM1 = &1.           " by ABAP callback routine
  &9-ERR_PARAM2 = &2.

  PERFORM (&1) IN PROGRAM (&2)
     TABLES &3 &4 &5
     USING  &6 &7 &8 &9 IF FOUND.

END-OF-DEFINITION. " CCMS_AL_EXECUTE_RULE_CB_V1.
*
* Macro for defining a rule processing callback ( latest version )
*
DEFINE CCMS_AL_RULE_CALLBACK_BEGIN.
*---------------------------------------------------------------------*
*       FORM &1                                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAMS_TO_EVAL                                                *
*  -->  PARAMETERS                                                    *
*  -->  RESULT_NODES                                                  *
*  -->  OPERATION_MODE                                                *
*  -->  NODE_NAME_RULE                                                *
*  -->  RETURN_CODE                                                   *
*  -->  ERROR_INFO                                                    *
*---------------------------------------------------------------------*
FORM &1 USING PARAMS_TO_EVAL   TYPE ALRLPARTBL
              PARAMETERS       TYPE ALRLPARTBL
              RESULT_NODES     TYPE ALRLRSNTBL
              OPERATION_MODE   TYPE ALTYPES-CHAR1
              NODE_NAME_RULE   TYPE ALMDNNAME.

  DATA: RULE_CB_MSG_PARAM   TYPE SYMSGV,
        RULE_CB_RESULT_NODE LIKE LINE OF RESULT_NODES.
*
* prove existence of form routine by deleting error result node
* created by macro that defines a rule callback
*
  REFRESH RESULT_NODES.
*
* check operation mode
*
  IF OPERATION_MODE NE AL_CB_PROCESS_RULE    AND
     OPERATION_MODE NE AL_CB_CHECK_EXISTENCE AND
     OPERATION_MODE NE AL_CB_CHK_PARMS_ONLY.
*
*       invalid operation mode - create error result node
*
        RULE_CB_MSG_PARAM = OPERATION_MODE.

        CALL FUNCTION 'RULE_RESULT_ERROR_NODE_CREATE'
             EXPORTING
                  ERROR_TYPE     = AL_RULE_EXECUTION_ERROR
                  ERROR_MSG_ID   = 'RA'
                  ERROR_MSG_NO   = 239
                  ERROR_MSG_PAR1 = RULE_CB_MSG_PARAM
             IMPORTING
                  RESULT_NODE    = RULE_CB_RESULT_NODE
             EXCEPTIONS
                  OTHERS         = 99.

        IF SY-SUBRC EQ 0.
           APPEND RULE_CB_RESULT_NODE TO RESULT_NODES.
        ENDIF.

        EXIT.
  ENDIF.

  IF OPERATION_MODE EQ AL_CB_CHECK_EXISTENCE.
     EXIT.
  ENDIF.

END-OF-DEFINITION.

DEFINE CCMS_AL_RULE_CALLBACK_END.

  ENDFORM.

END-OF-DEFINITION.
*
* macro for calling a callback routine for processing a monitor
* defintion rule ( latest version )
*
DATA: RULE_CB_DOESNT_EXIST_RESULT TYPE ALRLRSNODE.

DEFINE CCMS_AL_EXECUTE_RULE_CB.
*
* create result node as if form routine &2 in program &1 does not
* exist. Because of performance reasons we do not use function
* module 'RULE_RESULT_ERROR_NODE_CREATE' ( avoid DB-access )
*
  RULE_CB_DOESNT_EXIST_RESULT-ERRNODTYP      = AL_RULE_EXECUTION_ERROR.
  RULE_CB_DOESNT_EXIST_RESULT-INFO-XMIMSGCLS = 'SAP-T100'.

  CONCATENATE 'RA' '243'
              INTO RULE_CB_DOESNT_EXIST_RESULT-INFO-XMIMSGID
              SEPARATED BY SPACE.

  RULE_CB_DOESNT_EXIST_RESULT-INFO-PARAM1 = &1.
  RULE_CB_DOESNT_EXIST_RESULT-INFO-PARAM2 = &2.

  APPEND RULE_CB_DOESNT_EXIST_RESULT TO &5.

  PERFORM (&1) IN PROGRAM (&2) USING &3 &4 &5 &6 &7 IF FOUND.

END-OF-DEFINITION. " CCMS_AL_EXECUTE_RULE_CB.
*
* macro that checks whether there is at least one error result node
* in the result node set of a rule. Parameter &1 = table with
* rule result nodes. If at least one error node is found parameter
* &2 is set to TRUE else to FALSE.
*
DEFINE CCMS_AL_CHECK_FOR_RULE_ERROR.

  DATA: ERR_CHECK_RULE_RESULT_NODE TYPE ALRLRSNODE.

  &2 = AL_FALSE.

  LOOP AT    &1
       INTO  ERR_CHECK_RULE_RESULT_NODE
       WHERE ERRNODTYP NE AL_RULE_NO_ERROR.

    &2 = AL_TRUE.
    EXIT.

  ENDLOOP.

END-OF-DEFINITION. " CCMS_AL_CHECK_FOR_RULE_ERROR
*
* Makros für die Definition eines Callbacks zur Ermittlung der Werte-
* menge eines Regelparameters ( Version 1 )
*
* Die Parameter der im Makro definierten Formroutinenparameter
* haben folgende Bedeutung:
*
* - PARAMETER_NAME:
*   Name des Parameters dessen Wertemenge ermittelt werden soll
*
* - PARAMETER_VALUES:
*   vom Callback ermittelte Wertemenge des Parameters
*
* - PARAMETERS
*   Werte der anderen Regelparameter ( falls vorhanden )
*
* - RETURN_CODE:
*   Returncode des Callbacks
*
* - ERROR_INFO:
*   stellt ein Callback ein Fehler fest, dann kann über diesen
*   Parameter eine R/3 Fehlernachricht an den Rufer des Callbacks
*   an den Rufer des Callbacks zurückgegeben werden
*
DEFINE CCMS_AL_RULE_F4_CB_BEGIN_V1.
*---------------------------------------------------------------------*
*       FORM &1                                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAMETER_VALUES                                              *
*  -->  PARAMETERS                                                    *
*  -->  OPERATION_MODE                                                *
*  -->  PARAMETER_NAME                                                *
*  -->  RETURN_CODE                                                   *
*  -->  ERROR_INFO                                                    *
*---------------------------------------------------------------------*
FORM &1 TABLES PARAMETER_VALUES  TYPE CCMSM_RULE_PARAM_VALUE_F4_TBL
               PARAMETERS        TYPE CCMSM_RULE_PARAM_TBL
        USING  OPERATION_MODE    TYPE ALTYPES-CHAR1
               PARAMETER_NAME    TYPE ALMDRLPNAM
               RETURN_CODE       TYPE ALRCTABLE-RC
               ERROR_INFO        TYPE CCMSM_RULE_CB_ERROR_INFO.
*
*    general test and initialization of parameters
*
  RETURN_CODE = AL_RC_OK.

  CLEAR ERROR_INFO.

  CLEAR   PARAMETER_VALUES.
  REFRESH PARAMETER_VALUES.

  IF OPERATION_MODE NE AL_CB_PROCESS_RULE
     AND
     OPERATION_MODE NE AL_CB_CHECK_EXISTENCE.
*
*         invalid operation mode
*
    RETURN_CODE           = AL_RC_RULE_CB_ERROR.
    ERROR_INFO-ERR_MSG_ID = 'RA'.
    ERROR_INFO-ERR_MSG_NR = 239.
    ERROR_INFO-ERR_PARAM1 = OPERATION_MODE.
    EXIT.
  ENDIF.

  IF OPERATION_MODE EQ AL_CB_CHECK_EXISTENCE.
*
*       Callback proves its existence by having set return code to ok
*
    EXIT.
  ENDIF.
END-OF-DEFINITION. " CCMS_AL_RULE_F4_CB_BEGINV1

DEFINE CCMS_AL_RULE_F4_CB_END_V1.
  ENDFORM.
END-OF-DEFINITION.
*
* macro for calling a callback routine for processing a F4 help
* for a monitor definition rule parameter ( Version 1 )
*
DEFINE CCMS_AL_EXECUTE_RULE_F4_CB_V1.

  &7 = AL_RC_RULE_CB_ERROR.              " Initializie return code
                                         " information as if
  CLEAR &8.                              " ABAP callback routine
                                         " does not exist. If it
  &8-ERR_MSG_ID = 'RA'.                  " exists, then this error
  &8-ERR_MSG_NR = '298'.                 " info will be overwritten
  &8-ERR_PARAM1 = &6.                    " by ABAP callback routine

  PERFORM (&1) IN PROGRAM (&2)
          TABLES &3 &4
          USING  &5 &6 &7 &8 IF FOUND.

END-OF-DEFINITION. " CCMS_AL_EXECUTE_RULE_F4_CB_V1
*
* F4-macro for rule parameter help processing ( latest version )
*
DEFINE CCMS_AL_RULE_F4_CB_BEGIN.
*---------------------------------------------------------------------*
*       FORM &1                                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAMETER_VALUES                                              *
*  -->  PARAMETERS                                                    *
*  -->  OPERATION_MODE                                                *
*  -->  PARAMETER_NAME                                                *
*  -->  RETURN_CODE                                                   *
*  -->  ERROR_INFO                                                    *
*---------------------------------------------------------------------*
FORM &1 USING PARAMETER_VALUES  TYPE ALRLPF4TBL
              PARAMETERS        TYPE ALRLPARTBL
              OPERATION_MODE    TYPE ALTYPES-CHAR1
              PARAMETER_NAME    TYPE ALMDRLPNAM
              RETURN_CODE       TYPE ALRCTABLE-RC
              ERROR_INFO        TYPE ALTMPLNDIF.
*
* general test and initialization of parameters
*
  RETURN_CODE = AL_RC_OK.

  CLEAR ERROR_INFO.

  REFRESH PARAMETER_VALUES.

  IF OPERATION_MODE NE AL_CB_PROCESS_RULE
     AND
     OPERATION_MODE NE AL_CB_CHECK_EXISTENCE.
*
*      invalid operation mode
*
       RETURN_CODE = AL_RC_RULE_CB_ERROR.

       ERROR_INFO-XMIMSGCLS = 'SAP-T100'.

       CONCATENATE 'RA' '239'
                   INTO ERROR_INFO-XMIMSGID
                   SEPARATED BY SPACE.

       ERROR_INFO-PARAM1 = OPERATION_MODE.

       EXIT.
  ENDIF.

  IF OPERATION_MODE EQ AL_CB_CHECK_EXISTENCE.
*
*    Callback proves its existence by having set return code to ok
*
     EXIT.
  ENDIF.
END-OF-DEFINITION. " CCMS_AL_RULE_F4_CB_BEGIN

DEFINE CCMS_AL_RULE_F4_CB_END.
  ENDFORM.
END-OF-DEFINITION.
*
* macro for calling a callback routine for processing a F4 help
* of a rule parameter ( latest version )
*
DEFINE CCMS_AL_EXECUTE_RULE_F4_CB.

  &7 = AL_RC_RULE_CB_ERROR.          " Initializie return code
                                     " information as if
  CLEAR &8.                          " ABAP callback routine
                                     " does not exist. It it exists
  &8-XMIMSGCLS = 'SAP-T100'.         " then this error info will
                                     " be overwritten by corresponding
  CONCATENATE 'RA' '298'             " ABAP callback routine
              INTO &8-XMIMSGID
              SEPARATED BY SPACE.

  &8-PARAM1 = &6.

  PERFORM (&1) IN PROGRAM (&2)
          USING  &3 &4 &5 &6 &7 &8 IF FOUND.

END-OF-DEFINITION. " CCMS_AL_EXECUTE_RULE_F4_CB

DEFINE MACRO_SALC_CCALL_CHECK_RESULT.
IF &3 <> 0.
  IF ONLY_LOCAL = 'X'.
    RAISE C_CALL_FAILED.
  ELSE.
    LOOP AT &1.
      MOVE-CORRESPONDING &1 TO &2.
      &2-RC = AL_RC_C_CALL_FAILED.
      APPEND &2.
    ENDLOOP.
  ENDIF.
ENDIF.
END-OF-DEFINITION.
*
* macro for checking whether AID1 equals AID2
*
* Input parameter : &1 = AID1, &2 = AID2
* Output parameter: &3 = variable of type ALBOOL ( content = AL_TRUE if
*                        AID1 == AID2, AL_FALSE if AID1 != AID2 )
*
DEFINE COMPARE_AID1_WITH_AID2.

  IF &1-ALSYSID   EQ &2-ALSYSID   AND
     &1-MSEGNAME  EQ &2-MSEGNAME  AND
     &1-ALUNIQNUM EQ &2-ALUNIQNUM AND
     &1-ALERTDATE EQ &2-ALERTDATE AND
     &1-ALERTTIME EQ &2-ALERTTIME.

        &3 = AL_TRUE.

   ELSE.

        &3 = AL_FALSE.

   ENDIF.

END-OF-DEFINITION.

*=============CONSTANTS==============================================
* monitoring object types
CONSTANTS:
MT_TYPE_REAL    TYPE CCMSM_MT_TYPE VALUE '1',
MT_TYPE_VIRTUAL TYPE CCMSM_MT_TYPE VALUE '2',
MT_TYPE_ERROR   TYPE CCMSM_MT_TYPE VALUE '3'.

* monitoring tree element (MT): type classes
CONSTANTS:
MT_CLASS_NO_CLASS     TYPE  ALGLOBTID-MTCLASS       VALUE '000',
MT_CLASS_SUMMARY      TYPE  ALGLOBTID-MTCLASS       VALUE '050',
MT_CLASS_MONIOBJECT   TYPE  ALGLOBTID-MTCLASS       VALUE '070',
MT_CLASS_FIRST_MA     TYPE  ALGLOBTID-MTCLASS       VALUE '099',
MT_CLASS_PERFORMANCE  TYPE  ALGLOBTID-MTCLASS       VALUE '100',
MT_CLASS_MSG_CONT     TYPE  ALGLOBTID-MTCLASS       VALUE '101',
MT_CLASS_SINGLE_MSG   TYPE  ALGLOBTID-MTCLASS       VALUE '102',
MT_CLASS_HEARTBEAT    TYPE  ALGLOBTID-MTCLASS       VALUE '103',
MT_CLASS_LONGTEXT     TYPE  ALGLOBTID-MTCLASS       VALUE '110',
MT_CLASS_SHORTTEXT    TYPE  ALGLOBTID-MTCLASS       VALUE '111',
MT_CLASS_VIRTUAL      TYPE  ALGLOBTID-MTCLASS       VALUE '199'.

* monitoring tree element (MT): subtype classes
CONSTANTS:
AL_STD_NO_SUBCLASS  TYPE  ALTDEFRC-MTESUBTYPE       VALUE 0,
* ------ subtypes of performance types ----------------------------- */
* default behaviour (al_std_no_subclass) means:              */
*           total of reported values is checked against      */
*             thresholds (same unit for reported value and   */
*             threshold  assumed)                            */
*                                                            */
* al_std_perf_freq_1_minute means:                           */
*           only count of reported values is regarded and    */
*             measured in 1-minute-periods                   */
*           total of reported values is ignored              */
*           as 'Relevant Value' (see below) only smooth_01   */
*             smooth_05 and  smooth_15 make sense            */
*           as 'Unit' something TYPE '/min' should be used   */

AL_STD_PERF_FREQ_1_MINUTE  TYPE  ALTDEFRC-MTESUBTYPE      VALUE 10,
AL_STD_PERF_COUNTER        TYPE  ALTDEFRC-MTESUBTYPE      VALUE 11,
AL_STD_PERF_QUALITY_COUNTER TYPE  ALTDEFRC-MTESUBTYPE     VALUE 12,
AL_STD_PERF_AVAILABILITY   TYPE  ALTDEFRC-MTESUBTYPE      VALUE 13,
AL_STD_PERF_OCCUPANCY      TYPE  ALTDEFRC-MTESUBTYPE      VALUE 14,
AL_STD_PERF_OCCUPANCY_DIFF TYPE  ALTDEFRC-MTESUBTYPE      VALUE 15,
AL_STD_PERF_HEARTBEAT      TYPE  ALTDEFRC-MTESUBTYPE      VALUE 16,
AL_STD_PERF_HEARTBEAT_AVAIL TYPE  ALTDEFRC-MTESUBTYPE     VALUE 17,
AL_STD_PERF_COUNTER_PER_SEC TYPE  ALTDEFRC-MTESUBTYPE     VALUE 18,


* ------ subtypes of single message types -------------------------- */

* default behaviour (al_std_no_subclass) means:              */
*           no alert implies green attribute                 */
*           thus fresh/new attribute is green                */
*           attribute's actual value is green after setting  */
*             done all alerts                                */
*                                                            */
* al_std_smes_green_only_explicit means:                     */
*           no alert means attribute is inactive             */
*           thus fresh/new attribute is inactive             */
*           attribute's actual value is still red/yellow     */
*             after setting done all alerts                  */
*                                                            */
* al_std_smes_trigger_startup_tool means:                    */
*           this status message mte exists only for the      */
*           purpose of triggering a startup tool             */
*           after successful run of the tool, the mte will   */
*           be deleted. in case of an error occured          */
*           an according status message will be given.       */
AL_STD_SMES_GREEN_ONLY_EXPLIC TYPE  ALTDEFRC-MTESUBTYPE  VALUE 50,
AL_STD_SMES_TRIGGER_STARTUP_TL TYPE  ALTDEFRC-MTESUBTYPE  VALUE 60,
AL_STD_SMES_HEARTBEAT          TYPE  ALTDEFRC-MTESUBTYPE  VALUE 70,


* ------ subtypes of message container types --------------------------

* default (al_std_no_subclass) not allowed for message cont!!!:     */
*                                                            */
* al_std_msc_cache means:                                    */
*           message lines are kept in monitoring architecture*/
*           shared memory, thus capacity limits apply!       */
AL_STD_MSC_CACHE TYPE  ALTDEFRC-MTESUBTYPE  VALUE 90,
*                                                            */
* al_std_msc_syslog means:    INTERNAL USE ONLY              */
*           syslog is used as a message container, all       */
*           relevant syslog entries are copied to and        */
*           filtered by the monitoring architecture, but     */
*           only alerts arekept in the shared memory         */
*           monitoring segment                               */
AL_STD_MSC_SYSLOG TYPE  ALTDEFRC-MTESUBTYPE  VALUE 91,
*                                                            */
* al_std_msc_external means:                                 */
*           any other external message container is used     */
*           relevant messages are copied to and              */
*           filtered by the monitoring architecture, but     */
*           only alerts are kept in the shared memory        */
*           monitoring segment                               */
AL_STD_MSC_EXTERNAL TYPE  ALTDEFRC-MTESUBTYPE  VALUE 92,
*                                                            */
* al_std_msc_logfile means:    INTERNAL USE ONLY            */
*           a file on OS level is used as message container  */
*           relevant logfile (e.g. dev_* traces) are read    */
*           and filtered by a specific logfile agent.        */
*           Only alerts are kept in the shared memory        */
*           monitoring segment                               */
AL_STD_MSC_LOGFILE TYPE  ALTDEFRC-MTESUBTYPE  VALUE 93,
AL_STD_MSC_SECAUDIT TYPE  ALTDEFRC-MTESUBTYPE  VALUE 94,

* Reference attribute: link to global TID
AL_STD_LTXT_TIDLINK TYPE  ALTDEFRC-MTESUBTYPE  VALUE 101.


* monitoring type and alert values
CONSTANTS:
AL_VAL_INACTIV        TYPE ALALERTRC-VALUE        VALUE 0,
AL_VAL_GREEN          TYPE ALALERTRC-VALUE        VALUE 1,
AL_VAL_YELLOW         TYPE ALALERTRC-VALUE        VALUE 2,
AL_VAL_RED            TYPE ALALERTRC-VALUE        VALUE 3.

* alert status
CONSTANTS:
AL_STAT_UNKNOWN          TYPE ALALERTRC-STATUS      VALUE 0,
AL_STAT_FREE             TYPE ALALERTRC-STATUS      VALUE 1,
AL_STAT_PREINIT          TYPE ALALERTRC-STATUS      VALUE 9,
AL_STAT_INITIAL          TYPE ALALERTRC-STATUS      VALUE 10,
AL_STAT_ACTION_REQUIRED  TYPE ALALERTRC-STATUS      VALUE 30,
AL_STAT_ACTION_RUNNING   TYPE ALALERTRC-STATUS      VALUE 31,
AL_STAT_ACTION_FAILED    TYPE ALALERTRC-STATUS      VALUE 38,
AL_STAT_ACTION_STOPPED   TYPE ALALERTRC-STATUS      VALUE 39,
AL_STAT_ACTIVE           TYPE ALALERTRC-STATUS      VALUE 40,
AL_AS_WORKFLOW_ACTIVE    TYPE ALALERTRC-STATUS      VALUE 70,
AL_AS_WORKITEM_IN_PROCESS TYPE ALALERTRC-STATUS     VALUE 75,
AL_STAT_MAX_ACTIVE       TYPE ALALERTRC-STATUS      VALUE 99,
AL_STAT_DONE_SET         TYPE ALALERTRC-STATUS      VALUE 100,
AL_STAT_DONE_TO_DB       TYPE ALALERTRC-STATUS      VALUE 101,
AL_STAT_DONE_DBWAIT      TYPE ALALERTRC-STATUS      VALUE 102,
AL_STAT_DONE_DBCOMMITED  TYPE ALALERTRC-STATUS      VALUE 103,
AL_STAT_DONE_ALL         TYPE ALALERTRC-STATUS      VALUE 104,
AL_STAT_ALERTDB_DONE     TYPE ALALERTRC-STATUS      VALUE 200,
AL_STAT_ALERTDB_AUTO_COMPLETED TYPE ALALERTRC-STATUS  VALUE 205,
AL_STAT_ALERTDB_PROTECTED TYPE ALALERTRC-STATUS      VALUE 210,
AL_STAT_ALERTDB_DELETED   TYPE ALALERTRC-STATUS      VALUE 220.

* --- Returncodes
CONSTANTS:
*** OK
AL_RC_OK                       TYPE ALRCTABLE-RC    VALUE 0,
AL_RC_OK_TID_UPDATED           TYPE ALRCTABLE-RC    VALUE 10,
AL_RC_OK_AID_UPDATED           TYPE ALRCTABLE-RC    VALUE 11,
AL_RC_OK_LID_UPDATED           TYPE ALRCTABLE-RC    VALUE 12,
AL_RC_OK_NO_AID_FOUND_FOR_TID  TYPE ALRCTABLE-RC    VALUE 20,
AL_RC_OK_MORE_OBJ              TYPE ALRCTABLE-RC    VALUE 30,
AL_RC_OK_NOTHING_DONE          TYPE ALRCTABLE-RC    VALUE 40,
AL_RC_OK_ALREADY_EXIST         TYPE ALRCTABLE-RC    VALUE 50,
AL_RC_OK_ALREADY_LAUNCHED      TYPE ALRCTABLE-RC    VALUE 60,
AL_RC_OK_READ_FROM_CACHE       TYPE ALRCTABLE-RC    VALUE 70,
*** ERRORs first error is 100
AL_RC_FIRST_ERROR              TYPE ALRCTABLE-RC    VALUE 100,
*** ERRORs
AL_RC_NAME_NOT_FOUND           TYPE ALRCTABLE-RC    VALUE 100,
AL_RC_NAME_INVALID             TYPE ALRCTABLE-RC    VALUE 101,
AL_RC_TID_INVALID              TYPE ALRCTABLE-RC    VALUE 102,
AL_RC_AID_INVALID              TYPE ALRCTABLE-RC    VALUE 103,
AL_RC_NAME_UNABLE_TO_EXPAND    TYPE ALRCTABLE-RC    VALUE 104,
AL_RC_LID_INVALID              TYPE ALRCTABLE-RC    VALUE 105,
AL_RC_SID_INVALID              TYPE ALRCTABLE-RC    VALUE 106,
AL_RC_EID_INVALID              TYPE ALRCTABLE-RC    VALUE 107,
AL_RC_ID_NOT_FOUND             TYPE ALRCTABLE-RC    VALUE 110,
AL_RC_MC_NOT_FOUND             TYPE ALRCTABLE-RC    VALUE 111,
AL_RC_MO_NOT_FOUND             TYPE ALRCTABLE-RC    VALUE 112,
AL_RC_MA_NOT_FOUND             TYPE ALRCTABLE-RC    VALUE 113,

*
AL_RC_SALD_PROBLEM             TYPE ALRCTABLE-RC    VALUE 180,
AL_RC_VERSION_CALL_NOT_SUPP    TYPE ALRCTABLE-RC    VALUE 181,
*
AL_RC_WRONG_CLASS              TYPE ALRCTABLE-RC    VALUE 200,
AL_RC_WRONG_SUBTYPECLASS       TYPE ALRCTABLE-RC    VALUE 201,
AL_RC_WRONG_NUMRANGE           TYPE ALRCTABLE-RC    VALUE 202,
AL_RC_WRONG_MTECLASS           TYPE ALRCTABLE-RC    VALUE 203,
AL_RC_WRONG_NAME               TYPE ALRCTABLE-RC    VALUE 204,
AL_RC_WRONG_PARENT             TYPE ALRCTABLE-RC    VALUE 205,
*
AL_RC_COMMUNICATION_FAILURE    TYPE ALRCTABLE-RC    VALUE 210,
AL_RC_C_CALL_FAILED            TYPE ALRCTABLE-RC    VALUE 211,
AL_RC_NO_ROUTE                 TYPE ALRCTABLE-RC    VALUE 212,
AL_RC_TIMEOUT                  TYPE ALRCTABLE-RC    VALUE 213,
*
AL_RC_GROUP_NOT_IN_REPOSITORY  TYPE ALRCTABLE-RC    VALUE 220,
AL_RC_GROUP_HAS_NO_MEMBERS     TYPE ALRCTABLE-RC    VALUE 221,
AL_RC_SYSTEM_INVALID           TYPE ALRCTABLE-RC    VALUE 222,
*
AL_RC_OLD_DATA_FROM_CACHE      TYPE ALRCTABLE-RC    VALUE 230,
AL_RC_CACHE_NOT_CONFIGURED     TYPE ALRCTABLE-RC    VALUE 231,
AL_RC_CACHE_READ_NO_DATA       TYPE ALRCTABLE-RC    VALUE 232,
AL_RC_CACHE_WRITE_FAILED       TYPE ALRCTABLE-RC    VALUE 233,
*
AL_RC_TOO_FEW_SLOTS            TYPE ALRCTABLE-RC    VALUE 244,
AL_RC_WRONG_SEGMENT            TYPE ALRCTABLE-RC    VALUE 245,
AL_RC_EID_EXPIRED              TYPE ALRCTABLE-RC    VALUE 246,
AL_RC_CONTEXT_INACTIVE         TYPE ALRCTABLE-RC    VALUE 247,
AL_RC_PERMISSON_DENIED         TYPE ALRCTABLE-RC    VALUE 248,
AL_RC_SEGMENT_NOT_AVAILABLE    TYPE ALRCTABLE-RC    VALUE 249,
AL_RC_COULD_NOT_OPEN_FILE      TYPE ALRCTABLE-RC    VALUE 250,
AL_RC_FLD_ERROR                TYPE ALRCTABLE-RC    VALUE 251,
AL_RC_LOCK_ERROR               TYPE ALRCTABLE-RC    VALUE 252,
AL_RC_CALL_INVALID             TYPE ALRCTABLE-RC    VALUE 253,
AL_RC_NO_MORE_SPACE            TYPE ALRCTABLE-RC    VALUE 254,
AL_RC_INTERNAL_ERROR           TYPE ALRCTABLE-RC    VALUE 255,
AL_RC_INVALID_REC_TYPE         TYPE ALRCTABLE-RC    VALUE 256,
AL_RC_INVALID_DATE_RANGE       TYPE ALRCTABLE-RC    VALUE 257,
AL_RC_EMPTY_INPUT_DATE         TYPE ALRCTABLE-RC    VALUE 258,
AL_RC_NO_ACCESS_TO_ANOTHER_R3  TYPE ALRCTABLE-RC    VALUE 259,
AL_RC_NO_REQUESTS_DEFINED      TYPE ALRCTABLE-RC    VALUE 260.

* special returncodes for Customizing
CONSTANTS:
AL_RC_CUST_DATA_UPDATED        TYPE ALCUSGRPRC-RC   VALUE 0,
AL_RC_CUST_DATA_INSERTED       TYPE ALCUSGRPRC-RC   VALUE 10,
AL_RC_CUST_DATA_ERROR          TYPE ALCUSGRPRC-RC   VALUE 100.

* returncodes for callback routines of monitor definition rules
CONSTANTS:
AL_RC_RULE_CB_ERROR   TYPE ALRCTABLE-RC  VALUE 99,
AL_RC_RULE_CB_WARNING TYPE ALRCTABLE-RC  VALUE 98.

*===================================================================
CONSTANTS:
AL_MC_ALL_CLIENTS TYPE SY-MANDT VALUE '   '.
*===================================================================
* num ranges:
CONSTANTS:
AL_NR_UNKNOWN          TYPE ALGLOBTID-MTNUMRANGE    VALUE  '000',
AL_NR_TEMP             TYPE ALGLOBTID-MTNUMRANGE    VALUE  '001',
AL_NR_SYS_PERM         TYPE ALGLOBTID-MTNUMRANGE    VALUE  '002',
AL_NR_VIRT             TYPE ALGLOBTID-MTNUMRANGE    VALUE  '003',
AL_NR_AUTO             TYPE ALGLOBTID-MTNUMRANGE    VALUE  '004',
AL_NR_AUTO_C           TYPE ALGLOBTID-MTNUMRANGE    VALUE  '005',
AL_NR_SAP_CPHBI_TEST   TYPE ALGLOBTID-MTNUMRANGE    VALUE  '006',
* range 10 - 110 reserverd for sap
AL_NR_SAP_OLD          TYPE ALGLOBTID-MTNUMRANGE    VALUE  '010',
AL_NR_SAP_R3_APPLSRV   TYPE ALGLOBTID-MTNUMRANGE    VALUE  '011',
AL_NR_SAP_MONI_SELF    TYPE ALGLOBTID-MTNUMRANGE    VALUE  '012',
AL_NR_SAP_PFDB_DUPL    TYPE ALGLOBTID-MTNUMRANGE    VALUE  '013',
AL_NR_SAP_PFDB_DUMMY   TYPE ALGLOBTID-MTNUMRANGE    VALUE  '014',
AL_NR_SAP_WWW_GATE     TYPE ALGLOBTID-MTNUMRANGE    VALUE  '020',
AL_NR_SAP_ALE          TYPE ALGLOBTID-MTNUMRANGE    VALUE  '021',
AL_NR_SAP_DB           TYPE ALGLOBTID-MTNUMRANGE    VALUE  '030',
AL_NR_SAP_R3_GW        TYPE ALGLOBTID-MTNUMRANGE    VALUE  '031',
AL_NR_SAP_R3_BTC       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '032',
AL_NR_SAP_R3_SLIC      TYPE ALGLOBTID-MTNUMRANGE    VALUE  '033',
*         al_nr_sap_r3_slic:            /* range 000000 ... 099999 */
AL_NR_SAP_SECURITY     TYPE ALGLOBTID-MTNUMRANGE    VALUE  '033',
*         al_nr_sap_security:           /* range 100000 ... 199999 */
AL_NR_SAP_R3_CTS       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '034',
AL_NR_SAP_R3_SPOOL     TYPE ALGLOBTID-MTNUMRANGE    VALUE  '035',
AL_NR_SAP_R3_BDC       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '036',
AL_NR_SAP_R3_ABAP      TYPE ALGLOBTID-MTNUMRANGE    VALUE  '037',
AL_NR_SAP_R3_UPDATE    TYPE ALGLOBTID-MTNUMRANGE    VALUE  '038',
AL_NR_SAP_DB_ORA       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '039',
AL_NR_SAP_DB_INF       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '040',
AL_NR_SAP_DB_MSQ       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '041',
AL_NR_SAP_DB_ADA       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '042',
AL_NR_SAP_DB_AS4       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '043',
AL_NR_SAP_DB_DB2       TYPE ALGLOBTID-MTNUMRANGE    VALUE  '044',
*range 111 - 210 reserved for defined partners */
AL_NR_CA_              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '111',
AL_NR_BMC              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '112',
AL_NR_PLT              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '113',
AL_NR_TIV              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '114',
AL_NR_ENVIVE           TYPE ALGLOBTID-MTNUMRANGE    VALUE  '115',
AL_NR_MS               TYPE ALGLOBTID-MTNUMRANGE    VALUE  '131',
AL_NR_IBM              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '132',
AL_NR_HP               TYPE ALGLOBTID-MTNUMRANGE    VALUE  '133',
AL_NR_SNI              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '134',
AL_NR_DEC              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '135',
AL_NR_SUN              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '136',
AL_NR_ORA              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '151',
AL_NR_INF              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '152',
AL_NR_MSQ              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '153',
AL_NR_ADA              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '154',
AL_NR_AS4              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '155',
AL_NR_DB2              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '156',
AL_NR_EMC              TYPE ALGLOBTID-MTNUMRANGE    VALUE  '157',
* Range for customer specific number contexts 211 - 254 */
AL_NR_CUSTOMER         TYPE ALGLOBTID-MTNUMRANGE    VALUE  '211'.

*================    TOOLS   ===========================================
* TOOLS:  which type of tool
CONSTANTS:
AL_WT_UNKNOWN     TYPE ALTOOLASSG-WHICHTOOL VALUE '000',
AL_WT_COLLECT     TYPE ALTOOLASSG-WHICHTOOL VALUE '010',
AL_WT_ANALYZE     TYPE ALTOOLASSG-WHICHTOOL VALUE '020',
AL_WT_ONALERT     TYPE ALTOOLASSG-WHICHTOOL VALUE '030',
AL_WT_ASSIST      TYPE ALTOOLASSG-WHICHTOOL VALUE '040'.

* TOOLS: Tool definition status
CONSTANTS:
AL_TD_DEF_UNKNOWN      TYPE ALTOOLASSG-TOOLSTATUS VALUE 0,
AL_TD_DEF_NOTOOL       TYPE ALTOOLASSG-TOOLSTATUS VALUE 1,
AL_TD_DEF_INITIAL      TYPE ALTOOLASSG-TOOLSTATUS VALUE 50,
AL_TD_DEF_PRESET       TYPE ALTOOLASSG-TOOLSTATUS VALUE 60,
AL_TD_DEF_WPSET        TYPE ALTOOLASSG-TOOLSTATUS VALUE 70,
AL_TD_DEF_DBSET        TYPE ALTOOLASSG-TOOLSTATUS VALUE 80,
AL_TD_DEF_CEN_SET      TYPE ALTOOLASSG-TOOLSTATUS VALUE 81,
AL_TD_DEF_CHECKED      TYPE ALTOOLASSG-TOOLSTATUS VALUE 90,
AL_TD_DEF_CEN_CHECKED  TYPE ALTOOLASSG-TOOLSTATUS VALUE 91,
AL_TD_DEF_ERROR        TYPE ALTOOLASSG-TOOLSTATUS VALUE 200,
AL_TD_DEF_FATAL_ERROR  TYPE ALTOOLASSG-TOOLSTATUS VALUE 255.

* TOOLS: Tool runtime status
CONSTANTS:
AL_TD_RUN_UNKNOWN             TYPE ALTOOLASSG-TOOLSTATUS VALUE 0,
AL_TD_RUN_READY               TYPE ALTOOLASSG-TOOLSTATUS VALUE 90,
AL_TD_RUN_REQ_BUT_NOT_CHECKED TYPE ALTOOLASSG-TOOLSTATUS VALUE 95,
AL_TD_RUN_REQUIRED            TYPE ALTOOLASSG-TOOLSTATUS VALUE 101,
AL_TD_RUN_LAUNCHED            TYPE ALTOOLASSG-TOOLSTATUS VALUE 102,
AL_TD_RUN_LNCHD_BUT_NEW_ALERT TYPE ALTOOLASSG-TOOLSTATUS VALUE 103,
AL_TD_RUN_SENT_TO_CEN         TYPE ALTOOLASSG-TOOLSTATUS VALUE 110,
AL_TD_RUN_ERROR               TYPE ALTOOLASSG-TOOLSTATUS VALUE 200,
AL_TD_RUN_FATAL_ERROR         TYPE ALTOOLASSG-TOOLSTATUS VALUE 255.

* TOOLS: call type for tool execution
CONSTANTS:
AL_TX_CT_REPORT        TYPE ALTOOLEXEC-CALLTYPE VALUE 'A',
AL_TX_CT_FUNCTION      TYPE ALTOOLEXEC-CALLTYPE VALUE 'F',
AL_TX_CT_TRANSACTION   TYPE ALTOOLEXEC-CALLTYPE VALUE 'T',
AL_TX_CT_WORKFLOW      TYPE ALTOOLEXEC-CALLTYPE VALUE 'W',
AL_TX_CT_URL           TYPE ALTOOLEXEC-CALLTYPE VALUE 'U',
AL_TX_CT_EXT_COMMAND   TYPE ALTOOLEXEC-CALLTYPE VALUE 'E'.

* TOOLS: destination type for TOOL-execution
CONSTANTS:
AL_TX_DEST_ANY          TYPE ALTOOLEXEC-DEST_TYPE VALUE SPACE,
AL_TX_DEST_MT_LOCAL     TYPE ALTOOLEXEC-DEST_TYPE VALUE 'L',
AL_TX_DEST_SPECIFIC     TYPE ALTOOLEXEC-DEST_TYPE VALUE 'S',
AL_TX_DEST_CLOSE_TO_DB  TYPE ALTOOLEXEC-DEST_TYPE VALUE 'D'.

* TOOLS: type for tool execution  with TID
CONSTANTS:
AL_TX_TABLE_OF_TID      TYPE ALTOOLEXEC-STRTTIDTYP VALUE SPACE,
AL_TX_SINGLE_TID        TYPE ALTOOLEXEC-STRTTIDTYP VALUE 'S'.

CONSTANTS:
* TOOL: Tool started in Dialogmode or not
AL_DIALOG_MODE_YES            TYPE ALTYPES-CHAR1       VALUE '1',
AL_DIALOG_MODE_NO             TYPE ALTYPES-CHAR1       VALUE '2',
*
* Boole values
*
AL_TRUE  TYPE ALBOOL VALUE '1',
AL_FALSE TYPE ALBOOL VALUE '0'.

*================================================================
* constants for monitor visualization function modules
*================================================================

CONSTANTS:
* use this constant to tell a CCMS_MT_TREE_CONSTRUCT form routine that
* a specific MT tree is to be constructed for the very first time
* ( used to differentiate between a first construct and refresh of an
*   MO tree )
AL_INITIAL_MT_TREE_CONSTRUCT TYPE I VALUE 0.

* constants that define the operation mode of function module
* SALM_MT_MARKED_INFO_GET
CONSTANTS:
AL_HIGHEST_ALERTS_ONLY   TYPE CCMSM_DATA_GET_MODE VALUE '1',
AL_ALL_ALERTS            TYPE CCMSM_DATA_GET_MODE VALUE '2',
AL_GET_NO_ALERT_INFO     TYPE CCMSM_DATA_GET_MODE VALUE '3',

AL_DO_RELOAD             TYPE CCMSM_DATA_GET_MODE VALUE '1',
AL_DO_NOT_RELOAD         TYPE CCMSM_DATA_GET_MODE VALUE '2'.

* constants that define the operation mode of function module
* SALM_MT_CLASSES_MARK
CONSTANTS:
AL_MARK_NODES            TYPE CCMSM_MARKING_MODE VALUE '1',
AL_UNMARK_NODES          TYPE CCMSM_MARKING_MODE VALUE '2'.
*
* constants that define the type of a visual MT-tree instance
* ( root / monitor instance - SALM-DB format version 1 only )
CONSTANTS:
AL_MT_ROOT_TREE_INSTANCE        TYPE CCMSM_MT_TREE_TYPE VALUE 'R',
AL_MT_INSTRUMENT_TREE_INSTANCE  TYPE CCMSM_MT_TREE_TYPE VALUE 'I'.
*
* constants that describe the operation mode of the monitor node
* editors ( function module SALM_MONIDEF_NODE_EDITOR /
* SALM_MONIDEF_EDITOR )
*
CONSTANTS:
AL_CREATE    TYPE CCMSM_EDITOR_OPMODE VALUE 'C',
AL_EDIT      TYPE CCMSM_EDITOR_OPMODE VALUE 'E',
AL_SHOW      TYPE CCMSM_EDITOR_OPMODE VALUE 'S',
AL_SHOW_LIST TYPE CCMSM_EDITOR_OPMODE VALUE 'L',
AL_SHOW_PROTOCOL TYPE CCMSM_EDITOR_OPMODE VALUE 'P'.
*
* constants that describe node types within a monitor definition
*
CONSTANTS:
AL_MONIDEF_NODE_MTE           TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'M',
AL_MONIDEF_NODE_RULE          TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'R',
AL_MONIDEF_NODE_VIRTUAL       TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'V',
AL_MONIDEF_NODE_SETPARAM      TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'P',
AL_MONIDEF_NODE_DELPARAM      TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'D',
AL_MONIDEF_NODE_MONIDEF_LINK  TYPE CCMSM_MONIDEF_NODE_TYPE VALUE 'L',
AL_MONIDEF_PRES_NODE_ASG_MTE  TYPE CCMSM_MONIDEF_NODE_TYPE VALUE '1',
AL_MONIDEF_PRES_NODE_MTEREPOS TYPE CCMSM_MONIDEF_NODE_TYPE VALUE '2',
AL_MONIDEF_PRES_ERROR_NODE    TYPE CCMSM_MONIDEF_NODE_TYPE VALUE '3'.
*
* constants that describe node types within a monitor template
*
CONSTANTS:
AL_MONITEMPL_NODE_MTE       TYPE CCMSM_MONITEMPL_NODE_TYPE VALUE 'M',
AL_MONITEMPL_NODE_VIRTUAL   TYPE CCMSM_MONITEMPL_NODE_TYPE VALUE 'V',
AL_MONITEMPL_NODE_ERROR     TYPE CCMSM_MONITEMPL_NODE_TYPE VALUE 'E'.
*
* constants that describe error node types within a monitor template
*
CONSTANTS:
AL_RULE_NO_ERROR            TYPE ALRLERTYPE VALUE 'N',
AL_RULE_SEMANTIC_ERROR      TYPE ALRLERTYPE VALUE 'S',
AL_RULE_EXECUTION_ERROR     TYPE ALRLERTYPE VALUE 'E'.
*
* constants that describe node types within a monitor presentation
*
CONSTANTS:
AL_TEMPLATE_NODE    TYPE ALMTRNDTYP VALUE 'N',
AL_TEMPLATE_LEAF    TYPE ALMTRNDTYP VALUE 'L',
AL_REAL_MTE_SUBTREE TYPE ALMTRNDTYP VALUE 'S'.
*
* constants that describe how to expand / compress a monitor subtree
*
CONSTANTS:
AL_EXPAND_TREE_ONE_LEVEL  TYPE ALTYPES-CHAR1 VALUE '1',
AL_EXPAND_TREE_COMPLETELY TYPE ALTYPES-CHAR1 VALUE 'X',
AL_COMPRESS_TREE          TYPE ALTYPES-CHAR1 VALUE 'C'.
*
* Typen von Einträgen in der Tabelle ALMONITORS
*
CONSTANTS:
  AL_MONITOR   TYPE ALMONTYPE VALUE 'M',
  AL_DIRECTORY TYPE ALMONTYPE VALUE 'D'.
*
* constants for rule parameter names
*
CONSTANTS:
AL_CB_PAR_R3SYSTEM         TYPE ALMDRLPNAM
                                VALUE 'R3System',     "#EC NOTEXT
AL_CB_PAR_TID              TYPE ALMDRLPNAM
                                VALUE 'TID',          "#EC NOTEXT
AL_CB_PAR_CONTEXT          TYPE ALMDRLPNAM
                                VALUE 'Context',      "#EC NOTEXT
AL_CB_PAR_OBJECT           TYPE ALMDRLPNAM
                                VALUE 'Object',       "#EC NOTEXT
AL_CB_PAR_SHORTNAME        TYPE ALMDRLPNAM
                                VALUE 'ShortName',    "#EC NOTEXT
AL_CB_PAR_MTECLASS         TYPE ALMDRLPNAM
                                VALUE 'MTEClass',     "#EC NOTEXT
AL_CB_PAR_R3CLIENT         TYPE ALMDRLPNAM
                                VALUE 'R3Client',     "#EC NOTEXT
AL_CB_PAR_SUMMARY_NAME     TYPE ALMDRLPNAM
                                VALUE 'SummaryMTEName', "#EC NOTEXT
AL_CB_PAR_SUMMARY_CLASS    TYPE ALMDRLPNAM
                                VALUE 'SummaryMTEClass', "#EC NOTEXT
AL_CB_PAR_MONISEGMENT      TYPE ALMDRLPNAM
                                VALUE 'MoniSegment',  "#EC NOTEXT
AL_CB_PAR_MONICONTEXT      TYPE ALMDRLPNAM
                                VALUE 'MoniContext',  "#EC NOTEXT
AL_CB_PAR_LAST_REAL_TID    TYPE ALMDRLPNAM
                              VALUE 'Node_LastRealTID', "#EC NOTEXT
AL_CB_PAR_RESULT_MTE_NAME  TYPE ALMDRLPNAM
                                VALUE 'Node_Name', "#EC NOTEXT
AL_CB_PAR_RESULT_MTE_TID   TYPE ALMDRLPNAM
                                VALUE 'Node_TID', "#EC NOTEXT
AL_CB_PAR_RESULT_MTE_CLASS TYPE ALMDRLPNAM
                                VALUE 'Node_MTEClass'. "#EC NOTEXT
*
* constants for that describe the 'LastRealTID-Behaviour' of a
* rule result node
*
CONSTANTS:

AL_LAST_REALTID_PROPAGATE  TYPE ALGLOBTID VALUE '<<PROP>>',  "#EC NOTEXT
AL_LAST_REALTID_DONTPROP   TYPE ALGLOBTID VALUE '<<INVAL>>'. "#EC NOTEXT
*
* constants for generic rule parameter values
*
CONSTANTS:

AL_CB_PAR_VALUE_CURR_R3_SYSTEM  TYPE ALMDRLPARM
                                    VALUE '<CURRENT>',
AL_CB_PAR_VALUE_ALL_R3_SYSTEMS  TYPE ALMDRLPARM
                                   VALUE '<ALL>',
AL_CB_PAR_VALUE_ALL_CONF_R3SYS  TYPE ALMDRLPARM
                                   VALUE '<ALL_CONFIGURED>',
AL_CB_PAR_VALUE_CURR_R3CLIENT   TYPE ALMDRLPARM
                                   VALUE '<CURRENT>',
AL_CB_PAR_VALUE_ALL_R3CLIENTS   TYPE ALMDRLPARM
                                   VALUE '<ALL>',
AL_CB_PAR_VALUE_CURR_SEGMENT    TYPE ALMDRLPARM
                                   VALUE '<CURRENT>',
AL_CB_PAR_VALUE_ALL_SEGMENTS    TYPE ALMDRLPARM
                                   VALUE '<ALL>',
AL_CB_PAR_VALUE_ANY_SEGMENT     TYPE ALMDRLPARM
                                   VALUE '<ANY>',
AL_CB_PAR_VALUE_ALL_CONTEXTS    TYPE ALMDRLPARM
                                   VALUE '<ALL>'.
*
* constants that define the operation mode of a monitor definition
* rule callback routine
*
CONSTANTS:
AL_CB_PROCESS_RULE      TYPE ALTYPES-CHAR1 VALUE 'P',
AL_CB_CHECK_EXISTENCE   TYPE ALTYPES-CHAR1 VALUE 'X',
AL_CB_CHK_PARMS_ONLY    TYPE ALTYPES-CHAR1 VALUE 'E'.
*
* constants that define which monitor sets are to be loaded by
* function module SALM_MT_MONITORING_START
*
CONSTANTS:
AL_LOAD_ALL_MONISETS      TYPE CCMSM_MONISET_NAME VALUE '%'.
*
* constants that define the format of a requested MTE-Name to be
* be constructed by function module SALC_MT_BUILD_MTNAME
*
CONSTANTS:
VISUAL_FORMAT TYPE ALTYPES-CHAR1 VALUE 'V',
NATIVE_FORMAT TYPE ALTYPES-CHAR1 VALUE 'N'.

*============ Constants for Customizing ==========================

* Usage of MT-Class(CUSGRPNAME) for general part of Customizing
* and for Tools
CONSTANTS:
AL_COS_UNKNOWN         TYPE  ALTOOLDEF-USECLASS  VALUE 0,
AL_COS_CLASS           TYPE  ALTOOLDEF-USECLASS  VALUE 10,
AL_COS_TID_SPECIFIC    TYPE  ALTOOLDEF-USECLASS  VALUE 20.

* Customizing: activate customizing data in shared memory
CONSTANTS:
AL_CUST_ACTIVATE_SOON       TYPE C       VALUE 'A',
AL_CUST_ACTIVATE_NOT        TYPE C       VALUE 'N'.

* XMI-Messageclasses for descriptiontext, alerttext,
*                        singlemessage, messagecontainer,
CONSTANTS:
SAP_T100_CLASS    TYPE ALMTCUST-DTEXTCLASS VALUE 'SAP-T100',
SAP_SLOG_CLASS    TYPE ALMTCUST-DTEXTCLASS VALUE 'SAP-SYSLOG'.

* Customizing GeneralPart: statistic record (YES/NO)
CONSTANTS:
AL_STAT_RECORD_NO         TYPE  ALMTCUST-STATISTREC  VALUE 0,
AL_STAT_RECORD_YES        TYPE  ALMTCUST-STATISTREC  VALUE 1.

* Customizing GeneralPart: visible on userlevel
CONSTANTS:
AL_VISIBLE_UNKNOWN        TYPE  ALMTCUST-VISUSERLEV  VALUE 0,
AL_VISIBLE_OPERATOR       TYPE  ALMTCUST-VISUSERLEV  VALUE 1,
AL_VISIBLE_EXPERT         TYPE  ALMTCUST-VISUSERLEV  VALUE 2,
AL_VISIBLE_DEVELOPER      TYPE  ALMTCUST-VISUSERLEV  VALUE 3.

* Customizing GeneralPart: keep alerts type
CONSTANTS:
AL_KEEP_ALL               TYPE  ALMTCUST-KEEPALTYPE  VALUE 0,
AL_KEEP_OLDEST            TYPE  ALMTCUST-KEEPALTYPE  VALUE 1,
AL_KEEP_NEWEST            TYPE  ALMTCUST-KEEPALTYPE  VALUE 2,

** AL_KEEP_HIGHEST and AL_KEEP_SLAVE are obsolete!
** Please use AL_KEEP_ALL,AL_KEEP_OLDEST,AL_KEEP_NEWEST
AL_KEEP_HIGHEST           TYPE  ALMTCUST-KEEPALTYPE  VALUE 3,
AL_KEEP_SLAVE             TYPE  ALMTCUST-KEEPALTYPE  VALUE 4.

* Customizing Performance Class:  Relvant Value Type
CONSTANTS:
AL_PERF_RV_UNKNOWN   TYPE  ALPERFCUS-RELVALTYPE   VALUE 0,
AL_PERF_RV_LAST      TYPE  ALPERFCUS-RELVALTYPE   VALUE 1,
AL_PERF_RV_MINUTE    TYPE  ALPERFCUS-RELVALTYPE   VALUE 1,
AL_PERF_RV_QUARTER   TYPE  ALPERFCUS-RELVALTYPE   VALUE 2,
AL_PERF_RV_HOUR      TYPE  ALPERFCUS-RELVALTYPE   VALUE 3,
AL_PERF_RV_SMOOTH_01 TYPE  ALPERFCUS-RELVALTYPE   VALUE 4,
AL_PERF_RV_SMOOTH_05 TYPE  ALPERFCUS-RELVALTYPE   VALUE 5,
AL_PERF_RV_SMOOTH_15 TYPE  ALPERFCUS-RELVALTYPE   VALUE 6.

* Customizing Performance Class:  Threshold Direction
CONSTANTS:
AL_THRESHDIR_UNKNOWN   TYPE  ALPERFCUS-THRESHDIR   VALUE 0,
AL_THRESHDIR_ABOVE     TYPE  ALPERFCUS-THRESHDIR   VALUE 1,
AL_THRESHDIR_BELOW     TYPE  ALPERFCUS-THRESHDIR   VALUE 2.

* Customizing SingleMessages: Mode for Alertraising
CONSTANTS:
AL_SMSG_ALMODE_UNKNOWN      TYPE  ALSMSGCUS-ALERTMODE  VALUE 0,
AL_SMSG_ALMODE_ALWAYS       TYPE  ALSMSGCUS-ALERTMODE  VALUE 1,
AL_SMSG_ALMODE_VALUE_CHG    TYPE  ALSMSGCUS-ALERTMODE  VALUE 2,
AL_SMSG_ALMODE_MSG_CHG      TYPE  ALSMSGCUS-ALERTMODE  VALUE 3,
AL_SMSG_ALMODE_NEVER        TYPE  ALSMSGCUS-ALERTMODE  VALUE 4.

* Customizing SingleMessages: Shift of Alertvalues
CONSTANTS:
AL_SMSG_ALSHIFT_UNKNOWN    TYPE  ALSMSGCUS-ALERTSHIFT VALUE 0,
AL_SMSG_ALSHIFT_UNCHG      TYPE  ALSMSGCUS-ALERTSHIFT VALUE 1,
* shift RED values to YELLOW
AL_SMSG_ALSHIFT_R_AS_Y     TYPE  ALSMSGCUS-ALERTSHIFT VALUE 2,
* shift YELLOW values to RED
AL_SMSG_ALSHIFT_Y_AS_R     TYPE  ALSMSGCUS-ALERTSHIFT VALUE 3,
* shift RED values to YELLOW and YELLOW to GREEN
AL_SMSG_ALSHIFT_RAY_YAG    TYPE  ALSMSGCUS-ALERTSHIFT VALUE 4.


* Customizing Message Container:  Actual value follows...
CONSTANTS:
AL_TD_MSC_VAL_MODE_UNKNOWN     TYPE  ALMSCCUS-ACTMSGMODE VALUE 0,
* ... last message
AL_TD_MSC_VAL_MODE_LAST        TYPE  ALMSCCUS-ACTMSGMODE VALUE 1,
* ... high alert
AL_TD_MSC_VAL_MODE_HIGHALRT    TYPE  ALMSCCUS-ACTMSGMODE VALUE 2,
* ... worst message line since..
AL_TD_MSC_VAL_MODE_WORST_SINCE TYPE  ALMSCCUS-ACTMSGMODE VALUE 3,

* extra Eintrag für Dafaultwert (original ist zu lang...)
AL_MSC_VAL_MODE_LAST           TYPE  ALMSCCUS-ACTMSGMODE VALUE 1.

* Customizing Message Container:  if cache subtyp: which lines to keep
CONSTANTS:
* keep newest message lines, try to keep more lines, even if
*      keeplinesmax is exceeded
AL_TD_KL_ALL     TYPE  ALMSCCUS-KEEPLINTYP VALUE 0,
* keep oldest (up to keeplinesmax) message lines,
*      don't create new message lines if limit reached
AL_TD_KL_OLDEST  TYPE  ALMSCCUS-KEEPLINTYP VALUE 1,
* keep newest (up to keeplinesmax) message lines,
*      get rid of old message lines in case of new message lines
AL_TD_KL_NEWEST  TYPE  ALMSCCUS-KEEPLINTYP VALUE 2.



* Customizing MessageContainer:  Mode for Alertraising
CONSTANTS:
* raise always an alert: set value to green and severity to 255
BEGIN OF AL_MSC_RAISE_ALERT_ALWAYS,
   VALUE TYPE ALMSCCUS-RAISEVALUE VALUE 1,
   SEVER TYPE ALMSCCUS-RAISESEVER VALUE 255,
END OF AL_MSC_RAISE_ALERT_ALWAYS,

* raise never an alert: set value to red and severity to 255
BEGIN OF AL_MSC_RAISE_ALERT_NEVER,
   VALUE TYPE ALMSCCUS-RAISEVALUE VALUE 3,
   SEVER TYPE ALMSCCUS-RAISESEVER VALUE 255,
END OF AL_MSC_RAISE_ALERT_NEVER.


*===================================================================
* Kernel-predefined Summaries and objects
DATA:
DIALOG_FULLNAME TYPE ALMTNAME_L-ALMTFULLNM VALUE
                  '\&SY\&INSTANCE_NAME\R3Services\Dialog',

BTC_FULLNAME    TYPE ALMTNAME_L-ALMTFULLNM VALUE
                  '\&SY\&INSTANCE_NAME\R3Services\Background'.

* =====================================================================
* Definiton of performance history types
* =====================================================================

* constants for using the SALP calls
CONSTANTS:
*rectypes:
PERFDB_AVERAGE_TYP_TODAY  TYPE  ALPERFDB-RECTYPE  VALUE 'Z',  "'T'

PERFDB_AVERAGE_TYP_MIN    TYPE  ALPERFDB-RECTYPE  VALUE 'I',
PERFDB_AVERAGE_TYP_QTR_HR  TYPE  ALPERFDB-RECTYPE  VALUE 'R',
PERFDB_AVERAGE_TYP_DAY    TYPE  ALPERFDB-RECTYPE  VALUE 'D',
PERFDB_AVERAGE_TYP_DAY_WHD TYPE ALPERFDB-RECTYPE VALUE 'H',   "new

PERFDB_AVERAGE_TYP_WEEK_MIN TYPE ALPERFDB-RECTYPE VALUE 'A',   "new
PERFDB_AVERAGE_TYP_WEEK_QTR TYPE ALPERFDB-RECTYPE VALUE 'B',
PERFDB_AVERAGE_TYP_WEEK   TYPE  ALPERFDB-RECTYPE  VALUE 'W',   "new
PERFDB_AVERAGE_TYP_WEEK_WHD TYPE ALPERFDB-RECTYPE VALUE 'C',   "new

PERFDB_AVERAGE_TYP_MONTH_MIN TYPE ALPERFDB-RECTYPE VALUE 'J',   "new
PERFDB_AVERAGE_TYP_MONTH_QTR TYPE ALPERFDB-RECTYPE VALUE 'K',   "new
PERFDB_AVERAGE_TYP_MONTH  TYPE  ALPERFDB-RECTYPE  VALUE 'M',
PERFDB_AVERAGE_TYP_MONTH_WHD TYPE ALPERFDB-RECTYPE VALUE 'L',   "new

PERFDB_AVERAGE_TYP_QUART_MIN TYPE ALPERFDB-RECTYPE VALUE 'N',   "new
PERFDB_AVERAGE_TYP_QUART_QTR TYPE ALPERFDB-RECTYPE VALUE 'O',   "new
PERFDB_AVERAGE_TYP_QUART  TYPE  ALPERFDB-RECTYPE  VALUE 'Q',
PERFDB_AVERAGE_TYP_QUART_WHD TYPE ALPERFDB-RECTYPE VALUE 'P',   "new

PERFDB_AVERAGE_TYP_YEAR_MIN TYPE ALPERFDB-RECTYPE VALUE 'S',   "new
PERFDB_AVERAGE_TYP_YEAR_QTR TYPE ALPERFDB-RECTYPE VALUE 'T',   "new
PERFDB_AVERAGE_TYP_YEAR   TYPE  ALPERFDB-RECTYPE  VALUE 'Y',
PERFDB_AVERAGE_TYP_YEAR_WHD TYPE ALPERFDB-RECTYPE VALUE 'U',   "new

PERFDB_AVERAGE_TYP_XDAYS_MIN TYPE ALPERFDB-RECTYPE VALUE 'E',   "new
PERFDB_AVERAGE_TYP_XDAYS_QTR TYPE ALPERFDB-RECTYPE VALUE 'F',   "new
PERFDB_AVERAGE_TYP_XDAYS  TYPE  ALPERFDB-RECTYPE  VALUE 'X',
PERFDB_AVERAGE_TYP_XDAYS_WHD TYPE ALPERFDB-RECTYPE VALUE 'G',   "new

*some special rectypes, only for reporting
PERFDB_AVERAGE_TYP_DAY_5MIN TYPE ALPERFDB-RECTYPE VALUE '0',   "new
PERFDB_AVERAGE_TYP_WEEK_5MIN TYPE ALPERFDB-RECTYPE VALUE '1',   "new
PERFDB_AVERAGE_TYP_MONTH_5MIN TYPE ALPERFDB-RECTYPE VALUE '3',   "new
PERFDB_AVERAGE_TYP_QUART_5MIN TYPE ALPERFDB-RECTYPE VALUE '4',   "new
PERFDB_AVERAGE_TYP_YEAR_5MIN TYPE ALPERFDB-RECTYPE VALUE '5',   "new
PERFDB_AVERAGE_TYP_XDAYS_5MIN TYPE ALPERFDB-RECTYPE VALUE '2',   "new

*data collection methods
perfdb_collmeth_agent type ALPFCOLLREORGSCH-COLL_METHOD value 'A',
perfdb_collmeth_central type ALPFCOLLREORGSCH-COLL_METHOD value 'C',
perfdb_collmeth_both type ALPFCOLLREORGSCH-COLL_METHOD value 'B',

*perfdb data output status
perfdb_out_stat_exact type char1 value '1',   "directly taken from db
perfdb_out_stat_agg type char1 value '2',     "aggregated data
perfdb_out_stat_ires type char1 value '3',    "calculated from lower
                                              "resolution
perfdb_out_stat_ityp type char1 value '4',    "calculated from higer
                                              "aggregation types
perfdb_out_stat_itypres type char1 value '5', "calc from lower resol
                                              "AND higher aggtypes
perfdb_out_stat_uncompl type char1 value '6', "uncomplete data directly
                                              "taken from DB
perfdb_out_stat_agg_uc type char1 value '7',  "uncomplete aggregated
                                              "data, maybe complete
                                              "(status 1 or 2) at a
                                              "later time
perfdb_out_stat_iuc_res type char1 value '8', "like '3', uncomplete
                                              "data
perfdb_out_stat_iuc_tr type char1 value '9',  "like '4' or '5',
                                              "uncomplete data



* constants for using the SALC call
PERFSM_AVERAGE_TYP_MIN    TYPE  ALPERFDB-RECTYPE  VALUE 'I',
PERFSM_AVERAGE_TYP_QUART  TYPE  ALPERFDB-RECTYPE  VALUE 'Q',
PERFSM_AVERAGE_TYP_CDAY   TYPE  ALPERFDB-RECTYPE  VALUE 'C',

* =====================================================================
* Definitions defining the exported time (SALR and SALX)
* =====================================================================
AL_EXPORT_USER_TIME TYPE TIMEZONE VALUE '#USER',
AL_EXPORT_DATA_BASE_TIME TYPE TIMEZONE VALUE '#DB',
*
* constants that describe the requested state of an MTE
*
AL_MTE_ACTIVATE   TYPE ALMTESTAT VALUE '1',
AL_MTE_DEACTIVATE TYPE ALMTESTAT VALUE '2',

* =====================================================================
* Definitions used for CCMS downtime handling
* =====================================================================
* Downtime Status of Monitored Segment
AL_DOWNTIME_REGULAR_MONITORING TYPE I VALUE 0, " no downtime active
AL_DOWNTIME_ACTIVE             TYPE I VALUE 1, " Downtime active
AL_DOWNTIME_NO_ALERTS          TYPE I VALUE 2, " no alerts for Segment
AL_DOWNTIME_NO_CURRENT_VALUES  TYPE I VALUE 4, " no current values for
                                               " segment

* return values of SCSM_DOWNTIME
AL_RC_DOWNTIME_OK              TYPE I value 0,
AL_RC_DOWNTIME_COMM_ERROR      TYPE I value 110,
AL_RC_DOWNTIME_INTERNAL_ERROR  TYPE I value 120,
AL_RC_DOWNTIME_SEGMENT_ERROR   TYPE I value 125,
AL_RC_DOWNTIME_SCHEDL_ERROR    TYPE I value 126,
AL_RC_DOWNTIME_ABAP_VERS_ERROR   TYPE I value 130,
AL_RC_DOWNTIME_KRNL_VERS_ERROR   TYPE I value 135.
