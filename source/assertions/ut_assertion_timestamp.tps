create or replace type ut_assertion_timestamp under ut_assertion
(
  constructor function ut_assertion_timestamp(self in out nocopy ut_assertion_timestamp, a_actual timestamp_unconstrained, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_timestamp, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)
)
/
