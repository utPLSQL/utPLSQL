create or replace type ut_expectation as object(
  assert_name varchar2(128),
  expected    ut_data_value,
  final member function not_implemented(a_actual ut_data_value)  return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_anydata) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_blob) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_boolean) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_clob) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_date) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_number) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_refcursor) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_timestamp) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_timestamp_tz) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_timestamp_ltz) return ut_assert_result,
  member function run_expectation(a_actual ut_data_value_varchar2) return ut_assert_result,
  member function build_assert_result(a_assert_result boolean, a_actual ut_data_value) return ut_assert_result
) not final not instantiable
/
