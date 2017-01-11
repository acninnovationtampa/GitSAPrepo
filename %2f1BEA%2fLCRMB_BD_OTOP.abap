FUNCTION-POOL /1BEA/CRMB_BD_O.              "MESSAGE-ID ..
*======================================================================
*
* The following coding has been generated. Please do not change
* manually. All modifications will be lost by new generation.
*
* The code generation was triggered by
*
* Name  : DDIC
* Date  : 03.05.2012
* Time  : 13:52:50
*
*======================================================================
**********************************************************************
* Definition of includes
**********************************************************************
INCLUDE BEA_BASICS.
INCLUDE BEA_PRC_CON.
INCLUDE CRM_OBJECT_TYPES_CON.

* Enqueue buffer (can be hard-coded to BDH)
 TYPES:
   BEGIN OF ty_enqueue_bdh_s,
     appl      TYPE bef_appl,
     bdh_guid  TYPE bea_bdh_guid,
   END OF ty_enqueue_bdh_s.
 TYPES:
   ty_enqueue_bdh_t TYPE TABLE OF ty_enqueue_bdh_s.
**********************************************************************
* Definition of contants
**********************************************************************
CONSTANTS:
  GC_APPL             TYPE BEF_APPL VALUE 'CRMB',
  GC_HEAD             TYPE BEA_SPLIT_REASON VALUE 'HEAD',
  GC_PARTNER          TYPE BEA_SPLIT_REASON VALUE 'PARTNER'.
**********************************************************************
* Definition of variables
**********************************************************************
DATA:
  GT_CUM_DFL    TYPE BEAT_CUM_DFL,
  GV_OWN_LOGSYS TYPE TBDLS-LOGSYS,
  GV_MAX_SEL_OPT TYPE SYTABIX VALUE 500,
  GV_MAX_COL_CAN TYPE SYTABIX VALUE 100,
  GS_DLI_HLP TYPE /1BEA/S_CRMB_DLI_WRK,
  GS_DLI_HLP_REF TYPE /1BEA/S_CRMB_DLI_WRK.

 DATA:
   GT_BDH_WRK TYPE /1BEA/T_CRMB_BDH_WRK,
   GT_BDH_HLP TYPE /1BEA/T_CRMB_BDH_WRK,
   GS_BDH_HLP TYPE /1BEA/S_CRMB_BDH_WRK,
   GT_BDI_WRK TYPE /1BEA/T_CRMB_BDI_WRK,
   GT_BDI_HLP TYPE /1BEA/T_CRMB_BDI_WRK,
   GS_BDI_HLP TYPE /1BEA/S_CRMB_BDI_WRK.

 DATA:
   GV_WITH_DOCFLOW TYPE BEA_BOOLEAN VALUE GC_FALSE.
TYPES:
  BEGIN OF XBELEG,
       ID(1) TYPE C,
       NR(9) TYPE N,
  END OF XBELEG.

 DATA:
   GT_ENQUEUE_BDH TYPE TY_ENQUEUE_BDH_T.
*.....................................................................
* Message and CRP-Handling
*.....................................................................
data: gt_return  type beat_return, "Messages of CREATE and CANCEL!
      gs_crp     type beas_crp,
      gv_loghndl type balloghndl.

* Event BD_OTOP
  INCLUDE %2f1BEA%2fX_CRMBBD_OTOP_0INC_F1CON.
**********************************************************************
* Definition of classes
**********************************************************************
CLASS /BEA/CL_EX_BDCPREQ DEFINITION LOAD.
CLASS /BEA/CL_EX_BDCPREQC DEFINITION LOAD.

DATA:
 GO_CPREQC TYPE REF TO BEA_CRMB_BD_CPREQC.

LOAD-OF-PROGRAM.
  DATA:
    LV_SGPB TYPE SYTABIX,
    LV_SGPBC(4).
  EXPORT APPL = GC_APPL TO MEMORY ID GC_APPL_MEMORY_ID.
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM         = gv_own_logsys.
   GET PARAMETER ID 'TRANSFER_BLOCKSIZE' FIELD LV_SGPBC.
   CATCH SYSTEM-EXCEPTIONS CONVERSION_ERRORS = 1.
     MOVE LV_SGPBC TO LV_SGPB.
   ENDCATCH.
   IF SY-SUBRC IS INITIAL.
     IF LV_SGPB > 0.
       GV_MAX_SEL_OPT = LV_SGPB.
     ENDIF.
   ENDIF.
   CLEAR: LV_SGPB, LV_SGPBC.
   GET PARAMETER ID 'COLL_CANC_BLOCKSIZE' FIELD LV_SGPBC.
   CATCH SYSTEM-EXCEPTIONS CONVERSION_ERRORS = 1.
     MOVE LV_SGPBC TO LV_SGPB.
   ENDCATCH.
   IF SY-SUBRC IS INITIAL.
     IF LV_SGPB > 0.
       GV_MAX_COL_CAN = LV_SGPB.
     ENDIF.
   ENDIF.
