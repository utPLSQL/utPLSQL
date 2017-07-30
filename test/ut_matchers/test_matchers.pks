create or replace package test_matchers is

  --%suite(matchers)
  --%suitepath(utplsql.core)
  
  --%test
  procedure test_be_less_than;  
  --%test
  procedure test_be_greater_or_equal;
  --%test
  procedure test_be_greater_than;
  --%test
  procedure test_be_less_or_equal;
  --%test
  procedure test_be_between;
  --%test
  procedure test_be_between2;
  --%test
  procedure test_match;
  --%test
  procedure test_be_empty_cursor;
  --%test
  procedure test_be_nonempty_cursor;
  --%test
  procedure test_be_empty_collection;
  --%test
  procedure test_be_nonempty_collection;
  --%test
  --%disabled
  procedure test_be_empty_others;
  
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
