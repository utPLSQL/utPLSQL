create or replace package test_expectations_cursor is

  --%suite(expectations - cursor)
  --%suitepath(utplsql.core.expectations.cursor)

  type t_test_record is record ( 
     my_num number(9,0),
     my_string varchar2(4000),
     my_clob clob,
     my_date date);

  type t_test_table is table of t_test_record index by binary_integer;


  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;
  
  --%test(Test cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure test_cursor_w_temp_table;

  --%test(Test cursor comparison success)
  procedure test_cursor_success;

  --%test(Test cursor comparison success when both empty)
  procedure test_cursor_success_on_empty;

  --%test(Test cursor comparison fails on different content)
  procedure test_cursor_fail_on_difference;

  --%test(Test cursor comparison fails on missing row in expected cursor)
  procedure test_cursor_fail_on_expected_missing;

  --%test(Test cursor comparison fails on missing row in actual cursor)
  procedure test_cursor_fail_on_actual_missing;
end;
/