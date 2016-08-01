create or replace type ut_test force under ut_test_object
(
  setup ut_executable,
	test ut_executable,
	teardown ut_executable,

  constructor function ut_test(a_object_name varchar2, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null)
    return self as result,

  member function is_valid(self in ut_test) return boolean,

  overriding member procedure execute(self in out nocopy ut_test, a_reporter ut_suite_reporter),
  overriding member function execute(self in out nocopy ut_test, a_reporter ut_suite_reporter) return ut_suite_reporter,
  overriding member procedure execute(self in out nocopy ut_test)

)
not final
/
