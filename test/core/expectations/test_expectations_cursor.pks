create or replace package test_expectations_cursor is

  --%suite(expectations - cursor)
  --%suitepath(utplsql.core.expectations.cursor)

  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;

  --%test(Compares data from cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure test_cursor_w_temp_table;

  --%test(Returns success for identical data)
  procedure test_cursor_success;

  --%test(Returns success when both cursors are empty)
  procedure test_cursor_success_on_empty;

  --%test(Returns failure when different data present in one of rows)
  procedure test_cursor_fail_on_difference;

  --%test(Returns failure when more rows exist in actual)
  procedure fail_on_expected_missing;

  --%test(Returns failure when more rows exist in expected)
  procedure fail_on_actual_missing;
end;
/