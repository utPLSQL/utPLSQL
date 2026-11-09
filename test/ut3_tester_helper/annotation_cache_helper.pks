create or replace package annotation_cache_helper as

  procedure setup_two_suites;
  procedure add_new_suite;
  procedure revoke_granted_suite;

  procedure cleanup_two_suites;
  procedure cleanup_new_suite;

  procedure purge_annotation_cache;

  procedure disable_ddl_trigger;
  procedure enable_ddl_trigger;

  procedure setup_suite_hierarchy;
  procedure cleanup_suite_hierarchy;

  procedure create_run_function_for_users;
  procedure drop_run_function_for_users;

  function run_tests_as(a_user varchar2, a_path varchar2 := 'ut3_cache_test_owner') return clob;
  function get_suites_info_as(a_user varchar2) return clob;

end;
/