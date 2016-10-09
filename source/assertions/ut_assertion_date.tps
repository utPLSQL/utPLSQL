create or replace type ut_assertion_date under ut_assertion
(
  constructor function ut_assertion_date(self in out nocopy ut_assertion_date, a_actual date, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_date, a_expected date, a_nulls_are_equal boolean := null)
)
/
