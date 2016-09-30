create or replace package ut_metadata as
  /*
    package: ut_metadata
  
    Common place for all code that reads from the system tables.
  
  */

  subtype t_annotation_name is varchar2(1000);

  type typ_annotation_param is record(
     key   varchar2(255)
    ,value varchar2(4000));

  type tt_annotation_params is table of typ_annotation_param index by pls_integer;

  type tt_annotations is table of tt_annotation_params index by t_annotation_name;

  type tt_anoteded_procs is table of tt_annotations index by t_annotation_name;

  type typ_annotated_package is record(
     procedures  tt_anoteded_procs
    ,annotations tt_annotations);

  /*
    function form_name
      
    forms correct object/subprogram name to call as owner.object[.subprogram]
    
  */

  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2;

  /*
    function: package_valid
  
    check if package exists and is VALID.
  
  */
  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean;

  /*
    function: procedure_exists
  
    check if package exists and is VALID and contains the given procedure.
  
  */
  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean;

  /*
    procedure: do_resolve

    resolves [owner.]object using dbms_utility.name_resolve and returnes resolved parts

  */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2);

  /*
    procedure: do_resolve
    
    resolves [owner.]object[.procedure] using dbms_utility.name_resolve and returnes resolved parts 
    
  */
  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2);

  function get_annotation_param(a_param_list tt_annotation_params, a_def_index pls_integer) return varchar2;

  /*
    function: parse_package_annotations
    
    parse package specification for annotations and return its annotated schema
  */
  function parse_package_annotations(a_owner_name varchar2, a_name varchar2) return typ_annotated_package;

  /*
    function: is_dba_source_accessible

    check if utplsql can see dba_source system view (it's faster than all_source)
  */
  function is_dba_source_accessible return boolean;

end ut_metadata;
/
