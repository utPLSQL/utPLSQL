create or replace type ut_expectation_yminterval under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_yminterval, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null)
)
/
