create or replace type ut_match under ut_matcher(
  pattern varchar2(4000),
  modifiers varchar2(4000),
  constructor function ut_match(self in out nocopy ut_match, a_pattern in varchar2, a_modifiers in varchar2 default null) return self as result,
  overriding member function run_matcher(self in out nocopy ut_match, a_actual ut_data_value) return boolean
)
/
