create or replace type ut_test under ut_suite_item (
  /**
  * The procedure to be invoked before invoking the test
  * Procedure exists within the same package as the test itself
  */
  before_test ut_executable,
  /**
  * The Test procedure to be executed
  */
  item        ut_executable,
  /**
  * The procedure to be invoked after invoking the test
  * Procedure exists within the same package as the test itself
  */
  after_test  ut_executable,
  /**
  * The list of assert results as well as database errors encountered while invoking
  * The test procedure and the before_test/after_test blocks
  */
  results     ut_assert_results,
  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_description varchar2 := null,
    a_path varchar2 := null, a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_test_proc_name varchar2 := null, a_after_test_proc_name varchar2 := null
  ) return self as result,
  member function is_valid return boolean,
  overriding member procedure do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base),
  overriding member function do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_test)
)
/
