create or replace package test_expectations_cursor is

  --%suite(expectations - cursor)
  --%suitepath(utplsql.core.expectations.cursor)

  --%aftereach
  procedure cleanup_expectations;

  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;

  --%test(Compares data from cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure with_temp_table;

  --%test(Returns success for identical data)
  procedure success_on_same_data;

  --%test(Returns success when both cursors are empty)
  procedure success_on_empty;

  --%test(Returns success when both cursors are null)
  procedure success_on_null;

  --%test(Returns failure when one cursor is empty and another is null)
  procedure fail_null_vs_empty;

  --%test(Returns failure when different data present in one of rows)
  procedure fail_on_difference;

  --%test(Returns failure when more rows exist in actual)
  procedure fail_on_expected_missing;

  --%test(Returns failure when more rows exist in expected)
  procedure fail_on_actual_missing;

end;
/