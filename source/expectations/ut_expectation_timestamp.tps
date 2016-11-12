create or replace type ut_expectation_timestamp under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_timestamp, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)
)
/
