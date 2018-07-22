create or replace package test_expect_to_be_empty is

  --%suite
  --%suitepath(utplsql.core.expectations.unary)

  --%aftereach
  procedure cleanup_expectations;

  --%context(to_be_empty)

  --%test(Gives success for an empty cursor)
  procedure success_be_empty_cursor;

  --%test(Gives failure for a non empty cursor)
  procedure fail_be_empty_cursor;

  --%test(Reports the content of cursor when cursor is not empty)
  procedure fail_be_empty_cursor_report;

  --%test(Gives success for an empty collection)
  procedure success_be_empty_collection;

  --%test(Gives failure for a non empty collection)
  procedure fail_be_empty_collection;

  --%test(Gives failure for a NULL collection)
  procedure fail_be_empty_null_collection;

  --%test(Gives failure for an object)
  procedure fail_be_empty_object;

  --%test(Gives failure for a null object)
  procedure fail_be_empty_null_object;

  --%test(Gives failure for number)
  procedure fail_be_empty_number;

  --%test(Gives success for an empty CLOB)
  procedure success_be_empty_clob;

  --%test(Gives failure for a non empty CLOB)
  procedure fail_be_empty_clob;

  --%test(Gives success for an empty BLOB)
  procedure success_be_empty_blob;

  --%test(Gives failure for a non empty BLOB)
  procedure fail_be_empty_blob;

  --%endcontext

  --%context(not_to_be_empty)

  --%test(Gives failure for an empty cursor)
  procedure fail_not_be_empty_cursor;

  --%test(Gives success for a non empty cursor)
  procedure success_not_be_empty_cursor;

  --%test(Gives success for a non empty collection)
  procedure success_not_be_empty_coll;

  --%test(Gives failure for an empty collection)
  procedure fail_not_be_empty_collection;

  --%test(Gives failure for an empty collection)
  procedure fail_not_be_empty_null_coll;

  --%test(Gives failure for an object)
  procedure fail_not_be_empty_object;

  --%test(Gives failure for a null object)
  procedure fail_not_be_empty_null_object;

  --%test(Gives failure for number)
  procedure fail_not_be_empty_number;

  --%test(Gives failure for an empty CLOB)
  procedure fail_not_be_empty_clob;

  --%test(Gives success for a non empty CLOB)
  procedure success_not_be_empty_clob;

  --%test(Gives failure for an empty BLOB)
  procedure fail_not_be_empty_blob;

  --%test(Gives success for a non empty BLOB)
  procedure success_not_be_empty_blob;

  --%endcontext

end;
/
