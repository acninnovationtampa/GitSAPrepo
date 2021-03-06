
*----------------------------------------------------------------------*
*   INCLUDE BPALDEFS                                                   *
*----------------------------------------------------------------------*

* Constants for monitor object identifiers
CONSTANTS:
  SYSTEM_WIDE_BACKGROUND_UID   LIKE ALMTCREATE-UNIQUENUM VALUE 4,
  SYSTEM_WIDE_QUEUE_LEN_UID    LIKE ALMTCREATE-UNIQUENUM VALUE 5,
  SERVER_SPEC_QUEUE_LEN_UID    LIKE ALMTCREATE-UNIQUENUM VALUE 2,
  SERVER_SPEC_ABORTED_JOBS_UID LIKE ALMTCREATE-UNIQUENUM VALUE 3.

* Constants for monitor object names
CONSTANTS:
  SYSTEM_WIDE_BP_CTX_NAME       LIKE ALMTCREATE-NAME
    VALUE 'Background', "#EC NOTEXT
  SYSTEM_WIDE_BACKGROUND_NAME   LIKE ALMTCREATE-NAME
    VALUE 'BackgroundService',
  SYSTEM_WIDE_QUEUE_LEN_NAME    LIKE ALMTCREATE-NAME
    VALUE 'SystemWideQueueLength',
  SERVER_SPEC_QUEUE_LEN_NAME    LIKE ALMTCREATE-NAME
    VALUE 'ServerSpecificQueueLength',
  SERVER_SPEC_ABORTED_JOBS_NAME LIKE ALMTCREATE-NAME
    VALUE 'AbortedJobs'.

* Constants for monitor attribute type class.
CONSTANTS:
  QUEUE_LEN_TC    LIKE ALGLOBTID-MTCLASS VALUE MT_CLASS_PERFORMANCE,
  ABORTED_JOBS_TC LIKE ALGLOBTID-MTCLASS VALUE MT_CLASS_SINGLE_MSG.

CONSTANTS:
  R3_SYSTEM_WIDE_BP_CTX_MTC       LIKE ALMTCREATE-CUSGROUPMT
    VALUE 'R3BPSystemWideContext',
  R3_SYSTEM_WIDE_BACKGROUND_MTC   LIKE ALMTCREATE-CUSGROUPMT
    VALUE 'R3BPSystemWide',
  R3_SYSTEM_WIDE_QUEUE_LEN_MTC    LIKE ALMTCREATE-CUSGROUPMT
    VALUE 'R3BPSystemWideQueueLen',
  R3_SERVER_SPEC_QUEUE_LEN_MTC    LIKE ALMTCREATE-CUSGROUPMT
    VALUE 'R3BPServerSpecQueueLen',
  R3_SERVER_SPEC_ABORT_JOBS_MTC LIKE ALMTCREATE-CUSGROUPMT
    VALUE 'R3BPServerSpecAbortedJobs'.

CONSTANTS:
  ABORTED_JOBS_FALLBACK_TEXT(30) TYPE C
    VALUE 'Job &1 (count &2) aborted'. "#EC NOTEXT

CONSTANTS:
  SOURCE_BATCH(30) TYPE C VALUE 'BP RT system'. "#EC NOTEXT

CONSTANTS:
  BP_QUEUE_ANALYZE_TOOL(30)       TYPE C VALUE 'CCMS_BP_JOB_QUEUE',
  BP_ABORTED_JOB_ANALYZE_TOOL(30) TYPE C VALUE 'CCMS_BP_ABORTED_JOB'.
