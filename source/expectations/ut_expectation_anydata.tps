create or replace type ut_expectation_anydata under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_anydata, a_expected anydata, a_nulls_are_equal boolean := null)
)
/
