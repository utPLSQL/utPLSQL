create or replace type body ut_expectation as

  final member function not_implemented(a_actual ut_data_value)  return ut_assert_result is
  begin
    ut_utils.debug_log('ERROR - equal.run_expectation(a_actual '||a_actual.type||')');
    return 
      ut_assert_result(
        self.assert_name, ut_utils.tr_error, self.expected.type, a_actual.type, self.expected.value_string, a_actual.value_string,
      'This expectation is not implemented for this data type'
      );    
  end;
  
  member function run_expectation(a_actual ut_data_value_blob) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_boolean) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_clob) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_number) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_date) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_timestamp) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_timestamp_tz) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_timestamp_ltz) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function run_expectation(a_actual ut_data_value_varchar2) return ut_assert_result is
  begin
    return not_implemented(a_actual);
  end;

  member function build_assert_result(a_assert_result boolean, a_actual ut_data_value) return ut_assert_result is
  begin
    ut_utils.debug_log('ut_expectation.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':');
    return
      ut_assert_result(
        self.assert_name, ut_utils.to_test_result(a_assert_result),
        self.expected.type, a_actual.type,
        self.expected.value_string, a_actual.value_string, null
      );
  end;
end;
/
