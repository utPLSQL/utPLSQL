create or replace type ut_assertion_number under ut_assertion
(
  actual number,
  constructor function ut_assertion_number(self in out nocopy ut_assertion_number, a_actual number, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_number, a_expected number, a_nulls_are_equal boolean := null)
)
/
