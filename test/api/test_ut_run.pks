create or replace package test_ut_run is
  --%suite(ut_run)

  procedure create_test_suite;
  procedure drop_test_suite;

  --%test(ut.run - raises after completing all tests if a test fails with ORA-04068 or ORA-04061)
  --%beforetest(create_test_suite)
  --%aftertest(drop_test_suite)
  procedure raise_in_invalid_state;
end;
/
