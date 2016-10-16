create or replace type body ut_expectation as

  member function run_expectation(self in out nocopy ut_expectation, a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_expectation.run_expectation'||'(a_actual '||a_actual.type||')');
    self.additional_info := self.additional_info ||'. The matcher '''||self.name||''' cannot be used with data type ('||a_actual.type||')';
    return false;
  end;

end;
/
