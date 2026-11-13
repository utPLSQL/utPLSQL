create or replace package test_ut_coverage_gate is

  --%suite(ut_coverage_gate)
  --%suitepath(utplsql.ut3_tester.core)

  --%test(coverage_pct returns percentage of covered lines)
  procedure pct_full_and_partial;

  --%test(coverage_pct returns zero when there is nothing to cover)
  procedure pct_zero_denominator;

  --%test(coverage_pct rounds to two decimals)
  procedure pct_rounding;

  --%test(assert_coverage passes when coverage meets or exceeds threshold)
  procedure assert_pass_equal_and_above;

  --%test(assert_coverage is a no-op for null or negative threshold)
  procedure assert_noop_null_and_negative;

  --%test(assert_coverage raises ORA-20218 with parseable message below threshold)
  procedure assert_fails_below_threshold;

  --%test(assert_coverage prepends custom message when given)
  procedure assert_fails_with_custom_message;

end;
/
