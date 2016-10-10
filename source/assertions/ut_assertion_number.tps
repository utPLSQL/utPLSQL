create or replace type ut_assertion_number under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_number, a_expected number, a_nulls_are_equal boolean := null)
)
/
