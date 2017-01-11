*----------------------------------------------------------------------*
*   INCLUDE RSCSMEXTI                                                  *
*----------------------------------------------------------------------*

* CSMNUDATA constants - inactive container component

* ---------------------------------------------------------------------*
* Constants für die Übertragung von Daten über CSMNUDATA
* ---------------------------------------------------------------------*
* Standardname des Background-Jobs für die Verarbeitung von
* übertragenen CSM-Daten (CSMNUDATA)
CONSTANTS: csm_std_reconciliation_job(32) TYPE c
             VALUE 'CCMS_REPOSITORY_RECONCILIATION',        "#EC NOTEXT
           csm_std_repository_job(32) TYPE c
             VALUE 'CCMS_LOAD_REPOSITORY_LOCDATA',          "#EC NOTEXT
           csm_std_datasupplier TYPE rsvar-report
             VALUE 'CSM_LOAD_LOCAL_SYSTEM_DATA',            "#EC NOTEXT
           csm_std_reconciler TYPE rsvar-report
             VALUE 'CSM_RECONCILE_REPOSITORIES',            "#EC NOTEXT
           csm_std_datentransfer_job(32) TYPE c
             VALUE 'CCMS_DATA_TRANSFER_JOB',                "#EC NOTEXT

* Standardname des Benutzers, der lediglich in die CSMNUDATA
* schreiben darf - Anmeldebenutzer für SALRECVR Dateneingabe
  csm_csmnudata_writer TYPE sy-uname
             VALUE 'CCMS_DATA_R',                           "#EC NOTEXT

* Standardname des Benutzers, der CSMNUDATA verarbeiten darf,
* Berechtigungsbenutzer für CSM_STD_DATENTRANSFER_JOB.
  csm_csmnudata_processor TYPE sy-uname
             VALUE 'CCMS_DATA_W',                           "#EC NOTEXT

* Name of report for starting csmnudata processor
  csmnudata_process TYPE sy-repid VALUE 'RSCSMNUDATA_PROCESS',
                                                            "#EC NOTEXT

* Name of event upon which CSMNUDATA_PROCESSOR waits
  csmnudata_event(32) TYPE c VALUE 'SAP_RSCSMNUDATA',
                                                            "#EC NOTEXT

* Status von Sätzen in der CSMNUDATA
  added(4) TYPE c VALUE 'ADED',                             "#EC NOTEXT
  e_unauth_table(4) TYPE c VALUE 'AUTH',                    "#EC NOTEXT
  e_dupl_record(4) TYPE c VALUE 'DUPL',                     "#EC NOTEXT
  e_incomplete_key(4) TYPE c VALUE 'IKEY',                  "#EC NOTEXT
  e_dereference_fs(4) TYPE c VALUE 'DERF',                  "#EC NOTEXT
  e_interface_error(4) TYPE c VALUE 'INTF',                 "#EC NOTEXT
  inserted(4) TYPE c VALUE 'INSR',                          "#EC NOTEXT
  unchanged(4) TYPE c VALUE 'UNCH',                         "#EC NOTEXT
  e_lock_err(4) TYPE c VALUE 'LOCK',                        "#EC NOTEXT
  modified(4) TYPE c VALUE 'MODI',                          "#EC NOTEXT
  nu_data(4) TYPE c VALUE 'NEWD',                           "#EC NOTEXT
  e_invalid_table(4) TYPE c VALUE 'TABL',                   "#EC NOTEXT
  e_update_db(4) TYPE c VALUE 'UPDT',                       "#EC NOTEXT
* Status von Sätzen in der CSMNUDATA
* für die CSMBK
  e_incomplete_record(4) TYPE c VALUE 'IREC',               "#EC NOTEXT
  e_could_not_get_object_guid(4) TYPE c VALUE 'NGUD',       "#EC NOTEXT
  e_semantic_not_found(4) TYPE c VALUE 'NSEM',              "#EC NOTEXT
  e_invalid_guid(4) TYPE c VALUE 'IGUD',                    "#EC NOTEXT
  e_no_owner_class(4) TYPE c VALUE 'NOCL'.                  "#EC NOTEXT
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Constants for the CSMBK tables
*----------------------------------------------------------------------*
* Data cluster tables for class and token definitions
TABLES: csmbk_cl, csmbk_tk, csmbk_cl2, csmbk_tk2.

* Object types for CSMBK_OBJ
CONSTANTS:
* Length of a guid - used for simple check for
* valid GUID entries
            csm_guidlength TYPE i VALUE 32.
CONSTANTS:
* Ttype (association, property) for csmbk
* Also pa_flag in csmbk_sem (semantic definitions)
            association TYPE c VALUE 'A',                   "#EC NOTEXT
*            csm_association type c value 'A',
            property    TYPE c VALUE 'P',                   "#EC NOTEXT
            csm_property TYPE c VALUE 'P',                  "#EC NOTEXT
* Object types for csmbk_obj type field
            csm_association TYPE csmtokntyp
              VALUE 'ASSC',                                 "#EC NOTEXT
            csm_object TYPE csmtokntyp
              VALUE 'OBJ',                                  "#EC NOTEXT
* Authorization types - return codes for authorization
* check routine
            csm_change_authorization TYPE c VALUE '1',      "#EC NOTEXT
            csm_read_authorization   TYPE c VALUE '3',      "#EC NOTEXT
            csm_table_authorization  TYPE c VALUE '5',      "#EC NOTEXT
            csm_basis_table_authorization TYPE c VALUE '7', "#EC NOTEXT
* Booleans
            csm_yes     TYPE csmactive VALUE 'Y',           "#EC NOTEXT
            csm_no      TYPE csmactive VALUE 'N',           "#EC NOTEXT
            csm_none    TYPE csmactive VALUE '0',           "#EC NOTEXT
            csm_unknown TYPE csmactive VALUE '?',           "#EC NOTEXT
            csm_all     TYPE csmactive VALUE 'L',           "#EC NOTEXT
* Active value for class definitions and semantics
* And objects and properties
* May not be changed, used by SAL_RECVR to obtain
* active definition of a structure or table
            csm_active  TYPE csmactive VALUE 'A',           "#EC NOTEXT
            csm_deleted TYPE csmactive VALUE 'D',           "#EC NOTEXT
            csm_future  TYPE csmactive VALUE 'F',           "#EC NOTEXT
            csm_expired TYPE csmactive VALUE 'E',           "#EC NOTEXT
            csm_speculative TYPE csmactive VALUE 'P',       "#EC NOTEXT
              " Posited
* Class definition statuses
            csm_obsolete_class TYPE csmactive VALUE 'O',    "#EC NOTEXT
            csm_invalid_class TYPE csmactive VALUE 'I',     "#EC NOTEXT
* Operation codes for inter-system repository ops
            csm_reconcile TYPE csmactive VALUE 'R',         "#EC NOTEXT
            csm_update_data TYPE csmactive VALUE 'U',       "#EC NOTEXT
            csm_add TYPE csmactive VALUE '1',               "#EC NOTEXT
            csm_delete TYPE csmactive VALUE '2',            "#EC NOTEXT
            csm_update TYPE csmactive VALUE '3',            "#EC NOTEXT
            csm_new TYPE csmactive VALUE '6',               "#EC NOTEXT
            csm_nochange TYPE csmactive VALUE '7',          "#EC NOTEXT
            csm_register TYPE csmactive VALUE '5',          "#EC NOTEXT
            csm_fail TYPE csmactive VALUE '4',              "#EC NOTEXT
* System roles
            csm_subordinate_system TYPE csmactive VALUE 'S',"#EC NOTEXT
            csm_central_system TYPE csmactive VALUE 'C',    "#EC NOTEXT
* Select values
            csm_single TYPE csmactive VALUE 'S',            "#EC NOTEXT
            csm_multiple TYPE csmactive VALUE 'M',          "#EC NOTEXT
* Class types
            csm_association_class TYPE csmactive VALUE 'A', "#EC NOTEXT
            csm_indication_class TYPE csmactive VALUE 'I',  "#EC NOTEXT
            csm_object_class TYPE csmactive VALUE 'O',      "#EC NOTEXT
* Association types for SCSM_CLASS2CLASS_ASSOCPATH_GET
            csm_any_association TYPE csmactive VALUE 'A',   "#EC NOTEXT
            csm_scoping_association TYPE csmactive VALUE 'S',
                                                            "#EC NOTEXT
            csm_nonscoping_association TYPE csmactive VALUE 'N',
                                                            "#EC NOTEXT
* RFC destinations
            csm_dummy   TYPE almcname VALUE 'INITIAL',      "#EC NOTEXT
* Prefix for destination created in central system for
* accessing a remote system
            csm_standard_mnt_dest(17) TYPE c VALUE
              'CCMS_CSM_MNT_DEST',                          "#EC NOTEXT
            csm_standard_query_dest(17) TYPE c VALUE
              'CCMS_CSM_QRY_DEST',                          "#EC NOTEXT
            csm_cendesc TYPE rfcdoc_d
              VALUE 'Central System for CCMS Central System Management',
                                                            "#EC NOTEXT
            csm_standard_cen_dest(17) TYPE c VALUE
              'CCMS_CSM_CEN_DEST',                          "#EC NOTEXT
            csm_remdesc_m TYPE rfcdoc_d
              VALUE
  'Maint Access to Managed System in CCMS Central System Management',
                                                            "#EC NOTEXT
            csm_remdesc_q TYPE rfcdoc_d
              VALUE
  'Query Access to Managed System in CCMS Central System Management',
                                                            "#EC NOTEXT
            csm_standard_user LIKE sy-uname
              VALUE 'CSMREG',                               "#EC NOTEXT
* Reporter to be used for changes made from the
* configuration transaction - csm administrator
            csm_adm(32) TYPE c VALUE 'CCMS_CSM_ADMIN',      "#EC NOTEXT
*            csm_interpolated(32) type c value 'Interpolated',
*              "#EC NOTEXT
*            " Interpolated:  Name entry missing, object id used
* Permissible availability policies (name values)
            av_all             TYPE almteclass
              VALUE 'Monitor entire system',                "#EC NOTEXT
            av_none            TYPE almteclass
              VALUE 'Do not monitor system',                "#EC NOTEXT
* Association types
            " Part relation
            component TYPE csmassoc VALUE 1,
            dependency TYPE csmassoc VALUE 2,
            directed TYPE csmassoc VALUE 3,
* Reference token types
            csm_reference_type TYPE csmclass
              VALUE 'Reference_Type',                       "#EC NOTEXT
            csm_isreference TYPE csmclass
              VALUE 'IsReference',                          "#EC NOTEXT
            csm_reference_weak_side TYPE csmassoc
              VALUE 1,
             csm_weak_side TYPE csmtokntyp VALUE 'WEAK',    "#EC NOTEXT
             csm_reference_strong_side TYPE csmassoc
               VALUE 2,
             csm_strong_side TYPE csmtokntyp VALUE 'STRN',  "#EC NOTEXT
             csm_reference_directed_start TYPE csmassoc
               VALUE 3,
             csm_start_side TYPE csmtokntyp VALUE 'BEGN',   "#EC NOTEXT
             csm_reference_directed_end TYPE csmassoc
               VALUE 4,
             csm_end_side TYPE csmtokntyp VALUE 'END',      "#EC NOTEXT
             csm_reference_strong_side_cim TYPE csmassoc
               VALUE 5,
             csm_reference_weak_side_cim TYPE csmassoc
               VALUE 6,
             csm_assoc_beg TYPE csmassoc
               VALUE 7,
             csm_assoc_end TYPE csmassoc
               VALUE 8,
             csm_directed_assoc TYPE csmassoc
               VALUE 9,
             csm_sap_scope_assoc TYPE csmassoc
               VALUE 10,
             csm_cim_weak_assoc TYPE csmassoc
               VALUE 11,
* Token override values
             csm_override_allowed TYPE csmovrride
               VALUE 'Y',                                   "#EC NOTEXT
* Repository version
             csm_scr_version TYPE almteclass
               VALUE 'Version',                             "#EC NOTEXT
             repository_version LIKE sy-saprl
               VALUE '610',                                 "#EC NOTEXT
             model_version LIKE sy-saprl
               VALUE '1.0',                                 "#EC NOTEXT
* SAP keys constants
             csm_separator TYPE csmactive
               VALUE '_',                                   "#EC NOTEXT
             csm_quote TYPE csmactive
               VALUE '''',                                  "#EC NOTEXT
             csm_point TYPE csmactive
               VALUE '.',                                   "#EC NOTEXT
             csm_equal TYPE csmactive
               VALUE '=',                                   "#EC NOTEXT
             csm_equaldquote(2)
               VALUE '="',                                  "#EC NOTEXT
             csm_comma TYPE csmactive
               VALUE ',',                                   "#EC NOTEXT
             csm_dquotecomma(2)
               VALUE '",',                                  "#EC NOTEXT
             csm_dquote TYPE csmactive
               VALUE '"',                                   "#EC NOTEXT
             csm_escapeddquote(2)
               VALUE '\"',                                  "#EC NOTEXT
             csm_escapedsquote(2)
               VALUE '''''',                                "#EC NOTEXT
             csm_escapeddquote_placeholder(17)
               VALUE 'CSM_ESCAPEDDQUOTE',                   "#EC NOTEXT
             csm_schraeg TYPE csmactive
               VALUE '\',                                   "#EC NOTEXT
             csm_escapedschraeg(2)
               VALUE '\\',                                  "#EC NOTEXT
             csm_escapedschraeg_placeholder(19)
               VALUE 'CSM_ESCAPEDDSCHRAEG',                 "#EC NOTEXT
             csm_dummyvalue TYPE csmtoken
               VALUE 'INITIAL',                             "#EC NOTEXT
*             csm_sapkeypos type csmtoken "Not used. Pos is value of
*               value 'SAP_KEY_POSITION', "SAP_KEY
*             csm_ancestorkey type csmtoken
*               value 'ANCKey',
*             csm_keyend type csmtoken
*               value '##',
*             csm_scoping_association type csmtoken
*               value 'SCOPING_ASSOCIATION',
             csm_keypos_1 TYPE csmactive
               VALUE '1',                                   "#EC NOTEXT
             csm_keypos_2 TYPE csmactive
               VALUE '2',                                   "#EC NOTEXT
             csm_keypos_3 TYPE csmactive
               VALUE '3',                                   "#EC NOTEXT
             csm_keypos_4 TYPE csmactive
               VALUE '4',                                   "#EC NOTEXT
             csm_keypos_5 TYPE csmactive
               VALUE '5',                                   "#EC NOTEXT
             csm_keypos_6 TYPE csmactive
               VALUE '6',                                   "#EC NOTEXT
             csm_cim TYPE csmsmntc
               VALUE 'CIM',                                 "#EC NOTEXT
             csm_extended_val_entry TYPE csmtoken
               VALUE 'CSM_EXTENDED_VALHANDLING_ON',         "#EC NOTEXT
             csm_extended_key(5) VALUE '#XVAL',             "#EC NOTEXT
             csm_classkey_limit TYPE i VALUE 240,
             csm_classkey_xvallimit TYPE i VALUE 235,
             csm_value_limit TYPE i VALUE 40,
             csm_value_xvallimit TYPE i VALUE 35,
             csm_sapkey_field TYPE csmtoken
               VALUE 'SAP_KEY',                             "#EC NOTEXT
             csm_cimkey_field TYPE csmtoken
               VALUE 'CIM_KEY',                             "#EC NOTEXT
*             csm_propagkey_limit type i value 180,
*             csm_propagkey_xvallimit type i value 175,
*---------------------------------------------------------------*
* CSM Qualifiers
*---------------------------------------------------------------*
             csm_override TYPE csmtoken VALUE 'OVERRIDE',   "#EC NOTEXT
             csm_triggertype TYPE csmtoken VALUE 'TRIGGERTYPE',
* Trigger types
             csm_trigger_create TYPE csmobjnm VALUE 'CREATE',
             csm_trigger_update TYPE csmobjnm VALUE 'UPDATE',
             csm_trigger_access TYPE csmobjnm VALUE 'ACCESS',
             csm_trigger_throw TYPE csmobjnm VALUE 'THROW',
             csm_trigger_delete TYPE csmobjnm VALUE 'DELETE',
             csm_dynamic TYPE csmtoken
               VALUE 'DYNAMIC_CLASS',                       "#EC NOTEXT
             csm_sapkey TYPE csmtoken
               VALUE 'SAP_KEY',                             "#EC NOTEXT
             csm_replicate_class TYPE csmtoken
               VALUE 'REPLICATE_CLASS',                     "#EC NOTEXT
             csm_reconcile_class TYPE csmtoken
               VALUE 'RECONCILE_CLASS',                     "#EC NOTEXT
             csm_compound_key TYPE csmtoken
               VALUE 'SAP_COMPOSITE',                       "#EC NOTEXT
*             csm_sap_position type csmtoken
*               value 'SAP_Position',
             csm_sap_propagated TYPE csmtoken
               VALUE 'SAP_PROPAGATED',                      "#EC NOTEXT
             csm_cim_propagated TYPE csmtoken
               VALUE 'PROPAGATED',                          "#EC NOTEXT
             csm_compabbr TYPE csmtoken
               VALUE 'COMPONENT_ABBR',                      "#EC NOTEXT
             csm_xnameon TYPE csmtoken
               VALUE 'EXTENDED_NAMING_ON',                  "#EC NOTEXT
             csm_cimkey TYPE csmtoken
*               value 'CIM_KEY', "#EC NOTEXT
                VALUE 'KEY',                                "#EC NOTEXT
             csm_qualifier_version TYPE csmtoken
               VALUE 'VERSION',
             csm_delete_qualifier TYPE csmtoken
               VALUE 'DELETE',
             csm_ifdeleted_qualifier TYPE csmtoken
               VALUE 'IFDELETED',
             csm_ui_field TYPE csmtoken
               VALUE 'DISPLAYABLENAME',                     "#EC NOTEXT
             csm_scope_qualifier TYPE csmtoken
                VALUE 'SCOPED',                             "#EC NOTEXT
            csm_abstract TYPE csmclass VALUE
              'ABSTRACT',                                   "#EC NOTEXT
            csm_final TYPE csmclass VALUE
              'FINAL',                                      "#EC NOTEXT
            csm_component TYPE csmclass VALUE
              'COMPONENT',                                  "#EC NOTEXT
            csm_abap_class TYPE csmclass VALUE
              'ABAP_CLASS',                                 "#EC NOTEXT
            csm_standard_abap_class TYPE seoclsname VALUE
              'SCSM_MANAGED_ELEMENT',                       "#EC NOTEXT
            csm_java_class TYPE csmclass VALUE
              'JAVA_CLASS',                                 "#EC NOTEXT
            csm_array TYPE csmobjnm VALUE
              'ARRAYTYPE',                                  "#EC NOTEXT
            csm_classtoken_guid TYPE csmtoken
              VALUE 'CLASS_REPOSITORY_GUID',                "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Intrinsic method types and parameters
*---------------------------------------------------------------*
             csm_report TYPE csmmethtp
               VALUE 'R',                                   "#EC NOTEXT
             csm_callback TYPE csmmethtp
               VALUE 'C',                                   "#EC NOTEXT
             csm_fuba TYPE csmmethtp
               VALUE 'F',                                   "#EC NOTEXT
             csm_abapclass TYPE csmmethtp
               VALUE 'A',                                   "#EC NOTEXT
             csm_javaclass TYPE csmmethtp
               VALUE 'J',                                   "#EC NOTEXT
             csm_url TYPE csmmethtp
               VALUE 'U',                                   "#EC NOTEXT
             csm_selectoption TYPE tvarv_val
               VALUE 'MethRunReq',                          "#EC NOTEXT

*---------------------------------------------------------------*
* CSM Intrinsic events (standard events from csm_events)
*---------------------------------------------------------------*
             csm_classdef_change TYPE csmevent
               VALUE 'CSM_CLASSDEF_CHANGE',                 "#EC NOTEXT
             csm_classdef_lock TYPE csmevent
               VALUE 'CSM_CLASSDEF_LOCK',                   "#EC NOTEXT
             csm_classdef_new TYPE csmevent
               VALUE 'CSM_CLASSDEF_NEW',                    "#EC NOTEXT
             csm_classdef_newguid TYPE csmevent
               VALUE 'CSM_CLASSDEF_NEWGUID',                "#EC NOTEXT
             csm_classdef_obsolete TYPE csmevent
               VALUE 'CSM_CLASSDEF_OBSOLETE',               "#EC NOTEXT
             csm_classdef_unlock TYPE csmevent
               VALUE 'CSM_CLASSDEF_UNLOCK',                 "#EC NOTEXT
             csm_object_delete TYPE csmevent
               VALUE 'CSM_OBJECT_DELETE',                   "#EC NOTEXT
             csm_object_distributed_to_sub TYPE csmevent
               VALUE 'CSM_OBJECT_DISTRIBUTED_TO_SUB',       "#EC NOTEXT
             csm_object_maintained TYPE csmevent
               VALUE 'CSM_OBJECT_MAINTAINED',               "#EC NOTEXT
             csm_object_migrated TYPE csmevent
               VALUE 'CSM_OBJECT_MIGRATED',                 "#EC NOTEXT
             csm_object_new TYPE csmevent
               VALUE 'CSM_OBJECT_NEW',                      "#EC NOTEXT
             csm_system_initial_lic TYPE csmevent
               VALUE 'CSM_INITIAL_LICENSE',                 "#EC NOTEXT
             csm_system_dummy_lic TYPE csmevent
               VALUE 'CSM_DUMMY_LICENSE',                   "#EC NOTEXT
             csm_object_reconcile_newincen TYPE csmevent
               VALUE 'CSM_OBJECT_RECONCILE_NEWINCEN',       "#EC NOTEXT
             csm_object_reconcile_newinsub TYPE csmevent
               VALUE 'CSM_OBJECT_RECONCILE_NEWINSUB',       "#EC NOTEXT
             csm_object_reconcile_updincen TYPE csmevent
               VALUE 'CSM_OBJECT_RECONCILE_UPDINCEN',       "#EC NOTEXT
             csm_object_reconcile_updinsub TYPE csmevent
               VALUE 'CSM_OBJECT_RECONCILE_UPDINSUB',       "#EC NOTEXT
             csm_object_replicated TYPE csmevent
               VALUE 'CSM_OBJECT_REPLICATED',               "#EC NOTEXT
             csm_object_updated TYPE csmevent
               VALUE 'CSM_OBJECT_UPDATED',                  "#EC NOTEXT
             csm_property_value_changed TYPE csmevent
               VALUE 'CSM_PROPERTY_VALUE_CHANGED',          "#EC NOTEXT
             csm_new_namespace TYPE csmevent
               VALUE 'CSM_NEW_NAMESPACE',                   "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Subscriptions and methods
*---------------------------------------------------------------*
             csm_objabo TYPE csmabotyp
               VALUE 'O',                                   "#EC NOTEXT
             csm_clsabo TYPE csmabotyp
               VALUE 'C',                                   "#EC NOTEXT
             csm_synchron TYPE csmactive
               VALUE 'Y',                                   "#EC NOTEXT
             csm_validated TYPE csmactive
               VALUE 'Y',                                   "#EC NOTEXT
             csm_context_needed TYPE csmactive
               VALUE 'R',                                   "#EC NOTEXT
             csm_context_notneeded TYPE csmactive
               VALUE 'N',                                   "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Event types
*---------------------------------------------------------------*
             csm_sap_event TYPE csmactive
               VALUE 'S',                                   "#EC NOTEXT
             csm_user_event TYPE csmactive
               VALUE 'U',                                   "#EC NOTEXT
*---------------------------------------------------------------*
* CSM standard groups
*---------------------------------------------------------------*
              csm_known_systems TYPE csmobjnm
                VALUE 'CSM_Known_Systems',                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Class and Token Names
*---------------------------------------------------------------*

* Placeholder for creationclass, the CIM property used in
* CIM System and derived keys.  Creation class is not managed
* as a property but is rather present as part of the object entry.
             csm_creationclass TYPE csmtoken
               VALUE 'CreationClassName',                   "#EC NOTEXT

*---------------------------------------------------------------*
* Required NAME entry for each object - at this time,
* the only key field allowed for an object
*---------------------------------------------------------------*
            csm_name TYPE csmtoken VALUE 'Name',            "#EC NOTEXT
* Translation text
            csm_namet TYPE almteclass VALUE 'Name',         "#EC NOTEXT

*---------------------------------------------------------------*
* CSM Management Domain_V2 (Component name space root)
*---------------------------------------------------------------*
            cls_dom            TYPE csmclass "50
              VALUE 'BCManagedObjectsCollection',           "#EC NOTEXT
*              value 'SAPCCMS_Obj_Managed_Objects_Collection',
            tok_domname       TYPE csmtoken
              VALUE 'DomainName',                           "#EC NOTEXT
            tok_domversion       TYPE csmtoken
              VALUE 'Version',                              "#EC NOTEXT
* Initial central system management Domain_V2
* Scoped component hierarchy root - for all objects
* Associations to domain are implicit in CIM Domain_V2 concept,
* This is the relational realization.
            csm_default_domain TYPE csmobjnm
*              value 'CCMS_Domain',  "#EC NOTEX 'CCMS_Domain',
              VALUE 'CCMS_Domain',                 "#EC NOTEXT As of 50
*---------------------------------------------------------------*
* CSM R/3 System
*---------------------------------------------------------------*
            cls_r3             TYPE csmclass "50
              VALUE 'BCSystem',                             "#EC NOTEXT
*              value 'SAPCCMS_Obj_BCSystem',       "#EC NOTEXT
* Propagated key constants....
            tok_rfcsysname TYPE csmtoken  "RFCs for use by classes with
              VALUE 'SystemName',                           "#EC NOTEXT
                                           "established CIM Systme
            tok_rfcsyscreationclass TYPE csmtoken " propagation.
              VALUE 'SystemCreationClassName',              "#EC NOTEXT
            tok_rfcsyslicno TYPE csmtoken
              VALUE 'SystemNLic',                           "#EC NOTEXT
            tok_syscreationclass TYPE csmtoken
              VALUE 'SCCN',                                 "#EC NOTEXT
            val_syscreationclass TYPE csmobjnm
              VALUE 'R3',                                   "#EC NOTEXT
            tok_sysname TYPE csmtoken
              VALUE 'SN',                                   "#EC NOTEXT
            tok_syspropaglic TYPE csmtoken  "Not used
              VALUE 'SNLic',                                "#EC NOTEXT
            tok_r3sid        TYPE csmtoken  " New with 50
              VALUE 'SystemID',                             "#EC NOTEXT
            tok_r3role         TYPE csmtoken
              VALUE 'RoleInDevelopmentLandscape',           "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_CSMRole', "#EC NOTEXT
            tok_licno          TYPE csmtoken
              VALUE 'SystemLicenseKey',                     "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_LicenseNumber',  "#EC NOTEXT
            tok_instno          TYPE csmtoken
              VALUE 'SystemInstallationNumber',             "#EC NOTEXT
            tok_licexp         TYPE csmtoken
              VALUE 'LicenseExpiration',                    "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_LicenseExpiration',  "#EC NOTEXT
            tok_r3sysrelease   TYPE csmtoken
              VALUE 'Release',                              "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_Release', "#EC NOTEXT
*            tok_r3admin        type csmtoken
*              value 'Administrator', "#EC NOTEXT
**              value 'SAPCCMS_BCSystem_Administrator', "#EC NOTEXT
*            tok_r3admintel     type csmtoken
*              value 'AdministratorTel',
**              value 'SAPCCMS_BCSystem_AdministratorTel',
*              "#EC NOTEXT
*            tok_r3adminpager   type csmtoken
*              value 'AdministratorPager', "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_AdministratorPager', "#EC NOTEXT
            tok_r3desc         TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_Description', "#EC NOTEXT
            tok_r3loc          TYPE csmtoken
              VALUE 'Location',                             "#EC NOTEXT
*              value 'SAPCCMS_BCLocationSystem', "#EC NOTEXT
            tok_r3sysno        TYPE csmtoken
              VALUE 'SystemNumber',                         "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_Number', "#EC NOTEXT
            tok_r3dsractive    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsActive',
*---------------------------------------------------------------*
* SLD property names, unfortunately not always identical.
*---------------------------------------------------------------*
            bcsys_caption      TYPE csmtoken
              VALUE 'Caption',  "#EC NOTEXT
            bcsys_description  TYPE csmtoken
              VALUE 'Description',  "#EC NOTEXT
            bcsys_installdate  TYPE csmtoken
              VALUE 'InstallDate', "#EC NOTEXT
            bcsys_status       TYPE csmtoken
              VALUE 'Status', "#EC NOTEXT
            bcsys_nameformat   TYPE csmtoken
              VALUE 'NameFormat', "#EC NOTEXT
            bcsys_primaryownercontact TYPE csmtoken
              VALUE 'PrimaryOwnerContact', "#EC NOTEXT
            bcsys_primaryownername TYPE csmtoken
              VALUE 'PrimaryOwnerName', "#EC NOTEXT
            bcsys_name         TYPE csmtoken
              VALUE 'Name', "#EC NOTEXT
            bcsys_sapsystemname TYPE csmtoken
              VALUE 'SapSystemName', "#EC NOTEXT
            bcsys_systemnumber TYPE csmtoken
              VALUE 'SystemNumber', "#EC NOTEXT
            bcsys_systemhome TYPE csmtoken
              VALUE 'SystemHome', "#EC NOTEXT
            bcsys_systemlicensenumber TYPE csmtoken
              VALUE 'SystemLicenseNumber', "#EC NOTEXT
            bcsys_licenseexpiration TYPE csmtoken
              VALUE 'LicenseExpiration', "#EC NOTEXT
            bcsys_release TYPE csmtoken
              VALUE 'Release', "#EC NOTEXT
            bcsys_location TYPE csmtoken
              VALUE 'Location', "#EC NOTEXT
            bcsys_roleindevlandscape TYPE csmtoken
              VALUE 'RoleInDevelopmentLandscape', "#EC NOTEXT
            bcsys_roleincensysmanagement TYPE csmtoken
              VALUE 'RoleInCentralSystemManagement', "#EC NOTEXT
            bcsys_monitorinccms TYPE csmtoken
              VALUE 'MonitorInCCMS', "#EC NOTEXT
            bcsys_managewithagents TYPE csmtoken
              VALUE 'ManageWithAgents', "#EC NOTEXT
            bcsys_storeperfdatacentrally TYPE csmtoken
              VALUE 'StorePerformanceDataCentrally', "#EC NOTEXT
            bcsys_avlmonpolicy TYPE csmtoken
              VALUE 'AvailabilityMonitoringPolicy', "#EC NOTEXT
            bcsys_systemlanguage TYPE csmtoken
              VALUE 'SystemLanguage', "#EC NOTEXT
            bcsys_tmsdomain TYPE csmtoken
              VALUE 'TMSDomain', "#EC NOTEXT
            bcsys_tmstransportgroup TYPE csmtoken
              VALUE 'TMSTransportGroup', "#EC NOTEXT
            bcsys_tmstransportgroupname TYPE csmtoken
              VALUE 'TMSTransportGroupName', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM System Component Repository (Management Info, also
* for the monitoring architecture)
*---------------------------------------------------------------*
            cls_scrproxy    TYPE csmclass "50
              VALUE 'SystemComponentRepository',            "#EC NOTEXT
            tok_repvers        TYPE csmtoken
              VALUE 'SCRVersion',                           "#EC NOTEXT
*              value 'SAPCCMS_Repository_Version',
            tok_comprepvers   TYPE csmtoken
              VALUE 'CompatibleSCRVersions',
            tok_modelvers   TYPE csmtoken
              VALUE 'ModelVersion',
            tok_lastr3destchk TYPE csmtoken
              VALUE 'LastR3RFCDestinationCheck',
            tok_cenrole        TYPE csmtoken
              VALUE 'RoleInCentralSystemManagement',        "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_RoleInCentralSysMgmt',
            tok_r3firstreconcile TYPE csmtoken
              VALUE 'SCRFirstReconciliation',               "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_ReconciledTS',
            tok_r3lastcenupdate TYPE csmtoken
              VALUE 'SCRMostRecentReconciliation',          "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_UpdatedTS',
            tok_r3av           TYPE csmtoken
              VALUE 'AvailabilityMonitoringPolicy',         "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_MonitorAvail',      "#EC NOTEX T
            tok_agents         TYPE csmtoken
              VALUE 'ManageWithAgents',                     "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_ManWithAgents', "#EC NOTEXT
            tok_perfdata       TYPE csmtoken
              VALUE 'StorePerformanceDataCentrally',        "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_CollPerfData', "#EC NOTEXT
            tok_cendest        TYPE csmtoken
              VALUE 'CentralSystemDestination',             "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_DestCentralSys',
            tok_censys         TYPE csmtoken
              VALUE 'CentralSystem',                        "#EC NOTEXT
            tok_censysguid     TYPE csmtoken
              VALUE 'CentralSystemID',                      "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_MyCentralSys',
            tok_lokdest        TYPE csmtoken
              VALUE 'DestinationInCentralSystem',           "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_DestInCentralSys',
            tok_cenlastupdate  TYPE csmtoken
              VALUE 'CentralSCRLastUpdate',                 "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_LastUpdateFromSys',
            tok_r3mona         TYPE csmtoken
              VALUE 'MonitorInCCMS',                        "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_MonitorWithMona',    "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Distributed Application System
*---------------------------------------------------------------*
            cls_dasystem    TYPE csmclass "50
              VALUE 'DistributedApplicationSystem',         "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Distributed Application System Component System
*---------------------------------------------------------------*
            asc_dasystemcompsystem    TYPE csmclass "50
              VALUE 'DASystemComponentSystem',              "#EC NOTEXT
            tok_dasystemcompsystem TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_compsystemdasystem TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM AppServer Kernel (BCKernel)
*---------------------------------------------------------------*
            cls_bckernel TYPE csmclass
              VALUE 'BCKernel',                             "#EC NOTEXT
* Release replaced by version...
            tok_r3kernelrelease TYPE csmtoken
              VALUE 'Version',                              "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_KernelRelease', "#EC NOTEXT
* Product name...
            csm_kernel TYPE csmobjnm
              VALUE 'Kernel',                               "#EC NOTEXT
            csm_basis TYPE csmobjnm
              VALUE 'SAP_BASIS',                            "#EC NOTEXT
            tok_r3dbsupp        TYPE csmtoken
              VALUE 'CompatibleDBSystemReleases',           "#EC NOTEXT
*              value 'SAPCCMS_BCSupportedDB', "#EC NOTEXT
*            tok_supdb type csmtoken
**              value 'R3Host_DBVersionsSupported',
**              value 'SAPCCMS_R3Host_DBVersionsSupported',
                                                            "#EC NOTEXT
            tok_r3sapsupp       TYPE csmtoken
              VALUE 'CompatibleBCSystemReleases',           "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_SupportedSAP', "#EC NOTEXT
*            tok_supsap type csmtoken
*              value 'SAPVersionsSupported', "#EC NOTEXT
*              value 'R3Host_SAPVersionsSupported', "#EC NOTEXT
**              value 'SAPCCMS_R3Host_SAPVersionsSupported', "#EC NOTEXT
            tok_r3kernelpatchlevel TYPE csmtoken
              VALUE 'PatchLevel',                           "#EC NOTEXT
*              value 'SAPCCMS_BCSystem_KernelPatchlevel', "#EC NOTEXT
            tok_kernelcompiled TYPE csmtoken
              VALUE 'CompilationInfo',                      "#EC NOTEXT
*              value 'SAPCCMS_R3Host_KernelCompiled', "#EC NOTEXT
*            tok_kernelpatchlevel type csmtoken
*              value 'R3Host_KernelPatchLevel', "#EC NOTEXT
**              value 'SAPCCMS_R3Host_KernelPatchLevel', "#EC NOTEXT
            tok_supos TYPE csmtoken
              VALUE 'CompatibleOSReleases',                 "#EC NOTEXT
*              value 'SAPCCMS_R3Host_OpSysValid', "#EC NOTEXT
*            tok_kernelrelease type csmtoken
*              value 'R3Host_KernelRelease', "#EC NOTEXT
**              value 'SAPCCMS_R3Host_KernelRelease', "#EC NOTEXT
            tok_dblib TYPE csmtoken
              VALUE 'DBSLVersion',                          "#EC NOTEXT
*              value 'SAPCCMS_R3Host_DatabaseLibrary', "#EC NOTEXT
            tok_abapload TYPE csmtoken
              VALUE 'ABAPLoadVersion',                      "#EC NOTEXT
*              value 'SAPCCMS_R3Host_ABAPLoadVersion', "#EC NOTEXT
            tok_cuaload TYPE csmtoken
              VALUE 'CUALoadVersion',                       "#EC NOTEXT
*              value 'SAPCCMS_R3Host_CUALoadVersion', "#EC NOTEXT
            tok_kernelkind TYPE csmtoken
               VALUE 'KernelType',                          "#EC NOTEXT
*               value 'SAPCCMS_R3Host_KernelKind', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Kernel Component
*---------------------------------------------------------------*
            cls_bckernelcomponent TYPE csmclass
               VALUE 'BCKernelComponent',                   "#EC NOTEXT
            tok_kernelcomptype TYPE csmtoken
               VALUE 'Type',                                "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Database
*---------------------------------------------------------------*
            cls_db             TYPE csmclass "50
              VALUE 'DatabaseSystem',                       "#EC NOTEXT
*              value 'SAPCCMS_Obj_BCDatabase',
            tok_dbsid        TYPE csmtoken
              VALUE 'SID',                                  "#EC NOTEXT
            tok_dbsccn        TYPE csmtoken
              VALUE 'SCCN',                                 "#EC NOTEXT
            tok_dbsn        TYPE csmtoken
              VALUE 'SN',                                   "#EC NOTEXT
            tok_dbsnlic        TYPE csmtoken
              VALUE 'SNLic',                                "#EC NOTEXT
            tok_dbmaker        TYPE csmtoken
              VALUE 'Manufacturer',                         "#EC NOTEXT
*              value 'SAPCCMS_BCDB_Manufacturer', "#EC NOTEXT
            tok_dbrelease      TYPE csmtoken
              VALUE 'Release',                              "#EC NOTEXT
*              value 'SAPCCMS_BCDB_Release', "#EC NOTEXT
            tok_dbhostname         TYPE csmtoken
              VALUE 'Host',                                 "#EC NOTEXT
             tok_dbowner        TYPE csmtoken
              VALUE 'Owner',                                "#EC NOTEXT
*              value 'SAPCCMS_BCDB_Owner', "#EC NOTEXT
            tok_dbdblib          TYPE csmtoken
              VALUE 'Library',                              "#EC NOTEXT
*              value 'SAPCCMS_BCDB_Library', "#EC NOTEXT
*            tok_dbadmin        type csmtoken
*              value 'Administrator', "#EC NOTEXT
**              value 'SAPCCMS_BCDB_Administrator', "#EC NOTEXT
*            tok_dbadmintel     type csmtoken
*              value 'AdministratorTel', "#EC NOTEXT
**              value 'SAPCCMS_BCDB_AdministratorTel', "#EC NOTEXT
*            tok_dbadminpager   type csmtoken
*              value 'AdministratorPag', "#EC NOTEXT
**              value 'SAPCCMS_BCDB_AdministratorPag', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Database Instance New with 4.6D
*---------------------------------------------------------------*
            cls_dbinst             TYPE csmclass "50
              VALUE 'DatabaseInstance',                     "#EC NOTEXT
*              value 'SAPCCMS_Obj_BCDatabaseInstance',
*            tok_dbinstname         type csmtoken "50
*               value 'DBInstanceName',
*---------------------------------------------------------------*
* CSM Instance NO LONGER USED AS OF 4.6D
*---------------------------------------------------------------*
            cls_inst           TYPE csmclass
              VALUE 'SAPCCMS_Obj_BCInstance',               "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Client Logical System
*---------------------------------------------------------------*
            cls_logsys           TYPE csmclass "50
              VALUE 'LogicalSystem',                        "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3LogSys',  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Application Server
*---------------------------------------------------------------*
            cls_trex          TYPE csmclass "50
              VALUE 'TREX',                  "#EC NOTEXT
            cls_appsrv           TYPE csmclass "50
              VALUE 'BCApplicationServer',                  "#EC NOTEXT
*              value 'SAPCCMS_Obj_BCAppSrv',       "#EC NOTEXT
            tok_inav           TYPE csmtoken
              VALUE 'AvailabilityMonitoringPolicy',         "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_MonitorAvail',      "#EC NOTEXT
            tok_instprofile     TYPE csmtoken
              VALUE 'InstanceProfileName',                  "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_InstProfile',  "#EC NOTEXT
            tok_instpfpath      TYPE csmtoken
              VALUE 'InstanceProfilePath',                  "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_InstProfilePath', "#EC NOTEXT
            tok_startprofile    TYPE csmtoken
              VALUE 'StartProfileName',                     "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_StartProfile', "#EC NOTEXT
            tok_startpfpath     TYPE csmtoken
              VALUE 'StartProfilePath',                     "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_StartProfilePath', "#EC NOTEXT
            tok_homedir         TYPE csmtoken
              VALUE 'HomeDirectory',                        "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_HomeDirectory', "#EC NOTEXT
            tok_appsrv_services TYPE csmtoken
              VALUE 'Services',                             "#EC NOTEXT
*              value 'SAPCCMS_BCAppSrv_Services',
            tok_appsrv_number TYPE csmtoken
              VALUE 'Number',                               "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Client
*---------------------------------------------------------------*
            cls_cli            TYPE csmclass "50
              VALUE 'BCClient',                             "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3Client',       "#EC NOTEXT
            tok_clinum         TYPE csmtoken "50
              VALUE  'ClientNumber',                        "#EC NOTEXT
            tok_cliloc         TYPE csmtoken
              VALUE 'Location',                             "#EC NOTEXT
            tok_clisoftlock         TYPE csmtoken
              VALUE 'Softlock',                             "#EC NOTEXT
            tok_clioriginalcontrol         TYPE csmtoken
              VALUE 'OriginalControl',                      "#EC NOTEXT
            tok_clidesc        TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_R3Client_Description', "#EC NOTEXT
            tok_cli_curr        TYPE csmtoken
              VALUE 'Currency',                             "#EC NOTEXT
*              value 'SAPCCMS_R3Client_Currency', "#EC NOTEXT
            tok_cli_logsys      TYPE csmtoken
              VALUE 'LogicalSystemName',                    "#EC NOTEXT
*              value 'SAPCCMS_R3Client_LogicalSystem', "#EC NOTEXT
            tok_cli_changereg   TYPE csmtoken
              VALUE 'ClientSpecificChangePolicy',           "#EC NOTEXT
*              value 'SAPCCMS_R3Client_ChangeAllowed', "#EC NOTEXT
            val_cli_changereg_0  TYPE csmobjnm
              VALUE 'No auto. change-recording in transports',
                                                            "#EC NOTEXT
            val_cli_changereg_1  TYPE csmobjnm
              VALUE 'Changes recorded in transports',       "#EC NOTEXT
            val_cli_changereg_2  TYPE csmobjnm
              VALUE 'No customizing changes allowed',       "#EC NOTEXT
            val_cli_changereg_3  TYPE csmobjnm
              VALUE 'Cust. chngs allowed but not transported',
                                                            "#EC NOTEXT
            tok_cli_indep       TYPE csmtoken
              VALUE 'CrossClientChangePolicy',              "#EC NOTEXT
*              value 'SAPCCMS_R3Client_Independent', "#EC NOTEXT
            val_cli_indep_0  TYPE csmobjnm
              VALUE 'Client-independent changes allowed',   "#EC NOTEXT
            val_cli_indep_1  TYPE csmobjnm
            VALUE 'No changes allowed to cli.-indep. cust.',"#EC NOTEXT
            val_cli_indep_2  TYPE csmobjnm
              VALUE 'No changes allowed to repository obj.',"#EC NOTEXT
            val_cli_indep_3  TYPE csmobjnm
            VALUE 'No changes to cli.indep. cust. or obj.', "#EC NOTEXT
            tok_cli_cpylck      TYPE csmtoken
               VALUE 'ClientCopyPolicy',                    "#EC NOTEXT
*               value 'SAPCCMS_R3Client_CopyLock', "#EC NOTEXT
            val_cli_cpylck_x  TYPE csmobjnm
              VALUE 'No restriction',                       "#EC NOTEXT
            val_cli_cpylck_l  TYPE csmobjnm
              VALUE 'Pro.lev1 - no overwrite',              "#EC NOTEXT
            val_cli_cpylck_0  TYPE csmobjnm
            VALUE 'Pro.lev2 - no overwrite, no ext. avail.',"#EC NOTEXT
            tok_cli_cattstat    TYPE csmtoken
              VALUE 'CATTLocked',                           "#EC NOTEXT
*              value 'SAPCCMS_R3Client_CATTStatus', "#EC NOTEXT
            tok_cli_imprtcasc   TYPE csmtoken
              VALUE 'ClientCopyLocked',                     "#EC NOTEXT
*              value 'SAPCCMS_R3Client_ImportCascade', "#EC NOTEXT
            tok_cli_lock        TYPE csmtoken
              VALUE 'UpgradeLocked',                        "#EC NOTEXT
*              value 'SAPCCMS_R3Client_Lock', "#EC NOTEXT
            tok_cli_chnguser    TYPE csmtoken
              VALUE 'LastChangedBy',                        "#EC NOTEXT
*              value 'SAPCCMS_R3Client_LastChanger', "#EC NOTEXT
            tok_cli_chngdate    TYPE csmtoken
              VALUE 'LastChangedOn',                        "#EC NOTEXT
*              value 'SAPCCMS_R3Client_ChangeDate', "#EC NOTEXT
            tok_cli_role        TYPE csmtoken
              VALUE 'RoleInDevelopmentLandscape',           "#EC NOTEXT
*              value 'SAPCCMS_R3Client_Role', "#EC NOTEXT
            val_cli_role_p      TYPE csmobjnm
              VALUE 'Production (P)',                       "#EC NOTEXT
            val_cli_role_t      TYPE csmobjnm
              VALUE 'Test (T)',                             "#EC NOTEXT
            val_cli_role_c      TYPE csmobjnm
              VALUE 'Customizing (C)',                      "#EC NOTEXT
            val_cli_role_d      TYPE csmobjnm
              VALUE 'Demo (D)',                             "#EC NOTEXT
            val_cli_role_e      TYPE csmobjnm
              VALUE 'Training/Education (E)',               "#EC NOTEXT
            val_cli_role_f      TYPE csmobjnm
              VALUE 'SAP Reference (F)',                    "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 RFC Destination
*---------------------------------------------------------------*
            cls_logicalport    type csmclass
              value 'LogicalPort',
            cls_rfc            TYPE csmclass "50
              VALUE 'RFCDestination',                       "#EC NOTEXT
*              value 'SAPCCMS_Obj_RFCDest',        "#EC NOTEXT
*            tok_rfctype        type csmtoken
*              value 'RFCDest_Type', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_Type', "#EC NOTEXT
*            val_rfctype_l      type csmobjnm
*              value 'Logical Destination', "#EC NOTEXT
*            val_rfctype_3      type csmobjnm
*              value 'R/3 System', "#EC NOTEXT
*            val_rfctype_2      type csmobjnm
*              value 'R/2 System', "#EC NOTEXT
*            val_rfctype_I      type csmobjnm
*              value 'Internal Destination', "#EC NOTEXT
*            val_rfctype_T      type csmobjnm
*              value 'TCP/IP - External Program', "#EC NOTEXT
*            val_rfctype_X      type csmobjnm
*              value 'ABAP Driver', "#EC NOTEXT
*            val_rfctype_M      type csmobjnm
*              value 'Asynchronous X.400 R/3', "#EC NOTEXT
*            tok_rfcloadbal     type csmtoken
*              value 'RFCDest_LoadBalancing', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_LoadBalancing', "#EC NOTEXT
*            tok_rfcsysid       type csmtoken
*              value 'RFCDest_DestSystem', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_DestSystem', "#EC NOTEXT
*            tok_rfcsysnr       type csmtoken
*              value 'RFCDest_DestSystemNr', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_DestSystemNr', "#EC NOTEXT
            tok_rfcserver      TYPE csmtoken
              VALUE 'TargetHost',                           "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_DestServer', "#EC NOTEXT
*            tok_rfcgroup       type csmtoken
*              value 'RFCDest_DestGroup', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_DestGroup', "#EC NOTEXT
*            tok_rfctrustedsys  type csmtoken
*              value 'RFCDest_TrustedSystem', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_TrustedSystem', "#EC NOTEXT
*            tok_rfcsnc         type csmtoken
*              value 'RFCDest_SNC', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_SNC', "#EC NOTEXT
*            tok_rfclang        type csmtoken
*              value 'RFCDest_LogonLanguage', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_LogonLanguage', "#EC NOTEXT
*            tok_rfccli         type csmtoken
*              value 'RFCDest_LogonClient', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_LogonClient', "#EC NOTEXT
*            tok_rfcuser        type csmtoken
*               value 'RFCDest_LogonUser', "#EC NOTEXT
*               value 'SAPCCMS_RFCDest_LogonUser', "#EC NOTEXT
            tok_rfccharwidth        TYPE csmtoken
              VALUE 'TargetSystemCharacterWidth',           "#EC NOTEXT
            tok_rfconverterr        TYPE csmtoken
              VALUE 'OnConversionError',                    "#EC NOTEXT
            val_rfcconverrdump       TYPE csmobjnm
              VALUE 'Short dump',                           "#EC NOTEXT
            val_rfcconverrignore     TYPE csmobjnm
              VALUE 'Ignore',                               "#EC NOTEXT
            tok_rfcconverrchar       TYPE csmobjnm
              VALUE 'UnconvertibleCharacter',               "#EC NOTEXT
            tok_rfcunicodepoint      TYPE csmobjnm
              VALUE 'ErrorCharacterUnicodePoint',           "#EC NOTEXT
            tok_rfcdesc        TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_RFCDest_Description', "#EC NOTEXT
            tok_rfcgwhost       TYPE csmtoken
              VALUE 'GatewayHost',                          "#EC NOTEXT
*            tok_rfctgwhost       type csmtoken
*              value 'TargetGatewayHost', "#EC NOTEXT
*              value 'SAPCCMS_RFCDest_GWHost', "#EC NOTEXT
            tok_rfcgwservice    TYPE csmtoken
              VALUE 'GatewayService',                       "#EC NOTEXT
            tok_rfccreator    TYPE csmtoken
              VALUE 'Creator',                              "#EC NOTEXT
            tok_rfccreatdate    TYPE csmtoken
              VALUE 'CreationDate',                         "#EC NOTEXT
            tok_rfcchanger    TYPE csmtoken
              VALUE 'LastChangedBy',                        "#EC NOTEXT
            tok_rfcchangedate    TYPE csmtoken
              VALUE 'LastChangedOn',                        "#EC NOTEXT
            tok_rfctrace            TYPE csmtoken
              VALUE 'TraceOn',                              "#EC NOTEXT
            tok_rfclang        TYPE csmtoken
              VALUE 'TargetLogonLanguage',                  "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_LogonLanguage', "#EC NOTEXT
            tok_r3rfccli         TYPE csmtoken
              VALUE 'TargetLogonClientNumber',              "#EC NOTEXT
**              value 'SAPCCMS_R3RFCDest_LogonClient', "#EC NOTEXT
            tok_r3rfcuser        TYPE csmtoken
               VALUE 'TargetLogonUserName',                 "#EC NOTEXT
**               value 'SAPCCMS_R3RFCDest_LogonUser', "#EC NOTEXT
*            tok_rfctgwservice    type csmtoken
*              value 'TargetGatewayService', "#EC NOTEXT
*              value 'SAPCCMS_RFCDest_GWService', "#EC NOTEXT
*            tok_rfcalias        type csmtoken
*              value 'RFCDest_LogicalRef', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_LogicalRef', "#EC NOTEXT
*            tok_rfcmeth         type csmtoken
*              value 'RFCDest_TCPIPMethod', "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_TCPIPMethod', "#EC NOTEXT
*            val_rfcmeth_a       type csmobjnm
*              value 'Application Server', "#EC NOTEXT
*            val_rfcmeth_e       type csmobjnm
*              value 'Explicit Host', "#EC NOTEXT
*            val_rfcmeth_f       type csmobjnm
*              value 'Front-End Workstation', "#EC NOTEXT
            tok_rfcprog         TYPE csmtoken
              VALUE 'TargetProgramName',                    "#EC NOTEXT
**              value 'SAPCCMS_RFCDest_TCPIPProgram', "#EC NOTEXT
             tok_csmtype       TYPE csmtoken
               VALUE 'CSMType',                             "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 R3-HTTP Destination
*---------------------------------------------------------------*
            cls_httprfc TYPE csmclass
              VALUE 'R3HTTPDestination',                    "#EC NOTEXT
            tok_httpauth TYPE csmtoken
              VALUE 'SourceAuthorization',                  "#EC NOTEXT
            tok_httptarghost TYPE csmtoken
              VALUE 'TargetHost',                           "#EC NOTEXT
            tok_httptargserv TYPE csmtoken
              VALUE 'TargetService',                        "#EC NOTEXT
            tok_httplogonuser TYPE csmtoken
              VALUE 'LogonUser',                            "#EC NOTEXT
            tok_httplogonlang TYPE csmtoken
              VALUE 'LogonLanguage',                        "#EC NOTEXT
            tok_httplogonclient TYPE csmtoken
              VALUE 'LogonClient',                          "#EC NOTEXT
            tok_httptargpath TYPE csmtoken
              VALUE 'TargetPathPrefix',                     "#EC NOTEXT
            tok_httpproxyhost TYPE csmtoken
              VALUE 'ProxyHost',                            "#EC NOTEXT
            tok_httpproxyserv TYPE csmtoken
              VALUE 'ProxyService',                         "#EC NOTEXT
            tok_httpslogin TYPE csmtoken
              VALUE 'SingleSignOn',                         "#EC NOTEXT
            tok_httpsameuser TYPE csmtoken
              VALUE 'SameUser',                             "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 R3-HTTP ServicePort
*---------------------------------------------------------------*
            cls_httpserviceport TYPE csmclass
              VALUE 'HTTPServicePort',                      "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Logon-RFC Destination
*---------------------------------------------------------------*
            cls_logonrfc            TYPE csmclass "50
              VALUE 'LogonRFCDestination',                  "#EC NOTEXT
            tok_logonlang            TYPE csmtoken
              VALUE 'TargetLogonLanguage',                  "#EC NOTEXT
            tok_logoncli             TYPE csmtoken
              VALUE 'TargetLogonClientNumber',              "#EC NOTEXT
            tok_passwordprotect     TYPE csmtoken
              VALUE 'PasswordEncryptionOff',                "#EC NOTEXT
            tok_trustlogon          TYPE csmtoken
              VALUE 'LogonScreenForTrustedSystems',         "#EC NOTEXT
            tok_logonuser            TYPE csmtoken
              VALUE 'TargetLogonUserName',                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 non-R3-HTTP Destination
*---------------------------------------------------------------*
            cls_nonr3http            TYPE csmclass "50
              VALUE 'NonR3HTTPDestination',                 "#EC NOTEXT
            tok_targetlogonusername        TYPE csmtoken
              VALUE 'TargetLogonUserName',                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 R3-RFC Destination
*---------------------------------------------------------------*
            cls_r3rfc            TYPE csmclass "50
              VALUE 'R3RFCDestination',                     "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3RFCDest',        "#EC NOTEXT
            tok_r3rfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_DestActive',
            tok_r3sncname    TYPE csmtoken
              VALUE 'SNCName',                              "#EC NOTEXT
            tok_r3sncactive    TYPE csmtoken
              VALUE 'SNCActive',                            "#EC NOTEXT
            tok_r3sncqp    TYPE csmtoken
              VALUE 'SNCQualityOfProtection',               "#EC NOTEXT
*            tok_R3rfctype        type csmtoken
*              value 'RFCDest_Type', "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_Type', "#EC NOTEXT
*            val_rfctype_l      type csmobjnm
*              value 'Logical Destination', "#EC NOTEXT
*            val_rfctype_3      type csmobjnm
*              value 'R/3 System', "#EC NOTEXT
*            val_rfctype_2      type csmobjnm
*              value 'R/2 System', "#EC NOTEXT
*            val_rfctype_I      type csmobjnm
*              value 'Internal Destination', "#EC NOTEXT
*            val_rfctype_T      type csmobjnm
*              value 'TCP/IP - External Program', "#EC NOTEXT
*            val_rfctype_X      type csmobjnm
*              value 'ABAP Driver', "#EC NOTEXT
*            val_rfctype_M      type csmobjnm
*              value 'Asynchronous X.400 R/3', "#EC NOTEXT
            tok_r3rfcloadbal     TYPE csmtoken
              VALUE 'LoadBalancing',                        "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_LoadBalancing', "#EC NOTEXT
            tok_r3rfcsysid       TYPE csmtoken
              VALUE 'TargetSystemID',                       "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_DestSystem', "#EC NOTEXT
            tok_r3rfcsysnr       TYPE csmtoken
              VALUE 'TargetApplicationServerNumber',        "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_DestSystemNr', "#EC NOTEXT
            tok_r3rfcserver      TYPE csmtoken
              VALUE 'TargetApplicationServerHost',          "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_DestServer', "#EC NOTEXT
            tok_r3rfcmserver      TYPE csmtoken "50
              VALUE 'TargetMessageServerHost',              "#EC NOTEXT
            tok_r3rfcgroup       TYPE csmtoken
              VALUE 'TargetLogonGroup',                     "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_DestGroup', "#EC NOTEXT
            tok_r3rfctrustedsys  TYPE csmtoken
              VALUE 'SourceIsTrustedSystemInTargetSystem',  "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_TrustedSystem', "#EC NOTEXT
            tok_r3rfcsnc         TYPE csmtoken
              VALUE 'SNCActive',                            "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_SNC', "#EC NOTEXT
*            tok_R3rfclang        type csmtoken
*              value 'RFCDest_LogonLanguage', "#EC NOTEXT
**              value 'SAPCCMS_R3RFCDest_LogonLanguage', "#EC NOTEXT
*            tok_R3rfccli         type csmtoken
*              value 'RFCDest_LogonClient', "#EC NOTEXT
**              value 'SAPCCMS_R3RFCDest_LogonClient', "#EC NOTEXT
*            tok_R3rfcuser        type csmtoken
*               value 'RFCDest_LogonUser', "#EC NOTEXT
**               value 'SAPCCMS_R3RFCDest_LogonUser', "#EC NOTEXT
            tok_r3rfcdesc        TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_Description', "#EC NOTEXT
            tok_r3rfcgwhost       TYPE csmtoken
              VALUE 'GatewayHost',                          "#EC NOTEXT
**              value 'SAPCCMS_R3RFCDest_GWHost', "#EC NOTEXT
            tok_r3rfcgwservice    TYPE csmtoken
              VALUE 'GatewayService',                       "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_GWService', "#EC NOTEXT
*            tok_R3rfcalias        type csmtoken
*              value 'RFCDest_LogicalRef', "#EC NOTEXT
*              value 'SAPCCMS_R3RFCDest_LogicalRef', "#EC NOTEXT
*            tok_R3rfcmeth         type csmtoken
*              value 'SAPCCMS_R3RFCDest_TCPIPMethod', "#EC NOTEXT
*            val_rfcmeth_a       type csmobjnm
*              value 'Application Server', "#EC NOTEXT
*            val_rfcmeth_e       type csmobjnm
*              value 'Explicit Host', "#EC NOTEXT
*            val_rfcmeth_f       type csmobjnm
*              value 'Front-End Workstation', "#EC NOTEXT
*            tok_rfcprog         type csmtoken
*              value 'SAPCCMS_RFCDest_TCPIPProgram', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Logical RFC Destination   4.6D
*---------------------------------------------------------------*
            cls_logrfc            TYPE csmclass "50
              VALUE 'R3LogicalRFCDestination',              "#EC NOTEXT
*              value 'SAPCCMS_Obj_LogRFCDest',        "#EC NOTEXT
            tok_logrfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_DestActive',
*            tok_logrfcloadbal     type csmtoken
*              value 'RFCDest_LoadBalancing', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_LoadBalancing', "#EC NOTEXT
*            tok_logrfcsysid       type csmtoken
*              value 'RFCDest_DestSystem', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_DestSystem', "#EC NOTEXT
*            tok_logrfcsysnr       type csmtoken
*              value 'RFCDest_DestSystemNr', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_DestSystemNr', "#EC NOTEXT
*            tok_Logrfcserver      type csmtoken
*              value 'RFCDest_DestServer', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_DestServer', "#EC NOTEXT
*            tok_Logrfcgroup       type csmtoken
*              value 'RFCDest_DestGroup', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_DestGroup', "#EC NOTEXT
*            tok_logrfctrustedsys  type csmtoken
*              value 'RFCDest_TrustedSystem', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_TrustedSystem', "#EC NOTEXT
*            tok_logrfcsnc         type csmtoken
*              value 'RFCDest_SNC', "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_SNC', "#EC NOTEXT
            tok_logrfclang        TYPE csmtoken
              VALUE 'LogonLanguage',                        "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_LogonLanguage', "#EC NOTEXT
            tok_logrfccli         TYPE csmtoken
              VALUE 'LogonClient',                          "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_LogonClient', "#EC NOTEXT
            tok_logrfcuser        TYPE csmtoken
               VALUE 'LogonUser',                           "#EC NOTEXT
*               value 'SAPCCMS_LogRFCDest_LogonUser', "#EC NOTEXT
            tok_logrfcdesc        TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_Description', "#EC NOTEXT
            tok_logrfcgwhost       TYPE csmtoken
              VALUE 'GatewayHost',                          "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_GWHost', "#EC NOTEXT
            tok_logrfcgwservice    TYPE csmtoken
              VALUE 'GatewayService',                       "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_GWService', "#EC NOTEXT
            tok_logrfcalias        TYPE csmtoken
              VALUE 'ReferencedDestination',                "#EC NOTEXT
*              value 'SAPCCMS_LogRFCDest_LogicalRef', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 R/2 RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_r2rfc            TYPE csmclass "50
              VALUE 'R2RFCDestination',                     "#EC NOTEXT
*              value 'SAPCCMS_Obj_R2RFCDest',        "#EC NOTEXT
            tok_r2rfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_R2RFCDest_DestActive',
*---------------------------------------------------------------*
* CSM R/3 Internal RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_intrfc            TYPE csmclass "50
              VALUE 'InternalRFCDestination',               "#EC NOTEXT
*              value 'SAPCCMS_Obj_IntRFCDest',        "#EC NOTEXT
            tok_intrfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_IntRFCDest_DestActive',
            tok_intrfcsysnr       TYPE csmtoken
              VALUE 'TargetApplicationServerNumber',        "#EC NOTEXT
            tok_intrfcserver      TYPE csmtoken
              VALUE 'TargetApplicationServerHost',          "#EC NOTEXT
**---------------------------------------------------------------*
** CSM R/3 HTTP Destination  5.0A (6.10)
**---------------------------------------------------------------*
*            cls_r3http            type csmclass "50
*              value 'R3HTTPDestination',        "#EC NOTEXT
*            tok_r3httpactv    type csmtoken
*              value 'DestinationActive',
*            tok_r3httptrust    type csmtoken
*              value 'SourceIsTrustedSystemInTargetSystem',
*            tok_r3httplang    type csmtoken
*              value 'TargetLogonLanguage',
*            tok_r3httpcli    type csmtoken
*              value 'TargetLogonClientNumber',
*            tok_r3httpuser    type csmtoken
*              value 'TargetLogonUserName',
*---------------------------------------------------------------*
* CSM R/3 TCP/IP Service Port 50
*---------------------------------------------------------------*
            cls_tcpsrvport            TYPE csmclass "50
              VALUE 'TCPIPServicePort',                     "#EC NOTEXT
            tok_tcpporthost    TYPE csmtoken
              VALUE 'HostName',                             "#EC NOTEXT
            tok_tcpportservice    TYPE csmtoken
              VALUE 'ServiceName',                          "#EC NOTEXT
            tok_tcpportaddrtype    TYPE csmtoken
              VALUE 'AddressType',                          "#EC NOTEXT
            tok_tcpportaddr    TYPE csmtoken
              VALUE 'Address',                              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 TCP/IP RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_tcprfc            TYPE csmclass "50
              VALUE 'TCPIPRFCDestination',                  "#EC NOTEXT
*              value 'SAPCCMS_Obj_TCPRFCDest',        "#EC NOTEXT
            tok_tcprfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_DestActive',
*            tok_tcprfcserver      type csmtoken
*              value 'RFCDest_DestServer', "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_DestServer', "#EC NOTEXT
*            tok_tcprfcdesc        type csmtoken
*              value 'RFCDest_Description', "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_Description', "#EC NOTEXT
            tok_tcprfcgwhost       TYPE csmtoken
              VALUE 'GatewayHost',                          "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_GWHost', "#EC NOTEXT
            tok_tcprfcgwservice    TYPE csmtoken
              VALUE 'GatewayService',                       "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_GWService', "#EC NOTEXT
            tok_tcprfcmeth         TYPE csmtoken
              VALUE 'TargetStartMethod',                    "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_TCPIPMethod', "#EC NOTEXT
            val_rfcmeth_a       TYPE csmobjnm
              VALUE 'Application Server',                   "#EC NOTEXT
            val_rfcmeth_e       TYPE csmobjnm
              VALUE 'Explicit Host',                        "#EC NOTEXT
            val_rfcmeth_f       TYPE csmobjnm
              VALUE 'Front-End Workstation',                "#EC NOTEXT
            tok_tcprfcprog         TYPE csmtoken
              VALUE 'TargetProgramName',                    "#EC NOTEXT
*              value 'SAPCCMS_TCPRFCDest_TCPIPProgram', "#EC NOTEXT
            tok_tcprfchost         TYPE csmtoken
              VALUE 'TargetHost',                           "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 ABAP Treiber X RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_xrfc            TYPE csmclass "50
              VALUE 'ABAPDriverRFCDestination',             "#EC NOTEXT
*              value 'SAPCCMS_Obj_XRFCDest',        "#EC NOTEXT
            tok_xrfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive', "Internal upgrade done
*              value 'SAPCCMS_XRFCDest_DestActive',
            tok_drvpgm TYPE csmtoken
              VALUE 'DriverProgramName',                    "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 CMC M RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_mrfc            TYPE csmclass "50
              VALUE 'CMCRFCDestination',                    "#EC NOTEXT
*              value 'SAPCCMS_Obj_MRFCDest',        "#EC NOTEXT
            tok_mrfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_MRFCDest_DestActive',
            tok_mrfc_targetcmchost TYPE csmtoken            " new 50
              VALUE 'TargetCMCHost',                        "#EC NOTEXT
            tok_mrfc_targetcmcprog TYPE csmtoken
              VALUE 'TargetCMCPathOrProgram',               "#EC NOTEXT
            tok_mrfc_targetcmcrecipient TYPE csmtoken
              VALUE 'TargetCMCRecipient',                   "#EC NOTEXT
            tok_mrfc_targetappsrvhost TYPE csmtoken
              VALUE 'TargetApplicationServerHost',          "#EC NOTEXT
            tok_mrfc_targetappsrvnumber TYPE csmtoken
              VALUE 'TargetApplicationServerNumber',        "#EC NOTEXT
            tok_mrfc_sourceappsrvhost TYPE csmtoken
              VALUE 'SourceApplicationServerHost',          "#EC NOTEXT
            tok_mrfc_sourceappsrvnumber TYPE csmtoken
              VALUE 'SourceApplicationServerNumber',        "#EC NOTEXT
            tok_mrfc_sourcelogonclient TYPE csmtoken
              VALUE 'SourceLogonClientNumber',              "#EC NOTEXT
            tok_mrfc_sourcelogonuser TYPE csmtoken
              VALUE 'SourceLogonUserName',                  "#EC NOTEXT
            tok_mrfc_sourcelogonlang TYPE csmtoken
              VALUE 'SourceLogonLanguage',                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 SNA S RFC Destination  4.6D
*---------------------------------------------------------------*
            cls_srfc            TYPE csmclass "50
              VALUE 'SNARFCDestination',                    "#EC NOTEXT
*              value 'SAPCCMS_Obj_SRFCDest',        "#EC NOTEXT
            tok_srfcdestactv    TYPE csmtoken
              VALUE 'DestinationActive',                    "#EC NOTEXT
*              value 'SAPCCMS_SRFCDest_DestActive',
*---------------------------------------------------------------*
* CSM R/3 Message Server
*---------------------------------------------------------------*
            cls_msgsrv         TYPE csmclass
              VALUE 'BCMessageServer',                      "#EC NOTEXT
*              value 'SAPCCMS_Obj_BCMsgSrv',       "#EC NOTEXT
            tok_msgsrv_host TYPE csmtoken
              VALUE 'Host',                                 "#EC NOTEXT
            tok_msgsrv_service TYPE csmtoken      " NEW 4.6D!!!
              VALUE 'Service',                              "#EC NOTEXT
*              value 'SAPCCMS_MsgSrv_Service',
            tok_msgsrv_routerstring TYPE csmtoken " NEW 4.6D!!!
              VALUE 'RouterString',                         "#EC NOTEXT
*              value 'SAPCCMS_MsgSrv_RouterString',
*---------------------------------------------------------------*
* CSM R/3 ApplicationService
*---------------------------------------------------------------*
             cls_appservice TYPE csmclass
               VALUE 'ApplicationService',                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 ApplicationService access point
*---------------------------------------------------------------*
             cls_appsap TYPE csmclass
               VALUE 'ApplicationServiceAccessPoint',       "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 ApplicationServicePort
*---------------------------------------------------------------*
             cls_appport TYPE csmclass
               VALUE 'ApplicationServicePort',              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 ApplicationServiceReference
*---------------------------------------------------------------*
             cls_appref TYPE csmclass
               VALUE 'ApplicationServiceReference',         "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 SoftwareSystem
*---------------------------------------------------------------*
             cls_swsystem TYPE csmclass
               VALUE 'SoftwareSystem',                      "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Message Server Service
*---------------------------------------------------------------*
* OUT WITH 4.6D
            cls_msgsrvservice  TYPE csmclass
              VALUE 'SAPCCMS_Obj_BCService',                "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Monitoring Architecture System Group
*---------------------------------------------------------------*
            cls_grp            TYPE csmclass "50
              VALUE 'BCSystemGroup',                        "#EC NOTEXT
*              value 'SAPCCMS_Obj_SysGrp',          "#EC NOTEXT
            tok_grpid          TYPE csmtoken
               VALUE 'CollectionID',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Host
*---------------------------------------------------------------*
            cls_host           TYPE csmclass "50
              VALUE 'ComputerSystem',                       "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3Host',          "#EC NOTEXT
            tok_hostip TYPE csmtoken
              VALUE 'IPAddress',                            "#EC NOTEXT
*              value 'SAPCCMS_R3Host_IPAddress', "#EC NOTEXT
            tok_opsys TYPE csmtoken
              VALUE 'OpSys',                                "#EC NOTEXT
*              value 'SAPCCMS_R3Host_OpSys', "#EC NOTEXT
            tok_osrel TYPE csmtoken
               VALUE 'OpSysRelease',                        "#EC NOTEXT
*               value 'SAPCCMS_R3Host_OpSysRelease', "#EC NOTEXT
            tok_matype TYPE csmtoken
              VALUE 'MachineType',                          "#EC NOTEXT
            tok_osvalid TYPE csmtoken
              VALUE 'OpSysValid',                           "#EC NOTEXT
            tok_ossapverssupp TYPE csmtoken
              VALUE 'SAPVersionsSupported',                 "#EC NOTEXT
*              value 'SAPCCMS_R3Host_MachineType', "#EC NOTEXT
*            tok_sapsysid type csmtoken Not used in 50
*              value 'R3Host_SAPSystemID', "#EC NOTEXT
*              value 'SAPCCMS_R3Host_SAPSystemID', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Availability Policy
*---------------------------------------------------------------*
            cls_av             TYPE csmclass "50
              VALUE 'BCAvailabilityPolicy',                 "#EC NOTEXT
*              value 'SAPCCMS_Obj_AvPol',           "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Printers
*---------------------------------------------------------------*
            cls_r3prt          TYPE csmclass "50
              VALUE 'PrintSAP',                             "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3Printer',       "#EC NOTEXT
            tok_r3prt_devtype  TYPE csmtoken
              VALUE 'DeviceType',                           "#EC NOTEXT
*              value 'SAPCCMS_R3Printer_DeviceType', "#EC NOTEXT
            tok_r3prt_desc     TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
*              value 'SAPCCMS_R3Printer_Description', "#EC NOTEXT
            tok_r3prt_printprotocol     TYPE csmtoken
              VALUE 'PrintProtocol',                        "#EC NOTEXT
            tok_r3prt_printprotocolinfo     TYPE csmtoken
              VALUE 'PrintProtocolInfo',                    "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Component
*---------------------------------------------------------------*
            cls_r3comp         TYPE csmclass "50
              VALUE 'Component',                            "#EC NOTEXT
*              value 'SAPCCMS_Obj_R3Component', "#EC NOTEXT
            tok_r3comp_release TYPE csmtoken
              VALUE 'Version',                              "#EC NOTEXT
*              value 'SAPCCMS_R3Component_Release', "#EC NOTEXT
            tok_r3comp_prodname TYPE csmtoken
              VALUE 'ProductName',                          "#EC NOTEXT
            tok_r3comp_vendor TYPE csmtoken
              VALUE 'Vendor',                               "#EC NOTEXT
            tok_r3comp_idnr TYPE csmtoken
              VALUE 'IdentifyingNumber',                    "#EC NOTEXT
            tok_r3comp_sn TYPE csmtoken
              VALUE 'SN',                                   "#EC NOTEXT
            tok_r3comp_sccn TYPE csmtoken
              VALUE 'SCCN',                                 "#EC NOTEXT
            tok_r3comp_slic TYPE csmtoken
              VALUE 'SNLIC',                                "#EC NOTEXT
*            tok_r3comp_prodname type csmtoken
*              value 'ProductName',
            tok_r3comp_patchlevel TYPE csmtoken
              VALUE 'PatchLevel',                           "#EC NOTEXT
*              value 'SAPCCMS_R3Component_PatchLevel', "#EC NOTEXT
            tok_r3comp_desc TYPE csmtoken
              VALUE 'Description',                          "#EC NOTEXT
            tok_r3comp_type TYPE csmtoken
              VALUE 'Type',                                 "#EC NOTEXT
            val_r3comp_type_a TYPE csmobjnm
              VALUE 'Add-On',                               "#EC NOTEXT
            val_r3comp_type_c TYPE csmobjnm
              VALUE 'Component',                            "#EC NOTEXT
*              value 'SAPCCMS_R3Component_Description', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Support Package
*---------------------------------------------------------------*
            cls_r3support_pack TYPE csmclass "50
              VALUE 'SupportPackage',                       "#EC NOTEXT
*              value 'SAPCCMS_Obj_SupportPackage', "#EC NOTEXT
            tok_sw_id TYPE csmtoken
              VALUE 'SoftwareElementID',                    "#EC NOTEXT
            tok_sw_state TYPE csmtoken
              VALUE 'SoftwareElementState',                 "#EC NOTEXT
            tok_sw_targetos TYPE csmtoken
              VALUE 'TargetOperatingSystem',                "#EC NOTEXT
            tok_sw_version TYPE csmtoken
              VALUE 'Version',                              "#EC NOTEXT
            tok_sw_sccn TYPE csmtoken
              VALUE 'SCCN',                                 "#EC NOTEXT
            tok_sw_sn TYPE csmtoken
              VALUE 'SN',                                   "#EC NOTEXT
            tok_sw_snlic TYPE csmtoken
              VALUE 'SNLic',                                "#EC NOTEXT
            tok_31_45_hpnumber TYPE csmtoken
              VALUE 'HotPack_Num31_45',                     "#EC NOTEXT
*              value 'SAPCCMS_HotPack_Num31_45', "#EC NOTEXT
            tok_31_45_hpstat TYPE csmtoken
              VALUE 'HotPack_Stat31_45',                    "#EC NOTEXT
*              value 'SAPCCMS_HotPack_Stat31_45', "#EC NOTEXT
            tok_31_45_hptype TYPE csmtoken
              VALUE 'HotPack_Type31_45',                    "#EC NOTEXT
*              value 'SAPCCMS_HotPack_Type31_45', "#EC NOTEXT
            tok_r3support_desc TYPE csmtoken
               VALUE 'Description',                         "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Description', "#EC NOTEXT
            tok_r3support_status TYPE csmtoken
               VALUE 'Status',                              "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Status', "#EC NOTEXT
            val_r3support_status_n TYPE csmobjnm
               VALUE 'Support package not installed',       "#EC NOTEXT
            val_r3support_status_i TYPE csmobjnm
               VALUE 'Support package installed successfully',
                                                            "#EC NOTEXT
            val_r3support_status_? TYPE csmobjnm
               VALUE 'Package installation aborted',        "#EC NOTEXT
            val_r3support_status_d TYPE csmobjnm
               VALUE 'Support package installed without SPAM',
                                                            "#EC NOTEXT
            val_r3support_status_u TYPE csmobjnm
               VALUE 'Support package integrated in update',"#EC NOTEXT
            tok_r3support_responsible TYPE csmtoken
               VALUE 'Responsible',                         "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Resp', "#EC NOTEXT
            tok_r3support_idate TYPE csmtoken
               VALUE 'ImplementationDate',                  "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_IDate', "#EC NOTEXT
            tok_r3support_itime TYPE csmtoken
               VALUE 'ImplementationTime',                  "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_ITime', "#EC NOTEXT
            tok_r3support_limplrel TYPE csmtoken
               VALUE 'LegalImplementationRequirement',      "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_LImplRel', "#EC NOTEXT
            tok_r3support_conflict TYPE csmtoken
               VALUE 'Conflict',                            "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Conflict', "#EC NOTEXT
            tok_r3support_confirmed TYPE csmtoken
               VALUE 'Confirmed',                           "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Confirmed', "#EC NOTEXT
            tok_r3support_fromrel TYPE csmtoken
               VALUE 'FromRelease',                         "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_FromRel', "#EC NOTEXT
            tok_r3support_torel TYPE csmtoken
               VALUE 'ToRelease',                           "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_ToRel', "#EC NOTEXT
            tok_r3support_os TYPE csmtoken
               VALUE 'OperatingSystem',                     "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_OS', "#EC NOTEXT
            tok_r3support_db TYPE csmtoken
               VALUE 'DataBase',                            "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_DB', "#EC NOTEXT
            tok_r3support_patchtype TYPE csmtoken
               VALUE 'PatchType',                           "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_PatchType', "#EC NOTEXT
            val_r3support_patchtype_lcp TYPE csmobjnm
               VALUE 'Legal Change Patch (LCP)',            "#EC NOTEXT
            val_r3support_patchtype_pat TYPE csmobjnm
               VALUE 'SPAM-Update (PAT)',                   "#EC NOTEXT
            val_r3support_patchtype_hot TYPE csmobjnm
               VALUE 'Hot Package (HOT)',                   "#EC NOTEXT
            val_r3support_patchtype_crt TYPE csmobjnm
               VALUE 'Conflict Resolution Transport (CRT)', "#EC NOTEXT
            val_r3support_patchtype_ffd TYPE csmobjnm
               VALUE 'FCS-Final Delta Patch (FFD)',         "#EC NOTEXT
            val_r3support_patchtype_bwp TYPE csmobjnm
               VALUE 'Business Warehouse Patch (BWP)',      "#EC NOTEXT
            val_r3support_patchtype_aoi TYPE csmobjnm
               VALUE 'Add-On Installation (AOI)',           "#EC NOTEXT
            val_r3support_patchtype_aou TYPE csmobjnm
               VALUE 'Add-On Upgrade (AOU)',                "#EC NOTEXT
            val_r3support_patchtype_aop TYPE csmobjnm
               VALUE 'Add-On Patch (AOP)',                  "#EC NOTEXT
            val_r3support_patchtype_cop TYPE csmobjnm
               VALUE 'Component Patch (COP)',               "#EC NOTEXT
            val_r3support_patchtype_lan TYPE csmobjnm
               VALUE 'Language Package (LAN)',              "#EC NOTEXT
            tok_r3support_ancestor TYPE csmtoken
               VALUE 'Ancestor',                            "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Ancestor', "#EC NOTEXT
            tok_r3support_strictseq TYPE csmtoken
               VALUE 'StrictSequence',                      "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_StrictSeq', "#EC NOTEXT
            tok_r3support_nogen TYPE csmtoken
               VALUE 'NoGeneration',                        "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_NoGen', "#EC NOTEXT
            tok_r3support_spamfix TYPE csmtoken
               VALUE 'SpamFix',                             "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_SpamFix', "#EC NOTEXT
            tok_r3support_addonid TYPE csmtoken
               VALUE 'AddOnID',                             "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_AddonID', "#EC NOTEXT
            tok_r3support_addonrel TYPE csmtoken
               VALUE 'AddOnRelease',                        "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_AddonRel', "#EC NOTEXT
            tok_r3support_ign_confli TYPE csmtoken
               VALUE 'IgnoreConflict',                      "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_IgnoreConfl', "#EC NOTEXT
            tok_r3support_apancest TYPE csmtoken
               VALUE 'AddOnPackageAncestor',                "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_APAncest', "#EC NOTEXT
            tok_r3support_epsfilsiz TYPE csmtoken
               VALUE 'EPSFileSize',                         "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_EPSFilSiz', "#EC NOTEXT
            tok_r3support_hiancest TYPE csmtoken
               VALUE 'HighAncestor',                        "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_HiAnc', "#EC NOTEXT
            tok_r3support_comprel TYPE csmtoken
               VALUE 'ComponentRelease',                    "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_CompRel', "#EC NOTEXT
            tok_r3support_comp TYPE csmtoken
               VALUE 'Component',                           "#EC NOTEXT
*               value 'SAPCCMS_SupportPackage_Comp', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Person
*---------------------------------------------------------------*
           cls_person TYPE csmclass "50
             VALUE 'Person',                                "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R/3 Op Mode
*---------------------------------------------------------------*
           cls_r3opmode TYPE csmclass "50
             VALUE 'BCOperationMode',                       "#EC NOTEXT
*             value 'SAPCCMS_Obj_Opmode',
           tok_opmodetype TYPE csmtoken
             VALUE 'Type',                                  "#EC NOTEXT
*             value 'SAPCCMS_Opmode_Type',
           val_opmodetype_t TYPE csmobjnm
             VALUE 'Test (T)',                              "#EC NOTEXT
           val_opmodetype_p TYPE csmobjnm
             VALUE 'Production (P)',                        "#EC NOTEXT
           val_opmodetype_m TYPE csmobjnm
             VALUE 'Maintenance (M)',                       "#EC NOTEXT
           tok_opmodesel TYPE csmtoken
             VALUE 'ApplicationServerSelection',            "#EC NOTEXT
*             value 'SAPCCMS_Opmode_InstanceSelection',
           val_opmodesel_a TYPE csmobjnm
             VALUE 'All (A)',                               "#EC NOTEXT
           val_opmodesel_e TYPE csmobjnm
             VALUE 'Explicit Selection (E)',                "#EC NOTEXT
           tok_opmodemonivari TYPE csmtoken
             VALUE 'MonitoringVariant',                     "#EC NOTEXT
*             value 'SAPCCMS_Opmode_MoniVariant',
           tok_opmodedesc TYPE csmtoken
             VALUE 'Description',                           "#EC NOTEXT
*             value 'SAPCCMS_Opmode_Description',
*---------------------------------------------------------------*
* CSM R/3 Agent
*---------------------------------------------------------------*
           cls_r3agent TYPE csmclass "50
             VALUE 'BCAgent',                               "#EC NOTEXT
*             value 'SAPCCMS_Obj_R3Agent',
           cls_sapstartsrv type csmclass
             value 'SAPSTARTSRV',
           tok_longsid type csmtoken
            value 'LongSID',                                "#EC NOTEXT SAPSTARTSRV
           tok_localhost TYPE csmtoken
            value 'LocalHost',                              "#EC NOTEXT SAPSTARTSRV
           tok_instancenumber TYPE csmtoken
            value 'InstanceNumber',                         "#EC NOTEXT SAPSTARTSRV
           tok_instancetype TYPE csmtoken
            value 'InstanceType',                           "#EC NOTEXT SAPSTARTSRV
           tok_appservername TYPE csmtoken
            value 'ApplicationServerName',                  "#EC NOTEXT SAPSTARTSRV
           tok_porttypedsr TYPE csmtoken
            value 'PortTypeDSR',                            "#EC NOTEXT SAPSTARTSRV
           tok_segmentname TYPE csmtoken
             VALUE 'SegmentName',                           "#EC NOTEXT
*             value 'SAPCCMS_R3Agent_SegmentName',
           tok_segmenttype TYPE csmtoken
             VALUE 'SegmentType',                           "#EC NOTEXT
*             value 'SAPCCMS_R3Agent_SegmentType',
           tok_agenttype TYPE csmtoken
             VALUE 'AgentType',                             "#EC NOTEXT
*             value 'SAPCCMS_R3Agent_Type',
           tok_agentversion TYPE csmtoken
             VALUE 'AgentVersion',                          "#EC NOTEXT
*             value 'SAPCCMS_R3Agent_Version',
           tok_agentdesc TYPE csmtoken
             VALUE 'AgentDescription',                      "#EC NOTEXT
*             value 'SAPCCMS_R3Agent_Description',
           tok_agentdsractive    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsActive',
           tok_agentdsrversion    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsVersion',
           tok_agentdsrdest    TYPE csmtoken
              VALUE 'DSRDestination',
           tok_agentdest    TYPE csmtoken
              VALUE 'AgentDestination',
           tok_agentlogicalport    TYPE csmtoken
              VALUE 'LogicalPort',
           csm_n3stat_prefix TYPE csmobjnm
              VALUE 'N3STAT',  "Prefix for JD agent destinations for DSR
*---------------------------------------------------------------*
* SLD Properties of SAP_BCAgent. Names are unfortunately not
* identical to SCR names
*---------------------------------------------------------------*
           agent_caption TYPE csmtoken
             VALUE 'Caption', "#EC NOTEXT
           agent_description TYPE csmtoken
             VALUE 'Description', "#EC NOTEXT
           agent_installdate TYPE csmtoken
             VALUE 'InstallDate', "#EC NOTEXT
           agent_status TYPE csmtoken
             VALUE 'Status', "#EC NOTEXT
           agent_name TYPE csmtoken
             VALUE 'Name', "#EC NOTEXT
           agent_nameformat TYPE csmtoken
             VALUE 'NameFormat', "#EC NOTEXT
           agent_primaryownercontact TYPE csmtoken
             VALUE 'PrimaryOwnerContact', "#EC NOTEXT
           agent_primaryownername TYPE csmtoken
             VALUE 'PrimaryOwnerName', "#EC NOTEXT
           agent_type TYPE csmtoken
             VALUE 'Type', "#EC NOTEXT
           agent_version TYPE csmtoken
             VALUE 'Version', "#EC NOTEXT
           agent_segmentname TYPE csmtoken
             VALUE 'SegmentName', "#EC NOTEXT
           agent_segmenttype TYPE csmtoken
             VALUE 'SegmentType', "#EC NOTEXT
           agent_roles TYPE csmtoken
             VALUE 'Roles', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM External Component (superclass for ITS, other components
* external to R/3 system
*---------------------------------------------------------------*
* Component type passed in by external component determines the
* class, which is new if need be but always inherits from this one.
* These attribute names are expected.
           cls_xcomponent TYPE csmclass "50
             VALUE 'ExternalComponent',                     "#EC NOTEXT
*             value 'SAPCCMS_Obj_ITS',
           tok_xcompname TYPE csmtoken
             VALUE 'Name',                                  "#EC NOTEXT
           tok_xcompclass TYPE csmtoken
             VALUE 'CreationClassName',                     "#EC NOTEXT
           tok_xctracepath TYPE csmtoken
             VALUE 'TracePath',                             "#EC NOTEXT
           tok_xctracestdfn TYPE csmtoken
             VALUE 'TraceFilePattern',
           tok_xctracefns TYPE csmtoken
             VALUE 'TraceFileName',
           tok_xcversion TYPE csmtoken
             VALUE 'ComponentVersion',                      "#EC NOTEXT
           tok_xcdsractive    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsActive',
           tok_xcdsrversion    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsVersion',
*---------------------------------------------------------------*
* CSM ITS Internet Transaction Server
*---------------------------------------------------------------*
           cls_its TYPE csmclass "50
             VALUE 'ITS',                                   "#EC NOTEXT
*             value 'SAPCCMS_Obj_ITS',
           tok_itshostname TYPE csmtoken
             VALUE 'ITSHostName',                           "#EC NOTEXT
           tok_itsname TYPE csmtoken
             VALUE 'Name',                                  "#EC NOTEXT
           tok_hostccname TYPE csmtoken
             VALUE 'ITSHostCreationClassName',              "#EC NOTEXT
*           tok_sidname type csmtoken     "50
*             value 'Associated_SID', "#EC NOTEXT
*           tok_itsindex type csmtoken     "50
*             value 'IndexNr', "#EC NOTEXT
           tok_itsport TYPE csmtoken
             VALUE 'ITSPort',                               "#EC NOTEXT
           tok_itsadminurl TYPE csmtoken
             VALUE 'ITSAdminURL',                           "#EC NOTEXT
           tok_itsversion TYPE csmtoken
             VALUE 'ITSVersion',                            "#EC NOTEXT
           tok_itslogpath TYPE csmtoken
             VALUE 'ITSLogPath',                            "#EC NOTEXT
           tok_itstracepath TYPE csmtoken
             VALUE 'TracePath',                             "#EC NOTEXT
           tok_itstracestdfn TYPE csmtoken
             VALUE 'TraceFilePattern',
           tok_itstracefns TYPE csmtoken
             VALUE 'TraceFileName',
           tok_itsexepath TYPE csmtoken
             VALUE 'ITSExePath',                            "#EC NOTEXT
           tok_itsdsractive    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsActive',
           tok_itsdsrversion    TYPE csmtoken
              VALUE 'DistributedStatisticalRecordsVersion',
*             value 'SAPCCMS_ITS_ITSAdminURL',
*---------------------------------------------------------------*
* CSM ITS Internet Transaction Server AdminTool
*---------------------------------------------------------------*
           cls_itsadmin TYPE csmclass "50
             VALUE 'ITSAdminTool',                          "#EC NOTEXT
           tok_itsadmininstance TYPE csmtoken     "50
             VALUE 'Instance',                              "#EC NOTEXT
*             value 'SAPCCMS_Obj_ITSAdminTool',

*---------------------------------------------------------------*
* CSM Monitoring Architecture Classes
*---------------------------------------------------------------*
*---------------------------------------------------------------*
* CSM Monitoring Architecture (Container for system implementation)
* CIM LogicalElement
*---------------------------------------------------------------*
           cls_monarch TYPE csmclass
             VALUE 'MonitoringArchitecture',                "#EC NOTEXT
           tok_monversion TYPE csmtoken
             VALUE 'Version',                               "#EC NOTEXT
           tok_monavail TYPE csmtoken
             VALUE 'AvailabilityMonitoringPolicy',
*---------------------------------------------------------------*
* CSM MTEClassSettings (Collection of settings for an MTE class)
* CIM Collection
*---------------------------------------------------------------*
           cls_mte_cl_sets TYPE csmclass
             VALUE 'MTEClassSettings',                      "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MTEClassSetting (A setting for an MTE class)
* CIM Setting
*---------------------------------------------------------------*
           cls_mte_cl_set TYPE csmclass
             VALUE 'MTEClassSetting',                       "#EC NOTEXT
*---------------------------------------------------------------*
* CSM AttGroupSetting (A setting for an Attribute Group)
* CIM Setting
*---------------------------------------------------------------*
           cls_att_set TYPE csmclass
             VALUE 'AttributeGroupSetting',                 "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MonitoringVariants (Collection of variants)
* CIM Collection
*---------------------------------------------------------------*
           cls_mon_vars TYPE csmclass
             VALUE 'MonitoringVariants',                    "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MonitoringVariant (A setting for an Attribute Group)
* CIM Configuration
*---------------------------------------------------------------*
           cls_mon_var TYPE csmclass
             VALUE 'MonitoringVariant',                     "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MethodSettings (Collection of settings for a method)
* CIM Collection
*---------------------------------------------------------------*
           cls_meth_sets TYPE csmclass
             VALUE 'MethodSettings',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MethodSetting (A setting for an MTE class)
* CIM Setting
*---------------------------------------------------------------*
           cls_meth_set TYPE csmclass
             VALUE 'MethodSetting',                         "#EC NOTEXT
*---------------------------------------------------------------*
* CSM MTEClass (An MTE class)
* CIM LogicalElement
*---------------------------------------------------------------*
           cls_mte_cls TYPE csmclass
             VALUE 'MTEClass',                              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM AttributeGroup (An attribute group)
* CIM LogicalElement
*---------------------------------------------------------------*
           cls_att_grp TYPE csmclass
             VALUE 'AttributeGroup',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Method (A method)
* CIM LogicalElement
*---------------------------------------------------------------*
           cls_method TYPE csmclass
             VALUE 'Method',                                "#EC NOTEXT


*---------------------------------------------------------------*
* CSM SAP Product
*---------------------------------------------------------------*
           cls_product TYPE csmclass "50
             VALUE 'Product',                               "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS Product Version
*---------------------------------------------------------------*
           cls_ppmsproduct TYPE csmclass "50
             VALUE 'Product',                               "#EC NOTEXT
           tok_ppmsname TYPE csmtoken
             VALUE 'Name',                                  "#EC NOTEXT
           tok_ppmsversion TYPE csmtoken
             VALUE 'Version',                               "#EC NOTEXT
           tok_ppmsidnr TYPE csmtoken
             VALUE 'IdentifyingNumber',                     "#EC NOTEXT
           tok_ppmsvendor TYPE csmtoken
             VALUE 'Vendor',                                "#EC NOTEXT
           tok_ppmstype TYPE csmtoken
             VALUE 'Type',                                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS Component Version
*---------------------------------------------------------------*
           cls_ppmscomponent TYPE csmclass "50
             VALUE 'Component',                             "#EC NOTEXT
           tok_componentname TYPE csmtoken
             VALUE 'Name',                                  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS Component Installability
*---------------------------------------------------------------*
           cls_ppmscomponentinstall TYPE csmclass "50
             VALUE 'ComponentInstallability',               "#EC NOTEXT
           tok_inststid TYPE csmtoken
             VALUE 'ID',                                    "#EC NOTEXT
           tok_inststinstid TYPE csmtoken
             VALUE 'InstallableID',                         "#EC NOTEXT
           tok_inststvis TYPE csmtoken
             VALUE 'Visibility',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS InstallabilityStatement
*---------------------------------------------------------------*
           cls_ppmsinstallstmt TYPE csmclass "50
             VALUE 'InstallabilityStatement',               "#EC NOTEXT
           tok_is_id TYPE csmtoken
             VALUE 'ID',                                    "#EC NOTEXT
           tok_is_vis TYPE csmtoken
             VALUE 'Visibility',                            "#EC NOTEXT
*           tok_compinststring type csmtoken
*             value 'Option',
*           tok_compinsttype type csmtoken
*             value 'Type',
*---------------------------------------------------------------*
* CSM PPMS InstallableInDatabase
*---------------------------------------------------------------*
           cls_ppmsinstindb TYPE csmclass "50
             VALUE 'InstallableInDatabase',                 "#EC NOTEXT
           tok_instdbshared TYPE csmtoken
             VALUE 'SharedDB',                              "#EC NOTEXT
*           tok_ppmscompversion type csmtoken
*             value 'ComponentVersion',
*---------------------------------------------------------------*
* CSM PPMS InstallableOnHardware
*---------------------------------------------------------------*
           cls_ppmsinstonhw TYPE csmclass "50
             VALUE 'InstallableOnHardware',                 "#EC NOTEXT
           tok_insthwshared TYPE csmtoken
             VALUE 'SharedHW',                              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS Product Installability
*---------------------------------------------------------------*
           cls_ppmspi TYPE csmclass "50
             VALUE 'ProductInstallabilityMember',           "#EC NOTEXT
           tok_ppms_pi_compatible TYPE csmtoken
             VALUE 'Compatible',                            "#EC NOTEXT
           tok_ppms_pi_id TYPE csmtoken
             VALUE 'ID',                                    "#EC NOTEXT
           tok_ppms_pi_visibility TYPE csmtoken
             VALUE 'Visibility',                            "#EC NOTEXT
           val_ppms_pi_visexternal TYPE csmobjnm
             VALUE 'External',                              "#EC NOTEXT
           val_ppms_pi_visinternal TYPE csmobjnm
             VALUE 'Internal',                              "#EC NOTEXT
           val_ppms_pi_vispartner TYPE csmobjnm
             VALUE 'Partner',                               "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS Patch
*---------------------------------------------------------------*
           cls_ppmspatch TYPE csmclass "50
             VALUE 'SupportPackage',                        "#EC NOTEXT
           tok_ppmspatchrelease TYPE csmtoken
             VALUE 'Status',                                "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS MainInstance
*---------------------------------------------------------------*
           cls_ppmsmaininstance TYPE csmclass "50
             VALUE 'MainInstance',                          "#EC NOTEXT
*           tok_mi type csmtoken
*             value 'SharedDB',
*---------------------------------------------------------------*
* CSM PPMS Constants
*---------------------------------------------------------------*
           ppms_deployable TYPE csmtoken "State of soll components
             VALUE 'Deployable',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM PPMS plug-in
*---------------------------------------------------------------*
           cls_ppmsplugin TYPE csmclass "50
             VALUE 'PlugIn',                                "#EC NOTEXT
* Example: Plug in in SAP BW 2.0A for SAP APO 1.1
           tok_inproduct TYPE csmtoken
             VALUE 'PlugInOfProduct',                       "#EC NOTEXT
           tok_forproduct TYPE csmtoken
             VALUE 'PlugInWithProduct',                     "#EC NOTEXT
           tok_pluginname TYPE csmtoken "Not sure will be needed
             VALUE 'PlugInName',                            "#EC NOTEXT
           tok_ppmspluginversion TYPE csmtoken
             VALUE 'PlugInVersion',                         "#EC NOTEXT
*---------------------------------------------------------------*
* PPMS Association classes  50
*---------------------------------------------------------------*
*---------------------------------------------------------------*
* PPMS Association classes  Stellvertreter for standard CIM weak
* association
*---------------------------------------------------------------*
            asc_ppms_ppc TYPE csmclass
              VALUE 'PrincipalProductComponent',            "#EC NOTEXT
             tok_ppms_ppc TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_cpp TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A
*---------------------------------------------------------------*
* PPMS Association classes  Product to Component (directed)
*---------------------------------------------------------------*
            asc_ppms_pc TYPE csmclass
              VALUE 'ProductComponent',                     "#EC NOTEXT
             tok_ppms_pc TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_cp TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A
*---------------------------------------------------------------*
* PPMS Association classes  System to Component (directed)
*---------------------------------------------------------------*
            asc_ppms_syscomp TYPE csmclass
              VALUE 'SWSystemComponent',                    "#EC NOTEXT
             tok_ppms_syscomp TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_compsys TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A
*---------------------------------------------------------------*
* PPMS Association classes  Component to Support Package (directed)
*---------------------------------------------------------------*
            asc_ppms_comppatch TYPE csmclass
              VALUE 'ComponentSupportPackage',              "#EC NOTEXT
            tok_ppms_comppatch TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_patchcomp TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ProductsInstallability (directed)
*---------------------------------------------------------------*
            asc_ppms_productsinstall TYPE csmclass
              VALUE 'ProductsInstallability',               "#EC NOTEXT
            tok_ppms_pistart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_piend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  InstallabilityStatements (weak)
*---------------------------------------------------------------*
            asc_ppms_inststmt TYPE csmclass
              VALUE 'ProductInstallabilityStatement',       "#EC NOTEXT
            tok_ppms_isstart TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_isend TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ProductMaininstance
*---------------------------------------------------------------*
            asc_ppms_productmaininstances TYPE csmclass
              VALUE 'ProductMaininstance',                  "#EC NOTEXT
            tok_ppms_pmistart TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_pmiend TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  MaininstanceComponent
*---------------------------------------------------------------*
            asc_ppms_maininstancecomp TYPE csmclass
              VALUE 'MainInstanceComponent',                "#EC NOTEXT
            tok_ppms_micstart TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_ppms_micend TYPE csmtoken
               VALUE 'PartComponent',                 "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  MaininstanceInstallabilityInDB
*---------------------------------------------------------------*
            asc_ppms_maininstanceinstindb TYPE csmclass
              VALUE 'MainInstanceInstallabilityInDB',       "#EC NOTEXT
            tok_ppms_miidbstart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_miidbend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  MaininstanceInstallabilityonHW
*---------------------------------------------------------------*
            asc_ppms_maininstanceinstonhw TYPE csmclass
              VALUE 'MainInstanceInstallabilityOnHW',       "#EC NOTEXT
            tok_ppms_miihwstart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_miihwend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ComponentInstallabilityMaininstance
*---------------------------------------------------------------*
            asc_ppms_cimi TYPE csmclass
              VALUE 'ComponentInstallabilityMainInstance',  "#EC NOTEXT
            tok_ppms_cimistart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_cimiend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ComponentInstallabilityComponent
*---------------------------------------------------------------*
            asc_ppms_cico TYPE csmclass
              VALUE 'ComponentInstallabilityComponent',     "#EC NOTEXT
            tok_ppms_cicostart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_cicoend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ComponentInstallabilityToSP
*---------------------------------------------------------------*
            asc_ppms_citosp TYPE csmclass
              VALUE 'ComponentInstallabilityToSP',          "#EC NOTEXT
            tok_ppms_citospstart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_citospend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ComponentInstallabilityFromSP
*---------------------------------------------------------------*
            asc_ppms_cifromsp TYPE csmclass
              VALUE 'ComponentInstallabilityFromSP',        "#EC NOTEXT
            tok_ppms_cifromspstart TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_ppms_cifromspend TYPE csmtoken
               VALUE 'Member',                        "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ProductInstallation
*---------------------------------------------------------------*
            asc_ppms_prodinst TYPE csmclass
              VALUE 'ProductInstallation',                  "#EC NOTEXT
            tok_ppms_prodinststart TYPE csmtoken
               VALUE 'Antecedent',                     "#EC NOTEXT "50A
            tok_ppms_prodinstend TYPE csmtoken
               VALUE 'Depedent',                      "#EC NOTEXT  "50A

*---------------------------------------------------------------*
* PPMS Association classes  ComponentInstallation
*---------------------------------------------------------------*
            asc_ppms_compinst TYPE csmclass
              VALUE 'ComponentInstallation',                "#EC NOTEXT
            tok_ppms_compinststart TYPE csmtoken
               VALUE 'Antecedent',                     "#EC NOTEXT "50A
            tok_ppms_compinstend TYPE csmtoken
               VALUE 'Depedent',                      "#EC NOTEXT  "50A

**---------------------------------------------------------------*
** PPMS Association classes  Component to Plug in (directed)
**---------------------------------------------------------------*
*            asc_ppms_pplu type csmclass
*              value 'PPMS_Product_PlugIn',
*            tok_ppms_pplu type csmtoken
*              value 'GroupComponent',
*            tok_ppms_plup type csmtoken
*              value 'PartComponent',
*---------------------------------------------------------------*
* CCMS Association classes
*---------------------------------------------------------------*

* Naming changes have taken place at 5.0A.
*---------------------------------------------------------------*
* CSM Association CCMS Management Domain_V2 to System
* System is weak with respect to Domain_V2
*---------------------------------------------------------------*
            asc_domsys TYPE csmclass
*              value 'SAPCCMS_Assoc_Domain_BCSystem', "50
              VALUE 'NamespaceBCSystem',                    "#EC NOTEXT
             tok_domsys TYPE csmtoken
**              value 'SAPCCMS_DomSys_ManagingDomain',
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_sysdom TYPE csmtoken
**              value 'SAPCCMS_DomSys_ManagedSystem',
               VALUE 'Member',                        "#EC NOTEXT  "50A
*---------------------------------------------------------------*
* CSM Association CCMS Management Domain to Host
* Host is weak with respect to Domain_V2
*---------------------------------------------------------------*
            asc_domhost TYPE csmclass
*              value 'SAPCCMS_Assoc_Domain_Host',
              VALUE 'NamespaceHost',                        "#EC NOTEXT
            tok_domhost TYPE csmtoken
*              value 'SAPCCMS_DomHost_ManagingDomain',
               VALUE 'Collection',                          "#EC NOTEXT
            tok_hostdom TYPE csmtoken
*              value 'SAPCCMS_DomHost_ManagedHost',
               VALUE 'Member',                              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association CCMS Management Domain_V2 to ITS
* ITS is weak with respect to Domain_V2
*---------------------------------------------------------------*
            asc_domits TYPE csmclass
*              value 'SAPCCMS_Assoc_Domain_ITS',
              VALUE 'NamespaceITS',                         "#EC NOTEXT
            tok_domits TYPE csmtoken
*              value 'SAPCCMS_DomITS_ManagingDomain',
               VALUE 'Collection',                     "#EC NOTEXT "50A
            tok_itsdom TYPE csmtoken
*              value 'SAPCCMS_DomITS_ManagedITS',
               VALUE 'Member',                        "#EC NOTEXT  "50A
*---------------------------------------------------------------*
* CSM Association CCMS Management Domain_V2 to ITS Admin
* ITSAdmin is weak with respect to Domain_V2
*---------------------------------------------------------------*
            asc_domitsadmin TYPE csmclass
*              value 'SAPCCMS_Assoc_Domain_ITSAdmin',
              VALUE 'NamespaceITSAdmin',                    "#EC NOTEXT
            tok_domitsadmin TYPE csmtoken
               VALUE 'Collection',                     "#EC NOTEXT "50A
*              value 'SAPCCMS_DomITSAdmin_ManagingDomain',
            tok_itsadmindom TYPE csmtoken
               VALUE 'Member',                         "#EC NOTEXT "50A
*              value 'SAPCCMS_DomITSAdmin_ManagedITSAdmin',
*---------------------------------------------------------------*
* CSM Association Reference Port Dependency
* Directed association
*---------------------------------------------------------------*
            asc_refport TYPE csmclass
              VALUE 'ReferencePortDependency',              "#EC NOTEXT
            tok_refport TYPE csmtoken
               VALUE 'Antecedent',                     "#EC NOTEXT "50A
            tok_portref TYPE csmtoken
               VALUE 'Dependent',                      "#EC NOTEXT "50A
*---------------------------------------------------------------*
* CSM Association CCMS System to Instance of Monitoring Architecture
* Monitoring Architecture is weak with respect to System
*---------------------------------------------------------------*
            asc_sysmonarch TYPE csmclass
*              value 'SAPCCMS_Assoc_System_Component', "50
              VALUE 'BCSystemMonArch',                      "#EC NOTEXT
            tok_sysmonarch TYPE csmtoken
*              value 'SAPCCMS_SysComp_SystemHasComponent',
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_monarchsys TYPE csmtoken
*              value 'SAPCCMS_SysComp_ComponentInSystem',
               VALUE 'PartComponent',                  "#EC NOTEXT "50A
*---------------------------------------------------------------*
* CSM Association CCMS System to Component
* Component is weak with respect to System
*---------------------------------------------------------------*
            asc_syscomp TYPE csmclass
*              value 'SAPCCMS_Assoc_System_Component', "50
              VALUE 'BCSystemComponent',                    "#EC NOTEXT
            tok_syscomp TYPE csmtoken
*              value 'SAPCCMS_SysComp_SystemHasComponent',
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
            tok_compsys TYPE csmtoken
*              value 'SAPCCMS_SysComp_ComponentInSystem',
               VALUE 'PartComponent',                  "#EC NOTEXT "50A
*---------------------------------------------------------------*
* CSM Association CCMS System to Support Package
* Support Package is weak with respect to System
*---------------------------------------------------------------*
            asc_syspack TYPE csmclass
*              CCMS_System_SupPack
*              value 'SAPCCMS_Assoc_System_SupportPack', "50
              VALUE 'ComponentSupportPackage',              "#EC NOTEXT
            tok_syspack TYPE csmtoken
               VALUE 'GroupComponent',                 "#EC NOTEXT "50A
*              value 'SAPCCMS_SysPack_SystemHasSupportPack',
            tok_packsys TYPE csmtoken
*              value 'SAPCCMS_SysPack_SupportPackInSys',
               VALUE 'PartComponent',                  "#EC NOTEXT "50A
*---------------------------------------------------------------*
* CSM Association System to Database
* DB is weak with respect to system
*---------------------------------------------------------------*
            asc_sysdb TYPE csmclass
*              value 'SAPCCMS_Assoc_System_DB', "50
              VALUE 'BCSystemSystemDB',                     "#EC NOTEXT
            tok_sysdb TYPE csmtoken
*              value 'SAPCCMS_SysDB_SystemHasDB',
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_dbsys TYPE csmtoken
*              value 'SAPCCMS_SysDB_DBOfSystem',
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to Used Database
* System has start of directed link to db
*---------------------------------------------------------------*
            asc_sysudb TYPE csmclass
*              value 'SAPCCMS_Assoc_System_DB', "50
              VALUE 'BCUsingDB',                            "#EC NOTEXT
            tok_sysudb TYPE csmtoken
*              value 'SAPCCMS_SysDB_SystemHasDB',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_udbsys TYPE csmtoken
*              value 'SAPCCMS_SysDB_DBOfSystem',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association DB Host to Database
* DB has the start of a directed association to host
*---------------------------------------------------------------*
            asc_dbhost TYPE csmclass
              VALUE 'DBHost',                           "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_DB_DBHost', "50
            tok_dbhost TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_DB_Runs_On_Host',
            tok_hostdb TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_Host_Supports_DB',
*---------------------------------------------------------------*
* CSM Association DB to Database Instance  4.6D
* DB has the start of a directed association to an instance
*---------------------------------------------------------------*
            asc_dbsrv TYPE csmclass
*              value 'SAPCCMS_Assoc_DB_DBInstance', "50
              VALUE 'DBSystemInstance',                 "#EC NOTEXT "50
            tok_dbsrv TYPE csmtoken
*              value 'SAPCCMS_DB_Has_Instance',
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_srvdb TYPE csmtoken
*              value 'SAPCCMS_Instance_Of_DB',
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association DB Instance to Host 4.6D
* DBinstance has the start of a directed association to host
*---------------------------------------------------------------*
            asc_dbinsthost TYPE csmclass
*              value 'SAPCCMS_Assoc_DBInst_Host', "50
              VALUE 'DBInstanceHost',                   "#EC NOTEXT "50
            tok_dbinsthost TYPE csmtoken
*              value 'SAPCCMS_DBInst_Runs_On_Host',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_hostdbinst TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_Host_Supports_DBInst',
*---------------------------------------------------------------*
* CSM Association Domain_V2 to System Group
* System group is weak with respect to Domain_V2
*---------------------------------------------------------------*
             asc_domgrp TYPE csmclass
*               value 'SAPCCMS_Assoc_Domain_SysGrp',
               VALUE 'NamespaceSystemGroup',                "#EC NOTEXT
             tok_domgrp TYPE csmtoken
*               value 'SAPCCMS_DomGrp_DomainHasGroup',
               VALUE 'Collection',                     "#EC NOTEXT "50A
             tok_grpdom TYPE csmtoken
*               value 'SAPCCMS_DomGrp_GroupInDomain',
               VALUE 'Member',                         "#EC NOTEXT "50A
*---------------------------------------------------------------*
** CSM Association System Group to System
** System group has start of directed link to system
**---------------------------------------------------------------*
*            asc_grpsys type csmclass
**              value 'SAPCCMS_Assoc_Group_System',
*              value 'BCSystemGroupSystem',
*            tok_grpsys type csmtoken
**              value 'SAPCCMS_GrpSys_OwningGroup',
*              value 'Collection',
*            tok_sysgrp type csmtoken
**              value 'SAPCCMS_GrpSys_GroupedSystem',
*               value 'Member',
*---------------------------------------------------------------*
* CSM Association System Group to Component
* System group has start of directed link to system
*---------------------------------------------------------------*
            asc_grpcomp TYPE csmclass
*              value 'SAPCCMS_Assoc_Group_System',
              VALUE 'BCSystemGroupComponent',               "#EC NOTEXT
            tok_grpcomp TYPE csmtoken
*              value 'SAPCCMS_GrpSys_OwningGroup',
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_compgrp TYPE csmtoken
*              value 'SAPCCMS_GrpSys_GroupedSystem',
               VALUE 'PartComponent',                       "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to AppServer
* AppServer is weak with respect system
*---------------------------------------------------------------*
            asc_systrex TYPE csmclass
              VALUE 'BCSystemTREXInstance',        "#EC NOTEXT "50
            asc_sysappsrv TYPE csmclass
              VALUE 'BCSystemApplicationServer',        "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_AppServer',
            tok_sysappsrv TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_SysAppSrv_SystemHasAppServer',
            tok_appsrvsys TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_SysAppSrv_AppSrvOfSystem',
*---------------------------------------------------------------*
* CSM Association AppServer to Host
* AppServer has start of link to host
*---------------------------------------------------------------*
            asc_trexhost TYPE csmclass
              VALUE 'TREXInstanceHost',          "#EC NOTEXT "50
            asc_appsrvhost TYPE csmclass
              VALUE 'BCApplicationServerHost',          "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_AppServer_Host',
            tok_appsrvhost TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_AppSrvHost_AppServerRunsOnHost',
            tok_hostappsrv TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_AppSrvHost_HostOfAppServer',
*---------------------------------------------------------------*
* CSM Association AppServer to Kernel
* AppServer has start of link to kernel
*---------------------------------------------------------------*
            asc_appsrvkernel TYPE csmclass
              VALUE 'BCApplicationServerKernel',        "#EC NOTEXT "50
            tok_appsrvkernel TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_kernelappsrv TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association Kernel to KernelComponent
* Kernel has start of link to kernel components
*---------------------------------------------------------------*
            asc_kernelkcomp TYPE csmclass
              VALUE 'BCKernelComponent',                "#EC NOTEXT "50
            tok_kernelkcomp TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
            tok_kcompkernel TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to Administrator
* System has start of link to administrator
*---------------------------------------------------------------*
            asc_sysadm TYPE csmclass
              VALUE 'BCSystemAdministrator',            "#EC NOTEXT "50
            tok_sysadm TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_admsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association DB to Administrator
* DB has start of link to administrator
*---------------------------------------------------------------*
            asc_dbadm TYPE csmclass
              VALUE 'DBAdministrator',                  "#EC NOTEXT "50
            tok_dbadm TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_admdb TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association OpMode to AppServer
* OpMode has start of link to AppServer
*---------------------------------------------------------------*
            asc_opmodeappsrv TYPE csmclass
              VALUE 'BCOperationModeApplicationServer', "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_OpMode_AppSrv',
            tok_opmodeappsrv TYPE csmtoken
              VALUE 'Configuration',                        "#EC NOTEXT
*              value 'SAPCCMS_OpModeAppSrv_OpmodeHasAppSrv',
            tok_appsrvopmode TYPE csmtoken
              VALUE 'Element',                              "#EC NOTEXT
*              value 'SAPCCMS_OpModeAppSrv_AppSrvOfOpMode',
*---------------------------------------------------------------*
* CSM Association AppServer to Instance
* Instance is weak with respect to AppServer
* NO LONGER USED AS OF 4.6D !!!
*---------------------------------------------------------------*
            asc_appsrvinst TYPE csmclass
              VALUE 'SAPCCMS_Assoc_AppServer_Instance',     "#EC NOTEXT
            tok_appsrvinst TYPE csmtoken
              VALUE 'SAPCCMS_AppSrvInst_AppSrvHasInst',     "#EC NOTEXT
            tok_instappsrv TYPE csmtoken
              VALUE 'SAPCCMS_AppSrvInsta_InstRunsOnAppSrv', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association AppServer to Application Service
* Service is weak with respect to Appserver
* New as of 5.0
*---------------------------------------------------------------*
            asc_appsrvservice TYPE csmclass
              VALUE 'HostedApplicationService',             "#EC NOTEXT
            tok_appsrvservice TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_serviceappsrv TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association AppServer to Service Port
* Port is weak with respect to ApplicationServer
* New as of 5.0
*---------------------------------------------------------------*
            asc_appsrvport TYPE csmclass
              VALUE 'HostedApplicationServicePort',         "#EC NOTEXT
            tok_appsrvport TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_portappsrv TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to HTTP Destination
* Port is weak with respect to ApplicationServer
* New as of 5.0
*---------------------------------------------------------------*
            asc_syshttp TYPE csmclass
              VALUE 'HostedHTTPDestination',                "#EC NOTEXT
            tok_syshttp TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_httpsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association AppServer to Service Reference
* Reference is weak with respect to ApplicationServer
* New as of 5.0
*---------------------------------------------------------------*
            asc_appsrvref TYPE csmclass
              VALUE 'HostedApplicationServiceReference',    "#EC NOTEXT
            tok_appsrvref TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_refappsrv TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association Agent to TCPIP Service Port
* Port is weak with respect to agent
* New as of 5.0
*---------------------------------------------------------------*
            asc_sapstartsrvport type csmclass
              value 'HostedSAPSTARTSRVLogicalPort',
            asc_agentport TYPE csmclass
              VALUE 'HostedBCAgentPort',                    "#EC NOTEXT
            tok_agentport TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_portagent TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to R/3 Printer
* Printer is weak with respect to system
*---------------------------------------------------------------*
            asc_sysprt TYPE csmclass
              VALUE 'HostedPrintSAP',                   "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_Printer',
            tok_sysprt TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysPrt_SystemOwnsPrinter',
            tok_prtsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysPrt_PrinterOfSystem',
*---------------------------------------------------------------*
* CSM Association System to RFC Destination
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_syslogicalport TYPE csmclass
              VALUE 'HostedLogicalPort',             "#EC NOTEXT "50
            asc_sysrfc TYPE csmclass
              VALUE 'HostedRFCDestination',             "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_Destination',
            tok_sysrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasRFCDest',
            tok_rfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_RFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to Logical RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_logrfcref TYPE csmclass
              VALUE 'LogicalRFCDestinationReference',   "#EC NOTEXT "50
            tok_logrfcref TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_reflogrfc TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to Logical RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_syslogrfc TYPE csmclass
              VALUE 'HostedLogicalRFCDestination',      "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_LogDestination',
            tok_syslogrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasLogRFCDest',
            tok_logrfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_LogRFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to X RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_sysxrfc TYPE csmclass
              VALUE 'HostedABAPDriverRFCDestination',   "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_XDestination',
            tok_sysxrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasXRFCDest',
            tok_xrfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_XRFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to M RFC Destination  4.6D
* Destination is weak with respect to system  (CMC)
*---------------------------------------------------------------*
            asc_sysmrfc TYPE csmclass
              VALUE 'HostedCMCRFCDestination',          "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_MDestination',
            tok_sysmrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasMRFCDest',
            tok_mrfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_MRFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to R3 RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_sysr3rfc TYPE csmclass
              VALUE 'HostedR3RFCDestination',           "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_R3Destination',
            tok_sysr3rfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasR3RFCDest',
            tok_r3rfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_R3RFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to R2 RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_sysr2rfc TYPE csmclass
              VALUE 'HostedR2RFCDestination',           "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_R2Destination',
            tok_sysr2rfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasR2RFCDest',
            tok_r2rfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_R2RFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to Internal RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_sysintrfc TYPE csmclass
              VALUE 'HostedInternalRFCDestination',     "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_IntDestination',
            tok_sysintrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasIntRFCDest',
            tok_intrfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_IntRFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to TCP/IP RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_systcprfc TYPE csmclass
              VALUE 'HostedTCPIPRFCDestination',        "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_TCPDestination',
            tok_systcprfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasTCPRFCDest',
            tok_tcprfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_TCPRFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association System to SNA RFC Destination  4.6D
* Destination is weak with respect to system
*---------------------------------------------------------------*
            asc_syssrfc TYPE csmclass
              VALUE 'HostedSNARFCDestination',          "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_SNADestination',
            tok_syssrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SysHasSNARFCDest',
            tok_srfcsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_SysDest_SNARFCDestOfSystem',
*---------------------------------------------------------------*
* CSM Association RFC Destination to destination system
* RFC Destination has start of link to system
*---------------------------------------------------------------*
            asc_rfcdestsys TYPE csmclass
              VALUE 'RFCDestinationTargetSystem',       "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_RFCDest_DestinationSystem',
            tok_rfcdestsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_RFCSys_DestinationToSystem',
            tok_sysrfcdest TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_RFCSys_DestinationSystem_of_RFC',
**---------------------------------------------------------------*
** CSM Association CSM RFC Destination to central system
** Destination has start of link to System - Destination is
** one created in the local system for csm purposes.
**---------------------------------------------------------------*
*            asc_censysdestsys type csmclass
*              value 'SCRDestinationToCentralSystem', "50
*            tok_censysdestsys type csmtoken
*              value 'Antecedent',
*            tok_syscensysdest type csmtoken
*              value 'Dependent',
**---------------------------------------------------------------*
** CSM Association CSM RFC Destination in central system
** System has start of link to RFC Destination - Destination is
** one created in the local system for csm purposes.
**---------------------------------------------------------------*
*            asc_syssubsysdest type csmclass
*              value 'SCRDestinationToCentralSystem', "50
*            tok_rfcdestsys type csmtoken
*              value 'Antecedent',
*            tok_sysrfcdest type csmtoken
*              value 'Dependent',
**---------------------------------------------------------------*
** CSM Association R/3 RFC Destination to destination system
** RFC Destination has start of link to system    4.6D
**---------------------------------------------------------------*
*            asc_R3rfcdestsys type csmclass
*              value 'CCMS_R3RFCDest_DestSystem', "50
**              value 'SAPCCMS_Assoc_R3RFCDest_DestSystem',
*            tok_R3rfcdestsys type csmtoken
*              value 'Dependent',
**              value 'SAPCCMS_R3RFCSys_DestToSystem',
*            tok_sysR3rfcdest type csmtoken
*              value 'Antecedent',
**              value 'SAPCCMS_R3RFCSys_DestSystem_of_RFC',
*---------------------------------------------------------------*
* CSM Association System to Message Server
* Message server is weak with respect to system
*---------------------------------------------------------------*
            asc_sysmsgsrv TYPE csmclass
              VALUE 'BCSystemMessageServer',            "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_MsgSrv',
            tok_sysmsgsrv TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_SysMsgSrv_SystemHasMsgSrv',
            tok_msgsrvsys TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_SysMsgSrv_MsgSrvOfSystem',
*---------------------------------------------------------------*
* CSM Association Message Server to TCPIP Service Port
* Port is weak with respect to Message server
*---------------------------------------------------------------*
            asc_msgsrvport TYPE csmclass
              VALUE 'HostedBCMessageServerPort',        "#EC NOTEXT "50
            tok_msgsrvport TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_portmsgsrv TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to Message Server Service
* Message server service is weak with respect to system
* NO LONGER USED AS OF 4.6D !!!
*---------------------------------------------------------------*
            asc_sysmsserv TYPE csmclass
              VALUE 'SAPCCMS_Assoc_System_Service',         "#EC NOTEXT
            tok_sysmsserv TYPE csmtoken
              VALUE 'SAPCCMS_SysService_SystemHasService',  "#EC NOTEXT
            tok_msservsys TYPE csmtoken
              VALUE 'SAPCCMS_SysService_ServiceOfSystem',   "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association Message Server to Message Server Service
* Message server has start of directed link to message server
* service
* NO LONGER USED AS OF 4.6D !!!
*---------------------------------------------------------------*
           asc_msgsrv2service TYPE csmclass
              VALUE 'SAPCCMS_Assoc_MsgSrv_Service',         "#EC NOTEXT
            tok_msgsrv2service TYPE csmtoken
              VALUE 'SAPCCMS_MsgSrv_Antecedent_to_Service', "#EC NOTEXT
            tok_service2msgsrv TYPE csmtoken
              VALUE 'SAPCCMS_Service_Dependent_on_MsgSrv',  "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association Message Server to Host
* message server has start of directed link to host
* Not sure if this association will be retained.
*---------------------------------------------------------------*

            asc_hostmsgsrv TYPE csmclass
              VALUE 'BCMessageServerHost',              "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_Host_MsgSrv',
            tok_msgsrvhost TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_HostMsgSrv_HostOfMsgSrv',
            tok_hostmsgsrv TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_HostMsgSrv_MsgSrvOnHost',

* No longer used in 6.10 model
**---------------------------------------------------------------*
** CSM Association System to Message Server Host
** System has start of directed link to host 50 Reinhold Kautzleben
**---------------------------------------------------------------*
*
*            asc_sysmshost type csmclass
*              value 'SystemMessageServerHost', "50
**              value 'SAPCCMS_Assoc_Host_MsgSrv',
*            tok_sysmshost type csmtoken
*              value 'GroupComponent',
**              value 'SAPCCMS_HostMsgSrv_HostOfMsgSrv',
*            tok_mshostsys type csmtoken
*              value 'PartComponent',
**              value 'SAPCCMS_HostMsgSrv_MsgSrvOnHost',

* No longer used in 6.10 model
**---------------------------------------------------------------*
** CSM Association System to Host
** System has start of directed link to host
**---------------------------------------------------------------*
*            asc_systemhost type csmclass
*              value 'SystemHosts', "50
**              value 'SAPCCMS_Assoc_System_to_Host',
*            tok_systemhost type csmtoken
*              value 'Antecedent',
**              value 'SAPCCMS_System_Running_On_Host',
*            tok_hostsystem type csmtoken
*              value 'Dependent',
**              value 'SAPCCMS_Host_Supporting_System',
*---------------------------------------------------------------*
* CSM Association System Client
* Client is weak with respect to system
*---------------------------------------------------------------*
            asc_syscli TYPE csmclass
              VALUE 'BCSystemClient',                   "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_Client',
            tok_syscli TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_SysCli_SystemHasClient',
            tok_clisys TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_SysCli_ClientInSystem',
*---------------------------------------------------------------*
* CSM Association System Operation Mode
* Op Mode is weak with respect to system
*---------------------------------------------------------------*
            asc_sysopmode TYPE csmclass
              VALUE 'BCSystemOperationMode',            "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_System_OpMode',
            tok_sysopmode TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_SysOpm_SystemHasOpMode',
            tok_opmodesys TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_SysOpm_OpModeInSystem',
*---------------------------------------------------------------*
* CSM Association OpMode to Instance
* OpMode has start of directed link to Instance
* NO LONGER USED AS OF 4.6D !!!
*---------------------------------------------------------------*
            asc_opmodeinst TYPE csmclass
              VALUE 'SAPCCMS_Assoc_OpMode_Instance',        "#EC NOTEXT
            tok_opmodeinst TYPE csmtoken
              VALUE 'SAPCCMS_OpmInst_OpModeHasInstance',    "#EC NOTEXT
            tok_instopmode TYPE csmtoken
              VALUE 'SAPCCMS_OpmInst_InstanceInOpMode',     "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Association System to System Repository Landscape proxy
* System has start of directed link to Repository
*---------------------------------------------------------------*
            asc_sysscrrole TYPE csmclass
              VALUE 'BCSystemSystemRepository',         "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_MgingSys_MontdSys',
            tok_sysscrrole TYPE csmtoken
              VALUE 'SystemElement',                        "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_CentralOfSystem',
            tok_scrrolesys TYPE csmtoken
              VALUE 'SameElement',                          "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_SystemAtCentral',
*---------------------------------------------------------------*
* CSM Association Central System Repos. to SubordSystemRepos System
* System has start of directed link to Monitored System
*---------------------------------------------------------------*
            asc_mgingsysmonsys TYPE csmclass
              VALUE 'BCSystemCSMSystem',                "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_MgingSys_MontdSys',
            tok_mgingsysmonsys TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_CentralOfSystem',
            tok_monsysmgingsys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_SystemAtCentral',
*---------------------------------------------------------------*
* CSM Association Central System to Known System
* System has start of directed link to Known System
* Implies: functioning RFC link, candidate for managed system
*---------------------------------------------------------------*
            asc_sysknownsys TYPE csmclass
              VALUE 'BCSystemKnownSystem',              "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_MgingSys_MontdSys',
            tok_sysknownsys TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_CentralOfSystem',
            tok_knownsyssys TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_SystemAtCentral',
*---------------------------------------------------------------*
* CSM Association Central System Monitoring. to SubordSystem Monitoring
* System has start of directed link to Monitored System
*---------------------------------------------------------------*
            asc_cenmon TYPE csmclass
              VALUE 'BCSystemMonitoredSystem',          "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_MgingSys_MontdSys',
            tok_cenmon TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_CentralOfSystem',
            tok_moncen TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_MgrMon_SystemAtCentral',
*---------------------------------------------------------------*
* CSM System to Agent Registered with System
* Agent is weak with respect to System
*---------------------------------------------------------------*
            asc_syssapstartsrv type csmclass
              value 'BCSystemSAPSTARTSRV',
            asc_sysagent TYPE csmclass
              VALUE 'BCSystemAgent',                    "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_MgingSys_RegAgent',
            tok_sysagent TYPE csmtoken
              VALUE 'GroupComponent',                       "#EC NOTEXT
*              value 'SAPCCMS_SysAgent_SystemHasAgent',
            tok_agentsys TYPE csmtoken
              VALUE 'PartComponent',                        "#EC NOTEXT
*              value 'SAPCCMS_SysAgent_AgentAtSystem',
*---------------------------------------------------------------*
* CSM Agent to Monitored System
* Agent has start of directed link to Monitored System
*---------------------------------------------------------------*
            asc_agentmonsys TYPE csmclass
              VALUE 'AgentMonitoredSystem',             "#EC NOTEXT "50
*              value 'SAPCCMS_Assoc_Agent_MontdSys',
            sld_asc_agentmonsys type csmclass
              value 'BCAgentMonitoredSystem',
            tok_agentmonsys TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_AgentSys_AgentMonitorsSys',
            tok_monsysagent TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_AgentSys_SysMonitoredByAgent',
*---------------------------------------------------------------*
* CSM Agent runs on Host
* Agent has start of directed link to Host
*---------------------------------------------------------------*
            asc_agenthost TYPE csmclass
*              value 'SAPCCMS_Assoc_Agent_Host',
              VALUE 'BCAgentHost',                          "#EC NOTEXT
            tok_agenthost TYPE csmtoken
*              value 'SAPCCMS_AgentHost_AgentOnHost',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_hostagent TYPE csmtoken
*              value 'SAPCCMS_AgentHost_HostSupportsAgent',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Agent monitors Host
* Agent has start of directed link to Host
*---------------------------------------------------------------*
            asc_agentmonhost TYPE csmclass
*              value 'SAPCCMS_Assoc_Agent_Host',
              VALUE 'BCAgentMonitorsHost',                  "#EC NOTEXT
            tok_agentmonhost TYPE csmtoken
*              value 'SAPCCMS_AgentHost_AgentOnHost',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_hostagentmon TYPE csmtoken
*              value 'SAPCCMS_AgentHost_HostSupportsAgent',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Agent to Server (Application Server)
* Agent has start of directed link to AppServer
*---------------------------------------------------------------*
            asc_agenttrex TYPE csmclass
*              value 'SAPCCMS_Assoc_Agent_AppSrv',
              VALUE 'BCAgentMonitoredTREX',    "#EC NOTEXT
            asc_agentappsrv TYPE csmclass
*              value 'SAPCCMS_Assoc_Agent_AppSrv',
              VALUE 'BCAgentMonitoredApplicationServer',    "#EC NOTEXT
             tok_agentappsrv TYPE csmtoken
*              value 'SAPCCMS_AgentAppSrv_AgentMonitorsAppSrv',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_appsrvagent TYPE csmtoken
*              value 'SAPCCMS_AppSrvAgent_AppSrvMonByAgent',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Agent to RFC Destination
* Agent has start of directed link to RFC Destination
* With 50 - agent is end of link from RFC destinatio nfor
* compatibility with similar RFC Dst to object links.
*---------------------------------------------------------------*
            asc_agentrfc TYPE csmclass
*              value 'SAPCCMS_Assoc_Agent_RFCDest',
              VALUE 'RFCDestinationBCAgent',                "#EC NOTEXT
            tok_agentrfc TYPE csmtoken
              VALUE 'Antecedent',                           "#EC NOTEXT
*              value 'SAPCCMS_AgentRFC_AgentReachableAtDest',
            tok_rfcagent TYPE csmtoken
              VALUE 'Dependent',                            "#EC NOTEXT
*              value 'SAPCCMS_AgentRFC_UseDestToReachAgent',
*---------------------------------------------------------------*
* CSM ITS to System served by ITS (external component)
* ITS has start of directed link to System
*---------------------------------------------------------------*
            asc_sysxc TYPE csmclass
*              value 'SAPCCMS_Assoc_ITS_SystemServed',
              VALUE 'ExternalComponentSystemServed',        "#EC NOTEXT
            tok_sysxc TYPE csmtoken
*              value 'SAPCCMS_SysITS_ITSServesSystem',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_xcsys TYPE csmtoken
*              value 'SAPCCMS_SysITS_ITSServesSystem',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM System Monitoring (RZ20) ITS to ITS
* System has start of directed link to ITS
*---------------------------------------------------------------*
            asc_monsysits TYPE csmclass
*              value 'SAPCCMS_Assoc_MonSystem_ITS',
              VALUE 'MonitoringSystemITS',                  "#EC NOTEXT
            tok_monsysits TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_SysMonitorsITS',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_itsmonsys TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_ITSMonitoredBySys',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM system linked to dsr component
* System has start of directed link to ITS
*---------------------------------------------------------------*
            asc_sysdsr TYPE csmclass
*              value 'SAPCCMS_Assoc_MonSystem_ITS',
              VALUE 'DSRLinkedSystem',                      "#EC NOTEXT
            tok_sysdsr TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_SysMonitorsITS',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_dsrsys TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_ITSMonitoredBySys',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM System served by ITS
* System has start of directed link to ITS
*---------------------------------------------------------------*
            asc_sysits TYPE csmclass
*              value 'SAPCCMS_Assoc_MonSystem_ITS',
              VALUE 'ServedSystemITS',                      "#EC NOTEXT
            tok_sysits TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_SysMonitorsITS',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_itssys TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_ITSMonitoredBySys',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Agent Monitoring (DSR) ITS to ITS
* System has start of directed link to ITS
*---------------------------------------------------------------*
            asc_sapstartsrvdsr type csmclass
              value 'MonitoringSAPSTARTSRVDSRComponent',
            asc_agentdsr TYPE csmclass
*              value 'SAPCCMS_Assoc_MonSystem_ITS',
              VALUE 'MonitoringAgentDSRComponent',          "#EC NOTEXT
            tok_agentdsr TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_SysMonitorsITS',
              VALUE 'Antecedent',                           "#EC NOTEXT
            tok_dsragent TYPE csmtoken
*              value 'SAPCCMS_MonSysITS_ITSMonitoredBySys',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM ITSAdmin to ITS
* ITSAdmin has start of directed link to ITS
*---------------------------------------------------------------*
            asc_itsadminits TYPE csmclass
*              value 'SAPCCMS_Assoc_ITSAdmin_ITS',
              VALUE 'ITSManagingInstance',                  "#EC NOTEXT
            tok_itsadminits TYPE csmtoken
*              value 'SAPCCMS_ITSAdmin_AdminManagesITS',
              VALUE 'Antecedent',               "#EC NOTEXT "#EC NOTEXT
            tok_itsitsadmin TYPE csmtoken
*              value 'SAPCCMS_ITSAdmin_ITSManagedByAdmin',
              VALUE 'Dependent',                            "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Host to ITS Instance
* ITS Instance is weak with respect to host
*---------------------------------------------------------------*
            asc_hostits TYPE csmclass
*              value 'SAPCCMS_Assoc_ITSAdmin_ITS',
              VALUE 'ITSHosteByComputerSystem',             "#EC NOTEXT
            tok_hostits TYPE csmtoken
*              value 'SAPCCMS_ITSAdmin_AdminManagesITS',
              VALUE 'GroupComponent',           "#EC NOTEXT "#EC NOTEXT
            tok_itshost TYPE csmtoken
*              value 'SAPCCMS_ITSAdmin_ITSManagedByAdmin',
              VALUE 'PartComponent',                        "#EC NOTEXT
*---------------------------------------------------------------*
* CSM R3System to Logical System
* R3System has start of weak link to Logical System
* No longer used as of 4.6D/C!!!
*---------------------------------------------------------------*
            asc_syslogsys TYPE csmclass
              VALUE 'SAPCCMS_Assoc_System_LogicalSystem',   "#EC NOTEXT
            tok_syslogsys TYPE csmtoken
              VALUE 'SAPCCMS_LogSys_SystemHasLogicalSystem',"#EC NOTEXT
            tok_logsyssys TYPE csmtoken
              VALUE 'SAPCCMS_LogSys_LogicalSystemInSystem', "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Domain_V2 to logical system
* Domain_V2 has start of weak link to logical system
*---------------------------------------------------------------*
            asc_domlogsys TYPE csmclass
*              value 'SAPCCMS_Assoc_Domain_LogicalSystem', "50
              VALUE 'NamespaceLogicalSystem',           "#EC NOTEXT "50
            tok_domlogsys TYPE csmtoken
*              value 'SAPCCMS_LogSys_DomainOfLogicalSystem',
               VALUE 'Collection',                          "#EC NOTEXT
            tok_logsysdom TYPE csmtoken
*              value 'SAPCCMS_LogSys_LogicalSystemInDomain',
               VALUE 'Member',                              "#EC NOTEXT
*---------------------------------------------------------------*
* CSM Logical System to Client
* Logical System has start of directed link to client
*---------------------------------------------------------------*
            asc_logsyscli TYPE csmclass
*              value 'SAPCCMS_Assoc_LogicalSystem_Client', "50
              VALUE 'LogicalSystemClient', "50 "#EC NOTEXT
            tok_logsyscli TYPE csmtoken
*              value 'SAPCCMS_LogCli_LogicalSystemForClient',
               VALUE 'Antecedent',                          "#EC NOTEXT
            tok_clilogsys TYPE csmtoken
*              value 'SAPCCMS_LogCli_ClientReachedByLogSys',
               VALUE 'Dependent',                           "#EC NOTEXT

*---------------------------------------------------------------*
* CSM Indication
* Logical System has start of directed link to client
*---------------------------------------------------------------*
            cls_sapind TYPE csmclass
              VALUE 'MethodRunRequest', "50 "#EC NOTEXT
            tok_refdguid TYPE csmtoken
               VALUE 'Referenced_GUID',                     "#EC NOTEXT
            tok_refdtype TYPE csmtoken
               VALUE 'Referenced_GUID_Type',                "#EC NOTEXT
            tok_refdscheme TYPE csmtoken
               VALUE 'Referenced_Schema',                   "#EC NOTEXT
            tok_refdclass TYPE csmtoken
               VALUE 'Referenced_Class',                    "#EC NOTEXT
            tok_aboevent TYPE csmtoken
               VALUE 'Event',                               "#EC NOTEXT
            tok_abosubscriber TYPE csmtoken
               VALUE 'Subscriber',                          "#EC NOTEXT
            tok_indmethod TYPE csmtoken
               VALUE 'Method',                              "#EC NOTEXT
            tok_synchron TYPE csmtoken
               VALUE 'Synchronous_Execution',               "#EC NOTEXT
            tok_context TYPE csmtoken
               VALUE 'RequiredContext',                     "#EC NOTEXT
            tok_contextkey TYPE csmtoken
               VALUE 'GUIDKey_For_Context',                 "#EC NOTEXT
            tok_indstatus TYPE csmtoken
               VALUE 'Method_Run_Status',                   "#EC NOTEXT

* CSM Scheme names
            bc_scheme  TYPE csmsmntc VALUE 'SAP',        "#EC NOTEXT"50
            scheme_bc  TYPE csmsmntc VALUE 'SAP',        "#EC NOTEXT"50
            scheme_cim TYPE csmsmntc VALUE 'CIM',           "#EC NOTEXT
*            scheme_sap type csmsmntc value 'SAP', "#EC NOTEXT
            scheme_mon TYPE csmsmntc VALUE 'MON',           "#EC NOTEXT
            scheme_old TYPE csmsmntc VALUE 'R3Basis',       "#EC NOTEXT
            scheme_ppms_soll TYPE csmsmntc VALUE 'SAPPPMS', "#EC NOTEXT
            scheme_sap TYPE csmsmntc VALUE 'SAP',        "#EC NOTEXT"50

* CSM Semantic Names
            sem_bc TYPE csmsmntc VALUE 'R3Basis',           "#EC NOTEXT
            sem_dsr TYPE csmsmntc VALUE 'DSR',              "#EC NOTEXT
            sem_mon TYPE csmsmntc VALUE 'MonArch',          "#EC NOTEXT
            sem_cim TYPE csmsmntc VALUE 'CIM',              "#EC NOTEXT
            sem_its TYPE csmsmntc VALUE 'ITS',              "#EC NOTEXT
            sem_logsys TYPE csmsmntc VALUE 'LogSys',        "#EC NOTEXT
            sem_grp TYPE csmsmntc VALUE 'MoniGrp',          "#EC NOTEXT
            sem_agent TYPE csmsmntc VALUE 'BCAgent',        "#EC NOTEXT
            sem_db TYPE csmsmntc VALUE 'Database',          "#EC NOTEXT
            sem_rep TYPE csmsmntc VALUE 'SCR',              "#EC NOTEXT
            sem_scr TYPE csmsmntc VALUE 'SRC',              "#EC NOTEXT
            sem_ppms_soll TYPE csmsmntc VALUE 'SAPPPMS',    "#EC NOTEXT
            sem_ppms_ist TYPE csmsmntc VALUE 'PPMSINST',    "#EC NOTEXT
* CSM Semantic names: translation texts
            sem_bct TYPE almteclass VALUE 'R/3 Basis System',
                                                            "#EC NOTEXT
* CSM Provider names
            pro_bc             TYPE almteclass
              VALUE 'CSMProvider_R3BasisSystem',            "#EC NOTEXT
            pro_mon            TYPE almteclass
              VALUE 'CSMProvider_R3Monitoring',             "#EC NOTEXT
* Standard CSM owner for classes
            csm_standard_owner TYPE csmsysguid
              VALUE 'mySAP.com_Infrastr-Mgmt'.              "#EC NOTEXT
*----------------------------------------------------------------------
*
CONSTANTS: csm_space TYPE csmobjnm
              VALUE 'FIELD_EMPTY'.
