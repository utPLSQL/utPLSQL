create or replace type ut_assertion_clob under ut_assertion
(
  actual clob,
  constructor function ut_assertion_clob(self in out nocopy ut_assertion_clob, a_actual clob, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_clob, a_expected clob, a_nulls_are_equal boolean := null),
  member procedure to_be_like(self in ut_assertion_clob, a_mask in varchar2, a_escape_char in varchar2 := null),
  member procedure to_match(self in ut_assertion_clob, a_pattern in varchar2, a_modifier in varchar2 := null)
)
/
