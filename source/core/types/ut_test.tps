create or replace type ut_test force under ut_test_object
(
  setup    ut_executable,
  test     ut_executable,
  teardown ut_executable,

  constructor function ut_test(self in out nocopy ut_test,a_object_name varchar2,a_object_path varchar2 default null, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null, a_rollback_type integer default null)
    return self as result,

  member function is_valid return boolean,

  overriding member procedure do_execute(self in out nocopy ut_test, a_reporter in out nocopy ut_reporter, a_parent_err_msg varchar2 default null)
)
not final
/
