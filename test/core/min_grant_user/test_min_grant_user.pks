create or replace package test_min_grant_user is

  --%suite(minimum grant user tests)
  --%suitepath(utplsql.core)

  --%beforeall
  procedure create_ut3$user#_tests;

  --%afterall
  procedure drop_ut3$user#_tests;
  
  --%test(execute join by test)
  procedure test_join_by_cursor;  
 
end;
/
