create or replace type ut_test_suite force under ut_test_object
(
  items      ut_test_objects_list,

	constructor function ut_test_suite(a_suite_name varchar2, a_items ut_test_objects_list default ut_test_objects_list()) return self as result,
	member procedure add_item(self in out nocopy ut_test_suite, a_item ut_test_object),

  overriding member procedure execute(self in out nocopy ut_test_suite, a_reporter ut_suite_reporter),
  overriding member function execute(self in out nocopy ut_test_suite, a_reporter ut_suite_reporter) return ut_suite_reporter,
  overriding member procedure execute(self in out nocopy ut_test_suite)
)
not final
/
