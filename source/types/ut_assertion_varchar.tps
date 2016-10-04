create or replace type ut_assertion_varchar under ut_assertion
(
  a_actual varchar2(32767),
  constructor function ut_assertion_varchar(self in out nocopy ut_assertion_varchar, a_message varchar2 default null, a_actual varchar2) return self as result,
  member procedure to_be_equal(a_expected varchar2),
  member procedure to_be_like(a_mask in varchar, a_escape_char in varchar2 := null),
  member procedure to_be_matching(a_pattern in varchar2, a_modifier in varchar2 := null),
  member procedure to_be_null,
  member procedure to_be_not_null
);
/
