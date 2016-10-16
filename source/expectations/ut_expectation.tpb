create or replace type body ut_expectation as

  member function run_expectation(a_actual ut_data_value) return boolean is
  begin
    ut_utils.debug_log('Failure - ut_expectation.run_expectation'||'(a_actual '||a_actual.type||')');
    return false;
  end;

end;
/
