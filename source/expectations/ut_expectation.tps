create or replace type ut_expectation as object(
  name        varchar2(4000),
  expected    ut_data_value,
  member function run_expectation(a_actual ut_data_value) return boolean
) not final not instantiable
/
