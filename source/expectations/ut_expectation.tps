create or replace type ut_expectation as object(
  assert_name varchar2(128),
  expected    ut_data_value,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_varchar2) return ut_assert_result,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_number) return ut_assert_result,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_clob) return ut_assert_result,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_blob) return ut_assert_result,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_date) return ut_assert_result,
  not instantiable member function run_expectation(self in ut_expectation, a_actual ut_data_value_timestamp) return ut_assert_result,
  member function build_assert_result(self in ut_expectation, a_assert_result boolean, a_actual ut_data_value) return ut_assert_result
) not final not instantiable
/
