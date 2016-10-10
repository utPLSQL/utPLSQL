create or replace type ut_assertion_date under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_date, a_expected date, a_nulls_are_equal boolean := null)
)
/
