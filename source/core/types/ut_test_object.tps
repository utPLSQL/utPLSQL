create or replace type ut_test_object force under ut_composite_object
(
  start_time  timestamp with time zone,
  end_time    timestamp with time zone,
  object_name varchar2(4000),
  rollback_type integer(1), -- ut_utils:gc_rollback_% constants
  ignore_flag   integer(1),
  
  not instantiable member procedure execute(self in out nocopy ut_test_object, a_reporter ut_reporter),
  not instantiable member function execute(self in out nocopy ut_test_object, a_reporter ut_reporter)
    return ut_reporter,
  not instantiable member procedure execute(self in out nocopy ut_test_object),
  
  member procedure set_ignore_flag(self in out nocopy ut_test_object, a_ignore_flag boolean),
  member procedure set_rollback_type(self in out nocopy ut_test_object, a_rollback_type integer)
)
not instantiable not final
/
