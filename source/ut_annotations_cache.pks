create or replace package ut_annotations_cache as

  gc_purge_after_days constant integer :=5;

  /*
    package: ut_annotations

    Responsible for reading and maintaining the annotations cache tables.
    Invocation of the package within a session for the firs time will execute automatic purge
    of cached annotations that are older than gc_purge_after_days.

  */

  subtype typ_annotated_package    is ut_annotations.typ_annotated_package;
  subtype tt_procedure_annotations is ut_annotations.tt_procedure_annotations;
  subtype tt_annotations           is ut_annotations.tt_annotations;
  subtype tt_annotation_params     is ut_annotations.tt_annotation_params;
  subtype t_annotation_name        is ut_annotations.t_annotation_name;
  subtype t_procedure_name         is ut_annotations.t_procedure_name;

  /*
    procedure: purge_cache

    Deletes cache data from cache tables for a given package
    Uses autonomous transaction to perform the operations.
     
  */
  procedure purge_cache(a_owner_name varchar2, a_package_name varchar2);


  /*
    procedure: purge_cache

    Deletes cache data from cache tables that is older than given number of days
    Uses autonomous transaction to perform the operations.

  */
  procedure purge_cache(a_number_of_days number);

  /*
    procedure: purge_cache

    Deletes whole cache data from cache tables
    Uses autonomous transaction to perform the operations.

  */
  procedure purge_cache;

  /*
    procedure: update_cache

    Updates cache data in cache tables for a given package
    Uses autonomous transaction to perform the operations.

  */
  procedure update_cache(a_owner_name varchar2, a_package_name varchar2, a_annotated_pkg typ_annotated_package);

  /*
    function: get_cache_data

    Get annotations for package specification by reading it from cache tables
    Returns NULL if package is not present the cache
  */
  function get_cache_data(a_owner_name varchar2, a_package_name varchar2) return typ_annotated_package;

  /*
    function: is_cache_valid

    Returns true if package is cached and cache data is greater than last DDL timestamp of the package
  */
  function is_cache_valid(a_owner_name varchar2, a_package_name varchar2) return boolean;

end;
/
