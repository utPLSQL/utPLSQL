create or replace package ut3$user#.test_cursor_grants is
  --%suite()

  procedure run_test_join_by_cursor; 
  procedure run_test_equal_cursor;
  procedure run_test_not_empty_cursor;
  procedure run_test_have_count_cursor;
  procedure run_test_empty_cursor;  
  procedure run_test_equal_non_diff_sql; 
  
  --%test(execute join by test)
  procedure test_join_by_cursor;
  
  --%test(execute equal test)
  procedure test_equal_cursor;
  
  --%test(execute not empty test)
  procedure test_not_empty_cursor;
  
  --%test(execute have_count test)
  procedure test_have_count_cursor;
  
  --%test(execute empty test)
  procedure test_empty_cursor;  
  
  --%test(execute test with non diff datatype)
  procedure test_equal_non_diff_sql;
  
end;
/
