create or replace package min_grant_user_exp is

  --%suite(minimum grant user tests)
  
  --%test(execute join by test)
  procedure test_join_by_cursor;  
 
  --%test(execute contain test)
  procedure test_include_cursor;  
 
end;
/
