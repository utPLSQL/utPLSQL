create or replace package test_expect_to_be_empty is

  --%suite((not)to_be_empty)
  --%suitepath(utplsql.core.expectations.unary)

  --%aftereach
  procedure cleanup_expectations;

  --%test(Gives success for an empty cursor)
  procedure success_be_empty_cursor;

  --%test(Gives failure for a non empty cursor)
  procedure fail_be_empty_cursor;

  --%test(Negated - Gives success for a non empty cursor)
  procedure success_not_be_empty_cursor;

  --%test(Negated - Gives failure for an empty cursor)
  procedure fail_not_be_empty_cursor;

  --%test(Gives success for an empty collection)
  procedure success_be_empty_collection;

  --%test(Gives failure for a non empty collection)
  procedure fail_be_empty_collection;

  --%test(Negated - Gives success for a non empty collection)
  procedure success_not_be_empty_coll;

  --%test(Negated - Gives failure for an empty collection)
  procedure fail_not_be_empty_collection;

  --%test(Gives failure for a NULL collection)
  procedure fail_be_empty_null_collection;

  --%test(Negated - Gives failure for an empty collection)
  procedure fail_not_be_empty_null_coll;

  --%test(Gives failure for an object)
  procedure fail_be_empty_object;

  --%test(Gives failure for a null object)
  procedure fail_be_empty_null_object;

  --%test(Gives failure for number)
  procedure fail_be_empty_number;

  --%test(Negated - Gives failure for an object)
  procedure fail_not_be_empty_object;

  --%test(Negated - Gives failure for a null object)
  procedure fail_not_be_empty_null_object;

  --%test(Negated - Gives failure for number)
  procedure fail_not_be_empty_number;

end;
/
