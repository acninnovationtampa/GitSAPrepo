*----------------------------------------------------------------------*
*   INCLUDE WIZARDEF                                                   *
*----------------------------------------------------------------------*
INCLUDE %3CWIZARD%3E.
INCLUDE CNT4DEFS.
TYPE-POOLS CNTL .

TABLES:
* wizard transaction structions for subscreens.
        BTCH4100,      " General information for job definition
        BTCH4200,                      " Step selection
        BTCH4210,                      " ABAP step
        BTCH4220,                      " External program step
        BTCH4230,                      " External command step
        BTCH4300,      " Multiple step option / spool list recp.
        BTCH4400,                      " Start condition selection
        BTCH4410,                      " Start immediately
        BTCH4420,                      " Start date / time
        BTCH4430,                      " Start after event
        BTCH4440,                      " Start after predecessor job
        BTCH4450,      " Start after operating mode switch
        BTCH4460,                      " Start according to workdays
        BTCH4470,      " Distinguish multiple jobs with same names
        BTCH4480,      " Period behaviour of a job on non-workdays
        BTCH4490,                      " Factory calendar
        BTCH4500,                      " Periodicity definition
        BTCH4510,                      " Display/edit period values
        BTCHWIZALL.    " Collected information on job definition

* wizard variables.
DATA: DEFINITION LIKE SWF_WIZDEF OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF INPUT_DATA_GEN.
        INCLUDE STRUCTURE BTCH4100.
DATA: END OF INPUT_DATA_GEN.

DATA: BEGIN OF INPUT_DATA_STEP.
        INCLUDE STRUCTURE BTCH4200.
DATA: END OF INPUT_DATA_STEP.

DATA: BEGIN OF INPUT_DATA_ABAPSTEP.
        INCLUDE STRUCTURE BTCH4210.
DATA: END OF INPUT_DATA_ABAPSTEP.

DATA: BEGIN OF INPUT_DATA_EXTPROGSTEP.
        INCLUDE STRUCTURE BTCH4220.
DATA: END OF INPUT_DATA_EXTPROGSTEP.

DATA: BEGIN OF INPUT_DATA_EXTCOMMSTEP.
        INCLUDE STRUCTURE BTCH4230.
DATA: END OF INPUT_DATA_EXTCOMMSTEP.

DATA: BEGIN OF INPUT_DATA_SPOOLLIST.
        INCLUDE STRUCTURE BTCH4300.
DATA: END OF INPUT_DATA_SPOOLLIST.

DATA: BEGIN OF INPUT_DATA_START.
        INCLUDE STRUCTURE BTCH4400.
DATA: END OF INPUT_DATA_START.

DATA: BEGIN OF INPUT_DATA_STIMM.
        INCLUDE STRUCTURE BTCH4410.
DATA: END OF INPUT_DATA_STIMM.

DATA: BEGIN OF INPUT_DATA_STDT.
        INCLUDE STRUCTURE BTCH4420.
DATA: END OF INPUT_DATA_STDT.

DATA: BEGIN OF INPUT_DATA_STAFJOB.
        INCLUDE STRUCTURE BTCH4430.
DATA: END OF INPUT_DATA_STAFJOB.

DATA: BEGIN OF INPUT_DATA_STAFEVT.
        INCLUDE STRUCTURE BTCH4440.
DATA: END OF INPUT_DATA_STAFEVT.

DATA: BEGIN OF INPUT_DATA_STATOP.
        INCLUDE STRUCTURE BTCH4450.
DATA: END OF INPUT_DATA_STATOP.

DATA: BEGIN OF INPUT_DATA_WORKDAY.
        INCLUDE STRUCTURE BTCH4460.
DATA: END OF INPUT_DATA_WORKDAY.

DATA: BEGIN OF INPUT_DATA_SNJOBS.
        INCLUDE STRUCTURE BTCH4470.
DATA: END OF INPUT_DATA_SNJOBS.

DATA: BEGIN OF INPUT_DATA_PERD.
        INCLUDE STRUCTURE BTCH4500.
DATA: END OF INPUT_DATA_PERD.

DATA: BEGIN OF JOB_DEF_WIZ_INIT,
        JWIZD0 LIKE SWD_DATA-XFELD,
        JWIZD1 LIKE SWD_DATA-XFELD,
        JWIZD2 LIKE SWD_DATA-XFELD,
        JWIZD3 LIKE SWD_DATA-XFELD,
        JWIZD4 LIKE SWD_DATA-XFELD,
        JWIZD5 LIKE SWD_DATA-XFELD,
        JWIZD6 LIKE SWD_DATA-XFELD,
        JWIZD7 LIKE SWD_DATA-XFELD,
        JWIZD8 LIKE SWD_DATA-XFELD,
        JWIZD9 LIKE SWD_DATA-XFELD,
        JWIZD10 LIKE SWD_DATA-XFELD,
        JWIZD11 LIKE SWD_DATA-XFELD,
        JWIZD12 LIKE SWD_DATA-XFELD,
        JWIZD13 LIKE SWD_DATA-XFELD,
        JWIZD14 LIKE SWD_DATA-XFELD,
        JWIZD15 LIKE SWD_DATA-XFELD,
        JWIZD16 LIKE SWD_DATA-XFELD,
        JWIZD17 LIKE SWD_DATA-XFELD,
        JWIZD18 LIKE SWD_DATA-XFELD,
      END OF JOB_DEF_WIZ_INIT.

DATA: BEGIN OF JOB_STEP_LIST OCCURS 10,
        ABAPSTEP LIKE BTCH4200-ABAPSTEP,
        EXTPROGRAM LIKE BTCH4200-EXTPROGRAM,
        EXTCOMMAND LIKE BTCH4200-EXTCOMMAND,
        PROGNAME LIKE BTCH4210-PROGNAME,
        VARIANT LIKE BTCH4210-VARIANT,
        LANG LIKE BTCH4210-LANG,
        EXTPROG LIKE BTCH4220-EXTPROG,
        PARAM LIKE BTCH4220-PARAM,
        TRGTHOST LIKE BTCH4220-TRGTHOST,
        COMMNAME LIKE BTCH4230-COMMNAME,
        PARAM_COM LIKE BTCH4230-PARAM_COM,
        OS LIKE BTCH4230-OS,
        HOST LIKE BTCH4230-HOST,
     END OF JOB_STEP_LIST.

DATA: BTCHWIZALL_ITAB LIKE BTCHWIZALL OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF INPUT_DATA_RESTRICTION.
        INCLUDE STRUCTURE BTCH4480.
DATA: END OF INPUT_DATA_RESTRICTION.

DATA: WIZ_OKCODE LIKE SY-UCOMM.

* table control to show the existing jobs with same name
TYPE-POOLS CXTAB.
CONTROLS: TC TYPE TABLEVIEW USING SCREEN 4470.
DATA: SAME_NAME_JOBS LIKE TBTCO OCCURS 0 WITH HEADER LINE,
      NUMBER_SNJOBS TYPE I VALUE 1,
      TC_LINE(50),
      SELLINE LIKE SY-STEPL,
      TABIX LIKE TC-TOP_LINE.

* workday scheduled job with restriction
DATA: ACTUAL_EXEC_DATE LIKE SY-DATUM.

* temp storage for same name job.
DATA: TEMP_SNJOB LIKE BTCH4470.

* job card preview variables
DATA: JOBCARD(10) VALUE SPACE.

* for mini wizard of start conditino definition
DATA: START_STATUS(10) TYPE C.

* for job card tree control.
TYPES: NODE_TABLE_TYPE LIKE STANDARD TABLE OF MTREESNODE
         WITH DEFAULT KEY.

DATA: TREE_HANDLE TYPE CNTL_HANDLE.

* for mini wizard.
DATA: BEGIN OF fixed_info OCCURS 10.
        include structure job_step_list.
data:   jname like btch4100-jobname,
        repname like btch4210-progname,
        varname like btch4210-variant,
     END OF fixed_info.

data: wiz_mode(4) type c.

* external control flags
data: ext_ctrl_flag like btch1160 occurs 0 with header line.

* flag for schedule-only job.
data: schedule_only like btc_yes.

* 13.6.01   d023157  due to error
* internal table for print and archive parameters of job steps
* table will be filled in module pai_4210 (LBTCHI01)

data: begin of arc_pri_tab occurs 10.
          include structure arc_params.
          include structure pri_params.
data: end of arc_pri_tab.
