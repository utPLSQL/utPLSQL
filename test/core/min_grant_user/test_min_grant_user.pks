create or replace package test_min_grant_user is

  --%suite(minimum grant user tests)
  --%suitepath(utplsql.core)

  --%test(execute join by test)
  procedure test_join_by_cursor;  
  
   --%test(execute equal test)
  procedure test_equal_cursor;  
  
   --%test(execute not_empty test)
  procedure test_not_empty_cursor;  

   --%test(execute have_count test)
  procedure test_have_count_cursor;  
 
   --%test(execute empty test)
  procedure test_empty_cursor;  

end;
/
