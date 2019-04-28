create or replace package test_equal is

  --%suite((not)to_be_equal)
  --%suitepath(utplsql.test_user.expectations.binary)

  procedure reset_nulls_equal;

  --%aftereach
  procedure cleanup_expectations;

  --%test(Gives failure for different data types)
  procedure equal_fail_on_type_diff;
  --%test(Negated - gives failure for different data types)
  procedure not_equal_fail_on_type_diff;
  --%test(Gives failure for different data values)
  procedure failure_on_data_diff;
  --%test(Gives failure when actual is null)
  procedure failure_on_actual_null;
  --%test(Gives failure when expected is null)
  procedure failure_on_expected_null;
  --%test(Gives failure when both values are null and argument nulls_are_equal is false)
  procedure failure_on_both_null_with_parm;

  --%test(Gives failure when both values are null and configuration nulls_are_equal is false)
  --%aftertest(reset_nulls_equal)
  procedure failure_on_both_null_with_conf;

  --%test(Gives success for equal values)
  procedure success_on_equal_data;
  --%test(Gives success when both values are null)
  procedure success_on_both_null;

  --%test(Gives success when both values are null and argument nulls_are_equal is true)
  --%aftertest(reset_nulls_equal)
  procedure success_on_both_null_with_parm;

end;
/
