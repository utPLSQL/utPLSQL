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

  type t_suite_with_path is record(
     path  varchar2(4000 char)
    ,suite ut_test_suite);

  /*
    function form_name
      
    forms correct object/subprogram name to call as owner.object[.subprogram]
    
  */

  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2;

  /*
    function: resolvable
    
    tries to resolve full subprogram name using dbms_utility.name_resolve
  */
  function resolvable(a_owner in varchar2, a_object in varchar2, a_procedurename in varchar2) return boolean;

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
    
    resolves [owner.]object[.procedure] using dbms_utility.name_resolve and returnes resolved parts 
    
  */
  procedure do_resolve(a_owner in out varchar2, a_object in out varchar2, a_procedure_name in out varchar2);

  function get_annotation_param(a_param_list tt_annotation_params, a_def_index pls_integer) return varchar2;

  /*
    procedure: parse_package_annotations
    
    parse package specification for annotations and return its annotated schema
  */
  procedure parse_package_annotations(a_owner_name varchar2, a_name varchar2, a_annotated_pkg out typ_annotated_package);

end ut_metadata;
/
