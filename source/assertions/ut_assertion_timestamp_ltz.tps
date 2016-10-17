create or replace type ut_assertion_timestamp_ltz under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_timestamp_ltz, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)
)
/
