create or replace package ut_suite_manager authid definer is

  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_suite;

  procedure config_schema(a_owner_name varchar2);
  
  --INTERNAL USE
  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items;

end ut_suite_manager;
/
