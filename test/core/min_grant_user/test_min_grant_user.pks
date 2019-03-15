create or replace package test_min_grant_user is

  --%suite(minimum grant user tests)
  --%suitepath(utplsql.core)

  --%test(execute join by test)
  procedure test_join_by_cursor;  
 
end;
/
