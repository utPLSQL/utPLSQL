create or replace type ut_test_suite force under ut_test_object
(

  setup    ut_executable,
  teardown ut_executable,

  constructor function ut_test_suite(self in out nocopy ut_test_suite,a_suite_name varchar2, a_object_name varchar2, a_object_path varchar2 default null, a_items ut_objects_list default ut_objects_list(), a_rollback_type number default null)
    return self as result,

  member procedure set_suite_setup   (self in out nocopy ut_test_suite, a_object_name in varchar2, a_proc_name in varchar2, a_owner_name varchar2 default null),

  member procedure set_suite_teardown(self in out nocopy ut_test_suite, a_object_name in varchar2, a_proc_name in varchar2, a_owner_name varchar2 default null),
  member function is_valid return boolean,

  overriding member procedure do_execute(self in out nocopy ut_test_suite, a_reporter in out nocopy ut_reporter, a_parent_err_msg varchar2)
)
not final
/
