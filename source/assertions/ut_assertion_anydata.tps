create or replace type ut_assertion_anydata under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_anydata, a_expected anydata, a_nulls_are_equal boolean := null)
)
/
