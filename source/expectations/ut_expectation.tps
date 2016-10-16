create or replace type ut_expectation as object(
  name            varchar2(250),
  additional_info varchar2(4000),
  expected        ut_data_value,
  member function run_expectation(self in out nocopy ut_expectation, a_actual ut_data_value) return boolean
) not final not instantiable
/
