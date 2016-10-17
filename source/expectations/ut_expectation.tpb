create or replace type body ut_expectation as

  member function run_expectation(self in out nocopy ut_expectation, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_expectation.run_expectation'||'(a_actual '||a_actual.type||')');
    self.error_message := 'The matcher '''||self.name||''' cannot be used';
    if self.expected is not null then
      self.error_message := self.error_message ||' for comparison of data type ('||self.expected.type||')';
    end if;
    self.error_message := self.error_message ||' with data type ('||a_actual.type||').';
    return null;
  end;

end;
/
