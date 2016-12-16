create or replace type ut_expectation_dsinterval under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null)
)
/
