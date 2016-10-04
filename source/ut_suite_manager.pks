create or replace package ut_suite_manager is

  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_test_suite;

  procedure config_schema(a_owner_name varchar2);

  procedure run_schema_suites(a_owner_name varchar2, a_reporter in out nocopy ut_reporter, a_force_parse_again boolean default false);

  procedure run_schema_suites_static(a_owner_name varchar2, a_reporter in ut_reporter, a_force_parse_again boolean default false);

  procedure run_cur_schema_suites(a_reporter in out nocopy ut_reporter, a_force_parse_again boolean default false);

  procedure run_cur_schema_suites_static(a_reporter in ut_reporter, a_force_parse_again boolean default false);

end ut_suite_manager;
/
