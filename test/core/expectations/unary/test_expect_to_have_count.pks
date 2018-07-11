create or replace package test_expect_to_have_count is

  --%suite((not)to_have_count)
  --%suitepath(utplsql.core.expectations.unary)

  --%aftereach
  procedure cleanup_expectations;

  --%test(Gives success for an empty cursor)
  procedure success_have_count_cursor;

  --%test(Gives failure for a non empty cursor)
  procedure fail_have_count_cursor;

  --%test(Reports the content of cursor when cursor is not empty)
  procedure fail_have_count_cursor_report;

  --%test(Negated - Gives success for a non empty cursor)
  procedure success_not_have_count_cursor;

  --%test(Negated - Gives failure for an empty cursor)
  procedure fail_not_have_count_cursor;

  --%test(Gives success for an empty collection)
  procedure success_have_count_collection;

  --%test(Gives failure for a non empty collection)
  procedure fail_have_count_collection;

  --%test(Negated - Gives success for a non empty collection)
  procedure success_not_have_count_coll;

  --%test(Negated - Gives failure for an empty collection)
  procedure fail_not_have_count_coll;

  --%test(Gives failure for a NULL collection)
  procedure fail_have_count_null_coll;

  --%test(Negated - Gives failure for an empty collection)
  procedure fail_not_have_count_null_coll;

  --%test(Gives failure for an object)
  procedure fail_have_count_object;

  --%test(Gives failure for a null object)
  procedure fail_have_count_null_object;

  --%test(Gives failure for number)
  procedure fail_have_count_number;

  --%test(Negated - Gives failure for an object)
  procedure fail_not_have_count_object;

  --%test(Negated - Gives failure for a null object)
  procedure fail_not_have_count_null_obj;

  --%test(Negated - Gives failure for number)
  procedure fail_not_have_count_number;

end;
/
