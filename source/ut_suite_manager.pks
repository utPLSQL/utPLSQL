create or replace package ut_suite_manager is

  procedure config_package(a_owner_name varchar2, a_object_name varchar2, a_suite out ut_test_suite);

  procedure config_schema(a_owner_name varchar2);

  procedure run_schema_suites(a_owner_name varchar2, a_reporter in out nocopy ut_reporter);

  procedure run_schema_suites_static(a_owner_name varchar2, a_reporter in ut_reporter);

  procedure run_cur_schema_suites(a_reporter in out nocopy ut_reporter);

  procedure run_cur_schema_suites_static(a_reporter in ut_reporter);

end ut_suite_manager;
/
