create or replace type ut_reporter force as object
(
  name varchar2(250 char),
	
	constructor function ut_reporter return self as result,

  member procedure before_execution(self in out nocopy ut_reporter, a_suites in ut_objects_list),

  member procedure before_suite(self in out nocopy ut_reporter, a_suite in ut_object),

  member procedure on_suite_setup(self in out nocopy ut_reporter, a_suite in ut_object),

  member procedure before_test(self in out nocopy ut_reporter, a_test in ut_object),

  member procedure on_test_setup(self in out nocopy ut_reporter, a_test in ut_object),
  member procedure on_test_execute(self in out nocopy ut_reporter, a_test in ut_object),
  member procedure on_test_teardown(self in out nocopy ut_reporter, a_test in ut_object),

  member procedure before_asserts_process(self in out nocopy ut_reporter, a_test in ut_object),
  member procedure on_assert_process(self in out nocopy ut_reporter, a_assert in ut_object),
  member procedure after_asserts_process(self in out nocopy ut_reporter, a_test in ut_object),

  member procedure after_test(self in out nocopy ut_reporter, a_test in ut_object),

  member procedure on_suite_teardown(self in out nocopy ut_reporter, a_suite in ut_object),

  member procedure after_suite(self in out nocopy ut_reporter, a_suite in ut_object),

  member procedure after_execution(self in out nocopy ut_reporter, a_suites in ut_objects_list)

)
not final
/
