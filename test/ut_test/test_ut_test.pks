create or replace package test_ut_test is

  --%suite(ut_test)
  --%suitepath(utplsql.core)

  procedure execute_autonomous(a_sql varchar2);

  function run_test(a_path varchar2) return clob;

  function get_value(a_variable varchar2) return integer;

  --%afterall
  procedure drop_test_package;

  --%test(Disabled flag for a test skips the tests execution in suite)
  procedure disabled_test;

  --%test(Marks test as errored if aftertest raises exception)
  procedure aftertest_errors;

  --%test(Marks each test as errored if aftereach raises exception)
  procedure aftereach_errors;

  --%test(Marks test as errored if beforetest raises exception)
  procedure beforetest_errors;

  --%test(Marks each test as errored if beforeeach raises exception)
  procedure beforeeach_errors;


end;
/
