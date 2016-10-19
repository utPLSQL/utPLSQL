create or replace type be_like under ut_matcher(
  mask varchar2(4000),
  escape_char varchar2(1),
  constructor function be_like(self in out nocopy be_like, a_mask in varchar2, a_escape_char in varchar2 := null) return self as result,
  overriding member function run_matcher(self in out nocopy be_like, a_actual ut_data_value) return boolean
)
/
