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

  --%test(Returns failure when different column name is used in cursors)
  procedure fail_on_different_column_name;

  --%test(Returns failure when different column ordering is used in cursors)
  procedure fail_on_different_column_order;

  --%test(Returns failure when different row ordering is used in cursors)
  procedure fail_on_different_row_order;

  --%test(Ignores time part of date when NLS is not set)
  procedure ignore_time_part_of_date;

  --%test(Compares time part of date when NLS is set)
  procedure include_time_in_date_with_nls;

  --%test(List of columns to exclude is case sensitive)
  procedure exclude_Columns_as_list;

  --%test(Columns to exclude are case sensitive)
  procedure excludes_columns_as_csv;

  --%test(Exclude columns fails on invalid XPath)
  procedure exclude_columns_xpath_invalid;

  --%test(Exclude columns by XPath is case sensitive)
  procedure exclude_columns_xpath;

  --%test(Reports data-diff on expectation failure)
  procedure data_diff_on_failure;


  procedure prepare_table;
  procedure cleanup_table;

  --%test(Compares cursor on table to cursor on plsql data)
  --%beforetest(prepare_table)
  --%aftertest(cleanup_table)
  procedure compares_sql_and_plsql_types;

    --%test(Closes the cursor after use)
  procedure closes_cursor_after_use;

  --%test(Closes the cursor after use when exception was raised)
  procedure closes_cursor_after_use_on_err;

  --%test(Reports exception when cursor raises exception)
  procedure reports_on_exception_in_cursor;

  --%test(Reports exception when cursor is closed)
  --%disabled
  procedure reports_on_closed_cursor;

end;
/