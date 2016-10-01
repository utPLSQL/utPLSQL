create or replace package ut_annotations_cache as
  /*
    package: ut_annotations

    Responsible for reading and maintaining the annotations cache tables.

  */

  subtype typ_annotated_package is ut_annotations.typ_annotated_package;

  /*
    function: get_package_annotations

    obtain annotations for package specification by reading cache or by parsing the package
  */
  function get_package_annotations(a_owner_name varchar2, a_name varchar2) return typ_annotated_package;

end;
/
