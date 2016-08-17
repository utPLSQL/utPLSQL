create or replace type ut_composite_reporter under ut_reporter
(
  reporters ut_reporters_list,

  constructor function ut_composite_reporter(a_reporters ut_reporters_list default ut_reporters_list())
    return self as result,
  member procedure add_reporter(self in out nocopy ut_composite_reporter, a_reporter ut_reporter),
  member procedure remove_reporter(self in out nocopy ut_composite_reporter, a_index pls_integer),
	
  overriding member procedure before_execution(self in out nocopy ut_composite_reporter, a_suites in ut_objects_list),

  overriding member procedure before_suite(self in out nocopy ut_composite_reporter, a_suite in ut_object),

  overriding member procedure on_suite_setup(self in out nocopy ut_composite_reporter, a_suite in ut_object),

  overriding member procedure before_test(self in out nocopy ut_composite_reporter, a_test in ut_object),

  overriding member procedure on_test_setup(self in out nocopy ut_composite_reporter, a_test in ut_object),
  overriding member procedure on_test_execute(self in out nocopy ut_composite_reporter, a_test in ut_object),
  overriding member procedure on_test_teardown(self in out nocopy ut_composite_reporter, a_test in ut_object),

  overriding member procedure before_asserts_process(self in out nocopy ut_composite_reporter, a_test in ut_object),
  overriding member procedure on_assert_process(self in out nocopy ut_composite_reporter, a_assert in ut_object),
  overriding member procedure after_asserts_process(self in out nocopy ut_composite_reporter, a_test in ut_object),

  overriding member procedure after_test(self in out nocopy ut_composite_reporter, a_test in ut_object),

  overriding member procedure on_suite_teardown(self in out nocopy ut_composite_reporter, a_suite in ut_object),

  overriding member procedure after_suite(self in out nocopy ut_composite_reporter, a_suite in ut_object),

  overriding member procedure after_execution(self in out nocopy ut_composite_reporter, a_suites in ut_objects_list)

)
not final
/
