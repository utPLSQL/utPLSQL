create or replace type ut_expectation_number under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_number, a_expected number, a_nulls_are_equal boolean := null),
  member procedure to_be_between(self in ut_expectation_number, a_lower_bound number, a_higher_bound number)
)
/
