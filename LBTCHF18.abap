*----------------------------------------------------------------------*
***INCLUDE LBTCHF18 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  map_id_to_name
*&---------------------------------------------------------------------*
*       find the group name for a given (persistent) id
*----------------------------------------------------------------------*
*      -->P_BTCH1140_TGTSRVGRP  text
*      -->P_TGT_GRP_NAME  text
*----------------------------------------------------------------------*
FORM map_id_to_name USING    P_BTCH1140_TGTSRVGRP type BPSRVGRPN
                             P_TGT_GRP_NAME type BPSRVGRP.

data: all_grp_list type table of BPSRVGRPI,
      grp_list_wa  type BPSRVGRPI,
      tmp_id       type CSMSYSGUID,
      tmp_grp      type ref to CL_BP_SERVER_GROUP.


P_TGT_GRP_NAME = space.

CALL METHOD CL_BP_GROUP_FACTORY=>GET_GROUP_NAMES
   IMPORTING
    O_GROUPLIST = all_grp_list .

loop at all_grp_list into grp_list_wa.

  CALL METHOD CL_BP_GROUP_FACTORY=>MAKE_GROUP_BY_NAME
   EXPORTING
     I_NAME         = grp_list_wa-grpname
   RECEIVING
     O_GRP_INSTANCE = tmp_grp.

  tmp_id = tmp_grp->get_id( ).
  if tmp_id = P_BTCH1140_TGTSRVGRP.
     P_TGT_GRP_NAME = grp_list_wa-grpname.
     exit.
  endif.

endloop.

ENDFORM.                    " map_id_to_name
