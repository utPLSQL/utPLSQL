create or replace package ut_annotations as
  /*
    package: ut_annotations

    Responsible for parsing and accessing utplsql annotations.

  */

  subtype t_annotation_name is varchar2(1000);
  subtype t_procedure_name  is varchar2(30);

  /*
    type: typ_annotation_param

    a key/value pair of annotation parameters

    example:
      --%test(name=A name of the test)
    will be stored as:
      typ_annotation_param( key=> 'name', value=>'A name of the test' )
  */
  type typ_annotation_param is record(
     key   varchar2(255)
    ,value varchar2(4000));

  /*
    type: typ_annotation_param
    a list of typ_annotation_param
  */
  type tt_annotation_params is table of typ_annotation_param index by pls_integer;

  /*
    type: tt_annotations
    a list of tt_annotation_params index by the annotation name
  */
  type tt_annotations is table of tt_annotation_params index by t_annotation_name;

  /*
    type: tt_procedure_annotations
    a list of tt_annotations index by the procedure name
  */
  type tt_procedure_annotations is table of tt_annotations index by t_procedure_name;

  /*
    type: typ_annotated_package
    a structure containing a list of package level annotations and a list of procedure level annotations

  */
  type typ_annotated_package is record(
     procedure_annotations  tt_procedure_annotations
    ,package_annotations    tt_annotations);



  /*
    function: get_package_annotations

    get annotations for specified package specification and return its annotated schema
  */
  function get_package_annotations(a_owner_name varchar2, a_name varchar2) return typ_annotated_package;


  /*
    function: parse_package_sourcecode

    parse annotations of a given source code
  */
  function parse_package_sourcecode(a_source clob) return typ_annotated_package;

  /*
    function: get_annotation_param

    get annotation parameter on a specified index position
  */
  function get_annotation_param(a_param_list tt_annotation_params, a_def_index pls_integer) return varchar2;

end ut_annotations;
/
