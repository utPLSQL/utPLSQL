create or replace package test_to_be_within is

  --%suite((not)to_be_within)
  --%suitepath(utplsql.test_user.expectations.binary)
  
  --%aftereach
  procedure cleanup_expectations;

  --%test(gives success for values within a distance)
  procedure success_tests;

  --%test(gives failure when number is not within distance)
  procedure failed_tests;
 
  --%test(Check failure message for number not within)
  procedure fail_for_number_not_within;
  
  --%test(Check failure message for inteval of 1 sec not within)
  procedure fail_for_ds_int_not_within;  
  
  --%test(Check failure message for custom ds interval not within)
  procedure fail_for_custom_ds_int;    
  
  --%test(Check failure message for inteval of 1 month not within)
  procedure fail_for_ym_int_not_within;  
  
  --%test(Check failure message for custom ym interval not within)
  procedure fail_for_custom_ym_int;   
  
end;
/
