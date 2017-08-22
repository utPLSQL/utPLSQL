create or replace package test_expectations_cursor is

  --%suite(expectations - cursor)
  --%suitepath(utplsql.core.expectations.cursor)

  
  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;
  
  --%test(Test cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure test_cursor_w_temp_table;

   type t_gtt_data_r is record (
      value varchar2(250)
      );
   type t_gtt_data_t is table of t_gtt_data_r index by binary_integer;
end;
/