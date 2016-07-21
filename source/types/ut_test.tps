create or replace type ut_test force under ut_test_object
(

  /*
	object_name        varchar2(32 char),
  test_procedure     varchar2(32 char),
  owner_name         varchar2(32 char),
  setup_procedure    varchar2(32 char),
  teardown_procedure varchar2(32 char),
	*/
	call_params ut_test_call_params,
  assert_results ut_assert_list,

  constructor function ut_test(a_object_name varchar2, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null)
    return self as result,

  member function is_valid(self in ut_test) return boolean,

  overriding member procedure execute(self in out nocopy ut_test, a_reporter in out nocopy ut_suite_reporter),
  overriding member procedure execute(self in out nocopy ut_test)

)
not final
/
