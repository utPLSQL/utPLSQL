create or replace type ut_assertion_varchar2 under ut_assertion
(
  actual varchar2(32767 char),
  constructor function ut_assertion_varchar2(self in out nocopy ut_assertion_varchar2, a_actual varchar2, a_message varchar2 default null) return self as result,
  overriding member procedure to_equal(self in ut_assertion_varchar2, a_expected varchar2, a_nulls_are_equal boolean := null),
  member procedure to_be_like(self in ut_assertion_varchar2, a_mask in varchar2, a_escape_char in varchar2 := null),
  member procedure to_match(self in ut_assertion_varchar2, a_pattern in varchar2, a_modifier in varchar2 := null)
)
/
