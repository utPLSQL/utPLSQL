create or replace type body ut_matcher as

  member function run_matcher(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_matcher.run_matcher'||'(a_actual '||a_actual.datatype||')');
    self.error_message := 'The matcher '''||self.name||''' cannot be used';
    if self.expected is not null then
      self.error_message := self.error_message ||' for comparison of data type ('||self.expected.datatype||')';
    end if;
    self.error_message := self.error_message ||' with data type ('||a_actual.datatype||').';
    return null;
  end;

end;
/
