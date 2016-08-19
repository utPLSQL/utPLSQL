create or replace type ut_test_object force under ut_composite_object
(
  start_time  timestamp with time zone,
  end_time    timestamp with time zone,
  object_name varchar2(32),
  not instantiable member procedure execute(self in out nocopy ut_test_object, a_reporter ut_suite_reporter),
  not instantiable member function execute(self in out nocopy ut_test_object, a_reporter ut_suite_reporter)
    return ut_suite_reporter,
  not instantiable member procedure execute(self in out nocopy ut_test_object)
)
not instantiable not final
/
