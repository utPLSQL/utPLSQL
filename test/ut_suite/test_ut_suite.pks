create or replace package test_ut_suite is

  --%suite(ut_suite)
  --%suitepath(utplsql.core)

  --%afterall
  procedure drop_test_package;

  --%test(Disabled flag skips tests execution in suite)
  procedure disabled_suite;

  --%test(Marks each test as errored if beforeall raises exception)
  procedure beforeall_errors;

  --%test(Reports warnings for each test if afterall raises exception)
  procedure aftereall_errors;

end;
/
