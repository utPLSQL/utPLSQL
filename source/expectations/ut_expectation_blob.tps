create or replace type ut_expectation_blob under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_blob, a_expected blob, a_nulls_are_equal boolean := null)
)
/
