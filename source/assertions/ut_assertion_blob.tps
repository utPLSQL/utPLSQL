create or replace type ut_assertion_blob under ut_assertion
(
  actual blob,
  constructor function ut_assertion_blob(self in out nocopy ut_assertion_blob, a_actual blob, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_blob, a_expected blob, a_nulls_are_equal boolean := null)
)
/
