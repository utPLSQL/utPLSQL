create or replace type ut_test_object force as object
(
  name varchar2(250 char),
  execution_result ut_execution_result,

  not instantiable  member procedure execute(self in out nocopy ut_test_object, a_reporter ut_suite_reporter),
  not instantiable  member function execute(self in out nocopy ut_test_object, a_reporter ut_suite_reporter) return ut_suite_reporter,
  not instantiable  member procedure execute(self in out nocopy ut_test_object)
)
not instantiable not final
/
