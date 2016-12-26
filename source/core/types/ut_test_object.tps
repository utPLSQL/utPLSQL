create or replace type ut_test_object force under ut_composite_object
(

  object_name varchar2(4000),
  object_path varchar2(4000),
  rollback_type integer(1), -- ut_utils:gc_rollback_% constants
  ignore_flag   integer(1),
  start_time  timestamp with time zone,
  end_time    timestamp with time zone,
  
  member procedure init(self in out nocopy ut_test_object, a_desc_name varchar2, a_object_name varchar2, a_object_type integer, a_object_path varchar2 default null, a_rollback_type integer default null),
  
  not instantiable member procedure do_execute(self in out nocopy ut_test_object, a_reporter in out nocopy ut_reporter, a_parent_err_msg varchar2),
  final member procedure do_execute(self in out nocopy ut_test_object),

  member procedure set_ignore_flag(self in out nocopy ut_test_object, a_ignore_flag boolean),
  member function get_ignore_flag return boolean,
  member procedure set_rollback_type(self in out nocopy ut_test_object, a_rollback_type integer),

  member function execution_time return number
)
not instantiable not final
/
