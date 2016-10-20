create or replace type ut_expectation_timestamp_ltz under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_timestamp_ltz, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)
)
/
