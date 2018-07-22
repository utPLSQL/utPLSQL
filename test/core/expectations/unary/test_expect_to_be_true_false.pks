create or replace package test_expect_to_be_true_false
is
  --%suite(to_be_true/false)
  --%suitepath(utplsql.core.expectations.unary)

  --%aftereach
  procedure cleanup_expectations;

  --%test(to_be_true - Gives failure with null boolean)
  procedure to_be_true_null_boolean;

  --%test(to_be_true - Gives success with true expression)
  procedure to_be_true_success;

  --%test(to_be_true - Gives failure with false expression)
  procedure to_be_true_failure;

  --%test(to_be_true - Gives failure with non-boolean data type)
  procedure to_be_true_bad_type;

  --%test(not_to_be_true - Gives failure with null boolean)
  procedure not_to_be_true_null_boolean;

  --%test(not_to_be_true - Gives failure with true expression)
  procedure not_to_be_true_success;

  --%test(not_to_be_true - Gives success with false expression)
  procedure not_to_be_true_failure;

  --%test(not_to_be_true - Gives failure with non-boolean data type)
  procedure not_to_be_true_bad_type;

  --%test(to_be_false - Gives failure with null boolean)
  procedure to_be_false_null_boolean;

  --%test(to_be_false - Gives failure with true expression)
  procedure to_be_false_success;

  --%test(to_be_false - Gives success with false expression)
  procedure to_be_false_failure;

  --%test(to_be_false - Gives failure with non-boolean data type)
  procedure to_be_false_bad_type;

  --%test(not_to_be_false - Gives failure with null boolean)
  procedure not_to_be_false_null_boolean;

  --%test(not_to_be_false - Gives success with true expression)
  procedure not_to_be_false_success;

  --%test(not_to_be_false - Gives failure with false expression)
  procedure not_to_be_false_failure;

  --%test(not_to_be_false - Gives failure with non-boolean data type)
  procedure not_to_be_false_bad_type;

end;
/
