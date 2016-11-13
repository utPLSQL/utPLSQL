create or replace type ut_expectation_timestamp_tz under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_timestamp_tz, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_be_between(self in ut_expectation_timestamp_tz, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)
)
/
