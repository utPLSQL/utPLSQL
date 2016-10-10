create or replace type ut_assertion_timestamp_tz under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_timestamp_tz, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)
)
/
