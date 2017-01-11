*----------------------------------------------------------------------*
*   INCLUDE BEF_BASICS_CON                                             *
*----------------------------------------------------------------------*
*=======================================================================
* Constants definitions sorted by their meanings
*=======================================================================
constants:

* Boolean Variables:
  gc_no                 type xfeld             value ' ',   "#EC *
  gc_yes                type xfeld             value 'X',   "#EC *

* Fixed Values:
  gc_nocommit           type bef_commit        value ' ',   "#EC *
  gc_commit_async       type bef_commit        value 'A',   "#EC *
  gc_commit_sync        type bef_commit        value 'B',   "#EC *

* Message Types:
  gc_msgtype_a          type symsgty           value 'A',   "#EC *
  gc_msgtype_e          type symsgty           value 'E',   "#EC *
  gc_msgtype_i          type symsgty           value 'I',   "#EC *
  gc_msgtype_s          type symsgty           value 'S',   "#EC *
  gc_msgtype_w          type symsgty           value 'W',   "#EC *
  gc_msgtype_x          type symsgty           value 'X',   "#EC *

* Returncodes:
  gc_returncode_0       type sysubrc           value '0',   "#EC *
  gc_returncode_1       type sysubrc           value '1',   "#EC *
  gc_returncode_2       type sysubrc           value '2',   "#EC *
  gc_returncode_3       type sysubrc           value '3',   "#EC *
  gc_returncode_4       type sysubrc           value '4',   "#EC *
  gc_returncode_5       type sysubrc           value '5',   "#EC *
  gc_returncode_6       type sysubrc           value '6',   "#EC *


* Constants for Ranges:
  gc_rangesign_e        type tvarv_sign        value 'E',   "#EC *
  gc_rangesign_i        type tvarv_sign        value 'I',   "#EC *
  gc_rangeoption_eq     type tvarv_opti        value 'EQ',  "#EC *
  gc_rangeoption_ne     type tvarv_opti        value 'NE',  "#EC *
  gc_rangeoption_cp     type tvarv_opti        value 'CP',  "#EC *

* Miscellaneous:
  gc_local              type c                 value '$',   "#EC *
  gc_gennamespace       type namespace         value '/1BEA/',"#EC *
  gc_star               type c                 value '*',   "#EC *
  gc_underscore         type c                 value '_',   "#EC *
  gc_genflag_t          type genflag           value 'T',   "#EC *
  gc_genflag_x          type genflag           value 'X',   "#EC *
  gc_ddstate_a          type ddgotstate        value 'A',   "#EC *

* Search help exits:
  gc_step_disp         type ddshf4step         value 'DISP',"#EC *
  gc_step_return       type ddshf4step         value 'RETURN',"#EC *
  gc_step_exit         type ddshf4step         value 'EXIT'."#EC *
