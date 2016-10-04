create or replace type ut_assertion_raw under ut_assertion
(
  actual raw(32767),
  constructor function ut_assertion_raw(self in out nocopy ut_assertion_raw, a_actual raw, a_message varchar2 default null) return self as result,
  overriding member procedure to_be_equal(self in ut_assertion_raw, a_expected raw)
)
/
