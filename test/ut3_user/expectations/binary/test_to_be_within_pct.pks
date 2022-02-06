create or replace package test_to_be_within_pct is

  --%suite((not)to_be_within_pct)
  --%suitepath(utplsql.test_user.expectations.binary)
  
  --%aftereach
  procedure cleanup_expectations;

  --%test(gives success for values within a distance)
  procedure success_tests;

  --%test(gives failure when number is not within distance)
  procedure failed_tests;
 
  --%test(returns well formatted failure message when expectation fails)
  procedure fail_for_number_not_within;

  --%test(fails at compile or run time for unsupported data-types )
  procedure fail_at_invalid_argument_types;

end;
/
