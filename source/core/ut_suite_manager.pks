create or replace package ut_suite_manager authid current_user is

  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_test_suite;

  procedure config_schema(a_owner_name varchar2);
  
  procedure run(a_path in varchar2, a_reporter in ut_reporter);
  -- implementation to be changed
  procedure run(a_paths in ut_varchar2_list, a_reporter in ut_reporter);
  
  --INTERNAL USE  
  procedure configure_execution_by_path(a_paths in ut_varchar2_list, a_objects_to_run out nocopy ut_objects_list);

end ut_suite_manager;
/
