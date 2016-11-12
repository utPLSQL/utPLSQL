create or replace type ut_expectation_date under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_date, a_expected date, a_nulls_are_equal boolean := null)
)
/
