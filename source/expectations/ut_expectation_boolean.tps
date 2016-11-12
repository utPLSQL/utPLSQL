create or replace type ut_expectation_boolean under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_boolean, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure to_be_true(self in ut_expectation_boolean),
  member procedure to_be_false(self in ut_expectation_boolean)
)
/
