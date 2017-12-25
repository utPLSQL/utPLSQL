create or replace package test_ut_suite is

  --%suite(ut_suite)
  --%suitepath(utplsql.core)

  --%beforeall
  procedure create_test_packages;
  --%afterall
  procedure drop_test_packages;

  --%test(Disabled flag skips tests execution in suite)
  procedure disabled_suite;

  --%test(Marks each test as errored if beforeall raises exception)
  procedure beforeall_errors;

  --%test(Reports warnings for each test if afterall raises exception)
  procedure aftereall_errors;

  --%test(Fails all tests in package when package has no body)
  procedure package_without_body;

  --%test(Fails all tests in package when package body is invalid)
  procedure package_with_invalid_body;

end;
/
