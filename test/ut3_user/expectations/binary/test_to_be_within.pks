create or replace package test_to_be_within is

  --%suite((not)to_be_within)
  --%suitepath(utplsql.test_user.expectations.binary)
  
  --%aftereach
  procedure cleanup_expectations;

  --%test(gives success for values within a distance)
  procedure success_tests;

  --%test(gives failure when value is not within distance)
  procedure failed_tests;
 
  --%test(returns well formatted failure message when expectation fails)
  procedure fail_for_number_not_within;
  
  --%test(returns well formatted failure message for inteval of 1 sec not within)
  procedure fail_for_ds_int_not_within;  
  
  --%test(returns well formatted failure message for custom ds interval not within)
  procedure fail_for_custom_ds_int;    
  
  --%test(returns well formatted failure message for inteval of 1 month not within)
  procedure fail_for_ym_int_not_within;  
  
  --%test(returns well formatted failure message for custom ym interval not within)
  procedure fail_for_custom_ym_int;   
   
  --%test(returns well formatted failure message for simple within)
  procedure fail_msg_when_not_within;  
    
  --%test(returns well formatted failure message when comparing different datatypes)
  procedure fail_msg_wrong_types;

  --%test(failure on null expected value)
  procedure null_expected;

  --%test(failure on null actual value)
  procedure null_actual;

  --%test(failure on null expected and actual value)
  procedure null_actual_and_expected;

  --%test(failure on null distance value)
  procedure null_distance;

  --%test(failure on invalid distance datatype for number expected)
  procedure invalid_distance_for_number;

  --%test(failure on invalid distance datatype for timestamp expected)
  procedure invalid_distance_for_timestamp;

  --%test(failure on exceeding difference in day second time by nanosecond)
  procedure failure_on_tiny_time_diff;

  --%test(failure when comparing very large year difference)
  procedure failure_on_large_years_compare;

end;
/
