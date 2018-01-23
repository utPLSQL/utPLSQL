create or replace package test_matchers is

  --%suite(matchers)
  --%suitepath(utplsql.core.expectations)

  --%aftereach
  procedure cleanup_expectations;

  --%test
  procedure test_be_between2;
  --%test
  procedure test_match;

  --%test
  procedure test_be_like;
  
  --%test
  procedure test_timestamp_between;
  
  --%test
  procedure test_timestamp_ltz_between;
  
  --%test
  procedure test_timestamp_tz_between;

end test_matchers;
/
