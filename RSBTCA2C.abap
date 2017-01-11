* INCLUDE RSBTCA2C.
*---------------------------------------------------------------------*
* Diese Datei enthaelt Kennungen der SAP-Kernel-Funktionen, die von   *
* ABAP-Programmen aus gerufen werden koennen.                         *
*                                                                     *
*  symbolischer Name        | Kommentar                               *
* --------------------------+---------------------------------------- *
*  BTC_A2C_CLEAN_ZOMBIE_LOG | Initiierung des Aufraeumens der         *
*                           | Protokolle von Zombie-Jobs              *
*  BTC_A2C_SET_DEBUG_FLAG   | Setzen von Debug-Flags                  *
*  BTC_A2C_EVENT_RAISE      | Ausloesen eines Ereignisses             *
*  BTC_A2C_RUNTIME_INFO     | Abgreifen von Laufzeitinformationen     *
*  BTC_A2C_SEND_SUBMIT_REQ  | Senden einer Nachricht zum Starten      *
*                           | eines Jobs                              *
*  BTC_A2C_FORCE_CLOSE      | Erzwungenes Schliessen eines TemSe      *
*                           | Datei-Objekts                           *
*  BTC_A2C_WRITE_TRACE      | Schreiben einer Trace-Meldung           *
*  BTC_A2C_TRIGGER_ACTION   | Ausloesen einer besonderen              *
*                           | Scheduler-Aktion                        *
*  BTC_A2C_PRETEND_EXEC     | scheinbare Ausfuehrung eines Jobs       *
*  BTC_A2C_INIT_TRACE       | Initialisierung der Trace-Umgebung      *
*  BTC_A2C_OPMODE_SWITCH    | Umschalten in andere Betriebsart        *
*  BTC_A2C_SET_STEP_FLAG    | setzen des Step-Start Flags             *
*  BTC_A2C_SAVE_STEPDATA    | Abschapeichern der Listidentifizierer   *
*
*---------------------------------------------------------------------*

CONSTANTS:
  BTC_A2C_CLEAN_ZOMBIE_LOG TYPE I VALUE 0,
  BTC_A2C_SET_DEBUG_FLAG   TYPE I VALUE 1,
  BTC_A2C_EVENT_RAISE      TYPE I VALUE 2,
  BTC_A2C_RUNTIME_INFO     TYPE I VALUE 3,
  BTC_A2C_SEND_SUBMIT_REQ  TYPE I VALUE 4,
  BTC_A2C_FORCE_CLOSE      TYPE I VALUE 5,
  BTC_A2C_WRITE_TRACE      TYPE I VALUE 6,
  BTC_A2C_TRIGGER_ACTION   TYPE I VALUE 7,
  BTC_A2C_PRETEND_EXEC     TYPE I VALUE 8,
  BTC_A2C_INIT_TRACE       TYPE I VALUE 9,
  BTC_A2C_OPMODE_SWITCH    TYPE I VALUE 10,
  BTC_A2C_SET_STEP_FLAG    TYPE I VALUE 11,
  BTC_A2C_SAVE_STEPDATA    TYPE I VALUE 12.
