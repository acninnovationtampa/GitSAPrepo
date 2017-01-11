function-pool /sapcnd/determination.

include %3CICON%3E.

type-pools: rsds, ctcus.

field-symbols:
    <f>                   type any,
    <time>                type any.

* field-symbols and data refs correspond
* globally set in /SAPCND/GET_APPL_USAGE
field-symbols:
    <head>                type any,
    <item>                type any,
    <data>                type any,
* these two are cond view dependent
    <result>              type any,
    <sel_t>               type table.

constants:
    yes                   type c value 'X',
    no                    type c value ' '.

constants:
    gc_fstst_free         type /sapcnd/access_field_type value 'A',
    gc_fstst_nosel(2)     type c                         value 'BC'.

constants:
    gc_timestamp_to_str   type fieldname value 'TIMESTAMP_TO',
    gc_timestamp_from_str type fieldname value 'TIMESTAMP_FROM',
    gc_release_status_str type fieldname value 'RELEASE_STATUS'.

* interface constants
include %2fSAPCND%2fLDETERMINATIONTC1.

* Key T682Z
types:
    begin of ty_t682z_key,
      kvewe    type /sapcnd/usage,
      kappl    type /sapcnd/application,
      kozgf    type /sapcnd/access_sequence,
      kolnr    type /sapcnd/access_id,
      tabix_1  type sytabix,
      tabix_2  type sytabix,
    end of    ty_t682z_key.

data:
    gr_head_comm          type ref to data,
    gr_item_comm          type ref to data,
    gr_koview             type ref to data,
    gr_koview_t           type ref to data,
    gr_usdata             type ref to data.

data:
    gs_t681v              type /sapcnd/t681v,
    gs_t681vt             type /sapcnd/t681vt,
    gs_t681a              type /sapcnd/t681a,
    gs_t681at             type /sapcnd/t681at.

data:
    gv_koview             type /sapcnd/cond_view_name,
    gv_koview_ttyp        type ddobjname.

data:
    gv_fb_us_put          type funcname.

data:
    gt_cond_tab           type table of /sapcnd/det_cond_int
                               initial size 5,
    gw_cond_tab           type /sapcnd/det_cond_int.

data:
    gt_t682z_buf          type table of /sapcnd/t682z_d
                               initial size 100,
    gw_t682z_buf          type /sapcnd/t682z_d.

data:
    gt_t682z_tab          type table of /sapcnd/t682z_d
                               initial size 10,
    gw_t682z_tab          type /sapcnd/t682z_d.

data:
    gt_t682z_key          type table of ty_t682z_key
                               initial size 25,
    gw_t682z_key type ty_t682z_key.

* Buffer Prestep Customizing
data
    gt_t682v_tab type hashed table of /sapcnd/t682v
                 with unique key kappl kvewe kschl kolnr
                 initial size 10.
* Analysis
data:
    gt_proto_fld_tab      type /sapcnd/det_analysis_fld_t,
    gw_proto_fld_tab      type /sapcnd/det_analysis_fld.

* /SAPCND/CNF_DYNAMIC_ACCESS
data:
    gt_coding_tab         type rsds_where_tab,
    gt_range_tab          type rsds_trange,
    gw_range_tab          type rsds_range,
    gw_range_fields       type rsds_frange,
    gw_range_sel          type rsdsselopt,
    gt_where_tab          type rsds_twhere,
    gw_where_tab          type rsds_where.

* /SAPCND/CNF_LOGTAB_2_RANGE
data:
    gw_logtab             type /sapcnd/key_value_pair,
    gw_ranges             type rsdsselopt.

* /SAPCND/CNF_DETERMINE
data:
    gt_conddet_tab        type /sapcnd/det_result_t,
    gw_conddet_tab        type /sapcnd/det_result.
